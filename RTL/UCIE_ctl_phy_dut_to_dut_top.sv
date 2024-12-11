module UCIE_ctl_phy_dut_to_dut_top # (
    parameter NBYTES = 32 , parameter NC = 32) 
 (
 // Clock and reset
  input  bit                     i_clk,
  input  bit                     i_rst_n,

  // Adapter (LP) Interface Inputs
  input  logic [3:0]             i_rdi_lp_state_req_dut_one,
  input  logic                   i_rdi_lp_linkerror_dut_one,
  input  logic                   i_rdi_lp_irdy_dut_one,
  input  logic                   i_rdi_lp_valid_dut_one,
  input  logic [NBYTES-1:0][7:0] i_rdi_lp_data_dut_one,
  input  logic                   i_rdi_lp_cfg_crd_dut_one,
  input  logic                   i_rdi_lp_cfg_valid_dut_one,
  input  logic          [NC-1:0] i_rdi_lp_cfg_dut_one,

  // CSR Input
  input  logic                   i_start_ucie_link_training_dut_one,

  //Test Bench Inputs 

  input  logic                   i_phy_req_trainerror_dut_one,
  input  logic                   i_phy_req_nferror_dut_one,
  input  logic                   i_phy_req_cerror_dut_one,
  input  logic                   i_phy_req_pl_error_dut_one,
  input  logic                   i_phy_req_data_error_dut_one,

      // Adapter (LP) Interface Inputs
  input  logic [3:0]             i_rdi_lp_state_req_dut_two,
  input  logic                   i_rdi_lp_linkerror_dut_two,
  input  logic                   i_rdi_lp_irdy_dut_two,
  input  logic                   i_rdi_lp_valid_dut_two,
  input  logic [NBYTES-1:0][7:0] i_rdi_lp_data_dut_two,
  input  logic                   i_rdi_lp_cfg_crd_dut_two,
  input  logic                   i_rdi_lp_cfg_valid_dut_two,
  input  logic                   i_sb_data_valid_dut_two,
  input  logic          [NC-1:0] i_data_received_sb_dut_two,
  input  logic          [NC-1:0] i_rdi_lp_cfg_dut_two,


  // CSR Input
  input  logic                   i_start_ucie_link_training_dut_two,

  //Test Bench Inputs 

  input  logic                   i_phy_req_trainerror_dut_two,
  input  logic                   i_phy_req_nferror_dut_two,
  input  logic                   i_phy_req_cerror_dut_two,
  input  logic                   i_phy_req_pl_error_dut_two,
  input  logic                   i_phy_req_data_error_dut_two,



  // Adapter (LP) Interface Outpus
  output logic [3:0]             o_rdi_pl_state_sts_dut_one,
  output logic                   o_rdi_pl_error_dut_one,
  output logic                   o_rdi_pl_cerror_dut_one,
  output logic                   o_rdi_pl_nferror_dut_one,
  output logic                   o_rdi_pl_trainerror_dut_one,
  output logic                   o_rdi_pl_phyinrecenter_dut_one,
  output logic [2:0]             o_rdi_pl_speedmode_dut_one,
  output logic [2:0]             o_rdi_pl_lnk_cfg_dut_one,
  output logic                   o_rdi_pl_inband_pres_dut_one,
  output logic                   o_rdi_pl_cfg_crd_dut_one,
  output logic                   o_rdi_pl_cfg_vld_dut_one,
  output logic                   o_sb_data_valid_dut_one,
  output logic          [NC-1:0] o_rdi_pl_cfg_dut_one,
  output logic          [NC-1:0] o_data_sent_sb_dut_one,
  output logic                   o_rdi_pl_trdy_dut_one,
  output logic                   o_rdi_pl_valid_dut_one,
  output logic [NBYTES-1:0][7:0] o_rdi_pl_data_dut_one,


  // Adapter (LP) Interface Outpus
  output logic [3:0]             o_rdi_pl_state_sts_dut_two,
  output logic                   o_rdi_pl_error_dut_two,
  output logic                   o_rdi_pl_cerror_dut_two,
  output logic                   o_rdi_pl_nferror_dut_two,
  output logic                   o_rdi_pl_trainerror_dut_two,
  output logic                   o_rdi_pl_phyinrecenter_dut_two,
  output logic [2:0]             o_rdi_pl_speedmode_dut_two,
  output logic [2:0]             o_rdi_pl_lnk_cfg_dut_two,
  output logic                   o_rdi_pl_inband_pres_dut_two,
  output logic                   o_rdi_pl_cfg_crd_dut_two,
  output logic                   o_rdi_pl_cfg_vld_dut_two,
  output logic          [NC-1:0] o_rdi_pl_cfg_dut_two,
  output logic                   o_rdi_pl_trdy_dut_two,
  output logic                   o_rdi_pl_valid_dut_two,
  output logic [NBYTES-1:0][7:0] o_rdi_pl_data_dut_two

	
);


  // Second DUT Inputs 
  logic           [3:0]   sb_msg_dut_one;
  logic [NBYTES-1:0][7:0] data_transfer_one;
  logic                   data_valid_dut_one;

  logic [3:0]             sb_msg_dut_two;
  logic [NBYTES-1:0][7:0] data_transfer_two;
  logic                   data_valid_dut_two;

  logic                   sb_data_valid_dut_one;
  logic          [NC-1:0] data_transfer_sb_dut_one;

  logic                   sb_data_valid_dut_two;
  logic          [NC-1:0] data_transfer_sb_dut_two;


// Instantiaition

UCIE_ctl_fsm_phy_top # (
     .NBYTES(NBYTES) , .NC(NC)) phy_top_DUT1

 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_rdi_lp_state_req(i_rdi_lp_state_req_dut_one),
    .i_rdi_lp_linkerror(i_rdi_lp_linkerror_dut_one),
    .i_sb_msg_in(sb_msg_dut_two),
    .i_start_ucie_link_training(i_start_ucie_link_training_dut_one),
    .i_phy_req_trainerror(i_phy_req_trainerror_dut_one),
    .i_phy_req_nferror(i_phy_req_nferror_dut_one),
    .i_phy_req_cerror(i_phy_req_cerror_dut_one),
    .i_phy_req_pl_error(i_phy_req_pl_error_dut_one),
    .o_rdi_pl_state_sts(o_rdi_pl_state_sts_dut_one),
    .o_rdi_pl_error(o_rdi_pl_error_dut_one),
    .o_rdi_pl_cerror(o_rdi_pl_cerror_dut_one),
    .o_rdi_pl_nferror(o_rdi_pl_nferror_dut_one),
    .o_rdi_pl_trainerror(o_rdi_pl_trainerror_dut_one),
    .o_rdi_pl_phyinrecenter(o_rdi_pl_phyinrecenter_dut_one),
    .o_rdi_pl_speedmode(o_rdi_pl_speedmode_dut_one),
    .o_rdi_pl_lnk_cfg(o_rdi_pl_lnk_cfg_dut_one),
    .o_rdi_pl_inband_pres(o_rdi_pl_inband_pres_dut_one),
    .o_sb_msg_out(sb_msg_dut_one),
    .i_rdi_lp_irdy(i_rdi_lp_irdy_dut_one),
    .i_rdi_lp_valid(i_rdi_lp_valid_dut_one),
    .i_rdi_lp_data(i_rdi_lp_data_dut_one),
    .i_data_received(data_transfer_two),
    .i_data_valid(data_valid_dut_two),
    .i_phy_req_data_error(i_phy_req_data_error_dut_one),
    .o_rdi_pl_valid(o_rdi_pl_valid_dut_one),
    .o_data_sent(data_transfer_one),
    .o_data_valid(data_valid_dut_one),
    .i_rdi_lp_cfg_crd(i_rdi_lp_cfg_crd_dut_one),
    .i_rdi_lp_cfg_valid(i_rdi_lp_cfg_valid_dut_one),
    .i_sb_data_valid(sb_data_valid_dut_two),
    .i_data_received_sb(data_transfer_sb_dut_two),
    .i_rdi_lp_cfg(i_rdi_lp_cfg_dut_one),
    .o_rdi_pl_cfg_crd(o_rdi_pl_cfg_crd_dut_one),
    .o_rdi_pl_cfg_vld(o_rdi_pl_cfg_vld_dut_one),
    .o_sb_data_valid(sb_data_valid_dut_one),
    .o_rdi_pl_cfg(o_rdi_pl_cfg_dut_one),
    .o_data_sent_sb(data_transfer_sb_dut_one),
    .o_rdi_pl_trdy(o_rdi_pl_trdy_dut_one),
    .o_rdi_pl_data(o_rdi_pl_data_dut_one)
  
);

   UCIE_ctl_fsm_phy_top # (
     .NBYTES(NBYTES),  .NC(NC)) phy_top_DUT2

 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_rdi_lp_state_req(i_rdi_lp_state_req_dut_two),
    .i_rdi_lp_linkerror(i_rdi_lp_linkerror_dut_two),
    .i_sb_msg_in(sb_msg_dut_one),
    .i_start_ucie_link_training(i_start_ucie_link_training_dut_two),
    .i_phy_req_trainerror(i_phy_req_trainerror_dut_two),
    .i_phy_req_nferror(i_phy_req_nferror_dut_two),
    .i_phy_req_cerror(i_phy_req_cerror_dut_two),
    .i_phy_req_pl_error(i_phy_req_pl_error_dut_two),
    .o_rdi_pl_state_sts(o_rdi_pl_state_sts_dut_two),
    .o_rdi_pl_error(o_rdi_pl_error_dut_two),
    .o_rdi_pl_cerror(o_rdi_pl_cerror_dut_two),
    .o_rdi_pl_nferror(o_rdi_pl_nferror_dut_two),
    .o_rdi_pl_trainerror(o_rdi_pl_trainerror_dut_two),
    .o_rdi_pl_phyinrecenter(o_rdi_pl_phyinrecenter_dut_two),
    .o_rdi_pl_speedmode(o_rdi_pl_speedmode_dut_two),
    .o_rdi_pl_lnk_cfg(o_rdi_pl_lnk_cfg_dut_two),
    .o_rdi_pl_inband_pres(o_rdi_pl_inband_pres_dut_two),
    .o_sb_msg_out(sb_msg_dut_two),
    .i_rdi_lp_irdy(i_rdi_lp_irdy_dut_two),
    .i_rdi_lp_valid(i_rdi_lp_valid_dut_two),
    .i_rdi_lp_data(i_rdi_lp_data_dut_two),
    .i_data_received(data_transfer_one),
    .i_data_valid(data_valid_dut_one),
    .i_phy_req_data_error(i_phy_req_data_error_dut_two),
    .o_rdi_pl_valid(o_rdi_pl_valid_dut_two),
    .o_data_sent(data_transfer_two),
    .o_data_valid(data_valid_dut_two),
    .i_rdi_lp_cfg_crd(i_rdi_lp_cfg_crd_dut_two),
    .i_rdi_lp_cfg_valid(i_rdi_lp_cfg_valid_dut_two),
    .i_sb_data_valid(sb_data_valid_dut_one),
    .i_data_received_sb(data_transfer_sb_dut_one),
    .i_rdi_lp_cfg(i_rdi_lp_cfg_dut_two),
    .o_rdi_pl_cfg_crd(o_rdi_pl_cfg_crd_dut_two),
    .o_rdi_pl_cfg_vld(o_rdi_pl_cfg_vld_dut_two),
    .o_sb_data_valid(o_sb_data_valid_dut_two),
    .o_rdi_pl_cfg(o_rdi_pl_cfg_dut_two),
    .o_data_sent_sb(data_transfer_sb_dut_two),
    .o_rdi_pl_trdy(o_rdi_pl_trdy_dut_two),
    .o_rdi_pl_data(o_rdi_pl_data_dut_two)
  
);

endmodule : UCIE_ctl_phy_dut_to_dut_top