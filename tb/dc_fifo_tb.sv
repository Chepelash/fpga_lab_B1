module dc_fifo_tb;

parameter  int CLK_RD  = 60;
parameter  int CLK_WR  = 52;

parameter  int DWIDTH = 8;
parameter  int AWIDTH = 3;
parameter      SHOWAHEAD = "ON";

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


int queue[$];


dc_fifo      #(
  .DWIDTH     ( DWIDTH     ),
  .AWIDTH     ( AWIDTH     ),
  .SHOWAHEAD  ( SHOWAHEAD  )
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
  
  aclr <= 1'b1;
  @( posedge wr_clk );
  aclr <= 1'b0;
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
      queue.push_back(wr_data);
      data_i <= wr_data;
      
      @( posedge wr_clk );
      
    end
  wr_req_i <= '0;
  @( posedge wr_clk );
  
  // fail states
  if( wr_full_o != '1 )
    begin
      $display("Fail! Expected wr_full flag");
      $stop();
    end
  // syncronization
  for( int i = 0; i < 2; i++ )
    @( posedge rd_clk );
    
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

bit [DWIDTH-1:0] rd_data;
int              cntr;

task automatic reading_test;
  $display("Starting reading test!");
  
  rd_req_i <= '1;
  cntr = 0;
  @( posedge rd_clk );
  if( SHOWAHEAD == "OFF" )
    @( posedge rd_clk );
  for( int i = 0; i < ADRESSES; i++ )
    begin
      if ( ( SHOWAHEAD == "OFF" ) && ( i == ( ADRESSES - 1 ) ) )
        begin
          if ( rd_empty_o != 1 )
            begin
              $display("Fail! Expected rd_empty flag at the end");
              $stop();
            end
        end
      else if( rd_empty_o == '1 )
        begin
          $display("Fail! Unexpected rd_empty flag");
          $stop();
        end
      rd_data = queue.pop_front();

      if( rd_data != q_o )
        begin
          $display("Fail! Unexpected data read. cntr = %d. q_o = %b, rd_data = %b", cntr, q_o, rd_data);
          $stop();
        end
      @( posedge rd_clk );
    end
  
  // fail states
  if( rd_empty_o != '1 )
    begin
      $display("Fail! Expected rd_empty flag");
      $stop();
    end
  
  // syncronization
  for( int i = 0; i < 2; i++ )
    @( posedge wr_clk );
    
  if( wr_full_o != '0 )
    begin
      $display("Fail! Unexpected wr_full flag");
      $stop();
    end
  if( wr_empty_o != '1 )
    begin
      $display("Fail! Unexpected wr_empty flag");
      $stop();
    end
  // end fail states

endtask


task automatic init;
  aclr     <= '0;
  rd_clk   <= '1;
  wr_clk   <= '1;
  rd_req_i <= '0;
  wr_req_i <= '0;
endtask

task write_fifo_data( mailbox ref_data );
logic [DWIDTH-1:0] next_ref_data;
  forever
    begin
      @( posedge wr_clk )
      if( !wr_full_o )
        begin
          next_ref_data = $urandom_range(2**DWIDTH - 1);
          ref_data.put( next_ref_data );
          data_i <= next_ref_data;
          wr_req_i <= 1'b1;
        end
      else
        begin
          while( !wr_full_o )
            @( posedge wr_clk );
        end
    end
endtask

// Working only with SHOWAHEAD mod for now!
task collect_fifo_data( mailbox read_data );
  forever
    begin
      @( posedge rd_clk );
      if( !rd_empty_o )
        begin
          read_data.put( q_o );
          rd_req_i <= 1'b1;
        end
      else
        rd_req_i <= 1'b1;
    end
endtask

task check_data( mailbox read_data, mailbox ref_data );
logic [DWIDTH-1:0] next_ref_data;
logic [DWIDTH-1:0] next_dut_data;

  forever
    begin
      ref_data.get( next_ref_data );
      read_data.get( next_dut_data );
      if( next_ref_data !== next_dut_data )
        begin
          $error( "Data mismatch!\n\tExpected %x\n\tRead %x" , next_ref_data, next_dut_data );
          $stop();
        end
    end
endtask

mailbox ref_data;
mailbox dut_data;

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
    $display("Writing test - OK!");
    
    reading_test();
    $display("Reading test - OK!");

    ref_data = new();
    dut_data = new();

    init();
    apply_aclr();

    fork
      write_fifo_data( ref_data );
      collect_fifo_data( dut_data );
      check_data( dut_data, ref_data );
    join
    // For now testbench will never end!
    // TODO: Added check for timeout and test finish conditions
    $display("Everything is OK!");
    $stop();
  end


endmodule
