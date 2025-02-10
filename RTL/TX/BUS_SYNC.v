module BUS_SYNC (clk,rst,IN,OUT);
	
	parameter N=2;
	parameter POINTER_WIDTH=4;

	input clk,rst;
	input [POINTER_WIDTH-1:0] IN;
	
	output [POINTER_WIDTH-1:0] OUT;

	generate
		genvar i;
		for (i = 0; i < POINTER_WIDTH; i = i + 1)
		begin:BIT_SYNC_INST
		BIT_SYNC #(.N(N)) BIT_SYNC_i (clk,rst,IN[i],OUT[i]);
		end
	endgenerate
	
endmodule