module binary_to_gray (binary,gray);
	
	parameter POINTER_WIDTH=4;

	input [POINTER_WIDTH-1:0] binary;
	output reg [POINTER_WIDTH-1:0] gray;

	integer i;

	always @(*) begin
		gray[POINTER_WIDTH-1] = binary[POINTER_WIDTH-1];

		for (i=POINTER_WIDTH-2;i>=0;i=i-1) begin
			gray[i]=binary[i+1]^binary[i];
		end
		
	end
endmodule