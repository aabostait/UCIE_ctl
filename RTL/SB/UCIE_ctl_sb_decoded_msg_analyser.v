// ************************* Description ************************** //
//  This module is implemented to:-                                 //
//  -- analysing decoded msg sent by ctrl module                    //
//  -- generate control signal and msg parts addresses              //
// **************************************************************** //
`include "./defines.svh"
module UCIE_ctl_sb_decoded_msg_analyser(
    // Global domains
    input   wire              i_clk,
    input   wire              i_rst,
    // CTL interface    
    input   wire [4:0]        i_rdi_lp_sb_decode,
    // SB control signals   
    input   wire              i_enable,
    output  reg   				    o_op_addr,
    output  reg   [1 : 0 ]    o_msg_addr,
    output  reg   [1 : 0 ]    o_sub_addr,
    output  reg   				    o_info_addr,
    output  reg   [1:0]       o_sel_data,
    output  reg               o_ignore_data2
);

    // REGFILE ADDR WIDTH
    localparam OP_CODE_ADDR_WIDTH   = 1;
    localparam INFO_CODE_ADDR_WIDTH = 1;
    localparam MSG_CODE_ADDR_WIDTH  = 2;
    localparam SUB_CODE_ADDR_WIDTH  = 2;

    localparam ADV_CAP                              = 5'b00000;
    localparam LINK_MGMT_ADAPTER0_REQ_ACTIVE        = 5'b10101;
    localparam LINK_MGMT_ADAPTER0_REQ_LINK_RESET    = 5'b10111;
    localparam LINK_MGMT_ADAPTER0_RSP_ACTIVE        = 5'b11001;
    localparam LINK_MGMT_ADAPTER0_RSP_LINK_RESET    = 5'b11011;
    localparam ERROR_CORRECTABLE                    = 5'b11100;
    localparam ERROR_NON_FATAL                      = 5'b11101;
    localparam ERROR_FATAL                          = 5'b11110;


    localparam OP_CODE_1_ADDR = 0;
    localparam OP_CODE_2_ADDR = 1;

    localparam MSG_CODE_1_ADDR = 0;
    localparam MSG_CODE_2_ADDR = 1;
    localparam MSG_CODE_3_ADDR = 2;
    localparam MSG_CODE_4_ADDR = 3;

    localparam SUB_CODE_1_ADDR = 0;
    localparam SUB_CODE_2_ADDR = 1;
    localparam SUB_CODE_3_ADDR = 2;
    localparam SUB_CODE_4_ADDR = 3;

    localparam INFO_CODE_1_ADDR = 0;


    always @(posedge i_clk, negedge i_rst) begin
      if(!i_rst)begin
          o_op_addr      <= 0;
          o_msg_addr     <= 0;
          o_sub_addr     <= 0;
          o_info_addr    <= 0;
  
          o_sel_data     <= 0;
          o_ignore_data2 <= 0;

      end else if (i_enable) begin
          o_op_addr          <= OP_CODE_1_ADDR;
          o_info_addr        <= INFO_CODE_1_ADDR;
          o_ignore_data2     <= 1;
          o_sel_data         <= 0;
          case (i_rdi_lp_sb_decode)
            ADV_CAP: begin
              o_op_addr      <= OP_CODE_2_ADDR;
              o_msg_addr     <= MSG_CODE_1_ADDR;
              o_sub_addr     <= SUB_CODE_1_ADDR;
              o_sel_data     <= 'b01;
            end

            LINK_MGMT_ADAPTER0_REQ_ACTIVE: begin
              o_msg_addr     <= MSG_CODE_2_ADDR;
              o_sub_addr     <= SUB_CODE_2_ADDR;
              o_sel_data     <= 'b00;
            end

            LINK_MGMT_ADAPTER0_REQ_LINK_RESET: begin
              o_msg_addr     <= MSG_CODE_2_ADDR;
              o_sub_addr     <= SUB_CODE_4_ADDR;
              o_sel_data     <= 'b00;
            end

            LINK_MGMT_ADAPTER0_RSP_ACTIVE: begin
              o_msg_addr     <= MSG_CODE_3_ADDR;
              o_sub_addr     <= SUB_CODE_2_ADDR;
              o_sel_data     <= 'b00;
            end

            LINK_MGMT_ADAPTER0_RSP_LINK_RESET: begin
              o_msg_addr     <= MSG_CODE_3_ADDR;
              o_sub_addr     <= SUB_CODE_4_ADDR;
              o_sel_data     <= 'b00;
            end

            ERROR_CORRECTABLE: begin
              o_msg_addr     <= MSG_CODE_4_ADDR;
              o_sub_addr     <= SUB_CODE_1_ADDR;
              o_sel_data     <= 'b00;
            end

            ERROR_NON_FATAL: begin
              o_msg_addr     <= MSG_CODE_4_ADDR;
              o_sub_addr     <= SUB_CODE_2_ADDR;
              o_sel_data     <= 'b00;
            end

            ERROR_FATAL: begin
              o_msg_addr     <= MSG_CODE_4_ADDR;
              o_sub_addr     <= SUB_CODE_3_ADDR;
              o_sel_data     <= 'b00;
            end

            default: begin
            end
          endcase 
        end else begin
          o_op_addr      <= o_op_addr;
          o_msg_addr     <= o_msg_addr;
          o_sub_addr     <= o_sub_addr;
          o_info_addr    <= o_info_addr;
  
          o_sel_data     <= o_sel_data;
          o_ignore_data2 <= o_ignore_data2;
        end
    end
    
endmodule