restart
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /camif/G_IMG_WIDTH
add wave -noupdate /camif/G_IMG_HEIGHT
add wave -noupdate /camif/G_NO_PX
add wave -noupdate /camif/G_IN_WIDTH
add wave -noupdate /camif/G_FIFO_SIZE
add wave -noupdate /camif/clk_in
add wave -noupdate /camif/rst_in
add wave -noupdate /camif/min_fll_lvl_in
add wave -noupdate /camif/data_in
add wave -noupdate /camif/data_vl_in
add wave -noupdate /camif/data_out
add wave -noupdate /camif/data_rdy_in
add wave -noupdate /camif/data_vl_out
add wave -noupdate /camif/error_out
add wave -noupdate /camif/done_out
add wave -noupdate /camif/dut_fo_rdy_s
add wave -noupdate /camif/dut_px_active_s
add wave -noupdate /camif/dut_px_s
add wave -noupdate /camif/dut_vsync_s
add wave -noupdate /camif/dut_hsync_s
add wave -noupdate /camif/dut_error_s
add wave -noupdate /camif/dut_out_s
add wave -noupdate /camif/dut_out_vl_s
add wave -noupdate /camif/fifo_rst_s
add wave -noupdate /camif/fifo_in_s
add wave -noupdate /camif/fifo_in_vl_s
add wave -noupdate /camif/fifo_rd_s
add wave -noupdate /camif/fifo_rd_nxt_s
add wave -noupdate -radix unsigned /camif/fifo_lvl_s
add wave -noupdate /camif/row_cnt_s
add wave -noupdate /camif/col_cnt_s
add wave -noupdate /camif/int_err_s
add wave -noupdate /camif/state_s
add wave -noupdate -radix decimal /camif/vl_pixel_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {174494057 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 332
configure wave -valuecolwidth 203
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
force -freeze sim:/camif/min_fll_lvl_in 16'h0010 0
force -freeze sim:/camif/clk_in 1 0, 0 {5000 ps} -r {10 ns}
force -freeze sim:/camif/rst_in 0 0
run 100ns
force -freeze sim:/camif/dut_fo_rdy_s 1 0
force -freeze sim:/camif/rst_in 1 0
run 100ns
force -freeze sim:/camif/rst_in 0 0
run 100ns
force -freeze sim:/camif/data_in 1040'h00405555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555 0
force -freeze sim:/camif/data_vl_in 1 0
run 1us
force -freeze sim:/camif/data_vl_in 0 0
run 20us
force -freeze sim:/camif/data_in 1040'h00405555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555 0
force -freeze sim:/camif/data_vl_in 1 0
run 2us
force -freeze sim:/camif/data_vl_in 0 0
run 20us
force -freeze sim:/camif/data_in 1040'h00405555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555 0
force -freeze sim:/camif/data_vl_in 1 0
run 2us
force -freeze sim:/camif/data_vl_in 0 0
run 20us
force -freeze sim:/camif/data_in 1040'h00405555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555 0
force -freeze sim:/camif/data_vl_in 1 0
run 2us
force -freeze sim:/camif/data_vl_in 0 0
run 20us
force -freeze sim:/camif/data_in 1040'h00405555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555 0
force -freeze sim:/camif/data_vl_in 1 0
run 2us
force -freeze sim:/camif/data_vl_in 0 0
run 20us
force -freeze sim:/camif/data_in 1040'h00405555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555 0
force -freeze sim:/camif/data_vl_in 1 0
run 2us
force -freeze sim:/camif/data_vl_in 0 0
run 20us
force -freeze sim:/camif/data_in 1040'h00405555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555 0
force -freeze sim:/camif/data_vl_in 1 0
run 2us
force -freeze sim:/camif/data_vl_in 0 0
run 20us
force -freeze sim:/camif/data_in 1040'h00405555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555 0
force -freeze sim:/camif/data_vl_in 1 0
run 2us
force -freeze sim:/camif/data_vl_in 0 0
run 20us
force -freeze sim:/camif/data_in 1040'h00405555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555 0
force -freeze sim:/camif/data_vl_in 1 0
run 2us
force -freeze sim:/camif/data_vl_in 0 0
run 20us
WaveRestoreZoom {0 ps} {207165 ns}


