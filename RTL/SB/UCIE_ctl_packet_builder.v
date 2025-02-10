// ************************* Description ************************** //
//  This module is implemented to:-                                 //
//  -- Connect decoded msg analyser block with RO register files    //
//  -- Integrate parity generator block                             //
//  -- implement connected advcap data buffers to analyser          //
//  -- phase build and MUXing                                       //
// **************************************************************** //
`include "./defines.svh"
module UCIE_ctl_packet_builder(
    input   wire            i_clk,
    input   wire            i_rst,
    input   wire [31:0]     i_msg_data,
    input   wire [4:0]      i_rdi_lp_sb_decode,
    input   wire            i_enable_analyser,
    input   wire [1:0]      i_buf_en,
    input   wire [1:0]      i_phase_sel,
    output  wire            o_ignore_data2,
    output  reg  [31:0]     o_phase_sent

);
    localparam OP_CODE_ADDR_WIDTH    = 1 ;
    localparam MSG_CODE_ADDR_WIDTH   = 2 ;
    localparam SUB_CODE_ADDR_WIDTH   = 2 ;
    localparam INFO_CODE_ADDR_WIDTH  = 1 ;

    localparam OP_CODE_DATA_WIDTH    = 5 ;
    localparam MSG_CODE_DATA_WIDTH   = 8 ;
    localparam SUB_CODE_DATA_WIDTH   = 8 ;
    localparam INFO_CODE_DATA_WIDTH  = 16;

    localparam        srcid          = 3'b001;
    localparam        dstid          = 3'b101;
    localparam        PADDING        = 32'd0;

    wire   [OP_CODE_ADDR_WIDTH   - 1 : 0 ]     w_op_addr  ;
    wire   [MSG_CODE_ADDR_WIDTH  - 1 : 0 ]     w_msg_addr ;
    wire   [SUB_CODE_ADDR_WIDTH  - 1 : 0 ]     w_sub_addr ;
    wire   [INFO_CODE_ADDR_WIDTH - 1 : 0 ]     w_info_addr;  
    wire   [1:0]                               w_sel_data ;

    wire   [OP_CODE_DATA_WIDTH   - 1 : 0 ]     w_op_code  ;
    wire   [MSG_CODE_DATA_WIDTH  - 1 : 0 ]     w_msg_code ;
    wire   [SUB_CODE_DATA_WIDTH  - 1 : 0 ]     w_sub_code ;
    wire   [INFO_CODE_DATA_WIDTH - 1 : 0 ]     w_info_code;

    reg   [31:0]                              r_concat_phase0     ;
    reg   [29:0]                              r_temp_concat_phase1;
    reg   [31:0]                              r_concat_phase1     ;
    reg   [31:0]                              r_concat_phase2     ;
    reg   [31:0]                              r_concat_phase3     ;

    wire                                       w_dp;
    wire                                       w_cp;

    reg    [31:0]                              r_data_reg_1;
    reg    [31:0]                              r_data_reg_2;



    //INSTANTIATING MODULES
    UCIE_ctl_sb_decoded_msg_analyser 
      decoded_inst(
        .i_clk                (i_clk              ),
        .i_rst                (i_rst              ),
        .i_rdi_lp_sb_decode   (i_rdi_lp_sb_decode ),
        .i_enable             (i_enable_analyser  ),
        .o_op_addr            (w_op_addr          ),
        .o_msg_addr           (w_msg_addr         ),
        .o_sub_addr           (w_sub_addr         ),
        .o_info_addr          (w_info_addr        ),
        .o_sel_data           (w_sel_data         ),
        .o_ignore_data2       (o_ignore_data2     )
      );

    UCIE_ctl_sb_reg_files
      reg_file_inst(
        .i_clk                (i_clk              ),
        .i_rst                (i_rst              ),
        .i_op_addr            (w_op_addr          ),
        .i_msg_addr           (w_msg_addr         ),
        .i_sub_addr           (w_sub_addr         ),
        .i_info_addr          (w_info_addr        ),
        .o_op_code            (w_op_code          ),
        .o_msg_code           (w_msg_code         ),
        .o_sub_code           (w_sub_code         ),
        .o_info_code          (w_info_code        )  
      );
        
    UCIE_ctl_parity_generator
      parity_generator_inst(
        .i_clk                (i_clk                ),
        .i_rst                (i_rst                ),
        .i_concat_phase0      (r_concat_phase0      ),
        .i_concat_phase1      (r_temp_concat_phase1 ),
        .i_concat_phase2      (r_concat_phase2      ),
        .i_concat_phase3      (r_concat_phase3      ),
        .o_dp                 (w_dp                 ),
        .o_cp                 (w_cp                 )
      ); 

      //DATA Buffers
      always @(posedge i_clk, negedge i_rst) begin
        if(!i_rst) begin
          r_data_reg_1 <= 0;
        end else if(i_buf_en[0]) begin
          r_data_reg_1 <= i_msg_data;
        end
      end

     always @(posedge i_clk, negedge i_rst) begin
        if(!i_rst) begin
          r_data_reg_2 <= 0;
        end else if(i_buf_en[1]) begin
          r_data_reg_2 <= i_msg_data;
        end
      end

      //PHASE CONCATINATION
      always @(*) begin
        r_concat_phase0      = {srcid, PADDING[6:0], w_msg_code, PADDING[8:0], w_op_code};
        r_temp_concat_phase1 = {PADDING[2:0], dstid, w_info_code, w_sub_code            };    
        r_concat_phase1      = {w_dp, w_cp, r_temp_concat_phase1                        };
        r_concat_phase2      = (w_sel_data[0])? r_data_reg_1 : PADDING                   ;
        r_concat_phase3      = (w_sel_data[1])? r_data_reg_2 : PADDING                   ;
      end

      // PHASE MUXING
      always @(*) begin
        case (i_phase_sel)
          'd0 : begin
            o_phase_sent = r_concat_phase0;
          end
          'd1 : begin
            o_phase_sent = r_concat_phase1;
          end
          'd2 : begin
            o_phase_sent = r_concat_phase2;
          end
          'd3 : begin
            o_phase_sent = r_concat_phase3;
          end
        endcase
      end

      


    
endmodule
