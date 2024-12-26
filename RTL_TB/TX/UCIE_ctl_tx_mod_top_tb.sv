`timescale 1ns/1ps
module UCIE_ctl_tx_mod_top_tb;
  // TB prameters
    localparam 		CLK_PERIOD   = 10;
  // DATA packets: just any cases for testing
    localparam 		DATA_TEST_1  = 64'h 0001_0002_00003_0004;
    localparam 		DATA_TEST_2  = 64'h 0005_0006_00007_0008;
    localparam 		DATA_TEST_3  = 64'h 0009_000A_0000B_000C;
    localparam 		DATA_TEST_4  = 64'h 000C_000D_0000E_000F;
  // TX parameters
    localparam    	FIFO_P_SIZE = 4  ;
    localparam    	FIFO_DEPTH  = 8  ;                       
    localparam    	FIFO_D_SIZE = 64 ;
  // UCIE 1.1 parameters: for testing
	localparam UCIE_RESET       = 0;
	localparam UCIE_ACTIVE      = 1;
	localparam UCIE_LINK_ERROR  = 2;
	localparam UCIE_LINK_RESET   = 3;
  
//----------------------------------------------------------------                       
 // Inputs
	logic i_clk;
	logic i_rst;
	logic [3:0] i_fdi_pl_state_sts;
	logic i_fdi_lp_valid;
	logic i_fdi_lp_irdy;
	logic i_rdi_pl_trdy;
	logic [63:0] i_w_data;

// Outputs
	wire o_tx_overf_err;
	wire o_fdi_pl_trdy;
	wire o_rdi_lp_valid;
	wire o_rdi_lp_irdy;
	wire [63:0] o_r_data;

// Expected Outputs
    logic exp_o_tx_overf_err;
    logic exp_o_fdi_pl_trdy;
    logic exp_o_rdi_lp_valid;
    logic exp_o_rdi_lp_irdy;
    wire [63:0] exp_o_r_data;
  
    logic exp_fsm_fifo_winc;
    logic exp_fsm_fifo_wrst_n;
    logic exp_fsm_fifo_rinc;
    logic exp_fsm_fifo_rrst_n;

	wire  w_wfull  ;
    wire  w_rempty ;

	longint data_array [4];

// --------------------------------------------------------- DUT instantation --------------------------------------------------
	UCIE_ctl_tx_mod_top #(
      .UCIE_ACTIVE 	(UCIE_ACTIVE),
      .FIFO_DEPTH 	(FIFO_DEPTH	),
      .FIFO_P_SIZE 	(FIFO_P_SIZE)
    ) DUT (
		.i_clk					    (i_clk				      ), 
		.i_rst					    (i_rst				      ), 
		.i_fdi_pl_state_sts	(i_fdi_pl_state_sts	), 
		.i_fdi_lp_valid			(i_fdi_lp_valid		), 
		.i_fdi_lp_irdy			(i_fdi_lp_irdy		), 
		.i_rdi_pl_trdy			(i_rdi_pl_trdy		), 
		.o_tx_overf_err			(o_tx_overf_err		), 
		.o_fdi_pl_trdy			(o_fdi_pl_trdy		), 
		.o_rdi_lp_valid			(o_rdi_lp_valid		), 
		.o_rdi_lp_irdy			(o_rdi_lp_irdy		), 
		.i_w_data				    (i_w_data			    ), 
		.o_r_data				    (o_r_data			    )
	);
// --------------------------------------------------------- CLK generator  --------------------------------------------------
  
  always #(CLK_PERIOD/2) i_clk = ~i_clk;

//--------------------------------------------------------  TX FSM MODEL ------------------------------------------------------
  logic [1:0] current_state;
  logic [1:0] next_state   ;
  logic [1:0] current_sub_state1;
  logic [1:0] next_sub_state1;
  
  localparam RESET_TX  = 0;
  localparam ACTIVE_TX = 1;
  
  localparam VALID_DATA = 0;
  localparam OVERFLOW   = 1;
  localparam NO_DATA    = 2;
  
  always @(posedge i_clk, negedge i_rst) begin
	if(!i_rst) begin
	  current_state      = RESET_TX  ;
	  current_sub_state1 = NO_DATA   ;
	end else begin
	  current_state      = next_state;
	  current_sub_state1 = next_sub_state1;
	end
  end

  always_comb begin
	case (current_state)
	  RESET_TX : begin
		exp_o_tx_overf_err  = 0;
		exp_o_fdi_pl_trdy   = 0;
		exp_o_rdi_lp_valid  = 0;
		exp_o_rdi_lp_irdy   = 0;
		exp_fsm_fifo_winc   = 0;
		exp_fsm_fifo_wrst_n = 0;
		exp_fsm_fifo_rinc   = 0;
		exp_fsm_fifo_rrst_n = 0;
		next_state          = (i_fdi_pl_state_sts == UCIE_ACTIVE)? ACTIVE_TX : RESET_TX;
		next_sub_state1     = NO_DATA;
	  end
			  
	  ACTIVE_TX: begin
		exp_fsm_fifo_wrst_n = 1;
		exp_fsm_fifo_rrst_n = 1;
		next_state          = (i_fdi_pl_state_sts != UCIE_ACTIVE)? RESET_TX : ACTIVE_TX;   
		case (current_sub_state1)
		  
		  NO_DATA : begin
			exp_o_tx_overf_err  = 0;
			exp_o_fdi_pl_trdy   = 1;
			exp_fsm_fifo_winc   = i_fdi_lp_irdy & i_fdi_lp_valid;
			exp_o_rdi_lp_valid  = 0;
			exp_o_rdi_lp_irdy   = 0;  

			// State transition handling
			if (~w_wfull && ~w_rempty) begin
			  exp_fsm_fifo_rinc   = 1			;
			  next_sub_state1     = VALID_DATA	;
			end else begin
				exp_fsm_fifo_rinc = 0					;
				next_sub_state1   = current_sub_state1	;
			  end
			end

			VALID_DATA : begin
			  // NO DATA TRANSITION
			  if (w_rempty) begin
				exp_o_tx_overf_err  = 0            					;
				exp_o_fdi_pl_trdy   = 1            					;
				exp_o_rdi_lp_valid  = i_rdi_pl_trdy					;
				exp_o_rdi_lp_irdy   = i_rdi_pl_trdy					;
				exp_fsm_fifo_winc   = i_fdi_lp_irdy & i_fdi_lp_valid;
				exp_fsm_fifo_rinc   = 0			   					;
				next_sub_state1     = NO_DATA      					;
			  // OVERFLOW
			  end else if (i_fdi_lp_irdy & i_fdi_lp_valid & w_wfull) begin
				exp_o_tx_overf_err  = 1            ;
				exp_o_fdi_pl_trdy   = 0            ;
				exp_o_rdi_lp_valid  = i_rdi_pl_trdy;
				exp_o_rdi_lp_irdy   = i_rdi_pl_trdy;
				exp_fsm_fifo_winc   = 0            ;
				exp_fsm_fifo_rinc   = i_rdi_pl_trdy;
				next_sub_state1     = OVERFLOW     ;
			  // normal case
			  end else begin
				exp_o_tx_overf_err  = 0                 			;
				exp_o_fdi_pl_trdy   = 1                 			;
				exp_o_rdi_lp_valid  = i_rdi_pl_trdy     			;
				exp_o_rdi_lp_irdy   = i_rdi_pl_trdy     			;
				exp_fsm_fifo_winc   = i_fdi_lp_irdy & i_fdi_lp_valid;
				exp_fsm_fifo_rinc   = i_rdi_pl_trdy     			;
				next_sub_state1     = current_sub_state1			;
			  end
			end         

			OVERFLOW: begin
			  exp_o_tx_overf_err  = 1;
			  exp_fsm_fifo_winc   = 0;
			  exp_fsm_fifo_rinc   = 0;
			  exp_o_fdi_pl_trdy   = 0;
			  exp_o_rdi_lp_valid  = 0;
			  exp_o_rdi_lp_irdy   = 0;
			  next_sub_state1     = current_sub_state1;
			end

		//  just for safty
			default: begin
				exp_o_tx_overf_err  = 0;
				exp_fsm_fifo_winc   = 0;
				exp_fsm_fifo_rinc   = 0;
				exp_o_fdi_pl_trdy   = 0;
				exp_o_rdi_lp_valid  = 0;
				exp_o_rdi_lp_irdy   = 0;
				next_sub_state1     = current_sub_state1;
			  end 
		endcase
	  end
	endcase
  end
// ------------------------------------------------------ TX FIFO Model instance -------------------------------------------
  
  UCIE_ctl_tx_async_fifo #(
    .DSIZE (FIFO_D_SIZE),
    .ASIZE (FIFO_P_SIZE)
  )  
    fifo_model_inst (
      .wclk  	  (i_clk       		    ),
      .rclk  	  (i_clk       		    ),
      .wrst_n 	(exp_fsm_fifo_wrst_n),
      .rrst_n 	(exp_fsm_fifo_rrst_n),
      .winc  	  (exp_fsm_fifo_winc	),
      .rinc  	  (exp_fsm_fifo_rinc	),
      .wfull   	(w_wfull 			      ),
      .rempty  	(w_rempty			      ),
      .wdata 	  (i_w_data    		    ),
      .rdata 	  (exp_o_r_data    	  )
  );

//------------------------------------------------------------ Test tasks -----------------------------------------------------
	always @(negedge i_clk) begin
	if( 
		(exp_o_tx_overf_err	== o_tx_overf_err	)	&&
		(exp_o_fdi_pl_trdy	== o_fdi_pl_trdy	)	&&
		(exp_o_rdi_lp_valid	== o_rdi_lp_valid	)	&&
		(exp_o_rdi_lp_irdy	== o_rdi_lp_irdy	)	&&
		(exp_o_r_data		== o_r_data			)
	) begin
	  $display ("\n---------------------Test case SUCCEEDED -------------------\n");
	  $display ("case info: \n"     );
	  $display ("@ TIME = %t ", $time());
	  $display("i_fdi_pl_state_sts = %b ", i_fdi_pl_state_sts );
	  $display("i_fdi_lp_valid = %b "    , i_fdi_lp_valid     );
	  $display("i_fdi_lp_irdy = %b "     , i_fdi_lp_irdy      );
	  $display("i_rdi_pl_trdy = %b "     , i_rdi_pl_trdy      );
	  $display("i_w_data = %h "     	 , i_w_data     	  );
	  $display(" ============================================ ");
	  $display ("exp_o_tx_overf_err  = %h      o_tx_overf_err  = %h"  , exp_o_tx_overf_err  , o_tx_overf_err );
	  $display ("exp_o_fdi_pl_trdy   = %h      o_fdi_pl_trdy   = %h"  , exp_o_fdi_pl_trdy   , o_fdi_pl_trdy  );
	  $display ("exp_o_rdi_lp_valid  = %h      o_rdi_lp_valid  = %h"  , exp_o_rdi_lp_valid  , o_rdi_lp_valid );
	  $display ("exp_o_rdi_lp_irdy   = %h      o_rdi_lp_irdy   = %h"  , exp_o_rdi_lp_irdy   , o_rdi_lp_irdy  );
	  $display ("exp_o_r_data   = %h           o_r_data   = %h"  	  , exp_o_r_data   		, o_r_data  	 );

  end else begin
	  $display ("\n----------------------- Test case FAILED  ---------------------\n");
	  $display ("case info: \n"     );
	  $display ("@ TIME = %t ", $time());
	  $display("i_fdi_pl_state_sts = %b ", i_fdi_pl_state_sts );
	  $display("i_fdi_lp_valid = %b "    , i_fdi_lp_valid     );
	  $display("i_fdi_lp_irdy = %b "     , i_fdi_lp_irdy      );
	  $display("i_rdi_pl_trdy = %b "     , i_rdi_pl_trdy      );
	  $display("i_w_data = %h "     	 , i_w_data     	  );
	  $display(" ============================================ ");
	  $display ("exp_o_tx_overf_err  = %h      o_tx_overf_err  = %h"  , exp_o_tx_overf_err  , o_tx_overf_err );
	  $display ("exp_o_fdi_pl_trdy   = %h      o_fdi_pl_trdy   = %h"  , exp_o_fdi_pl_trdy   , o_fdi_pl_trdy  );
	  $display ("exp_o_rdi_lp_valid  = %h      o_rdi_lp_valid  = %h"  , exp_o_rdi_lp_valid  , o_rdi_lp_valid );
	  $display ("exp_o_rdi_lp_irdy   = %h      o_rdi_lp_irdy   = %h"  , exp_o_rdi_lp_irdy   , o_rdi_lp_irdy  );
	  $display ("exp_o_r_data   = %h           o_r_data   = %h"  	  , exp_o_r_data   		, o_r_data  	 );
	  end
	end
// ------------------------------------------------------- Test Tasks ----------------------------------------------------
  task initialize;
// Initialize Inputs
  begin
	i_clk = 0;
	i_rst = 0;
	i_fdi_pl_state_sts = 0;
	i_fdi_lp_valid = 0;
	i_fdi_lp_irdy = 0;
	i_rdi_pl_trdy = 0;
	i_w_data = 0;
	@(negedge i_clk)
	i_rst = 1;
  end
  endtask

  task TX_accept_fdi(
	input longint DATA [4]
  );
	int i;
  begin
		i = 1;
	  i_fdi_pl_state_sts = UCIE_ACTIVE;
	  i_fdi_lp_valid = 1;
	  i_fdi_lp_irdy = 1;
	  i_w_data = DATA [0];
	  @ (posedge o_fdi_pl_trdy)
	  while (i < 4) begin
		if (o_fdi_pl_trdy) begin
			@(posedge i_clk)
			i_w_data = DATA [i];
			i = i + 1;
		end
	  end
	  @ (posedge i_clk)
	  i_fdi_lp_valid = 0;
	  i_fdi_lp_irdy = 0;
	end
endtask

task TX_send_rdi;
  begin
	repeat (5) @(posedge i_clk) 
	  i_rdi_pl_trdy = 1;
  end
endtask

task overflow_err;
  begin
	i_fdi_pl_state_sts = UCIE_ACTIVE;
	i_fdi_lp_valid = 1;
	i_fdi_lp_irdy = 1;
	i_rdi_pl_trdy = 0;
	i_w_data = DATA_TEST_1;
	# ((FIFO_DEPTH + 20)* CLK_PERIOD) // ANY PERIOD > FIFO DEPTH
	i_fdi_pl_state_sts = UCIE_LINK_ERROR;
	# (CLK_PERIOD)
	i_fdi_pl_state_sts = UCIE_RESET;
  end
endtask

//-------------------------------------------------------- INITIAL BLOCK -----------------------------------------------
  initial begin
  	data_array = {DATA_TEST_1, DATA_TEST_2, DATA_TEST_3, DATA_TEST_4};
  	initialize();
  	TX_accept_fdi(data_array);
  	TX_send_rdi();
  	overflow_err();
	# (4*CLK_PERIOD)
	$stop();
  end
endmodule
