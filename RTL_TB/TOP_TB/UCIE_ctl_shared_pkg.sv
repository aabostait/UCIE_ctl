package UCIE_ctl_shared_pkg;

	typedef enum logic [4:0] {	GLOBAL_RESET 					= 5'b00000,
								RESET 							= 5'b00001,
								REQ_ACTIVE_STATE_ON_PHY			= 5'b00011,
								SEE_CAPS						= 5'b00010,
								PARAMETER_NEGOTIATION_FALIED	= 5'b00110,
								PARAMETER_NEGOTIATION_DONE		= 5'b00111,
								SEND_SB_ACTIVE_REQ				= 5'b00101,
								SB_ACTIVE_RSP_RECEIVED			= 5'b00100,
								WAIT_RX_STATE					= 5'b01100,
								OPEN_RX							= 5'b01101,
								SEND_SB_ACTIVE_RSP				= 5'b01111,
								ACTIVE							= 5'b01110,
								PROPAGATE_RETRAIN_REQ_TO_PHY	= 5'b01010,
								RETRAIN							= 5'b01011,
								PROPAGATE_LINKERROR_TO_PHY		= 5'b01001,
								LINKERROR 						= 5'b01000,
								SEND_SB_LINKRESET_REQ			= 5'b11000,
								SEND_SB_LINKRESET_RSP			= 5'b11001,
								PROPAGATE_LINKRESET_REQ_TO_PHY	= 5'b11011,
								LINKRESET 						= 5'b11010,
								PROPAGATE_ACTIVE_REQ_TO_PHY		= 5'b11110} e_states;

	typedef enum logic [3:0] {	NOP_REQ 						= 4'b0000,
	  							ACTIVE_REQ 						= 4'b0001,
	 							LINKRESET_REQ 					= 4'b1001,
	 							RETRAIN_REQ 					= 4'b1011} 	e_request;

	typedef enum logic [3:0] {	RESET_STS 						= 4'b0000,
	  							ACTIVE_STS 						= 4'b0001,
	 							LINKRESET_STS 					= 4'b1001,
	 							LINKERROR_STS 					= 4'b1010,
	 							RETRAIN_STS 					= 4'b1011} 	e_status;

	typedef enum logic [4:0] {	SB_ADV_CAP_ADAPTER 				= 5'b00000,
								SB_ADAPTER_REQ_ACTIVE 			= 5'b10101,
								SB_ADAPTER_RSP_ACTIVE 			= 5'b11001,
	 							SB_ADAPTER_REQ_LINKRESET 		= 5'b10111,
	 							SB_ADAPTER_RSP_LINKRESET 		= 5'b11011,
	 							SB_MSG_ERROR_CORRECTABLE 		= 5'b11100,
	 							SB_MSG_ERROR_NON_FATAL 			= 5'b11101,
	 							SB_MSG_ERROR_FATAL 				= 5'b11110} e_SB_msg;


	typedef enum logic [3:0] {RAW_FORMAT = 4'b0001} e_format;

	typedef enum logic [2:0] {	STREAMING_PROTOCOL				= 3'b111,
							 	PCIE_PROTOCOL 					= 3'b000,
							 	CXL_1_PROTOCOL					= 3'b011} 	e_protocol;


	typedef enum logic [2:0] {	GT_4							= 3'b000,
								GT_8							= 3'b001,
								GT_12							= 3'b010,
								GT_16							= 3'b011,
								GT_24							= 3'b100,
								GT_32							= 3'b101} 	e_speed;


	typedef enum logic [2:0] {	X8								= 3'b001,
								X16								= 3'b010,
								X32								= 3'b011,
								X64								= 3'b100,
								X128							= 3'b101,
								X256							= 3'b110} 	e_lnk_cfg;


	typedef enum logic [7:0] {	UCIE_LINK_CONTROL 				= 8'h10,
								ADVCAP 							= 8'h20,
								INTERNAL_ERROR_MASK_CODE 		= 8'h28,
								ADAPTER_ERROR_MASK_CODE 		= 8'h30,
								UNCORR_ERROR_STATUS_MASK 		= 8'h38}		e_CSR_p_addr;

	typedef enum logic [31:0]{	INITALIZATION 					= 32'h00000000,
								START_UCIE_LINK_TRAINING 		= 32'h00000400,
								RETRAIN_UCIE_LINK 				= 32'h00000800,
								STREAMING_RAW 					= 32'h00000011,
								NOT_STREAMING_RAW 				= 32'h00000082} 	e_CSR_p_data;
	
	typedef enum logic [7:0] {	LINK_STATUS 					= 8'h14,
								INTERNAL_ERROR_STATUS_CODE 		= 8'h24,
								ADAPTER_ERROR_STATUS_CODE 		= 8'h2C,
								UNCORR_ERROR_STATUS 			= 8'h34} 	e_CSR_a_addr;


	typedef enum logic [4:0] {	RDI_PL_ERROR 					= 5'h00,
								RDI_PL_CERROR 					= 5'h01,
								RDI_PL_NFERROR 					= 5'h02,
								RDI_PL_TRAINERROR 				= 5'h03,
								TX_OVERFLOW 					= 5'h04,
								RX_OVERFLOW 					= 5'h05,
								SB_SRC_ERROR 					= 5'h06,
								SB_DST_ERROR 					= 5'h07,
								SB_OPCODE_ERROR 				= 5'h08,
								SB_UNSUPPORTED_MESSAGE 			= 5'h09,
								SB_PARITY_ERROR 				= 5'h0a,
								SB_CORRECTABLE_ERROR_MESSAGE 	= 5'h0b,
								SB_NONFATAL_ERROR_MESSAGE 		= 5'h0c,
								SB_FATAL_ERROR_MESSAGE 			= 5'h0d,
								INVALID_PARAMETER_EXCHANGE 		= 5'h0e,
								PARAMETER_EXCHANGE_TIMEOUT 		= 5'h0f,
								ADAPTER_TIMEOUT 				= 5'h10,
								STATE_STATUS_TRANSITION_TIMEOUT = 5'h11} 	e_err;



	typedef enum logic [4:0] {	MSG_WITHOUT_DATA 				= 5'b10010,
								MSG_WITH_DATA 					= 5'b11011,
								INVALID_OPCODE 					= 5'b11111} e_sb_opcode;





	typedef enum logic [1:0] { 	CSR_START_UCIE_LINK_TRAINING 	= 2'h0,
								PROTOCOL_NOP_ACTIVE_REQ 		= 2'h1,
								PROTOCOL_ACTIVE_REQ 			= 2'h2} 	e_active_trig;
	
	typedef enum logic 		 { 	CSR_RETRAIN_UCIE_LINK 			= 1'b0,
								PROTOCOL_RETRAIN_REQ 			= 1'b1} 	e_retrain_trig;

	typedef enum logic 		 { 	PROTOCOL_NOP_LINKRESET_REQ 		= 1'b0,
								PROTOCOL_LINKRESET_REQ 			= 1'b1} 	e_linkreset_trig;

	typedef enum logic [2:0] { 	CSR_START_UCIE_LINK_TRAINING_WHILE_ACTIVE 	= 3'h0,
								CSR_ADVCAP_MISMATCH 						= 3'h1,
								PROTOCOL_LINKERROR_REQ 						= 3'h2,
								TX_OVERFLOW_LINKERROR_TRIG 					= 3'h3,
								RX_OVERFLOW_LINKERROR_TRIG 					= 3'h4} 	e_linkerror_trig;




	typedef enum logic [1:0] {	RESET_PHY_DATA             					= 2'b00,
                                READY_PHY_DATA             					= 2'b01,
                                RECEIVING_PHY_DATA         					= 2'b11} 	data_transfer_states_e;



    typedef enum logic [1:0] { 	IDLE_PHY_SB_INTERFACE             			= 2'b00,
                                SB_FRM_ADAPTER   							= 2'b01,
                                SB_FRM_PHY       							= 2'b11} 	sb_interface_states_e;


    typedef enum logic [3:0] {
							    RESET_PHY             = 4'b0000,
							    LINK_TRAINIG_PHY      = 4'b0001,
							    WAIT_FOR_ADAPTER_PHY  = 4'b0010,
							    REQ_ACTIVE_PHY        = 4'b0011,
							    RSP_ACTIVE_PHY        = 4'b0100,
							    ACTIVE_PHY            = 4'b0101,
							    RETRAIN_PHY           = 4'b0110,
							    RETRAIN_TX_PHY        = 4'b0111,
							    NOP_PHY               = 4'b1000,
							    LINK_ERR_TX_PHY       = 4'b1001,
							    LINK_RESET_PHY        = 4'b1010,
							    LINK_ERROR_PHY        = 4'b1011,
							    RETRAIN_RX_PHY        = 4'b1100,
							    LINK_RST_TX_PHY       = 4'b1101,
							    RETRAIN_RX_TWO_PHY    = 4'b1110,
    							GLOBAL_RESET_PHY      = 4'b1111 } phy_states_e;


    typedef enum  logic [1:0] {    IDLE_TX       = 2'd0,
                            	   NO_CRED       = 2'd1,
                         		   SENDING       = 2'd2 } SB_TX_e;


	typedef enum  logic [2:0] {      
								   IDLE_SB          = 3'b000,
 								   PHASE_0       	= 3'b001,
   								   PHASE_1       	= 3'b010,
   								   PHASE_2       	= 3'b011,
   								   PHASE_3    	 	= 3'b100,
 								   READY_SB         = 3'b101
														 } SB_RX_e;


	typedef enum logic [1:0] { 	RESET_TX 		= 2'b00,
                              	ACTIVE_TX 		= 2'b10,
                               	OVERFLOW_TX		= 2'b11 }	TX_states_e;


    typedef enum logic [2:0] { 	IDLE_RX     		= 3'b001,
                              	ACTIVE_RX   		= 3'b010,
                               	OVERFLOW_RX 		= 3'b100 }	RX_states_e;


    typedef enum logic [2:0] {	STATE_IDLE 					= 3'b000,
    							STATE_LINK_STATUS   		= 3'b001,
    							STATE_INTERNAL_ERROR_STATUS	= 3'b010,
    							STATE_ADAPTER_ERROR_STATUS 	= 3'b011,
    							STATE_UNCORR_ERROR_STATUS 	= 3'b100,
    							STATE_CLEAR_RETRAIN 		= 3'b101} e_log_states;
    
                               	

        
	


endpackage : UCIE_ctl_shared_pkg