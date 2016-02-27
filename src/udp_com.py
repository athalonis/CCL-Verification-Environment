#!/usr/bin/env python3
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



import time
import threading
import math
import socket
from collections import deque
import utils.ErrFileHandler as Fh
import utils.Types as t
import datetime
import sys
import udp_pkg
from optparse import OptionParser

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
CNTRD = 13

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
        CNTRD    : "CNTRD",
        }

class ComError(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)



class verifier_dec:

    def __init__ (self, port=55328, ip="192.168.42.23"):
        self.hwcfg_read = False
        self.__port = port
        self.__ip = ip
        self.__com = udp_pkg.udp_com(name_types, self, port=port, ip=ip)
        self.__com.start()

        self.__timeout = 10
        self.__retries = 20

        self.__version = None
        self.__max_data_length = None
        self.__img_width_byte = None
        self.__max_img_width = None
        self.__img_width = None
        self.__img_height_byte = None
        self.__max_img_height = None
        self.__img_height = None
        self.__box_size_byte = None
        self.__box_size = None
        self.__stim_len_byte = None
        self.__stim_len = None
        self.__instances_byte = None
        self.__instances = None

        self.__err_str = 0
        self.__err_str_event = threading.Event()
        self.__err_str_sema = threading.Semaphore()

        self.__err_event = threading.Event()
        self.__err_sema = threading.Semaphore()

        self.__err_rd_ack_event = threading.Event()
        self.__err_rd_ack_sema = threading.Semaphore()

        self.__err_drp_event = threading.Event()

        self.__err_cnt_event = threading.Event()

        self.__cnt_event = threading.Event()

        self.__status_event = threading.Event()


    def close(self):
        self.__com.close()

    def __del__(self):
        self.close()


    def getHW_CFG(self):
        if self.hwcfg_read:
            return (self.__version, self.__max_data_length, self.__max_img_width,
                    self.__img_width, self.__max_img_height, self.__img_height,
                    self.__box_size, self.__stim_len, self.__stim_len_byte,
                    self.__instances, self.__cmp_err_len, self.__rev_err_len,
                    self.__dut_err_len)
        else:
            return None




    ## check if FPGA verification is running
    # returns True if the FPGA verification is running
    def isRunning(self):
        self.read_status()
        if self.__state == 2 or self.__state == 3:
            return True
        else:
            return False

    def errorsStored(self):
        if self.__err_str == 0:
            # retry until respons
            completet = False
            cnt = self.__retries
            while cnt > 0 and not completet:
                cnt -= 1
                self.__read_err_str()
                if self.__err_str_event.wait(self.__timeout):
                    completet = True
            if not completet:
                udp_pkg.debug("can not receive number of stored errors", 1)
                return 0
        return self.__err_str

    def nextError(self):
        if self.errorsStored() > 0:
            self.__read_err_nxt()
            self.__err_event.wait()
            self.__write_err_rd()
            if self.__err_rd_ack_event.wait(self.__timeout):
                with self.__err_str_sema:
                    self.__err_str -= 1
                return self.__err
        return None





    def read_hw (self):
        self.__com.send(HW_CFG)

    def read_status (self):
        self.__com.send(STATUS)

    def write_sstim (self, stim):
        if self.__stim_len_byte is not None:
            self.__sstim = stim
            tmp = self.__com.int_conv(stim, self.__stim_len_byte)
#            print("stimlen: " + str(self.__stim_len_byte))
#            output = "0x"
#            for c in tmp:
#                output += (hex(ord(c))[2:])
#            print ("send: " + output)
#
            self.__com.send(SSTIM, tmp)
        else:
            raise ComError("Unknown HW parameters. Read first HWCFG")

    def write_estim (self, stim):
        if self.__stim_len_byte is not None:
            self.__estim = stim
            tmp = self.__com.int_conv(stim, self.__stim_len_byte)
            self.__com.send(ESTIM, tmp)
        else:
            raise ComError("Unknown HW parameters. Read first HWCFG")


    def write_restart (self):
        self.__com.send(RESTART)

    def __read_err_cnt (self):
        self.__err_cnt_event.clear()
        self.__com.send(ERRCNT)

    def getERR_droped(self):
        self.__read_err_drp()
        cnt = self.__retries
        while cnt > 0:
            cnt -= 1
            if self.__err_drp_event.wait(self.__timeout):
                return self.__err_drp
        return None

    def getERR_counter(self):
        self.__read_err_cnt()
        cnt = self.__retries
        while cnt > 0:
            cnt -= 1
            if self.__err_cnt_event.wait(self.__timeout):
                return self.__err_cnt
        return None

    def __read_cnt (self):
        self.__cnt_event.clear()
        self.__com.send(CNTRD)

    def getCounter(self):
        self.__read_cnt()
        cnt = self.__retries
        while cnt > 0:
            cnt -= 1
            if self.__cnt_event.wait(self.__timeout):
                return self.__cnt
        return None



    def __read_err_str (self):
        self.__com.send(ERRSTR)
        with self.__err_str_sema:
            self.__err_str_event.clear()

    def __read_err_drp (self):
        self.__err_drp_event.clear()
        self.__com.send(ERRDRP)

    def __read_err_nxt (self):
        with self.__err_sema:
            self.__err_event.clear()
        self.__com.send(ERRNXT)

    def __write_err_rd (self):
        with self.__err_rd_ack_sema:
            self.__err_rd_ack_event.clear()
        self.__com.send(ERRRD)

    def getCurStim(self):
        return self.__cur_stim

    ## process received ACK package called by udp_com
    def T_ACK (self, recv_data, send_msg):
        (send_type, send_data, send_try_cnt, send_time) = send_msg

        p = (recv_data, None)
        udp_pkg.debug("received " + name_types[ACK] + " data: " + str(p), 10)

        # with the send_type of this package we can process the response
        try:
            self.send_types[send_type](self, recv_data, ACK)
        except KeyError as e:
            print("Send message are wrong")
            print(send_msg)
            print(e)

    ## process received NACK package called by udp_com
    def T_NACK (self, recv_data, send_msg):
        (send_type, send_data, send_try_cnt, send_time) = send_msg

        try:
            self.send_types[send_type](self, recv_data, NACK)
        except KeyError as e:
            print("Send message are wrong")
            print(send_msg)
            print(e)

        print(("Received " + name_types[NACK] + " in response of " +
                name_types[send_type] + " with message: " + str((recv_data,))))


    ## decodes response to HW_CFG
    # @param data is the data string as a ascii string
    def T_HW_CFG (self, data, recv_type):
        if recv_type == ACK:
            self.__version = self.__com.str_conv_int(data[0:4])
            self.__max_data_length = self.__com.str_conv_int(data[4:6])
            pos = 6

            (self.__img_width_byte, self.__max_img_width) = self.__parse_value(data[pos:])
            pos += self.__img_width_byte + 1


            self.__img_width = self.__com.str_conv_int(data[pos:pos+self.__img_width_byte])
            pos += self.__img_width_byte


            (self.__img_height_byte, self.__max_img_height) = self.__parse_value(data[pos:])
            pos += self.__img_height_byte + 1

            self.__img_height = self.__com.str_conv_int(data[pos:pos+self.__img_height_byte])
            pos += self.__img_height_byte

            (self.__box_size_byte, self.__box_size) = self.__parse_value(data[pos:])
            pos += self.__box_size_byte + 1

            (self.__stim_len_byte, self.__stim_len) = self.__parse_value(data[pos:])
            pos += self.__stim_len_byte + 1

            (self.__instances_byte, self.__instances) = self.__parse_value(data[pos:])
            pos += self.__instances_byte + 1

            self.__cmp_err_len = self.__com.str_conv_int(data[pos:pos+1])
            pos += 1

            self.__rev_err_len = self.__com.str_conv_int(data[pos:pos+1])
            pos += 1

            self.__dut_err_len = self.__com.str_conv_int(data[pos:pos+1])
            pos += 1

            # the byte size means the size of the value needed to store the size
            # now it means how how many bytes are needed to store the whole value
            self.__stim_len_byte = int(math.ceil(self.__stim_len/8.0))
            self.__img_height_byte = int(math.ceil(self.__img_height/8.0))
            self.__img_width_byte = int(math.ceil(self.__img_width/8.0))
            self.__err_len_byte = int(math.ceil((self.__cmp_err_len +
                self.__rev_err_len + self.__dut_err_len)/8))

            self.hwcfg_read = True

            udp_pkg.debug("Received " + name_types[HW_CFG] + "\n"
                    + "\thw_version :    " + str(self.__version) + '\n'
                    + "\tmax_dat_len :   " + str(self.__max_data_length) + '\n'
                    + "\tmax_img_width : " + str(self.__max_img_width) + '\n'
                    + "\timg_width :     " + str(self.__img_width) + '\n'
                    + "\tmax_img_height: " + str(self.__max_img_height) + '\n'
                    + "\timg_height:     " + str(self.__img_height) + '\n'
                    + "\tbox_size:       " + str(self.__box_size) + '\n'
                    + "\tstim_len:       " + str(self.__stim_len) + '\n'
                    + "\tstim_len_byte:  " + str(self.__stim_len_byte) + '\n'
                    + "\tinstances:      " + str(self.__instances) + '\n'
                    + "\tcmp_err_len:    " + str(self.__cmp_err_len) + '\n'
                    + "\trev_err_len:    " + str(self.__rev_err_len) + '\n'
                    + "\tdut_err_len:    " + str(self.__dut_err_len), 5)



    """
    4  -> status[r]
      response:
        state (1 Byte: IDLE=0, RESTART=1, RUN=2, CHECK_LAST=3, CHECK_DONE=4)
        current_stimuli
    """
    ## decodes responses to STATUS
    # @param data is the data string as a ascii string
    def T_STATUS (self, data, recv_type):
        if recv_type == ACK:
            self.__state = self.__com.str_conv_int(data[0:1])
            self.__cur_stim = self.__com.str_conv_int(data[1:])
            udp_pkg.debug("Received " + name_types[STATUS] + "\n"
                    + "state:    " + str(self.__state) + "\n"
                    + "cur_stim: " + str(self.__cur_stim) + "\n", 5);


    """ 5  -> start stimuli[rw] (SS) (data length = stimuli_length)"""
    ## decodes responses to SSTIM
    # @param data is the data string as a ascii string
    def T_SSTIM (self, data, recv_type):
        None

    ## decodes responses to ESTIM
    # @param data is the data string as a ascii string
    def T_ESTIM (self, data, recv_type):
        None

    ## decodes responses to RESTART
    # @param data is the data string as a ascii string
    def T_RESTART (self, data, recv_type):
        None

    """8  -> error count[r]"""
    ## decodes responses to ERRCNT
    # @param data is the data string as a ascii string
    def T_ERRCNT (self, data, recv_type):
        if recv_type == ACK:
            self.__err_cnt = self.__com.str_conv_int(data[0:])

            self.__err_cnt_event.set()
            udp_pkg.debug("Received " + name_types[ERRCNT] + "\n"
                    + "errcnt: " + str(self.__err_cnt) + "\n", 5)

    """9  -> errors stored[r]"""
    ## decodes responses to ERRSTR
    # @param data is the data string as a ascii string
    def T_ERRSTR (self, data, recv_type):
        if recv_type == ACK:
            with self.__err_str_sema:
                self.__err_str = self.__com.str_conv_int(data[0:])
                self.__err_str_event.set()
            udp_pkg.debug("Received " + name_types[ERRSTR] + " "
                    + "errstr: " + str(self.__err_str) + "\n", 5)

    """10 -> errors droped[r] (amount of dropped errors)"""
    ## decodes responses to ERRDRP
    # @param data is the data string as a ascii string
    def T_ERRDRP (self, data, recv_type):
        if recv_type == ACK:
            self.__err_drp = self.__com.str_conv_int(data[0:])
            self.__err_drp_event.set()
            udp_pkg.debug("Received " + name_types[ERRDRP] + "\n"
                    + "errdrp: " + str(self.__err_drp) + "\n", 5)

    ## decodes responses to ERRNXT
    # @param data is the data string as a ascii string
    def T_ERRNXT (self, data, recv_type):
        if recv_type == ACK and len(data) == self.__stim_len_byte + self.__err_len_byte:
            err_type = self.__com.str_conv_int(data[0:self.__err_len_byte])
            err = self.__com.str_conv_int(data[self.__err_len_byte:])
            self.__err = (err_type, err)

            d = (err_type, err)
            udp_pkg.debug("Received " + name_types[ERRNXT] + "\n"
                    + "\t(err_type, err): " + str(d) + "\n", 5)

            with self.__err_sema:
                self.__err_event.set()

    ## decodes responses to ERRRD
    # @param data is the data string as a ascii string
    def T_ERRRD (self, data, recv_type):
        with self.__err_rd_ack_sema:
            self.__err_rd_ack_event.set()

    ## parses a string in hex in the format 1. byte [length of value], [value] ,...
    # @param data the hex value as string
    def __parse_value (self, data):
        d = (data[0:1], data[1:])
        udp_pkg.debug("parse_value with data: " + str(d), 10)
        length = self.__com.str_conv_int(data[0:1])
        udp_pkg.debug("\tbyte length: " + str(length), 10)
        value = self.__com.str_conv_int(data[1:length+1])
        d = (data[1:length+1], value)
        udp_pkg.debug("\tdata: " + str(d), 10)

        return (length, value)

    ## decodes responses to CNTRD
    # @param data is the data string as a ascii string
    def T_CNTRD (self, data, recv_type):
        if recv_type == ACK:
            size = self.__max_img_height * self.__max_img_width
            different = int(math.ceil(self.__max_img_height/2.0))*int(math.ceil(self.__max_img_width/2.0))
            self.__cnt = []
            for i in range(different-1, -1, -1):
                self.__cnt.append(self.__com.str_bit_conv_int(data,
                    i*size,(i+1)*size-1))

            self.__cnt_event.set()
            udp_pkg.debug("Received " + name_types[CNTRD] + "\n"
                    + "cnt: " + str(self.__cnt) + "\n", 5)



    # map types to methodes
    recv_types = {
            ACK      : T_ACK,
            NACK     : T_NACK,
            }

    send_types = {
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
            CNTRD    : T_CNTRD,
            }




#This methode reads the current state of a run and prints the ETA
#interval in seconds
class printState(threading.Thread):
    def __init__(self, interval, startStim, endStim):
        super(printState, self).__init__()
        self.interval = interval
        self.enabled = False
        self.startStim = startStim
        self.endStim = endStim

    def enableETA(self):
        self.startTime = int(round(time.time() * 1000)) # in ms
        self.enabled = True
        self.start()

    def disableETA(self):
        self.enabled = False

    def run(self):
        while self.enabled:
            #every minute print the current stimuli

            now = int(round(time.time() * 1000)) # in ms
            currs = hw_verifier.getCurStim()
            percent = float(currs-self.startStim) / float(self.endStim - self.startStim) * 100.0
            ms_to_go = float(now - self.startTime)*(100/percent - 1)

            sys.stdout.write((("{0} current Stimuli: {1} ({2:.02f}%) ETA {3} - ").format(
                time.strftime('[%Y\%m\%d %H:%M:%S]'),
                str(currs),
                percent,
                str(datetime.timedelta(seconds=round(ms_to_go/1000))))))

            hw_verifier.read_status()
            sys.stdout.write(("errors found: {0}, errors droped: {1}\n").format(
                hw_verifier.getERR_counter(),
                hw_verifier.getERR_droped()))
            sys.stdout.flush()

            time.sleep(self.interval)




if __name__ == "__main__":


    parser = OptionParser()
    parser.add_option("-s", "--start", dest="sstim", type="int",
            help="stimulus to start the simulation if not set it starts with 0")
    parser.add_option("-e", "--end", dest="estim", type="int",
            help="stimulus to stop when reached if not set it ends at the "
            + "highest possible value.")
    parser.add_option("-i", "--info", dest="info", action="store_true",
            help="Show the hardware configuration")
    parser.add_option("-c", "--counter", dest="counter", action="store_true",
            help="Show the distribution counter value")
    (option, args) = parser.parse_args()


    hw_verifier = verifier_dec(ip="192.168.4.23")
    #hw_verifier = verifier_dec(ip="127.0.0.1")
    hw_verifier.read_hw()
    hw_verifier.read_status()


    cnt = 0
    while cnt < 30 and (not hw_verifier.hwcfg_read):
        time.sleep(1)
        cnt += 1

    if cnt >= 30:
        print ("HW_CFG could not be read")
    else:

        currtime = time.strftime("%Y_%m_%d-%H_%M")
        file_w = Fh.FileWriter("logdir/file_" + currtime, hw_verifier.getHW_CFG())
        info_version = 2

        hw=t.HwCfg(hw_verifier.getHW_CFG())

        if option.info:
            print(hw)
            hw_verifier.close()
            sys.exit(0)
        elif option.counter:
            cnt=hw_verifier.getCounter()
            for i in range(0, len(cnt)):
                sys.stdout.write(("Images with {0:2d} Boxes: {1:11d}\n").format(i+1, cnt[i]))
            hw_verifier.close()
            sys.exit(0)


        if option.sstim is None:
            start_stim = 0
        else:
            if option.sstim <=  2**hw.stim_len-1:
                start_stim = option.sstim
            else:
                print("The maximum stimuli is " + str(2**hw.stim_len-1))



        if option.estim is None:
            end_stim = 2**hw.stim_len-1
        else:
            if option.estim <=  2**hw.stim_len-1:
                end_stim = option.estim
            else:
                print("The maximum stimuli is " + str(2**hw.stim_len-1))

        print ("Verification starts at " +str(start_stim)+ " and ends at "
                +str(end_stim))

        eta = printState(60, start_stim, end_stim)

        hw_verifier.write_sstim(start_stim)
        hw_verifier.write_estim(end_stim)
        hw_verifier.read_status()

        time.sleep(2)
        hw_verifier.write_restart()

        hw_verifier.read_status()
        hw_verifier.write_restart()
        hw_verifier.read_status()

        while not hw_verifier.isRunning():
            time.sleep(.2)
        starttime = int(round(time.time() * 1000000)) # in ms

        eta.enableETA()

        while hw_verifier.isRunning():
            while hw_verifier.errorsStored() > 0:
                err = hw_verifier.nextError()
                if err is not None:
                    file_w.addRecord(err)
                    udp_pkg.debug("error: " + (str(err)), 1)

        endtime = int(round(time.time() * 1000000)) # in ms
        del(file_w)

        eta.disableETA()

        hw_verifier.read_status()
        err_found = hw_verifier.getERR_counter()
        err_droped = hw_verifier.getERR_droped()

        file_w = Fh.FileWriter("logdir/file_" + currtime +"_info", hw_verifier.getHW_CFG())
        file_w.addRecord((info_version, err_found, err_droped, start_stim,
            end_stim, starttime, endtime))
        del(file_w)

        print("Errors Found: " + str(err_found) + ", droped: " + str(err_droped))

        time.sleep(2)
    hw_verifier.close()
    print("hw_verifier closed")
#this should be not necessary but some threads do not stop...
    import sys
    sys.exit(0)

