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
--! @file udp_decoder.vhd
--! @brief decodes the received udp packets
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-11-25
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use work.axi.all;
use work.ipv4_types.all;
use work.arp_types.all;

entity udp_decoder is
	generic(
		G_MAX_DATA_SIZE : natural := 128
	);
	port (
		-- System signals
		------------------
		rst_in              : in std_logic; -- asynchronous reset
		rx_clk_in           : in std_logic;

		-- UDP RX signals
	  -----------------
		udp_rx_start_in     : in std_logic;
		udp_rx_in           : in udp_rx_type;

		ip_rx_hdr_in        : in ipv4_rx_header_type;

		-- Decoder outputs
	  -- read/write command
		dec_valid_out        : out std_logic;
		write_out            : out std_logic;
		type_out             : out unsigned(15 downto 0);
		id_out               : out unsigned(15 downto 0);
		length_out           : out unsigned(15 downto 0);
		data_out             : out unsigned(G_MAX_DATA_SIZE - 1 downto 0);
		header_error_out     : out std_logic
	  
);
end udp_decoder;


architecture udp_decoder_arc of udp_decoder is

	CONSTANT C_UDP_PORT     : unsigned(15 downto 0) := x"D820"; --55328
	
	type T_STATE is (IDLE, DECODING, VALID, INVALID, IDLE_WAIT);
	signal rx_state_s : T_STATE;


	-- counts the data bytes of udp packet
	signal udp_cnt_s  : unsigned(15 downto 0);
	signal udp_data_s : unsigned(G_MAX_DATA_SIZE - 1 downto 0);

	signal write_s    : std_logic;
	signal type_s     : unsigned(15 downto 0);
	signal id_s       : unsigned(15 downto 0);
	signal length_s   : unsigned(15 downto 0);
	

begin


	--! @brief RX state process
	--! STATES:
	--!         IDLE       wait for new UDP Data (rising udp_rx.hdr.is_valid = 1)
	--!         DECODING   decode receiving data
	--!         VALID      received data valid and write to output
	--!         IDLE_WAIT  wait for udp_rx.hdr.is_valid = 0
	--!         INVALID    data_length of UDP to short/big wrong port or broadcast
	--!
	p_rx_state : process (rx_clk_in, rst_in) is
	begin
		if rst_in = '1' then
			--reset
			rx_state_s <= IDLE;
		elsif rising_edge(rx_clk_in) then

			case rx_state_s is
				when IDLE =>
					if udp_rx_in.hdr.is_valid = '1' then

						-- UDP DATA length needs to be at least 6 bytes
						-- only listen on the C_UDP_PORT
						-- Broadcasts should not be interpreted
						if unsigned(udp_rx_in.hdr.data_length) < 6 or
							 unsigned(udp_rx_in.hdr.data_length) > G_MAX_DATA_SIZE or
							 ip_rx_hdr_in.is_broadcast = '1' or
						   unsigned(udp_rx_in.hdr.dst_port) /= C_UDP_PORT
							 then

							rx_state_s <= INVALID;
						else
							rx_state_s <= DECODING;
						end if;
					end if;

				when DECODING =>
					if udp_rx_in.data.data_in_last = '1' then
						rx_state_s <= VALID;
					end if;

				when VALID =>
					rx_state_s <= IDLE_WAIT;

				when IDLE_WAIT =>
					if udp_rx_in.hdr.is_valid = '0' then
						rx_state_s <= IDLE;
					end if;

				when INVALID =>
					rx_state_s <= IDLE_WAIT;
			end case;

		end if; --clk
	end process p_rx_state;

	--! @brief store UDP Packet
	p_rx_udp : process (rx_clk_in, rst_in) is
	begin
		if rst_in = '1' then
			udp_cnt_s <= (others => '0');
			dec_valid_out <= '0';
			header_error_out <= '0';
			write_out <= '0';

		elsif rising_edge(rx_clk_in) then
			-- default output
			dec_valid_out <= '0';

		  if rx_state_s = IDLE then
				udp_cnt_s <= (others => '0');

			elsif rx_state_s = DECODING then

				--only read data if valid
				-- and prevent storing invalid data
				if udp_rx_in.data.data_in_valid = '1' and
				   udp_cnt_s <= unsigned(udp_rx_in.hdr.data_length) then

				  -- Packet format:
					--  0     7     15 16    23    31 32     39   47 48
					-- +--------------+--------------+--------------+------...-------
					-- |     type     |      id      |    length    |      data     |
					-- +--------------+--------------+--------------+------...-------

					case udp_cnt_s is
						when x"0000" =>
							write_s <= udp_rx_in.data.data_in(7);
							type_s(15 downto 8) <= "0" & unsigned(udp_rx_in.data.data_in(6 downto 0));
						when x"0001" =>
							type_s(7 downto 0) <= unsigned(udp_rx_in.data.data_in);
						when x"0002" =>
							id_s(15 downto 8) <= unsigned(udp_rx_in.data.data_in);
						when x"0003" =>
							id_s(7 downto 0) <= unsigned(udp_rx_in.data.data_in);
						when x"0004" =>
							length_s(15 downto 8) <= unsigned(udp_rx_in.data.data_in);
						when x"0005" =>
							length_s(7 downto 0) <= unsigned(udp_rx_in.data.data_in);
						when others =>
							--store data part
							udp_data_s(G_MAX_DATA_SIZE-1 - to_integer(udp_cnt_s-6)*8 downto
							G_MAX_DATA_SIZE-1 -	to_integer(udp_cnt_s-6)*8 - 7) 
							<= unsigned(udp_rx_in.data.data_in);
					end case;

					--increment data counter
					udp_cnt_s <= udp_cnt_s + 1;

				end if; -- udp valid


			elsif rx_state_s = VALID then
				write_out <= write_s;
				type_out <= type_s;
				id_out <= id_s;
				length_out <= length_s;
				data_out <= udp_data_s;
				dec_valid_out <= '1';

				if udp_cnt_s < 6 then
					header_error_out <= '1';
				else
					header_error_out <= '0';
				end if;

			end if; -- state
		end if; --clk
	end process p_rx_udp;

end architecture udp_decoder_arc;
