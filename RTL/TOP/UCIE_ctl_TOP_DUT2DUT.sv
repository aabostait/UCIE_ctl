`include "./defines.svh"
module UCIE_ctl_TOP_DUT2DUT #  (
	parameter 	  NBYTES 		= `NBYTES  , 
	parameter 	  NC 			= `NC ,
	parameter     UCIE_ACTIVE 	= 1  ,
	parameter     DATA_WIDTH_TX = `TX_WIDTH ,
  	parameter     FIFO_DEPTH_TX = `TX_DEPTH    
                           
  	)

	(
	////////////////////////////////////// Adapter_Die_0 /////////////////////////////////////
	//------------------------ Inputs ------------------------//
	input 							i_clk_die_0,
	input 							i_rst_n_die_0,

	//------- CNTL -------//
	// FDI Signals
 	input 	[3:0]					i_fdi_lp_state_req_die_0,
	input 							i_fdi_lp_rx_active_sts_die_0,
	input 							i_fdi_lp_linkerror_die_0,
	input 							i_fdi_lp_irdy_die_0,
	input   [(NBYTES*8)-1:0]        i_fdi_lp_data_die_0,
	input 							i_fdi_lp_valid_die_0,

	//-------- CSR -------//
	// Protocol Signals
	input							i_P_Select_die_0,
	input							i_P_Enable_die_0,
	input	[7:0]					i_P_addr_die_0,
	input	[31:0]					i_P_WDATA_die_0,
	input							i_P_WR_die_0,

	//-------- PHY Model -------//
  	//Test Bench Inputs 

  	input                     	 	i_phy_req_trainerror_die_0,
  	input                    		i_phy_req_nferror_die_0,
  	input                    		i_phy_req_cerror_die_0,
  	input                     		i_phy_req_pl_error_die_0,
  	input                     		i_phy_req_data_error_die_0,


  	//------------------------ Outputs ------------------------//
	//------- CNTL -------//
	// FDI Signals
	output	[3:0]					o_fdi_pl_state_sts_die_0,
	output							o_fdi_pl_inband_pres_die_0,
	output							o_fdi_pl_rx_active_req_die_0,
 	output	[2:0]					o_fdi_pl_protocol_die_0,
 	output	[3:0]					o_fdi_pl_protocol_flitfmt_die_0,
	output							o_fdi_pl_protocol_vld_die_0,
	output	[2:0]					o_fdi_pl_speedmode_die_0,
	output	[2:0]					o_fdi_pl_lnk_cfg_die_0,
	output							o_fdi_pl_error_die_0,
	output							o_fdi_pl_cerror_die_0,
	output							o_fdi_pl_nferror_die_0,
	output							o_fdi_pl_phyinrecenter_die_0,
	output							o_fdi_pl_trainerror_die_0,
	output 							o_fdi_pl_trdy_die_0,
	output [(NBYTES*8)-1:0]			o_fdi_pl_data_die_0,
    output 							o_fdi_pl_valid_die_0,


	


	//-------- CSR -------//
	// Protocol Signals
	output							o_P_Ready_die_0,
	output	[31:0]					o_P_RDATA_die_0,

	////////////////////////////////////////////////////////////////////////////////////////////////////////



	////////////////////////////////////// Adapter_Die_1 /////////////////////////////////////
	//------------------------ Inputs ------------------------//
	input 							i_clk_die_1,
	input 							i_rst_n_die_1,

	//------- CNTL -------//
	// FDI Signals
 	input 	[3:0]					i_fdi_lp_state_req_die_1,
	input 							i_fdi_lp_rx_active_sts_die_1,
	input 							i_fdi_lp_linkerror_die_1,
	input 							i_fdi_lp_irdy_die_1,
	input   [(NBYTES*8)-1:0]        i_fdi_lp_data_die_1,
	input 							i_fdi_lp_valid_die_1,

	//-------- CSR -------//
	// Protocol Signals
	input							i_P_Select_die_1,
	input							i_P_Enable_die_1,
	input	[7:0]					i_P_addr_die_1,
	input	[31:0]					i_P_WDATA_die_1,
	input							i_P_WR_die_1,

	//-------- PHY Model -------//
  	//Test Bench Inputs 

  	input                     	 	i_phy_req_trainerror_die_1,
  	input                    		i_phy_req_nferror_die_1,
  	input                    		i_phy_req_cerror_die_1,
  	input                     		i_phy_req_pl_error_die_1,
  	input                     		i_phy_req_data_error_die_1,

 


  	//------------------------ Outputs ------------------------//
	//------- CNTL -------//
	// FDI Signals
	output	[3:0]					o_fdi_pl_state_sts_die_1,
	output							o_fdi_pl_inband_pres_die_1,
	output							o_fdi_pl_rx_active_req_die_1,
 	output	[2:0]					o_fdi_pl_protocol_die_1,
 	output	[3:0]					o_fdi_pl_protocol_flitfmt_die_1,
	output							o_fdi_pl_protocol_vld_die_1,
	output	[2:0]					o_fdi_pl_speedmode_die_1,
	output	[2:0]					o_fdi_pl_lnk_cfg_die_1,
	output							o_fdi_pl_error_die_1,
	output							o_fdi_pl_cerror_die_1,
	output							o_fdi_pl_nferror_die_1,
	output							o_fdi_pl_phyinrecenter_die_1,
	output							o_fdi_pl_trainerror_die_1,
	output 							o_fdi_pl_trdy_die_1,
	output [(NBYTES*8)-1:0]			o_fdi_pl_data_die_1,
    output 							o_fdi_pl_valid_die_1,

	//-------- CSR -------//
	// Protocol Signals
	output							o_P_Ready_die_1,
	output	[31:0]					o_P_RDATA_die_1

	////////////////////////////////////////////////////////////////////////////////////////////////////////


);


	///////////////////////////////////////////////////////////////////////////////////////////



	// Second DUT Inputs 
	  logic           [3:0]   sb_msg_die_0;
	  logic [(NBYTES*8)-1:0]  data_transfer_die_0;
	  logic                   data_valid_die_0;

	  logic [3:0]             sb_msg_die_1;
	  logic [(NBYTES*8)-1:0]  data_transfer_die_1;
	  logic                   data_valid_die_1;

	  logic                   sb_data_valid_die_0;
	  logic          [NC-1:0] data_transfer_sb_die_0;

	  logic                   sb_data_valid_die_1;
	  logic          [NC-1:0] data_transfer_sb_die_1;

	  logic 				o_training_start_notification_out_die_0;
	  logic 				o_training_start_notification_out_die_1;


	/////////////////////////////////////////////////////////////////////////////////////////

 UCIE_ctl_TOP #  (
	 	.NBYTES(NBYTES), 		 
	 	.NC(NC), 			
	    .UCIE_ACTIVE(UCIE_ACTIVE),                        
  	    .FIFO_DEPTH_TX(FIFO_DEPTH_TX),
        .DATA_WIDTH_TX(DATA_WIDTH_TX)	 
  	)

 	Adapter_Die_0

	(
	//------------------------ Inputs ------------------------//
	 	.i_clk(i_clk_die_0),
	 	.i_rst_n(i_rst_n_die_0),

	//------- CNTL -------//
	// FDI Signals
 	 	.i_fdi_lp_state_req(i_fdi_lp_state_req_die_0),
	 	.i_fdi_lp_rx_active_sts(i_fdi_lp_rx_active_sts_die_0),
	 	.i_fdi_lp_linkerror(i_fdi_lp_linkerror_die_0),
	 	.i_fdi_lp_irdy(i_fdi_lp_irdy_die_0),
	    .i_fdi_lp_data(i_fdi_lp_data_die_0),
	 	.i_fdi_lp_valid(i_fdi_lp_valid_die_0),

	//-------- CSR -------//
	// Protocol Signals
		.i_P_Select(i_P_Select_die_0),
		.i_P_Enable(i_P_Enable_die_0),
		.i_P_addr(i_P_addr_die_0),
		.i_P_WDATA(i_P_WDATA_die_0),
		.i_P_WR(i_P_WR_die_0),

	//-------- PHY Model -------//
  	//Test Bench inputs 

		.i_phy_req_trainerror(i_phy_req_trainerror_die_0),
		.i_phy_req_nferror(i_phy_req_nferror_die_0),
		.i_phy_req_cerror(i_phy_req_cerror_die_0),
		.i_phy_req_pl_error(i_phy_req_pl_error_die_0),
		.i_phy_req_data_error(i_phy_req_data_error_die_0),

  	// Second DUT inputs 
    	.i_sb_msg_in(sb_msg_die_1),
    	.i_data_received(data_transfer_die_1),
    	.i_data_valid(data_valid_die_1),
    	.i_sb_data_valid(sb_data_valid_die_1),
    	.i_data_received_sb(data_transfer_sb_die_1),
    	.i_training_start_notification_in(o_training_start_notification_out_die_1),


  	//------------------------ Outputs ------------------------//
	//------- CNTL -------//
	// FDI Signals
		.o_fdi_pl_state_sts(o_fdi_pl_state_sts_die_0),
		.o_fdi_pl_inband_pres(o_fdi_pl_inband_pres_die_0),
		.o_fdi_pl_rx_active_req(o_fdi_pl_rx_active_req_die_0),
	 	.o_fdi_pl_protocol(o_fdi_pl_protocol_die_0),
	 	.o_fdi_pl_protocol_flitfmt(o_fdi_pl_protocol_flitfmt_die_0),
		.o_fdi_pl_protocol_vld(o_fdi_pl_protocol_vld_die_0),
		.o_fdi_pl_speedmode(o_fdi_pl_speedmode_die_0),
		.o_fdi_pl_lnk_cfg(o_fdi_pl_lnk_cfg_die_0),
		.o_fdi_pl_error(o_fdi_pl_error_die_0),
		.o_fdi_pl_cerror(o_fdi_pl_cerror_die_0),
		.o_fdi_pl_nferror(o_fdi_pl_nferror_die_0),
		.o_fdi_pl_phyinrecenter(o_fdi_pl_phyinrecenter_die_0),
		.o_fdi_pl_trainerror(o_fdi_pl_trainerror_die_0),
		.o_fdi_pl_trdy(o_fdi_pl_trdy_die_0),
		.o_fdi_pl_data(o_fdi_pl_data_die_0),
	    .o_fdi_pl_valid(o_fdi_pl_valid_die_0),


	//-------- PHY Model -------//
	// Second DUT outputs 
	   .o_sb_msg_out(sb_msg_die_0),
	   .o_data_sent(data_transfer_die_0),
	   .o_data_valid(data_valid_die_0),
	   .o_sb_data_valid(sb_data_valid_die_0),
	   .o_data_sent_sb(data_transfer_sb_die_0),
	   .o_training_start_notification_out(o_training_start_notification_out_die_0),


	//-------- CSR -------//
	// Protocol Signals
		.o_P_Ready(o_P_Ready_die_0),
		.o_P_RDATA(o_P_RDATA_die_0)


);


	UCIE_ctl_TOP #  (
	 	.NBYTES(NBYTES), 		 
	 	.NC(NC), 			
	    .UCIE_ACTIVE(UCIE_ACTIVE),                        
  	    .FIFO_DEPTH_TX(FIFO_DEPTH_TX),
        .DATA_WIDTH_TX(DATA_WIDTH_TX)	 
  	)

 	Adapter_Die_1

	(
	//------------------------ Inputs ------------------------//
	 	.i_clk(i_clk_die_1),
	 	.i_rst_n(i_rst_n_die_1),

	//------- CNTL -------//
	// FDI Signals
 	 	.i_fdi_lp_state_req(i_fdi_lp_state_req_die_1),
	 	.i_fdi_lp_rx_active_sts(i_fdi_lp_rx_active_sts_die_1),
	 	.i_fdi_lp_linkerror(i_fdi_lp_linkerror_die_1),
	 	.i_fdi_lp_irdy(i_fdi_lp_irdy_die_1),
	    .i_fdi_lp_data(i_fdi_lp_data_die_1),
	 	.i_fdi_lp_valid(i_fdi_lp_valid_die_1),

	//-------- CSR -------//
	// Protocol Signals
		.i_P_Select(i_P_Select_die_1),
		.i_P_Enable(i_P_Enable_die_1),
		.i_P_addr(i_P_addr_die_1),
		.i_P_WDATA(i_P_WDATA_die_1),
		.i_P_WR(i_P_WR_die_1),

	//-------- PHY Model -------//
  	//Test Bench inputs 

		.i_phy_req_trainerror(i_phy_req_trainerror_die_1),
		.i_phy_req_nferror(i_phy_req_nferror_die_1),
		.i_phy_req_cerror(i_phy_req_cerror_die_1),
		.i_phy_req_pl_error(i_phy_req_pl_error_die_1),
		.i_phy_req_data_error(i_phy_req_data_error_die_1),

  	// Second DUT inputs 
    	.i_sb_msg_in(sb_msg_die_0),
    	.i_data_received(data_transfer_die_0),
    	.i_data_valid(data_valid_die_0),
    	.i_sb_data_valid(sb_data_valid_die_0),
    	.i_data_received_sb(data_transfer_sb_die_0),
    	.i_training_start_notification_in(o_training_start_notification_out_die_0),



  	//------------------------ Outputs ------------------------//
	//------- CNTL -------//
	// FDI Signals
		.o_fdi_pl_state_sts(o_fdi_pl_state_sts_die_1),
		.o_fdi_pl_inband_pres(o_fdi_pl_inband_pres_die_1),
		.o_fdi_pl_rx_active_req(o_fdi_pl_rx_active_req_die_1),
	 	.o_fdi_pl_protocol(o_fdi_pl_protocol_die_1),
	 	.o_fdi_pl_protocol_flitfmt(o_fdi_pl_protocol_flitfmt_die_1),
		.o_fdi_pl_protocol_vld(o_fdi_pl_protocol_vld_die_1),
		.o_fdi_pl_speedmode(o_fdi_pl_speedmode_die_1),
		.o_fdi_pl_lnk_cfg(o_fdi_pl_lnk_cfg_die_1),
		.o_fdi_pl_error(o_fdi_pl_error_die_1),
		.o_fdi_pl_cerror(o_fdi_pl_cerror_die_1),
		.o_fdi_pl_nferror(o_fdi_pl_nferror_die_1),
		.o_fdi_pl_phyinrecenter(o_fdi_pl_phyinrecenter_die_1),
		.o_fdi_pl_trainerror(o_fdi_pl_trainerror_die_1),
		.o_fdi_pl_trdy(o_fdi_pl_trdy_die_1),
		.o_fdi_pl_data(o_fdi_pl_data_die_1),
	    .o_fdi_pl_valid(o_fdi_pl_valid_die_1),


	//-------- PHY Model -------//
	// Second DUT outputs 
	   .o_sb_msg_out(sb_msg_die_1),
	   .o_data_sent(data_transfer_die_1),
	   .o_data_valid(data_valid_die_1),
	   .o_sb_data_valid(sb_data_valid_die_1),
	   .o_data_sent_sb(data_transfer_sb_die_1),
	   .o_training_start_notification_out(o_training_start_notification_out_die_1),


	//-------- CSR -------//
	// Protocol Signals
		.o_P_Ready(o_P_Ready_die_1),
		.o_P_RDATA(o_P_RDATA_die_1)

);


 
endmodule