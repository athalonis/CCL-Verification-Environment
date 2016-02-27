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
--! @file fifo_asym.vhd
--! @brief Configurable fifo with bigger in than output
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2014-04-23
--! @detail the input needs to be a multiple of the output
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.utils.all;

--! simple synchronous FIFO
entity fifo_asym is
	generic(
		--! Size of the fifo in input words
		G_SIZE           : NATURAL := 64;
		--! output width in bits
		G_OUT_WORD_WIDTH : NATURAL := 8;
		--! input width as a multiple of the output
		G_IN_MUL_WIDTH   : NATURAL := 2;
		--! output width in bits
		G_ALMOST_EMPTY   : NATURAL := 1;
		--! Threshold for the nearly full signal in input words
		G_ALMOST_FULL    : NATURAL := 64 - 1;
		--! First Word Fall Through
		G_FWFT           : BOOLEAN := false
	);
	port(
		--! Reset input
		rst_in            : in STD_LOGIC;

		--! Clock input
		clk_in            : in STD_LOGIC;

		--! Data input
		wr_d_in           : in unsigned(G_OUT_WORD_WIDTH*G_IN_MUL_WIDTH - 1 downto 0);
		--! Data on write input valid
		wr_valid_in       : in STD_LOGIC;
		--! Fifo reached the G_ALMOST_FULL threshold
		almost_full_out   : out STD_LOGIC;
		--! Fifo is full
		full_out          : out STD_LOGIC;

		--! Data output
		rd_d_out          : out unsigned(G_OUT_WORD_WIDTH - 1 downto 0);
		--! Data on output read -> next
		rd_next_in        : in STD_LOGIC;
		--! Fifo reached the G_ALMOST_EMPTY threshold
		almost_empty_out  : out STD_LOGIC;
		--! Fifo is empty
		empty_out         : out STD_LOGIC;

		--! Fill level of fifo in output words
		fill_lvl_out      : out unsigned(log2_ceil(G_SIZE) downto 0)
	);
end entity fifo_asym;

--! @brief the almost full and full signal is counted in input words
--!        the almost empty and empty signal is counted in output words
architecture fifo_asym_in_big_arc of fifo_asym is
	signal fifo_rd_d_s   : UNSIGNED(G_OUT_WORD_WIDTH*G_IN_MUL_WIDTH-1 downto 0);
	signal fifo_rd_nxt_s : STD_LOGIC;
	signal fifo_empty_s  : STD_LOGIC;

	signal fill_lvl_s    : UNSIGNED(log2_ceil(G_SIZE) downto 0);
	signal rd_cnt_s      : UNSIGNED(log2_ceil(G_IN_MUL_WIDTH) downto 0);

begin

	--empty_out <= '1' when fill_lvl_s = 0 else '0';
	empty_out <= '1' when fifo_empty_s = '1' and rd_cnt_s = 0 else '0';
	almost_empty_out <= '1' when fill_lvl_s <= G_ALMOST_EMPTY else '0';

	fill_lvl_out <= fill_lvl_s;

	p_fill_level : process (clk_in, rst_in)
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				fill_lvl_s <= (others => '0');
			else
				if rd_next_in = '1' and wr_valid_in = '0' then
					if fill_lvl_s > 0 then
						fill_lvl_s <= fill_lvl_s - 1;
					end if;
				elsif rd_next_in = '0' and wr_valid_in = '1' then
					if fill_lvl_s < G_SIZE then
						fill_lvl_s <= fill_lvl_s + G_IN_MUL_WIDTH;
					end if;
				elsif rd_next_in = '1' and wr_valid_in = '1' then
					if fill_lvl_s = 0 then
						fill_lvl_s <= fill_lvl_s + G_IN_MUL_WIDTH;
					else
						fill_lvl_s <= fill_lvl_s + G_IN_MUL_WIDTH - 1;
					end if;
				end if;
			end if;
		end if;
	end process p_fill_level;


	p_read : process (clk_in, rst_in)
	begin
		if rst_in = '0' then
			if rising_edge(clk_in) then

				--default value
				fifo_rd_nxt_s <= '0';

				if G_FWFT and fill_lvl_s = 0 and wr_valid_in = '1' then
					-- data are written to a empty fifo (no data on the output)
					-- in first word fall through mode the data needs to be output
					rd_d_out <= wr_d_in(wr_d_in'high downto wr_d_in'high -
											G_OUT_WORD_WIDTH+1);
					rd_cnt_s <= to_unsigned(1, rd_cnt_s'length);
				elsif rd_next_in = '1' and fill_lvl_s > 0 then
					-- new data read from a filled fifo
					if G_FWFT and fill_lvl_s = 1 and wr_valid_in = '1' then
						-- in case of FWFT all words are on output new output is only
						-- possible if new data arrives at the moment
						rd_d_out <= wr_d_in(wr_d_in'high downto wr_d_in'high -
												G_OUT_WORD_WIDTH+1);
						rd_cnt_s <= to_unsigned(1, rd_cnt_s'length);
					else
						rd_d_out <= fifo_rd_d_s(fifo_rd_d_s'high -
												to_integer(rd_cnt_s)*G_OUT_WORD_WIDTH downto
												fifo_rd_d_s'high -
												(to_integer(rd_cnt_s)+1)*G_OUT_WORD_WIDTH+1);
						if fill_lvl_s > 1 or not G_FWFT then
							if rd_cnt_s = G_IN_MUL_WIDTH -1 then
								rd_cnt_s <= (others => '0');
							else
								rd_cnt_s <= rd_cnt_s + 1;
							end if;
						end if;
						
						if rd_cnt_s = G_IN_MUL_WIDTH -1 then
							fifo_rd_nxt_s <= '1';
						end if;
					end if;
				else
					assert rd_next_in = '0' report "Read from empty fifo" severity warning;
				end if;
			end if; --clk
		else
			--reset
			rd_cnt_s <= (others => '0');
			fifo_rd_nxt_s <= '0';
		end if;
	end process p_read;

	fifo_sym : entity work.fifo
	generic map(
		--! Size of the fifo in input words
		G_SIZE          => G_SIZE,
		--! input width in bits
		G_WORD_WIDTH    => G_OUT_WORD_WIDTH*G_IN_MUL_WIDTH,
		--! Threshold for the almost empty signal
		G_ALMOST_EMPTY  => 0,
		--! Threshold for the nearly full signal in input words
		G_ALMOST_FULL   => G_ALMOST_FULL,
		--! First Word Fall Through
		G_FWFT          => True
	)
	port map(
		--! Reset input
		rst_in            => rst_in,

		--! Clock input
		clk_in            => clk_in,

		--! Data input
		wr_d_in           => wr_d_in,
		--! Data on write input valid
		wr_valid_in       => wr_valid_in,
		--! Fifo reached the G_ALMOST_FULL threshold
		almost_full_out   => almost_full_out,
		--! Fifo is full
		full_out          => full_out,

		--! Data output
		rd_d_out          => fifo_rd_d_s, 
		--! Data on output read -> next
		rd_next_in        => fifo_rd_nxt_s,
		--! Fifo reached the G_ALMOST_EMPTY threshold
		almost_empty_out  => open,
		--! Fifo is empty
		empty_out         => fifo_empty_s,

		--! Fill level of fifo
		fill_lvl_out      => open
	);
end fifo_asym_in_big_arc;
