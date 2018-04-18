module uart_tx_tb();

reg tx_start, clk, rst_n;
reg [7:0] tx_data;
wire tx_rdy;
wire tx;
// Determine which number is being transmitted
reg [1:0] count;
reg [3:0] index;

// DUT
uart_tx iDUT(tx_rdy, tx, tx_start, tx_data, clk, rst_n);

// clock
initial clk = 0;
always #10 clk = ~clk;

// Detects rx_rdy and prints value
always begin 
  repeat(2604) @(negedge clk);
  // Start bit
  if (index == 0) 
    $display("Expected: %h, Actual: %h", 1'h0, tx);
  // Stop bit
  else if (index == 9) 
    $display("Expected: %h, Actual: %h", 1'h1, tx);
  // Tx data bits
  else 
    $display("Expected: %h, Actual: %h", tx_data[index-1], tx);

  index = index + 1;
end

// Stop when tx_ready goes high at the end of trasmission
always@(posedge tx_rdy) begin 
  if (count > 0) begin
       $stop;
  end
  count = count + 1;
end

initial begin 
index = 0;
count = 0;
rst_n = 0;
// Set tx_data
tx_data = 8'b11100011;
#1000;
// Start transmission
tx_start = 1;
rst_n = 1;
#40;
tx_start = 0;


end
endmodule