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

from PIL import Image
import numpy as np

## Reads a image from a file converts it to black and white and creates a numpy array
#
#  @param filename File to read image from
#  @param threshold Threshold to convert greyscale image to black and white. Range 0.0 ... 1.0
#  @param max_x is the image size to crop/extend the image in width
#  @param max_y is the image size to crop/extend the image in high
#  @return Returns the black and white numpy array
def import_img (filename, threshold, max_x, max_y):  #convert image to grey scale
    img = Image.open(filename)
    img_grey = img.convert('L')

    img_array = np.array(img_grey)
    img_out = np.zeros((max_y, max_x), dtype=np.int)

    #convert to black/white
    max_val = 255 #np.iinfo(type(img_array[0][0])).max
    min_val = 0 #np.iinfo(type(img_array[0][0])).min

    threshold = threshold * (max_val-min_val) - min_val

    for y in range(0, img_out.shape[0]):
        for x in range(0, img_out.shape[1]):
            if y < img_array.shape[0] and x < img_array.shape[1] and img_array[y][x] < threshold:
                img_out[y][x] = min_val
            else:
                img_out[y][x] = max_val

    del img
    del img_grey
    del img_array
    return img_out


