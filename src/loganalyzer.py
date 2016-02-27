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


# -*- coding: utf-8 -*-

import sys
from PyQt4 import QtGui, QtCore
import gui.LogTable as Lt
import gui.ErrWindow as Ew
import gui.ErrTable as Et
try:
    import configparser
except ImportError:
    import ConfigParser as configparser

class CclGui(QtGui.QWidget):

    def __init__(self):
        super(CclGui, self).__init__()
        self.config = configparser.ConfigParser()
        self.initUI()

        self.createTable = CreateTable()
        self.createTable.taskFinished.connect(self.showTable)

    def initUI(self):
        self.logdir = ""
        self.read_config()
        self.errWindow = None
        #self.pbar = QtGui.QProgressBar(self)
        #self.pbar.setGeometry(30, 40, 200, 25)

        self.lblLog = QtGui.QLabel(self)
        self.lblLog.setText("Logdir:")
        self.lblLog.adjustSize()

        self.qleLogDir = QtGui.QLineEdit(self.logdir, self)
        #qleLogDir.textChanged[str].connect(self.onChanged)
        self.qleLogDir.setEnabled(False)

        self.btnLogSelect = QtGui.QPushButton('Select', self)
        self.btnLogSelect.clicked.connect(self.selectLogDir)

        self.logTable = Lt.LogTable(self.logdir, self)
        self.logTable.setSelectionBehavior(QtGui.QTableView.SelectRows)
        self.logTable.setSelectionMode(QtGui.QTableView.SingleSelection)
        self.logTable.setAlternatingRowColors(True)

        grid = QtGui.QGridLayout()
        grid.setSpacing(10)
        grid.addWidget(self.lblLog, 1, 0)
        grid.addWidget(self.qleLogDir, 1, 1)
        grid.addWidget(self.btnLogSelect, 1, 2)
        grid.addWidget(self.logTable, 2, 0, 1, -1)

        #self.logTable.mouseDoubleClickEvent.connect(self.doubleClickLogHandler)


        #self.timer = QtCore.QBasicTimer()
        #self.step = 0

        # Progressbar if it takes longer
        self.__progress = QtGui.QProgressDialog("This can take a moment...",
                "..." , 0, 0, self)
        self.__progress.setCancelButton(None)
        self.__progress.setValue(0)
        self.__progress.setRange(0,0)

        self.setLayout(grid)
        #self.setGeometry(300, 300, 1200, 800)
        self.resize(self.logWinWidth, self.logWinHeight)
        self.move(self.logWinXPos, self.logWinYPos)
        if self.logWinFs:
            self.showMaximized()
        self.setWindowTitle('CCL Verification Architecture - Logfile Inspector')
        self.show()

    def onChanged(self, text):
        None

        #progress = QtGui.QProgressDialog("This can take a moment...", "bla" , 0, 0, self)
        #progress.setCancelButton(None)
        #progress.setValue(0)

    def logAnalyze(self, item):
        #item = self.logTable.itemFromIndex(idx)
        self.errWindow = Ew.ErrWindow(item.getFileReader(), self.saveSpace, self)
        self.errWindow.resize(self.errWinWidth, self.errWinHeight)
        self.errWindow.move(self.errWinXPos, self.errWinYPos)
        if self.errWinFs:
            self.errWindow.showMaximized()
        self.createTable.setItem(item)
        self.createTable.start()
        self.__progress.open()

    #def heatMap(self, item):
    #    self.heatMap = Hm.QHeatMap(item.getFileReader(), self)
    #    self.heatMap.show()

    def showTable(self):
        self.errWindow.errTable.setSortingEnabled(False)
        #for items in self.createTable.errItems:
        #    self.errWindow.errTable.appendErrors(items)
        self.errWindow.errTable.setAllItems(self.createTable.errItems)
        self.errWindow.errTable.makeNice()
        self.__progress.close()
        self.errWindow.show()


    def selectLogDir(self):
        filename = QtGui.QFileDialog.getExistingDirectory(self, 'Select LogDir')
        self.logdir = filename
        self.qleLogDir.setText(filename)
        self.logTable.updateLogDir(filename)

    def closeEvent(self, event):
        self.saveConfig()

    def saveConfig(self):
        self.config.set('Main', 'logdir', self.logdir)
        print(self.errWindow)
        if self.errWindow is not None:
            self.config.set('ErrWindow', 'width', str(self.errWindow.width()))
            self.config.set('ErrWindow', 'height', str(self.errWindow.height()))
            self.config.set('ErrWindow', 'xpos', str(self.errWindow.x()))
            self.config.set('ErrWindow', 'ypos', str(self.errWindow.y()))
            self.config.set('ErrWindow', 'fullscreen', str(self.errWindow.maximized))
        self.config.set('LogWindow', 'width', str(self.width()))
        self.config.set('LogWindow', 'height', str(self.height()))
        self.config.set('LogWindow', 'xpos', str(self.x()))
        self.config.set('LogWindow', 'ypos', str(self.y()))
        self.config.set('LogWindow', 'fullscreen', str(self.isMaximized()))

        with open('loganalyzer.conf', 'w') as configfile:
                self.config.write(configfile)



    def read_config(self):
        try:
                self.config.read('loganalyzer.conf')
                self.logdir = self.config.get('Main', 'logdir')
                self.saveSpace = False
                if self.config.get('Main', 'saveSpace') == "True":
                    self.saveSpace = True
                self.errWinWidth = int(self.config.get('ErrWindow', 'width'))
                self.errWinHeight = int(self.config.get('ErrWindow', 'height'))
                self.errWinXPos  = int(self.config.get('ErrWindow', 'xpos'))
                self.errWinYPos = int(self.config.get('ErrWindow', 'ypos'))
                self.errWinFs = False
                if  self.config.get('ErrWindow', 'fullscreen') == "True":
                    self.errWinFs = True

                self.logWinWidth = int(self.config.get('LogWindow', 'width'))
                self.logWinHeight = int(self.config.get('LogWindow', 'height'))
                self.logWinXPos  = int(self.config.get('LogWindow', 'xpos'))
                self.logWinYPos = int(self.config.get('LogWindow', 'ypos'))
                self.logWinFs = False
                if  self.config.get('LogWindow', 'fullscreen') == "True":
                    self.logWinFs = True
        except:
                if not self.config.has_section('Main'):
                    self.config.add_section('Main')
                    #self.config['Main'] = {}
                self.config.set('Main', 'logdir', '')
                self.config.set('Main', 'saveSpace', str(False))
                self.saveSpace = False
                #self.config['Main']['logdir'] = ''
                if not self.config.has_section('ErrWindow'):
                    self.config.add_section('ErrWindow')
                self.config.set('ErrWindow', 'width', str(1100))
                self.config.set('ErrWindow', 'height', str(770))
                self.config.set('ErrWindow', 'xpos', str(300))
                self.config.set('ErrWindow', 'ypos', str(300))
                self.config.set('ErrWindow', 'fullscreen', str(False))
                self.errWinWidth = 1100
                self.errWinHeight = 770
                self.errWinXPos  = 300
                self.errWinYPos = 300
                self.errWinFs = False

                if not self.config.has_section('LogWindow'):
                    self.config.add_section('LogWindow')
                self.config.set('LogWindow', 'width', str(1100))
                self.config.set('LogWindow', 'height', str(770))
                self.config.set('LogWindow', 'xpos', str(300))
                self.config.set('LogWindow', 'ypos', str(300))
                self.config.set('LogWindow', 'fullscreen', str(False))
                self.logWinWidth = 1100
                self.logWinHeight = 770
                self.logWinXPos  = 0
                self.logWinYPos = 0
                self.logWinFs = False


class CreateTable(QtCore.QThread):
    taskFinished =QtCore.pyqtSignal()

    def setItem(self, item):
        self.item = item
        self.__size = (item.getFileReader().hw_cfg.img_width, item.getFileReader().hw_cfg.img_height)
        self.hw_cfg=item.getFileReader().hw_cfg
        self.errItems = []

    def run(self):
        count = 500000
        errors = self.item.getFileReader().resetErrFile()
        errors = self.item.getFileReader().readNextErrFile()
        while not(errors is None) and count>0:
            for err in errors:
                (err_type, stim) = err
                (err_cmp, err_ref, err_dut) = self.hw_cfg.decodeError(err_type)
                self.errItems.append((Et.ErrCmpItem(err_cmp),
                    Et.ErrRefItem(err_ref), Et.ErrDutItem(err_dut),
                    Et.ErrItem(err_type), Et.StimItem(stim, self.__size)))
                count -= len(err)
            errors = self.item.getFileReader().readNextErrFile()
        if count <= 0:
            print("not all errors are insert into the table")
        self.taskFinished.emit()

def main():

    app = QtGui.QApplication(sys.argv)
    cclg = CclGui()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
