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

  //assign o_rdi_pl_cfg_crd=1;

UCIE_ctl_phy_sb_msg_interface_TX #(.NC(NC)) TX
 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),

   // Adapter (LP) Interface Inputs
    .i_rdi_lp_cfg_valid(i_rdi_lp_cfg_valid),
    .i_rdi_lp_cfg(i_rdi_lp_cfg),

   
   // Adapter (LP) Interface Outputs
    .o_rdi_pl_cfg_crd(o_rdi_pl_cfg_crd),
    .o_sb_data_valid(o_sb_data_valid),
    .o_data_sent_sb(o_data_sent_sb)

  );

 UCIE_ctl_phy_sb_msg_interface_RX # ( .NC(NC)) RX (

   // Clock and reset
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),

   // Adapter (LP) Interface Inputs
    .i_rdi_lp_cfg_crd(i_rdi_lp_cfg_crd),
    .i_sb_data_valid(i_sb_data_valid),
    .i_data_received_sb(i_data_received_sb),

   
   // Adapter (LP) Interface Outputs
    .o_rdi_pl_cfg_vld(o_rdi_pl_cfg_vld),
    .o_rdi_pl_cfg(o_rdi_pl_cfg)


  );


endmodule