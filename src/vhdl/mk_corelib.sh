#!/bin/sh
vlib xilinxcorelib 
find XilinxCoreLib/ -name "*.vhd" | xargs -I%   vcom -just p -work xilinxcorelib %
find XilinxCoreLib/ -name "*.vhd" | xargs -I%   vcom -just e -work xilinxcorelib %
find XilinxCoreLib/ -name "*.vhd" | xargs -I%   vcom -just pb -work xilinxcorelib %
find XilinxCoreLib/ -name "*.vhd" | xargs -I%   vcom -just a -work xilinxcorelib %
find XilinxCoreLib/ -name "*.vhd" | xargs -I%   vcom -just c -work xilinxcorelib %
find XilinxCoreLib/ -name "*.vhd" | xargs -I%   vcom -work xilinxcorelib %

