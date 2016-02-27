#!/bin/sh


vcomopts="-2008"

vlib work

#PCCL DUT
vlib pccl_lib
vcom $vcomopts -work pccl_lib \
	ccl_dut/txt_util_pkg.vhd \
	ccl_dut/txt_util_pkg_body.vhd \
	ccl_dut/functions_pkg.vhd \
	ccl_dut/common_pkg.vhd \
	ccl_dut/sp_dt_ccontrol_entity.vhd \
	ccl_dut/SP_DT_CControl_behav.vhd \
	ccl_dut/sp_dt_input_align_entity.vhd \
	ccl_dut/SP_DT_Input_Align_behav.vhd \
	ccl_dut/sp_dt_ro_entity.vhd \
	ccl_dut/SP_DT_RO_behav.vhd \
	ccl_dut/sp_data_table_entity.vhd \
	ccl_dut/SP_Data_table_behav.vhd \
	ccl_dut/sp_data_control_unit_entity.vhd \
	ccl_dut/sp_data_control_unit_struct.vhd \
	ccl_dut/sp_ccl_control_entity.vhd \
	ccl_dut/SP_CCL_control_behav.vhd \
	ccl_dut/sc_fifo_entity.vhd \
	ccl_dut/SC_FIFO_behav.vhd \
	ccl_dut/sp_lmc_entity.vhd \
	ccl_dut/SP_LMC_behav.vhd \
	ccl_dut/sp_lm_debug_entity.vhd \
	ccl_dut/SP_LM_debug_behav.vhd \
	ccl_dut/sp_label_management_entity.vhd \
	ccl_dut/sp_label_management_struct.vhd \
	ccl_dut/sp_label_selection_entity.vhd \
	ccl_dut/SP_Label_Selection_behav.vhd \
	ccl_dut/sp_link_table_entity.vhd \
	ccl_dut/SP_Link_table_behav.vhd \
	ccl_dut/sp_merger_table_entity.vhd \
	ccl_dut/SP_Merger_table_behav.vhd \
	ccl_dut/sp_nh_comm_entity.vhd \
	ccl_dut/SP_NH_Comm_behav.vhd \
	ccl_dut/sp_neighborhood_entity.vhd \
	ccl_dut/SP_Neighborhood_behav.vhd \
	ccl_dut/sp_row_buffer_entity.vhd \
	ccl_dut/SP_Row_Buffer_behav.vhd \
	ccl_dut/sp_stack_entity.vhd \
	ccl_dut/SP_Stack_behav.vhd \
	ccl_dut/sp_labeling_unit_entity.vhd \
	ccl_dut/sp_labeling_unit_struct.vhd \
	ccl_dut/ccl_slice_entity.vhd \
	ccl_dut/ccl_slice_struct.vhd \
	ccl_dut/ccl_array_connections_entity.vhd \
	ccl_dut/CCl_Array_Connections_behav.vhd \
	ccl_dut/ccl_array_entity.vhd \
	ccl_dut/ccl_array_struct.vhd \
	ccl_dut/error_notififier_entity.vhd \
	ccl_dut/Error_Notififier_behav.vhd \
	ccl_dut/image_distribution_mux_entity.vhd \
	ccl_dut/image_distribution_mux_behav.vhd \
	ccl_dut/slice_buffer_entity.vhd \
	ccl_dut/Slice_Buffer_behav.vhd \
	ccl_dut/image_distribution_entity.vhd \
	ccl_dut/image_distribution_struct.vhd \
	ccl_dut/output_arbiter_entity.vhd \
	ccl_dut/Output_arbiter_behav.vhd \
	ccl_dut/sb_dc_fifo_behav.vhd \
	ccl_dut/dp_ram_entity.vhd \
	ccl_dut/DP_RAM_behav.vhd \
	ccl_dut/cu_fsm_entity.vhd \
	ccl_dut/cu_fsm_fsm.vhd \
	ccl_dut/cuv2_fsm2_entity.vhd \
	ccl_dut/CUv2_FSM2_behav.vhd \
	ccl_dut/cu_control_entity.vhd \
	ccl_dut/cu_control_struct.vhd \
	ccl_dut/fo_arbiter_entity.vhd \
	ccl_dut/FO_Arbiter_behav.vhd \
	ccl_dut/fo_deli_gen_entity.vhd \
	ccl_dut/FO_deli_gen_behav.vhd \
	ccl_dut/fo_queue_entity.vhd \
	ccl_dut/fo_queue_struct.vhd \
	ccl_dut/glm_label_distr_entity.vhd \
	ccl_dut/GLM_LABEL_DISTR_behav.vhd \
	ccl_dut/glm_debug_entity.vhd \
	ccl_dut/GLM_debug_behav.vhd \
	ccl_dut/glm_slice_assign_entity.vhd \
	ccl_dut/GLM_slice_assign_behav.vhd \
	ccl_dut/glm_entity.vhd \
	ccl_dut/glm_struct.vhd \
	ccl_dut/gmt_entity.vhd \
	ccl_dut/GMT_behav.vhd \
	ccl_dut/mq_arbiter_entity.vhd \
	ccl_dut/MQ_Arbiter_behav.vhd \
	ccl_dut/mq_deli_gen_entity.vhd \
	ccl_dut/MQ_deli_gen_behav.vhd \
	ccl_dut/merger_queue_entity.vhd \
	ccl_dut/merger_queue_struct.vhd \
	ccl_dut/fo_debug_entity.vhd \
	ccl_dut/fo_debug_fo_debug.vhd \
	ccl_dut/mq_debug_entity.vhd \
	ccl_dut/mq_debug_behav.vhd \
	ccl_dut/gdt_struct.vhd \
	ccl_dut/gdt_entity.vhd \
	ccl_dut/coalescing_unit_entity.vhd \
	ccl_dut/coalescing_unit_struct.vhd \
	ccl_dut/pccl_top_entity.vhd \
	ccl_dut/pccl_top_struct.vhd


#emac of xilinx
vcom $vcomopts ise/udp_high_tech/ipcore_dir/v6_emac_v2_2.vhd
vcom -work work \
  ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/common/reset_sync.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/common/sync_block.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/physical/gmii_if.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/fifo/tx_client_fifo_8.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/fifo/rx_client_fifo_8.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/fifo/ten_100_1g_eth_fifo.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/pat_gen/address_swap.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/pat_gen/axi_mux.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/pat_gen/axi_pat_gen.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/pat_gen/axi_pat_check.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/pat_gen/axi_pipe.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/pat_gen/basic_pat_gen.vhd
vcom -work work \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/clk_wiz.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/v6_emac_v2_2_block.vhd \
	ise/udp_high_tech/ipcore_dir/v6_emac_v2_2/example_design/v6_emac_v2_2_fifo_block.vhd



#UDP Stack
udp_src_dir="communication/udp_ip_stack/trunk/rtl/vhdl"
vcom $vcomopts \
	$udp_src_dir/axi.vhd \
	$udp_src_dir/arp_types.vhd \
	$udp_src_dir/ipv4_types.vhd \
	$udp_src_dir/UDP_RX.vhd \
	$udp_src_dir/UDP_TX.vhd \
	$udp_src_dir/UDP_Complete_nomac.vhd \
	$udp_src_dir/arp_REQ.vhd \
	$udp_src_dir/arp_SYNC.vhd \
	$udp_src_dir/arp_TX.vhd \
	$udp_src_dir/arp_RX.vhd \
	$udp_src_dir/arp_STORE_br.vhd \
	$udp_src_dir/tx_arbitrator.vhd \
	$udp_src_dir/arp.vhd \
	$udp_src_dir/arpv2.vhd \
	$udp_src_dir/IP_complete_nomac.vhd \
	$udp_src_dir/ipv4_types.vhd \
	$udp_src_dir/IPv4_RX.vhd \
	$udp_src_dir/IPv4_TX.vhd \
	$udp_src_dir/IPv4.vhd

	#communication/uart2bus/trunk/vhdl/rtl/uartRx.vhd
#communication/uart2bus/trunk/vhdl/rtl/uartTx.vhd
#communication/uart2bus/trunk/vhdl/rtl/baudGen.vhd
#communication/uart2bus/trunk/vhdl/rtl/uart2BusTop_pkg.vhd
#communication/uart2bus/trunk/vhdl/rtl/uart2BusTop.vhd
#communication/uart2bus/trunk/vhdl/rtl/uartTop.vhd
#communication/com_uart.vhd
#communication/top_com_uart.vhd
#communication/tb_com_uart.vhd


vcom $vcomopts \
	utils.vhd \
	types.vhd \
	reset.vhd \
	fifo.vhd \
	ise/udp_high_tech/ipcore_dir/clk_udp.vhd \
	px_storage.vhd \
	labeling_p1.vhd \
	sim_package.vhd \
	lookup_table.vhd \
	tb_labeling_p1.vhd \
	counter.vhd \
	labeling_non_pipline.vhd \
	tb_labeling.vhd \
	boundbox_big.vhd \
	labeling_box_non_pipline.vhd \
	tb_labeling_box.vhd \
	tb_labeling_cont.vhd \
	tb_labeling_box_cont.vhd \
	comparator.vhd \
	box_counter.vhd \
	verificator.vhd \
	stimgen.vhd \
	tb_stimgen.vhd \
	tb_comparator.vhd \
	udp_decoder.vhd \
	udp_encoder.vhd \
	control_unit.vhd \
	tb_xilinx_mac.vhd \
	fifo_asym.vhd \
	ise/udp_high_tech/ipcore_dir/in_fifo.vhd \
	ise/udp_high_tech/ipcore_dir/out_fifo.vhd \
	camif.vhd \
	box_out_storage.vhd \
	cam_control_unit.vhd \
	top_udp.vhd \
	tb_camif.vhd \
	tb_gmii.vhd

vmake work > makefile
