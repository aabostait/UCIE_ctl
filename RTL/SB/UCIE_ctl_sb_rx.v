`include "./defines.svh"
module UCIE_ctl_sb_rx #(
  parameter N = `NC // Default width of the input data
) (
  input  wire         i_clk,                     // Clock signal
  input  wire         i_rst,                     // Reset signal (active low)
  input  wire         i_pl_cfg_vld,              // Configuration valid signal
  input  wire [N-1:0] i_received_data,           // Received data input
  output wire         o_cfg_crd,                 // Configuration credit output
  output wire         o_sb_src_error,            // Source error signal
  output wire         o_sb_dst_error,            // Destination error signal
  output wire         o_sb_opcode_error,         // Opcode error signal
  output wire         o_sb_unsupported_message,  // Unsupported message signal
  output wire         o_sb_parity_error,         // Parity error signal
  output wire         o_valid_pl_sb,             // Valid PL SB signal
  output wire [4:0]   o_rdi_pl_sb_decode,        // RDI PL SB decode signal
  output wire [31:0]  o_rdi_pl_adv_cap_value     // RDI PL advanced capability value
);

  // Internal signals
  wire        w_counter_done;          // Counter done signal
  wire [2:0]  w_counter_count;         // Counter output count
  wire [31:0] w_shift_reg_out;         // Shift register output

  // Counter instantiation
  UCIE_ctl_counter #(
    .N(N) // Counter parameter
  ) counter_inst (
    .i_clk(i_clk),
    .i_reset(i_rst),
    .i_enable(i_pl_cfg_vld),
    .o_count(w_counter_count),
    .o_done(w_counter_done)
  );

  // Shift register instantiation
  UCIE_ctl_shift_register #(
    .N(N) // Width of the input data
  ) shift_reg_inst (
    .i_clk(i_clk),
    .i_reset(i_rst),
    .i_enable(i_pl_cfg_vld),  // Enable shift register
    .i_data_in(i_received_data),
    .o_reg_out(w_shift_reg_out)
  );

  // FSM instantiation
  UCIE_ctl_sb_rx_fsm fsm_inst (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_pl_cfg_vld(i_pl_cfg_vld),
    .i_count_done(w_counter_done),
    .i_received_data(w_shift_reg_out),
    .o_cfg_crd(o_cfg_crd),
    .o_sb_src_error(o_sb_src_error),
    .o_sb_dst_error(o_sb_dst_error),
    .o_sb_opcode_error(o_sb_opcode_error),
    .o_sb_unsupported_message(o_sb_unsupported_message),
    .o_sb_parity_error(o_sb_parity_error),
    .o_valid_pl_sb(o_valid_pl_sb),
    .o_rdi_pl_sb_decode(o_rdi_pl_sb_decode),
    .o_rdi_pl_adv_cap_value(o_rdi_pl_adv_cap_value)
  );

endmodule

