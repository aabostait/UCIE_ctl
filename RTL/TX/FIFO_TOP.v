module FIFO_TOP (w_data,winc,w_clk,wrst_n,wfull,r_data,rinc,rempty,r_clk,rrst_n);

	parameter FIFO_DEPTH=8;
	parameter DATA_WIDTH=8;
	parameter N=2;//for synchronizer

	localparam POINTER_WIDTH= $clog2(FIFO_DEPTH)+1;

	input w_clk,r_clk;
	input wrst_n,rrst_n;

	input winc,rinc;
	input [DATA_WIDTH-1:0] w_data;

	output  [DATA_WIDTH-1:0] r_data;
	output  wfull,rempty;

	wire [$clog2(FIFO_DEPTH)-1:0] w_addr;
	wire [$clog2(FIFO_DEPTH)-1:0] r_addr;
	wire [POINTER_WIDTH-1:0] gray_rptr;
	wire [POINTER_WIDTH-1:0] gray_wptr;
	wire [POINTER_WIDTH-1:0] gray_rptr_afterSYNC;
	wire [POINTER_WIDTH-1:0] gray_wptr_afterSYNC;
	wire wclken;

	 FIFO_Memory #(.FIFO_DEPTH(FIFO_DEPTH),.DATA_WIDTH(DATA_WIDTH)) FIFO_Memory(
	 .w_clk(w_clk),
	 .rst(wrst_n),
	 .w_data(w_data),
	 .w_en(wclken),
	 .w_addr(w_addr),
	 .r_addr(r_addr),
	 .r_data(r_data)
	 );

	 FIFO_rptr #(.POINTER_WIDTH( POINTER_WIDTH ))  FIFO_rptr(
	 .r_clk(r_clk),
	 .rrst_n(rrst_n),
	 .rinc(rinc),
	 .rempty(rempty),
	 .r_addr(r_addr),
	 .gray_rptr(gray_rptr),
	 .gray_wptr(gray_wptr_afterSYNC)
	 );

	 FIFO_wptr #(.POINTER_WIDTH( POINTER_WIDTH )) FIFO_wptr(
	 .w_clk(w_clk),
	 .wrst_n(wrst_n),
	 .winc(winc),
	 .wfull(wfull),
	 .waddr(w_addr),
	 .gray_wptr(gray_wptr),
	 .gray_rptr(gray_rptr_afterSYNC)
	 );

	 BUS_SYNC #(.N(N),.POINTER_WIDTH( POINTER_WIDTH )) BUS_SYNC_w2r(
	 .clk(r_clk),
	 .rst(rrst_n),
	 .IN(gray_wptr),
	 .OUT(gray_wptr_afterSYNC)
	 ); // from write to read

	 BUS_SYNC #(.N(N),.POINTER_WIDTH( POINTER_WIDTH )) BUS_SYNC_r2w(
	 .clk(w_clk),
	 .rst(wrst_n),
	 .IN(gray_rptr),
	 .OUT(gray_rptr_afterSYNC)
	 ); // from read to write

	 assign wclken=(winc && !wfull);

	
endmodule