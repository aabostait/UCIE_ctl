`timescale 1ns/1ps

// Side band messages 
 typedef enum logic [3:0] {
    IDLE,
    ACT_REQ,
    ACT_RSP,    
    RETRAIN_REQ, 
    RETRAIN_RSP,
    LNKERR_REQ,
    LNKERR_RSP,
    LNKRST_REQ,
    LNKRST_RSP
  } SB_MSG_e;

  module UCIE_ctl_phy_rx_dut_to_dut_top_tb # (parameter NBYTES = 8 , parameter NC = 32);
    // Clock and reset
   bit                     i_clk;
   bit                     i_rst_n;

  // Adapter (LP) Interface Inputs
   logic [3:0]             i_rdi_lp_state_req_dut_one;
   logic                   i_rdi_lp_linkerror_dut_one;
   logic                   i_rdi_lp_irdy_dut_one;
   logic                   i_rdi_lp_valid_dut_one;
   logic [(NBYTES*8)-1:0]  i_rdi_lp_data_dut_one;
   logic                   i_rdi_lp_cfg_crd_dut_one;
   logic                   i_rdi_lp_cfg_valid_dut_one;
   logic                   i_sb_data_valid_dut_one;
   logic          [NC-1:0] i_data_received_sb_dut_one;
   logic          [NC-1:0] i_rdi_lp_cfg_dut_one;

  // Second DUT Inputs 
   logic           [3:0]   i_sb_msg_in_dut_one;
   logic [(NBYTES*8)-1:0]  i_data_received_dut_one;
   logic                   i_data_valid_dut_one;

  // CSR Input
   logic                   i_start_ucie_link_training_dut_one;

  //Test Bench Inputs 

   logic                   i_phy_req_trainerror_dut_one;
   logic                   i_phy_req_nferror_dut_one;
   logic                   i_phy_req_cerror_dut_one;
   logic                   i_phy_req_pl_error_dut_one;
   logic                   i_phy_req_data_error_dut_one;

      // Adapter (LP) Interface Inputs
   logic [3:0]             i_rdi_lp_state_req_dut_two;
   logic                   i_rdi_lp_linkerror_dut_two;
   logic                   i_rdi_lp_irdy_dut_two;
   logic                   i_rdi_lp_valid_dut_two;
   logic [(NBYTES*8)-1:0]  i_rdi_lp_data_dut_two;
   logic                   i_rdi_lp_cfg_crd_dut_two;
   logic                   i_rdi_lp_cfg_valid_dut_two;
   logic                   i_sb_data_valid_dut_two;
   logic          [NC-1:0] i_data_received_sb_dut_two;
   logic          [NC-1:0] i_rdi_lp_cfg_dut_two;

  // Second DUT Inputs 
   logic           [3:0]   sb_msg_in_dut_two;
   logic [(NBYTES*8)-1:0]  i_data_received_dut_two;
   logic                   i_data_valid_dut_two;

  // CSR Input
   logic                   i_start_ucie_link_training_dut_two;

  //Test Bench Inputs 

   logic                   i_phy_req_trainerror_dut_two;
   logic                   i_phy_req_nferror_dut_two;
   logic                   i_phy_req_cerror_dut_two;
   logic                   i_phy_req_pl_error_dut_two;
   logic                   i_phy_req_data_error_dut_two;



  // Adapter (LP) Interface Outpus
   logic [3:0]             o_rdi_pl_state_sts_dut_one;
   logic                   o_rdi_pl_error_dut_one;
   logic                   o_rdi_pl_cerror_dut_one;
   logic                   o_rdi_pl_nferror_dut_one;
   logic                   o_rdi_pl_trainerror_dut_one;
   logic                   o_rdi_pl_phyinrecenter_dut_one;
   logic [2:0]             o_rdi_pl_speedmode_dut_one;
   logic [2:0]             o_rdi_pl_lnk_cfg_dut_one;
   logic                   o_rdi_pl_inband_pres_dut_one;
   logic                   o_rdi_pl_cfg_crd_dut_one;
   logic                   o_rdi_pl_cfg_vld_dut_one;
   logic                   o_sb_data_valid_dut_one;
   logic          [NC-1:0] o_rdi_pl_cfg_dut_one;
   logic          [NC-1:0] o_data_sent_sb_dut_one;
   logic                   o_rdi_pl_trdy_dut_one;
   logic                   o_rdi_pl_valid_dut_one;
   logic [(NBYTES*8)-1:0]  o_rdi_pl_data_dut_one;


  // Adapter (LP) Interface Outpus
   logic [3:0]             o_rdi_pl_state_sts_dut_two;
   logic                   o_rdi_pl_error_dut_two;
   logic                   o_rdi_pl_cerror_dut_two;
   logic                   o_rdi_pl_nferror_dut_two;
   logic                   o_rdi_pl_trainerror_dut_two;
   logic                   o_rdi_pl_phyinrecenter_dut_two;
   logic [2:0]             o_rdi_pl_speedmode_dut_two;
   logic [2:0]             o_rdi_pl_lnk_cfg_dut_two;
   logic                   o_rdi_pl_inband_pres_dut_two;
   logic                   o_rdi_pl_cfg_crd_dut_two;
   logic                   o_rdi_pl_cfg_vld_dut_two;
   logic                   o_sb_data_valid_dut_two;
   logic          [NC-1:0] o_rdi_pl_cfg_dut_two;
   logic          [NC-1:0] o_data_sent_sb_dut_two;
   logic                   o_rdi_pl_trdy_dut_two;
   logic                   o_rdi_pl_valid_dut_two;
   logic [(NBYTES*8)-1:0]  o_rdi_pl_data_dut_two;

    //outputs of RX
   logic [(NBYTES*8)-1:0]  o_fdi_data_dut_one;
   logic [(NBYTES*8)-1:0]  o_fdi_data_dut_two;
   logic                   o_fdi_data_valid_dut_one;
   logic                   o_fdi_data_valid_dut_two;
   logic                   o_overflow_detected_dut_one;
   logic                   o_overflow_detected_dut_two;




    UCIE_ctl_phy_rx_dut_to_dut_top # (.NBYTES(NBYTES) ,.NC(NC)) PHY_RX_TOP (.*);



// clock generation
initial begin   
    forever #1 i_clk = !i_clk;   
end

initial begin
i_rst_n                                 = 0;
i_phy_req_trainerror_dut_one            = 0;
i_phy_req_nferror_dut_one               = 0;
i_phy_req_cerror_dut_one                = 0;
i_phy_req_pl_error_dut_one              = 0;
i_phy_req_data_error_dut_one            = 0;
i_phy_req_trainerror_dut_two            = 0;
i_phy_req_nferror_dut_two               = 0;
i_phy_req_cerror_dut_two                = 0;
i_phy_req_pl_error_dut_two              = 0;
i_phy_req_data_error_dut_two            = 0;
#10
i_rst_n = 1;

#10;

RDI_BringUp_flow();

#10;

ACTIVE_State();


#10 $stop;


end



task RDI_BringUp_flow;
    @(negedge i_clk) 
        i_start_ucie_link_training_dut_one = 1'b1;

        #10;
        i_start_ucie_link_training_dut_two = 1'b1;

        #10;

        i_rdi_lp_state_req_dut_one = 4'b0001;

        #10;
   

        #20; 
        i_rdi_lp_state_req_dut_two = 4'b0001;
        i_start_ucie_link_training_dut_two = 1'b0;
        i_start_ucie_link_training_dut_one =1'b0;


endtask : RDI_BringUp_flow

task ACTIVE_State ;
    for (integer i = 0 ; i <20 ;i++) begin
        @(negedge i_clk)  begin
            i_rdi_lp_irdy_dut_one = 1 ;
            i_rdi_lp_data_dut_one = $random;
            i_rdi_lp_valid_dut_one = 1;
        end
   end
endtask





endmodule