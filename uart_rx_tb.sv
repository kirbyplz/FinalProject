module uart_rx_tb();

reg rx, clk, rst_n;
wire rx_rdy;
wire [7:0] rx_data;
// Determine which number is being transmitted
reg [1:0] count;

// DUT
uart_rx iDUT(rx_rdy, rx_data, clk, rst_n, rx);

// clock
initial clk = 0;
always #10 clk = ~clk;

// Detects rx_rdy and prints value
always@(rx_rdy) begin 
  if (rx_rdy) begin
     if (count == 0)
       $display("Expected: a5, Actual: %h", rx_data);
     if (count == 1)
       $display("Expected: e7, Actual: %h", rx_data);
     if (count == 2)
       $display("Expected: 24, Actual: %h", rx_data);
  end
end

initial begin 
count = 0;
rst_n = 0;
rx = 1;
#1000;
rst_n = 1;

// A5
rx = 0;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);
rx = 0;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);
rx = 0;
repeat(2604) @(negedge clk);
rx = 0;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);
rx = 0;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);

// Wait in between
#1000;
count = 1;

// E7
rx = 0;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);
rx = 0;
repeat(2604) @(negedge clk);
rx = 0;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);

// Wait in between
#1000;
count = 2;

// 24
rx = 0;
repeat(2604) @(negedge clk);
rx = 0;
repeat(2604) @(negedge clk);
rx = 0;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);
rx = 0;
repeat(2604) @(negedge clk);
rx = 0;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);
rx = 0;
repeat(2604) @(negedge clk);
rx = 0;
repeat(2604) @(negedge clk);
rx = 1;
repeat(2604) @(negedge clk);

#1000;

$stop;

end
endmodule
