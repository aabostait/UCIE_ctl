module UCIE_ctl_phy_rx_dut_to_dut_top #(parameter NBYTES =8 , parameter NC = 32) (

  input  bit                     i_clk,
  input  bit                     i_rst_n,

  // Adapter (LP) Interface Inputs
  input  logic [3:0]             i_rdi_lp_state_req_dut_one,
  input  logic                   i_rdi_lp_linkerror_dut_one,
  input  logic                   i_rdi_lp_irdy_dut_one,
  input  logic                   i_rdi_lp_valid_dut_one,
  input  logic [(NBYTES*8)-1:0]  i_rdi_lp_data_dut_one,
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
  input  logic [(NBYTES*8)-1:0]  i_rdi_lp_data_dut_two,
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
  output logic [(NBYTES*8)-1:0]  o_rdi_pl_data_dut_one,


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
  output logic [(NBYTES*8)-1:0]  o_rdi_pl_data_dut_two,

  //outputs of RX
  output logic [(NBYTES*8)-1:0]  o_fdi_data_dut_one,
  output logic [(NBYTES*8)-1:0]  o_fdi_data_dut_two,
  output logic                   o_fdi_data_valid_dut_one,
  output logic                   o_fdi_data_valid_dut_two,
  output logic                   o_overflow_detected_dut_one,
  output logic                   o_overflow_detected_dut_two
);



	// RX DUT ONE
	UCIE_ctl_RX_TOP  #(.NBYTES(NBYTES)) DUT_ONE 
	(
	   .i_clk(i_clk),
	   .i_rst(i_rst_n),
	   .i_state_request(i_rdi_lp_state_req_dut_one),
       .i_rdi_pl_data(o_rdi_pl_data_dut_one),
       .i_rdi_pl_valid(o_rdi_pl_valid_dut_one), 
       .o_fdi_data(o_fdi_data_dut_one),
       .o_fdi_data_valid(o_fdi_data_valid_dut_one),
       .o_overflow_detected(o_overflow_detected_dut_one)
     );


	UCIE_ctl_RX_TOP  #(.NBYTES(NBYTES)) DUT_TWO 
	( 
	   .i_clk(i_clk),
	   .i_rst(i_rst_n),
	   .i_state_request(i_rdi_lp_state_req_dut_two),
       .i_rdi_pl_data(o_rdi_pl_data_dut_two),
       .i_rdi_pl_valid(o_rdi_pl_valid_dut_two), 
       .o_fdi_data(o_fdi_data_dut_two),
       .o_fdi_data_valid(o_fdi_data_valid_dut_two),
       .o_overflow_detected(o_overflow_detected_dut_two)
     );


	UCIE_ctl_phy_dut_to_dut_top # (.NBYTES(NBYTES),.NC(NC)) PHY_DUT_TO_DUT_TOP
	 (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
	      .i_rdi_lp_state_req_dut_one(i_rdi_lp_state_req_dut_one),
        .i_rdi_lp_linkerror_dut_one(i_rdi_lp_linkerror_dut_one),
        .i_rdi_lp_irdy_dut_one(i_rdi_lp_irdy_dut_one),
        .i_rdi_lp_valid_dut_one(i_rdi_lp_valid_dut_one),
        .i_rdi_lp_data_dut_one(i_rdi_lp_data_dut_one),
        .i_rdi_lp_cfg_crd_dut_one(i_rdi_lp_cfg_crd_dut_one),
        .i_rdi_lp_cfg_valid_dut_one(i_rdi_lp_cfg_valid_dut_one),
        .i_rdi_lp_cfg_dut_one(i_rdi_lp_cfg_dut_one),

         // CSR Input
        .i_start_ucie_link_training_dut_one(i_start_ucie_link_training_dut_one),

		//Test Bench Inputs 	

        .i_phy_req_trainerror_dut_one(i_phy_req_trainerror_dut_one),
        .i_phy_req_nferror_dut_one(i_phy_req_nferror_dut_one),
        .i_phy_req_cerror_dut_one(i_phy_req_cerror_dut_one),
        .i_phy_req_pl_error_dut_one(i_phy_req_pl_error_dut_one),
        .i_phy_req_data_error_dut_one(i_phy_req_data_error_dut_one),

      // Adapter (LP) Interface Inputs
        .i_rdi_lp_state_req_dut_two(i_rdi_lp_state_req_dut_two),
        .i_rdi_lp_linkerror_dut_two(i_rdi_lp_linkerror_dut_two),
        .i_rdi_lp_valid_dut_two(i_rdi_lp_valid_dut_two),
        .i_rdi_lp_data_dut_two(i_rdi_lp_data_dut_two),
        .i_rdi_lp_cfg_crd_dut_two(i_rdi_lp_cfg_crd_dut_two),
        .i_rdi_lp_cfg_valid_dut_two(i_rdi_lp_cfg_valid_dut_two),
        .i_sb_data_valid_dut_two(i_sb_data_valid_dut_two),
        .i_data_received_sb_dut_two(i_data_received_sb_dut_two),
        .i_rdi_lp_cfg_dut_two(i_rdi_lp_cfg_dut_two),
        .i_rdi_lp_irdy_dut_two(i_rdi_lp_irdy_dut_two),

  		// CSR Input
        .i_start_ucie_link_training_dut_two(i_start_ucie_link_training_dut_two),

  		//Test Bench Inputs 

        .i_phy_req_trainerror_dut_two(i_phy_req_trainerror_dut_two),
        .i_phy_req_nferror_dut_two(i_phy_req_nferror_dut_two),
        .i_phy_req_cerror_dut_two(i_phy_req_cerror_dut_two),
        .i_phy_req_pl_error_dut_two(i_phy_req_pl_error_dut_two),
        .i_phy_req_data_error_dut_two(i_phy_req_data_error_dut_two),



  		// Adapter (LP) Interface Outpus
        .o_rdi_pl_state_sts_dut_one(o_rdi_pl_state_sts_dut_one),
        .o_rdi_pl_error_dut_one(o_rdi_pl_error_dut_one),
        .o_rdi_pl_cerror_dut_one(o_rdi_pl_cerror_dut_one),
        .o_rdi_pl_nferror_dut_one(o_rdi_pl_nferror_dut_one),
        .o_rdi_pl_trainerror_dut_one(o_rdi_pl_trainerror_dut_one),
        .o_rdi_pl_phyinrecenter_dut_one(o_rdi_pl_phyinrecenter_dut_one),
        .o_rdi_pl_speedmode_dut_one(o_rdi_pl_speedmode_dut_one),
        .o_rdi_pl_lnk_cfg_dut_one(o_rdi_pl_lnk_cfg_dut_one),
        .o_rdi_pl_inband_pres_dut_one(o_rdi_pl_inband_pres_dut_one),
        .o_rdi_pl_cfg_crd_dut_one(o_rdi_pl_cfg_crd_dut_one),
        .o_rdi_pl_cfg_vld_dut_one(o_rdi_pl_cfg_vld_dut_one),
        .o_sb_data_valid_dut_one(o_sb_data_valid_dut_one),
        .o_rdi_pl_cfg_dut_one(o_rdi_pl_cfg_dut_one),
        .o_data_sent_sb_dut_one(o_data_sent_sb_dut_one),
        .o_rdi_pl_trdy_dut_one(o_rdi_pl_trdy_dut_one),
        .o_rdi_pl_valid_dut_one(o_rdi_pl_valid_dut_one),
        .o_rdi_pl_data_dut_one(o_rdi_pl_data_dut_one),


 		 // Adapter (LP) Interface Outpus
        .o_rdi_pl_state_sts_dut_two(o_rdi_pl_state_sts_dut_two),
        .o_rdi_pl_error_dut_two(o_rdi_pl_error_dut_two),
        .o_rdi_pl_cerror_dut_two(o_rdi_pl_cerror_dut_two),
        .o_rdi_pl_nferror_dut_two(o_rdi_pl_nferror_dut_two),
        .o_rdi_pl_trainerror_dut_two(o_rdi_pl_trainerror_dut_two),
        .o_rdi_pl_phyinrecenter_dut_two(o_rdi_pl_phyinrecenter_dut_two),
        .o_rdi_pl_speedmode_dut_two(o_rdi_pl_speedmode_dut_two),
        .o_rdi_pl_lnk_cfg_dut_two(o_rdi_pl_lnk_cfg_dut_two),
        .o_rdi_pl_inband_pres_dut_two(o_rdi_pl_inband_pres_dut_two),
        .o_rdi_pl_cfg_crd_dut_two(o_rdi_pl_cfg_crd_dut_two),
        .o_rdi_pl_cfg_vld_dut_two(o_rdi_pl_cfg_vld_dut_two),
        .o_rdi_pl_cfg_dut_two(o_rdi_pl_cfg_dut_two),
        .o_rdi_pl_trdy_dut_two(o_rdi_pl_trdy_dut_two),
        .o_rdi_pl_valid_dut_two(o_rdi_pl_valid_dut_two),
        .o_rdi_pl_data_dut_two(o_rdi_pl_data_dut_two)
     );
endmodule