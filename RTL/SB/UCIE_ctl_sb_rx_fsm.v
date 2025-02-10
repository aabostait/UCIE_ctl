`include "./defines.svh"
module UCIE_ctl_sb_rx_fsm
(
  input        i_clk,
  input        i_rst,
  input        i_pl_cfg_vld,
  input        i_count_done,
  input  [31:0] i_received_data,
  output reg   o_cfg_crd,
  output reg   o_sb_src_error,
  output reg   o_sb_dst_error,
  output reg   o_sb_opcode_error,
  output reg   o_sb_unsupported_message,
  output reg   o_sb_parity_error,
  output reg   o_valid_pl_sb,
  output reg [4:0] o_rdi_pl_sb_decode,
  output reg [31:0] o_rdi_pl_adv_cap_value
);

  // Internal Registers
  reg        r_phase0_parity, r_phase2_parity;
  reg        r_dp;
  reg [2:0]  r_current_state, r_next_state;

  // Local Parameters
  localparam idle                     = 3'b000; 
  localparam phase_0                  = 3'b001; 
  localparam phase_1                  = 3'b010;
  localparam phase_2                  = 3'b011;
  localparam phase_3                  = 3'b100;
  localparam ready                    = 3'b101;

  localparam opcode_msg_without_data  = 5'b10010;
  localparam opcode_msg_with_data     = 5'b11011;

  // State Register
  always @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
      r_current_state <= idle;
    end else begin
      r_current_state <= r_next_state;
    end
  end

  // Phase 0 Logic
  always @(posedge i_clk or negedge i_rst) begin
    if (!i_rst | (r_current_state == ready)) begin
      o_rdi_pl_sb_decode[4:2] <= 0;
      o_sb_src_error         <= 0;
      o_sb_opcode_error      <= 0;
      o_sb_unsupported_message <= 0;
      r_phase0_parity        <= 0;
    end else begin
      if (r_current_state == phase_0 & i_count_done) begin
        if (i_received_data[4:0] == opcode_msg_with_data) begin
          if (i_received_data[21:14] == 8'h01) begin
            o_rdi_pl_sb_decode[3:2] <= 2'b00;
          end else begin
            o_sb_unsupported_message <= 1;
          end
        end 

        if (i_received_data[4:0] == opcode_msg_without_data) begin
          o_rdi_pl_sb_decode[4] <= 1;
          case (i_received_data[21:14])
            8'h03: o_rdi_pl_sb_decode[3:2] <= 2'b01;
            8'h04: o_rdi_pl_sb_decode[3:2] <= 2'b10;
            8'h09: o_rdi_pl_sb_decode[3:2] <= 2'b11;
            default: begin
              o_rdi_pl_sb_decode[3:2] <= 2'b00;
              o_sb_unsupported_message <= 1;
            end
          endcase
        end

        if ((i_received_data[4:0] != opcode_msg_with_data) & 
            (i_received_data[4:0] != opcode_msg_without_data)) begin
          o_sb_opcode_error <= 1;
        end

        if (i_received_data[31:29] == 3'b001) begin
          o_sb_src_error <= 0;
        end else begin
          o_sb_src_error <= 1;
        end

        r_phase0_parity <= ^i_received_data;
      end
    end
  end

  // Phase 1 Logic
  always @(posedge i_clk or negedge i_rst) begin
    if (!i_rst | (r_current_state == ready)) begin
      o_rdi_pl_sb_decode[1:0] <= 0;
      o_sb_dst_error          <= 0;
      o_sb_unsupported_message <= 0;
      o_sb_parity_error       <= 0;
      r_dp                    <= 0;
    end else begin
      if (r_current_state == phase_1 & i_count_done) begin
        if (i_received_data[26:24] != 3'b101) begin
          o_sb_dst_error <= 1;
        end
        if (i_received_data[23:8] != 16'h0000) begin
          o_sb_unsupported_message <= 1;
        end
        case (o_rdi_pl_sb_decode[3:2])
          2'b01: begin
            case (i_received_data[7:0])
              8'h01: o_rdi_pl_sb_decode[1:0] <= 2'b01;
              8'h09: o_rdi_pl_sb_decode[1:0] <= 2'b11;
              default: begin
                o_rdi_pl_sb_decode[1:0] <= 2'b00;
                o_sb_unsupported_message <= 1;
              end
            endcase
          end
          2'b10: begin
            case (i_received_data[7:0])
              8'h01: o_rdi_pl_sb_decode[1:0] <= 2'b01;
              8'h09: o_rdi_pl_sb_decode[1:0] <= 2'b11;
              default: begin
                o_rdi_pl_sb_decode[1:0] <= 2'b00;
                o_sb_unsupported_message <= 1;
              end
            endcase
          end
          2'b11: begin
            case (i_received_data[7:0])
              8'h00: o_rdi_pl_sb_decode[1:0] <= 2'b00;
              8'h01: o_rdi_pl_sb_decode[1:0] <= 2'b01;
              8'h02: o_rdi_pl_sb_decode[1:0] <= 2'b10;
              default: begin
                o_rdi_pl_sb_decode[1:0] <= 2'b00;
                o_sb_unsupported_message <= 1;
              end
            endcase
          end
          2'b00: begin
            if (i_received_data[7:0] == 8'h00) begin
              o_rdi_pl_sb_decode[1:0] <= 2'b00;
            end else begin
              o_sb_unsupported_message <= 1;
              o_rdi_pl_sb_decode[1:0] <= 2'b00;
            end
          end
          default: o_sb_unsupported_message <= 1;
        endcase
        r_dp              <= i_received_data[31];
        o_sb_parity_error <= i_received_data[30] ^ (^{i_received_data[29:0], r_phase0_parity});
      end
    end
  end

  // Phase 2 Logic
  always @(posedge i_clk or negedge i_rst) begin
    if (!i_rst | (r_current_state == ready)) begin
      o_sb_parity_error <= 0;
      r_phase2_parity   <= 0;
      o_rdi_pl_adv_cap_value <= 0;
    end else begin
      if (r_current_state == phase_2 & i_count_done) begin
        o_rdi_pl_adv_cap_value <= i_received_data;
        r_phase2_parity <= ^i_received_data;
      end
    end
  end

  // Phase 3 Logic
  always @(posedge i_clk or negedge i_rst) begin
    if (!i_rst | (r_current_state == ready)) begin
      o_sb_parity_error <= 0;
    end else begin
      if (r_current_state == phase_3 & i_count_done) begin
        o_sb_parity_error <= o_sb_parity_error | (r_phase2_parity ^ i_received_data ^ r_dp);
      end
    end
  end

  // Next-State Logic
  always @(*) begin
    case (r_current_state)
      idle: begin
        o_valid_pl_sb = 0;
        if (i_pl_cfg_vld) begin
          o_cfg_crd  = 0;
          r_next_state = phase_0;
        end else begin
          o_cfg_crd  = 1;
          r_next_state = idle;
        end
      end

      phase_0: begin
        o_valid_pl_sb = 0;
        if (!i_pl_cfg_vld)
          r_next_state = idle;
       else if (i_count_done) begin
          r_next_state = phase_1;
        end else begin
          r_next_state = phase_0;
        end
      end

      phase_1: begin
        o_valid_pl_sb = 0;
        if (!i_pl_cfg_vld)
          r_next_state = idle;
        else if (i_count_done) begin
          r_next_state = phase_2;
        end else begin
          r_next_state = phase_1;
        end
      end

      phase_2: begin
        o_valid_pl_sb = 0;

        if (i_count_done) begin
          r_next_state = phase_3;
        end else begin
          r_next_state = phase_2;
        end
      end

      phase_3: begin
        o_valid_pl_sb = 0;
         if (i_count_done) begin
          r_next_state = ready;
        end else begin
          r_next_state = phase_3;
        end
      end

      ready: begin
        o_valid_pl_sb = 1;
        r_next_state  = idle;
      end
    endcase
  end
endmodule
