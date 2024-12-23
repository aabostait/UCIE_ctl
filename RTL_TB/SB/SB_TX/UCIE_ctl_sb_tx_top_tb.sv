////////////////////////////////////////////////////////////
// 
`timescale 1ns / 1ps
module UCIE_ctl_sb_tx_top_tb;
  // UCIE 1.1 NC widths 8, 16, and 32
    localparam NC				                      =  32      ;
    // CTRL MSG decodings
    localparam ADV_CAP                              = 5'b00000;
    localparam LINK_MGMT_ADAPTER0_REQ_ACTIVE        = 5'b10101;
    localparam LINK_MGMT_ADAPTER0_REQ_LINK_RESET    = 5'b10111;
    localparam LINK_MGMT_ADAPTER0_RSP_ACTIVE        = 5'b11001;
    localparam LINK_MGMT_ADAPTER0_RSP_LINK_RESET    = 5'b11011;
    localparam ERROR_CORRECTABLE                    = 5'b11100;
    localparam ERROR_NON_FATAL                      = 5'b11101;
    localparam ERROR_FATAL                          = 5'b11110;
  
    // UCIE 1.1 SB messages header codes
    localparam OP_CODE_1        = 5'b10010; // Message without data
    localparam OP_CODE_2        = 5'b11011; // Message with data
  
    localparam MSG_CODE_1       = 8'h01   ;
    localparam MSG_CODE_2       = 8'h03   ;
    localparam MSG_CODE_3       = 8'h04   ;
    localparam MSG_CODE_4       = 8'h09   ;
  
    localparam SUB_CODE_1       = 8'h00   ;
    localparam SUB_CODE_2       = 8'h01   ;
    localparam SUB_CODE_3       = 8'h02   ;
    localparam SUB_CODE_4       = 8'h09   ;
  
    localparam INFO_CODE_1      = 16'h0000;

    localparam srcid = 3'b001;
    localparam dstid = 3'b101;
  
//  CLOCK PERIOD for 2 GT/sec
    localparam CLK_PERIOD       = 0.5     ;

//  Model FSM states
    localparam  IDLE        = 0;
    localparam  SENDING     = 1;
    localparam  NO_CRED     = 2;
    localparam  BUILD_MSG   = 3;  
    
//-------------------------------------------------- Interface signals --------------------------------------------
  // Inputs
  logic         i_clk                   ;
  logic         i_rst                   ;
  logic         i_valid_lp_sb           ;
  logic [4:0]   i_rdi_lp_sb_decode      ;
  logic [31:0]  i_rdi_lp_adv_cap_value  ;
  logic         i_rdi_pl_cfg_crd        ;

  // Actual Outputs
  wire          o_pl_sb_busy        ;
  wire          o_rdi_lp_cfg_vld    ;
  wire [NC-1:0] o_rdi_lp_cfg        ;

  // Expected Outputs
  bit            exp_o_pl_sb_busy     ;
  bit            exp_o_rdi_lp_cfg_vld ;
  bit  [NC-1:0]  exp_o_rdi_lp_cfg     ;

  // Score board activation signal
  bit            score_board_active   ;

  // Modeled Design data types to be used
  logic                     cred_count      ;
  logic   [1:0]             current_state   ;
  logic   [1:0]             next_state      ;
  bit     [127:0]           exp_msg         ;
  logic   [NC-1:0]          cfg_packet      ;
  logic   [NC-1:0]          cfg_packet_temp ;
  logic   [($clog2((32/NC)*4)) - 1:0]       packet_counter  ;
  logic   [($clog2((32/NC)*4)) - 1:0]       packet_counter_temp;

  typedef struct packed {
    bit   [31:0]            phase0          ;
    bit   [31:0]            phase1          ;
    bit   [31:0]            phase2          ;
    bit   [31:0]            phase3          ;
  } message_t;


  
//---------------------------------------------------- CLK generator ------------------------------------------

  always # (CLK_PERIOD/2) i_clk = ~i_clk;  
   
//----------------------------------------------  EXPECTED MODEL functions------------------------------------------

  function bit [127:0] built_msg(
    input message_t message_phases
  );
  begin

    built_msg [31:0] = message_phases.phase0;
    built_msg [63:32] = message_phases.phase1;
    built_msg [95:64] = message_phases.phase2;
    built_msg [128:96] = message_phases.phase3;

  end
  endfunction

//------------------------------------------------- Parity Generator function

  function bit [1:0] parity_gen(
    input bit [31:0] phase0,
    input bit [29:0] phase1,
    input bit [31:0] phase2
  );
  bit [61:0] msg_header;
  
  begin

    msg_header      = {phase1, phase0}  ;
    parity_gen [0]  = ^msg_header       ; // cp
    parity_gen [1]  = ^phase2           ; // dp

  end
  endfunction

// ----------------------------------------------- Message Builder function

  function message_t expected_msg(
    input logic [4:0] ctrl_decode_msg,
    input logic [31:0] advcap_data
  );
  begin

    case (ctrl_decode_msg)
      ADV_CAP: begin // 2 1 1
        expected_msg.phase0 [4:0]   = OP_CODE_2;
        expected_msg.phase0 [21:14] = MSG_CODE_1;
        expected_msg.phase1 [7:0]   = SUB_CODE_1;
        expected_msg.phase2         = advcap_data;
        expected_msg.phase3         = 0;
      end

      LINK_MGMT_ADAPTER0_REQ_ACTIVE: begin // 1 2 2
        expected_msg.phase0 [4:0]   = OP_CODE_1;
        expected_msg.phase0 [21:14] = MSG_CODE_2;
        expected_msg.phase1 [7:0]   = SUB_CODE_2;
        expected_msg.phase2         = 0;
        expected_msg.phase3         = 0;
      end

      LINK_MGMT_ADAPTER0_REQ_LINK_RESET: begin // 1 2 4
        expected_msg.phase0 [4:0]   = OP_CODE_1;
        expected_msg.phase0 [21:14] = MSG_CODE_2;
        expected_msg.phase1 [7:0]   = SUB_CODE_4;
        expected_msg.phase2         = 0;
        expected_msg.phase3         = 0;
      end

      LINK_MGMT_ADAPTER0_RSP_ACTIVE: begin // 1 3 2
        expected_msg.phase0 [4:0]   = OP_CODE_1;
        expected_msg.phase0 [21:14] = MSG_CODE_3;
        expected_msg.phase1 [7:0]   = SUB_CODE_2;
        expected_msg.phase2         = 0;
        expected_msg.phase3         = 0;
      end

      LINK_MGMT_ADAPTER0_RSP_LINK_RESET: begin // 1 3 4
        expected_msg.phase0 [4:0]   = OP_CODE_1;
        expected_msg.phase0 [21:14] = MSG_CODE_3;
        expected_msg.phase1 [7:0]   = SUB_CODE_4;
        expected_msg.phase2         = 0;
        expected_msg.phase3         = 0;
      end

      ERROR_CORRECTABLE: begin
        expected_msg.phase0 [4:0]   = OP_CODE_1;
        expected_msg.phase0 [21:14] = MSG_CODE_4;
        expected_msg.phase1 [7:0]   = SUB_CODE_1;
        expected_msg.phase2         = 0;
        expected_msg.phase3         = 0;
      end

      ERROR_NON_FATAL: begin
        expected_msg.phase0 [4:0]   = OP_CODE_1;
        expected_msg.phase0 [21:14] = MSG_CODE_4;
        expected_msg.phase1 [7:0]   = SUB_CODE_2;
        expected_msg.phase2         = 0;
        expected_msg.phase3         = 0;
      end

      ERROR_FATAL: begin
        expected_msg.phase0 [4:0]   = OP_CODE_1;
        expected_msg.phase0 [21:14] = MSG_CODE_4;
        expected_msg.phase1 [7:0]   = SUB_CODE_3;
        expected_msg.phase2         = 0;
        expected_msg.phase3         = 0;
      end

    endcase

      expected_msg.phase0 [31:29]      = srcid;
      expected_msg.phase1 [26:24]      = dstid;
      expected_msg.phase1 [31:30]      = 
      parity_gen(expected_msg.phase0, expected_msg.phase1 [29:0], expected_msg.phase2);

  end
  endfunction

// ------------------------------------------------- Top Level Model  ----------------------------------------------------------------
      

      always @(posedge i_clk, negedge i_rst) begin
        if(! i_rst) begin
          current_state   = IDLE;
          cfg_packet      =  0  ;
          packet_counter  =  0  ; 
        end else begin
          current_state   = next_state     ;
          cfg_packet      = cfg_packet_temp;
          packet_counter  = packet_counter_temp;
        end        
      end
      
      always_comb begin
        case (current_state)
          IDLE: begin
            exp_o_pl_sb_busy     = 0              ;
            exp_o_rdi_lp_cfg     = cfg_packet     ;
            exp_o_rdi_lp_cfg_vld = 0              ;
            cfg_packet_temp      = cfg_packet_temp;
            cred_count           = 1              ;
            packet_counter_temp  = 0              ;
            if(i_valid_lp_sb) begin
              exp_msg            = built_msg(expected_msg (i_rdi_lp_sb_decode, i_rdi_lp_adv_cap_value));         
              next_state         = BUILD_MSG      ;
            end else begin
            next_state           = current_state;
            end
          end
          BUILD_MSG: begin
            exp_o_pl_sb_busy     = 1              ;
            exp_o_rdi_lp_cfg     = cfg_packet     ;
            exp_o_rdi_lp_cfg_vld = 0              ;
            cred_count           = 1              ;
            cfg_packet_temp      = exp_msg [NC-1:0];
            packet_counter_temp  = 0              ;
            next_state           = SENDING;
          end
          SENDING : begin
            if(packet_counter == ((32/NC) * 4) - 1) begin
              exp_o_pl_sb_busy     = 1                 ;
              exp_o_rdi_lp_cfg     = cfg_packet        ;
              exp_o_rdi_lp_cfg_vld = 1                 ;
              cred_count           = (i_rdi_pl_cfg_crd);
              exp_msg              = exp_msg >> NC     ;
              cfg_packet_temp      = exp_msg [NC-1:0]  ;
              packet_counter_temp  = 0;
              next_state           = (i_rdi_pl_cfg_crd)? IDLE : NO_CRED;
            end else begin
              exp_o_pl_sb_busy     = 1                 ;
              exp_o_rdi_lp_cfg     = cfg_packet        ;
              exp_o_rdi_lp_cfg_vld = 1                 ;
              cred_count           = (i_rdi_pl_cfg_crd);
              exp_msg              = exp_msg >> NC     ;
              cfg_packet_temp      = exp_msg [NC-1:0]  ;
              packet_counter_temp  = packet_counter + 1;
              next_state           = current_state     ;
            end
          end
          NO_CRED : begin
            exp_o_pl_sb_busy     = 1              ;
            exp_o_rdi_lp_cfg     = cfg_packet     ;
            exp_o_rdi_lp_cfg_vld = 0              ;
            cred_count           = (i_rdi_pl_cfg_crd)     ;
            packet_counter_temp  = 0              ;
            cfg_packet_temp      = exp_msg [NC-1:0];
            next_state           = (i_rdi_pl_cfg_crd)? IDLE : NO_CRED;
          end    
            endcase
          end
  // -------------------------------------------------- DUT instantiation -------------------------------------------
 
    UCIE_ctl_sb_tx_top # (.NC(NC)) DUT(
      .i_clk                   (i_clk                   ), 
      .i_rst                   (i_rst                   ), 
      .i_valid_lp_sb           (i_valid_lp_sb           ), 
      .i_rdi_lp_sb_decode      (i_rdi_lp_sb_decode      ), 
      .i_rdi_lp_adv_cap_value  (i_rdi_lp_adv_cap_value  ), 
      .o_pl_sb_busy            (o_pl_sb_busy            ), 
      .i_rdi_pl_cfg_crd        (i_rdi_pl_cfg_crd        ), 
      .o_rdi_lp_cfg_vld        (o_rdi_lp_cfg_vld        ), 
      .o_rdi_lp_cfg            (o_rdi_lp_cfg            )
  );
  
  //---------------------------------------------  Self checking mechanism ----------------------------------------

  always @(posedge i_clk) begin
    if (score_board_active) begin
      if ( (o_pl_sb_busy     == exp_o_pl_sb_busy    ) &&
           (o_rdi_lp_cfg_vld == exp_o_rdi_lp_cfg_vld) &&
           (o_rdi_lp_cfg     == exp_o_rdi_lp_cfg    )
      ) begin
        $display ("\n---------------------Test case SUCCEEDED -------------------\n");
        $display ("case info: \n"     );
        $display ("@ TIME = %t", $time());
        $display ("o_pl_sb_busy = %b              exp_o_pl_sb_busy = %b"      ,o_pl_sb_busy,      exp_o_pl_sb_busy);
        $display ("o_rdi_lp_cfg_vld = %b          exp_o_rdi_lp_cfg_vld = %b"  ,o_rdi_lp_cfg_vld,  exp_o_rdi_lp_cfg_vld);
        $display ("o_rdi_lp_cfg = %h              exp_o_rdi_lp_cfg = %h"      ,o_rdi_lp_cfg,      exp_o_rdi_lp_cfg);
      end else begin
        $display ("----------------------- Test case FAILED  ---------------------\n");
        $display ("case info: \n"     );
        $display ("@ TIME = %t", $time());
        $display ("o_pl_sb_busy = %b              exp_o_pl_sb_busy = %b"      ,o_pl_sb_busy,      exp_o_pl_sb_busy);
        $display ("o_rdi_lp_cfg_vld = %b          exp_o_rdi_lp_cfg_vld = %b"  ,o_rdi_lp_cfg_vld,  exp_o_rdi_lp_cfg_vld);
        $display ("o_rdi_lp_cfg = %h              exp_o_rdi_lp_cfg = %h"      ,o_rdi_lp_cfg,      exp_o_rdi_lp_cfg);
        end
      end
    end

//------------------------------------------------------- Test Tasks --------------------------------------------
//------------------------------------- intialization
  task sb_intialize;
    begin
    // Initialize Inputs
    i_clk                  = 0;
    i_rst                  = 0;
    i_valid_lp_sb          = 0;
    i_rdi_lp_sb_decode     = 0;
    i_rdi_lp_adv_cap_value = 0;
    i_rdi_pl_cfg_crd       = 0;
    // Assync RST
    @ (negedge i_clk)
    i_rst                  = 1;
    //# 1step
    //# (CLK_PERIOD)
    end
  endtask

//----------------------------------------------------- ADVCAP test
  
  task ADV_CAP_MSG;

    begin
      @ (posedge i_clk)
      i_valid_lp_sb          = 1           ;
      i_rdi_lp_sb_decode     = ADV_CAP     ;
      i_rdi_lp_adv_cap_value = 32'hAABBCCDD; // ANY DATA
      $display("######################## START ADVCAP ########################");
      score_board_active = 1;
      #((32/NC * 4 + 1) * CLK_PERIOD)  
      @(posedge i_clk)
      i_valid_lp_sb          = 0;
      i_rdi_pl_cfg_crd       = 1;
    end 

  endtask

//-------------------------------------- LINK_MGMT_ADAPTER0_REQ_ACTIVE test

  task LINK_MGMT_ADAPTER0_REQ_ACTIVE_MSG;
    begin
      @ (posedge i_clk)
      i_valid_lp_sb          = 1           ;
      i_rdi_lp_sb_decode     = LINK_MGMT_ADAPTER0_REQ_ACTIVE     ;
      i_rdi_lp_adv_cap_value = 32'hAABBCCDD; // ANY DATA
      $display("######################## START LINK_MGMT_ADAPTER0_REQ_ACTIVE ########################");
      score_board_active = 1;
      #((32/NC * 4 + 1) * CLK_PERIOD)  
      @(posedge i_clk)
      i_valid_lp_sb          = 0;
      i_rdi_pl_cfg_crd       = 1;
    end 
  endtask

//-------------------------------------- LINK_MGMT_ADAPTER0_REQ_LINK_RESET test

  task LINK_MGMT_ADAPTER0_REQ_LINK_RESET_MSG;
    begin
      @ (posedge i_clk)
      i_valid_lp_sb          = 1           ;
      i_rdi_lp_sb_decode     = LINK_MGMT_ADAPTER0_REQ_LINK_RESET     ;
      i_rdi_lp_adv_cap_value = 32'hAABBCCDD; // ANY DATA
      $display("######################## START LINK_MGMT_ADAPTER0_REQ_LINK_RESET ########################");
      score_board_active = 1;
      #((32/NC * 4 + 1) * CLK_PERIOD)  
      @(posedge i_clk)
      i_valid_lp_sb          = 0;
      i_rdi_pl_cfg_crd       = 1;
    end 
  endtask

//-------------------------------------- LINK_MGMT_ADAPTER0_REQ_LINK_RESET test  

  task LINK_MGMT_ADAPTER0_RSP_ACTIVE_MSG;
    begin
      @ (posedge i_clk)
      i_valid_lp_sb          = 1           ;
      i_rdi_lp_sb_decode     = LINK_MGMT_ADAPTER0_RSP_ACTIVE     ;
      i_rdi_lp_adv_cap_value = 32'hAABBCCDD; // ANY DATA
      $display("######################## START LINK_MGMT_ADAPTER0_RSP_ACTIVE ########################");
      score_board_active = 1;
      #((32/NC * 4 + 1) * CLK_PERIOD)  
      @(posedge i_clk)
      i_valid_lp_sb          = 0;
      i_rdi_pl_cfg_crd       = 1;
    end 
  endtask

  //-------------------------------------- LINK_MGMT_ADAPTER0_RSP_LINK_RESET test  

  task LINK_MGMT_ADAPTER0_RSP_LINK_RESET_MSG;
    begin
      @ (posedge i_clk)
      i_valid_lp_sb          = 1           ;
      i_rdi_lp_sb_decode     = LINK_MGMT_ADAPTER0_RSP_LINK_RESET     ;
      i_rdi_lp_adv_cap_value = 32'hAABBCCDD; // ANY DATA
      $display("######################## START LINK_MGMT_ADAPTER0_RSP_LINK_RESET ########################");
      score_board_active = 1;
      #((32/NC * 4 + 1) * CLK_PERIOD)  
      @(posedge i_clk)
      i_valid_lp_sb          = 0;
      i_rdi_pl_cfg_crd       = 1;
    end 
  endtask

  //-------------------------------------- ERROR_CORRECTABLE test 

  task ERROR_CORRECTABLE_MSG;
    begin
      @ (posedge i_clk)
      i_valid_lp_sb          = 1           ;
      i_rdi_lp_sb_decode     = ERROR_CORRECTABLE     ;
      i_rdi_lp_adv_cap_value = 32'hAABBCCDD; // ANY DATA
      $display("######################## START ERROR_CORRECTABLE ########################");
      score_board_active = 1;
      #((32/NC * 4 + 1) * CLK_PERIOD)  
      @(posedge i_clk)
      i_valid_lp_sb          = 0;
      i_rdi_pl_cfg_crd       = 1;
    end 
  endtask

  //-------------------------------------- ERROR_FATAL test 

  task ERROR_FATAL_MSG;
    begin
      @ (posedge i_clk)
      i_valid_lp_sb          = 1           ;
      i_rdi_lp_sb_decode     = ERROR_FATAL     ;
      i_rdi_lp_adv_cap_value = 32'hAABBCCDD; // ANY DATA
      $display("######################## START ERROR_FATAL ########################");
      score_board_active = 1;
      #((32/NC * 4 + 1) * CLK_PERIOD)  
      @(posedge i_clk)
      i_valid_lp_sb          = 0;
      i_rdi_pl_cfg_crd       = 1;
    end 
  endtask

  //-------------------------------------- ERROR_NON_FATAL test

  task ERROR_NON_FATAL_MSG;
    begin
      @ (posedge i_clk)
      i_valid_lp_sb          = 1           ;
      i_rdi_lp_sb_decode     = ERROR_NON_FATAL     ;
      i_rdi_lp_adv_cap_value = 32'hAABBCCDD; // ANY DATA
      $display("######################## START ERROR_NON_FATAL ########################");
      score_board_active = 1;
      #((32/NC * 4 + 1) * CLK_PERIOD)  
      @(posedge i_clk)
      i_valid_lp_sb          = 0;
      i_rdi_pl_cfg_crd       = 1;
    end 
  endtask



//---------------------------------------initial block -------------------------------------------------------
initial begin
    sb_intialize();
    ADV_CAP_MSG ();
    LINK_MGMT_ADAPTER0_REQ_ACTIVE_MSG();
    LINK_MGMT_ADAPTER0_REQ_LINK_RESET_MSG();
    LINK_MGMT_ADAPTER0_RSP_ACTIVE_MSG();
    LINK_MGMT_ADAPTER0_RSP_LINK_RESET_MSG();
    ERROR_CORRECTABLE_MSG();
    ERROR_NON_FATAL_MSG ();
    ERROR_FATAL_MSG();
    # (CLK_PERIOD)
    score_board_active     = 0;
    $stop();
end

//------------------------------------------------

endmodule
