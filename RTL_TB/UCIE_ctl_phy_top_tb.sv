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

 module UCIE_ctl_phy_top_tb # (parameter NBYTES = 32 , parameter NC = 32) ;

 // Clock and reset
  bit                     i_clk;
  bit                     i_rst_n;

  // Adapter (LP) Interface Inputs
  logic [3:0]             i_rdi_lp_state_req;
  logic                   i_rdi_lp_linkerror;
  logic                   i_rdi_lp_irdy;
  logic                   i_rdi_lp_valid;
  logic [NBYTES-1:0][7:0] i_rdi_lp_data;
  logic                   i_rdi_lp_cfg_crd;
  logic                   i_rdi_lp_cfg_valid;
  logic                   i_sb_data_valid;
  logic          [NC-1:0] i_data_received_sb;
  logic          [NC-1:0] i_rdi_lp_cfg;

  // Second DUT Inputs 
  logic [3:0]             i_sb_msg_in;
  logic [NBYTES-1:0][7:0] i_data_received;
  logic                   i_data_valid;

  // CSR Input
  logic                   i_start_ucie_link_training;

  //Test Bench Inputs 

  logic                   i_phy_req_trainerror;
  logic                   i_phy_req_nferror;
  logic                   i_phy_req_cerror;
  logic                   i_phy_req_pl_error;
  logic                   i_phy_req_data_error;


  // Adapter (LP) Interface Outpus
  logic [3:0]             o_rdi_pl_state_sts;
  logic                   o_rdi_pl_error;
  logic                   o_rdi_pl_cerror;
  logic                   o_rdi_pl_nferror;
  logic                   o_rdi_pl_trainerror;
  logic                   o_rdi_pl_phyinrecenter;
  logic [2:0]             o_rdi_pl_speedmode;
  logic [2:0]             o_rdi_pl_lnk_cfg;
  logic                   o_rdi_pl_inband_pres;
  logic                   o_rdi_pl_cfg_crd;
  logic                   o_rdi_pl_cfg_vld;
  logic                   o_sb_data_valid;
  logic          [NC-1:0] o_rdi_pl_cfg;
  logic          [NC-1:0] o_data_sent_sb;
  logic                   o_rdi_pl_trdy;
  logic                   o_rdi_pl_valid;
  logic [NBYTES-1:0][7:0] o_rdi_pl_data;

  // Second DUT Inputs 
  logic [3:0]              o_sb_msg_out;
  logic [NBYTES-1:0][7:0] o_data_sent;
  logic                   o_data_valid;


// internal signals
  logic                   r_enable;


// DUT Instantitaion 

 	 UCIE_ctl_fsm_phy_top # (
     .NBYTES(NBYTES) , .NC(NC)) phy_top_DUT

 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_rdi_lp_state_req(i_rdi_lp_state_req),
    .i_rdi_lp_linkerror(i_rdi_lp_linkerror),
    .i_sb_msg_in(i_sb_msg_in),
    .i_start_ucie_link_training(i_start_ucie_link_training),
    .i_phy_req_trainerror(i_phy_req_trainerror),
    .i_phy_req_nferror(i_phy_req_nferror),
    .i_phy_req_cerror(i_phy_req_cerror),
    .i_phy_req_pl_error(i_phy_req_pl_error),
    .o_rdi_pl_state_sts(o_rdi_pl_state_sts),
    .o_rdi_pl_error(o_rdi_pl_error),
    .o_rdi_pl_cerror(o_rdi_pl_cerror),
    .o_rdi_pl_nferror(o_rdi_pl_nferror),
    .o_rdi_pl_trainerror(o_rdi_pl_trainerror),
    .o_rdi_pl_phyinrecenter(o_rdi_pl_phyinrecenter),
    .o_rdi_pl_speedmode(o_rdi_pl_speedmode),
    .o_rdi_pl_lnk_cfg(o_rdi_pl_lnk_cfg),
    .o_rdi_pl_inband_pres(o_rdi_pl_inband_pres),
    .o_sb_msg_out(o_sb_msg_out),
    .i_rdi_lp_irdy(i_rdi_lp_irdy),
    .i_rdi_lp_valid(i_rdi_lp_valid),
    .i_rdi_lp_data(i_rdi_lp_data),
    .i_data_received(i_data_received),
    .i_data_valid(i_data_valid),
    .i_phy_req_data_error(i_phy_req_data_error),
    .o_rdi_pl_valid(o_rdi_pl_valid),
    .o_data_sent(o_data_sent),
    .o_data_valid(o_data_valid),
    .i_rdi_lp_cfg_crd(i_rdi_lp_cfg_crd),
    .i_rdi_lp_cfg_valid(i_rdi_lp_cfg_valid),
    .i_sb_data_valid(i_sb_data_valid),
    .i_data_received_sb(i_data_received_sb),
    .i_rdi_lp_cfg(i_rdi_lp_cfg),
    .o_rdi_pl_cfg_crd(o_rdi_pl_cfg_crd),
    .o_rdi_pl_cfg_vld(o_rdi_pl_cfg_vld),
    .o_sb_data_valid(o_sb_data_valid),
    .o_rdi_pl_cfg(o_rdi_pl_cfg),
    .o_data_sent_sb(o_data_sent_sb),
    .o_rdi_pl_trdy(o_rdi_pl_trdy),
    .o_rdi_pl_data(o_rdi_pl_data)
	
);




// clock generation
initial begin   
	forever #1 i_clk = !i_clk;   
end

initial begin
i_rst_n 				= 0;
i_phy_req_trainerror    = 0;
i_phy_req_nferror       = 0;
i_phy_req_cerror        = 0;
i_phy_req_pl_error      = 0;
i_phy_req_data_error    = 0;
#10
i_rst_n = 1;

#10;
RDI_BringUp_flow_RX();

#2;
i_rst_n = 0;
#10
i_rst_n = 1;

RDI_BringUp_flow_TX();

ACTIVE_State();

Retrain();

Linkreset_State();

Linkerror_state();

#1000 $stop;

end


task RDI_BringUp_flow_TX;
	@(negedge i_clk) begin
		i_start_ucie_link_training = 1'b1;
		i_rdi_lp_state_req = 4'b0001;
		i_sb_msg_in = ACT_RSP;
	end
	#200;
	i_start_ucie_link_training = 1'b0;
endtask : RDI_BringUp_flow_TX

task RDI_BringUp_flow_RX;
	@(negedge i_clk) begin
		i_start_ucie_link_training = 1'b1;
		i_rdi_lp_state_req = 4'b0000;
		i_sb_msg_in = ACT_REQ;
	end

	#200 
	i_rdi_lp_state_req = 4'b0001;
	i_start_ucie_link_training = 1'b0;


endtask : RDI_BringUp_flow_RX

task ACTIVE_State ;
	for (integer i = 0 ; i <20 ;i++) begin
		@(negedge i_clk)  begin
			i_rdi_lp_irdy = 1 ;
			i_rdi_lp_data = $random;
			i_rdi_lp_valid = 1;
		end
   end
endtask

task Retrain;
	@(negedge i_clk)
			i_rdi_lp_state_req = 4'b1011;

	#10;
	i_sb_msg_in = RETRAIN_RSP;

	#10;

	@(negedge i_clk) i_rdi_lp_state_req = 4'b0000;
	@(negedge i_clk) i_rdi_lp_state_req = 4'b0001;

	#10;

	i_sb_msg_in = ACT_RSP;

	#10;

	@(negedge i_clk) i_phy_req_pl_error = 1;

	#10 
	i_sb_msg_in = ACT_REQ;
    i_phy_req_pl_error = 0;
	#10;

	@(negedge i_clk) i_rdi_lp_state_req = 4'b0000;
	@(negedge i_clk) i_rdi_lp_state_req = 4'b0001;

	#10;

	i_sb_msg_in =ACT_RSP;

	#10;
endtask : Retrain


task Linkreset_State;
	@(negedge i_clk) i_rdi_lp_state_req = 4'b1001;

	#10;

	i_sb_msg_in = LNKRST_RSP;

	#10;

	@(negedge i_clk) i_rdi_lp_state_req = 4'b0001;

	#10;

	@(negedge i_clk) i_rdi_lp_state_req = 4'b0000;
	@(negedge i_clk) i_rdi_lp_state_req = 4'b0001;

	#20;

	i_sb_msg_in = ACT_REQ;

	#10;

	i_sb_msg_in = LNKRST_REQ;
	#20;
	i_start_ucie_link_training = 1'b0;


endtask : Linkreset_State

task Linkerror_state;
		@(negedge i_clk) i_rdi_lp_linkerror = 1;
		i_rdi_lp_state_req = 4'b0000;

	#10;

	i_sb_msg_in = LNKERR_RSP;

	#10;

	@(negedge i_clk) i_rdi_lp_state_req = 4'b0001;
	i_rdi_lp_linkerror = 0;

	#10;

	@(negedge i_clk) i_rdi_lp_state_req = 4'b0000;
	@(negedge i_clk) i_rdi_lp_state_req = 4'b0001;

	#20;

	i_sb_msg_in = ACT_REQ;

	#10;

	i_sb_msg_in = LNKERR_REQ;
	#20;
	i_start_ucie_link_training = 1'b1;

			@(negedge i_clk) i_phy_req_trainerror = 1;

	#10;

	i_sb_msg_in = LNKERR_RSP;

	#10;

	@(negedge i_clk) i_rdi_lp_state_req = 4'b0001;
	i_phy_req_trainerror = 0;

	#10;

	@(negedge i_clk) i_rdi_lp_state_req = 4'b0000;
	@(negedge i_clk) i_rdi_lp_state_req = 4'b0001;

	#20;

	i_sb_msg_in = ACT_REQ;

	#10;

	i_sb_msg_in = LNKERR_REQ;
	#20;
	i_start_ucie_link_training = 1'b1;

	#50;

	i_start_ucie_link_training = 0;
	i_sb_msg_in = ACT_RSP;



endtask : Linkerror_state

endmodule