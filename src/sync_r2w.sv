module sync_r2w #(
  parameter AWIDTH = 4
)(
  input                   wr_clk_i,
  input                   aclr_i,
  
  input        [AWIDTH:0] rd_pntr_gray_wr,
  input                   rd_empty_wr,
  
  output logic [AWIDTH:0] rd_pntr_gray,
  output logic            wr_empty_o
);

logic [AWIDTH:0] rd_pntr_gray_temp;

always_ff @( posedge wr_clk_i, negedge aclr_i )
  begin
    if( !aclr_i )
      begin
        rd_pntr_gray_temp <= '0;
        rd_pntr_gray      <= '0;
      end
    else
      begin
        rd_pntr_gray_temp <= rd_pntr_gray_wr;
        rd_pntr_gray      <= rd_pntr_gray_temp;
      end
  end

  
logic rd_empty_wr_temp;
always_ff @( posedge wr_clk_i, negedge aclr_i )
  begin
    if( !aclr_i )
      begin
        rd_empty_wr_temp  <= '1;
        wr_empty_o        <= '1;
      end
    else
      begin
        rd_empty_wr_temp <= rd_empty_wr;
        wr_empty_o       <= rd_empty_wr_temp;
      end
  end
  
endmodule
