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



entity sim_gmii is
	port (
			-- System signals
			------------------
		rst_in_n            : in  std_logic; -- asynchronous reset
		clk_in              : in  std_logic;

		-- GMII Interface
		-----------------
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
		gmii_gtx_clk        : out std_logic;
		mii_tx_clk          : in  std_logic
	);
end sim_gmii;

architecture sim_gmii_arc of sim_gmii is
begin
end sim_gmii_arc;

