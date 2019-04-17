module ram_memory #(
  parameter DWIDTH    = 8,
  parameter AWIDTH    = 3,
  parameter SHOWAHEAD = "OFF"
)(
  input                     rd_clk_i,
  input                     wr_clk_i,
  input                     aclr_i,
  
  input                     wr_req_i,
  input                     rd_req_i,
  input                     wr_full_i,
  input                     rd_empty_i,
  
  input        [DWIDTH-1:0] data_i,
  input        [AWIDTH-1:0] rd_pntr_i,
  input        [AWIDTH-1:0] wr_pntr_i,
  
  output logic [DWIDTH-1:0] q_o
);

(* ramstyle = "M10K, no_rw_check" *) logic [DWIDTH-1:0] mem [0:2**AWIDTH-1];

logic [AWIDTH-1:0] rd_pntr_reg;

// reading mechanism
generate
  if( SHOWAHEAD == "ON" ) 
    begin
      assign q_o = mem[rd_pntr_reg];
      always_latch
        begin
          if( rd_req_i )
            rd_pntr_reg <= rd_pntr_i;
        end
    end
  else if( SHOWAHEAD == "OFF" )
    begin
      always_ff @( posedge rd_clk_i, negedge aclr_i )
        begin
          if( !aclr_i )
            begin
              q_o <= 'x;
            end
          else if( rd_req_i && ( !rd_empty_i ) )
            begin
              q_o <= mem[rd_pntr_i];
            end
          else
            begin
              q_o <= q_o;
            end
        end
      end
endgenerate

// writing mechanism
always_ff @( posedge wr_clk_i )
  begin
    if( wr_req_i && ( !wr_full_i ) )
      mem[wr_pntr_i] <= data_i;
  end

endmodule
