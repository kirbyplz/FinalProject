module snn_core(rst_n,clk, start, q_input, addr_input_unit, done, digit);
	input logic rst_n, clk, start, q_input;
	output logic [3:0] digit;
	output logic done;
	output logic [9:0] addr_input_unit;
	logic [7:0] mac_a_mux, mac_b_mux;
	
	
	assign mac_a_mux =
	
	module mac(.rst_n(rst_n),.clk(clk),.a(mac_a_mux),.b(mac_b_mux),.clr_n(mac_clr),.acc(mac_output);
	module controlfsm;
	module rom_act_func_lut;
	module ram_hidden_unit(.clk(clk),.addr(addr_input_unit),.data(hiddenweight),.we(writeenable),.q(hiddenunit));
	module ram_output_unit(.clk(clk),.addr(addr_input_unit),.data(outputweight),.we(writeenable),.q(outputunit));
	module rom_hidden_weight rom(.addr(addr_input_unit), .clk(clk), .q(hiddenweight));
	module rom_output_weight rom(.addr(addr_input_unit), .clk(clk), .q(outputweight));
endmodule
