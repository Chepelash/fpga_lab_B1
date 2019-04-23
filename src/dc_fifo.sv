module dc_fifo #(
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

localparam AWVAL = AWIDTH + 1;

logic [AWIDTH-1:0] rd_pntr;
logic [AWVAL-1:0]  rd_pntr_gray;
logic [AWVAL-1:0]  rd_pntr_gray_wr;

logic              wr_full;
logic [AWIDTH-1:0] wr_pntr;
logic [AWVAL-1:0]  wr_pntr_gray;
logic [AWVAL-1:0]  wr_pntr_gray_rd;

ram_memory   #(
  .DWIDTH     ( DWIDTH     ),
  .AWIDTH     ( AWIDTH     ),
  .SHOWAHEAD  ( SHOWAHEAD  )
) ram_mem     (
  .rd_clk_i   ( rd_clk_i   ),
  .wr_clk_i   ( wr_clk_i   ),
  .aclr_i     ( aclr_i     ),
  
  .wr_req_i   ( wr_req_i   ),
  .rd_req_i   ( rd_req_i   ),
  .wr_full_i  ( wr_full_o  ), 
  .rd_empty_i ( rd_empty_o ),
  
  .data_i     ( data_i     ),
  .rd_pntr_i  ( rd_pntr    ), 
  .wr_pntr_i  ( wr_pntr    ), 
  
  .q_o        ( q_o        )
);

rd_pntrs_and_empty  #(
  .AWIDTH            ( AWIDTH          )
) rd_pntr_empty      (
  .rd_clk_i          ( rd_clk_i        ),
  .aclr_i            ( aclr_i          ),
  .rd_req_i          ( rd_req_i        ),
  
  .wr_pntr_gray_i    ( wr_pntr_gray    ), 
  
  .rd_pntr_o         ( rd_pntr         ),
  .rd_pntr_gray_wr_o ( rd_pntr_gray_wr ), 
  .rd_empty_o        ( rd_empty_o      ),
  .rd_usedw_o        ( rd_usedw_o      )
);

wr_pntrs_and_full   #(
  .DWIDTH            ( DWIDTH          ),
  .AWIDTH            ( AWIDTH          )
) wr_pntr_full       (
  .wr_clk_i          ( wr_clk_i        ),
  .aclr_i            ( aclr_i          ),
  .wr_req_i          ( wr_req_i        ),
  
  .rd_pntr_gray_i    ( rd_pntr_gray    ), 
  
  .wr_pntr_o         ( wr_pntr         ),
  .wr_pntr_gray_rd_o ( wr_pntr_gray_rd ), 
  .wr_full_o         ( wr_full_o       ),
  .wr_usedw_o        ( wr_usedw_o      )
);

sync           #(
  .AWIDTH       ( AWIDTH          )
) sync_r2w      (
  .clk_i        ( wr_clk_i        ),
  .aclr_i       ( aclr_i          ),
  
  .pntr_gray_i  ( rd_pntr_gray_wr ),
  .flag_i       ( rd_empty_o      ),
  .resetval_i   ( 1'b1            ),
  
  .pntr_gray_o  ( rd_pntr_gray    ),
  .flag_o       ( wr_empty_o      )  
);

sync           #(
  .AWIDTH       ( AWIDTH          )
) sync_w2r      (
  .clk_i        ( rd_clk_i        ),
  .aclr_i       ( aclr_i          ),
  
  .pntr_gray_i  ( wr_pntr_gray_rd ),
  .flag_i       ( wr_full_o       ),
  .resetval_i   ( 1'b0            ),
  
  .pntr_gray_o  ( wr_pntr_gray    ),
  .flag_o       ( rd_full_o       )
  
);

endmodule
