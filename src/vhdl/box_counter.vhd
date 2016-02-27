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
--! @file box_counter.vhd
--! @brief counts the number of boxes grouped over the occurence number
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-03-10
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.utils.all;


entity box_counter is
	generic(
		--! Number of max boxes
		G_MAX_BOXES       : NATURAL := C_MAX_BOXES;
		G_CNT_SIZE        : NATURAL := C_CNT_SIZE
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

		--! REV Box valid
		box2_valid_in     : in STD_LOGIC;

		count_out         : out unsigned(G_MAX_BOXES*G_CNT_SIZE-1 downto 0)

	);
end entity box_counter;

architecture box_counter_arc of box_counter is
	TYPE T_CNT is array (0 to G_MAX_BOXES - 1) of unsigned(G_CNT_SIZE-1 downto 0);
	signal cnt_s : T_CNT;
	signal last_cnt_s : unsigned(G_CNT_SIZE-1 downto 0);
begin

	gen_output : for i in cnt_s'range generate
		count_out(G_CNT_SIZE*(i+1)-1 downto G_CNT_SIZE*i) <= cnt_s(i);
	end generate gen_output;

	p_cnt : process (clk_in, rst_in) is
	begin
		if rst_in = '1' then
			cnt_s <= (others => (others => '0'));
			last_cnt_s <= (others => '0');
		else
			if rising_edge(clk_in) then
				if last_box_in = '1' then
					if box2_valid_in = '1' then
						cnt_s(to_integer(last_cnt_s)) <= cnt_s(to_integer(last_cnt_s)) + 1;
					else
						cnt_s(to_integer(last_cnt_s-1)) <= cnt_s(to_integer(last_cnt_s-1)) + 1;
					end if;
					last_cnt_s <= (others => '0');
				elsif box2_valid_in = '1' then
					last_cnt_s <= last_cnt_s + 1;
				end if;
			end if; -- clk
		end if; -- rst
	end process p_cnt;
end architecture box_counter_arc;
