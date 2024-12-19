package shared_pkg;

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
	 							SB_ADAPTER_RSP_LINKRESET 		= 5'b11011} e_SB_msg;


	typedef enum logic [3:0] {RAW_FORMAT = 4'b0001} e_format;

	typedef enum logic [2:0] {	STREAMING_PROTOCOL				= 3'b111,
							 	PCIe_PROTOCOL 					= 3'b000,
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

endpackage : shared_pkg