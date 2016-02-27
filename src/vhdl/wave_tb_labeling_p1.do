onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_labeling_p1/dut_labeling_p1/clk_in
add wave -noupdate /tb_labeling_p1/dut_labeling_p1/rst_in
add wave -noupdate /tb_labeling_p1/dut_labeling_p1/stall_out
add wave -noupdate /tb_labeling_p1/dut_labeling_p1/px_in
add wave -noupdate -radix unsigned /tb_labeling_p1/dut_labeling_p1/label_out
add wave -noupdate -radix unsigned /tb_labeling_p1/dut_labeling_p1/merge_table
add wave -noupdate -radix unsigned /tb_labeling_p1/dut_labeling_p1/merge_cnt
add wave -noupdate -radix unsigned /tb_labeling_p1/dut_labeling_p1/chain_stack
add wave -noupdate /tb_labeling_p1/dut_labeling_p1/chain_p
add wave -noupdate -radix unsigned -childformat {{/tb_labeling_p1/dut_labeling_p1/row_buffer(0) -radix unsigned} {/tb_labeling_p1/dut_labeling_p1/row_buffer(1) -radix unsigned} {/tb_labeling_p1/dut_labeling_p1/row_buffer(2) -radix unsigned} {/tb_labeling_p1/dut_labeling_p1/row_buffer(3) -radix unsigned} {/tb_labeling_p1/dut_labeling_p1/row_buffer(4) -radix unsigned}} -subitemconfig {/tb_labeling_p1/dut_labeling_p1/row_buffer(0) {-radix unsigned} /tb_labeling_p1/dut_labeling_p1/row_buffer(1) {-radix unsigned} /tb_labeling_p1/dut_labeling_p1/row_buffer(2) {-radix unsigned} /tb_labeling_p1/dut_labeling_p1/row_buffer(3) {-radix unsigned} /tb_labeling_p1/dut_labeling_p1/row_buffer(4) {-radix unsigned}} /tb_labeling_p1/dut_labeling_p1/row_buffer
add wave -noupdate -radix unsigned /tb_labeling_p1/dut_labeling_p1/d
add wave -noupdate -radix unsigned /tb_labeling_p1/dut_labeling_p1/c
add wave -noupdate -radix unsigned /tb_labeling_p1/dut_labeling_p1/b
add wave -noupdate -radix unsigned /tb_labeling_p1/dut_labeling_p1/a
add wave -noupdate -radix unsigned /tb_labeling_p1/dut_labeling_p1/c_buf
add wave -noupdate -radix decimal /tb_labeling_p1/dut_labeling_p1/label_cnt
add wave -noupdate -radix unsigned /tb_labeling_p1/dut_labeling_p1/col_cnt
add wave -noupdate -radix unsigned /tb_labeling_p1/dut_labeling_p1/row_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {266586 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 383
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
WaveRestoreZoom {23800 ps} {419800 ps}
