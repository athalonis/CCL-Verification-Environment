onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group dcm_module /tb_gmii/my_top/dcm/CLK_IN
add wave -noupdate -group dcm_module /tb_gmii/my_top/dcm/CLK_125_OUT
add wave -noupdate -group dcm_module /tb_gmii/my_top/dcm/CLK_200_OUT
add wave -noupdate -group dcm_module /tb_gmii/my_top/dcm/CLK_250_OUT
add wave -noupdate -group dcm_module /tb_gmii/my_top/dcm/RESET
add wave -noupdate -group dcm_module /tb_gmii/my_top/dcm/LOCKED
add wave -noupdate -group dcm_module /tb_gmii/my_top/dcm/CLK_IN
add wave -noupdate -group dcm_module /tb_gmii/my_top/dcm/CLK_125_OUT
add wave -noupdate -group dcm_module /tb_gmii/my_top/dcm/CLK_200_OUT
add wave -noupdate -group dcm_module /tb_gmii/my_top/dcm/CLK_250_OUT
add wave -noupdate -group dcm_module /tb_gmii/my_top/dcm/RESET
add wave -noupdate -group dcm_module /tb_gmii/my_top/dcm/LOCKED
add wave -noupdate -group top_io /tb_gmii/my_top/rst_in_n
add wave -noupdate -group top_io /tb_gmii/my_top/clk_in
add wave -noupdate -group top_io /tb_gmii/my_top/led_out
add wave -noupdate -group top_io /tb_gmii/my_top/phy_resetn
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_txd
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_tx_en
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_tx_er
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_tx_clk
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_rxd
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_rx_dv
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_rx_er
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_rx_clk
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_col
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_crs
add wave -noupdate -group top_io /tb_gmii/my_top/mii_tx_clk
add wave -noupdate -group top_io /tb_gmii/my_top/rst_in_n
add wave -noupdate -group top_io /tb_gmii/my_top/clk_in
add wave -noupdate -group top_io /tb_gmii/my_top/led_out
add wave -noupdate -group top_io /tb_gmii/my_top/phy_resetn
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_txd
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_tx_en
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_tx_er
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_tx_clk
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_rxd
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_rx_dv
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_rx_er
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_rx_clk
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_col
add wave -noupdate -group top_io /tb_gmii/my_top/gmii_crs
add wave -noupdate -group top_io /tb_gmii/my_top/mii_tx_clk
add wave -noupdate /tb_gmii/my_top/cu/rst_in
add wave -noupdate /tb_gmii/my_top/cu/rx_clk_in
add wave -noupdate /tb_gmii/my_top/cu/rx_2clk_in
add wave -noupdate /tb_gmii/my_top/cu/dec_valid_in
add wave -noupdate /tb_gmii/my_top/cu/write_in
add wave -noupdate /tb_gmii/my_top/cu/type_in
add wave -noupdate /tb_gmii/my_top/cu/id_in
add wave -noupdate /tb_gmii/my_top/cu/length_in
add wave -noupdate /tb_gmii/my_top/cu/data_in
add wave -noupdate /tb_gmii/my_top/cu/header_error_in
add wave -noupdate -group TX_DATA /tb_gmii/my_top/cu/enc_valid_out
add wave -noupdate -group TX_DATA /tb_gmii/my_top/cu/type_out
add wave -noupdate -group TX_DATA /tb_gmii/my_top/cu/id_out
add wave -noupdate -group TX_DATA /tb_gmii/my_top/cu/length_out
add wave -noupdate -group TX_DATA -childformat {{/tb_gmii/my_top/cu/data_out(156) -radix unsigned} {/tb_gmii/my_top/cu/data_out(155) -radix unsigned} {/tb_gmii/my_top/cu/data_out(154) -radix unsigned} {/tb_gmii/my_top/cu/data_out(153) -radix unsigned} {/tb_gmii/my_top/cu/data_out(152) -radix unsigned} {/tb_gmii/my_top/cu/data_out(151) -radix unsigned} {/tb_gmii/my_top/cu/data_out(150) -radix unsigned} {/tb_gmii/my_top/cu/data_out(149) -radix unsigned} {/tb_gmii/my_top/cu/data_out(148) -radix unsigned} {/tb_gmii/my_top/cu/data_out(147) -radix unsigned} {/tb_gmii/my_top/cu/data_out(146) -radix unsigned} {/tb_gmii/my_top/cu/data_out(145) -radix unsigned} {/tb_gmii/my_top/cu/data_out(144) -radix unsigned} {/tb_gmii/my_top/cu/data_out(143) -radix unsigned} {/tb_gmii/my_top/cu/data_out(142) -radix unsigned} {/tb_gmii/my_top/cu/data_out(141) -radix unsigned} {/tb_gmii/my_top/cu/data_out(140) -radix unsigned} {/tb_gmii/my_top/cu/data_out(139) -radix unsigned} {/tb_gmii/my_top/cu/data_out(138) -radix unsigned} {/tb_gmii/my_top/cu/data_out(137) -radix unsigned} {/tb_gmii/my_top/cu/data_out(136) -radix unsigned} {/tb_gmii/my_top/cu/data_out(135) -radix unsigned} {/tb_gmii/my_top/cu/data_out(134) -radix unsigned} {/tb_gmii/my_top/cu/data_out(133) -radix unsigned} {/tb_gmii/my_top/cu/data_out(132) -radix unsigned} {/tb_gmii/my_top/cu/data_out(131) -radix unsigned} {/tb_gmii/my_top/cu/data_out(130) -radix unsigned} {/tb_gmii/my_top/cu/data_out(129) -radix unsigned} {/tb_gmii/my_top/cu/data_out(128) -radix unsigned} {/tb_gmii/my_top/cu/data_out(127) -radix unsigned} {/tb_gmii/my_top/cu/data_out(126) -radix unsigned} {/tb_gmii/my_top/cu/data_out(125) -radix unsigned} {/tb_gmii/my_top/cu/data_out(124) -radix unsigned} {/tb_gmii/my_top/cu/data_out(123) -radix unsigned} {/tb_gmii/my_top/cu/data_out(122) -radix unsigned} {/tb_gmii/my_top/cu/data_out(121) -radix unsigned} {/tb_gmii/my_top/cu/data_out(120) -radix unsigned} {/tb_gmii/my_top/cu/data_out(119) -radix unsigned} {/tb_gmii/my_top/cu/data_out(118) -radix unsigned} {/tb_gmii/my_top/cu/data_out(117) -radix unsigned} {/tb_gmii/my_top/cu/data_out(116) -radix unsigned} {/tb_gmii/my_top/cu/data_out(115) -radix unsigned} {/tb_gmii/my_top/cu/data_out(114) -radix unsigned} {/tb_gmii/my_top/cu/data_out(113) -radix unsigned} {/tb_gmii/my_top/cu/data_out(112) -radix unsigned}} -subitemconfig {/tb_gmii/my_top/cu/data_out(156) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(155) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(154) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(153) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(152) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(151) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(150) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(149) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(148) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(147) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(146) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(145) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(144) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(143) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(142) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(141) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(140) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(139) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(138) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(137) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(136) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(135) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(134) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(133) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(132) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(131) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(130) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(129) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(128) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(127) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(126) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(125) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(124) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(123) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(122) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(121) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(120) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(119) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(118) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(117) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(116) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(115) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(114) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(113) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(112) {-height 17 -radix unsigned}} /tb_gmii/my_top/cu/data_out
add wave -noupdate -group TX_DATA /tb_gmii/my_top/cu/enc_valid_out
add wave -noupdate -group TX_DATA /tb_gmii/my_top/cu/type_out
add wave -noupdate -group TX_DATA /tb_gmii/my_top/cu/id_out
add wave -noupdate -group TX_DATA /tb_gmii/my_top/cu/length_out
add wave -noupdate -group TX_DATA -childformat {{/tb_gmii/my_top/cu/data_out(156) -radix unsigned} {/tb_gmii/my_top/cu/data_out(155) -radix unsigned} {/tb_gmii/my_top/cu/data_out(154) -radix unsigned} {/tb_gmii/my_top/cu/data_out(153) -radix unsigned} {/tb_gmii/my_top/cu/data_out(152) -radix unsigned} {/tb_gmii/my_top/cu/data_out(151) -radix unsigned} {/tb_gmii/my_top/cu/data_out(150) -radix unsigned} {/tb_gmii/my_top/cu/data_out(149) -radix unsigned} {/tb_gmii/my_top/cu/data_out(148) -radix unsigned} {/tb_gmii/my_top/cu/data_out(147) -radix unsigned} {/tb_gmii/my_top/cu/data_out(146) -radix unsigned} {/tb_gmii/my_top/cu/data_out(145) -radix unsigned} {/tb_gmii/my_top/cu/data_out(144) -radix unsigned} {/tb_gmii/my_top/cu/data_out(143) -radix unsigned} {/tb_gmii/my_top/cu/data_out(142) -radix unsigned} {/tb_gmii/my_top/cu/data_out(141) -radix unsigned} {/tb_gmii/my_top/cu/data_out(140) -radix unsigned} {/tb_gmii/my_top/cu/data_out(139) -radix unsigned} {/tb_gmii/my_top/cu/data_out(138) -radix unsigned} {/tb_gmii/my_top/cu/data_out(137) -radix unsigned} {/tb_gmii/my_top/cu/data_out(136) -radix unsigned} {/tb_gmii/my_top/cu/data_out(135) -radix unsigned} {/tb_gmii/my_top/cu/data_out(134) -radix unsigned} {/tb_gmii/my_top/cu/data_out(133) -radix unsigned} {/tb_gmii/my_top/cu/data_out(132) -radix unsigned} {/tb_gmii/my_top/cu/data_out(131) -radix unsigned} {/tb_gmii/my_top/cu/data_out(130) -radix unsigned} {/tb_gmii/my_top/cu/data_out(129) -radix unsigned} {/tb_gmii/my_top/cu/data_out(128) -radix unsigned} {/tb_gmii/my_top/cu/data_out(127) -radix unsigned} {/tb_gmii/my_top/cu/data_out(126) -radix unsigned} {/tb_gmii/my_top/cu/data_out(125) -radix unsigned} {/tb_gmii/my_top/cu/data_out(124) -radix unsigned} {/tb_gmii/my_top/cu/data_out(123) -radix unsigned} {/tb_gmii/my_top/cu/data_out(122) -radix unsigned} {/tb_gmii/my_top/cu/data_out(121) -radix unsigned} {/tb_gmii/my_top/cu/data_out(120) -radix unsigned} {/tb_gmii/my_top/cu/data_out(119) -radix unsigned} {/tb_gmii/my_top/cu/data_out(118) -radix unsigned} {/tb_gmii/my_top/cu/data_out(117) -radix unsigned} {/tb_gmii/my_top/cu/data_out(116) -radix unsigned} {/tb_gmii/my_top/cu/data_out(115) -radix unsigned} {/tb_gmii/my_top/cu/data_out(114) -radix unsigned} {/tb_gmii/my_top/cu/data_out(113) -radix unsigned} {/tb_gmii/my_top/cu/data_out(112) -radix unsigned}} -subitemconfig {/tb_gmii/my_top/cu/data_out(156) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(155) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(154) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(153) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(152) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(151) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(150) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(149) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(148) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(147) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(146) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(145) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(144) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(143) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(142) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(141) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(140) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(139) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(138) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(137) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(136) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(135) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(134) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(133) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(132) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(131) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(130) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(129) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(128) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(127) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(126) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(125) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(124) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(123) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(122) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(121) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(120) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(119) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(118) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(117) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(116) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(115) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(114) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(113) {-height 17 -radix unsigned} /tb_gmii/my_top/cu/data_out(112) {-height 17 -radix unsigned}} /tb_gmii/my_top/cu/data_out
add wave -noupdate /tb_gmii/my_top/cu/rx_state_s
add wave -noupdate /tb_gmii/my_top/cu/int_state_s
add wave -noupdate -radix unsigned /tb_gmii/my_top/cu/err_cnt_s
add wave -noupdate -radix unsigned /tb_gmii/my_top/cu/err_drp_s
add wave -noupdate /tb_gmii/my_top/cu/next_sstim_s
add wave -noupdate /tb_gmii/my_top/cu/next_estim_s
add wave -noupdate /tb_gmii/my_top/cu/rst_exec_s
add wave -noupdate -group counter /tb_gmii/my_top/cu/cnt_rst_s
add wave -noupdate -group counter /tb_gmii/my_top/cu/cnt_s
add wave -noupdate -group counter /tb_gmii/my_top/cu/cnt_inc_s
add wave -noupdate -group counter /tb_gmii/my_top/cu/cnt_offset_s
add wave -noupdate -group counter /tb_gmii/my_top/cu/cnt_end_s
add wave -noupdate -group counter /tb_gmii/my_top/cu/cnt_rst_s
add wave -noupdate -group counter /tb_gmii/my_top/cu/cnt_s
add wave -noupdate -group counter /tb_gmii/my_top/cu/cnt_inc_s
add wave -noupdate -group counter /tb_gmii/my_top/cu/cnt_offset_s
add wave -noupdate -group counter /tb_gmii/my_top/cu/cnt_end_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_rst_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_wr_d_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_wr_vl_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_am_fu_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_fu_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_rd_d_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_rd_nxt_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_am_ep_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_ep_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_fi_lvl_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_rst_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_wr_d_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_wr_vl_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_am_fu_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_fu_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_rd_d_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_rd_nxt_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_am_ep_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_ep_s
add wave -noupdate -group {error fifo} /tb_gmii/my_top/cu/err_fifo_fi_lvl_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/clk_in
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/clk2x_in
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rst_in
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/run_in
add wave -noupdate -group verificator -radix unsigned /tb_gmii/my_top/cu/ver/stimuli_in
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/stimuli_v_in
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/error_valid_out
add wave -noupdate -group verificator -radix unsigned /tb_gmii/my_top/cu/ver/error_out
add wave -noupdate -group verificator -radix unsigned /tb_gmii/my_top/cu/ver/stimuli_out
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/max_util_out
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/idle_out
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_stim_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_dut_state_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_rev_state_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_cmp_state_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_rev_id_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_comp_id_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_rev_rd_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_dut_rd_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/next_id_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_sched_pro_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_sched_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/in_use_cnt_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/in_use_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/in_use_cnt_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_err_l_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_err_lv_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_err_stim_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_restart_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_rst_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_last_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_box1_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_box1_vl_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_box2_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_box2_vl_s
add wave -noupdate -group verificator -expand /tb_gmii/my_top/cu/ver/comp_err_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_done_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/dut_rst_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/dut_px_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/dut_box_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/dut_done_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_px_vl_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_px_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_vl_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_s_x_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_s_y_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_e_x_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_e_y_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_done_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/clk_in
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/clk2x_in
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rst_in
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/run_in
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/stimuli_in
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/stimuli_v_in
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/error_valid_out
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/error_out
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/stimuli_out
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/max_util_out
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/idle_out
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_stim_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_dut_state_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_rev_state_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_cmp_state_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_rev_id_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_comp_id_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_rev_rd_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/sched_dut_rd_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/next_id_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_sched_pro_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_sched_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/in_use_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/in_use_cnt_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_err_l_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_err_lv_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_err_stim_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_restart_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_rst_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_last_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_box1_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_box1_vl_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_box2_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_box2_vl_s
add wave -noupdate -group verificator -expand /tb_gmii/my_top/cu/ver/comp_err_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/comp_done_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/dut_rst_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/dut_px_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/dut_box_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/dut_done_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_px_vl_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_px_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_vl_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_s_x_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_s_y_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_e_x_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_e_y_out_s
add wave -noupdate -group verificator /tb_gmii/my_top/cu/ver/rev_done_out_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/rst_in
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/rx_clk_in
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/udp_rx_start_in
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/udp_rx_in
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/ip_rx_hdr_in
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/dec_valid_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/write_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/type_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/id_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/length_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/data_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/header_error_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/rx_state_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/udp_cnt_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/udp_data_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/write_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/type_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/id_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/length_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/rst_in
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/rx_clk_in
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/udp_rx_start_in
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/udp_rx_in
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/ip_rx_hdr_in
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/dec_valid_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/write_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/type_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/id_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/length_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/data_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/header_error_out
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/rx_state_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/udp_cnt_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/udp_data_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/write_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/type_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/id_s
add wave -noupdate -group udp_decoder /tb_gmii/my_top/udp_decoder/length_s
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/udp_tx_start
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/udp_txi
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/udp_tx_result
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/udp_tx_data_out_ready
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/udp_rx_start
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/udp_rxo
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_rx_hdr
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/rx_clk
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/tx_clk
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/reset
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/our_ip_address
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/our_mac_address
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/control
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/arp_pkt_count
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_pkt_count
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_tx_tdata
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_tx_tvalid
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_tx_tready
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_tx_tfirst
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_tx_tlast
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_rx_tdata
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_rx_tvalid
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_rx_tready
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_rx_tlast
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_tx_int
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_tx_start_int
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_tx_result_int
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_tx_data_out_ready_int
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_rx_int
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_rx_start_int
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/udp_tx_start
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/udp_txi
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/udp_tx_result
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/udp_tx_data_out_ready
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/udp_rx_start
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/udp_rxo
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_rx_hdr
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/rx_clk
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/tx_clk
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/reset
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/our_ip_address
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/our_mac_address
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/control
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/arp_pkt_count
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_pkt_count
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_tx_tdata
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_tx_tvalid
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_tx_tready
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_tx_tfirst
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_tx_tlast
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_rx_tdata
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_rx_tvalid
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_rx_tready
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/mac_rx_tlast
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_tx_int
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_tx_start_int
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_tx_result_int
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_tx_data_out_ready_int
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_rx_int
add wave -noupdate -group UDP_STACK /tb_gmii/my_top/udp_stack/ip_rx_start_int
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/G_SIZE
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/G_WORD_WIDTH
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/G_ALMOST_EMPTY
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/G_ALMOST_FULL
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/G_FWFT
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/rst_in
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/clk_in
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/wr_d_in
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/wr_valid_in
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/almost_full_out
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/full_out
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/rd_d_out
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/rd_next_in
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/almost_empty_out
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/empty_out
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/fill_lvl_out
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/buf_s
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/rd_cnt_s
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/wr_cnt_s
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/fill_lvl_s
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/G_SIZE
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/G_WORD_WIDTH
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/G_ALMOST_EMPTY
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/G_ALMOST_FULL
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/G_FWFT
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/rst_in
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/clk_in
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/wr_d_in
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/wr_valid_in
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/almost_full_out
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/full_out
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/rd_d_out
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/rd_next_in
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/almost_empty_out
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/empty_out
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/fill_lvl_out
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/buf_s
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/rd_cnt_s
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/wr_cnt_s
add wave -noupdate -group udp_encoder -group tx_fifo /tb_gmii/my_top/udp_encoder/tx_buf/fill_lvl_s
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/rst_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/tx_clk_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/udp_tx_start_out
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/udp_tx_out
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/udp_tx_result_out
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/udp_tx_data_rdy_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/enc_valid_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/type_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/id_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/length_in
add wave -noupdate -group udp_encoder -radix hexadecimal /tb_gmii/my_top/udp_encoder/data_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/udp_rx_header_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/tx_state_s
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/bytes_to_send_s
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/bytes_send_s
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/invalid_data_out
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/rst_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/tx_clk_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/udp_tx_start_out
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/udp_tx_out
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/udp_tx_result_out
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/udp_tx_data_rdy_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/enc_valid_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/type_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/id_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/length_in
add wave -noupdate -group udp_encoder -radix hexadecimal /tb_gmii/my_top/udp_encoder/data_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/udp_rx_header_in
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/tx_state_s
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/bytes_to_send_s
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/bytes_send_s
add wave -noupdate -group udp_encoder /tb_gmii/my_top/udp_encoder/invalid_data_out
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gtx_clk
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_mac_aclk
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_reset
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_statistics_vector
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_statistics_valid
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_fifo_clock
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_fifo_resetn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_fifo_tdata
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_fifo_tvalid
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_fifo_tready
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_fifo_tlast
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_reset
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_ifg_delay
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_statistics_vector
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_statistics_valid
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_fifo_clock
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_fifo_resetn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_fifo_tdata
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_fifo_tvalid
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_fifo_tready
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_fifo_tlast
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/pause_req
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/pause_val
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/refclk
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_txd
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_tx_en
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_tx_er
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_tx_clk
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_rxd
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_rx_dv
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_rx_er
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_rx_clk
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/glbl_rstn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axi_rstn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axi_rstn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_mac_aclk_int
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_reset_int
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_reset_int
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_mac_resetn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_mac_resetn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_mac_tdata
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_mac_tvalid
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_mac_tlast
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_mac_tuser
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_mac_tdata
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_mac_tvalid
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_mac_tready
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_mac_tlast
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_mac_tuser
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_collision
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_retransmit
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gtx_clk
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_mac_aclk
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_reset
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_statistics_vector
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_statistics_valid
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_fifo_clock
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_fifo_resetn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_fifo_tdata
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_fifo_tvalid
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_fifo_tready
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_fifo_tlast
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_reset
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_ifg_delay
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_statistics_vector
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_statistics_valid
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_fifo_clock
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_fifo_resetn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_fifo_tdata
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_fifo_tvalid
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_fifo_tready
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_fifo_tlast
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/pause_req
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/pause_val
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/refclk
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_txd
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_tx_en
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_tx_er
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_tx_clk
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_rxd
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_rx_dv
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_rx_er
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/gmii_rx_clk
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/glbl_rstn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axi_rstn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axi_rstn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_mac_aclk_int
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_reset_int
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_reset_int
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_mac_resetn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_mac_resetn
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_mac_tdata
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_mac_tvalid
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_mac_tlast
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/rx_axis_mac_tuser
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_mac_tdata
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_mac_tvalid
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_mac_tready
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_mac_tlast
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_axis_mac_tuser
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_collision
add wave -noupdate -group Xilinx_EMAC /tb_gmii/my_top/emac_fifo_block/tx_retransmit
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/clk_in
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/rst_in
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/rst_out
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/rst_out_n
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/rst_s
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/rst_cnt_s
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/rst_int_s
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/clk_in
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/rst_in
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/rst_out
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/rst_out_n
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/rst_s
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/rst_cnt_s
add wave -noupdate -group {reset modul} /tb_gmii/my_top/rst/rst_int_s
add wave -noupdate /tb_gmii/my_top/cu/restart_cnt_s
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/rst_in
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/clk_in
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/wr_d_in
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/wr_valid_in
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/almost_full_out
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/full_out
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/rd_d_out
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/rd_next_in
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/almost_empty_out
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/empty_out
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/fill_lvl_out
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/buf_s
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/rd_cnt_s
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/wr_cnt_s
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/fill_lvl_s
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/rst_in
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/clk_in
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/wr_d_in
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/wr_valid_in
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/almost_full_out
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/full_out
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/rd_d_out
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/rd_next_in
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/almost_empty_out
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/empty_out
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/fill_lvl_out
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/buf_s
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/rd_cnt_s
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/wr_cnt_s
add wave -noupdate -group comp_1 -group fifo /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fifo/fill_lvl_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/clk_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/rst_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/restart_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/last_box_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/clk1_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_valid_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box2_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box2_valid_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/error_code_out
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/check_done_out
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/state_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/state_d_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box2_ram_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box2_valid_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box2_found_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/wr_cnt_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/rd_cnt_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/rd_cnt_d_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_v_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_v_d_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_next_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_empty_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fill_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/match_done_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/restart_d_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/rst_fifo_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/clk_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/rst_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/restart_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/last_box_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/clk1_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_valid_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box2_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box2_valid_in
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/error_code_out
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/check_done_out
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/state_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/state_d_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box2_ram_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box2_valid_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box2_found_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/wr_cnt_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/rd_cnt_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/rd_cnt_d_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_v_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_v_d_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_next_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_empty_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/box1_fill_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/match_done_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/restart_d_s
add wave -noupdate -group comp_1 /tb_gmii/my_top/cu/ver/gen_comp(1)/comparator/rst_fifo_s
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/LLabel_in
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/LSetLT_in
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/RLabel_in
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/RSetLT_in
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/clk
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/gl_new
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/ready
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/pixel_valid
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/pixel_value
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/res
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/LLAbel_out
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/LsetLT_out
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/RLabel_out
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/RSetLT_out
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/finished_object
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/fo_gl
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/fo_sn
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/fo_valid
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/gl_used
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/to_mq
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/A
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/B
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/C
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/CP
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/D
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/crt_label_d1
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/crt_label_local
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/first_column
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/fo_gl_data
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/fo_gl_read
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/last_column
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/merge_entries
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/reusable_merger_label
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/reuseable_label
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/rl_valid
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/rml_valid
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/row_fhd
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/LLabel_in
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/LSetLT_in
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/RLabel_in
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/RSetLT_in
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/clk
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/gl_new
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/pixel_valid
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/pixel_value
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/res
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/LLAbel_out
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/LsetLT_out
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/RLabel_out
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/RSetLT_out
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/finished_object
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/fo_gl
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/fo_sn
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/fo_valid
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/gl_used
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/to_mq
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/A
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/B
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/C
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/CP
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/D
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/crt_label_d1
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/crt_label_local
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/first_column
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/fo_gl_data
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/fo_gl_read
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/last_column
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/merge_entries
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/reusable_merger_label
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/reuseable_label
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/rl_valid
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/rml_valid
add wave -noupdate -expand -group dut_1 /tb_gmii/my_top/cu/ver/gen_dut(1)/box_dut/row_fhd
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/clk_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/rst_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/stall_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/stall_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/data_valid_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/px_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/img_width_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/img_height_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_valid_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_start_x_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_start_y_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_end_x_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_end_y_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_done_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/error_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/stall_lbl_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/valid_lbl_out_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/last_lbl_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/label_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_rst_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_done_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/last_box_noti_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_out_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/clk_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/rst_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/stall_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/stall_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/data_valid_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/px_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/img_width_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/img_height_in
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_valid_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_start_x_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_start_y_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_end_x_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_end_y_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_done_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/error_out
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/stall_lbl_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/valid_lbl_out_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/last_lbl_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/label_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_rst_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_done_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/last_box_noti_s
add wave -noupdate -expand -group rev_1 /tb_gmii/my_top/cu/ver/gen_rev(1)/box_rev/box_out_s
add wave -noupdate /tb_gmii/my_top/cu/rst_in
add wave -noupdate /tb_gmii/my_top/cu/rx_clk_in
add wave -noupdate /tb_gmii/my_top/cu/rx_2clk_in
add wave -noupdate /tb_gmii/my_top/cu/dec_valid_in
add wave -noupdate /tb_gmii/my_top/cu/write_in
add wave -noupdate /tb_gmii/my_top/cu/type_in
add wave -noupdate /tb_gmii/my_top/cu/id_in
add wave -noupdate /tb_gmii/my_top/cu/length_in
add wave -noupdate /tb_gmii/my_top/cu/data_in
add wave -noupdate /tb_gmii/my_top/cu/header_error_in
add wave -noupdate /tb_gmii/my_top/cu/rx_state_s
add wave -noupdate /tb_gmii/my_top/cu/int_state_s
add wave -noupdate -radix unsigned /tb_gmii/my_top/cu/err_cnt_s
add wave -noupdate -radix unsigned /tb_gmii/my_top/cu/err_drp_s
add wave -noupdate /tb_gmii/my_top/cu/next_sstim_s
add wave -noupdate /tb_gmii/my_top/cu/next_estim_s
add wave -noupdate /tb_gmii/my_top/cu/rst_exec_s
add wave -noupdate /tb_gmii/my_top/cu/restart_cnt_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1121011 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 546
configure wave -valuecolwidth 159
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2766750 ps}
