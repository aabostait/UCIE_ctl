onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /UCIE_ctl_CNTL_FSM_tb/i_clk
add wave -noupdate /UCIE_ctl_CNTL_FSM_tb/i_rst_n
add wave -noupdate -height 40 -expand -group Inputs -color Magenta /UCIE_ctl_CNTL_FSM_tb/i_rdi_pl_state_sts
add wave -noupdate -height 40 -expand -group Inputs -color Magenta /UCIE_ctl_CNTL_FSM_tb/i_fdi_lp_state_req
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_rdi_pl_sb_decode
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_valid_pl_sb
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_fdi_lp_rx_active_sts
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_fdi_lp_linkerror
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_fdi_pl_error
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_rdi_pl_inband_pres
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_rdi_pl_speedmode
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_rdi_pl_lnk_cfg
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_rdi_pl_phyinrecenter
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_rdi_pl_adv_cap_val
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_CSR_UCIe_Link_Control_Retrain
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_CSR_ADVCAP
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_overflow_TX
add wave -noupdate -height 40 -expand -group Inputs /UCIE_ctl_CNTL_FSM_tb/i_overflow_RX
add wave -noupdate -height 40 -expand -group Outputs -color Magenta /UCIE_ctl_CNTL_FSM_tb/o_fdi_pl_state_sts
add wave -noupdate -height 40 -expand -group Outputs -color Magenta /UCIE_ctl_CNTL_FSM_tb/o_rdi_lp_state_req
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_rdi_lp_sb_decode
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_valid_lp_sb
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_fdi_pl_inband_pres
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_fdi_pl_rx_active_req
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_pl_phyinrecenter_i
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_pl_trainerror_i
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_rdi_lp_linkerror
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_fdi_pl_protocol_vld
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_fdi_pl_protocol
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_fdi_pl_protocol_flitfmt
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_fdi_pl_speedmode
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_fdi_pl_lnk_cfg
add wave -noupdate -height 40 -expand -group Outputs /UCIE_ctl_CNTL_FSM_tb/o_rdi_lp_adv_cap_val
add wave -noupdate -color Magenta /UCIE_ctl_CNTL_FSM_tb/cs
add wave -noupdate /UCIE_ctl_CNTL_FSM_tb/ns
add wave -noupdate -expand -group etc /UCIE_ctl_CNTL_FSM_tb/i_sb_busy_flag
add wave -noupdate -expand -group etc /UCIE_ctl_CNTL_FSM_tb/IS_NOP_SENT_temp
add wave -noupdate -expand -group etc /UCIE_ctl_CNTL_FSM_tb/IS_NOP_SENT
add wave -noupdate -expand -group etc /UCIE_ctl_CNTL_FSM_tb/error_count
add wave -noupdate /UCIE_ctl_CNTL_FSM_tb/DUT/sb_busy_flag_edge_detected
add wave -noupdate /UCIE_ctl_CNTL_FSM_tb/DUT/timer/Flag
add wave -noupdate /UCIE_ctl_CNTL_FSM_tb/DUT/timer/counter
add wave -noupdate /UCIE_ctl_CNTL_FSM_tb/DUT/transitioned_from_NOP_flag
add wave -noupdate /UCIE_ctl_CNTL_FSM_tb/DUT/RX_done_flag
add wave -noupdate /UCIE_ctl_CNTL_FSM_tb/DUT/TX_done_flag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3414 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 260
configure wave -valuecolwidth 203
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
WaveRestoreZoom {3256 ns} {3502 ns}
