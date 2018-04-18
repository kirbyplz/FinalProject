module SNN_tb ();
  logic clk, sys_rst_n, uart_tx, uart_rx, tx_start, rx_rdy;
  logic [7:0] value, output_val;

  //uart_tx1 TX (.clk(clk), .rst_n(sys_rst_n), .tx_start(tx_start), .tx_ready(), .tx(uart_rx), .tx_data(value));
  //uart_rx1 RX (.clk(clk), .rst_n(sys_rst_n), .rx(uart_tx), .rx_rdy(rx_rdy), .rx_data(output_val));
  SNN SNN    (.clk(clk), .sys_rst_n(sys_rst_n), .led(), .uart_tx(uart_tx), .uart_rx(uart_rx));

  /*initial begin
    tx_start = 0;
    clk = 0;
    value = 0;
    sys_rst_n = 0;
    #20 sys_rst_n = 1;

    value = 8'h38;
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;

    @(posedge rx_rdy)

    if ( value != output_val) begin
      $display("Output Value: %h, doesn't equal expected value %h", output_val, value);
      $stop;
    end

  $stop;
  end*/

// clock
initial clk = 0;
always #10 clk = ~clk;

initial begin
sys_rst_n = 0;
uart_rx = 1;
#1000;
sys_rst_n = 1;

// A5
uart_rx = 0;
repeat(2604) @(negedge clk);
uart_rx = 1;
repeat(2604) @(negedge clk);
uart_rx = 0;
repeat(2604) @(negedge clk);
uart_rx = 1;
repeat(2604) @(negedge clk);
uart_rx = 0;
repeat(2604) @(negedge clk);
uart_rx = 0;
repeat(2604) @(negedge clk);
uart_rx = 1;
repeat(2604) @(negedge clk);
uart_rx = 0;
repeat(2604) @(negedge clk);
uart_rx = 1;
repeat(2604) @(negedge clk);
uart_rx = 1;
repeat(2604) @(negedge clk);


#50000;
// A5
uart_rx = 0;
repeat(2604) @(negedge clk);
uart_rx = 1;
repeat(2604) @(negedge clk);
uart_rx = 0;
repeat(2604) @(negedge clk);
uart_rx = 1;
repeat(2604) @(negedge clk);
uart_rx = 0;
repeat(2604) @(negedge clk);
uart_rx = 0;
repeat(2604) @(negedge clk);
uart_rx = 1;
repeat(2604) @(negedge clk);
uart_rx = 0;
repeat(2604) @(negedge clk);
uart_rx = 1;
repeat(2604) @(negedge clk);
uart_rx = 1;
repeat(2604) @(negedge clk);

// Wait in between
#1000;
end
endmodule
