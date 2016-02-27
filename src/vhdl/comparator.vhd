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
		G_MAX_BOXES       : NATURAL := div_ceil(C_MAX_IMAGE_WIDTH,2)*div_ceil(C_MAX_IMAGE_WIDTH,2)
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

architecture comparator_arc of comparator is
	TYPE T_STATE is (SAMPLING, COMPARE, RESET);

	TYPE T_BOX2_RAM is array (0 to G_MAX_BOXES - 1) of T_BOX;
	SUBTYPE T_BOX2_BITS is STD_LOGIC_VECTOR(G_MAX_BOXES - 1 downto 0);

	constant C_NO_ERROR   : unsigned(3 downto 0) := "0000";
	constant C_DUT_LESS   : unsigned(3 downto 0) := "0001";
	constant C_DUT_MORE   : unsigned(3 downto 0) := "0010";
	constant C_DUT_WRONG  : unsigned(3 downto 0) := "0011";

	signal state_s        : T_STATE;
	signal state_d_s      : T_STATE;

	signal box2_ram_s     : T_BOX2_RAM;
	signal box2_valid_s   : unsigned(log2_ceil(T_BOX2_RAM'length) - 1 downto 0);
	signal box2_found_s   : T_BOX2_BITS;
	signal wr_cnt_s       : unsigned(log2_ceil(T_BOX2_RAM'length) - 1 downto 0);
	signal rd_cnt_s       : unsigned(log2_ceil(T_BOX2_RAM'length) - 1 downto 0);
	signal rd_cnt_d_s     : unsigned(log2_ceil(T_BOX2_RAM'length) - 1 downto 0);

	signal box1_s         : T_BOX;
	signal box1_v_s       : STD_LOGIC;
	signal box1_v_d_s     : STD_LOGIC;
	signal box1_next_s    : STD_LOGIC := '0';
	signal box1_empty_s   : STD_LOGIC;
	signal box1_fill_s    : unsigned(0 to log2_ceil(G_MAX_BOXES));

	signal match_done_s   : STD_LOGIC;

	signal restart_d_s    : STD_LOGIC;

	signal rst_fifo_s     : STD_LOGIC;
begin

	rst_fifo_s <= '1' when state_s = RESET or rst_in = '1' else '0';

	--! p_state contorls the state machine
	--! RESET after a external reset
	--! SAMPLING reads values from box_in if valid
	--! COMPARE after last_box_in gets high until every thing is compared
	p_state : process(clk_in, rst_in) is
	begin
		if rst_in = '1' then
			state_s <= SAMPLING;

		elsif rising_edge(clk_in) then

			if restart_in = '1' then
				state_s <= SAMPLING;
			else
				state_d_s <= state_s;
				case state_s is
					when SAMPLING =>
						if last_box_in = '1' then
							if box1_fill_s /= wr_cnt_s then
								-- box1 and box2 different number of boxes
								state_s <= RESET;
							else
								state_s <= COMPARE;
							end if;
						end if;
					when COMPARE =>
						if box1_empty_s = '1' and match_done_s = '1' then
							state_s <= RESET;
						end if;
					when RESET =>
						if last_box_in = '0' then
							state_s <= SAMPLING;
						end if;
				end case;
			end if; --rst
		end if; --clk
	end process p_state;

	p_write : process(clk_in, rst_in) is
		variable box2_valid_v : unsigned(T_BOX2_RAM'length downto 0);
	begin

		if rst_in = '1' then
			wr_cnt_s <= (others => '0');
			rd_cnt_s <= (others => '0');
			box2_valid_s <= (others => '0');
			box2_found_s <= (others => '0');
			box1_v_s <= '0';
			box1_v_d_s <= '0';
			match_done_s <= '0';
			restart_d_s <= '0';
			box1_next_s <= '0';
			check_done_out <= '0';

		elsif rising_edge(clk_in) then
			box1_next_s <= '0';
			check_done_out <= '0';

			restart_d_s <= '0';
			if restart_in = '1' then
				restart_d_s <= '1';
			end if;

			if state_s = RESET then
				wr_cnt_s <= (others => '0');
				rd_cnt_s <= (others => '0');
				box2_valid_s <= (others => '0');
				box2_found_s <= (others => '0');
				box1_v_s <= '0';
				box1_v_d_s <= '0';
				match_done_s <= '0';

				-- box2_found_s is unary coded -> convert box2_valid_s to unary
				box2_valid_v := (others => '0');
				box2_valid_v(to_integer(box2_valid_s)) := '1';
				box2_valid_v := box2_valid_v-1;

				if restart_d_s = '0' or restart_in = '1' then
					check_done_out <= '1';

					if state_d_s = SAMPLING then
						-- different box count
						if wr_cnt_s < box1_fill_s + 1 then
							error_code_out <= C_DUT_MORE;
						else
							error_code_out <= C_DUT_LESS;
						end if;

					elsif box2_valid_v /= unsigned(box2_found_s) then
						error_code_out <= C_DUT_WRONG;
					end if;
				end if;


			elsif state_s = SAMPLING then
				if box2_valid_in = '1' then
					box2_ram_s(to_integer(wr_cnt_s)) <= box2_in;
					box2_valid_s <= box2_valid_s + 1;
					wr_cnt_s <= wr_cnt_s + 1;
				end if;


			elsif state_s = COMPARE then
				error_code_out <= C_NO_ERROR;
				box1_v_d_s <= box1_v_s;

				-- is the fifo output valid?
				if box1_v_s = '0' then
					-- read first word from buffer
					-- can be removed if the fifo has first word fall through
					--! TODO generate box1_next_s combinatorial to save one clock

					-- is there a additional result in the fifo?
					if box1_empty_s = '0' then
						box1_next_s <= '1';
						box1_v_s <= '1';
						match_done_s <= '0';
					else
						match_done_s <= '1';
					end if;

				elsif box1_v_d_s = '1' then
					if box2_ram_s(to_integer(rd_cnt_s)) = box1_s then
						box2_found_s(to_integer(rd_cnt_s)) <= '1';
						rd_cnt_s <= (others => '0');
						rd_cnt_d_s <= (others => '1');

						-- the right value was found -> the output of fifo will be
						-- invalidated
						box1_v_s <= '0';

					elsif rd_cnt_s = rd_cnt_d_s then
						-- the read counter has not changed
						-- this only can happen if ther is no
						-- match possible of box2 and box1
						box1_v_s <= '0';
					else

						-- store this read counter
						rd_cnt_d_s <= rd_cnt_s;

						-- select next unfound box
						for i in 0 to box2_found_s'high loop
							if box2_found_s(i) = '0' and i > rd_cnt_s then
								rd_cnt_s <= to_unsigned(i, rd_cnt_s'length);
								exit;
							end if;
						end loop;

					end if;
				end if;

			end if; --state
		end if; --clk
	end process p_write;

	--! can be replaced by asynchrone fifo
	--! if one of the CCL architectures needs different clock domain
	box1_fifo : entity work.fifo
	generic map(
		G_SIZE              => G_MAX_BOXES,
		G_WORD_WIDTH        => T_BOX'LENGTH,
		G_ALMOST_FULL       => G_MAX_BOXES - 1
	)
	port map(
		rst_in              => rst_fifo_s,
		clk_in              => clk_in,

		wr_d_in             => box1_in,
		wr_valid_in         => box1_valid_in,
		almost_full_out     => open,
		full_out            => open,

		rd_d_out            => box1_s,
		rd_next_in          => box1_next_s,
		almost_empty_out    => open,
		empty_out           => box1_empty_s,

		fill_lvl_out        => box1_fill_s
	);

end architecture;
