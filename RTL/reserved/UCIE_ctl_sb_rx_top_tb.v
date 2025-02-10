`timescale 1ns / 1ps


module UCIE_ctl_sb_rx_top_tb #(parameter N = 16);  // Parameterized width

  // Inputs to the DUT (Device Under Test)
  reg i_clk;
  reg i_rst;
  reg i_pl_cfg_vld;
  reg [N-1:0] i_received_data;  // Parameterized input data

  // Outputs from the DUT
  wire o_cfg_crd;
  wire o_valid_pl_sb;
  wire o_sb_src_error;
  wire o_sb_dst_error;
  wire o_sb_opcode_error;
  wire o_sb_unsupported_message;
  wire o_sb_parity_error;
  wire [4:0] o_rdi_pl_sb_decode;
  wire [31:0] o_rdi_pl_adv_cap_value;

  // Instantiate the top module (DUT) with parameter n
  UCIE_ctl_sb_rx #(.N(N)) u_dut (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_pl_cfg_vld(i_pl_cfg_vld),
    .i_received_data(i_received_data),
    .o_cfg_crd(o_cfg_crd),
    .o_valid_pl_sb(o_valid_pl_sb),
    .o_sb_src_error(o_sb_src_error),
    .o_sb_dst_error(o_sb_dst_error),
    .o_sb_opcode_error(o_sb_opcode_error),
    .o_sb_unsupported_message(o_sb_unsupported_message),
    .o_sb_parity_error(o_sb_parity_error),
    .o_rdi_pl_sb_decode(o_rdi_pl_sb_decode),
    .o_rdi_pl_adv_cap_value(o_rdi_pl_adv_cap_value)
  );

  // Phase 0: Valid/Invalid source ID, message code, and opcode
  localparam opcode_msg_without_data = 5'b10010;
  localparam opcode_msg_with_data    = 5'b11011;
  localparam src_id_valid    = 3'b001;
  localparam src_id_invalid  = 3'b000;
  localparam msg_code_invalid = 8'b11111111;
  localparam opcode_invalid   = 5'b11111;

  // Phase 1: Valid/Invalid dp, cp, dst_id, msg_info, msg_sub_code
  localparam dst_id_valid      = 3'b101;
  localparam dst_id_invalid    = 3'b110;
  localparam msg_info_valid    = 16'b0000000000000000;
  localparam msg_info_invalid  = 16'b1111111111111111;
  localparam msg_sub_code_invalid = 8'b11111111;

  // Phase 2 and Phase 3: Data bits and parity
  localparam data_bits_even = 32'b00000000000000000000000000000000;
  localparam data_bits_odd  = 32'b00000000000000000000000000000001;

  // Complete messages
  localparam req_active_phase0 = {src_id_valid, 7'b0000000, 8'h03, 9'b0, opcode_msg_without_data};
  localparam req_linkreset_phase0 = {src_id_valid, 7'b0, 8'h03, 9'b0, opcode_msg_without_data};
  localparam rsp_active_phase0 = {src_id_valid, 7'b0, 8'h04, 9'b0, opcode_msg_without_data};
  localparam rsp_linkreset_phase0 = {src_id_valid, 7'b0, 8'h04, 9'b0, opcode_msg_without_data};
  localparam errmsg_phase0 = {src_id_valid, 7'b0, 8'h09, 9'b0, opcode_msg_without_data};
  localparam req_active_phase1 = {1'b0, 1'b0, 3'b0, dst_id_valid, msg_info_valid, 8'h01};
  localparam req_linkreset_phase1 = {1'b0, 1'b0, 3'b0, dst_id_valid, msg_info_valid, 8'h09};
  localparam rsp_active_phase1 = {1'b0, 1'b1, 3'b0, dst_id_valid, msg_info_valid, 8'h01};
  localparam rsp_linkreset_phase1 = {1'b0, 1'b0, 3'b0, dst_id_valid, msg_info_valid, 8'h09};
  localparam err_ce = {1'b0, 1'b0, 3'b0, dst_id_valid, msg_info_valid, 8'h00};
  localparam err_nf = {1'b0, 1'b1, 3'b0, dst_id_valid, msg_info_valid, 8'h01};
  localparam err_f = {1'b0, 1'b1, 3'b0, dst_id_valid, msg_info_valid, 8'h02};
  localparam advcap_phase0 = {src_id_valid, 7'b0000000, 8'h01, 9'b0, opcode_msg_with_data};
  localparam advcap_phase1 = {1'b0, 1'b0, 3'b0, dst_id_valid, msg_info_valid, 8'h00};
  localparam all_errors_phase0 = {src_id_invalid, 7'b0000000, 8'h03, 9'b0, 5'b00000};
  localparam all_errors_phase1 = {1'b0, 1'b1, 3'b0, dst_id_invalid, msg_info_invalid, 8'h01};

  // Clock generation
  always begin
    #5 i_clk = ~i_clk;  // 10ns clock period
  end

  // Initialize signals
  initial begin
    i_clk = 0;
    i_rst = 0;
    i_pl_cfg_vld = 0;
    i_received_data = 32'b0;

    // start 
    #15 i_rst = 1;
    #10;
    i_pl_cfg_vld <= 1;
    
    /*
    //32 bit configuration Test cases: Phase 0, Phase 1, Phase 2, Phase 3

    // Phase 0: Valid src_id, msg_code, and opcode
    i_received_data <= req_active_phase0;  // Valid case
    #10;

    // Phase 1: Valid dp, cp, dst_id, msg_info, msg_sub_code
    i_received_data <= req_active_phase1;  // Valid case
    #10;

    // Phase 2:
    i_received_data <= data_bits_even;  // Valid data with correct dp parity
    #10;

    // Phase 3:
    i_received_data <= data_bits_even;  // Valid data with correct dp parity
    #10;
    i_pl_cfg_vld <= 0;

    #20;
    i_pl_cfg_vld <= 1;
    // Test cases: Phase 0, Phase 1, Phase 2, Phase 3

    // Phase 0:
    i_received_data <= all_errors_phase0;
    #10;

    // Phase 1:
    i_received_data <= all_errors_phase1;
    #10;

    // Phase 2:
    i_received_data <= data_bits_odd;
    #10;

    // Phase 3:
    i_received_data <= data_bits_even;
    #10;
*/

// 16 bit configuration
    
    // Test cases: Phase 0, Phase 1, Phase 2, Phase 3

    // Phase 0 part 1:
    i_received_data <= req_active_phase0 [31:16];  // Valid case
    #10;

    // Phase 0 part 2:
    i_received_data <= req_active_phase0 [15:0]; 
    #10;

    // Phase 1 part 1:
    i_received_data <= req_active_phase1 [31:16];
    #10;

    // Phase 1 part 2:
    i_received_data <= req_active_phase1 [15:0]; 
    #10;

    // Phase 2 part 1:
    i_received_data <= data_bits_even[31:16];  // Valid data with correct dp parity
    #10;

    // Phase 2 part 2:
    i_received_data <= data_bits_even[15:0];  // Valid data with correct dp parity
    #10;

    // Phase 3 part 1:
    i_received_data <= data_bits_even[31:16];  // Valid data with correct dp parity
    #10;

    // Phase 3 part 2:
    i_received_data <= data_bits_even[15:0];
    #10;   
    i_pl_cfg_vld <= 0;

    #30;
    i_pl_cfg_vld <= 1;
    // Test cases: Phase 0, Phase 1, Phase 2, Phase 3

    // Phase 0 part 1:
    i_received_data <= all_errors_phase0 [31:16];  // Valid case
    #10;

    // Phase 0 part 2:
    i_received_data <= all_errors_phase0 [15:0]; 
    #10;

    // Phase 1 part 1:
    i_received_data <= all_errors_phase1 [31:16];
    #10;

    // Phase 1 part 2:
    i_received_data <= all_errors_phase1 [15:0]; 
    #10;

    // Phase 2 part 1:
    i_received_data <= data_bits_even[31:16];
    #10;

    // Phase 2 part 2:
    i_received_data <= data_bits_even[15:0];
    #10;

    // Phase 3 part 1:
    i_received_data <= data_bits_even[31:16];
    #10;

    // Phase 3 part 2:
    i_received_data <= data_bits_odd[15:0];
    #10;  
    i_pl_cfg_vld <= 0;
    #40;

  end

endmodule
