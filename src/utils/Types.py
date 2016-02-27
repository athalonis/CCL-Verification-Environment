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


## HwCfg Class stores all readable FPGA HW parameters
class HwCfg:
    def __init__(self, parlist=()):
        self.version = None
        self.max_data_length = None
        self.max_img_width = None
        self.img_width = None
        self.max_img_height = None
        self.img_height = None
        self.box_size = None
        self.stim_len = None
        self.stim_len_byte = None
        self.instances = None
        self.cmp_err_len = None
        self.ref_err_len = None
        self.dut_err_len = None
        self.cam_mode = False
        self.max_err_injections = None

        if len(parlist) == 10:
            (self.version, self.max_data_length, self.max_img_width,
                    self.img_width, self.max_img_height, self.img_height,
                    self.box_size, self.stim_len, self.stim_len_byte,
                    self.instances) = parlist
        elif len(parlist) == 13:
            (self.version, self.max_data_length, self.max_img_width,
                    self.img_width, self.max_img_height, self.img_height,
                    self.box_size, self.stim_len, self.stim_len_byte,
                    self.instances, self.cmp_err_len, self.ref_err_len,
                    self.dut_err_len) = parlist

        elif len(parlist) == 15:
            (self.version, self.max_data_length, self.max_img_width,
                    self.img_width, self.max_img_height, self.img_height,
                    self.box_size, self.stim_len, self.stim_len_byte,
                    self.instances, self.cmp_err_len, self.ref_err_len,
                    self.dut_err_len, self.cam_mode,
                    self.max_err_injections ) = parlist



    def decodeError(self, err):
        err_cmp = err
        if self.cmp_err_len is not None:
            err_cmp = err &  (2**self.cmp_err_len-1)
        err_ref = 0
        err_dut = 0
        if self.ref_err_len is not None and self.dut_err_len is not None:
            err_ref = (err >> self.cmp_err_len)&(2**self.ref_err_len-1)
            err_dut = (err >> self.cmp_err_len+self.ref_err_len)&(2**self.dut_err_len-1)
        return (err_cmp, err_ref, err_dut)
    
    @staticmethod 
    def cmpErrToStr(err):
        if err==0:
            return ""
        elif err==1:
            return "#DUT < #REF"
        elif err==2:
            return "#DUT > #REF"
        elif err==3:
            return "DUT /= REF"
        return "Unknown"

        
    @staticmethod 
    def refErrToStr(err):
        if err==0:
            return ""
        elif err==1:
            return"Lookup FiFo overflow"
        return "Unknown"
    
    @staticmethod 
    def dutErrToStr(err):
        if err==0:
            return ""
        elif err==1:
            return "ll_cnt overflow"
        return "Unknown"
 

    def errToStr(self, err):
        (err_cmp, err_ref, err_dut) = self.decodeError(err)
        s = ""
        if err_cmp > 0:
            s += "CMP: " + HwCfg.cmpErrToStr(err_cmp)
            if err_ref > 0 or err_dut > 0:
                s += " / "
        if err_ref > 0:
            s += "REF: " + HwCfg.refErrToStr(err_ref)
            if err_dut > 0:
                s += " / "
        if err_dut > 0:
            s += "DUT: " + HwCfg.dutErrToStr(err_dut)
        return s



    def __str__(self):
        s = "HW Revision: " + str(self.version) +"\n"
        s += "HW Send/Receive buffer size: " + str(self.max_data_length) +"\n"
        s += "HW max image width: " + str(self.max_img_width) +"\n"
        s += "HW image width: " + str(self.img_width) +"\n"
        s += "HW max image height: " + str(self.max_img_height) +"\n"
        s += "HW image height: " + str(self.img_height) +"\n"
        s += "HW Box size: " + str(self.box_size) +"\n"
        if not self.cam_mode:
            s += "HW Stimuli size: " + str(self.stim_len) +"\n"
            s += "HW Verification instances: " + str(self.instances) +"\n"
            s += "HW Comperator error bits: " + str(self.cmp_err_len) +"\n"
            s += "HW CCL Reference error bits: " + str(self.ref_err_len) +"\n"
            s += "HW CCL DUT error bits: " + str(self.dut_err_len)
        else:
            s += "HW max error injections: " + str(self.max_err_injections)
            s =  "Hardware in camera emulation mode\n" + s
        return s



