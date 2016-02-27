onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_stimgen/my_stimgen/clk_in
add wave -noupdate /tb_stimgen/my_stimgen/clk2x_in
add wave -noupdate /tb_stimgen/my_stimgen/rst_in
add wave -noupdate /tb_stimgen/my_stimgen/error_valid_out
add wave -noupdate /tb_stimgen/my_stimgen/error_out
add wave -noupdate /tb_stimgen/my_stimgen/stimuli_out
add wave -noupdate /tb_stimgen/my_stimgen/processed_out
add wave -noupdate /tb_stimgen/my_stimgen/check_done_out
add wave -noupdate /tb_stimgen/my_stimgen/sched_stim_s
add wave -noupdate -expand /tb_stimgen/my_stimgen/sched_dut_state_s
add wave -noupdate -expand /tb_stimgen/my_stimgen/sched_rev_state_s
add wave -noupdate -expand /tb_stimgen/my_stimgen/sched_cmp_state_s
add wave -noupdate /tb_stimgen/my_stimgen/sched_dut_id_s
add wave -noupdate /tb_stimgen/my_stimgen/sched_rev_id_s
add wave -noupdate /tb_stimgen/my_stimgen/sched_comp_id_s
add wave -noupdate /tb_stimgen/my_stimgen/sched_error_s
add wave -noupdate /tb_stimgen/my_stimgen/sched_rev_rd_s
add wave -noupdate /tb_stimgen/my_stimgen/sched_dut_rd_s
add wave -noupdate /tb_stimgen/my_stimgen/sched_err_done_s
add wave -noupdate /tb_stimgen/my_stimgen/sched_chk_s
add wave -noupdate /tb_stimgen/my_stimgen/sched_err_chk_s
add wave -noupdate -expand /tb_stimgen/my_stimgen/rev_sched_in_s
add wave -noupdate -expand /tb_stimgen/my_stimgen/rev_sched_pro_s
add wave -noupdate -expand /tb_stimgen/my_stimgen/rev_sched_out_s
add wave -noupdate /tb_stimgen/my_stimgen/rev_next_id_s
add wave -noupdate /tb_stimgen/my_stimgen/comp_in_use_s
add wave -noupdate /tb_stimgen/my_stimgen/comp_rst_s
add wave -noupdate /tb_stimgen/my_stimgen/comp_last_s
add wave -noupdate /tb_stimgen/my_stimgen/comp_box1_s
add wave -noupdate /tb_stimgen/my_stimgen/comp_box1_vl_s
add wave -noupdate /tb_stimgen/my_stimgen/comp_box2_s
add wave -noupdate /tb_stimgen/my_stimgen/comp_box2_vl_s
add wave -noupdate /tb_stimgen/my_stimgen/comp_err_s
add wave -noupdate /tb_stimgen/my_stimgen/comp_done_s
add wave -noupdate /tb_stimgen/my_stimgen/dut_in_use_s
add wave -noupdate /tb_stimgen/my_stimgen/dut_rst_s
add wave -noupdate /tb_stimgen/my_stimgen/dut_px_s
add wave -noupdate /tb_stimgen/my_stimgen/dut_rd_s
add wave -noupdate /tb_stimgen/my_stimgen/dut_box_s
add wave -noupdate /tb_stimgen/my_stimgen/dut_done_s
add wave -noupdate /tb_stimgen/my_stimgen/rev_px_vl_s
add wave -noupdate /tb_stimgen/my_stimgen/rev_px_s
add wave -noupdate /tb_stimgen/my_stimgen/rev_vl_out_s
add wave -noupdate /tb_stimgen/my_stimgen/rev_s_x_out_s
add wave -noupdate /tb_stimgen/my_stimgen/rev_s_y_out_s
add wave -noupdate /tb_stimgen/my_stimgen/rev_e_x_out_s
add wave -noupdate /tb_stimgen/my_stimgen/rev_e_y_out_s
add wave -noupdate /tb_stimgen/my_stimgen/rev_done_out_s
add wave -noupdate /tb_stimgen/my_stimgen/cnt_inc_s
add wave -noupdate /tb_stimgen/my_stimgen/cnt_s
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/clk_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/rst_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/stall_out
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/stall_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/data_valid_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/px_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/img_width_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/img_height_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/box_valid_out
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/box_start_x_out
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/box_start_y_out
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/box_end_x_out
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/box_end_y_out
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/box_done_out
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/error_out
add wave -noupdate /tb_stimgen/my_stimgen/gen_rev(4)/box_rev/pipe_state
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/clk
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/clk2x
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/reset
add wave -noupdate -expand /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/pixel_stream
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/read_fifo
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/obj_data
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/read_from_fifo_signal
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/swap_tables
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/A
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/B
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/C
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/D
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/crt_pixel
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/cp
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/crt_merger_type
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/image_pixel
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/RO_data
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/image_complete
add wave -noupdate /tb_stimgen/my_stimgen/gen_dut(8)/box_dut/finish_row_signal
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/clk_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/rst_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/last_box_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/clk1_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/box1_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/box1_valid_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/box2_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/box2_valid_in
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/error_code_out
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/check_done_out
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/state_s
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/state_d_s
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/box2_ram_s
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/box2_valid_s
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/box2_found_s
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/wr_cnt_s
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/rd_cnt_s
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/box1_s
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/box1_next_s
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/box1_empty_s
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/box1_fill_s
add wave -noupdate /tb_stimgen/my_stimgen/gen_comp(9)/comparator/rst_d_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {254 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 472
configure wave -valuecolwidth 100
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {469 ns}
