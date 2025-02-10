module FIFO_Memory (w_clk,rst,w_data,w_en,w_addr,r_addr,r_data);
	
	parameter FIFO_DEPTH=8;
	parameter DATA_WIDTH=8;

	input [DATA_WIDTH-1:0] w_data;
	input w_en;
	input w_clk,rst;
	input [$clog2(FIFO_DEPTH)-1:0] r_addr;
	input [$clog2(FIFO_DEPTH)-1:0] w_addr;
	output  [DATA_WIDTH-1:0] r_data;

	integer i;
	reg [DATA_WIDTH-1:0] FIFO_MEM [FIFO_DEPTH-1:0];

	always @(posedge w_clk or negedge rst) begin
		if(!rst) begin
			for(i=0;i<FIFO_DEPTH;i=i+1)
				FIFO_MEM[i]<=0;
		end
		else begin
			if(w_en)
				FIFO_MEM[w_addr]<=w_data;
		end
			
	end

	assign r_data=FIFO_MEM[r_addr];


endmodule