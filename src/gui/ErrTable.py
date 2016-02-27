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

import sys
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from utils import Types as t

class ErrItem(QTableWidgetItem):
    def __init__(self, err, *args):
        QTableWidgetItem.__init__(self, *args)
        self.err = err
        self.setData(Qt.DisplayRole, err)
        #self.setText(str(err))

class ErrCmpItem(QTableWidgetItem):
    def __init__(self, err, *args):
        QTableWidgetItem.__init__(self, *args)
        self.err = err
        self.setData(Qt.DisplayRole, err)
        self.setText(t.HwCfg.cmpErrToStr(err))

class ErrRefItem(QTableWidgetItem):
    def __init__(self, err, *args):
        QTableWidgetItem.__init__(self, *args)
        self.err = err
        self.setData(Qt.DisplayRole, err)
        self.setText(t.HwCfg.refErrToStr(err))


class ErrDutItem(QTableWidgetItem):
    def __init__(self, err, *args):
        QTableWidgetItem.__init__(self, *args)
        self.err = err
        self.setData(Qt.DisplayRole, err)
        self.setText(t.HwCfg.dutErrToStr(err))

       #if err == 0:
        #    self.setBackgroundColor(QColor(0, 255, 0, 128))
        #elif err == 1:
        #    self.setBackgroundColor(QColor(255, 0, 0, 128))
        #elif err == 2:
        #    self.setBackgroundColor(QColor(255, 0, 0, 100))
        #elif err == 3:
        #    self.setBackgroundColor(QColor(255, 0, 0, 80))


class StimItem(QTableWidgetItem):
    def __init__(self, stim, size, *args):
        QTableWidgetItem.__init__(self, *args)
        self.__size = size
        (w, h) = size
        self.stim = stim
        self.setData(Qt.DisplayRole, stim)
        self.setText(str(stim) + " (0x" + hex(stim) + ")")

        flags = Qt.ItemIsSelectable | Qt.ItemIsUserCheckable | Qt.ItemIsEnabled;
        self.setFlags(flags)

        #generate icon of stimuli
        #pixmap = QPixmap(w, h)
        #pixmap.fill()
        #self.__draw(pixmap)
        #self.setIcon(QIcon(pixmap))

    #def stimToBin(self):
    #    stim_str = ""
    #    stim = self.stim
    #    for i in range(size, 0):
    #        if stim >= 2**i:
    #            stim_str += "1"
    #            stim -= 2**i
    #        else:
    #            stim_str += "0"
    #    return stim_str


    #def __draw(self, pixmap):
    #    painter = pixmap.paintEngine()
    #    #painter.setPen(QColor(255, 255, 255, 255))
    #    val = self.stimToBin #bin(self.stim)
    #    w, h = self.__size
    #    for y in range(w,1):
    #        for x in range(h,1):
    #            if y*x <= len(val):
    #                if val[x*y] == '1':
    #                    painter.drawPoints(QPoint(x, y))



class ErrTable(QTableWidget):
    def __init__(self, size, *args):
        QTableWidget.__init__(self, 0, 5, *args)
        self.__rows = 0
        self.__size = size

        self.setHorizontalHeaderLabels(["DUT Error", "REF Error", "CMP Error" ,"Error Vector", "Stimuli"])
        #self.setUniformRowHeights(True)
        #self.resizeColumnsToContents()

        #add some additional space for sorting arrow
        colw = self.columnWidth(0) + 20
        self.setColumnWidth(0, colw)

        self.resizeRowsToContents()

        self.sortByColumn(4, Qt.AscendingOrder)
        self.setSortingEnabled(False)

    def setAllItems(self, items):
        self.setRowCount(len(items))
        for item in reversed(items):
            (err_cmp, err_ref, err_dut, typeItem, stimItem) = item
            self.setItem(self.__rows, 0, err_dut)
            self.setItem(self.__rows, 1, err_ref)
            self.setItem(self.__rows, 2, err_cmp)
            self.setItem(self.__rows, 3, typeItem)
            self.setItem(self.__rows, 4, stimItem)
            if self.__rows == 0:
                self.resizeRowsToContents()
                self.resizeColumnsToContents()
            self.__rows += 1

    def appendErrors(self, items):
        (typeItem, stimItem) = items
        self.__rows += 1
        self.setRowCount(self.__rows)
        self.setItem(self.__rows-1, 0, typeItem)
        self.setItem(self.__rows-1, 1, stimItem)

    def makeNice(self):
        #self.resizeColumnsToContents()
        #add some additional space for sorting arrow
        #self.setColumnWidth(0, 50)
        #self.setColumnWidth(1, 120)
        #colw = self.columnWidth(0) + 20
        #self.setColumnWidth(0, colw)
        self.setSortingEnabled(True)


def main(args):
    app = QApplication(args)
    data = [(1, 22), (2, 68484), (1, 32853456346), (0, 12374), (3, 3)]
    table = ErrTable(data, (9, 5))
    table.show()
    sys.exit(app.exec_())
 
if __name__=="__main__":
    main(sys.argv)
