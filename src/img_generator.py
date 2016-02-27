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

import glob
import random
import os
from PIL import Image
from optparse import OptionParser

class TestImage:
    def __init__(self, w, h, test_pattern, min_pattern, max_pattern, min_noise,
            max_noise):
        self.__w = w
        self.__h = h
        self.__tp = test_pattern
        self.__min_p = min_pattern
        self.__max_p = max_pattern
        self.__min_n = min_noise
        self.__max_n = max_noise

        random.seed()

    def getImg(self):
        img = Image.new('1', (self.__w, self.__h), "white")
        #min/max_noise is a faktor of the image value
        noise_cnt = random.uniform(self.__min_n, self.__max_n)
        noise_cnt = int(round(float(noise_cnt) *(self.__w*self.__h)))
        pattern_cnt = random.randint(self.__min_p, self.__max_p)

        for i in range(0, pattern_cnt):
            #with overlapping
            #select a randome pattern
            sel_pattern = random.randint(0, len(self.__tp)-1)
            pattern = self.__tp[sel_pattern]
            pattern_s = pattern.size
            x_coord = random.randint(0, self.__w - pattern_s[0]-1)
            y_coord = random.randint(0, self.__h - pattern_s[1]-1)
            img.paste(pattern, (x_coord, y_coord))

        for i in range(0, noise_cnt):
            x_coord = random.randint(0, self.__w-1)
            y_coord = random.randint(0, self.__h-1)
            img.putpixel((x_coord, y_coord), 0)

        return img


class TestPattern:
    def __init__(self, pattern_dir):
        self.__pattern_dir = pattern_dir

        self.pattern = []
        self.__pattern_read(self.__pattern_dir)


    def __pattern_read(self, pdir):
        for files in glob.glob(pdir + "/pattern*"):
            self.pattern.append(Image.open(files))

if __name__== "__main__":

    parser = OptionParser()
    parser.add_option("--max-pattern", dest="max_p", default=800, type="int",
            help="The maximum number of paterns to place on the image")
    parser.add_option("--min-pattern", dest="min_p", default=100, type="int",
            help="The minimum number of paterns to place on the image")
    parser.add_option("--min-noise", dest="min_n", default=.001, type="float",
            help="The minimum factor of noise to place on the image")
    parser.add_option("--max-noise", dest="max_n", default=.003, type="float",
            help="The minimum factor of noise to place on the image")
    parser.add_option("-w", "--img-width", dest="width", default=1024, type="int",
            help="Image width")
    parser.add_option("-y", "--img-height", dest="height", default=768, type="int",
            help="Image height")
    parser.add_option("-p", "--pattern-dir", dest="p_dir",
            default="../img/pattern/",
            help="Directory with the image pattern \"pattern*\"")
    parser.add_option("-o", "--out-dir", dest="o_dir",
            help="Directory for the generated files")
    parser.add_option("-n", "--num-images", dest="img_num", default=1, type="int",
            help="Number of test images to generate")
    (op, args) = parser.parse_args()

    if not op.o_dir:
        o_dir = "../img/" + str(op.width) + "_" + str(op.height) +"/"
    else:
        o_dir = op.o_dir + "/"

    p_dir = op.p_dir + "/"

    tp = TestPattern(p_dir)

    if not os.path.exists(o_dir):
        os.makedirs(o_dir)

    for i in range (0, op.img_num):
        ti = TestImage(op.width, op.height, tp.pattern, op.min_p, op.max_p,
                op.min_n, op.max_n)

        ti.getImg().save(o_dir + "test" + str(op.max_p)+ "_"
                +str(op.min_p)+ "_" + str(op.min_n)+ "_" +
                str(op.max_n) + "_" + str(i) + ".png")
