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
--! @file reset.vhd
--! @brief Generates reset after power on
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-07-30
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use IEEE.std_logic_1164.all;

--! @brief executes a reset for G_CLOCKS clock cycles
--! the reset is executed after personalizing the fpga
--! if external reset is trigered by rst_in
entity reset is
	generic(
		--! How long should the reset be active
		G_CLOCKS        : NATURAL := 100;

		--! Reset active signal for input
		G_RESET_ACTIVE  : STD_LOGIC := '1'
	);
	port(
		--! Clock input
		clk_in            : in STD_LOGIC;
		--! Reset input
		rst_in            : in STD_LOGIC;
		--! Reset output
		rst_out           : out STD_LOGIC;
		--! Inverted reset output
		rst_out_n         : out STD_LOGIC
	);
end entity reset;

--! @brief arc description
--! @details more detailed description
architecture reset_arc of reset is

	Signal rst_s     : STD_LOGIC := '1';
	Signal rst_cnt_s : UNSIGNED(integer(ceil(log2(real(G_CLOCKS)))) - 1 downto 0);

	Signal rst_int_s : STD_LOGIC := '0';


	-- Timing Ignore for reset signal
	attribute TIG: string; 
	attribute TIG of rst_int_s : signal is "yes";
	attribute TIG of rst_s : signal is "yes";

begin
	rst_out_n <= not (rst_int_s or rst_s);
	rst_out <= rst_int_s or rst_s;
	
	p_rst : process(clk_in, rst_in) is
	begin
		if rising_edge(clk_in) then
			rst_int_s <= '0';

			if rst_in = G_RESET_ACTIVE then
				rst_s <= '1';
				rst_int_s <= '1';
			elsif rst_s = '1' then
				rst_cnt_s <= to_unsigned(G_CLOCKS - 1, rst_cnt_s'length);
				rst_int_s <= '1';
				rst_s <= '0';
			elsif rst_cnt_s > 0 then
				rst_int_s <= '1';
				rst_cnt_s <= rst_cnt_s - 1;
			end if;
		end if;
	end process;
end architecture reset_arc;



