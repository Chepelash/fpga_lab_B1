module dc_fifo_tb;

parameter  int CLK_RD  = 30;
parameter  int CLK_WR  = 30;

parameter  int DWIDTH = 8;
parameter  int AWIDTH = 4;

localparam int ADRESSES = 2**AWIDTH;

logic              rd_clk;
logic              wr_clk;
logic              aclr;

logic              wr_req_i;
logic              rd_req_i;

logic [DWIDTH-1:0] data_i;

logic [DWIDTH-1:0] q_o;

logic              wr_empty_o;
logic              wr_full_o;
logic [AWIDTH-1:0] wr_usedw_o;

logic              rd_empty_o;
logic              rd_full_o; 
logic [AWIDTH-1:0] rd_usedw_o;


mailbox m_box = new(); // mailbox!


dc_fifo      #(
  .DWIDTH     ( DWIDTH     ),
  .AWIDTH     ( AWIDTH     )
) DUT         (
  .rd_clk_i   ( rd_clk     ),
  .wr_clk_i   ( wr_clk     ),
  .aclr_i     ( aclr       ),
  
  .wr_req_i   ( wr_req_i   ),
  .rd_req_i   ( rd_req_i   ),
  
  .data_i     ( data_i     ),
  
  .q_o        ( q_o        ),
  
  .wr_empty_o ( wr_empty_o ),
  .wr_full_o  ( wr_full_o  ),
  .wr_usedw_o ( wr_usedw_o ),
  
  .rd_empty_o ( rd_empty_o ),
  .rd_full_o  ( rd_full_o  ),  
  .rd_usedw_o ( rd_usedw_o )
);


task automatic rd_clk_gen;
  
  forever
    begin
      # ( CLK_RD / 2 );
      rd_clk <= ~rd_clk;
    end
  
endtask

task automatic wr_clk_gen;
  
  forever
    begin
      # ( CLK_WR / 2 );
      wr_clk <= ~wr_clk;
    end
  
endtask



task automatic apply_aclr;
  
  aclr <= 1'b0;
  @( posedge wr_clk );
  aclr <= 1'b1;
  @( posedge wr_clk );

endtask


bit [DWIDTH-1:0] wr_data;

task automatic writing_test;
  $display("Starting writing test!");
  
  wr_req_i <= '1;
  for( int i = 0; i < ADRESSES; i++ )
    begin
      if( wr_full_o == '1 )
        begin
          $display("Fail! Unexpected wr_full flag");
          $stop();
        end
      wr_data = $urandom_range(2**DWIDTH - 1); 
      m_box.put(wr_data);
      data_i <= wr_data;
      
      @( posedge wr_clk );
      
    end
  wr_req_i <= '0;
  @( posedge wr_clk );
  @( posedge wr_clk );
  @( posedge wr_clk );
  @( posedge wr_clk );
  @( posedge wr_clk );
  @( posedge wr_clk );
  @( posedge wr_clk );
  @( posedge wr_clk );
  @( posedge wr_clk );
  @( posedge wr_clk );
  @( posedge wr_clk );
  @( posedge wr_clk );
  @( posedge wr_clk );
  @( posedge wr_clk );
  
  // fail states
  if( wr_full_o != '1 )
    begin
      $display("Fail! Expected wr_full flag");
      $stop();
    end
  if( wr_empty_o != '0 )
    begin
      $display("Fail! Unexpected wr_empty flag");
      $stop();
    end
  if( rd_empty_o != '0 )
    begin
      $display("Fail! Unexpected rd_empty flag");
      $stop();
    end
  // end fail states

endtask

task automatic reading_test;


endtask


task automatic init;
  aclr     <= '1;
  rd_clk   <= '1;
  wr_clk   <= '1;
  rd_req_i <= '0;
  wr_req_i <= '0;  
  
endtask

initial
  begin
    init();
    fork
      wr_clk_gen();
      rd_clk_gen();
    join_none 
    
    apply_aclr();
    
    $display("Starting testbench!");
    
    
    writing_test();
    
    reading_test();
    
    
    for( int i = 0; i < 100; i++ )
      @( posedge wr_clk );
      
    $stop();
  end


endmodule
