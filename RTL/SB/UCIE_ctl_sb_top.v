// ************************* Description *********************** //
//  This module is implemented to:-                              //
//  -- Wrap up the SB_tx and SB_rx in a top SB module            //
// ************************************************************* //

module UCIE_ctl_sb_top # (
  parameter NC  =   32
)(
// ------------------------------------------------ Global domains
  input             i_clk,
  input             i_rst,
//------------------------------------------------ CTL interface
  //         TX        //
  input                 i_valid_lp_sb,
  input  [4:0 ]         i_rdi_lp_sb_decode,
  input  [31:0]         i_rdi_lp_adv_cap_value,
  output                o_pl_sb_busy,
  //         RX        //
  output                o_sb_src_error, 
  output                o_sb_dst_error,      
  output                o_sb_opcode_error,   
  output                o_sb_unsupported_message, 
  output                o_sb_parity_error, 
  output                o_valid_pl_sb,     
  output [4:0 ]         o_rdi_pl_sb_decode,     
  output [31:0]         o_rdi_pl_adv_cap_value,     
//------------------------------------------------- RDI interface
  //         TX        //
  input                 i_rdi_pl_cfg_crd,
  output                o_rdi_lp_cfg_vld,
  output [NC-1:0]       o_rdi_lp_cfg,
  //         RX        //
  input                 i_pl_cfg_vld,              
  input  [NC-1:0]       i_received_data,           
  output                o_cfg_crd         
);


// SB_TX instantiation 
UCIE_ctl_sb_tx_top # (
  .NC (NC)
) sb_tx_inst (
  .i_clk                     (i_clk                     ),
  .i_rst                     (i_rst                     ),
  .i_valid_lp_sb             (i_valid_lp_sb             ),
  .i_rdi_lp_sb_decode        (i_rdi_lp_sb_decode        ),
  .i_rdi_lp_adv_cap_value    (i_rdi_lp_adv_cap_value    ),
  .i_rdi_pl_cfg_crd          (i_rdi_pl_cfg_crd          ),
  .o_pl_sb_busy              (o_pl_sb_busy              ),
  .o_rdi_lp_cfg_vld          (o_rdi_lp_cfg_vld          ),
  .o_rdi_lp_cfg              (o_rdi_lp_cfg              )
);

// SB_RX instantiation 
UCIE_ctl_sb_rx #(
  .N (NC)
) sb_rx_inst (
  .i_clk                     (i_clk                     ),
  .i_rst                     (i_rst                     ),
  .i_pl_cfg_vld              (i_pl_cfg_vld              ),
  .i_received_data           (i_received_data           ),
  .o_cfg_crd                 (o_cfg_crd                 ),
  .o_sb_src_error            (o_sb_src_error            ),
  .o_sb_dst_error            (o_sb_dst_error            ),
  .o_sb_opcode_error         (o_sb_opcode_error         ),
  .o_sb_unsupported_message  (o_sb_unsupported_message  ),
  .o_sb_parity_error         (o_sb_parity_error         ),
  .o_valid_pl_sb             (o_valid_pl_sb             ),
  .o_rdi_pl_sb_decode        (o_rdi_pl_sb_decode        ),
  .o_rdi_pl_adv_cap_value    (o_rdi_pl_adv_cap_value    )
);

endmodule
