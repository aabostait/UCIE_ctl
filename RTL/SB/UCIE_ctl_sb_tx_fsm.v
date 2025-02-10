// ************************* Description **************************   //
//  This module is implemented to:-                                   //
//  -- control all the sb_tx module operation control signals/outputs //
// ****************************************************************** //
`include "./defines.svh"
module UCIE_ctl_sb_tx_fsm #(
  parameter NC = `NC
)(
    input               i_clk,
    input               i_rst,
    // CTL interface
    input   wire        i_valid_lp_sb,
    output  reg         o_pl_sb_busy,
    // SB ctrl signals
    output  reg [1:0]   o_buf_en,
    output  reg [1:0]   o_shift_load,
    output  reg [1:0]   o_phase_sel,
    output  reg         o_en_analyser,
    // SB decode analyser mod
    input   wire        i_ignore_data2,
    // RDI interface
    input   wire        i_rdi_pl_cfg_cred,
    output  reg         o_lp_cfg_vld,
    // shifter
    input   wire        i_done_shift
);

    localparam  IDLE_TX       = 2'd0;
    localparam  NO_CRED       = 2'd1;
    localparam  SENDING       = 2'd2;

    reg [1:0]   r_inc_decr_cred;
    reg [1:0]   r_current_state;
    reg [1:0]   r_next_state;
    // supporting 1 cred
    reg         r_cred_counter;
    reg [2:0]   r_sending_counter;
    reg [2:0]   r_sending_counter_temp;

    reg         r_flag;
    //reg         r_flag_temp;


//////////////////////////////////////////////////////////  I Made Some Changes HERE  ///////////////////////////////////

    reg         r_valid_lp_sb;
    wire        w_valid_lp_sb_posedge;

      // Detect rising edge
    assign w_valid_lp_sb_posedge = i_valid_lp_sb & ~r_valid_lp_sb;


        always @(posedge i_clk, negedge i_rst) begin
        if(!i_rst) begin
            r_valid_lp_sb <= 1'b0;
        end else begin
            r_valid_lp_sb <= i_valid_lp_sb;
        end
    end


  //////////////////////////////////////////////////////////  I Made Some Changes HERE ///////////////////////////////////

    // CREDIT COUNTER
    always @(posedge i_clk, negedge i_rst) begin
      if(!i_rst) begin
        r_cred_counter <= 'd1;            
      end else begin
        // MSB = increment and LSM = decrement
        case (r_inc_decr_cred)
          2'd0: begin
            r_cred_counter <= r_cred_counter;
          end
          2'd1: begin
            r_cred_counter <= r_cred_counter - 1;
          end
          2'd2: begin
            r_cred_counter <= r_cred_counter + 1;
          end
          2'd3: begin
            r_cred_counter <= r_cred_counter;
          end
        endcase
      end
    end

    always @(posedge i_clk, negedge i_rst) begin
      if(!i_rst) begin
        r_current_state     <= IDLE_TX;
        r_sending_counter   <= 0;
        r_flag              <= 0;
      end else begin
        r_current_state     <= r_next_state;
        r_sending_counter   <= r_sending_counter_temp;
        if (i_done_shift) begin
          r_flag            <= ~r_flag;
        end else begin
          r_flag            <=  r_flag;
        end
      end
    end





    always @(*) begin
      case (r_current_state)
        IDLE_TX : begin
          o_pl_sb_busy           = 0;
          o_buf_en               = (i_valid_lp_sb & r_cred_counter);
          o_shift_load           = 0;
          o_phase_sel            = 0;
          o_lp_cfg_vld           = 0;
          o_en_analyser          = (i_valid_lp_sb & r_cred_counter);
          r_inc_decr_cred        = 0;
          r_sending_counter_temp = 0;
          r_next_state           = (w_valid_lp_sb_posedge  & r_cred_counter)? SENDING : r_current_state;
        end

        SENDING : begin
          o_pl_sb_busy      = 1;
          o_en_analyser     = 0;

          // CHANGE HERE//


          
          case (NC)

          // Special case for the edged NC value 32
            'd32 : begin
              case (r_sending_counter)
                'd0 : begin
                  o_buf_en          = (i_ignore_data2)? 'b00 : 'b10;
                  o_shift_load      = (i_ignore_data2)? 'b01 : 'b00;
                  //o_pl_sb_busy      = 0;    //******* debuging
                  o_phase_sel       = 0;
                  o_lp_cfg_vld      = 0;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp = (i_ignore_data2)? 'd2: 'd1;
                  if (!i_valid_lp_sb) 
                           r_next_state = IDLE_TX;
                  else
                  r_next_state      = r_current_state;
                end
                'd1 : begin
                  o_buf_en          = 0;
                  o_shift_load      = 'b01;
                  o_phase_sel       = 0;
                  o_lp_cfg_vld      = 0;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp = r_sending_counter_temp  + 1;
                  if (!i_valid_lp_sb) 
                           r_next_state = IDLE_TX;
                  else
                  r_next_state      = r_current_state;
                end
                'd2 : begin
                  o_buf_en          = 0;
                  o_shift_load      = 'b01;
                  o_phase_sel       = 'd1;
                  o_lp_cfg_vld      = 1;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp = r_sending_counter_temp + 1;
                  if (!i_valid_lp_sb) 
                           r_next_state = IDLE_TX;
                  else
                  r_next_state      = r_current_state;
                end
                'd3 : begin
                  o_buf_en          = 0;
                  o_shift_load      = 'b01;
                  o_phase_sel       = 'd2;
                  o_lp_cfg_vld      = 1;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp = r_sending_counter_temp + 1;
                   if (!i_valid_lp_sb) 
                           r_next_state = IDLE_TX;
                  else
                  r_next_state      = r_current_state;
                end
                'd4 : begin
                  o_buf_en          = 0;
                  o_shift_load      = 'b01;
                  o_phase_sel       = 'd3;
                  o_lp_cfg_vld      = 1;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp = r_sending_counter_temp + 1;
                if (!i_valid_lp_sb) 
                           r_next_state = IDLE_TX;
                  else
                  r_next_state      = r_current_state;
                end
                'd5 : begin
                  o_buf_en          = 0;
                  o_shift_load      = 'b00;
                  o_phase_sel       = 'd0;
                  o_lp_cfg_vld      = 0;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp   =  0     ;
                  if (i_rdi_pl_cfg_cred) begin
                    r_inc_decr_cred   =       0;
                    r_next_state      = IDLE_TX;
                  end else begin
                    r_inc_decr_cred   =    'b01;
                    r_next_state      = NO_CRED;
                  end
                end
                default : begin
                  o_buf_en          = 0;
                  o_shift_load      = 0;
                  o_phase_sel       = 0;
                  o_lp_cfg_vld      = 0;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp = 0;
                  r_next_state      = IDLE_TX;
                end
              endcase
            end
            
          // for normal cases NC = 16 , 8 bits
            default: begin
              case (r_sending_counter)
                'd0 : begin
                  o_buf_en          = (i_ignore_data2)? 'b00 : 'b10;
                  o_shift_load      = (i_ignore_data2)? 'b01 : 'b00;
                  //o_pl_sb_busy      = 0;    //******* debuging
                  o_phase_sel       = 0;
                  o_lp_cfg_vld      = 0;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp = (i_ignore_data2)? 'd2: 'd1;
                  r_next_state      = r_current_state;
                end
                'd1 : begin
                  o_buf_en          = 0;
                  o_shift_load      = 'b01;
                  o_phase_sel       = 0;
                  o_lp_cfg_vld      = 0;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp = r_sending_counter_temp  + 1;
                  r_next_state      = r_current_state;
                end
                'd2 : begin
                  o_buf_en          = 0;
                  o_shift_load      = (r_flag)? 'b01 : 'b10;
                  o_phase_sel       = (r_flag)? 'd1 : 'd0;
                  o_lp_cfg_vld      = 1;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp = (r_flag)? r_sending_counter_temp + 1 : r_sending_counter_temp;
                  r_next_state      = r_current_state;
                end
                'd3 : begin
                  o_buf_en          = 0;
                  o_shift_load      = (~r_flag)? 'b01 : 'b10;
                  o_phase_sel       = (~r_flag)? 'd2 : 'd1;
                  o_lp_cfg_vld      = 1;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp = (~r_flag)? r_sending_counter_temp + 1 : r_sending_counter_temp;
                  r_next_state      = r_current_state;
                end
                'd4 : begin
                  o_buf_en          = 0;
                  o_shift_load      = (r_flag)? 'b01 : 'b10;
                  o_phase_sel       = (r_flag)? 'd3 : 'd2;
                  o_lp_cfg_vld      = 1;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp = (r_flag)? r_sending_counter_temp + 1 : r_sending_counter_temp;
                  r_next_state      = r_current_state;
                end
                'd5 : begin
                  o_buf_en          = 0;
                  o_shift_load      = (~r_flag)? 'b00 : 'b10;
                  o_phase_sel       = (~r_flag)? 'd0 : 'd3;
                  o_lp_cfg_vld      = 1;
                  r_inc_decr_cred   = 0;
                  
                  if (~r_flag) begin
                    r_sending_counter_temp   =  0     ;
                    if (i_rdi_pl_cfg_cred) begin
                      r_inc_decr_cred   =       0;
                      r_next_state      = IDLE_TX;
                    end else begin
                      r_inc_decr_cred   =    'b01;
                      r_next_state      = NO_CRED;
                    end
                  end else begin
                      r_sending_counter_temp = r_sending_counter_temp;
                      r_inc_decr_cred   =               0;
                      r_next_state      = r_current_state;
                  end
                
                end
                default : begin
                  o_buf_en          = 0;
                  o_shift_load      = 0;
                  o_phase_sel       = 0;
                  o_lp_cfg_vld      = 0;
                  r_inc_decr_cred   = 0;
                  r_sending_counter_temp = 0;
                  r_next_state      = IDLE_TX;
                end
              endcase
        end
        NO_CRED : begin
          o_pl_sb_busy      =       1;
          o_buf_en          =       0;
          o_shift_load      =       0;
          o_phase_sel       =       0;
          o_lp_cfg_vld      =       0;
          o_en_analyser     =       0;
          r_inc_decr_cred   = (i_rdi_pl_cfg_cred)? 'b10 : 'b00;
          r_sending_counter_temp =       0;
          r_next_state      = (i_rdi_pl_cfg_cred)? IDLE_TX : r_current_state;
        end
      endcase
            end
              
          endcase
    end

endmodule