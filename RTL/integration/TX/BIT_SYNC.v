module BIT_SYNC (clk,rst,IN,OUT);
	
	parameter N=2;

	input clk,rst;
	input IN;
	
	output OUT;

	reg [N-1:0] stage;

	always @(posedge clk or negedge rst) begin
		if(!rst) begin
			stage<=0;
		end
		else begin
			stage<={stage[N-2:0],IN};
		end	
	end

	assign OUT=stage[N-1];
	
endmodule