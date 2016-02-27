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
--! @file stimgen.vhd
--! @brief Generates Stimulies by using a counter
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-09-02
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;
use work.types.all;
use work.utils.all;

entity stimgen is
	generic(
		--! width of the input
		G_INPUT_WIDTH     : NATURAL := C_IMAGE_WIDTH * C_IMAGE_HEIGHT
	);
	port(
		--! Clock input
		clk_in          : in STD_LOGIC;

		--! Reset input
		rst_in          : in STD_LOGIC;

		--! error_out valid
		error_valid_out : out STD_LOGIC;

		--! error valu
		error_out       : out STD_LOGIC_VECTOR(T_ERROR'range);

		--! stimuli lead to error
		stimuli_out     : out STD_LOGIC_VECTOR(G_INPUT_WIDTH-1 downto 0);

		--! how many stimulis are processed
		--! this value has a error of G_COMP_INSTANCES
		processed_out   : out STD_LOGIC_VECTOR(G_INPUT_WIDTH-1 downto 0);

		--! rises if check is done
		check_done_out  : out STD_LOGIC
	);
end entity stimgen;

architecture stimgen_arc of stimgen is
	CONSTANT C_MAX_STIM   : UNSIGNED(G_INPUT_WIDTH-1 downto 0) := (others => '1'); 

	Signal cnt_s          : UNSIGNED(G_INPUT_WIDTH-1 downto 0);
	Signal cnt_inc_s      : STD_LOGIC;
	Signal max_util_s     : STD_LOGIC;
	Signal idle_s         : STD_LOGIC;
	Signal stimuli_v_s    : STD_LOGIC;
	Signal stimuli_s      : UNSIGNED(G_INPUT_WIDTH-1 downto 0);
	Signal stimuli_out_s  : UNSIGNED(G_INPUT_WIDTH-1 downto 0);
	Signal error_out_s    : T_ERROR;
begin

	stimuli_out <= std_logic_vector(stimuli_out_s);
	error_out   <= std_logic_vector(error_out_s);

	--! generate new stimuli if the verificator has not max utilization
	--cnt_inc_s <= (not max_util_s) and (not rst_in);

	check_done_out <= '1' when cnt_s = C_MAX_STIM and idle_s = '1' else '0';

	--! this value has a error of G_COMP_INSTANCES
	processed_out <= std_logic_vector(cnt_s); 

	--! assign the stimuli valid signal clock dependent
	--! (the max_util_out dependt combinatorical on stimuli_v_in)
	p_inc : process (clk_in) is
	begin
		if rising_edge(clk_in) then
			stimuli_v_s <= '0';
			cnt_inc_s <= '0';

			if max_util_s = '0' and rst_in = '0' then
				stimuli_v_s <= '1';
				stimuli_s <= cnt_s;
				cnt_inc_s <= '1';
			end if;
		end if;
	end process p_inc;


	verificator : entity work.verificator
	PORT MAP(
		clk_in               => clk_in,
		rst_in               => rst_in,

		stimuli_v_in         => stimuli_v_s,
		stimuli_in           => stimuli_s, 

		error_valid_out      => error_valid_out,
		error_out		         => error_out_s,
		stimuli_out          => stimuli_out_s,

		run_in               => '1',

		max_util_out         => max_util_s,
		idle_out             => idle_s
	);


	counter : entity work.counter GENERIC MAP(
		G_CNT_LENGTH    => G_INPUT_WIDTH,
		G_INC_VALUE     => 1,
		G_OFFSET        => to_unsigned(1, 64) --to_unsigned(21, 64)
		--G_OFFSET        => x"0000000700F73906" --there should be dragons
	)
	PORT MAP(
		clk_in          => clk_in,
		rst_in          => rst_in,
		inc_in          => cnt_inc_s,
		cnt_out         => cnt_s
	);

end architecture stimgen_arc;


