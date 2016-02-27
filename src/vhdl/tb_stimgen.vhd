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
--! @file tb_stimgen.vhd
--! @brief Generates Stimulies for CCL and compares the result of two instances
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-09-02
--------------------------------------------------------------------------------


--! Use standard library
library ieee;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

use work.types.all;

entity tb_stimgen is
end tb_stimgen;

architecture Behavioral of tb_stimgen is

	constant C_HALF_PER_FAST  : Time := 2.5 ns; -- 200MHz
	constant C_HALF_PER       : Time := 2*C_HALF_PER_FAST; -- 100MHz

	Signal clk_en_s          : STD_LOGIC := '1';
	Signal clk_in_s          : STD_LOGIC := '0';
	Signal clk2x_in_s        : STD_LOGIC := '0';
	Signal rst_in_s          : STD_LOGIC := '1';
	Signal error_valid_out_s : STD_LOGIC;
	Signal error_out_s       : STD_LOGIC_VECTOR(T_ERROR'RANGE);
	Signal stimuli_out_s     : STD_LOGIC_VECTOR(C_IMAGE_WIDTH*C_IMAGE_HEIGHT-1 downto 0);
	Signal processed_out_s   : STD_LOGIC_VECTOR(C_IMAGE_WIDTH*C_IMAGE_HEIGHT-1 downto 0);
	Signal check_done_out_s  : STD_LOGIC;
begin

	rst_in_s <= '0' after 300 ns;

	clk_p : process
	begin
		while clk_en_s = '1' loop
			clk_in_s <= not clk_in_s;
			clk2x_in_s <= not clk2x_in_s;
			wait for C_HALF_PER_FAST;
			clk2x_in_s <= not clk2x_in_s;
			wait for C_HALF_PER_FAST;
		end loop;
		wait;
	end process clk_p;



	my_stimgen : entity work.stimgen
	port map(
		clk_in            => clk_in_s,
		rst_in            => rst_in_s,
		error_valid_out   => error_valid_out_s,
		error_out         => error_out_s,
		stimuli_out       => stimuli_out_s,
		processed_out     => processed_out_s,
		check_done_out    => check_done_out_s
	);


end architecture Behavioral;
