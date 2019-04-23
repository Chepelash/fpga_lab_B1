module sync #(
  parameter AWIDTH = 3
)(
  input                   clk_i,
  input                   aclr_i,
  
  input        [AWIDTH:0] pntr_gray_i,
  input                   flag_i,
  input                   resetval_i,
  
  output logic [AWIDTH:0] pntr_gray_o,
  output logic            flag_o
);

localparam AWVAL = AWIDTH + 1;

logic [AWVAL-1:0] pntr_gray_temp;

always_ff @( posedge clk_i, posedge aclr_i )
  begin
    if( aclr_i )
      begin
        pntr_gray_temp <= '0;
        pntr_gray_o    <= '0;
      end
    else
      begin
        pntr_gray_temp <= pntr_gray_i;
        pntr_gray_o    <= pntr_gray_temp;
      end
  end
  
logic flag_temp;
always_ff @( posedge clk_i, posedge aclr_i )
  begin
    if( aclr_i )
      begin
        flag_temp <= resetval_i;
        flag_o    <= resetval_i;
      end
    else
      begin
        flag_temp <= flag_i;
        flag_o    <= flag_temp;
      end
  end
//assign flag_o = flag_i;

endmodule
