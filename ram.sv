module ram (
 input [(DATA_WIDTH-1):0] data,
 input [(ADDR_WIDTH-1):0] addr,
 input we, clk,
 output [(DATA_WIDTH-1):0] q);
 // Declare the RAM variable
 reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
 // Variable to hold the registered read address
 reg [ADDR_WIDTH-1:0] addr_reg;

 initial begin
   readmemh("Initialization file", rom);
 end

 always @ (posedge clk) begin
   if (we) begin
     ram[addr] <= data;
   end
   addr_reg <= addr;
 end
 assign q = ram[addr_reg];
endmodule
