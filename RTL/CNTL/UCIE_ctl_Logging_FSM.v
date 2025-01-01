module UCIE_ctl_Logging_FSM(
  // Inputs
  input i_clk,
  input i_rst,
  input [3:0] i_fdi_pl_state_sts,
  input [2:0] i_rdi_pl_speedmode,
  input [2:0] i_rdi_pl_lnk_cfg,
  input i_rdi_pl_phyinrecenter,
  input i_pl_phyinrecenter_i,
  input i_rdi_pl_error,
  input i_rdi_pl_cerror,
  input i_valid_pl_sb,
  input [4:0] i_rdi_pl_sb_decode,
  input i_sb_src_error,
  input i_sb_dst_error,
  input i_sb_opcode_error,
  input i_sb_unsupported_message,
  input i_sb_parity_error,
  input i_rdi_pl_nferror,
  input i_pl_trainerror_i,
  input i_rdi_pl_trainerror,
  input i_parameter_exchange_timeout,
  input i_state_status_transition_timeout,
  input i_adapter_timeout,
  input i_tx_over_flow,
  input i_rx_over_flow,

  // Outputs
  output o_fdi_pl_error,
  output o_fdi_pl_cerror,
  output o_fdi_pl_nferror,
  output o_fdi_pl_phyinrecenter,
  output o_fdi_pl_trainerror,
  output reg o_a_wr,
  output reg [7:0] o_a_addr,
  output reg [31:0] o_a_wdata
);

// Signal assignments
assign o_fdi_pl_error       = i_rdi_pl_error;
assign o_fdi_pl_cerror      = i_rdi_pl_cerror;
assign o_fdi_pl_nferror     = i_rdi_pl_nferror;
assign o_fdi_pl_phyinrecenter = i_rdi_pl_phyinrecenter | i_pl_phyinrecenter_i;
assign o_fdi_pl_trainerror  = i_rdi_pl_trainerror | i_pl_trainerror_i;
//
wire w_rdi_pl_phyinrecenter_p, w_pl_phyinrecenter_i_p, w_rdi_pl_error_p, w_rdi_pl_cerror_p, w_valid_pl_sb_p, 
     w_sb_src_error_p, w_sb_dst_error_p, w_sb_opcode_error_p, w_sb_unsupported_message_p, w_sb_parity_error_p, 
     w_rdi_pl_nferror_p, w_pl_trainerror_i_p, w_rdi_pl_trainerror_p, 
     w_state_status_transition_timeout_p, w_adapter_timeout_p, w_tx_over_flow_p, w_rx_over_flow_p;

wire w_sb_correctable,w_sb_nonfatal,w_sb_fatal;
assign w_sb_correctable = (i_rdi_pl_sb_decode == 5'b11100 && i_valid_pl_sb ) ? 1 : 0;
assign w_sb_nonfatal = (i_rdi_pl_sb_decode == 5'b11101 && i_valid_pl_sb) ? 1 : 0;
assign w_sb_fatal = (i_rdi_pl_sb_decode == 5'b11110 && i_valid_pl_sb) ? 1 : 0;

//
// Instantiate Pulse_Gen for each wire with updated inputs
Pulse_Gen #(1) pg_rdi_pl_phyinrecenter (.clk(i_clk), .rst(i_rst), .in(i_rdi_pl_phyinrecenter), .out(w_rdi_pl_phyinrecenter_p));
Pulse_Gen #(1) pg_pl_phyinrecenter (.clk(i_clk), .rst(i_rst), .in(i_pl_phyinrecenter_i), .out(w_pl_phyinrecenter_i_p));
Pulse_Gen #(1) pg_rdi_pl_error (.clk(i_clk), .rst(i_rst), .in(i_rdi_pl_error), .out(w_rdi_pl_error_p));
Pulse_Gen #(1) pg_rdi_pl_cerror (.clk(i_clk), .rst(i_rst), .in(i_rdi_pl_cerror), .out(w_rdi_pl_cerror_p));
Pulse_Gen #(1) pg_sb_src_error (.clk(i_clk), .rst(i_rst), .in(i_sb_src_error), .out(w_sb_src_error_p));
Pulse_Gen #(1) pg_sb_dst_error (.clk(i_clk), .rst(i_rst), .in(i_sb_dst_error), .out(w_sb_dst_error_p));
Pulse_Gen #(1) pg_sb_opcode_error (.clk(i_clk), .rst(i_rst), .in(i_sb_opcode_error), .out(w_sb_opcode_error_p));
Pulse_Gen #(1) pg_sb_unsupported_message (.clk(i_clk), .rst(i_rst), .in(i_sb_unsupported_message), .out(w_sb_unsupported_message_p));
Pulse_Gen #(1) pg_sb_parity_error (.clk(i_clk), .rst(i_rst), .in(i_sb_parity_error), .out(w_sb_parity_error_p));
Pulse_Gen #(1) pg_rdi_pl_nferror (.clk(i_clk), .rst(i_rst), .in(i_rdi_pl_nferror), .out(w_rdi_pl_nferror_p));
Pulse_Gen #(1) pg_pl_trainerror (.clk(i_clk), .rst(i_rst), .in(i_pl_trainerror_i), .out(w_pl_trainerror_i_p));
Pulse_Gen #(1) pg_rdi_pl_trainerror (.clk(i_clk), .rst(i_rst), .in(i_rdi_pl_trainerror), .out(w_rdi_pl_trainerror_p));
Pulse_Gen #(1) pg_state_status_transition_timeout (.clk(i_clk), .rst(i_rst), .in(i_state_status_transition_timeout), .out(w_state_status_transition_timeout_p));
Pulse_Gen #(1) pg_adapter_timeout (.clk(i_clk), .rst(i_rst), .in(i_adapter_timeout), .out(w_adapter_timeout_p));
Pulse_Gen #(1) pg_tx_over_flow (.clk(i_clk), .rst(i_rst), .in(i_tx_over_flow), .out(w_tx_over_flow_p));
Pulse_Gen #(1) pg_rx_over_flow (.clk(i_clk), .rst(i_rst), .in(i_rx_over_flow), .out(w_rx_over_flow_p));


//
reg r_link_state,r_link_state_prev,r_status_changed;
reg [2:0] r_ucie_link_errors;   //[0] is correctable error , [1] is nonfatal , [2]is fatal
reg [6:0] r_internal_errors;    //[0] src error, [1]dst error, [2] opcode, [3]unsupported, [4]parity, [5]tx_fifo_of, [6]rx_fifo_of
reg [1:0] r_adapter_errors;     //[0] prarmeter exchange time out , [1] state status tranistion timeout
reg [5:0] r_uncorrectable_errors; //[0] adapter timeout, [1]receiver of, [2]internal error , [3]sb fatal, [4]sb non fatal, [5]invalid parameter exchange

// Local parameters for FSM states
localparam state_link_status             = 2'b00;
localparam state_internal_error_status   = 2'b01;
localparam state_adapter_error_status    = 2'b10;
localparam state_uncorr_error_status     = 2'b11;

// State registers
reg [1:0] r_current_state, r_next_state;

// FSM sequential logic
always @(posedge i_clk or negedge i_rst) begin
  if (!i_rst) begin
    r_current_state <= state_link_status;
  end else begin
    r_current_state <= r_next_state;
  end
end

//state_link_status sequential logic
always @(posedge i_clk or negedge i_rst) begin
  if (!i_rst) begin
    r_link_state<=0;
    r_link_state_prev<=0;
    r_status_changed<=0;
  end else begin
    r_link_state_prev<=r_link_state;
    if(i_fdi_pl_state_sts==5'b01110 || i_fdi_pl_state_sts==5'b01011)
    r_link_state <= 1;
    else
    r_link_state <= 0;
    if ((r_link_state ^ r_link_state_prev)==1)
    r_status_changed<=1;
    else
    r_status_changed<=r_status_changed;
    if (r_current_state==state_link_status && r_status_changed==1)
    r_status_changed<=0;
  end
end

//state_link_status sequential logic
always @(posedge i_clk or negedge i_rst) begin
  if (!i_rst) begin
    r_ucie_link_errors <= 0;
  end else begin
    if (r_current_state == state_link_status && r_ucie_link_errors[0] == 1)
      r_ucie_link_errors[0] <= 0;
    else if (w_sb_correctable || w_rdi_pl_cerror_p || w_rdi_pl_error_p)
      r_ucie_link_errors[0] <= 1;

    if (r_current_state == state_link_status && r_ucie_link_errors[1] == 1)
      r_ucie_link_errors[1] <= 0;
    else if (w_sb_nonfatal || w_rdi_pl_nferror_p)
      r_ucie_link_errors[1] <= 1;

    if (r_current_state == state_link_status && r_ucie_link_errors[2] == 1)
      r_ucie_link_errors[2] <= 0;
    else if (w_sb_fatal || w_pl_trainerror_i_p || w_rdi_pl_trainerror_p || w_adapter_timeout_p || 
             w_state_status_transition_timeout_p || w_sb_src_error_p || w_sb_dst_error_p || 
             w_sb_opcode_error_p || w_sb_parity_error_p || w_sb_unsupported_message_p)
      r_ucie_link_errors[2] <= 1;
  end
end


//state_internal_error_status sequential logic
always @(posedge i_clk or negedge i_rst) begin
  if (!i_rst) begin
    r_internal_errors <= 0;
  end else begin
    if (r_current_state == state_internal_error_status && r_internal_errors[0] == 1)
      r_internal_errors[0] <= 0;
    else if (w_sb_src_error_p)
      r_internal_errors[0] <= 1;

    if (r_current_state == state_internal_error_status && r_internal_errors[1] == 1)
      r_internal_errors[1] <= 0;
    else if (w_sb_dst_error_p)
      r_internal_errors[1] <= 1;

    if (r_current_state == state_internal_error_status && r_internal_errors[2] == 1)
      r_internal_errors[2] <= 0;
    else if (w_sb_opcode_error_p)
      r_internal_errors[2] <= 1;

    if (r_current_state == state_internal_error_status && r_internal_errors[3] == 1)
      r_internal_errors[3] <= 0;
    else if (w_sb_unsupported_message_p)
      r_internal_errors[3] <= 1;

    if (r_current_state == state_internal_error_status && r_internal_errors[4] == 1)
      r_internal_errors[4] <= 0;
    else if (w_sb_parity_error_p)
      r_internal_errors[4] <= 1;

    if (r_current_state == state_internal_error_status && r_internal_errors[5] == 1)
      r_internal_errors[5] <= 0;
    else if (w_tx_over_flow_p)
      r_internal_errors[5] <= 1;

    if (r_current_state == state_internal_error_status && r_internal_errors[6] == 1)
      r_internal_errors[6] <= 0;
    else if (w_rx_over_flow_p)
      r_internal_errors[6] <= 1;
  end
end



//state_adapter_error_status sequential logic
always @(posedge i_clk or negedge i_rst) begin
  if (!i_rst) begin
    r_adapter_errors <= 0;
  end else begin
    if (r_current_state == state_adapter_error_status && r_adapter_errors[0] == 1)
      r_adapter_errors[0] <= 0;
    else if (w_pl_trainerror_i_p)
      r_adapter_errors[0] <= 1;

    if (r_current_state == state_adapter_error_status && r_adapter_errors[1] == 1)
      r_adapter_errors[1] <= 0;
    else if (w_state_status_transition_timeout_p)
      r_adapter_errors[1] <= 1;
  end
end
  


//state_uncorr_error_status sequential logic
always @(posedge i_clk or negedge i_rst) begin
  if (!i_rst) begin
    r_uncorrectable_errors <= 0;
  end else begin
    if (r_current_state == state_uncorr_error_status && r_uncorrectable_errors[0] == 1)
      r_uncorrectable_errors[0] <= 0;
    else if (w_adapter_timeout_p)
      r_uncorrectable_errors[0] <= 1;

    if (r_current_state == state_uncorr_error_status && r_uncorrectable_errors[1] == 1)
      r_uncorrectable_errors[1] <= 0;
    else if (w_rx_over_flow_p)
      r_uncorrectable_errors[1] <= 1;

    if (r_current_state == state_uncorr_error_status && r_uncorrectable_errors[2] == 1)
      r_uncorrectable_errors[2] <= 0;
    else if (w_sb_src_error_p || w_sb_dst_error_p || w_sb_opcode_error_p || 
             w_sb_unsupported_message_p || w_sb_parity_error_p || 
             w_rdi_pl_trainerror_p)
      r_uncorrectable_errors[2] <= 1;

    if (r_current_state == state_uncorr_error_status && r_uncorrectable_errors[3] == 1)
      r_uncorrectable_errors[3] <= 0;
    else if (w_sb_fatal)
      r_uncorrectable_errors[3] <= 1;

    if (r_current_state == state_uncorr_error_status && r_uncorrectable_errors[4] == 1)
      r_uncorrectable_errors[4] <= 0;
    else if (w_sb_nonfatal)
      r_uncorrectable_errors[4] <= 1;

    if (r_current_state == state_uncorr_error_status && r_uncorrectable_errors[5] == 1)
      r_uncorrectable_errors[5] <= 0;
    else if (w_pl_trainerror_i_p)
      r_uncorrectable_errors[5] <= 1;
  end
end


// FSM combinational logic
always @(*) begin
  // Default values
  o_a_wr    = 0;
  o_a_addr  = 0;
  o_a_wdata = 0;
  r_next_state = r_current_state;

  case (r_current_state)
    state_link_status: begin
      // Handle state_link_status logic
      r_next_state = state_internal_error_status; // Example transition
      o_a_wr    = 1;
      o_a_addr  = 'h14;
      o_a_wdata = {10'b0,r_ucie_link_errors,1'b0,r_status_changed, 1'b0, r_link_state,1'b0, i_rdi_pl_speedmode,1'b0, i_rdi_pl_lnk_cfg, 7'b0};
    end

    state_internal_error_status: begin
      // Handle state_internal_error_status logic
      r_next_state = state_adapter_error_status; // Example transition
      o_a_wr    = 1;
      o_a_addr  = 'h24;
      o_a_wdata = {24'b0,r_internal_errors[6:5],1'b0,r_internal_errors[4:0]};
    end

    state_adapter_error_status: begin
      // Handle state_adapter_error_status logic
      r_next_state = state_uncorr_error_status; // Example transition
      o_a_wr    = 1;
      o_a_addr  = 'h2c;
      o_a_wdata = {30'b0,r_adapter_errors};
    end

    state_uncorr_error_status: begin
      // Handle state_uncorr_error_status logic
      r_next_state = state_link_status; // Example transition
      o_a_wr    = 1;
      o_a_addr  = 'h34;
      o_a_wdata = {26'b0,r_uncorrectable_errors};
    end
  endcase
end

endmodule