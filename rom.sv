module rom (
 input [(ADDR_WIDTH-1):0] addr,
 input clk,
 output reg [(DATA_WIDTH-1):0] q);

 // Declare the ROM variable
 reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

 initial
   readmemh("Initialization file", rom);

 always @ (posedge clk)
   q <= rom[addr];

endmodule 