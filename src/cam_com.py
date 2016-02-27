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



import threading
import math
import utils.Types as t
import time
import sys
import udp_pkg
import utils.Image as image
#from udp_pkg import *
from optparse import OptionParser
import cola

ACK = 1
NACK = 2
HW_CFG = 3
STATUS = 4
RESTART = 7
SEND_PX = 14
SEND_BOX = 15
SET_FLL_LVL = 16
SET_ACT_ERR = 17
SET_HSY_ERR = 18
SET_VSY_ERR = 19

name_types = {
        ACK      : "ACK",
        NACK     : "NACK",
        HW_CFG   : "HW_CFG",
        STATUS   : "STATUS",
        RESTART  : "RESTART",
        SEND_PX  : "SEND_PX",
        SEND_BOX : "SEND_BOX",
        SET_FLL_LVL : "SET_FLL_LVL",
        SET_ACT_ERR : "SET_ACT_ERR",
        SET_HSY_ERR : "SET_HSY_ERR",
        SET_VSY_ERR : "SET_VSY_ERR",
        }


class ComError(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class InjErrorType:
    def __init__(self, col=1, row=0, val=1):
        self.row = row
        self.col = col
        self.val = val

    def __str__(self):
        return "(" + str(self.col) + ", " + str(self.row) + ") = " + str(self.val)

class InjError():
    def __init__(self, number):
        self.__hsync__ = []
        self.__vsync__ = []
        self.__act__ = []
        for i in range(0, number):
            self.__hsync__.append(InjErrorType())
            self.__vsync__.append(InjErrorType())
            self.__act__.append(InjErrorType())

    def getLength(self):
        return len(self.__act__)

    def __setError__(self, typ, idx, err):
        if idx > len(typ)-1:
            raise IndexError('Element ' + str(idx) + ' is not in range 0..' + str(len(typ)))
        typ[idx] = err

    def setHsyncErr(self, idx, err):
        self.__setError__(self.__hsync__, idx, err)
    def setVsyncErr(self, idx, err):
        self.__setError__(self.__vsync__, idx, err)
    def setActErr(self, idx, err):
        self.__setError__(self.__act__, idx, err)

    def __getError__(self, typ, idx):
        if idx > len(typ)-1:
            raise IndexError('Element ' + str(idx) + ' is not in range 0..' + str(len(typ)))
        return typ[idx]

    def getHsyncErr(self, idx):
        return self.__getError__(self.__hsync__, idx)
    def getVsyncErr(self, idx):
        return self.__getError__(self.__vsync__, idx)
    def getActErr(self, idx):
        return self.__getError__(self.__act__, idx)

    def __strOne__(self, typ):
        s = ""
        for i in range(0, len(typ)):
            s += str(typ[i]) + '\n'
        return s

    def __str__(self):
        s = "HSync force (x, y) = value:\n"
        s += self.__strOne__(self.__hsync__)
        s += "VSync force (x, y) = value:\n"
        s += self.__strOne__(self.__vsync__)
        s += "Px force (x, y) = value:\n"
        s += self.__strOne__(self.__act__)
        return s



class cam_dec:

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
        self.__cam_mode = False
        self.__max_err_injections = None

        self.__max_img_width_bits = None
        self.__max_img_height_bits = None

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

        self.inj_err = None

        self.boxes = []

    def w(self):
        return self.__img_width
    def h(self):
        return self.__img_height


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
                    self.__dut_err_len, self.__cam_mode, self.__max_err_injections)
        else:
            return None




    ## check if FPGA verification is running
    # returns True if the FPGA verification is running
    def isRunning(self):
        self.read_status()
        if self.__state == 0x81:
            return True
        else:
            return False

    def read_hw (self):
        self.__com.send(HW_CFG)

    def read_status (self):
        self.__com.send(STATUS)

    def __send_px (self, data):
        if len(data) > (int)(self.__max_data_length/8):
            print("tried to send more date than possible in one package")
        else:
            self.__com.send(SEND_PX, data)

    def send_img(self, img_file):
        img = image.import_img(img_file, .5, self.__max_img_width,
                self.__max_img_height)

        # convert the image to binary string...
        send_d = b""
        val = 0
        shift = 7
        cnt = 0
        packages = 0
        for y in range(img.shape[0]):
            for x in range(img.shape[1]):
                if img[y][x] == 0:
                    val += (1 << shift)
                shift -= 1

                if shift == -1:
                    send_d += self.__com.int_conv(val, 1)
                    shift = 7
                    val = 0
                    cnt += 1
                if cnt == (int)(self.__max_data_length/8):
                    self.__send_px(send_d)
                    packages += 1
                    send_d = b""
                    cnt = 0
        if cnt > 0:
            self.__send_px(send_d)

        print(str(packages) + " packages send")


    def write_fll_lvl (self, lvl):
        tmp = self.__com.int_conv(lvl, 2)
        self.__com.send(SET_FLL_LVL, tmp)

    def __write_err__ (self, fetch_m, msgTyp):
        bitstr = ""
        for i in range(0, self.__max_err_injections):
            bitstr += self.__com.int_binstr_conv(fetch_m(i).row, self.__max_img_height_bits)
            bitstr += self.__com.int_binstr_conv(fetch_m(i).col, self.__max_img_width_bits)
            bitstr += self.__com.int_binstr_conv(fetch_m(i).val, 1)
        send_d = self.__com.binstr_conv(bitstr)
        self.__com.send(msgTyp, send_d)

    def writeHsyncErr(self):
        self.__write_err__(self.inj_err.getHsyncErr, SET_HSY_ERR)
    def writeVsyncErr(self):
        self.__write_err__(self.inj_err.getVsyncErr, SET_VSY_ERR)
    def writeActErr(self):
        self.__write_err__(self.inj_err.getActErr, SET_ACT_ERR)

    def write_restart (self):
        self.__com.send(RESTART)

    ## process received ACK package called by udp_com
    def T_ACK (self, recv_data, send_msg):
        if type(send_msg) != int:
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
        else:
            raise Exception('Received ACK for package not send by me')

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

    def T_SEND_BOX (self, recv_data, send_data):
        box_cnt = (int)(len(recv_data)*8/64)
        for i in range (box_cnt-1, -1, -1):
            end = len(recv_data)-((int)(64/8))*i
            start = len(recv_data)-((int)(64/8))*(i+1)
            box = recv_data[start:end]

            x1 = self.__com.str_bit_conv_int(box, self.__x1s, self.__x1e-1)
            y1 = self.__com.str_bit_conv_int(box, self.__y1s, self.__y1e-1)
            x2 = self.__com.str_bit_conv_int(box, self.__x2s, self.__x2e-1)
            y2 = self.__com.str_bit_conv_int(box, self.__y2s, self.__y2e-1)

            self.boxes.append(((x1, y1), (x2, y2)))


    def T_NULL (self, data, recv_type):
        None


    ## decodes response to HW_CFG
    # @param data is the data string as a ascii string
    def T_HW_CFG (self, data, recv_type):
        if recv_type == ACK:
            self.__version = self.__com.str_conv_int(data[0:4])
            self.__max_data_length = self.__com.str_conv_int(data[4:6])
            pos = 6

            (self.__img_width_byte, self.__max_img_width) = self.__parse_value(data[pos:])
            self.__max_img_width_bits = int(math.ceil(math.log(self.__max_img_width + 1, 2)))
            pos += self.__img_width_byte + 1


            self.__img_width = self.__com.str_conv_int(data[pos:pos+self.__img_width_byte])
            pos += self.__img_width_byte


            (self.__img_height_byte, self.__max_img_height) = self.__parse_value(data[pos:])
            self.__max_img_height_bits = int(math.ceil(math.log(self.__max_img_height+1, 2)))
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

            if pos < len(data):
                tmp = self.__com.str_conv_int(data[pos:pos+1])
                pos += 1
                if tmp == 42:
                    self.__cam_mode = True

                    self.__max_err_injections = self.__com.str_conv_int(data[pos:pos+1])
                    pos += 1

                    self.inj_err = InjError(self.__max_err_injections)


            # the byte size means the size of the value needed to store the size
            # now it means how how many bytes are needed to store the whole value
            self.__stim_len_byte = int(math.ceil(self.__stim_len/8.0))
            self.__img_height_byte = int(math.ceil(self.__img_height/8.0))
            self.__img_width_byte = int(math.ceil(self.__img_width/8.0))
            self.__err_len_byte = int(math.ceil((self.__cmp_err_len +
                self.__rev_err_len + self.__dut_err_len)/8))

            w=int(math.ceil(math.log(self.__max_img_width*1.0, 2)))
            h=int(math.ceil(math.log(self.__max_img_height*1.0, 2)))

            self.__x1s = 64 - (2*w + 2*h)
            self.__x1e = 64 - (1*w + 2*h)
            self.__y1s = 64 - (1*w + 2*h)
            self.__y1e = 64 - (1*w + 1*h)
            self.__x2s = 64 - (1*w + 1*h)
            self.__x2e = 64 - (1*w + 0*h)
            self.__y2s = 64 - (1*w + 0*h)
            self.__y2e = 64 - (0*w + 0*h)

            self.hwcfg_read = True

            udp_pkg.debug("Received " + name_types[HW_CFG] + "\n"
                    + "\thw_version :        " + str(self.__version) + '\n'
                    + "\tmax_dat_len :       " + str(self.__max_data_length) + '\n'
                    + "\tmax_img_width :     " + str(self.__max_img_width) + '\n'
                    + "\timg_width :         " + str(self.__img_width) + '\n'
                    + "\tmax_img_height:     " + str(self.__max_img_height) + '\n'
                    + "\timg_height:         " + str(self.__img_height) + '\n'
                    + "\tbox_size:           " + str(self.__box_size) + '\n'
                    + "\tstim_len:           " + str(self.__stim_len) + '\n'
                    + "\tstim_len_byte:      " + str(self.__stim_len_byte) + '\n'
                    + "\tinstances:          " + str(self.__instances) + '\n'
                    + "\tcmp_err_len:        " + str(self.__cmp_err_len) + '\n'
                    + "\trev_err_len:        " + str(self.__rev_err_len) + '\n'
                    + "\tdut_err_len:        " + str(self.__dut_err_len) + '\n'
                    + "\tcam_mode:           " + str(self.__cam_mode) + '\n'
                    + "\tmax_err_injections: " + str(self.__max_err_injections),
                    5)



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
                    + "state:    " + str(self.__state) + "\n", 5);


    ## decodes responses to RESTART
    # @param data is the data string as a ascii string
    def T_RESTART (self, data, recv_type):
        None

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

    # map types to methodes
    recv_types = {
            ACK      : T_ACK,
            NACK     : T_NACK,
            SEND_BOX : T_SEND_BOX,
            }

    send_types = {
            HW_CFG   : T_HW_CFG,
            STATUS   : T_STATUS,
            RESTART  : T_RESTART,
            SEND_PX  : T_NULL,
            SET_FLL_LVL : T_NULL,
            SET_ACT_ERR : T_NULL,
            SET_HSY_ERR : T_NULL,
            SET_VSY_ERR : T_NULL,
            }



if __name__ == "__main__":


    parser = OptionParser()
    parser.add_option("-l", "--level", dest="level", type="int", default=1,
            help="fill level in pixels")
    parser.add_option("-i", "--info", dest="info", action="store_true",
            help="Show the hardware configuration")
    parser.add_option("-f", "--file", dest="file", default="",
            help="Image file send to pccl")
    (option, args) = parser.parse_args()

    if option.info is None and (option.file == ""):
        parser.print_help()
        sys.exit(0)

    hw_cam = cam_dec(ip="192.168.4.23")
    #hw_cam = cam_dec(ip="127.0.0.1")
    hw_cam.read_hw()
    hw_cam.read_status()

    while hw_cam.getHW_CFG() is None:
        time.sleep(.2)

    hw=t.HwCfg(hw_cam.getHW_CFG())


    if option.info:
        print(hw)
        hw_cam.close()
        sys.exit(0)


    # times 16, since each px_in value has 16 pixels
    hw_cam.inj_err.setHsyncErr(0, InjErrorType(1*16,0,1))
    hw_cam.inj_err.setHsyncErr(9, InjErrorType(3*16,1,1))
    #hw_cam.writeHsyncErr()

    #force the 3. data write to be 0 for px
    hw_cam.inj_err.setActErr(3, InjErrorType(2*16,0,0))
    #hw_cam.writeActErr()

    #force vsync to 4. data write
    hw_cam.inj_err.setVsyncErr(0, InjErrorType(3*16,0,1))
    #hw_cam.writeVsyncErr()
    print(hw_cam.inj_err)

    hw_cam.write_fll_lvl(option.level)
    hw_cam.write_restart()

    hw_cam.read_status()

    hw_cam.send_img(option.file)

    time.sleep(1)

    #visualize the result
    pl=cola.ComponentLabeling(option.file, max_x=hw_cam.w(), max_y=hw_cam.h(), disable_calc=True)
    pl.plot_one("PCCL - processed image", boxes=hw_cam.boxes)

    hw_cam.read_status()

    hw_cam.close()
    print("hw_verifier closed")
    #this should not be necessary but some threads do not stop...
    import sys
    sys.exit(0)

