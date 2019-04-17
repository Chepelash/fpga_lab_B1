derive_clock_uncertainty

create_clock -period 10 -name {wr_clk_i} [get_ports {wr_clk_i}]
create_clock -period 15 -name {rd_clk_i} [get_ports {rd_clk_i}]

