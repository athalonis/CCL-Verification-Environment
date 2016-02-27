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
--! @file boundbox_big.vhd
--! @brief Computes the boundboxes of each label after equal labels matched
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-06-04
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.utils.all;
use IEEE.math_real.all;

--! The big version needs for each possible label a boundbox storage space

entity boundbox is
	generic(
		--! Max image
		G_MAX_IMG_WIDTH   : NATURAL := C_MAX_IMAGE_WIDTH;

		--! Max image
		G_MAX_IMG_HEIGHT  : NATURAL := C_MAX_IMAGE_HEIGHT;

		--! Only for compatibility purposes
		G_MAX_BOUNDBOXES  : NATURAL :=  div_ceil(C_MAX_IMAGE_WIDTH,2)+div_ceil(C_MAX_IMAGE_HEIGHT,2)
	);
	port(
		--! Clock input
		clk_in            : in STD_LOGIC;

		--! Reset input
		rst_in            : in STD_LOGIC;

		--! stall the output of bound box
		stall_in          : in STD_LOGIC; 

		--! High if the lable input valid
		lbl_valid_in      : in STD_LOGIC;

		--! Input of Lables
		label_in          : in T_LABEL;

		--! High if the boundbox output valid
		box_valid_out     : out STD_LOGIC;

		--! output of bound box
		box_out           : out T_BOX;

		--! high if all boxes are computed
		box_done_out      : out STD_LOGIC;

		--! High if the memory free manager can't find fast new storage
		--! The result of the bounding box are wrong
		error_out         : out STD_LOGIC;

		--! width of the image at the input
		img_width_in      : in UNSIGNED(log2_ceil(G_MAX_IMG_WIDTH) downto 0);

		--! height of the image 
		img_height_in     : in UNSIGNED(log2_ceil(G_MAX_IMG_HEIGHT) downto 0)
	);
end entity boundbox;

--! @brief arc description
--! @details more detailed description
architecture boundbox_arc of boundbox is

	-- Types --------------------------------------------------------------------
	type T_BOX_STORE is array (2**T_LABEL'length - 1 downto 0) of T_BOX;

	-- Constants ----------------------------------------------------------------

	-- Signals ------------------------------------------------------------------
	signal box_store_s  : T_BOX_STORE;
	signal box_used_s		: unsigned(T_BOX_STORE'range);

	signal col_cnt_s    : UNSIGNED(log2_ceil(G_MAX_IMG_WIDTH) - 1 downto 0);
	signal row_cnt_s    : UNSIGNED(log2_ceil(G_MAX_IMG_HEIGHT) downto 0);


	signal next_chk_s   : T_LABEL;

begin

	box_done_out <= '1' when box_used_s = 0 else '0';

	p_counter : process (clk_in, rst_in)
	begin
		if rst_in = '1' then
			col_cnt_s <= (others => '0');
			row_cnt_s <= (others => '0');
		elsif rising_edge(clk_in) and rst_in = '0' then
			if lbl_valid_in = '1' and stall_in = '0' then
				if col_cnt_s = img_width_in - 1 then
					col_cnt_s <= (others => '0');
					row_cnt_s <= row_cnt_s + 1;
				else
					col_cnt_s <= col_cnt_s + 1;
				end if;
			end if;
		end if;
	end process p_counter;

	p_box : process (clk_in, rst_in)
		variable tmp_x_0_v : unsigned(log2_ceil(G_MAX_IMG_WIDTH)-1 downto 0);
		variable tmp_y_0_v : unsigned(log2_ceil(G_MAX_IMG_HEIGHT)-1 downto 0);
		variable tmp_x_1_v : unsigned(log2_ceil(G_MAX_IMG_WIDTH)-1 downto 0);
		variable tmp_y_1_v : unsigned(log2_ceil(G_MAX_IMG_HEIGHT)-1 downto 0);
	begin
		if rst_in = '1' then
			box_used_s <= (others => '0');
			next_chk_s <= (others => '0');
			error_out <= '0';
			box_valid_out <= '0';
		elsif rising_edge(clk_in) and rst_in = '0' then
			if stall_in = '0' then
				box_valid_out <= '0';

				if lbl_valid_in = '1' and label_in /= C_UNLABELD then

					--resize to map lable 256 to position 0
					if box_used_s(to_integer(label_in)) = '0' then
						-- first label of this box
						-- mark heap position as inuse
						box_used_s(to_integer(label_in)) <= '1';

						-- store this pixel as the start of the box
						box_store_s(to_integer(label_in))(T_X_END) <= col_cnt_s; 
						box_store_s(to_integer(label_in))(T_Y_END) <= resize(row_cnt_s, row_cnt_s'length-1);
						box_store_s(to_integer(label_in))(T_X_START) <= col_cnt_s;
						box_store_s(to_integer(label_in))(T_Y_START) <= resize(row_cnt_s, row_cnt_s'length-1);
					else
						-- the box of this label allready has stored a start point
						-- x and y value of the start (0) can't be smaller
						tmp_x_1_v := box_store_s(to_integer(label_in))(T_X_END); 
						tmp_y_1_v := box_store_s(to_integer(label_in))(T_Y_END); 
						tmp_x_0_v := box_store_s(to_integer(label_in))(T_X_START); 
						tmp_y_0_v := box_store_s(to_integer(label_in))(T_Y_START); 

						-- has the end point moved to the right?
						if tmp_x_1_v < col_cnt_s then
							tmp_x_1_v := col_cnt_s;
						end if;

						-- has the start point moved to the left?
						if tmp_x_0_v > col_cnt_s then
							tmp_x_0_v := col_cnt_s;
						end if;

						-- the y value need no check it can only be bigger or equals
						tmp_y_1_v := resize(row_cnt_s, row_cnt_s'length-1);

						-- write the new bounderies
						box_store_s(to_integer(label_in))(T_X_END) <= tmp_x_1_v;
						box_store_s(to_integer(label_in))(T_Y_END) <= tmp_y_1_v; 
						box_store_s(to_integer(label_in))(T_X_START) <= tmp_x_0_v;
						box_store_s(to_integer(label_in))(T_Y_START) <= tmp_y_0_v;
					end if;
				else
					--TODO: use the biggest possible lable to reduce the check_s range
					next_chk_s <= next_chk_s + 1;

					if box_used_s(to_integer(next_chk_s)) = '1' then
						tmp_x_1_v := box_store_s(to_integer(next_chk_s))(T_X_END);
						tmp_y_1_v := box_store_s(to_integer(next_chk_s))(T_Y_END);
						if (tmp_y_1_v < row_cnt_s and resize(tmp_x_1_v, tmp_x_1_v'length+1) + 2 < col_cnt_s) or -- last lable one row before and in x at least one pixle space
						tmp_y_1_v + 1 < row_cnt_s or -- one row without a pixle of this lable
						(row_cnt_s = img_height_in - 1 and resize(tmp_x_1_v, tmp_x_1_v'length+1) + 1 < col_cnt_s) or -- last line
						(row_cnt_s = img_height_in and col_cnt_s >= 0) -- end of image
						then

							-- output the processed box
							box_out <= box_store_s(to_integer(next_chk_s));
							box_valid_out <= '1';

							-- mark heap memory as free
							box_used_s(to_integer(next_chk_s)) <= '0';
						end if;
					end if;
				end if;
			end if;
		end if;
	end process p_box;


end architecture boundbox_arc;
