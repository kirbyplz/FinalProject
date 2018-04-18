module mac_tb();

reg signed [7:0] a, b;
reg clk, rst_n, clr_n;
wire of, uf;
wire signed [15:0] acc;

mac iDUT(clk, rst_n, a, b, of, uf, clr_n, acc);

initial clk = 0;

always #5 clk = ~clk;

initial begin

rst_n = 1;
a = 2;
b = 5;
clr_n = 0;
#10;
if (of)
  $display("Overflow");
else if(uf)
  $display("Underflow");
a = -2;
b = 5;
clr_n = 1;
#10;
if (of)
  $display("Overflow");
else if(uf)
  $display("Underflow");
a = -3;
b = 8;
#10

clr_n = 0;
#10
clr_n = 1;
if (of)
  $display("Overflow");
else if(uf)
  $display("Underflow");
a = 126;
b = 126;
#10;
if (of)
  $display("Overflow");
else if(uf)
  $display("Underflow");
a = 126;
b = 126;
#10;
if (of)
  $display("Overflow");
else if(uf)
  $display("Underflow");
a = 126;
b = 126;
#10;

clr_n = 0;
#10
clr_n = 1;

if (of)
  $display("Overflow");
else if(uf)
  $display("Underflow");
a = -128;
b = 128;
#10;
if (of)
  $display("Overflow");
else if(uf)
  $display("Underflow");
a = -128;
b = 128;
#10;
if (of)
  $display("Overflow");
else if(uf)
  $display("Underflow");
a = -1;
b = 1;
#10;

$stop;
end
endmodule 