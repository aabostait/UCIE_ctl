// ************************* Description ************************** //
//  This module is implemented to:-                                 //
//  -- save msg code parts in a RO registers                        //
// **************************************************************** //
`include "./defines.svh"
module UCIE_ctl_sb_reg_files(
    //  INPUTS
    input                                       i_clk,
    input                                       i_rst,
    input        				i_op_addr,
    input  	[1 : 0 ]    			i_msg_addr,
    input   	[1 : 0 ]     			i_sub_addr,
    input   				        i_info_addr,
    //OUTPUTS
    output 	[4 : 0 ]     			o_op_code,
    output 	[7 : 0 ]     			o_msg_code,
    output 	[7 : 0 ]     			o_sub_code,
    output 	[15 : 0]     			o_info_code
);

    parameter OP_CODE_ADDR_WIDTH    = 1 ;
    localparam MSG_CODE_ADDR_WIDTH   = 2 ;
    localparam SUB_CODE_ADDR_WIDTH   = 2 ;
    localparam INFO_CODE_ADDR_WIDTH  = 1 ;

    localparam OP_CODE_DATA_WIDTH    = 5 ;
    localparam MSG_CODE_DATA_WIDTH   = 8 ;
    localparam SUB_CODE_DATA_WIDTH   = 8 ;
    localparam INFO_CODE_DATA_WIDTH  = 16;

    localparam OP_CODE_DEPTH    = 2;
    localparam MSG_CODE_DEPTH   = 4;
    localparam SUB_CODE_DEPTH   = 4;
    localparam INFO_CODE_DEPTH  = 1;

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

    localparam OP_CODE_1        = 5'b10010; // Message without data
    localparam OP_CODE_2        = 5'b11011; // Message with data

    localparam MSG_CODE_1       = 8'h01;
    localparam MSG_CODE_2       = 8'h03;
    localparam MSG_CODE_3       = 8'h04;
    localparam MSG_CODE_4       = 8'h09;

    localparam SUB_CODE_1       = 8'h00;
    localparam SUB_CODE_2       = 8'h01;
    localparam SUB_CODE_3       = 8'h02;
    localparam SUB_CODE_4       = 8'h09;

    localparam INFO_CODE_1      = 16'h0000;

    

    reg [OP_CODE_DATA_WIDTH - 1 : 0] r_op_reg_file [OP_CODE_DEPTH - 1 : 0];   
    reg [MSG_CODE_DATA_WIDTH - 1 : 0] r_msg_reg_file [MSG_CODE_DEPTH - 1 : 0];   
    reg [SUB_CODE_DATA_WIDTH - 1 : 0] r_sub_reg_file [SUB_CODE_DEPTH - 1 : 0];   
    reg [INFO_CODE_DATA_WIDTH - 1 : 0] r_info_reg_file [INFO_CODE_DEPTH - 1 : 0];   


    // OPCODE REGFILE
    always @(posedge i_clk, negedge i_rst) begin
      if (!i_rst) begin
        r_op_reg_file [OP_CODE_1_ADDR] <= OP_CODE_1;
        r_op_reg_file [OP_CODE_2_ADDR] <= OP_CODE_2;
      end
    end
    assign o_op_code = r_op_reg_file [i_op_addr];


    // MSGCODE REGFILE
    always @(posedge i_clk, negedge i_rst) begin
	   if (!i_rst) begin
        r_msg_reg_file  [MSG_CODE_1_ADDR] <= MSG_CODE_1;
        r_msg_reg_file  [MSG_CODE_2_ADDR] <= MSG_CODE_2;
        r_msg_reg_file  [MSG_CODE_3_ADDR] <= MSG_CODE_3;
        r_msg_reg_file  [MSG_CODE_4_ADDR] <= MSG_CODE_4;
		end
    end
    assign o_msg_code = r_msg_reg_file [i_msg_addr];


    // SUBCODE REGFILE
    always @(posedge i_clk, negedge i_rst) begin
	   if (!i_rst) begin
        r_sub_reg_file  [SUB_CODE_1_ADDR] <= SUB_CODE_1;
        r_sub_reg_file  [SUB_CODE_2_ADDR] <= SUB_CODE_2;
        r_sub_reg_file  [SUB_CODE_3_ADDR] <= SUB_CODE_3;
        r_sub_reg_file  [SUB_CODE_4_ADDR] <= SUB_CODE_4;
		end
    end
    assign o_sub_code = r_sub_reg_file [i_sub_addr];


    //INFO CODE REGFILE
    always @(posedge i_clk, negedge i_rst) begin
	   if(!i_rst) begin
        r_info_reg_file  [INFO_CODE_1_ADDR] <= INFO_CODE_1;
		end
    end
    assign o_info_code = r_info_reg_file [i_info_addr];

endmodule