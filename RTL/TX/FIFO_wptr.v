module FIFO_wptr (w_clk,wrst_n,winc,wfull,waddr,gray_wptr,gray_rptr);
	
	parameter POINTER_WIDTH=4;

	input w_clk,wrst_n;
	input winc;
	input [POINTER_WIDTH-1:0]gray_rptr;

	output  [POINTER_WIDTH-2:0] waddr;
	output  [POINTER_WIDTH-1:0] gray_wptr;
	output  wfull;

	reg [POINTER_WIDTH-1:0]wptr; 

	always @(posedge w_clk or negedge wrst_n) begin
		if(!wrst_n)
			wptr<=0;
		else begin
			if(!wfull && winc)
				wptr<=wptr+1;
		end	

	end

	//here we want to convert rptr to gray_rptr

	binary_to_gray #(.POINTER_WIDTH( POINTER_WIDTH )) b2g(wptr,gray_wptr);
	//////////////////////////////////////////////////
	assign waddr=wptr[POINTER_WIDTH-2:0];
	assign wfull=  (gray_wptr[POINTER_WIDTH-1] != gray_rptr[POINTER_WIDTH-1] 
				&& gray_wptr[POINTER_WIDTH-2] != gray_rptr[POINTER_WIDTH-2] 
				&& gray_wptr[POINTER_WIDTH-3:0] == gray_rptr[POINTER_WIDTH-3:0] );

endmodule	