------------------------------------------------------------------------
-- Title      : GMII Testbench
-- Project    : Xilinx LogiCORE Virtex-6 Embedded Tri-Mode Ethernet MAC
-- File       : phy_tb.vhd
-- Version    : 2.2
-------------------------------------------------------------------------------
--
-- (c) Copyright 2004-2008 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
------------------------------------------------------------------------
-- Description: This testbench will exercise the PHY ports of the EMAC
--              to demonstrate the functionality.
------------------------------------------------------------------------
--
-- This testbench performs the following operations on the EMAC
-- and its design example:

--  - Four frames are pushed into the receiver from the PHY
--    interface (GMII/MII):
--    The first is of minimum length (Length/Type = Length = 46 bytes).
--    The second frame sets Length/Type to Type = 0x8000.
--    The third frame has an error inserted.
--    The fourth frame only sends 4 bytes of data: the remainder of the
--    data field is padded up to the minimum frame length i.e. 46 bytes.

--  - These frames are then parsed from the MAC into the MAC's design
--    example.  The design example provides a MAC client loopback
--    function so that frames which are received without error will be
--    looped back to the MAC transmitter and transmitted back to the
--    testbench.  The testbench verifies that this data matches that
--    previously injected into the receiver.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_xilinx_mac is
    port(
      ------------------------------------------------------------------
      -- GMII Interface
      ------------------------------------------------------------------
      gmii_txd              : in  std_logic_vector(7 downto 0);
      gmii_tx_en            : in  std_logic;
      gmii_tx_er            : in  std_logic;
      gmii_tx_clk           : in  std_logic;
      gmii_rxd              : out std_logic_vector(7 downto 0);
      gmii_rx_dv            : out std_logic;
      gmii_rx_er            : out std_logic;
      gmii_rx_clk           : out std_logic;
      gmii_col              : out std_logic;
      gmii_crs              : out std_logic;
      mii_tx_clk            : out std_logic;

      ------------------------------------------------------------------
      -- Test Bench Semaphores
      ------------------------------------------------------------------
      configuration_busy    : in  boolean;
      monitor_finished_1g   : out boolean;
      monitor_finished_100m : out boolean;
      monitor_finished_10m  : out boolean
      );
end tb_xilinx_mac;


architecture behavioral of tb_xilinx_mac is

	-- run first 0 .. C_PAUSE_AFTER_FRAME frames then pause for C_PAUSE_CYCLES
	constant C_PAUSE_AFTER_FRAME  : Natural := 12;
	constant C_PAUSE2_AFTER_FRAME : Natural := C_PAUSE_AFTER_FRAME + 7;
	constant C_PAUSE3_AFTER_FRAME : Natural := C_PAUSE2_AFTER_FRAME + 1;
	constant C_PAUSE_CYCLES       : Natural := 1800;
	constant C_PAUSE2_CYCLES      : Natural := 2800;
	constant C_PAUSE3_CYCLES      : Natural := 29800;

  ----------------------------------------------------------------------
  -- Types to support frame data
  ----------------------------------------------------------------------
  -- Tx Data and Data_valid record
  type data_typ is record
      data : bit_vector(7 downto 0);  -- data
      valid : bit;                    -- data_valid
      error : bit;                    -- data_error
  end record;
  type frame_of_data_typ is array (natural range <>) of data_typ;

  -- Tx Data, Data_valid and underrun record
  type frame_typ is record
      columns   : frame_of_data_typ(0 to 65);-- data field
      bad_frame : boolean;  -- does this frame contain an error?
  end record;
  type frame_typ_ary is array (natural range <>) of frame_typ;

  ----------------------------------------------------------------------
  -- Stimulus - Frame data
  ----------------------------------------------------------------------
  -- The following constant holds the stimulus for the testbench. It is
  -- an ordered array of frames, with frame 0 the first to be injected
  -- into the core receiver PHY interface by the testbench.
  ----------------------------------------------------------------------
  constant frame_data : frame_typ_ary := (
   -------------
   -- Frame 0
 	 -- Send an ARP request: who has 192.168.5.9? Tell 192.168.5.1
   -------------
    0          => (
      columns  => (
        0      => ( DATA => x"ff", VALID => '1', ERROR => '0'), --dest adr 
        1      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- src adr
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), -- type 0806 arp
       13      => ( DATA => x"06", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- hw adr type
       15      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"08", VALID => '1', ERROR => '0'), -- proto type
       17      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       18      => ( DATA => x"06", VALID => '1', ERROR => '0'), -- MAC size
       19      => ( DATA => x"04", VALID => '1', ERROR => '0'), -- IP size
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- arp req
       21      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- src mac
       23      => ( DATA => x"23", VALID => '1', ERROR => '0'),
       24      => ( DATA => x"18", VALID => '1', ERROR => '0'),
       25      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       27      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"c0", VALID => '1', ERROR => '0'), --src ip
       29      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       31      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- dest mac
       33      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       35      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       37      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- dest ip
       39      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       40      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       41      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       43      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       45      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

	 -------------
   -- Frame 1
 	 -- Send read HW_CFG with malformed header
   -------------
    1          => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"21", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=HW_CFG
       43      => ( DATA => x"03", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=1
       45      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
   -- Frame 2
 	 -- Send read HW_CFG
   -------------
    2          => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=HW_CFG
       43      => ( DATA => x"03", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=2
       45      => ( DATA => x"02", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),


  -------------
  -- Frame 2
	-- Send UDP IP pkt dst ip_address C0A80417, from port f49a to port 2694
  -------------
    3          => (
      columns  => (
        0      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => X"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => X"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => X"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => X"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => X"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => X"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => X"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => X"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => X"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => X"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => X"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => X"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => X"21", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => X"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => X"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => X"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => X"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => X"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => X"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => X"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => X"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => X"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => X"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => X"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => X"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => X"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => X"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => X"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => X"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => X"0d", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => X"8b", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => X"79", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => X"68", VALID => '1', ERROR => '0'), -- Type=HW_CFG
       43      => ( DATA => X"65", VALID => '1', ERROR => '0'),
       44      => ( DATA => X"6c", VALID => '1', ERROR => '0'), -- ID=6c6c
       45      => ( DATA => X"6c", VALID => '1', ERROR => '0'),
       46      => ( DATA => X"6f", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => X"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => X"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => X"00", VALID => '0', ERROR => '0')),

       -- Error this frame
      bad_frame => false),

  -------------
  -- Frame 3
	-- Send start stimuli=0x0
  -------------
    4          => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"28", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"15", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=STRStim
       43      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=4
       45      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=6
       47      => ( DATA => x"02", VALID => '1', ERROR => '0'), -- DATA_LENGTH
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- strstim
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- strstim
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- strstim
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- strstim
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- strstim
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- strstim
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),
		-------------
  -- Frame 5
	-- Send end stimuli=fff...
  -------------
    5          => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"28", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"15", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=ENDStim
       43      => ( DATA => x"06", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=5
       45      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=6
       47      => ( DATA => x"02", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"ff", VALID => '1', ERROR => '0'), -- PAD + Stim
       49      => ( DATA => x"ff", VALID => '1', ERROR => '0'), -- Stim
       50      => ( DATA => x"ff", VALID => '1', ERROR => '0'), -- Stim
       51      => ( DATA => x"ff", VALID => '1', ERROR => '0'), -- Stim
       52      => ( DATA => x"ff", VALID => '1', ERROR => '0'), -- Stim
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Stim
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),
			
   -------------
   -- Frame 6
 	 -- Send write restart
   -------------
    6          => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=RESET
       43      => ( DATA => x"07", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=6
       45      => ( DATA => x"06", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),



   -------------
	 -- Frame 7
	 -- Send UDP IP pkt dst ip_address c0a80509, from port f49a to port 2694
   -------------
   7          => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Adr
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'),
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'),
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => x"21", VALID => '1', ERROR => '0'),
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'),
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'),
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'),
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'),
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       37      => ( DATA => x"94", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       39      => ( DATA => x"0d", VALID => '1', ERROR => '0'),
       40      => ( DATA => x"8b", VALID => '1', ERROR => '0'),
       41      => ( DATA => x"79", VALID => '1', ERROR => '0'),
       42      => ( DATA => x"68", VALID => '1', ERROR => '0'),
       43      => ( DATA => x"65", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"6c", VALID => '1', ERROR => '0'),
       45      => ( DATA => x"6c", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"6f", VALID => '1', ERROR => '0'),
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),
			
   -------------
	 -- Frame 8
	 -- Send UDP IP pkt dst ip_address C0A80417, from port f49a to port 2694
   -------------

		   8          => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Adr
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'),
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'),
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => x"21", VALID => '1', ERROR => '0'),
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'),
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'),
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'),
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'),
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       37      => ( DATA => x"94", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       39      => ( DATA => x"0d", VALID => '1', ERROR => '0'),
       40      => ( DATA => x"8b", VALID => '1', ERROR => '0'),
       41      => ( DATA => x"79", VALID => '1', ERROR => '0'),
       42      => ( DATA => x"42", VALID => '1', ERROR => '0'),
       43      => ( DATA => x"65", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"6c", VALID => '1', ERROR => '0'),
       45      => ( DATA => x"6c", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"6f", VALID => '1', ERROR => '0'),
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
	 -- Frame 9
	 -- Send UDP IP pkt dst ip_address bc, from port f49a to port 2694
   -------------

		   9          => (
      columns  => (
        0      => ( DATA => x"ff", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Adr
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'),
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'),
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => x"21", VALID => '1', ERROR => '0'),
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'),
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'),
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
       31      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"ff", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'),
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       37      => ( DATA => x"94", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       39      => ( DATA => x"0d", VALID => '1', ERROR => '0'),
       40      => ( DATA => x"8b", VALID => '1', ERROR => '0'),
       41      => ( DATA => x"79", VALID => '1', ERROR => '0'),
       42      => ( DATA => x"68", VALID => '1', ERROR => '0'),
       43      => ( DATA => x"65", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"6c", VALID => '1', ERROR => '0'),
       45      => ( DATA => x"6c", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"6f", VALID => '1', ERROR => '0'),
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
	 -- Frame 10
	 -- Send UDP IP pkt dst ip_address C0A80417, from port f49a to port 2694 with data x43 to trig tx to unknown IP";
   -------------

		   10          => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Adr
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'),
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'),
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => x"21", VALID => '1', ERROR => '0'),
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'),
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'),
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'),
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'),
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       37      => ( DATA => x"94", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       39      => ( DATA => x"0d", VALID => '1', ERROR => '0'),
       40      => ( DATA => x"8b", VALID => '1', ERROR => '0'),
       41      => ( DATA => x"79", VALID => '1', ERROR => '0'),
       42      => ( DATA => x"43", VALID => '1', ERROR => '0'),
       43      => ( DATA => x"65", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"6c", VALID => '1', ERROR => '0'),
       45      => ( DATA => x"6c", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"6f", VALID => '1', ERROR => '0'),
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
	 -- Frame 12
	 -- Send UDP IP pkt dst ip_address c0a80509, from port f49a to port 2694
   -------------

		   11          => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Adr
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'),
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'),
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       17      => ( DATA => x"21", VALID => '1', ERROR => '0'),
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'),
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'),
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'),
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'),
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       37      => ( DATA => x"94", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       39      => ( DATA => x"0d", VALID => '1', ERROR => '0'),
       40      => ( DATA => x"8b", VALID => '1', ERROR => '0'),
       41      => ( DATA => x"79", VALID => '1', ERROR => '0'),
       42      => ( DATA => x"68", VALID => '1', ERROR => '0'),
       43      => ( DATA => x"65", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"6c", VALID => '1', ERROR => '0'),
       45      => ( DATA => x"6c", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"6f", VALID => '1', ERROR => '0'),
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
   -- Frame 13
 	 -- Send cntrd
   -------------
    12          => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=RESET
       43      => ( DATA => x"0d", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=7
       45      => ( DATA => x"07", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),



   -------------
   -- Frame 1 after Pause
 	 -- Send read ERROR_COUNT
   -------------
    C_PAUSE_AFTER_FRAME + 1 => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=ERRORCNT
       43      => ( DATA => x"08", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=7
       45      => ( DATA => x"07", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),
   -------------
   -- Frame 2 after pause
 	 -- Send read ERROR_STORED
   -------------
    C_PAUSE_AFTER_FRAME + 2  => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=ERRORstr
       43      => ( DATA => x"09", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=8
       45      => ( DATA => x"08", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),
   -------------
   -- Frame 3
 	 -- Send read ERRORS_DROPED
   -------------
    C_PAUSE_AFTER_FRAME + 3   => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=ERRORDRP
       43      => ( DATA => x"0a", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=9
       45      => ( DATA => x"09", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),
   -------------
   -- Frame 4 after pause
 	 -- Send read next error
   -------------
    C_PAUSE_AFTER_FRAME + 4   => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=getERR
       43      => ( DATA => x"0b", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=10
       45      => ( DATA => x"0a", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
   -- Frame 5 after pause
 	 -- Send read next error
   -------------
    C_PAUSE_AFTER_FRAME + 5 => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=getERR
       43      => ( DATA => x"0b", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=10
       45      => ( DATA => x"0a", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
   -- Frame 6 after pause
 	 -- Send read next error
   -------------
    C_PAUSE_AFTER_FRAME + 6 => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=ERR_RD
       43      => ( DATA => x"0c", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=11
       45      => ( DATA => x"0b", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
   -- Frame 7 after pause
 	 -- Send read next error
   -------------
    C_PAUSE_AFTER_FRAME + 7 => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=getERR
       43      => ( DATA => x"0b", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=12
       45      => ( DATA => x"0c", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
   -- Frame 1 after 1. pause
 	 -- Send write restart
   -------------
    C_PAUSE2_AFTER_FRAME + 1 => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=RESET
       43      => ( DATA => x"07", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=6
       45      => ( DATA => x"06", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
   -- Frame 1 after 2. pause
 	 -- Send read next error
   -------------
    C_PAUSE3_AFTER_FRAME + 1   => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=getERR
       43      => ( DATA => x"0b", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=10
       45      => ( DATA => x"0a", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),
   -------------
   -- Frame 2 after 2. pause
 	 -- Send read next error
   -------------
    C_PAUSE3_AFTER_FRAME + 2 => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=ERR_RD
       43      => ( DATA => x"0c", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=11
       45      => ( DATA => x"0b", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),


      -- No error in this frame
      bad_frame => false),

   -------------
   -- Frame 2 after 3. pause
 	 -- Send read next error
   -------------
    C_PAUSE3_AFTER_FRAME + 3 => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=getERR
       43      => ( DATA => x"0b", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=10
       45      => ( DATA => x"0a", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
   -- Frame 4 after 2. pause
 	 -- Send read next error
   -------------
    C_PAUSE3_AFTER_FRAME + 4 => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=ERR_RD
       43      => ( DATA => x"0c", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=11
       45      => ( DATA => x"0b", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),

      -- No error in this frame
      bad_frame => false),

   -------------
   -- Frame 5 after pause2
 	 -- Send read next error
   -------------
    C_PAUSE3_AFTER_FRAME + 5 => (
      columns  => (
        0      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Dest Adr
        1      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        2      => ( DATA => x"20", VALID => '1', ERROR => '0'),
        3      => ( DATA => x"21", VALID => '1', ERROR => '0'),
        4      => ( DATA => x"22", VALID => '1', ERROR => '0'),
        5      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        6      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Source Address
        7      => ( DATA => x"23", VALID => '1', ERROR => '0'),
        8      => ( DATA => x"18", VALID => '1', ERROR => '0'),
        9      => ( DATA => x"29", VALID => '1', ERROR => '0'),
       10      => ( DATA => x"26", VALID => '1', ERROR => '0'),
       11      => ( DATA => x"7c", VALID => '1', ERROR => '0'),
       12      => ( DATA => x"08", VALID => '1', ERROR => '0'), --type 0800 IP
       13      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       14      => ( DATA => x"45", VALID => '1', ERROR => '0'), -- IP HEADER
       15      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       16      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       17      => ( DATA => x"22", VALID => '1', ERROR => '0'), -- LENGTH
       18      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       19      => ( DATA => x"7a", VALID => '1', ERROR => '0'),
       20      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       21      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       22      => ( DATA => x"80", VALID => '1', ERROR => '0'),
       23      => ( DATA => x"11", VALID => '1', ERROR => '0'), -- Proto: UDP
       24      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- IP HEADER CS
       25      => ( DATA => x"00", VALID => '1', ERROR => '0'),
       26      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- SRC IP
       27      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       28      => ( DATA => x"05", VALID => '1', ERROR => '0'),
       29      => ( DATA => x"01", VALID => '1', ERROR => '0'),
       30      => ( DATA => x"c0", VALID => '1', ERROR => '0'), -- DEST IP
       31      => ( DATA => x"a8", VALID => '1', ERROR => '0'),
       32      => ( DATA => x"04", VALID => '1', ERROR => '0'),
       33      => ( DATA => x"17", VALID => '1', ERROR => '0'),
       34      => ( DATA => x"f4", VALID => '1', ERROR => '0'), -- SRC PORT
       35      => ( DATA => x"9a", VALID => '1', ERROR => '0'),
       36      => ( DATA => x"D8", VALID => '1', ERROR => '0'), -- DST PORT
       37      => ( DATA => x"20", VALID => '1', ERROR => '0'),
       38      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- LENGTH
       39      => ( DATA => x"0e", VALID => '1', ERROR => '0'), -- LENGTH
       40      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       41      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- UDP CS
       42      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- Type=getERR
       43      => ( DATA => x"0b", VALID => '1', ERROR => '0'),
       44      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- ID=12
       45      => ( DATA => x"0c", VALID => '1', ERROR => '0'),
       46      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- DATA_LENGTH=0
       47      => ( DATA => x"00", VALID => '1', ERROR => '0'), 
       48      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       49      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       50      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       51      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       52      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       53      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       54      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       55      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       56      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       57      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       58      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       59      => ( DATA => x"00", VALID => '1', ERROR => '0'), -- PADDING
       others  => ( DATA => x"00", VALID => '0', ERROR => '0')),


      -- No error in this frame
      bad_frame => false)


);


  ----------------------------------------------------------------------
  -- CRC engine
  ----------------------------------------------------------------------
  function calc_crc (data : in std_logic_vector;
                     fcs  : in std_logic_vector)
  return std_logic_vector is

     variable crc          : std_logic_vector(31 downto 0);
     variable crc_feedback : std_logic;
  begin

    crc := not fcs;

    for I in 0 to 7 loop
      crc_feedback      := crc(0) xor data(I);

      crc(4 downto 0)   := crc(5 downto 1);
      crc(5)            := crc(6)  xor crc_feedback;
      crc(7 downto 6)   := crc(8 downto 7);
      crc(8)            := crc(9)  xor crc_feedback;
      crc(9)            := crc(10) xor crc_feedback;
      crc(14 downto 10) := crc(15 downto 11);
      crc(15)           := crc(16) xor crc_feedback;
      crc(18 downto 16) := crc(19 downto 17);
      crc(19)           := crc(20) xor crc_feedback;
      crc(20)           := crc(21) xor crc_feedback;
      crc(21)           := crc(22) xor crc_feedback;
      crc(22)           := crc(23);
      crc(23)           := crc(24) xor crc_feedback;
      crc(24)           := crc(25) xor crc_feedback;
      crc(25)           := crc(26);
      crc(26)           := crc(27) xor crc_feedback;
      crc(27)           := crc(28) xor crc_feedback;
      crc(28)           := crc(29);
      crc(29)           := crc(30) xor crc_feedback;
      crc(30)           := crc(31) xor crc_feedback;
      crc(31)           :=             crc_feedback;
    end loop;

    -- return the CRC result
    return not crc;

  end calc_crc;


  -- Delay to provide setup and hold timing at the GMII/MII.
  constant dly : time := 2 ns;


  -- Testbench signals
  signal mii_tx_clk_int      : std_logic := '0';
  signal mii_tx_clk100       : std_logic := '0';
  signal mii_tx_clk10        : std_logic := '0';

  signal gmii_rx_clk_int     : std_logic := '0';
  signal gmii_rx_clk1000     : std_logic := '0';
  signal gmii_rx_clk100      : std_logic := '0';
  signal gmii_rx_clk10       : std_logic := '0';

  -- Testbench control signals
  signal current_speed       : string(1 to 6);

  signal clkmux_en_100       : std_logic := '0';
  signal clkmux_en_10        : std_logic := '0';


begin  -- behavioral

  -- Currently not used in this testbench.
  gmii_col <= '0';
  gmii_crs <= '0';

  mii_tx_clk <= mii_tx_clk_int;

  ----------------------------------------------------------------------
  -- gmii_rx_clk clock driver
  ----------------------------------------------------------------------

  -- Drives gmii_rx_clk at 125 MHz for 1000Mb/s operation
  p_gmii_rx_clk1000 : process
  begin
    gmii_rx_clk_int <= '0';
    wait for 20 ns;
    loop
      wait for 4 ns;
      gmii_rx_clk_int <= '1';
      wait for 4 ns;
      gmii_rx_clk_int <= '0';
    end loop;
  end process p_gmii_rx_clk1000;

  gmii_rx_clk <= gmii_rx_clk_int;


  ----------------------------------------------------------------------
  -- Simulus process
  ------------------
  -- Send four frames through the MAC and Design Example
  --      -- frame 0 = minimum length frame
  --      -- frame 1 = type frame
  --      -- frame 2 = errored frame
  --      -- frame 3 = padded frame
  ----------------------------------------------------------------------
  p_stimulus : process
    variable current_col : natural := 0;  -- Column counter within frame
    variable fcs         : std_logic_vector(31 downto 0);
    variable frm_high    : natural;
		variable frm_low     : natural;
  begin

  -- Initialise GMII
  gmii_rxd      <= "00000000";
  gmii_rx_dv    <= '0';
  gmii_rx_er    <= '0';

  -- Initialize clock mux enables
  clkmux_en_100 <= '0';
  clkmux_en_10  <= '0';

  -- Wait for the configuration to initialise the MAC
  wait until configuration_busy;
  wait until not configuration_busy;

  current_speed <= "1gig  ";

  clkmux_en_100 <= '0';
  clkmux_en_10  <= '0';

  ------------------------------------
  -- Send frames at 1Gb/s speed
  ------------------------------------

  wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';

	frm_low := 0;
	frm_high := C_PAUSE_AFTER_FRAME;

	for i in 1 to 4 loop
		for current_frame in frm_low to frm_high loop

			assert false
			report "EMAC: Sending Frame " & integer'image(current_frame) & " at 1Gb/s" & cr
			severity note;

		-- Adding the preamble field
			for j in 0 to 7 loop
				gmii_rxd   <= "01010101" after dly;
				gmii_rx_dv <= '1' after dly;
				gmii_rx_er <= '0' after dly;
				wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';
			end loop;

		-- Adding the Start of Frame Delimiter (SFD)
			gmii_rxd   <= "11010101" after dly;
			gmii_rx_dv <= '1' after dly;
			wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';

		-- Sending the MAC frame
			fcs         := (others => '0'); -- reset the FCS field
			current_col := 0;
			gmii_rxd    <= to_stdlogicvector(frame_data(current_frame).columns(current_col).data) after dly;
			fcs         := calc_crc(to_stdlogicvector(frame_data(current_frame).columns(current_col).data), fcs);
			gmii_rx_dv  <= to_stdUlogic(frame_data(current_frame).columns(current_col).valid) after dly;
			gmii_rx_er  <= to_stdUlogic(frame_data(current_frame).columns(current_col).error) after dly;

			wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';

			current_col   := current_col + 1;
		-- loop over columns in frame.
			while frame_data(current_frame).columns(current_col).valid /= '0' loop
			-- send one column of data
				gmii_rxd    <= to_stdlogicvector(frame_data(current_frame).columns(current_col).data) after dly;
				fcs         := calc_crc(to_stdlogicvector(frame_data(current_frame).columns(current_col).data), fcs);
				gmii_rx_dv  <= to_stdUlogic(frame_data(current_frame).columns(current_col).valid) after dly;
				gmii_rx_er  <= to_stdUlogic(frame_data(current_frame).columns(current_col).error) after dly;
				current_col := current_col + 1;
				wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';  -- wait for next clock tick

			end loop;

		-- Send the FCS.
			for j in 0 to 3 loop
				gmii_rxd   <= fcs(((8*j)+7) downto (8*j)) after dly;
			--gmii_rxd <= x"00" after dly;
				gmii_rx_dv <= '1' after dly;
				gmii_rx_er <= '0' after dly;
				wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';  -- wait for next clock tick
			end loop;

		-- Clear the data lines.
			gmii_rxd   <= (others => '0') after dly;
			gmii_rx_dv <=  '0' after dly;
			gmii_rx_er <=  '0' after dly;

		-- Adding the minimum Interframe gap for a receiver (8 idles)
			for j in 0 to 7 loop
				wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';
			end loop;

		end loop;  -- current_frame

		-- wait for next frame burst
		if i = 1 then
			for j in 0 to C_PAUSE_CYCLES loop
				wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';
			end loop;
			frm_low := C_PAUSE_AFTER_FRAME + 1;
			frm_high := C_PAUSE2_AFTER_FRAME;
		elsif i = 2 then
			for j in 0 to C_PAUSE2_CYCLES loop
				wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';
			end loop;
			frm_low := C_PAUSE2_AFTER_FRAME + 1;
			frm_high := C_PAUSE3_AFTER_FRAME;
		else
			for j in 0 to C_PAUSE3_CYCLES loop
				wait until gmii_rx_clk_int'event and gmii_rx_clk_int = '1';
			end loop;
			frm_low := C_PAUSE3_AFTER_FRAME + 1;
			frm_high := frame_data'high;
		end if;


	end loop; -- second frame burst

	-- Our work here is done
	wait;

end process p_stimulus;


	----------------------------------------------------------------------
	-- Monitor process
	------------------
	-- This process checks the data coming out of the
	-- transmitter to make sure that it matches that inserted into the
	-- receiver.
	--      -- frame 0 = minimum length frame
	--      -- frame 1 = type frame
	--      -- frame 2 = errored frame
	--      -- frame 3 = padded frame
	--
	-- Repeated for all 3 speeds.
	----------------------------------------------------------------------
p_monitor : process
	variable f                  : frame_typ;       -- temporary frame variable
	variable current_col        : natural   := 0;  -- Column counter
	variable current_frame      : natural   := 0;
	variable fcs                : std_logic_vector(31 downto 0);
begin  -- process p_monitor

	monitor_finished_1g   <= false;
	monitor_finished_100m <= false;
	monitor_finished_10m  <= false;

		-- first, get synced up with the TX clock
	wait until gmii_tx_clk'event and gmii_tx_clk = '1';
	wait until gmii_tx_clk'event and gmii_tx_clk = '1';

		------------------------------------
		-- Compare the frames at 1Gb/s speed
		------------------------------------

	wait until gmii_tx_clk'event and gmii_tx_clk = '1';

		-- loop over all the frames in the stimulus vector
	loop
		current_col := 0;

			-- If the current frame had an error inserted then it would have been
			-- dropped by the FIFO in the design example.  Therefore move
			-- immediately on to the next frame.
		while frame_data(current_frame).bad_frame loop
			current_frame := current_frame + 1;
			if current_frame = frame_data'high + 1 then
				exit;
			end if;
		end loop;

			-- There are only 4 frames in this test.
		if current_frame = frame_data'high + 1 then
			exit;
		end if;

			-- Parse over the preamble field
		while gmii_tx_en /= '1' or gmii_txd = "01010101" loop
			wait until gmii_tx_clk'event and gmii_tx_clk = '1';
		end loop;

		assert false
		report "EMAC: Comparing Frame " & integer'image(current_frame) & " at 1Gb/s" & cr
		severity note;

			-- Parse over the Start of Frame Delimiter (SFD)
		if (gmii_txd /= "11010101") then
			assert false
			report "EMAC: SFD not present" & cr
			severity error;
		end if;
		fcs         := (others => '0'); -- reset the FCS field
		wait until gmii_tx_clk'event and gmii_tx_clk = '1';

			-- frame has started, loop over columns of frame
		while ((frame_data(current_frame).columns(current_col).valid)='1') loop

			assert (gmii_tx_en = to_stdulogic(frame_data(current_frame).columns(current_col).valid))
			report "EMAC: gmii_tx_en incorrect" & cr
			severity error;

			if gmii_tx_en = '1' then

						-- The transmitted Destination Address was the Source Address of the injected frame
				if current_col < 6 then
					fcs := calc_crc(to_stdlogicvector(frame_data(current_frame).columns(current_col+6).data), fcs);
					assert (gmii_txd(7 downto 0) =
					to_stdlogicvector(frame_data(current_frame).columns(current_col+6).data(7 downto 0)))
					report "EMAC: gmii_txd incorrect" & cr
					severity error;

						-- The transmitted Source Address was the Destination Address of the injected frame
				elsif current_col >= 6 and current_col < 12 then
					fcs := calc_crc(to_stdlogicvector(frame_data(current_frame).columns(current_col-6).data), fcs);
					assert (gmii_txd(7 downto 0) =
					to_stdlogicvector(frame_data(current_frame).columns(current_col-6).data(7 downto 0)))
					report "EMAC: gmii_txd incorrect" & cr
					severity error;

						-- for remainder of frame
				else
					fcs := calc_crc(to_stdlogicvector(frame_data(current_frame).columns(current_col).data), fcs);
					assert (gmii_txd(7 downto 0) =
					to_stdlogicvector(frame_data(current_frame).columns(current_col).data(7 downto 0)))
					report "EMAC: gmii_txd incorrect" & cr
					severity error;
				end if;
			end if;
				-- wait for next column of data
			current_col        := current_col + 1;
			wait until gmii_tx_clk'event and gmii_tx_clk = '1';
		end loop;  -- while data valid

			-- Check the FCS
			-- Having checked all data columns, txd must contain FCS.
		for j in 0 to 3 loop
			assert (gmii_txd = fcs(((8*j)+7) downto (8*j)))
			report "EMAC: gmii_txd incorrect during FCS field" & cr
			severity error;

			wait until gmii_tx_clk'event and gmii_tx_clk = '1';
		end loop;  -- j

			-- move to the next frame
		if current_frame = frame_data'high then
			exit;
		else
			current_frame := current_frame + 1;
		end if;

	end loop;

	monitor_finished_1g   <= true;

		-- Our work here is done
	wait;

end process p_monitor;


end behavioral;
