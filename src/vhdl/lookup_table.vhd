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
--! @file lookup_table.vhd
--! @brief Lookup table generation with equivalent resolving
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-06-04
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.utils.all;

--! Lookup generation for the second pass of connected component labeling

entity lookup_table is
	generic(
		--! Number of max chain elements to store before stall
		G_MAX_CHAIN       : NATURAL := 5
	);
	port(
		--! Clock input
		clk_in            : in STD_LOGIC;
		--! Reset input
		rst_in            : in STD_LOGIC;

		--! Output if the chain resolution stalls
		stall_out         : out STD_LOGIC;

		--! Output of the next label
		next_lable_out    : out T_LABEL;

		--! Generates next label
		gen_lable_in      : in STD_LOGIC;

		--! Equivalent label
		equi_in           : in T_EQUI;

		--! equi_in data valid
		equi_valid_in     : in STD_LOGIC;

		--! High if the lookup table is ready to use. All chains are resolved
		lookup_ready_out  : out STD_LOGIC;

		--! Lookup label
		lookup_in         : in T_LABEL;

		--! Looked up label
		lookup_out        : out T_LABEL;

	  --! Last lookup reset after this
	  last_look_up_in   : in STD_LOGIC;

		error_out         : out STD_LOGIC

	);
end entity lookup_table;

--! @brief arc description
--! @details more detailed description
architecture lookup_table_arc of lookup_table is
	type T_EQUI_TABLE is array (0 to 2**T_LABEL'length) of T_LABEL;

	type T_CHK_STATE is (READY, RUN, RESTART);

	signal chk_state_s  : T_CHK_STATE;
	signal chk_ptr_s    : T_LABEL;

	signal equi_table_s : T_EQUI_TABLE;

	signal lbl_cnt_s    : T_LABEL;

	-- equi ff signals
	signal eq_ff_di_s   : unsigned(2*T_LABEL'length - 1 downto 0);
	signal eq_ff_do_s   : unsigned(2*T_LABEL'length - 1 downto 0);
	signal eq_ff_full_s : std_logic;
	signal eq_ff_ep_s   : std_logic;
	signal eq_ff_ae_s   : std_logic;
	signal eq_ff_nx_s   : std_logic;
	signal eq_ff_d_vl_s : std_logic;

	signal l_dst_s      : T_LABEL;
	signal l_src_s      : T_LABEL;

	signal lo_rdy_s     : std_logic;
	signal lo_rdy_d_s   : std_logic;

	signal last_lo_s    : std_logic;

begin

	l_dst_s <= eq_ff_do_s(2*T_LABEL'length-1 downto T_LABEL'length);
	l_src_s <= eq_ff_do_s(T_LABEL'range);

	next_lable_out <= lbl_cnt_s + 1 when gen_lable_in = '0' else lbl_cnt_s + 2;

	lookup_ready_out <= lo_rdy_s and lo_rdy_d_s;
	stall_out <= '0';


	--! Label generation process

	p_lable_gen : process (rst_in, clk_in, gen_lable_in)
	begin
		if rst_in = '1' then
			lbl_cnt_s <= (others => '0');
			last_lo_s <= '0';
		elsif rising_edge(clk_in) and rst_in = '0' then
			if gen_lable_in = '1' then
				lbl_cnt_s <= lbl_cnt_s + 1;
			end if;

			if last_look_up_in = '1' then
				last_lo_s <= '1';
			end if;

			if last_lo_s = '1' and lo_rdy_s = '1' and lo_rdy_d_s = '1' then
				-- auto reset
				lbl_cnt_s <= (others => '0');
				last_lo_s <= '0';
			end if;

		end if;
	end process p_lable_gen;

	p_equi : process (rst_in, clk_in, gen_lable_in)
		--! memory stuff to get xst to recognise it
		-- write data
		variable wr_data_v    : T_LABEL;
		variable wr_addr_v    : T_LABEL;
		variable wr_en_v      : STD_LOGIC;

	begin
		if rst_in = '1' then
			eq_ff_d_vl_s <= '0';
			lo_rdy_s <= '0';
			lo_rdy_d_s <= '0';
			equi_table_s <= (others => (others => '0'));
		elsif rising_edge(clk_in) and rst_in = '0' then
			wr_en_v := '0';
			eq_ff_d_vl_s <= '0';

			if chk_state_s = READY and eq_ff_ep_s = '1' and eq_ff_d_vl_s = '0' then
				lo_rdy_s <= '1';
			else
				lo_rdy_s <= '0';
			end if;

			lo_rdy_d_s <= lo_rdy_s;

		if gen_lable_in = '1' then
				--equi_table_s(to_integer(lbl_cnt_s + 1)) <= lbl_cnt_s + 1;
				wr_addr_v := lbl_cnt_s + 1;
				wr_data_v := lbl_cnt_s + 1;
				wr_en_v := '1';
			else
				if equi_valid_in = '1' then
					eq_ff_di_s <= equi_in(0) & equi_in(1);
					eq_ff_d_vl_s <= '1';
				else

					case chk_state_s is
						when RUN =>
						--resolve chains in equivalent table

						--equi_table_s(to_integer(chk_ptr_s)) <= equi_table_s(to_integer(equi_table_s(to_integer(chk_ptr_s))));
							if equi_table_s(to_integer(chk_ptr_s)) = l_dst_s or chk_ptr_s = l_dst_s then
								if equi_table_s(to_integer(chk_ptr_s)) > l_src_s then
									if equi_table_s(to_integer(chk_ptr_s)) /= l_src_s then
										eq_ff_di_s <= equi_table_s(to_integer(chk_ptr_s)) & l_src_s;
										eq_ff_d_vl_s <= '1';
									end if;
								elsif equi_table_s(to_integer(chk_ptr_s)) < l_src_s then
									if l_src_s /= equi_table_s(to_integer(chk_ptr_s)) then
										eq_ff_di_s <= l_src_s & equi_table_s(to_integer(chk_ptr_s));
										eq_ff_d_vl_s <= '1';
									end if;
								else
									if equi_table_s(to_integer(chk_ptr_s)) >
									equi_table_s(to_integer(equi_table_s(to_integer(chk_ptr_s))))
									then
										if equi_table_s(to_integer(chk_ptr_s)) /=
										equi_table_s(to_integer(equi_table_s(to_integer(chk_ptr_s))))
										then
											eq_ff_di_s <= equi_table_s(to_integer(chk_ptr_s))
																		&equi_table_s(to_integer(equi_table_s(to_integer(chk_ptr_s))));
											eq_ff_d_vl_s <= '1';
										end if;
									end if;
								end if;


								wr_addr_v := chk_ptr_s;
								wr_data_v := l_src_s;
								wr_en_v := '1';
							end if;

						when RESTART =>
							null;

						when READY =>
							if lookup_in > 0 then
							-- lookup only possible if lookup table fully processed
								lookup_out <= equi_table_s(to_integer(lookup_in));
							else
								lookup_out <= (others => '0');
							end if;
					end case;
				end if;
			end if;

			if wr_en_v = '1' then
				equi_table_s(to_integer(wr_addr_v)) <= wr_data_v;
			end if;
		end if; -- clk
	end process p_equi;

	p_state : process (rst_in, clk_in)
	begin
		if rst_in = '1' then
			chk_state_s <= READY;
			eq_ff_nx_s <= '0';
		elsif rising_edge(clk_in) and rst_in = '0' then
			eq_ff_nx_s <= '0';

			case chk_state_s is
				when READY =>
					if eq_ff_ep_s = '0' and eq_ff_nx_s = '0' then
						chk_state_s <= RUN;
						chk_ptr_s <= lbl_cnt_s;
					end if;

				when RUN =>
					if chk_ptr_s > 1 and gen_lable_in = '0' and equi_valid_in = '0' then
						chk_ptr_s <= chk_ptr_s - 1;
					elsif chk_ptr_s <= 1 and eq_ff_ae_s = '1' and equi_valid_in = '0' then
						chk_state_s <= READY;
						if eq_ff_ep_s = '0' then
							eq_ff_nx_s <= '1';
						end if;
					elsif chk_ptr_s <= 1 and (eq_ff_ae_s = '0' or equi_valid_in = '1') then
						chk_state_s <= RESTART;
						eq_ff_nx_s <= '1';
					end if;

				when RESTART =>
					chk_state_s <= RUN;
					chk_ptr_s <= lbl_cnt_s;
			end case;

		end if;
	end process p_state;

	error_out <= eq_ff_d_vl_s and eq_ff_full_s;

	equi_fifo : entity work.fifo
	generic map(
		--! Size of the fifo in input words
		G_SIZE          => C_MAX_IMAGE_HEIGHT * C_MAX_IMAGE_WIDTH*2,
		--! input width in bits
		G_WORD_WIDTH    => 2*T_LABEL'LENGTH,
		--! output width in bits
		G_ALMOST_EMPTY  => 1,
		--! Threshold for the nearly full signal in input words
		G_ALMOST_FULL   => C_MAX_IMAGE_WIDTH - 1,
		--! First Word Fall Through
		G_FWFT          => true
	)
	port map(
		--! Reset input
		rst_in          => rst_in,

		--! Clock input
		clk_in          => clk_in,

		--! Data input
		wr_d_in         => eq_ff_di_s,
		--! Data on write input valid
		wr_valid_in     => eq_ff_d_vl_s,
		--! Fifo reached the G_ALMOST_FULL threshold
		almost_full_out => open,
		--! Fifo is full
		full_out        => eq_ff_full_s,

		--! Data output
		rd_d_out        => eq_ff_do_s,
		--! Data on output read -> next
		rd_next_in      => eq_ff_nx_s,
		--! Fifo reached the G_ALMOST_EMPTY threshold
		almost_empty_out=> eq_ff_ae_s,
		--! Fifo is empty
		empty_out       => eq_ff_ep_s,

		--! Fill level of fifo
		fill_lvl_out    => open
	);

end architecture lookup_table_arc;


