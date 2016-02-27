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
--! @file counter.vhd
--! @brief A Simple counter it increments its value by G_INC_VALUE
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-07-08
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.types.all;

--! @brief Counter increments the cnt_out when clk_in rises and inc_in is high

entity counter is
	generic(
		--! Defines the Size of the Counter
		G_CNT_LENGTH      : NATURAL := T_LABEL'LENGTH;

		--! Defines the value to increment
		G_INC_VALUE       : NATURAL := 1;

		--! Defines a offset between the internal and the output value
		G_OFFSET          : UNSIGNED(63 downto 0) := x"0000000000000001"
	);
	port(
		--! Clock input
		clk_in            : in STD_LOGIC;
		--! Reset input
		rst_in            : in STD_LOGIC;

		--! If high the counter will be incremented
		inc_in            : in STD_LOGIC;

		--! Outputs the currenct counter value
		cnt_out           : out UNSIGNED (G_CNT_LENGTH - 1 downto 0)
	);
end entity counter;

--! @brief Simple Counter
--! @details Counts
architecture counter_arc of counter is

	-- Counter value
	signal cnt_s      : UNSIGNED(G_CNT_LENGTH - 1 downto 0);

begin

	cnt_out <= resize(cnt_s + G_OFFSET, G_CNT_LENGTH) when inc_in='0' else resize(cnt_s + G_OFFSET + G_INC_VALUE, G_CNT_LENGTH);

	p_cnt_inc : process(rst_in, clk_in, inc_in)
	begin
		if rst_in = '1' then
			cnt_s <= (others => '0');
		elsif rst_in = '0' and rising_edge(clk_in) and inc_in = '1' then
			cnt_s <= cnt_s + G_INC_VALUE;
		end if;
	end process p_cnt_inc;

end counter_arc;

