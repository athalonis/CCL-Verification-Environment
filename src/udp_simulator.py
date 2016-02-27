#!/usr/bin/env python2.7
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



ACK = 1
NACK = 2
HW_CFG = 3
STATUS = 4
SSTIM = 5
ESTIM = 6
RESTART = 7
ERRCNT = 8
ERRSTR = 9
ERRDRP = 10
ERRNXT = 11
ERRRD = 12
SEND_PX = 14
SEND_BOX = 15
SET_FLL_LVL = 16



name_types = {
        ACK      : "ACK",
        NACK     : "NACK",
        HW_CFG   : "HW_CFG",
        STATUS   : "STATUS",
        SSTIM    : "SSTIM",
        ESTIM    : "ESTIM",
        RESTART  : "RESTART",
        ERRCNT   : "ERRCNT",
        ERRSTR   : "ERRSTR",
        ERRDRP   : "ERRDRP",
        ERRNXT   : "ERRNXT",
        ERRRD    : "ERRRD",
        SEND_PX  : "SEND_PX",
        SEND_BOX : "SEND_BOX",
        SET_FLL_LVL : "SET_FLL_LVL",
        }

debug_level = 10

def debug(m, level):
    if debug_level > 0:
        if debug_level >= level:
            print (str(m))
import math
import random

class verifier_dec:


    def __init__ (self, port=55328, ip="192.168.42.23"):
        self.__hwcfg_read = False
        self.__port = port
        self.__ip = ip
        self.__com = udp_com(self, port, ip)
        self.__com.start()
        "state (1 Byte: IDLE=0, RESTART=1, RUN=2, CHECK_LAST=3, CHECK_DONE=4)"
        self.__state = 0
        self.__cnt = 0
        self.__err_cnt = 0
        self.__err_drp = 0
        self.__err_str = 0
        self.__err_end = 0
        self.__err_str_nxt = 0
        self.__err_end_nxt = 0
        self.__err_last = 0
        self.__starttime = 0
        self.__fifo_fill_lvl = 0
        # how many errors should be generated?
        self.__amount_of_errors = 0.99
        self.__speed = 125000000 # in Hz
        self.__clks_per_px = 2.1 # clks per pixel

        self.img_height = 5
        self.img_width = 9
        self.fifo_max = 1024
        self.hw_version = 244
        self.max_data_size = 160
        self.instances = 60

        self.__max_img_height_len = int(math.ceil(math.log(self.img_height+1, 2)))
        self.__max_img_height_len_byte = int(math.ceil(self.__max_img_height_len))
        self.__max_img_width_len = int(math.ceil(math.log(self.img_width+1, 2)))
        self.__max_img_width_len_byte = int(math.ceil(self.__max_img_width_len))
        self.__fifo_len = int(math.ceil(math.log(self.fifo_max+1, 2)))
        self.__fifo_len_byte = int(math.ceil(self.__fifo_len/8.0))
        self.__stim_len = self.img_height*self.img_width
        self.__stim_len_len_byte = int(math.ceil((math.ceil(math.log(self.img_height*self.img_width, 2)))/8.0))
        self.__stim_len_byte = int(math.ceil(self.__stim_len/8.0))
        self.__max_img_height = 2**self.__max_img_height_len
        self.__max_img_width = 2**self.__max_img_width_len
        self.__instances_len_byte = int(math.ceil((math.ceil(math.log(self.instances, 2)))/8.0))
        self.__box_len = int(2*math.ceil(math.log(self.img_height+1, 2)) +
                2*math.ceil(math.log(self.img_width+1, 2)))
        self.__box_len_byte = int(math.ceil(self.__box_len/8.0))



    def close(self):
        print "verifier_dec closing"
        self.__com.close()

    def __del__(self):
        self.close()

    ## process received ACK package called by udp_com
    def T_ACK (self, recv_data):

        debug("received " + name_types[ACK] + " data: " + str(hex(recv_data)), 10)


    ## process received NACK package called by udp_com
    def T_NACK (self, recv_data):

        print ("Received " + name_types[NACK] + " with message: " + recv_data)

    """
    HW_config[r]
        response:
            HW-Version (4 Bytes -> hg revision)
            MAX_DATA_LENGTH (2 Bytes)
            length of max_img_width (1 Byte)
            max_img_width
            img_width
            length of max_img_height  (1 Byte)
            max_img_height
            img_height
            length of box size (1 Byte)
            box size
            length of stimuli (log2(stimuli length)) (1 Byte)
            stimuli length
            length of instances (1 Byte)
            instances
    """

    ## decodes response to HW_CFG
    # @param data is the data string as a ascii string
    def T_HW_CFG (self, data, ip, port, recv_id):
        print("HW_CFG received")
        tmp = ""
        tmp += self.__com.int_conv(self.hw_version, 4)
        tmp += self.__com.int_conv(self.max_data_size, 2)
        tmp += self.__com.int_conv(self.__max_img_width_len_byte, 1)
        tmp += self.__com.int_conv(self.__max_img_width, self.__max_img_width_len_byte)
        tmp += self.__com.int_conv(self.img_width, self.__max_img_width_len_byte)
        tmp += self.__com.int_conv(self.__max_img_height_len_byte, 1)
        tmp += self.__com.int_conv(self.__max_img_height, self.__max_img_height_len_byte)
        tmp += self.__com.int_conv(self.img_height, self.__max_img_height_len_byte)
        tmp += self.__com.int_conv(self.__box_len_byte, 1)
        tmp += self.__com.int_conv(self.__box_len, self.__box_len_byte)
        tmp += self.__com.int_conv(self.__stim_len_len_byte, 1)
        tmp += self.__com.int_conv(self.__stim_len, self.__stim_len_len_byte)
        tmp += self.__com.int_conv(self.__instances_len_byte, 1)
        tmp += self.__com.int_conv(self.instances, self.__instances_len_byte)
        tmp += self.__com.int_conv(5, 1)
        tmp += self.__com.int_conv(0, 1)
        tmp += self.__com.int_conv(0, 1)
        tmp += self.__com.int_conv(42, 1)
        tmp += self.__com.int_conv(10, 1)

        self.__com.send(ACK, tmp, 0, recv_id, ip, port)

    def update_cnt(self):
        if self.__state == 2 or self.__state == 3:
            currtime = int(round(time.time() * 1000)) # in ms
            self.__cnt = int(((currtime - self.__starttime)*1.0) *
                    ((self.__speed/1000.0)*self.instances) /
                    (self.__clks_per_px*self.img_height*self.img_width))
            if self.__cnt >= self.__err_end - self.__err_str:
                self.__cnt = self.__err_end
                self.__state = 4
        elif self.__state == 0:
            self.__cnt = 0
        elif self.__state == 4:
            self.__cnt = self.__err_end

    def udpate_err_cnt(self):
        self.update_cnt()
        old_err_cnt = self.__err_cnt
        self.__err_cnt = int(self.__cnt * self.__amount_of_errors)
        new_errors = self.__err_cnt - old_err_cnt
        fifo_free = (self.fifo_max - self.__fifo_fill_lvl)
        if fifo_free <= new_errors:
            self.__fifo_fill_lvl = self.fifo_max
            self.__err_drp = new_errors - fifo_free
        else:
            self.__fifo_fill_lvl += new_errors

    def next_error(self):
        self.udpate_err_cnt()
        err_off = random.random()*(self.__cnt-self.__err_last-self.__fifo_fill_lvl)
        self.__err_last += int(err_off + 1)
        err_type = int(round(1 + random.random()*3))
        return (err_type, self.__err_last)


    ## decodes responses to STATUS
    # @param data is the data string as a ascii string
    def T_STATUS (self, data, ip, port, recv_id):
        print ("STATUS received")

        "state (1 Byte: IDLE=0, RESTART=1, RUN=2, CHECK_LAST=3, CHECK_DONE=4)"
        self.update_cnt()

        tmp = self.__com.int_conv(self.__state, 1)
        tmp2 = self.__com.int_conv(self.__cnt, self.__stim_len_byte)
        self.__com.send(ACK, tmp + tmp2, 0, recv_id, ip, port)

    ## decodes responses to SSTIM
    # @param data is the data string as a ascii string
    def T_SSTIM (self, data, ip, port, recv_id):
        debug("sstim_len_byte: " + str(self.__stim_len_byte) + " len_data " +
                str(len(data)) + ", data=" + data.encode("HEX"), 10)
        if len(data) != self.__stim_len_byte:
            self.__com.send(NACK, "wrong stimuli size", 0, recv_id, ip, port)
        else:
            self.__err_str_nxt = self.__com.str_conv_int(data)
            self.__com.send(ACK, "", 0, recv_id, ip, port)

    ## decodes responses to ESTIM
    # @param data is the data string as a ascii string
    def T_ESTIM (self, data, ip, port, recv_id):
        if len(data) != self.__stim_len_byte:
            self.__com.send(NACK, "wrong stimuli size", 0, recv_id, ip, port)
        else:
            self.__err_end_nxt = self.__com.str_conv_int(data)
            self.__com.send(ACK, "", 0, recv_id, ip, port)

    ## decodes responses to RESTART
    # @param data is the data string as a ascii string
    def T_RESTART (self, data, ip, port, recv_id):
        self.__err_end = self.__err_end_nxt
        self.__err_str = self.__err_str_nxt
        self.__state = 2

        self.__cnt = 0
        self.__err_cnt = 0
        self.__err_drp = 0
        self.__fifo_fill_lvl = 0
        self.__err_last = 0

        currtime = int(round(time.time() * 1000)) # in ms
        self.__starttime = currtime
        self.__com.send(ACK, "", 0, recv_id, ip, port)

    ## decodes responses to ERRCNT
    # @param data is the data string as a ascii string
    def T_ERRCNT (self, data, ip, port, recv_id):
        self.udpate_err_cnt()
        tmp = self.__com.int_conv(self.__err_cnt, self.__stim_len_byte)
        self.__com.send(ACK, tmp, 0, recv_id, ip, port)

    ## decodes responses to ERRSTR
    # @param data is the data string as a ascii string
    def T_ERRSTR (self, data, ip, port, recv_id):
        self.udpate_err_cnt()
        tmp = self.__com.int_conv(self.__fifo_fill_lvl, self.__fifo_len_byte)
        self.__com.send(ACK, tmp, 0, recv_id, ip, port)

    ## decodes responses to ERRDRP
    # @param data is the data string as a ascii string
    def T_ERRDRP (self, data, ip, port, recv_id):
        tmp = self.__com.int_conv(self.__err_cnt, self.__stim_len_byte)
        self.__com.send(ACK, tmp, 0, recv_id, ip, port)

    ## decodes responses to ERRNXT
    # @param data is the data string as a ascii string
    def T_ERRNXT (self, data, ip, port, recv_id):
        self.udpate_err_cnt()
        if self.__fifo_fill_lvl > 0:
            (err_type, err) = self.next_error()
            tmp = ""
            tmp += self.__com.int_conv(err_type, 1)
            tmp += self.__com.int_conv(err, self.__stim_len_byte)
            self.__com.send(ACK, tmp, 0, recv_id, ip, port)

        else:
            self.__com.send(NACK, "no errors to read", 0, recv_id, ip, port)

    ## decodes responses to ERRRD
    # @param data is the data string as a ascii string
    def T_ERRRD (self, data, ip, port, recv_id):
        self.udpate_err_cnt()
        if self.__fifo_fill_lvl > 0:
            self.__com.send(ACK, "", 0, recv_id, ip, port)
            self.__fifo_fill_lvl -= 1
        else:
            self.__com.send(NACK, "no errors to read", 0, recv_id, ip, port)

    def T_SEND_PX (self, data, ip, port, recv_id):
        self.__com.send(ACK, "", 0, recv_id, ip, port)


    ## parses a string in hex in the format 1. byte [length of value], [value] ,...
    # @param data the hex value as string
    def __parse_value (data):
        length = int(data[0], 16)
        value = int(data[1:length], 16)

        return (length, value)

    # map types to methodes
    send_types = {
            ACK      : T_ACK,
            NACK     : T_NACK,
            }

    recv_types = {
            HW_CFG   : T_HW_CFG,
            STATUS   : T_STATUS,
            SSTIM    : T_SSTIM,
            ESTIM    : T_ESTIM,
            RESTART  : T_RESTART,
            ERRCNT   : T_ERRCNT,
            ERRSTR   : T_ERRSTR,
            ERRDRP   : T_ERRDRP,
            ERRNXT   : T_ERRNXT,
            ERRRD    : T_ERRRD,
            SEND_PX  : T_SEND_PX,
            }



import threading
import time

class udp_com(threading.Thread):
    def __init__ (self, decoder, port=55328, ip="192.168.42.23"):
        super(udp_com, self).__init__()

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

        self.__id = 0

    def close (self):
        self.__enable = False
        self.__recv.disable()
        self.__con.close()
        self.__recv.close()
        print("udp_com will join")
        self.join()
        print("udp_com ended")

    def __del__(self):
        self.close()

    ## sends a message to the fpga with type and data, the id and length is
    # generated
    # @param data_type number in range of 0..2^16-1
    def send(self, data_type, data=None, try_cnt=0, send_id=-1, ip=None, port=None):

        if send_id == -1:
            send_id = self.__id
            self.__id += 1

        leng_bin = self.int_conv(0, 2)
        if data is None:
            data = ""
        else:
            leng_bin = self.int_conv(len(data), 2)

        send_id_bin = self.int_conv(send_id, 2)
        data_type_bin = self.int_conv(data_type, 2)
        self.__con.send(data_type_bin + send_id_bin + leng_bin + data, ip, port)

        # store the package with the number of trys, timestampe to do resend
        timestamp = int(round(time.time() * 1000)) # in ms
        with self.__sema:
            self.__inpro[self.__id] = (data_type, data, try_cnt+1, timestamp)


    ## converts unsigned integer to string with a length of leng bytes
    #  @param value is the integer value to convert
    #  @param leng is the length of the resulting string in bytes
    #  @returns string with length of leng and the uint value coded in it
    def int_conv(self, value, leng):
        if value < 0 or value > 2**(8*leng):
            raise IndexError('integer %r is out of bounds!' % value)

        ret = ""
        mask = 2**8-1

        for _ in range(leng):
            ret = chr(value & mask) + ret
            value >>= 8

        return ret

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
            ret += ord(data[-1])
            data = data[:-1]

        return ret


    def __parse_pkg(self, data):
        resp, ip, port = data
        print (str(data))
        print ("received from " + str(ip) +":" + str(port))
        recv_id = None
        if (len(resp) < 6):
            #invalid package
            #TODO hex(resp) will not work
            print("received invalid data: %r", str(hex(resp)))
        else:
            recv_type = self.str_conv_int(resp[:2])
            recv_id = self.str_conv_int(resp[2:4])
            length = self.str_conv_int(resp[4:6])
            print ("\ttype: " + name_types[recv_type])
            print ("\tid: " + str(recv_id))
            print ("\tlength: " + str(length))
            if len(resp) < length + 6:
                print "Message header error length field wrong"
            else:
                if length > 0:
                    recv_data = resp[6:6+length]
                else:
                    recv_data = None
                try:
                    print ("call specific methode do process command")
                    self.__decoder.recv_types[recv_type](self.__decoder, recv_data, ip, port, recv_id)
                except KeyError, e:
                    print "UNKNOWN: '" + resp +"'"
                    print e
                    #self.__decoder.T_UNKNOWN(resp, para)
        return recv_id


    def run(self):
        while self.__enable:
            self.__recv.event.wait(1.0 * self.__wait_timeout/3.0)
            if self.__recv.event.is_set() and self.__enable:
                # process received Data
                 self.__parse_pkg(self.__recv.getMessage())



import socket

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
        self.s.bind(('', port))

    def close(self):
        self.__enable = False
        self.__event.set()
        self.s.shutdown(socket.SHUT_RDWR)
        self.s.setblocking(False)
        self.s.settimeout(.1)
        time.sleep(1)
        self.s.close()
        self.join()
        print ("udp_con ended")

    def __del__(self):
        self.close()




    def send (self, data, ip, port):
        with self.__sema:
            self.__que.append((ip, port, data))
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
                    ip, port, msg = self.__que.popleft()
                    if len(self.__que) == 0:
                        self.__event.clear()
                self.s.sendto(msg, (ip, port))




from collections import deque
class udp_recv(threading.Thread):

    def __init__ (self, udp_con):
        super(udp_recv, self).__init__()
        self.__udp_con = udp_con
        self.__enable = True
        self.__que = deque([])
        self.event = threading.Event()
        self.__sema = threading.Semaphore()

    def close (self):
        self.__enable = False
        self.event.set()
        self.join()
        print("udp_recv ended")

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
                #only packages from the right ip are accepted
                self.__add_message((data, ip, port))
                p = (data, ip, port)
                print ("received: " + str(p))


if __name__== "__main__":
    hw_verifier = verifier_dec(ip="127.0.0.1")
    raw_input('To exit press any key')
    print('Try to exit')
    hw_verifier.close()
#    hw_verifier.read_hw()

