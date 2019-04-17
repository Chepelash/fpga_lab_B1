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

logic [AWIDTH:0] rd_pntr_bin;     
logic [AWIDTH:0] rd_pntr_bin_next;
logic [AWIDTH:0] rd_pntr_gray_next; // next read pointer in gray code
logic            rd_empty;

assign rd_pntr_o = rd_pntr_bin[AWIDTH-1:0];

always_ff @( posedge rd_clk_i, negedge aclr_i )
  begin
    if( !aclr_i )
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

assign rd_pntr_bin_next  = rd_pntr_bin + ( rd_req_i & ~rd_empty_o );
assign rd_pntr_gray_next = rd_pntr_bin_next ^ ( rd_pntr_bin_next >> 1 );


assign rd_empty = ( rd_pntr_gray_next == wr_pntr_gray_i );

always_ff @( posedge rd_clk_i, negedge aclr_i )
  begin
    if( !aclr_i )
      rd_empty_o <= '1;
    else
      rd_empty_o <= rd_empty;
  end

  
logic [AWIDTH:0]   cntr; // just counter
logic [AWIDTH:0]   wr_pntr_bin;
logic [AWIDTH-1:0] wr_pntr_bin_t;
always_comb
  begin
    wr_pntr_bin = '0;
    for( cntr = 0; cntr < AWIDTH; cntr++ )
      wr_pntr_bin[cntr] = ^( wr_pntr_gray_i >> cntr );
  end

assign wr_pntr_bin_t = wr_pntr_bin[AWIDTH-1:0];

always_ff @( posedge rd_clk_i, negedge aclr_i )
  begin
    if( !aclr_i )
      rd_usedw_o <= '0;
    else
      begin
        if( wr_pntr_bin_t >= rd_pntr_o )
          begin
            rd_usedw_o <= wr_pntr_bin_t - rd_pntr_o;
          end
        else
          begin
            rd_usedw_o <= DWIDTH[AWIDTH-1:0] - rd_pntr_o + wr_pntr_bin_t;
          end
      end
  end

endmodule
