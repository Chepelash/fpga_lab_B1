module sync_w2r #(
  parameter AWIDTH = 3
)(
  input                   rd_clk_i,
  input                   aclr_i,
  
  input        [AWIDTH:0] wr_pntr_gray_rd_i,
  input                   wr_full_rd_i,
  
  output logic [AWIDTH:0] wr_pntr_gray_o,
  output logic            rd_full_o
);

logic [AWIDTH:0] wr_pntr_gray_temp;

always_ff @( posedge rd_clk_i, negedge aclr_i )
  begin
    if( !aclr_i )
      begin
        wr_pntr_gray_temp <= '0;
        wr_pntr_gray_o    <= '0;
      end
    else
      begin
        wr_pntr_gray_temp <= wr_pntr_gray_rd_i;
        wr_pntr_gray_o    <= wr_pntr_gray_temp;
      end
  end

  
logic wr_full_rd_temp;
always_ff @( posedge rd_clk_i, negedge aclr_i )
  begin
    if( !aclr_i )
      begin
        wr_full_rd_temp <= '0;
        rd_full_o       <= '0;
      end
    else
      begin
        wr_full_rd_temp <= wr_full_rd_i;
        rd_full_o       <= wr_full_rd_temp;
      end
  end
endmodule
