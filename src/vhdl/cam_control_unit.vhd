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
--! @file cam_control_unit.vhd
--! @brief Control Unit for the camera interface
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2014-04-25
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;
use work.utils.all;

library pccl_lib;
use pccl_lib.common.all;

entity cam_control_unit is
	generic(
		G_MAX_DATA_SIZE : natural := C_MAX_SEND_DATA;
		--! Number of Comparators
		G_COMP_INST     : NATURAL := C_COMP_INST;

		--! Image width
		-- value from ccl_dut common.vhd
		G_IMG_WIDTH     : NATURAL := C_IMAGE_WIDTH;

		--! Image height
		-- value from ccl_dut common.vhd
		G_IMG_HEIGHT    : NATURAL := C_IMAGE_HEIGHT;

		--! Error Storage
		G_ERR_SIZE      : NATURAL := C_ERR_BUF_SIZE

	);
	port (
		-- System signals
		------------------
		rst_in             : in std_logic; -- asynchronous reset
		rx_clk_in          : in std_logic;
		clk_dut_in         : in std_logic;

		-- Decoded data
	  -- read/write command
		dec_valid_in       : in std_logic;
		write_in           : in std_logic;
		type_in            : in unsigned(15 downto 0);
		id_in              : in unsigned(15 downto 0);
		length_in          : in unsigned(15 downto 0);
		data_in            : in unsigned(G_MAX_DATA_SIZE - 1 downto 0);
		header_error_in    : in std_logic;

		-- Encoder data
		enc_valid_out      : out std_logic;
		type_out           : out unsigned(15 downto 0);
		id_out             : out unsigned(15 downto 0);
		length_out         : out unsigned(15 downto 0);
		data_out           : out unsigned(G_MAX_DATA_SIZE - 1 downto 0);

		run_out            : out std_logic

);
end cam_control_unit;

architecture cam_control_unit_arc of cam_control_unit is
	CONSTANT C_RESTART_WAIT      : natural := 3;
	CONSTANT C_STIM_SIZE         : natural := G_IMG_WIDTH*G_IMG_HEIGHT;
	CONSTANT C_STIM_SIZE_BYTE    : natural := div_ceil(C_STIM_SIZE, 8);
	CONSTANT C_BOX_SIZE          : natural := 2*(log2_ceil(G_IMG_WIDTH)+log2_ceil(G_IMG_HEIGHT));
--log2_ceil(C_MAX_IMAGE_HEIGHT)+1+log2_ceil(C_MAX_IMAGE_WIDTH)+1
	CONSTANT C_BOX_SIZE_BYTE     : natural := div_ceil(C_BOX_SIZE, 8);
	CONSTANT C_ERR_FIFO_WIDTH    : natural := 6;
	CONSTANT C_ERR_FI_LV_SIZE    : natural := log2_ceil(G_ERR_SIZE)+1;
	CONSTANT C_ERR_FI_LV_BYTE    : natural := div_ceil(C_ERR_FI_LV_SIZE, 8);

	--! length of error injection package
	CONSTANT C_ERR_PKG_LEN       : natural := div_ceil(T_CAM_ERR'length *	(log2_ceil(C_MAX_IMAGE_HEIGHT+1)+log2_ceil(C_MAX_IMAGE_WIDTH+1)+1),8);

	CONSTANT C_TYP_ACK           : unsigned(15 downto 0) := x"0001";
	CONSTANT C_TYP_NACK          : unsigned(15 downto 0) := x"0002";
	CONSTANT C_TYP_HW_CFG        : unsigned(15 downto 0) := x"0003";
	CONSTANT C_TYP_STATUS        : unsigned(15 downto 0) := x"0004";
	CONSTANT C_TYP_RESET         : unsigned(15 downto 0) := x"0007";
	CONSTANT C_TYP_SEND_PX       : unsigned(15 downto 0) := x"000E";
	CONSTANT C_TYP_SEND_BOX      : unsigned(15 downto 0) := x"000F";
	CONSTANT C_TYP_SET_FLL_LVL   : unsigned(15 downto 0) := x"0010";
	CONSTANT C_TYP_SET_ACT_ERR   : unsigned(15 downto 0) := x"0011";
	CONSTANT C_TYP_SET_HSY_ERR   : unsigned(15 downto 0) := x"0012";
	CONSTANT C_TYP_SET_VSY_ERR   : unsigned(15 downto 0) := x"0013";

	type T_RX_STATE is (NOP, ACK, NACK, HEAD_ERR, HW_CFG, STATUS,
	                    RESET, SEND_PX, SET_FLL_LVL,
											SET_ACT_ERR, SET_HSY_ERR, SET_VSY_ERR, SEND_OUT,
											SEND_OUT_LAST, UNKNOWN);
	signal rx_state_s : T_RX_STATE;


	--! verifier state
	type T_INT_STATE is (RESTART, PROCESSING, DONE);
	signal int_state_s    : T_INT_STATE;

	--! internal signals
	signal rst_exec_s     : std_logic := '0';
	signal rst_prepare_s	: std_logic := '0';
	signal restart_cnt_s  : unsigned(log2_ceil(C_RESTART_WAIT+1)-1 downto 0);

	--! camif signals
	Signal cam_rst_s         : STD_LOGIC;
	Signal cam_min_fll_lvl_s : UNSIGNED(15 downto 0);
	Signal cam_di_s          : UNSIGNED(G_MAX_DATA_SIZE+16 - 1 downto 0);
	Signal cam_di_vl_s       : STD_LOGIC;
	Signal cam_di_ry_s       : STD_LOGIC;
	Signal cam_do_s          : UNSIGNED(63 downto 0);
	Signal cam_do_ry_s       : STD_LOGIC;
	Signal cam_do_vl_s       : STD_LOGIC;
	Signal cam_err_s         : UNSIGNED(5 downto 0);
	Signal cam_done_s        : STD_LOGIC;

	--! Error injection registers
	signal active_err_s      : T_CAM_ERR;
	signal hsync_err_s       : T_CAM_ERR;
	signal vsync_err_s       : T_CAM_ERR;

	--! Signals for output fifo
	signal out_fifo_rst_s    : STD_LOGIC;
	signal out_fifo_full_s   : STD_LOGIC;
	signal out_fifo_fill_s   : UNSIGNED(6 downto 0);
	signal out_fifo_di_s     : UNSIGNED(63 downto 0) := (others => '0');
	signal out_fifo_do_s     : UNSIGNED(1023 downto 0);
	signal out_fifo_do_vl_s  : STD_LOGIC;
	signal out_fifo_ack_s    : STD_LOGIC;

	--! Is the output fifo flushed?
	signal out_fifo_flu_s    : STD_LOGIC; 

	signal pkg_cnt_s         : unsigned(id_out'range);

	procedure str_unsigned
	(str : string;
	 signal data : out unsigned;
	 signal data_valid : out unsigned) is
	begin
		for i in str'range loop
			data(data'high-(i-1)*8 downto data'high-(i-1)*8-7) <=
			to_unsigned(character'pos(str(i)), 8);
		end loop;
		data_valid <= to_unsigned(str'length, data_valid'length);
	end procedure str_unsigned;

	procedure hw_cfg_status(
		signal hw_cfg_out     : out unsigned(G_MAX_DATA_SIZE-1 downto 0);
		signal hw_cfg_len_out : out unsigned(15 downto 0);
	  instances             : in  natural)
	is
		variable hw_cfg     : unsigned(G_MAX_DATA_SIZE-1 downto 0);
		variable hw_cfg_len : natural := 0;
		variable pos        : natural := G_MAX_DATA_SIZE-1;
		variable tmp        : natural;
	begin
		--HW-Version (4 Bytes -> hg revision)
		hw_cfg(pos downto pos - (4*8-1)) := to_unsigned(C_VERSION, 4*8);
		hw_cfg_len := hw_cfg_len + 4;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		-- MAX_DATA_LENGTH (2 Bytes)
		hw_cfg(pos downto pos - (2*8-1)) := to_unsigned(G_MAX_DATA_SIZE, 2*8);
		hw_cfg_len := hw_cfg_len + 2;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	--length of max img_width (1 byte)
		tmp := div_ceil(log2_ceil(G_IMG_WIDTH), 8);
		hw_cfg(pos downto pos - (1*8-1)) := to_unsigned(tmp, 1*8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	-- max img_width
		hw_cfg(pos downto pos - (tmp*8-1)) := to_unsigned(C_MAX_IMAGE_WIDTH, tmp*8);
		hw_cfg_len := hw_cfg_len + tmp;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		-- img_width
		hw_cfg(pos downto pos - (tmp*8-1)) := to_unsigned(C_IMAGE_WIDTH, tmp*8);
		hw_cfg_len := hw_cfg_len + tmp;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	--length of max img_height (1 byte)
		tmp := div_ceil(log2_ceil(C_MAX_IMAGE_HEIGHT), 8);
		hw_cfg(pos downto pos - (1*8-1)) := to_unsigned(tmp, 1*8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	--max img_height
		hw_cfg(pos downto pos - (tmp*8-1)) := to_unsigned(C_MAX_IMAGE_HEIGHT, tmp*8);
		hw_cfg_len := hw_cfg_len + tmp;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	--img_height
		hw_cfg(pos downto pos - (tmp*8-1)) := to_unsigned(C_IMAGE_HEIGHT, tmp*8);
		hw_cfg_len := hw_cfg_len + tmp;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		--length of box_size (1 byte)
		tmp := div_ceil(log2_ceil(log2_ceil(C_MAX_IMAGE_HEIGHT)+1+log2_ceil(C_MAX_IMAGE_WIDTH)+1), 8);
		hw_cfg(pos downto pos - (1*8-1)) := to_unsigned(tmp, 1*8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	--box_size
		hw_cfg(pos downto pos - (tmp*8-1)) := to_unsigned(log2_ceil(C_MAX_IMAGE_HEIGHT)+1+log2_ceil(C_MAX_IMAGE_WIDTH)+1, tmp*8);
		hw_cfg_len := hw_cfg_len + tmp;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	--length of stimuli_length (log2(stimuli length))
		--tmp := div_ceil(log2_ceil(2*C_MAX_IMAGE_HEIGHT * 2*C_MAX_IMAGE_WIDTH), 8);
		tmp := 1;
		hw_cfg(pos downto pos - (1*8-1)) := to_unsigned(tmp, 1*8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	--stimuli_length
		--hw_cfg(pos downto pos - (tmp*8-1)) := to_unsigned(2**C_MAX_IMAGE_HEIGHT * 2**C_MAX_IMAGE_WIDTH, tmp*8);
		hw_cfg(pos downto pos - (tmp*8-1)) := to_unsigned(0, tmp*8);
		hw_cfg_len := hw_cfg_len + tmp;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		--length of instances (ceil(log2(instances)))
		tmp := div_ceil(log2_ceil(1), 8);
		hw_cfg(pos downto pos - (1*8-1)) := to_unsigned(tmp, 1*8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	-- instances
		hw_cfg(pos downto pos - (tmp*8-1)) := to_unsigned(0, tmp*8);
		hw_cfg_len := hw_cfg_len + tmp;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	-- comparator error_type length
		hw_cfg(pos downto pos - (8-1)) := to_unsigned(cam_err_s'high-cam_err_s'low+1, 8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		-- rev error_type length
		hw_cfg(pos downto pos - (8-1)) := to_unsigned(0, 8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		-- dut error_type length
		hw_cfg(pos downto pos - (8-1)) := to_unsigned(0, 8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		-- magic number for camera simulation mode
		hw_cfg(pos downto pos - (8-1)) := to_unsigned(42, 8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		-- T_CAM_ERR_ARY_LENGTH
		hw_cfg(pos downto pos - (8-1)) := to_unsigned(T_CAM_ERR'length, 8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		hw_cfg_len_out <= to_unsigned(hw_cfg_len, 2*8);
		hw_cfg_out <= hw_cfg;

	end procedure hw_cfg_status;

	procedure read_err(
		signal length_in          : in unsigned(15 downto 0);
		signal data_in            : in unsigned(G_MAX_DATA_SIZE - 1 downto 0);
		signal err_s              : out T_CAM_ERR)
	is
		constant c_word_len : natural := (err_s(0).row'length +	err_s(0).col'length + 1);
	begin
		-- data vector:
		-- row size: log2_ceil(C_MAX_IMAGE_HEIGHT+1)
	  -- col size: log2_ceil(C_MAX_IMAGE_WIDTH+1)
		-- data size: 1bit
		-- | row(0), col(0), data(0) | row(1), col(1), data(1) | ...
		for i in err_s'range loop
			err_s(i).row <= data_in(
											data_in'high - i*c_word_len downto
											data_in'high - i*c_word_len - err_s(0).row'length +1);
			err_s(i).col <= data_in(
											data_in'high - i*c_word_len - err_s(0).row'length downto
											data_in'high - i*c_word_len
											- err_s(0).row'length - err_s(0).col'length +1);
			err_s(i).val <= data_in(
											data_in'high - i*c_word_len
											- err_s(0).row'length - err_s(0).col'length);
		end loop;

	end procedure read_err;

begin

	run_out <= '1' when int_state_s = PROCESSING else '0';

	--! @brief This process generates the states of the incoming commands
	p_rx_decode : process (rst_in, rx_clk_in) is
		variable tmp : natural;
	begin
		if rst_in = '1' then
			rx_state_s <= NOP;
			cam_min_fll_lvl_s <= to_unsigned(1, cam_min_fll_lvl_s'length);
			active_err_s   <= (others => (row => (others => '1'), col => (others => '1'), val => '0'));
			hsync_err_s    <= (others => (row => (others => '1'), col => (others =>	'1'), val => '0'));
			vsync_err_s    <= (others => (row => (others => '1'), col => (others =>	'1'), val => '0'));
			pkg_cnt_s      <= (others => '0');
			out_fifo_flu_s <= '0';

		elsif rising_edge(rx_clk_in) then

			rx_state_s <= NOP;

			if int_state_s = DONE and out_fifo_fill_s*64/8 < G_MAX_DATA_SIZE/8 and
			out_fifo_fill_s > 0 and out_fifo_flu_s = '0'
			then
				rx_state_s <= SEND_OUT_LAST;
				out_fifo_flu_s<= '1';
			elsif out_fifo_do_vl_s = '1' then
				rx_state_s <= SEND_OUT;
				pkg_cnt_s <= pkg_cnt_s + 1;
			end if;


			cam_di_vl_s <= '0';

			if dec_valid_in = '1' then
				--! default

				if header_error_in = '1' then
					rx_state_s <= HEAD_ERR;
				else
					case type_in is
						when C_TYP_ACK =>
							rx_state_s <= ACK;
						when C_TYP_NACK =>
							rx_state_s <= NACK;
						when C_TYP_HW_CFG =>
							rx_state_s <= HW_CFG;
						when C_TYP_STATUS =>
							rx_state_s <= STATUS;
						when C_TYP_RESET =>
							rx_state_s <= RESET;
						when C_TYP_SEND_PX =>
							rx_state_s <= SEND_PX;
							out_fifo_flu_s <= '0';

							if cam_di_ry_s = '1' then
								cam_di_s <= length_in & data_in(data_in'high downto data_in'high+1-G_MAX_DATA_SIZE);
								cam_di_vl_s <= '1';
							end if;
						when C_TYP_SET_FLL_LVL =>
							rx_state_s <= SET_FLL_LVL;
							cam_min_fll_lvl_s <= data_in(data_in'high downto data_in'high-15);
						when C_TYP_SET_ACT_ERR =>
							rx_state_s <= SET_ACT_ERR;
							if length_in = C_ERR_PKG_LEN then
								read_err(length_in, data_in, active_err_s);
							end if;
						when C_TYP_SET_HSY_ERR =>
							rx_state_s <= SET_HSY_ERR;
							if length_in = C_ERR_PKG_LEN then
								read_err(length_in, data_in, hsync_err_s);
							end if;
						when C_TYP_SET_VSY_ERR =>
							rx_state_s <= SET_VSY_ERR;
							if length_in = C_ERR_PKG_LEN then
								read_err(length_in, data_in, vsync_err_s);
							end if;
						when others =>
							rx_state_s <= UNKNOWN;
					end case;
				end if; --header_error
			end if; -- dec_valid
		end if; --rst/clk
	end process p_rx_decode;

	--! @brief This process generates the answers on rx messages according to
	--! udp_protocol.txt
	p_tx_answer : process (
		rst_in, rx_state_s, id_in, int_state_s, length_in, cam_di_ry_s,
		out_fifo_fill_s, pkg_cnt_s, out_fifo_do_s
	) is
		variable tmp : natural;
	begin
		if rst_in = '1' then
			--reset
			rst_prepare_s  <= '0';
			type_out       <= (others => '-');
			id_out         <= (others => '-');
			length_out     <= (others => '0');
			data_out       <= (others => '-');
			enc_valid_out  <= '0';
			out_fifo_ack_s <= '0';
		else
			-- default values
			enc_valid_out  <= '0';
			type_out       <= (others => '-');
			id_out         <= (others => '-');
			length_out     <= (others => '0');
			data_out       <= (others => '-');
			rst_prepare_s  <= '0';
			out_fifo_ack_s <= '0';

			case rx_state_s is
				when NOP =>
					null;

				when SEND_OUT_LAST =>
					--image processed completed flushing buffer
					--the C_TYP_SEND_BOX uses the length_out as number of valid bits
					--instead of bytes
					enc_valid_out <= '1';
					type_out      <= C_TYP_SEND_BOX;
					id_out        <= pkg_cnt_s;
					length_out    <= resize(out_fifo_fill_s*64/8, length_out'length);
					data_out      <= out_fifo_do_s;

				when SEND_OUT =>
					--enough data stored to fill one complet package
					enc_valid_out  <= '1';
					type_out       <= C_TYP_SEND_BOX;
					id_out         <= pkg_cnt_s;
					length_out     <= to_unsigned(G_MAX_DATA_SIZE/8, length_out'length);
					data_out       <= out_fifo_do_s;
					out_fifo_ack_s <= '1';

				when ACK =>
					-- This case is ignored
					-- TODO: implement send queue. The queue stores all send commands
					-- until a ACK for this id is received. After a timeout do resend
					null;
				when NACK =>
					-- Ignore NACK
					-- TODO: remove from queue or resend
					null;

				when HEAD_ERR =>
					enc_valid_out <= '1';
					type_out <= C_TYP_NACK;
					id_out <= id_in;
					str_unsigned("corrupt header", data_out, length_out);
				--length_out <= x"0e";
				--data_out(G_MAX_DATA_SIZE-1 downto G_MAX_DATA_SIZE-(14*8))
				--<= x"636f727275707420686561646572"; --corrupt header in ASCII


				when HW_CFG =>
					enc_valid_out <= '1';
					type_out <= C_TYP_ACK;
					id_out <= id_in;
					hw_cfg_status(data_out, length_out, G_COMP_INST);

				when STATUS =>
					enc_valid_out <= '1';
					type_out <= C_TYP_ACK;
					id_out <= id_in;
					--constant tmp
					length_out <= to_unsigned(1, 16);
					case int_state_s is
						when RESTART =>
							data_out (G_MAX_DATA_SIZE-1 downto G_MAX_DATA_SIZE-(1*8))
							<= x"80";
						when PROCESSING =>
							data_out (G_MAX_DATA_SIZE-1 downto G_MAX_DATA_SIZE-(1*8))
							<= x"81";
						when DONE =>
							data_out (G_MAX_DATA_SIZE-1 downto G_MAX_DATA_SIZE-(1*8))
							<= x"82";
					end case;
					--add stimuli with alignment to the lsb
					tmp := data_out'high-8+1;

				when RESET =>
					rst_prepare_s <= '1';
					enc_valid_out <= '1';
					type_out <= C_TYP_ACK;
					id_out <= id_in;

				when SEND_PX =>
					enc_valid_out <= '1';
					id_out <= id_in;

					if cam_di_ry_s = '1' then
						type_out <= C_TYP_ACK;
					else
						type_out <= C_TYP_NACK;
						str_unsigned("fifo full", data_out, length_out);
					end if;

				when SET_FLL_LVL =>
					enc_valid_out <= '1';
					id_out <= id_in;
					type_out <= C_TYP_ACK;

				when SET_ACT_ERR =>
					enc_valid_out <= '1';
					id_out <= id_in;

					if length_in = C_ERR_PKG_LEN then
						type_out <= C_TYP_ACK;
					else
						type_out <= C_TYP_NACK;
					end if;

				when SET_HSY_ERR =>
					enc_valid_out <= '1';
					id_out <= id_in;

					if length_in = C_ERR_PKG_LEN then
						type_out <= C_TYP_ACK;
					else
						type_out <= C_TYP_NACK;
					end if;

				when SET_VSY_ERR =>
					enc_valid_out <= '1';
					id_out <= id_in;

					if length_in = C_ERR_PKG_LEN then
						type_out <= C_TYP_ACK;
					else
						type_out <= C_TYP_NACK;
					end if;

				when UNKNOWN =>
					enc_valid_out <= '1';
					id_out <= id_in;
					type_out <= C_TYP_NACK;
					str_unsigned("cmd unknown", data_out, length_out);

				--when others =>
				--	enc_valid_out <= '1';
				--	id_out <= id_in;
				--	type_out <= C_TYP_NACK;
				--	str_unsigned("unexpected", data_out, length_out);
			end case;
		end if; --rst
	end process p_tx_answer;

	--! Statemachine for internal state
	--! States:
	--! IDLE just resetted nothing to do
	--! RESTART do a restart of camif
	--! PROCESSING pixel receive in progress
	--! DONE image processed
	p_int_state : process (rst_in, rx_clk_in) is
	begin

		if rst_in = '1' then
			int_state_s  <= RESTART;
			rst_exec_s <= '0';
			restart_cnt_s <= to_unsigned(C_RESTART_WAIT, restart_cnt_s'length);

		elsif rising_edge(rx_clk_in) then

			--! default Values

			if rst_prepare_s = '1' then
				rst_exec_s <= '1';
			end if;

			case int_state_s is

				when RESTART =>

					rst_exec_s <= '0';
					restart_cnt_s <= restart_cnt_s - 1;

					-- restart wait at least C_RESTART_WAIT clock cycles
					-- and set reset signals
					if restart_cnt_s = 0 then
						int_state_s <= PROCESSING;
						restart_cnt_s <= to_unsigned(C_RESTART_WAIT, restart_cnt_s'length);
					end if;

				when PROCESSING =>

					if cam_done_s = '1' then
						int_state_s <= DONE;
					end if;

					if rst_exec_s = '1' then
						int_state_s <= RESTART;
					end if;

				when DONE =>
					if rst_exec_s = '1' then
						int_state_s <= RESTART;
					end if;

			end case;
		end if;
	end process p_int_state;


	--! @brief Process for controling internal signals
	p_ctrl : process (int_state_s, rst_in) is
	begin

		--default values
		cam_rst_s <= '0';
		out_fifo_rst_s <= '0';

		if rst_in = '1' then
			cam_rst_s <= '1';
		else
			case int_state_s is

				when RESTART =>
					-- reset the counter and the verifier
					cam_rst_s <= '1';
					out_fifo_rst_s <= '1';

				when PROCESSING =>
					null;

				when DONE =>
					null;

			end case;
		end if;

	end process p_ctrl;

	-- send ready to data_out of camif if fifo has space to store value
	cam_do_ry_s   <= not out_fifo_full_s;
	out_fifo_di_s <= cam_do_s;

	out_fifo: entity work.box_out_storage
	port map(
		rst_in             => out_fifo_rst_s,
		clk_in             => rx_clk_in,

		full_out           => out_fifo_full_s,
		fill_lvl_out       => out_fifo_fill_s,

		data_in            => out_fifo_di_s,
		data_vl_in         => cam_do_vl_s,

		data_out           => out_fifo_do_s,
		data_vl_out        => out_fifo_do_vl_s,
		data_ack_in        => out_fifo_ack_s
	);


	camif : entity work.camif
	generic map(
			--! Image width
			-- value from ccl_dut common.vhd
		G_IMG_WIDTH     => C_IMAGE_WIDTH,

			--! Image height
			-- value from ccl_dut common.vhd
		G_IMG_HEIGHT    => C_IMAGE_HEIGHT,

			--! Number of parallel pixels
		G_NO_PX         => no_pixels,

			--! Input width in bits
		G_IN_WIDTH      => G_MAX_DATA_SIZE,
		G_FIFO_SIZE     => 256
	)
	port map(
		clk_in          => rx_clk_in,
		clk_cam_in      => clk_dut_in,
		rst_in          => cam_rst_s,

		min_fll_lvl_in  => cam_min_fll_lvl_s,

			-- input of image data
			-- 16 MSB bits are used to save the number of valid pixels
			-- only the last package of pixels can be smaller than 1024
		data_in         => cam_di_s, --: in UNSIGNED(G_IN_WIDTH+16 - 1 downto 0);
		data_vl_in      => cam_di_vl_s, -- : in STD_LOGIC;
		data_in_rdy_out => cam_di_ry_s,

			--! output data out
		data_out        => cam_do_s,
		data_rdy_in     => cam_do_ry_s,
		data_vl_out     => cam_do_vl_s,

			--! error value
		error_out       => cam_err_s,

			--! high if image processing is completed
		done_out        => cam_done_s,


		--vsync error injection
		vsync_err_in    => vsync_err_s,
		--hsync error injection
		hsync_err_in    => hsync_err_s,
		--px active error injection
		-- if value = 1 inserts a additional pixel before the given coordinate
		-- if value = 0 forces the active signal to zero for the given coordinate
		active_err_in   => active_err_s


	);

end architecture cam_control_unit_arc;
