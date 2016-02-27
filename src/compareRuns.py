#!/usr/bin/env python3
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


import utils.ErrFileHandler as Fh
import sqlite3

class RunDiff():
    def __init__(self, fh1, fh2):

        #to always get the same filenmame whatever the order of the files is...
        fns=sorted((fh1.file_prefix, fh2.file_prefix))
        self.fhs = [fh1, fh2]
        if fns[0] != fh1.file_prefix:
            self.fhs[0] = fh2
            self.fhs[1] = fh1

        self.__fns__ = fns
        self.__dbFile__ = fh1.file_dir + "/diff_" + fns[0] + "_" + fns[1]+".db";
        self.__dbFiles__ = [self.fhs[0].file_dir + "/sql_" + fns[0] +".db",
                self.fhs[1].file_dir + "/sql_" + fns[1] +".db"];

        self.__fh1__ = fns[0]
        self.__fh2__ = fns[1]

        print("dbfilename: " + self.__dbFile__)
        print("dbfile1: " + self.__dbFiles__[0])
        print("dbfile2: " + self.__dbFiles__[1])

        self.__openDBs__()

    #opens the required database files and creates it if required
    def __openDBs__(self):
        import os.path
        self.fDb = [None, None]
        for i in range (0, 2):
            if os.path.isfile(self.__dbFiles__[i]):
                self.fDb[i] = sqlite3.connect(self.__dbFiles__[i])
                if not self.__isFileDbValid__(i):
                    #database corrupt recreate...
                    print("database file corrupt recreate database...")
                    self.fDb[i]. close()
                    os.remove(self.__dbFiles__[i])
                    self.fDb[i] = sqlite3.connect(self.__dbFiles__[i])
                    self.__createFileDB__(i)
            else:
                self.fDb[i] = sqlite3.connect(self.__dbFiles__[i])
                self.__createFileDB__(i)

        if os.path.isfile(self.__dbFile__):
            self.db = sqlite3.connect(self.__dbFile__)
        else:
            #database does not exist
            self.db = sqlite3.connect(self.__dbFile__)
            self.__createDB__()

    def __isFileDbValid__(self, idx):
        cursor = self.fDb[idx].cursor()
        cursor.execute("SELECT state FROM state where value='done'")
        res = cursor.fetchall()
        print(res)
        if len(res) == 1:
            if res[0][0] == 1:
                return True
        return False

    #reads a JSON file and adds all errors and stimulus to the database
    def __createFileDB__(self, idx):
        cursor = self.fDb[idx].cursor()
        cursor.execute("""CREATE Table state (value TEXT, state INTEGER)""");
        cursor.execute("""CREATE Table log (error LONG, stimulus LONG)""");
        cursor.execute("""INSERT INTO state VALUES("done", 0)""");
        cursor.execute("""INSERT INTO state VALUES('filesread', 0)""");
        self.fDb[idx].commit()
        files_read = 0

        errs=self.fhs[idx].readNextErrFile()
        while errs is not None:
            cursor.executemany("INSERT INTO log VALUES (?, ?)", errs)
            files_read += 1
            v = (str(files_read), )
            cursor.execute("""update state set state=? where value='filesread'""", v);
            self.fDb[idx].commit()
            errs=self.fhs[idx].readNextErrFile()

        cursor.execute("""update state set state=1 where value='done'""");
        self.fDb[idx].commit()
        self.fDb[idx].close()

    def __createDB__(self):
        cursor = self.db.cursor
        #cursor.execute("""attach database ? as db0""", (self.__dbFiles__[0],))
        #cursor.execute("""attach database ? as db1""", (self.__dbFiles__[1],))
        #self.db.commit()
        #cursor.execute("""select error, stimulus from db0.log as e1 join
        #        db1.log as e2 where e1.stimulus = e2.stimulus""")
        #self.db.commit()
        #print(cursor.fetchall())
        #cursor.execute("""CREATE TABLE

def main():
    fh1 = Fh.FileReader("logdir/", "file_2014_03_01-00_23")
#    fh2 = Fh.FileReader("logdir/", "file_2014_03_01-01_57")
#    fh2 = Fh.FileReader("logdir/", "file_2014_03_01-22_34")
    fh2 = Fh.FileReader("logdir/", "file_2014_03_01-01_19")
    diff = RunDiff(fh2, fh1)


if __name__ == '__main__':
    main()
