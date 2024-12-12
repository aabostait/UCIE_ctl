module UCIE_ctl_RX_buffer #(parameter NBYTES=32 , DEPTH=4)(
  
  input wire               i_clk,
  input wire               i_rst,
  input wire [NBYTES-1:0]  i_rdi_pl_data,
  input wire               i_rdi_pl_valid,
  input wire               i_buffer_en,
  output reg [NBYTES-1:0]  o_fdi_data,
  output reg               o_fdi_data_valid,
  output reg               o_overflow_detected
  );
  
  
  reg [NBYTES-1:0] r_mem [DEPTH-1:0];
  reg [DEPTH-1:0] r_rd_ptr,r_wr_ptr   ;
  reg [DEPTH-1:0] r_count             ;
  
  
  always@(posedge i_clk or negedge i_rst)begin
    if(!i_rst)begin
      r_wr_ptr            <=0;
      r_rd_ptr            <=0;
      r_count             <=0;
      o_fdi_data_valid    <=0;
      o_overflow_detected <=0;
    end
      
    else if(i_buffer_en && i_rdi_pl_valid)begin
        if(r_count < DEPTH)begin
          r_mem[r_wr_ptr] <=i_rdi_pl_data;
          r_count         <=r_count+1    ;
          r_wr_ptr        <=r_wr_ptr+1   ;
        end else begin
          o_overflow_detected <= 1       ;
        end
      end 
  end

  always@(posedge i_clk)begin
      if(i_buffer_en && (DEPTH >= r_count) && (r_count > 0))begin
       o_fdi_data_valid <= 1              ;
       o_fdi_data       <= r_mem[r_rd_ptr];
       r_rd_ptr         <= r_rd_ptr + 1   ;
       r_count          <=r_count-1       ;
     end else begin
       o_fdi_data_valid <= 0              ;
     end
      
  end
endmodule 



