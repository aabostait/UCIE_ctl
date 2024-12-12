module UCIE_ctl_RX_TOP #( parameter NBYTES=32)(
  
  input wire               i_clk,
  input wire               i_rst,
  input wire        i_state_request,
  input wire [NBYTES-1:0]  i_rdi_pl_data,
  input wire               i_rdi_pl_valid,
  
  output wire [NBYTES-1:0]  o_fdi_data,
  output wire               o_fdi_data_valid,
  output wire               o_overflow_detected
 
);

wire w_buffer_enable;
wire w_overflow_detected;

UCIE_ctl_RX_buffer BUF(
  .i_clk(i_clk),
  .i_rst(i_rst),
  .i_rdi_pl_data(i_rdi_pl_data),
  .i_rdi_pl_valid(i_rdi_pl_valid),
  .o_fdi_data(o_fdi_data),
  .o_fdi_data_valid(o_fdi_data_valid),
  .o_overflow_detected(w_overflow_detected),
  .i_buffer_en(w_buffer_enable)
);

UCIE_ctl_RX_FSM FSM (
  .i_clk(i_clk),
  .i_rst(i_rst),
  .i_state_request(i_state_request),
  .o_overflow_detected(o_overflow_detected),
  .o_buffer_enable(w_buffer_enable),
  .i_overflow_detected(w_overflow_detected)
);

endmodule