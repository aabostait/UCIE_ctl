module FIFO_rptr (r_clk,rrst_n,rinc,rempty,r_addr,gray_rptr,gray_wptr);
	
	parameter POINTER_WIDTH=4;

	input r_clk,rrst_n;
	input rinc;
	input [POINTER_WIDTH-1:0]gray_wptr;

	output  [POINTER_WIDTH-2:0] r_addr;
	output  [POINTER_WIDTH-1:0] gray_rptr;
	output  rempty;

	reg [POINTER_WIDTH-1:0]rptr; 

	always @(posedge r_clk or negedge rrst_n) begin
		if(!rrst_n)
			rptr<=0;
		else begin
			if(!rempty && rinc)
				rptr<=rptr+1;
		end	

	end

	//here we want to convert rptr to gray_rptr

	binary_to_gray #(.POINTER_WIDTH( POINTER_WIDTH )) b2g(rptr,gray_rptr);
	//////////////////////////////////////////////////
	assign r_addr=rptr[POINTER_WIDTH-2:0];
	assign rempty=(gray_wptr==gray_rptr);

endmodule