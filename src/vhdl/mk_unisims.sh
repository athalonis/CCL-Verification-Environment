#!/bin/sh
compxlib -l vhdl -s mti_se -arch virtex6 -lib unisim -dir .

#if [ -d unisims ]
#then
#	vlib unisim
#	vcom -work unisim unisims/unisim_VCOMP.vhd
#	vcom -work unisim unisims/unisim_VPKG.vhd
#	for file in unisims/primitive/*.vhd
#	do
#	  vcom -work unisim $file
#	done
#
#	find unisims/secureip/ -name "*.vhd" | xargs -I%   vcom -work unisim %
#
#else
#	echo "unisim sources not found just link it to this directory"
#	echo "\tnormaly found in .../ISE_DS/ISE/vhdl/src/unisims"
#fi
