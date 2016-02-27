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

		--! High if the output of at least one box is wrong
		error_out         : out STD_LOGIC_VECTOR(C_ERR_REF_SIZE - 1 downto 0)
	);
end entity labeling_box;

--! @brief arc description
--! @details more detailed description
architecture labeling_box_arc of labeling_box is

	--! State machine
	type T_STATE is (LABELING, BOXES);
	signal state             : T_STATE;

	signal stall_lbl_s       : STD_LOGIC;
	signal valid_lbl_out_s   : STD_LOGIC;
	signal last_lbl_s        : STD_LOGIC;
	signal label_s           : STD_LOGIC_VECTOR(T_LABEL'RANGE);
	signal box_rst_s         : STD_LOGIC;
	signal box_done_s        : STD_LOGIC;
	signal lbl_err_s         : STD_LOGIC;

	signal last_box_noti_s   : STD_LOGIC := '1';

	signal box_out_s         : T_BOX;

begin
	box_start_x_out     <= STD_LOGIC_VECTOR(box_out_s(T_X_START));
	box_start_y_out     <= STD_LOGIC_VECTOR(box_out_s(T_Y_START));
	box_end_x_out       <= STD_LOGIC_VECTOR(box_out_s(T_X_END));
	box_end_y_out       <= STD_LOGIC_VECTOR(box_out_s(T_Y_END));

	error_out(0)        <= lbl_err_s;

	p_pipe_state : process(clk_in) is
	begin
		if rising_edge(clk_in) then
			if rst_in = '1' then
				state <= LABELING;
				box_rst_s <= '1';
				box_done_out <= '0';
			else
				box_done_out <= '0';
				box_rst_s <= '0';

				case state is
					when LABELING =>
						if last_lbl_s = '1' then
							state <= BOXES;
						end if;

					when BOXES =>
						if box_done_s = '1' then
							state <= LABELING;
							box_done_out <= '1';
							box_rst_s <= '1';
						end if;

				end case;
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
		error_out         => lbl_err_s
	);


	boundbox : entity work.boundbox PORT MAP(
		clk_in            => clk_in,
		rst_in            => box_rst_s,
		stall_in          => stall_in,
		lbl_valid_in      => valid_lbl_out_s,
		label_in          => UNSIGNED(label_s),
		box_valid_out     => box_valid_out,
		box_out           => box_out_s,
		box_done_out      => box_done_s,
		error_out         => open,
		img_width_in      => UNSIGNED(img_width_in),
		img_height_in     => UNSIGNED(img_height_in)
	);

end labeling_box_arc;

