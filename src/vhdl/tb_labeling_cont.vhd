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
--! @file tb_labeling_cont.vhd
--! @brief testbench for the whole connected component labeling with continous input
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-06-04
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
use ieee.std_logic_1164.all;
--! Use numeric std
use IEEE.numeric_std.all;
use work.pbm_package.all;
use work.types.all;
use work.utils.all;

--! Reads in a PPM file an use it as input for connected component labeling
entity tb_labeling_cont is
end tb_labeling_cont;

architecture Behavioral of tb_labeling_cont is
	constant infile           : String := "../../img/continuous.files";
	constant half_period      : Time := 20 ns;

	type T_FILES is record
		fname : T_LINE;
		length : natural;
	end record;
	type T_LINES is array (0 to 9) of T_FILES;

	Signal clk_in_s           : STD_LOGIC := '0';
	Signal rst_in_s           : STD_LOGIC := '1';
	Signal px_in_s            : STD_LOGIC;
	Signal stall_out_s        : STD_LOGIC;
	Signal img_width_in_s     : STD_LOGIC_VECTOR(log2_ceil(C_MAX_IMAGE_WIDTH) downto 0);
	Signal img_height_in_s    : STD_LOGIC_VECTOR(log2_ceil(C_MAX_IMAGE_HEIGHT) downto 0);
	Signal data_valid_out_s   : STD_LOGIC;
	Signal last_lbl_out_s     : STD_LOGIC;
	Signal label_out_s        : STD_LOGIC_VECTOR(T_LABEL'HIGH downto T_LABEL'LOW);
	Signal data_valid_in_s    : STD_LOGIC;


	-- used to turn the clock off after simulation
	Signal clk_en_s           : STD_LOGIC := '1';

begin
	dut_labeling : entity work.labeling PORT MAP(
		clk_in            => clk_in_s,
		rst_in            => rst_in_s,
		stall_out         => stall_out_s,
		stall_in					=> '0',
		px_in             => px_in_s,
		img_width_in      => img_width_in_s,
		img_height_in     => img_height_in_s,
		data_valid_out    => data_valid_out_s,
		data_valid_in     => data_valid_in_s,
		last_lbl_out      => last_lbl_out_s,
		label_out         => label_out_s
	);


	rst_in_s <= '1' after 50 ns, '0' after 100 ns; -- generate initial reset

	clk_p : process
	begin
		while clk_en_s = '1' loop
			clk_in_s <= not clk_in_s;
			wait for half_period;
		end loop;
		wait;
	end process clk_p;


	test_p : process
		variable img_width  : natural;
		variable img_height : natural;
		variable image      : image_type;
		variable first      : boolean := true;
		variable x_v        : natural;
		variable y_v        : natural;
		file file_list      : image_file_type;

		variable img_anz    : natural;
		variable img_w      : natural;
		variable img_h      : natural;
		variable sline      : T_LINE;
		variable slength    : natural;
		variable out_file   : T_LINE;
		variable out_file_l : natural;
		variable next_file  : T_LINE;
		variable start      : boolean := true;

		-- count the output files
		variable of_wr_cnt  : natural := 0;
		variable of_rd_cnt  : natural := 0;
		variable out_files  : T_LINES;

	begin

		file_open(file_list, infile, read_mode);
		img_anz := read_natural(file_list);
		img_w := read_natural(file_list);
		img_h := read_natural(file_list);
		
		data_valid_in_s <= '0';
		
		img_width_in_s <= std_logic_vector(to_unsigned(img_w, img_width_in_s'length));
		img_height_in_s <= std_logic_vector(to_unsigned(img_h, img_height_in_s'length));

		wait until rst_in_s = '0';
		wait until clk_in_s = '1';
		wait for half_period;


		for img_cnt in 1 to img_anz loop 
			read_line(file_list, sline, slength);

			next_file := sline;

			-- store filenames of input files in fifo
			if start then
				start := false;
				out_file := sline;
				out_file_l := slength;
			else
				out_files(of_wr_cnt).fname := sline;
				out_files(of_wr_cnt).length := slength;
				if of_wr_cnt < out_files'length -1 then
					of_wr_cnt := of_wr_cnt + 1;
				else
					of_wr_cnt := 0;
				end if;
			end if;

			read_pbm(line2str(next_file, slength), image, img_width, img_height);

			y_v := 1;
			x_v := 1;
			while y_v <= img_h loop 

				data_valid_in_s <= '1';

				px_in_s <= '0';
				if y_v <= img_height and x_v <= img_width and y_v <= img_h and x_v <= img_w then
					px_in_s <= image(y_v)(x_v);
				end if;

				if x_v < img_w then
					x_v := x_v + 1;
				else
					x_v := 1;
					y_v := y_v + 1;
				end if;


				wait for half_period*2;
				data_valid_in_s <= '0';

				if data_valid_out_s = '1' then
					report "File: '" & line2str(out_file, out_file_l) & "' Label: " & INTEGER'IMAGE(TO_INTEGER(unsigned(label_out_s)));
				end if;

				if last_lbl_out_s = '1' then
					out_file := out_files(of_rd_cnt).fname;
					out_file_l := out_files(of_rd_cnt).length;
					if of_rd_cnt < out_files'length -1 then
						of_rd_cnt := of_rd_cnt + 1;
					else
						of_rd_cnt := 0;
					end if;
				end if;

			end loop;
		end loop;
		

		while data_valid_out_s = '1' loop
			wait for half_period*2;
			if data_valid_out_s = '1' then
				report "File: '" & line2str(out_file, out_file_l) & "' Label: " & INTEGER'IMAGE(TO_INTEGER(unsigned(label_out_s)));
			end if;

			if last_lbl_out_s = '1' then
				out_file := out_files(of_rd_cnt).fname;
				out_file_l := out_files(of_rd_cnt).length;
				if of_rd_cnt < out_files'length -1 then
					of_rd_cnt := of_rd_cnt + 1;
				else
					of_rd_cnt := 0;
				end if;
			end if;


		end loop;

		wait for half_period*2;
		clk_en_s <= '0';
		wait;
	end process test_p;

end architecture Behavioral;
