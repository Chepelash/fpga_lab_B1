transcript on


vlib work

vlog -sv ../src/dc_fifo.sv
vlog -sv ../src/ram_memory.sv
vlog -sv ../src/rd_pntrs_and_empty.sv
vlog -sv ../src/wr_pntrs_and_full.sv
vlog -sv ../src/sync_r2w.sv
vlog -sv ../src/sync_w2r.sv
vlog -sv ./dc_fifo_tb.sv

vsim -novopt dc_fifo_tb 

add wave /dc_fifo_tb/aclr

add wave /dc_fifo_tb/wr_clk
add wave /dc_fifo_tb/wr_req_i
add wave /dc_fifo_tb/data_i
add wave /dc_fifo_tb/wr_full_o
add wave /dc_fifo_tb/wr_empty_o
add wave /dc_fifo_tb/wr_usedw_o

add wave /dc_fifo_tb/rd_clk
add wave /dc_fifo_tb/rd_req_i
add wave /dc_fifo_tb/q_o
add wave /dc_fifo_tb/rd_full_o
add wave /dc_fifo_tb/rd_empty_o
add wave /dc_fifo_tb/rd_usedw_o

run -all

