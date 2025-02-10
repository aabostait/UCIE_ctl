`include "./defines.svh"
module UCIE_ctl_TOP #  (
	parameter 	  NBYTES 		= `NBYTES  , 
	parameter 	  NC 			= `NC ,
	parameter     UCIE_ACTIVE 	= 1  ,                           
  	parameter     DATA_WIDTH_TX = `TX_WIDTH ,
  	parameter     FIFO_DEPTH_TX = `TX_DEPTH    

  	)

	(
	//------------------------ Inputs ------------------------//
	input 							i_clk,
	input 							i_rst_n,

	//------- CNTL -------//
	// FDI Signals
 	input 	[3:0]					i_fdi_lp_state_req,
	input 							i_fdi_lp_rx_active_sts,
	input 							i_fdi_lp_linkerror,
	input 							i_fdi_lp_irdy,
	input   [(NBYTES*8)-1:0]        i_fdi_lp_data,
	input 							i_fdi_lp_valid,

	//-------- CSR -------//
	// Protocol Signals
	input							i_P_Select,
	input							i_P_Enable,
	input	[7:0]					i_P_addr,
	input	[31:0]					i_P_WDATA,
	input							i_P_WR,

	//-------- PHY Model -------//
  	//Test Bench Inputs 

  	input                     	 	i_phy_req_trainerror,
  	input                    		i_phy_req_nferror,
  	input                    		i_phy_req_cerror,
  	input                     		i_phy_req_pl_error,
  	input                     		i_phy_req_data_error,

  	// Second DUT Inputs 
    input   [3:0]					i_sb_msg_in,
    input   [(NBYTES*8)-1:0]		i_data_received,
    input    						i_data_valid,
    input  		                    i_sb_data_valid,
    input   [NC-1:0] 				i_data_received_sb,
    input 							i_training_start_notification_in,


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
	output 							o_fdi_pl_trdy,
	output [(NBYTES*8)-1:0]			o_fdi_pl_data,
    output 							o_fdi_pl_valid,


	//-------- PHY Model -------//
	// Second DUT outputs 
    output  [3:0]                   o_sb_msg_out,
    output  [(NBYTES*8)-1:0]        o_data_sent,
    output     						o_data_valid,
    output 							o_sb_data_valid,
    output  [NC-1:0] 				o_data_sent_sb,
	output 							o_training_start_notification_out,


	//-------- CSR -------//
	// Protocol Signals
	output							o_P_Ready,
	output	[31:0]					o_P_RDATA

);
 



	// TX & RX  Signals
 	wire 								w_overflow_TX;
 	wire 								w_overflow_RX;

 	// RDI Signals 
 	wire  [3:0]							w_rdi_pl_state_sts;
	wire								w_rdi_pl_inband_pres;
 	wire  [2:0]							w_rdi_pl_speedmode;
 	wire  [2:0]							w_rdi_pl_lnk_cfg;
 	wire 								w_rdi_pl_phyinrecenter;;
	wire 								w_rdi_pl_error;
	wire 								w_rdi_pl_cerror;
	wire 								w_rdi_pl_nferror;
	wire 								w_rdi_pl_trainerror;
	wire  [3:0]							w_rdi_lp_state_req;
	wire								w_rdi_lp_linkerror;
	wire 								w_rdi_pl_trdy;
	wire 								w_rdi_lp_valid;
	wire 								w_rdi_lp_irdy;
	wire 								w_rdi_pl_valid;
	wire  [(NBYTES*8)-1:0] 				w_rdi_pl_data;
	wire  [(NBYTES*8)-1:0] 				w_rdi_lp_data;

	//-------- SB RDI Signals --------//
	wire 			   					w_rdi_pl_cfg_crd;
	wire               					w_rdi_pl_cfg_vld;
  	wire  [NC-1:0]	   					w_rdi_pl_cfg;



	wire								w_rdi_lp_cfg_crd;
	wire								w_rdi_lp_cfg_vld;
	wire  [NC-1:0]	    				w_rdi_lp_cfg;


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



	wire [7:0]  w_csr_addr; 
	wire [31:0] w_csr_WDATA;
	wire 		w_csr_WR; // 1 write , 0 read


	 /////////////////////////////////////////////////////// DUTS Instantiation ////////////////////////////////////////////////////////




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
	 	.i_rdi_pl_state_sts 			(w_rdi_pl_state_sts),
		.i_rdi_pl_inband_pres 			(w_rdi_pl_inband_pres),
	 	.i_rdi_pl_speedmode 			(w_rdi_pl_speedmode),
	 	.i_rdi_pl_lnk_cfg 				(w_rdi_pl_lnk_cfg),
	 	.i_rdi_pl_phyinrecenter 		(w_rdi_pl_phyinrecenter),
		.i_rdi_pl_error 				(w_rdi_pl_error),
		.i_rdi_pl_cerror 				(w_rdi_pl_cerror),
		.i_rdi_pl_nferror 				(w_rdi_pl_nferror),
		.i_rdi_pl_trainerror 			(w_rdi_pl_trainerror),

	 	// TX Signals
	 	.i_tx_overflow 					(w_overflow_TX),
	 	.i_rx_overflow 					(w_overflow_RX),
		

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
		.o_rdi_lp_state_req 			(w_rdi_lp_state_req),
		.o_rdi_lp_linkerror 			(w_rdi_lp_linkerror),


	 	//--------------------- Connections ----------------------//
	 	// SB Signals
	 	.i_sb_src_error 				(w_sb_src_error),
		.i_sb_dst_error 				(w_sb_dst_error),
		.i_sb_opcode_error 				(w_sb_opcode_error),
		.i_sb_unsupported_message 		(w_sb_unsupported_message),
		.i_sb_parity_error 				(w_sb_parity_error),

	 	.i_sb_busy_flag 				(w_pl_sb_busy),
		.i_sb_pl_decode 				(w_pl_sb_decode),
		.i_sb_pl_valid 					(w_valid_pl_sb),
		.i_sb_pl_adv_cap_val 			(w_pl_adv_cap_val),
		
		.o_sb_lp_decode 				(w_lp_sb_decode),
		.o_sb_lp_valid 					(w_valid_lp_sb),
		.o_sb_lp_adv_cap_val 			(w_lp_adv_cap_val),

		// CSR Signals
	  	.i_csr_UCIe_Link_Control_Retrain(w_CSR_UCIe_Link_Control_Retrain),
	 	.i_csr_ADVCAP 					(w_CSR_ADVCAP),

		.o_csr_wr 						(w_a_wr),
		.o_csr_addr 					(w_a_addr),
		.o_csr_wdata 					(w_a_wdata)
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

		.o_phy_WR 						(w_csr_WR),
		.o_phy_addr 					(w_csr_addr),
		.o_phy_WDATA					(w_csr_WDATA)
	);


	UCIE_ctl_sb_top #(.NC(NC)) SB (
		//------------------------ Inputs ------------------------//
		.i_clk 							(i_clk),
		.i_rst 							(i_rst_n),

		// RDI Signals
		.i_rdi_pl_cfg_crd 				(w_rdi_pl_cfg_crd),
		.i_pl_cfg_vld 					(w_rdi_pl_cfg_vld),              
	  	.i_received_data 				(w_rdi_pl_cfg),  

		//------------------------ Outputs ------------------------//
		// RDI Signals
		.o_cfg_crd 						(w_rdi_lp_cfg_crd),
	  	.o_rdi_lp_cfg_vld 				(w_rdi_lp_cfg_vld),
	  	.o_rdi_lp_cfg 					(w_rdi_lp_cfg),

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



	///////////////////////////////////////////////////////////////////////////////////////////////////////////


	// UCIe TX 
	UCIE_ctl_TX #( .UCIE_ACTIVE(UCIE_ACTIVE) ,
	 .DATA_WIDTH_TX(DATA_WIDTH_TX) ,
	 .FIFO_DEPTH_TX(FIFO_DEPTH_TX) 
	 ) 
	TX 
	(

		.i_clk(i_clk),
   		.i_rst(i_rst_n),
   		.i_fdi_pl_state_sts(o_fdi_pl_state_sts),
   		.i_fdi_lp_valid(i_fdi_lp_valid),
 	    .i_fdi_lp_irdy(i_fdi_lp_irdy),
  		.i_rdi_pl_trdy(w_rdi_pl_trdy),
  		.o_tx_overf_err(w_overflow_TX),
   	 	.o_fdi_pl_trdy(o_fdi_pl_trdy),
   		.o_rdi_lp_valid(w_rdi_lp_valid),
   		.o_rdi_lp_irdy(w_rdi_lp_irdy),
      	.i_w_data(i_fdi_lp_data),             // write data bus 
       	.o_r_data(w_rdi_lp_data)             // read data bus
		);


	 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	 // RX DUT ONE
	UCIE_ctl_RX_TOP  #(.NBYTES(NBYTES)) RX
	(
	   .i_clk(i_clk),
	   .i_rst(i_rst_n),
	   .i_state_request(o_fdi_pl_state_sts),
       .i_rdi_pl_data(w_rdi_pl_data),
       .i_rdi_pl_valid(w_rdi_pl_valid), 
       .o_fdi_data(o_fdi_pl_data),
       .o_fdi_data_valid(o_fdi_pl_valid),
       .o_overflow_detected(w_overflow_RX)
     );




	UCIE_ctl_phy_top # (.NBYTES(NBYTES),.NC(NC)) PHY
	 (
       	.i_clk(i_clk),
        .i_rst_n(i_rst_n),

        // Adapter CSR Inputs
		.i_csr_addr 					(w_csr_addr),
		.i_csr_WDATA 					(w_csr_WDATA),
		.i_csr_WR 						(w_csr_WR),

  		// Adapter (LP) Interface Inputs
        .i_rdi_lp_state_req(w_rdi_lp_state_req),
        .i_rdi_lp_linkerror(w_rdi_lp_linkerror),
        .i_rdi_lp_irdy(w_rdi_lp_irdy),
        .i_rdi_lp_valid(w_rdi_lp_valid),
        .i_rdi_lp_data(w_rdi_lp_data),
        .i_rdi_lp_cfg_crd(w_rdi_lp_cfg_crd),
        .i_rdi_lp_cfg_valid(w_rdi_lp_cfg_vld),
        .i_sb_data_valid(i_sb_data_valid),
        .i_data_received_sb(i_data_received_sb),
        .i_rdi_lp_cfg(w_rdi_lp_cfg),

  		// Second DUT inputs 
        .i_sb_msg_in(i_sb_msg_in),
        .i_data_received(i_data_received),
        .i_data_valid(i_data_valid),
        .i_training_start_notification_in (i_training_start_notification_in),

  		//Test Bench Flags
        .i_phy_req_trainerror(i_phy_req_trainerror),
        .i_phy_req_nferror(i_phy_req_nferror),
        .i_phy_req_cerror(i_phy_req_cerror),
        .i_phy_req_pl_error(i_phy_req_pl_error),
        .i_phy_req_data_error(i_phy_req_data_error),


  		// Adapter (LP) Interface Outputs
         .o_rdi_pl_state_sts(w_rdi_pl_state_sts),
         .o_rdi_pl_error(w_rdi_pl_error),
         .o_rdi_pl_cerror(w_rdi_pl_cerror),
         .o_rdi_pl_nferror(w_rdi_pl_nferror),
         .o_rdi_pl_trainerror(w_rdi_pl_trainerror),
         .o_rdi_pl_phyinrecenter(w_rdi_pl_phyinrecenter),
         .o_rdi_pl_speedmode(w_rdi_pl_speedmode),
         .o_rdi_pl_lnk_cfg(w_rdi_pl_lnk_cfg),
         .o_rdi_pl_inband_pres(w_rdi_pl_inband_pres),
         .o_rdi_pl_cfg_crd(w_rdi_pl_cfg_crd),
         .o_rdi_pl_cfg_vld(w_rdi_pl_cfg_vld),
         .o_sb_data_valid(o_sb_data_valid),
         .o_rdi_pl_cfg(w_rdi_pl_cfg),
         .o_data_sent_sb(o_data_sent_sb),
         .o_rdi_pl_trdy(w_rdi_pl_trdy),
         .o_rdi_pl_valid(w_rdi_pl_valid),
     	 .o_rdi_pl_data(w_rdi_pl_data),

  		 // Second DUT outputs 
         .o_sb_msg_out(o_sb_msg_out),
         .o_data_sent(o_data_sent),
         .o_data_valid(o_data_valid),
         .o_training_start_notification_out(o_training_start_notification_out)

     );

	 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


 	
endmodule