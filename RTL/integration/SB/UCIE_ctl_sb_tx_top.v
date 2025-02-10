// ************************* Description ************************************ //
//  This module is implemented to:-                                           //
//  -- Connect: FSM, pakcet builder and packet sender blocks in top sb_tx mod //
// ************************************************************************** //

module UCIE_ctl_sb_tx_top # (parameter NC = 16)(
    input   wire            i_clk,
    input   wire            i_rst,
    // CTL mod interface signals
    input             i_valid_lp_sb,
    input  [4:0]      i_rdi_lp_sb_decode,
    input  [31:0]     i_rdi_lp_adv_cap_value,
    output            o_pl_sb_busy,
    // RDI interface signals
    input             i_rdi_pl_cfg_crd,
    output            o_rdi_lp_cfg_vld,
    output [NC-1:0]   o_rdi_lp_cfg
);
    wire            w_enable_analyser;
    wire [1:0]      w_buf_en         ;
    wire [1:0]      w_phase_sel      ;
    wire            w_ignore_data2   ;
    wire [31:0]     w_phase_sent     ;

    wire       	    w_done_shift     ;
    wire   [1:0]    w_shift_load     ;
    
    UCIE_ctl_packet_builder
      packet_builder_inst (
        .i_clk               (i_clk                 ),
        .i_rst               (i_rst                 ),
        .i_msg_data          (i_rdi_lp_adv_cap_value),
        .i_rdi_lp_sb_decode  (i_rdi_lp_sb_decode    ),
        .i_enable_analyser   (w_enable_analyser     ),
        .i_buf_en            (w_buf_en              ),
        .i_phase_sel         (w_phase_sel           ),
        .o_ignore_data2      (w_ignore_data2        ),
        .o_phase_sent        (w_phase_sent          )
      );

    UCIE_ctl_sb_tx_fsm #(.NC (NC))
      fsm_inst (
        .i_clk                (i_clk                ),
        .i_rst                (i_rst                ),
        .i_valid_lp_sb        (i_valid_lp_sb        ),          
        .i_done_shift         (w_done_shift         ),
        .i_ignore_data2       (w_ignore_data2       ),
        .i_rdi_pl_cfg_cred    (i_rdi_pl_cfg_crd    ),
        .o_pl_sb_busy         (o_pl_sb_busy         ),
        .o_buf_en             (w_buf_en             ),
        .o_shift_load         (w_shift_load         ),
        .o_phase_sel          (w_phase_sel          ),
        .o_en_analyser        (w_enable_analyser    ),
        .o_lp_cfg_vld         (o_rdi_lp_cfg_vld     )
      );

    UCIE_ctl_sb_tx_packet_sender #(.NC (NC))
      packet_sender_inst (
        .i_clk                (i_clk                ),   
        .i_rst                (i_rst                ),
        .i_shift_load         (w_shift_load         ),
        .i_phase_sent         (w_phase_sent         ),
        .o_rdi_lp_cfg         (o_rdi_lp_cfg         ),
        .o_done_shift         (w_done_shift         )        
      );




endmodule