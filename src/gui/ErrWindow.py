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
import gui.ErrTable as Err
import gui.qlabelplot as qlp
import scipy.misc as spm
import utils.Helper as hp
import cola
import verifier
import sys

class ErrWindow(QtGui.QDialog):

    def __init__(self, fileReader, saveSpace, parent=None):
        super(ErrWindow, self).__init__(parent)
        self.fr = fileReader
        self.saveSpace = saveSpace
        self.initUI()
        self.maximized = False
        self.stimulus = {}

    def initUI(self):

        self.img_ary = None
        self.stim = 0

        self.lblLog = QtGui.QLabel(self)
        self.lblLog.setText("Log Prefix:")
        self.lblLog.adjustSize()

        self.qleLogDir = QtGui.QLineEdit(self)
        self.qleLogDir.setText(self.fr.file_prefix)
        #qleLogDir.textChanged[str].connect(self.onChanged)
        self.qleLogDir.setEnabled(False)


        imgSize = (self.fr.hw_cfg.img_width, self.fr.hw_cfg.img_height)
        self.sw = imgSize[0]
        self.sh = imgSize[1]
        self.errTable = Err.ErrTable(imgSize)

        modelsim = hp.which("vsim")

        grid = QtGui.QGridLayout()
        grid.setSpacing(10)
        grid.addWidget(self.lblLog, 1, 0)
        grid.addWidget(self.qleLogDir, 1, 1)
        grid.addWidget(self.errTable, 2, 0, 2, 2)


        #Right analyzing boxes
        vbox = QtGui.QVBoxLayout()

        #Stimuli save Button
        self.btnStimSave = QtGui.QPushButton('Save Stimulus as Image', self)
        self.btnStimSave.clicked.connect(self.onStimSave)
        self.btnStimSave.setEnabled(False)
        vbox.addWidget(self.btnStimSave)

        #stimuli python
        pystim = QtGui.QVBoxLayout()

        #Stimuli view
        self.stimV = qlp.QLabelPlot(imgSize[0], imgSize[1], self, self.saveSpace)
        pystim.addWidget(self.stimV);

        pystiml = QtGui.QGroupBox("Python Boxes")
        pystiml.setLayout(pystim)
        vbox.addWidget(pystiml)
        vbox.setStretchFactor(pystiml, 1)

        msimbox = QtGui.QVBoxLayout()
        self.btnClearSim = QtGui.QPushButton('Clear Simulation Cache', self)
        self.btnClearSim.clicked.connect(self.clearSimCache)
        self.btnClearSim.setEnabled(False)
        msimbox.addWidget(self.btnClearSim)
        if modelsim is not None:
            self.vsim = True

            self.simlbl = QtGui.QLabel(self)
            self.simlbl.setText("Simulation in progress...")
            self.simlbl.setVisible(False)
            msimbox.addWidget(self.simlbl)
            self.simprog = QtGui.QProgressBar(self)
            self.simprog.setRange(0, 0)
            self.simprog.setVisible(False)
            msimbox.addWidget(self.simprog)

            self.stimDut = qlp.QLabelPlot(imgSize[0], imgSize[1], self, self.saveSpace)
            dutLayoutBox = QtGui.QVBoxLayout()
            dutLayoutBox.addWidget(self.stimDut)
            dutbox = QtGui.QGroupBox("Modelsim DUT Simulation")
            dutbox.setLayout(dutLayoutBox)
            msimbox.addWidget(dutbox)

            self.stimRef = qlp.QLabelPlot(imgSize[0], imgSize[1], self, self.saveSpace)
            refLayoutBox = QtGui.QVBoxLayout()
            refLayoutBox.addWidget(self.stimRef)
            refbox = QtGui.QGroupBox("Modelsim REF Simulation")
            refbox.setLayout(refLayoutBox)
            msimbox.addWidget(refbox)

        else:
            self.vsim = False
            lbl = QtGui.QLabel(self)
            lbl.setText("No VHDL simulations are possible! vsim not in PATH")
            msimbox.addWidget(lbl)

        simbox = QtGui.QGroupBox("Simulation")
        simbox.setLayout(msimbox)
        vbox.addWidget(simbox)
        vbox.setStretchFactor(simbox, 2)
        grid.addLayout(vbox, 2,2)


        self.errTable.doubleClicked.connect(self.doubleClickErrHandler)
#        self.errTable.cellClicked.connect(self.ActivatedHandler)
        self.errTable.setSelectionBehavior(QtGui.QTableView.SelectRows)
        self.errTable.setSelectionMode(QtGui.QTableView.SingleSelection)
        self.errTable.setAlternatingRowColors(True)


        self.tablesel=self.errTable.selectionModel()
        self.tablesel.selectionChanged.connect(self.selChange)

        #connect the box updater thread
        self.boxup = BoxUpdater(imgSize[0], imgSize[1])
        self.connect(self.boxup, QtCore.SIGNAL('updateStim'), self.__updateStimBox__)
        self.connect(self.boxup, QtCore.SIGNAL('updateDut'), self.__updateDutBox__)
        self.connect(self.boxup, QtCore.SIGNAL('updateRef'), self.__updateRefBox__)

        #self.timer = QtCore.QBasicTimer()
        #self.step = 0

        self.setLayout(grid)
        #self.setGeometry(300, 300, 1100, 770)
        self.setWindowTitle('CCL Verification Architecture - Error Inspector')

    def onChanged(self, text):
        None

    def onStimSave(self):
        row = self.errTable.currentRow()
        stim = self.errTable.item(row, 4).stim;
        fe = "Images (*.png *.bmp *.gif *.jpg *.jpeg *.eps * ppm *.tif *.xbm)"
        try:
            filename = QtGui.QFileDialog.getSaveFileName(self, 'Save Stimuli', str(stim) + ".png", fe)
            spm.imsave(filename, self.img_ary)
        except:
            print(sys.exc_info()[0])
            QtGui.QMessageBox.critical(self, "Save failed",
                    "Save stimuli as image failed!")


    def doubleClickErrHandler(self, idx):
        item = self.errTable.itemFromIndex(idx)
        print (str(item.row()))

    def selChange(self, selected, deselected):
        rows = self.tablesel.selectedRows()
        self.maximized = self.isMaximized()
        if len(rows) == 1:
            row=rows[0].row()
            item = self.errTable.item(row, 4)
            self.stim = item.stim
            if (str(item.stim)+"_"+str(self.sw)+"_"+str(self.sh)) in self.stimulus:
                self.img_ary = self.stimulus[str(item.stim)+"_"+str(self.sw)+"_"+str(self.sh)]
            else:
                self.img_ary = qlp.stimToImg(item.stim, self.sw, self.sh)
                self.stimulus[str(item.stim)+"_"+str(self.sw)+"_"+str(self.sh)] = self.img_ary

            self.stimV.addImg(self.img_ary)
            self.stimRef.addImg(self.img_ary)
            self.stimDut.addImg(self.img_ary)
            self.__startUpdateBoxes__()

            # now a stimuli is selected and you can save it
            self.btnStimSave.setEnabled(True)

    def __startUpdateBoxes__(self):
        self.btnClearSim.setEnabled(False)
        #check if last is running and terminate it
        if self.boxup.isRunning():
            self.boxup.terminate()
        self.boxup.setImage(self.img_ary)
        self.boxup.setStim(self.stim)

        if not self.boxup.inCache():
            self.simlbl.setVisible(True)
            self.simprog.setVisible(True)
            self.btnClearSim.setVisible(False)
        self.boxup.start()

    def __updateStimBox__(self):
        self.stimV.appendBoxes(self.boxup.stimBox)

    def __updateDutBox__(self):
        self.stimDut.appendBoxes(self.boxup.dutBox)

    def __updateRefBox__(self):
        self.stimRef.appendBoxes(self.boxup.refBox)
        self.simlbl.setVisible(False)
        self.simprog.setVisible(False)
        self.btnClearSim.setVisible(True)
        self.btnClearSim.setEnabled(True)

    def clearSimCache(self):
        self.boxup.clearCache()
        self.btnClearSim.setEnabled(False)

    def selectLogDir(self):
        filename = QtGui.QFileDialog.getExistingDirectory(self, 'Select LogDir')
        self.logdir = filename
        self.qleLogDir.setText(filename)
        self.logTable.updateLogDir(filename)


class BoxUpdater(QtCore.QThread):

    updateStim = QtCore.pyqtSignal(name='updateStim')
    updateRef = QtCore.pyqtSignal(name='updateRef')
    updateDut = QtCore.pyqtSignal(name='updateDut')

    def __init__(self, width, height):
        QtCore.QThread.__init__(self)
        self.__width__ = width
        self.__height__ = height

        self.stimBox = None
        self.refBox = None
        self.dutBox = None

        # Cache for allready calculated boxes
        self.clearCache()

    def clearCache(self):
        self.cacheStim = {}
        self.cacheRef = {}
        self.cacheDut = {}

    def inCache(self):
        if (self.stim in self.cacheStim) and (self.stim in self.cacheRef) and (self.stim in self.cacheDut):
            return True
        else:
            return False

    def setImage(self, img):
        self.__img__ = img

    def setStim(self, stim):
        self.stim = stim

    def __del__(self):
        self.wait()

    def run(self):
        if self.stim not in self.cacheStim:
            cl = cola.ComponentLabeling(self.__img__, False, 0.5, 
                    self.__width__, self.__height__)
            self.stimBox = cl.get_boxes()
            self.cacheStim[self.stim] = self.stimBox
        self.stimBox = self.cacheStim[self.stim]
        self.emit(QtCore.SIGNAL('updateStim'))

        if self.stim not in self.cacheDut:
            self.dutBox = self.__getVhdlBoxes__("vhdl/ccl_dut")
            self.cacheDut[self.stim] = self.dutBox
        self.dutBox = self.cacheDut[self.stim]
        self.emit(QtCore.SIGNAL('updateDut'))

        if self.stim not in self.cacheRef:
            self.refBox = self.__getVhdlBoxes__("vhdl", "ns")
            self.cacheRef[self.stim] = self.refBox
        self.refBox = self.cacheRef[self.stim]
        self.emit(QtCore.SIGNAL('updateRef'))

    def __getVhdlBoxes__(self, work_dir, resolution="ps"):
        comp_first=verifier.CompareF(self.__img__, False, 20, work_dir,
                "tb_labeling_box", True, resolution,
                self.__width__, self.__height__, False, True)
        comp_first.run_boxes("tb_labeling_box", "1", resolution, False,
                False)
        return comp_first.get_hdl_boxes()["1"]
 
