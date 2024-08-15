module apb_slave(
  input  pclk,
  input  prst_n,
  input  psel,
  input  pwrite,
  input  penable,
  input  [ADDR_LENGTH-1:0] paddr,
  input  [DATA_LENGTH-1:0] pwdata,
  output                   pready,
  output [DATA_LENGTH-1:0] prdata);

  reg [1:0] state, next_state;
  reg [DATA_LENGTH-1:0] mem [0:ADDR_LENGTH-1];

  
  
endmodule
