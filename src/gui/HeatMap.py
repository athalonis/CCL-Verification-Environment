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

# -*- coding: utf-8 -*-

## Window to analyze errors of one spezific run

from PyQt4 import QtGui, QtCore
import numpy as np
import gui.qlabelplot as qlp
import utils.Helper as hp
import json

try:
    import matplotlib.pyplot as plt
    no_matplot=False
except:
    no_matplot=True
    print("no matplotlib installed")


VERSION=1

class QHeatMap(QtGui.QDialog):

    def __init__(self, fileReader, parent=None):
        super(QHeatMap, self).__init__(parent)
        self.fr = fileReader

        self.imgSize = (self.fr.hw_cfg.img_width, self.fr.hw_cfg.img_height)
 
        self.initUI()
        if not no_matplot:
            self.hmWorker.start()

    def initUI(self):

        vbox = QtGui.QVBoxLayout()

        self.prog = QtGui.QProgressBar(self)
        self.prog.setRange(0, 0)
        self.prog.setVisible(True)
        vbox.addWidget(self.prog)


        hmapbox = QtGui.QHBoxLayout()
        self.elist = QtGui.QListView(self)
        hmapbox.addWidget(self.elist)
        hmapbox.setStretchFactor(self.elist, 3)
 
        self.imgviewer = qlp.QLabelPlot(self.imgSize[0], self.imgSize[1], self,
                False)
        hmapbox.addWidget(self.imgviewer)
        hmapbox.setStretchFactor(self.imgviewer, 7)
        
        self.colorbar = None
        
        self.model = QtGui.QStandardItemModel()
        self.elist.setModel(self.model)
        self.model.itemChanged.connect(self.itemChanged)

        self.mapbox = QtGui.QGroupBox("Error HeatMap")
        self.mapbox.setLayout(hmapbox)
        self.mapbox.setEnabled(False)
        vbox.addWidget(self.mapbox)

        self.hmWorker = HeatMapWorker(self.fr)
        self.connect(self.hmWorker, QtCore.SIGNAL('updateProgress'), self.__updateProgress__)
        self.connect(self.hmWorker, QtCore.SIGNAL('updateImage'), self.__updateImages__)

        self.setLayout(vbox)
        self.setGeometry(300, 300, 800, 600)
        self.setWindowTitle('CCL Verification Architecture - HeatMap')

    def __updateProgress__(self):
        self.prog.setRange(0, self.hmWorker.prog_max)
        self.prog.setValue(self.hmWorker.progress)

    def __updateImages__(self):
        first = True
        for errType in self.hmWorker.images:
            item = QtGui.QStandardItem(self.fr.hw_cfg.errToStr(errType))
            item.setData(errType)
            item.setCheckable(True)
            if first:
                first = False
                item.setCheckState(QtCore.Qt.Checked)
            self.model.appendRow(item)

        self.mapbox.setEnabled(True)
        self.prog.setVisible(False)
        self.__updateMap__()

    def itemChanged(self):
        self.__updateMap__()

    def __updateMap__(self):
        self.heatmatrix = None
        i = 0
        while self.model.item(i) is not None:
            item = self.model.item(i)
            if item.checkState() == QtCore.Qt.Checked:
                if self.heatmatrix is None:
                    self.heatmatrix = self.hmWorker.images[int(item.data())].copy()
                else:
                    self.heatmatrix += self.hmWorker.images[int(item.data())]
            i += 1

        if self.heatmatrix is not None:
            self.imgviewer.clear()
            vmin = 0
            if self.fr.err_found is not None and self.fr.err_droped is not None:
                vmax = self.fr.err_found-self.fr.err_droped
            else:
                vmax = np.max(self.heatmatrix)
            self.colorbar = self.imgviewer.axes.pcolormesh(self.heatmatrix,
                    vmin = vmin, vmax = vmax)
            self.imgviewer.fig.colorbar(self.colorbar)
            self.__fix_labels__()
            self.imgviewer.canvas.draw()

    def __fix_labels__(self):
        self.imgviewer.axes.set_xticks(np.arange(self.imgSize[0])+0.5, minor=False)
        self.imgviewer.axes.set_yticks(np.arange(self.imgSize[1])+0.5, minor=False)
        self.imgviewer.axes.set_ylim([self.imgSize[1], 0])
        self.imgviewer.axes.set_xlim([0, self.imgSize[0]])

        xlbls=[str(i) for i in range(0, self.imgSize[0])]
        ylbls=[str(i) for i in range(0, self.imgSize[1])]

        self.imgviewer.axes.format_coord = self.img_coord
        self.imgviewer.axes.set_xticklabels(xlbls)
        self.imgviewer.axes.set_yticklabels(ylbls)

    # do int coords only
    def img_coord(self, x, y):
        col = ""
        row = ""
        if x >= 0 and x < self.imgSize[0]:
            col = str(int(x))
        if y >= 0 and y < self.imgSize[1]:
            row = str(int(y))

        val=""
        if x > 0 and x < self.imgSize[0] and y > 0 and y < self.imgSize[1] and self.heatmatrix is not None:
            val = "value=" + str(self.heatmatrix[int(y)][int(x)])+ " "
        return val + "x=" + col + " y=" + row





class HeatMapWorker(QtCore.QThread):

    updateStim = QtCore.pyqtSignal(name='updateProgress')
    updateRef = QtCore.pyqtSignal(name='updateImage')

    def __init__(self, fr):
        QtCore.QThread.__init__(self)
        self.__fr = fr
        self.progress = 0
        self.prog_max = 0

        self.__cache_file__ = self.__fr.file_dir +"/"+ self.__fr.file_prefix + "_heatmap"

        self.images = {}

    def __del__(self):
        self.wait()

    def run(self):
        if not self.readFromFile():
            if self.__fr.maxFileNo >0:
                self.prog_max = self.__fr.maxFileNo-1
            self.emit(QtCore.SIGNAL('updateProgress'))
            
            #read in every error log file and add the black pixels up
            self.__fr.resetErrFile()
            errors = self.__fr.readNextErrFile()
            while errors is not None:
                for error in errors:
                    (typ, stimuli) = error
                    self.addErrors(typ, stimuli)
                self.progress += 1
                self.emit(QtCore.SIGNAL('updateProgress'))
                errors = self.__fr.readNextErrFile()
            self.emit(QtCore.SIGNAL('updateImage'))

            self.writeToFile()
        else:
            # data found in cache
            self.emit(QtCore.SIGNAL('updateProgress'))
            self.emit(QtCore.SIGNAL('updateImage'))


    def getEmptyMatrix(self):
        return 255*np.ones((self.__fr.hw_cfg.img_height, self.__fr.hw_cfg.img_width), dtype=np.int)

    #adds up the black pixels of stimuli to a matrix
    def addErrors(self, typ, stimuli):
        if not typ in self.images:
            self.images[typ] = self.getEmptyMatrix()
        bits = str(bin(int(stimuli)))[2:]
        for i in range(len(bits)-1, -1, -1):
            if bits[i] == '1':
                x=(len(bits)-i-1) % self.__fr.hw_cfg.img_width
                y=int((len(bits)-i-1)/self.__fr.hw_cfg.img_width)
                self.images[typ][y][x] += 1

    #writes to cache file
    def writeToFile(self):
        data = (VERSION, self.serializeImages(self.images))
        new_file = open(self.__cache_file__, 'w')
        json.dump(data, new_file)
        new_file.close()

    def serializeImages(self, imgs):
        data = []
        for key in imgs:
            dtype = type(imgs[key][0][0])
            if dtype == np.int8:
                dtype = 8
            if dtype == np.int32:
                dtype = 32
            elif dtype == np.int64:
                dtype = 64
            data.append((key, dtype, imgs[key].tolist()))
        return data

    def deserializeImages(self, blob):
        images = {}

        for d in blob:
            dtype = None
            if d[1] == 8:
                dtype = np.int8
            elif d[1] == 32:
                dtype = np.int32
            elif d[1] == 64:
                dtype = np.int64
            ary=np.zeros((len(d[2]), len(d[2][0])), dtype=dtype)
            for x in range(0, ary.shape[0]):
                for y in range(0, ary.shape[1]):
                    ary[x][y] = d[2][x][y]
            images[d[0]] = ary
        return images

    # reads in cache
    def readFromFile(self):
        import os.path
        if os.path.isfile(self.__cache_file__):
            file_r = open(self.__cache_file__, 'r')
            data = json.load(file_r)
            file_r.close()
            if len(data) == 2:
                if data[0] == 1: #version check
                    self.images = self.deserializeImages(data[1])
            return True
        return False

 
