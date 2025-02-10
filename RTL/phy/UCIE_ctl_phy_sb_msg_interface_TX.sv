`include "./defines.svh"
module UCIE_ctl_phy_sb_msg_interface_TX # (
  	parameter NC = `NC) (

   // Clock and reset
   input  bit                     i_clk,
   input  bit                     i_rst_n,

   // Adapter (LP) Interface Inputs
   input  logic                   i_rdi_lp_cfg_valid,
   input  logic          [NC-1:0] i_rdi_lp_cfg,

   
   // Adapter (LP) Interface Outputs
  output logic                   o_rdi_pl_cfg_crd,
   output logic                   o_sb_data_valid,
   output logic          [NC-1:0] o_data_sent_sb



	);

   logic   [NC-1:0] r_rdi_lp_cfg;


  // State encoding
  typedef enum logic [1:0] {
    IDLE             = 2'b00,
    SB_FRM_ADAPTER   = 2'b01  
  } sb_interface_states_e;


  // Internal Flags
  sb_interface_states_e r_current_state, w_next_state;

always_ff @(posedge i_clk or negedge i_rst_n) begin 
   if(!i_rst_n) begin
      r_rdi_lp_cfg        <= 'b0;
   end else  begin
      r_rdi_lp_cfg       <= i_rdi_lp_cfg;
   end
end

  // State Memory
always_ff @(posedge i_clk or negedge i_rst_n) begin 
   if(!i_rst_n) begin
      r_current_state  <= IDLE;
   end else begin
      r_current_state  <= w_next_state;
   end
end

// Next state logic 
always_comb begin
   case (r_current_state)

      IDLE: begin
         if (i_rdi_lp_cfg_valid)
            w_next_state = SB_FRM_ADAPTER;
         else
            w_next_state = IDLE;
      end

      SB_FRM_ADAPTER:begin
            if (!i_rdi_lp_cfg_valid) 
               w_next_state = IDLE;
            else
               w_next_state = SB_FRM_ADAPTER;
      end

   endcase
end

// Output Logic

always_comb begin
          o_rdi_pl_cfg_crd   = 'b0;
          o_data_sent_sb     = 'b0;
          o_sb_data_valid    = 'b0;


   case (r_current_state)

      IDLE: begin
          o_rdi_pl_cfg_crd   = 'b0;
          o_data_sent_sb        = 'b0;
          o_sb_data_valid    = 'b0;
      end

      SB_FRM_ADAPTER:begin

          if (!i_rdi_lp_cfg_valid)
          o_rdi_pl_cfg_crd    = 'b1;
         else
            o_rdi_pl_cfg_crd = 'b0;

          o_data_sent_sb     = r_rdi_lp_cfg;
          o_sb_data_valid    = 'b1;
      end

   endcase
end

endmodule