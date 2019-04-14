module sync_w2r #(
  parameter AWIDTH = 4
)(
  input                   rd_clk_i,
  input                   aclr_i,
  
  input        [AWIDTH:0] wr_pntr_gray_rd,
  input                   wr_full_rd,
  
  output logic [AWIDTH:0] wr_pntr_gray,
  output logic            rd_full_o
);

logic [AWIDTH:0] wr_pntr_gray_temp;

always_ff @( posedge rd_clk_i, negedge aclr_i )
  begin
    if( !aclr_i )
      begin
        wr_pntr_gray_temp <= '0;
        wr_pntr_gray      <= '0;
      end
    else
      begin
        wr_pntr_gray_temp <= wr_pntr_gray_rd;
        wr_pntr_gray      <= wr_pntr_gray_temp;
      end
  end

  
logic wr_full_rd_temp;
always_ff @( posedge rd_clk_i, negedge aclr_i )
  begin
    if( !aclr_i )
      begin
        wr_full_rd_temp  <= '0;
        rd_full_o        <= '0;
      end
    else
      begin
        wr_full_rd_temp <= wr_full_rd;
        rd_full_o       <= wr_full_rd_temp;
      end
  end
endmodule
