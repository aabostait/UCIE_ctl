module Pulse_Gen (clk,rst,in,out);
	
	parameter WIDTH=8;

	input clk,rst;
	input [WIDTH-1:0] in;
	output [WIDTH-1:0]out;

	reg [WIDTH-1:0] q;

	always @(posedge clk or negedge rst) begin
		if(!rst) begin
			q<=0;
		end
		else begin
			q<=in;
		end
	end

	assign out=(~q)&in;

endmodule