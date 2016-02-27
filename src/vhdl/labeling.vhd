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
--! @file labeling.vhd
--! @brief Connected Component Labeling two pass
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

--! The first pass of the labeling algorithm

entity labeling is
	generic(
		--! Max image width
		G_MAX_IMG_WIDTH   : NATURAL := C_MAX_IMAGE_WIDTH;

		--! Max image height
		G_MAX_IMG_HEIGHT  : NATURAL := C_MAX_IMAGE_HEIGHT
	);
	port(
		--! Clock input
		clk_in            : in STD_LOGIC;
		--! Reset input
		rst_in            : in STD_LOGIC;

		--! Output if the chain resolution stalls
		stall_out         : out STD_LOGIC;

		--! Stall the output of the labeling
		stall_in					: in STD_LOGIC;

		--! Pixel input 0 => background, 1=> foreground
		px_in             : in STD_LOGIC;

		--! width of the image at the input
		img_width_in      : in STD_LOGIC_VECTOR(log2_ceil(G_MAX_IMG_WIDTH) downto 0);

		--! height of the image
		img_height_in     : in STD_LOGIC_VECTOR(log2_ceil(G_MAX_IMG_HEIGHT) downto 0);

		--! output data are valid
		data_valid_out    : out STD_LOGIC;

		--! input data are valid
		data_valid_in     : in STD_LOGIC;

		--! Signal rises if the last label of this image at output
		last_lbl_out      : out STD_LOGIC;

		--! output of labeled image
		label_out         : out STD_LOGIC_VECTOR(T_LABEL'RANGE);

		error_out         : out STD_LOGIC;
	);
end entity labeling;

--! @brief arc description
--! @details more detailed description
architecture labeling_arc of labeling is
	constant C_INSTANCES      : natural := 3;

	type T_LABEL_VECTOR is array (C_INSTANCES - 1 downto 0) of T_LABEL;
	type T_EQUI_VECTOR is array (C_INSTANCES - 1 downto 0) of T_EQUI;

	-- Singals in generate statement
	Signal lu_next_lbl_out_s  : T_LABEL_VECTOR;
	Signal lu_gen_lable_in_s  : STD_LOGIC_VECTOR(C_INSTANCES - 1 downto 0);
	Signal lu_equi_out_s      : T_EQUI_VECTOR;
	Signal lu_equi_valid_in_s : STD_LOGIC_VECTOR(C_INSTANCES - 1 downto 0);
	Signal lu_ready_out_s     : STD_LOGIC_VECTOR(C_INSTANCES - 1 downto 0);
	Signal lu_lbl_out_s       : T_LABEL_VECTOR;
	Signal lu_last_s          : STD_LOGIC_VECTOR(C_INSTANCES - 1 downto 0);

	Signal st_px_valid_in_s   : STD_LOGIC_VECTOR(C_INSTANCES - 1 downto 0);
	Signal st_rd_px_in_s      : STD_LOGIC_VECTOR(C_INSTANCES - 1 downto 0);
	Signal st_rd_px_out_s     : STD_LOGIC_VECTOR(C_INSTANCES - 1 downto 0);
	Signal st_rd_valid_out_s  : STD_LOGIC_VECTOR(C_INSTANCES - 1 downto 0);
	Signal st_rd_last_out_s   : STD_LOGIC_VECTOR(C_INSTANCES - 1 downto 0);
	Signal st_rd_slast_out_s  : STD_LOGIC_VECTOR(C_INSTANCES - 1 downto 0);

	Signal use_in_st_s        : unsigned(log2_ceil(C_INSTANCES) - 1 downto 0);
	Signal use_out_st_s       : unsigned(log2_ceil(C_INSTANCES) - 1 downto 0);
	Signal use_out_st_d1_s    : unsigned(log2_ceil(C_INSTANCES) - 1 downto 0);
	Signal use_in_lu_s        : unsigned(log2_ceil(C_INSTANCES) - 1 downto 0);
	Signal use_out_lu_s       : unsigned(log2_ceil(C_INSTANCES) - 1 downto 0);
	Signal use_out_lu_d1_s    : unsigned(log2_ceil(C_INSTANCES) - 1 downto 0);
	Signal use_out_lu_d2_s    : unsigned(log2_ceil(C_INSTANCES) - 1 downto 0);


	Signal rst_lbl_cnt_s      : STD_LOGIC;

	Signal stall_out_s        : STD_LOGIC;

	Signal img_px_lbl2_s      : STD_LOGIC;

	Signal px_valid_lbl2_in_s : STD_LOGIC;
	Signal px_valid_lbl2_d1_s : STD_LOGIC;

	Signal last_lbl_s         : STD_LOGIC;
	Signal slast_lbl_s        : STD_LOGIC;
	Signal last_lbled_s       : STD_LOGIC_VECTOR(C_INSTANCES - 1 downto 0);
	Signal last_lbl2_s        : STD_LOGIC;
	Signal last_lbl2_d1_s     : STD_LOGIC := '0';

	Signal lookup_ready_s     : STD_LOGIC;

	Signal data_valid_s       : STD_LOGIC;

	Signal cnt_lbl2_s         : T_LABEL;
	Signal inc_lbl2_s         : STD_LOGIC;

	Signal next_gen_in_s      : T_LABEL;
	Signal gen_lable_out_s    : STD_LOGIC;
	Signal equi_out_s         : T_EQUI;
	Signal equi_valid_out_s   : STD_LOGIC;

	Signal p2_lbl_s           : T_LABEL;


begin
	stall_out <= '0';
	last_lbl_out <= last_lbl2_d1_s;
	label_out <= STD_LOGIC_VECTOR(lu_lbl_out_s(to_integer(use_out_lu_d2_s)));
	lookup_ready_s <= last_lbled_s(to_integer(use_out_st_s)) and lu_ready_out_s(to_integer(use_out_lu_s));

	-- arbiter for two lookup tables
	next_gen_in_s         <= lu_next_lbl_out_s(to_integer(use_in_st_s));
	img_px_lbl2_s         <= st_rd_px_out_s(to_integer(use_out_lu_s));
	data_valid_s          <= st_rd_valid_out_s(to_integer(use_out_lu_s));

	rst_lbl_cnt_s <= rst_in or last_lbl2_s;

	labeling_p1 : entity work.labeling_p1 PORT MAP(
		clk_in          => clk_in,
		rst_in          => rst_in,
		stall_out       => stall_out_s,
		stall_in        => stall_in,
		px_in           => px_in,
		px_valid_in     => data_valid_in,
		img_width_in    => UNSIGNED(img_width_in),
		img_height_in   => UNSIGNED(img_height_in),
		next_lable_in   => next_gen_in_s,
		gen_lable_out   => gen_lable_out_s,
		equi_out        => equi_out_s,
		equi_valid_out  => equi_valid_out_s,
		last_lbl_out    => last_lbl_s,
		slast_lbl_out   => slast_lbl_s,
		label_out       => open
	);


	gen_lookup : for i in C_INSTANCES - 1 downto 0 generate
		lookup_table : entity work.lookup_table PORT MAP(
			clk_in          => clk_in,
			rst_in          => rst_in,
			stall_out       => open,
			next_lable_out  => lu_next_lbl_out_s(i),
			gen_lable_in    => lu_gen_lable_in_s(i),
			equi_in         => lu_equi_out_s(i),
			equi_valid_in   => lu_equi_valid_in_s(i),
			lookup_ready_out=> lu_ready_out_s(i),
			lookup_in       => p2_lbl_s,
			lookup_out      => lu_lbl_out_s(i),
			last_look_up_in => lu_last_s(i),
			error_out       => error_out
		);

		px_store : entity work.px_storage port map(
			clk_in          => clk_in,
			rst_in          => rst_in,
			img_width_in    => UNSIGNED(img_width_in),
			img_height_in   => UNSIGNED(img_height_in),
			wr_px_in        => px_in,
			wr_valid_in     => st_px_valid_in_s(i),
			rd_px_in        => st_rd_px_in_s(i),
			rd_px_out       => st_rd_px_out_s(i),
			rd_valid_out    => st_rd_valid_out_s(i),
			rd_last_px_out  => st_rd_last_out_s(i),
			rd_slast_px_out => st_rd_slast_out_s(i)
		);


		lu_gen_lable_in_s(i)  <= gen_lable_out_s when use_in_lu_s = i else '0';
		lu_equi_valid_in_s(i) <= equi_valid_out_s when use_in_lu_s = i else '0';
		st_px_valid_in_s(i)   <= '1' when data_valid_in = '1' and use_in_st_s = i else '0';
		st_rd_px_in_s(i)      <= '1' when lookup_ready_s = '1' and use_out_st_s = i else '0';
		lu_last_s(i)          <= '1' when use_out_lu_d1_s = i and last_lbl2_s = '1' else '0';

		lu_equi_out_s(i)      <= equi_out_s when use_in_lu_s = i else (others => (others => '-'));

	end generate gen_lookup;

	lbl_cnt_p2 : entity work.counter PORT MAP(
		clk_in          => clk_in,
		rst_in          => rst_lbl_cnt_s,
		inc_in          => inc_lbl2_s,
		cnt_out         => cnt_lbl2_s
	);

	px_valid_lbl2_in_s <= data_valid_s;
	labeling_p2 : entity work.labeling_p1 PORT MAP(
		clk_in          => clk_in,
		rst_in          => rst_in,
		stall_out       => open,
		stall_in        => stall_in,
		px_in           => img_px_lbl2_s,
		px_valid_in     => px_valid_lbl2_in_s,
		img_width_in    => UNSIGNED(img_width_in),
		img_height_in   => UNSIGNED(img_height_in),
		next_lable_in   => cnt_lbl2_s,
		gen_lable_out   => inc_lbl2_s,
		equi_out        => open,
		equi_valid_out  => open,
		last_lbl_out    => last_lbl2_s,
		label_out       => p2_lbl_s
	);


	p_delay_last : process(clk_in)
	begin
		if rising_edge (clk_in) then
			if rst_in = '1' then
				last_lbl2_d1_s <= '0';
				px_valid_lbl2_d1_s <= '0';
				data_valid_out <= '0';
			else
				last_lbl2_d1_s <= last_lbl2_s;

				px_valid_lbl2_d1_s <= px_valid_lbl2_in_s;
				data_valid_out <= px_valid_lbl2_d1_s;
			end if;
		end if;
	end process p_delay_last;

	p_lu_switch : process(clk_in)
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				use_in_st_s <= (others => '0');
				use_out_lu_s <= (others => '0');
				use_out_lu_d1_s <= (others => '0');
				use_out_lu_d2_s <= (others => '0');
				use_out_st_s <= (others => '0');
				last_lbled_s <= (others => '0');
			else

				use_out_lu_d1_s <= use_out_lu_s;
				use_out_lu_d2_s <= use_out_lu_d1_s;

				use_in_lu_s <= use_in_st_s;

				if slast_lbl_s = '1' then
					if use_in_st_s = C_INSTANCES - 1 then
						use_in_st_s <= (others => '0');
						last_lbled_s(0) <= '0';
					else
						use_in_st_s <= use_in_st_s + 1;
						last_lbled_s(to_integer(use_in_st_s + 1)) <= '0';
					end if;
					last_lbled_s(to_integer(use_in_st_s)) <= '1';
				end if;

				if st_rd_slast_out_s(to_integer(use_out_st_s)) = '1' then
					if use_out_st_s = C_INSTANCES - 1 then
						use_out_st_s <= (others => '0');
					else
						use_out_st_s <= use_out_st_s + 1;
					end if;
				end if;
				use_out_st_d1_s <= use_out_st_s;


				use_out_lu_s <= use_out_st_s;
			end if; -- rst
		end if; -- clk
	end process p_lu_switch;



end labeling_arc;

