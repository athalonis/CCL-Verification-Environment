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
--! @file camif.vhd
--! @brief Simulates the interface of the camera to the PCCL
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2014-04-11
--! @details This is the top module for the verification of a interface with vsync and
--! hsync used by the camera to send data to the PCCL
--! For automatic exhaustive testing of the PCCL use the verificator.vhd
--------------------------------------------------------------------------------

library ieee;
--! Use numeric std
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;
use work.types.all;
use work.utils.all;

library pccl_lib;
use pccl_lib.all;
use pccl_lib.common.all;

entity camif is
	generic(
		--! Image width
		-- value from ccl_dut common.vhd
		G_IMG_WIDTH     : NATURAL := C_IMAGE_WIDTH;

		--! Image height
		-- value from ccl_dut common.vhd
		G_IMG_HEIGHT    : NATURAL := C_IMAGE_HEIGHT;

		--! Number of parallel pixels
		G_NO_PX         : NATURAL := no_pixels;

		--! Input width in bits
		G_IN_WIDTH      : NATURAL := 1024;
		G_FIFO_SIZE     : NATURAL := 64
	);
	port(
		--! Clock input
		clk_in          : in STD_LOGIC;
		clk_cam_in			: in STD_LOGIC;

		--! Reset input
		rst_in          : in STD_LOGIC;


		min_fll_lvl_in  : in UNSIGNED(15 downto 0);

		-- input of image data
		-- 16 MSB bits are used to save the number of valid pixels
	  -- only the last package of pixels can be smaller than 1024
		data_in         : in UNSIGNED(G_IN_WIDTH+16 - 1 downto 0);
		data_vl_in      : in STD_LOGIC;
		data_in_rdy_out : out STD_LOGIC;

		--! output data out
		data_out        : out UNSIGNED(63 downto 0);
		data_rdy_in     : in STD_LOGIC;
		data_vl_out     : out STD_LOGIC;

		--! error value
		error_out       : out UNSIGNED(0 to 5);

		--! high if image processing is completed
		done_out        : out STD_LOGIC;

		--vsync error injection
		vsync_err_in    : in T_CAM_ERR;
		--hsync error injection
		hsync_err_in    : in T_CAM_ERR;
		--px active error injection
		-- if value = 1 inserts a additional pixel before the given coordinate
		-- if value = 0 forces the active signal to zero for the given coordinate
		active_err_in   : in T_CAM_ERR

	);
end entity camif;

architecture camif_arc of camif is
	--! pccl_dut signals
	signal dut_fo_rdy_s    : STD_LOGIC;
	signal dut_hsync_s     : STD_LOGIC;
	signal dut_px_active_s : STD_LOGIC;
	signal dut_px_s        : UNSIGNED (0 to G_NO_PX-1);
	signal dut_rst_s       : STD_LOGIC;
	signal dut_vsync_s     : STD_LOGIC;
	signal dut_error_s		 : STD_LOGIC_VECTOR (error_out'range);
	signal dut_out_s       : STD_LOGIC_VECTOR (gdt_data_range);
	signal dut_out_vl_s    : STD_LOGIC;
	signal done_wait_s     : UNSIGNED(log2_ceil(C_DUT_EXTRA_CLKS+1)-1 downto 0);


	signal px_active_s     : STD_LOGIC;

	--! OUT FIFO signals
	signal fifo_out_in_s   : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
	signal fifo_out_in_vl_s: STD_LOGIC;
	signal fifo_out_full_s : STD_LOGIC;
	signal fifo_out_rd_s   : STD_LOGIC_VECTOR(63 downto 0);
	signal fifo_out_rd_nx_s: STD_LOGIC;
	signal fifo_out_empty_s: STD_LOGIC;

	--! FIFO signals
	signal fifo_rst_s      : STD_LOGIC;
	signal fifo_in_s       : UNSIGNED(G_IN_WIDTH - 1 downto 0);
	signal fifo_in_vl_s    : STD_LOGIC;
	signal fifo_full_s     : STD_LOGIC;
	signal fifo_rd_s       : UNSIGNED(G_NO_PX - 1 downto 0);
	signal fifo_rd_nxt_s   : STD_LOGIC;
	signal fifo_empty_s    : STD_LOGIC;
	--signal fifo_lvl_s      : UNSIGNED(log2_ceil(G_FIFO_SIZE) downto 0);

	signal fifo_as_rd_nxt_s: STD_LOGIC;
	signal fifo_as_full_s  : STD_LOGIC;
	signal fifo_as_empty_s : STD_LOGIC;
	signal fifo_as_pempty_s: STD_LOGIC;
	signal fifo_as_rd_s    : STD_LOGIC_VECTOR(15 downto 0);
	signal fifo_as_pthresh_s : STD_LOGIC_VECTOR(6 downto 0);
	signal fifo_as_wr_en_s : STD_LOGIC;
	signal fifo_as_rst_s   : STD_LOGIC;

	signal vl_pixel_s      : UNSIGNED(log2_ceil(C_IMAGE_HEIGHT * C_IMAGE_HEIGHT*2) downto 0);
	signal row_cnt_s       : UNSIGNED(log2_ceil(G_IMG_HEIGHT) downto 0);
	signal col_cnt_s       : UNSIGNED(log2_ceil(G_IMG_WIDTH) downto 0);

	signal int_err_s       : UNSIGNED(dut_error_s'range);

	type T_STATE is (WAITING_DATA, PROCESSING, DONE, DONE_WAIT, RESET);
	signal state_s         : T_STATE;
	signal state_dl1_s      : T_STATE;
	signal state_dl2_s      : T_STATE;

	signal active_err_d1_s : T_CAM_ERR;
	signal hsync_err_d1_s  : T_CAM_ERR;
	signal vsync_err_d1_s  : T_CAM_ERR;
	signal active_err_d2_s : T_CAM_ERR;
	signal hsync_err_d2_s  : T_CAM_ERR;
	signal vsync_err_d2_s  : T_CAM_ERR;

	signal active_err_s    : T_CAM_ERR;
	signal active_err_exe_s: unsigned(T_CAM_ERR'range);
	signal hsync_err_s     : T_CAM_ERR;
	signal vsync_err_s     : T_CAM_ERR;

	signal min_fll_lvl_d1_s : STD_LOGIC_VECTOR(fifo_as_pthresh_s'range);
	signal min_fll_lvl_d2_s : STD_LOGIC_VECTOR(fifo_as_pthresh_s'range);

begin

	-- store active, hsync, vsync error injection values on reset
	-- prevent metastable signals
	p_err_store : process (clk_in, clk_cam_in)
	begin
		if rising_edge(clk_in) then
			active_err_d1_s <= active_err_in;
			hsync_err_d1_s  <= hsync_err_in;
			vsync_err_d1_s  <= vsync_err_in;
		end if;
		if rising_edge(clk_cam_in) then
			active_err_d2_s <= active_err_d1_s;
			hsync_err_d2_s  <= hsync_err_d1_s;
			vsync_err_d2_s  <= vsync_err_d1_s;

			active_err_s <= active_err_d2_s;
			hsync_err_s  <= hsync_err_d2_s;
			vsync_err_s  <= vsync_err_d2_s;
		end if;
	end process;

	-- prevent metastable signal for fifo fill level threshold before start with processing pixels
	p_min_stable : process (clk_cam_in, clk_in)
	begin
		if rising_edge(clk_in) then
			min_fll_lvl_d1_s <= STD_LOGIC_VECTOR(min_fll_lvl_in(min_fll_lvl_d1_s'range));
		end if;
		if rising_edge(clk_cam_in) then
			min_fll_lvl_d2_s <= min_fll_lvl_d1_s;
			fifo_as_pthresh_s <= min_fll_lvl_d2_s;
		end if;
	end process p_min_stable;

	--! state machine generating the internal state
	--! states: WAITING_DATA -> the buffer has not reached the min_fll_lvl_in
	--!                         waiting for more data
	--!         PROCESSING   -> enough data in the fifo writing data to camera
	--!                         interface
	--!         RESET        -> start new image
	--!         DONE_WAIT    -> All pixels are send to the DUT waiting for all
	--!                         output data
	--!         DONE         -> All output data should be read
	p_state : process (rst_in, clk_cam_in)
	begin
		if rst_in = '0' then
			if rising_edge(clk_cam_in) then

				dut_rst_s <= '0';
				px_active_s <= '0';
				dut_vsync_s <= '0';
				dut_hsync_s <= '0';
				fifo_as_rst_s <= '0';
				fifo_as_rd_nxt_s <= '0';
				int_err_s <= int_err_s or unsigned(dut_error_s);

				case state_s is
					when WAITING_DATA =>
						if fifo_as_pempty_s = '0' then --fifo_lvl_s >= min_fll_lvl_in then
							state_s <= PROCESSING;
							fifo_as_rd_nxt_s <= '1';
						end if;

					when PROCESSING =>

						if fifo_as_empty_s = '1' then  --if vl_pixel_s < G_NO_PX then --fifo_lvl_s = 0 then
							state_s <= WAITING_DATA;
							if row_cnt_s = G_IMG_HEIGHT then
								state_s <= DONE_WAIT;
							end if;
						else

							px_active_s <= '1';

							fifo_as_rd_nxt_s <= '1';

							if col_cnt_s = 0 then
								dut_hsync_s <= '1';
								if row_cnt_s = 0 then
									dut_vsync_s <= '1';
								end if;
							end if;

							col_cnt_s <= col_cnt_s + G_NO_PX;
							if col_cnt_s = G_IMG_WIDTH-G_NO_PX then
								row_cnt_s <= row_cnt_s + 1;
								col_cnt_s <= (others => '0');
							end if;


							-- active overwrite
							for i in active_err_s'range loop
								if active_err_s(i).row = row_cnt_s and
								active_err_s(i).col = col_cnt_s
								then
									if active_err_s(i).val = '1' and active_err_exe_s(i) = '0' then
										row_cnt_s <= row_cnt_s;
										col_cnt_s <= col_cnt_s;
										dut_hsync_s <= '0';
										dut_vsync_s <= '0';
										fifo_as_rd_nxt_s <= '0';
										active_err_exe_s(i) <= '1';
									elsif active_err_s(i).val = '0' then
										px_active_s <= '0';
									end if;
								end if;
							end loop;

							-- hsync overwrite
							for i in hsync_err_s'range loop
								if hsync_err_s(i).row = row_cnt_s and
								hsync_err_s(i).col = col_cnt_s
								then
									dut_hsync_s <= hsync_err_s(i).val;
								end if;
							end loop;

							-- vsync overwrite
							for i in hsync_err_s'range loop
								if vsync_err_s(i).row = row_cnt_s and
								vsync_err_s(i).col = col_cnt_s
								then
									dut_vsync_s <= vsync_err_s(i).val;
								end if;
							end loop;
						end if;



					when DONE_WAIT =>
						if done_wait_s = 1 then
							state_s <= DONE;
						end if;
						done_wait_s <= done_wait_s - 1;
						fifo_as_rst_s <= '1';

					when DONE =>
						if done_wait_s = 0 then
							state_s <= WAITING_DATA;
						end if;
						done_wait_s <= to_unsigned(C_DUT_EXTRA_CLKS+1, done_wait_s'length);
						done_wait_s <= done_wait_s - 1;
						row_cnt_s <= (others => '0');
						col_cnt_s <= (others => '0');
						dut_hsync_s <= '0';
						fifo_as_rst_s <= '1';
						active_err_exe_s <= (others => '0');

					when RESET =>
						state_s <= WAITING_DATA;
						done_wait_s <= to_unsigned(C_DUT_EXTRA_CLKS+1, done_wait_s'length);
						row_cnt_s <= (others => '0');
						col_cnt_s <= (others => '0');
						dut_hsync_s <= '0';
						dut_rst_s <= '1';
						fifo_as_rst_s <= '1';
						int_err_s <= (others => '0');
						active_err_exe_s <= (others => '0');
				end case;
			end if;
		else
			state_s <= RESET;
			done_wait_s <= to_unsigned(C_DUT_EXTRA_CLKS+1, done_wait_s'length);
			row_cnt_s <= (others => '0');
			col_cnt_s <= (others => '0');
			dut_hsync_s <= '0';
			dut_rst_s <= '1';
			fifo_as_rst_s <= '1';
			int_err_s <= (others => '0');
			active_err_exe_s <= (others => '0');

		end if;
	end process p_state;

	p_rst_fifo : process (state_s)
	begin
		case state_s is
			when RESET =>
				fifo_rst_s <= '1';
			when DONE_WAIT =>
				fifo_rst_s <= '1';
			when others =>
				fifo_rst_s <= '0';
		end case;
	end process p_rst_fifo;


	--! process for generating delay state signal
	p_state_dl : process (clk_cam_in, clk_in)
	begin
		if rising_edge(clk_cam_in) then
			state_dl1_s <= state_s;
		end if;
		if rising_edge(clk_in) then
			state_dl2_s <= state_dl1_s;
		end if;
	end process p_state_dl;


	fifo_rd_nxt_s <= not fifo_empty_s;
	fifo_as_wr_en_s  <= '1' when fifo_empty_s = '0' and vl_pixel_s > 0 else '0';

	--! counts the valid pixels int the buffer
	p_vl_px_cnt : process (clk_in, rst_in)
	begin
		if rst_in = '1' then
			vl_pixel_s <= (others => '0');
		else
			if rising_edge(clk_in) then
				if fifo_rd_nxt_s = '1' and vl_pixel_s >= G_NO_PX then --state_s = PROCESSING then
					vl_pixel_s <= vl_pixel_s - G_NO_PX;
				end if;
				if data_vl_in = '1' then
					if fifo_rd_nxt_s = '1' and vl_pixel_s >= G_NO_PX then --state_s = PROCESSING then
						vl_pixel_s <= resize(vl_pixel_s + 8*data_in(data_in'high downto
													data_in'high-16+1) - G_NO_PX, vl_pixel_s'length);
					else
						vl_pixel_s <= resize(vl_pixel_s + 8*data_in(data_in'high downto
													data_in'high-16+1), vl_pixel_s'length);
					end if;
				end if;
			end if;--clk
		end if;--rst
	end process p_vl_px_cnt;

	error_out <= int_err_s;
	done_out <= '1' when state_dl2_s = DONE and state_dl2_s /= DONE and rst_in = '0' else '0';
	dut_px_s <= unsigned(fifo_as_rd_s);

	-- convert to unsigned
	dut_fo_rdy_s <= not fifo_out_full_s;
	data_vl_out <= not fifo_out_empty_s;

	fifo_out_in_s(dut_out_s'range) <= dut_out_s;
	data_out <= unsigned(fifo_out_rd_s);

	fifo_out : entity work.out_fifo
  port map (
    rst    => rst_in,
    wr_clk => clk_cam_in,
    rd_clk => clk_in,
    din    => fifo_out_in_s,
    wr_en  => dut_out_vl_s,
    rd_en  => data_rdy_in,
    dout   => fifo_out_rd_s,
    full   => fifo_out_full_s,
    empty  => fifo_out_empty_s
  );

	dut_px_active_s <= px_active_s;-- and not fifo_as_empty_s;

	pccl_dut : entity pccl_lib.pccl_top
  generic map(
		add_cu => False
	)
	port map (
		clk          => clk_cam_in,
		fo_rdy       => dut_fo_rdy_s,
		hsync        => dut_hsync_s,
		pixel_active => dut_px_active_s,
		pixel_clk    => clk_cam_in,
		pixel_data   => std_logic_vector(dut_px_s),
		res          => dut_rst_s,
		vsync        => dut_vsync_s,
		error_code   => dut_error_s,
		fo           => dut_out_s,
		fo_valid     => dut_out_vl_s
	);

	-- the first 16 bits are used to indicate the number of valid bytes in data_in
	fifo_in_s <= data_in(data_in'high-16 downto 0);
	fifo_in_vl_s <= data_vl_in;

	data_in_rdy_out <= not fifo_full_s;

	in_async_fifo : entity work.in_fifo
  port map (
    rst        => fifo_as_rst_s,
    wr_clk     => clk_in,
    rd_clk     => clk_cam_in,
    din        => std_logic_vector(fifo_rd_s),
    wr_en      => fifo_as_wr_en_s,
    rd_en      => fifo_as_rd_nxt_s,
    dout       => fifo_as_rd_s,
    full       => fifo_as_full_s,
    empty      => fifo_as_empty_s,
    prog_empty_thresh => fifo_as_pthresh_s,
    prog_empty => fifo_as_pempty_s
  );



	in_fifo : entity work.fifo_asym
	generic map(
		G_SIZE          => G_FIFO_SIZE,
		G_OUT_WORD_WIDTH=> G_NO_PX,
		G_IN_MUL_WIDTH  => G_IN_WIDTH/G_NO_PX,
		G_ALMOST_EMPTY  => 1,
		G_ALMOST_FULL   => G_FIFO_SIZE - 1,
		G_FWFT          => true
	)
	port map(
		rst_in          => fifo_rst_s,
		clk_in          => clk_in,

		--! Data input
		wr_d_in         => fifo_in_s,
		wr_valid_in     => fifo_in_vl_s,
		almost_full_out => open,
		full_out        => fifo_full_s,

		--! Data output
		rd_d_out        => fifo_rd_s,
		rd_next_in      => fifo_rd_nxt_s,
		almost_empty_out=> open,
		empty_out       => fifo_empty_s,

		--! Fill level of fifo
		fill_lvl_out    => open --fifo_lvl_s
	);


end architecture camif_arc;



