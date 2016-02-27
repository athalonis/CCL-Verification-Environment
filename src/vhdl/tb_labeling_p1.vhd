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
--! @file tb_labeling_p1.vhd
--! @brief testbench for the 1. pass of component labeling
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
entity tb_labeling_p1 is
end tb_labeling_p1;

architecture Behavioral of tb_labeling_p1 is

	constant infile           : String := "../../img/sim_in.pbm";
	constant half_period      : Time := 10 ns; -- generate 50MHz clock

	Signal clk_in_s           : STD_LOGIC := '0';
	Signal rst_in_s           : STD_LOGIC := '1';
	Signal px_in_s            : STD_LOGIC;
	Signal stall_out_s        : STD_LOGIC;
	Signal stall_in_s         : STD_LOGIC;
	Signal img_width_in_s     : UNSIGNED(log2_ceil(C_MAX_IMAGE_WIDTH) downto 0);
	Signal img_height_in_s    : UNSIGNED(log2_ceil(C_MAX_IMAGE_HEIGHT) downto 0);
	Signal next_lable_in_s    : T_LABEL;
	Signal gen_lable_out_s    : STD_LOGIC;
	Signal equi_out_s         : T_EQUI;
	Signal equi_valid_out_s   : STD_LOGIC;
	Signal label_out_s        : T_LABEL;
	Signal px_valid_in_s      : STD_LOGIC;
	Signal last_lookup_in_s   : STD_LOGIC;


	Signal equi_ready_out_s   : STD_LOGIC;

	-- used to turn the clock off after simulation
	Signal clk_en_s           : STD_LOGIC := '1';

begin
	dut_labeling_p1 : entity work.labeling_p1 PORT MAP(
		clk_in              => clk_in_s,
		rst_in              => rst_in_s,
		stall_out           => stall_out_s,
		stall_in            => stall_in_s,
		px_in               => px_in_s,
		px_valid_in         => px_valid_in_s, 
		img_width_in        => img_width_in_s,
		img_height_in       => img_height_in_s,
		next_lable_in       => next_lable_in_s,
		gen_lable_out       => gen_lable_out_s,
		equi_out            => equi_out_s,
		equi_valid_out      => equi_valid_out_s,
		label_out           => label_out_s,
		last_lbl_out      => open
	);
	dut_lookup_table : entity work.lookup_table PORT MAP(
		clk_in            => clk_in_s,
		rst_in            => rst_in_s,
		stall_out         => stall_in_s,
		next_lable_out    => next_lable_in_s,
		gen_lable_in      => gen_lable_out_s,
		equi_in           => equi_out_s,
		equi_valid_in     => equi_valid_out_s,
		lookup_ready_out  => equi_ready_out_s,
		last_look_up_in   => last_lookup_in_s,
		lookup_in         => to_unsigned(1, T_LABEL'length),
		lookup_out        => open
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

	begin
		read_pbm(infile, image, img_width, img_height);

		stall_in_s <= '0';
		px_valid_in_s <= '0';
		last_lookup_in_s <= '0';

		img_width_in_s <= to_unsigned(img_width, img_width_in_s'length);
		img_height_in_s <= to_unsigned(img_height, img_height_in_s'length);

		wait until rst_in_s = '0';
		wait until clk_in_s = '1';
		wait for half_period;

		for y in 1 to img_height loop
			for x in 1 to img_width loop

				px_in_s <= image(y)(x);
				px_valid_in_s <= '1';
				if y = img_height and x = img_width then
					last_lookup_in_s <= '1';
				end if;

				wait for half_period*2;

				report "Label: " & INTEGER'IMAGE(TO_INTEGER(label_out_s));

			end loop;
		end loop;

		px_valid_in_s <= '0';

		if equi_ready_out_s = '0' then
			wait until equi_ready_out_s = '1';
			wait for half_period*2;
		end if;
		clk_en_s <= '0';
		wait;
	end process test_p;

end architecture Behavioral;
