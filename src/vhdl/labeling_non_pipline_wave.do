onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_labeling/dut_labeling/clk_in
add wave -noupdate /tb_labeling/dut_labeling/rst_in
add wave -noupdate /tb_labeling/dut_labeling/stall_out
add wave -noupdate /tb_labeling/dut_labeling/stall_in
add wave -noupdate /tb_labeling/dut_labeling/px_in
add wave -noupdate /tb_labeling/dut_labeling/img_width_in
add wave -noupdate /tb_labeling/dut_labeling/img_height_in
add wave -noupdate /tb_labeling/dut_labeling/data_valid_out
add wave -noupdate /tb_labeling/dut_labeling/data_valid_in
add wave -noupdate /tb_labeling/dut_labeling/last_lbl_out
add wave -noupdate /tb_labeling/dut_labeling/label_out
add wave -noupdate /tb_labeling/dut_labeling/lu_next_lbl_out_s
add wave -noupdate /tb_labeling/dut_labeling/lu_gen_lable_in_s
add wave -noupdate /tb_labeling/dut_labeling/lu_ready_out_s
add wave -noupdate /tb_labeling/dut_labeling/lu_lbl_out_s
add wave -noupdate /tb_labeling/dut_labeling/lu_last_s
add wave -noupdate /tb_labeling/dut_labeling/st_px_valid_in_s
add wave -noupdate /tb_labeling/dut_labeling/st_rd_px_in_s
add wave -noupdate /tb_labeling/dut_labeling/st_rd_px_out_s
add wave -noupdate /tb_labeling/dut_labeling/st_rd_valid_out_s
add wave -noupdate /tb_labeling/dut_labeling/st_rd_last_out_s
add wave -noupdate /tb_labeling/dut_labeling/st_rd_slast_out_s
add wave -noupdate /tb_labeling/dut_labeling/rst_lbl_cnt_s
add wave -noupdate /tb_labeling/dut_labeling/stall_out_s
add wave -noupdate /tb_labeling/dut_labeling/last_lbl_s
add wave -noupdate /tb_labeling/dut_labeling/slast_lbl_s
add wave -noupdate /tb_labeling/dut_labeling/cnt_lbl2_s
add wave -noupdate /tb_labeling/dut_labeling/inc_lbl2_s
add wave -noupdate /tb_labeling/dut_labeling/next_gen_in_s
add wave -noupdate /tb_labeling/dut_labeling/gen_lable_out_s
add wave -noupdate /tb_labeling/dut_labeling/equi_out_s
add wave -noupdate /tb_labeling/dut_labeling/equi_valid_out_s
add wave -noupdate /tb_labeling/dut_labeling/p2_lbl_s
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/clk_in
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/rst_in
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/stall_out
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/stall_in
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/px_in
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/px_valid_in
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/img_width_in
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/img_height_in
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/last_lbl_out
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/slast_lbl_out
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/next_lable_in
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/gen_lable_out
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/equi_out
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/equi_valid_out
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/label_out
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/row_buffer
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/d
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/c
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/b
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/a
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/c_buf
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/label_out_s
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/col_cnt
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/row_cnt
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/buf_wr_adr_s
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/buf_rd_adr_s
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/buf_read_s
add wave -noupdate -group labeling /tb_labeling/dut_labeling/labeling/last_lbl_s
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/clk_in
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/rst_in
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/stall_out
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/next_lable_out
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/gen_lable_in
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/equi_in
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/equi_valid_in
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/lookup_ready_out
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/lookup_in
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/lookup_out
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/last_look_up_in
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/chk_state_s
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/chk_ptr_s
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/equi_table_s
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/lbl_cnt_s
add wave -noupdate -expand -group lookup /tb_labeling/dut_labeling/lookup_table/rerun_s
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/clk_in
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/rst_in
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/img_width_in
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/img_height_in
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/wr_px_in
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/wr_valid_in
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/rd_px_in
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/rd_px_out
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/rd_valid_out
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/rd_last_px_out
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/rd_slast_px_out
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/img_buffer
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/img_wptr
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/img_rptr
add wave -noupdate -expand -group px_store /tb_labeling/dut_labeling/px_store/last_px_s
add wave -noupdate -expand -group lbl_cnt2 /tb_labeling/dut_labeling/lbl_cnt_p2/clk_in
add wave -noupdate -expand -group lbl_cnt2 /tb_labeling/dut_labeling/lbl_cnt_p2/rst_in
add wave -noupdate -expand -group lbl_cnt2 /tb_labeling/dut_labeling/lbl_cnt_p2/inc_in
add wave -noupdate -expand -group lbl_cnt2 /tb_labeling/dut_labeling/lbl_cnt_p2/cnt_out
add wave -noupdate -expand -group lbl_cnt2 /tb_labeling/dut_labeling/lbl_cnt_p2/cnt_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2000000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 393
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
configure wave -timelineunits ps
update
WaveRestoreZoom {1275 ns} {3375 ns}
