// ************************* Description ************************** //
//  This module is implemented to:-                                 //
//  -- generate dp and cp (data and control parities)               //
// **************************************************************** //

module UCIE_ctl_parity_generator(
    input                 i_clk,
    input                 i_rst,
    input       [31:0]    i_concat_phase0,
    input       [29:0]    i_concat_phase1,
    input       [31:0]    i_concat_phase2,
    input       [31:0]    i_concat_phase3,

    output reg            o_dp,
    output reg            o_cp
);
    reg [61 : 0] control_reg; 
    reg [63 : 0] data_reg;

    always @(*) begin
      control_reg     =     {i_concat_phase0, i_concat_phase1};
      data_reg        =     {i_concat_phase2, i_concat_phase3};
      o_dp            =     ^data_reg                         ;
      o_cp            =     ^control_reg                      ;
    end

/*
    // Input Isolation
    always @(posedge i_clk, negedge i_rst) begin
      if(!i_rst) begin
        control_reg <= 62'd0;
        data_reg    <= 64'd0;
      end else begin
        control_reg <= {i_concat_phase0, i_concat_phase1};
        data_reg    <= {i_concat_phase2, i_concat_phase3};
      end
    end

    // data parity and control parity generation
    always @(posedge i_clk, negedge i_rst) begin
      if(!i_rst) begin
        o_dp  <= 1'b0;
        o_cp  <= 1'b0;
      end else begin
        o_dp  <= ^data_reg;
        o_cp  <= ^control_reg;
      end
    end
*/
    
endmodule