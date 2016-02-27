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

		error_out         : out STD_LOGIC
	);
end entity labeling;

--! @brief arc description
--! @details more detailed description
architecture labeling_arc of labeling is
	constant C_INSTANCES      : natural := 3;

	type T_STATE is (LABLING_P1, WAIT_LOOKUP, LABLING_P2, PRERESET, RESET);
	Signal state_s : T_STATE;

	type T_LABEL_VECTOR is array (C_INSTANCES - 1 downto 0) of T_LABEL;
	type T_EQUI_VECTOR is array (C_INSTANCES - 1 downto 0) of T_EQUI;

	-- Singals in generate statement
	Signal lu_next_lbl_out_s  : T_LABEL;
	Signal lu_gen_lable_in_s  : STD_LOGIC;
	Signal lu_equi_in_s       : T_EQUI;
	Signal lu_ready_out_s     : STD_LOGIC;
	Signal lu_lbl_out_s       : T_LABEL;
	Signal lu_last_s          : STD_LOGIC;

	Signal st_px_valid_in_s   : STD_LOGIC;
	Signal st_rd_px_in_s      : STD_LOGIC;
	Signal st_rd_px_out_s     : STD_LOGIC;
	Signal st_rd_valid_out_s  : STD_LOGIC;
	Signal st_rd_last_out_s   : STD_LOGIC;
	Signal st_rd_slast_out_s  : STD_LOGIC;

	Signal rst_lbl_cnt_s      : STD_LOGIC;

	Signal stall_out_s        : STD_LOGIC;

	Signal last_lbl_s         : STD_LOGIC;
	Signal slast_lbl_s        : STD_LOGIC;

	Signal cnt_lbl2_s         : T_LABEL;
	Signal inc_lbl2_s         : STD_LOGIC;

	Signal next_gen_in_s      : T_LABEL;
	Signal gen_lable_out_s    : STD_LOGIC;
	Signal equi_out_s         : T_EQUI;
	Signal equi_valid_out_s   : STD_LOGIC;

	Signal p2_lbl_s           : T_LABEL;

	Signal rst_lbl_s          : STD_LOGIC;
	Signal px_lbl_in_s        : STD_LOGIC;
	Signal px_lbl_vl_in_s     : STD_LOGIC;
	Signal lbl_out_s          : T_LABEL;
	Signal lbl_vl_out_s       : STD_LOGIC;
	Signal rst_lu_s           : STD_LOGIC;
	Signal lu_equi_in_vl_s    : STD_LOGIC;
	Signal rst_px_st_s        : STD_LOGIC;


begin
	stall_out <= '0';

	--! Finite State Machine for internal state
	p_state : process (clk_in, rst_in) is
	begin
		if rst_in = '1' then

			state_s <= LABLING_P1;

		elsif rising_edge(clk_in) then
			case state_s is

				when LABLING_P1 =>
					if last_lbl_s = '1' then
						state_s <= WAIT_LOOKUP;
					end if;

				when WAIT_LOOKUP =>
					if lu_ready_out_s = '1' then
						state_s <= LABLING_P2;
					end if;

				when LABLING_P2 =>
					if st_rd_last_out_s = '1' then
						state_s <= PRERESET;
					end if;

				when PRERESET =>
					state_s <= RESET;

				when RESET =>
					state_s <= LABLING_P1;

			end case;
		end if; -- clk/rst

	end process p_state;


	p_state_signals : process (state_s, rst_in, px_in,
	                           data_valid_in, lu_next_lbl_out_s,
														 gen_lable_out_s, equi_out_s,
														 equi_valid_out_s, st_rd_px_out_s,
														 cnt_lbl2_s, lbl_out_s, lu_lbl_out_s,
														 st_rd_valid_out_s
		) is
	begin

		-- default values
		rst_lbl_s <= '0';
		rst_lbl_cnt_s <= '0';
		rst_lu_s <= '0';
		px_lbl_in_s <= '-';
		next_gen_in_s <= (others => '-');
		lu_gen_lable_in_s <= '0';
		lu_equi_in_s <= (others => (others => '-'));
		lu_equi_in_vl_s <= '0';
		px_lbl_vl_in_s <= '0';
		inc_lbl2_s <= '0';
		p2_lbl_s <=  (others => '-');
		label_out <= (others => '-');
		last_lbl_out <= '0';
		rst_px_st_s <= '0';
		st_rd_px_in_s <= '0';
		lu_last_s <= '0';
		st_px_valid_in_s <= '0';

		case state_s is
			when LABLING_P1 =>
				px_lbl_in_s <= px_in;
				px_lbl_vl_in_s <= data_valid_in;
				next_gen_in_s <= lu_next_lbl_out_s;
				lu_gen_lable_in_s <= gen_lable_out_s;
				lu_equi_in_s <= equi_out_s;
				lu_equi_in_vl_s <= equi_valid_out_s;
				st_px_valid_in_s <= data_valid_in;

			when WAIT_LOOKUP =>
				rst_lbl_cnt_s <= '1';
				rst_lbl_s <= '1';

			when LABLING_P2 =>
				px_lbl_in_s <= st_rd_px_out_s;
				px_lbl_vl_in_s <= st_rd_valid_out_s;
				next_gen_in_s <= cnt_lbl2_s;
				inc_lbl2_s <= gen_lable_out_s;
				p2_lbl_s <= lbl_out_s;
				st_rd_px_in_s <= '1';
				label_out <= std_logic_vector(lu_lbl_out_s);

			when PRERESET =>
				px_lbl_in_s <= st_rd_px_out_s;
				px_lbl_vl_in_s <= st_rd_valid_out_s;
				next_gen_in_s <= cnt_lbl2_s;
				inc_lbl2_s <= gen_lable_out_s;
				p2_lbl_s <= lbl_out_s;
				label_out <= std_logic_vector(lu_lbl_out_s);


			when RESET =>
				rst_lbl_s <= '1';
				rst_lu_s <= '1';
				rst_lu_s <= '1';
				rst_px_st_s <= '1';

				label_out <= std_logic_vector(lu_lbl_out_s);
				last_lbl_out <= '1';

		end case;


		if rst_in = '1' then
			rst_lbl_s <= '1';
			rst_lu_s <= '1';
			rst_lu_s <= '1';
			rst_px_st_s <= '1';
		end if;

	end process;


	--!brief delay the data_valid_out by one
	p_vl_d : process (clk_in, rst_in) is
	begin
		if rst_in = '1' then
			lbl_vl_out_s <= '0';
			data_valid_out <= '0';

		elsif rising_edge(clk_in) then
			lbl_vl_out_s <= px_lbl_vl_in_s;
			data_valid_out <= '0';

			if state_s = LABLING_P2 or state_s = PRERESET then
				-- if labling pass2 the output can be valid
				data_valid_out <= lbl_vl_out_s;
			end if;

		end if;
	end process;




	labeling : entity work.labeling_p1 PORT MAP(
		clk_in          => clk_in,
		rst_in          => rst_lbl_s,
		stall_out       => stall_out_s,
		stall_in        => stall_in,
		px_in           => px_lbl_in_s,
		px_valid_in     => px_lbl_vl_in_s,
		img_width_in    => UNSIGNED(img_width_in),
		img_height_in   => UNSIGNED(img_height_in),
		next_lable_in   => next_gen_in_s,
		gen_lable_out   => gen_lable_out_s,
		equi_out        => equi_out_s,
		equi_valid_out  => equi_valid_out_s,
		last_lbl_out    => last_lbl_s,
		slast_lbl_out   => slast_lbl_s,
		label_out       => lbl_out_s
	);


	lookup_table : entity work.lookup_table PORT MAP(
		clk_in          => clk_in,
		rst_in          => rst_lu_s,
		stall_out       => open,
		next_lable_out  => lu_next_lbl_out_s,
		gen_lable_in    => lu_gen_lable_in_s,
		equi_in         => lu_equi_in_s,
		equi_valid_in   => lu_equi_in_vl_s,
		lookup_ready_out=> lu_ready_out_s,
		lookup_in       => p2_lbl_s,
		lookup_out      => lu_lbl_out_s,
		last_look_up_in => lu_last_s,
		error_out       => error_out
	);

	px_store : entity work.px_storage port map(
		clk_in          => clk_in,
		rst_in          => rst_px_st_s,
		img_width_in    => UNSIGNED(img_width_in),
		img_height_in   => UNSIGNED(img_height_in),
		wr_px_in        => px_in,
		wr_valid_in     => st_px_valid_in_s,
		rd_px_in        => st_rd_px_in_s,
		rd_px_out       => st_rd_px_out_s,
		rd_valid_out    => st_rd_valid_out_s,
		rd_last_px_out  => st_rd_last_out_s,
		rd_slast_px_out => st_rd_slast_out_s
	);

	lbl_cnt_p2 : entity work.counter PORT MAP(
		clk_in          => clk_in,
		rst_in          => rst_lbl_cnt_s,
		inc_in          => inc_lbl2_s,
		cnt_out         => cnt_lbl2_s
	);

end labeling_arc;

