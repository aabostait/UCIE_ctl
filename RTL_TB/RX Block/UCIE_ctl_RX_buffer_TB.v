module UCIE_ctl_RX_buffer_TB;

  parameter NBYTES = 3;
  parameter DEPTH  = 4;

  reg                clk_tb;
  reg                rst_tb;
  reg [NBYTES-1:0]   rdi_pl_data_tb;
  reg                rdi_pl_valid_tb;
  reg                buffer_en_tb;
  wire [NBYTES-1:0]  fdi_data_tb;
  wire               fdi_data_valid_tb;
  wire               overflow_detected_tb;

  UCIE_ctl_RX_buffer DUT (
    .i_clk(clk_tb),
    .i_rst(rst_tb),
    .i_rdi_pl_data(rdi_pl_data_tb),
    .i_rdi_pl_valid(rdi_pl_valid_tb),
    .i_buffer_en(buffer_en_tb),
    .o_fdi_data(fdi_data_tb),
    .o_fdi_data_valid(fdi_data_valid_tb),
    .o_overflow_detected(overflow_detected_tb)
  );
  initial clk_tb=0;
  always #10 clk_tb=~clk_tb;
  
  initial begin
    rst_tb = 0;
    rdi_pl_valid_tb = 0;
    buffer_en_tb = 0;
    
    
    #20
    rst_tb=1;
    #20
    buffer_en_tb = 1;
    repeat (DEPTH) begin
       rdi_pl_valid_tb = 1;
       rdi_pl_data_tb = $random;
       #40;
        $display("fdi_data_valid_tb=%d ", fdi_data_valid_tb);
      end
        rdi_pl_valid_tb = 0;
    $display("overflow_detected_tb=%b ", overflow_detected_tb);
    
    
    
end
 
endmodule

