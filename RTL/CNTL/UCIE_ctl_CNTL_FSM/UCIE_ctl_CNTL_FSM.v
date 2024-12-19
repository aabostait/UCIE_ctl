module UCIE_ctl_CNTL_FSM (
	// FDI signals
	//input i_fdi_lclk,
	input 				i_clk, i_rst_n,
	input 		[3:0] 	i_fdi_lp_state_req,
	input 				i_fdi_lp_rx_active_sts,
	input				i_fdi_lp_linkerror,
	input 				i_fdi_pl_error,
	output reg  [3:0] 	o_fdi_pl_state_sts,
	output reg 			o_fdi_pl_inband_pres,
	output reg 			o_fdi_pl_rx_active_req,
	output reg 	[2:0] 	o_fdi_pl_protocol,
	output reg 	[3:0] 	o_fdi_pl_protocol_flitfmt,
	output reg 			o_fdi_pl_protocol_vld,
	output reg 	[2:0]	o_fdi_pl_speedmode,
	output reg 	[2:0]	o_fdi_pl_lnk_cfg,
	output reg 			o_pl_phyinrecenter_i, // INTERNAL IN ADAPTER IT SELF when go to retrain state
	output reg 			o_pl_trainerror_i, // INTERNAL IN ADAPTER IT SELF when parameter negotiation fail


	// RDI signals 
	//input i_rdi_lclk,
	input 		[3:0] 	i_rdi_pl_state_sts,
	input 				i_rdi_pl_inband_pres,
	input 		[2:0] 	i_rdi_pl_speedmode,
	input 		[2:0] 	i_rdi_pl_lnk_cfg,
	input 		[4:0] 	i_rdi_pl_sb_decode,
	input 				i_valid_pl_sb,
	input 		[31:0] 	i_rdi_pl_adv_cap_val,
	output reg 	[3:0] 	o_rdi_lp_state_req,
	output reg 			o_rdi_lp_linkerror,
	output reg 	[4:0]	o_rdi_lp_sb_decode,
	output reg 			o_valid_lp_sb,
	output reg 	[31:0]	o_rdi_lp_adv_cap_val,



	// CSR Signals
	input  			 	i_CSR_UCIe_Link_Control_Retrain,
	input 		[31:0] 	i_CSR_ADVCAP,

	// TX Signals
	input 				i_overflow_TX,
	input 				i_overflow_RX,



	// SB Module Signals
	input 				i_sb_busy_flag
	);


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	// States Encoding: Gray Code
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




	localparam  NOP_REQ 						= 4'b0000;
	localparam  ACTIVE_REQ 						= 4'b0001;
	localparam 	LINKRESET_REQ 					= 4'b1001;
	localparam 	RETRAIN_REQ 					= 4'b1011;

	localparam  RESET_STS 						= 4'b0000;
	localparam  ACTIVE_STS 						= 4'b0001;
	localparam 	LINKRESET_STS 					= 4'b1001;
	localparam  LINKERROR_STS 					= 4'b1010;
	localparam 	RETRAIN_STS 					= 4'b1011;

	localparam  SB_ADV_CAP_ADAPTER 				= 5'b00000; /////////////////////
	localparam	SB_ADAPTER_REQ_ACTIVE 			= 5'b10101;
	localparam	SB_ADAPTER_RSP_ACTIVE 			= 5'b11001;
	localparam 	SB_ADAPTER_REQ_LINKRESET 		= 5'b10111;
	localparam 	SB_ADAPTER_RSP_LINKRESET 		= 5'b11011;

	localparam  RAW_FORMAT						= 4'b0001;
	localparam  STREAMING_PROTOCOL				= 3'b111;
	localparam  PCIe_PROTOCOL 					= 3'b000;
	localparam  CXL_1_PROTOCOL					= 3'b011;








	reg [4:0] cs, ns;
	reg IS_NOP_SENT;

	reg transitioned_from_NOP_flag;
	reg RX_done_flag, TX_done_flag;
	reg linkreset_req_sent_flag;

	reg en, T;

	wire link_down_signal_i;

	wire i_timeout_flag;


	wire sb_busy_flag_edge_detected;

	reg flag_to_enable_transition_after_busy_detected;


	//declare temp signals 
	//////////////////////////////////////////////////////////////////////////////////
	reg	[3:0]   o_fdi_pl_state_sts_temp;
	reg 		o_fdi_pl_inband_pres_temp;
	reg 		pl_trainerror_i_temp;
	reg 		o_fdi_pl_rx_active_req_temp;
	reg [2:0] 	o_fdi_pl_protocol_temp;
	reg [3:0] 	o_fdi_pl_protocol_flitfmt_temp;	
	reg 		o_fdi_pl_protocol_vld_temp;
	reg [2:0] 	o_fdi_pl_speedmode_temp;
	reg [2:0]	o_fdi_pl_lnk_cfg_temp;
	reg 		pl_phyinrecenter_i_temp;

	reg [3:0] 	o_rdi_lp_state_req_temp;
	reg 		o_rdi_lp_linkerror_temp;
	reg [4:0]	o_rdi_lp_sb_decode_temp;
	reg 		o_valid_lp_sb_temp;
	reg [31:0]	o_rdi_lp_adv_cap_val_temp;
	reg 		TX_done_flag_temp;
	reg 		RX_done_flag_temp;
	reg 		IS_NOP_SENT_temp;
	reg 		transitioned_from_NOP_flag_temp;
	reg 		i_sb_busy_flag_temp;

	reg 		flag_to_enable_transition_after_busy_detected_temp;


	





	Timer  timer(i_clk,i_rst_n,en,T,i_timeout_flag);

	







	assign link_down_signal_i = i_fdi_lp_linkerror || o_pl_trainerror_i || 
								((o_fdi_pl_state_sts == ACTIVE_STS) && (i_overflow_TX || i_overflow_RX));

	assign sb_busy_flag_edge_detected = i_sb_busy_flag && ~i_sb_busy_flag_temp; //edge det

	always @(*) begin
		
		transitioned_from_NOP_flag = transitioned_from_NOP_flag_temp;

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
				else if (link_down_signal_i) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if ((i_fdi_lp_state_req == LINKRESET_REQ) && transitioned_from_NOP_flag_temp) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin
					
					if(	i_rdi_pl_inband_pres || ((i_fdi_lp_state_req == ACTIVE_REQ) && transitioned_from_NOP_flag_temp)) begin
						
						ns = REQ_ACTIVE_STATE_ON_PHY;
						transitioned_from_NOP_flag = 0;

					end
					else if(i_fdi_lp_state_req == NOP_REQ) begin

						transitioned_from_NOP_flag = 1;
						ns = RESET;
						
					end
					else begin
						
						transitioned_from_NOP_flag = 0;
						ns = RESET;

					end

				end			
			end

			REQ_ACTIVE_STATE_ON_PHY : begin
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (link_down_signal_i || i_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
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
				else if (link_down_signal_i || i_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADV_CAP_ADAPTER) && flag_to_enable_transition_after_busy_detected) begin
						
						if (i_CSR_ADVCAP == i_rdi_pl_adv_cap_val) begin
							
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
				else if (link_down_signal_i) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
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
				else if (link_down_signal_i || i_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (i_valid_pl_sb && flag_to_enable_transition_after_busy_detected) begin

						if ((i_rdi_pl_sb_decode == SB_ADAPTER_REQ_ACTIVE) && !RX_done_flag) begin
							
							ns = OPEN_RX;

						end
						else if (i_rdi_pl_sb_decode == SB_ADAPTER_RSP_ACTIVE) begin
							
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
				else if (link_down_signal_i) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (RX_done_flag) begin
						
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
				else if (link_down_signal_i || i_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_ACTIVE)) begin

						ns = OPEN_RX;

					end
					else if (i_fdi_lp_state_req == ACTIVE_REQ && !TX_done_flag) begin
						
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
				else if (link_down_signal_i || i_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
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
				else if (link_down_signal_i) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if (flag_to_enable_transition_after_busy_detected) begin

						if (TX_done_flag) begin

							ns = ACTIVE;

						end
						else begin

							if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_RSP_ACTIVE)) begin
								
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
				else if (link_down_signal_i) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
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
							i_CSR_UCIe_Link_Control_Retrain 	||
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
				else if (link_down_signal_i || i_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
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
				else if (link_down_signal_i) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
					ns = SEND_SB_LINKRESET_RSP;

				end
				else if (i_fdi_lp_state_req == LINKRESET_REQ) begin
					
					ns = SEND_SB_LINKRESET_REQ;

				end
				else begin

					if((i_fdi_lp_state_req == ACTIVE_REQ) && transitioned_from_NOP_flag_temp) begin
						
						ns = REQ_ACTIVE_STATE_ON_PHY;
						transitioned_from_NOP_flag = 0;


					end
					else if(i_fdi_lp_state_req == NOP_REQ) begin

						transitioned_from_NOP_flag = 1;
						ns = RETRAIN;
						
					end
					else begin
						
						transitioned_from_NOP_flag = 0;
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
				else if (!i_timeout_flag) begin

					ns = LINKERROR;

				end
				else begin

					if (link_down_signal_i) begin

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
				else if (link_down_signal_i || i_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else begin

					if (i_valid_pl_sb && flag_to_enable_transition_after_busy_detected) begin

						if (i_rdi_pl_sb_decode == SB_ADAPTER_RSP_LINKRESET) begin
						
							ns = PROPAGATE_LINKRESET_REQ_TO_PHY;

						end
						else if (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET) begin
							
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
				else if (link_down_signal_i) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else begin

					if (flag_to_enable_transition_after_busy_detected) begin

						if (linkreset_req_sent_flag) begin
							
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
				else if (link_down_signal_i || i_timeout_flag) begin
					
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
				else if (link_down_signal_i) begin
					
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
				if (i_rdi_pl_state_sts == LINKERROR_STS) begin
					
					ns = LINKERROR;

				end
				else if (link_down_signal_i || i_timeout_flag) begin
					
					ns = PROPAGATE_LINKERROR_TO_PHY;

				end
				else if (i_valid_pl_sb && (i_rdi_pl_sb_decode == SB_ADAPTER_REQ_LINKRESET)) begin
					
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

		o_fdi_pl_state_sts  		= o_fdi_pl_state_sts_temp;
		o_fdi_pl_inband_pres    	= o_fdi_pl_inband_pres_temp;
		o_pl_trainerror_i 			= pl_trainerror_i_temp;
		o_fdi_pl_rx_active_req 		= o_fdi_pl_rx_active_req_temp;
		o_fdi_pl_protocol 			= o_fdi_pl_protocol_temp;
		o_fdi_pl_protocol_flitfmt 	= o_fdi_pl_protocol_flitfmt_temp;
		o_fdi_pl_protocol_vld 		= o_fdi_pl_protocol_vld_temp;
		o_fdi_pl_speedmode 			= o_fdi_pl_speedmode_temp;
		o_fdi_pl_lnk_cfg 			= o_fdi_pl_lnk_cfg_temp;
		o_pl_phyinrecenter_i 			= pl_phyinrecenter_i_temp;

		o_rdi_lp_state_req  		= o_rdi_lp_state_req_temp;
		o_rdi_lp_linkerror 			= o_rdi_lp_linkerror_temp;
		o_rdi_lp_sb_decode 			= o_rdi_lp_sb_decode_temp;
		o_valid_lp_sb  				= o_valid_lp_sb_temp;
		o_rdi_lp_adv_cap_val 		= o_rdi_lp_adv_cap_val_temp;

		IS_NOP_SENT 				= IS_NOP_SENT_temp;
		en 							= 0;
		T 							= 0;

		TX_done_flag				= TX_done_flag_temp;
		RX_done_flag				= RX_done_flag_temp;

		flag_to_enable_transition_after_busy_detected = flag_to_enable_transition_after_busy_detected_temp;

		case(cs)

			GLOBAL_RESET: begin

				o_fdi_pl_state_sts 		=  RESET_STS;
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;

				if (i_CSR_ADVCAP[4]) begin
					o_fdi_pl_protocol 	=  STREAMING_PROTOCOL;
				end
				else if (i_CSR_ADVCAP[3]) begin
					o_fdi_pl_protocol 	=  PCIe_PROTOCOL;
				end
				else if (i_CSR_ADVCAP[1] || i_CSR_ADVCAP[2] ) begin
					o_fdi_pl_protocol 	=  CXL_1_PROTOCOL;
				end
					
				
				o_fdi_pl_protocol_flitfmt 	=  RAW_FORMAT;
				o_fdi_pl_protocol_vld 		=  0;

				o_fdi_pl_speedmode 			=  i_rdi_pl_speedmode;
				o_fdi_pl_lnk_cfg 			=  i_rdi_pl_lnk_cfg;
				o_pl_phyinrecenter_i 			=  0;
				o_rdi_lp_state_req 			=  NOP_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_rdi_lp_sb_decode  		=  0;
				o_valid_lp_sb 				=  0;
				o_rdi_lp_adv_cap_val 		=  0;

				TX_done_flag 				=  0;
				RX_done_flag 				=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;


			end

			RESET : begin
				o_fdi_pl_state_sts 			=  RESET_STS;
				o_fdi_pl_inband_pres 		=  0;
				o_pl_trainerror_i 			=  0;
				o_fdi_pl_rx_active_req 		=  0;
				o_fdi_pl_protocol_vld 		=  0;

				o_fdi_pl_speedmode 			=  i_rdi_pl_speedmode;
				o_fdi_pl_lnk_cfg 			=  i_rdi_pl_lnk_cfg;
				o_pl_phyinrecenter_i 			=  0;
				o_rdi_lp_state_req 			=  NOP_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_rdi_lp_sb_decode 			=  0;
				o_valid_lp_sb 				=  0;
				o_rdi_lp_adv_cap_val 		=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 				=  0;
				TX_done_flag 				=  0;
				RX_done_flag 				=  0;

			end



			REQ_ACTIVE_STATE_ON_PHY : begin

				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(i_timeout_flag) begin
					en 	=  0;
				end 
				else begin
					en 	=  1;
					T 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;

				o_pl_phyinrecenter_i 		=  1;

				if ( (o_fdi_pl_state_sts== RESET_STS) && i_rdi_pl_inband_pres) begin
					o_rdi_lp_state_req 	=  ACTIVE_REQ;
				end

				else if(IS_NOP_SENT_temp) begin
					o_rdi_lp_state_req 	=  ACTIVE_REQ;
				end
				else begin
					o_rdi_lp_state_req 	=  NOP_REQ;
					IS_NOP_SENT 		=  1;
				end


				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  0;
				o_valid_lp_sb 			=  0;
				o_rdi_lp_adv_cap_val 	=  0;
				flag_to_enable_transition_after_busy_detected =0;


			end

			SEE_CAPS : begin


				if (sb_busy_flag_edge_detected) begin
					flag_to_enable_transition_after_busy_detected=1;
				end


				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(i_timeout_flag) begin
					en 	=  0;
				end 
				else begin
					en 	=  1;
					T 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_fdi_pl_state_sts 		=  RESET_STS;
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;

				// HERE WE HAVE A BUG ^^

				if ( (i_CSR_ADVCAP == i_rdi_pl_adv_cap_val )
				 && (i_valid_pl_sb && i_rdi_pl_sb_decode ==  SB_ADV_CAP_ADAPTER) && i_CSR_ADVCAP[4]  ) begin 
					o_fdi_pl_protocol 	=  STREAMING_PROTOCOL;
				end
				else if (  (i_CSR_ADVCAP ==  i_rdi_pl_adv_cap_val )
				 && (i_valid_pl_sb && i_rdi_pl_sb_decode ==  SB_ADV_CAP_ADAPTER) && i_CSR_ADVCAP[3]) begin
					o_fdi_pl_protocol 	=  PCIe_PROTOCOL;
				end
				else if ((i_CSR_ADVCAP ==  i_rdi_pl_adv_cap_val )
				 && (i_valid_pl_sb && i_rdi_pl_sb_decode ==  SB_ADV_CAP_ADAPTER) && (i_CSR_ADVCAP[1] || i_CSR_ADVCAP[2]) ) begin
					o_fdi_pl_protocol 	=  CXL_1_PROTOCOL;
				end

				o_fdi_pl_protocol_flitfmt 	=  RAW_FORMAT;
				o_fdi_pl_protocol_vld 		=  0;

				o_pl_phyinrecenter_i 			=  1;
				o_rdi_lp_state_req 			=  NOP_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_rdi_lp_sb_decode 			=  SB_ADV_CAP_ADAPTER;
				o_valid_lp_sb 				=  1;
				o_rdi_lp_adv_cap_val 		=  i_CSR_ADVCAP;
				IS_NOP_SENT 		=  0;
			end

			PARAMETER_NEGOTIATION_FALIED : begin
				o_fdi_pl_state_sts 			=  RESET_STS;
				o_fdi_pl_inband_pres 		=  0;
				o_pl_trainerror_i 			=  1;
				o_fdi_pl_rx_active_req 		=  0;
				o_fdi_pl_protocol 			=  0;//dummy
				o_fdi_pl_protocol_flitfmt 	=  0; //dummy
				o_fdi_pl_protocol_vld 		=  0; // dummy 

				o_pl_phyinrecenter_i 			=  1;
				o_rdi_lp_state_req 			=  NOP_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_rdi_lp_sb_decode 			=  0;
				o_valid_lp_sb 				=  0;
				o_rdi_lp_adv_cap_val 		=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;

			end

			PARAMETER_NEGOTIATION_DONE : begin
				o_fdi_pl_state_sts 			=  RESET_STS;
				o_fdi_pl_inband_pres 		=  1;
				o_pl_trainerror_i 			=  0;
				o_fdi_pl_rx_active_req 		=  0;
				o_fdi_pl_protocol_vld 		=  1;

				o_pl_phyinrecenter_i 			=  1;
				o_rdi_lp_state_req 			=  NOP_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_rdi_lp_sb_decode 			=  0;
				o_valid_lp_sb 				=  0;
				o_rdi_lp_adv_cap_val 		=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;
			end

			SEND_SB_ACTIVE_REQ : begin
				
				if (sb_busy_flag_edge_detected) begin
					flag_to_enable_transition_after_busy_detected=1;
				end

				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(i_timeout_flag) begin
					en 	=  0;
				end 
				else begin
					en 	=  1;
					T 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 		=  1;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  SB_ADAPTER_REQ_ACTIVE;
				o_valid_lp_sb 			=  1;
				o_rdi_lp_adv_cap_val 	=  0;
				IS_NOP_SENT 		=  0;
			end

			SB_ACTIVE_RSP_RECEIVED : begin
				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 		=  1;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  0;
				o_valid_lp_sb 			=  0;
				o_rdi_lp_adv_cap_val 	=  0;
				TX_done_flag 			=  1;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;

			end

			WAIT_RX_STATE : begin
				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(i_timeout_flag) begin
					en 	=  0;
				end 
				else begin
					en 	=  1;
					T 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 		=  1;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  0;
				o_valid_lp_sb 			=  0;
				o_rdi_lp_adv_cap_val 	=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;

			end

			OPEN_RX : begin

				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(i_timeout_flag) begin
					en 	=  0;
				end 
				else begin
					en 	=  1;
					T 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  1;
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 		=  1;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  0;
				o_valid_lp_sb 			=  0;
				o_rdi_lp_adv_cap_val 	=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;
			end

			SEND_SB_ACTIVE_RSP : begin
				
				if (sb_busy_flag_edge_detected) begin
					flag_to_enable_transition_after_busy_detected=1;
				end

				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  1; //it must remain 1 till i exist from active state
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 		=  1;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  SB_ADAPTER_RSP_ACTIVE;
				o_valid_lp_sb 			=  1;
				o_rdi_lp_adv_cap_val 	=  0;
				RX_done_flag 			=  1;
				IS_NOP_SENT 		=  0;
			end



			ACTIVE : begin
				o_fdi_pl_state_sts 		=  ACTIVE_STS;
				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  1;
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 		=  0;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  0;
				o_valid_lp_sb 			=  0;
				o_rdi_lp_adv_cap_val 	=  0;

				TX_done_flag 			=  0;
				RX_done_flag 			=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;
			end

			PROPAGATE_RETRAIN_REQ_TO_PHY : begin
				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(i_timeout_flag) begin
					en 	=  0;
				end 
				else begin
					en 	=  1;
					T 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_fdi_pl_state_sts 		=  ACTIVE_STS;
				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0; ////// !!!!!!!!!
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 		=  1;
				o_rdi_lp_state_req 		=  RETRAIN_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  0;
				o_valid_lp_sb 			=  0;
				o_rdi_lp_adv_cap_val 	=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;
			end

			RETRAIN : begin
				o_fdi_pl_state_sts 		=  RETRAIN_STS;
				o_fdi_pl_inband_pres 	=  1;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  1;

				o_pl_phyinrecenter_i 		=  1;
				o_rdi_lp_state_req 		=  RETRAIN_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  0;
				o_valid_lp_sb 			=  0;
				o_rdi_lp_adv_cap_val 	=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;
			end

			

			PROPAGATE_LINKERROR_TO_PHY : begin
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 		=  0;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  1;
				o_rdi_lp_sb_decode 		=  0;
				o_valid_lp_sb 			=  0;
				o_rdi_lp_adv_cap_val 	=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;
			end

			LINKERROR : begin
				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(i_timeout_flag) begin
					en 	=  0;
				end 
				else begin
					en 	=  1;
					T 	=  1;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////
				o_fdi_pl_state_sts 		=  LINKERROR_STS;
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 		=  0;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_sb_decode 		=  0;
				o_valid_lp_sb 			=  0;
				o_rdi_lp_adv_cap_val 	=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;
			end

			SEND_SB_LINKRESET_REQ : begin
				
				if (sb_busy_flag_edge_detected) begin
					flag_to_enable_transition_after_busy_detected=1;
				end


				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(i_timeout_flag) begin
					en 	=  0;
				end 
				else begin
					en 	=  1;
					T 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 		=  0;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  SB_ADAPTER_REQ_LINKRESET;
				o_valid_lp_sb 			=  1;
				o_rdi_lp_adv_cap_val 	=  0;
				IS_NOP_SENT 		=  0;
			end

			SEND_SB_LINKRESET_RSP : begin
				
				if (sb_busy_flag_edge_detected) begin
					flag_to_enable_transition_after_busy_detected=1;
				end

				o_fdi_pl_state_sts 		=  LINKRESET_STS;
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 		=  0;
				o_rdi_lp_state_req 		=  NOP_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  SB_ADAPTER_RSP_LINKRESET;
				o_valid_lp_sb 			=  1;
				o_rdi_lp_adv_cap_val 	=  0;
				IS_NOP_SENT 		=  0;
			end

			PROPAGATE_LINKRESET_REQ_TO_PHY : begin
				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(i_timeout_flag) begin
					en 	=  0;
				end 
				else begin
					en 	=  1;
					T 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////

				o_fdi_pl_state_sts 		=  LINKRESET_STS;
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 		=  0;
				o_rdi_lp_state_req 		=  LINKRESET_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  0;
				o_valid_lp_sb 			=  0;
				o_rdi_lp_adv_cap_val 	=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;
			end

			LINKRESET : begin

				o_fdi_pl_state_sts 		=  LINKRESET_STS;
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 		=  0;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  0;
				o_valid_lp_sb 			=  0;
				o_rdi_lp_adv_cap_val 	=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;
			end

			PROPAGATE_ACTIVE_REQ_TO_PHY : begin
				
				/////////////////////////////////////////////////////////////////////
				// for time out trigger
				if(i_timeout_flag) begin
					en 	=  0;
				end 
				else begin
					en 	=  1;
					T 	=  0;
				end
				// for time out trigger
				/////////////////////////////////////////////////////////////////////
				o_fdi_pl_inband_pres 	=  0;
				o_pl_trainerror_i 		=  0;
				o_fdi_pl_rx_active_req 	=  0;
				o_fdi_pl_protocol_vld 	=  0;

				o_pl_phyinrecenter_i 		=  0;
				o_rdi_lp_state_req 		=  ACTIVE_REQ;
				o_rdi_lp_linkerror 		=  0;
				o_rdi_lp_sb_decode 		=  0;
				o_valid_lp_sb 			=  0;
				o_rdi_lp_adv_cap_val 	=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;
			end

			default : begin
				o_fdi_pl_state_sts 			=  RESET_STS;
				o_fdi_pl_inband_pres 		=  0;
				o_pl_trainerror_i 			=  0;
				o_fdi_pl_rx_active_req 		=  0;
				o_fdi_pl_protocol 			=  0;
				o_fdi_pl_protocol_flitfmt 	=  0;
				o_fdi_pl_protocol_vld 		=  0;

				o_fdi_pl_speedmode 			=  i_rdi_pl_speedmode;
				o_fdi_pl_lnk_cfg 			=  i_rdi_pl_lnk_cfg;
				o_pl_phyinrecenter_i 			=  0;
				o_rdi_lp_state_req 			=  NOP_REQ;
				o_rdi_lp_linkerror 			=  0;
				o_rdi_lp_sb_decode 			=  0;
				o_valid_lp_sb 				=  0;
				o_rdi_lp_adv_cap_val 		=  0;
				flag_to_enable_transition_after_busy_detected =0;
				IS_NOP_SENT 		=  0;
			end
		endcase
	end

	always @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			o_fdi_pl_state_sts_temp			<= 0;
			o_fdi_pl_inband_pres_temp		<= 0;
			pl_trainerror_i_temp			<= 0;
			o_fdi_pl_rx_active_req_temp		<= 0;
			o_fdi_pl_protocol_temp  		<= 0;
			o_fdi_pl_protocol_flitfmt_temp	<= 0;
			o_fdi_pl_protocol_vld_temp		<= 0;
			o_fdi_pl_speedmode_temp			<= 0;
			o_fdi_pl_lnk_cfg_temp			<= 0;
			pl_phyinrecenter_i_temp			<= 0;

			o_rdi_lp_state_req_temp			<= 0;
			o_rdi_lp_linkerror_temp			<= 0;
			o_rdi_lp_sb_decode_temp			<= 0;
			o_valid_lp_sb_temp				<= 0;
			o_rdi_lp_adv_cap_val_temp		<= 0;
			IS_NOP_SENT_temp 				<= 0;
			TX_done_flag_temp				<= 0;
			RX_done_flag_temp				<= 0;

			transitioned_from_NOP_flag_temp	<= 0;

			i_sb_busy_flag_temp 				<= 0;
			flag_to_enable_transition_after_busy_detected_temp <=0;
		end
		else begin
			o_fdi_pl_state_sts_temp 		<= o_fdi_pl_state_sts;
			o_fdi_pl_inband_pres_temp 		<= o_fdi_pl_inband_pres;
			pl_trainerror_i_temp 			<= o_pl_trainerror_i;
			o_fdi_pl_rx_active_req_temp 	<= o_fdi_pl_rx_active_req;
			o_fdi_pl_protocol_temp 			<= o_fdi_pl_protocol;
			o_fdi_pl_protocol_flitfmt_temp 	<= o_fdi_pl_protocol_flitfmt;
			o_fdi_pl_protocol_vld_temp 		<= o_fdi_pl_protocol_vld;
			o_fdi_pl_speedmode_temp  		<= o_fdi_pl_speedmode;
			o_fdi_pl_lnk_cfg_temp  			<= o_fdi_pl_lnk_cfg;
			pl_phyinrecenter_i_temp  		<= o_pl_phyinrecenter_i;

			o_rdi_lp_state_req_temp  		<= o_rdi_lp_state_req;
			o_rdi_lp_linkerror_temp  		<= o_rdi_lp_linkerror;
			o_rdi_lp_sb_decode_temp  		<= o_rdi_lp_sb_decode;
			o_valid_lp_sb_temp  			<= o_valid_lp_sb;
			o_rdi_lp_adv_cap_val_temp   	<= o_rdi_lp_adv_cap_val;

			IS_NOP_SENT_temp 				<= IS_NOP_SENT;
			TX_done_flag_temp				<= TX_done_flag;
			RX_done_flag_temp				<= RX_done_flag;

			transitioned_from_NOP_flag_temp	<= transitioned_from_NOP_flag;

			i_sb_busy_flag_temp 				<= i_sb_busy_flag;
			flag_to_enable_transition_after_busy_detected_temp <= flag_to_enable_transition_after_busy_detected;
		end
	end


endmodule