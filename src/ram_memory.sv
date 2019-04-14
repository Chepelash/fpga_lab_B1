(* ramstyle = "M10K, no_rw_check" *) module ram_memory #(
  parameter DWIDTH    = 8,
  parameter AWIDTH    = 4
)(
  input                     rd_clk_i,
  input                     wr_clk_i,
  input                     wr_req_i,
  input                     wr_full,
  
  input        [DWIDTH-1:0] data_i,
  input        [AWIDTH-1:0] rd_pntr,
  input        [AWIDTH-1:0] wr_pntr,
  
  output logic [DWIDTH-1:0] q_o
);

logic [DWIDTH-1:0] mem [0:2**AWIDTH-1];

logic [AWIDTH-1:0] rd_pntr_reg;

//assign q_o = mem[rd_pntr];
always_ff @( posedge rd_clk_i )
  begin
    q_o         <= mem[rd_pntr];
//    rd_pntr_reg <= rd_pntr;
  end

always_ff @( posedge wr_clk_i )
  begin
    if( wr_req_i && ( !wr_full ) )
      mem[wr_pntr] <= data_i;
  end

endmodule
