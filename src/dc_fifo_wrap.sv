module dc_fifo_wrap #(
  parameter DWIDTH    = 8,
  parameter AWIDTH    = 4,
  parameter SHOWAHEAD = "ON"
)(
  input                     rd_clk_i,
  input                     wr_clk_i,
  input                     aclr_i,
  
  input                     wr_req_i,
  input                     rd_req_i,
  
  input        [DWIDTH-1:0] data_i,
  
  output logic [DWIDTH-1:0] q_o,
  
  output logic              wr_empty_o,
  output logic              wr_full_o,
  output logic [AWIDTH-1:0] wr_usedw_o,
  
  output logic              rd_empty_o,
  output logic              rd_full_o,  
  output logic [AWIDTH-1:0] rd_usedw_o
);


logic              wr_req_i_wrap;
logic              rd_req_i_wrap;

logic [DWIDTH-1:0] data_i_wrap;

logic [DWIDTH-1:0] q_o_wrap;

logic              wr_empty_o_wrap;
logic              wr_full_o_wrap;
logic [AWIDTH-1:0] wr_usedw_o_wrap;

logic              rd_empty_o_wrap;
logic              rd_full_o_wrap;
logic [AWIDTH-1:0] rd_usedw_o_wrap;

dc_fifo #(
  .DWIDTH     ( DWIDTH          ),
  .AWIDTH     ( AWIDTH          )
) dc_fifo_1   (
  .rd_clk_i   ( rd_clk_i        ),
  .wr_clk_i   ( wr_clk_i        ),
  .aclr_i     ( aclr_i          ),
  
  .wr_req_i   ( wr_req_i_wrap   ),
  .rd_req_i   ( rd_req_i_wrap   ),
  
  .data_i     ( data_i_wrap     ),
  
  .q_o        ( q_o_wrap        ),
 
  .wr_empty_o ( wr_empty_o_wrap ),
  .wr_full_o  ( wr_full_o_wrap  ),
  .wr_usedw_o ( wr_usedw_o_wrap ),

  .rd_empty_o ( rd_empty_o_wrap ),
  .rd_full_o  ( rd_full_o_wrap  ),
  .rd_usedw_o (rd_usedw_o_wrap  )
);


always_ff @( posedge rd_clk_i )
  begin
    rd_req_i_wrap <= rd_req_i;
    
    rd_empty_o    <= rd_empty_o_wrap;
    rd_full_o     <= rd_full_o_wrap;
    rd_usedw_o    <= rd_usedw_o_wrap;
    q_o           <= q_o_wrap;
  end

always_ff @( posedge wr_clk_i )
  begin
    wr_req_i_wrap <= wr_req_i;
    data_i_wrap   <= data_i;
    
    wr_empty_o    <= wr_empty_o_wrap;
    wr_full_o     <= wr_full_o_wrap;
    wr_usedw_o    <= wr_usedw_o_wrap;
  end

endmodule
