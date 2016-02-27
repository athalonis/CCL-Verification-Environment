#!/bin/sh
vhdl=`vsim -c -do 'run -all;quit' tb_labeling_p1 | grep Note: | sed 's/.*Note: \([0-9]\+\)/\1/'`
python=`../Software/Python/cocola.py -c -i ../img/test1.png | grep 1.run | sed 's/^1\.run: \([0-9]\+\)/\1/'`

