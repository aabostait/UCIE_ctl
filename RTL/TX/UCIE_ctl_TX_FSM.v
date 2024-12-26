
module UCIE_ctl_TX_FSM (
	rst_n				,
	i_fdi_pl_state_sts	,
	clk					,
	i_fdi_lp_valid		,
	i_fdi_lp_irdy		, 
	i_rdi_pl_trdy		, 
	o_tx_overf_err		,
	o_fdi_pl_trdy		, 
	o_rdi_lp_valid		, 
	o_rdi_lp_irdy		,
	wfull				, 
	rempty				, 
	winc				, 
	wrst_n				, 
	rinc				, 
	rrst_n
);

	parameter UCIE_ACTIVE 	= 'b0001;
	localparam RESET 		= 2'b00; 
	localparam ACTIVE 		= 2'b10; 
	localparam OVERFLOW		= 2'b11;

	// i_fdi_pl_state_sts == 0001b : Active
	input 			clk;
	input 			rst_n;
	input [3:0] 	i_fdi_pl_state_sts;
	input 			i_fdi_lp_valid;
	input 			i_fdi_lp_irdy;
	input			i_rdi_pl_trdy;
	input 		 	wfull	;
	input	 		rempty	;
	output reg 		o_tx_overf_err;
	output reg 		o_fdi_pl_trdy;
	output reg		o_rdi_lp_valid;
	output reg		o_rdi_lp_irdy;

	reg [1:0] CS , NS;

	output 	reg 	winc, 		wrst_n;
	output 	reg 	rinc, 		rrst_n;

	
	always @(posedge clk, negedge rst_n) begin : State_Memory
		if(~rst_n) begin
			CS <= RESET;
		end else begin
			CS <= NS;
		end
	end

	always @(*) begin : FSM_of_TX
	
		case(CS)
			RESET:begin
				if(i_fdi_pl_state_sts == UCIE_ACTIVE) begin
					NS = ACTIVE;
				end else begin
					NS = RESET;
				end
			end

			ACTIVE:begin
				if(i_fdi_pl_state_sts != UCIE_ACTIVE) begin
					NS = RESET;
				end else if(wfull && i_fdi_lp_irdy && i_fdi_lp_valid)begin
					NS = OVERFLOW  ;
				end else begin
					NS = ACTIVE	   ;
				end
			end

			OVERFLOW : begin
				if(i_fdi_pl_state_sts != UCIE_ACTIVE) begin
					NS = RESET;
				end else begin
					NS = OVERFLOW;
				end
			end
			default:begin
			 NS = CS;
			end
		endcase
	end
	
	always @(*) begin : OUTPUT_of_TX
		o_tx_overf_err  = 0;
		o_fdi_pl_trdy   = 0;
		rinc            = 0;
		rrst_n          = 0;
		winc            = 0;
		wrst_n          = 0;
		o_rdi_lp_valid  = 0;
		o_rdi_lp_irdy   = 0;
		case (CS)
			RESET: begin
				o_tx_overf_err  = 0;
				o_fdi_pl_trdy   = 0;
				rinc            = 0;
				rrst_n          = 0;
				winc            = 0;
				wrst_n          = 0;
				o_rdi_lp_valid  = 0;
				o_rdi_lp_irdy   = 0;
			end

			ACTIVE: begin
				rrst_n          = 1;
				wrst_n          = 1;

				// overflow predicted, send remaining data to rdi, stop recieving from fdi
				if (wfull && i_fdi_lp_irdy && i_fdi_lp_valid) begin
						o_tx_overf_err  = 1;
						winc            = 0;
						o_fdi_pl_trdy   = 0;
						rrst_n          = 1;
						wrst_n          = 1;
					if(~rempty) begin
							o_rdi_lp_valid  = 1;
							o_rdi_lp_irdy   = 1;
					end else begin
							o_rdi_lp_valid  = 0;
							o_rdi_lp_irdy   = 0;
					end

					if(i_rdi_pl_trdy && o_rdi_lp_irdy && o_rdi_lp_valid) begin
						rinc = 1;
					end  else begin
						rinc = 0;
					end

				// normal sending and reciving data operations
				end else if (~rempty) begin
					o_tx_overf_err  = 0;
					o_fdi_pl_trdy   = 1;
					o_rdi_lp_valid  = 1;
					o_rdi_lp_irdy   = 1;
					if(i_rdi_pl_trdy && o_rdi_lp_irdy && o_rdi_lp_valid) begin
						rinc = 1;
					end else begin
						rinc = 0;
					end
					if(i_fdi_lp_irdy && i_fdi_lp_valid && o_fdi_pl_trdy) begin
						winc = 1;
					end else begin
						winc = 0;
					end
				end else begin
					o_tx_overf_err  = 0;
					rinc            = 0;
					o_fdi_pl_trdy   = 1;
					o_rdi_lp_valid  = 0;
					o_rdi_lp_irdy   = 0;
					if(i_fdi_lp_irdy && i_fdi_lp_valid && o_fdi_pl_trdy) begin
						winc = 1;
					end  else begin
						winc = 0;
					end
				end
			end

			OVERFLOW: begin
				// overflow predicted, send remaining data to rdi, stop recieving from fdi
				o_tx_overf_err  = 1;
				winc            = 0;
				o_fdi_pl_trdy   = 0;
				rrst_n          = 1;
				wrst_n          = 1;
				if(~rempty) begin
					o_rdi_lp_valid  = 1;
					o_rdi_lp_irdy   = 1;
				end else begin
					o_rdi_lp_valid  = 0;
					o_rdi_lp_irdy   = 0;
				end

				if(i_rdi_pl_trdy && o_rdi_lp_irdy && o_rdi_lp_valid) begin
					rinc = 1;
				end  else begin
					rinc = 0;
				end
			end

			default: begin
				// Default outputs for safety
				o_tx_overf_err  = 0;
				o_fdi_pl_trdy   = 0;
				rinc            = 0;
				rrst_n          = 0;
				winc            = 0;
				wrst_n          = 0;
				o_rdi_lp_valid  = 0;
				o_rdi_lp_irdy   = 0;
			end
	    endcase
	end




endmodule

