`include "./defines.svh"
module UCIE_ctl_phy_fsm_control # (
    parameter NBYTES = `NBYTES) 
(
  // Clock and reset
  input  bit                     i_clk,
  input  bit                     i_rst_n,

  // Adapter (LP) Interface Inputs
  input  logic [3:0]             i_rdi_lp_state_req,
  input  logic                   i_rdi_lp_linkerror,

  // Second DUT Inputs 
  input  logic [3:0]             i_sb_msg_in,
  input  logic                   i_training_start_notification_in,


  // CSR Input
  input  logic                   i_start_ucie_link_training,

  //Test Bench Inputs 

  input  logic                   i_phy_req_trainerror,
  input  logic                   i_phy_req_nferror,
  input  logic                   i_phy_req_cerror,
  input  logic                   i_phy_req_pl_error,

  // Adapter (LP) Interface Outpus
  output logic [3:0]             o_rdi_pl_state_sts,
  output logic                   o_rdi_pl_error,
  output logic                   o_rdi_pl_cerror,
  output logic                   o_rdi_pl_nferror,
  output logic                   o_rdi_pl_trainerror,
  output logic                   o_rdi_pl_phyinrecenter,
  output logic [2:0]             o_rdi_pl_speedmode,
  output logic [2:0]             o_rdi_pl_lnk_cfg,
  output logic                   o_rdi_pl_inband_pres,
  output logic                   o_rdi_enable,

  // Second DUT Inputs 
  output logic [3:0]             o_sb_msg_out,
  output logic                   o_training_start_notification_out

);

 // counter parameter 
    parameter COUNTER_TIME_OUT = 3;

 // Side band messages 
    localparam  IDLE         = 4'b0000;
    localparam  ACT_REQ      = 4'b0001;
    localparam  ACT_RSP      = 4'b0010;
    localparam  RETRAIN_REQ  = 4'b0011;
    localparam  RETRAIN_RSP  = 4'b0100;
    localparam  LNKERR_REQ   = 4'b0101;
    localparam  LNKERR_RSP   = 4'b0110;
    localparam  LNKRST_REQ   = 4'b0111;
    localparam  LNKRST_RSP   = 4'b1000;

  // State encoding
  typedef enum logic [3:0] {
    RESET             = 4'b0000,
    LINK_TRAINIG      = 4'b0001,
    WAIT_FOR_ADAPTER  = 4'b0010,
    REQ_ACTIVE        = 4'b0011,
    RSP_ACTIVE        = 4'b0100,
    ACTIVE            = 4'b0101,
    RETRAIN           = 4'b0110,
    RETRAIN_TX        = 4'b0111,
    NOP               = 4'b1000,
    LINK_ERR_TX       = 4'b1001,
    LINK_RESET        = 4'b1010,
    LINK_ERROR        = 4'b1011,
    RETRAIN_RX        = 4'b1100,
    LINK_RST_TX       = 4'b1101,
    RETRAIN_RX_TWO    = 4'b1110,
    GLOBAL_RESET      = 4'b1111
  } phy_states_e;


  // Internal Flags
  phy_states_e r_current_state, w_next_state;
  logic        r_linkreset_flag;  
  logic        r_linkerror_flag;
  logic [1:0]  r_timeout_cntr;
  logic [1:0]  r_training_cntr;

  logic  [3:0]       i_rdi_lp_state_req_temp;
  logic              r_nop_active_flag;


  assign r_nop_active_flag =(i_rdi_lp_state_req ==4'b0001 && i_rdi_lp_state_req_temp==4'b0000)? 1'b1:1'b0;

  

  // State machine

  // State Memory
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      r_current_state    <= GLOBAL_RESET;
    end else 
      r_current_state <= w_next_state;

  end

  // Counters
  // For timeout counter and link training counter 

  always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_
    if(!i_rst_n) begin
      r_timeout_cntr     <= 2'b00;
      r_training_cntr    <= 2'b00;
    end else begin
        if (r_current_state == LINK_TRAINIG) begin
        r_training_cntr <= r_training_cntr + 1'b1;
      end

      if (  r_current_state == LINK_ERROR  &&  !r_linkerror_flag) begin
        r_timeout_cntr <= r_timeout_cntr + 1'b1;
      end

      else if ( r_current_state == LINK_RESET  &&  !r_linkerror_flag) begin
        r_timeout_cntr <= r_timeout_cntr + 1'b1;

        // If phy go to link error from link reset 
        if (i_rdi_lp_linkerror || i_phy_req_trainerror || i_sb_msg_in == LNKERR_RSP)
          r_timeout_cntr <= 2'b00;
      end

    end

  end

  // Flags control 
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      r_linkreset_flag     <= 1'b0;
      r_linkerror_flag     <= 1'b0;
      i_rdi_lp_state_req_temp <=4'b0;
    end else begin

        i_rdi_lp_state_req_temp <=i_rdi_lp_state_req;

      // Here proirty for LinkError state then LinkReset state
       if (i_rdi_lp_linkerror || i_phy_req_trainerror) begin
          r_linkerror_flag <= 1'b1;

        end else if (i_rdi_lp_state_req == 4'b1001) begin
          r_linkreset_flag <= 1'b1;

       end 

      // link reset , retrain and error flags 
      if (r_current_state == ACTIVE) begin  
        r_linkerror_flag    <= 1'b0;
        r_linkreset_flag    <= 1'b0;

      end 


  end

end


  // Next state logic
  always_comb begin
    case (r_current_state)

      GLOBAL_RESET : begin
              if (!i_rst_n)
                w_next_state = GLOBAL_RESET;
              else 
                w_next_state = LINK_TRAINIG;
        end


      RESET: begin

        // priority for link error
        if (i_rdi_lp_linkerror || i_phy_req_trainerror) begin
            w_next_state = LINK_ERR_TX;

       end else if (i_sb_msg_in == LNKERR_REQ )
          w_next_state = LINK_ERROR;
        // then prioirty for link reset      
        else if (i_rdi_lp_state_req == 4'b1001) 
            w_next_state = LINK_RST_TX;

        else if (i_sb_msg_in == LNKRST_REQ)
          w_next_state = LINK_RESET;

        else if ( (i_start_ucie_link_training   && !r_linkerror_flag) ||
                  (i_start_ucie_link_training   && !r_linkreset_flag) ||
                ( (i_start_ucie_link_training   || r_nop_active_flag) && r_linkerror_flag) ||
                ( (i_start_ucie_link_training   || r_nop_active_flag) && r_linkreset_flag) ||
                i_training_start_notification_in )  begin

          w_next_state = LINK_TRAINIG;
        end else begin 
          w_next_state = RESET;
        end
      
      end

      LINK_TRAINIG: begin

        // Link Error flow and LinkReset flow
         if (i_rdi_lp_linkerror || i_phy_req_trainerror) 
          w_next_state = LINK_ERR_TX;

        else if (i_sb_msg_in == LNKERR_REQ )
          w_next_state = LINK_ERROR;

        else if (i_rdi_lp_state_req == 4'b1001)
          w_next_state = LINK_RST_TX;

        else if (i_sb_msg_in == LNKRST_REQ)
          w_next_state = LINK_RESET;

        else if (r_training_cntr == COUNTER_TIME_OUT) 
          w_next_state = WAIT_FOR_ADAPTER;

        else
          w_next_state = LINK_TRAINIG;

      end

      WAIT_FOR_ADAPTER: begin

        // Link Error flow and LinkReset flow
         if (i_rdi_lp_linkerror || i_phy_req_trainerror ) 
          w_next_state = LINK_ERR_TX;

        else if (i_sb_msg_in == LNKERR_REQ )
          w_next_state = LINK_ERROR;

        else if (i_rdi_lp_state_req == 4'b1001)
          w_next_state = LINK_RST_TX;

        else if (i_sb_msg_in == LNKRST_REQ)
          w_next_state = LINK_RESET;

        else if ((r_linkerror_flag || r_linkreset_flag) && i_sb_msg_in == ACT_REQ)
          w_next_state = ACTIVE;

        else if (i_sb_msg_in == ACT_REQ)
          w_next_state = RSP_ACTIVE;

        else if (i_rdi_lp_state_req == 4'b0001) 
          w_next_state = REQ_ACTIVE;

        else
          w_next_state = WAIT_FOR_ADAPTER;

      end

      REQ_ACTIVE:begin
                // Link Error flow and LinkReset flow
         if (i_rdi_lp_linkerror || i_phy_req_trainerror ) 
          w_next_state = LINK_ERR_TX;

        else if (i_sb_msg_in == LNKERR_REQ )
          w_next_state = LINK_ERROR;

        else if (i_rdi_lp_state_req == 4'b1001)
          w_next_state = LINK_RST_TX;

        else if (i_sb_msg_in == LNKRST_REQ)
          w_next_state = LINK_RESET;

        else if (i_sb_msg_in == ACT_RSP)
          w_next_state = ACTIVE;
        
        else if (i_sb_msg_in == ACT_REQ )
          w_next_state = RSP_ACTIVE;

        else w_next_state = REQ_ACTIVE; 
      end

      RSP_ACTIVE: begin
                // Link Error flow and LinkReset flow
         if (i_rdi_lp_linkerror || i_phy_req_trainerror) 
          w_next_state = LINK_ERR_TX;

        else if (i_sb_msg_in == LNKERR_REQ )
          w_next_state = LINK_ERROR;

        else if (i_rdi_lp_state_req == 4'b1001)
          w_next_state = LINK_RST_TX;

        else if (i_sb_msg_in == LNKRST_REQ)
          w_next_state = LINK_RESET;

        else if (i_rdi_lp_state_req == 4'b0001) 
          w_next_state = ACTIVE;

        else w_next_state = RSP_ACTIVE;
      end

      ACTIVE: begin

        // Link Error flow and LinkReset flow
         if (i_rdi_lp_linkerror || i_phy_req_trainerror || i_start_ucie_link_training) 
          w_next_state = LINK_ERR_TX;

        else if (i_sb_msg_in == LNKERR_REQ )
          w_next_state = LINK_ERROR;

        else if (i_rdi_lp_state_req == 4'b1001)
          w_next_state = LINK_RST_TX;

        else if (i_sb_msg_in == LNKRST_REQ)
          w_next_state = LINK_RESET;

        // Retrain flow 
        else if (i_rdi_lp_state_req == 4'b1011) 
          w_next_state = RETRAIN_TX;
        else if (i_phy_req_pl_error || i_sb_msg_in == RETRAIN_REQ)  
          w_next_state = RETRAIN;


        else 
          w_next_state = ACTIVE;
      end

      RETRAIN_TX: begin
        // Link Error flow and LinkReset flow
         if (i_rdi_lp_linkerror || i_phy_req_trainerror) 
          w_next_state = LINK_ERR_TX;

        else if (i_sb_msg_in == LNKERR_REQ )
          w_next_state = LINK_ERROR;

        else if (i_rdi_lp_state_req == 4'b1001)
          w_next_state = LINK_RST_TX;
        
        else if (i_sb_msg_in == LNKRST_REQ)
          w_next_state = LINK_RESET;

        // Retrian flow
        else if (i_sb_msg_in == RETRAIN_RSP)  
          w_next_state = RETRAIN;

        else w_next_state = RETRAIN_TX;
      end

      RETRAIN: begin
        // Link Error flow and LinkReset flow
         if (i_rdi_lp_linkerror || i_phy_req_trainerror || i_start_ucie_link_training) 
          w_next_state = LINK_ERR_TX;

        else if (i_sb_msg_in == LNKERR_REQ )
          w_next_state = LINK_ERROR;

        else if (i_rdi_lp_state_req == 4'b1001)
          w_next_state = LINK_RST_TX;
        
        else if (i_sb_msg_in == LNKRST_REQ)
          w_next_state = LINK_RESET;

        else if (i_sb_msg_in == ACT_REQ  )  
          w_next_state = RETRAIN_RX;
        else if(r_nop_active_flag )
          w_next_state = NOP;

        else w_next_state =RETRAIN;

      end

      RETRAIN_RX:begin

        // Link Error flow and LinkReset flow
         if (i_rdi_lp_linkerror || i_phy_req_trainerror) 
          w_next_state = LINK_ERR_TX;

        else if (i_sb_msg_in == LNKERR_REQ )
          w_next_state = LINK_ERROR;

        else if (i_rdi_lp_state_req == 4'b1001)
          w_next_state = LINK_RST_TX;
        
        else if (i_sb_msg_in == LNKRST_REQ)
          w_next_state = LINK_RESET;

        else if (r_nop_active_flag)
          w_next_state = RETRAIN_RX_TWO ;
        else 
          w_next_state = RETRAIN_RX;
      end

      RETRAIN_RX_TWO:begin
        // Link Error flow and LinkReset flow
         if (i_rdi_lp_linkerror || i_phy_req_trainerror) 
          w_next_state = LINK_ERR_TX;

        else if (i_sb_msg_in == LNKERR_REQ )
          w_next_state = LINK_ERROR;

        else if (i_rdi_lp_state_req == 4'b1001)
          w_next_state = LINK_RST_TX;
        
        else if (i_sb_msg_in == LNKRST_REQ)
          w_next_state = LINK_RESET;

        else w_next_state = NOP;
      end

       NOP: begin

        // Link Error flow and LinkReset flow
         if (i_rdi_lp_linkerror || i_phy_req_trainerror) 
          w_next_state = LINK_ERR_TX;

        else if (i_sb_msg_in == LNKERR_REQ )
          w_next_state = LINK_ERROR;

        else if (i_rdi_lp_state_req == 4'b1001)
          w_next_state = LINK_RST_TX;
        
        else if (i_sb_msg_in == LNKRST_REQ)
          w_next_state = LINK_RESET;

       else if (i_sb_msg_in == ACT_RSP)  
          w_next_state = ACTIVE;

        else w_next_state = NOP;
      end

      LINK_ERR_TX: begin

       if (i_sb_msg_in == LNKERR_RSP || i_sb_msg_in == LNKERR_REQ)
          w_next_state = LINK_ERROR;

        else w_next_state = LINK_ERR_TX;
      end

      LINK_RST_TX: begin
        if (i_sb_msg_in == LNKERR_RSP)  
          w_next_state = LINK_ERROR;

        else if (i_sb_msg_in == LNKRST_RSP)
          w_next_state = LINK_RESET;

        else w_next_state = LINK_RST_TX;
      end

      LINK_RESET: begin

          // Link Error flow 
         if (i_rdi_lp_linkerror || i_phy_req_trainerror) 
          w_next_state = LINK_ERR_TX;

        else if (i_sb_msg_in == LNKERR_REQ )
          w_next_state = LINK_ERROR;        

        else if ((!r_linkreset_flag && r_timeout_cntr == COUNTER_TIME_OUT) || (r_linkreset_flag == 1'b1 && i_rdi_lp_state_req == 4'b0001) )
          w_next_state = RESET;

        else w_next_state = LINK_RESET;
      end

      LINK_ERROR: begin
        if ((!r_linkerror_flag && r_timeout_cntr == COUNTER_TIME_OUT) || (r_linkerror_flag == 1'b1 && i_rdi_lp_state_req == 4'b0001)) 
          w_next_state = RESET;

        else w_next_state = LINK_ERROR;
      end

      default: w_next_state = RESET;
    endcase
  end


  // Output assignments
  always_comb begin
    // Default assignments
    o_rdi_pl_state_sts     = 4'b0000;
    o_rdi_pl_error         = i_phy_req_pl_error;
    o_rdi_pl_cerror        = i_phy_req_cerror;
    o_rdi_pl_nferror       = i_phy_req_nferror;
    o_rdi_pl_trainerror    = i_phy_req_trainerror;
    o_rdi_pl_phyinrecenter = 1'b0;
    o_rdi_pl_speedmode     = 3'b000;
    o_rdi_pl_lnk_cfg       = 3'b001;   
    o_rdi_pl_inband_pres   = 1'b0;
    o_rdi_enable           = 1'b0;
    o_sb_msg_out           = IDLE;
    o_training_start_notification_out =0;


    case (r_current_state)
      GLOBAL_RESET : begin 
          o_rdi_pl_state_sts     = 4'b0000;
          o_rdi_pl_phyinrecenter = 1'b0;
          o_rdi_enable           = 1'b0;
          o_rdi_pl_inband_pres   = 1'b0;
          o_sb_msg_out           = IDLE;
      end
      RESET:begin
          o_rdi_pl_state_sts     = 4'b0000;
          o_rdi_pl_phyinrecenter = 1'b0;
          o_rdi_enable           = 1'b0;
          o_rdi_pl_inband_pres   = 1'b0;
          o_sb_msg_out           = IDLE;
      end

      LINK_TRAINIG:begin
          o_rdi_pl_state_sts     = 4'b0000;
          o_rdi_pl_phyinrecenter = 1'b1;
          o_rdi_pl_inband_pres   = 1'b0;
          o_rdi_enable           = 1'b0;
          o_sb_msg_out           = IDLE;
          o_training_start_notification_out =1;
      end

      WAIT_FOR_ADAPTER:begin 
          o_rdi_pl_state_sts     = 4'b0000;
          o_rdi_pl_phyinrecenter = 1'b0;
          o_rdi_pl_inband_pres   = 1'b1;
          o_rdi_enable           = 1'b0;
          o_sb_msg_out           = IDLE;
      end

      REQ_ACTIVE: begin
          o_rdi_pl_state_sts     = 4'b0000;
          o_rdi_pl_phyinrecenter = 1'b0;
          o_rdi_enable           = 1'b0;
          o_rdi_pl_inband_pres   = 1'b1;
          o_sb_msg_out           = ACT_REQ;
      end

      RSP_ACTIVE: begin
          o_rdi_pl_state_sts     = 4'b0000;
          o_rdi_pl_phyinrecenter = 1'b0;
          o_rdi_enable           = 1'b0;
          o_rdi_pl_inband_pres   = 1'b1;
          o_sb_msg_out           = IDLE;
      end

      ACTIVE:begin
          if(i_sb_msg_in == RETRAIN_REQ)
            o_sb_msg_out =RETRAIN_RSP;
          else
            o_sb_msg_out         = ACT_RSP;

          o_rdi_pl_state_sts     = 4'b0001; 
          o_rdi_pl_phyinrecenter = 1'b0;
          o_rdi_pl_inband_pres   = 1'b1;
          o_rdi_enable           = 1'b1;

      end

      RETRAIN_TX:begin
          o_rdi_pl_state_sts     = 4'b0001;
          o_rdi_enable           = 1'b1;
          o_rdi_pl_phyinrecenter = 1'b0;
          o_rdi_pl_inband_pres   = 1'b1;
          o_sb_msg_out           = RETRAIN_REQ;

      end

      RETRAIN:begin
          o_rdi_pl_state_sts     = 4'b1011;
          o_rdi_pl_phyinrecenter = 1'b1;
          o_rdi_pl_inband_pres   = 1'b0;
          o_rdi_enable           = 1'b0;
          o_sb_msg_out           = IDLE;
      end

      RETRAIN_RX:begin
          o_rdi_pl_state_sts     = 4'b1011;
          o_rdi_pl_phyinrecenter = 1'b1;
          o_rdi_pl_inband_pres   = 1'b0;
          o_rdi_enable           = 1'b0;
          o_sb_msg_out           = RETRAIN_REQ;
      end

     RETRAIN_RX_TWO:begin
          o_rdi_pl_state_sts     = 4'b1011;
          o_rdi_pl_phyinrecenter = 1'b1;
          o_rdi_pl_inband_pres   = 1'b0;
          o_rdi_enable           = 1'b0;
          o_sb_msg_out           = ACT_REQ;
     end

      NOP:begin
          o_rdi_pl_state_sts     = 4'b1011;
          o_rdi_pl_phyinrecenter = 1'b1;
          o_rdi_pl_inband_pres   = 1'b0;
          o_rdi_enable           = 1'b0;
          o_sb_msg_out           = ACT_RSP;
      end

      LINK_ERR_TX:begin
          o_rdi_pl_state_sts     = 4'b0001;
          o_rdi_pl_phyinrecenter = 1'b0;
          o_rdi_pl_inband_pres   = 1'b0;
          o_rdi_enable           = 1'b1;
          o_sb_msg_out           = LNKERR_REQ;

      end

      LINK_RST_TX:begin
          o_rdi_pl_state_sts     = 4'b0001;
          o_rdi_pl_phyinrecenter = 1'b0;
          o_rdi_pl_inband_pres   = 1'b0;
          o_rdi_enable           = 1'b1;
          o_sb_msg_out           = LNKRST_REQ;
      end

      LINK_RESET:begin
          o_rdi_pl_state_sts     = 4'b1001;
          o_rdi_pl_phyinrecenter = 1'b0;
          o_rdi_pl_inband_pres   = 1'b0;
          o_rdi_enable           = 1'b0;
          o_sb_msg_out         = LNKRST_RSP;

      end

      LINK_ERROR:begin
          o_rdi_pl_state_sts     = 4'b1010;
          o_rdi_pl_phyinrecenter = 1'b0;
          o_rdi_pl_inband_pres   = 1'b0;
          o_rdi_enable           = 1'b0;
          o_sb_msg_out         = LNKERR_RSP;
      end

      default:begin
          o_rdi_pl_state_sts     = 4'b1001;
          o_rdi_pl_phyinrecenter = 1'b0;
          o_rdi_pl_inband_pres   = 1'b0;
          o_sb_msg_out           = IDLE;
          o_rdi_enable           = 1'b0;
      end 

    endcase

  end

endmodule