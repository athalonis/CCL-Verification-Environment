#!/bin/sh
./mk_build.sh
vcom ise/ConnectedComponentLabeling/netgen/synthesis/labeling_synthesis.vhd
vcom tb_labeling.vhd
