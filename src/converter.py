#!/usr/bin/python
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


import numpy as np
from PIL import Image

class Img_conv(object):
    def __init__(self, ifile, max_x, max_y, threshold):
        self.__ifile = ifile
        self.__threshold = threshold
        self.__max_x = max_x
        self.__max_y = max_y
        self.__img = self.__convert()

    def __convert(self):
        img_out = ""
        img = Image.open(self.__ifile)
        img_grey = img.convert('L')

        img_array = np.array(img_grey)

        max_val = 255 #np.iinfo(type(img_array[0][0])).max
        min_val = 0 #np.iinfo(type(img_array[0][0])).min

        threshold = self.__threshold * (max_val-min_val) - min_val
        line=""

        for y in range(0, self.__max_y):
            line=""
            for x in range(0, self.__max_x):
                if x != 0:
                    line += " "
                if x < img_array.shape[1] and y < img_array.shape[0] and img_array[y][x] < threshold: 
                    line += "1"
                else:
                    line += "0"
            img_out += line + "\n"

        del img
        del img_grey
        del img_array
        return img_out

    def __str__(self):
        return self.__img

    def save(self, dest):
        f = open(dest, 'w')
        f.write(self.__img)
        f.close()

if __name__== "__main__":

    from optparse import OptionParser

    parser = OptionParser()
    parser.add_option("-i", "--ifile", dest="ifile",
            help="input image to run connected component labling")
    parser.add_option("-t", "--threshold", dest="threshold", type="float", default=0.5,
            help="threshold for converting image to black/white. Value 0.0...1.0")
    (option, args) = parser.parse_args()

    if option.threshold > 1.0 or option.threshold < 0.0:
        print("Threshold needs to be between 0.0 ... 1.0")

    if option.ifile:
        print(str(Img_conv(option.ifile, 32, 32, option.threshold)))
    else:
        print("no filename passed as argument")
