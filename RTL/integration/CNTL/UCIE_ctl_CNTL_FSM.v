module UCIE_ctl_CNTL_FSM (
	// ------------------------------ Inputs ------------------------------- //
	input 				i_clk,
	input 				i_rst_n,
	// FDI signals
	input 		[3:0] 	i_fdi_lp_state_req,
	input 				i_fdi_lp_rx_active_sts,
	input				i_fdi_lp_linkerror,
	input 				i_fdi_pl_error,


	// RDI signals 
	input 		[3:0] 	i_rdi_pl_state_sts,
	input 				i_rdi_pl_inband_pres,
	input 		[2:0] 	i_rdi_pl_speedmode,
	input 		[2:0] 	i_rdi_pl_lnk_cfg,


	// CSR Signals
	input  			 	i_csr_UCIe_Link_Control_Retrain,
	input 		[31:0] 	i_csr_ADVCAP,


	// TX Signals
	input 				i_tx_overflow,
	input 				i_rx_overflow,


	// SB Signals
	input 				i_sb_busy_flag,
	input 		[4:0] 	i_sb_pl_decode,
	input 				i_sb_pl_valid,
	input 		[31:0] 	i_sb_pl_adv_cap_val,
	input 				i_sb_src_error,
	input 				i_sb_dst_error,
	input 				i_sb_opcode_error,
	input 				i_sb_unsupported_message,
	input 				i_sb_parity_error,


	// ------------------------------ Outputs ------------------------------- //
	// FDI Signals
	output reg  [3:0] 	o_fdi_pl_state_sts,
	output reg 			o_fdi_pl_inband_pres,
	output reg 			o_fdi_pl_rx_active_req,
	output reg 	[2:0] 	o_fdi_pl_protocol,
	output reg 	[3:0] 	o_fdi_pl_protocol_flitfmt,
	output reg 			o_fdi_pl_protocol_vld,
	output reg 	[2:0]	o_fdi_pl_speedmode,
	output reg 	[2:0]	o_fdi_pl_lnk_cfg,
	output reg 			o_pl_phyinrecenter_i, 	// INTERNAL IN CNTL - asserted on going to retrain state
	output reg 			o_pl_trainerror_i, 		// INTERNAL IN CNTL - asserted when parameter negotiation fails


	// RDI Signals
	output reg 	[3:0] 	o_rdi_lp_state_req,
	output reg 			o_rdi_lp_linkerror,


	// SB Signals
	output reg 	[4:0]	o_sb_lp_decode,
	output reg 			o_sb_lp_valid,
	output reg 	[31:0]	o_sb_lp_adv_cap_val,


	// Logging FSM Signals
	output reg			o_log_parameter_exchange_timeout,
	output reg			o_log_state_status_transition_timeout,
	output reg			o_log_adapter_timeout,
	output reg	[3:0]	o_log_enabled_caps
	);


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	// States Encoding: Gray Encoding
	localparam  GLOBAL_RESET 					= 5'b00000;
	localparam	RESET 							= 5'b00001;
	localparam	REQ_ACTIVE_STATE_ON_PHY			= 5'b00011;
	localparam	SEE_CAPS						= 5'b00010;
	localparam	PARAMETER_NEGOTIATION_FALIED	= 5'b00110;
	localparam	PARAMETER_NEGOTIATION_DONE		= 5'b00111;
	localparam	SEND_SB_ACTIVE_REQ				= 5'b00101;
	localparam	SB_ACTIVE_RSP_RECEIVED			= 5'b00100;
	localparam	WAIT_RX_STATE					= 5'b01100;
	localparam	OPEN_RX							= 5'b01101;
	localparam	SEND_SB_ACTIVE_RSP				= 5'b01111;
	localparam	ACTIVE							= 5'b01110;
	localparam	PROPAGATE_RETRAIN_REQ_TO_PHY	= 5'b01010;
	localparam	RETRAIN							= 5'b01011;
	localparam	PROPAGATE_LINKERROR_TO_PHY		= 5'b01001;
	localparam	LINKERROR 						= 5'b01000;
	localparam	SEND_SB_LINKRESET_REQ			= 5'b11000;
	localparam	SEND_SB_LINKRESET_RSP			= 5'b11001;
	localparam	PROPAGATE_LINKRESET_REQ_TO_PHY	= 5'b11011;
	localparam	LINKRESET 						= 5'b11010;
	localparam	PROPAGATE_ACTIVE_REQ_TO_PHY		= 5'b11110;




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// lp_state_req
	localparam  NOP_REQ 						= 4'b0000;
	localparam  ACTIVE_REQ 						= 4'b0001;
	localparam 	LINKRESET_REQ 					= 4'b1001;
	localparam 	RETRAIN_REQ 					= 4'b1011;

	// pl_state_sts
	localparam  RESET_STS 						= 4'b0000;
	localparam  ACTIVE_STS 						= 4'b0001;
	localparam 	LINKRESET_STS 					= 4'b1001;
	localparam  LINKERROR_STS 					= 4'b1010;
	localparam 	RETRAIN_STS 					= 4'b1011;

	// SB MSGs
	localparam  SB_ADV_CAP_ADAPTER 				= 5'b00000;
	localparam	SB_ADAPTER_REQ_ACTIVE 			= 5'b10101;
	localparam	SB_ADAPTER_RSP_ACTIVE 			= 5'b11001;
	localparam 	SB_ADAPTER_REQ_LINKRESET 		= 5'b10111;
	localparam 	SB_ADAPTER_RSP_LINKRESET 		= 5'b11011;

	// ADVCAP Value
	localparam  RAW_FORMAT						= 4'b0001;
	localparam  STREAMING_PROTOCOL				= 3'b111;
	localparam  PCIE_PROTOCOL 					= 3'b000;
	localparam  CXL_1_PROTOCOL					= 3'b011;




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	reg [4:0] cs, ns;

	// NOP Request Monitor
	reg r_IS_NOP_SENT_flag;
	reg r_transitioned_from_NOP_flag;

	// FSM Flags
	reg r_RX_done_flag, r_TX_done_flag;
	reg r_linkreset_req_sent_flag;

	// Indicates SB initiated MSG Transmission
	reg w_en_transition_after_sb_busy_detected_flag;

	// Represents Negotiated Caps in SEE_CAPS State
	reg [3:0] r_negotiated_caps;

	// Timer Inputs
	reg r_en_timer, r_mode_timer;
	
	// Timer Outputs
	wire w_timeout_flag;

	// Link Error Triggers
	wire w_link_down_signal;

	// Indicates SB initiated MSG Transmission
	wire w_sb_busy_detected_flag;


	//Temp Registers Declaration
	//////////////////////////////////////////////////////////////////////////////////
	reg	[3:0]   r_fdi_pl_state_sts_temp;
	reg 		r_fdi_pl_inband_pres_temp;
	reg 		r_fdi_pl_rx_active_req_temp;
	reg [2:0] 	r_fdi_pl_protocol_temp;
	reg [3:0] 	r_fdi_pl_protocol_flitfmt_temp;	
	reg 		r_fdi_pl_protocol_vld_temp;
	reg [2:0] 	r_fdi_pl_speedmode_temp;
	reg [2:0]	r_fdi_pl_lnk_cfg_temp;

	reg 		r_sb_busy_flag_temp;
	reg [4:0]	r_sb_lp_decode_temp;
	reg 		r_sb_lp_valid_temp;
	reg [31:0]	o_sb_lp_adv_cap_val_temp;

	reg [3:0] 	r_rdi_lp_state_req_temp;
	reg 		r_rdi_lp_linkerror_temp;

	reg 		r_pl_phyinrecenter_i_temp;
	reg 		r_pl_trainerror_i_temp;
	
	reg 		r_TX_done_flag_temp;
	reg 		r_RX_done_flag_temp;
	reg 		r_IS_NOP_SENT_temp;
	reg 		r_transitioned_from_NOP_flag_temp;
	reg 		r_en_transition_after_sb_busy_detected_flag_temp;

	reg [3:0] 	r_log_enabled_caps_temp;
	reg [3:0] 	r_negotiated_caps_temp;

	




	Timer  timer (.clk(i_clk), .rst(i_rst_n), .en(r_en_timer), .T(r_mode_timer), .Flag(w_timeout_flag));

	





	assign w_link_down_signal = ((o_fdi_pl_state_sts == ACTIVE_STS) && (i_tx_overflow || i_rx_overflow))   ||
								i_fdi_lp_linkerror || o_pl_trainerror_i || 
								i_sb_src_error 	   || i_sb_dst_error 	|| i_sb_opcode_error || i_sb_parity_error ||
								i_sb_unsupported_message;

	assign w_sb_busy_detected_flag = i_sb_busy_flag & ~r_sb_busy_flag_temp; //Edge Detection


	always @(*) begin
		
		r_transitioned_from_NOP_flag = r_transitioned_from_NOP_flag_temp;

		case(cs)
			GLOBAL_RESET: begin
				if(!i_rst_n) begin

					ns = GLOBAL_RESET;
				
				end
				else begin

					ns = RESET;

				end
			end

			RESET : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if ((i_fdi_lp_state_req == LINKRESET_REQ) && r_transitioned_from_NOP_flag_temp) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin
					
					if(	i_rdi_pl_inband_pres || ((i_fdi_lp_state_req == ACTIVE_REQ) && r_transitioned_from_NOP_flag_temp)) begin
						
						ns = REQ_ACTIVE_STATE_ON_PHY;
						r_transitioned_from_NOP_flag = 0;

					end
					else if(i_fdi_lp_state_req == NOP_REQ) begin

						r_transitioned_from_NOP_flag = 1;
						ns = RESET;
						
					end
					else begin
						
						r_transitioned_from_NOP_flag = 0;
						ns = RESET;

					end

				end			
			end

			REQ_ACTIVE_STATE_ON_PHY : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal || w_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (i_rdi_pl_state_sts == ACTIVE_STS) begin
						
						if (o_fdi_pl_inband_pres) begin
							
							ns = SEND_SB_ACTIVE_REQ;
						
						end
						else begin
						
							ns = SEE_CAPS;

						end

					end
					else begin

						ns = REQ_ACTIVE_STATE_ON_PHY;

					end

				end
			end

			SEE_CAPS : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal || w_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADV_CAP_ADAPTER) && w_en_transition_after_sb_busy_detected_flag) begin
						
						if (i_csr_ADVCAP == i_sb_pl_adv_cap_val) begin
							
							ns = PARAMETER_NEGOTIATION_DONE;

						end
						else begin
							
							ns = PARAMETER_NEGOTIATION_FALIED;

						end

					end
					else begin
						
						ns = SEE_CAPS;

					end

				end
			end

			PARAMETER_NEGOTIATION_FALIED : begin
				ns = PROPAGATE_LINKERROR_TO_PHY;
			end

			PARAMETER_NEGOTIATION_DONE : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (i_fdi_lp_state_req == ACTIVE_REQ) begin

						ns = SEND_SB_ACTIVE_REQ;

					end
					else begin
						
						ns = WAIT_RX_STATE;

					end

				end
			end

			SEND_SB_ACTIVE_REQ : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal || w_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (i_sb_pl_valid && w_en_transition_after_sb_busy_detected_flag) begin

						if ((i_sb_pl_decode == SB_ADAPTER_REQ_ACTIVE) && !r_RX_done_flag) begin
							
							ns = OPEN_RX;

						end
						else if (i_sb_pl_decode == SB_ADAPTER_RSP_ACTIVE) begin
							
							ns = SB_ACTIVE_RSP_RECEIVED;

						end
						else begin
							
							ns = SEND_SB_ACTIVE_REQ;

						end

					end
					else begin
					
						ns = SEND_SB_ACTIVE_REQ;

					end

				end
			end

			SB_ACTIVE_RSP_RECEIVED : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (r_RX_done_flag) begin
						
						ns = ACTIVE;

					end
					else begin
						
						ns = WAIT_RX_STATE;

					end

				end
			end

			WAIT_RX_STATE : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal || w_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_ACTIVE)) begin

						ns = OPEN_RX;

					end
					else if (i_fdi_lp_state_req == ACTIVE_REQ && !r_TX_done_flag) begin
						
						ns = SEND_SB_ACTIVE_REQ;

					end
					else begin
						
						ns = WAIT_RX_STATE;

					end

				end
			end

			OPEN_RX : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal || w_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (i_fdi_lp_rx_active_sts) begin
						
						ns = SEND_SB_ACTIVE_RSP;

					end
					else begin
						
						ns = OPEN_RX;

					end

				end
			end

			SEND_SB_ACTIVE_RSP : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (w_en_transition_after_sb_busy_detected_flag) begin

						if (r_TX_done_flag) begin

							ns = ACTIVE;

						end
						else begin

							if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_RSP_ACTIVE)) begin
								
								ns = SB_ACTIVE_RSP_RECEIVED;

							end
							else if (i_fdi_lp_state_req == ACTIVE_REQ) begin
							
								ns = SEND_SB_ACTIVE_REQ;

							end
							else begin
								
								ns = SEND_SB_ACTIVE_RSP;

							end

						end

					end
					else begin
						
						ns = SEND_SB_ACTIVE_RSP;

					end

				end
			end

			ACTIVE : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (i_rdi_pl_state_sts == RETRAIN_STS) begin

						ns = RETRAIN;

					end
					else if (i_fdi_lp_state_req == RETRAIN_REQ 	||
							i_csr_UCIe_Link_Control_Retrain 	||
							i_fdi_pl_error) begin

						ns = PROPAGATE_RETRAIN_REQ_TO_PHY;

					end
					else begin

						ns = ACTIVE;

					end

				end
			end

			PROPAGATE_RETRAIN_REQ_TO_PHY : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal || w_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (i_rdi_pl_state_sts == RETRAIN_STS) begin
						
						ns = RETRAIN;

					end
					else begin
						
						ns = PROPAGATE_RETRAIN_REQ_TO_PHY;

					end

				end
			end

			RETRAIN : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if((i_fdi_lp_state_req == ACTIVE_REQ) && r_transitioned_from_NOP_flag_temp) begin
						
						ns = REQ_ACTIVE_STATE_ON_PHY;
						r_transitioned_from_NOP_flag = 0;


					end
					else if(i_fdi_lp_state_req == NOP_REQ) begin

						r_transitioned_from_NOP_flag = 1;
						ns = RETRAIN;
						
					end
					else begin
						
						r_transitioned_from_NOP_flag = 0;
						ns = RETRAIN;

					end

				end
			end

			PROPAGATE_LINKERROR_TO_PHY : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
			end

			LINKERROR : begin

				if (i_rdi_pl_state_sts == RESET_STS) begin
						
					ns = RESET;

				end
				else if (!w_timeout_flag) begin

					ns = LINKERROR;

				end
				else begin

					if (w_link_down_signal) begin

						ns = LINKERROR;

					end
					else if (i_fdi_lp_state_req == ACTIVE_REQ) begin
					
						ns = PROPAGATE_ACTIVE_REQ_TO_PHY;
					
					end
					else begin
					
						ns = LINKERROR;

					end

				end
			end

			SEND_SB_LINKRESET_REQ : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal || w_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else begin

					if (i_sb_pl_valid && w_en_transition_after_sb_busy_detected_flag) begin

						if (i_sb_pl_decode == SB_ADAPTER_RSP_LINKRESET) begin
						
							ns = PROPAGATE_LINKRESET_REQ_TO_PHY;

						end
						else if (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET) begin
							
							ns = SEND_SB_LINKRESET_RSP;

						end
						else begin
							
							ns = SEND_SB_LINKRESET_REQ;

						end

					end
					else begin
						
						ns = SEND_SB_LINKRESET_REQ;

					end

				end
			end

			SEND_SB_LINKRESET_RSP : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else begin

					if (w_en_transition_after_sb_busy_detected_flag) begin

						if (r_linkreset_req_sent_flag) begin
							
							ns = PROPAGATE_LINKRESET_REQ_TO_PHY;

						end
						else if (i_rdi_pl_state_sts == LINKRESET_STS) begin
							
							ns = LINKRESET;

						end
						else begin
							
							ns = SEND_SB_LINKRESET_RSP;

						end

					end
					else begin
						
						ns = SEND_SB_LINKRESET_RSP;
						
					end

				end
			end

			PROPAGATE_LINKRESET_REQ_TO_PHY : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal || w_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else begin

					if (i_rdi_pl_state_sts == LINKRESET_STS) begin
						
						ns = LINKRESET;

					end
					else begin
						
						ns = PROPAGATE_LINKRESET_REQ_TO_PHY;

					end

				end
			end

			LINKRESET : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (w_link_down_signal) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else begin
					
					if (i_rdi_pl_state_sts == RESET_STS) begin
						
						ns = RESET;
					
					end
					else if (i_fdi_lp_state_req == ACTIVE_REQ) begin
					
						ns = PROPAGATE_ACTIVE_REQ_TO_PHY;
					
					end
					else begin
					
						ns = LINKRESET;

					end

				end

			end

			PROPAGATE_ACTIVE_REQ_TO_PHY : begin
				if (w_link_down_signal || w_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_sb_pl_valid && (i_sb_pl_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (i_rdi_pl_state_sts == RESET_STS) begin
						
						ns = RESET;

					end
					else begin
						
						ns = PROPAGATE_ACTIVE_REQ_TO_PHY;

					end

				end
			end

			default : begin

				ns = GLOBAL_RESET;
			
			end
		endcase
	end





	always @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			cs <= GLOBAL_RESET;
		end
		else begin
			cs <= ns;
		end
	end





	always @(*) begin

		o_fdi_pl_state_sts  		= r_fdi_pl_state_sts_temp;
		o_fdi_pl_inband_pres    	= r_fdi_pl_inband_pres_temp;
		o_pl_trainerror_i 			= r_pl_trainerror_i_temp;
		o_fdi_pl_rx_active_req 		= r_fdi_pl_rx_active_req_temp;
		o_fdi_pl_protocol 			= r_fdi_pl_protocol_temp;
		o_fdi_pl_protocol_flitfmt 	= r_fdi_pl_protocol_flitfmt_temp;
		o_fdi_pl_protocol_vld 		= r_fdi_pl_protocol_vld_temp;
		o_fdi_pl_speedmode 			= r_fdi_pl_speedmode_temp;
		o_fdi_pl_lnk_cfg 			= r_fdi_pl_lnk_cfg_temp;
		o_pl_phyinrecenter_i 		= r_pl_phyinrecenter_i_temp;

		o_rdi_lp_state_req  		= r_rdi_lp_state_req_temp;
		o_rdi_lp_linkerror 			= r_rdi_lp_linkerror_temp;
		o_sb_lp_decode 				= r_sb_lp_decode_temp;
		o_sb_lp_valid  				= r_sb_lp_valid_temp;
		o_sb_lp_adv_cap_val 		= o_sb_lp_adv_cap_val_temp;

		r_IS_NOP_SENT_flag 			= r_IS_NOP_SENT_temp;
		r_en_timer 					= 0;
		r_mode_timer 				= 0;

		r_TX_done_flag				= r_TX_done_flag_temp;
		r_RX_done_flag				= r_RX_done_flag_temp;

		w_en_transition_after_sb_busy_detected_flag = r_en_transition_after_sb_busy_detected_flag_temp;
		r_negotiated_caps 			= r_negotiated_caps_temp;

		o_log_parameter_exchange_timeout 		= 0;
		o_log_state_status_transition_timeout 	= 0;
		o_log_adapter_timeout 					= 0;
		o_log_enabled_caps 						= r_log_enabled_caps_temp;

		case(cs)

			GLOBAL_RESET: begin

				o_fdi_pl_state_sts 		=  RESET_STS;
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;

				if (i_csr_ADVCAP[4]) begin
					o_fdi_pl_protocol 	=  STREAMING_PROTOCOL;
				end
				else if (i_csr_ADVCAP[3]) begin
					o_fdi_pl_protocol 	=  PCIE_PROTOCOL;
				end
				else if (i_csr_ADVCAP[1] || i_csr_ADVCAP[2] ) begin
					o_fdi_pl_protocol 	=  CXL_1_PROTOCOL;
				end
					
				
				o_fdi_pl_protocol_flitfmt 	=  RAW_FORMAT;
				o_fdi_pl_protocol_vld 		=  0;

				o_fdi_pl_speedmode 			=  3'b000;
				o_fdi_pl_lnk_cfg 			=  3'b001;
				o_pl_phyinrecenter_i 		=  0;
				o_rdi_lp_state_req 			=  NOP_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_sb_lp_decode  			=  0;
				o_sb_lp_valid 				=  0;
				o_sb_lp_adv_cap_val 		=  0;

				r_TX_done_flag 				=  0;
				r_RX_done_flag 				=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 			=  0;

				o_log_enabled_caps 			=  0;
			end

			RESET : begin
				o_fdi_pl_state_sts 			=  RESET_STS;
				o_fdi_pl_inband_pres 		=  0;
				o_pl_trainerror_i 			=  0;
				o_fdi_pl_rx_active_req 		=  0;
				o_fdi_pl_protocol_vld 		=  0;

				o_pl_phyinrecenter_i 		=  0;
				o_rdi_lp_state_req 			=  NOP_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_sb_lp_decode 				=  0;
				o_sb_lp_valid 				=  0;
				o_sb_lp_adv_cap_val 		=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 			=  0;
				r_TX_done_flag 				=  0;
				r_RX_done_flag 				=  0;

			end



			REQ_ACTIVE_STATE_ON_PHY : begin

				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(w_timeout_flag) begin
					r_en_timer 		=  0;
				end 
				else begin
					r_en_timer 		=  1;
					r_mode_timer 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;

				o_pl_phyinrecenter_i 	=  1;

				if ( (o_fdi_pl_state_sts== RESET_STS) && i_rdi_pl_inband_pres) begin
					o_rdi_lp_state_req 	=  ACTIVE_REQ;
				end

				else if(r_IS_NOP_SENT_temp) begin
					o_rdi_lp_state_req 	=  ACTIVE_REQ;
				end
				else begin
					o_rdi_lp_state_req 	=  NOP_REQ;
					r_IS_NOP_SENT_flag 	=  1;
				end


				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  0;
				o_sb_lp_valid 			=  0;
				o_sb_lp_adv_cap_val 	=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;



			end

			SEE_CAPS : begin


				if (w_sb_busy_detected_flag) begin
					w_en_transition_after_sb_busy_detected_flag = 1;
				end


				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(w_timeout_flag) begin
					o_log_parameter_exchange_timeout = 1;
					r_en_timer 		=  0;
				end 
				else begin
					r_en_timer 		=  1;
					r_mode_timer 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_fdi_pl_state_sts 		=  RESET_STS;
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;

				// HERE WE HAVE A BUG ^^

				if ( (i_csr_ADVCAP == i_sb_pl_adv_cap_val )
				 && (i_sb_pl_valid && i_sb_pl_decode ==  SB_ADV_CAP_ADAPTER) && i_csr_ADVCAP[4]  ) begin 
					o_fdi_pl_protocol 	=  STREAMING_PROTOCOL;
				end
				else if (  (i_csr_ADVCAP ==  i_sb_pl_adv_cap_val )
				 && (i_sb_pl_valid && i_sb_pl_decode ==  SB_ADV_CAP_ADAPTER) && i_csr_ADVCAP[3]) begin
					o_fdi_pl_protocol 	=  PCIE_PROTOCOL;
				end
				else if ((i_csr_ADVCAP ==  i_sb_pl_adv_cap_val )
				 && (i_sb_pl_valid && i_sb_pl_decode ==  SB_ADV_CAP_ADAPTER) && (i_csr_ADVCAP[1] || i_csr_ADVCAP[2]) ) begin
					o_fdi_pl_protocol 	=  CXL_1_PROTOCOL;
				end

				o_fdi_pl_protocol_flitfmt 	=  RAW_FORMAT;
				o_fdi_pl_protocol_vld 		=  0;

				o_pl_phyinrecenter_i 		=  1;
				o_rdi_lp_state_req 			=  NOP_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_sb_lp_decode 				=  SB_ADV_CAP_ADAPTER;
				o_sb_lp_valid 				=  1;
				o_sb_lp_adv_cap_val 		=  i_csr_ADVCAP;
				r_IS_NOP_SENT_flag 			=  0;

				o_fdi_pl_speedmode 			=  i_rdi_pl_speedmode;
				o_fdi_pl_lnk_cfg 			=  i_rdi_pl_lnk_cfg;

				r_negotiated_caps 			=  i_csr_ADVCAP[3:0];
			end

			PARAMETER_NEGOTIATION_FALIED : begin
				o_fdi_pl_state_sts 			=  RESET_STS;
				o_fdi_pl_inband_pres 		=  0;
				o_pl_trainerror_i 			=  1;
				o_fdi_pl_rx_active_req 		=  0;
				o_fdi_pl_protocol 			=  0;
				o_fdi_pl_protocol_flitfmt 	=  0;
				o_fdi_pl_protocol_vld 		=  0;

				o_pl_phyinrecenter_i 		=  1;
				o_rdi_lp_state_req 			=  NOP_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_sb_lp_decode 				=  0;
				o_sb_lp_valid 				=  0;
				o_sb_lp_adv_cap_val 		=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 			=  0;

			end

			PARAMETER_NEGOTIATION_DONE : begin
				o_fdi_pl_state_sts 			=  RESET_STS;
				o_fdi_pl_inband_pres 		=  1;
				o_pl_trainerror_i 			=  0;
				o_fdi_pl_rx_active_req 		=  0;
				o_fdi_pl_protocol_vld 		=  1;

				o_pl_phyinrecenter_i 		=  1;
				o_rdi_lp_state_req 			=  NOP_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_sb_lp_decode 				=  0;
				o_sb_lp_valid 				=  0;
				o_sb_lp_adv_cap_val 		=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 			=  0;

				o_log_enabled_caps 			= r_negotiated_caps;
			end

			SEND_SB_ACTIVE_REQ : begin
				
				if (w_sb_busy_detected_flag) begin
					w_en_transition_after_sb_busy_detected_flag = 1;
				end

				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(w_timeout_flag) begin
					o_log_adapter_timeout = 1;
					r_en_timer 		=  0;
				end 
				else begin
					r_en_timer 		=  1;
					r_mode_timer 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 	=  1;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  SB_ADAPTER_REQ_ACTIVE;
				o_sb_lp_valid 			=  1;
				o_sb_lp_adv_cap_val 	=  0;
				r_IS_NOP_SENT_flag 		=  0;
			end

			SB_ACTIVE_RSP_RECEIVED : begin
				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 	=  1;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  0;
				o_sb_lp_valid 			=  0;
				o_sb_lp_adv_cap_val 	=  0;
				r_TX_done_flag 			=  1;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 		=  0;

			end

			WAIT_RX_STATE : begin
				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(w_timeout_flag) begin
					o_log_adapter_timeout = 1;
					r_en_timer 		=  0;
				end 
				else begin
					r_en_timer 		=  1;
					r_mode_timer 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 	=  1;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  0;
				o_sb_lp_valid 			=  0;
				o_sb_lp_adv_cap_val 	=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 		=  0;

			end

			OPEN_RX : begin

				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(w_timeout_flag) begin
					o_log_adapter_timeout = 1;
					r_en_timer 		=  0;
				end 
				else begin
					r_en_timer 		=  1;
					r_mode_timer 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  1;
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 	=  1;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  0;
				o_sb_lp_valid 			=  0;
				o_sb_lp_adv_cap_val 	=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 		=  0;
			end

			SEND_SB_ACTIVE_RSP : begin
				
				if (w_sb_busy_detected_flag) begin
					w_en_transition_after_sb_busy_detected_flag = 1;
				end

				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  1; //it must remain 1 till i exist from active state
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 	=  1;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  SB_ADAPTER_RSP_ACTIVE;
				o_sb_lp_valid 			=  1;
				o_sb_lp_adv_cap_val 	=  0;
				r_RX_done_flag 			=  1;
				r_IS_NOP_SENT_flag 		=  0;
			end



			ACTIVE : begin
				o_fdi_pl_state_sts 		=  ACTIVE_STS;
				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  1;
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 	=  0;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  0;
				o_sb_lp_valid 			=  0;
				o_sb_lp_adv_cap_val 	=  0;

				r_TX_done_flag 			=  0;
				r_RX_done_flag 			=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 		=  0;

				o_fdi_pl_speedmode 		=  i_rdi_pl_speedmode;
				o_fdi_pl_lnk_cfg 		=  i_rdi_pl_lnk_cfg;
			end

			PROPAGATE_RETRAIN_REQ_TO_PHY : begin
				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(w_timeout_flag) begin
					o_log_state_status_transition_timeout = 1;
					r_en_timer 		=  0;
				end 
				else begin
					r_en_timer 		=  1;
					r_mode_timer 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_fdi_pl_state_sts 		=  ACTIVE_STS;
				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0; ////// !!!!!!!!!
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 	=  1;
				o_rdi_lp_state_req 		=  RETRAIN_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  0;
				o_sb_lp_valid 			=  0;
				o_sb_lp_adv_cap_val 	=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 		=  0;

				o_fdi_pl_speedmode 		=  i_rdi_pl_speedmode;
				o_fdi_pl_lnk_cfg 		=  i_rdi_pl_lnk_cfg;
			end

			RETRAIN : begin
				o_fdi_pl_state_sts 		=  RETRAIN_STS;
				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 	=  1;
				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  0;
				o_sb_lp_valid 			=  0;
				o_sb_lp_adv_cap_val 	=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 		=  0;

				o_fdi_pl_speedmode 		=  i_rdi_pl_speedmode;
				o_fdi_pl_lnk_cfg 		=  i_rdi_pl_lnk_cfg;

				o_fdi_pl_speedmode 		=  i_rdi_pl_speedmode;
				o_fdi_pl_lnk_cfg 		=  i_rdi_pl_lnk_cfg;
			end

			

			PROPAGATE_LINKERROR_TO_PHY : begin
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 	=  0;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  1;
				o_sb_lp_decode 			=  0;
				o_sb_lp_valid 			=  0;
				o_sb_lp_adv_cap_val 	=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 		=  0;
			end

			LINKERROR : begin
				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(w_timeout_flag) begin
					r_en_timer 		=  0;
				end 
				else begin
					r_en_timer 		=  1;
					r_mode_timer 	=  1;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////
				o_fdi_pl_state_sts 		=  LINKERROR_STS;
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 	=  0;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_sb_lp_decode 			=  0;
				o_sb_lp_valid 			=  0;
				o_sb_lp_adv_cap_val 	=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 		=  0;
			end

			SEND_SB_LINKRESET_REQ : begin
				
				if (w_sb_busy_detected_flag) begin
					w_en_transition_after_sb_busy_detected_flag = 1;
				end


				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(w_timeout_flag) begin
					o_log_adapter_timeout = 1;
					r_en_timer 		=  0;
				end 
				else begin
					r_en_timer 		=  1;
					r_mode_timer 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 	=  0;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  SB_ADAPTER_REQ_LINKRESET;
				o_sb_lp_valid 			=  1;
				o_sb_lp_adv_cap_val 	=  0;
				r_IS_NOP_SENT_flag 		=  0;
			end

			SEND_SB_LINKRESET_RSP : begin
				
				if (w_sb_busy_detected_flag) begin
					w_en_transition_after_sb_busy_detected_flag=1;
				end

				o_fdi_pl_state_sts 		=  LINKRESET_STS;
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 	=  0;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  SB_ADAPTER_RSP_LINKRESET;
				o_sb_lp_valid 			=  1;
				o_sb_lp_adv_cap_val 	=  0;
				r_IS_NOP_SENT_flag 		=  0;
			end

			PROPAGATE_LINKRESET_REQ_TO_PHY : begin
				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(w_timeout_flag) begin
					o_log_state_status_transition_timeout = 1;
					r_en_timer 		=  0;
				end 
				else begin
					r_en_timer 		=  1;
					r_mode_timer 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_fdi_pl_state_sts 		=  LINKRESET_STS;
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 	=  0;
				o_rdi_lp_state_req 		=  LINKRESET_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  0;
				o_sb_lp_valid 			=  0;
				o_sb_lp_adv_cap_val 	=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 		=  0;
			end

			LINKRESET : begin

				o_fdi_pl_state_sts 		=  LINKRESET_STS;
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 	=  0;
				o_rdi_lp_linkerror 		=  0;
				o_sb_lp_decode 			=  0;
				o_sb_lp_valid 			=  0;
				o_sb_lp_adv_cap_val 	=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 		=  0;
			end

			PROPAGATE_ACTIVE_REQ_TO_PHY : begin
				
				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(w_timeout_flag) begin
					o_log_state_status_transition_timeout = 1;
					r_en_timer 		=  0;
				end 
				else begin
					r_en_timer 		=  1;
					r_mode_timer 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////
				o_fdi_pl_inband_pres 		=  0;
				o_pl_trainerror_i 			=  0;
				o_fdi_pl_rx_active_req 		=  0;
				o_fdi_pl_protocol_vld 		=  0;

				o_pl_phyinrecenter_i 		=  0;
				o_rdi_lp_state_req 			=  ACTIVE_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_sb_lp_decode 				=  0;
				o_sb_lp_valid 				=  0;
				o_sb_lp_adv_cap_val 		=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 			=  0;
			end

			default : begin
				o_fdi_pl_state_sts 			=  RESET_STS;
				o_fdi_pl_inband_pres 		=  0;
				o_pl_trainerror_i 			=  0;
				o_fdi_pl_rx_active_req 		=  0;
				o_fdi_pl_protocol 			=  0;
				o_fdi_pl_protocol_flitfmt 	=  0;
				o_fdi_pl_protocol_vld 		=  0;

				o_pl_phyinrecenter_i 		=  0;
				o_rdi_lp_state_req 			=  NOP_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_sb_lp_decode 				=  0;
				o_sb_lp_valid 				=  0;
				o_sb_lp_adv_cap_val 		=  0;
				w_en_transition_after_sb_busy_detected_flag = 0;
				r_IS_NOP_SENT_flag 			=  0;
			end
		endcase
	end

	always @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			r_fdi_pl_state_sts_temp			<= 0;
			r_fdi_pl_inband_pres_temp		<= 0;
			r_pl_trainerror_i_temp			<= 0;
			r_fdi_pl_rx_active_req_temp		<= 0;
			r_fdi_pl_protocol_temp  		<= 0;
			r_fdi_pl_protocol_flitfmt_temp	<= 0;
			r_fdi_pl_protocol_vld_temp		<= 0;
			r_fdi_pl_speedmode_temp			<= 0;
			r_fdi_pl_lnk_cfg_temp			<= 0;
			r_pl_phyinrecenter_i_temp		<= 0;

			r_rdi_lp_state_req_temp			<= 0;
			r_rdi_lp_linkerror_temp			<= 0;
			r_sb_lp_decode_temp				<= 0;
			r_sb_lp_valid_temp				<= 0;
			o_sb_lp_adv_cap_val_temp		<= 0;
			r_IS_NOP_SENT_temp 				<= 0;
			r_TX_done_flag_temp				<= 0;
			r_RX_done_flag_temp				<= 0;

			r_transitioned_from_NOP_flag_temp	<= 0;

			r_sb_busy_flag_temp 				<= 0;
			r_en_transition_after_sb_busy_detected_flag_temp <= 0;

			r_log_enabled_caps_temp 		<= 0;
			r_negotiated_caps_temp 			<= 0;
		end
		else begin
			r_fdi_pl_state_sts_temp 		<= o_fdi_pl_state_sts;
			r_fdi_pl_inband_pres_temp 		<= o_fdi_pl_inband_pres;
			r_pl_trainerror_i_temp 			<= o_pl_trainerror_i;
			r_fdi_pl_rx_active_req_temp 	<= o_fdi_pl_rx_active_req;
			r_fdi_pl_protocol_temp 			<= o_fdi_pl_protocol;
			r_fdi_pl_protocol_flitfmt_temp 	<= o_fdi_pl_protocol_flitfmt;
			r_fdi_pl_protocol_vld_temp 		<= o_fdi_pl_protocol_vld;
			r_fdi_pl_speedmode_temp  		<= o_fdi_pl_speedmode;
			r_fdi_pl_lnk_cfg_temp  			<= o_fdi_pl_lnk_cfg;
			r_pl_phyinrecenter_i_temp  		<= o_pl_phyinrecenter_i;

			r_rdi_lp_state_req_temp  		<= o_rdi_lp_state_req;
			r_rdi_lp_linkerror_temp  		<= o_rdi_lp_linkerror;
			r_sb_lp_decode_temp  			<= o_sb_lp_decode;
			r_sb_lp_valid_temp  			<= o_sb_lp_valid;
			o_sb_lp_adv_cap_val_temp   		<= o_sb_lp_adv_cap_val;

			r_IS_NOP_SENT_temp 				<= r_IS_NOP_SENT_flag;
			r_TX_done_flag_temp				<= r_TX_done_flag;
			r_RX_done_flag_temp				<= r_RX_done_flag;

			r_transitioned_from_NOP_flag_temp	<= r_transitioned_from_NOP_flag;

			r_sb_busy_flag_temp 				<= i_sb_busy_flag;
			r_en_transition_after_sb_busy_detected_flag_temp <= w_en_transition_after_sb_busy_detected_flag;

			r_log_enabled_caps_temp 		<= o_log_enabled_caps;
			r_negotiated_caps_temp 			<= r_negotiated_caps;
		end
	end


endmodule