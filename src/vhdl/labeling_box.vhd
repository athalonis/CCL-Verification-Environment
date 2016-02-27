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
--! @file labeling_box.vhd
--! @brief Connected Component Labeling two pass and computation of bound boxes
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

--! The two pass algorithem implemented in labeling.vhd
--! will be run and the output of labels used to compute
--! the bound boxes with the boundbox.vhd.
--! The boundbox has a internal heap to store boundboxes
--! if the memory is to small the the error signal will
--! rise and the output of the boxes is incompleat

entity labeling_box is
	generic(
		--! Max image width means 2^...
		G_MAX_IMG_WIDTH   : NATURAL := C_MAX_IMAGE_WIDTH;

		--! Max image width means 2^...
		G_MAX_IMG_HEIGHT  : NATURAL := C_MAX_IMAGE_HEIGHT

	);
	port(
		--! Clock input
		clk_in            : in STD_LOGIC;
		--! Reset input
		rst_in            : in STD_LOGIC;

		--! Output if the labeling stalls
		stall_out         : out STD_LOGIC;

		--! Input to stall the output of the labeling
		stall_in          : in STD_LOGIC;

		--! input data are valid
		data_valid_in     : in STD_LOGIC;

		--! Pixel input 0 => background, 1=> foreground
		px_in             : in STD_LOGIC;

		--! width of the image at the input
		img_width_in      : in STD_LOGIC_VECTOR(log2_ceil(G_MAX_IMG_WIDTH) downto 0);

		--! height of the image
		img_height_in     : in STD_LOGIC_VECTOR(log2_ceil(G_MAX_IMG_HEIGHT) downto 0);

		--! High if the boundbox output valid
		box_valid_out     : out STD_LOGIC;

		--! output of bound box upper x
		box_start_x_out   : out STD_LOGIC_VECTOR(log2_ceil(G_MAX_IMG_WIDTH) - 1 downto 0);

		--! output of bound box upper y
		box_start_y_out   : out STD_LOGIC_VECTOR(log2_ceil(G_MAX_IMG_HEIGHT) - 1 downto 0);

		--! output of bound box lower x
		box_end_x_out     : out STD_LOGIC_VECTOR(log2_ceil(G_MAX_IMG_WIDTH) - 1 downto 0);

		--! output of bound box lower y
		box_end_y_out     : out STD_LOGIC_VECTOR(log2_ceil(G_MAX_IMG_HEIGHT) - 1 downto 0);

		--! high if all boxes are computed
		box_done_out      : out STD_LOGIC;

		--! Error Type out
		error_type_out    : out STD_LOGIC_VECTOR(C_ERR_REF_SIZE - 1 downto 0)
	);
end entity labeling_box;

--! @brief arc description
--! @details more detailed description
architecture labeling_box_arc of labeling_box is
	--! How many boxing instances should be provided
	constant C_BOX_INSTANCES : NATURAL := 2;

	type T_BOXES is array (C_BOX_INSTANCES - 1 downto 0) of T_BOX;

	--! State machine
	type T_STATE is (IDLE, LABELING, BOXES, FIFO_READ);
	type T_STATES is array(C_BOX_INSTANCES - 1 downto 0) of T_STATE;
	signal pipe_state        : T_STATES;

	signal stall_lbl_s       : STD_LOGIC;
	signal data_valid_lbl_s  : STD_LOGIC_VECTOR(C_BOX_INSTANCES-1 downto 0);
	signal valid_lbl_out_s   : STD_LOGIC;
	signal last_lbl_s        : STD_LOGIC;
	signal label_s           : STD_LOGIC_VECTOR(T_LABEL'RANGE);
	signal box_rst_s         : STD_LOGIC_VECTOR(C_BOX_INSTANCES-1 downto 0);
	signal box_done_s        : STD_LOGIC_VECTOR(C_BOX_INSTANCES-1 downto 0);

	signal ff_box_out_s      : T_BOXES;
	signal ff_box_in_s       : T_BOXES;
	signal ff_wr_valid_s     : STD_LOGIC_VECTOR(C_BOX_INSTANCES-1 downto 0);
	signal ff_rd_next_s      : STD_LOGIC_VECTOR(C_BOX_INSTANCES-1 downto 0);
	signal ff_empty_s        : STD_LOGIC_VECTOR(C_BOX_INSTANCES-1 downto 0);

	signal err_lbl_s         : STD_LOGIC_VECTOR(C_BOX_INSTANCES-1 downto 0);

	signal box_out_s         : T_BOX;

	--! instance to use for first stage input
	signal use_st_1_in_s     : unsigned(log2_ceil(C_BOX_INSTANCES)-1 downto 0);
	signal use_st_1_out_s    : unsigned(log2_ceil(C_BOX_INSTANCES)-1 downto 0);

	--! which boundbox should be used for input next
	signal next_input_s      : unsigned(log2_ceil(C_BOX_INSTANCES)-1 downto 0);

	function inst_inc (
		inst : in unsigned)
		return unsigned
	is
		variable ret_val : unsigned(log2_ceil(C_BOX_INSTANCES)-1 downto 0);
	begin
		if inst = C_BOX_INSTANCES - 1 then
			ret_val := (others => '0');
		else
			ret_val := inst + 1;
		end if;

		return ret_val;
	end function inst_inc;

begin
	box_start_x_out     <= STD_LOGIC_VECTOR(box_out_s(T_X_START));
	box_start_y_out     <= STD_LOGIC_VECTOR(box_out_s(T_Y_START));
	box_end_x_out       <= STD_LOGIC_VECTOR(box_out_s(T_X_END));
	box_end_y_out       <= STD_LOGIC_VECTOR(box_out_s(T_Y_END));

	box_out_s <= ff_box_out_s(to_integer(use_st_1_out_s));
	error_type_out(0) <= '0';

	p_valid_out : process(clk_in) is
	begin
		if rising_edge(clk_in) then
			if pipe_state(to_integer(use_st_1_out_s)) = FIFO_READ and
			ff_empty_s(to_integer(use_st_1_out_s)) = '0'then
				box_valid_out <= '1';
			else
				box_valid_out <= '0';
			end if;
		end if;
	end process;



	p_pipe_state : process(clk_in) is
		variable next_input_sel_v : boolean;
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				pipe_state <= (others => IDLE);
				pipe_state(0) <= LABELING;
				next_input_s <= to_unsigned(1, next_input_s'length);
				use_st_1_out_s <= (others => '0');
				use_st_1_in_s <= (others => '0');
				box_rst_s <= (others => '1');
				box_done_out <= '0';
			else
				next_input_sel_v := false;
				box_done_out <= '0';
				for i in C_BOX_INSTANCES - 1 downto 0 loop
					box_rst_s(i) <= '0';

					case pipe_state(i) is
						when IDLE =>
							if next_input_s = i and last_lbl_s = '1' then
								pipe_state(i) <= LABELING;
								next_input_s <= inst_inc(next_input_s);
							end if;

						when LABELING =>
							if last_lbl_s = '1' then
								pipe_state(i) <= BOXES;
								use_st_1_in_s <= next_input_s;
							end if;

						when BOXES =>
							if box_done_s(i) = '1' then
								pipe_state(i) <= FIFO_READ;
								box_rst_s(i) <= '1';
							end if;

						when FIFO_READ =>
							if ff_empty_s(i) = '1' then
								pipe_state(i) <= IDLE;
								use_st_1_out_s <= inst_inc(use_st_1_out_s);
								box_done_out <= '1';
							end if;
					end case;
				end loop;
			end if; -- rst
		end if; --clk
	end process p_pipe_state;

	my_labeling : entity work.labeling PORT MAP(
		clk_in            => clk_in,
		rst_in            => rst_in,
		stall_out         => stall_lbl_s,
		stall_in					=> stall_in,
		px_in             => px_in,
		img_width_in      => img_width_in,
		img_height_in     => img_height_in,
		data_valid_out    => valid_lbl_out_s,
		data_valid_in     => data_valid_in,
		last_lbl_out      => last_lbl_s,
		label_out         => label_s,
		error_out					=> error_lbl_s
	);


	gen_boxes : for i in C_BOX_INSTANCES - 1 downto 0 generate
		boundbox : entity work.boundbox PORT MAP(
			clk_in            => clk_in,
			rst_in            => box_rst_s(i),
			stall_in          => stall_in,
			lbl_valid_in      => data_valid_lbl_s(i),
			label_in          => UNSIGNED(label_s),
			box_valid_out     => ff_wr_valid_s(i),
			box_out           => ff_box_in_s(i),
			box_done_out      => box_done_s(i),
			error_out         => open,
			img_width_in      => UNSIGNED(img_width_in),
			img_height_in     => UNSIGNED(img_height_in)
		);

		box_fifo : entity work.fifo
		GENERIC MAP(
			G_SIZE           => G_MAX_IMG_WIDTH/2*G_MAX_IMG_HEIGHT/2,
			G_WORD_WIDTH     => T_BOX'LENGTH,
			G_ALMOST_EMPTY   => 1,
			G_ALMOST_FULL    => 64 - 1
		)
		PORT MAP(
			rst_in           => rst_in,
			clk_in           => clk_in,

			wr_d_in          => ff_box_in_s(i),
			wr_valid_in      => ff_wr_valid_s(i),
			almost_full_out  => open,
			full_out         => open,

			rd_d_out         => ff_box_out_s(i),
			rd_next_in       => ff_rd_next_s(i),
			almost_empty_out => open,
			empty_out        => ff_empty_s(i)
		);

		data_valid_lbl_s(i) <= valid_lbl_out_s when i = use_st_1_in_s else '0';
		ff_rd_next_s(i) <= not ff_empty_s(i) when
											 pipe_state(to_integer(use_st_1_out_s)) = FIFO_READ
										 else '0';

		end generate gen_boxes;
	end labeling_box_arc;

