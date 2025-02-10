module  UCIE_ctl_CNTRL_SB_TOP # (
  parameter NC  =   32
)(
	// FDI signals
	//input i_fdi_lclk,
	input 				i_clk, i_rst_n,
	input 		[3:0] 	i_fdi_lp_state_req,
	input 				i_fdi_lp_rx_active_sts,
	input				i_fdi_lp_linkerror,
	input 				i_fdi_pl_error,
	output   [3:0] 	o_fdi_pl_state_sts,
	output  			o_fdi_pl_inband_pres,
	output  			o_fdi_pl_rx_active_req,
	output  	[2:0] 	o_fdi_pl_protocol,
	output  	[3:0] 	o_fdi_pl_protocol_flitfmt,
	output  			o_fdi_pl_protocol_vld,
	output  	[2:0]	o_fdi_pl_speedmode,
	output  	[2:0]	o_fdi_pl_lnk_cfg,
	output  			o_pl_phyinrecenter_i, // INTERNAL IN ADAPTER IT SELF when go to retrain state
	output  			o_pl_trainerror_i, // INTERNAL IN ADAPTER IT SELF when parameter negotiation fail


	// RDI signals 
	//input i_rdi_lclk,
	input 		[3:0] 	i_rdi_pl_state_sts,
	input 				i_rdi_pl_inband_pres,
	input 		[2:0] 	i_rdi_pl_speedmode,
	input 		[2:0] 	i_rdi_pl_lnk_cfg,

	output  	[3:0] 	o_rdi_lp_state_req,
	output  			o_rdi_lp_linkerror,



	// CSR Signals
	input  			 	i_CSR_UCIe_Link_Control_Retrain,
	input 		[31:0] 	i_CSR_ADVCAP,

	// TX Signals
	input 				i_overflow_TX,
	input 				i_overflow_RX,



	// SB Module Signals
	
  //         RX        //
  	output                o_sb_src_error, 
  	output                o_sb_dst_error,      
  	output                o_sb_opcode_error,   
  	output                o_sb_unsupported_message, 
  	output                o_sb_parity_error, 
   
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


	wire 		[4:0] 	w_rdi_pl_sb_decode;
	wire 				w_valid_pl_sb;
	wire 		[31:0] 	w_rdi_pl_adv_cap_val;

	wire  	[4:0]	w_rdi_lp_sb_decode;
	wire  			w_valid_lp_sb;
	wire  	[31:0]	w_rdi_lp_adv_cap_val;

	wire 				sb_busy_flag;



	UCIE_ctl_CNTL_FSM CTRL_DUT (

		// FDI signals

		.i_clk(i_clk), 
		.i_rst_n(i_rst_n),
	 	.i_fdi_lp_state_req(i_fdi_lp_state_req),
		.i_fdi_lp_rx_active_sts(i_fdi_lp_rx_active_sts),
		.i_fdi_lp_linkerror(i_fdi_lp_linkerror),
		.i_fdi_pl_error(i_fdi_pl_error),
	 	.o_fdi_pl_state_sts(o_fdi_pl_state_sts),
		.o_fdi_pl_inband_pres(o_fdi_pl_inband_pres),
		.o_fdi_pl_rx_active_req(o_fdi_pl_rx_active_req),
	 	.o_fdi_pl_protocol(o_fdi_pl_protocol),
	 	.o_fdi_pl_protocol_flitfmt(o_fdi_pl_protocol_flitfmt),
		.o_fdi_pl_protocol_vld(o_fdi_pl_protocol_vld),
		.o_fdi_pl_speedmode(o_fdi_pl_speedmode),
		.o_fdi_pl_lnk_cfg(o_fdi_pl_lnk_cfg),
		.o_pl_phyinrecenter_i(o_pl_phyinrecenter_i), // INTERNAL IN ADAPTER IT SELF when go to retrain state
		.o_pl_trainerror_i(o_pl_trainerror_i), // INTERNAL IN ADAPTER IT SELF when parameter negotiation fail


	// RDI signals 
	//input i_rdi_lclk,
	 	.i_rdi_pl_state_sts(i_rdi_pl_state_sts),
		.i_rdi_pl_inband_pres(i_rdi_pl_inband_pres),
	 	.i_rdi_pl_speedmode(i_rdi_pl_speedmode),
	 	.i_rdi_pl_lnk_cfg(i_rdi_pl_lnk_cfg),
	 	.i_rdi_pl_sb_decode(w_rdi_pl_sb_decode),
		.i_valid_pl_sb(w_valid_pl_sb),
	 	.i_rdi_pl_adv_cap_val(w_rdi_pl_adv_cap_val),
		.o_rdi_lp_state_req(o_rdi_lp_state_req),
		.o_rdi_lp_linkerror(o_rdi_lp_linkerror),
		.o_rdi_lp_sb_decode(w_rdi_lp_sb_decode),
		.o_valid_lp_sb(w_valid_lp_sb),
		.o_rdi_lp_adv_cap_val(w_rdi_lp_adv_cap_val),



	// CSR Signals
	  	.i_CSR_UCIe_Link_Control_Retrain(i_CSR_UCIe_Link_Control_Retrain),
	 	.i_CSR_ADVCAP(i_CSR_ADVCAP),

	// TX Signals
	 	.i_overflow_TX(i_overflow_TX),
	 	.i_overflow_RX(i_overflow_RX),
	 	.i_sb_busy_flag(sb_busy_flag)

	);


	UCIE_ctl_sb_top SB_DUT (

		.i_clk(i_clk),
        .i_rst(i_rst_n),
        .i_valid_lp_sb(w_valid_lp_sb),
        .i_rdi_lp_sb_decode(w_rdi_lp_sb_decode),
        .i_rdi_lp_adv_cap_value(w_rdi_lp_adv_cap_val),
        .o_pl_sb_busy(sb_busy_flag),
        .o_sb_src_error(o_sb_src_error), 
        .o_sb_dst_error(o_sb_dst_error),      
        .o_sb_opcode_error(o_sb_opcode_error),   
        .o_sb_unsupported_message(o_sb_unsupported_message), 
        .o_sb_parity_error(o_sb_parity_error), 
        .o_valid_pl_sb(w_valid_pl_sb),     
        .o_rdi_pl_sb_decode(w_rdi_pl_sb_decode),     
        .o_rdi_pl_adv_cap_value(w_rdi_pl_adv_cap_val),     
        .i_rdi_pl_cfg_crd(i_rdi_pl_cfg_crd),
        .o_rdi_lp_cfg_vld(o_rdi_lp_cfg_vld),
        .o_rdi_lp_cfg(o_rdi_lp_cfg),
        .i_pl_cfg_vld(i_pl_cfg_vld),              
        .i_received_data(i_received_data),           
        .o_cfg_crd(o_cfg_crd)         

		);

endmodule 