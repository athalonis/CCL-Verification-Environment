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
--! @file tb_comparator.vhd
--! @brief checks the comparator.vhd
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-10-15
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.types.all;

entity tb_comparator is
	end tb_comparator;

architecture Behavioral of tb_comparator is

	constant infile           : String := "../../img/sim_in.pbm";
	constant half_period      : Time := 20 ns;
	constant C_IDLE_MIN       : Natural := 50;

	Signal clk_in_s           : STD_LOGIC := '0';
	Signal rst_in_s           : STD_LOGIC := '1';
	Signal restart_in_s       : STD_LOGIC := '0';
	Signal last_box_in_s      : STD_LOGIC;
	Signal clk1_in_s          : STD_LOGIC := '0';
	Signal box1_in_s          : T_BOX;
	Signal box1_valid_in_s    : STD_LOGIC;
	Signal box2_in_s          : T_BOX;
	Signal box2_valid_in_s    : STD_LOGIC;
	Signal error_code_out_s   : unsigned(3 downto 0);
	Signal check_done_out_s   : STD_LOGIC;

	-- used to turn the clock off after simulation
	Signal clk_en_s           : STD_LOGIC := '1';

	function set_box(
									 x_s : integer;
									 y_s : integer;
									 x_e : integer;
									 y_e : integer)
									 return T_BOX is
		variable box : T_BOX;
	begin
		box(T_X_START) := to_unsigned(x_s, T_X_START'high-T_X_START'low + 1);
		box(T_Y_START) := to_unsigned(y_s, T_Y_START'high-T_Y_START'low + 1);
		box(T_X_END)   := to_unsigned(x_e, T_X_END'high-T_X_END'low + 1);
		box(T_Y_END)   := to_unsigned(y_e, T_Y_END'high-T_Y_END'low + 1);
		return box;
	end function;

begin
	dut_comparator : entity work.comparator
	generic map(
		G_MAX_BOXES       => 8
	)
	port map(
		clk_in            => clk_in_s,
		rst_in            => rst_in_s,
		restart_in        => restart_in_s,
		last_box_in       => last_box_in_s,
		clk1_in           => clk1_in_s,
		box1_in           => box1_in_s,
		box1_valid_in     => box1_valid_in_s,
		box2_in           => box2_in_s,
		box2_valid_in     => box2_valid_in_s,
		--! error 0 => no error
		--! error 1 => DUT less BOXes as expected
		--! error 2 => DUT more BOXes as expected
		--! error 3 => DUT missing BOX
		error_code_out    => error_code_out_s,
		check_done_out    => check_done_out_s
	);

	--rst_in_s <= '1' after 50 ns, '0' after 100 ns; -- generate initial reset

	clk_p : process
	begin
		while clk_en_s = '1' loop
			clk_in_s <= not clk_in_s;
			clk1_in_s <= not clk1_in_s;
			wait for half_period;
		end loop;
		wait;
	end process clk_p;


	test_p : process
		variable error_n : natural := 0;
	begin
		box1_valid_in_s <= '0';
		box2_valid_in_s <= '0';
		last_box_in_s <= '0';
		rst_in_s <= '0';

		wait for 50 ns;
		rst_in_s <= '1';
		wait for 50 ns;
		rst_in_s <= '0';

		wait until clk_in_s = '0';
		wait until clk_in_s = '1';
		wait for half_period;

		------------------------------
		-- Test 1 - No error         -
		-- box 1 before box 2        -
		------------------------------
		box1_valid_in_s <= '1';
		box1_in_s <= set_box(5,3,8,4);
		wait for 2*half_period;
		box1_in_s <= set_box(1,2,4,2);
		wait for 2*half_period;
		box1_in_s <= set_box(4,1,8,7);
		wait for 2*half_period;
		box1_in_s <= set_box(2,5,3,6);
		wait for 2*half_period;
		box1_valid_in_s <= '0';

		box2_valid_in_s <= '1';
		box2_in_s <= set_box(5,3,8,4);
		wait for 2*half_period;
		box2_in_s <= set_box(1,2,4,2);
		wait for 2*half_period;
		box2_in_s <= set_box(4,1,8,7);
		wait for 2*half_period;
		box2_in_s <= set_box(2,5,3,6);
		wait for 2*half_period;
		box2_valid_in_s <= '0';

		last_box_in_s <= '1';
		wait for 2*half_period;
		last_box_in_s <= '0';

		if check_done_out_s = '0' then
			wait until check_done_out_s = '1';
		end if;
		if unsigned(error_code_out_s) /= 0 then
			error_n := error_n + 1;
			report "Test 1 failed" severity error;
		end if;

		restart_in_s <= '1';
		wait for 2*half_period;
		restart_in_s <= '0';

		------------------------------
		-- Test 2 - No error         -
		-- box 1 same time box 2     -
		------------------------------
		box1_valid_in_s <= '1';
		box2_valid_in_s <= '1';
		box1_in_s <= set_box(5,3,8,4);
		box2_in_s <= set_box(5,3,8,4);
		wait for 2*half_period;
		box1_in_s <= set_box(1,2,4,2);
		box2_in_s <= set_box(1,2,4,2);
		wait for 2*half_period;
		box1_in_s <= set_box(4,1,8,7);
		box2_in_s <= set_box(4,1,8,7);
		wait for 2*half_period;
		box1_in_s <= set_box(2,5,3,6);
		box2_in_s <= set_box(2,5,3,6);
		wait for 2*half_period;
		box1_valid_in_s <= '0';
		box2_valid_in_s <= '0';

		last_box_in_s <= '1';
		wait for 2*half_period;
		last_box_in_s <= '0';

		if check_done_out_s = '0' then
			wait until check_done_out_s = '1';
		end if;
		if unsigned(error_code_out_s) /= 0 then
			error_n := error_n + 1;
			report "Test 2 failed" severity error;
		end if;

		restart_in_s <= '1';
		wait for 2*half_period;
		restart_in_s <= '0';

		------------------------------------
		-- Test 3 - No error               -
		-- box 1 different order box 2     -
		------------------------------------
		box1_valid_in_s <= '1';
		box2_valid_in_s <= '1';
		box1_in_s <= set_box(5,3,8,4);
		box2_in_s <= set_box(4,1,8,7);
		wait for 2*half_period;
		box1_in_s <= set_box(1,2,4,2);
		box2_in_s <= set_box(2,5,3,6);
		wait for 2*half_period;
		box1_in_s <= set_box(4,1,8,7);
		box2_in_s <= set_box(5,3,8,4);
		wait for 2*half_period;
		box1_in_s <= set_box(2,5,3,6);
		box2_in_s <= set_box(1,2,4,2);
		wait for 2*half_period;
		box1_valid_in_s <= '0';
		box2_valid_in_s <= '0';

		last_box_in_s <= '1';
		wait for 2*half_period;
		last_box_in_s <= '0';

		if check_done_out_s = '0' then
			wait until check_done_out_s = '1';
		end if;
		if unsigned(error_code_out_s) /= 0 then
			error_n := error_n + 1;
			report "Test 3 failed" severity error;
		end if;

		restart_in_s <= '1';
		wait for 2*half_period;
		restart_in_s <= '0';

		------------------------------------
		-- Test 4 - Error 1                -
		-- box 1 lesser boxes than box 2   -
		------------------------------------
		box2_valid_in_s <= '1';
		box2_in_s <= set_box(4,1,8,7);
		wait for 2*half_period;
		box1_valid_in_s <= '1';
		box1_in_s <= set_box(1,2,4,2);
		box2_in_s <= set_box(2,5,3,6);
		wait for 2*half_period;
		box1_in_s <= set_box(4,1,8,7);
		box2_in_s <= set_box(5,3,8,4);
		wait for 2*half_period;
		box1_in_s <= set_box(2,5,3,6);
		box2_in_s <= set_box(1,2,4,2);
		wait for 2*half_period;
		box1_valid_in_s <= '0';
		box2_valid_in_s <= '0';

		last_box_in_s <= '1';
		wait for 2*half_period;
		last_box_in_s <= '0';

		if check_done_out_s = '0' then
			wait until check_done_out_s = '1';
		end if;
		if unsigned(error_code_out_s) /= 1 then
			error_n := error_n + 1;
			report "Test 4 failed" severity error;
		end if;

		restart_in_s <= '1';
		wait for 2*half_period;
		restart_in_s <= '0';

		------------------------------------
		-- Test 5 - Error 2                -
		-- box 1 more boxes than box 2     -
		------------------------------------
		box1_valid_in_s <= '1';
		box1_in_s <= set_box(5,6,7,2);
		wait for 2*half_period;
		box2_valid_in_s <= '1';
		box1_in_s <= set_box(5,3,8,4);
		box2_in_s <= set_box(4,1,8,7);
		wait for 2*half_period;
		box1_in_s <= set_box(1,2,4,2);
		box2_in_s <= set_box(2,5,3,6);
		wait for 2*half_period;
		box1_in_s <= set_box(4,1,8,7);
		box2_in_s <= set_box(5,3,8,4);
		wait for 2*half_period;
		box1_in_s <= set_box(2,5,3,6);
		box2_in_s <= set_box(1,2,4,2);
		wait for 2*half_period;
		box1_valid_in_s <= '0';
		box2_valid_in_s <= '0';

		last_box_in_s <= '1';
		wait for 2*half_period;
		last_box_in_s <= '0';

		if check_done_out_s = '0' then
			wait until check_done_out_s = '1';
		end if;
		if unsigned(error_code_out_s) /= 2 then
			error_n := error_n + 1;
			report "Test 5 failed" severity error;
		end if;

		restart_in_s <= '1';
		wait for 2*half_period;
		restart_in_s <= '0';

		------------------------------------
		-- Test 6 - Error 3                -
		-- box 1 different box 2           -
		------------------------------------
		box1_valid_in_s <= '1';
		box2_valid_in_s <= '1';
		box1_in_s <= set_box(1,3,8,4);
		box2_in_s <= set_box(4,1,8,7);
		wait for 2*half_period;
		box1_in_s <= set_box(1,2,4,2);
		box2_in_s <= set_box(2,5,3,6);
		wait for 2*half_period;
		box1_in_s <= set_box(4,1,8,7);
		box2_in_s <= set_box(5,3,8,4);
		wait for 2*half_period;
		box1_in_s <= set_box(2,5,3,6);
		box2_in_s <= set_box(1,2,4,2);
		wait for 2*half_period;
		box1_valid_in_s <= '0';
		box2_valid_in_s <= '0';

		last_box_in_s <= '1';
		wait for 2*half_period;
		last_box_in_s <= '0';

		if check_done_out_s = '0' then
			wait until check_done_out_s = '1';
		end if;
		if unsigned(error_code_out_s) /= 3 then
			error_n := error_n + 1;
			report "Test 6 failed" severity error;
		end if;

		restart_in_s <= '1';
		wait for 2*half_period;
		restart_in_s <= '0';


		-------------------------------------------
		-- Test 7 - Error 3					              -
		-- box 1 has to times the same output     -
		-------------------------------------------
		box1_valid_in_s <= '1';
		box2_valid_in_s <= '1';
		box1_in_s <= set_box(5,3,8,4);
		box2_in_s <= set_box(5,3,8,4);
		wait for 2*half_period;
		box1_in_s <= set_box(1,2,4,2);
		box2_in_s <= set_box(1,2,4,2);
		wait for 2*half_period;
		box1_in_s <= set_box(4,1,8,7);
		box2_in_s <= set_box(4,1,8,7);
		wait for 2*half_period;
		box1_in_s <= set_box(4,1,8,7);
		box2_in_s <= set_box(2,5,3,6);
		wait for 2*half_period;
		box1_valid_in_s <= '0';
		box2_valid_in_s <= '0';

		last_box_in_s <= '1';
		wait for 2*half_period;
		last_box_in_s <= '0';

		if check_done_out_s = '0' then
			wait until check_done_out_s = '1';
		end if;
		if unsigned(error_code_out_s) /= 3 then
			error_n := error_n + 1;
			report "Test 7 failed" severity error;
		end if;

		restart_in_s <= '1';
		wait for 2*half_period;
		restart_in_s <= '0';

		-------------------------------------------
		-- Test 8 - Error 3					              -
		-- box 2 has to times the same output     -
		-------------------------------------------
		box1_valid_in_s <= '1';
		box2_valid_in_s <= '1';
		box1_in_s <= set_box(5,3,8,4);
		box2_in_s <= set_box(5,3,8,4);
		wait for 2*half_period;
		box1_in_s <= set_box(1,2,4,2);
		box2_in_s <= set_box(1,2,4,2);
		wait for 2*half_period;
		box1_in_s <= set_box(4,1,8,7);
		box2_in_s <= set_box(4,1,8,7);
		wait for 2*half_period;
		box1_in_s <= set_box(2,5,3,6);
		box2_in_s <= set_box(4,1,8,7);
		wait for 2*half_period;
		box1_valid_in_s <= '0';
		box2_valid_in_s <= '0';

		last_box_in_s <= '1';
		wait for 2*half_period;
		last_box_in_s <= '0';

		if check_done_out_s = '0' then
			wait until check_done_out_s = '1';
		end if;
		if unsigned(error_code_out_s) /= 3 then
			error_n := error_n + 1;
			report "Test 8 failed" severity error;
		end if;

		restart_in_s <= '1';
		wait for 2*half_period;
		restart_in_s <= '0';

		-------------------------------------------
		-- Test 10 - Error 1                      -
		-- box 2 has more boxes and different     -
		-------------------------------------------
		box1_valid_in_s <= '1';
		box2_valid_in_s <= '1';
		box1_in_s <= set_box(0,0,0,0);
		box2_in_s <= set_box(0,0,0,0);
		wait for 2*half_period;
		box1_in_s <= set_box(1,2,4,2);
		box2_in_s <= set_box(1,2,4,2);
		wait for 2*half_period;
		box1_in_s <= set_box(4,1,8,7);
		box2_in_s <= set_box(4,1,8,7);
		wait for 2*half_period;
		box1_in_s <= set_box(4,1,8,7);
		box2_in_s <= set_box(5,2,1,0);
		wait for 2*half_period;
		box1_valid_in_s <= '0';
		box2_in_s <= set_box(1,1,1,0);
		wait for 2*half_period;
		box2_valid_in_s <= '0';

		last_box_in_s <= '1';
		wait for 2*half_period;
		last_box_in_s <= '0';

		if check_done_out_s = '0' then
			wait until check_done_out_s = '1';
		end if;
		if unsigned(error_code_out_s) /= 1 then
			error_n := error_n + 1;
			report "Test 10 failed" severity error;
		end if;

		restart_in_s <= '1';
		wait for 2*half_period;
		restart_in_s <= '0';

		-------------------------------------------
		-- Test 11 - Error 3                      -
		-- box 2 double box output and different  -
		-- but the same number of boxes           -
		-------------------------------------------
		box1_valid_in_s <= '1';
		box2_valid_in_s <= '1';
		box1_in_s <= set_box(1,2,4,2);
		box2_in_s <= set_box(0,0,0,0);
		wait for 2*half_period;
		box1_in_s <= set_box(0,0,0,0);
		box2_in_s <= set_box(4,1,8,7);
		wait for 2*half_period;
		box1_in_s <= set_box(4,1,8,7);
		box2_in_s <= set_box(5,2,1,0);
		wait for 2*half_period;
		box1_in_s <= set_box(5,2,1,0);
		box2_in_s <= set_box(1,2,4,2);
		wait for 2*half_period;
		box2_in_s <= set_box(3,2,1,0);
		box2_in_s <= set_box(1,1,1,0);
		wait for 2*half_period;
		box2_valid_in_s <= '0';
		box1_valid_in_s <= '0';

		last_box_in_s <= '1';
		wait for 2*half_period;
		last_box_in_s <= '0';

		if check_done_out_s = '0' then
			wait until check_done_out_s = '1';
		end if;
		if unsigned(error_code_out_s) /= 3 then
			error_n := error_n + 1;
			report "Test 11 failed" severity error;
		end if;

		restart_in_s <= '1';
		wait for 2*half_period;
		restart_in_s <= '0';

		-------------------------------------------
		-- Test 12 - Error 3                      -
		-- same amount of boxes but wrong         -
		-------------------------------------------

		wait for 55*2*half_period;
		box1_valid_in_s <= '1';
		box1_in_s <= set_box(0,4,2,2);
		wait for 2*half_period;
		box1_valid_in_s <= '0';
		wait for 24*2*half_period;
		box1_valid_in_s <= '1';
		box1_in_s <= set_box(0,0,5,5);
		wait for 2*half_period;
		box1_valid_in_s <= '0';
		wait for 9*2*half_period;
		box2_valid_in_s <= '1';
		box2_in_s <= set_box(0,0,5,5);
		wait for 2*half_period;
		box2_in_s <= set_box(0,1,2,2);
		wait for 2*half_period;
		box2_valid_in_s <= '0';
		wait for 17*2*half_period;

		last_box_in_s <= '1';
		wait for 2*half_period;
		last_box_in_s <= '0';

		if check_done_out_s = '0' then
			wait until check_done_out_s = '1';
		end if;
		if unsigned(error_code_out_s) /= 3 then
			error_n := error_n + 1;
			report "Test 12 failed" severity error;
		end if;

		restart_in_s <= '1';
		wait for 2*half_period;
		restart_in_s <= '0';




		clk_en_s <= '0';
		if error_n = 0 then
			report "no error found";
		else
			report Integer'image(error_n) & " errors found" severity failure;
		end if;
		wait;
	end process test_p;

end architecture Behavioral;
