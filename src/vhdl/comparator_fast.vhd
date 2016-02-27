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
--! @file comparator.vhd
--! @brief Compares the result of the DUT and REV Implementaion
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-08-29
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.utils.all;


entity comparator is
	generic(
		--! Number of max boxes
		G_MAX_BOXES       : NATURAL :=  div_ceil(C_MAX_IMAGE_WIDTH,2)*div_ceil(C_MAX_IMAGE_WIDTH,2)
	);
	port(
		--! Clock input
		clk_in            : in STD_LOGIC;

		--! Reset input
		rst_in            : in STD_LOGIC;

		--! Restart comparation
		restart_in        : in STD_LOGIC;

		--! last box input
		last_box_in       : in STD_LOGIC;

		--! clock for DUT in
		clk1_in           : in STD_LOGIC;

		--! Boxes input of the DUT
		box1_in           : in T_BOX;

		--! DUT Box valid
		box1_valid_in     : in STD_LOGIC;

		--! Boxes input of the REV
		box2_in           : in T_BOX;

		--! REV Box valid
		box2_valid_in     : in STD_LOGIC;

		--! error 0 => no error
		--! error 1 => DUT less BOXes as expected
		--! error 2 => DUT more BOXes as expected
		--! error 3 => DUT unexpected BOXes
		error_code_out    : out unsigned(3 downto 0);

		--! rises if check is done the error_code_out is also valid
		check_done_out    : out STD_LOGIC
	);
end entity comparator;








-- starting with line 70 the code is used for the appendix (to line 147)
architecture comparator_arc of comparator is
	TYPE T_BOX_RAM is array (0 to G_MAX_BOXES - 1) of T_BOX;

	CONSTANT C_NO_ERROR    : unsigned(3 downto 0) := "0000";
	CONSTANT C_DUT_LESS    : unsigned(3 downto 0) := "0001";
	CONSTANT C_DUT_MORE    : unsigned(3 downto 0) := "0010";
	CONSTANT C_DUT_WRONG   : unsigned(3 downto 0) := "0011";

	signal box2_ram_s      : T_BOX_RAM;
	signal box2_valid_s    : unsigned(log2_ceil(G_MAX_BOXES+2)-1 downto 0);
	signal box1_ram_s      : T_BOX_RAM;
	signal box1_valid_s    : unsigned(log2_ceil(G_MAX_BOXES+2)-1 downto 0);
	signal last_box_in_d_s : std_logic; -- delayed last_box_in

	procedure insert_element(
		signal el     : in T_BOX;
		signal list   : inout T_BOX_RAM;
		signal valids : inout unsigned
	) is
		variable pos  : natural;
	begin
		pos := 0;
		for i in list'range loop
			if i < valids and list(i) < el then
				pos := i+1;
			end if;
		end loop;
		if pos = 0 then
			list <= el & list(pos to list'high-1);
		elsif pos > list'high then
			list <= list(0 to pos-2) & el;
		else
			list <= list(0 to pos-1) & el & list(pos to list'high-1);
		end if;
		valids <= valids + 1;
	end procedure;
begin
	-- this process does the inserting of new boxes and de comparation
	p_insert : process(clk_in, rst_in) is
	begin
		if rst_in = '1' then
			box1_valid_s    <= (others => '0'); -- reset value
			box2_valid_s    <= (others => '0'); -- reset value
			last_box_in_d_s <= '0';             -- reset value
			check_done_out  <= '0';             -- reset value
		elsif rising_edge(clk_in) then
			check_done_out  <= '0';             -- set default value
			last_box_in_d_s <= last_box_in;     -- delay signal for last_box_in
			if box1_valid_in = '1' then         -- new output1 to compare
				insert_element(box1_in, box1_ram_s, box1_valid_s);
			end if;
			if box2_valid_in = '1' then         -- new output2 to compare
				insert_element(box2_in, box2_ram_s, box2_valid_s);
			end if;
			if last_box_in_d_s = '1' then       -- generate output
				check_done_out <= '1';
				if box1_valid_s < box2_valid_s then
					error_code_out <= C_DUT_LESS;
				elsif box1_valid_s > box2_valid_s then
					error_code_out <= C_DUT_MORE;
				elsif box1_valid_s = 0 and box2_valid_s = 0 then
					error_code_out <= C_NO_ERROR;
				elsif box2_ram_s(0 to to_integer(box2_valid_s)-1) = 
				box1_ram_s(0 to to_integer(box1_valid_s)-1) then
					error_code_out <= C_NO_ERROR;
				else
					error_code_out <= C_DUT_WRONG;
				end if;
				box1_valid_s <= (others => '0'); -- auto reset
				box2_valid_s <= (others => '0'); -- auto reset
			end if;
		end if; --clk
	end process p_insert;
end architecture;
