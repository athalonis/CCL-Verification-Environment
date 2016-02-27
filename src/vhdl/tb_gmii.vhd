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
--! @file tb_gmii.vhd
--! @brief gmii testbench adopted from the opencores udp ip stack
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-11-13
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.axi.all;
use work.ipv4_types.all;
use work.arp_types.all;

entity tb_gmii is
end tb_gmii;

architecture behavior of tb_gmii is

	signal gmii_txd_s    : std_logic_vector(7 downto 0);
	signal gmii_tx_en_s  : std_logic;
	signal gmii_tx_er_s  : std_logic;
	signal gmii_tx_clk_s : std_logic;
	signal gmii_rxd_s    : std_logic_vector(7 downto 0);
	signal gmii_rx_dv_s  : std_logic;
	signal gmii_rx_er_s  : std_logic;
	signal gmii_rx_clk_s : std_logic;
	signal gmii_col_s    : std_logic;
	signal gmii_crs_s    : std_logic;
	signal mii_tx_clk_s  : std_logic;

	signal cfg_busy_s    : boolean;
	signal m_1g_done_s   : boolean;
	signal m_100m_done_s : boolean;
	signal m_10m_done_s  : boolean;

	signal reset_s_n     : std_logic := '1';

	signal clk_int       : std_logic;
	signal clk200_int    : std_logic;
	signal clk250_int    : std_logic;

begin

	my_top : entity work.top_udp
	port map(
		-- System signals
		------------------
		rst_in_n            => reset_s_n,
		clk_in              => clk_int,

		led_out             => open,

		-- GMII Interface
		-----------------
		phy_resetn          => open,
		gmii_txd            => gmii_txd_s,
		gmii_tx_en          => gmii_tx_en_s,
		gmii_tx_er          => gmii_tx_er_s,
		gmii_tx_clk         => gmii_tx_clk_s,
		gmii_rxd            => gmii_rxd_s,
		gmii_rx_dv          => gmii_rx_dv_s,
		gmii_rx_er          => gmii_rx_er_s,
		gmii_rx_clk         => gmii_rx_clk_s,
		gmii_col            => gmii_col_s,
		gmii_crs            => gmii_crs_s,
		mii_tx_clk          => mii_tx_clk_s
	);

	xilinx_tb : entity work.tb_xilinx_mac
  port map(
      ------------------------------------------------------------------
      -- GMII Interface
      ------------------------------------------------------------------
      gmii_txd         => gmii_txd_s,
      gmii_tx_en       => gmii_tx_en_s,
      gmii_tx_er       => gmii_tx_er_s,
      gmii_tx_clk      => gmii_tx_clk_s,
      gmii_rxd         => gmii_rxd_s,
      gmii_rx_dv       => gmii_rx_dv_s,
      gmii_rx_er       => gmii_rx_er_s,
      gmii_rx_clk      => gmii_rx_clk_s,
      gmii_col         => gmii_col_s,
      gmii_crs         => gmii_crs_s,
      mii_tx_clk       => mii_tx_clk_s,

      ------------------------------------------------------------------
      -- Test Bench Semaphores
      ------------------------------------------------------------------
      configuration_busy    => cfg_busy_s,
      monitor_finished_1g   => m_1g_done_s,
      monitor_finished_100m => m_100m_done_s,
      monitor_finished_10m  => m_10m_done_s
      );


	-- Clock process definitions
	clk_process :process
	begin
		clk_int <= '0';
		wait for 10 ns;
		loop
			clk_int <= '1';
			wait for 5 ns;
			clk_int <= '0';
			wait for 5 ns;
		end loop;
	end process;




	-- Stimulus process
	stim_proc: process
	begin
		cfg_busy_s <= TRUE;

		reset_s_n <= '0';
		wait for 5000 ns;

		for j in 0 to 49 loop
			wait until rising_edge(clk_int);
		end loop;

		cfg_busy_s <= FALSE;

		wait until m_1g_done_s;
		cfg_busy_s <= TRUE;

		report "--- end of tests ---";
		wait;
	end process;

END;
