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
--! @file udp_encoder.vhd
--! @brief encodes the send udp packets
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-11-25
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.utils.all;
--use work.axi.all;
use work.ipv4_types.all;
use work.arp_types.all;
use work.types.all;


entity udp_encoder is
	generic(
		G_MAX_DATA_SIZE : natural := C_MAX_SEND_DATA;
		G_SEND_BUFFER   : natural := 8
	);
	port (
		-- System signals
		------------------
		rst_in              : in std_logic; -- asynchronous reset
		tx_clk_in           : in std_logic;

	  -- tried to send malformed header data
		invalid_data_out    : out std_logic;

		-- data lost -> send buffer full
		data_lost_out       : out std_logic;

		-- UDP TX signals
	  -----------------
		-- indicates req to tx UDP
		udp_tx_start_out	  : out std_logic;
		-- UDP tx cxns
		udp_tx_out			    : out udp_tx_type;
		-- tx status (changes during transmission)
		udp_tx_result_out	  : in std_logic_vector (1 downto 0);
		-- indicates udp_tx is ready to take data
		udp_tx_data_rdy_in  : in std_logic;

		-- Encoder inputs
	  -- read/write command
		enc_valid_in       : in std_logic;
		type_in            : in unsigned(15 downto 0);
		id_in              : in unsigned(15 downto 0);
		length_in          : in unsigned(15 downto 0);
		data_in            : in unsigned(G_MAX_DATA_SIZE - 1 downto 0);

		udp_rx_header_in   : in udp_rx_header_type


);
end udp_encoder;

  -- Packet format:
	--  0      7      15 16      23      31 32      39      47 48
	-- +----------------+------------------+------------------+-------...--------
	-- |      type      |        id        |      length      |       data      |
	-- +----------------+------------------+------------------+-------...--------



architecture udp_encoder_arc of udp_encoder is
	CONSTANT C_HEADER_SIZE      : natural := type_in'length+id_in'length+length_in'length;
	CONSTANT C_HEADER_BYTE_SIZE : natural := div_ceil(C_HEADER_SIZE,8);
	CONSTANT C_MAX_STORE_SIZE   : natural := C_HEADER_SIZE + data_in'length;
	CONSTANT C_MAX_SEND_BYTES   : natural := div_ceil(C_MAX_STORE_SIZE, 8);

	CONSTANT C_IP_LEN           : natural := udp_rx_header_in.src_ip_addr'length;
	CONSTANT C_PORT_LEN         : natural := udp_rx_header_in.src_port'length;

	CONSTANT C_BUF_LENGTH       : natural := C_MAX_STORE_SIZE
	                                         + udp_rx_header_in.src_ip_addr'length
	                                         + udp_rx_header_in.src_port'length
	                                         + udp_rx_header_in.dst_port'length;

	-- Addresses in the buffer
	subtype R_BUF_TYP is natural range C_BUF_LENGTH-1 downto C_BUF_LENGTH-1-type_in'length+1;
	subtype R_BUF_ID  is natural range R_BUF_TYP'LOW-1 downto	R_BUF_TYP'LOW-1-id_in'length+1;
	subtype R_BUF_LEN is natural range R_BUF_ID'LOW-1 downto R_BUF_ID'LOW-1- length_in'length+1;
	subtype R_BUF_DAT is natural range R_BUF_LEN'LOW-1 downto
	R_BUF_LEN'LOW-1-data_in'length+1;
	subtype R_BUF_IP  is natural range R_BUF_DAT'LOW-1 downto R_BUF_DAT'LOW-1-C_IP_LEN+1;
	subtype R_BUF_SP  is natural range R_BUF_IP'LOW-1 downto R_BUF_IP'LOW-1-C_PORT_LEN+1;
	subtype R_BUF_DP  is natural range R_BUF_SP'LOW-1 downto R_BUF_SP'LOW-1-C_PORT_LEN+1;

	type T_TX_STATE is (IDLE, WAITRDY, SEND, WAITSEND);
	signal tx_state_s : T_TX_STATE;

	signal bytes_to_send_s  :	unsigned(log2_ceil(C_HEADER_BYTE_SIZE) + length_in'length downto 0);
	signal bytes_send_s     : unsigned(log2_ceil(C_MAX_STORE_SIZE/8+1) downto 0);


	--! FIFO Buffer Signals
	signal tx_buf_d_s       : unsigned(C_BUF_LENGTH-1 downto 0);
	signal tx_buf_full_s    : std_logic;
	signal tx_buf_d_out_s   : unsigned(C_BUF_LENGTH-1 downto 0);
	signal tx_buf_rd_nxt_s  : std_logic;
	signal tx_buf_empty_s   : std_logic;

begin
	data_lost_out <= tx_buf_full_s and enc_valid_in;

	--! Data to fifo send buffer 
	tx_buf_d_s(R_BUF_TYP) <= type_in;
	tx_buf_d_s(R_BUF_ID)  <= id_in;
	tx_buf_d_s(R_BUF_LEN) <= length_in;
	tx_buf_d_s(R_BUF_DAT) <= data_in;
	tx_buf_d_s(R_BUF_IP)  <= unsigned(udp_rx_header_in.src_ip_addr);
	tx_buf_d_s(R_BUF_SP)  <= unsigned(udp_rx_header_in.src_port);
	tx_buf_d_s(R_BUF_DP)  <= unsigned(udp_rx_header_in.dst_port);

	-- serializes the udp packet end sends the udp data
	p_serializer : process (rst_in, tx_clk_in) is
		variable tmp : natural;
	begin
		if rst_in = '1' then
			tx_state_s <= IDLE;
			udp_tx_start_out <= '0';
			udp_tx_out.data.data_out_valid <= '0';
			udp_tx_out.data.data_out_last  <= '0';
			udp_tx_out.data.data_out <= (others => '0');
			tx_buf_rd_nxt_s <= '0';

		elsif rising_edge(tx_clk_in) then

			-- default values
			udp_tx_start_out <= '0';
			udp_tx_out.data.data_out_valid <= '0';
			invalid_data_out <= '0';
			udp_tx_out.data.data_out_last  <= '0';
			udp_tx_out.data.data_out <= (others => '0');
			tx_buf_rd_nxt_s <= '0';

			case tx_state_s is
				when IDLE =>
					if tx_buf_empty_s = '0' then

						--! write header for udp Packet
						udp_tx_out.hdr.dst_ip_addr <= std_logic_vector(tx_buf_d_out_s(R_BUF_IP));
						udp_tx_out.hdr.dst_port    <= std_logic_vector(tx_buf_d_out_s(R_BUF_SP));
						udp_tx_out.hdr.src_port    <= std_logic_vector(tx_buf_d_out_s(R_BUF_DP));
						udp_tx_out.hdr.data_length <= std_logic_vector(tx_buf_d_out_s(R_BUF_LEN)+
																					C_HEADER_BYTE_SIZE);

						--! @TODO implement CHECKSUM generation for UDP TX header
						udp_tx_out.hdr.checksum    <= (others => '0');

						bytes_to_send_s <= resize(tx_buf_d_out_s(R_BUF_LEN),bytes_to_send_s'length) + C_HEADER_BYTE_SIZE;
						bytes_send_s    <= (others => '0');

						tx_state_s <= WAITRDY;

						udp_tx_start_out <= '1';
					end if; --enc_valid_in

				when WAITRDY =>
					udp_tx_start_out <= '1';

					if bytes_to_send_s > C_MAX_SEND_BYTES then
						-- more data to send than the data vector is long
						invalid_data_out <= '1';
						udp_tx_start_out <= '0';
						tx_state_s <= IDLE;

					elsif udp_tx_data_rdy_in = '1' then
						tx_state_s <= SEND;
					end if;

				when SEND =>
					--! data are valid
					udp_tx_out.data.data_out_valid <= '1';

					tmp := to_integer(tx_buf_d_out_s'HIGH - bytes_send_s*8);
					udp_tx_out.data.data_out <= std_logic_vector(tx_buf_d_out_s(tmp
																			downto tmp-7));

					-- increment byte counter
					bytes_send_s <= bytes_send_s + 1;

					-- last byte?
					if bytes_send_s < bytes_to_send_s-1 then
						udp_tx_out.data.data_out_last  <= '0';
					else
						udp_tx_out.data.data_out_last  <= '1';
						tx_buf_rd_nxt_s <= '1';
						tx_state_s <= WAITSEND;
					end if;

				when WAITSEND =>
					-- wait until fifo empty signal is changed
					tx_state_s <= IDLE;

			end case;
		end if; --clk/rst
	end process p_serializer;


	--! stores send requests until mac is ready for sending
	tx_buf : entity work.fifo 
	generic map(
		--! Size of the fifo in input words
		G_SIZE          => G_SEND_BUFFER,
		--! input width in bits
		G_WORD_WIDTH    => C_BUF_LENGTH,
		--! output width in bits
		G_ALMOST_EMPTY  => 1,
		--! Threshold for the nearly full signal in input words
		G_ALMOST_FULL   => G_SEND_BUFFER - 1,
		--! First Word Fall Through
		G_FWFT          => true
	)
	port map(
		--! Reset input
		rst_in            => rst_in,

		--! Clock input
		clk_in            => tx_clk_in,

		--! Data input
		wr_d_in           => tx_buf_d_s,
		--! Data on write input valid
		wr_valid_in       => enc_valid_in,
		--! Fifo reached the G_ALMOST_FULL threshold
		almost_full_out   => open,
		--! Fifo is full
		full_out          => tx_buf_full_s,

		--! Data output
		rd_d_out          => tx_buf_d_out_s,
		--! Data on output read -> next
		rd_next_in        => tx_buf_rd_nxt_s,
		--! Fifo reached the G_ALMOST_EMPTY threshold
		almost_empty_out  => open,
		--! Fifo is empty
		empty_out         => tx_buf_empty_s,

		--! Fill level of fifo
		fill_lvl_out      => open
	);


end architecture udp_encoder_arc;


