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

import sys
from PyQt4.QtCore import *
from PyQt4.QtGui import *

import gui.HeatMap as Hm
import datetime

import utils.ErrFileHandler as Fh

class LogTable(QTableWidget):
    def __init__(self, logdir, analyzer, *args):
        self.__logdir = logdir
        QTableWidget.__init__(self, 0, 12, *args)
        self.__rows = 0

        self.__analyzer = analyzer

        self.__append_logs()

        self.setHorizontalHeaderLabels(["Date", "Logfile", "Size",
        "Inst", "Start Stim", "End Stim",
        "Err recorded", "Err dropped",
        "Total Errors", "Runtime", "Clk/Image", "Clk/Pixel"])
        self.resizeColumnsToContents()
        self.setSortingEnabled(True)
        self.resizeRowsToContents()

        self.popMenu = QMenu(self)
        self.popMenu.addAction('Error Inspector', self.onErrorInspector)
        self.popMenu.addAction('HeatMap', self.onHeatMap)
    

    def generateHeatmap():
        print("clicked")


    def mouseDoubleClickEvent(self, e):
        if e.button() == Qt.LeftButton:
            self.__analyzer.logAnalyze(self.currentItem())

    def onErrorInspector(self):
        self.__analyzer.logAnalyze(self.currentItem())

    def onHeatMap(self):
    #    self.__analyzer.heatMap(self.currentItem())
        self.heatMap = Hm.QHeatMap(self.currentItem().getFileReader(), self)
        self.heatMap.show()

    def mouseReleaseEvent(self, e):
        if e.button() == Qt.RightButton:
            self.popMenu.exec_(e.globalPos())  


    def updateLogDir(self, logdir):
        self.__logdir = logdir
        self.clear()
        self.setSortingEnabled(False)
        self.__append_logs()

        self.setHorizontalHeaderLabels(["Date", "Logfile", "Image Size",
        "Instances", "Start Stimuli", "End Stimuli",
        "Errors Recorded", "Errors Droped",
        "Total Errors", "Runtime", "Clocks per Image", "Clocks per Pixel"])
        self.setSortingEnabled(True)
        self.resizeColumnsToContents()
        self.resizeRowsToContents()

    def __append_logs(self):
        #get all file prefixes
        if self.__logdir is not None:
            self.__fprefix=Fh.FileReader.filePrefixes(self.__logdir)
            for files in self.__fprefix:
                fr = Fh.FileReader(self.__logdir, files)
                self.__rows += 1
                self.setRowCount(self.__rows)
                for i in range (0, 12):
                    item = LogItem(fr, i)
                    self.setItem(self.__rows-1, i, item)

class LogItem(QTableWidgetItem):

    def __init__(self, fr, col, *args):
        QTableWidgetItem.__init__(self, *args)
        self.__fr = fr

        flags = Qt.ItemIsSelectable | Qt.ItemIsUserCheckable | Qt.ItemIsEnabled;
        self.setFlags(flags)

        if col == 0:
            if self.__fr.date is not None and self.__fr.time is not None:
                date = self.__fr.date
                time = self.__fr.time
                datestr = date[0] + "/" + date[1] + "/" + date[2]
                timestr = time[0] + ":" + time[1]
                self.setText(datestr + " " + timestr)
        elif col == 1:
            self.setText(self.__fr.file_prefix)
        elif col == 2:
            if self.__fr.hw_cfg is not None:
                imgSize = str(self.__fr.hw_cfg.img_width) + "x" + str(self.__fr.hw_cfg.img_height)
                self.setText(imgSize)
        elif col == 3:
            if self.__fr.hw_cfg is not None:
                inst = str(self.__fr.hw_cfg.instances)
                self.setText(inst)
        elif col == 4:
            if self.__fr.start_stim is not None:
                self.setText(str(self.__fr.start_stim))
        elif col == 5:
            if self.__fr.end_stim is not None:
                self.setText(str(self.__fr.end_stim))
        elif col == 6:
            if  self.__fr.err_found is not None:
                if self.__fr.err_droped is not None:
                    self.setText(str(int(self.__fr.err_found) -
                        int(self.__fr.err_droped)))
            else:
                self.setText("run incomplete");
        elif col == 7:
            if self.__fr.err_droped is not None:
                self.setText(str(self.__fr.err_droped))
            else:
                self.setText("run incomplete");
        elif col == 8:
            if self.__fr.err_found is not None:
                self.setText(str(self.__fr.err_found))
            else:
                self.setText("run incomplete");
        elif col == 9:
            if self.__fr.start_time is not None and self.__fr.end_time is not None:
                runtime=self.__fr.end_time-self.__fr.start_time
                self.setText(str(datetime.timedelta(microseconds=runtime)))
            else:
                self.setText("unknown");
        elif col == 10 or col == 11:
            if self.__fr.hw_cfg is not None and self.__fr.start_time is not None and self.__fr.end_time is not None and  self.__fr.start_stim is not None and self.__fr.end_stim is not None:
                instances = self.__fr.hw_cfg.instances
                runtime=self.__fr.end_time-self.__fr.start_time
                frequency=125
                tested_pics=self.__fr.end_stim - self.__fr.start_stim
                clocksperimage = float(runtime)*frequency*instances/tested_pics
                if col == 10:
                    self.setText(("{0:.04f}").format(clocksperimage))
                elif col == 11:
                    imgSize = self.__fr.hw_cfg.img_width * self.__fr.hw_cfg.img_height
                    self.setText(("{0:.04f}").format(clocksperimage/imgSize))
            else:
                self.setText("unknown");



    def getFileReader(self):
        return self.__fr

