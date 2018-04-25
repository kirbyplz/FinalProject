module snn_core(rst_n,clk, start, q_input, addr_input_unit, done, digit);
	input logic rst_n, clk, start, q_input;
	output logic [3:0] digit;
	output logic done;
	output logic [9:0] addr_input_unit;
	logic [7:0] mac_a_mux, mac_b_mux;
	logic [8:0] hidden_count;
	logic [6:0] output_count;
	logic [8:0] hidden_nxt_count;
	logic [6:0] output_count;
	logic hidden_has_input, output_has_input;
	logic weight_read;
	logic hidden_output; //hidden = 0, output = 1
	logic input_out;
	logic [7:0] q_input_ext;
	logic [6:0] lut_output;
	logic hiddenwe, outputwe;
    logic [10:0] lut_address;
	
	assign addr_input_unit = (input_out) ? hidden_count : output_count;
	assign q_input_ext =  (q_input) ? 8'b00000000 : 8'b01111111;
	
	assign mac_a_mux = (input_out) ? q_input : hiddenunit;
	assign mac_b_mux = (input_out) ? hiddenweight : outputweight;
	
	assign hiddenwe = (input_out) ? 1'b1 : 1'b0;
	assign outputwe = (input_out) ? 1'b0 : 1'b1;
	
	assign lut_address = (mac_output[25] == 0 && |mac_output[24:17]) ? 11'b01111111111 : 
							(mac_output[25] == 1 && ~&mac_output[24:17]) ? 11'b10000000000 : 
								mac_output[17:7];
	

	module macimpl mac(.rst_n(rst_n),.clk(clk),.a(mac_a_mux),.b(mac_b_mux),.clr_n(mac_clr),.acc(mac_output);
	
	module rom_act_func_lut rom(.addr(mac_output), .clk(clk), .q(lut_output));
	module rom_hidden_weight rom(.addr(addr_input_unit), .clk(clk), .q(hiddenweight));
	module rom_output_weight rom(.addr(addr_input_unit), .clk(clk), .q(outputweight));
	
	module ram_hidden_unit(.clk(clk),.addr(addr_input_unit),.data(lut_output),.we(hiddenwe),.q(hiddenunit));
	module ram_output_unit(.clk(clk),.addr(addr_input_unit),.data(lut_output),.we(outputwe),.q(outputunit));
	
	
	module controlfsm;
	
	// States
	typedef enum reg[3:0] { IDLE, HIDDEN_READ, HIDDEN_INPUT, HIDDEN_CALC, HIDDEN_WRITE, OUTPUT_READ,
		OUTPUT_INPUT, OUTPUT_CALC, OUTPUT_WRITE, DONE } state_t;
	state_t state, nxt_state;
	
	// Sequential control of states
	always_ff@(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
		end

	// Combinational control of states and outputs
	always_comb begin
		hidden_count = 1'b0;
		output_count = 1'b0;
		hidden_has_input = 1'b0;
		output_has_input = 1'b0;
		weight_read = 1'b0;
		nxt_state = IDLE;
		input_out = 1'b0;
		mac_clr = 1'b0;
	  // State case statement
	  case(state)
		// Stays in IDLE unitl start bit
		IDLE: begin
		  if(start)
			nxt_state = HIDDEN_READ;
			addr_input_unit = hidden_count;
		  else begin
			nxt_state = IDLE;
		  end
		end
		// Stays in read one extra cycle to read weight
		HIDDEN_READ: begin
		   if (weight_read) begin
			 nxt_state = HIDDEN_INPUT;
			 mac_clr = 1'b1;
		   end
		   else begin
			 nxt_state = HIDDEN_READ;
			 weight_read = 1'b1;
			 //read weight logic
		   end
		end
		HIDDEN_INPUT: begin
		  nxt_state = HIDDEN_CALC;
		  //Pass to calc
		end
		HIDDEN_CALC: begin
			nxt_state = HIDDEN_WRITE;
			hidden_nxt_count = hidden_count + 1'b1;
			//Do calculation
		end
		HIDDEN_WRITE: begin
		  nxt_state = HIDDEN_READ;
		  hidden_count = hidden_nxt_count;
		  if(hidden_count == 10'b1100001111) begin //783
			nxt_state = OUTPUT_READ;
			input_out = 1'b1;
		  end
		end
		OUTPUT_READ: begin
		   if (weight_read) begin
			 nxt_state = OUTPUT_INPUT;
			 input_out = 1'b1;
		   end
		   else begin
			 nxt_state = OUTPUT_READ;
			 weight_read = 1'b1;
			 input_out = 1'b1;
			 //read weight logic
		   end
		end
		OUTPUT_INPUT: begin
		  nxt_state = OUTPUT_CALC;
		  input_out = 1'b1;
		  //Pass to calc
		end
		OUTPUT_CALC: begin
			nxt_state = OUTPUT_WRITE;
			output_nxt_count = output_count + 1'b1;
			input_out = 1'b1;
			//Do calculation
		end
		OUTPUT_WRITE: begin
		  nxt_state = OUTPUT_READ;
		  hidden_count = hidden_nxt_count;
		  input_out = 1'b1;
		  if(output_count == 5'b11110) begin //30
			nxt_state = DONE;
			output_count = 1'b0;
			//All other counts
		  end
		end
		DONE: begin
		end
		// default values
		default: begin
		  nxt_state = IDLE;
		end
	  endcase
	end
	
	
	
	endmodule

endmodule
