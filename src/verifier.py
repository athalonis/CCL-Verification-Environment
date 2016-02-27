#!/usr/bin/env python
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



ccl_c_dir="ccl_single_pass_c_code/"

import subprocess
import signal
import glob
import os
import re
import numpy as np
import threading
from PIL import Image
from cola import ComponentLabeling as cola
from converter import Img_conv as Img_conv


class CompareCP:
    def get_error_cnt (self):
        return self.__error_cnt

    def get_report (self):
        return self.__report

    def __init__(self, timeout, max_x, max_y, file_show=None):
        self.__timeout = timeout
        self.__report = ""
        self.__error_cnt = 0
        self.__c_box = []

        # convert images
        try:
            os.mkdir(ccl_c_dir + "/img");
        except:
            None

        for files in glob.glob(ccl_c_dir + "/img/*.pbm"):
            os.remove(files)

        destreg = re.compile(r".*/(.*)$")

        file_chk=""
        file_cnt=0
        if file_show is None:
            for files in glob.glob("../img/*.pbm"):
                if files != "../img/sim_in.pbm" and files != "../img\\sim_in.pbm":
                    img = Img_conv(files, max_x, max_y, 0.5)
                    m = destreg.match(files)
                    if m.group(1) is not None:
                        file_cnt+=1
                        file_chk+="img/" + m.group(1) + "\n"
                        img.save(ccl_c_dir + "/img/" + m.group(1))
        else:
            img = Img_conv(file_show, max_x, max_y, 0.5)
            m = destreg.match(file_show)
            if m.group(1) is not None:
                file_cnt+=1
                file_chk+="img/" + m.group(1) + "\n"
                img.save(ccl_c_dir + "/img/" + m.group(1))

        f = open(ccl_c_dir + "/test_batch_01.txt", "w")
        f.write(str(file_cnt) + "\n" + file_chk)
        f.close()
        del f

        self.get_c_box()


        if file_show is None:
            for files in glob.glob("../img/*.pbm"):
                if files != "../img/sim_in.pbm" and files != "../img\\sim_in.pbm":
                    file_cnt+=1
                    pycola = cola(files, max_x=max_x, max_y=max_y);
                    self.chk_file(files, pycola)
                    del pycola
        else:
            pycola = cola(file_show, max_x=max_x, max_y=max_y);
            c_boxes=self.chk_file(file_show, pycola)
            print((str(c_boxes)))
            pycola.plot_sp_add('Boxes C', None, c_boxes)



    def chk_file(self, files, pycola):
        self.__report += "Check file: " + files + "\n"
        py_boxes = pycola.get_boxes().copy()
        c_boxes = {}
        box_cnt = 0

        for b in py_boxes:
            ((py_start_x, py_start_y), (py_end_x, py_end_y)) = py_boxes[b]


            found = False
            for bc in self.__c_box:
                (stim_file, c_start_y, c_start_x, c_end_y, c_end_x) = bc
                c_end_x -= 1
                c_end_y -= 1

                c_boxes[str(c_start_x) + str(c_start_y) + str(c_end_x) + str(c_end_y)] = ((c_start_x, c_start_y), (c_end_x, c_end_y))
                box_cnt += 1

                if stim_file == files[3:] and py_start_x == c_start_x and py_start_y == c_start_y and py_end_x == c_end_x and py_end_y == c_end_y:
                    found = True
                    self.__c_box.remove(bc)
                    break
            if not found:
                self.__report += "\033[91mError\033[0m" + " Python Box: ((" + str(py_start_x)
                self.__report += ", " + str(py_start_y) + "), (" + str(py_end_x) + ", " + str(py_end_y) + ")"
                self.__report += " not in C implementation\n"
                self.__error_cnt += 1

        for bc in self.__c_box:
            (stim_file, c_start_y, c_start_x, c_end_y, c_end_x) = bc
            c_end_x -= 1
            c_end_y -= 1
            if stim_file == files[3:]:
                self.__report += "\033[91mError\033[0m" + " C Box: ((" + str(c_start_x)
                self.__report += ", " + str(c_start_y) + "), (" + str(c_end_x) + ", " + str(c_end_y) + ")"
                self.__report += " not in Python implementation\n"
                self.__error_cnt += 1

        del pycola
        return c_boxes

    def get_c_box(self):
        c_box = C_parser()
        c_box.start()

        while not c_box.done:
            c_box.event.wait(self.__timeout)
            if not c_box.event.is_set():
                break;

        if not c_box.done:
            self.__report += "\033[91mError\033[0m" + " Verification with C Code timedout\n"
            self.__error_cnt += 1
        else:
            self.__c_box = c_box.getMessages()

        del c_box



class CompareF:
    def get_py_lable (self):
        return self.__py_lable

    def get_hdl_lable (self):
        return self.__hdl_lable

    def get_hdl_boxes (self):
        return self.__hdl_boxes

    def get_error_cnt (self):
        return self.__error_cnt

    def get_report (self):
        return self.__report

    def get_pycola(self):
        return self.__pycola

    def __init__(self, stim_file, passone, timeout, wdir, hdl_file, box_only,
            resolution, max_x, max_y, continuous, run_only=False):

        self.__timeout = timeout
        self.__wdir = wdir
        self.__max_x__ = max_x
        self.__max_y__ = max_y
        self.__passone__ = passone
        self.__continuous__ = continuous
        self.__resolution__ = resolution
        self.__hdl_file__ = hdl_file
        self.__stim_file__ = stim_file
        self.__regmeta = re.compile(r".*metavalue detected.*")

        self.__py_colas = {}
        self.__py_lables = {}
        self.__hdl_lables = {}
        self.__px_boxes = {}
        self.__hdl_boxes = {}


        self.__report = ""
        self.__error_cnt=0

        if not run_only:
            self.__prepare__()
        else:
            #write stimulus file
            j = Image.fromarray(self.__stim_file__.astype(np.uint8))
            j.mode = "1";
            j.save("../img/sim_in.pbm")
            del j

    def __prepare__(self):
        from cola import ComponentLabeling as cola
        self.__pycola = cola(self.__stim_file__, max_x=self.__max_x__,
                max_y=self.__max_y__);

        #labels of first pass
        if self.__passone__:
            self.__py_lable = self.__pycola.get_lable_f()
        else:
            self.__py_lable = self.__pycola.get_lable_s()

        #generate empty array to store results of vhdl output
        self.__hdl_lable = -1*np.ones(self.__py_lable.shape, dtype=np.int)

        if not self.__continuous__:
            self.__py_colas[self.__stim_file__] = self.__pycola
            self.__py_lables[self.__stim_file__] = self.__py_lable
            self.__hdl_lables[self.__stim_file__] = self.__hdl_lable



        #write test image file for vhdl
        j = Image.fromarray(self.__pycola.get_img().astype(np.uint8))
        j.mode = "1";
        j.save("../img/sim_in.pbm")
        del j
        #if stim_file != "../img/sim_in.pbm":
        #    shutil.copy(stim_file, "../img/sim_in.pbm")


        if not box_only:
            self.verify_labels(self.__hdl_file__, self.__stim_file__,
                    self.__resolution__, self.__continuous__)

        if not self.__passone__:
            if self.__hdl_file__ == "tb_labeling":
                self.run_boxes("tb_labeling_box", self.__stim_file__,
                        self.__resolution__, self.__continuous__)
            elif self.__hdl_file__ == "tb_labeling_cont":
                self.run_boxes("tb_labeling_box_cont", self.__stim_file__,
                        self.__resolution__, self.__continuous__)
            else:
                self.run_boxes(self.__hdl_file__, self.__stim_file__,
                        self.__resolution__, self.__continuous__)

    def verify_labels(self, hdl_file, stim_file, resolution="ns", continuous=False):
        vsim = VSIM_parser(hdl_file, "vhdl/", resolution)
        vsim.start()

        #compile some regex pattern
        if continuous:
            regline = re.compile(r"File: '([^']+)' Label: ([0-9]+).*")
        else:
            regline = re.compile(r"(Label:) ([0-9]+).*")

        # index of picture
        pos_x=0
        pos_y=0

        while not vsim.done:
            vsim.event.wait(self.__timeout)
            if not vsim.event.is_set():
                break;
            messages = vsim.getMessages()
            for message in messages:
                (time, severity, text) = message
                if severity == "Note":
                    res = regline.match(text)

                    if res is None:
                        print(("unparsed text: " + text))

                    elif res.group(2) is not None:
                        label = int(res.group(2))
                        if continuous:
                            img_file = res.group(1)[3:]
                            stim_file = img_file
                            if img_file not in self.__py_lables:
                                pos_x = 0
                                pos_y = 0
                                self.__py_colas[img_file] = cola(stim_file, max_x=self.__max_x__, max_y=self.__max_y__);
                                self.__py_lables[img_file] = self.__py_colas[img_file].get_lable_s()
                                self.__hdl_lables[img_file] = -1*np.ones(self.__py_lables[img_file].shape, dtype=np.int)

                        if pos_y >= len(self.__py_lables[stim_file]):
                            self.__report += stim_file + ": additional pixel (x=" + str(pos_x) +", y=" + str(pos_y) +")\n"
                            self.__error_cnt += 1
                        else:
                            self.__hdl_lables[stim_file][pos_y][pos_x] = label
                            if self.__py_lables[stim_file][pos_y][pos_x] != label:
                                self.__report += ("\033[91mError\033[0m" + " File: "+ stim_file +" at pixel x=" + str(pos_x) + " y=" +
                                        str(pos_y) + " expected: " + str(self.__py_lables[stim_file][pos_y][pos_x]) + " vhdl: " +
                                        str(label) + " at time: " + str(time) + "\n")
                                self.__error_cnt += 1

                        pos_x = pos_x + 1
                        if pos_x == len(self.__py_lable[0]):
                            pos_y = pos_y + 1
                            pos_x = 0
                    elif res.group(2) is not None:
                        self.__report = "\033[91mError\033[0m" + "Unknown Message: " + text + "\n"

                else:
                    metaval = self.__regmeta.match(text)
                    if not(severity == "Warning" and metaval is not None):
                        self.__report += severity + " " + text + "\n"
                        if severity != "Note" and severity != "Warning":
                            #self.__error_cnt += 1
                            None
                            #TODO report this seperately

        if not vsim.done:
            self.__report = self.__report + stim_file + ": Output of data reached timeout in 2-pass simulation. Simulation abort\n"
            self.__error_cnt += 1

        for files in self.__py_lables:
            if len(self.__py_lables[files][0]) >  pos_y and pos_x != 0:
                self.__report = self.__report + files + ": Not all pixels processed. First unprocessed pixel: x=" + str(pos_x+1) + " y=" + str(pos_y+1) + "\n"

                self.__error_cnt += 1

        del vsim



    def run_boxes(self, hdl_file, stim_file, resolution="ns",
            continuous=False, compare=True):
        vsim = VSIM_parser(hdl_file, self.__wdir, resolution)
        vsim.start()
        if continuous:
                    regline = re.compile(r"File: '([^']+)' Box: \(([0-9]+), ([0-9]+)\), \(([0-9]+), ([0-9]+)\).*|Box: (error).*")
        else:
                    regline = re.compile(r"(Box): \(([0-9]+), ([0-9]+)\), \(([0-9]+), ([0-9]+)\).*|Box: (error).*")
        cnt={}

        if (stim_file not in self.__px_boxes) and compare:
            self.__px_boxes[stim_file] = self.__py_colas[stim_file].get_boxes().copy()
            self.__hdl_boxes[stim_file] = {}
            cnt[stim_file] = 0
        elif not compare:
            self.__hdl_boxes[stim_file] = {}
            cnt[stim_file] = 0


        while not vsim.done:
            vsim.event.wait(self.__timeout)
            if not vsim.event.is_set():
                break;
            messages = vsim.getMessages()
            for message in messages:
                (time, severity, text) = message

                                #print ("test:" + str(message))
                if severity == "Note":
                    res = regline.match(text)
                    if res is None:
                        print(("unparsed text: \""+text+ "\""))
                    elif res.group(6) is not None:
                        self.__error_cnt += 1
                        self.__report = "Recognised error with to small heap\n"
                    elif res.group(2) is not None:
                        img_file = res.group(1)[3:]
                        if continuous:
                            self.__px_boxes[img_file] = self.__px_boxes[stim_file]
                            self.__hdl_boxes[img_file] = self.__hdl_boxes[stim_file]
                            cnt[stim_file] = cnt[img_file]
                            stim_file = img_file

                        start_x = int(res.group(2))
                        start_y = int(res.group(3))
                        end_x = int(res.group(4))
                        end_y = int(res.group(5))

                        self.__hdl_boxes[stim_file][cnt[stim_file]] = ((start_x, start_y), (end_x, end_y))
                        cnt[stim_file] += 1

                        if compare:
                            found = False
                            for b in self.__px_boxes[stim_file]:
                                ((py_start_x, py_start_y), (py_end_x, py_end_y)) = self.__px_boxes[stim_file][b]

                                if py_start_x == start_x and py_start_y == start_y and py_end_x == end_x and py_end_y == end_y:
                                    found = True
                                    del self.__px_boxes[stim_file][b]
                                    break

                            if not found:
                                self.__report += "\033[91mError\033[0m" + " File: '" + stim_file
                                self.__report += "' VHDL found box ((" + str(start_x) + ", "
                                self.__report += str(start_y) + "), (" + str(end_x) + ", "
                                self.__report += str(end_y) + ")) but python not\n"
                                self.__error_cnt += 1
                    elif res.group(3) is not None:
                        self.__report = "\033[91mError\033[0m" + "Unknown Message: " + text
                else:
                    metaval = self.__regmeta.match(text)
                    if not(severity == "Warning" and metaval is not None):
                        self.__report += severity + " " + text + "\n"
                        if severity != "Note" and severity != "Warning":
                            #self.__error_cnt += 1
                            #TODO: Report this separatly
                            None

        if compare:
            for f in self.__px_boxes:
                if self.__px_boxes[f] != {}:
                    for b in self.__px_boxes[f]:
                        ((start_x, start_y), (end_x, end_y)) = self.__px_boxes[f][b]
                        self.__report += "\033[91mError\033[0m" + " File: '" + f
                        self.__report += "' VHDL missing box ((" + str(start_x) + ", "
                        self.__report += str(start_y) + "), (" + str(end_x) + ", " + str(end_y) + "))\n"
                        self.__error_cnt += 1

        if not vsim.done:
            self.__report = self.__report + stim_file + ": Output of data reached timeout in simulation of 2-pass with boundbox calculation. Simulation abort\n"
            self.__error_cnt += 1
        del vsim





class Exec_parser(threading.Thread):

    ## Executes a binary file and parses the output
    #
    #  You can use the event.wait to wait for new messages or the done signal
    #  The boolean done gives you the information if the simulation is done
    #  @param cmd command to execute
    #  @param cwd working directory
    #  @param regex used to parse the output of each line of stdout and
    #  use the result as parameter to run the eval_line

    def __init__(self, cmd, cwd=".", regex = None):
        super(Exec_parser, self).__init__()
        self.__cmd = cmd;
        self.__cwd = cwd
        self.event = threading.Event()
        self.__sema = threading.Semaphore()
        self.__messages =  []
        self.done = False
        self.__stop = False
        # store parsed messages

        # overwrite this values
        self.__regline = re.compile(regex)
        print(("Exec: " + str(cmd)))
        print(("CWD: " + self.__cwd))
        self.__proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, cwd=self.__cwd)

    def add_message(self, m):
        with self.__sema:
            self.__messages.append(m)
            self.event.set()


    ## Get all Messages stored in the message queue
    def getMessages(self):
        with self.__sema:
            ret_msg = self.__messages
            self.__messages = []
            self.event.clear()
            return ret_msg

    def __del__(self):
        self.__stop = True
        os.kill(self.__proc.pid, signal.SIGKILL)


    ## This methode has to evaluate the result of the regex for each line
    #  you need to overwrite this methode
    def eval_line(self, res):
        None

    def run(self):

        line = ' ';
        while not self.__stop and line != '':
            #apply precompile regex pattern
            line = self.__proc.stdout.readline().decode()
            res = self.__regline.match(line)

            if res is not None:
                self.eval_line(res)

        # notify the event if done
        with self.__sema:
            self.event.set()
            self.done = True


class VSIM_parser(Exec_parser):
    vsim="vsim"

    ## Executes Modelsim and parses the output
    #
    #  You can use the event.wait to wait for new messages or the done signal
    #  The boolean done gives you the information if the simulation is done
    #  @param hdl_entity entity wich should be executed
    #  @param cwd working directory this has to be the directory where the vlib is stored
    def __init__(self, hdl_entity, cwd=".", resolution="ns"):
        super(VSIM_parser, self).__init__([self.vsim, "-c", "-do", "run -all;quit", "-t", resolution, hdl_entity], cwd, r"#    Time: ([0-9]+ [fpnum]s).*|# \*\* (Note|Warning|Error|Failure): (.*)")
        self.__msg = []

    ## This methode has to evaluate the result of the regex for each line
    def eval_line(self, res):
        if res.group(1) is not None:
            # this is the output of a time info

                for m in self.__msg:
                    (severity, text) = m
                    self.add_message((res.group(1), severity, text))
                self.__msg = []

        else:
            if res.group(2) is not None:
                severity = res.group(2)
                if res.group(3) is not None:
                    self.__msg.append((severity, res.group(3)))


class C_parser(Exec_parser):
    ## Executes Cpp Code and parses the output
    #
    #  You can use the event.wait to wait for new messages or the done signal
    #  The boolean done gives you the information if the simulation is done
    #  @param cwd working directory this has to be the directory where the vlib is stored
    def __init__(self, cwd=ccl_c_dir):
        super(C_parser, self).__init__(["./ccl"], cwd, r"Processing file '([^']+)' and .*|Completed object:\[([0-9]+), ([0-9]+)\]x\[([0-9]+), ([0-9]+)\].*")
        self.__file=""

    ## This methode has to evaluate the result of the regex for each line
    def eval_line(self, res):
        if res.group(1) is not None:
            # filename of analyzed file
            self.__file = res.group(1)
        else:
            if res.group(2) is not None and res.group(3) is not None and res.group(4) is not None and res.group(5) is not None :
                self.add_message((self.__file, int(res.group(2)), int(res.group(3)), int(res.group(4)), int(res.group(5))))





if __name__== "__main__":

    from optparse import OptionParser

    parser = OptionParser()
    parser.add_option("-s", "--sim-file", dest="sim_file",
            help="filename for which the simulation should run and the result be visualized")
    parser.add_option("-p", "--pass-one", dest="passone", action="store_true",
            help="only the first pass will be analyzed otherwise the lables after the second pass and the boundboxes will be analyzed")
    parser.add_option("-u", "--uart-tb", dest="uart_tb", action="store_true",
            help="Simulates the uart_tb and compare the output with the python implementation")
    parser.add_option("-n", "--continuous", dest="continuous", action="store_true",
            help="Sends all Pictures in one continuous stream to the DUT")
    parser.add_option("-t", "--timeout", dest="timeout", type="float", default=120.0,
            help="seconds (as float) how long the time between two outputs before abort the simulation")
    parser.add_option("-c", dest="c", action="store_true",
            help="Checks the Python boundbox calculation against the cpp")
    parser.add_option("-v", "--vhdl-dut", dest="v", action="store_true",
            help="Checks the Python boundbox calculation against the vhdl DUT")
    parser.add_option("--no-lables", dest="nl", action="store_true",
            help="Don't check lables")
    parser.add_option("-x", "--max-x", dest="max_x", type="int", default=32,
            help="Max width of image send to ccl")
    parser.add_option("-y", "--max-y", dest="max_y", type="int", default=32,
            help="Max height of image send to ccl")
    parser.add_option("-d", "--input-dir", dest="indir" , default="../img/",
            help="Input dir used to check all Files")
    parser.add_option("-e", "--file-extension", dest="fext", default="pbm",
            help="File extension for the input dir run (default \"pbm\")")
    (option, args) = parser.parse_args()

    fext = option.fext
    indir = option.indir
    box_only = False
    hdl_file = "tb_labeling"
    resolution = "ns"
    if option.uart_tb:
        hdl_file = "tb_com_uart"
        resolution = "ps"
        box_only = True
    if option.passone:
        hdl_file = "tb_labeling_p1"

    wdir="vhdl/"
    if option.v:
        wdir="vhdl/ccl_dut/"
        box_only = True

    if option.nl:
        box_only = True

    if (not option.c) and option.sim_file:
        if option.passone:
            comp_first=CompareF(option.sim_file, option.passone, option.timeout, wdir,
                        hdl_file, box_only, resolution, option.max_x,
                        option.max_y, False)
            comp_first.get_pycola().plot_fp_add('First Pass HDL',
                                                comp_first.get_hdl_lable())
        else:
            comp_first=CompareF(option.sim_file, False, option.timeout, wdir,
                    hdl_file, box_only, resolution, option.max_x,
                    option.max_y, False)

            errors = comp_first.get_error_cnt()
            print(str(errors) + " errors reported")
            print("error report: \n" + comp_first.get_report())

            if box_only:
                boxes = comp_first.get_hdl_boxes()
                if len(boxes) == 1:
                    for k in boxes:
                        comp_first.get_pycola().plot_sp_add('Boxes HDL', None, boxes[k])
                elif len(boxes) == 0:
                    comp_first.get_pycola().plot_sp_add('Boxes HDL', None, None)

                else:
                    print ("more outputs received than expected")
                    print((str(boxes)))
            else:
                boxes = comp_first.get_hdl_boxes()
                if len(boxes) <= 1:
                    for k in boxes:
                        comp_first.get_pycola().plot_sp_add('Second Pass HDL',
                          comp_first.get_hdl_lable(), boxes[k])
                elif len(boxes) == 0:
                    comp_first.get_pycola().plot_sp_add('Second Pass HDL',
                        comp_first.get_hdl_lable(), None)
                else:
                    print ("more outputs received than expected")
                    print((str(boxes)))


    else:
        # run verification of all availible stimuli files and generate a report
        # count errors
        errors=0
        chkdfiles=""
        err_by_file={}
        report=""

        if option.c:
            cmp_cp = CompareCP(option.timeout, option.max_x, option.max_y, option.sim_file)
            errors = cmp_cp.get_error_cnt()
            print((cmp_cp.get_report()))

        elif option.continuous:
            cnt = 0
            filenames = ""
            for files in glob.glob(indir + "/*." + option.fext):
                if files != indir + "/sim_in." + fext and files != indir + "\\sim_in."+fext:
                    filenames += "../" + files + "\n"
                    cnt += 1
            f = open("../img/continuous.files", 'w')
            f.write(str(cnt) + "\n")
            f.write(str(option.max_x) + "\n")
            f.write(str(option.max_y) + "\n")
            f.write(filenames)
            f.close()

            hdl_file="tb_labeling_cont"
            comp_first=CompareF(files, option.passone, option.timeout, wdir, hdl_file,
                    box_only, resolution, option.max_x, option.max_y, True)

            errors = errors + comp_first.get_error_cnt()
            print((comp_first.get_report()))

        else:
            #run vhdl simulation for each input file
            for files in glob.glob(indir + "/*."+fext):
                if files != indir + "/sim_in." +fext and files != indir + "\\sim_in." +fext:
                    print(("\n\nStart verification with input of " + files+"\n"))
                    chkdfiles = chkdfiles + files +'\n'

                    comp_first=CompareF(files, option.passone, option.timeout, wdir,
                            hdl_file, box_only, resolution, option.max_x, option.max_y, False)

                    errors = errors + comp_first.get_error_cnt()
                    err_by_file[files] = comp_first.get_error_cnt()
                    print((comp_first.get_report()))


            print("Verification with the following files:")
            for filename in err_by_file:
                if err_by_file[filename] == 0:
                    print(("\033[92m" + filename + "\033[0m"))
                else:
                    print(("\033[91m" + filename + " errors: " + str(err_by_file[filename]) + "\033[0m"))



        if errors == 0:
            print("\033[92mVerification successful\033[0m")
        else:
            print(report)
            print(("\033[91mVerification failed\033[0m with " + str(errors) + " errors"))

        if wdir == "vhdl/ccl_dut/":
            print(("The verification is only valid if you run ./mk_build.sh in "+wdir))
            print("Don't forget to run ./mk_synthesis.sh before a synthesis run")

