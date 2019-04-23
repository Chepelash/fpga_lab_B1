module wr_pntrs_and_full #(
  parameter DWIDTH = 8,
  parameter AWIDTH = 4
)(
  input                     wr_clk_i,
  input                     aclr_i,
  input                     wr_req_i,
  
  input        [AWIDTH:0]   rd_pntr_gray_i,
  
  output logic [AWIDTH-1:0] wr_pntr_o,
  output logic [AWIDTH:0]   wr_pntr_gray_rd_o,
  output logic              wr_full_o,
  output logic [AWIDTH-1:0] wr_usedw_o
);

localparam MAXWORDS = 2**AWIDTH - 1;
localparam AWVAL = AWIDTH + 1;

logic [AWVAL-1:0]  wr_pntr_bin;     
logic [AWVAL-1:0]  wr_pntr_bin_next;
logic [AWVAL-1:0]  wr_pntr_gray_next;
logic              wr_full;
logic [AWVAL-1:0]  rd_pntr_bin;
logic [AWIDTH-1:0] rd_pntr_bin_t;

//bg_transf #(
//  .AWIDTH      ( AWIDTH            )
//) bg_transf_wr (
//  .pntr_gray_i ( rd_pntr_gray_i    ),
//  .pntr_bin_i  ( wr_pntr_bin_next  ),
//  
//  .pntr_bin_o  ( rd_pntr_bin       ),
//  .pntr_gray_o ( wr_pntr_gray_next )
//);
assign wr_pntr_gray_next = wr_pntr_bin_next ^ ( wr_pntr_bin_next >> 1 );

always_comb
  begin
    rd_pntr_bin = '0;
    for( logic [AWVAL-1:0] cntr = 0; cntr < AWIDTH; cntr++ )
      rd_pntr_bin[cntr] = ^( rd_pntr_gray_i >> cntr );
  end




assign wr_pntr_o = wr_pntr_bin[AWIDTH-1:0];

always_ff @( posedge wr_clk_i, posedge aclr_i )
  begin
    if( aclr_i )
      begin
        wr_pntr_bin       <= '0;
        wr_pntr_gray_rd_o <= '0;
      end
    else
      begin
        wr_pntr_bin       <= wr_pntr_bin_next;
        wr_pntr_gray_rd_o <= wr_pntr_gray_next;
      end
  end

assign wr_pntr_bin_next  = wr_pntr_bin + ( wr_req_i & ~wr_full_o );


assign wr_full = ( wr_pntr_gray_next == {~rd_pntr_gray_i[AWIDTH:AWIDTH-1],
                                          rd_pntr_gray_i[AWIDTH-2:0]} );


always_ff @( posedge wr_clk_i, posedge aclr_i )
  begin
    if( aclr_i )
      wr_full_o <= '0;
    else
      wr_full_o <= wr_full;
  end



assign rd_pntr_bin_t = rd_pntr_bin[AWIDTH-1:0];

always_ff @( posedge wr_clk_i, posedge aclr_i )
  begin
    if( aclr_i )
      wr_usedw_o <= '0;
    else
      begin
        if( wr_pntr_o >= rd_pntr_bin_t )
          begin
            wr_usedw_o <= wr_pntr_o - rd_pntr_bin_t;
          end
        else
          begin
            wr_usedw_o <= MAXWORDS[AWIDTH-1:0] - rd_pntr_bin_t + wr_pntr_o + 1'b1;
          end
      end
  end


endmodule
