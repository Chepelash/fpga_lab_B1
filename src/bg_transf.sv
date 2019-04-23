module bg_transf #(
  parameter AWIDTH = 4
)(
  input        [AWVAL-1:0] pntr_gray_i,
  input        [AWVAL-1:0] pntr_bin_i,
  
  output logic [AWVAL-1:0] pntr_bin_o,
  output logic [AWVAL-1:0] pntr_gray_o
);

localparam AWVAL = AWIDTH + 1;

assign pntr_gray_o = pntr_bin_i ^ ( pntr_bin_i >> 1 );

always_comb
  begin
    pntr_bin_o = '0;
    for( logic [AWVAL-1:0] cntr = 0; cntr < AWIDTH; cntr++ )
      pntr_bin_o[cntr] = ^( pntr_gray_i >> cntr );
  end

endmodule
