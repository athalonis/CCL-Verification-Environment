--------------------------------------------------------------------------------
-- Copyright (c) 1995-2011 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: O.87xd
--  \   \         Application: netgen
--  /   /         Filename: v6_emac_v2_2.vhd
-- /___/   /\     Timestamp: Mon Dec  9 15:05:01 2013
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -w -sim -ofmt vhdl ./tmp/_cg/v6_emac_v2_2.ngc ./tmp/_cg/v6_emac_v2_2.vhd 
-- Device	: 6vlx240tff1759-2
-- Input file	: ./tmp/_cg/v6_emac_v2_2.ngc
-- Output file	: ./tmp/_cg/v6_emac_v2_2.vhd
-- # of Entities	: 1
-- Design Name	: v6_emac_v2_2
-- Xilinx	: /import/pas.local/sw/Xilinx/13.4/ISE_DS/ISE/
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------


-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity v6_emac_v2_2 is
  port (
    rx_axi_clk : in STD_LOGIC := 'X'; 
    glbl_rstn : in STD_LOGIC := 'X'; 
    rx_axis_mac_tuser : out STD_LOGIC; 
    gmii_col : in STD_LOGIC := 'X'; 
    gmii_crs : in STD_LOGIC := 'X'; 
    gmii_tx_en : out STD_LOGIC; 
    tx_axi_rstn : in STD_LOGIC := 'X'; 
    gmii_tx_er : out STD_LOGIC; 
    tx_collision : out STD_LOGIC; 
    rx_axi_rstn : in STD_LOGIC := 'X'; 
    tx_axis_mac_tlast : in STD_LOGIC := 'X'; 
    tx_retransmit : out STD_LOGIC; 
    tx_axis_mac_tuser : in STD_LOGIC := 'X'; 
    rx_axis_mac_tvalid : out STD_LOGIC; 
    rx_statistics_valid : out STD_LOGIC; 
    tx_statistics_valid : out STD_LOGIC; 
    rx_axis_mac_tlast : out STD_LOGIC; 
    speed_is_10_100 : out STD_LOGIC; 
    gtx_clk : in STD_LOGIC := 'X'; 
    rx_reset_out : out STD_LOGIC; 
    tx_reset_out : out STD_LOGIC; 
    tx_axi_clk : in STD_LOGIC := 'X'; 
    gmii_rx_dv : in STD_LOGIC := 'X'; 
    gmii_rx_er : in STD_LOGIC := 'X'; 
    tx_axis_mac_tready : out STD_LOGIC; 
    tx_axis_mac_tvalid : in STD_LOGIC := 'X'; 
    pause_req : in STD_LOGIC := 'X'; 
    tx_statistics_vector : out STD_LOGIC_VECTOR ( 31 downto 0 ); 
    pause_val : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
    rx_statistics_vector : out STD_LOGIC_VECTOR ( 27 downto 0 ); 
    gmii_rxd : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    tx_ifg_delay : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    tx_axis_mac_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 ); 
    rx_axis_mac_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 ); 
    gmii_txd : out STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end v6_emac_v2_2;

architecture STRUCTURE of v6_emac_v2_2 is
  signal N0 : STD_LOGIC; 
  signal N1 : STD_LOGIC; 
  signal NlwRenamedSig_OI_rx_reset_out : STD_LOGIC; 
  signal NlwRenamedSig_OI_rx_statistics_valid : STD_LOGIC; 
  signal NlwRenamedSig_OI_tx_reset_out : STD_LOGIC; 
  signal NlwRenamedSig_OI_tx_axis_mac_tready : STD_LOGIC; 
  signal NlwRenamedSig_OI_tx_retransmit : STD_LOGIC; 
  signal NlwRenamedSig_OI_tx_collision : STD_LOGIC; 
  signal NlwRenamedSig_OI_tx_statistics_valid : STD_LOGIC; 
  signal NlwRenamedSig_OI_speed_is_10_100 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_n0246_inv1_rstpot_514 : STD_LOGIC; 
  signal BU2_N64 : STD_LOGIC; 
  signal BU2_N62 : STD_LOGIC; 
  signal BU2_N58 : STD_LOGIC; 
  signal BU2_N56 : STD_LOGIC; 
  signal BU2_N53 : STD_LOGIC; 
  signal BU2_N52 : STD_LOGIC; 
  signal BU2_N47 : STD_LOGIC; 
  signal BU2_N46 : STD_LOGIC; 
  signal BU2_N44 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_7_Q : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_6_Q : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_5_Q : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_4_Q : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_3_Q : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_2_Q : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_1_Q : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_0_Q : STD_LOGIC; 
  signal BU2_N28 : STD_LOGIC; 
  signal BU2_N26 : STD_LOGIC; 
  signal BU2_N24 : STD_LOGIC; 
  signal BU2_N22 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_retransmit_tx_state_3_OR_17_o : STD_LOGIC; 
  signal BU2_N20 : STD_LOGIC; 
  signal BU2_U0_INT_RX_STATISTICS_VALID_rstpot1_490 : STD_LOGIC; 
  signal BU2_U0_INT_TX_STATISTICS_VALID_rstpot1_489 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_collision_r_rstpot_488 : STD_LOGIC; 
  signal BU2_U0_rx_axi_shim_rx_frame_complete_rstpot_487 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_force_end_rstpot_486 : STD_LOGIC; 
  signal BU2_U0_rx_axi_shim_rx_mac_tvalid_rstpot_485 : STD_LOGIC; 
  signal BU2_U0_rx_axi_shim_rx_mac_tlast_rstpot_484 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_no_burst_rstpot_483 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_rstpot_482 : STD_LOGIC; 
  signal BU2_U0_SYNC_TX_RESET_I_R4_rstpot_481 : STD_LOGIC; 
  signal BU2_U0_SYNC_RX_RESET_I_R4_rstpot_480 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_two_byte_tx_rstpot_479 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_valid_glue_set_478 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_ignore_packet_glue_set_477 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_early_deassert_glue_set_476 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_early_underrun_475 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_early_underrun_glue_set_474 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_force_burst2_473 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_force_burst2_glue_set_472 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_force_assert_glue_set_471 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_force_burst1_470 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_force_burst1_glue_set_469 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_underrun_glue_set_468 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tlast_reg_467 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tlast_reg_glue_set_466 : STD_LOGIC; 
  signal BU2_U0_MATCH_FRAME_INT_glue_set_465 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_collision_r_464 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_tx_en1 : STD_LOGIC; 
  signal BU2_N16 : STD_LOGIC; 
  signal BU2_U0_MATCH_FRAME_INT_461 : STD_LOGIC; 
  signal BU2_N14 : STD_LOGIC; 
  signal BU2_N12 : STD_LOGIC; 
  signal BU2_N10 : STD_LOGIC; 
  signal BU2_N8 : STD_LOGIC; 
  signal BU2_N6 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_force_end_455 : STD_LOGIC; 
  signal BU2_N4 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o3_452 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o2_451 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o1_450 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_In : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o5_448 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o2 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_early_deassert_446 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_force_assert_OR_22_o_445 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_force_assert_444 : STD_LOGIC; 
  signal BU2_N2 : STD_LOGIC; 
  signal BU2_U0_rx_axi_shim_next_rx_state_1_rx_state_1_OR_15_o12 : STD_LOGIC; 
  signal BU2_U0_rx_axi_shim_rx_frame_complete_441 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_3_tx_state_3_OR_37_o : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_valid_two_byte_tx_OR_34_o : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_two_byte_tx_438 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In2 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_no_burst_435 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_ignore_packet_434 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o1_433 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_suppress_r_431 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_suppress : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_r_429 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r_428 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_r2_411 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_r1_410 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_er_r2_409 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_er_r1_408 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_r_tx_stats_byte_valid_AND_6_o : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_Result_0_1 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_inv : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_Result_1_1 : STD_LOGIC; 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_from_mac_inv : STD_LOGIC; 
  signal BU2_U0_rx_axi_shim_next_rx_state_1_rx_enable_AND_16_o_394 : STD_LOGIC; 
  signal BU2_U0_rx_axi_shim_rx_state_1_rx_enable_AND_17_o : STD_LOGIC; 
  signal BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_382 : STD_LOGIC; 
  signal BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_In : STD_LOGIC; 
  signal BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_380 : STD_LOGIC; 
  signal BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_In : STD_LOGIC; 
  signal BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_REQ_reg_362 : STD_LOGIC; 
  signal BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd2_361 : STD_LOGIC; 
  signal BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd2_In : STD_LOGIC; 
  signal BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359 : STD_LOGIC; 
  signal BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_In_358 : STD_LOGIC; 
  signal BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0048 : STD_LOGIC; 
  signal BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0056_inv : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_ack_reg_339 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_mac_tready_reg_338 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_gate_tready_336 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_PWR_20_o_tx_enable_MUX_106_o : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_0_dpot_334 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_1_dpot_333 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_2_dpot_332 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_3_dpot_331 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_4_dpot_330 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_5_dpot_329 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_6_dpot_328 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_7_dpot_327 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_enable_reg_326 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_29_o : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_323 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_In_322 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd9_321 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_28_o : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd8_319 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_70_o : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_317 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_PWR_20_o_equal_74_o : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd6_315 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd6_In : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd5_313 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_71_o : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd3_311 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd3_In_310 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_309 : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_72_o : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_0_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_1_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_2_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_3_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_4_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_5_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_6_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_7_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_8_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_9_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_10_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_11_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_12_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_13_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_14_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_15_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_16_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_17_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_18_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_19_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_20_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_21_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_22_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_23_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_24_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_25_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_26_Q : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_27_Q : STD_LOGIC; 
  signal BU2_U0_SYNC_TX_RESET_I_R3_247 : STD_LOGIC; 
  signal BU2_U0_SYNC_TX_RESET_I_R2_246 : STD_LOGIC; 
  signal BU2_U0_SYNC_TX_RESET_I_R1_245 : STD_LOGIC; 
  signal BU2_U0_INT_TX_RST_ASYNCH : STD_LOGIC; 
  signal BU2_U0_SYNC_RX_RESET_I_R3_243 : STD_LOGIC; 
  signal BU2_U0_SYNC_RX_RESET_I_R2_242 : STD_LOGIC; 
  signal BU2_U0_SYNC_RX_RESET_I_R1_241 : STD_LOGIC; 
  signal BU2_U0_INT_RX_RST_ASYNCH : STD_LOGIC; 
  signal BU2_U0_RX_BAD_FRAME : STD_LOGIC; 
  signal BU2_U0_INT_GLBL_RST : STD_LOGIC; 
  signal BU2_U0_TX_STATS_SHIFT : STD_LOGIC; 
  signal BU2_U0_GMII_TX_ER_INT : STD_LOGIC; 
  signal BU2_U0_RX_STATS_SHIFT_VLD : STD_LOGIC; 
  signal BU2_U0_TX_STATS_SHIFT_VLD : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_data_valid_186 : STD_LOGIC; 
  signal BU2_U0_RX_CLIENT_CE : STD_LOGIC; 
  signal BU2_U0_tx_axi_shim_tx_underrun_184 : STD_LOGIC; 
  signal BU2_U0_PAUSE_REQ_INT : STD_LOGIC; 
  signal BU2_U0_RX_GOOD_FRAME : STD_LOGIC; 
  signal BU2_U0_GMII_TX_EN_INT : STD_LOGIC; 
  signal BU2_U0_RX_DATA_VALID : STD_LOGIC; 
  signal BU2_U0_TX_ACK : STD_LOGIC; 
  signal BU2_U0_TX_STATS_BYTEVLD : STD_LOGIC; 
  signal BU2_U0_TX_AXI_CLK_OUT_INT2 : STD_LOGIC; 
  signal BU2_mdc_out : STD_LOGIC; 
  signal BU2_mdio_tri : STD_LOGIC; 
  signal BU2_mdio_out : STD_LOGIC; 
  signal BU2_txcharisk : STD_LOGIC; 
  signal BU2_txchardispval : STD_LOGIC; 
  signal BU2_txchardispmode : STD_LOGIC; 
  signal BU2_syncacqstatus : STD_LOGIC; 
  signal BU2_powerdown : STD_LOGIC; 
  signal BU2_mgttxreset : STD_LOGIC; 
  signal BU2_mgtrxreset : STD_LOGIC; 
  signal BU2_loopbackmsb : STD_LOGIC; 
  signal BU2_encommaalign : STD_LOGIC; 
  signal BU2_aninterrupt : STD_LOGIC; 
  signal BU2_tx_axi_clk_out : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTMIIMRDY_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_DCRHOSTDONEIR_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACCLIENTRXFRAMEDROP_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACCLIENTRXDVLDMSW_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACCLIENTRXSTATSBYTEVLD_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRACK_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACPHYTXCLK_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACCLIENTRXD_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACCLIENTRXD_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACCLIENTRXD_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACCLIENTRXD_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACCLIENTRXD_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACCLIENTRXD_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACCLIENTRXD_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACCLIENTRXD_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_0_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_16_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_24_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_EMACDCRDBUS_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_31_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_30_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_29_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_28_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_27_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_26_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_25_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_24_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_23_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_22_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_21_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_20_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_19_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_18_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_17_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_16_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_15_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_14_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_13_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_12_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_11_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_10_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_9_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_8_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_BU2_U0_v6_emac_HOSTRDDATA_0_UNCONNECTED : STD_LOGIC; 
  signal gmii_txd_2 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal rx_axis_mac_tdata_3 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal NlwRenamedSig_OI_rx_statistics_vector : STD_LOGIC_VECTOR ( 27 downto 6 ); 
  signal rx_statistics_vector_4 : STD_LOGIC_VECTOR ( 5 downto 0 ); 
  signal tx_axis_mac_tdata_5 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal tx_ifg_delay_6 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal NlwRenamedSig_OI_tx_statistics_vector : STD_LOGIC_VECTOR ( 31 downto 0 ); 
  signal pause_val_7 : STD_LOGIC_VECTOR ( 15 downto 0 ); 
  signal gmii_rxd_8 : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2 : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1 : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2 : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1 : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count_r : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_count : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal BU2_U0_FCSBLKGEN_fcs_blk_inst_Result : STD_LOGIC_VECTOR ( 1 downto 0 ); 
  signal BU2_U0_rx_axi_shim_rx_data_reg : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal BU2_U0_rx_axi_shim_fsmfake1 : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal BU2_U0_rx_axi_shim_next_rx_state : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg : STD_LOGIC_VECTOR ( 15 downto 0 ); 
  signal BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Result : STD_LOGIC_VECTOR ( 3 downto 0 ); 
  signal BU2_U0_tx_axi_shim_tx_data_hold : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT : STD_LOGIC_VECTOR ( 31 downto 0 ); 
  signal BU2_U0_RX_STATS_SHIFT : STD_LOGIC_VECTOR ( 6 downto 0 ); 
  signal BU2_U0_PAUSE_VAL_INT : STD_LOGIC_VECTOR ( 15 downto 0 ); 
  signal BU2_U0_GMII_TXD_INT : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal BU2_U0_RX_DATA : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal BU2_U0_tx_axi_shim_tx_data : STD_LOGIC_VECTOR ( 7 downto 0 ); 
  signal BU2_rx_axis_filter_tuser : STD_LOGIC_VECTOR ( 0 downto 0 ); 
begin
  tx_statistics_vector(31) <= NlwRenamedSig_OI_tx_statistics_vector(31);
  tx_statistics_vector(30) <= NlwRenamedSig_OI_tx_statistics_vector(30);
  tx_statistics_vector(29) <= NlwRenamedSig_OI_tx_statistics_vector(29);
  tx_statistics_vector(28) <= NlwRenamedSig_OI_tx_statistics_vector(28);
  tx_statistics_vector(27) <= NlwRenamedSig_OI_tx_statistics_vector(27);
  tx_statistics_vector(26) <= NlwRenamedSig_OI_tx_statistics_vector(26);
  tx_statistics_vector(25) <= NlwRenamedSig_OI_tx_statistics_vector(25);
  tx_statistics_vector(24) <= NlwRenamedSig_OI_tx_statistics_vector(24);
  tx_statistics_vector(23) <= NlwRenamedSig_OI_tx_statistics_vector(23);
  tx_statistics_vector(22) <= NlwRenamedSig_OI_tx_statistics_vector(22);
  tx_statistics_vector(21) <= NlwRenamedSig_OI_tx_statistics_vector(21);
  tx_statistics_vector(20) <= NlwRenamedSig_OI_tx_statistics_vector(20);
  tx_statistics_vector(19) <= NlwRenamedSig_OI_tx_statistics_vector(19);
  tx_statistics_vector(18) <= NlwRenamedSig_OI_tx_statistics_vector(18);
  tx_statistics_vector(17) <= NlwRenamedSig_OI_tx_statistics_vector(17);
  tx_statistics_vector(16) <= NlwRenamedSig_OI_tx_statistics_vector(16);
  tx_statistics_vector(15) <= NlwRenamedSig_OI_tx_statistics_vector(15);
  tx_statistics_vector(14) <= NlwRenamedSig_OI_tx_statistics_vector(14);
  tx_statistics_vector(13) <= NlwRenamedSig_OI_tx_statistics_vector(13);
  tx_statistics_vector(12) <= NlwRenamedSig_OI_tx_statistics_vector(12);
  tx_statistics_vector(11) <= NlwRenamedSig_OI_tx_statistics_vector(11);
  tx_statistics_vector(10) <= NlwRenamedSig_OI_tx_statistics_vector(10);
  tx_statistics_vector(9) <= NlwRenamedSig_OI_tx_statistics_vector(9);
  tx_statistics_vector(8) <= NlwRenamedSig_OI_tx_statistics_vector(8);
  tx_statistics_vector(7) <= NlwRenamedSig_OI_tx_statistics_vector(7);
  tx_statistics_vector(6) <= NlwRenamedSig_OI_tx_statistics_vector(6);
  tx_statistics_vector(5) <= NlwRenamedSig_OI_tx_statistics_vector(5);
  tx_statistics_vector(4) <= NlwRenamedSig_OI_tx_statistics_vector(4);
  tx_statistics_vector(3) <= NlwRenamedSig_OI_tx_statistics_vector(3);
  tx_statistics_vector(2) <= NlwRenamedSig_OI_tx_statistics_vector(2);
  tx_statistics_vector(1) <= NlwRenamedSig_OI_tx_statistics_vector(1);
  tx_statistics_vector(0) <= NlwRenamedSig_OI_tx_statistics_vector(0);
  pause_val_7(15) <= pause_val(15);
  pause_val_7(14) <= pause_val(14);
  pause_val_7(13) <= pause_val(13);
  pause_val_7(12) <= pause_val(12);
  pause_val_7(11) <= pause_val(11);
  pause_val_7(10) <= pause_val(10);
  pause_val_7(9) <= pause_val(9);
  pause_val_7(8) <= pause_val(8);
  pause_val_7(7) <= pause_val(7);
  pause_val_7(6) <= pause_val(6);
  pause_val_7(5) <= pause_val(5);
  pause_val_7(4) <= pause_val(4);
  pause_val_7(3) <= pause_val(3);
  pause_val_7(2) <= pause_val(2);
  pause_val_7(1) <= pause_val(1);
  pause_val_7(0) <= pause_val(0);
  rx_statistics_vector(27) <= NlwRenamedSig_OI_rx_statistics_vector(27);
  rx_statistics_vector(26) <= NlwRenamedSig_OI_rx_statistics_vector(26);
  rx_statistics_vector(25) <= NlwRenamedSig_OI_rx_statistics_vector(25);
  rx_statistics_vector(24) <= NlwRenamedSig_OI_rx_statistics_vector(24);
  rx_statistics_vector(23) <= NlwRenamedSig_OI_rx_statistics_vector(23);
  rx_statistics_vector(22) <= NlwRenamedSig_OI_rx_statistics_vector(22);
  rx_statistics_vector(21) <= NlwRenamedSig_OI_rx_statistics_vector(21);
  rx_statistics_vector(20) <= NlwRenamedSig_OI_rx_statistics_vector(20);
  rx_statistics_vector(19) <= NlwRenamedSig_OI_rx_statistics_vector(19);
  rx_statistics_vector(18) <= NlwRenamedSig_OI_rx_statistics_vector(18);
  rx_statistics_vector(17) <= NlwRenamedSig_OI_rx_statistics_vector(17);
  rx_statistics_vector(16) <= NlwRenamedSig_OI_rx_statistics_vector(16);
  rx_statistics_vector(15) <= NlwRenamedSig_OI_rx_statistics_vector(15);
  rx_statistics_vector(14) <= NlwRenamedSig_OI_rx_statistics_vector(14);
  rx_statistics_vector(13) <= NlwRenamedSig_OI_rx_statistics_vector(13);
  rx_statistics_vector(12) <= NlwRenamedSig_OI_rx_statistics_vector(12);
  rx_statistics_vector(11) <= NlwRenamedSig_OI_rx_statistics_vector(11);
  rx_statistics_vector(10) <= NlwRenamedSig_OI_rx_statistics_vector(10);
  rx_statistics_vector(9) <= NlwRenamedSig_OI_rx_statistics_vector(9);
  rx_statistics_vector(8) <= NlwRenamedSig_OI_rx_statistics_vector(8);
  rx_statistics_vector(7) <= NlwRenamedSig_OI_rx_statistics_vector(7);
  rx_statistics_vector(6) <= NlwRenamedSig_OI_rx_statistics_vector(6);
  rx_statistics_vector(5) <= rx_statistics_vector_4(5);
  rx_statistics_vector(4) <= rx_statistics_vector_4(4);
  rx_statistics_vector(3) <= rx_statistics_vector_4(3);
  rx_statistics_vector(2) <= rx_statistics_vector_4(2);
  rx_statistics_vector(1) <= rx_statistics_vector_4(1);
  rx_statistics_vector(0) <= rx_statistics_vector_4(0);
  gmii_rxd_8(7) <= gmii_rxd(7);
  gmii_rxd_8(6) <= gmii_rxd(6);
  gmii_rxd_8(5) <= gmii_rxd(5);
  gmii_rxd_8(4) <= gmii_rxd(4);
  gmii_rxd_8(3) <= gmii_rxd(3);
  gmii_rxd_8(2) <= gmii_rxd(2);
  gmii_rxd_8(1) <= gmii_rxd(1);
  gmii_rxd_8(0) <= gmii_rxd(0);
  tx_collision <= NlwRenamedSig_OI_tx_collision;
  tx_retransmit <= NlwRenamedSig_OI_tx_retransmit;
  tx_ifg_delay_6(7) <= tx_ifg_delay(7);
  tx_ifg_delay_6(6) <= tx_ifg_delay(6);
  tx_ifg_delay_6(5) <= tx_ifg_delay(5);
  tx_ifg_delay_6(4) <= tx_ifg_delay(4);
  tx_ifg_delay_6(3) <= tx_ifg_delay(3);
  tx_ifg_delay_6(2) <= tx_ifg_delay(2);
  tx_ifg_delay_6(1) <= tx_ifg_delay(1);
  tx_ifg_delay_6(0) <= tx_ifg_delay(0);
  tx_axis_mac_tdata_5(7) <= tx_axis_mac_tdata(7);
  tx_axis_mac_tdata_5(6) <= tx_axis_mac_tdata(6);
  tx_axis_mac_tdata_5(5) <= tx_axis_mac_tdata(5);
  tx_axis_mac_tdata_5(4) <= tx_axis_mac_tdata(4);
  tx_axis_mac_tdata_5(3) <= tx_axis_mac_tdata(3);
  tx_axis_mac_tdata_5(2) <= tx_axis_mac_tdata(2);
  tx_axis_mac_tdata_5(1) <= tx_axis_mac_tdata(1);
  tx_axis_mac_tdata_5(0) <= tx_axis_mac_tdata(0);
  rx_axis_mac_tdata(7) <= rx_axis_mac_tdata_3(7);
  rx_axis_mac_tdata(6) <= rx_axis_mac_tdata_3(6);
  rx_axis_mac_tdata(5) <= rx_axis_mac_tdata_3(5);
  rx_axis_mac_tdata(4) <= rx_axis_mac_tdata_3(4);
  rx_axis_mac_tdata(3) <= rx_axis_mac_tdata_3(3);
  rx_axis_mac_tdata(2) <= rx_axis_mac_tdata_3(2);
  rx_axis_mac_tdata(1) <= rx_axis_mac_tdata_3(1);
  rx_axis_mac_tdata(0) <= rx_axis_mac_tdata_3(0);
  rx_statistics_valid <= NlwRenamedSig_OI_rx_statistics_valid;
  tx_statistics_valid <= NlwRenamedSig_OI_tx_statistics_valid;
  speed_is_10_100 <= NlwRenamedSig_OI_speed_is_10_100;
  rx_reset_out <= NlwRenamedSig_OI_rx_reset_out;
  tx_reset_out <= NlwRenamedSig_OI_tx_reset_out;
  gmii_txd(7) <= gmii_txd_2(7);
  gmii_txd(6) <= gmii_txd_2(6);
  gmii_txd(5) <= gmii_txd_2(5);
  gmii_txd(4) <= gmii_txd_2(4);
  gmii_txd(3) <= gmii_txd_2(3);
  gmii_txd(2) <= gmii_txd_2(2);
  gmii_txd(1) <= gmii_txd_2(1);
  gmii_txd(0) <= gmii_txd_2(0);
  tx_axis_mac_tready <= NlwRenamedSig_OI_tx_axis_mac_tready;
  VCC_0 : VCC
    port map (
      P => N1
    );
  GND_1 : GND
    port map (
      G => N0
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_from_mac_inv1_INV_0 : INV
    port map (
      I => BU2_U0_GMII_TX_EN_INT,
      O => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_from_mac_inv
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_inv1_INV_0 : INV
    port map (
      I => BU2_U0_TX_STATS_BYTEVLD,
      O => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_inv
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mcount_tx_en_count_xor_0_11_INV_0 : INV
    port map (
      I => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_count(0),
      O => BU2_U0_FCSBLKGEN_fcs_blk_inst_Result(0)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mcount_tx_byte_count_xor_0_11_INV_0 : INV
    port map (
      I => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count(0),
      O => BU2_U0_FCSBLKGEN_fcs_blk_inst_Result_0_1
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mcount_tx_stats_bytevld_ctr_xor_0_11_INV_0 : INV
    port map (
      I => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(0),
      O => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Result(0)
    );
  BU2_U0_INT_GLBL_RST1_INV_0 : INV
    port map (
      I => glbl_rstn,
      O => BU2_U0_INT_GLBL_RST
    );
  BU2_U0_tx_axi_shim_tx_data_7_dpot : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_n0246_inv1_rstpot_514,
      I1 => BU2_U0_tx_axi_shim_tx_data(7),
      I2 => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_7_Q,
      O => BU2_U0_tx_axi_shim_tx_data_7_dpot_327
    );
  BU2_U0_tx_axi_shim_tx_data_6_dpot : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_n0246_inv1_rstpot_514,
      I1 => BU2_U0_tx_axi_shim_tx_data(6),
      I2 => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_6_Q,
      O => BU2_U0_tx_axi_shim_tx_data_6_dpot_328
    );
  BU2_U0_tx_axi_shim_tx_data_5_dpot : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_n0246_inv1_rstpot_514,
      I1 => BU2_U0_tx_axi_shim_tx_data(5),
      I2 => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_5_Q,
      O => BU2_U0_tx_axi_shim_tx_data_5_dpot_329
    );
  BU2_U0_tx_axi_shim_tx_data_4_dpot : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_n0246_inv1_rstpot_514,
      I1 => BU2_U0_tx_axi_shim_tx_data(4),
      I2 => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_4_Q,
      O => BU2_U0_tx_axi_shim_tx_data_4_dpot_330
    );
  BU2_U0_tx_axi_shim_tx_data_3_dpot : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_n0246_inv1_rstpot_514,
      I1 => BU2_U0_tx_axi_shim_tx_data(3),
      I2 => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_3_Q,
      O => BU2_U0_tx_axi_shim_tx_data_3_dpot_331
    );
  BU2_U0_tx_axi_shim_tx_data_2_dpot : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_n0246_inv1_rstpot_514,
      I1 => BU2_U0_tx_axi_shim_tx_data(2),
      I2 => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_2_Q,
      O => BU2_U0_tx_axi_shim_tx_data_2_dpot_332
    );
  BU2_U0_tx_axi_shim_tx_data_1_dpot : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_n0246_inv1_rstpot_514,
      I1 => BU2_U0_tx_axi_shim_tx_data(1),
      I2 => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_1_Q,
      O => BU2_U0_tx_axi_shim_tx_data_1_dpot_333
    );
  BU2_U0_tx_axi_shim_tx_data_0_dpot : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_n0246_inv1_rstpot_514,
      I1 => BU2_U0_tx_axi_shim_tx_data(0),
      I2 => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_0_Q,
      O => BU2_U0_tx_axi_shim_tx_data_0_dpot_334
    );
  BU2_U0_tx_axi_shim_n0246_inv1_rstpot : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_317,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_309,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      O => BU2_U0_tx_axi_shim_n0246_inv1_rstpot_514
    );
  BU2_U0_tx_axi_shim_ignore_packet_glue_set : LUT6
    generic map(
      INIT => X"00020202888A8A8A"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => BU2_U0_tx_axi_shim_ignore_packet_434,
      I2 => BU2_N64,
      I3 => BU2_U0_tx_axi_shim_gate_tready_336,
      I4 => BU2_U0_tx_axi_shim_tx_mac_tready_reg_338,
      I5 => tx_axis_mac_tlast,
      O => BU2_U0_tx_axi_shim_ignore_packet_glue_set_477
    );
  BU2_U0_tx_axi_shim_ignore_packet_glue_set_SW1 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325,
      I1 => tx_axis_mac_tuser,
      O => BU2_N64
    );
  BU2_U0_MATCH_FRAME_INT_glue_set : LUT4
    generic map(
      INIT => X"FA2A"
    )
    port map (
      I0 => BU2_U0_MATCH_FRAME_INT_461,
      I1 => BU2_U0_RX_BAD_FRAME,
      I2 => BU2_U0_RX_CLIENT_CE,
      I3 => BU2_U0_RX_GOOD_FRAME,
      O => BU2_U0_MATCH_FRAME_INT_glue_set_465
    );
  BU2_U0_rx_axi_shim_rx_frame_complete_rstpot : LUT6
    generic map(
      INIT => X"EEEEEEEEEEEEA2AA"
    )
    port map (
      I0 => BU2_U0_rx_axi_shim_rx_frame_complete_441,
      I1 => BU2_U0_RX_CLIENT_CE,
      I2 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_382,
      I3 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_380,
      I4 => BU2_U0_RX_BAD_FRAME,
      I5 => BU2_U0_RX_GOOD_FRAME,
      O => BU2_U0_rx_axi_shim_rx_frame_complete_rstpot_487
    );
  BU2_U0_tx_axi_shim_two_byte_tx_rstpot : LUT4
    generic map(
      INIT => X"ABA8"
    )
    port map (
      I0 => tx_axis_mac_tlast,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd8_319,
      I3 => BU2_U0_tx_axi_shim_two_byte_tx_438,
      O => BU2_U0_tx_axi_shim_two_byte_tx_rstpot_479
    );
  BU2_U0_tx_axi_shim_force_burst2_glue_set : LUT6
    generic map(
      INIT => X"FFA2A2A2A2A2A2A2"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_force_burst2_473,
      I1 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I2 => BU2_U0_tx_axi_shim_force_burst1_470,
      I3 => BU2_U0_tx_axi_shim_two_byte_tx_438,
      I4 => BU2_N62,
      I5 => BU2_U0_tx_axi_shim_tlast_reg_467,
      O => BU2_U0_tx_axi_shim_force_burst2_glue_set_472
    );
  BU2_U0_tx_axi_shim_force_burst2_glue_set_SW0 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd6_315,
      I1 => tx_axis_mac_tvalid,
      O => BU2_N62
    );
  BU2_U0_tx_axi_shim_early_underrun_glue_set : LUT6
    generic map(
      INIT => X"0040000055555555"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325,
      I1 => BU2_U0_tx_axi_shim_gate_tready_336,
      I2 => tx_axis_mac_tuser,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_317,
      I4 => BU2_U0_tx_axi_shim_tx_mac_tready_reg_338,
      I5 => BU2_N58,
      O => BU2_U0_tx_axi_shim_early_underrun_glue_set_474
    );
  BU2_U0_tx_axi_shim_early_underrun_glue_set_SW0 : LUT6
    generic map(
      INIT => X"FFFFEF2FFFFF0F0F"
    )
    port map (
      I0 => BU2_U0_TX_ACK,
      I1 => NlwRenamedSig_OI_speed_is_10_100,
      I2 => BU2_U0_tx_axi_shim_early_underrun_475,
      I3 => BU2_U0_tx_axi_shim_tx_ack_reg_339,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      I5 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      O => BU2_N58
    );
  BU2_U0_tx_axi_shim_force_assert_glue_set : LUT6
    generic map(
      INIT => X"FFAAFFFA22AAF2FA"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_force_assert_444,
      I1 => BU2_U0_tx_axi_shim_tx_data_valid_186,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_309,
      I3 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I4 => BU2_N10,
      I5 => BU2_N56,
      O => BU2_U0_tx_axi_shim_force_assert_glue_set_471
    );
  BU2_U0_tx_axi_shim_force_assert_glue_set_SW0 : LUT5
    generic map(
      INIT => X"0EF002F0"
    )
    port map (
      I0 => BU2_U0_TX_ACK,
      I1 => NlwRenamedSig_OI_speed_is_10_100,
      I2 => BU2_U0_tx_axi_shim_force_burst2_473,
      I3 => BU2_U0_tx_axi_shim_force_burst1_470,
      I4 => BU2_U0_tx_axi_shim_tx_ack_reg_339,
      O => BU2_N56
    );
  BU2_U0_tx_axi_shim_no_burst_rstpot : LUT3
    generic map(
      INIT => X"10"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => NlwRenamedSig_OI_tx_reset_out,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd3_311,
      O => BU2_U0_tx_axi_shim_no_burst_rstpot_483
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_rstpot : LUT3
    generic map(
      INIT => X"08"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_309,
      I1 => tx_axis_mac_tvalid,
      I2 => NlwRenamedSig_OI_tx_reset_out,
      O => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_rstpot_482
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_collision_r_rstpot : LUT3
    generic map(
      INIT => X"F8"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_collision_r_464,
      I1 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_r2_411,
      I2 => NlwRenamedSig_OI_tx_collision,
      O => BU2_U0_FCSBLKGEN_fcs_blk_inst_collision_r_rstpot_488
    );
  BU2_U0_tx_axi_shim_tlast_reg_glue_set : LUT5
    generic map(
      INIT => X"8080FF80"
    )
    port map (
      I0 => tx_axis_mac_tlast,
      I1 => BU2_U0_tx_axi_shim_gate_tready_336,
      I2 => BU2_U0_tx_axi_shim_tx_mac_tready_reg_338,
      I3 => BU2_U0_tx_axi_shim_tlast_reg_467,
      I4 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      O => BU2_U0_tx_axi_shim_tlast_reg_glue_set_466
    );
  BU2_U0_INT_RX_STATISTICS_VALID_rstpot1 : LUT5
    generic map(
      INIT => X"54101010"
    )
    port map (
      I0 => NlwRenamedSig_OI_rx_reset_out,
      I1 => BU2_U0_RX_CLIENT_CE,
      I2 => NlwRenamedSig_OI_rx_statistics_valid,
      I3 => BU2_U0_RX_STATS_SHIFT_VLD,
      I4 => NlwRenamedSig_OI_rx_statistics_vector(6),
      O => BU2_U0_INT_RX_STATISTICS_VALID_rstpot1_490
    );
  BU2_U0_INT_TX_STATISTICS_VALID_rstpot1 : LUT5
    generic map(
      INIT => X"54101010"
    )
    port map (
      I0 => NlwRenamedSig_OI_tx_reset_out,
      I1 => BU2_U0_TX_AXI_CLK_OUT_INT2,
      I2 => NlwRenamedSig_OI_tx_statistics_valid,
      I3 => NlwRenamedSig_OI_tx_statistics_vector(0),
      I4 => BU2_U0_TX_STATS_SHIFT_VLD,
      O => BU2_U0_INT_TX_STATISTICS_VALID_rstpot1_489
    );
  BU2_U0_tx_axi_shim_early_deassert_two_byte_tx_OR_38_o1_SW1_G : LUT6
    generic map(
      INIT => X"AB03AA00FBF3AA00"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => BU2_U0_TX_ACK,
      I2 => NlwRenamedSig_OI_speed_is_10_100,
      I3 => BU2_U0_tx_axi_shim_tlast_reg_467,
      I4 => BU2_U0_tx_axi_shim_force_burst1_470,
      I5 => BU2_U0_tx_axi_shim_tx_ack_reg_339,
      O => BU2_N53
    );
  BU2_U0_tx_axi_shim_early_deassert_two_byte_tx_OR_38_o1_SW1_F : LUT3
    generic map(
      INIT => X"F8"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => BU2_U0_tx_axi_shim_tlast_reg_467,
      I2 => BU2_U0_tx_axi_shim_force_burst1_470,
      O => BU2_N52
    );
  BU2_U0_tx_axi_shim_early_deassert_two_byte_tx_OR_38_o1_SW1 : MUXF7
    port map (
      I0 => BU2_N52,
      I1 => BU2_N53,
      S => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      O => BU2_N47
    );
  BU2_U0_tx_axi_shim_force_burst1_glue_set : LUT6
    generic map(
      INIT => X"FFFFECA0135F0000"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd6_315,
      I1 => BU2_U0_tx_axi_shim_early_deassert_446,
      I2 => BU2_U0_tx_axi_shim_two_byte_tx_438,
      I3 => BU2_U0_tx_axi_shim_tx_state_3_tx_state_3_OR_37_o,
      I4 => BU2_N46,
      I5 => BU2_N47,
      O => BU2_U0_tx_axi_shim_force_burst1_glue_set_469
    );
  BU2_U0_tx_axi_shim_early_deassert_two_byte_tx_OR_38_o1_SW0 : LUT5
    generic map(
      INIT => X"10D0F0F0"
    )
    port map (
      I0 => BU2_U0_TX_ACK,
      I1 => NlwRenamedSig_OI_speed_is_10_100,
      I2 => BU2_U0_tx_axi_shim_force_burst1_470,
      I3 => BU2_U0_tx_axi_shim_tx_ack_reg_339,
      I4 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      O => BU2_N46
    );
  BU2_U0_tx_axi_shim_tx_underrun_glue_set : LUT6
    generic map(
      INIT => X"FFFFFFFF0A0AFACA"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_underrun_184,
      I1 => BU2_U0_tx_axi_shim_force_end_455,
      I2 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I4 => BU2_N44,
      I5 => BU2_N8,
      O => BU2_U0_tx_axi_shim_tx_underrun_glue_set_468
    );
  BU2_U0_tx_axi_shim_tx_mac_tready_int_tx_ack_wire_OR_32_o_SW1 : LUT2
    generic map(
      INIT => X"D"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_early_underrun_475,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      O => BU2_N44
    );
  BU2_U0_tx_axi_shim_Mmux_tx_data_7_tx_mac_tdata_7_mux_64_OUT81 : LUT6
    generic map(
      INIT => X"AACCAACCACCCCCCC"
    )
    port map (
      I0 => tx_axis_mac_tdata_5(7),
      I1 => BU2_U0_tx_axi_shim_tx_data_hold(7),
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      I3 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I5 => BU2_N28,
      O => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_7_Q
    );
  BU2_U0_tx_axi_shim_Mmux_tx_data_7_tx_mac_tdata_7_mux_64_OUT71 : LUT6
    generic map(
      INIT => X"AACCAACCACCCCCCC"
    )
    port map (
      I0 => tx_axis_mac_tdata_5(6),
      I1 => BU2_U0_tx_axi_shim_tx_data_hold(6),
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      I3 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I5 => BU2_N28,
      O => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_6_Q
    );
  BU2_U0_tx_axi_shim_Mmux_tx_data_7_tx_mac_tdata_7_mux_64_OUT61 : LUT6
    generic map(
      INIT => X"AACCAACCACCCCCCC"
    )
    port map (
      I0 => tx_axis_mac_tdata_5(5),
      I1 => BU2_U0_tx_axi_shim_tx_data_hold(5),
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      I3 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I5 => BU2_N28,
      O => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_5_Q
    );
  BU2_U0_tx_axi_shim_Mmux_tx_data_7_tx_mac_tdata_7_mux_64_OUT51 : LUT6
    generic map(
      INIT => X"AACCAACCACCCCCCC"
    )
    port map (
      I0 => tx_axis_mac_tdata_5(4),
      I1 => BU2_U0_tx_axi_shim_tx_data_hold(4),
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      I3 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I5 => BU2_N28,
      O => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_4_Q
    );
  BU2_U0_tx_axi_shim_Mmux_tx_data_7_tx_mac_tdata_7_mux_64_OUT41 : LUT6
    generic map(
      INIT => X"AACCAACCACCCCCCC"
    )
    port map (
      I0 => tx_axis_mac_tdata_5(3),
      I1 => BU2_U0_tx_axi_shim_tx_data_hold(3),
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      I3 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I5 => BU2_N28,
      O => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_3_Q
    );
  BU2_U0_tx_axi_shim_Mmux_tx_data_7_tx_mac_tdata_7_mux_64_OUT31 : LUT6
    generic map(
      INIT => X"AACCAACCACCCCCCC"
    )
    port map (
      I0 => tx_axis_mac_tdata_5(2),
      I1 => BU2_U0_tx_axi_shim_tx_data_hold(2),
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      I3 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I5 => BU2_N28,
      O => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_2_Q
    );
  BU2_U0_tx_axi_shim_Mmux_tx_data_7_tx_mac_tdata_7_mux_64_OUT21 : LUT6
    generic map(
      INIT => X"AACCAACCACCCCCCC"
    )
    port map (
      I0 => tx_axis_mac_tdata_5(1),
      I1 => BU2_U0_tx_axi_shim_tx_data_hold(1),
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      I3 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I5 => BU2_N28,
      O => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_1_Q
    );
  BU2_U0_tx_axi_shim_Mmux_tx_data_7_tx_mac_tdata_7_mux_64_OUT11 : LUT6
    generic map(
      INIT => X"AACCAACCACCCCCCC"
    )
    port map (
      I0 => tx_axis_mac_tdata_5(0),
      I1 => BU2_U0_tx_axi_shim_tx_data_hold(0),
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      I3 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I5 => BU2_N28,
      O => BU2_U0_tx_axi_shim_tx_data_7_tx_mac_tdata_7_mux_64_OUT_0_Q
    );
  BU2_U0_tx_axi_shim_tx_state_3_tx_enable_reg_AND_78_o1_SW0 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_317,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_309,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325,
      O => BU2_N28
    );
  BU2_U0_tx_axi_shim_Mmux_PWR_20_o_tx_enable_MUX_106_o11 : LUT6
    generic map(
      INIT => X"AFAFABAFFFFFBBFF"
    )
    port map (
      I0 => BU2_U0_TX_AXI_CLK_OUT_INT2,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_317,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In2,
      I4 => BU2_N26,
      I5 => BU2_N12,
      O => BU2_U0_tx_axi_shim_PWR_20_o_tx_enable_MUX_106_o
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In_SW1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_two_byte_tx_438,
      I1 => BU2_U0_tx_axi_shim_early_deassert_446,
      O => BU2_N26
    );
  BU2_U0_tx_axi_shim_force_end_rstpot : LUT6
    generic map(
      INIT => X"FFAAFFEEF0A0F0E0"
    )
    port map (
      I0 => NlwRenamedSig_OI_tx_retransmit,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd5_313,
      I2 => BU2_U0_tx_axi_shim_force_end_455,
      I3 => BU2_N24,
      I4 => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o1_433,
      I5 => BU2_U0_tx_axi_shim_tx_retransmit_tx_state_3_OR_17_o,
      O => BU2_U0_tx_axi_shim_force_end_rstpot_486
    );
  BU2_U0_tx_axi_shim_n02411_SW0 : LUT2
    generic map(
      INIT => X"1"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_323,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325,
      O => BU2_N24
    );
  BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o5 : LUT6
    generic map(
      INIT => X"FFFFFEFCFFFFFAF0"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o2,
      I2 => BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_71_o,
      I3 => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o5_448,
      I4 => BU2_N22,
      I5 => BU2_U0_tx_axi_shim_next_tx_state_3_PWR_20_o_equal_74_o,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o
    );
  BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o5_SW0 : LUT5
    generic map(
      INIT => X"FFF4F4F4"
    )
    port map (
      I0 => tx_axis_mac_tlast,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd9_321,
      I2 => BU2_U0_tx_axi_shim_ignore_packet_434,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_309,
      I4 => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o1_433,
      O => BU2_N22
    );
  BU2_U0_rx_axi_shim_rx_mac_tvalid_rstpot : LUT3
    generic map(
      INIT => X"08"
    )
    port map (
      I0 => BU2_U0_RX_CLIENT_CE,
      I1 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_382,
      I2 => BU2_U0_rx_axi_shim_next_rx_state_1_rx_state_1_OR_15_o12,
      O => BU2_U0_rx_axi_shim_rx_mac_tvalid_rstpot_485
    );
  BU2_U0_rx_axi_shim_rx_mac_tlast_rstpot : LUT4
    generic map(
      INIT => X"0080"
    )
    port map (
      I0 => BU2_U0_RX_CLIENT_CE,
      I1 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_380,
      I2 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_382,
      I3 => BU2_U0_rx_axi_shim_next_rx_state_1_rx_state_1_OR_15_o12,
      O => BU2_U0_rx_axi_shim_rx_mac_tlast_rstpot_484
    );
  BU2_U0_tx_axi_shim_early_deassert_glue_set : LUT6
    generic map(
      INIT => X"0000000ACCCCCCCE"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => BU2_U0_tx_axi_shim_early_deassert_446,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_317,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In2,
      I5 => BU2_U0_tx_axi_shim_tx_data_valid_two_byte_tx_OR_34_o,
      O => BU2_U0_tx_axi_shim_early_deassert_glue_set_476
    );
  BU2_U0_tx_axi_shim_tx_retransmit_tx_state_3_OR_17_o1 : LUT6
    generic map(
      INIT => X"FEAAAEAAAAAAAAAA"
    )
    port map (
      I0 => NlwRenamedSig_OI_tx_retransmit,
      I1 => BU2_U0_TX_ACK,
      I2 => NlwRenamedSig_OI_speed_is_10_100,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd5_313,
      I4 => BU2_U0_tx_axi_shim_tx_ack_reg_339,
      I5 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      O => BU2_U0_tx_axi_shim_tx_retransmit_tx_state_3_OR_17_o
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd5_In1 : LUT6
    generic map(
      INIT => X"1000D000F000F000"
    )
    port map (
      I0 => BU2_U0_TX_ACK,
      I1 => NlwRenamedSig_OI_speed_is_10_100,
      I2 => BU2_N20,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd6_315,
      I4 => BU2_U0_tx_axi_shim_tx_ack_reg_339,
      I5 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_71_o
    );
  BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o11_SW0 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => tx_axis_mac_tuser,
      I1 => tx_axis_mac_tlast,
      O => BU2_N20
    );
  BU2_U0_tx_axi_shim_tx_data_valid_glue_set : LUT3
    generic map(
      INIT => X"AE"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_next_tx_state_3_force_assert_OR_22_o_445,
      I1 => BU2_U0_tx_axi_shim_tx_data_valid_186,
      I2 => BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o,
      O => BU2_U0_tx_axi_shim_tx_data_valid_glue_set_478
    );
  BU2_U0_INT_RX_STATISTICS_VALID : FD
    port map (
      C => rx_axi_clk,
      D => BU2_U0_INT_RX_STATISTICS_VALID_rstpot1_490,
      Q => NlwRenamedSig_OI_rx_statistics_valid
    );
  BU2_U0_INT_TX_STATISTICS_VALID : FD
    port map (
      C => tx_axi_clk,
      D => BU2_U0_INT_TX_STATISTICS_VALID_rstpot1_489,
      Q => NlwRenamedSig_OI_tx_statistics_valid
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_collision_r : FD
    port map (
      C => tx_axi_clk,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_collision_r_rstpot_488,
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_collision_r_464
    );
  BU2_U0_rx_axi_shim_rx_frame_complete : FD
    port map (
      C => rx_axi_clk,
      D => BU2_U0_rx_axi_shim_rx_frame_complete_rstpot_487,
      Q => BU2_U0_rx_axi_shim_rx_frame_complete_441
    );
  BU2_U0_tx_axi_shim_force_end : FD
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_force_end_rstpot_486,
      Q => BU2_U0_tx_axi_shim_force_end_455
    );
  BU2_U0_rx_axi_shim_rx_mac_tvalid : FD
    port map (
      C => rx_axi_clk,
      D => BU2_U0_rx_axi_shim_rx_mac_tvalid_rstpot_485,
      Q => rx_axis_mac_tvalid
    );
  BU2_U0_rx_axi_shim_rx_mac_tlast : FD
    port map (
      C => rx_axi_clk,
      D => BU2_U0_rx_axi_shim_rx_mac_tlast_rstpot_484,
      Q => rx_axis_mac_tlast
    );
  BU2_U0_tx_axi_shim_no_burst : FD
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_no_burst_rstpot_483,
      Q => BU2_U0_tx_axi_shim_no_burst_435
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd1 : FD
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_rstpot_482,
      Q => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432
    );
  BU2_U0_SYNC_TX_RESET_I_R4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => tx_axi_clk,
      D => BU2_U0_SYNC_TX_RESET_I_R4_rstpot_481,
      Q => NlwRenamedSig_OI_tx_reset_out
    );
  BU2_U0_SYNC_TX_RESET_I_R4_rstpot : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => BU2_U0_SYNC_TX_RESET_I_R3_247,
      I1 => BU2_U0_SYNC_TX_RESET_I_R2_246,
      O => BU2_U0_SYNC_TX_RESET_I_R4_rstpot_481
    );
  BU2_U0_SYNC_RX_RESET_I_R4 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => rx_axi_clk,
      D => BU2_U0_SYNC_RX_RESET_I_R4_rstpot_480,
      Q => NlwRenamedSig_OI_rx_reset_out
    );
  BU2_U0_SYNC_RX_RESET_I_R4_rstpot : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => BU2_U0_SYNC_RX_RESET_I_R3_243,
      I1 => BU2_U0_SYNC_RX_RESET_I_R2_242,
      O => BU2_U0_SYNC_RX_RESET_I_R4_rstpot_480
    );
  BU2_U0_tx_axi_shim_two_byte_tx : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_two_byte_tx_rstpot_479,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_two_byte_tx_438
    );
  BU2_U0_tx_axi_shim_tx_data_valid : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_tx_data_valid_glue_set_478,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data_valid_186
    );
  BU2_U0_tx_axi_shim_ignore_packet : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_ignore_packet_glue_set_477,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_ignore_packet_434
    );
  BU2_U0_tx_axi_shim_early_deassert : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_early_deassert_glue_set_476,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_early_deassert_446
    );
  BU2_U0_tx_axi_shim_early_underrun : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_early_underrun_glue_set_474,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_early_underrun_475
    );
  BU2_U0_tx_axi_shim_force_burst2 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_force_burst2_glue_set_472,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_force_burst2_473
    );
  BU2_U0_tx_axi_shim_force_assert : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_force_assert_glue_set_471,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_force_assert_444
    );
  BU2_U0_tx_axi_shim_force_burst1 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_force_burst1_glue_set_469,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_force_burst1_470
    );
  BU2_U0_tx_axi_shim_tx_underrun : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_tx_underrun_glue_set_468,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_underrun_184
    );
  BU2_U0_tx_axi_shim_tlast_reg : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_tlast_reg_glue_set_466,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tlast_reg_467
    );
  BU2_U0_MATCH_FRAME_INT : FDR
    port map (
      C => rx_axi_clk,
      D => BU2_U0_MATCH_FRAME_INT_glue_set_465,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => BU2_U0_MATCH_FRAME_INT_461
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_tx_en12 : LUT6
    generic map(
      INIT => X"88B8AAAA88A8AAAA"
    )
    port map (
      I0 => BU2_U0_GMII_TX_EN_INT,
      I1 => BU2_U0_FCSBLKGEN_fcs_blk_inst_collision_r_464,
      I2 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_r2_411,
      I3 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_suppress_r_431,
      I4 => BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r_428,
      I5 => BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_tx_en1,
      O => gmii_tx_en
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_tx_en11 : LUT5
    generic map(
      INIT => X"9009FFFF"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_count(1),
      I1 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count_r(1),
      I2 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_count(0),
      I3 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count_r(0),
      I4 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_r1_410,
      O => BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_tx_en1
    );
  BU2_U0_rx_axi_shim_next_rx_state_1_rx_enable_AND_16_o : LUT6
    generic map(
      INIT => X"0808080808080800"
    )
    port map (
      I0 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_382,
      I1 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_380,
      I2 => BU2_N16,
      I3 => BU2_U0_rx_axi_shim_fsmfake1(0),
      I4 => BU2_U0_rx_axi_shim_rx_frame_complete_441,
      I5 => BU2_U0_RX_DATA_VALID,
      O => BU2_U0_rx_axi_shim_next_rx_state_1_rx_enable_AND_16_o_394
    );
  BU2_U0_rx_axi_shim_next_rx_state_1_rx_enable_AND_16_o_SW0 : LUT2
    generic map(
      INIT => X"B"
    )
    port map (
      I0 => BU2_U0_MATCH_FRAME_INT_461,
      I1 => BU2_U0_RX_CLIENT_CE,
      O => BU2_N16
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_In : LUT6
    generic map(
      INIT => X"FDFDA0A0FD55A000"
    )
    port map (
      I0 => BU2_U0_TX_AXI_CLK_OUT_INT2,
      I1 => pause_req,
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd2_361,
      I3 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(2),
      I4 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I5 => BU2_N14,
      O => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_In_358
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_In_SW0 : LUT3
    generic map(
      INIT => X"F7"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(3),
      I1 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(0),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(1),
      O => BU2_N14
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In : LUT6
    generic map(
      INIT => X"FF10FF0010100000"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_early_deassert_446,
      I1 => BU2_U0_tx_axi_shim_two_byte_tx_438,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_317,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In2,
      I5 => BU2_N12,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_PWR_20_o_equal_74_o
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In_SW0 : LUT5
    generic map(
      INIT => X"FFDC0000"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd6_315,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_323,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      I4 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      O => BU2_N12
    );
  BU2_U0_tx_axi_shim_early_deassert_force_burst2_OR_36_o_SW0 : LUT3
    generic map(
      INIT => X"F7"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_early_deassert_446,
      I1 => tx_axis_mac_tvalid,
      I2 => tx_axis_mac_tlast,
      O => BU2_N10
    );
  BU2_U0_tx_axi_shim_tx_mac_tready_int_tx_ack_wire_OR_32_o_SW0 : LUT5
    generic map(
      INIT => X"D0000000"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => tx_axis_mac_tuser,
      I2 => BU2_U0_tx_axi_shim_gate_tready_336,
      I3 => BU2_U0_tx_axi_shim_tx_mac_tready_reg_338,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_317,
      O => BU2_N8
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd3_In : LUT5
    generic map(
      INIT => X"FFFF4000"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => BU2_U0_tx_axi_shim_force_end_455,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_323,
      I3 => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o1_433,
      I4 => BU2_N6,
      O => BU2_U0_tx_axi_shim_tx_state_FSM_FFd3_In_310
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd3_In_SW0 : LUT6
    generic map(
      INIT => X"FC00FEAAFF00FFAA"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd3_311,
      I1 => BU2_U0_tx_axi_shim_early_deassert_446,
      I2 => BU2_U0_tx_axi_shim_two_byte_tx_438,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_317,
      I4 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I5 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In2,
      O => BU2_N6
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_In : LUT6
    generic map(
      INIT => X"FFFFCDCCFFFFCCCC"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd5_313,
      I2 => BU2_U0_tx_axi_shim_force_end_455,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_323,
      I4 => BU2_N4,
      I5 => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o1_433,
      O => BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_In_322
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_In_SW0 : LUT4
    generic map(
      INIT => X"8880"
    )
    port map (
      I0 => tx_axis_mac_tlast,
      I1 => tx_axis_mac_tuser,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd9_321,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd8_319,
      O => BU2_N4
    );
  BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o4 : LUT5
    generic map(
      INIT => X"AAAAAA80"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I2 => BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o3_452,
      I3 => BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o1_450,
      I4 => BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o2_451,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o
    );
  BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o3 : LUT3
    generic map(
      INIT => X"DC"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => BU2_U0_tx_axi_shim_early_deassert_446,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_309,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o3_452
    );
  BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o2 : LUT5
    generic map(
      INIT => X"FFFD0000"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => tx_axis_mac_tuser,
      I2 => BU2_U0_tx_axi_shim_no_burst_435,
      I3 => BU2_U0_tx_axi_shim_ignore_packet_434,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o2_451
    );
  BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o1 : LUT3
    generic map(
      INIT => X"EA"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd3_311,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_317,
      I2 => BU2_U0_tx_axi_shim_two_byte_tx_438,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_tx_state_3_OR_24_o1_450
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_In2 : LUT6
    generic map(
      INIT => X"FFFFFFFFDC00CC00"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd3_311,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_309,
      I3 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1,
      I5 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_In,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_29_o
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_In1 : LUT6
    generic map(
      INIT => X"FFFD0000FFFF0000"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => tx_axis_mac_tuser,
      I2 => BU2_U0_tx_axi_shim_no_burst_435,
      I3 => BU2_U0_tx_axi_shim_ignore_packet_434,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325,
      I5 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      O => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_In
    );
  BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o4 : LUT6
    generic map(
      INIT => X"FFF1FFF0FFF0FFF0"
    )
    port map (
      I0 => tx_axis_mac_tuser,
      I1 => BU2_U0_tx_axi_shim_no_burst_435,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_323,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_309,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325,
      I5 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o5_448
    );
  BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o1 : LUT2
    generic map(
      INIT => X"1"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_early_deassert_446,
      I1 => BU2_U0_tx_axi_shim_two_byte_tx_438,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o2
    );
  BU2_U0_tx_axi_shim_next_tx_state_3_force_assert_OR_22_o : LUT6
    generic map(
      INIT => X"CCCECCCC00000000"
    )
    port map (
      I0 => BU2_N2,
      I1 => BU2_U0_tx_axi_shim_force_assert_444,
      I2 => BU2_U0_tx_axi_shim_no_burst_435,
      I3 => BU2_U0_tx_axi_shim_ignore_packet_434,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325,
      I5 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_force_assert_OR_22_o_445
    );
  BU2_U0_tx_axi_shim_next_tx_state_3_force_assert_OR_22_o_SW0 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => tx_axis_mac_tuser,
      I1 => tx_axis_mac_tvalid,
      O => BU2_N2
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_r_tx_stats_byte_valid_AND_6_o1 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => BU2_U0_TX_STATS_BYTEVLD,
      I1 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_r_429,
      O => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_r_tx_stats_byte_valid_AND_6_o
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_tx_er11 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r_428,
      I1 => BU2_U0_GMII_TX_ER_INT,
      I2 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_er_r2_409,
      O => gmii_tx_er
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_txd81 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r_428,
      I1 => BU2_U0_GMII_TXD_INT(7),
      I2 => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2(3),
      O => gmii_txd_2(7)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_txd71 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r_428,
      I1 => BU2_U0_GMII_TXD_INT(6),
      I2 => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2(2),
      O => gmii_txd_2(6)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_txd61 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r_428,
      I1 => BU2_U0_GMII_TXD_INT(5),
      I2 => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2(1),
      O => gmii_txd_2(5)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_txd51 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r_428,
      I1 => BU2_U0_GMII_TXD_INT(4),
      I2 => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2(0),
      O => gmii_txd_2(4)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_txd41 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r_428,
      I1 => BU2_U0_GMII_TXD_INT(3),
      I2 => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2(3),
      O => gmii_txd_2(3)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_txd31 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r_428,
      I1 => BU2_U0_GMII_TXD_INT(2),
      I2 => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2(2),
      O => gmii_txd_2(2)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_txd21 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r_428,
      I1 => BU2_U0_GMII_TXD_INT(1),
      I2 => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2(1),
      O => gmii_txd_2(1)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mmux_txd11 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r_428,
      I1 => BU2_U0_GMII_TXD_INT(0),
      I2 => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2(0),
      O => gmii_txd_2(0)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mcount_tx_en_count_xor_1_11 : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_count(1),
      I1 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_count(0),
      O => BU2_U0_FCSBLKGEN_fcs_blk_inst_Result(1)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_Mcount_tx_byte_count_xor_1_11 : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count(1),
      I1 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count(0),
      O => BU2_U0_FCSBLKGEN_fcs_blk_inst_Result_1_1
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_suppress1 : LUT6
    generic map(
      INIT => X"0440444444440440"
    )
    port map (
      I0 => BU2_U0_GMII_TX_EN_INT,
      I1 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_r1_410,
      I2 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_count(0),
      I3 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count_r(0),
      I4 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_count(1),
      I5 => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count_r(1),
      O => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_suppress
    );
  BU2_U0_rx_axi_shim_rx_state_1_rx_enable_AND_17_o1 : LUT3
    generic map(
      INIT => X"08"
    )
    port map (
      I0 => BU2_U0_RX_CLIENT_CE,
      I1 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_382,
      I2 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_380,
      O => BU2_U0_rx_axi_shim_rx_state_1_rx_enable_AND_17_o
    );
  BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_In1 : LUT5
    generic map(
      INIT => X"2AEE2AAA"
    )
    port map (
      I0 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_382,
      I1 => BU2_U0_RX_CLIENT_CE,
      I2 => BU2_U0_rx_axi_shim_rx_frame_complete_441,
      I3 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_380,
      I4 => BU2_U0_RX_DATA_VALID,
      O => BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_In
    );
  BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_In1 : LUT5
    generic map(
      INIT => X"80AACCAA"
    )
    port map (
      I0 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_380,
      I1 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_382,
      I2 => BU2_U0_rx_axi_shim_rx_frame_complete_441,
      I3 => BU2_U0_RX_CLIENT_CE,
      I4 => BU2_U0_RX_DATA_VALID,
      O => BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_In
    );
  BU2_U0_rx_axi_shim_next_rx_state_1_rx_state_1_OR_15_o121 : LUT6
    generic map(
      INIT => X"FFFFFFFF01770133"
    )
    port map (
      I0 => BU2_U0_RX_DATA_VALID,
      I1 => BU2_U0_rx_axi_shim_fsmfake1(0),
      I2 => BU2_U0_rx_axi_shim_rx_frame_complete_441,
      I3 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_380,
      I4 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_382,
      I5 => NlwRenamedSig_OI_rx_reset_out,
      O => BU2_U0_rx_axi_shim_next_rx_state_1_rx_state_1_OR_15_o12
    );
  BU2_U0_rx_axi_shim_Mmux_next_rx_state11 : LUT5
    generic map(
      INIT => X"DD999980"
    )
    port map (
      I0 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_380,
      I1 => BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_382,
      I2 => BU2_U0_rx_axi_shim_rx_frame_complete_441,
      I3 => BU2_U0_RX_DATA_VALID,
      I4 => BU2_U0_rx_axi_shim_fsmfake1(0),
      O => BU2_U0_rx_axi_shim_next_rx_state(0)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n00481 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => BU2_U0_TX_STATS_BYTEVLD,
      I1 => BU2_U0_TX_AXI_CLK_OUT_INT2,
      O => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0048
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_REQ_out1 : LUT4
    generic map(
      INIT => X"AE04"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_req,
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd2_361,
      I3 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_REQ_reg_362,
      O => BU2_U0_PAUSE_REQ_INT
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mcount_tx_stats_bytevld_ctr_xor_1_11 : LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(1),
      I1 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(0),
      O => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Result(1)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out161 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(9),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(9),
      O => BU2_U0_PAUSE_VAL_INT(9)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out151 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(8),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(8),
      O => BU2_U0_PAUSE_VAL_INT(8)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out141 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(7),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(7),
      O => BU2_U0_PAUSE_VAL_INT(7)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out131 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(6),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(6),
      O => BU2_U0_PAUSE_VAL_INT(6)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out121 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(5),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(5),
      O => BU2_U0_PAUSE_VAL_INT(5)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out111 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(4),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(4),
      O => BU2_U0_PAUSE_VAL_INT(4)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out101 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(3),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(3),
      O => BU2_U0_PAUSE_VAL_INT(3)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out91 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(2),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(2),
      O => BU2_U0_PAUSE_VAL_INT(2)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out81 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(1),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(1),
      O => BU2_U0_PAUSE_VAL_INT(1)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out71 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(15),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(15),
      O => BU2_U0_PAUSE_VAL_INT(15)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out61 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(14),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(14),
      O => BU2_U0_PAUSE_VAL_INT(14)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out51 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(13),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(13),
      O => BU2_U0_PAUSE_VAL_INT(13)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out41 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(12),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(12),
      O => BU2_U0_PAUSE_VAL_INT(12)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out31 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(11),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(11),
      O => BU2_U0_PAUSE_VAL_INT(11)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out21 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(10),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(10),
      O => BU2_U0_PAUSE_VAL_INT(10)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mmux_PAUSE_VAL_out17 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359,
      I1 => pause_val_7(0),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(0),
      O => BU2_U0_PAUSE_VAL_INT(0)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd2_In1 : LUT6
    generic map(
      INIT => X"444444E444444444"
    )
    port map (
      I0 => BU2_U0_TX_AXI_CLK_OUT_INT2,
      I1 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd2_361,
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(3),
      I3 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(2),
      I4 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(1),
      I5 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(0),
      O => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd2_In
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mcount_tx_stats_bytevld_ctr_xor_3_11 : LUT4
    generic map(
      INIT => X"6AAA"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(3),
      I1 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(0),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(1),
      I3 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(2),
      O => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Result(3)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0056_inv1 : LUT4
    generic map(
      INIT => X"02AA"
    )
    port map (
      I0 => BU2_U0_TX_AXI_CLK_OUT_INT2,
      I1 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(2),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(1),
      I3 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(3),
      O => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0056_inv
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Mcount_tx_stats_bytevld_ctr_xor_2_11 : LUT3
    generic map(
      INIT => X"6A"
    )
    port map (
      I0 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(2),
      I1 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(0),
      I2 => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(1),
      O => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Result(2)
    );
  BU2_U0_tx_axi_shim_tx_mac_tready_int1 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_mac_tready_reg_338,
      I1 => BU2_U0_tx_axi_shim_gate_tready_336,
      O => NlwRenamedSig_OI_tx_axis_mac_tready
    );
  BU2_U0_tx_axi_shim_tx_state_tx_state_3_tx_state_3_OR_37_o1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd8_319,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      O => BU2_U0_tx_axi_shim_tx_state_3_tx_state_3_OR_37_o
    );
  BU2_U0_tx_axi_shim_tx_data_valid_two_byte_tx_OR_34_o1 : LUT5
    generic map(
      INIT => X"FBF3FAF0"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => BU2_U0_tx_axi_shim_tx_data_valid_186,
      I2 => BU2_U0_tx_axi_shim_two_byte_tx_438,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_309,
      I4 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      O => BU2_U0_tx_axi_shim_tx_data_valid_two_byte_tx_OR_34_o
    );
  BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o11 : LUT4
    generic map(
      INIT => X"1DFF"
    )
    port map (
      I0 => BU2_U0_TX_ACK,
      I1 => NlwRenamedSig_OI_speed_is_10_100,
      I2 => BU2_U0_tx_axi_shim_tx_ack_reg_339,
      I3 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o1_433
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_In1 : LUT4
    generic map(
      INIT => X"EA40"
    )
    port map (
      I0 => tx_axis_mac_tvalid,
      I1 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_309,
      I2 => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o1_433,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_323,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_72_o
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In11 : LUT3
    generic map(
      INIT => X"E4"
    )
    port map (
      I0 => NlwRenamedSig_OI_speed_is_10_100,
      I1 => BU2_U0_TX_ACK,
      I2 => BU2_U0_tx_axi_shim_tx_ack_reg_339,
      O => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In1
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In21 : LUT3
    generic map(
      INIT => X"7F"
    )
    port map (
      I0 => tx_axis_mac_tlast,
      I1 => BU2_U0_tx_axi_shim_gate_tready_336,
      I2 => BU2_U0_tx_axi_shim_tx_mac_tready_reg_338,
      O => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_In2
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd9_In1 : LUT6
    generic map(
      INIT => X"0000000000004000"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_ignore_packet_434,
      I1 => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      I2 => tx_axis_mac_tvalid,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325,
      I4 => tx_axis_mac_tuser,
      I5 => BU2_U0_tx_axi_shim_no_burst_435,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_28_o
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd8_In1 : LUT3
    generic map(
      INIT => X"2A"
    )
    port map (
      I0 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd9_321,
      I1 => tx_axis_mac_tlast,
      I2 => tx_axis_mac_tuser,
      O => BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_70_o
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd6_In1 : LUT6
    generic map(
      INIT => X"FFFF777070707070"
    )
    port map (
      I0 => tx_axis_mac_tuser,
      I1 => tx_axis_mac_tlast,
      I2 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd8_319,
      I3 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd6_315,
      I4 => BU2_U0_tx_axi_shim_tx_state_FSM_FFd1_432,
      I5 => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o1_433,
      O => BU2_U0_tx_axi_shim_tx_state_FSM_FFd6_In
    );
  BU2_U0_INT_TX_RST_ASYNCH1 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => glbl_rstn,
      I1 => tx_axi_rstn,
      O => BU2_U0_INT_TX_RST_ASYNCH
    );
  BU2_U0_INT_RX_RST_ASYNCH1 : LUT2
    generic map(
      INIT => X"7"
    )
    port map (
      I0 => glbl_rstn,
      I1 => rx_axi_rstn,
      O => BU2_U0_INT_RX_RST_ASYNCH
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT321 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(10),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(9)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT311 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(9),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(8)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT301 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(8),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(7)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT291 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(7),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(6)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT281 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(6),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(5)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT271 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(5),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(4)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT261 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(4),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(3)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT251 : LUT2
    generic map(
      INIT => X"B"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT,
      I1 => BU2_U0_TX_STATS_SHIFT_VLD,
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(31)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT241 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(31),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(30)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT231 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(3),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(2)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT221 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(30),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(29)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT211 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(29),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(28)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT201 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(28),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(27)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT191 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(27),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(26)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT181 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(26),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(25)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT171 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(25),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(24)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT161 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(24),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(23)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT151 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(23),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(22)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT141 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(22),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(21)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT131 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(21),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(20)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT121 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(2),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(1)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT111 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(20),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(19)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT101 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(19),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(18)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT91 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(18),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(17)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT81 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(17),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(16)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT71 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(16),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(15)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT61 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(15),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(14)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT51 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(14),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(13)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT41 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(13),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(12)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT33 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(12),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(11)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT210 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(11),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(10)
    );
  BU2_U0_Mmux_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT110 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_TX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_tx_statistics_vector(1),
      O => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(0)
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT281 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(16),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_9_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT271 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(15),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_8_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT261 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(14),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_7_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT251 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(13),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_6_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT241 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(12),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_5_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT231 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(11),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_4_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT221 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(10),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_3_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT211 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(9),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_2_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT201 : LUT2
    generic map(
      INIT => X"B"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT(6),
      I1 => BU2_U0_RX_STATS_SHIFT_VLD,
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_27_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT191 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => BU2_U0_RX_STATS_SHIFT(5),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_26_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT181 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => BU2_U0_RX_STATS_SHIFT(4),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_25_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT171 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => BU2_U0_RX_STATS_SHIFT(3),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_24_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT161 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => BU2_U0_RX_STATS_SHIFT(2),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_23_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT151 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => BU2_U0_RX_STATS_SHIFT(1),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_22_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT141 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => BU2_U0_RX_STATS_SHIFT(0),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_21_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT131 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(27),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_20_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT121 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(8),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_1_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT111 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(26),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_19_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT101 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(25),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_18_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT91 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(24),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_17_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT81 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(23),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_16_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT71 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(22),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_15_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT61 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(21),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_14_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT51 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(20),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_13_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT41 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(19),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_12_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT31 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(18),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_11_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT29 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(17),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_10_Q
    );
  BU2_U0_Mmux_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT110 : LUT2
    generic map(
      INIT => X"8"
    )
    port map (
      I0 => BU2_U0_RX_STATS_SHIFT_VLD,
      I1 => NlwRenamedSig_OI_rx_statistics_vector(7),
      O => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_0_Q
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1_0 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_GMII_TXD_INT(4),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1(0)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1_1 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_GMII_TXD_INT(5),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1(1)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1_2 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_GMII_TXD_INT(6),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1(2)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1_3 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_GMII_TXD_INT(7),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1(3)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1_0 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_GMII_TXD_INT(0),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1(0)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1_1 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_GMII_TXD_INT(1),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1(1)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1_2 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_GMII_TXD_INT(2),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1(2)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1_3 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_GMII_TXD_INT(3),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1(3)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_r1 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_GMII_TX_EN_INT,
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_r1_410
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_er_r1 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_GMII_TX_ER_INT,
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_er_r1_408
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_suppress_r : FD
    port map (
      C => tx_axi_clk,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_suppress,
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_suppress_r_431
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_r : FD
    port map (
      C => tx_axi_clk,
      D => BU2_U0_TX_STATS_BYTEVLD,
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_r_429
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r : FD
    port map (
      C => tx_axi_clk,
      D => NlwRenamedSig_OI_speed_is_10_100,
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_speed_is_10_100_r_428
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2_0 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1(0),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2(0)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2_1 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1(1),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2(1)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2_2 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1(2),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2(2)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2_3 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r1(3),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_lonbl_r2(3)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2_0 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1(0),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2(0)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2_1 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1(1),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2(1)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2_2 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1(2),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2(2)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2_3 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r1(3),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_txd_hinbl_r2(3)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_r2 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_r1_410,
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_r2_411
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_er_r2 : FDC
    port map (
      C => tx_axi_clk,
      CLR => NlwRenamedSig_OI_tx_reset_out,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_er_r1_408,
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_er_r2_409
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count_r_0 : FDE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_r_tx_stats_byte_valid_AND_6_o,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count(0),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count_r(0)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count_r_1 : FDE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_r_tx_stats_byte_valid_AND_6_o,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count(1),
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count_r(1)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count_0 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_Result_0_1,
      R => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_inv,
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count(0)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count_1 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_Result_1_1,
      R => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_stats_byte_valid_inv,
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_byte_count(1)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_count_0 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_Result(0),
      R => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_from_mac_inv,
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_count(0)
    );
  BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_count_1 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_FCSBLKGEN_fcs_blk_inst_Result(1),
      R => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_from_mac_inv,
      Q => BU2_U0_FCSBLKGEN_fcs_blk_inst_tx_en_count(1)
    );
  BU2_U0_rx_axi_shim_rx_data_reg_0 : FDE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_DATA(0),
      Q => BU2_U0_rx_axi_shim_rx_data_reg(0)
    );
  BU2_U0_rx_axi_shim_rx_data_reg_1 : FDE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_DATA(1),
      Q => BU2_U0_rx_axi_shim_rx_data_reg(1)
    );
  BU2_U0_rx_axi_shim_rx_data_reg_2 : FDE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_DATA(2),
      Q => BU2_U0_rx_axi_shim_rx_data_reg(2)
    );
  BU2_U0_rx_axi_shim_rx_data_reg_3 : FDE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_DATA(3),
      Q => BU2_U0_rx_axi_shim_rx_data_reg(3)
    );
  BU2_U0_rx_axi_shim_rx_data_reg_4 : FDE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_DATA(4),
      Q => BU2_U0_rx_axi_shim_rx_data_reg(4)
    );
  BU2_U0_rx_axi_shim_rx_data_reg_5 : FDE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_DATA(5),
      Q => BU2_U0_rx_axi_shim_rx_data_reg(5)
    );
  BU2_U0_rx_axi_shim_rx_data_reg_6 : FDE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_DATA(6),
      Q => BU2_U0_rx_axi_shim_rx_data_reg(6)
    );
  BU2_U0_rx_axi_shim_rx_data_reg_7 : FDE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_DATA(7),
      Q => BU2_U0_rx_axi_shim_rx_data_reg(7)
    );
  BU2_U0_rx_axi_shim_rx_mac_tuser : FDR
    port map (
      C => rx_axi_clk,
      D => BU2_U0_rx_axi_shim_next_rx_state_1_rx_enable_AND_16_o_394,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_axis_mac_tuser
    );
  BU2_U0_rx_axi_shim_rx_mac_tdata_0 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_rx_axi_shim_rx_state_1_rx_enable_AND_17_o,
      D => BU2_U0_rx_axi_shim_rx_data_reg(0),
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_axis_mac_tdata_3(0)
    );
  BU2_U0_rx_axi_shim_rx_mac_tdata_1 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_rx_axi_shim_rx_state_1_rx_enable_AND_17_o,
      D => BU2_U0_rx_axi_shim_rx_data_reg(1),
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_axis_mac_tdata_3(1)
    );
  BU2_U0_rx_axi_shim_rx_mac_tdata_2 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_rx_axi_shim_rx_state_1_rx_enable_AND_17_o,
      D => BU2_U0_rx_axi_shim_rx_data_reg(2),
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_axis_mac_tdata_3(2)
    );
  BU2_U0_rx_axi_shim_rx_mac_tdata_3 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_rx_axi_shim_rx_state_1_rx_enable_AND_17_o,
      D => BU2_U0_rx_axi_shim_rx_data_reg(3),
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_axis_mac_tdata_3(3)
    );
  BU2_U0_rx_axi_shim_rx_mac_tdata_4 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_rx_axi_shim_rx_state_1_rx_enable_AND_17_o,
      D => BU2_U0_rx_axi_shim_rx_data_reg(4),
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_axis_mac_tdata_3(4)
    );
  BU2_U0_rx_axi_shim_rx_mac_tdata_5 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_rx_axi_shim_rx_state_1_rx_enable_AND_17_o,
      D => BU2_U0_rx_axi_shim_rx_data_reg(5),
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_axis_mac_tdata_3(5)
    );
  BU2_U0_rx_axi_shim_rx_mac_tdata_6 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_rx_axi_shim_rx_state_1_rx_enable_AND_17_o,
      D => BU2_U0_rx_axi_shim_rx_data_reg(6),
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_axis_mac_tdata_3(6)
    );
  BU2_U0_rx_axi_shim_rx_mac_tdata_7 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_rx_axi_shim_rx_state_1_rx_enable_AND_17_o,
      D => BU2_U0_rx_axi_shim_rx_data_reg(7),
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_axis_mac_tdata_3(7)
    );
  BU2_U0_rx_axi_shim_fsmfake1_0 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_rx_axi_shim_next_rx_state(0),
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => BU2_U0_rx_axi_shim_fsmfake1(0)
    );
  BU2_U0_rx_axi_shim_rx_state_FSM_FFd2 : FDR
    port map (
      C => rx_axi_clk,
      D => BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_In,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => BU2_U0_rx_axi_shim_rx_state_FSM_FFd2_382
    );
  BU2_U0_rx_axi_shim_rx_state_FSM_FFd1 : FDR
    port map (
      C => rx_axi_clk,
      D => BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_In,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => BU2_U0_rx_axi_shim_rx_state_FSM_FFd1_380
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_0 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(0),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(0)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_1 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(1),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(1)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_2 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(2),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(2)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_3 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(3),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(3)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_4 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(4),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(4)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_5 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(5),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(5)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_6 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(6),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(6)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_7 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(7),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(7)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_8 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(8),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(8)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_9 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(9),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(9)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_10 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(10),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(10)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_11 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(11),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(11)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_12 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(12),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(12)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_13 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(13),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(13)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_14 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(14),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(14)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg_15 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_val_7(15),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_VAL_reg(15)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_REQ_reg : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => pause_req,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_PAUSE_REQ_reg_362
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd2 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd2_In,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd2_361
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_In_358,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_pausereq_mux_slt_FSM_FFd1_359
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr_0 : FDRE
    generic map(
      INIT => '0'
    )
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0056_inv,
      D => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Result(0),
      R => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0048,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(0)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr_1 : FDRE
    generic map(
      INIT => '0'
    )
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0056_inv,
      D => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Result(1),
      R => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0048,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(1)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr_2 : FDRE
    generic map(
      INIT => '0'
    )
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0056_inv,
      D => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Result(2),
      R => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0048,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(2)
    );
  BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr_3 : FDRE
    generic map(
      INIT => '0'
    )
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0056_inv,
      D => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_Result(3),
      R => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_n0048,
      Q => BU2_U0_PAUSESHIM_8_GEN_pausereq_shim_inst_tx_stats_bytevld_ctr(3)
    );
  BU2_U0_tx_axi_shim_tx_enable_reg : FD
    port map (
      C => tx_axi_clk,
      D => BU2_U0_TX_AXI_CLK_OUT_INT2,
      Q => BU2_U0_tx_axi_shim_tx_enable_reg_326
    );
  BU2_U0_tx_axi_shim_tx_data_hold_0 : FDRE
    port map (
      C => tx_axi_clk,
      CE => NlwRenamedSig_OI_tx_axis_mac_tready,
      D => tx_axis_mac_tdata_5(0),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data_hold(0)
    );
  BU2_U0_tx_axi_shim_tx_data_hold_1 : FDRE
    port map (
      C => tx_axi_clk,
      CE => NlwRenamedSig_OI_tx_axis_mac_tready,
      D => tx_axis_mac_tdata_5(1),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data_hold(1)
    );
  BU2_U0_tx_axi_shim_tx_data_hold_2 : FDRE
    port map (
      C => tx_axi_clk,
      CE => NlwRenamedSig_OI_tx_axis_mac_tready,
      D => tx_axis_mac_tdata_5(2),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data_hold(2)
    );
  BU2_U0_tx_axi_shim_tx_data_hold_3 : FDRE
    port map (
      C => tx_axi_clk,
      CE => NlwRenamedSig_OI_tx_axis_mac_tready,
      D => tx_axis_mac_tdata_5(3),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data_hold(3)
    );
  BU2_U0_tx_axi_shim_tx_data_hold_4 : FDRE
    port map (
      C => tx_axi_clk,
      CE => NlwRenamedSig_OI_tx_axis_mac_tready,
      D => tx_axis_mac_tdata_5(4),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data_hold(4)
    );
  BU2_U0_tx_axi_shim_tx_data_hold_5 : FDRE
    port map (
      C => tx_axi_clk,
      CE => NlwRenamedSig_OI_tx_axis_mac_tready,
      D => tx_axis_mac_tdata_5(5),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data_hold(5)
    );
  BU2_U0_tx_axi_shim_tx_data_hold_6 : FDRE
    port map (
      C => tx_axi_clk,
      CE => NlwRenamedSig_OI_tx_axis_mac_tready,
      D => tx_axis_mac_tdata_5(6),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data_hold(6)
    );
  BU2_U0_tx_axi_shim_tx_data_hold_7 : FDRE
    port map (
      C => tx_axi_clk,
      CE => NlwRenamedSig_OI_tx_axis_mac_tready,
      D => tx_axis_mac_tdata_5(7),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data_hold(7)
    );
  BU2_U0_tx_axi_shim_tx_ack_reg : FD
    port map (
      C => tx_axi_clk,
      D => BU2_U0_TX_ACK,
      Q => BU2_U0_tx_axi_shim_tx_ack_reg_339
    );
  BU2_U0_tx_axi_shim_tx_mac_tready_reg : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_next_tx_state_3_ignore_packet_OR_48_o,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_mac_tready_reg_338
    );
  BU2_U0_tx_axi_shim_gate_tready : FDS
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_PWR_20_o_tx_enable_MUX_106_o,
      S => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_gate_tready_336
    );
  BU2_U0_tx_axi_shim_tx_data_0 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      D => BU2_U0_tx_axi_shim_tx_data_0_dpot_334,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data(0)
    );
  BU2_U0_tx_axi_shim_tx_data_1 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      D => BU2_U0_tx_axi_shim_tx_data_1_dpot_333,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data(1)
    );
  BU2_U0_tx_axi_shim_tx_data_2 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      D => BU2_U0_tx_axi_shim_tx_data_2_dpot_332,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data(2)
    );
  BU2_U0_tx_axi_shim_tx_data_3 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      D => BU2_U0_tx_axi_shim_tx_data_3_dpot_331,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data(3)
    );
  BU2_U0_tx_axi_shim_tx_data_4 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      D => BU2_U0_tx_axi_shim_tx_data_4_dpot_330,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data(4)
    );
  BU2_U0_tx_axi_shim_tx_data_5 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      D => BU2_U0_tx_axi_shim_tx_data_5_dpot_329,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data(5)
    );
  BU2_U0_tx_axi_shim_tx_data_6 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      D => BU2_U0_tx_axi_shim_tx_data_6_dpot_328,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data(6)
    );
  BU2_U0_tx_axi_shim_tx_data_7 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_tx_axi_shim_tx_enable_reg_326,
      D => BU2_U0_tx_axi_shim_tx_data_7_dpot_327,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_data(7)
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd10 : FDS
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_29_o,
      S => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_state_FSM_FFd10_325
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd7 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_In_322,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_state_FSM_FFd7_323
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd9 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_28_o,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_state_FSM_FFd9_321
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd8 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_70_o,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_state_FSM_FFd8_319
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd4 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_next_tx_state_3_PWR_20_o_equal_74_o,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_state_FSM_FFd4_317
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd6 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_tx_state_FSM_FFd6_In,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_state_FSM_FFd6_315
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd5 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_71_o,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_state_FSM_FFd5_313
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd3 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_tx_state_FSM_FFd3_In_310,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_state_FSM_FFd3_311
    );
  BU2_U0_tx_axi_shim_tx_state_FSM_FFd2 : FDR
    port map (
      C => tx_axi_clk,
      D => BU2_U0_tx_axi_shim_next_tx_state_3_GND_20_o_equal_72_o,
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => BU2_U0_tx_axi_shim_tx_state_FSM_FFd2_309
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_0 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_0_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_statistics_vector_4(0)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_1 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_1_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_statistics_vector_4(1)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_2 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_2_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_statistics_vector_4(2)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_3 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_3_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_statistics_vector_4(3)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_4 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_4_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_statistics_vector_4(4)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_5 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_5_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => rx_statistics_vector_4(5)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_6 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_6_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(6)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_7 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_7_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(7)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_8 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_8_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(8)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_9 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_9_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(9)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_10 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_10_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(10)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_11 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_11_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(11)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_12 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_12_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(12)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_13 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_13_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(13)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_14 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_14_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(14)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_15 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_15_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(15)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_16 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_16_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(16)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_17 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_17_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(17)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_18 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_18_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(18)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_19 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_19_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(19)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_20 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_20_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(20)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_21 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_21_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(21)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_22 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_22_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(22)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_23 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_23_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(23)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_24 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_24_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(24)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_25 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_25_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(25)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_26 : FDRE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_26_Q,
      R => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(26)
    );
  BU2_U0_INT_RX_STATISTICS_VECTOR_27 : FDSE
    port map (
      C => rx_axi_clk,
      CE => BU2_U0_RX_CLIENT_CE,
      D => BU2_U0_RX_STATS_SHIFT_6_PWR_14_o_mux_4_OUT_27_Q,
      S => NlwRenamedSig_OI_rx_reset_out,
      Q => NlwRenamedSig_OI_rx_statistics_vector(27)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_0 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(0),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(0)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_1 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(1),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(1)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_2 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(2),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(2)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_3 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(3),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(3)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_4 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(4),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(4)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_5 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(5),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(5)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_6 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(6),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(6)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_7 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(7),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(7)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_8 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(8),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(8)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_9 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(9),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(9)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_10 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(10),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(10)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_11 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(11),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(11)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_12 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(12),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(12)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_13 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(13),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(13)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_14 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(14),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(14)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_15 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(15),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(15)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_16 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(16),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(16)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_17 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(17),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(17)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_18 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(18),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(18)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_19 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(19),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(19)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_20 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(20),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(20)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_21 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(21),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(21)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_22 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(22),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(22)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_23 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(23),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(23)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_24 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(24),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(24)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_25 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(25),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(25)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_26 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(26),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(26)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_27 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(27),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(27)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_28 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(28),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(28)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_29 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(29),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(29)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_30 : FDRE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(30),
      R => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(30)
    );
  BU2_U0_INT_TX_STATISTICS_VECTOR_31 : FDSE
    port map (
      C => tx_axi_clk,
      CE => BU2_U0_TX_AXI_CLK_OUT_INT2,
      D => BU2_U0_TX_STATS_SHIFT_PWR_14_o_mux_8_OUT(31),
      S => NlwRenamedSig_OI_tx_reset_out,
      Q => NlwRenamedSig_OI_tx_statistics_vector(31)
    );
  BU2_U0_SYNC_TX_RESET_I_R3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => tx_axi_clk,
      D => BU2_U0_SYNC_TX_RESET_I_R2_246,
      Q => BU2_U0_SYNC_TX_RESET_I_R3_247
    );
  BU2_U0_SYNC_TX_RESET_I_R2 : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => tx_axi_clk,
      D => BU2_U0_SYNC_TX_RESET_I_R1_245,
      PRE => BU2_U0_INT_TX_RST_ASYNCH,
      Q => BU2_U0_SYNC_TX_RESET_I_R2_246
    );
  BU2_U0_SYNC_TX_RESET_I_R1 : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => tx_axi_clk,
      D => BU2_rx_axis_filter_tuser(0),
      PRE => BU2_U0_INT_TX_RST_ASYNCH,
      Q => BU2_U0_SYNC_TX_RESET_I_R1_245
    );
  BU2_U0_SYNC_RX_RESET_I_R3 : FD
    generic map(
      INIT => '1'
    )
    port map (
      C => rx_axi_clk,
      D => BU2_U0_SYNC_RX_RESET_I_R2_242,
      Q => BU2_U0_SYNC_RX_RESET_I_R3_243
    );
  BU2_U0_SYNC_RX_RESET_I_R2 : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => rx_axi_clk,
      D => BU2_U0_SYNC_RX_RESET_I_R1_241,
      PRE => BU2_U0_INT_RX_RST_ASYNCH,
      Q => BU2_U0_SYNC_RX_RESET_I_R2_242
    );
  BU2_U0_SYNC_RX_RESET_I_R1 : FDP
    generic map(
      INIT => '1'
    )
    port map (
      C => rx_axi_clk,
      D => BU2_rx_axis_filter_tuser(0),
      PRE => BU2_U0_INT_RX_RST_ASYNCH,
      Q => BU2_U0_SYNC_RX_RESET_I_R1_241
    );
  BU2_U0_v6_emac : TEMAC_SINGLE
    generic map(
      EMAC_1000BASEX_ENABLE => FALSE,
      EMAC_ADDRFILTER_ENABLE => FALSE,
      EMAC_BYTEPHY => FALSE,
      EMAC_CTRLLENCHECK_DISABLE => TRUE,
      EMAC_DCRBASEADDR => X"00",
      EMAC_GTLOOPBACK => FALSE,
      EMAC_HOST_ENABLE => FALSE,
      EMAC_LINKTIMERVAL => X"031",
      EMAC_LTCHECK_DISABLE => TRUE,
      EMAC_MDIO_ENABLE => FALSE,
      EMAC_MDIO_IGNORE_PHYADZERO => FALSE,
      EMAC_PAUSEADDR => X"000000000000",
      EMAC_PHYINITAUTONEG_ENABLE => FALSE,
      EMAC_PHYISOLATE => FALSE,
      EMAC_PHYLOOPBACKMSB => FALSE,
      EMAC_PHYPOWERDOWN => FALSE,
      EMAC_PHYRESET => FALSE,
      EMAC_RGMII_ENABLE => FALSE,
      EMAC_RX16BITCLIENT_ENABLE => FALSE,
      EMAC_RXFLOWCTRL_ENABLE => FALSE,
      EMAC_RXHALFDUPLEX => FALSE,
      EMAC_RXINBANDFCS_ENABLE => FALSE,
      EMAC_RXJUMBOFRAME_ENABLE => FALSE,
      EMAC_RXRESET => FALSE,
      EMAC_RXVLAN_ENABLE => FALSE,
      EMAC_RX_ENABLE => TRUE,
      EMAC_SGMII_ENABLE => FALSE,
      EMAC_SPEED_LSB => FALSE,
      EMAC_SPEED_MSB => TRUE,
      EMAC_TX16BITCLIENT_ENABLE => FALSE,
      EMAC_TXFLOWCTRL_ENABLE => FALSE,
      EMAC_TXHALFDUPLEX => FALSE,
      EMAC_TXIFGADJUST_ENABLE => FALSE,
      EMAC_TXINBANDFCS_ENABLE => FALSE,
      EMAC_TXJUMBOFRAME_ENABLE => FALSE,
      EMAC_TXRESET => FALSE,
      EMAC_TXVLAN_ENABLE => FALSE,
      EMAC_TX_ENABLE => TRUE,
      EMAC_UNICASTADDR => X"000000000000",
      EMAC_UNIDIRECTION_ENABLE => FALSE,
      EMAC_USECLKEN => TRUE,
      SIM_VERSION => "1.0"
    )
    port map (
      EMACCLIENTTXCLIENTCLKOUT => BU2_U0_TX_AXI_CLK_OUT_INT2,
      EMACPHYTXCHARDISPMODE => BU2_txchardispmode,
      HOSTMIIMRDY => NLW_BU2_U0_v6_emac_HOSTMIIMRDY_UNCONNECTED,
      EMACPHYSYNCACQSTATUS => BU2_syncacqstatus,
      EMACCLIENTTXSTATSBYTEVLD => BU2_U0_TX_STATS_BYTEVLD,
      DCRHOSTDONEIR => NLW_BU2_U0_v6_emac_DCRHOSTDONEIR_UNCONNECTED,
      PHYEMACGTXCLK => BU2_rx_axis_filter_tuser(0),
      EMACPHYMGTRXRESET => BU2_mgtrxreset,
      PHYEMACRXCLK => rx_axi_clk,
      DCREMACENABLE => BU2_rx_axis_filter_tuser(0),
      EMACSPEEDIS10100 => NlwRenamedSig_OI_speed_is_10_100,
      PHYEMACTXGMIIMIICLKIN => tx_axi_clk,
      EMACCLIENTTXACK => BU2_U0_TX_ACK,
      EMACPHYTXCHARISK => BU2_txcharisk,
      PHYEMACRXRUNDISP => N0,
      PHYEMACMIITXCLK => tx_axi_clk,
      CLIENTEMACTXFIRSTBYTE => BU2_rx_axis_filter_tuser(0),
      EMACPHYTXGMIIMIICLKOUT => BU2_tx_axi_clk_out,
      HOSTMIIMSEL => BU2_rx_axis_filter_tuser(0),
      EMACCLIENTANINTERRUPT => BU2_aninterrupt,
      EMACPHYENCOMMAALIGN => BU2_encommaalign,
      EMACPHYMDTRI => BU2_mdio_tri,
      EMACCLIENTRXDVLD => BU2_U0_RX_DATA_VALID,
      EMACPHYTXEN => BU2_U0_GMII_TX_EN_INT,
      PHYEMACRXNOTINTABLE => N0,
      EMACCLIENTRXGOODFRAME => BU2_U0_RX_GOOD_FRAME,
      DCREMACCLK => BU2_rx_axis_filter_tuser(0),
      DCREMACWRITE => BU2_rx_axis_filter_tuser(0),
      CLIENTEMACDCMLOCKED => N1,
      PHYEMACRXDV => gmii_rx_dv,
      PHYEMACRXCHARISK => N0,
      PHYEMACTXBUFERR => N0,
      EMACPHYMCLKOUT => BU2_mdc_out,
      CLIENTEMACPAUSEREQ => BU2_U0_PAUSE_REQ_INT,
      CLIENTEMACTXUNDERRUN => BU2_U0_tx_axi_shim_tx_underrun_184,
      EMACCLIENTRXFRAMEDROP => NLW_BU2_U0_v6_emac_EMACCLIENTRXFRAMEDROP_UNCONNECTED,
      EMACCLIENTRXDVLDMSW => NLW_BU2_U0_v6_emac_EMACCLIENTRXDVLDMSW_UNCONNECTED,
      EMACCLIENTRXCLIENTCLKOUT => BU2_U0_RX_CLIENT_CE,
      CLIENTEMACTXCLIENTCLKIN => BU2_rx_axis_filter_tuser(0),
      PHYEMACCRS => gmii_crs,
      EMACCLIENTTXRETRANSMIT => NlwRenamedSig_OI_tx_retransmit,
      PHYEMACMCLKIN => N0,
      CLIENTEMACTXDVLDMSW => BU2_rx_axis_filter_tuser(0),
      EMACCLIENTRXSTATSBYTEVLD => NLW_BU2_U0_v6_emac_EMACCLIENTRXSTATSBYTEVLD_UNCONNECTED,
      EMACPHYTXCHARDISPVAL => BU2_txchardispval,
      PHYEMACRXDISPERR => N0,
      PHYEMACRXCHARISCOMMA => N0,
      EMACPHYMDOUT => BU2_mdio_out,
      EMACPHYMGTTXRESET => BU2_mgttxreset,
      PHYEMACCOL => gmii_col,
      CLIENTEMACTXDVLD => BU2_U0_tx_axi_shim_tx_data_valid_186,
      EMACCLIENTTXSTATSVLD => BU2_U0_TX_STATS_SHIFT_VLD,
      PHYEMACMDIN => N0,
      EMACCLIENTTXCOLLISION => NlwRenamedSig_OI_tx_collision,
      PHYEMACSIGNALDET => N0,
      EMACCLIENTRXSTATSVLD => BU2_U0_RX_STATS_SHIFT_VLD,
      HOSTREQ => BU2_rx_axis_filter_tuser(0),
      EMACDCRACK => NLW_BU2_U0_v6_emac_EMACDCRACK_UNCONNECTED,
      HOSTCLK => N0,
      PHYEMACRXER => gmii_rx_er,
      EMACPHYTXCLK => NLW_BU2_U0_v6_emac_EMACPHYTXCLK_UNCONNECTED,
      EMACPHYTXER => BU2_U0_GMII_TX_ER_INT,
      EMACPHYPOWERDOWN => BU2_powerdown,
      EMACPHYLOOPBACKMSB => BU2_loopbackmsb,
      CLIENTEMACRXCLIENTCLKIN => BU2_rx_axis_filter_tuser(0),
      EMACCLIENTTXSTATS => BU2_U0_TX_STATS_SHIFT,
      RESET => BU2_U0_INT_GLBL_RST,
      DCREMACREAD => BU2_rx_axis_filter_tuser(0),
      EMACCLIENTRXBADFRAME => BU2_U0_RX_BAD_FRAME,
      CLIENTEMACTXD(15) => BU2_rx_axis_filter_tuser(0),
      CLIENTEMACTXD(14) => BU2_rx_axis_filter_tuser(0),
      CLIENTEMACTXD(13) => BU2_rx_axis_filter_tuser(0),
      CLIENTEMACTXD(12) => BU2_rx_axis_filter_tuser(0),
      CLIENTEMACTXD(11) => BU2_rx_axis_filter_tuser(0),
      CLIENTEMACTXD(10) => BU2_rx_axis_filter_tuser(0),
      CLIENTEMACTXD(9) => BU2_rx_axis_filter_tuser(0),
      CLIENTEMACTXD(8) => BU2_rx_axis_filter_tuser(0),
      CLIENTEMACTXD(7) => BU2_U0_tx_axi_shim_tx_data(7),
      CLIENTEMACTXD(6) => BU2_U0_tx_axi_shim_tx_data(6),
      CLIENTEMACTXD(5) => BU2_U0_tx_axi_shim_tx_data(5),
      CLIENTEMACTXD(4) => BU2_U0_tx_axi_shim_tx_data(4),
      CLIENTEMACTXD(3) => BU2_U0_tx_axi_shim_tx_data(3),
      CLIENTEMACTXD(2) => BU2_U0_tx_axi_shim_tx_data(2),
      CLIENTEMACTXD(1) => BU2_U0_tx_axi_shim_tx_data(1),
      CLIENTEMACTXD(0) => BU2_U0_tx_axi_shim_tx_data(0),
      HOSTWRDATA(31) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(30) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(29) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(28) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(27) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(26) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(25) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(24) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(23) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(22) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(21) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(20) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(19) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(18) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(17) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(16) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(15) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(14) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(13) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(12) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(11) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(10) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(9) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(8) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(7) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(6) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(5) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(4) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(3) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(2) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(1) => BU2_rx_axis_filter_tuser(0),
      HOSTWRDATA(0) => BU2_rx_axis_filter_tuser(0),
      EMACCLIENTRXD(15) => NLW_BU2_U0_v6_emac_EMACCLIENTRXD_15_UNCONNECTED,
      EMACCLIENTRXD(14) => NLW_BU2_U0_v6_emac_EMACCLIENTRXD_14_UNCONNECTED,
      EMACCLIENTRXD(13) => NLW_BU2_U0_v6_emac_EMACCLIENTRXD_13_UNCONNECTED,
      EMACCLIENTRXD(12) => NLW_BU2_U0_v6_emac_EMACCLIENTRXD_12_UNCONNECTED,
      EMACCLIENTRXD(11) => NLW_BU2_U0_v6_emac_EMACCLIENTRXD_11_UNCONNECTED,
      EMACCLIENTRXD(10) => NLW_BU2_U0_v6_emac_EMACCLIENTRXD_10_UNCONNECTED,
      EMACCLIENTRXD(9) => NLW_BU2_U0_v6_emac_EMACCLIENTRXD_9_UNCONNECTED,
      EMACCLIENTRXD(8) => NLW_BU2_U0_v6_emac_EMACCLIENTRXD_8_UNCONNECTED,
      EMACCLIENTRXD(7) => BU2_U0_RX_DATA(7),
      EMACCLIENTRXD(6) => BU2_U0_RX_DATA(6),
      EMACCLIENTRXD(5) => BU2_U0_RX_DATA(5),
      EMACCLIENTRXD(4) => BU2_U0_RX_DATA(4),
      EMACCLIENTRXD(3) => BU2_U0_RX_DATA(3),
      EMACCLIENTRXD(2) => BU2_U0_RX_DATA(2),
      EMACCLIENTRXD(1) => BU2_U0_RX_DATA(1),
      EMACCLIENTRXD(0) => BU2_U0_RX_DATA(0),
      EMACPHYTXD(7) => BU2_U0_GMII_TXD_INT(7),
      EMACPHYTXD(6) => BU2_U0_GMII_TXD_INT(6),
      EMACPHYTXD(5) => BU2_U0_GMII_TXD_INT(5),
      EMACPHYTXD(4) => BU2_U0_GMII_TXD_INT(4),
      EMACPHYTXD(3) => BU2_U0_GMII_TXD_INT(3),
      EMACPHYTXD(2) => BU2_U0_GMII_TXD_INT(2),
      EMACPHYTXD(1) => BU2_U0_GMII_TXD_INT(1),
      EMACPHYTXD(0) => BU2_U0_GMII_TXD_INT(0),
      PHYEMACRXD(7) => gmii_rxd_8(7),
      PHYEMACRXD(6) => gmii_rxd_8(6),
      PHYEMACRXD(5) => gmii_rxd_8(5),
      PHYEMACRXD(4) => gmii_rxd_8(4),
      PHYEMACRXD(3) => gmii_rxd_8(3),
      PHYEMACRXD(2) => gmii_rxd_8(2),
      PHYEMACRXD(1) => gmii_rxd_8(1),
      PHYEMACRXD(0) => gmii_rxd_8(0),
      PHYEMACRXCLKCORCNT(2) => N0,
      PHYEMACRXCLKCORCNT(1) => N0,
      PHYEMACRXCLKCORCNT(0) => N0,
      CLIENTEMACPAUSEVAL(15) => BU2_U0_PAUSE_VAL_INT(15),
      CLIENTEMACPAUSEVAL(14) => BU2_U0_PAUSE_VAL_INT(14),
      CLIENTEMACPAUSEVAL(13) => BU2_U0_PAUSE_VAL_INT(13),
      CLIENTEMACPAUSEVAL(12) => BU2_U0_PAUSE_VAL_INT(12),
      CLIENTEMACPAUSEVAL(11) => BU2_U0_PAUSE_VAL_INT(11),
      CLIENTEMACPAUSEVAL(10) => BU2_U0_PAUSE_VAL_INT(10),
      CLIENTEMACPAUSEVAL(9) => BU2_U0_PAUSE_VAL_INT(9),
      CLIENTEMACPAUSEVAL(8) => BU2_U0_PAUSE_VAL_INT(8),
      CLIENTEMACPAUSEVAL(7) => BU2_U0_PAUSE_VAL_INT(7),
      CLIENTEMACPAUSEVAL(6) => BU2_U0_PAUSE_VAL_INT(6),
      CLIENTEMACPAUSEVAL(5) => BU2_U0_PAUSE_VAL_INT(5),
      CLIENTEMACPAUSEVAL(4) => BU2_U0_PAUSE_VAL_INT(4),
      CLIENTEMACPAUSEVAL(3) => BU2_U0_PAUSE_VAL_INT(3),
      CLIENTEMACPAUSEVAL(2) => BU2_U0_PAUSE_VAL_INT(2),
      CLIENTEMACPAUSEVAL(1) => BU2_U0_PAUSE_VAL_INT(1),
      CLIENTEMACPAUSEVAL(0) => BU2_U0_PAUSE_VAL_INT(0),
      EMACDCRDBUS(0) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_0_UNCONNECTED,
      EMACDCRDBUS(1) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_1_UNCONNECTED,
      EMACDCRDBUS(2) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_2_UNCONNECTED,
      EMACDCRDBUS(3) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_3_UNCONNECTED,
      EMACDCRDBUS(4) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_4_UNCONNECTED,
      EMACDCRDBUS(5) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_5_UNCONNECTED,
      EMACDCRDBUS(6) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_6_UNCONNECTED,
      EMACDCRDBUS(7) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_7_UNCONNECTED,
      EMACDCRDBUS(8) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_8_UNCONNECTED,
      EMACDCRDBUS(9) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_9_UNCONNECTED,
      EMACDCRDBUS(10) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_10_UNCONNECTED,
      EMACDCRDBUS(11) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_11_UNCONNECTED,
      EMACDCRDBUS(12) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_12_UNCONNECTED,
      EMACDCRDBUS(13) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_13_UNCONNECTED,
      EMACDCRDBUS(14) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_14_UNCONNECTED,
      EMACDCRDBUS(15) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_15_UNCONNECTED,
      EMACDCRDBUS(16) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_16_UNCONNECTED,
      EMACDCRDBUS(17) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_17_UNCONNECTED,
      EMACDCRDBUS(18) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_18_UNCONNECTED,
      EMACDCRDBUS(19) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_19_UNCONNECTED,
      EMACDCRDBUS(20) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_20_UNCONNECTED,
      EMACDCRDBUS(21) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_21_UNCONNECTED,
      EMACDCRDBUS(22) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_22_UNCONNECTED,
      EMACDCRDBUS(23) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_23_UNCONNECTED,
      EMACDCRDBUS(24) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_24_UNCONNECTED,
      EMACDCRDBUS(25) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_25_UNCONNECTED,
      EMACDCRDBUS(26) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_26_UNCONNECTED,
      EMACDCRDBUS(27) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_27_UNCONNECTED,
      EMACDCRDBUS(28) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_28_UNCONNECTED,
      EMACDCRDBUS(29) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_29_UNCONNECTED,
      EMACDCRDBUS(30) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_30_UNCONNECTED,
      EMACDCRDBUS(31) => NLW_BU2_U0_v6_emac_EMACDCRDBUS_31_UNCONNECTED,
      HOSTADDR(9) => BU2_rx_axis_filter_tuser(0),
      HOSTADDR(8) => BU2_rx_axis_filter_tuser(0),
      HOSTADDR(7) => BU2_rx_axis_filter_tuser(0),
      HOSTADDR(6) => BU2_rx_axis_filter_tuser(0),
      HOSTADDR(5) => BU2_rx_axis_filter_tuser(0),
      HOSTADDR(4) => BU2_rx_axis_filter_tuser(0),
      HOSTADDR(3) => BU2_rx_axis_filter_tuser(0),
      HOSTADDR(2) => BU2_rx_axis_filter_tuser(0),
      HOSTADDR(1) => BU2_rx_axis_filter_tuser(0),
      HOSTADDR(0) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(0) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(1) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(2) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(3) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(4) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(5) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(6) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(7) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(8) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(9) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(10) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(11) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(12) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(13) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(14) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(15) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(16) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(17) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(18) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(19) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(20) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(21) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(22) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(23) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(24) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(25) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(26) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(27) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(28) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(29) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(30) => BU2_rx_axis_filter_tuser(0),
      DCREMACDBUS(31) => BU2_rx_axis_filter_tuser(0),
      EMACCLIENTRXSTATS(6) => BU2_U0_RX_STATS_SHIFT(6),
      EMACCLIENTRXSTATS(5) => BU2_U0_RX_STATS_SHIFT(5),
      EMACCLIENTRXSTATS(4) => BU2_U0_RX_STATS_SHIFT(4),
      EMACCLIENTRXSTATS(3) => BU2_U0_RX_STATS_SHIFT(3),
      EMACCLIENTRXSTATS(2) => BU2_U0_RX_STATS_SHIFT(2),
      EMACCLIENTRXSTATS(1) => BU2_U0_RX_STATS_SHIFT(1),
      EMACCLIENTRXSTATS(0) => BU2_U0_RX_STATS_SHIFT(0),
      DCREMACABUS(0) => BU2_rx_axis_filter_tuser(0),
      DCREMACABUS(1) => BU2_rx_axis_filter_tuser(0),
      DCREMACABUS(2) => BU2_rx_axis_filter_tuser(0),
      DCREMACABUS(3) => BU2_rx_axis_filter_tuser(0),
      DCREMACABUS(4) => BU2_rx_axis_filter_tuser(0),
      DCREMACABUS(5) => BU2_rx_axis_filter_tuser(0),
      DCREMACABUS(6) => BU2_rx_axis_filter_tuser(0),
      DCREMACABUS(7) => BU2_rx_axis_filter_tuser(0),
      DCREMACABUS(8) => BU2_rx_axis_filter_tuser(0),
      DCREMACABUS(9) => BU2_rx_axis_filter_tuser(0),
      HOSTOPCODE(1) => BU2_rx_axis_filter_tuser(0),
      HOSTOPCODE(0) => BU2_rx_axis_filter_tuser(0),
      CLIENTEMACTXIFGDELAY(7) => tx_ifg_delay_6(7),
      CLIENTEMACTXIFGDELAY(6) => tx_ifg_delay_6(6),
      CLIENTEMACTXIFGDELAY(5) => tx_ifg_delay_6(5),
      CLIENTEMACTXIFGDELAY(4) => tx_ifg_delay_6(4),
      CLIENTEMACTXIFGDELAY(3) => tx_ifg_delay_6(3),
      CLIENTEMACTXIFGDELAY(2) => tx_ifg_delay_6(2),
      CLIENTEMACTXIFGDELAY(1) => tx_ifg_delay_6(1),
      CLIENTEMACTXIFGDELAY(0) => tx_ifg_delay_6(0),
      PHYEMACPHYAD(4) => N0,
      PHYEMACPHYAD(3) => N0,
      PHYEMACPHYAD(2) => N0,
      PHYEMACPHYAD(1) => N0,
      PHYEMACPHYAD(0) => N0,
      PHYEMACRXBUFSTATUS(1) => N0,
      PHYEMACRXBUFSTATUS(0) => BU2_rx_axis_filter_tuser(0),
      HOSTRDDATA(31) => NLW_BU2_U0_v6_emac_HOSTRDDATA_31_UNCONNECTED,
      HOSTRDDATA(30) => NLW_BU2_U0_v6_emac_HOSTRDDATA_30_UNCONNECTED,
      HOSTRDDATA(29) => NLW_BU2_U0_v6_emac_HOSTRDDATA_29_UNCONNECTED,
      HOSTRDDATA(28) => NLW_BU2_U0_v6_emac_HOSTRDDATA_28_UNCONNECTED,
      HOSTRDDATA(27) => NLW_BU2_U0_v6_emac_HOSTRDDATA_27_UNCONNECTED,
      HOSTRDDATA(26) => NLW_BU2_U0_v6_emac_HOSTRDDATA_26_UNCONNECTED,
      HOSTRDDATA(25) => NLW_BU2_U0_v6_emac_HOSTRDDATA_25_UNCONNECTED,
      HOSTRDDATA(24) => NLW_BU2_U0_v6_emac_HOSTRDDATA_24_UNCONNECTED,
      HOSTRDDATA(23) => NLW_BU2_U0_v6_emac_HOSTRDDATA_23_UNCONNECTED,
      HOSTRDDATA(22) => NLW_BU2_U0_v6_emac_HOSTRDDATA_22_UNCONNECTED,
      HOSTRDDATA(21) => NLW_BU2_U0_v6_emac_HOSTRDDATA_21_UNCONNECTED,
      HOSTRDDATA(20) => NLW_BU2_U0_v6_emac_HOSTRDDATA_20_UNCONNECTED,
      HOSTRDDATA(19) => NLW_BU2_U0_v6_emac_HOSTRDDATA_19_UNCONNECTED,
      HOSTRDDATA(18) => NLW_BU2_U0_v6_emac_HOSTRDDATA_18_UNCONNECTED,
      HOSTRDDATA(17) => NLW_BU2_U0_v6_emac_HOSTRDDATA_17_UNCONNECTED,
      HOSTRDDATA(16) => NLW_BU2_U0_v6_emac_HOSTRDDATA_16_UNCONNECTED,
      HOSTRDDATA(15) => NLW_BU2_U0_v6_emac_HOSTRDDATA_15_UNCONNECTED,
      HOSTRDDATA(14) => NLW_BU2_U0_v6_emac_HOSTRDDATA_14_UNCONNECTED,
      HOSTRDDATA(13) => NLW_BU2_U0_v6_emac_HOSTRDDATA_13_UNCONNECTED,
      HOSTRDDATA(12) => NLW_BU2_U0_v6_emac_HOSTRDDATA_12_UNCONNECTED,
      HOSTRDDATA(11) => NLW_BU2_U0_v6_emac_HOSTRDDATA_11_UNCONNECTED,
      HOSTRDDATA(10) => NLW_BU2_U0_v6_emac_HOSTRDDATA_10_UNCONNECTED,
      HOSTRDDATA(9) => NLW_BU2_U0_v6_emac_HOSTRDDATA_9_UNCONNECTED,
      HOSTRDDATA(8) => NLW_BU2_U0_v6_emac_HOSTRDDATA_8_UNCONNECTED,
      HOSTRDDATA(7) => NLW_BU2_U0_v6_emac_HOSTRDDATA_7_UNCONNECTED,
      HOSTRDDATA(6) => NLW_BU2_U0_v6_emac_HOSTRDDATA_6_UNCONNECTED,
      HOSTRDDATA(5) => NLW_BU2_U0_v6_emac_HOSTRDDATA_5_UNCONNECTED,
      HOSTRDDATA(4) => NLW_BU2_U0_v6_emac_HOSTRDDATA_4_UNCONNECTED,
      HOSTRDDATA(3) => NLW_BU2_U0_v6_emac_HOSTRDDATA_3_UNCONNECTED,
      HOSTRDDATA(2) => NLW_BU2_U0_v6_emac_HOSTRDDATA_2_UNCONNECTED,
      HOSTRDDATA(1) => NLW_BU2_U0_v6_emac_HOSTRDDATA_1_UNCONNECTED,
      HOSTRDDATA(0) => NLW_BU2_U0_v6_emac_HOSTRDDATA_0_UNCONNECTED
    );
  BU2_XST_GND : GND
    port map (
      G => BU2_rx_axis_filter_tuser(0)
    );

end STRUCTURE;

-- synthesis translate_on
