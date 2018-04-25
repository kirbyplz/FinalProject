module mac(rst_n,clk,a,b,clr_n,acc);
	input logic [7:0] a,b;
	input logic clr_n;
	output logic [15:0] acc;
	input logic clk;
	input logic rst_n;
	logic [15:0] mult;
	logic [15:0] add;
	
	assign mult = {{8{a[7]}},a} * {{8{b[7]}},b};
	assign add = acc + mult;
		
	always@(posedge clk, negedge rst_n)
	begin
		if (rst_n == 0)
			acc <= 16'b0;
		else
			acc <= (clr_n) ? add[15:0] : 0;
	end

endmodule
