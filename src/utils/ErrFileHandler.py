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

import json

class FileWriter():
    ## Writes error and config data of a verification run to the disk
    #
    #  The FileWriter writes a specified amount of errors to one file. If the
    #  number of errors to write exceeds the max_size count a new file will be
    #  written. The file name has a incrementing 12 digit suffix. The maximum
    #  number of files can be limited by max_files.
    #  @param file_prefix prefix of the file name
    #  @param head additional informations stored in every file
    #  @param max_size amount of errors stored per file
    #  @param max_files maximum number of files to store


    def __init__(self, file_prefix, head, max_size=10000, max_files=40000):
        self.__file_prefix = file_prefix
        self.__max_size = max_size # number of records
        self.__max_files = max_files # ~8GB
        self.__first_file = True
        self.__first_size = 5
        self.__file_cnt = 0
        self.__head = head

        self.__buffer = []

    def addRecord(self, rec):
        if self.__file_cnt <= self.__max_files:
            self.__buffer.append(rec)
            if len(self.__buffer) >= self.__max_size or (self.__first_file and
                    (len(self.__buffer) >= self.__first_size)) :
                self.__dump_data()
                self.__first_file = False

    def __dump_data(self):
        new_file_name = self.__file_prefix + "_" + str(self.__file_cnt).zfill(12)
        new_file = open(new_file_name, 'w')
        json.dump((self.__head, self.__buffer), new_file)
        new_file.close()
        self.__buffer = []
        self.__file_cnt += 1


    def __del__(self):
        if len(self.__buffer) > 0:
            self.__dump_data()


import glob, re
import utils.Types as t


class FileReader():
    def __init__(self, file_dir, file_prefix):
        self.file_prefix = file_prefix
        self.file_dir = file_dir
        self.__file_cnt = 0
        self.__errors_read = 0
        self.__file_list = []
        self.__header_file = None
        self.hw_cfg = None
        self.completed = False
        self.err_found = None
        self.err_droped = None
        self.start_stim = None
        self.end_stim = None
        self.start_time = None
        self.end_time = None
        self.date = None
        self.time = None
        self.missing_files = True

        self.findFiles()

        if self.__header_file is not None:
            self.completed = True
            self.readHeader()
        else:
            self.readHwCfg()

    def readNextErrFile(self):
        #if self.__errors_read <= self.__file_cnt:
        if len(self.__file_list) > self.__errors_read:
            file_r = open(self.__file_list[self.__errors_read], 'r')
            (hw_cfg, errors) = json.load(file_r)
            file_r.close()
            self.__errors_read += 1
            return errors
        return None

    def resetErrFile(self):
        self.__errors_read = 0

    def readHwCfg(self):
        if len(self.__file_list) > 0:
            file_r = open(self.__file_list[0], 'r')
            (hw_cfg_list, trash) = json.load(file_r)
            file_r.close()
            self.hw_cfg = t.HwCfg(hw_cfg_list)

    def readHeader(self):
        if self.__header_file is not None:
            file_r = open(self.__header_file, 'r')
            (hw_cfg_list, info) = json.load(file_r)
            file_r.close()
            self.hw_cfg = t.HwCfg(hw_cfg_list)

            if len(info[0]) == 2:
                #info version 0
                (self.err_found, self.err_droped) = info[0]
            elif len(info[0]) > 2:
                #info header with version info
                version = info[0][0]
                if version == 1:
                    (iv, self.err_found, self.err_droped, self.start_stim, self.end_stim) = info[0]
                elif version ==2:
                    (iv, self.err_found, self.err_droped,
                            self.start_stim, self.end_stim,
                            self.start_time, self.end_time) = info[0]

    ## check all files with file_prefix
    #
    def findFiles(self):
        regline = re.compile(r".*\/file_([0-9]{4})_([0-1][0-9])_([0-3][0-9])-"
                +"([0-2][0-9])_([0-5][0-9])_(info_)?([0-9]+)")
        max_file_number=-1

        for files in glob.glob(str(self.file_dir) + "/" + str(self.file_prefix)+"*"):
            res = regline.match(files)

            if res is not None:
                if res.group(6) is not None:#str(files).find("_info", len(str(self.file_dir))) > 0:
                    self.__header_file = files
                else:
                    self.__file_cnt += 1
                    self.__file_list.append(files)

                self.date = (res.group(1), res.group(2), res.group(3))
                self.time = (res.group(4), res.group(5))
                if len(res.group(7)) > 1 and int(res.group(7)) > max_file_number:
                    if res.group(6) == "_":
                        max_file_number = int(res.group(7))


        if self.__file_cnt == max_file_number:
            self.missing_files = False
        self.__file_list = sorted(self.__file_list)

        self.maxFileNo = max_file_number


    ## Lists the different logFiles in logDir
    #
    # @param logDir Directory with logfiles as String
    # @returns list of prefix Strings
    @staticmethod
    def filePrefixes(logDir):
        pref_list = []
        regline = re.compile(r".*\/(file_[0-9]{4}_[0-1][0-9]_[0-3][0-9]-[0-2][0-9]_[0-5][0-9])")

        for files in glob.glob(str(logDir) + "/file_*"):
            res = regline.match(files)
            if res is not None:
                if res.group(1) is not None:
                    if res.group(1) not in pref_list:
                        pref_list.append(res.group(1))
        return pref_list






