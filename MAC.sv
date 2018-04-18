module mac(clk, rst_n, a, b, of, uf, clr_n, acc);
// Inputs
input signed [7:0] a, b;
input clk, rst_n, clr_n;
// Outputs
output of, uf;
output signed [15:0] acc;

// Wires
wire signed [15:0] mult, addOut, acc_nxt;
wire of_nxt, uf_nxt;

// Multiplier
assign mult = a * b;
// Adder
assign addOut = mult + acc;
// Next overflow and underflow
assign of_nxt = (mult[15] == 0 && acc[15] == 0 && addOut[15] == 1) ? 1 : 0;
assign uf_nxt = (mult[15] == 1 && acc[15] == 1 && addOut[15] == 0) ? 1 : 0;
assign acc_nxt = (clr_n == 1) ? addOut : 16'h00;

// Acc flop
Flop1 F1(clk, rst_n, acc_nxt, acc);
// Overflow and underflow flop
Flop2 F2(clk, rst_n, of_nxt, uf_nxt, of, uf);

endmodule

// Single Flip flop
module Flop1(clk, rst_n, d, q);
input clk, rst_n;
input [15:0] d;
output reg [15:0] q;

always@(posedge clk, negedge rst_n) begin
  if(!rst_n)
    q <= 16'h00;
  else
    q <= d;
end
endmodule

// Double input flip flop
module Flop2(clk, rst_n, d1, d2, q1, q2);
input clk, rst_n;
input d1, d2;
output reg q1, q2;

always@(posedge clk, negedge rst_n) begin
  if(!rst_n) begin
    q1 <= 16'h00;
    q1 <= 16'h00;
  end
  else begin
    q1 <= d1;
    q2 <= d2;
  end
end
endmodule
