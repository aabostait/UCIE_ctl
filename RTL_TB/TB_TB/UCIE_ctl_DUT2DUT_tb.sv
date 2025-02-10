`include "./defines.svh"
module UCIE_ctl_DUT2DUT_tb ();
import UCIE_ctl_shared_pkg::*;

    parameter     CLK_PERIOD    = 10 ;
    parameter     NBYTES        = `NBYTES  ; 
    parameter     NC            = `NC ;
    parameter     UCIE_ACTIVE   = 1  ;                          
    parameter     DATA_WIDTH_TX = `TX_WIDTH ;
    parameter     FIFO_DEPTH_TX = `TX_DEPTH  ;

    ////////////////////////////////////////////////////////    START OF PORTS /////////////////////////////////////////////////////////    


    bit                             i_clk;
    logic                           i_rst_n;

    ////////////////////////////////////// Adapter_Die_0 /////////////////////////////////////
    //------------------------ Inputs ------------------------//
    //------- CNTL -------//
    // FDI Signals
    e_request                       i_fdi_lp_state_req_die_0;
    logic                           i_fdi_lp_rx_active_sts_die_0;
    logic                           i_fdi_lp_linkerror_die_0;
    logic                           i_fdi_lp_irdy_die_0;
    logic   [(NBYTES*8)-1:0]        i_fdi_lp_data_die_0;
    logic                           i_fdi_lp_valid_die_0;

    //-------- CSR -------//
    // Protocol Signals
    logic                           i_P_Select_die_0;
    logic                           i_P_Enable_die_0;
    e_CSR_p_addr                    i_P_addr_die_0;
    e_CSR_p_data                    i_P_WDATA_die_0;
    logic                           i_P_WR_die_0;

    //-------- PHY Model -------//
    //Test Bench Inputs 

    logic                           i_phy_req_trainerror_die_0;
    logic                           i_phy_req_nferror_die_0;
    logic                           i_phy_req_cerror_die_0;
    logic                           i_phy_req_pl_error_die_0;
    logic                           i_phy_req_data_error_die_0;



    //------------------------ Outputs ------------------------//
    //------- CNTL -------//
    // FDI Signals
    logic [3:0]                    o_fdi_pl_state_sts_die_0_port;
    logic                          o_fdi_pl_inband_pres_die_0;
    logic                          o_fdi_pl_rx_active_req_die_0;
    logic [2:0]                    o_fdi_pl_protocol_die_0_port;
    logic [3:0]                    o_fdi_pl_protocol_flitfmt_die_0_port;
    logic                          o_fdi_pl_protocol_vld_die_0;
    logic [2:0]                    o_fdi_pl_speedmode_die_0_port;
    logic [2:0]                    o_fdi_pl_lnk_cfg_die_0_port;
    logic                          o_fdi_pl_error_die_0;
    logic                          o_fdi_pl_cerror_die_0;
    logic                          o_fdi_pl_nferror_die_0;
    logic                          o_fdi_pl_phyinrecenter_die_0;
    logic                          o_fdi_pl_trainerror_die_0;
    logic                          o_fdi_pl_trdy_die_0;
    logic [(NBYTES*8)-1:0]         o_fdi_pl_data_die_0;
    logic                          o_fdi_pl_valid_die_0;



    //-------- CSR -------//
    // Protocol Signals
    logic                          o_P_Ready_die_0;
    logic [31:0]                   o_P_RDATA_die_0_port;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////



    ////////////////////////////////////// Adapter_Die_1 /////////////////////////////////////
    //------------------------ Inputs ------------------------//
    //------- CNTL -------//
    // FDI Signals
    e_request                       i_fdi_lp_state_req_die_1;
    logic                           i_fdi_lp_rx_active_sts_die_1;
    logic                           i_fdi_lp_linkerror_die_1;
    logic                           i_fdi_lp_irdy_die_1;
    logic   [(NBYTES*8)-1:0]        i_fdi_lp_data_die_1;
    logic                           i_fdi_lp_valid_die_1;

    //-------- CSR -------//
    // Protocol Signals
    logic                           i_P_Select_die_1;
    logic                           i_P_Enable_die_1;
    e_CSR_p_addr                    i_P_addr_die_1;
    e_CSR_p_data                    i_P_WDATA_die_1;
    logic                           i_P_WR_die_1;

    //-------- PHY Model -------//
    //Test Bench Inputs 

    logic                           i_phy_req_trainerror_die_1;
    logic                           i_phy_req_nferror_die_1;
    logic                           i_phy_req_cerror_die_1;
    logic                           i_phy_req_pl_error_die_1;
    logic                           i_phy_req_data_error_die_1;



    //------------------------ Outputs ------------------------//
    //------- CNTL -------//
    // FDI Signals
    logic [3:0]                    o_fdi_pl_state_sts_die_1_port;
    logic                          o_fdi_pl_inband_pres_die_1;
    logic                          o_fdi_pl_rx_active_req_die_1;
    logic [2:0]                    o_fdi_pl_protocol_die_1_port;
    logic [3:0]                    o_fdi_pl_protocol_flitfmt_die_1_port;
    logic                          o_fdi_pl_protocol_vld_die_1;
    logic [2:0]                    o_fdi_pl_speedmode_die_1_port;
    logic [2:0]                    o_fdi_pl_lnk_cfg_die_1_port;
    logic                          o_fdi_pl_error_die_1;
    logic                          o_fdi_pl_cerror_die_1;
    logic                          o_fdi_pl_nferror_die_1;
    logic                          o_fdi_pl_phyinrecenter_die_1;
    logic                          o_fdi_pl_trainerror_die_1;
    logic                          o_fdi_pl_trdy_die_1;
    logic [(NBYTES*8)-1:0]         o_fdi_pl_data_die_1;
    logic                          o_fdi_pl_valid_die_1;



    //-------- CSR -------//
    // Protocol Signals
    logic                          o_P_Ready_die_1;
    logic [31:0]                   o_P_RDATA_die_1_port;


////////////////////////////////////////////////////////    END OF PORTS /////////////////////////////////////////////////////////    


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    e_status                       o_fdi_pl_state_sts_die_0;
    e_protocol                     o_fdi_pl_protocol_die_0;
    e_format                       o_fdi_pl_protocol_flitfmt_die_0;
    e_speed                        o_fdi_pl_speedmode_die_0;
    e_lnk_cfg                      o_fdi_pl_lnk_cfg_die_0;
    e_CSR_p_data                   o_P_RDATA_die_0;

    e_status                       o_fdi_pl_state_sts_die_1;
    e_protocol                     o_fdi_pl_protocol_die_1;
    e_format                       o_fdi_pl_protocol_flitfmt_die_1;
    e_speed                        o_fdi_pl_speedmode_die_1;
    e_lnk_cfg                      o_fdi_pl_lnk_cfg_die_1;
    e_CSR_p_data                   o_P_RDATA_die_1;



    ////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// die_0 //////////////////////////////////////////
    e_states                cs_cntl_fsm_die_0, ns_cntl_fsm_die_0;

    phy_states_e            cs_phy_fsm_die_0 , ns_phy_fsm_die_0;
    data_transfer_states_e  cs_phy_data_transfer_die_0,ns_phy_data_transfer_die_0;
    sb_interface_states_e   cs_phy_sb_interface_TX_die_0 ,ns_phy_sb_interface_TX_die_0;
    sb_interface_states_e   cs_phy_sb_interface_RX_die_0 ,ns_phy_sb_interface_RX_die_0;


    SB_TX_e                 cs_SB_TX_die_0,ns_SB_TX_die_0;
    SB_RX_e                 cs_SB_RX_die_0,ns_SB_RX_die_0;


    TX_states_e             cs_TX_MOD_die_0,ns_TX_MOD_die_0;
    RX_states_e             cs_RX_MOD_die_0,ns_RX_MOD_die_0;

    wire                    Start_UCIe_Link_Training_die_0;


    ////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////// die_1 //////////////////////////////////////////////////
    e_states                cs_cntl_fsm_die_1, ns_cntl_fsm_die_1;

    phy_states_e            cs_phy_fsm_die_1 , ns_phy_fsm_die_1;
    data_transfer_states_e  cs_phy_data_transfer_die_1,ns_phy_data_transfer_die_1;
    sb_interface_states_e   cs_phy_sb_interface_TX_die_1 ,ns_phy_sb_interface_TX_die_1;
    sb_interface_states_e   cs_phy_sb_interface_RX_die_1 ,ns_phy_sb_interface_RX_die_1;


    SB_TX_e                 cs_SB_TX_die_1,ns_SB_TX_die_1;
    SB_RX_e                 cs_SB_RX_die_1,ns_SB_RX_die_1;


    TX_states_e             cs_TX_MOD_die_1,ns_TX_MOD_die_1;
    RX_states_e             cs_RX_MOD_die_1,ns_RX_MOD_die_1;

    wire                    Start_UCIe_Link_Training_die_1;


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Clock Generation
    initial begin
        forever
            #(CLK_PERIOD/2) i_clk = ~i_clk;
    end

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    assign o_fdi_pl_state_sts_die_0         = e_status'(o_fdi_pl_state_sts_die_0_port);
    assign o_fdi_pl_protocol_die_0          = e_protocol'(o_fdi_pl_protocol_die_0_port);
    assign o_fdi_pl_protocol_flitfmt_die_0  = e_format'(o_fdi_pl_protocol_flitfmt_die_0_port);
    assign o_fdi_pl_speedmode_die_0         = e_speed'(o_fdi_pl_speedmode_die_0_port);
    assign o_fdi_pl_lnk_cfg_die_0           = e_lnk_cfg'(o_fdi_pl_lnk_cfg_die_0_port);
    assign o_P_RDATA_die_0                  = e_CSR_p_data'(o_P_RDATA_die_0_port);

    assign o_fdi_pl_state_sts_die_1         = e_status'(o_fdi_pl_state_sts_die_1_port);
    assign o_fdi_pl_protocol_die_1          = e_protocol'(o_fdi_pl_protocol_die_1_port);
    assign o_fdi_pl_protocol_flitfmt_die_1  = e_format'(o_fdi_pl_protocol_flitfmt_die_1_port);
    assign o_fdi_pl_speedmode_die_1         = e_speed'(o_fdi_pl_speedmode_die_1_port);
    assign o_fdi_pl_lnk_cfg_die_1           = e_lnk_cfg'(o_fdi_pl_lnk_cfg_die_1_port);
    assign o_P_RDATA_die_1                  = e_CSR_p_data'(o_P_RDATA_die_1_port);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    assign cs_cntl_fsm_die_0                = e_states'(DUT_2_DUT.Adapter_Die_0.CNTL.CNTL_FSM.cs);                           
    assign ns_cntl_fsm_die_0                = e_states'(DUT_2_DUT.Adapter_Die_0.CNTL.CNTL_FSM.ns);

    assign cs_phy_fsm_die_0                 =phy_states_e'(DUT_2_DUT.Adapter_Die_0.PHY.Control_DUT.r_current_state);
    assign ns_phy_fsm_die_0                 =phy_states_e'(DUT_2_DUT.Adapter_Die_0.PHY.Control_DUT.w_next_state);

    assign cs_phy_data_transfer_die_0       =data_transfer_states_e'(DUT_2_DUT.Adapter_Die_0.PHY.Data_transfer_DUT.r_current_state);
    assign ns_phy_data_transfer_die_0       =data_transfer_states_e'(DUT_2_DUT.Adapter_Die_0.PHY.Data_transfer_DUT.w_next_state);

    assign cs_phy_sb_interface_TX_die_0     =sb_interface_states_e'(DUT_2_DUT.Adapter_Die_0.PHY.SB_interface_DUT.TX.r_current_state);
    assign ns_phy_sb_interface_TX_die_0     =sb_interface_states_e'(DUT_2_DUT.Adapter_Die_0.PHY.SB_interface_DUT.TX.w_next_state);
    assign cs_phy_sb_interface_RX_die_0     =sb_interface_states_e'(DUT_2_DUT.Adapter_Die_0.PHY.SB_interface_DUT.RX.r_current_state);
    assign ns_phy_sb_interface_RX_die_0     =sb_interface_states_e'(DUT_2_DUT.Adapter_Die_0.PHY.SB_interface_DUT.RX.w_next_state);

    assign cs_SB_TX_die_0                   =SB_TX_e'(DUT_2_DUT.Adapter_Die_0.SB.sb_tx_inst.fsm_inst.r_current_state);
    assign ns_SB_TX_die_0                   =SB_TX_e'(DUT_2_DUT.Adapter_Die_0.SB.sb_tx_inst.fsm_inst.r_next_state);

    assign cs_SB_RX_die_0                   =SB_RX_e'(DUT_2_DUT.Adapter_Die_0.SB.sb_rx_inst.fsm_inst.r_current_state);
    assign ns_SB_RX_die_0                   =SB_RX_e'(DUT_2_DUT.Adapter_Die_0.SB.sb_rx_inst.fsm_inst.r_next_state);

    assign cs_TX_MOD_die_0                  =TX_states_e'(DUT_2_DUT.Adapter_Die_0.TX.fsm_tx.CS);
    assign ns_TX_MOD_die_0                  =TX_states_e'(DUT_2_DUT.Adapter_Die_0.TX.fsm_tx.NS);

    assign cs_RX_MOD_die_0                  =RX_states_e'(DUT_2_DUT.Adapter_Die_0.RX.FSM.r_current_state);
    assign ns_RX_MOD_die_0                  =RX_states_e'(DUT_2_DUT.Adapter_Die_0.RX.FSM.r_next_state);

    assign Start_UCIe_Link_Training_die_0   =DUT_2_DUT.Adapter_Die_0.PHY.phy_CSR_DUT.mem['h11][2];



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    assign cs_cntl_fsm_die_1                = e_states'(DUT_2_DUT.Adapter_Die_1.CNTL.CNTL_FSM.cs);                           
    assign ns_cntl_fsm_die_1                = e_states'(DUT_2_DUT.Adapter_Die_1.CNTL.CNTL_FSM.ns);

    assign cs_phy_fsm_die_1                 =phy_states_e'(DUT_2_DUT.Adapter_Die_1.PHY.Control_DUT.r_current_state);
    assign ns_phy_fsm_die_1                 =phy_states_e'(DUT_2_DUT.Adapter_Die_1.PHY.Control_DUT.w_next_state);

    assign cs_phy_data_transfer_die_1       =data_transfer_states_e'(DUT_2_DUT.Adapter_Die_1.PHY.Data_transfer_DUT.r_current_state);
    assign ns_phy_data_transfer_die_1       =data_transfer_states_e'(DUT_2_DUT.Adapter_Die_1.PHY.Data_transfer_DUT.w_next_state);

    assign cs_phy_sb_interface_TX_die_1     =sb_interface_states_e'(DUT_2_DUT.Adapter_Die_1.PHY.SB_interface_DUT.TX.r_current_state);
    assign ns_phy_sb_interface_TX_die_1     =sb_interface_states_e'(DUT_2_DUT.Adapter_Die_1.PHY.SB_interface_DUT.TX.w_next_state);
    assign cs_phy_sb_interface_RX_die_1     =sb_interface_states_e'(DUT_2_DUT.Adapter_Die_1.PHY.SB_interface_DUT.RX.r_current_state);
    assign ns_phy_sb_interface_RX_die_1     =sb_interface_states_e'(DUT_2_DUT.Adapter_Die_1.PHY.SB_interface_DUT.RX.w_next_state);

    assign cs_SB_TX_die_1                   =SB_TX_e'(DUT_2_DUT.Adapter_Die_1.SB.sb_tx_inst.fsm_inst.r_current_state);
    assign ns_SB_TX_die_1                   =SB_TX_e'(DUT_2_DUT.Adapter_Die_1.SB.sb_tx_inst.fsm_inst.r_next_state);

    assign cs_SB_RX_die_1                   =SB_RX_e'(DUT_2_DUT.Adapter_Die_1.SB.sb_rx_inst.fsm_inst.r_current_state);
    assign ns_SB_RX_die_1                   =SB_RX_e'(DUT_2_DUT.Adapter_Die_1.SB.sb_rx_inst.fsm_inst.r_next_state);

    assign cs_TX_MOD_die_1                  =TX_states_e'(DUT_2_DUT.Adapter_Die_1.TX.fsm_tx.CS);
    assign ns_TX_MOD_die_1                  =TX_states_e'(DUT_2_DUT.Adapter_Die_1.TX.fsm_tx.NS);

    assign cs_RX_MOD_die_1                  =RX_states_e'(DUT_2_DUT.Adapter_Die_1.RX.FSM.r_current_state);
    assign ns_RX_MOD_die_1                  =RX_states_e'(DUT_2_DUT.Adapter_Die_1.RX.FSM.r_next_state);

    assign Start_UCIe_Link_Training_die_1   =DUT_2_DUT.Adapter_Die_1.PHY.phy_CSR_DUT.mem['h11][2];

   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


      UCIE_ctl_TOP_DUT2DUT #(
        .NBYTES(NBYTES),      
        .NC(NC),          
        .UCIE_ACTIVE(UCIE_ACTIVE),                        
        .FIFO_DEPTH_TX(FIFO_DEPTH_TX),
        .DATA_WIDTH_TX(DATA_WIDTH_TX)
    )

      DUT_2_DUT

    (
    ////////////////////////////////////// Adapter_Die_0 /////////////////////////////////////
    //------------------------ Inputs ------------------------//
        .i_clk_die_0(i_clk),
        .i_rst_n_die_0(i_rst_n),

        //------- CNTL -------//
        // FDI Signals
        .i_fdi_lp_state_req_die_0(i_fdi_lp_state_req_die_0),
        .i_fdi_lp_rx_active_sts_die_0(i_fdi_lp_rx_active_sts_die_0),
        .i_fdi_lp_linkerror_die_0(i_fdi_lp_linkerror_die_0),
        .i_fdi_lp_irdy_die_0(i_fdi_lp_irdy_die_0),
        .i_fdi_lp_data_die_0(i_fdi_lp_data_die_0),
        .i_fdi_lp_valid_die_0(i_fdi_lp_valid_die_0),

        //-------- CSR -------//
        // Protocol Signals
        .i_P_Select_die_0(i_P_Select_die_0),
        .i_P_Enable_die_0(i_P_Enable_die_0),
        .i_P_addr_die_0(i_P_addr_die_0),
        .i_P_WDATA_die_0(i_P_WDATA_die_0),
        .i_P_WR_die_0(i_P_WR_die_0),

        //-------- PHY Model -------//
        //Test Bench Inputs 

        .i_phy_req_trainerror_die_0(i_phy_req_trainerror_die_0),
        .i_phy_req_nferror_die_0(i_phy_req_nferror_die_0),
        .i_phy_req_cerror_die_0(i_phy_req_cerror_die_0),
        .i_phy_req_pl_error_die_0(i_phy_req_pl_error_die_0),
        .i_phy_req_data_error_die_0(i_phy_req_data_error_die_0),


        //------------------------ Outputs ------------------------//
        //------- CNTL -------//
        // FDI Signals
        .o_fdi_pl_state_sts_die_0(o_fdi_pl_state_sts_die_0_port),
        .o_fdi_pl_inband_pres_die_0(o_fdi_pl_inband_pres_die_0),
        .o_fdi_pl_rx_active_req_die_0(o_fdi_pl_rx_active_req_die_0),
        .o_fdi_pl_protocol_die_0(o_fdi_pl_protocol_die_0_port),
        .o_fdi_pl_protocol_flitfmt_die_0(o_fdi_pl_protocol_flitfmt_die_0_port),
        .o_fdi_pl_protocol_vld_die_0(o_fdi_pl_protocol_vld_die_0),
        .o_fdi_pl_speedmode_die_0(o_fdi_pl_speedmode_die_0_port),
        .o_fdi_pl_lnk_cfg_die_0(o_fdi_pl_lnk_cfg_die_0_port),
        .o_fdi_pl_error_die_0(o_fdi_pl_error_die_0),
        .o_fdi_pl_cerror_die_0(o_fdi_pl_cerror_die_0),
        .o_fdi_pl_nferror_die_0(o_fdi_pl_nferror_die_0),
        .o_fdi_pl_phyinrecenter_die_0(o_fdi_pl_phyinrecenter_die_0),
        .o_fdi_pl_trainerror_die_0(o_fdi_pl_trainerror_die_0),
        .o_fdi_pl_trdy_die_0(o_fdi_pl_trdy_die_0),
        .o_fdi_pl_data_die_0(o_fdi_pl_data_die_0),
        .o_fdi_pl_valid_die_0(o_fdi_pl_valid_die_0),


    


        //-------- CSR -------//
        // Protocol Signals
        .o_P_Ready_die_0(o_P_Ready_die_0),
        .o_P_RDATA_die_0(o_P_RDATA_die_0_port),

        ////////////////////////////////////////////////////////////////////////////////////////////////////////



        ////////////////////////////////////// Adapter_Die_1 /////////////////////////////////////
        //------------------------ Inputs ------------------------//
        .i_clk_die_1(i_clk),
        .i_rst_n_die_1(i_rst_n),

        //------- CNTL -------//
        // FDI Signals
        .i_fdi_lp_state_req_die_1(i_fdi_lp_state_req_die_1),
        .i_fdi_lp_rx_active_sts_die_1(i_fdi_lp_rx_active_sts_die_1),
        .i_fdi_lp_linkerror_die_1(i_fdi_lp_linkerror_die_1),
        .i_fdi_lp_irdy_die_1(i_fdi_lp_irdy_die_1),
        .i_fdi_lp_data_die_1(i_fdi_lp_data_die_1),
        .i_fdi_lp_valid_die_1(i_fdi_lp_valid_die_1),

        //-------- CSR -------//
        // Protocol Signals
        .i_P_Select_die_1(i_P_Select_die_1),
        .i_P_Enable_die_1(i_P_Enable_die_1),
        .i_P_addr_die_1(i_P_addr_die_1),
        .i_P_WDATA_die_1(i_P_WDATA_die_1),
        .i_P_WR_die_1(i_P_WR_die_1),

        //-------- PHY Model -------//
        //Test Bench Inputs 

        .i_phy_req_trainerror_die_1(i_phy_req_trainerror_die_1),
        .i_phy_req_nferror_die_1(i_phy_req_nferror_die_1),
        .i_phy_req_cerror_die_1(i_phy_req_cerror_die_1),
        .i_phy_req_pl_error_die_1(i_phy_req_pl_error_die_1),
        .i_phy_req_data_error_die_1(i_phy_req_data_error_die_1),




        //------------------------ Outputs ------------------------//
        //------- CNTL -------//
        // FDI Signals
        .o_fdi_pl_state_sts_die_1(o_fdi_pl_state_sts_die_1_port),
        .o_fdi_pl_inband_pres_die_1(o_fdi_pl_inband_pres_die_1),
        .o_fdi_pl_rx_active_req_die_1(o_fdi_pl_rx_active_req_die_1),
        .o_fdi_pl_protocol_die_1(o_fdi_pl_protocol_die_1_port),
        .o_fdi_pl_protocol_flitfmt_die_1(o_fdi_pl_protocol_flitfmt_die_1_port),
        .o_fdi_pl_protocol_vld_die_1(o_fdi_pl_protocol_vld_die_1),
        .o_fdi_pl_speedmode_die_1(o_fdi_pl_speedmode_die_1_port),
        .o_fdi_pl_lnk_cfg_die_1(o_fdi_pl_lnk_cfg_die_1_port),
        .o_fdi_pl_error_die_1(o_fdi_pl_error_die_1),
        .o_fdi_pl_cerror_die_1(o_fdi_pl_cerror_die_1),
        .o_fdi_pl_nferror_die_1(o_fdi_pl_nferror_die_1),
        .o_fdi_pl_phyinrecenter_die_1(o_fdi_pl_phyinrecenter_die_1),
        .o_fdi_pl_trainerror_die_1(o_fdi_pl_trainerror_die_1),
        .o_fdi_pl_trdy_die_1(o_fdi_pl_trdy_die_1),
        .o_fdi_pl_data_die_1(o_fdi_pl_data_die_1),
        .o_fdi_pl_valid_die_1(o_fdi_pl_valid_die_1),

        //-------- CSR -------//
        // Protocol Signals
        .o_P_Ready_die_1(o_P_Ready_die_1),
        .o_P_RDATA_die_1(o_P_RDATA_die_1_port)

    );

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                
    task Active_Entry (DUT_id, e_active_trig trigger);
        i_fdi_lp_linkerror_die_0 = 0;
        i_fdi_lp_linkerror_die_1 = 0;

        case (trigger)
            CSR_START_UCIE_LINK_TRAINING: begin

                apb_write(DUT_id, UCIE_LINK_CONTROL, START_UCIE_LINK_TRAINING);
            
            end

            PROTOCOL_NOP_ACTIVE_REQ: begin
               
                if (DUT_id) begin

                    i_fdi_lp_state_req_die_1 = NOP_REQ;
                    @(negedge i_clk);
                    i_fdi_lp_state_req_die_1 = ACTIVE_REQ;

                end
                else begin

                    i_fdi_lp_state_req_die_0 = NOP_REQ;
                    @(negedge i_clk);
                    i_fdi_lp_state_req_die_0 = ACTIVE_REQ;

                end
            
            end

            PROTOCOL_ACTIVE_REQ: begin

                if (DUT_id)
                    i_fdi_lp_state_req_die_1 = ACTIVE_REQ;
                else
                    i_fdi_lp_state_req_die_0 = ACTIVE_REQ;

            end
        endcase

        @(negedge i_clk);

    endtask : Active_Entry

    task LinkReset_Entry (DUT_id, e_linkreset_trig trigger);

        case (trigger)
            PROTOCOL_NOP_LINKRESET_REQ: begin
                if (DUT_id) begin

                    i_fdi_lp_state_req_die_1 = NOP_REQ;
                    @(negedge i_clk);
                    i_fdi_lp_state_req_die_1 = LINKRESET_REQ;

                end
                else begin
                    
                    i_fdi_lp_state_req_die_0 = NOP_REQ;
                    @(negedge i_clk);
                    i_fdi_lp_state_req_die_0 = LINKRESET_REQ;

                end
            end
            PROTOCOL_LINKRESET_REQ: begin

                if (DUT_id)
                    i_fdi_lp_state_req_die_1 = LINKRESET_REQ;
                else
                    i_fdi_lp_state_req_die_0 = LINKRESET_REQ;

            end
        endcase

        @(negedge i_clk);

    endtask : LinkReset_Entry

    task Retrain_Entry (DUT_id, e_retrain_trig trigger);

        case (trigger)
            CSR_RETRAIN_UCIE_LINK: begin

                apb_write(DUT_id, UCIE_LINK_CONTROL, RETRAIN_UCIE_LINK);
            
            end
            PROTOCOL_RETRAIN_REQ: begin
            
                if (DUT_id)
                    i_fdi_lp_state_req_die_1 = RETRAIN_REQ;
                else
                    i_fdi_lp_state_req_die_0 = RETRAIN_REQ;
            
            end
        endcase

        @(negedge i_clk);

    endtask : Retrain_Entry

    task LinkError_Entry (DUT_id, e_linkerror_trig trigger);

        case (trigger)
            CSR_START_UCIE_LINK_TRAINING_WHILE_ACTIVE: begin

                apb_write(DUT_id, UCIE_LINK_CONTROL, START_UCIE_LINK_TRAINING);
            
            end
            CSR_ADVCAP_MISMATCH: begin

                fork
                    apb_write(!DUT_id, ADVCAP, STREAMING_RAW);
                    apb_write(DUT_id, ADVCAP, NOT_STREAMING_RAW);
                join
                @(negedge i_clk);

                Active_Entry(DUT_id,PROTOCOL_NOP_ACTIVE_REQ);
            
            end

            PROTOCOL_LINKERROR_REQ: begin

                if (DUT_id)
                    i_fdi_lp_linkerror_die_1 = 1;
                else
                    i_fdi_lp_linkerror_die_0 = 1;

            end

        endcase

        @(negedge i_clk);

    endtask : LinkError_Entry


    task initialize_inputs;
        i_rst_n                         = 0;

        // FDI Signals
        i_fdi_lp_state_req_die_0        = NOP_REQ;
        i_fdi_lp_rx_active_sts_die_0    = 0;
        i_fdi_lp_linkerror_die_0        = 0;
        i_fdi_lp_irdy_die_0             = 0;
        i_fdi_lp_data_die_0             = 0;
        i_fdi_lp_valid_die_0            = 0;

        i_fdi_lp_state_req_die_1        = NOP_REQ;
        i_fdi_lp_rx_active_sts_die_1    = 0;
        i_fdi_lp_linkerror_die_1        = 0;
        i_fdi_lp_irdy_die_1             = 0;
        i_fdi_lp_data_die_1             = 0;
        i_fdi_lp_valid_die_1            = 0;

        // Protocol APB
        i_P_Select_die_0        = 0;
        i_P_Enable_die_0        = 1;
        i_P_addr_die_0          = UCIE_LINK_CONTROL;
        i_P_WDATA_die_0         = INITALIZATION;
        i_P_WR_die_0            = 0;

        i_P_Select_die_1        = 0;
        i_P_Enable_die_1        = 1;
        i_P_addr_die_1          = UCIE_LINK_CONTROL;
        i_P_WDATA_die_1         = INITALIZATION;
        i_P_WR_die_1            = 0;

        // PHY Model
        i_phy_req_trainerror_die_0      = 0;
        i_phy_req_nferror_die_0         = 0;
        i_phy_req_cerror_die_0          = 0;
        i_phy_req_pl_error_die_0        = 0;
        i_phy_req_data_error_die_0      = 0;

        i_phy_req_trainerror_die_1      = 0;
        i_phy_req_nferror_die_1         = 0;
        i_phy_req_cerror_die_1          = 0;
        i_phy_req_pl_error_die_1        = 0;
        i_phy_req_data_error_die_1      = 0;
    endtask : initialize_inputs


    task apb_write(DUT_id, e_CSR_p_addr ADDR, e_CSR_p_data WDATA);
        @(posedge i_clk);

        if (DUT_id) begin

            i_P_Select_die_1 = 1;
            i_P_Enable_die_1 = 0;
            i_P_WR_die_1 = 1;

            i_P_addr_die_1 = ADDR;
            i_P_WDATA_die_1 = WDATA;

            @(posedge i_clk);
            i_P_Enable_die_1 = 1;

            @(posedge i_clk);
            i_P_Select_die_1 = 0;
            i_P_WR_die_1 = 0;

        end
        else begin

            i_P_Select_die_0 = 1;
            i_P_Enable_die_0 = 0;
            i_P_WR_die_0 = 1;

            i_P_addr_die_0 = ADDR;
            i_P_WDATA_die_0 = WDATA;

            @(posedge i_clk);
            i_P_Enable_die_0 = 1;

            @(posedge i_clk);
            i_P_Select_die_0 = 0;
            i_P_WR_die_0 = 0;

        end
                
    endtask : apb_write


    task global_reset();
        initialize_inputs();

        $display("[%0t] ***************************************************************** Reset Asserted *****************************************************************\n", $time());
        
        i_rst_n=0;

        repeat (5) @(negedge i_clk);

        i_rst_n=1;

        $display("[%0t] **************************************************************** Reset Deasserted ****************************************************************\n", $time());
        
    endtask


    task Retrain_Flow_Diagram_test(input use_CSR);

        if (use_CSR) begin
            $display("[%0t] ************************************************************* Retrain Entry triggered by (SW) Started *************************************************************\n", $time());
            
            Retrain_Entry(0, CSR_RETRAIN_UCIE_LINK);
            repeat(30) @(negedge i_clk);        // Retrain State

            if (o_fdi_pl_state_sts_die_0 == RETRAIN_STS && o_fdi_pl_state_sts_die_1 == RETRAIN_STS)
                $display("[%0t] **************************************************************** Retrain Entry Succeeded ****************************************************************\n", $time());
            else begin
                $display("[%0t] ****************************************************************** Retrain Entry Failed **************************************************************\n", $time());
                $stop();
            end

            $display("[%0t] ************************************************************* Active Entry triggered by (SW) Started *************************************************************\n", $time());
            
            fork
                begin
                    Active_Entry(0, PROTOCOL_NOP_ACTIVE_REQ);
                end

                begin
                    repeat (2) @(negedge i_clk);
                    Active_Entry(1, PROTOCOL_NOP_ACTIVE_REQ);
                end
            join
            repeat (50) @(negedge i_clk);       // Active  State

            if (o_fdi_pl_state_sts_die_0 == ACTIVE_STS && o_fdi_pl_state_sts_die_1 == ACTIVE_STS)
                $display("[%0t] **************************************************************** Active Entry Succeeded ****************************************************************\n", $time());
            else begin
                $display("[%0t] ***************************************************************** Active Entry Failed ***************************************************************\n", $time());
                $stop();
            end
        end
        else begin
            $display("[%0t] ************************************************************* Retrain Entry triggered by (Protocol) Started *************************************************************\n", $time());
            
            Retrain_Entry(0, PROTOCOL_RETRAIN_REQ);
            repeat(30) @(negedge i_clk);        // Retrain State

            if (o_fdi_pl_state_sts_die_0 == RETRAIN_STS && o_fdi_pl_state_sts_die_1 == RETRAIN_STS)
                $display("[%0t] **************************************************************** Retrain Entry Succeeded ****************************************************************\n", $time());
            else begin
                $display("[%0t] ****************************************************************** Retrain Entry Failed **************************************************************\n", $time());
                $stop();
            end

            $display("[%0t] ************************************************************* Active Entry triggered by (Protocol) Started *************************************************************\n", $time());
            
            fork
                begin
                    Active_Entry(0, PROTOCOL_NOP_ACTIVE_REQ);
                end

                begin
                    repeat (2) @(negedge i_clk);
                    Active_Entry(1, PROTOCOL_NOP_ACTIVE_REQ);
                end
            join

            repeat (50) @(negedge i_clk);       // Active  State

            if (o_fdi_pl_state_sts_die_0 == ACTIVE_STS && o_fdi_pl_state_sts_die_1 == ACTIVE_STS)
                $display("[%0t] **************************************************************** Active Entry Succeeded ****************************************************************\n", $time());
            else begin
                $display("[%0t] ***************************************************************** Active Entry Failed ***************************************************************\n", $time());
                $stop();
            end
        end
    endtask : Retrain_Flow_Diagram_test


    task LinkError_Flow_Diagram_test(input use_CSR);

        if (use_CSR) begin
            $display("[%0t] ********************************************** LinkError Entry triggered by (SW - UCIe_Start_Link_Training 0->1) Started **********************************************\n", $time());
        
            LinkError_Entry(1, CSR_START_UCIE_LINK_TRAINING_WHILE_ACTIVE);
            repeat (5) @(negedge i_clk);       // LinkError  State

            if (o_fdi_pl_state_sts_die_0 == LINKERROR_STS && o_fdi_pl_state_sts_die_1 == LINKERROR_STS)
                $display("[%0t] **************************************************************** LinkError Entry Succeeded ****************************************************************\n", $time());
            else begin
                $display("[%0t] ***************************************************************** LinkError Entry Failed ***************************************************************\n", $time());
                $stop();
            end

            repeat (10) @(negedge i_clk);       // Reset  State
        end
        else begin
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
             $display("[%0t] ****************************************************** LinkError Entry triggered by (Protocol) Started ******************************************************\n", $time());
             i_fdi_lp_state_req_die_0=NOP_REQ;
             i_fdi_lp_state_req_die_1=NOP_REQ;

            LinkError_Entry(0, PROTOCOL_LINKERROR_REQ);
            repeat (20) @(negedge i_clk);       // LinkError  State


            if (o_fdi_pl_state_sts_die_0 == LINKERROR_STS && o_fdi_pl_state_sts_die_1 == RESET_STS)
                $display("[%0t] **************************************************************** LinkError Entry Succeeded ****************************************************************\n", $time());
            else begin
                $display("[%0t] ***************************************************************** LinkError Entry Failed ***************************************************************\n", $time());
                $stop();
            end

            Active_Entry(0, PROTOCOL_ACTIVE_REQ);
            repeat (170) @(negedge i_clk);       // Reset  State
        end

        $display("[%0t] ************************************************************* Active Entry triggered by (Protocol) Started *************************************************************\n", $time());


        Active_Entry(0, PROTOCOL_NOP_ACTIVE_REQ);
        repeat (50) @(negedge i_clk);       // Active  State

        if (o_fdi_pl_state_sts_die_0 == ACTIVE_STS && o_fdi_pl_state_sts_die_1 == ACTIVE_STS)
            $display("[%0t] **************************************************************** Active Entry Succeeded ****************************************************************\n", $time());
        else begin
            $display("[%0t] ***************************************************************** Active Entry Failed ***************************************************************\n", $time());
            $stop();
        end
        

        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        $display("[%0t] ****************************************************** LinkError Entry triggered by (ADVCAP MisMatch) Started ******************************************************\n", $time());

        LinkError_Entry(0, PROTOCOL_LINKERROR_REQ);
        repeat (20) @(negedge i_clk);       // LinkError  State
        Active_Entry(0, PROTOCOL_ACTIVE_REQ);
        repeat (170) @(negedge i_clk);       // Reset  State

        LinkError_Entry(0,CSR_ADVCAP_MISMATCH);
        repeat (50) @(negedge i_clk);       // LinkError  State

        if (o_fdi_pl_state_sts_die_0 == LINKERROR_STS && o_fdi_pl_state_sts_die_1 == LINKERROR_STS)
            $display("[%0t] **************************************************************** LinkError Entry Succeeded ****************************************************************\n", $time());
        else begin
            $display("[%0t] ***************************************************************** LinkError Entry Failed ***************************************************************\n", $time());
            $stop();
        end

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        apb_write(0, ADVCAP, STREAMING_RAW);
        apb_write(1, ADVCAP, STREAMING_RAW);

        Active_Entry(0, PROTOCOL_ACTIVE_REQ);
        Active_Entry(1, PROTOCOL_ACTIVE_REQ);
        repeat (170) @(negedge i_clk);       // Reset  State

        $display("[%0t] ************************************************************* Active Entry triggered by (SW) Started *************************************************************\n", $time());

        Active_Entry(0, CSR_START_UCIE_LINK_TRAINING);
        repeat (50) @(negedge i_clk);       // Active  State

        if (o_fdi_pl_state_sts_die_0 == ACTIVE_STS && o_fdi_pl_state_sts_die_1 == ACTIVE_STS)
            $display("[%0t] **************************************************************** Active Entry Succeeded ****************************************************************\n", $time());
        else begin
            $display("[%0t] ***************************************************************** Active Entry Failed ***************************************************************\n", $time());
            $stop();
        end   

    endtask : LinkError_Flow_Diagram_test


    task LinkReset_Flow_Diagram_test();
        i_fdi_lp_state_req_die_0=NOP_REQ;
        i_fdi_lp_state_req_die_1=NOP_REQ;

        $display("[%0t] ******************************************************** LinkReset Entry triggered by (Protocol) Started ********************************************************\n", $time());
        
        LinkReset_Entry(0, PROTOCOL_LINKRESET_REQ);
        repeat (50) @(negedge i_clk);       // LinkError  State

        if (o_fdi_pl_state_sts_die_0 == LINKRESET_STS && o_fdi_pl_state_sts_die_1 == RESET_STS)
            $display("[%0t] **************************************************************** LinkReset Entry Succeeded ****************************************************************\n", $time());
        else begin
            $display("[%0t] ***************************************************************** LinkReset Entry Failed ***************************************************************\n", $time());
            $stop();
        end

        $display("[%0t] ************************************************************* LinkReset Entry triggered by (Protocol) Started *************************************************************\n", $time());
        
        Active_Entry(0, PROTOCOL_ACTIVE_REQ);
        repeat (10) @(negedge i_clk);       // Reset  State
        Active_Entry(0, PROTOCOL_NOP_ACTIVE_REQ);
        repeat (50) @(negedge i_clk);       // Active  State



        if (o_fdi_pl_state_sts_die_0 == ACTIVE_STS && o_fdi_pl_state_sts_die_1 == ACTIVE_STS)
            $display("[%0t] ****************************************************************  ACTIVE Entry Succeeded ****************************************************************\n", $time());
        else begin
            $display("[%0t] ***************************************************************** ACTIVE Entry Failed ***************************************************************\n", $time());
            $stop();
        end

    endtask : LinkReset_Flow_Diagram_test

    task link_training_reset;
         DUT_2_DUT.Adapter_Die_0.CSR.mem['h11][2]=0;
    endtask

    task send_data(DUT_id,logic  [(NBYTES*8)-1:0] i_fdi_lp_data_die_t,logic stream_mode=0);
        @(negedge i_clk);

        if(!DUT_id) begin
            i_fdi_lp_data_die_0  =i_fdi_lp_data_die_t;
            i_fdi_lp_irdy_die_0     =1;
            i_fdi_lp_valid_die_0    =1;
        end
        else begin
            i_fdi_lp_data_die_1  =i_fdi_lp_data_die_t;
            i_fdi_lp_irdy_die_1     =1;
            i_fdi_lp_valid_die_1    =1;
        end 

        if (!stream_mode) begin
            @(negedge i_clk);

            if(!DUT_id) begin
                i_fdi_lp_data_die_0     =0;
                i_fdi_lp_irdy_die_0     =0;
                i_fdi_lp_valid_die_0    =0;
            end
            else begin
                i_fdi_lp_data_die_1     =0;
                i_fdi_lp_irdy_die_1     =0;
                i_fdi_lp_valid_die_1    =0;
            end 

        end

    endtask

    ////////////////////////////////////////// protocols triggers ///////////////////////////

    always @(posedge o_fdi_pl_inband_pres_die_0) begin
        @(posedge i_clk);
        i_fdi_lp_state_req_die_0=ACTIVE_REQ;
    end

    always @(posedge o_fdi_pl_inband_pres_die_1) begin
        @(posedge i_clk);
        i_fdi_lp_state_req_die_1=ACTIVE_REQ;
    end

    always @(posedge o_fdi_pl_rx_active_req_die_0) begin
        @(posedge i_clk);
        i_fdi_lp_rx_active_sts_die_0=1;
    end

    always @(posedge o_fdi_pl_rx_active_req_die_1) begin
        @(posedge i_clk);
        i_fdi_lp_rx_active_sts_die_1=1;
    end

    always @(negedge  o_fdi_pl_rx_active_req_die_0) begin
        @(posedge i_clk);
        i_fdi_lp_rx_active_sts_die_0=0;
    end

    always @(negedge  o_fdi_pl_rx_active_req_die_1) begin
        @(posedge i_clk);
        i_fdi_lp_rx_active_sts_die_1=0;
    end




        ////////////////////////////////////////// protocols triggers ///////////////////////////


    int correct_count=0;
    initial begin

        $display("[%0t] *********************************************************** Conventional Active Entry after Reset Started ***********************************************************\n", $time());
        global_reset();
        @(negedge i_clk)
        i_fdi_lp_state_req_die_0 = ACTIVE_REQ;
        @(negedge i_clk)
        i_fdi_lp_state_req_die_0 = NOP_REQ;
        @(negedge i_clk)
        i_fdi_lp_state_req_die_0 = ACTIVE_REQ;
        repeat(50) @(negedge i_clk);

        if (o_fdi_pl_state_sts_die_0 == ACTIVE_STS && o_fdi_pl_state_sts_die_1 == ACTIVE_STS) begin
            $display("[%0t] **************************************************************** Conventional Active Entry Test Succeeded ****************************************************************\n", $time());
            correct_count++;
        end
        else begin
            $display("[%0t] ***************************************************************** Active Entry Failed ***************************************************************\n", $time());
            $stop();
        end

        for (int i = 0; i < 40; i++) begin
            send_data(0,i,1);
        end
        $display("[%0t] ***************************************************************** Retrain Flow Diagram Test Started ***************************************************************\n", $time());

        Retrain_Flow_Diagram_test(1);
            correct_count++;


        $display("[%0t] ***************************************************************** Retrain Flow Diagram Test Succeeded ***************************************************************\n", $time());

        $display("[%0t] ***************************************************************** LinkReset Flow Diagram Test Started ***************************************************************\n", $time());
        LinkReset_Flow_Diagram_test();
        $display("[%0t] ***************************************************************** LinkReset Flow Diagram Test Succeeded ***************************************************************\n", $time());
         correct_count++;


        $display("[%0t] ***************************************************************** LinkError Flow Diagram Test Started ***************************************************************\n", $time());
        LinkError_Flow_Diagram_test(1);
        $display("[%0t] ***************************************************************** LinkError Flow Diagram Test Succeeded ***************************************************************\n", $time());
        correct_count++;

        $display("****************************** NUMBER OF PASSED TESTS = %0d *************************************",correct_count);
        @(negedge i_clk);
        $stop();

    end

endmodule : UCIE_ctl_DUT2DUT_tb
