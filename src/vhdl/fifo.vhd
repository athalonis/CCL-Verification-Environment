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
--! @file fifo.vhd
--! @brief Configurable fifo
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-07-24
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.utils.all;

--! simple synchronous FIFO
entity fifo is
	generic(
		--! Size of the fifo in input words
		G_SIZE          : NATURAL := 64;
		--! input width in bits
		G_WORD_WIDTH    : NATURAL := 8;
		--! Threshold for the almost empty signal
		G_ALMOST_EMPTY  : NATURAL := 1;
		--! Threshold for the nearly full signal in input words
		G_ALMOST_FULL   : NATURAL := 64 - 1;
		--! First Word Fall Through
		G_FWFT          : BOOLEAN := false
	);
	port(
		--! Reset input
		rst_in            : in STD_LOGIC;

		--! Clock input
		clk_in            : in STD_LOGIC;

		--! Data input
		wr_d_in           : in unsigned(G_WORD_WIDTH - 1 downto 0);
		--! Data on write input valid
		wr_valid_in       : in STD_LOGIC;
		--! Fifo reached the G_ALMOST_FULL threshold
		almost_full_out   : out STD_LOGIC;
		--! Fifo is full
		full_out          : out STD_LOGIC;

		--! Data output
		rd_d_out          : out unsigned(G_WORD_WIDTH - 1 downto 0);
		--! Data on output read -> next
		rd_next_in        : in STD_LOGIC;
		--! Fifo reached the G_ALMOST_EMPTY threshold
		almost_empty_out  : out STD_LOGIC;
		--! Fifo is empty
		empty_out         : out STD_LOGIC;

		--! Fill level of fifo
		fill_lvl_out      : out unsigned(log2_ceil(G_SIZE) downto 0)
	);
end entity fifo;

architecture fifo_arc of fifo is

	type T_BUFFER is array (G_SIZE - 1 downto 0)
	of UNSIGNED(G_WORD_WIDTH - 1 downto 0);

	signal buf_s      : T_BUFFER;
	signal rd_cnt_s   : UNSIGNED(log2_ceil(G_SIZE) - 1 downto 0);
	signal wr_cnt_s   : UNSIGNED(log2_ceil(G_SIZE) - 1 downto 0);

	signal fill_lvl_s : UNSIGNED(log2_ceil(G_SIZE) downto 0);
begin

	--empty_out <= '1' when fill_lvl_s = 0 else '0';
	empty_out <= '1' when rd_cnt_s = wr_cnt_s else '0';
	full_out <= '1' when fill_lvl_s = G_SIZE else '0';
	almost_full_out <= '1' when fill_lvl_s >= G_ALMOST_FULL else '0';
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
						fill_lvl_s <= fill_lvl_s + 1;
					end if;
				elsif rd_next_in = '1' and wr_valid_in = '1' then
					if fill_lvl_s = 0 then
						fill_lvl_s <= fill_lvl_s + 1;
					end if;
				end if;
			end if;
		end if;
	end process p_fill_level;

	p_write : process (clk_in, rst_in)
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				wr_cnt_s <= (others => '0');
			else
				if wr_valid_in = '1' then
					if fill_lvl_s < G_SIZE then
						if not (G_FWFT and fill_lvl_s = 0) and 
						not (G_FWFT and fill_lvl_s = 1 and rd_next_in = '1') then
							buf_s(to_integer(wr_cnt_s)) <= wr_d_in;
							if wr_cnt_s = G_SIZE-1 then
								wr_cnt_s <= (others => '0');
							else
								wr_cnt_s <= wr_cnt_s + 1;
							end if;
						end if;
					else
						report "Fifo Buffer overflow data droped" severity warning;
					end if;
				end if;
			end if;
		end if;
	end process p_write;

	p_read : process (clk_in, rst_in)
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				rd_cnt_s <= (others => '0');
			else
				if G_FWFT and fill_lvl_s = 0 and wr_valid_in = '1' then
					-- data are written to a empty fifo (no data on the output)
					-- in first word fall through mode the data needs to be output
					rd_d_out <= wr_d_in;
				elsif rd_next_in = '1' and fill_lvl_s > 0 then
					-- new data read from a filled fifo
					if G_FWFT and fill_lvl_s = 1 and wr_valid_in = '1' then
						-- in case of FWFT all words are on output new output is only
						-- possible if new data arrives at the moment
						rd_d_out <= wr_d_in;
					else
						rd_d_out <= buf_s(to_integer(rd_cnt_s));
						if fill_lvl_s > 1 or not G_FWFT then
							if rd_cnt_s = G_SIZE -1 then
								rd_cnt_s <= (others => '0');
							else
								rd_cnt_s <= rd_cnt_s + 1;
							end if;
						end if;
					end if;
				else
					assert rd_next_in = '0' report "Read from empty fifo" severity warning;
				end if;
			end if;
		end if;
	end process p_read;
end fifo_arc;


