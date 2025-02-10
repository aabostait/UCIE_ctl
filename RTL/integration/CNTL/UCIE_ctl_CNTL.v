module UCIE_ctl_CNTL (
	// --------------------------------------------- Inputs ---------------------------------------------- //
	input 				i_rst_n,

	// FDI Signals
	input 				i_fdi_lclk,
	input 		[3:0] 	i_fdi_lp_state_req,
	input 				i_fdi_lp_rx_active_sts,
	input				i_fdi_lp_linkerror,

	// RDI Signals 
	input 				i_rdi_lclk,
	input 		[3:0] 	i_rdi_pl_state_sts,
	input 				i_rdi_pl_inband_pres,
	input 		[2:0] 	i_rdi_pl_speedmode,
	input 		[2:0] 	i_rdi_pl_lnk_cfg,
	input 				i_rdi_pl_phyinrecenter,
	input 				i_rdi_pl_error,
	input 				i_rdi_pl_cerror,
	input 				i_rdi_pl_nferror,
	input 				i_rdi_pl_trainerror,

	// CSR Signals
	input  			 	i_csr_UCIe_Link_Control_Retrain,
	input 		[31:0] 	i_csr_ADVCAP,

	// TX Signals
	input 				i_tx_overflow,
	input 				i_rx_overflow,


	// SB Signals
	input 				i_sb_busy_flag,
	input 				i_sb_pl_valid,
	input 		[4:0] 	i_sb_pl_decode,
	input 		[31:0] 	i_sb_pl_adv_cap_val,
	input 				i_sb_src_error,
	input 				i_sb_dst_error,
	input 				i_sb_opcode_error,
	input 				i_sb_unsupported_message,
	input 				i_sb_parity_error,

	// --------------------------------------------- Outputs ---------------------------------------------- //
	// FDI Signals	
	output 	  	[3:0] 	o_fdi_pl_state_sts,
	output 	 			o_fdi_pl_inband_pres,
	output 	 			o_fdi_pl_rx_active_req,
	output 	 	[2:0] 	o_fdi_pl_protocol,
	output 	 	[3:0] 	o_fdi_pl_protocol_flitfmt,
	output 	 			o_fdi_pl_protocol_vld,
	output 	 	[2:0]	o_fdi_pl_speedmode,
	output 	 	[2:0]	o_fdi_pl_lnk_cfg,
	output 				o_fdi_pl_error,
	output 				o_fdi_pl_cerror,
	output 				o_fdi_pl_nferror,
	output 				o_fdi_pl_phyinrecenter,
	output 				o_fdi_pl_trainerror,


	// RDI Signals 
	output 	 	[3:0] 	o_rdi_lp_state_req,
	output 	 			o_rdi_lp_linkerror,


	// SB Signals
	output 	 	[4:0]	o_sb_lp_decode,
	output 	 			o_sb_lp_valid,
	output 	 	[31:0]	o_sb_lp_adv_cap_val,

	// CSR Signals
	output 				o_csr_wr,
	output [7:0]	 	o_csr_addr,
	output [31:0] 		o_csr_wdata
);



	
	wire 		w_pl_phyinrecenter_i;
	wire 		w_pl_trainerror_i;
	wire 		w_parameter_exchange_timeout;
	wire 		w_state_status_transition_timeout;
	wire 		w_adapter_timeout;
	wire [3:0]  w_enabled_caps;





	UCIE_ctl_CNTL_FSM CNTL_FSM (
		.i_clk 									(i_fdi_lclk),
		.i_rst_n 								(i_rst_n),

		// FDI Signals
	 	.i_fdi_lp_state_req 					(i_fdi_lp_state_req),
		.i_fdi_lp_rx_active_sts 				(i_fdi_lp_rx_active_sts),
		.i_fdi_lp_linkerror 					(i_fdi_lp_linkerror),
		.i_fdi_pl_error 						(o_fdi_pl_error),
	 	
	 	.o_fdi_pl_state_sts 					(o_fdi_pl_state_sts),
		.o_fdi_pl_inband_pres 					(o_fdi_pl_inband_pres),
		.o_fdi_pl_rx_active_req 				(o_fdi_pl_rx_active_req),
	 	.o_fdi_pl_protocol 						(o_fdi_pl_protocol),
	 	.o_fdi_pl_protocol_flitfmt 				(o_fdi_pl_protocol_flitfmt),
		.o_fdi_pl_protocol_vld 					(o_fdi_pl_protocol_vld),
		.o_fdi_pl_speedmode 					(o_fdi_pl_speedmode),
		.o_fdi_pl_lnk_cfg 						(o_fdi_pl_lnk_cfg),
		.o_pl_phyinrecenter_i 					(w_pl_phyinrecenter_i),
		.o_pl_trainerror_i 						(w_pl_trainerror_i),


		// RDI Signals 	
	 	.i_rdi_pl_state_sts 					(i_rdi_pl_state_sts),
		.i_rdi_pl_inband_pres 					(i_rdi_pl_inband_pres),
	 	.i_rdi_pl_speedmode 					(i_rdi_pl_speedmode),
	 	.i_rdi_pl_lnk_cfg 						(i_rdi_pl_lnk_cfg),
	 	
		.o_rdi_lp_state_req 					(o_rdi_lp_state_req),
		.o_rdi_lp_linkerror 					(o_rdi_lp_linkerror),
		

		// CSR Signals
	  	.i_csr_UCIe_Link_Control_Retrain 		(i_csr_UCIe_Link_Control_Retrain),
	 	.i_csr_ADVCAP 							(i_csr_ADVCAP),


		// TX Signals
	 	.i_tx_overflow 							(i_tx_overflow),
	 	.i_rx_overflow 							(i_rx_overflow),


	 	// SB Signals
	 	.i_sb_src_error 						(i_sb_src_error),
		.i_sb_dst_error 						(i_sb_dst_error),
		.i_sb_opcode_error 						(i_sb_opcode_error),
		.i_sb_unsupported_message 				(i_sb_unsupported_message),
		.i_sb_parity_error 						(i_sb_parity_error),
	 	.i_sb_busy_flag 						(i_sb_busy_flag),
	 	.i_sb_pl_decode 						(i_sb_pl_decode),
		.i_sb_pl_valid 							(i_sb_pl_valid),
	 	.i_sb_pl_adv_cap_val 					(i_sb_pl_adv_cap_val),
	
	 	.o_sb_lp_decode 						(o_sb_lp_decode),
		.o_sb_lp_valid 							(o_sb_lp_valid),
		.o_sb_lp_adv_cap_val 					(o_sb_lp_adv_cap_val),


		// Logging FSM Signals
		.o_log_parameter_exchange_timeout 		(w_parameter_exchange_timeout),
		.o_log_state_status_transition_timeout 	(w_state_status_transition_timeout),
		.o_log_adapter_timeout 					(w_adapter_timeout),
		.o_log_enabled_caps                    	(w_enabled_caps)
	);


	UCIE_ctl_Logging_FSM LOG_FSM (
		.i_clk 									(i_fdi_lclk),
		.i_rst 									(i_rst_n),

		// CNTL FSM Signals
		.i_cntl_pl_state_sts 					(o_fdi_pl_state_sts),
		.i_cntl_pl_speedmode 					(o_fdi_pl_speedmode),
		.i_cntl_pl_lnk_cfg 						(o_fdi_pl_lnk_cfg),
		.i_cntl_phyinrecenter 					(w_pl_phyinrecenter_i),
		.i_cntl_invalid_parameter_exchange 		(w_pl_trainerror_i),
		.i_cntl_parameter_exchange_timeout 		(w_parameter_exchange_timeout),
		.i_cntl_state_status_transition_timeout (w_state_status_transition_timeout),
		.i_cntl_adapter_timeout 				(w_adapter_timeout),
		.i_cntl_enabled_caps                    (w_enabled_caps),

		// RDI Signals
		.i_rdi_pl_error 						(i_rdi_pl_error),
		.i_rdi_pl_cerror 						(i_rdi_pl_cerror),
		.i_rdi_pl_nferror 						(i_rdi_pl_nferror),
		.i_rdi_pl_trainerror 					(i_rdi_pl_trainerror),
		.i_rdi_pl_phyinrecenter 				(i_rdi_pl_phyinrecenter),
		
		// SB Signals
		.i_sb_pl_valid 							(i_sb_pl_valid),
		.i_sb_pl_decode 						(i_sb_pl_decode),
		.i_sb_src_error 						(i_sb_src_error),
		.i_sb_dst_error 						(i_sb_dst_error),
		.i_sb_opcode_error 						(i_sb_opcode_error),
		.i_sb_unsupported_message 				(i_sb_unsupported_message),
		.i_sb_parity_error 						(i_sb_parity_error),
		
		// TX & RX Signals
		.i_tx_over_flow 						(i_tx_overflow),
		.i_rx_over_flow 						(i_rx_overflow),

		// FDI Signals
		.o_fdi_pl_error 						(o_fdi_pl_error),
		.o_fdi_pl_cerror 						(o_fdi_pl_cerror),
		.o_fdi_pl_nferror 						(o_fdi_pl_nferror),
		.o_fdi_pl_phyinrecenter 				(o_fdi_pl_phyinrecenter),
		.o_fdi_pl_trainerror 					(o_fdi_pl_trainerror),
		
		// CSR Signals
		.o_csr_wr 								(o_csr_wr),
		.o_csr_addr 							(o_csr_addr),
		.o_csr_wdata 							(o_csr_wdata)
	);



endmodule