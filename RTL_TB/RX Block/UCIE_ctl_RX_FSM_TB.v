module UCIE_ctl_RX_FSM_TB ();
  
  reg i_clk_tb,i_rst_tb,i_overflow_detected_tb;
  reg  i_state_request_tb;
  wire o_buffer_enable_tb,o_overflow_detected_tb;
  
  UCIE_ctl_RX_FSM DUT (
  .i_clk(i_clk_tb),
  .i_rst(i_rst_tb),
  .i_overflow_detected(i_overflow_detected_tb),
  .i_state_request(i_state_request_tb),
  .o_buffer_enable(o_buffer_enable_tb),
  .o_overflow_detected(o_overflow_detected_tb)
  );
  
  
  always #10 i_clk_tb=~i_clk_tb;
  
  initial begin
    i_clk_tb='b0;
    i_rst_tb='b0;
    i_overflow_detected_tb='b0;
    i_state_request_tb='b0;
    
    
    # 10
    i_rst_tb='b1;
    
    #10
    $display("o_buffer_enable_tb=%d ", o_buffer_enable_tb);
    
    #10
    i_state_request_tb='b1;
    
    #10
    $display("after enable -> o_buffer_enable_tb=%d ", o_buffer_enable_tb);
    
    #40
    i_overflow_detected_tb='b1;
    #10
    $display("after overflow -> o_buffer_enable_tb=%d ", o_buffer_enable_tb);

    
    
  end
  
endmodule
