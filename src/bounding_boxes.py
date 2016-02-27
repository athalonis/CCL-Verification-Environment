#!/usr/bin/env python2
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

import cv2
import numpy as np

##
# Fast way to calculate bounding boxes with the opencv library
#
# @param filename The source image file as a string. Many filetypes
# supported.
# @param invert black is the background color. If you want a white background
#   set this to true.

def getBoundingBoxes(filename, invert=False):
    img = cv2.imread(filename, cv2.CV_LOAD_IMAGE_GRAYSCALE)

    sh_type = cv2.THRESH_BINARY
    if invert:
        sh_type = cv2.THRESH_BINARY_INV
    #generate a black and white image
    ret, img = cv2.threshold(img, 127, 255, sh_type)

    #the findCountours methode will clip one border pixel
    #we add a additional pixel border around the image
    w=img.shape[0]
    h=img.shape[1]
    row = np.zeros(w, np.uint8)
    col = np.zeros((h+2, 1), np.uint8)
    img = np.hstack([col, np.vstack([row, img, row]), col])

    #get the contours
    contours,hierarchy = cv2.findContours(img, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)

    boxes=[]
    for cnt in contours:
        x,y,w,h = cv2.boundingRect(cnt)
        boxes.append((x-1,y-1,x+w-2,y+h-2))
    return boxes


if __name__== "__main__":
    print(getBoundingBoxes("../img/test61.pbm", True))
