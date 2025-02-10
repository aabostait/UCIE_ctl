module UCIE_ctl_phy_rx_top #(parameter NBYTES =8 , parameter NC = 32) (
	 // Clock and reset
  input  bit                     i_clk,
  input  bit                     i_rst_n,

  // Adapter (LP) Interface Inputs
  input  logic [3:0]             i_rdi_lp_state_req,
  input  logic                   i_rdi_lp_linkerror,
  input  logic                   i_rdi_lp_irdy,
  input  logic                   i_rdi_lp_valid,
  input  logic [(NBYTES*8)-1:0]  i_rdi_lp_data,
  input  logic                   i_rdi_lp_cfg_crd,
  input  logic                   i_rdi_lp_cfg_valid,
  input  logic                   i_sb_data_valid,
  input  logic          [NC-1:0] i_data_received_sb,
  input  logic          [NC-1:0] i_rdi_lp_cfg,

  // Second DUT Inputs 
  input  logic           [3:0]   i_sb_msg_in,
  input  logic [(NBYTES*8)-1:0]  i_data_received,
  input  logic                   i_data_valid,

  // CSR Input
  input  logic                   i_start_ucie_link_training,

  //Test Bench Inputs 

  input  logic                   i_phy_req_trainerror,
  input  logic                   i_phy_req_nferror,
  input  logic                   i_phy_req_cerror,
  input  logic                   i_phy_req_pl_error,
  input  logic                   i_phy_req_data_error,


  // Adapter (LP) Interface Outpus
  output logic [3:0]             o_rdi_pl_state_sts,
  output logic                   o_rdi_pl_error,
  output logic                   o_rdi_pl_cerror,
  output logic                   o_rdi_pl_nferror,
  output logic                   o_rdi_pl_trainerror,
  output logic                   o_rdi_pl_phyinrecenter,
  output logic [2:0]             o_rdi_pl_speedmode,
  output logic [2:0]             o_rdi_pl_lnk_cfg,
  output logic                   o_rdi_pl_inband_pres,
  output logic                   o_rdi_pl_cfg_crd,
  output logic                   o_rdi_pl_cfg_vld,
  output logic                   o_sb_data_valid,
  output logic          [NC-1:0] o_rdi_pl_cfg,
  output logic          [NC-1:0] o_data_sent_sb,
  output logic                   o_rdi_pl_trdy,
  output logic                   o_rdi_pl_valid,
  output logic [(NBYTES*8)-1:0]  o_rdi_pl_data,

  // Second DUT Inputs 
  output logic             [3:0] o_sb_msg_out,
  output logic   [(NBYTES*8)-1:0]o_data_sent,
  output logic                   o_data_valid,

  //outputs of RX
  output logic [(NBYTES*8)-1:0]  o_fdi_data,
  output logic                   o_fdi_data_valid,
  output logic                   o_overflow_detected

	);





	// RX DUT ONE
	UCIE_ctl_RX_TOP  #(.NBYTES(NBYTES)) RX_DUT
	(
	   .i_clk(i_clk),
	   .i_rst(i_rst_n),
	   .i_state_request(i_rdi_lp_state_req),
       .i_rdi_pl_data(o_rdi_pl_data),
       .i_rdi_pl_valid(o_rdi_pl_valid), 
       .o_fdi_data(o_fdi_data),
       .o_fdi_data_valid(o_fdi_data_valid),
       .o_overflow_detected(o_overflow_detected)
     );




	UCIE_ctl_phy_top # (.NBYTES(NBYTES),.NC(NC)) PHY_DUT_TOP
	 (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
	    .i_rdi_lp_state_req(i_rdi_lp_state_req),
        .i_rdi_lp_linkerror(i_rdi_lp_linkerror),
        .i_rdi_lp_irdy(i_rdi_lp_irdy),
        .i_rdi_lp_valid(i_rdi_lp_valid),
        .i_rdi_lp_data(i_rdi_lp_data),
        .i_rdi_lp_cfg_crd(i_rdi_lp_cfg_crd),
        .i_rdi_lp_cfg_valid(i_rdi_lp_cfg_valid),
        .i_data_received_sb(i_data_received_sb),
        .i_sb_data_valid(i_sb_data_valid),
        .i_rdi_lp_cfg(i_rdi_lp_cfg),

         // CSR Input
        .i_start_ucie_link_training(i_start_ucie_link_training),

		//Test Bench Inputs 	

        .i_phy_req_trainerror(i_phy_req_trainerror),
        .i_phy_req_nferror(i_phy_req_nferror),
        .i_phy_req_cerror(i_phy_req_cerror),
        .i_phy_req_pl_error(i_phy_req_pl_error),
        .i_phy_req_data_error(i_phy_req_data_error),


  		// Adapter (LP) Interface Outpus
        .o_rdi_pl_state_sts(o_rdi_pl_state_sts),
        .o_rdi_pl_error(o_rdi_pl_error),
        .o_rdi_pl_cerror(o_rdi_pl_cerror),
        .o_rdi_pl_nferror(o_rdi_pl_nferror),
        .o_rdi_pl_trainerror(o_rdi_pl_trainerror),
        .o_rdi_pl_phyinrecenter(o_rdi_pl_phyinrecenter),
        .o_rdi_pl_speedmode(o_rdi_pl_speedmode),
        .o_rdi_pl_lnk_cfg(o_rdi_pl_lnk_cfg),
        .o_rdi_pl_inband_pres(o_rdi_pl_inband_pres),
        .o_rdi_pl_cfg_crd(o_rdi_pl_cfg_crd),
        .o_rdi_pl_cfg_vld(o_rdi_pl_cfg_vld),
        .o_sb_data_valid(o_sb_data_valid),
        .o_rdi_pl_cfg(o_rdi_pl_cfg),
        .o_data_sent_sb(o_data_sent_sb),
        .o_rdi_pl_trdy(o_rdi_pl_trdy),
        .o_rdi_pl_valid(o_rdi_pl_valid),
        .o_rdi_pl_data(o_rdi_pl_data),

        //Second DUT Outputd
        .o_sb_msg_out(o_sb_msg_out),
		.o_data_sent(o_data_sent),
		.o_data_valid(o_data_valid),

		// Second DUT Inputs
		.i_sb_msg_in(i_sb_msg_in),
		.i_data_received(i_data_received),
		.i_data_valid(i_data_valid)

     );
endmodule