
module TB_UCIE_ctl_CSR ();
	parameter WIDTH = 8, DEPTH = 256;
	parameter UCIE_VENDOR_ID = 0;
	parameter UCIE_SPEC_VERSION = 0;
	parameter UCIE_DEFAULT_ADVCAP = 32'h11;

	reg i_clk, i_rst_n;
	reg i_A_Valid; 
	reg i_P_Select,i_P_Enable;
	reg [7:0] i_P_addr, i_A_addr; 
	reg [31:0] i_P_WDATA, i_A_WDATA;
	reg i_P_WR; // 1 write , 0 read
	wire o_P_Ready; 
	wire [31:0] o_P_RDATA;
	wire [31:0] o_Advcap;
	wire o_retrain;

	UCIE_ctl_CSR DUT (i_clk, i_rst_n, i_A_Valid, 
	i_P_Select, i_P_Enable, i_P_addr, i_A_addr, i_P_WDATA, i_P_WR,
	o_P_Ready, o_P_RDATA, o_Advcap, o_retrain, i_A_WDATA);

	task Reset();
		i_rst_n = 0;
		i_P_WR = 0;
		i_A_Valid = 0;
		i_P_Select = 0;
		i_P_Enable = 0;
		@(negedge i_clk);
		i_rst_n = 1;
	endtask 

	task protocol_Write (input logic [7:0] addr = 'h10 , [31:0] Data = 32'hFFFF_FFFF);
		i_P_Select = 1;
		i_P_WR = 1;
		i_P_addr = addr;
		i_P_WDATA = Data;
		@(negedge i_clk);
		i_P_Enable = 1;
		@(negedge i_clk);
		i_P_Enable = 0;
	endtask

	task protocol_Read(input logic [7:0] addr = 'h10);
		i_P_Select = 1;
		i_P_WR = 0;
		i_P_addr = addr;
		@(negedge i_clk);
		i_P_Enable = 1;
		@(negedge i_clk);
		i_P_Enable = 0;
	endtask

	task protocol_Write_Read(input logic [7:0] addr = 'h10 , [31:0] Data = 32'hFFFF_FFFF);
		protocol_Write(addr,Data);
		protocol_Read(addr);
	endtask

	task Adapter_Write(input logic [7:0] addr = 'h14 , [31:0] Data = 32'hAD00_00AD);
		i_A_Valid = 1;
		i_A_addr = addr;
		i_A_WDATA = Data;
		@(negedge i_clk);
	endtask

	// simultaneously
	task Protocol_adapter_same_time(input logic [7:0] P_addr = 'h10, A_addr = 'h10,
																	[31:0] P_Data = 32'hFFFF_FFFF, A_Data = 32'hFFFF_FFFF);
		fork 
			begin
				protocol_Write_Read(P_addr, P_Data);
			end
			begin
				Adapter_Write(A_addr, A_Data);
			end
		join
	endtask

	initial begin
		i_clk = 0;
		forever begin
			#1 i_clk = ~i_clk;
		end
	end

	initial begin
		Reset();
		// protocol Write
		protocol_Write('h10,32'hFFFF_FFFF);
		// protocol Read
		protocol_Read('h10);
		if(o_P_RDATA != (32'hFFFF_FFFF & ~'hFFE0_03FC) )
			$display("there is error in RO_mask at time = %t",$time);
		else
			$display("there is no error in RO_mask");
		

		protocol_Write_Read('h10,32'hFFFF_F000);

		// adapter write
		Adapter_Write('h14,32'hAD00_00AD);
		Adapter_Write('h24,32'hAD00_00AD);
		Adapter_Write('h2C,32'hAD00_00AD);
		Adapter_Write('h34,32'hAD00_00AD);

		//Adapter_Write_Protcol_Read_errors
		protocol_Write('h28,32'h0000_00FF);
		Adapter_Write('h24,32'hFFFF_FFFF);
		protocol_Read('h28);
		$display(" o_P_RDATA = %h ", o_P_RDATA);

		// check reset values masks
		// protocol Read
		protocol_Read('h20);
		if(o_P_RDATA != UCIE_DEFAULT_ADVCAP )
			$display("there is error in Reset mask");
		else
			$display("there is no error in Reset mask");
		

		// adapter first time only write, then Read-only
		Reset();
		Adapter_Write('h34,32'hAD00_00AD);
		protocol_Read('h34);
		$display(" o_P_RDATA = %h ", o_P_RDATA);
		Adapter_Write('h34,32'h0000_0000);
		protocol_Read('h34);
		$display(" o_P_RDATA = %h ", o_P_RDATA);


		// adapter and protocol working at the same time
		Protocol_adapter_same_time('h20,'h14, 32'hFF00_00FF, 32'hAD00_00AD);

		// random
		repeat(5) begin
			Protocol_adapter_same_time($random , $random, $random, $random);
		end

    $stop;
	end

endmodule
