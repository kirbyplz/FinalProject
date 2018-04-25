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

	
	assign mac_a_mux =
	
	module mac(.rst_n(rst_n),.clk(clk),.a(mac_a_mux),.b(mac_b_mux),.clr_n(mac_clr),.acc(mac_output);

	
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
	  // State case statement
	  case(state)
		// Stays in IDLE unitl start bit
		IDLE: begin
		  if(start)
			nxt_state = HIDDEN_READ;
			//read input logic
		  else begin
			nxt_state = IDLE;
		  end
		end
		// Stays in read one extra cycle to read weight
		HIDDEN_READ: begin
		   if (weight_read) begin
			 nxt_state = HIDDEN_INPUT;
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
		HIDDEN_INPUT: begin
		  nxt_state = HIDDEN_CALC;
		  hidden_count = hidden_nxt_count;
		  //Pass to calc
		end
		// default values
		default: begin
		  nxt_state = IDLE;
		  shift = 1'b0;
		  clrbaud = 1'b0;
		  rx_rdy = 1'b0;
		  clrshiftreg = 1'b0;
		end
	  endcase
	end
	
	
	
	endmodule
	module rom_act_func_lut;
	module ram_hidden_unit(.clk(clk),.addr(addr_input_unit),.data(hiddenweight),.we(writeenable),.q(hiddenunit));
	module ram_output_unit(.clk(clk),.addr(addr_input_unit),.data(outputweight),.we(writeenable),.q(outputunit));
	module rom_hidden_weight rom(.addr(addr_input_unit), .clk(clk), .q(hiddenweight));
	module rom_output_weight rom(.addr(addr_input_unit), .clk(clk), .q(outputweight));
endmodule
