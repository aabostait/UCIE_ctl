module UCIE_ctl_TX #(
  parameter     UCIE_ACTIVE = 1  ,                           
  parameter     FIFO_D_SIZE = 64 ,
  parameter     FIFO_DEPTH  = 8  ,                       
  parameter     FIFO_P_SIZE = 3  
) (
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

  input   [FIFO_D_SIZE-1:0]     i_w_data,             // write data bus 
  output  [FIFO_D_SIZE-1:0]     o_r_data             // read data bus
);

  wire  w_fifo_w_rst;
  wire  w_fifo_r_rst;
  wire  w_fifo_w_inc;
  wire  w_fifo_r_inc;
  wire  w_fifo_full ;
  wire  w_fifo_empty;

  async_fifo #(
    .DSIZE (FIFO_D_SIZE),
    .ASIZE (FIFO_P_SIZE)
  )  
    fifo_tx(
      .wclk  (i_clk       ),
      .rclk  (i_clk       ),
      .wrst_n (w_fifo_w_rst),
      .rrst_n (w_fifo_r_rst),
      .winc  (w_fifo_w_inc),
      .rinc  (w_fifo_r_inc),
      .wfull   (w_fifo_full ),
      .rempty  (w_fifo_empty),
      .wdata (i_w_data    ),
      .rdata (o_r_data    )
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
