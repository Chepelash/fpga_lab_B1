derive_clock_uncertainty

create_clock -period 10 -name {wr_clk_i} [get_ports {wr_clk_i}]
create_clock -period 15 -name {rd_clk_i} [get_ports {rd_clk_i}]

set_false_path -from [get_registers {*dc_fifo_1*wr_pntr_full*wr_pntr_gray_rd_o[*]}] -to [get_registers {*dc_fifo_1*sync_w2r*pntr_gray_temp[*]}]
set_false_path -from [get_registers {*dc_fifo_1*rd_pntr_empty*rd_pntr_gray_wr_o[*]}] -to [get_registers {*dc_fifo_1*sync_r2w*pntr_gray_temp[*]}]
