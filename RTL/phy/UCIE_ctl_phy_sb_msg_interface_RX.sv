module UCIE_ctl_phy_sb_msg_interface_RX # (
    parameter NC = 32) (
    // Clock and reset
    input  bit                     i_clk,
    input  bit                     i_rst_n,
    // Adapter (LP) Interface Inputs
    input  logic                   i_rdi_lp_cfg_crd,
    input  logic                   i_sb_data_valid,
    input  logic          [NC-1:0] i_data_received_sb,
    
    // Adapter (LP) Interface Outputs
    output logic                   o_rdi_pl_cfg_vld,
    output logic          [NC-1:0] o_rdi_pl_cfg
);
    // State encoding
    typedef enum logic [1:0] {
        IDLE             = 2'b00,
        SB_FRM_PHY       = 2'b11,  
        SB_RECIEVED      = 2'b10
    } sb_interface_states_e;

    // Internal Flags
    sb_interface_states_e  r_current_state, w_next_state;

    reg r_internal_counter; //  to show if the phy has credit or not
    reg [NC-1:0] r_data_received_sb; // to save the content of i_data_received_sb input
    reg r_sb_data_valid; //  to store previous value of i_sb_data_valid


    // Edge detection
    wire w_sb_data_valid_negedge;
    assign w_sb_data_valid_negedge = r_sb_data_valid && !i_sb_data_valid;

    always_ff @(posedge i_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin
            r_sb_data_valid <= 1'b0;
        end else begin
            r_sb_data_valid <= i_sb_data_valid;
        end
    end

    // State Memory
    always_ff @(posedge i_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin
            r_current_state <= IDLE;
        end else begin
            r_current_state <= w_next_state;
        end
    end

    // Data and counter logic
    always_ff @(posedge i_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin
            r_internal_counter <= 1'b1; // as we have one credit
            r_data_received_sb <= 'b0;
        end else begin
            r_data_received_sb <= i_data_received_sb;
            
            if (r_current_state == SB_FRM_PHY && w_sb_data_valid_negedge) begin
                r_internal_counter <= 0;
            end
            if (i_rdi_lp_cfg_crd) begin 
                r_internal_counter <= 1;
            end
        end
    end

    // Next state logic 
    always_comb begin
        case (r_current_state)
            IDLE: begin
                if (i_sb_data_valid)
                    w_next_state = SB_FRM_PHY;
                else
                    w_next_state = IDLE;
            end
            SB_FRM_PHY: begin
                if (w_sb_data_valid_negedge)
                    w_next_state = SB_RECIEVED;
                else
                    w_next_state = SB_FRM_PHY;
            end

            SB_RECIEVED: begin
                w_next_state = IDLE;
            end

            default: w_next_state = IDLE;
        endcase
    end

    // Output Logic
    always_comb begin
        o_rdi_pl_cfg_vld = 'b0;
        o_rdi_pl_cfg     = 'b0;
        
        case (r_current_state)
            IDLE: begin
                o_rdi_pl_cfg_vld = 'b0;
                o_rdi_pl_cfg     = 'b0;
            end

            SB_FRM_PHY: begin
                o_rdi_pl_cfg_vld = 'b1;
                if (r_internal_counter)
                    o_rdi_pl_cfg = r_data_received_sb;
                else 
                    o_rdi_pl_cfg = 'b0;
            end

            SB_RECIEVED: begin
              o_rdi_pl_cfg_vld = 'b1;
            if (r_internal_counter)
                    o_rdi_pl_cfg = r_data_received_sb;
                else 
                    o_rdi_pl_cfg = 'b0;
            end

            default: begin
                o_rdi_pl_cfg_vld = 'b0;
                o_rdi_pl_cfg     = 'b0;
            end
        endcase
    end

endmodule