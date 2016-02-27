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
--! @file top_udp.vhd
--! @brief Top Module of Comparator Architecture with UDP
--! @author Benjamin Bässler
--! @email ccl@xunit.de
--! @date 2013-11-04
--------------------------------------------------------------------------------

--! Use standard library
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use work.axi.all;
use work.ipv4_types.all;
use work.arp_types.all;
use work.types.all;


entity top_udp is
	port (
		-- System signals
		------------------
		rst_in_n            : in std_logic; -- asynchronous reset
		clk_in              : in std_logic; --100MHz
		led_out             : out std_logic_vector(7 downto 0);

		-- GMII Interface
		-----------------
		phy_resetn          : out std_logic;
		gmii_txd            : out std_logic_vector(7 downto 0);
		gmii_tx_en          : out std_logic;
		gmii_tx_er          : out std_logic;
		gmii_tx_clk         : out std_logic;
		gmii_rxd            : in  std_logic_vector(7 downto 0);
		gmii_rx_dv          : in  std_logic;
		gmii_rx_er          : in  std_logic;
		gmii_rx_clk         : in  std_logic;
		gmii_col            : in  std_logic;
		gmii_crs            : in  std_logic;
		mii_tx_clk          : in  std_logic
	);
end top_udp;

--! @brief Implements the Top Module of Comparator Architecture
--! with communication over Ethernet Port with UDP
architecture top_udp_arc of top_udp is
	CONSTANT C_MAX_RX_DATA_SIZE : natural := C_MAX_SEND_DATA;

	--ip 192.168.4.23
	Signal our_ip_address_s  : std_logic_vector (31 downto 0) := x"C0A80417";
	Signal our_mac_address_s : std_logic_vector (47 downto 0) := x"A0FEEA72BEEF";

	Signal udp_tx_start_s    : std_logic;
	Signal udp_txi_s         : udp_tx_type;
	Signal udp_tx_result_s   : std_logic_vector (1 downto 0);
	Signal udp_tx_d_out_rd_s : std_logic;

	Signal udp_rx_start_s    : std_logic;
	Signal udp_rxo_s         : udp_rx_type;

	Signal ip_rx_hdr_s       : ipv4_rx_header_type;

	Signal control_s         : udp_control_type:= (others => (others =>(others => '0')));

	Signal arp_pkt_count_s   : std_logic_vector (7 downto 0);
	Signal ip_pkt_count_s    : std_logic_vector (7 downto 0);

	Signal mac_tx_tdata_s    : std_logic_vector (7 downto 0);
	Signal mac_tx_tvalid_s   : std_logic;
	Signal mac_tx_tready_s   : std_logic;
	Signal mac_tx_tfirst_s   : std_logic;
	Signal mac_tx_tlast_s    : std_logic;

	Signal mac_rx_tdata_s    : std_logic_vector (7 downto 0);
	Signal mac_rx_tvalid_s   : std_logic;
	Signal mac_rx_tready_s   : std_logic;
	Signal mac_rx_tlast_s    : std_logic;

	-- Decoder signals
	signal dec_valid_s       : std_logic;
	signal dec_write_s       : std_logic;
	signal dec_type_s        : unsigned(15 downto 0);
	signal dec_id_s          : unsigned(15 downto 0);
	signal dec_length_s      : unsigned(15 downto 0);
	signal dec_data_s        : unsigned(C_MAX_RX_DATA_SIZE - 1 downto 0);
	signal dec_hdr_err_s     : std_logic;

	-- Encoder signals
	signal enc_valid_s       : std_logic;
	signal enc_type_s        : unsigned(15 downto 0);
	signal enc_id_s          : unsigned(15 downto 0);
	signal enc_length_s      : unsigned(15 downto 0);
	signal enc_data_s        : unsigned(C_MAX_RX_DATA_SIZE-1 downto 0);

	-- internal reset signals
	signal int_rst_s         : std_logic;
	signal int_rst_n_s       : std_logic;
	signal rst_in_s          : std_logic;

	-- dcm signals
	signal dcm_locked_s      : std_logic;
	signal clk125_s          : std_logic;
	signal clk200_s          : std_logic;
	signal clk_dut_s         : std_logic;

	signal send_err_s        : std_logic;
	signal send_lost_s       : std_logic;

	signal ver_run_s         : std_logic;


begin

	phy_resetn <= int_rst_n_s;
	rst_in_s <= rst_in_n or dcm_locked_s;

	led_out(2 downto 1) <= "00";
	led_out(7) <= send_err_s;
	led_out(6) <= '0'; --gmii_col;
	led_out(5) <= '0'; --gmii_crs;
	led_out(4) <= '0'; --mii_tx_clk;
	led_out(3) <= send_lost_s;
	led_out(0) <= ver_run_s;


	dcm : entity work.clk_udp
	port map(
	-- Clock in ports
  CLK_IN       => clk_in,

	-- Clock out ports
  CLK_125_OUT  => clk125_s,
  CLK_200_OUT  => clk200_s,
	CLK_DUT_OUT  => clk_dut_s,
  -- Status and control signals
  RESET        => '0',
  LOCKED       => dcm_locked_s
 );


	rst : entity work.reset
	generic map(
		--! How long should the reset be active
		G_CLOCKS        => 60,

		--! Reset active signal for input
		G_RESET_ACTIVE  => '0'
	)
	port map(
		--! Clock input
		clk_in          => clk125_s, 
		--! Reset input
		rst_in          => rst_in_s,
		--! Reset output
		rst_out         => int_rst_s,
		--! Inverted reset output
		rst_out_n       => int_rst_n_s
	);



	udp_stack: entity work.UDP_Complete_nomac
	generic map(
			CLOCK_FREQ      => 125000000, -- freq of data_in_clk -- needed to timout cntr
			ARP_TIMEOUT     => 60, -- ARP response timeout (s)
			ARP_MAX_PKT_TMO => 5, -- # wrong nwk pkts received before set error
			MAX_ARP_ENTRIES => 255 -- max entries in the ARP store
			)
    port map(
			-- UDP TX signals
			udp_tx_start    => udp_tx_start_s,
			udp_txi         => udp_txi_s,
			udp_tx_result   => udp_tx_result_s,
			udp_tx_data_out_ready => udp_tx_d_out_rd_s,

			-- UDP RX signals
			udp_rx_start    => udp_rx_start_s,
			udp_rxo         => udp_rxo_s,

			-- IP RX signals
			ip_rx_hdr       => ip_rx_hdr_s,

			-- system signals
			rx_clk          => clk125_s,
			tx_clk          => clk125_s,
			reset           => int_rst_s,
			our_ip_address  => our_ip_address_s,
			our_mac_address => our_mac_address_s,
			control         => control_s,

			-- status signals
			arp_pkt_count   => arp_pkt_count_s,
			ip_pkt_count    => ip_pkt_count_s,

			-- MAC Transmitter
			mac_tx_tdata    => mac_tx_tdata_s,
			mac_tx_tvalid   => mac_tx_tvalid_s,
			mac_tx_tready   => mac_tx_tready_s,
			mac_tx_tfirst   => mac_tx_tfirst_s,
			mac_tx_tlast    => mac_tx_tlast_s,

			-- MAC Receiver
			mac_rx_tdata    => mac_rx_tdata_s,
			mac_rx_tvalid   => mac_rx_tvalid_s,
			mac_rx_tready   => mac_rx_tready_s,
			mac_rx_tlast    => mac_rx_tlast_s
		);

	udp_decoder : entity work.udp_decoder
	generic map(
		G_MAX_DATA_SIZE => C_MAX_RX_DATA_SIZE
	)
	port map (
		-- System signals
		------------------
		rst_in             => int_rst_s,
		rx_clk_in          => clk125_s,

		-- UDP RX signals
	  -----------------
		udp_rx_start_in    => udp_rx_start_s,
		udp_rx_in          => udp_rxo_s,

		ip_rx_hdr_in       => ip_rx_hdr_s,

		-- Decoder outputs
	  -- read/write command
		dec_valid_out        => dec_valid_s,
		write_out            => dec_write_s,
		type_out             => dec_type_s,
		id_out               => dec_id_s,
		length_out           => dec_length_s,
		data_out             => dec_data_s,

		header_error_out     => dec_hdr_err_s

	);


	udp_encoder : entity work.udp_encoder
	generic map(
		G_MAX_DATA_SIZE => C_MAX_RX_DATA_SIZE
	)
	port map(
		-- System signals
		------------------
		rst_in              => int_rst_s,
		tx_clk_in           => clk125_s,

	  -- tried to send malformed header data
		invalid_data_out    => send_err_s,

		data_lost_out       => send_lost_s,

		-- UDP TX signals
	  -----------------
		udp_tx_start_out	  => udp_tx_start_s,
		udp_tx_out			    => udp_txi_s,
		udp_tx_result_out	  => udp_tx_result_s,
		udp_tx_data_rdy_in  => udp_tx_d_out_rd_s,

		-- Encoder inputs
	  -- read/write command
		enc_valid_in        => enc_valid_s,
		type_in             => enc_type_s,
		id_in               => enc_id_s,
		length_in           => enc_length_s,
		data_in             => enc_data_s,

		udp_rx_header_in    => udp_rxo_s.hdr 

	);

	cu_sel_cam : if C_CAM_IF generate
		cu : entity work.cam_control_unit
		generic map(
			G_MAX_DATA_SIZE => C_MAX_SEND_DATA,
			--! Number of Comparators
			G_COMP_INST     => C_COMP_INST,

			--! Image width
			-- value from ccl_dut common.vhd
			G_IMG_WIDTH     => C_IMAGE_WIDTH,

			--! Image height
			-- value from ccl_dut common.vhd
			G_IMG_HEIGHT    => C_IMAGE_HEIGHT,

			--! Error Storage
			G_ERR_SIZE      => C_ERR_BUF_SIZE
		)
		port map (
			-- System signals
			------------------
			rst_in             => int_rst_s,
			rx_clk_in          => clk125_s,
			clk_dut_in         => clk_dut_s,

			-- Decoded data
			-- read/write command
			dec_valid_in       => dec_valid_s,
			write_in           => dec_write_s,
			type_in            => dec_type_s,
			id_in              => dec_id_s,
			length_in          => dec_length_s,
			data_in            => dec_data_s,
			header_error_in    => dec_hdr_err_s,

			-- Coder data
			enc_valid_out      => enc_valid_s,
			type_out           => enc_type_s,
			id_out             => enc_id_s,
			length_out         => enc_length_s,
			data_out           => enc_data_s,

			run_out            => ver_run_s
		);
	end generate cu_sel_cam;



	cu_sel : if not C_CAM_IF generate
		cu : entity work.control_unit
		generic map(
		--! Size of data part in communication
			G_MAX_DATA_SIZE => C_MAX_RX_DATA_SIZE,
		--! Number of Comparators
			G_COMP_INST     => C_COMP_INST
		)
		port map(
		-- System signals
		------------------
			rst_in             => int_rst_s,
			rx_clk_in          => clk125_s,

		-- Decoded data
		-- read/write command
			dec_valid_in       => dec_valid_s,
			write_in           => dec_write_s,
			type_in            => dec_type_s,
			id_in              => dec_id_s,
			length_in          => dec_length_s,
			data_in            => dec_data_s,
			header_error_in    => dec_hdr_err_s,

		-- Coder data
			enc_valid_out      => enc_valid_s,
			type_out           => enc_type_s,
			id_out             => enc_id_s,
			length_out         => enc_length_s,
			data_out           => enc_data_s,

		--! status flag
			ver_run_out        => ver_run_s

		);
	end generate cu_sel;




	emac_fifo_block : entity work.v6_emac_v2_2_fifo_block
	port map(

		-- MAC Receiver Sideband
		------------------------------------------
		rx_statistics_vector => open,
		rx_statistics_valid  => open,
		rx_mac_aclk          => open,
		rx_reset					 	 => open,

		-- MAC Receiver (AXI-S) Interface
		------------------------------------------
		rx_fifo_clock         => clk125_s,
		rx_fifo_resetn        => int_rst_n_s,
		rx_axis_fifo_tready   => mac_rx_tready_s,
		rx_axis_fifo_tdata    => mac_rx_tdata_s,
		rx_axis_fifo_tvalid   => mac_rx_tvalid_s,
		rx_axis_fifo_tlast    => mac_rx_tlast_s,


		-- MAC Transmitter Sideband
		---------------------------------------------
		tx_reset             => open,
		tx_ifg_delay         => x"00",
		tx_statistics_vector => open,
		tx_statistics_valid  => open,

		-- MAC Transmitter (AXI-S) Interface
		---------------------------------------------
		tx_fifo_clock         => clk125_s,
		tx_fifo_resetn        => int_rst_n_s,
		tx_axis_fifo_tdata    => mac_tx_tdata_s,
		tx_axis_fifo_tvalid   => mac_tx_tvalid_s,
		tx_axis_fifo_tready   => mac_tx_tready_s,
		tx_axis_fifo_tlast    => mac_tx_tlast_s,

		-- Flow Control Interface
		pause_req            => '0',
		pause_val            => x"0000",

		-- Reference clock for IDELAYCTRL's
		refclk               => clk200_s,

		-- GMII Interface
		gtx_clk              => clk125_s, --125MHz
		gmii_txd             => gmii_txd,
		gmii_tx_en           => gmii_tx_en,
		gmii_tx_er           => gmii_tx_er,
		gmii_tx_clk          => gmii_tx_clk,
		gmii_rxd             => gmii_rxd,
		gmii_rx_dv           => gmii_rx_dv,
		gmii_rx_er           => gmii_rx_er,
		gmii_rx_clk          => gmii_rx_clk,
		gmii_col             => gmii_col,
		gmii_crs             => gmii_crs,
		mii_tx_clk           => mii_tx_clk,

		-- asynchronous reset
		glbl_rstn            => int_rst_n_s,
		tx_axi_rstn          => '1',
		rx_axi_rstn          => '1'


	);

end top_udp_arc;
