onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/i_clk
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/i_rst_n
add wave -noupdate -height 40 -expand -group i_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/i_fdi_lp_state_req_die_0
add wave -noupdate -height 40 -expand -group i_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/i_fdi_lp_rx_active_sts_die_0
add wave -noupdate -height 40 -expand -group i_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/i_fdi_lp_linkerror_die_0
add wave -noupdate -height 40 -expand -group i_fdi_die_0 -color Magenta /UCIE_ctl_DUT2DUT_tb/i_fdi_lp_irdy_die_0
add wave -noupdate -height 40 -expand -group i_fdi_die_0 -color Magenta /UCIE_ctl_DUT2DUT_tb/i_fdi_lp_data_die_0
add wave -noupdate -height 40 -expand -group i_fdi_die_0 -color Magenta /UCIE_ctl_DUT2DUT_tb/i_fdi_lp_valid_die_0
add wave -noupdate -height 40 -expand -group i_fdi_die_0 -color Magenta /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_trdy_die_0
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/TX/o_rdi_lp_valid
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/TX/o_rdi_lp_irdy
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/TX/o_r_data
add wave -noupdate -height 40 -group i_APB_die_0 /UCIE_ctl_DUT2DUT_tb/i_P_Select_die_0
add wave -noupdate -height 40 -group i_APB_die_0 /UCIE_ctl_DUT2DUT_tb/i_P_Enable_die_0
add wave -noupdate -height 40 -group i_APB_die_0 /UCIE_ctl_DUT2DUT_tb/i_P_addr_die_0
add wave -noupdate -height 40 -group i_APB_die_0 /UCIE_ctl_DUT2DUT_tb/i_P_WDATA_die_0
add wave -noupdate -height 40 -group i_APB_die_0 /UCIE_ctl_DUT2DUT_tb/i_P_WR_die_0
add wave -noupdate -height 40 -group i_phy_injection_die_0 /UCIE_ctl_DUT2DUT_tb/i_phy_req_trainerror_die_0
add wave -noupdate -height 40 -group i_phy_injection_die_0 /UCIE_ctl_DUT2DUT_tb/i_phy_req_nferror_die_0
add wave -noupdate -height 40 -group i_phy_injection_die_0 /UCIE_ctl_DUT2DUT_tb/i_phy_req_cerror_die_0
add wave -noupdate -height 40 -group i_phy_injection_die_0 /UCIE_ctl_DUT2DUT_tb/i_phy_req_pl_error_die_0
add wave -noupdate -height 40 -group i_phy_injection_die_0 /UCIE_ctl_DUT2DUT_tb/i_phy_req_data_error_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_state_sts_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_inband_pres_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_rx_active_req_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 -color Magenta /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_data_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 -color Magenta /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_valid_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_error_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_cerror_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_nferror_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_phyinrecenter_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_trainerror_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_protocol_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_protocol_vld_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_protocol_flitfmt_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_speedmode_die_0
add wave -noupdate -height 40 -expand -group o_fdi_die_0 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_lnk_cfg_die_0
add wave -noupdate -height 40 -group o_APB_die_0 /UCIE_ctl_DUT2DUT_tb/o_P_RDATA_die_0
add wave -noupdate -height 40 -group o_APB_die_0 /UCIE_ctl_DUT2DUT_tb/o_P_Ready_die_0
add wave -noupdate -height 40 -expand -group i_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/i_fdi_lp_state_req_die_1
add wave -noupdate -height 40 -expand -group i_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/i_fdi_lp_rx_active_sts_die_1
add wave -noupdate -height 40 -expand -group i_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/i_fdi_lp_linkerror_die_1
add wave -noupdate -height 40 -expand -group i_fdi_die_1 -color Magenta /UCIE_ctl_DUT2DUT_tb/i_fdi_lp_irdy_die_1
add wave -noupdate -height 40 -expand -group i_fdi_die_1 -color Magenta /UCIE_ctl_DUT2DUT_tb/i_fdi_lp_data_die_1
add wave -noupdate -height 40 -expand -group i_fdi_die_1 -color Magenta /UCIE_ctl_DUT2DUT_tb/i_fdi_lp_valid_die_1
add wave -noupdate -height 40 -expand -group i_fdi_die_1 -color Magenta /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_trdy_die_1
add wave -noupdate -height 40 -group i_APB_die_1 /UCIE_ctl_DUT2DUT_tb/i_P_Select_die_1
add wave -noupdate -height 40 -group i_APB_die_1 /UCIE_ctl_DUT2DUT_tb/i_P_Enable_die_1
add wave -noupdate -height 40 -group i_APB_die_1 /UCIE_ctl_DUT2DUT_tb/i_P_addr_die_1
add wave -noupdate -height 40 -group i_APB_die_1 /UCIE_ctl_DUT2DUT_tb/i_P_WDATA_die_1
add wave -noupdate -height 40 -group i_APB_die_1 /UCIE_ctl_DUT2DUT_tb/i_P_WR_die_1
add wave -noupdate -height 40 -group i_phy_injection_die_1 /UCIE_ctl_DUT2DUT_tb/i_phy_req_trainerror_die_1
add wave -noupdate -height 40 -group i_phy_injection_die_1 /UCIE_ctl_DUT2DUT_tb/i_phy_req_nferror_die_1
add wave -noupdate -height 40 -group i_phy_injection_die_1 /UCIE_ctl_DUT2DUT_tb/i_phy_req_cerror_die_1
add wave -noupdate -height 40 -group i_phy_injection_die_1 /UCIE_ctl_DUT2DUT_tb/i_phy_req_pl_error_die_1
add wave -noupdate -height 40 -group i_phy_injection_die_1 /UCIE_ctl_DUT2DUT_tb/i_phy_req_data_error_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_state_sts_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_inband_pres_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_rx_active_req_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 -color Magenta /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_data_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 -color Magenta /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_valid_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_lnk_cfg_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_protocol_vld_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_error_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_cerror_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_nferror_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_phyinrecenter_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_trainerror_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_protocol_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_protocol_flitfmt_die_1
add wave -noupdate -height 40 -expand -group o_fdi_die_1 /UCIE_ctl_DUT2DUT_tb/o_fdi_pl_speedmode_die_1
add wave -noupdate -height 40 -group o_APB_die_1 /UCIE_ctl_DUT2DUT_tb/o_P_Ready_die_1
add wave -noupdate -height 40 -group o_APB_die_1 /UCIE_ctl_DUT2DUT_tb/o_P_RDATA_die_1
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/i_clk
add wave -noupdate -height 40 -expand -group CNTL_FSM /UCIE_ctl_DUT2DUT_tb/cs_cntl_fsm_die_0
add wave -noupdate -height 40 -expand -group CNTL_FSM /UCIE_ctl_DUT2DUT_tb/ns_cntl_fsm_die_0
add wave -noupdate -height 40 -expand -group CNTL_FSM /UCIE_ctl_DUT2DUT_tb/cs_cntl_fsm_die_1
add wave -noupdate -height 40 -expand -group CNTL_FSM /UCIE_ctl_DUT2DUT_tb/ns_cntl_fsm_die_1
add wave -noupdate -height 40 -expand -group PHY_FSM_MAIN /UCIE_ctl_DUT2DUT_tb/cs_phy_fsm_die_0
add wave -noupdate -height 40 -expand -group PHY_FSM_MAIN /UCIE_ctl_DUT2DUT_tb/ns_phy_fsm_die_0
add wave -noupdate -height 40 -expand -group PHY_FSM_MAIN /UCIE_ctl_DUT2DUT_tb/cs_phy_fsm_die_1
add wave -noupdate -height 40 -expand -group PHY_FSM_MAIN /UCIE_ctl_DUT2DUT_tb/ns_phy_fsm_die_1
add wave -noupdate -height 40 -expand -group PHY_FSM_SB_INTERFACE -color Magenta /UCIE_ctl_DUT2DUT_tb/cs_phy_sb_interface_TX_die_0
add wave -noupdate -height 40 -expand -group PHY_FSM_SB_INTERFACE /UCIE_ctl_DUT2DUT_tb/ns_phy_sb_interface_TX_die_0
add wave -noupdate -height 40 -expand -group PHY_FSM_SB_INTERFACE -color Magenta /UCIE_ctl_DUT2DUT_tb/cs_phy_sb_interface_RX_die_1
add wave -noupdate -height 40 -expand -group PHY_FSM_SB_INTERFACE /UCIE_ctl_DUT2DUT_tb/ns_phy_sb_interface_RX_die_1
add wave -noupdate -height 40 -expand -group PHY_FSM_SB_INTERFACE -color Magenta /UCIE_ctl_DUT2DUT_tb/cs_phy_sb_interface_RX_die_0
add wave -noupdate -height 40 -expand -group PHY_FSM_SB_INTERFACE /UCIE_ctl_DUT2DUT_tb/ns_phy_sb_interface_RX_die_0
add wave -noupdate -height 40 -expand -group PHY_FSM_SB_INTERFACE -color Magenta /UCIE_ctl_DUT2DUT_tb/cs_phy_sb_interface_TX_die_1
add wave -noupdate -height 40 -expand -group PHY_FSM_SB_INTERFACE /UCIE_ctl_DUT2DUT_tb/ns_phy_sb_interface_TX_die_1
add wave -noupdate -height 40 -expand -group {SB_FSM(die_0_TX die_1_RX)} /UCIE_ctl_DUT2DUT_tb/cs_SB_TX_die_0
add wave -noupdate -height 40 -expand -group {SB_FSM(die_0_TX die_1_RX)} /UCIE_ctl_DUT2DUT_tb/ns_SB_TX_die_0
add wave -noupdate -height 40 -expand -group {SB_FSM(die_0_TX die_1_RX)} /UCIE_ctl_DUT2DUT_tb/cs_SB_RX_die_1
add wave -noupdate -height 40 -expand -group {SB_FSM(die_0_TX die_1_RX)} /UCIE_ctl_DUT2DUT_tb/ns_SB_RX_die_1
add wave -noupdate -height 40 -expand -group {SB_FSM(die_0_RX die_1_TX)} /UCIE_ctl_DUT2DUT_tb/cs_SB_RX_die_0
add wave -noupdate -height 40 -expand -group {SB_FSM(die_0_RX die_1_TX)} /UCIE_ctl_DUT2DUT_tb/ns_SB_RX_die_0
add wave -noupdate -height 40 -expand -group {SB_FSM(die_0_RX die_1_TX)} /UCIE_ctl_DUT2DUT_tb/cs_SB_TX_die_1
add wave -noupdate -height 40 -expand -group {SB_FSM(die_0_RX die_1_TX)} /UCIE_ctl_DUT2DUT_tb/ns_SB_TX_die_1
add wave -noupdate -height 40 -expand -group PHY_FSM_DATA_TRANSFER /UCIE_ctl_DUT2DUT_tb/cs_phy_data_transfer_die_0
add wave -noupdate -height 40 -expand -group PHY_FSM_DATA_TRANSFER /UCIE_ctl_DUT2DUT_tb/ns_phy_data_transfer_die_0
add wave -noupdate -height 40 -expand -group PHY_FSM_DATA_TRANSFER /UCIE_ctl_DUT2DUT_tb/cs_phy_data_transfer_die_1
add wave -noupdate -height 40 -expand -group PHY_FSM_DATA_TRANSFER /UCIE_ctl_DUT2DUT_tb/ns_phy_data_transfer_die_1
add wave -noupdate -height 40 -expand -group {TX_MOD_die_0 RX_MOD_die_1} /UCIE_ctl_DUT2DUT_tb/cs_TX_MOD_die_0
add wave -noupdate -height 40 -expand -group {TX_MOD_die_0 RX_MOD_die_1} /UCIE_ctl_DUT2DUT_tb/ns_TX_MOD_die_0
add wave -noupdate -height 40 -expand -group {TX_MOD_die_0 RX_MOD_die_1} /UCIE_ctl_DUT2DUT_tb/cs_RX_MOD_die_1
add wave -noupdate -height 40 -expand -group {TX_MOD_die_0 RX_MOD_die_1} /UCIE_ctl_DUT2DUT_tb/ns_RX_MOD_die_1
add wave -noupdate -height 40 -expand -group {RX_MOD_die_0 TX_MOD_die_1} /UCIE_ctl_DUT2DUT_tb/cs_RX_MOD_die_0
add wave -noupdate -height 40 -expand -group {RX_MOD_die_0 TX_MOD_die_1} /UCIE_ctl_DUT2DUT_tb/ns_RX_MOD_die_0
add wave -noupdate -height 40 -expand -group {RX_MOD_die_0 TX_MOD_die_1} /UCIE_ctl_DUT2DUT_tb/cs_TX_MOD_die_1
add wave -noupdate -height 40 -expand -group {RX_MOD_die_0 TX_MOD_die_1} /UCIE_ctl_DUT2DUT_tb/ns_TX_MOD_die_1
add wave -noupdate -height 40 -group Parameters /UCIE_ctl_DUT2DUT_tb/NBYTES
add wave -noupdate -height 40 -group Parameters /UCIE_ctl_DUT2DUT_tb/NC
add wave -noupdate -height 40 -group Parameters /UCIE_ctl_DUT2DUT_tb/UCIE_ACTIVE
add wave -noupdate -height 40 -group Parameters /UCIE_ctl_DUT2DUT_tb/CLK_PERIOD
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/PHY/SB_interface_DUT/i_data_received_sb
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/PHY/SB_interface_DUT/o_rdi_pl_cfg_crd
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/PHY/SB_interface_DUT/o_rdi_pl_cfg_vld
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/PHY/SB_interface_DUT/o_rdi_pl_cfg
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/PHY/SB_interface_DUT/o_data_sent_sb
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/PHY/SB_interface_DUT/i_sb_data_valid
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/PHY/SB_interface_DUT/o_sb_data_valid
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/TX/i_w_data
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/TX/o_r_data
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/PHY/o_data_sent
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/PHY/Data_transfer_DUT/i_rdi_lp_data
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/TX/o_rdi_lp_valid
add wave -noupdate -expand /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/TX/fifo_tx/FIFO_Memory/FIFO_MEM
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/TX/fifo_tx/rempty
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/TX/fifo_tx/wfull
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/PHY/Data_transfer_DUT/i_data_received
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/PHY/Data_transfer_DUT/i_data_valid
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/PHY/o_rdi_pl_valid
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/PHY/o_rdi_pl_data
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/RX/BUF/i_rdi_pl_data
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/RX/BUF/i_rdi_pl_valid
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/RX/BUF/i_buffer_en
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/RX/BUF/o_fdi_data
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/RX/BUF/o_fdi_data_valid
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/RX/BUF/o_overflow_detected
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/RX/BUF/r_mem
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/RX/BUF/r_rd_ptr
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/RX/BUF/r_wr_ptr
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/RX/BUF/r_count
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/w_overflow_TX
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/w_overflow_RX
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/w_rdi_pl_state_sts
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/w_rdi_pl_inband_pres
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/w_rdi_pl_error
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/w_rdi_pl_cerror
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/w_rdi_pl_nferror
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/w_rdi_pl_trainerror
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/w_rdi_lp_state_req
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/w_rdi_lp_linkerror
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/PHY/Control_DUT/i_start_ucie_link_training
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/PHY/Control_DUT/r_nop_active_flag
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/PHY/Control_DUT/i_rdi_lp_state_req
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/PHY/Control_DUT/r_nop_active_flag
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/CSR/mem
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/CSR/o_Advcap
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/CSR/o_Advcap
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/CSR/i_P_Select
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/CSR/i_P_Enable
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_0/CSR/i_P_addr
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/w_rdi_lp_state_req
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/w_rdi_lp_linkerror
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/Start_UCIe_Link_Training_die_0
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/Start_UCIe_Link_Training_die_1
add wave -noupdate /UCIE_ctl_DUT2DUT_tb/DUT_2_DUT/Adapter_Die_1/PHY/phy_CSR_DUT/i_clear_start_training_bit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3155 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 425
configure wave -valuecolwidth 301
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {329 ns}
