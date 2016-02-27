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
--! @file tb_com_uart.vhd
--! @brief testbench for the connected component through the uart
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-07-24
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
use ieee.std_logic_1164.all;
--! Use numeric std
use IEEE.numeric_std.all;
use work.pbm_package.all;
use work.types.all;

--! Reads in a PPM file and sends the image over the uart
entity tb_com_uart is

end tb_com_uart;

architecture Behavioral of tb_com_uart is
	constant C_INFILE         : String := "../../img/sim_in.pbm";
	constant C_HALF_PER_FAST  : Time := 2.5 ns; -- 200MHz
	constant C_HALF_PER       : Time := 2*C_HALF_PER_FAST; -- 100MHz
	constant C_BAUD           : REAL := 115200.0;
	constant C_BAUD_ERROR     : REAL := 3.0;

	--! sendSerial generates the tx signal of a uart the procedure is part of
	--! OpenCores uart2bus testbench  (file: communication/uart2bus/trunk/vhdl/bench/uart2BusTop_txt_tb.vhd)
	--! http://opencores.org/project,uart2bus
	--! The uart2bus is licensed under the BSD license
	procedure sendSerial(data : integer; baud : in real; parity : in integer; stopbit : in real; bitnumber : in integer; baudError : in real; signal txd : out std_logic) is
		variable shiftreg : std_logic_vector(7 downto 0);
		variable bitTime  : time;
	begin
		bitTime := 1000 ms / (baud + baud * baudError / 100.0);
		shiftreg := std_logic_vector(to_unsigned(data, shiftreg'length));
		txd <= '0';
		wait for bitTime;
		for index in 0 to bitnumber loop
			txd <= shiftreg(index);
			wait for bitTime;
		end loop;
		txd <= '1';
		wait for stopbit * bitTime;
	end procedure;

	--! recvSerial generates the tx signal of a uart the procedure is part of
	--! OpenCores uart2bus testbench  (file: communication/uart2bus/trunk/vhdl/bench/uart2BusTop_txt_tb.vhd)
	--! http://opencores.org/project,uart2bus
	--! The uart2bus is licensed under the BSD license
	procedure recvSerial( signal rxd : in std_logic; baud : in real; parity : in integer; stopbit : in real; bitnumber : in integer; baudError : in real; signal data : inout std_logic_vector(7 downto 0)) is

		variable bitTime  : time;

	begin
		bitTime := 1000 ms / (baud + baud * baudError / 100.0);
		wait until (rxd = '0');
		wait for bitTime / 2;
		wait for bitTime;
		for index in 0 to bitnumber loop
			data <= rxd & data(7 downto 1);
			wait for bitTime;
		end loop;
		wait for stopbit * bitTime;
	end procedure;


	Signal clk_in_s           : STD_LOGIC := '0';
	Signal clk_en_s           : STD_LOGIC := '1';

	Signal uart_rx_s          : STD_LOGIC;
	Signal uart_tx_s          : STD_LOGIC;

	Signal recv_data_s        : STD_LOGIC_VECTOR(7 downto 0);

begin

	dut_com_uart : entity work.top_com_uart
	port map(
		clk_in           => clk_in_s,
		rst_in_n         => '1',
		uart_rx_in       => uart_rx_s,
		uart_tx_out      => uart_tx_s,
		USR_LED_1        => open,
		USR_LED_2        => open
	);



	clk_p : process
	begin
		while clk_en_s = '1' loop
			clk_in_s <= not clk_in_s;
			wait for C_HALF_PER;
		end loop;
		wait;
	end process clk_p;


	p_send : process
		variable img_width_v  : natural;
		variable img_height_v : natural;
		variable image        : image_type;
		variable x_v          : natural;
		variable y_v          : natural;
		variable send_v       : unsigned(7 downto 0);

		-- clocks to wait after last pixel in before stop simulation
		constant C_END_MAX    : natural := 200;
		variable end_v        : integer := C_END_MAX;

	begin
		read_pbm(C_INFILE, image, img_width_v, img_height_v);

		assert img_width_v <= 2**C_MAX_IMAGE_WIDTH report "Image bigger than max width" severity error;
		assert img_height_v <= 2**C_MAX_IMAGE_HEIGHT report "Image bigger than max height" severity error;

		wait for C_HALF_PER*214;
		wait for C_HALF_PER*0.6; --start sending asynchron

		sendSerial(1, C_BAUD, 0, 1.0, 7, C_BAUD_ERROR, uart_rx_s); --send reset
		--sendSerial(16, C_BAUD, 0, 1.0, 7, C_BAUD_ERROR, uart_rx_s); --start image
		sendSerial(32, C_BAUD, 0, 1.0, 7, C_BAUD_ERROR, uart_rx_s); --start image

		y_v := 1;
		x_v := 0;
		while end_v > 0 loop 

			send_v := (others => '0');
			for i in send_v'range loop
				if x_v < 2**C_MAX_IMAGE_WIDTH then
					x_v := x_v + 1;
				else
					x_v := 1;
					y_v := y_v + 1;
				end if;

				if y_v <= img_height_v and x_v <= img_width_v then
					send_v(i) := image(y_v)(x_v);
				elsif y_v >= 2**C_MAX_IMAGE_HEIGHT then
					end_v := end_v - 1;
				end if;
			end loop;

			if y_v > 2**C_MAX_IMAGE_HEIGHT then
				wait for  1000 ms / (C_BAUD + C_BAUD * C_BAUD_ERROR / 100.0)*9;
			else
				sendSerial(to_integer(send_v), C_BAUD, 0, 1.0, 7, C_BAUD_ERROR, uart_rx_s); 
			end if;

				if uart_tx_s =  '0' then
					end_v := C_END_MAX;
				end if;
		end loop;

		sendSerial(1, C_BAUD, 0, 1.0, 7, C_BAUD_ERROR, uart_rx_s); --send reset
		
		wait for C_HALF_PER*C_END_MAX;

		clk_en_s <= '0';

		-- severtiy failure to stop the Simulation
		report "Simulation ended" severity failure;
		wait;
	end process p_send;

	p_recv : process
		variable recv_pkg_v : unsigned(31 downto 0);
	begin
		wait for C_HALF_PER*14 ;

		while true loop
			for i in 3 downto 0 loop
				recvSerial(uart_tx_s, C_BAUD, 0, 1.0, 7, C_BAUD_ERROR, recv_data_s);
				recv_pkg_v((i+1)*8-1 downto i*8) := unsigned(recv_data_s);
			end loop;
			report "Box: (" & INTEGER'IMAGE(TO_INTEGER(recv_pkg_v(T_X_START))) & ", "
			& INTEGER'IMAGE(TO_INTEGER(recv_pkg_v(T_Y_START))) & "), ("
			& INTEGER'IMAGE(TO_INTEGER(recv_pkg_v(T_X_END))) & ", "
			& INTEGER'IMAGE(TO_INTEGER(recv_pkg_v(T_Y_END))) & ")";
		end loop;
	end process p_recv;
end architecture Behavioral;

