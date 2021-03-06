module rd_pntrs_and_empty #(
  parameter DWIDTH = 8,
  parameter AWIDTH = 3
)(
  input                     rd_clk_i,
  input                     aclr_i,
  input                     rd_req_i,
  
  input        [AWIDTH:0]   wr_pntr_gray_i,
  
  output logic [AWIDTH-1:0] rd_pntr_o,
  output logic [AWIDTH:0]   rd_pntr_gray_wr_o,
  output logic              rd_empty_o,
  output logic [AWIDTH-1:0] rd_usedw_o
);

localparam MAXWORDS = 2**AWIDTH - 1;
localparam AWVAL    = AWIDTH + 1;

logic [AWVAL-1:0]  rd_pntr_bin;     
logic [AWVAL-1:0]  rd_pntr_bin_next;
logic [AWVAL-1:0]  rd_pntr_gray_next; // next read pointer in gray code
logic              rd_empty;
logic [AWVAL-1:0]  wr_pntr_bin;
logic [AWIDTH-1:0] wr_pntr_bin_t;

bg_transf #(
  .AWIDTH      ( AWIDTH            )
) bg_transf_rd (
  .pntr_gray_i ( wr_pntr_gray_i    ),
  .pntr_bin_i  ( rd_pntr_bin_next  ),
  
  .pntr_bin_o  ( wr_pntr_bin       ),
  .pntr_gray_o ( rd_pntr_gray_next )
);

assign rd_pntr_o = rd_pntr_bin[AWIDTH-1:0];

always_ff @( posedge rd_clk_i, posedge aclr_i )
  begin
    if( aclr_i )
      begin
        rd_pntr_bin       <= '0;
        rd_pntr_gray_wr_o <= '0;
      end
    else
      begin
        rd_pntr_bin       <= rd_pntr_bin_next;
        rd_pntr_gray_wr_o <= rd_pntr_gray_next;
      end
  end


assign rd_pntr_bin_next = ( rd_req_i & ~rd_empty_o ) ? ( rd_pntr_bin + 1'b1 ) : ( rd_pntr_bin );

assign rd_empty = ( rd_pntr_gray_next == wr_pntr_gray_i );

always_ff @( posedge rd_clk_i, posedge aclr_i )
  begin
    if( aclr_i )
      rd_empty_o <= '1;
    else
      rd_empty_o <= rd_empty;
  end
  
assign wr_pntr_bin_t = wr_pntr_bin[AWIDTH-1:0];

always_comb
  begin
    if( wr_pntr_bin_t >= rd_pntr_o )
      rd_usedw_o = wr_pntr_bin_t - rd_pntr_o;
    else
      rd_usedw_o = MAXWORDS[AWIDTH-1:0] - rd_pntr_o + wr_pntr_bin_t + 1'b1;
  end
endmodule
