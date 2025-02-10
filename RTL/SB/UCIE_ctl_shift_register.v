`include "./defines.svh"
module UCIE_ctl_shift_register #(
  parameter N = `NC  // Width of the input data (can vary)
) (
  input  wire           i_clk,      // Clock signal
  input  wire           i_reset,    // Reset signal (active high)
  input  wire           i_enable,   // Enable signal (active high)
  input  wire [N-1:0]   i_data_in,  // Parameterized input data
  output reg  [31:0]    o_reg_out   // Fixed 32-bit shift register output
);

  always @(posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
      // Reset the register to 0
      o_reg_out <= 32'b0;
    end else if (i_enable) begin
      // Shift and load new data
      o_reg_out <= {o_reg_out[N-1:0], i_data_in};
    end
  end

endmodule
