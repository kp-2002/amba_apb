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

  parameter IDLE = 2'b00, SETUP = 2'b01, ACCESS = 2'b10;

  reg [1:0] state, next_state;

  always @(posedge pclk) begin
    if(~prst_n)
      state <= IDLE;
    else
      state <= next_state;
  end

  always @(*) begin
    case(state) 
      IDLE:   next_state = (psel)? IDLE: SETUP;
      SETUP:  next_state = ACCESS;
      ACCESS: next_state = (pready)? ((psel)? SETUP: IDLE): ACCESS; 
    endcase
  end

  reg [DATA_WIDTH-1:0] mem [0:2**ADDR_WIDTH];

  always @(posedge pclk) begin
    if(~prst_n) begin
			for(int i=0; i<2**ADDR_WIDTH; i++)
				mem[i] <= 0;
      pready <= 1'b0;
      prdata <= 32'b0;
    end
    else if(state == ACCESS) begin
      pready <= 1'b1; 
      if(pwrite) begin
        mem[paddr] <= pwdata;
      end
      else begin
        prdata     <= mem[paddr];
      end
    end
  end
  
endmodule
