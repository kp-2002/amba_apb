module apb_slave_top #(parameter ADDR_WIDTH = 30,
                                parameter DATA_WIDTH = 32,
                                parameter STRB_WIDTH = DATA_WIDTH/8) (
    //Clock and active low reset
    input                       pclk,
    input                       pwakeup,
    input                       prst_n,

    //Slave inputs
    input      [ADDR_WIDTH-1:0] paddr,
    input               [3-1:0] pprot,
    input                       psel,
    input                       penable, 
    input                       pwrite,
    input      [DATA_WIDTH-1:0] pwdata,
    input      [STRB_WIDTH-1:0] pstrb,

    //Slave outputs
    output reg                  pready,
    output reg [DATA_WIDTH-1:0] prdata,
    output reg                  pslverr);

    wire                  mem_clk;
    wire                  mem_rst_n;
    wire                  mem_wr_en;
    wire                  mem_rd_en;
    wire [ADDR_WIDTH-1:0] mem_addr;
    wire [DATA_WIDTH-1:0] mem_wr_data;
    wire [STRB_WIDTH-1:0] mem_strb;
    wire [DATA_WIDTH-1:0] mem_rd_data;

    apb_slave_if  #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .STRB_WIDTH(STRB_WIDTH)) 

    i_apb_slave_if (

        //APB slave interface
        .pclk(pclk),
        .pwakeup(pwakeup),       
        .prst_n(prst_n),
        .paddr(paddr),
        .pprot(pprot),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),
        .pstrb(pstrb),
        .pready(pready),
        .prdata(prdata),
        .pslverr(pslverr),

        //External memory interface
        .mem_clk(mem_clk),
        .mem_rst_n(mem_rst_n),
        .mem_wr_en(mem_wr_en),
        .mem_rd_en(mem_rd_en),
        .mem_addr(mem_addr),
        .mem_wr_data(mem_wr_data),
        .mem_strb(mem_strb),
        .mem_rd_data(mem_rd_data));

    ext_mem  #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .STRB_WIDTH(STRB_WIDTH)) 
    
    i_ext_mem(
        .mem_clk(mem_clk),
        .mem_rst_n(mem_rst_n),
        .mem_wr_en(mem_wr_en),
        .mem_rd_en(mem_rd_en),
        .mem_addr(mem_addr),
        .mem_wr_data(mem_wr_data),
        .mem_strb(mem_strb),
        .mem_rd_data(mem_rd_data));


endmodule
