module uart_rx1(rx_rdy, rx_data, clk, rst_n, rx);

// Inputs and outputs
input rx, clk, rst_n;
output reg rx_rdy;
output reg [7:0] rx_data;

// Connecting wires
wire half_baud, full_baud, clrbaud, shiftreg_full, clrshiftreg, shift;

// Instantiations
fsm F1(.shift(shift), .clrbaud(clrbaud), .rx_rdy(rx_rdy), .clrshiftreg(clrshiftreg), .half_baud(half_baud), .full_baud(full_baud), .rx(rx), .shiftreg_full(shiftreg_full), .clk(clk), .rst_n(rst_n));
shifter S1(.rx_data(rx_data), .clrshiftreg(clrshiftreg), .rx(rx), .shift(shift), .clk(clk), .rst_n(rst_n));
baud B1(.half_baud(half_baud), .full_baud(full_baud), .clrbaud(clrbaud), .clk(clk), .rst_n(rst_n));
shift_count S2(.shiftreg_full(shiftreg_full), .clrshiftreg(clrshiftreg), .shift(shift), .clk(clk), .rst_n(rst_n));

endmodule

// Finite state machine
module fsm(shift, clrbaud, rx_rdy, clrshiftreg, half_baud, full_baud, rx, shiftreg_full, clk, rst_n);

input half_baud, full_baud, rx, shiftreg_full, clk, rst_n;
output reg shift, clrbaud, rx_rdy, clrshiftreg;

// States
typedef enum reg[1:0] { BACK_PORCH, RX, FRONT_PORCH, IDLE } state_t;
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
  shift = 0;
  clrbaud = 0;
  rx_rdy = 0;
  clrshiftreg = 0;
  // State case statement
  case(state)
    // Stays in IDLE unitl start bit
    IDLE: begin
      if(~rx)
        nxt_state = FRONT_PORCH;
      else begin
        nxt_state = IDLE;
        clrbaud = 1;
        clrshiftreg = 1;
      end
    end
    // Stays in front porch until half buad
    FRONT_PORCH: begin
       nxt_state = FRONT_PORCH;
       if (half_baud) begin
         nxt_state = RX;
         clrbaud = 1;
       end
       else begin
         nxt_state = FRONT_PORCH;
       end
       clrshiftreg = 1;
    end
    // Shifts in rx to rx_data until full
    RX: begin
      nxt_state = RX;
      if (full_baud & ~shiftreg_full) begin
        shift = 1;
        clrbaud = 1;
        nxt_state = RX;
      end
      else if (full_baud & shiftreg_full) begin 
	clrbaud = 1;
        nxt_state = BACK_PORCH;
      end
    end
    // Stays in back porch until half baud
    BACK_PORCH: begin
      if (half_baud) begin
        rx_rdy = 1;
        nxt_state = IDLE;
      end
      else
        nxt_state = BACK_PORCH;
    end
    // default values
    default: begin
      nxt_state = IDLE;
      shift = 0;
      clrbaud = 0;
      rx_rdy = 0;
      clrshiftreg = 0;
    end
  endcase
end
endmodule

// Shifter for rx_data
module shifter(rx_data, clrshiftreg, rx, shift, clk, rst_n);

input clrshiftreg, rx, shift, clk, rst_n;
output reg [7:0] rx_data;

always_ff@(posedge clk, negedge rst_n) begin

  if (!rst_n) 
    rx_data <= 8'h00;
  else begin
     // if shift clear is high, clear rx_data
     if (clrshiftreg)
       rx_data <= 8'h00;
     // Shift rx in to rx_data
     if (shift)
       rx_data <= {rx, rx_data[7:1]};
  end

end

endmodule

// Baud rate count
module baud(half_baud, full_baud, clrbaud, clk, rst_n);
input clrbaud, clk, rst_n;
output reg half_baud, full_baud;

reg [11:0] baud;

// half and full baud outputs
assign half_baud = (baud == 12'h516) ? 1 : 0;
assign full_baud = (baud == 12'hA2C) ? 1 : 0;

// Increments baud count
always_ff@(posedge clk, negedge rst_n) begin

  if (!rst_n) 
    baud <= 12'h000;
  else begin
     if (clrbaud)
       baud <= 12'h000;
     else
       baud <= baud + 1;
  end

end
endmodule

// Counts the shifts
module shift_count(shiftreg_full, clrshiftreg, shift, clk, rst_n);
input clrshiftreg, shift, clk, rst_n;
output reg shiftreg_full;

reg [3:0] count;

// Full during stop bit
assign shiftreg_full = (count == 4'h8) ? 1 : 0;

// Increments shift count
always_ff@(posedge clk, negedge rst_n) begin

  if (!rst_n) 
    count <= 4'h0;
  else begin
     if (clrshiftreg)
       count <= 4'h0;
     if (shift)
       count <= count + 1;
  end

end
endmodule
