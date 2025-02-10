  module UCIE_ctl_phy_data_transfer # (
  	parameter NBYTES = 8) (

   // Clock and reset
   input  bit                     i_clk,
   input  bit                     i_rst_n,

   // Adapter (LP) Interface Inputs
   input  logic                   i_rdi_lp_irdy,
   input  logic                   i_rdi_lp_valid,
   input  logic [(NBYTES*8)-1:0]  i_rdi_lp_data,


   // Second DUT Inputs
   input  logic [(NBYTES*8)-1:0]  i_data_received,
   input  logic                   i_data_valid,

   // FSM Control Input 
   input  logic                   i_enable,

   // Test Bench Inputs
   input  logic                   i_phy_req_data_error,
   
   // Adapter (LP) Interface Outputs
   output logic                   o_rdi_pl_trdy,
   output logic                   o_rdi_pl_valid,
   output logic [(NBYTES*8)-1:0]  o_rdi_pl_data,

   // Second DUT Outputs
   output logic[(NBYTES*8)-1:0]   o_data_sent,
   output logic                   o_data_valid

  	);

  // State encoding
  typedef enum logic [1:0] {
    RESET             = 2'b00,
    READY             = 2'b01,
    RECEIVING         = 2'b11
  } data_transfer_states_e;


  // Internal Flags
  data_transfer_states_e r_current_state, w_next_state;

  reg [(NBYTES*8)-1:0] r_rdi_lp_data;


  // State machine
always_ff @(posedge i_clk or negedge i_rst_n) begin 
	if(!i_rst_n) begin
		r_current_state  <= RESET;
	end else begin
		r_current_state  <= w_next_state;
	end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin 
	if(!i_rst_n) begin
		r_rdi_lp_data   <= 0;
	end else begin
		 r_rdi_lp_data   <= i_rdi_lp_data ;
	end
end

  // Next state logic
always_comb begin
	case (r_current_state)
		RESET:begin
			if (i_enable) begin
				w_next_state = READY;
			end else begin
				w_next_state = RESET;
			end
		end

		READY:begin
			if (i_enable && i_rdi_lp_irdy && i_rdi_lp_valid) begin
				w_next_state = RECEIVING;
			end else if(!i_enable) begin
				w_next_state = RESET;
			end else begin
				w_next_state = READY;
			end
		end

		RECEIVING:begin
			if (i_enable && (!i_rdi_lp_valid || !i_rdi_lp_irdy))begin
				w_next_state = READY;
			end else if (!i_enable) begin
				w_next_state = RESET;
			end else begin
				w_next_state = RECEIVING;
			end
		end
	endcase // r_current_state
end

 // Output logic

always_comb begin

	 	   o_rdi_pl_trdy       = 'b0;
  		   o_rdi_pl_valid      = 'b0;
  		   o_rdi_pl_data       = 'b0;
  		   o_data_sent         = 'b0;
           o_data_valid        = 'b0;

 case (r_current_state) 


 	RESET:begin
 		     o_rdi_pl_trdy       = 'b0;
  		   o_rdi_pl_valid      = 'b0;
  		   o_rdi_pl_data       = 'b0;
  		   o_data_sent         = 'b0;
         o_data_valid        = 'b0;
 	end

 	READY:begin
 		     o_rdi_pl_trdy       = 'b1;
  		   if (i_data_valid) begin
  		   o_rdi_pl_data       = i_data_received;
        o_rdi_pl_valid       = 'b1;
  		   end
  		   o_data_sent         = 'b0;
         o_data_valid        = 'b0; 		
 	end

 	RECEIVING:begin
  		   o_rdi_pl_trdy       = 'b1;
  		   if (i_data_valid) begin
  		   o_rdi_pl_data       = i_data_received;
         o_rdi_pl_valid      = 'b1;
  		   end
  		   if (!i_phy_req_data_error) 
  		   o_data_sent         = r_rdi_lp_data;
  		   else 
  		   	o_data_sent        = r_rdi_lp_data ^ 8'b11110010 ;

          o_data_valid        = 'b1;
 	end

 	default: begin
 		       o_rdi_pl_trdy       = 'b0;
   		     o_rdi_pl_valid      = 'b0;
           o_rdi_pl_data       = 'b0;
           o_data_sent         = 'b0;
           o_data_valid        = 'b0;
 	end

 endcase
end

endmodule : UCIE_ctl_phy_data_transfer


     