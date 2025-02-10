module UCIE_ctl_SB_PATH # (
  parameter NC  =   32
)(
	//------------------------ Inputs ------------------------//
	input 							i_clk,
	input 							i_rst_n,

	//------- CNTL -------//
	// FDI Signals
 	input 	[3:0]					i_fdi_lp_state_req,
	input 							i_fdi_lp_rx_active_sts,
	input 							i_fdi_lp_linkerror,

	// RDI Signals 
 	input 	[3:0]					i_rdi_pl_state_sts,
	input							i_rdi_pl_inband_pres,
 	input	[2:0]					i_rdi_pl_speedmode,
 	input	[2:0]					i_rdi_pl_lnk_cfg,
 	input							i_rdi_pl_phyinrecenter,
	input							i_rdi_pl_error,
	input							i_rdi_pl_cerror,
	input							i_rdi_pl_nferror,
	input							i_rdi_pl_trainerror,

 	// TX Signals
 	input							i_overflow_TX,
 	input							i_overflow_RX,

	//-------- CSR -------//
	// Protocol Signals
	input							i_P_Select,
	input							i_P_Enable,
	input	[7:0]					i_P_addr,
	input	[31:0]					i_P_WDATA,
	input							i_P_WR,

	//-------- SB --------//
	// RDI Signals
	input							i_rdi_pl_cfg_crd,
	input 							i_rdi_pl_cfg_vld,
  	input 	[NC-1:0]				i_rdi_pl_cfg,


  	//------------------------ Outputs ------------------------//
	//------- CNTL -------//
	// FDI Signals
	output	[3:0]					o_fdi_pl_state_sts,
	output							o_fdi_pl_inband_pres,
	output							o_fdi_pl_rx_active_req,
 	output	[2:0]					o_fdi_pl_protocol,
 	output	[3:0]					o_fdi_pl_protocol_flitfmt,
	output							o_fdi_pl_protocol_vld,
	output	[2:0]					o_fdi_pl_speedmode,
	output	[2:0]					o_fdi_pl_lnk_cfg,
	output							o_fdi_pl_error,
	output							o_fdi_pl_cerror,
	output							o_fdi_pl_nferror,
	output							o_fdi_pl_phyinrecenter,
	output							o_fdi_pl_trainerror,

	// RDI Signals
	output	[3:0]					o_rdi_lp_state_req,
	output							o_rdi_lp_linkerror,

	//-------- CSR -------//
	// Protocol Signals
	output							o_P_Ready,
	output	[31:0]					o_P_RDATA,

	//-------- SB --------//
	// RDI Signals
	output							o_rdi_lp_cfg_crd,
	output							o_rdi_lp_cfg_vld,
	output	[NC-1:0]				o_rdi_lp_cfg,

	//-------- CSR -------//
	// PHY Signal

	output                          o_start_ucie_link_training
);


	//----------------- CNTL - SB Wires -----------------//
	wire 		w_pl_sb_busy;
	wire 		w_valid_lp_sb;
	wire 		w_valid_pl_sb;
	wire [4:0]	w_lp_sb_decode;
	wire [4:0]	w_pl_sb_decode;
	wire [31:0]	w_lp_adv_cap_val;
	wire [31:0]	w_pl_adv_cap_val;

	wire 		w_sb_src_error;
	wire 		w_sb_dst_error;
	wire 		w_sb_opcode_error;
	wire 		w_sb_unsupported_message;
	wire 		w_sb_parity_error;


	//----------------- CNTL - CSR Wires -----------------//
	wire 		w_a_wr;
	wire [7:0] 	w_a_addr;
	wire [31:0] w_a_wdata;

	wire 		w_CSR_UCIe_Link_Control_Retrain;
	wire [31:0] w_CSR_ADVCAP;




	UCIE_ctl_CNTL CNTL (
		//------------------------ Inputs ------------------------//
		// FDI Signals
		.i_fdi_lclk 					(i_clk),
		.i_rst_n 						(i_rst_n),
	 	.i_fdi_lp_state_req 			(i_fdi_lp_state_req),
		.i_fdi_lp_rx_active_sts 		(i_fdi_lp_rx_active_sts),
		.i_fdi_lp_linkerror  			(i_fdi_lp_linkerror),

		// RDI Signals 
		.i_rdi_lclk 					(i_clk),
	 	.i_rdi_pl_state_sts 			(i_rdi_pl_state_sts),
		.i_rdi_pl_inband_pres 			(i_rdi_pl_inband_pres),
	 	.i_rdi_pl_speedmode 			(i_rdi_pl_speedmode),
	 	.i_rdi_pl_lnk_cfg 				(i_rdi_pl_lnk_cfg),
	 	.i_rdi_pl_phyinrecenter 		(i_rdi_pl_phyinrecenter),
		.i_rdi_pl_error 				(i_rdi_pl_error),
		.i_rdi_pl_cerror 				(i_rdi_pl_cerror),
		.i_rdi_pl_nferror 				(i_rdi_pl_nferror),
		.i_rdi_pl_trainerror 			(i_rdi_pl_trainerror),

	 	// TX Signals
	 	.i_overflow_TX 					(i_overflow_TX),
	 	.i_overflow_RX 					(i_overflow_RX),
		

	 	//------------------------ Outputs -----------------------//
		// FDI Signals
		.o_fdi_pl_state_sts  			(o_fdi_pl_state_sts),
		.o_fdi_pl_inband_pres  			(o_fdi_pl_inband_pres),
		.o_fdi_pl_rx_active_req  		(o_fdi_pl_rx_active_req),
	 	.o_fdi_pl_protocol  			(o_fdi_pl_protocol),
	 	.o_fdi_pl_protocol_flitfmt 		(o_fdi_pl_protocol_flitfmt),
		.o_fdi_pl_protocol_vld 			(o_fdi_pl_protocol_vld),
		.o_fdi_pl_speedmode  			(o_fdi_pl_speedmode),
		.o_fdi_pl_lnk_cfg  				(o_fdi_pl_lnk_cfg),
		.o_fdi_pl_error 				(o_fdi_pl_error),
		.o_fdi_pl_cerror 				(o_fdi_pl_cerror),
		.o_fdi_pl_nferror  				(o_fdi_pl_nferror),
		.o_fdi_pl_phyinrecenter 		(o_fdi_pl_phyinrecenter),
		.o_fdi_pl_trainerror 			(o_fdi_pl_trainerror),

		// RDI Signals
		.o_rdi_lp_state_req 			(o_rdi_lp_state_req),
		.o_rdi_lp_linkerror 			(o_rdi_lp_linkerror),


	 	//--------------------- Connections ----------------------//
	 	// SB Signals
	 	.i_sb_src_error 				(i_sb_src_error),
		.i_sb_dst_error 				(i_sb_dst_error),
		.i_sb_opcode_error 				(i_sb_opcode_error),
		.i_sb_unsupported_message 		(i_sb_unsupported_message),
		.i_sb_parity_error 				(i_sb_parity_error),

	 	.i_sb_busy_flag 				(w_pl_sb_busy),
		.i_rdi_pl_sb_decode 			(w_pl_sb_decode),
		.i_valid_pl_sb 					(w_valid_pl_sb),
		.i_rdi_pl_adv_cap_val 			(w_pl_adv_cap_val),
		
		.o_rdi_lp_sb_decode 			(w_lp_sb_decode),
		.o_valid_lp_sb 					(w_valid_lp_sb),
		.o_rdi_lp_adv_cap_val 			(w_lp_adv_cap_val),

		// CSR Signals
	  	.i_CSR_UCIe_Link_Control_Retrain(w_CSR_UCIe_Link_Control_Retrain),
	 	.i_CSR_ADVCAP 					(w_CSR_ADVCAP),

		.o_a_wr 						(w_a_wr),
		.o_a_addr 						(w_a_addr),
		.o_a_wdata 						(w_a_wdata)
	);


	UCIE_ctl_CSR CSR (
		//------------------------ Inputs ------------------------//
		.i_clk 							(i_clk),
		.i_rst_n 						(i_rst_n),
		
		// Protocol Signals
		.i_P_Select 					(i_P_Select),
		.i_P_Enable 					(i_P_Enable),
		.i_P_addr 						(i_P_addr),
		.i_P_WDATA 						(i_P_WDATA),
		.i_P_WR 						(i_P_WR),
		

		//------------------------ Outputs ------------------------//
		// Protocol Signals
		.o_P_Ready 						(o_P_Ready),
		.o_P_RDATA 						(o_P_RDATA),

		//--------------------- Connections ----------------------//
		// Adapter Signals
		.i_A_Valid 						(w_a_wr),
		.i_A_addr 						(w_a_addr),
		.i_A_WDATA 						(w_a_wdata),

		.o_Advcap 						(w_CSR_ADVCAP),
		.o_retrain 						(w_CSR_UCIe_Link_Control_Retrain),
		.o_start_ucie_link_training     (o_start_ucie_link_training)
	);


	UCIE_ctl_sb_top SB (
		//------------------------ Inputs ------------------------//
		.i_clk 							(i_clk),
		.i_rst 							(i_rst_n),

		// RDI Signals
		.i_rdi_pl_cfg_crd 				(i_rdi_pl_cfg_crd),
		.i_pl_cfg_vld 					(i_rdi_pl_cfg_vld),              
	  	.i_received_data 				(i_rdi_pl_cfg),  

		//------------------------ Outputs ------------------------//
		// RDI Signals
		.o_cfg_crd 						(o_rdi_lp_cfg_crd),
	  	.o_rdi_lp_cfg_vld 				(o_rdi_lp_cfg_vld),
	  	.o_rdi_lp_cfg 					(o_rdi_lp_cfg),

		//--------------------- Connections ----------------------//
		// CNTL Signals
		.i_valid_lp_sb 					(w_valid_lp_sb),
	  	.i_rdi_lp_sb_decode 			(w_lp_sb_decode),
	  	.i_rdi_lp_adv_cap_value 		(w_lp_adv_cap_val),

	  	.o_pl_sb_busy 					(w_pl_sb_busy),
	  	.o_valid_pl_sb 					(w_valid_pl_sb),     
	 	.o_rdi_pl_sb_decode 			(w_pl_sb_decode),     
		.o_rdi_pl_adv_cap_value 		(w_pl_adv_cap_val), 
	  	.o_sb_src_error 				(w_sb_src_error), 
	  	.o_sb_dst_error 				(w_sb_dst_error),      
	  	.o_sb_opcode_error 				(w_sb_opcode_error),   
	  	.o_sb_unsupported_message 		(w_sb_unsupported_message), 
	  	.o_sb_parity_error 				(w_sb_parity_error)
	);




endmodule