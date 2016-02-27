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
--! @file control_unit.vhd
--! @brief Control Unit for the verificator
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-11-25
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;
use work.utils.all;

library pccl_lib;
use pccl_lib.common.all;

entity control_unit is
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

		ver_run_out        : out std_logic

);
end control_unit;

architecture control_unit_arc of control_unit is
	CONSTANT C_RESTART_WAIT      : natural := 3;
	CONSTANT C_STIM_SIZE         : natural := G_IMG_WIDTH*G_IMG_HEIGHT;
	CONSTANT C_STIM_SIZE_BYTE    : natural := div_ceil(C_STIM_SIZE, 8);
	CONSTANT C_BOX_SIZE          : natural := 2*(log2_ceil(G_IMG_WIDTH)+log2_ceil(G_IMG_HEIGHT));
	CONSTANT C_BOX_SIZE_BYTE     : natural := div_ceil(C_BOX_SIZE, 8);
	CONSTANT C_ERR_FIFO_WIDTH    : natural := C_ERR_TYP_SIZE+C_STIM_SIZE;
	CONSTANT C_ERR_FI_LV_SIZE    : natural := log2_ceil(G_ERR_SIZE)+1;
	CONSTANT C_ERR_FI_LV_BYTE    : natural := div_ceil(C_ERR_FI_LV_SIZE, 8);

	CONSTANT C_TYP_ACK           : unsigned(15 downto 0) := x"0001";
	CONSTANT C_TYP_NACK          : unsigned(15 downto 0) := x"0002";
	CONSTANT C_TYP_HW_CFG        : unsigned(15 downto 0) := x"0003";
	CONSTANT C_TYP_STATUS        : unsigned(15 downto 0) := x"0004";
	CONSTANT C_TYP_SSTIMULI      : unsigned(15 downto 0) := x"0005";
	CONSTANT C_TYP_ESTIMULI      : unsigned(15 downto 0) := x"0006";
	CONSTANT C_TYP_RESET         : unsigned(15 downto 0) := x"0007";
	CONSTANT C_TYP_ERR_CNT       : unsigned(15 downto 0) := x"0008";
	CONSTANT C_TYP_ERR_STR       : unsigned(15 downto 0) := x"0009";
	CONSTANT C_TYP_ERR_DRP       : unsigned(15 downto 0) := x"000A";
	CONSTANT C_TYP_ERR_NXT       : unsigned(15 downto 0) := x"000B";
	CONSTANT C_TYP_ERR_RD        : unsigned(15 downto 0) := x"000C";
	CONSTANT C_TYP_CNT_RD        : unsigned(15 downto 0) := x"000D";


	type T_RX_STATE is (NOP, ACK, NACK, HEAD_ERR, HW_CFG, STATUS, SSTIMULI,
	                    ESTIMULI, RESET, ERR_CNT, ERR_STR, ERR_DRP, ERR_NXT,
										  ERR_RD, CNT_RD, UNKNOWN);
	signal rx_state_s : T_RX_STATE;


	--! verifier state
	type T_INT_STATE is (IDLE, RESTART, RUN, CHECK_LAST, CHECK_DONE);
	signal int_state_s    : T_INT_STATE;

	signal err_cnt_s      : unsigned(G_IMG_WIDTH*G_IMG_HEIGHT-1 downto 0);
	signal err_drp_s      : unsigned(G_IMG_WIDTH*G_IMG_HEIGHT-1 downto 0);


	--! internal signals
	signal next_sstim_s   : unsigned(G_IMG_WIDTH*G_IMG_HEIGHT-1 downto 0);
	signal next_estim_s   : unsigned(G_IMG_WIDTH*G_IMG_HEIGHT-1 downto 0);
	signal rst_exec_s     : std_logic := '0';
	signal rst_prepare_s	: std_logic := '0';
	signal restart_cnt_s  : unsigned(log2_ceil(C_RESTART_WAIT+1)-1 downto 0);

	--! signals for verificator
	signal ver_rst_s      : std_logic;
	signal stim_vl_s      : std_logic;
	signal stim_s         : unsigned(C_STIM_SIZE-1 downto 0);
	signal err_vl_s       : std_logic;
	signal err_s          : T_ERROR;
	signal err_stim_s     : unsigned(C_STIM_SIZE-1 downto 0);
	signal ver_idle_s     : std_logic;
	signal ver_run_s      : std_logic;
	signal ver_max_util_s : std_logic;

	--! signals for counter
	Signal cnt_rst_s      : STD_LOGIC;
	Signal cnt_s          : UNSIGNED(C_STIM_SIZE-1 downto 0);
	Signal cnt_inc_s      : STD_LOGIC;
	Signal cnt_offset_s   : UNSIGNED(C_STIM_SIZE-1 downto 0);
	Signal cnt_end_s      : UNSIGNED(C_STIM_SIZE-1 downto 0);


	--! err_fifo signals
	Signal err_fifo_rst_s    : STD_LOGIC;
	Signal err_fifo_wr_d_s   : UNSIGNED(C_ERR_FIFO_WIDTH-1 downto 0);
	Signal err_fifo_wr_vl_s  : STD_LOGIC;
	Signal err_fifo_am_fu_s  : STD_LOGIC;
	Signal err_fifo_fu_s     : STD_LOGIC;
	Signal err_fifo_rd_d_s   : UNSIGNED(C_ERR_FIFO_WIDTH-1 downto 0);
	Signal err_fifo_rd_nxt_s : STD_LOGIC;
	Signal err_fifo_am_ep_s  : STD_LOGIC;
	Signal err_fifo_ep_s     : STD_LOGIC;
	Signal err_fifo_fi_lvl_s : UNSIGNED(C_ERR_FI_LV_SIZE-1 downto 0);

	Signal counter_s : unsigned(C_CNT_SIZE*C_MAX_BOXES-1 downto 0);
	
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
		tmp := div_ceil(log2_ceil(G_IMG_HEIGHT * G_IMG_WIDTH), 8);
		hw_cfg(pos downto pos - (1*8-1)) := to_unsigned(tmp, 1*8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	--stimuli_length
		--hw_cfg(pos downto pos - (tmp*8-1)) := to_unsigned(2**C_MAX_IMAGE_HEIGHT * 2**C_MAX_IMAGE_WIDTH, tmp*8);
		hw_cfg(pos downto pos - (tmp*8-1)) := to_unsigned(G_IMG_WIDTH*G_IMG_HEIGHT, tmp*8);
		hw_cfg_len := hw_cfg_len + tmp;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		--length of instances (ceil(log2(instances)))
		tmp := div_ceil(log2_ceil(instances), 8);
		hw_cfg(pos downto pos - (1*8-1)) := to_unsigned(tmp, 1*8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	-- instances
		hw_cfg(pos downto pos - (tmp*8-1)) := to_unsigned(instances, tmp*8);
		hw_cfg_len := hw_cfg_len + tmp;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

   	-- comparator error_type length
		hw_cfg(pos downto pos - (8-1)) := to_unsigned(C_ERR_CMP_SIZE, 8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		-- rev error_type length
		hw_cfg(pos downto pos - (8-1)) := to_unsigned(C_ERR_REF_SIZE, 8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		-- dut error_type length
		hw_cfg(pos downto pos - (8-1)) := to_unsigned(C_ERR_DUT_SIZE, 8);
		hw_cfg_len := hw_cfg_len + 1;
		pos := G_MAX_DATA_SIZE-1 - hw_cfg_len*8;

		hw_cfg_len_out <= to_unsigned(hw_cfg_len, 2*8);
		hw_cfg_out <= hw_cfg;

	end procedure hw_cfg_status;


begin

	ver_run_out <= '1' when int_state_s = RUN else '0';

	--! @brief This process generates the states of the incoming commands
	p_rx_decode : process (rst_in, rx_clk_in) is
		variable tmp : natural;
	begin
		if rst_in = '1' then
			rx_state_s <= NOP;

			next_sstim_s  <= (others => '0');
			next_estim_s  <= (others => '1');
		elsif rising_edge(rx_clk_in) then

			rx_state_s <= NOP;
			if dec_valid_in = '1' then
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
						when C_TYP_SSTIMULI =>
							rx_state_s <= SSTIMULI;

							tmp := data_in'high - (C_STIM_SIZE_BYTE*8);
							next_sstim_s <= data_in(tmp + C_STIM_SIZE downto tmp + 1);

						when C_TYP_ESTIMULI =>
							rx_state_s <= ESTIMULI;

							tmp := data_in'high - (C_STIM_SIZE_BYTE*8);
							next_estim_s <= data_in(tmp + C_STIM_SIZE downto tmp + 1);

						when C_TYP_RESET =>
							rx_state_s <= RESET;
						when C_TYP_ERR_CNT =>
							rx_state_s <= ERR_CNT;
						when C_TYP_ERR_STR =>
							rx_state_s <= ERR_STR;
						when C_TYP_ERR_DRP =>
							rx_state_s <= ERR_DRP;
						when C_TYP_ERR_NXT =>
							rx_state_s <= ERR_NXT;
						when C_TYP_ERR_RD =>
							rx_state_s <= ERR_RD;
						when C_TYP_CNT_RD =>
							rx_state_s <= CNT_RD;
						when others =>
							rx_state_s <= UNKNOWN;
					end case;
				end if; --header_error
			end if; -- dec_valid
		end if; --rst/clk
	end process p_rx_decode;

	--! @brief This process generates the answers on rx messages according to
	--! udp_protocol.txt
	p_tx_answer : process (rst_in, rx_state_s, id_in, int_state_s, stim_s,
	                       length_in, err_fifo_fi_lvl_s, err_drp_s, err_cnt_s,
											   err_fifo_ep_s, err_fifo_rd_d_s, counter_s) is
		variable tmp : natural;
	begin
		if rst_in = '1' then
			--reset
			rst_prepare_s    <= '0';
			type_out      <= (others => '-');
			id_out        <= (others => '-');
			length_out    <= (others => '0');
			data_out      <= (others => '-');
			enc_valid_out <= '0';
			err_fifo_rd_nxt_s <= '0';
		else
			-- default values
			enc_valid_out <= '0';
			type_out      <= (others => '-');
			id_out        <= (others => '-');
			length_out    <= (others => '0');
			data_out      <= (others => '-');
			rst_prepare_s   <= '0';
			err_fifo_rd_nxt_s <= '0';

			case rx_state_s is
				when NOP =>
					null;
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
					tmp := C_STIM_SIZE_BYTE;
					length_out <= to_unsigned(1+tmp, 16);
					case int_state_s is
						when IDLE =>
							data_out (G_MAX_DATA_SIZE-1 downto G_MAX_DATA_SIZE-(1*8))
							<= x"00";
						when RESTART =>
							data_out (G_MAX_DATA_SIZE-1 downto G_MAX_DATA_SIZE-(1*8))
							<= x"01";
						when RUN =>
							data_out (G_MAX_DATA_SIZE-1 downto G_MAX_DATA_SIZE-(1*8))
							<= x"02";
						when CHECK_LAST =>
							data_out (G_MAX_DATA_SIZE-1 downto G_MAX_DATA_SIZE-(1*8))
							<= x"03";
						when CHECK_DONE =>
							data_out (G_MAX_DATA_SIZE-1 downto G_MAX_DATA_SIZE-(1*8))
							<= x"04";
					--when others =>
					--	data_out (G_MAX_DATA_SIZE-1 downto G_MAX_DATA_SIZE-(1*8))
					--	<= x"FF";
					end case;
					--add stimuli with alignment to the lsb
					tmp := data_out'high-8-(C_STIM_SIZE_BYTE*8);

					-- be shure the padding bits are filled with '0'
					data_out(tmp + C_STIM_SIZE downto	tmp + C_STIM_SIZE -7) <= x"00";

					data_out(tmp + C_STIM_SIZE downto	tmp +1) <= stim_s;

				when SSTIMULI =>
					enc_valid_out <= '1';
					id_out <= id_in;

					if length_in = C_STIM_SIZE_BYTE then
						type_out <= C_TYP_ACK;
					else
						type_out <= C_TYP_NACK;
						str_unsigned("wrong stimuli size", data_out, length_out);
					end if;

				when ESTIMULI =>
					enc_valid_out <= '1';
					id_out <= id_in;

					if length_in = C_STIM_SIZE_BYTE then
						type_out <= C_TYP_ACK;
					else
						type_out <= C_TYP_NACK;
						str_unsigned("wrong stimuli size", data_out, length_out);
					end if;

				when RESET =>
					rst_prepare_s <= '1';
					enc_valid_out <= '1';
					type_out <= C_TYP_ACK;
					id_out <= id_in;

				when ERR_CNT =>
					enc_valid_out <= '1';
					id_out <= id_in;
					type_out <= C_TYP_ACK;

					tmp := C_STIM_SIZE_BYTE;
					length_out <= to_unsigned(tmp, 16);

					-- be shure the padding bits are filled with '0'
					data_out(data_out'high downto data_out'high-7) <= x"00";

					data_out(data_out'high-(tmp*8)+C_STIM_SIZE
					downto data_out'high+1-(tmp*8)) <= err_cnt_s;


				when ERR_STR =>
					enc_valid_out <= '1';
					id_out <= id_in;
					type_out <= C_TYP_ACK;

					tmp := C_ERR_FI_LV_BYTE;
					length_out <= to_unsigned(tmp, 16);

					-- be shure the padding bits are filled with '0'
					data_out(data_out'high downto data_out'high-7) <= x"00";

					data_out(data_out'high-(tmp*8)+C_ERR_FI_LV_SIZE
					downto data_out'high+1-(tmp*8)) <= err_fifo_fi_lvl_s;


				when ERR_DRP =>
					enc_valid_out <= '1';
					id_out <= id_in;
					type_out <= C_TYP_ACK;

					tmp := C_STIM_SIZE_BYTE;
					length_out <= to_unsigned(tmp, 16);
					tmp := data_out'high-(C_STIM_SIZE_BYTE*8);

					-- be shure the padding bits are filled with '0'
					data_out(data_out'high downto data_out'high-7) <= x"00";

					data_out(tmp + C_STIM_SIZE downto tmp + 1) <= err_drp_s;


				when ERR_NXT =>
					enc_valid_out <= '1';
					id_out <= id_in;

					if err_fifo_ep_s = '1' then
						type_out <= C_TYP_NACK;
						str_unsigned("no errors to read", data_out, length_out);
					else

						type_out <= C_TYP_ACK;
						-- padding with 0
						data_out(data_out'high downto
						data_out'high+1-(C_ERR_TYP_SIZE_BYTE+C_STIM_SIZE_BYTE)*8)
						<= (others => '0');
						--read data from error fifo and write it byte aligned to data_out
						--error type

						-- be shure the padding bits are filled with '0'
						data_out(data_out'high downto data_out'high-7) <= x"00";

						data_out(data_out'high-C_ERR_TYP_SIZE_BYTE*8+C_ERR_TYP_SIZE downto
						data_out'high-C_ERR_TYP_SIZE_BYTE*8+1) <=
					 err_fifo_rd_d_s(err_fifo_rd_d_s'high downto
					 err_fifo_rd_d_s'high+1-C_ERR_TYP_SIZE);

						-- stimuli
					 tmp := data_out'high-(C_ERR_TYP_SIZE_BYTE*8)-C_STIM_SIZE_BYTE*8;

						-- be shure the padding bits are filled with '0'
					 data_out(tmp+C_STIM_SIZE downto tmp+C_STIM_SIZE-7) <= x"00";

					 data_out(tmp+C_STIM_SIZE downto tmp+1) <=
					 err_fifo_rd_d_s(err_fifo_rd_d_s'high-C_ERR_TYP_SIZE downto
					 err_fifo_rd_d_s'high+1-C_ERR_TYP_SIZE-C_STIM_SIZE);

					 length_out <= to_unsigned(C_ERR_TYP_SIZE_BYTE + C_STIM_SIZE_BYTE,
												 length_out'length);
				 end if;


			 when ERR_RD =>
				 enc_valid_out <= '1';
				 id_out <= id_in;
				 if err_fifo_ep_s = '1' then
					 type_out <= C_TYP_NACK;
					 str_unsigned("no errors to read", data_out, length_out);
				 else
					 err_fifo_rd_nxt_s <= '1';
					 type_out <= C_TYP_ACK;
				 end if;

			when CNT_RD =>
				enc_valid_out <= '1';
				id_out <= id_in;
				if C_INCLUDE_CNT then
					type_out <= C_TYP_ACK;
					length_out <= to_unsigned(C_CNT_SIZE_BYTE, length_out'length);
					data_out <= (others => '0');
					data_out(data_out'high downto data_out'high - counter_s'high) <= counter_s;
				else
					type_out <= C_TYP_NACK;
					str_unsigned("Not implemented", data_out, length_out);
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
 --! RESTART do a restart of verification with next_sstim and next_estim
 --!         values
 --! RUN run verification...
 --! CHECK_LAST all stimulis are generated but not all processed
 --! CHECK_DONE all stimulis are tested nothing to do
 p_int_state : process (rst_in, rx_clk_in) is
 begin

	 if rst_in = '1' then
		 int_state_s  <= IDLE;
		 cnt_offset_s <= (others => '0');
		 cnt_end_s <= (others => '1');
		 cnt_inc_s <= '0';
		 stim_vl_s <= '0';
		 restart_cnt_s <= to_unsigned(C_RESTART_WAIT, restart_cnt_s'length);
		 rst_exec_s <= '0';

	 elsif rising_edge(rx_clk_in) then

		 --! default Values
		 stim_vl_s <= '0';
		 cnt_inc_s <= '0';

		 if rst_prepare_s = '1' then
			 rst_exec_s <= '1';
		 end if;

		 case int_state_s is

			 when IDLE =>
				 if rst_exec_s = '1' and ver_idle_s = '1' then
					 int_state_s <= RESTART;
					 restart_cnt_s <= to_unsigned(C_RESTART_WAIT, restart_cnt_s'length);
				 end if;

			 when RESTART =>

				 rst_exec_s <= '0';
				 restart_cnt_s <= restart_cnt_s - 1;

				 -- restart wait at least C_RESTART_WAIT clock cycles
				 -- and set reset signals
				 if ver_idle_s = '1' and restart_cnt_s = 0 then
					 int_state_s <= RUN;
					 restart_cnt_s <= to_unsigned(C_RESTART_WAIT, restart_cnt_s'length);
				 end if;

				 -- the start and end values will be used for the counter
				 cnt_offset_s <= next_sstim_s;
				 cnt_end_s <= next_estim_s;
				 stim_s <= cnt_offset_s;


			 when RUN =>
				 if cnt_end_s = stim_s then
					 int_state_s <= CHECK_LAST;
				 else

					 if rst_exec_s = '1' and ver_idle_s = '1' then
						 int_state_s <= RESTART;
					 end if;


					 if rst_exec_s = '0' then
						 -- only send new stimuli if not wait for a restart
						 stim_s <= cnt_s + cnt_offset_s;
						 stim_vl_s <= (not ver_max_util_s) and (C_ALLOW_ERR_DRP or
													not	err_fifo_am_fu_s);
						 cnt_inc_s <= (not ver_max_util_s) and (C_ALLOW_ERR_DRP or
													not	err_fifo_am_fu_s);
					 end if;
				 end if;



			 when CHECK_LAST =>
				 if ver_idle_s = '1' and err_vl_s = '0' then
					 int_state_s <= CHECK_DONE;
				 end if;

			 when CHECK_DONE =>
				 if rst_exec_s = '1' and ver_idle_s = '1' then
					 int_state_s <= RESTART;
				 end if;

		 end case;
	 end if;
 end process p_int_state;


 err_fifo_wr_d_s <= err_s & err_stim_s;

 --! @brief Process for controling internal signals
 p_ctrl : process (cnt_s, int_state_s, ver_max_util_s, ver_idle_s, err_vl_s,
	 rst_in, err_s) is
 begin

	 --default values
	 cnt_rst_s <= '0';
	 ver_rst_s <= '0';
	 err_fifo_wr_vl_s <= '0';
	 err_fifo_rst_s <= '0';
	 ver_run_s    <= '0';

	 if rst_in = '1' then
		 ver_rst_s <= '1';
		 cnt_rst_s <= '1';
		 err_fifo_rst_s <= '1';
	 else
		 case int_state_s is

			 when IDLE =>
				 null;

			 when RESTART =>
				 -- reset the counter and the verifier
				 cnt_rst_s <= '1';
				 ver_rst_s <= '1';
				 err_fifo_rst_s <= '1';

			 when RUN =>
				 if err_s /= 0 then
					 err_fifo_wr_vl_s <= err_vl_s;
				 end if;
				 ver_run_s    <= '1';


			 when CHECK_LAST =>
				 if err_s /= 0 then
					 err_fifo_wr_vl_s <= err_vl_s;
				 end if;
				 ver_run_s        <= '1';

			 when CHECK_DONE =>
				 null;
		 --when others =>
		 --	null;
		 end case;
	 end if;

 end process p_ctrl;

 --! @brief counts the errors and the droped erro (if fifo is full)
 p_err_cnt : process(rx_clk_in, rst_in, int_state_s) is
 begin
	 if rst_in = '1' or int_state_s = RESTART then
		 -- reset the error statistic
		 err_drp_s <= (others => '0');
		 err_cnt_s <= (others => '0');

	 elsif rising_edge(rx_clk_in) then
		 if int_state_s = RUN then
			 if err_vl_s = '1' and err_s /= 0 then
				 err_cnt_s <= err_cnt_s + 1;

				 if err_fifo_fu_s = '1' then
					 err_drp_s <= err_drp_s + 1;
				 end if;
			 end if;
		 end if; -- state
	 end if; --clk
 end process p_err_cnt;


 ver : entity work.verificator
 generic map(
	 --! Number of Comparators
	 G_COMP_INST     => G_COMP_INST,

	 --! Image width
	 -- value from ccl_dut common.vhd
	 G_IMG_WIDTH     => G_IMG_WIDTH,

	 --! Image height
	 -- value from ccl_dut common.vhd
	 G_IMG_HEIGHT    => G_IMG_HEIGHT
 )
 port map(
	 --! Clock input
	 clk_in          => rx_clk_in,

	 --! Reset input
	 rst_in          => ver_rst_s,

	 --! verificator run
	 run_in          => ver_run_s,

	 --! Stimuli in
	 stimuli_in      => stim_s,

	 --! Stimuli in valid
	 stimuli_v_in    => stim_vl_s,

	 --! error_out valid
	 error_valid_out => err_vl_s,

	 --! error valu
	 error_out       => err_s,

	 --! stimuli lead to error
	 stimuli_out     => err_stim_s,

	 --! high if all instances of the comparators in use
	 max_util_out    => ver_max_util_s,

	 counter_out     => counter_s, 

	 --! high if no testpattern to process asigned
	 idle_out        => ver_idle_s
 );

 counter : entity work.counter GENERIC MAP(
	 G_CNT_LENGTH    => G_IMG_WIDTH * G_IMG_HEIGHT,
	 G_INC_VALUE     => 1,
	 G_OFFSET        => to_unsigned(0, 64) --to_unsigned(21, 64)
 --G_OFFSET        => x"0000000700F73906" --there should be dragons
 )
 PORT MAP(
	 clk_in          => rx_clk_in,
	 rst_in          => cnt_rst_s,
	 inc_in          => cnt_inc_s,
	 cnt_out         => cnt_s
 );

 -- stores errors with type different to zero
 -- format: |error_type|stimuli
 -- (error_typ -> 1Byte values = 1..4)
 -- (stimuli)
 --! @TODO write wrapper for FIFO first word fall through to use in
 --! control_unit
 err_fifo : entity work.fifo
 generic map (
	 --! Size of the fifo in input words
	 G_SIZE           => G_ERR_SIZE,
	 --! input width in bits
	 G_WORD_WIDTH     => C_ERR_FIFO_WIDTH,
	 --! output width in bits
	 G_ALMOST_EMPTY   => 1,
	 --! Threshold for the nearly full signal in input words
	 G_ALMOST_FULL    => G_ERR_SIZE - C_COMP_INST,
	 G_FWFT           => true
 )
 port map(
	 --! Reset input
	 rst_in           => err_fifo_rst_s,

	 --! Clock input
	 clk_in           => rx_clk_in,

	 --! Data input
	 wr_d_in          => err_fifo_wr_d_s,
	 --! Data on write input valid
	 wr_valid_in      => err_fifo_wr_vl_s,
	 --! Fifo reached the G_ALMOST_FULL threshold
	 almost_full_out  => err_fifo_am_fu_s,
	 --! Fifo is full
	 full_out         => err_fifo_fu_s,

	 --! Data output
	 rd_d_out         => err_fifo_rd_d_s,
	 --! Data on output read -> next
	 rd_next_in       => err_fifo_rd_nxt_s,
	 --! Fifo reached the G_ALMOST_EMPTY threshold
	 almost_empty_out => err_fifo_am_ep_s,
	 --! Fifo is empty
	 empty_out        => err_fifo_ep_s,

	 --! Fill level of fifo
	 fill_lvl_out     => err_fifo_fi_lvl_s
 );



end architecture control_unit_arc;


