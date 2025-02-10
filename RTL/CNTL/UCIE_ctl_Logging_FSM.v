`include "./defines.svh"
module UCIE_ctl_Logging_FSM(
  // --------------- Inputs ---------------- //
  input         i_clk,
  input         i_rst,

  // CNTL Signals
  input [3:0]   i_cntl_pl_state_sts,
  input         i_cntl_phyinrecenter,
  input         i_cntl_invalid_parameter_exchange,
  input         i_cntl_parameter_exchange_timeout,
  input         i_cntl_state_status_transition_timeout,
  input         i_cntl_adapter_timeout,
  input [2:0]   i_cntl_pl_speedmode,
  input [2:0]   i_cntl_pl_lnk_cfg,
  input [3:0]   i_cntl_enabled_caps,

  // Phy Signals
  input         i_rdi_pl_error,
  input         i_rdi_pl_cerror,
  input         i_rdi_pl_nferror,
  input         i_rdi_pl_trainerror,
  input         i_rdi_pl_phyinrecenter,

  // SB Signals
  input         i_sb_pl_valid,
  input [4:0]   i_sb_pl_decode,
  input         i_sb_src_error,
  input         i_sb_dst_error,
  input         i_sb_parity_error,
  input         i_sb_opcode_error,
  input         i_sb_unsupported_message,
  
  // TX & RX Signals
  input         i_tx_over_flow,
  input         i_rx_over_flow,

  // --------------- Outputs ---------------- //
  // FDI Signals
  output            o_fdi_pl_error,
  output            o_fdi_pl_cerror,
  output            o_fdi_pl_nferror,
  output            o_fdi_pl_phyinrecenter,
  output            o_fdi_pl_trainerror,

  // CSR Signals
  output reg        o_csr_wr,
  output reg [7:0]  o_csr_addr,
  output reg [31:0] o_csr_wdata
);

// ------------------------ Local Parameters ------------------------ //
// SB ERRORS
localparam SB_MSG_ERROR_CORRECTABLE      = 5'b11100;
localparam SB_MSG_ERROR_NON_FATAL        = 5'b11101;
localparam SB_MSG_ERROR_FATAL            = 5'b11110;

// LINK STATUS
localparam LINK_STATUS_ACTIVE            = 4'b0001;
localparam LINK_STATUS_RETRAIN           = 4'b1011;

// FSM STATES
localparam STATE_IDLE                    = 3'b000;
localparam STATE_LINK_STATUS             = 3'b001;   // Highest Priority
localparam STATE_INTERNAL_ERROR_STATUS   = 3'b010;
localparam STATE_ADAPTER_ERROR_STATUS    = 3'b011;
localparam STATE_UNCORR_ERROR_STATUS     = 3'b100;
localparam STATE_CLEAR_RETRAIN           = 3'b101;

// REGISTERS ADDRESSES
localparam REG_LINK_CONTROL              = 8'h10;
localparam REG_LINK_STATUS               = 8'h14;
localparam REG_INTERNAL_ERROR_STATUS     = 8'h24;
localparam REG_ADAPTER_ERROR_STATUS      = 8'h2c;
localparam REG_UNCORR_ERROR_STATUS       = 8'h34;


// ------------------------ Internal Wires ------------------------ // (_p is pulse generator output)
    // Main Errors
wire w_fdi_pl_error_p, w_fdi_pl_cerror_p, w_fdi_pl_nferror_p,
     w_invalid_parameter_exchange_p, w_fdi_pl_trainerror_p,

     // Train/Retrain Status
     w_fdi_pl_phyinrecenter_p, 

     // SB MSG Errors
     w_sb_correctable, w_sb_nonfatal, w_sb_fatal,
     w_sb_correctable_p, w_sb_nonfatal_p, w_sb_fatal_p,
     w_sb_src_error_p, w_sb_dst_error_p, w_sb_opcode_error_p, w_sb_unsupported_message_p, w_sb_parity_error_p, 

     // Timeouts
     w_state_status_transition_timeout_p, w_adapter_timeout_p, w_parameter_exchange_timeout_p,

     // TX & RX Overflow
     w_tx_over_flow_p, w_rx_over_flow_p,

     // Link Status (Up=1, Down=0)
     w_link_status, w_link_status_p,

     // Indicates Adapter Entered Retrain State
     w_entered_retrain, w_entered_retrain_p;

     // Link Parameters
wire [2:0]  w_fdi_pl_speedmode_p,
            w_fdi_pl_lnk_cfg_p;

     // Supported Capabilities
wire [3:0]  w_enabled_caps_p;



// ------------------------ Internal Registers ------------------------ //
          // State registers
reg [2:0]   r_current_state, r_next_state;
          // Data to be Logged in CSR
reg [31:0]  r_link_status_log_data, r_internal_error_status_log_data, r_uncorr_error_status_log_data, r_adapter_error_status_log_data,
            r_link_status_log_data_temp, r_internal_error_status_log_data_temp, r_uncorr_error_status_log_data_temp, r_adapter_error_status_log_data_temp;

reg [16:0]  r_link_status_log_updates_flag, r_link_status_log_updates_flag_temp;

reg         r_entered_retrain, r_entered_retrain_temp;

// ------------------------ Sub-Module Instantiations ------------------------ //
// Detecting Errors Assertion (using Pulse Generator)
Pulse_Gen #(19) PG_RISING_EDGE (
    .clk(i_clk),
    .rst(i_rst),
    .in ({o_fdi_pl_error,   o_fdi_pl_cerror,   o_fdi_pl_nferror,   i_cntl_invalid_parameter_exchange,   o_fdi_pl_trainerror,
          w_sb_correctable, w_sb_nonfatal,     w_sb_fatal,
          i_sb_src_error,   i_sb_dst_error,    i_sb_opcode_error,   i_sb_unsupported_message,   i_sb_parity_error,
          i_cntl_state_status_transition_timeout,   i_cntl_adapter_timeout,   i_cntl_parameter_exchange_timeout,
          i_tx_over_flow,   i_rx_over_flow,
          w_entered_retrain}
          ),
    .out({w_fdi_pl_error_p, w_fdi_pl_cerror_p, w_fdi_pl_nferror_p, w_invalid_parameter_exchange_p, w_fdi_pl_trainerror_p,
          w_sb_correctable_p, w_sb_nonfatal_p, w_sb_fatal_p,
          w_sb_src_error_p, w_sb_dst_error_p,  w_sb_opcode_error_p, w_sb_unsupported_message_p, w_sb_parity_error_p,
          w_state_status_transition_timeout_p, w_adapter_timeout_p, w_parameter_exchange_timeout_p,
          w_tx_over_flow_p, w_rx_over_flow_p,
          w_entered_retrain_p}
          )
    );

Pulse_Gen_2_Edges #(12) PG_BOTH_EDGES (
    .clk(i_clk),
    .rst(i_rst),
    .in ({w_link_status,        o_fdi_pl_phyinrecenter,
          i_cntl_pl_speedmode,   i_cntl_pl_lnk_cfg,
          i_cntl_enabled_caps}
          ),
    .out({w_link_status_p,      w_fdi_pl_phyinrecenter_p,
          w_fdi_pl_speedmode_p, w_fdi_pl_lnk_cfg_p,
          w_enabled_caps_p}
          )
    );


// ------------------------------------------------ Logic Start ------------------------------------------------ //

// Forwarding Errors to Protocol Layer
/*
    - Some of the Errors are forwarded as is because no internal errors
    arise from the Adapter... pl_error, pl_cerror, pl_nferror.

    - pl_trainerror can be asserted from the adapter on parameter negotiation
    failure (i_cntl_invalid_parameter_exchange), or originate from physical layer (i_rdi_pl_trainerror).

    - pl_phyinrecenter is asserted when adapter is training/retraining or
    when physical layer is training/retraining.
*/
assign o_fdi_pl_error           = i_rdi_pl_error;
assign o_fdi_pl_cerror          = i_rdi_pl_cerror;
assign o_fdi_pl_nferror         = i_rdi_pl_nferror;
assign o_fdi_pl_trainerror      = i_rdi_pl_trainerror    | i_cntl_invalid_parameter_exchange;
assign o_fdi_pl_phyinrecenter   = i_rdi_pl_phyinrecenter | i_cntl_phyinrecenter;



// SB Received Error Messages
assign w_sb_correctable = (i_sb_pl_decode == SB_MSG_ERROR_CORRECTABLE && i_sb_pl_valid) ? 1'b1 : 1'b0;
assign w_sb_nonfatal    = (i_sb_pl_decode == SB_MSG_ERROR_NON_FATAL   && i_sb_pl_valid) ? 1'b1 : 1'b0;
assign w_sb_fatal       = (i_sb_pl_decode == SB_MSG_ERROR_FATAL       && i_sb_pl_valid) ? 1'b1 : 1'b0;

// Link Status
assign w_link_status     = (i_cntl_pl_state_sts == LINK_STATUS_ACTIVE || i_cntl_pl_state_sts == LINK_STATUS_RETRAIN) ? 1'b1 : 1'b0;
assign w_entered_retrain = (i_cntl_pl_state_sts == LINK_STATUS_RETRAIN) ? 1'b1 : 1'b0;

// Next State Logic
always @(*) begin
    case (r_current_state)
        STATE_IDLE: begin
            if (r_link_status_log_updates_flag || r_link_status_log_data[31:17])
                r_next_state = STATE_LINK_STATUS;
            else if (r_internal_error_status_log_data)
                r_next_state = STATE_INTERNAL_ERROR_STATUS;  
            else if (r_uncorr_error_status_log_data)
                r_next_state = STATE_UNCORR_ERROR_STATUS;
            else if (r_adapter_error_status_log_data)
                r_next_state = STATE_ADAPTER_ERROR_STATUS;
            else if (r_entered_retrain)
                r_next_state = STATE_CLEAR_RETRAIN;
            else
                r_next_state = STATE_IDLE;
        end

        STATE_CLEAR_RETRAIN: begin
            r_next_state = STATE_IDLE;
        end

        STATE_LINK_STATUS: begin
            if (r_internal_error_status_log_data)
                r_next_state = STATE_INTERNAL_ERROR_STATUS;
            else if (r_uncorr_error_status_log_data)
                r_next_state = STATE_UNCORR_ERROR_STATUS;
            else if (r_adapter_error_status_log_data)
                r_next_state = STATE_ADAPTER_ERROR_STATUS;
            else
                r_next_state = STATE_IDLE;
        end

        STATE_INTERNAL_ERROR_STATUS: begin
            if (r_link_status_log_updates_flag || r_link_status_log_data[31:17])
                r_next_state = STATE_LINK_STATUS;
            else if (r_uncorr_error_status_log_data)
                r_next_state = STATE_UNCORR_ERROR_STATUS;
            else if (r_adapter_error_status_log_data)
                r_next_state = STATE_ADAPTER_ERROR_STATUS;
            else
                r_next_state = STATE_IDLE;
        end

        STATE_UNCORR_ERROR_STATUS: begin
            if (r_link_status_log_updates_flag || r_link_status_log_data[31:17])
                r_next_state = STATE_LINK_STATUS;
            else if (r_internal_error_status_log_data)
                r_next_state = STATE_INTERNAL_ERROR_STATUS;  
            else if (r_adapter_error_status_log_data)
                r_next_state = STATE_ADAPTER_ERROR_STATUS;
            else
                r_next_state = STATE_IDLE;
        end

        STATE_ADAPTER_ERROR_STATUS: begin
            if (r_link_status_log_updates_flag || r_link_status_log_data[31:17])
                r_next_state = STATE_LINK_STATUS;
            else if (r_internal_error_status_log_data)
                r_next_state = STATE_INTERNAL_ERROR_STATUS;  
            else if (r_uncorr_error_status_log_data)
                r_next_state = STATE_UNCORR_ERROR_STATUS;
            else
                r_next_state = STATE_IDLE;
        end
        
        default : r_next_state = STATE_IDLE;
    endcase
end



// FSM sequential logic
always @(posedge i_clk or negedge i_rst) begin
  if (!i_rst) begin
    r_current_state <= STATE_IDLE;
  end else begin
    r_current_state <= r_next_state;
  end
end




// Output Logic
always @ (*) begin
    // Outputs Initialization
    o_csr_wr    = 0;
    o_csr_addr  = 0;
    o_csr_wdata = 0;

    // Flags Initialization
    r_link_status_log_updates_flag   = r_link_status_log_updates_flag_temp;

    // Data Initialization
    r_link_status_log_data           = r_link_status_log_data_temp;
    r_internal_error_status_log_data = r_internal_error_status_log_data_temp;
    r_uncorr_error_status_log_data   = r_uncorr_error_status_log_data_temp;
    r_adapter_error_status_log_data  = r_adapter_error_status_log_data_temp;

    // ---------------------------- Link Status Register Flag ---------------------------- //
    if (w_enabled_caps_p && (i_cntl_enabled_caps != 0))
        r_link_status_log_updates_flag[3:0]     = {4{(w_enabled_caps_p && (i_cntl_enabled_caps != 0))}};

    if (w_link_status && w_fdi_pl_lnk_cfg_p)
        r_link_status_log_updates_flag[10:7]    = 4'b1111;

    if (w_link_status  && w_fdi_pl_speedmode_p)
        r_link_status_log_updates_flag[14:11]   = 4'b1111;

    if (w_link_status_p)
        r_link_status_log_updates_flag[15]      = 1'b1;

    if (w_fdi_pl_phyinrecenter_p)
        r_link_status_log_updates_flag[16]      = 1'b1;

    // ---------------------------- Link Status Register Data ---------------------------- //
    if (w_enabled_caps_p)           r_link_status_log_data[3:0]   = i_cntl_enabled_caps;
    if (w_link_status)              begin
        if (w_fdi_pl_lnk_cfg_p)     r_link_status_log_data[10:7]  = i_cntl_pl_lnk_cfg;
        if (w_fdi_pl_speedmode_p)   r_link_status_log_data[14:11] = i_cntl_pl_speedmode;
    end
    if (w_link_status_p)            begin
        r_link_status_log_data[15]   = w_link_status;
        r_link_status_log_data[17]   = 1'b1;
    end
    if (w_fdi_pl_phyinrecenter_p)   r_link_status_log_data[16]   = o_fdi_pl_phyinrecenter;
    if (w_fdi_pl_error_p || w_fdi_pl_cerror_p || w_sb_correctable_p) begin
        r_link_status_log_data[19]   = 1'b1;
    end
    if (w_fdi_pl_nferror_p)         r_link_status_log_data[20]   = 1'b1;
    if (w_fdi_pl_trainerror_p)      r_link_status_log_data[21]   = 1'b1;

    // ----------------------- Internal Error Status Register Data ----------------------- //
    if (w_sb_src_error_p)           r_internal_error_status_log_data[0] = 1'b1;
    if (w_sb_dst_error_p)           r_internal_error_status_log_data[1] = 1'b1;
    if (w_sb_opcode_error_p)        r_internal_error_status_log_data[2] = 1'b1;
    if (w_sb_unsupported_message_p) r_internal_error_status_log_data[3] = 1'b1;
    if (w_sb_parity_error_p)        r_internal_error_status_log_data[4] = 1'b1;
    if (w_tx_over_flow_p)           r_internal_error_status_log_data[6] = 1'b1;
    if (w_rx_over_flow_p)           r_internal_error_status_log_data[7] = 1'b1;

    // ----------------------- Adapter Error Status Register Data ------------------------ //
    if (w_parameter_exchange_timeout_p)         r_adapter_error_status_log_data[0]  = 1'b1;
    if (w_state_status_transition_timeout_p)    r_adapter_error_status_log_data[1]  = 1'b1;

    // ------------------------ Uncorr Error Status Register Data ------------------------ //
    if (w_adapter_timeout_p)        r_uncorr_error_status_log_data[0] = 1'b1;
    if (w_rx_over_flow_p)           r_uncorr_error_status_log_data[1] = 1'b1;
    
    if (w_sb_src_error_p     || w_sb_dst_error_p       || w_sb_opcode_error_p
     || w_sb_parity_error_p  || w_sb_unsupported_message_p
     || w_tx_over_flow_p     || w_rx_over_flow_p) begin
        r_uncorr_error_status_log_data[2] = 1'b1;
    end

    if (w_sb_fatal_p)                   r_uncorr_error_status_log_data[3] = 1'b1;
    if (w_sb_nonfatal_p)                r_uncorr_error_status_log_data[4] = 1'b1;
    if (w_invalid_parameter_exchange_p) r_uncorr_error_status_log_data[5] = 1'b1;
            
    // For Clearing Retrain Bit in CSR
    r_entered_retrain         = r_entered_retrain_temp;
    if (w_entered_retrain_p)    r_entered_retrain = 1;


    // ---------------------------------- State Outputs ---------------------------------- //
    case (r_current_state)
        STATE_CLEAR_RETRAIN: begin
            o_csr_wr    = 1;
            o_csr_addr  = REG_LINK_CONTROL;
            o_csr_wdata = 'h0000_0000;

            r_entered_retrain = 0;
        end
        STATE_LINK_STATUS: begin
            o_csr_wr    = 1;
            o_csr_addr  = REG_LINK_STATUS;
            o_csr_wdata = r_link_status_log_data;

            r_link_status_log_data[31:17] = 0;
            r_link_status_log_updates_flag = 0;
        end

        STATE_INTERNAL_ERROR_STATUS: begin
            o_csr_wr    = 1;
            o_csr_addr  = REG_INTERNAL_ERROR_STATUS;
            o_csr_wdata = r_internal_error_status_log_data;

            r_internal_error_status_log_data = 0;
        end

        STATE_UNCORR_ERROR_STATUS: begin
            o_csr_wr    = 1;
            o_csr_addr  = REG_UNCORR_ERROR_STATUS;
            o_csr_wdata = r_uncorr_error_status_log_data;

            r_uncorr_error_status_log_data = 0;
        end

        STATE_ADAPTER_ERROR_STATUS: begin
            o_csr_wr    = 1;
            o_csr_addr  = REG_ADAPTER_ERROR_STATUS;
            o_csr_wdata = r_adapter_error_status_log_data;

            r_adapter_error_status_log_data = 0;
        end

        default : begin
            o_csr_wr    = 0;
            o_csr_addr  = 0;
            o_csr_wdata = 0;
        end
    endcase

end


// Holding Previous Values of Flags and Data
always @(posedge i_clk or negedge i_rst) begin
    if (!i_rst) begin
        r_link_status_log_updates_flag_temp      <= 0;

        r_link_status_log_data_temp              <= 0;
        r_internal_error_status_log_data_temp    <= 0;
        r_uncorr_error_status_log_data_temp      <= 0;
        r_adapter_error_status_log_data_temp     <= 0;

        r_entered_retrain_temp                   <= 0;
    end
    else begin
        r_link_status_log_updates_flag_temp      <= r_link_status_log_updates_flag;

        r_link_status_log_data_temp              <= r_link_status_log_data;
        r_internal_error_status_log_data_temp    <= r_internal_error_status_log_data;
        r_uncorr_error_status_log_data_temp      <= r_uncorr_error_status_log_data;
        r_adapter_error_status_log_data_temp     <= r_adapter_error_status_log_data;

        r_entered_retrain_temp                   <= r_entered_retrain;
    end
end

endmodule