module UCIE_ctl_counter #(
  parameter N = 16 // Default value of N
) (
  input  wire        i_clk,    // Clock signal
  input  wire        i_reset,  // Reset signal (active high)
  input  wire        i_enable, // Enable signal (active high)
  output reg  [2:0]  o_count,  // Counter output
  output reg         o_done    // Indicates when the counter reaches 32/N
);

  localparam MAX_COUNT = 32 / N; // Maximum count value

  // Counter logic
  always @(posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
      o_count <= 0; // Reset the counter
    end else if (i_enable) begin
      if (o_count == MAX_COUNT - 1) begin
        o_count <= 0; // Reset counter when max is reached
      end else begin
        o_count <= o_count + 1; // Increment counter
      end
    end
  end

  // Done signal logic
  always @(*) begin
    if (o_count == 0) begin
      o_done = 1;
    end else begin
      o_done = 0;
    end
  end

endmodule
