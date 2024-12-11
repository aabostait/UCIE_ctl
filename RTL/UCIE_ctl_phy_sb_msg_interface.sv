module UCIE_ctl_phy_sb_msg_interface # (
  	parameter NC = 32) (

   // Clock and reset
   input  bit                     i_clk,
   input  bit                     i_rst_n,

   // Adapter (LP) Interface Inputs
   input  logic                   i_rdi_lp_cfg_crd,
   input  logic                   i_rdi_lp_cfg_valid,
   input  logic                   i_sb_data_valid,
   input  logic          [NC-1:0] i_data_received_sb,
   input  logic          [NC-1:0] i_rdi_lp_cfg,

   
   // Adapter (LP) Interface Outputs
   output logic                   o_rdi_pl_cfg_crd,
   output logic                   o_rdi_pl_cfg_vld,
   output logic                   o_sb_data_valid,
   output logic          [NC-1:0] o_rdi_pl_cfg,
   output logic          [NC-1:0] o_data_sent_sb


	);


  // State encoding
  typedef enum logic [1:0] {
    IDLE             = 2'b00,
    SB_FRM_ADAPTER   = 2'b01,
    SB_FRM_PHY       = 2'b11
  } sb_interface_states_e;


  // Internal Flags
  sb_interface_states_e r_current_state, w_next_state;
  reg r_internal_counter; // internal counter to show if the phy has credit or not
  reg [NC-1:0] r_data_received_sb; // to save the content of i_data_received_sb input
  reg [NC-1:0] r_rdi_lp_cfg; // to save the content of i_rdi_lp_cfg;

  // State machine

  // State Memory
always_ff @(posedge i_clk or negedge i_rst_n) begin 
   if(!i_rst_n) begin
      r_current_state  <= IDLE;
   end else begin
      r_current_state  <= w_next_state;
   end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin 
   if(!i_rst_n) begin
      r_internal_counter  <= 1'b1; // as we have one credit
      r_data_received_sb  <= 'b0;
      r_rdi_lp_cfg        <= 'b0;
   end else  begin
      r_data_received_sb <= i_data_received_sb;
      r_rdi_lp_cfg       <= i_rdi_lp_cfg;
      if (r_current_state == SB_FRM_PHY && !i_sb_data_valid ) begin
        r_internal_counter <= 0;
      end

      if (i_rdi_lp_cfg_crd) begin 
         r_internal_counter <= 1;
      end
   end
end

// Next state logic 
always_comb begin
   case (r_current_state)

      IDLE: begin
         if (i_rdi_lp_cfg_valid)
            w_next_state = SB_FRM_ADAPTER;

         else if (i_sb_data_valid)
            w_next_state =SB_FRM_PHY;

         else
            w_next_state = IDLE;
      end

      SB_FRM_ADAPTER:begin
            if (!i_rdi_lp_cfg_valid) 
               w_next_state = IDLE;
            else
               w_next_state = SB_FRM_ADAPTER;
      end

      SB_FRM_PHY: begin
         if(!i_sb_data_valid)
            w_next_state = IDLE;
         else
            w_next_state = SB_FRM_PHY;
      end
   endcase
end

// Output Logic

always_comb begin
          o_rdi_pl_cfg_crd   = 'b0;
          o_rdi_pl_cfg_vld  = 'b0;
          o_rdi_pl_cfg       = 'b0;
          o_data_sent_sb        = 'b0;
          o_sb_data_valid    = 'b0;


   case (r_current_state)

      IDLE: begin
          o_rdi_pl_cfg_crd   = 'b0;
          o_rdi_pl_cfg_vld  = 'b0;
          o_rdi_pl_cfg       = 'b0;
          o_data_sent_sb        = 'b0;
          o_sb_data_valid    = 'b0;
      end

      SB_FRM_ADAPTER:begin

          if (!i_rdi_lp_cfg_valid)
          o_rdi_pl_cfg_crd    = 'b1;
         else
            o_rdi_pl_cfg_crd = 'b0;

          o_rdi_pl_cfg_vld   = 'b0;
          o_rdi_pl_cfg       = 'b0;

          o_data_sent_sb        = r_rdi_lp_cfg;
          o_sb_data_valid    = 'b1;
      end

      SB_FRM_PHY:begin
          o_rdi_pl_cfg_crd   = 'b0;
          o_rdi_pl_cfg_vld   = 'b1;

          if (r_internal_counter)
          o_rdi_pl_cfg       = r_data_received_sb;
         else 
            o_rdi_pl_cfg     = 'b0;

          o_data_sent_sb        = 'b0;
          o_sb_data_valid    = 'b0;
      end
   endcase
end

endmodule