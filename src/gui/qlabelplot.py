#!/usr/bin/python3
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


import sys, os, random
from PyQt4.QtCore import *
from PyQt4.QtGui import *

try:
    import matplotlib
    from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
    from matplotlib.figure import Figure
    import matplotlib.cm as cm
    matplotlib_v=matplotlib.__version__
except:
    matplotlib_v=None

#workaround for new versions of matplotlib -> class was renamed
if matplotlib_v is not None:
    try:
        from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg as NavigationToolbar
    except:
        from matplotlib.backends.backend_qt4agg import NavigationToolbar2QT as NavigationToolbar

import numpy as np


class QLabelPlot(QWidget):

    def __init__(self, max_x, max_y, parent=None, saveSpace=False):
        super(QLabelPlot, self).__init__(parent)
        self.__max_x = max_x
        self.__max_y = max_y
        self.saveSpace = saveSpace
        self.dpi = 100

        if matplotlib_v is not None:
            self.initPlot()
            vbox = QVBoxLayout()
            if self.mpl_toolbar is not None:
                vbox.addWidget(self.mpl_toolbar)
            vbox.addWidget(self.canvas)
            self.setLayout(vbox)
        else:
            lbl = QLabel(self)
            lbl.setText("matplotlib not installed")
            vbox = QVBoxLayout()
            vbox.addWidget(lbl)
            self.setLayout(vbox)

        self.setSizePolicy(QSizePolicy.MinimumExpanding,
                QSizePolicy.MinimumExpanding)

    def initPlot(self):
            # 100 dpi and a Size of 5 times 4 inches
            self.fig = Figure((4.0, 4.0), dpi=self.dpi)
            self.canvas = FigureCanvas(self.fig)
            self.canvas.setParent(self)
            self.axes = self.fig.add_subplot(111)
            self.fig.subplots_adjust(left=0.0, right=1.0, top=0.9, bottom=0.1) 
    
            self.__setAxes__()

            self.mpl_toolbar = None
            if not self.saveSpace:
                #NavigationToolbar
                self.mpl_toolbar = NavigationToolbar(self.canvas, self)

            #colors and pattern for boxes
            self.__fc_colors=['b', 'g', 'r', 'c', 'm', 'y']
            self.__hatches=[ '/', '\\', '|', '-', '+', 'x', 'o', 'O', '.', '*' ]
    
    def clear(self):
        self.axes.cla()
        self.fig.clf()
        self.axes = self.fig.add_subplot(111)
        if self.saveSpace:
            self.fig.subplots_adjust(left=0.0, right=1.0, top=1.0, bottom=0.0)

    def __setAxes__(self):
            # do only integer coords
            self.axes.format_coord = self.img_coord

            #set coord ranges
            self.axes.set_ylim([self.__max_y-1+0.5, -0.5])
            self.axes.set_xlim([-0.5, self.__max_x-1+0.5])


    def sizeHint(self):
        if self.saveSpace:
            return QSize(self.__max_x*10+110, self.__max_y*10+110)
        else:
            return QSize(self.__max_x*20+40, self.__max_y*20+80)


    def addImg(self, img):
        self.__img = img
        if matplotlib_v is not None:
            self.axes.cla()
            self.__setAxes__()
            self.axes.imshow(img, interpolation="nearest", cmap=cm.Greys_r)
            self.canvas.draw()

    def appendBoxes(self, boxes):
        if matplotlib_v is not None:
            fc_i = 0;
            h_i = 0;
            if boxes is not None:
                for key in boxes:
                    ((x1, y1), (x2, y2)) = boxes[key]
                    self.axes.fill([x1-0.5+0.01, x2+0.5-0.01, x2+0.5-0.01, x1-0.5+0.01],
                            [y1-0.5+0.01, y1-0.5+0.01, y2+0.5-0.01, y2+0.5-0.01],
                            alpha=0.5, hatch=self.__hatches[h_i], fc=self.__fc_colors[fc_i])
                    fc_i = (fc_i + 1) % len(self.__fc_colors)
                    h_i = (h_i + 1) % len(self.__hatches)
                self.canvas.draw()


    # do int coords only
    def img_coord(self, x, y):
        col = ""
        row = ""
        if x >= -0.5 and x < self.__max_x+0.5:
            col = str(int(x+0.5))
        if y >= -0.5 and y < self.__max_y+0.5:
            row = str(int(y+0.5))
        return ("x=" + col + " y=" + row)

def stimToImg(stim, max_x, max_y):
    img = 255*np.ones((max_y, max_x), dtype=np.int)
    bits = str(bin(int(stim)))[2:]
    for i in range(len(bits)-1, -1, -1):
        if bits[i] == '1':
            x=(len(bits)-i-1) % max_x
            y=int((len(bits)-i-1)/max_x)
            img[y][x] = 0
    return img

if __name__ == "__main__":
    app = QApplication(sys.argv)
    form = QLabelPlot(6, 6)
    form.show()
    form.addImg(stimToImg(38354892, 6, 6))
    form.appendBoxes({'a': ((0,1), (2,3))})
    app.exec_()
