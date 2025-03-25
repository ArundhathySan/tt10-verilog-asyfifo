/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_asyfifo (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // Always 1 when the design is powered
    input  wire       clk,      // Write clock
    input  wire       rst_n     // Write reset (active low)
);

    wire rd_clk, rd_rst;

    // Instantiate clock divider for read clock and reset
    clock_divider clk_div (
        .wr_clk(clk),
        .wr_rst(~rst_n), // Convert active-low reset
        .rd_clk(rd_clk),
        .rd_rst(rd_rst)
    );

    // Instantiate FIFO
    async_fifo #(
        .DATA_WIDTH(4), 
        .ADDR_WIDTH(3)
    ) as_fifo (
        .wr_clk(clk),
        .wr_rst(~rst_n),
        .rd_clk(rd_clk),
        .rd_rst(rd_rst),
        .wr_en(ui_in[0]),
        .rd_en(ui_in[1]),
        .wr_data(ui_in[5:2]),
        .full(uo_out[0]),
        .empty(uo_out[1]),
        .rd_data(uo_out[5:2])
    );

    // Set unused outputs to 0
    assign uo_out[7:6] = 2'b00;
    assign uio_out = 8'b00000000;
    assign uio_oe = 8'b00000000;
    wire _unused = &{ena, 1'b0};

endmodule

// Clock divider module
module clock_divider (
    input wire wr_clk,  
    input wire wr_rst,  
    output reg rd_clk,  
    output reg rd_rst  
);
    reg [3:0] counter = 0;

    always @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            counter <= 0;
            rd_clk <= 0;
            rd_rst <= 1;
        end else begin
            counter <= counter + 1;
            if (counter == 2) begin
                rd_clk <= ~rd_clk;
                counter <= 0;
            end
            rd_rst <= 0;
        end
    end
endmodule

// Asynchronous FIFO
module async_fifo #(
    parameter DATA_WIDTH = 4,  
    parameter ADDR_WIDTH = 3  
)(
    input  wire wr_clk,    
    input  wire wr_rst,    
    input  wire rd_clk,    
    input  wire rd_rst,    
    input  wire wr_en,     
    input  wire rd_en,     
    input  wire [DATA_WIDTH-1:0] wr_data,  
    output reg  [DATA_WIDTH-1:0] rd_data,  
    output wire full,     
    output wire empty     
);

    localparam DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0] wr_ptr = 0, rd_ptr = 0;
    reg [ADDR_WIDTH:0] wr_ptr_gray = 0, wr_ptr_gray_sync = 0;
    reg [ADDR_WIDTH:0] rd_ptr_gray = 0, rd_ptr_gray_sync = 0;

    function [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] bin);
        bin2gray = bin ^ (bin >> 1);
    endfunction

    function [ADDR_WIDTH:0] gray2bin(input [ADDR_WIDTH:0] gray);
        integer i;
        reg [ADDR_WIDTH:0] bin;
        bin = gray[ADDR_WIDTH];
        for (i = ADDR_WIDTH-1; i >= 0; i = i - 1)
            bin[i] = bin[i+1] ^ gray[i];
        gray2bin = bin;
    endfunction

    always @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            wr_ptr <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1;
            wr_ptr_gray <= bin2gray(wr_ptr + 1);
        end
    end

    always @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) begin
            rd_ptr <= 0;
            rd_ptr_gray <= 0;
            rd_data <= 0;
        end else if (rd_en && !empty) begin  
            rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
            rd_ptr <= rd_ptr + 1;
            rd_ptr_gray <= bin2gray(rd_ptr + 1);
        end
    end

    always @(posedge rd_clk) begin
        wr_ptr_gray_sync <= wr_ptr_gray;
    end

    always @(posedge wr_clk) begin
        rd_ptr_gray_sync <= rd_ptr_gray;
    end

    assign full = (wr_ptr_gray == {~rd_ptr_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1], rd_ptr_gray_sync[ADDR_WIDTH-2:0]});
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync);

endmodule  


 

  


  
