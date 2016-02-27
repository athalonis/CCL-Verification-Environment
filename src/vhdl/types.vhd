--------------------------------------------------------------------------------
--Copyright (c) 2014, Benjamin Bässler <ccl@xunit.de>
--All rights reserved.
--
--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:
--
--* Redistributions of source code must retain the above copyright notice, this
--  list of conditions and the following disclaimer.
--
--* Redistributions in binary form must reproduce the above copyright notice,
--  this list of conditions and the following disclaimer in the documentation
--  and/or other materials provided with the distribution.
--
--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
--AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
--IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
--FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
--DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
--SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
--CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
--OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
--! @file types.vhd
--! @brief Definition of global types and settings, used in more than one architecture
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-06-04
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library pccl_lib;
use pccl_lib.common.all;

use work.utils.all;

--! Definition of global types and settings

package types is
	constant C_CAM_IF           : boolean := true;
	constant C_VERSION          : natural := 291;
	-- how many comparators?
	constant C_COMP_INST        : natural := 60;

	-- size of error_type output of REF
	CONSTANT C_ERR_REF_SIZE      : natural := 1;

	CONSTANT C_ERR_DUT_SIZE      : natural := sp_error_type_width;

	CONSTANT C_ERR_CMP_SIZE      : natural := 4;

	-- '1' means errors are droped if the error fifo is full
	-- '0' means stall the verification process if the fifo is full
	CONSTANT C_ALLOW_ERR_DRP     : std_logic := '1';


	-- get information from ccl_dut common_pkg.vhd
	constant C_IMAGE_WIDTH  : natural := image_width;
	constant C_IMAGE_HEIGHT : natural := image_height;

	constant C_MAX_IMAGE_WIDTH  : natural := C_IMAGE_WIDTH;
	constant C_MAX_IMAGE_HEIGHT : natural := C_IMAGE_HEIGHT;


	-- size of error storage
	CONSTANT C_ERR_BUF_SIZE      : natural := 8*1024;

	-- size of the error type
	CONSTANT C_ERR_TYP_SIZE      : natural := C_ERR_CMP_SIZE + C_ERR_REF_SIZE + C_ERR_DUT_SIZE;
	CONSTANT C_ERR_TYP_SIZE_BYTE : natural := div_ceil(C_ERR_TYP_SIZE, 8);


	-- defines how many clocks to wait for box outputs
	-- after the hole image is written to the dut input
	constant C_DUT_EXTRA_CLKS		: natural := 2 * C_IMAGE_WIDTH;

	--! max length of data part of send and receive data
	--constant C_MAX_USE_DATA     : natural := 1024;
	constant C_MAX_SEND_DATA    : natural := 1024;

	constant C_BACKGROUND       : std_logic := '0'; --! defines if the background is '0' or '1'

	-- build in a counter for the distribution of the number of different labels
	CONSTANT C_INCLUDE_CNT       : boolean := false;
	--! constants for counting number of different used labels over all images
	-- change this 0 if you want to include counter
	constant C_CNT_SIZE  : natural := 0;--C_MAX_IMAGE_WIDTH*C_MAX_IMAGE_HEIGHT;
	constant C_MAX_BOXES : natural := div_ceil(C_MAX_IMAGE_WIDTH,2)*div_ceil(C_MAX_IMAGE_WIDTH,2);
	constant C_CNT_SIZE_BYTE : natural := div_ceil(C_CNT_SIZE*C_MAX_BOXES, 8);

	--! the max number of lables are log2(IMAGE_WIDTH*IMAGE_HEIGHT/2/2)
	-- worst case: one lines with the toggeling input one 0 the next 1...
	--             you need line_width/2 different labels
	subtype T_LABEL is
		unsigned(log2_ceil(div_ceil(C_MAX_IMAGE_WIDTH,2)*div_ceil(C_MAX_IMAGE_HEIGHT,2)+1)-1 downto 0); --! type to store lables

	type T_EQUI is array (0 to 1) of T_LABEL;

	subtype T_BOX is unsigned(2*log2_ceil(C_MAX_IMAGE_HEIGHT) +	2*log2_ceil(C_MAX_IMAGE_WIDTH) - 1 downto 0);
	subtype T_X_START is natural range 2*log2_ceil(C_MAX_IMAGE_WIDTH) +	2*log2_ceil(C_MAX_IMAGE_HEIGHT) - 1 downto log2_ceil(C_MAX_IMAGE_WIDTH) +	2*log2_ceil(C_MAX_IMAGE_HEIGHT);
	subtype T_Y_START is natural range log2_ceil(C_MAX_IMAGE_WIDTH) +	2*log2_ceil(C_MAX_IMAGE_HEIGHT) - 1 downto log2_ceil(C_MAX_IMAGE_WIDTH) +	log2_ceil(C_MAX_IMAGE_HEIGHT);
	subtype T_X_END is natural range log2_ceil(C_MAX_IMAGE_WIDTH) +	log2_ceil(C_MAX_IMAGE_HEIGHT) - 1	downto log2_ceil(C_MAX_IMAGE_HEIGHT);
	subtype T_Y_END is natural range log2_ceil(C_MAX_IMAGE_HEIGHT) - 1 downto 0;

	--! Defines the unlabeld value
	constant C_UNLABELD         : T_LABEL := (others => '0');


	SUBTYPE T_ERROR is UNSIGNED(C_ERR_TYP_SIZE-1 downto 0);


	type T_CAM_POS is record
		row : unsigned(log2_ceil(C_MAX_IMAGE_HEIGHT+1)-1 downto 0);
		col : unsigned(log2_ceil(C_MAX_IMAGE_WIDTH+1) -1 downto 0);
		val : std_logic;
	end record;
	type T_CAM_ERR is array (0 to 9) of T_CAM_POS;

end package types;
