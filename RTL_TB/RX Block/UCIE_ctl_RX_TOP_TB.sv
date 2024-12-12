
module UCIE_ctl_RX_TOP_TB();

  parameter NBYTES = 32;


  reg                  i_clk;
  reg                  i_rst;
  reg                  i_state_request;
  reg  [NBYTES-1:0]    i_rdi_pl_data;
  reg                  i_rdi_pl_valid;
  wire [NBYTES-1:0]    o_fdi_data;
  wire                 o_fdi_data_valid;
  wire                 o_overflow_detected;
 

  UCIE_ctl_RX_TOP  DUT (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_state_request(i_state_request),
    .i_rdi_pl_data(i_rdi_pl_data),
    .i_rdi_pl_valid(i_rdi_pl_valid),
    .o_fdi_data(o_fdi_data),
    .o_fdi_data_valid(o_fdi_data_valid),
    .o_overflow_detected(o_overflow_detected)
  );
  
  
    initial i_clk = 0;
    always #5 i_clk = ~i_clk;

  
  initial begin
    i_rst = 1;
    i_state_request = 0;
    i_rdi_pl_data = 0;
    i_rdi_pl_valid = 0;

    
    #10 i_rst = 0;
    #10 i_rst = 1;

    // Normal operation
    #20 i_state_request = 1;
    #10 i_rdi_pl_valid = 1;
    i_rdi_pl_data = 8'hA5;
    #10 i_rdi_pl_data = 8'h5A;
    #10 i_rdi_pl_valid = 0;

    // Buffer overflow
    repeat (33) begin
      #10 i_rdi_pl_valid = 1;
      i_rdi_pl_data = $random;
    end
    #10 i_rdi_pl_valid = 0;

    //State transition to idle
    #20 i_state_request = 0;

  
  end


endmodule
