#!/usr/bin/env python2.7
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


import serial
import threading
from optparse import OptionParser
import time
import math
from cola import ComponentLabeling as cola

class Uart(object):
	
	def __init__(self, img_file, dev, baud, max_x, max_y, start_img):

		self.__msg = ""
		self.__errors = 0
		#print "Check file: " + img_file + "\n"
		self.__pycola = cola(img_file, max_x=max_x, max_y=max_y)

		uart = serial.Serial(dev, baud, timeout=2, 
												 bytesize=serial.EIGHTBITS, parity=serial.PARITY_NONE, 
												 stopbits=serial.STOPBITS_ONE, xonxoff=False, rtscts=False
												)
		# delay of 1 second recommanded
		time.sleep(1)

		ur = Uart_Receive(self.__pycola.get_boxes().copy(), uart, max_x, max_y)
		ur.start()
		self.__ur = ur

		img = self.__pycola.get_img()
		word = 0
		leng = 7
	

		# reset and start image
		uart.write(bytearray([1]))
		uart.flush()
		time.sleep(.1)
		uart.write(bytearray([start_img]))
		uart.flush()

		for y in range(0, max_y): #(0, img.shape[0]):
			for x in range(0, max_x): #img.shape[1]):
				if x < img.shape[1] and y < img.shape[0]:
					if img[y][x] == 0:
						#print "1"
						word += 2**leng
#					else:
#						print "0"
#				else:
#					print "0"
				leng -= 1

				if leng == -1:
					leng = 7
					uart.write(bytearray([word]))
					uart.flush()
					#print "write word: " + str(bytearray([word]))
					word = 0


	
		#send some zeros
		#uart.write(bytearray([0]))
		#uart.flush()

		#print "Image send by Uart now wait some time for results..."
		time.sleep(1)
		ur.stop = True
		uart.close()
		(self.__errors, self.__msg) = ur.getResult()
		self.__boxes = ur.getBoxes()
		del uart
		del ur
		time.sleep(3)

	def getResult(self):
		return (self.__errors, self.__msg)

	def getBoxes(self):
		return self.__boxes
	
	def getPycola(self):
		return self.__pycola

class Uart_Receive(threading.Thread):
	def __init__(self, boxes, uart, max_x, max_y):
		super(Uart_Receive, self).__init__()
		self.__uart = uart
		self.stop = False
		self.__boxes = boxes
		self.__errors = 0
		self.__received = 0
		self.__word = 0
		self.__x_bits = int(math.ceil(math.log(max_x, 2)))
		self.__y_bits = int(math.ceil(math.log(max_y, 2)))
		self.__uart_boxes = {}
		self.__msg=""
	
	def getBoxes(self):
		return self.__uart_boxes

	def decoder(self, byte):
		rb = bytearray(byte)
		if len(rb) == 1:
			#self.__word += (2**(self.__received*8))*rb[0]
			self.__word = (self.__word << 8) + rb[0]
			self.__received += 1
			if self.__received == 4:
				ey = self.__word & (2**(self.__y_bits)-1)
				ex = (self.__word >> (self.__y_bits)) & (2**(self.__x_bits)-1)
				sy = (self.__word >> (self.__y_bits + self.__x_bits)) & (2**(self.__y_bits)-1)
				sx = (self.__word >> (2*self.__y_bits + self.__x_bits)) & (2**(self.__x_bits)-1)
				box = ((sx, sy), (ex, ey))
				self.__word = 0
				self.__received = 0
				self.__uart_boxes[str(sx) + str(sy) + str(ex) + str(ey)] = ((sx, sy), (ex, ey))
				self.analyze(box)

	def analyze(self, values):
		found = False
		for key in self.__boxes:
			if self.__boxes[key] == values:
				found = True
				del self.__boxes[key]
				break;
		if not found:
			self.__msg += "VHDL found box " + str(values) + " but not in python implementation!\n"
			self.__errors += 1

	def getResult(self):
		for key in self.__boxes:
			self.__errors += 1
			self.__msg += "VHDL missing box " + str(self.__boxes[key]) + "\n"

		if self.__errors == 0:
			self.__msg += "No errors found!" + "\n"
		else:
			self.__msg += "Found " + str(self.__errors) + " errors!\n"
		return (self.__errors, self.__msg)


	def run(self):
		while not self.stop:
			r = self.__uart.read(1)
			# TODO Check for timeout...
			if r is not None:
				if len(r) != 0:
					rb = bytearray(r)
					#print "byte: " + str(rb) + " len: " +str(len(rb)) + " " + r
					self.decoder(r)


if __name__== "__main__":
	parser = OptionParser()
	parser.add_option("-b", "--baud", dest="baud", type="int", default=115200,
			help="Baudrate of serial connection")
	parser.add_option("-d", "--dev", dest="dev", help="Serial Device")
	parser.add_option("-i", "--in-file", dest="in_file", help="File to verify")
	parser.add_option("-x", "--max-width", dest="max_x", type=int, default=32,
			help="The maximum image width smaller images will be filled with '0' bits, bigger will be croped");
	parser.add_option("-y", "--max-height", dest="max_y", type=int, default=32,
			help="The maximum image height smaller images will be filled with '0' bits, bigger will be croped");
	parser.add_option("-u", "--use-dut", dest="use_dut", action="store_true",
			help="Select the dut (Michaels) HDL")
	(option, args) = parser.parse_args()


	if option.dev is None:
		print("Parameters missing. Check usage with -h")

	start_img=16
	device="FPGA two-pass"
	if option.use_dut:
		start_img=32
		device="FPGA singlepass"


	msg = ""
	errors = 0
	checked = ""

	if option.in_file is None:
		import glob
		for files in glob.glob("../img/*.pbm"):
			if files != "../img/sim_in.pbm" and files != "../img\\sim_in.pbm":
				u=Uart(files, option.dev, option.baud, option.max_x, option.max_y, start_img)
				(e, m) = u.getResult()
				print ("Check file: " + files)
				print (m)
				errors += e
				del u
				checked += files + "\n"

	else:
		checked = option.in_file + "\n"
		u=Uart(option.in_file, option.dev, option.baud, option.max_x, option.max_y, start_img)
		(errors, msg) = u.getResult()
		boxes = u.getBoxes()

		u.getPycola().plot_sp_add(device, None, boxes)
		
	print (msg + "\n")
	print ("Files checked:\n" + checked)
	if errors == 0:
		print ("No errors found!")
	else:
		print (str(errors) + " errors found!")





