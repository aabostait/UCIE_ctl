module Timer (clk,rst,en,T,Flag);

	input clk,en;
	input rst;
	input T;
	output reg Flag;

	reg [5:0] counter; //max 64
	reg Ignore_T,T_temp; // to capture First T only

	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			Flag <= 0;
			counter <= 0;
			Ignore_T <= 0;
			T_temp <= 0;
		end 
		else begin
			if(~en) begin
				Flag <= 0; //not mandatory 
				counter <= 0;
				Ignore_T <= 0;
				T_temp <= 0;
			end
			else begin
				if(Ignore_T == 0)
					T_temp <= T;

				if (T_temp==0 && counter==19) begin
					Flag<= 1;
					counter <= 0;
					Ignore_T <= 0;
				end
				else if (T_temp==1 && counter==39) begin
					Flag <= 1;
				    counter <= 0;
				    Ignore_T <= 0;
				end
				else begin
					Flag <= 0;
					Ignore_T <= 1;
					counter <= counter+1;
				end
			end
		end		
	end
endmodule 

