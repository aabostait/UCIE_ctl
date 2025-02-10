module UCIE_ctl_TX #(
  parameter     UCIE_ACTIVE = 1  ,                           
  parameter     DATA_WIDTH_TX = 64 ,
  parameter     FIFO_DEPTH_TX  = 8                         
 )
 (
  input 			i_clk,
  input 			i_rst,
  input [3:0] i_fdi_pl_state_sts,
  input 			i_fdi_lp_valid,
  input 			i_fdi_lp_irdy,
  input			    i_rdi_pl_trdy,
  output		 	o_tx_overf_err,
  output 	 		o_fdi_pl_trdy,
  output 			o_rdi_lp_valid,
  output 			o_rdi_lp_irdy,

  input   [DATA_WIDTH_TX-1:0]     i_w_data,             // write data bus 
  output  [DATA_WIDTH_TX-1:0]     o_r_data             // read data bus
);

  wire  w_fifo_w_rst;
  wire  w_fifo_r_rst;
  wire  w_fifo_w_inc;
  wire  w_fifo_r_inc;
  wire  w_fifo_full ;
  wire  w_fifo_empty;

    FIFO_TOP #(
      .FIFO_DEPTH(FIFO_DEPTH_TX),
      .DATA_WIDTH(DATA_WIDTH_TX)
      )
      fifo_tx
     (
      .w_data(i_w_data),
      .winc(w_fifo_w_inc),
      .w_clk(i_clk),
      .wrst_n(w_fifo_w_rst),
      .wfull(w_fifo_full),
      .r_data(o_r_data),
      .rinc(w_fifo_r_inc),
      .rempty(w_fifo_empty),
      .r_clk(i_clk),
      .rrst_n(w_fifo_r_rst)
      );


  UCIE_ctl_TX_FSM # (
    .UCIE_ACTIVE (UCIE_ACTIVE)
  )
    fsm_tx (
      .clk                   (i_clk              ),
      .rst_n                 (i_rst              ),
      .i_fdi_pl_state_sts    (i_fdi_pl_state_sts ),
      .i_fdi_lp_valid        (i_fdi_lp_valid     ),
      .i_fdi_lp_irdy         (i_fdi_lp_irdy      ),
      .i_rdi_pl_trdy         (i_rdi_pl_trdy      ),
      .wrst_n                (w_fifo_w_rst       ),
      .rrst_n                (w_fifo_r_rst       ),
      .winc                  (w_fifo_w_inc       ),
      .rinc                  (w_fifo_r_inc       ),
      .wfull                 (w_fifo_full        ),
      .rempty                (w_fifo_empty       ),
      .o_tx_overf_err        (o_tx_overf_err     ),
      .o_fdi_pl_trdy         (o_fdi_pl_trdy      ),
      .o_rdi_lp_valid        (o_rdi_lp_valid     ),
      .o_rdi_lp_irdy         (o_rdi_lp_irdy      )
    );

endmodule
