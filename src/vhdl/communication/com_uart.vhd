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
--! @file com_uart.vhd
--! @brief Interface between UART and connected component labeling
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
use work.common.all;
use IEEE.math_real.all;


--! This entity uses a part of the uart2bus project from opencores
--! http://opencores.org/project,uart2bus to implement a uart communication
--! between the usb uart of the hightech board and the connected component
--! labeling. The uart don't use hardware handshake.
entity com_uart is
	port(
		--! Clock input
		clk_in            : in STD_LOGIC;
		--! Clock input 2x
		clk2x_in          : in STD_LOGIC;
		--! Reset input
		rst_in_n          : in STD_LOGIC;
		--! UART receive input
		uart_rx_in        : in STD_LOGIC;
		--! UART transeive output
		uart_tx_out       : out STD_LOGIC;
		--! LED1 used for RX
		USR_LED_1         : out STD_LOGIC;
		--! LED2 used for TX
		USR_LED_2         : out STD_LOGIC

	);
end entity com_uart;


architecture com_uart_arc of com_uart is
	constant C_BAUD_RATE     : natural := 115200;
	constant C_BAUD_GCD      : natural := 6400; --gcd(global_clock_freq, 16*baud_rate)
	-- baud_freq = 16*baud_rate / gcd(global_clock_freq, 16*baud_rate)
	constant C_BAUD_FREQ     : natural := 16*C_BAUD_RATE/C_BAUD_GCD;
	-- baud_limit = (global_clock_freq / gcd(global_clock_freq, 16*baud_rate)) - baud_freq
	constant C_BAUD_LIMIT    : natural := 100000000/C_BAUD_GCD - C_BAUD_FREQ;

	constant C_UART_SILENT   : natural := 2000;

	-- length of clock high after uart reset
	constant C_RST_CLKS      : natural := 100;

	type T_TX_STATE is (IDLE, FIFO_RD, TX, TX_START, SILENT);

	type T_RX_STATE is (IDLE, IMG_DATA, RESET);

	signal use_dut_s         : STD_LOGIC := '0';

	signal uart_clk_s        : STD_LOGIC;
	signal uart_tx_s         : STD_LOGIC_VECTOR(7 downto 0);
	signal uart_rx_s         : STD_LOGIC_VECTOR(7 downto 0);
	signal uart_rx_s_d       : STD_LOGIC_VECTOR(7 downto 0);
	signal uart_tx_valid_s   : STD_LOGIC;
	signal uart_rx_valid_s   : STD_LOGIC;
	signal uart_tx_busy_s    : STD_LOGIC;

	signal stall_out_s       : STD_LOGIC;
	signal box_valid_out_s   : STD_LOGIC;
	signal box_s_x_out_s     : STD_LOGIC_VECTOR(C_MAX_IMAGE_WIDTH - 1 downto 0);
	signal box_s_y_out_s     : STD_LOGIC_VECTOR(C_MAX_IMAGE_HEIGHT - 1 downto 0);
	signal box_e_x_out_s     : STD_LOGIC_VECTOR(C_MAX_IMAGE_WIDTH - 1 downto 0);
	signal box_e_y_out_s     : STD_LOGIC_VECTOR(C_MAX_IMAGE_HEIGHT - 1 downto 0);
	signal box_done_out_s    : STD_LOGIC;
	signal error_out_s       : STD_LOGIC;

	signal tx_empty_s        : STD_LOGIC;
	signal tx_fifo_rd_s      : STD_LOGIC;
	signal tx_wr_en_s        : STD_LOGIC;

	signal rx_rd_d_s         : STD_LOGIC_VECTOR(0 downto 0);
	signal rx_wr_en_s        : STD_LOGIC;
	signal rx_rd_done_s      : STD_LOGIC;
	signal rx_empty_out_s    : STD_LOGIC;
	signal rx_valid_out_s    : STD_LOGIC;

	signal rev_valid_in_s    : STD_LOGIC;

	signal wr_d_s            : STD_LOGIC_VECTOR(31 downto 0);
	signal uart_silent_cnt_s : UNSIGNED(integer(ceil(log2(real(C_UART_SILENT)))) downto 0);
	signal tx_state_s        : T_TX_STATE;
	signal uart_tx_full_s    : STD_LOGIC;

	signal uart_tx_out_s     : STD_LOGIC;

	signal rx_state_s        : T_RX_STATE;
	signal px_count_s        : unsigned(integer(ceil(log2(real(2**C_MAX_IMAGE_WIDTH * 2**C_MAX_IMAGE_HEIGHT)))) downto 0);


	signal rst_s						 : STD_LOGIC;
	signal rst_init_s_n      : STD_LOGIC;

	signal dut_rd_fifo_s     : STD_LOGIC;
	signal dut_rd_done_s     : STD_LOGIC;
	signal dut_box_s         : STD_LOGIC_VECTOR(data_table_entry_width - 1 downto 0);
	signal dut_pixel_s       : STD_LOGIC_VECTOR(1 downto 0);

	signal rst_cnt_s         : unsigned(integer(log2(ceil(real(C_RST_CLKS)))) - 1 downto 0);

begin


	USR_LED_1 <= uart_rx_in;
	USR_LED_2 <= not uart_tx_out_s;


	rx_rd_done_s <= (not rx_empty_out_s) and (not uart_tx_full_s) and rx_valid_out_s when use_dut_s = '0' else dut_rd_done_s;
	rx_wr_en_s <= '1' when uart_rx_valid_s = '1' and rx_state_s = IMG_DATA else '0';

	uart_tx_out <= uart_tx_out_s;
	rev_valid_in_s <= rx_rd_done_s and (not use_dut_s);

	rev_labeling_box : entity work.labeling_box PORT MAP(
		clk_in            => clk_in,
		rst_in            => rst_s,
		stall_out         => stall_out_s,
		stall_in          => uart_tx_full_s,
		data_valid_in     => rx_rd_done_s,
		px_in             => rx_rd_d_s(0),
		img_width_in      => std_logic_vector(to_unsigned(image_width, C_MAX_IMAGE_WIDTH+1)),
		img_height_in     => std_logic_vector(to_unsigned(image_height, C_MAX_IMAGE_HEIGHT+1)),
		box_valid_out     => box_valid_out_s,
		box_start_x_out   => box_s_x_out_s,
		box_start_y_out   => box_s_y_out_s,
		box_end_x_out     => box_e_x_out_s,
		box_end_y_out     => box_e_y_out_s,
		box_done_out      => box_done_out_s,
		error_out         => error_out_s
	);


	dut_rd_done_s <= dut_rd_fifo_s and (not rx_empty_out_s) and rx_valid_out_s;

	p_dut_in : process (clk_in)
	begin
		if rising_edge(clk_in) then
			dut_pixel_s(0) <= rx_rd_d_s(0);
			dut_pixel_s(1) <= '0';
			if rx_valid_out_s = '1' and rx_empty_out_s = '0' and dut_rd_fifo_s = '1' and use_dut_s = '1' then
				dut_pixel_s(1) <= '1';
			end if;
		end if;
	end process p_dut_in;

	dut_labeling : entity work.CCL_module PORT MAP(
		clk          	   => clk_in,
		clk2x            => clk2x_in,
		reset        	   => rst_s,
		pixel_stream 	   => dut_pixel_s,
		read_fifo    	   => dut_rd_fifo_s,
		obj_data		     => dut_box_s
	);


	rst : entity work.reset
	GENERIC MAP(
		G_RESET_ACTIVE    => '0'
	)
	PORT MAP(
		clk_in            => clk_in,
		rst_in            => rst_in_n,
		rst_out           => open,
		rst_out_n         => rst_init_s_n
	);

	uart : entity work.uartTop PORT MAP (   -- global signals
		clr               => rst_s,           -- global reset input
		clk               => clk_in,          -- global clock input
																					-- uart serial signals
		serIn             => uart_rx_in,      -- serial data input
		serOut            => uart_tx_out_s,   -- serial data output
																					-- transmit and receive internal interface signals
		txData            => uart_tx_s,       -- data byte to transmit
		newTxData         => uart_tx_valid_s, -- asserted to indicate that there is a new data byte for transmission
		txBusy            => uart_tx_busy_s,  -- signs that transmitter is busy
		rxData            => uart_rx_s,       -- data byte received
		newRxData         => uart_rx_valid_s, -- signs that a new byte was received
																					-- baud rate configuration register - see baudGen.vhd for details
		baudFreq          => std_logic_vector(to_unsigned(C_BAUD_FREQ, 12)), -- baud rate setting registers - see header description
		baudLimit         => std_logic_vector(to_unsigned(C_BAUD_LIMIT, 16)),-- baud rate setting registers - see header description
		baudClk           => uart_clk_s
	);




	p_delay_uart_rx_s : process (clk_in)
	begin
		if rising_edge(clk_in) then
			uart_rx_s_d <= uart_rx_s;
		end if;
	end process p_delay_uart_rx_s;


	rx_fifo : entity work.uart_rx_fifo
	PORT MAP (
		rst          => rst_s,
		wr_clk       => clk_in,
		rd_clk       => clk_in,
		din          => uart_rx_s,
		wr_en        => rx_wr_en_s,
		rd_en        => rx_rd_done_s,
		dout         => rx_rd_d_s,
		full         => open,
		overflow     => open,
		empty        => rx_empty_out_s,
		almost_empty => open,
		valid        => rx_valid_out_s,
		underflow    => open
	);

	p_rx_state : process(rst_init_s_n, clk_in)
	begin
		if rst_init_s_n = '0' then
			rx_state_s <= IDLE;
			rst_s <= '1';
		else
			if rising_edge(clk_in) then
				rst_s <= '0';
				case rx_state_s is
					when IDLE =>
						if uart_rx_valid_s = '1' and uart_rx_s = x"10" and uart_rx_valid_s = '1' then
							rx_state_s <= IMG_DATA;
							px_count_s <= (others => '0');
							use_dut_s <= '0';
						elsif uart_rx_valid_s = '1' and uart_rx_s = x"20" and uart_rx_valid_s = '1' then
							rx_state_s <= IMG_DATA;
							px_count_s <= (others => '0');
							use_dut_s <= '1';

						elsif uart_rx_valid_s = '1' and uart_rx_s = x"01" and uart_rx_valid_s = '1' then
							rst_s <= '1';
							rx_state_s <= RESET;
							rst_cnt_s <= to_unsigned(C_RST_CLKS, rst_cnt_s'length);
						end if;
					when IMG_DATA =>

						if uart_rx_valid_s = '1' then
							px_count_s <= px_count_s + 8;
						end if;

						if px_count_s >= 2**C_MAX_IMAGE_HEIGHT * 2**C_MAX_IMAGE_WIDTH - 1 then
							rx_state_s <= IDLE;
						end if;

					when RESET =>
						rst_s <= '1';
						rst_cnt_s <= rst_cnt_s -1;

						if rst_cnt_s = 0 then
							rx_state_s <= IDLE;
							rst_s <= '0';
						end if;
				end case;
			end if;
		end if;
	end process p_rx_state;


	wr_d_s(2*(box_s_x_out_s'length + box_s_y_out_s'length)-1 downto 0) <= box_s_x_out_s & box_s_y_out_s & box_e_x_out_s & box_e_y_out_s when use_dut_s = '0' else dut_box_s(dut_box_s'length -2 downto 0);

	p_tx_state : process (rst_s, clk_in)
	begin
		if rst_s = '1' then
			tx_state_s <= IDLE;
		elsif rising_edge(clk_in) and rst_s = '0' then
			case tx_state_s is
				when IDLE =>
					if tx_empty_s = '0' then
						tx_state_s <= FIFO_RD;
					end if;
				when FIFO_RD =>
					tx_state_s <= TX_START;
				when TX_START =>
					tx_state_s <= TX;
				when TX =>
					if uart_tx_busy_s = '0' then
						uart_silent_cnt_s <= to_unsigned(C_UART_SILENT, uart_silent_cnt_s'length);
						tx_state_s <= SILENT;
					end if;
				when SILENT =>
					uart_silent_cnt_s <= uart_silent_cnt_s - 1;
					if uart_silent_cnt_s = 0 then
						tx_state_s <= IDLE;
					end if;
			end case;
		end if;
	end process p_tx_state;

	tx_fifo_rd_s <= '1' when tx_state_s = FIFO_RD else '0';
	uart_tx_valid_s <= '1' when tx_state_s = TX_START else '0';
	tx_wr_en_s <= box_valid_out_s when use_dut_s = '0' else dut_box_s(dut_box_s'high);

	tx_fifo : entity work.uart_tx_fifo
	PORT MAP (
		rst       => rst_s,
		wr_clk    => clk_in,
		rd_clk    => clk_in,
		din       => wr_d_s,
		wr_en     => tx_wr_en_s,
		rd_en     => tx_fifo_rd_s,
		dout      => uart_tx_s,
		full      => uart_tx_full_s,
		empty     => tx_empty_s
	);

end architecture com_uart_arc;


