module uart_tx1(tx_ready, tx, tx_start, tx_data, clk, rst_n);

// Inputs and outputs
input tx_start, clk, rst_n;
input [7:0] tx_data;
output reg tx_ready;
output reg tx;

// Connecting wires
wire full_baud, clrbaud, shiftreg_full, load, shift, clear;

// Instantiations
fsm1 F1(.clear(clear), .shift(shift), .clrbaud(clrbaud), .tx_ready(tx_ready), .load(load), .full_baud(full_baud), .tx_start(tx_start), .shiftreg_full(shiftreg_full), .clk(clk), .rst_n(rst_n));
shifter1 S1(.tx_ready(tx_ready), .tx(tx), .tx_data(tx_data), .load(load), .shift(shift), .clk(clk), .rst_n(rst_n));
baud1 B1(.full_baud(full_baud), .clrbaud(clrbaud), .clk(clk), .rst_n(rst_n));
shift_count1 S2(.clear(clear), .shiftreg_full(shiftreg_full), .load(load), .shift(shift), .clk(clk), .rst_n(rst_n));

endmodule

// Finite state machine
module fsm1(clear, shift, clrbaud, tx_ready, load, full_baud, tx_start, shiftreg_full, clk, rst_n);

input full_baud, tx_start, shiftreg_full, clk, rst_n;
output reg shift, clrbaud, tx_ready, load, clear;

// States
typedef enum reg[1:0] { TX, IDLE } state_t;
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
  nxt_state = IDLE;
  shift = 1'b0;
  clrbaud = 1'b0;
  tx_ready = 1'b0;
  load = 1'b0;
  clear = 1'b0;
  // State case statement
  case(state)
    // Stays in IDLE unitl start bit
    IDLE: begin
      clear = 1'b1;
      if(tx_start) begin
        nxt_state = TX;
        load = 1'b1;
        clear = 1'b0;
      end
      else begin
        nxt_state = IDLE;
        clrbaud = 1'b1;
        tx_ready = 1'b1;
      end
    end
    // Shifts in rx to rx_data until full
    TX: begin
      clear = 1'b0;
      nxt_state = TX;
      if (full_baud & ~shiftreg_full) begin
        shift = 1'b1;
        clrbaud = 1'b1;
        nxt_state = TX;
      end
      else if (shiftreg_full) begin 
        nxt_state = IDLE;
        clear = 1'b1;
      end
    end
    // default values
    default: begin
      nxt_state = IDLE;
      shift = 1'b0;
      clrbaud = 1'b0;
      tx_ready = 1'b0;
      load = 1'b0;
      clear = 1'b0;
    end
  endcase
end
endmodule

// Shifter for rx_data
module shifter1(tx_ready, tx, tx_data, load, shift, clk, rst_n);

input load, shift, clk, rst_n, tx_ready;
input [7:0] tx_data;
output reg tx;

reg [9:0] tx_out;

always_ff@(posedge clk, negedge rst_n) begin

  if (!rst_n) begin
    tx_out <= 10'h0;
    tx <= 1'b1;
  end
  else begin
     // Shift rx in to rx_data
     if (load) begin
       tx_out <= {1'b1, tx_data, 1'b0};
       tx <= 1'b1;
     end
     else if (shift) begin
       tx_out <= {tx_out[0], tx_out[9:1]};
       tx <= tx_out[0];
     end
     else if (tx_ready)
       tx <= 1'b1;
  end

end

endmodule

// Baud rate count
module baud1(full_baud, clrbaud, clk, rst_n);
input clrbaud, clk, rst_n;
output reg full_baud;

reg [11:0] baud;

// half and full baud outputs
assign full_baud = (baud == 12'hA2C) ? 1'b1 : 1'b0;

// Increments baud count
always_ff@(posedge clk, negedge rst_n) begin

  if (!rst_n) 
    baud <= 12'h000;
  else begin
     if (clrbaud)
       baud <= 12'h000;
     else
       baud <= baud + 1'b1;
  end

end
endmodule

// Counts the shifts
module shift_count1(clear, shiftreg_full, load, shift, clk, rst_n);
input load, shift, clk, rst_n, clear;
output reg shiftreg_full;

reg [3:0] count;

// Full during stop bit
assign shiftreg_full = (count == 4'hA) ? 1'b1 : 1'b0;

// Increments shift count
always_ff@(posedge clk, negedge rst_n) begin

  if (!rst_n) 
    count <= 4'h0;
  else begin
     if (load)
       count <= 4'h0;
     if (clear)
       count <= 4'h0;
     if (shift)
       count <= count + 1'b1;
     else if (~clear)
       count <= count;
  end

end
endmodule
