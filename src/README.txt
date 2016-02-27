=================================================================================
= Python Tools =
=================================================================================

bounding_boxes.py:
	Example methode how to use cv2 for computing bounding boxes
	requirements:
		- opencv2 for python
		- numpy/scipy http://www.numpy.org/

=================================================================================
cola.py:
=================================================================================
	Python implementation of CCL with visualisation of labeled pixels and bounding
	boxes
	requirements:
	- python3
	- matplotlib for Python3 http://matplotlib.org/
	- numpy/scipy for Python3 http://www.numpy.org/
	- PIL for Python3 http://www.pythonware.com/products/pil/
	ubuntu: apt-get install python3 python3-scipy python3-numpy python3-pil

Usage: cola.py [options]

Options:
  -h, --help            show this help message and exit
  -s IFILE, --sfile=IFILE
                        input image to run connected component labling
  -v                    enable status output
  -t THRESHOLD, --threshold=THRESHOLD
                        threshold for converting image to black/white. Value
                        0.0...1.0
  -c, --compare         just prints the Labels to the stdout
  -x MAX_X, --max-x=MAX_X
                        Max width of image send to ccl
  -y MAX_Y, --max-y=MAX_Y
                        Max height of image send to ccl

=================================================================================
verifier.py:
=================================================================================
	Runs Modelsim simulations of DUT/REF for a single image or a directory of
	images and compares the results with cola.py results.
	requirements:
		same as for cola.py and in addition:
		- modlesim with vsim needs to be in the PATH

Usage: verifier.py [options]

Options:
  -h, --help            show this help message and exit
  -s SIM_FILE, --sim-file=SIM_FILE
                        filename for running single image simulation and the
                        visualize the results
  -p, --pass-one        only the first pass will be analyzed otherwise the
                        lables after the second pass and the boundboxes will
                        be analyzed
  -u, --uart-tb         Simulates the uart_tb and compare the output with the
                        python implementation
  -n, --continuous      Sends all Pictures in one continuous stream to the DUT
  -t TIMEOUT, --timeout=TIMEOUT
                        seconds (as float) how long the time between two
                        outputs before abort the simulation
  -c                    Checks the Python boundbox calculation against the CPP
                        implementation
  -v, --vhdl-dut        Checks the Python boundbox calculation against the
                        vhdl DUT without -c and -v the REF will be simulated
  --no-lables           Don't check lables
  -x MAX_X, --max-x=MAX_X
                        Max width of image send to ccl
  -y MAX_Y, --max-y=MAX_Y
                        Max height of image send to ccl
  -d INDIR, --input-dir=INDIR
                        Input dir used to check all Files
  -e FEXT, --file-extension=FEXT
                        File extension for the input dir run (default "pbm")

=================================================================================
img_generator.py:
=================================================================================
	Generates test images for image sizes bigger than the images run in exhaustive
	test.
	It uses images from the P_DIR and random noise to generate this testimages.

	requirements:
		same as for cola.py and in addition:

Usage: img_generator.py [options]

Options:
  -h, --help            show this help message and exit
  --max-pattern=MAX_P   The maximum number of paterns to place on the image
  --min-pattern=MIN_P   The minimum number of paterns to place on the image
  --min-noise=MIN_N     The minimum factor of noise to place on the image
  --max-noise=MAX_N     The minimum factor of noise to place on the image
  -w WIDTH, --img-width=WIDTH
                        Image width
  -y HEIGHT, --img-height=HEIGHT
                        Image height
  -p P_DIR, --pattern-dir=P_DIR
                        Directory with the image pattern "pattern*"
  -o O_DIR, --out-dir=O_DIR
                        Directory for the generated files
  -n IMG_NUM, --num-images=IMG_NUM
                        Number of test images to generate


=================================================================================
loganalyzer.py:
=================================================================================
	This is the graphical user interface to analyze logged test runs.
	To get the error analyzer to a size for fitting on a screen with small
	resolution. Change the parameter "savespace" from "False" to "True"
	of the config file (generated after first starting and closing	the GUI).

	requirements:
		same as for verifier.py and in addition:
		- PyQt4 https://wiki.python.org/moin/PyQt4
		ubuntu: apt-get install python3-pyqt4

=================================================================================
udp_com.py:
=================================================================================
	Software to control the exhaustive test on the FPGA over udp and log the found
	errors to files.

	requirements:
		- Python3

Usage: udp_com.py [options]

Options:
  -h, --help            show this help message and exit
  -s SSTIM, --start=SSTIM
                        stimulus to start the simulation if not set it starts
                        with 0
  -e ESTIM, --end=ESTIM
                        stimulus to stop when reached if not set it ends at
                        the highest possible value.
  -i, --info            Show the hardware configuration

=================================================================================
converter.py:
=================================================================================
Converts input images to B/W images with given threshold
	requirements:
		- numpy/scipy for Python3 http://www.numpy.org/

=================================================================================
udp_simulator.py: -- OUT OF DATE --
=================================================================================
	This software is used to simulate the responses of the FPGA to develope the
	client software without the FPGA.
	requirement:
		- python only

=================================================================================
uart.py: -- OUT OF DATE --
=================================================================================
	Sends testimages to the FPGA over UART and reading out the boxes. This was
	used in a early development state for "vhdl/communication/top_com_uart.vhd".
	Not tested with the current development state.

	requirements:
		- same as for cola.py
