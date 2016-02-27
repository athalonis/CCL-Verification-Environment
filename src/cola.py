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


#from scipy import misc
import matplotlib.cm as cm
import matplotlib.pyplot as plt
import matplotlib.patheffects as PathEffects
import matplotlib.patches as mppatches
import numpy as np
import pylab
from PIL import Image

def getBoundingBoxes(image, invert=False):
    import cv2
    #filename or array?
    if type(image) == str:
        img = cv2.imread(image, cv2.CV_LOAD_IMAGE_GRAYSCALE)

        sh_type = cv2.THRESH_BINARY
        if invert:
            sh_type = cv2.THRESH_BINARY_INV
        #generate a black and white image
        ret, img = cv2.threshold(img, 127, 255, sh_type)
    else:
        img=image.copy()


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




## This Class runs a two pass connected component algorithem
#
#  You can get the lables after the first and the second run. You can also
#  get the equivalent table also the lookup table wich is created after the
#  second run.
class ComponentLabeling:

    ## Constructor
    #
    #  @param img this can be a numpy array with the image to analyze. You can also pass a filename this will be read in.
    #  @param verbose If True it prints some debug informations
    #  @param threshold Used to convert a greyscale image to black and white
    def __init__(self, img, verbose=False, threshold=0.5, max_x=32, max_y=32):

        self.__max_x = max_x
        self.__max_y = max_y

        # if the img is a file read this
        if type(img) == str:
            self.__filename = img
            img = self.__import_img(img, threshold, max_x, max_y)

        self.__img = img

        self.__threshold = threshold

        self.__lables_f = np.zeros((img.shape[0], img.shape[1]), dtype=np.int)
        self.__lables_s = np.zeros((img.shape[0], img.shape[1]), dtype=np.int)
        self.__verbose = verbose

        self.__print_v("first run")
        self.__equi_d = self.__run_1p()

        self.__print_v("equivalent table:")
        self.__print_v(self.__equi_d)

        self.__lookup = self.gen_lookuptable(self.__equi_d)
        self.__print_v("lookup table:")
        self.__print_v(self.__lookup)

        self.__print_v("second run")
        self.__run_2p(self.__lookup)

        self.__boundboxes = self.__boundbox(self.__lables_s)
        self.__print_v("bounding boxes:")
        for key in self.__boundboxes:
            self.__print_v(self.__boundboxes[key])

    def get_img(self):
        return self.__img

    ## Print messages only if verbose mode is enabled
    def __print_v(self, text):
        if self.__verbose:
            print(text)

    ## Get the labels after the first run
    #
    #  @return Returns a numpy array with the lables
    def get_lable_f (self):
        return self.__lables_f

    ## Get the labels after the second run
    #
    #  @return Returns a numpy array with the lables
    def get_lable_s (self):
        return self.__lables_s

    ## Get the lookup table created after the first run
    #
    #  @return Returns a lookup table as a dictionary
    def get_lookup (self):
        return self.__lookup

    ## Get the bound boxes as a list of tuples
    #
    #  @return Returns the boxes as a list
    def get_boxes (self):
        return self.__boundboxes

    ## Reads a image from a file converts it to black and white and creates a numpy array
    #
    #  @param filename File to read image from
    #  @param threshold Threshold to convert greyscale image to black and white. Range 0.0 ... 1.0
    #  @param max_x is the image size to crop/extend the image in width
    #  @param max_y is the image size to crop/extend the image in high
    #  @return Returns the black and white numpy array
    def __import_img (self, filename, threshold, max_x, max_y):  #convert image to grey scale
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



    ## Plots a numpy array as image to a diagram with labels on the pixels
    #
    #  @param lbl numpy array with lables
    #  @param plot It is used to write the plot on
    def __generate_lable_plot(self, lbl, plot):
        for y in range(0, lbl.shape[0]):
            for x in range(0, lbl.shape[1]):
                if lbl[y][x] != 0:
                    t=plot.text(x,y,lbl[y][x], fontsize=12, horizontalalignment='center', verticalalignment='center')
                    #add white stroke around the font
                    plt.setp(t, path_effects=[PathEffects.withStroke(linewidth=3, foreground="w")])

    ## Addes boxes to a plot
    #
    # @param boxes is a dictonary with tuples of tuples ((x1, y1), (x2, y2))
    # @param plot is used to plot the boxes on
    __fc_colors=['b', 'g', 'r', 'c', 'm', 'y']
    __hatches=[ '/', '\\', '|', '-', '+', 'x', 'o', 'O', '.', '*' ]
    def __append_boxes(self, boxes, plot):
        fc_i = 0;
        h_i = 0;
        if boxes is not None:
            for key in boxes:
                ((x1, y1), (x2, y2)) = boxes[key]
                plot.fill([x1-0.5+0.01, x2+0.5-0.01, x2+0.5-0.01, x1-0.5+0.01],
                          [y1-0.5+0.01, y1-0.5+0.01, y2+0.5-0.01, y2+0.5-0.01],
                          alpha=0.5, hatch=self.__hatches[h_i], fc=self.__fc_colors[fc_i])
                fc_i = (fc_i + 1) % len(self.__fc_colors)
                h_i = (h_i + 1) % len(self.__hatches)
                #plot.plot([x1-0.5, x2+0.5], [y1-0.5, y1-0.5], 'g-')
                #plot.plot([x2+0.5, x2+0.5], [y1-0.5, y2+0.5], 'g-')
                #plot.plot([x2+0.5, x1-0.5], [y2+0.5, y2+0.5], 'g-')
                #plot.plot([x1-0.5, x1-0.5], [y2+0.5, y1-0.5], 'g-')


    ## Plots a numpy array each valu in a new line
    #
    #  @param prefix This prefix is written on the begin of each line
    #  @param lbl Array to print
    def __print_sh_array(self, prefix, lbl):
        for y in range(0, lbl.shape[0]):
            for x in range(0, lbl.shape[1]):
                print((prefix + ": " + str(lbl[y][x])))

    ## Prints the lables after the first and second run
    def print_lables(self):
        self.__print_sh_array("1.run", self.__lables_f);
        self.__print_sh_array("2.run", self.__lables_s);


    ## Generates a plot whith the first and second run as a image.
    def plot_lables(self):
        self.plot_fp_add('Second Pass', self.__lables_s, self.__boundboxes)


    ## Generates a plot with the first pass of python code and a second labeling
    #  from else where
    #
    #  @param text2 Caption for the second plot
    #  @param data2 Lable array for the second plot
    def plot_fp_add(self, text2, data2, boxes2={}):
        #DA plot generation
        #first_p = plt.subplot(121)
        #second_p = plt.subplot(122)
        #second_p.format_coord = self.img_coord
        #second_p.imshow(self.__img, interpolation="nearest", cmap=cm.Greys_r)
        #second_p.set_ylim([self.__max_y-1+0.5, -0.5])
        #second_p.set_xlim([-0.5, self.__max_x-1+0.5])
        #from matplotlib.ticker import MaxNLocator
        #second_p.get_yaxis().set_major_locator(MaxNLocator(integer=True))
        #first_p.format_coord = self.img_coord
        #first_p.imshow(self.__img, interpolation="nearest", cmap=cm.Greys_r)
        #first_p.set_ylim([self.__max_y-1+0.5, -0.5])
        #first_p.set_xlim([-0.5, self.__max_x-1+0.5])
        #first_p.get_yaxis().set_major_locator(MaxNLocator(integer=True))
        #self.__generate_lable_plot(data2, first_p)
        #self.__generate_lable_plot(data2, second_p)
        #self.__append_boxes(boxes2, second_p)
        #plt.show()
        #return

        first_p = plt.subplot(121)
        second_p = plt.subplot(122)
        first_p.format_coord = self.img_coord
        second_p.format_coord = self.img_coord

        first_p.imshow(self.__img, interpolation="nearest", cmap=cm.Greys_r)
        first_p.set_title('First Pass Python')
        #first_p.grid(b=True, which='both', color='k', linestyle='-')
        self.__generate_lable_plot(self.__lables_f, first_p)
        self.__append_boxes(self.__boundboxes, first_p)

        # second pass
        second_p.imshow(self.__img, interpolation="nearest", cmap=cm.Greys_r)
        second_p.set_title(text2)
        self.__generate_lable_plot(data2, second_p)
        self.__append_boxes(boxes2, second_p)

        first_p.set_ylim([self.__max_y-1+0.5, -0.5])
        first_p.set_xlim([-0.5, self.__max_x-1+0.5])
        second_p.set_ylim([self.__max_y-1+0.5, -0.5])
        second_p.set_xlim([-0.5, self.__max_x-1+0.5])

        fig = pylab.gcf()
        fig.canvas.set_window_title('CCL 2-pass')
        plt.show()

    def img_coord(self, x, y):
        col = ""
        row = ""
        #print "max_x = " + str(self.__max_x) + " x = " + str(x)
        #print "max_y = " + str(self.__max_y) + " y = " + str(y)
        if x >= -0.5 and x < self.__max_x+0.5:
            col = str(int(x+0.5))
        if y >= -0.5 and y < self.__max_y+0.5:
            row = str(int(y+0.5))
        return ("x=" + col + " y=" + row)

    ## Generates a plot with the second pass of python code and a second labeling
    #  from else where
    #
    #  @param text2 Caption for the second plot
    #  @param data2 Lable array for the second plot
    def plot_sp_add(self, text2, data2, boxes2={}):
            plt = self.get_plot_sp_add(text2, data2, boxes2)
            plt.show()

    def get_plot_sp_add(self, text2, data2, boxes2={}):
        #f, (first_p, second_p) = plt.subplots(2, frameon=False)
        #f.subplots_adjust(hspace=.2, left=0.05, right=0.975, top=0.95, bottom=0.1)
        first_p = plt.subplot(121)
        second_p = plt.subplot(122)

        first_p.format_coord = self.img_coord
        second_p.format_coord = self.img_coord

        first_p.imshow(self.__img, interpolation="nearest", cmap=cm.Greys_r)
        first_p.set_title('Second Pass Python')
        #first_p.grid(b=True, which='both', color='k', linestyle='-')
        if data2 is not None:
            self.__generate_lable_plot(self.__lables_s, first_p)
        self.__append_boxes(self.__boundboxes, first_p)

        # second pass
        second_p.imshow(self.__img, interpolation="nearest", cmap=cm.Greys_r)
        second_p.set_title(text2)
        if data2 is not None:
            self.__generate_lable_plot(data2, second_p)
        self.__append_boxes(boxes2, second_p)

        first_p.set_ylim([self.__max_y-1+0.5, -0.5])
        first_p.set_xlim([-0.5, self.__max_x-1+0.5])
        second_p.set_ylim([self.__max_y-1+0.5, -0.5])
        second_p.set_xlim([-0.5, self.__max_x-1+0.5])

        return plt




    ## Second pass of the connected component labeling
    #
    #  @param lookup Lookup table as dictionary for the second run
    def __run_2p(self, lookup):
        for y in range(0, self.__lables_f.shape[0]):
            for x in range(0, self.__lables_f.shape[1]):
                if self.__lables_f[y][x] == 0:
                    self.__lables_s[y][x] = 0
                else:
                    self.__lables_s[y][x] = lookup[self.__lables_f[y][x]]

    ## Calculates the bounding boxes around pixels with the same lable
    #
    #  @param lables array with lables of the picture
    #  @return dictionary of all found boxes the values are stored in 2-tuples of 2-tuples ((startx, starty), (endx, endy))

    def __boundbox(self, lables):
        boxes={}
        for y in range(0, lables.shape[0]):
            for x in range(0, lables.shape[1]):
                if lables[y][x] != 0:
                    if lables[y][x] in boxes:
                        ((start_x, start_y), (end_x, end_y)) = boxes[lables[y][x]]

                        if end_x < x:
                            end_x = x

                        if start_x > x:
                            start_x =x

                        end_y = y
                        boxes[lables[y][x]] = ((start_x, start_y), (end_x, end_y))
                    else:
                        boxes[lables[y][x]] = ((x,y), (x,y))
        return boxes


    ## First pass of the connected component labeling
    #
    #  @return equivalent table as dictionary
    def __run_1p(self):
        #pixels in the image: A B C
        #                     D x

        # a_p means a pixel a_l means lable of a

        #max_value means unlabled

        last_lable=0
        equi_d = [[0]]#should be a array of arrays

        for y in range(0, self.__img.shape[0]):
            for x in range(0, self.__img.shape[1]):
                x_p = self.__img[y][x]

                if x == 0:
                    #first in row
                    a_l=0
                    d_l=0
                else:
                    d_l=self.__lables_f[y][x-1]

                if y == 0:
                    #first line
                    b_l=0
                    c_l=0
                else:
                    b_l=self.__lables_f[y-1][x]
                    if x < self.__lables_f.shape[1]-1:
                        c_l=self.__lables_f[y-1][x+1]
                    else:
                        c_l=0
                    if x > 0 :
                        a_l=self.__lables_f[y-1][x-1]


                #if x==3 and y==1:
                #    print ("a_l=" +str(a_l) +" b_l=" +str(b_l) + " c_l=" +str(c_l) +" d_l=" +str(d_l) +" x_p=" +str(x_p))
                if x_p == 0:
                    min_l = np.iinfo(np.int).max
                    findmin = [a_l, b_l, c_l, d_l]
                    for i in findmin:
                        if i < min_l and i > 0:
                            min_l = i

                    if min_l != np.iinfo(np.int).max:
                        self.__lables_f[y][x] = min_l

                        if min_l < a_l + b_l + c_l + d_l: # more than one labled?
                            # store equivalent lable
                            if a_l > min_l:
                                equi_d[a_l].append(min_l)
                            if b_l > min_l:
                                equi_d[b_l].append(min_l)
                            if c_l > min_l:
                                equi_d[c_l].append(min_l)
                            if d_l > min_l:
                                equi_d[d_l].append(min_l)

                    else:
                        # no neighbours is labled
                        self.__lables_f[y][x] = last_lable + 1
                        equi_d.insert(last_lable + 1, [last_lable + 1])
                        last_lable += 1
        return equi_d

    ## Generate lookup table
    #
    #  The equivalent lable dictionary is resolved to a lookup table
    #  The implementation is without any simplifications and in terms
    #  of runtime very bad but it should be correct
    #  @param equi_d The equivalent table as array of arrays
    #  @return Returns the lookup table as a array
    def gen_lookuptable(self, equi_d):

        for i in range(1, len(equi_d)):
            self.__rm_duplicates(equi_d[i])

        for n in range(1, len(equi_d)):
            for i in range(1, len(equi_d)):
                self.__rm_duplicates(equi_d[i])

                for j in range(0, len(equi_d[i])):
                    for k in range (0, len(equi_d[equi_d[i][j]])):
                        equi_d[i].append(equi_d[equi_d[i][j]][k])
                        equi_d[equi_d[i][j]].append(i)
                self.__rm_duplicates(equi_d[i])

        # the arrays of possible lables are sorted. Selecting the smalles label is
        # done by choosing the first element of the array
        for i in range(0, len(equi_d)):
            equi_d[i] = equi_d[i][0]

        return equi_d

    def __rm_duplicates(self, ary):
        ary.sort()
        last = -1
        to_rem = []
        for i in range(0, len(ary)):
            if last == ary[i]:
               to_rem.append(ary[i])
            last = ary[i]
        for i in to_rem:
            ary.remove(i)


if __name__== "__main__":

    from optparse import OptionParser

    parser = OptionParser()
    parser.add_option("-s", "--sfile", dest="ifile",
            help="input image to run connected component labling")
    parser.add_option("-v", dest="verbose", action="store_true",
            help="enable status output")
    parser.add_option("-t", "--threshold", dest="threshold", type="float", default=0.5,
            help="threshold for converting image to black/white. Value 0.0...1.0")
    parser.add_option("-c", "--compare", dest="compare", action="store_true",
            help="just prints the Labels to the stdout")
    parser.add_option("-x", "--max-x", dest="max_x", type="int", default=32,
            help="Max width of image send to ccl")
    parser.add_option("-y", "--max-y", dest="max_y", type="int", default=32,
            help="Max height of image send to ccl")

    (option, args) = parser.parse_args()

    if option.threshold > 1.0 or option.threshold < 0.0:
        print("Threshold needs to be between 0.0 ... 1.0")

    if option.ifile:
        img = option.ifile
    else:
        print("no filename passed as argument img/test1.png used")
        img = "../img/test1.png"

    cl = ComponentLabeling(img, option.verbose,
                              option.threshold, option.max_x,option.max_y)

    if option.compare:
        cl.print_lables()
    else:
        cl.plot_lables()
