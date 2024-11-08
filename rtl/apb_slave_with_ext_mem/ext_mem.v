module ext_mem #(parameter ADDR_WIDTH = 30,
		             parameter DATA_WIDTH = 32,
                 parameter STRB_WIDTH = DATA_WIDTH/8) (
	input                         mem_clk,
	input                         mem_rst_n,
	input                         mem_wr_en,
	input                         mem_rd_en,
	input      [ADDR_WIDTH-1 : 0] mem_addr,
	input      [DATA_WIDTH-1 : 0] mem_wr_data,
    input      [STRB_WIDTH-1 : 0] mem_strb,
	output reg [DATA_WIDTH-1 : 0] mem_rd_data);
	
	reg [DATA_WIDTH-1 : 0] mem [2**ADDR_WIDTH];
	
	always @(posedge mem_clk or negedge mem_rst_n) begin
		if(~mem_rst_n) begin
			for(int i=0; i<2**ADDR_WIDTH; i++)
				mem[i] <= {DATA_WIDTH{1'b0}};
		end
		else begin
			if(mem_wr_en) begin
                for(int i=0;i<STRB_WIDTH;i=i+1)
                    if(mem_strb[i]==1'b1)
				        mem[mem_addr][8*i +: 8] <= mem_wr_data[8*i +: 8];
			end
			else if(mem_rd_en) begin
				mem_rd_data   <= mem[mem_addr];
			end
		end
	end

endmodule
