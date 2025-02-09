module UCIE_ctl_CSR(i_clk, i_rst_n, i_A_Valid,
	i_P_Select, i_P_Enable, i_P_addr, i_A_addr, i_P_WDATA, i_P_WR,
	o_P_Ready, o_P_RDATA, o_Advcap, o_retrain, i_A_WDATA,
	o_phy_WR, o_phy_WDATA, o_phy_addr);
	parameter WIDTH = 8, DEPTH = 256;
	parameter UCIE_VENDOR_ID = 0;
	parameter UCIE_SPEC_VERSION = 0;
	parameter UCIE_DEFAULT_ADVCAP = 32'h11;

	localparam RETRAIN_STATE = 5'b01011;

	input i_clk, i_rst_n;
	input i_A_Valid; 
	input i_P_Select,i_P_Enable;
	input [7:0] i_P_addr, i_A_addr; 
	input [31:0] i_P_WDATA, i_A_WDATA;
	input i_P_WR; // 1 write , 0 read
	output reg [7:0] o_phy_addr; 
	output reg [31:0] o_phy_WDATA;
	output reg o_phy_WR; // 1 write , 0 read
	output reg o_P_Ready; 
	output reg [31:0] o_P_RDATA;
	output [31:0] o_Advcap;
	output o_retrain;

	wire [31:0] P_RO;
	wire [31:0] P_LOC;

	integer i,k;


	reg r_retrain_bit_clear_flag;

	reg [WIDTH-1:0]mem[DEPTH-1:0];


	reg [WIDTH-1:0]RO_Mask[DEPTH-1:0];
	always_comb begin
		//intializing memory with zeros
		for(k = 0; k < 255 ; k = k + 1)begin
			RO_Mask[k] = 0;
		end
		// bits masked by 1 is Read only
		//RO
		{RO_Mask['h0+3],RO_Mask['h0+2],RO_Mask['h0+1],RO_Mask['h0]}     = 'hFFFF_FFFF;
		{RO_Mask['h4+3],RO_Mask['h4+2],RO_Mask['h4+1],RO_Mask['h4]}     = 'hFFFF_FFFF;
		{RO_Mask['h14+3],RO_Mask['h14+2],RO_Mask['h14+1],RO_Mask['h14]} = 'h03C1_FFFF|'hFE00_0000; //[16:0][25:22]
		{RO_Mask['h24+3],RO_Mask['h24+2],RO_Mask['h24+1],RO_Mask['h24]} = 'hFFFF_FF20; //[5][31:8]

		//reserved RO
		{RO_Mask['h8+3],RO_Mask['h8+2],RO_Mask['h8+1],RO_Mask['h8]}     = 'hFFFF_FFFF; 
		{RO_Mask['hC+3],RO_Mask['hC+2],RO_Mask['hC+1],RO_Mask['hC]}     = 'hFFFF_FFFF; 
		{RO_Mask['h18+3],RO_Mask['h18+2],RO_Mask['h18+1],RO_Mask['h18]} = 'hFFFF_FFFF;
		{RO_Mask['h1C+3],RO_Mask['h1C+2],RO_Mask['h1C+1],RO_Mask['h1C]} = 'hFFFF_FFFF;
		//Reserved
		{RO_Mask['h10+3],RO_Mask['h10+2],RO_Mask['h10+1],RO_Mask['h10]} = 'hFFE0_03FC; //[9:2][31:21]
		//{RO_Mask['h14+3],RO_Mask['h14+2],RO_Mask['h14+1],RO_Mask['h14]} = 'hFE00_0000; //[31:26]
		{RO_Mask['h20+3],RO_Mask['h20+2],RO_Mask['h20+1],RO_Mask['h20]} = 'hFF80_0000; //[31:23]
		{RO_Mask['h28+3],RO_Mask['h28+2],RO_Mask['h28+1],RO_Mask['h28]} = 'hFFFF_FF20; //[5][31:8]

		{RO_Mask['h2C+3],RO_Mask['h2C+2],RO_Mask['h2C+1],RO_Mask['h2C]} = 'hFFFF_FFFC; //[31:2]
		{RO_Mask['h30+3],RO_Mask['h30+2],RO_Mask['h30+1],RO_Mask['h30]} = 'hFFFF_FFFC; //[31:2]
		{RO_Mask['h34+3],RO_Mask['h34+2],RO_Mask['h34+1],RO_Mask['h34]} = 'hFFFF_FFC0; //[31:6]
		{RO_Mask['h38+3],RO_Mask['h38+2],RO_Mask['h38+1],RO_Mask['h38]} = 'hFFFF_FFC0; //[31:6]

		// not specified (empty)
		//['hFF:'h3C]:///////////////////
	end
	
	always @(posedge i_clk, negedge i_rst_n) begin : OUTPUT_of_CSR
		if(~i_rst_n) begin
			o_P_Ready <= 0;
			o_P_RDATA <= 0;
			r_retrain_bit_clear_flag <= 0;

			for(i = 0; i < 255 ; i = i + 1) begin
				mem[i] <= 0;
			end

			// RESET values other than ZEROs	
			{mem['h0+3],mem['h0+2],mem['h0+1],mem['h0]}	     <= UCIE_VENDOR_ID; // Vendor_id ... Vendor ID RO
			{mem['h4+3],mem['h4+2],mem['h4+1],mem['h4]}	     <= UCIE_SPEC_VERSION; // UCIe_Standard_Version ... UCIe_Standard_Version RO
			{mem['h20+3],mem['h20+2],mem['h20+1],mem['h20]}	 <= UCIE_DEFAULT_ADVCAP; // AdvCap ...
			{mem['h28+3],mem['h28+2],mem['h28+1],mem['h28]}	 <= 'hFFFF_FFFF; // Internal Error ... Mask Code 
			{mem['h30+3],mem['h30+2],mem['h30+1],mem['h30]}	 <= 'hFFFF_FFFF; // Adapter Error ... Mask Code 
			{mem['h38+3],mem['h38+2],mem['h38+1],mem['h38]}	 <= 'hFFFF_FFFF; // Uncorr Error ... Status Mask
		end else begin

			o_phy_WR <= 0;
			o_phy_addr <= 'h0;
			o_phy_WDATA <= 0;
			
			// Protocol read and write
			if(i_P_Select) begin
				if(~i_P_Enable) begin
					if(i_P_WR)begin

						{mem[i_P_addr+3],mem[i_P_addr+2],mem[i_P_addr+1],mem[i_P_addr]} <= ( (i_P_WDATA&(~P_RO)) | (P_LOC&P_RO) );

						o_P_Ready <= 0;

						if (i_P_addr == 'h10) begin
							o_phy_WR <= 1;
							o_phy_addr <= 'h10;
							o_phy_WDATA <= i_P_WDATA;
						end
					
					end
					else begin

						if (i_P_addr=='h28 || i_P_addr=='h38 || i_P_addr=='h30) begin
							o_P_RDATA <= {mem[i_P_addr-4]&mem[i_P_addr] , mem[i_P_addr-3]&mem[i_P_addr+1] , mem[i_P_addr-2]&mem[i_P_addr+2] , mem[i_P_addr-1]&mem[i_P_addr+3]};
						end else begin
							o_P_RDATA <= P_LOC;
						end	

						o_P_Ready <= 1;

					end

				end
				else begin
					o_P_Ready <= 0;
				end
			end
			
			// Write Adapter
			if (r_retrain_bit_clear_flag && !(i_P_Select && !i_P_Enable && i_P_WR)) begin
				{mem[i_A_addr+3],mem[i_A_addr+2],mem[i_A_addr+1],mem[i_A_addr]} <= {i_A_WDATA[31:12],i_A_WDATA[10:0]&mem['h11][3],i_A_WDATA[10:0]};
				r_retrain_bit_clear_flag <= 0;
			end

			if(i_A_Valid) begin
				case(i_A_addr)
					'h10: begin
						if (!(i_P_Select && !i_P_Enable && i_P_WR)) begin
							{mem[i_A_addr+3],mem[i_A_addr+2],mem[i_A_addr+1],mem[i_A_addr]} <= {i_A_WDATA[31:12],i_A_WDATA[10:0]&mem['h11][3],i_A_WDATA[10:0]};
							r_retrain_bit_clear_flag <= 0;
						end
						else
							r_retrain_bit_clear_flag <= 1;
					end
					'h14: {mem[i_A_addr+3],mem[i_A_addr+2],mem[i_A_addr+1],mem[i_A_addr]} <= {i_A_WDATA[31:22],{i_A_WDATA[21:19]|mem['h16][5:3]},i_A_WDATA[18],i_A_WDATA[17]|mem['h16][1],i_A_WDATA[16:0]};
					'h24: {mem[i_A_addr+3],mem[i_A_addr+2],mem[i_A_addr+1],mem[i_A_addr]} <= {i_A_WDATA[31:8],{i_A_WDATA[7:6]|mem['h24][7:6]},i_A_WDATA[5],{i_A_WDATA[4:0]|mem['h24][4:0]}};
					'h2C: {mem[i_A_addr+3],mem[i_A_addr+2],mem[i_A_addr+1],mem[i_A_addr]} <= {i_A_WDATA[31:2],{i_A_WDATA[1:0]|mem['h2C][1:0]}};
					'h34: {mem[i_A_addr+3],mem[i_A_addr+2],mem[i_A_addr+1],mem[i_A_addr]} <= {i_A_WDATA[31:6],{mem['h34][5:0]|i_A_WDATA[5:0]}};
					default:  {mem[i_A_addr+3],mem[i_A_addr+2],mem[i_A_addr+1],mem[i_A_addr]} <= i_A_WDATA; 
				endcase
			end

		end
	end //always

	assign P_RO = {RO_Mask[i_P_addr+3],RO_Mask[i_P_addr+2],RO_Mask[i_P_addr+1],RO_Mask[i_P_addr]};
	assign P_LOC = {mem[i_P_addr+3],mem[i_P_addr+2],mem[i_P_addr+1],mem[i_P_addr]};

	assign o_retrain = mem['h11][3];
	assign o_Advcap = {mem['h20+3],mem['h20+2],mem['h20+1],mem['h20]};

endmodule 

