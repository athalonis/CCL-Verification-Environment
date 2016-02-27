-------------------------------------------------------
--! @file top_com_uart.vhd
--! @brief Interface with dcm for doubling clk
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-06-04
-------------------------------------------------------

--! Use standard library
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_com_uart is
	port(
		--! Clock input
		clk_in            : in STD_LOGIC;
		--! Reset input
		rst_in_n          : in STD_LOGIC;
		--! UART receive input
		uart_rx_in        : in STD_LOGIC;
		--! UART transeive output
		uart_tx_out       : out STD_LOGIC;
		--! LED1 used for RX
		USR_LED_1         : out STD_LOGIC;
		--! LED2 used for TX
		USR_LED_2         : out STD_LOGIC;
		--! LED3 used for DCM locked
		USR_LED_3         : out STD_LOGIC
	);
end entity top_com_uart;

architecture top_com_uart_arc of top_com_uart is
	signal clk_100_s     : STD_LOGIC;
	signal clk_200_s     : STD_LOGIC;
	signal dcm_locked_s  : STD_LOGIC;
	signal dcm_rst_s     : STD_LOGIC := '0';
	signal rst_out_s_n   : STD_LOGIC;
	signal rst_cnt_s     : unsigned(8 downto 0) := (others => '1');
begin
	USR_LED_3 <= dcm_locked_s;

	rst_out_s_n <= (not dcm_rst_s) and dcm_locked_s and rst_in_n;

	--p_rst : process (clk_100_s)
	--begin
	--	if rising_edge(clk_100_s) then
	--		if rst_cnt_s > 0 then
	--			rst_cnt_s <= rst_cnt_s - 1;
	--			dcm_rst_s <= '1';
	--		else
	--			dcm_rst_s <= '0';
	--		end if;
	--	end if;
	--end process p_rst;

	--my_clk_2x : entity work.clk_2x
	--port map (
		-- Clock in ports
	--	CLK_IN1          => clk_in,
		-- Clock out ports
	--	CLK_200          => clk_200_s,
	--	CLK_100          => clk_100_s,
		-- Status and control signals
	--	RESET            => dcm_rst_s,
	--	LOCKED           => dcm_locked_s
	--);
	
	my_clk_2x : entity work.dcm_clk
   port map(
		CLKIN_IN        => clk_in, 
      CLKIN_IBUFG_OUT => clk_100s,
      CLK2X_OUT       => clk_200s
	);

	my_com_uart : entity work.com_uart
	port map(
		--! Clock input
		clk_in            => clk_100_s,
		--! Clock input 2x
		clk2x_in          => clk_200_s,
		--! Reset input
		rst_in_n          => rst_out_s_n,
		--! UART receive input
		uart_rx_in        => uart_rx_in,
		--! UART transeive output
		uart_tx_out       => uart_tx_out,
		--! LED1 used for RX
		USR_LED_1         => USR_LED_1,
		--! LED2 used for TX
		USR_LED_2         => USR_LED_2
	);
end architecture top_com_uart_arc;






