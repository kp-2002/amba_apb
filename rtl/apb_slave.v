module apb_slave #(parameter ADDR_WIDTH = 30,
                   parameter DATA_WIDTH = 32,
                   parameter STRB_WIDTH = DATA_WIDTH/8) (
    input                       pclk,
    input                       pwakeup,
    input                       prst_n,

    input      [ADDR_WIDTH-1:0] paddr,
    input               [3-1:0] pprot,
    input                       psel,
    input                       penable, 
    input                       pwrite,
    input      [DATA_WIDTH-1:0] pwdata,
    input      [STRB_WIDTH-1:0] pstrb,

    output reg                  pready,
    output reg [DATA_WIDTH-1:0] prdata,
    output reg                  pslverr);

    reg enable_latch;
    always @(pclk or pwakeup)
        if(~pclk)
            enable_latch <= pwakeup;

    wire   g_clk;
    assign g_clk = (pclk & enable_latch);

    parameter IDLE = 2'b00, WRITE = 2'b01, READ = 2'b10;

    reg [1:0] state, next_state;

    reg [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];

    always @(posedge g_clk) begin
        if(~prst_n) begin
            state <= IDLE;
            for(int i=0; i<2**ADDR_WIDTH; i=i+1)
				mem[i] <= {DATA_WIDTH{1'b0}};
            pready <= 1'b0;
            prdata <= {DATA_WIDTH{1'b0}};
        end
        else
            state <= next_state;
    end

    always @(*) begin
        case(state) 
            IDLE:    next_state = (psel & pwrite)? WRITE: ((psel & ~pwrite)? READ: IDLE);
            WRITE:   next_state = (psel & penable)? IDLE: WRITE;
            READ:    next_state = (psel & penable)? IDLE: READ; 
            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
        pslverr = 1'b0;
        if(prst_n & pwakeup) begin
            case(state)
                IDLE:  begin
                    pready = 1'b0;
                    prdata = 32'b0;
                end
                WRITE: begin
                    if(psel & penable) begin
                        pready = 1'b1;
                        for(int i=0; i<STRB_WIDTH; i=i+1)
                            if(pstrb[i])
                                mem[paddr][8*i +: 8] = pwdata[8*i +: 8];
                    end
                end
                READ:  begin
                    if(psel & penable) begin
                        pready = 1'b1; 
                        prdata     = mem[paddr];
                    end
                end
                default: begin
                    pready = 1'b0;
                    prdata = {DATA_WIDTH{1'b0}};
                end
            endcase        
        end
    end

endmodule
