module UCIE_ctl_CNTL (

	///////////////////////////////////////////////// CNTL FSM Signals /////////////////////////////////////////////////
	// FDI signals
	input 				i_fdi_lclk,
	input 				i_rst_n,
	input 		[3:0] 	i_fdi_lp_state_req,
	input 				i_fdi_lp_rx_active_sts,
	input				i_fdi_lp_linkerror,
	output 	  	[3:0] 	o_fdi_pl_state_sts,
	output 	 			o_fdi_pl_inband_pres,
	output 	 			o_fdi_pl_rx_active_req,
	output 	 	[2:0] 	o_fdi_pl_protocol,
	output 	 	[3:0] 	o_fdi_pl_protocol_flitfmt,
	output 	 			o_fdi_pl_protocol_vld,
	output 	 	[2:0]	o_fdi_pl_speedmode,
	output 	 	[2:0]	o_fdi_pl_lnk_cfg,


	// RDI signals 
	input 				i_rdi_lclk,
	input 		[3:0] 	i_rdi_pl_state_sts,
	input 				i_rdi_pl_inband_pres,
	input 		[2:0] 	i_rdi_pl_speedmode,
	input 		[2:0] 	i_rdi_pl_lnk_cfg,
	input 		[4:0] 	i_rdi_pl_sb_decode,
	input 				i_valid_pl_sb,
	input 		[31:0] 	i_rdi_pl_adv_cap_val,
	output 	 	[3:0] 	o_rdi_lp_state_req,
	output 	 			o_rdi_lp_linkerror,
	output 	 	[4:0]	o_rdi_lp_sb_decode,
	output 	 			o_valid_lp_sb,
	output 	 	[31:0]	o_rdi_lp_adv_cap_val,



	// CSR Signals
	input  			 	i_CSR_UCIe_Link_Control_Retrain,
	input 		[31:0] 	i_CSR_ADVCAP,

	// TX Signals
	input 				i_overflow_TX,
	input 				i_overflow_RX,


	// SB Module Signals
	input 				i_sb_busy_flag,


	///////////////////////////////////////////////// Logging FSM Signals /////////////////////////////////////////////////
	// Inputs
	input i_rdi_pl_phyinrecenter,
	input i_rdi_pl_error,
	input i_rdi_pl_cerror,
	input i_sb_src_error,
	input i_sb_dst_error,
	input i_sb_opcode_error,
	input i_sb_unsupported_message,
	input i_sb_parity_error,
	input i_rdi_pl_nferror,
	input i_rdi_pl_trainerror,


	// Outputs
	output o_fdi_pl_error,
	output o_fdi_pl_cerror,
	output o_fdi_pl_nferror,
	output o_fdi_pl_phyinrecenter,
	output o_fdi_pl_trainerror,
	output o_a_wr,
	output [7:0] o_a_addr,
	output [31:0] o_a_wdata
);



	
	wire w_pl_phyinrecenter_i;
	wire w_pl_trainerror_i;





	UCIE_ctl_CNTL_FSM CNTL_FSM (
		// FDI signals

		.i_clk(i_fdi_lclk), 
		.i_rst_n(i_rst_n),
	 	.i_fdi_lp_state_req(i_fdi_lp_state_req),
		.i_fdi_lp_rx_active_sts(i_fdi_lp_rx_active_sts),
		.i_fdi_lp_linkerror(i_fdi_lp_linkerror),
		.i_fdi_pl_error(o_fdi_pl_error),
	 	.o_fdi_pl_state_sts(o_fdi_pl_state_sts),
		.o_fdi_pl_inband_pres(o_fdi_pl_inband_pres),
		.o_fdi_pl_rx_active_req(o_fdi_pl_rx_active_req),
	 	.o_fdi_pl_protocol(o_fdi_pl_protocol),
	 	.o_fdi_pl_protocol_flitfmt(o_fdi_pl_protocol_flitfmt),
		.o_fdi_pl_protocol_vld(o_fdi_pl_protocol_vld),
		.o_fdi_pl_speedmode(o_fdi_pl_speedmode),
		.o_fdi_pl_lnk_cfg(o_fdi_pl_lnk_cfg),
		.o_pl_phyinrecenter_i(w_pl_phyinrecenter_i),
		.o_pl_trainerror_i(w_pl_trainerror_i),


		// RDI signals 
	 	.i_rdi_pl_state_sts(i_rdi_pl_state_sts),
		.i_rdi_pl_inband_pres(i_rdi_pl_inband_pres),
	 	.i_rdi_pl_speedmode(i_rdi_pl_speedmode),
	 	.i_rdi_pl_lnk_cfg(i_rdi_pl_lnk_cfg),
	 	.i_rdi_pl_sb_decode(i_rdi_pl_sb_decode),
		.i_valid_pl_sb(i_valid_pl_sb),
	 	.i_rdi_pl_adv_cap_val(i_rdi_pl_adv_cap_val),
		.o_rdi_lp_state_req(o_rdi_lp_state_req),
		.o_rdi_lp_linkerror(o_rdi_lp_linkerror),
		.o_rdi_lp_sb_decode(o_rdi_lp_sb_decode),
		.o_valid_lp_sb(o_valid_lp_sb),
		.o_rdi_lp_adv_cap_val(o_rdi_lp_adv_cap_val),


		// CSR Signals
	  	.i_CSR_UCIe_Link_Control_Retrain(i_CSR_UCIe_Link_Control_Retrain),
	 	.i_CSR_ADVCAP(i_CSR_ADVCAP),

		// TX Signals
	 	.i_overflow_TX(i_overflow_TX),
	 	.i_overflow_RX(i_overflow_RX),
	 	.i_sb_busy_flag(i_sb_busy_flag)
	);


	UCIE_ctl_Logging_FSM LOG_FSM (
		.i_clk(i_fdi_lclk),
		.i_rst(i_rst_n),
		.i_fdi_pl_state_sts(o_fdi_pl_state_sts),
		.i_rdi_pl_speedmode(i_rdi_pl_speedmode),			///////////////
		.i_rdi_pl_lnk_cfg(i_rdi_pl_lnk_cfg),				///////////////
		.i_rdi_pl_phyinrecenter(i_rdi_pl_phyinrecenter),
		.i_pl_phyinrecenter_i(w_pl_phyinrecenter_i),
		.i_rdi_pl_error(i_rdi_pl_error),
		.i_rdi_pl_cerror(i_rdi_pl_cerror),
		.i_valid_pl_sb(i_valid_pl_sb),
		.i_rdi_pl_sb_decode(i_rdi_pl_sb_decode),
		.i_sb_src_error(i_sb_src_error),
		.i_sb_dst_error(i_sb_dst_error),
		.i_sb_opcode_error(i_sb_opcode_error),
		.i_sb_unsupported_message(i_sb_unsupported_message),
		.i_sb_parity_error(i_sb_parity_error),
		.i_rdi_pl_nferror(i_rdi_pl_nferror),
		.i_pl_trainerror_i(w_pl_trainerror_i),
		.i_rdi_pl_trainerror(i_rdi_pl_trainerror),
		.i_parameter_exchange_timeout(1'b0),    			//////////////////
		.i_state_status_transition_timeout(1'b0),			//////////////////	
		.i_adapter_timeout(1'b0),							//////////////////
		.i_tx_over_flow(i_overflow_TX),
		.i_rx_over_flow(i_overflow_RX),

		// Outputs
		.o_fdi_pl_error(o_fdi_pl_error),
		.o_fdi_pl_cerror(o_fdi_pl_cerror),
		.o_fdi_pl_nferror(o_fdi_pl_nferror),
		.o_fdi_pl_phyinrecenter(o_fdi_pl_phyinrecenter),
		.o_fdi_pl_trainerror(o_fdi_pl_trainerror),
		.o_a_wr(o_a_wr),
		.o_a_addr(o_a_addr),
		.o_a_wdata(o_a_wdata)
	);



endmodule