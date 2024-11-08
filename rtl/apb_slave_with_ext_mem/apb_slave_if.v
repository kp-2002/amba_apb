//Author: Kaivalyae Panicker <kaivalyaep22@gmail.com>
//Date  : 09.11.2024
//Description: This is the rtl for an apb slave interface that can be 
//connected to an external memory module of any size in a top-level 
//wrapper to generate a memory block with an apb interface

/*
 * Copyright 2024 Kaivalyae Panicker

 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at

 *  http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module apb_slave_if #(parameter ADDR_WIDTH = 30,
                      parameter DATA_WIDTH = 32,
                      parameter STRB_WIDTH = DATA_WIDTH/8) (

    //APB slave interface
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
    output     [DATA_WIDTH-1:0] prdata,
    output reg                  pslverr,
   

    //External memory interface
    //External memory clock and active low reset
    output                      mem_clk,
    output                      mem_rst_n,
    //External memory inputs
    output reg                  mem_wr_en,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output     [DATA_WIDTH-1:0] mem_wr_data,
    output     [STRB_WIDTH-1:0] mem_strb,
    output reg                  mem_rd_en,
    //External memory output
    input      [DATA_WIDTH-1:0] mem_rd_data);

    //Clock gating logic using pwakeup, enables the device to be
    //powered off when not in use
    reg enable_latch;
    always @(pclk or pwakeup)
        if(~pclk)
            enable_latch <= pwakeup;
    
    //Gated clock
    wire   g_clk;
    assign g_clk = (pclk & enable_latch);

    //State machine logic
    parameter IDLE = 2'b00, WRITE = 2'b01, READ = 2'b10;

    reg [1:0] state, next_state;
    
    always @(posedge g_clk) begin
        if(~prst_n) 
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case(state) 
            IDLE:    next_state = (psel & pwrite)? WRITE: ((psel & ~pwrite)? READ: IDLE);
            WRITE:   next_state = (psel & penable & pready)? IDLE: WRITE;
            READ:    next_state = (psel & penable & pready)? IDLE: READ; 
            default: next_state = IDLE;
        endcase
    end

    //Logic to drive external memory interface
    assign mem_clk     = g_clk;
    assign mem_rst_n   = prst_n;
    assign mem_wr_data = pwdata;
    assign mem_strb    = pstrb;

    always @(*) begin
        if(prst_n & pwakeup) begin
            case(state)
                IDLE: begin
                    mem_wr_en = 1'b0;
                    mem_rd_en = 1'b0;
                end
                WRITE: begin
                    mem_wr_en = 1'b1;
                    mem_rd_en = 1'b0;
                    mem_addr  = paddr;
                end
                READ: begin
                    mem_wr_en = 1'b0;
                    mem_rd_en = 1'b1;
                    mem_addr  = paddr;
                end
            endcase
        end
    end
    
    //Logic to drive apb interface
    assign prdata = mem_rd_data;
    
    always @(*) begin
        if(prst_n & pwakeup) begin
            pslverr = 1'b0;
            case(state)
                IDLE: begin
                    pready = 1'b0;
                end
                WRITE: begin
                    if(psel & penable)
                        pready = 1'b1;
                end
                READ: begin
                    if(psel & penable)
                        pready = 1'b1;
                end
            endcase
        end
    end
    
endmodule
