`include "./defines.svh"
module UCIE_ctl_phy_CSR(i_clk, i_rst_n, i_clear_start_training_bit,
	i_WR, i_WDATA, i_addr, o_start_ucie_link_training);
	parameter WIDTH = `CSR_WIDTH, DEPTH = `CSR_DEPTH;

	input i_clk, i_rst_n;
	input i_clear_start_training_bit;
	input i_WR; // 1 write , 0 read
	input [7:0] i_addr; 
	input [31:0] i_WDATA;
	output o_start_ucie_link_training;

	integer i;

	reg [WIDTH-1:0]mem[DEPTH-1:0];
	
	always @(posedge i_clk, negedge i_rst_n) begin
		if(~i_rst_n) begin

			for(i = 0; i < DEPTH; i = i + 1) begin
				mem[i] <= 0;
			end

		end else begin

			if(i_WR) begin

				{mem[i_addr+3],mem[i_addr+2],mem[i_addr+1],mem[i_addr]} <= i_WDATA;

			end
			else if (i_clear_start_training_bit) begin
				
				mem['h11] <= mem['h11] & ~{5'b0, 1'b1, 2'b0};

			end

		end
	end

	assign o_start_ucie_link_training = mem ['h11][2];

endmodule 

