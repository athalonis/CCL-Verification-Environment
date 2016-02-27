#Copyright (c) 2014, Benjamin Bässler <ccl@xunit.de>
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#
#* Redistributions of source code must retain the above copyright notice, this
#  list of conditions and the following disclaimer.
#
#* Redistributions in binary form must reproduce the above copyright notice,
#  this list of conditions and the following disclaimer in the documentation
#  and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import threading
import socket
import sys
import time
import math
from collections import deque

debug_level = 0
debug_stderr = 0


def debug(m, level):
    if debug_level >= level:
        print((str(m)))
    if debug_stderr >= level:
        print(str(m), file=sys.stderr)

class ConnectionError(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)


class udp_com(threading.Thread):

    ## converts string to hex string
    toHex = lambda x:"".join([hex(ord(c))[2:].zfill(2) for c in x])

    def __init__ (self, name_types, decoder, port=55328, ip="192.168.42.23"):
        super(udp_com, self).__init__()

        self.name_types = name_types

        self.__port = port
        self.__ip = ip
        self.__con = udp_con(port, ip)
        self.__con.start()
        self.__recv = udp_recv(self.__con)
        self.__recv.start()

        self.__inpro = {}
        self.__sema = threading.Semaphore()

        self.__wait_timeout = 5 #in seconds
        self.__max_try = 5

        self.__enable = True
        self.__no_response = False

        self.__decoder = decoder

        self.__id = 1

    def close (self):
        self.__enable = False
        self.__recv.disable()
        print("closing connection")
        self.__con.close()
        print("connection closed")
        print("stopping receiver thread")
        self.__recv.close()
        self.__recv.event.set()
        print("receiver thread stopped")
        self.join()

    def __del__(self):
        self.close()

    ## sends a message to the fpga with type and data, the id and length is
    # generated
    # @param data_type number in range of 0..2^16-1
    def send(self, data_type, data=None, try_cnt=0, send_id=-1):

        d = (self.name_types[data_type], data, try_cnt, send_id)
        debug(">> send (type, data, try, id): " + str(d), 6)

        if send_id == -1:
            send_id = self.__id
            if self.__id == 2**16-1:
                self.__id = 1
            else:
                self.__id += 1

        debug(">> send (id): " + str(send_id), 6)

        leng_bin = self.int_conv(0, 2)
        if data is None:
            data = b""
        else:
            leng_bin = self.int_conv(len(data), 2)

        send_id_bin = self.int_conv(send_id, 2)
        data_type_bin = self.int_conv(data_type, 2)

        debug_data = ((data_type_bin + send_id_bin + leng_bin + data), None)
        debug(">> send_bin (" +  str(debug_data) + ")", 6)

        self.__con.send(b""+data_type_bin + send_id_bin + leng_bin + data)

        # store the package with the number of trys, timestampe to do resend
        timestamp = int(round(time.time() * 1000)) # in ms
        with self.__sema:
            self.__inpro[send_id] = (data_type, data, try_cnt+1, timestamp)



    ## converts unsigned integer to string with a length of leng bytes
    #  @param value is the integer value to convert
    #  @param leng is the length of the resulting string in bytes
    #  @returns string with length of leng and the uint value coded in it
    def int_conv(self, value, leng):
        debug("int_conv("+str(value)+", "+str(leng)+")\n", 10)

        if value < 0 or value > 2**(8*(leng+1))-1:
            raise IndexError('integer ' + str(value) + ' is out of bounds (max is '
                    + str(2**(8*(leng+1))-1) + ')!')

        return value.to_bytes(leng, byteorder='big')

    ## converts unsigned integer to string of 1/0 with a length of leng bits
    #  @param value is the integer value to convert
    #  @param leng is the length of the resulting string in bytes
    #  @returns string with length of leng and the uint value coded in it
    def int_binstr_conv(self, value, leng):
        debug("int_conv("+str(value)+", "+str(leng)+")\n", 10)
        
        if value >= 2**leng:
            raise IndexError(str(value) + ' can not be converted to a ' + str(leng) + ' bit value')
        elif value < 0:
            raise IndexError(str(value) + ' is negative')


        bits = ""
        for i in range(leng-1,-1,-1):
            if int(value/(2**i)) == 1:
                bits += '1'
                value -= (2**i)
            else:
                bits += '0'
        return bits

    ## converts a 8 byte long string with 1/0 to binary coded byte string
    def __binto_byte__(self, value):
        out = 0
        for i in range(0, len(value)):
            if value[len(value)-1-i] == '1':
                out += 2**i
        return out.to_bytes(1, byteorder='big')


    ## converts string of 1/0 to binary string with last byte padded with 0
    #  @param value is the string
    #  @returns the byte string
    def binstr_conv(self, value):
        pad = int(math.ceil(len(value)/8.0))*8 - len(value)
        for i in range(0, pad):
            value += '0'
        byte = b""
        for i in range(0, len(value), 8):
            byte += self.__binto_byte__(value[i:i+8])
        return byte


    ## converts received string to unsigned integer
    #  @param data is the string to convert
    #  @returns a integer value as result
    def str_conv_int(self, data):
        leng = len(data)

        #revert string
        data = data[::-1]
        ret = 0

        for _ in range(leng):
            ret <<= 8
            ret +=data[-1]
            data = data[:-1]

        return ret

    def toHex(self, data):
        ret ="0x"
        for i in range(0, len(data)):
            ret += '{:02x}'.format(data[i])
        return ret

    ## converts received string to unsigned integer with given bit position
    #  @param data is a binary string with the data to parse
    #  @param start means the first valid bit, start index is included
    #  @param end means the last valid bit, end index is included
    #  @returns a integer value as result
    def str_bit_conv_int(self, data, start, end):
        leng = len(data)

        ret = 0
        end+=1

        start_b = int(math.floor(start/8.0))
        end_b = int(math.ceil(end/8.0))

        tmp = data[start_b:end_b]
        #print(self.toHex(tmp))
        frmt='{:0'+ str(8*len(tmp))+'b}'
        ret += int(frmt.format(self.str_conv_int(tmp)), 2)

        pbits=(end_b)*8 - end
        ret >>= pbits
        ret = ret & (int(2**(end-start)-1))

        return ret



    def __parse_pkg(self, resp):
        recv_id = None
        if (len(resp) < 6):
            #invalid package
            debug("received invalid data: " + str(resp).encode("hex"), 1)
        else:
            recv_type = self.str_conv_int(resp[:2])
            recv_id = self.str_conv_int(resp[2:4])
            length = self.str_conv_int(resp[4:6])
            if len(resp) < length + 6:
                print("Message header error length field wrong")
            else:
                if length > 0:
                    recv_data = resp[6:]
                else:
                    recv_data = None
                debug("check if id in send que", 5)
                debug("\t que: " + str(self.__inpro), 9)
                if recv_id in self.__inpro:
                    debug("\tin send que", 5)
                    send_msg = self.__inpro[recv_id]
                    try:
                        d = (self.name_types[recv_type], recv_data, send_msg)
                        debug("<< recv (type,  data, id): " + str(d), 6)
                        self.__decoder.recv_types[recv_type](self.__decoder, recv_data, send_msg)
                    except KeyError as e:
                        print("UNKNOWN: '" + resp +"'")
                        print(e)
                        #self.__decoder.T_UNKNOWN(resp, para)
                else:
                    self.__decoder.recv_types[recv_type](self.__decoder,
                            recv_data, length)

        return recv_id


    def run(self):
        while self.__enable:
            self.__recv.event.wait(1.0 * self.__wait_timeout/3.0)
            if self.__recv.event.is_set() and self.__enable:
                # process received Data
                recv_id = self.__parse_pkg(self.__recv.getMessage())
                if recv_id is not None:
                    if recv_id in self.__inpro:
                        with self.__sema:
                            del self.__inpro[recv_id]


            currtime = int(round(time.time() * 1000)) # in ms
            mark_del = []
            resend = []
            with self.__sema:
                for key in self.__inpro:
                    (data_type, data, try_cnt, timestamp) = self.__inpro[key]
                    if currtime - timestamp >= self.__wait_timeout*1000:
                        mark_del.append(key)
                        resend.append((data_type, data, try_cnt, key))


            for e in mark_del:
                with self.__sema:
                    del self.__inpro[e]

            for data in resend:
                (data_type, data, try_cnt, key) = data
                self.__pkg_timedout(data_type, data, try_cnt, key)



    ## processes timedout packages (no ACK/NACK received in time)
    def __pkg_timedout(self, data_type, data, try_cnt, send_id):
        if try_cnt < self.__max_try:
            #just resend
            debug("PKG id:" +str(send_id) + " resend try: " + str(try_cnt+1), 6)
            self.send(data_type, data, try_cnt, send_id)
        else:
            #max trys exceeded so handle this error
            self.__enable = False
            self.__unable = True
            raise ConnectionError('Connection not possible ip: ' +
                    str(self.__ip) + ' port: ' + str(self.__port))


class udp_con(threading.Thread):

    def __init__ (self, port=55328, ip="192.168.42.23"):
        super(udp_con, self).__init__()
        # try to connect to the hw over udpimport socket
        self.port = port
        self.ip = ip
        self.__enable = True

        self.__que = deque([])
        self.__event = threading.Event()
        self.__sema = threading.Semaphore()

        self.s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.s.bind(('', 4242))

    def close(self):
        self.__enable = False
        self.__event.set()
        self.s.shutdown(socket.SHUT_RDWR)
        self.s.setblocking(False)
        self.s.settimeout(.1)
        self.join()

    def __del__(self):
        self.close()

    def send (self, data):
        if debug_level > 20:
            output = "0x"
            for c in data:
                output += str(hex(c)[2:])
            debug(("con.send_befor_enc: " + output), 20)

        with self.__sema:
            self.__que.append(data)
            self.__event.set()

    def disable (self):
        self.__enable = False

    def run (self):
        while self.__enable:
            # wait for new data to send
            self.__event.wait()

            if self.__enable:
                # deque message
                with self.__sema:
                    msg = self.__que.popleft()
                    if len(self.__que) == 0:
                        self.__event.clear()
                self.s.sendto(msg, (self.ip, self.port))
        self.s.close()



class udp_recv(threading.Thread):

    def __init__ (self, udp_con):
        super(udp_recv, self).__init__()
        self.__udp_con = udp_con
        self.__enable = True
        self.__que = deque([])
        self.event = threading.Event()
        self.__sema = threading.Semaphore()

    def close (self):
        self.__udp_con.s.settimeout(0.1)
        self.__enable = False
        self.event.set()
        #self.stop()
        self.join()

    def __del__(self):
        self.close()

    def disable (self):
        self.__enable = False


    def __add_message(self, m):
        with self.__sema:
            self.__que.append(m)
            self.event.set()

    def getMessage(self):
        with self.__sema:
            ret_msg = self.__que.popleft()
            if len(self.__que) == 0:
                self.event.clear()
        return ret_msg


    def run(self):
        while self.__enable:
            data, adr = self.__udp_con.s.recvfrom(1500)
            if self.__enable:
                ip, port = adr
                if self.__enable:
                    if ip == self.__udp_con.ip:
                        #only packages from the right ip are accepted
                        self.__add_message(data)
                        p = (data, ip, port)
                        debug("received: " + str(p), 3)
                    else:
                        debug("Ignore package from: " + str(adr), 1)


