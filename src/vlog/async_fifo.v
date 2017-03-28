/*
    Copyright 2017 Damien Pretet ThotIP
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

`timescale 1 ns / 1 ps
`default_nettype none

module async_fifo

	#(
	parameter WIDTH		= 8,
	parameter POINTER	= 4
	)(
    // Write side of the FIFO
	input  wire             wr_clk,
	input  wire             awresetn,
	input  wire             wren,
	input  wire [WIDTH-1:0] data_in,
	output wire             wr_full,
    // Read side of the FIFO
	input  wire             rd_clk,
	input  wire             arresetn,
	input  wire             rden,
	output wire [WIDTH-1:0] data_out,
	output wire             rd_empty,
	);

    parameter DEPTH = 1 << POINTER;

    reg [POINTER-1 : 0] rd_pointer, rd_pointer_g, rd_sync_1, rd_sync_2;
    reg [POINTER-1 : 0] wr_pointer, wr_pointer_g, wr_sync_1, wr_sync_2;
    
    reg [WIDTH-1 : 0] mem [DIPTH-1 : 0];
    
    wire [POINTER-1 : 0] rd_pointer_sync;
    wire [POINTER-1 : 0] wr_pointer_sync;
    
    // Write logic management
    always @(posedge wr_clk or posedge awresetn) begin
        if (awresetn == 1'b0) begin
            wr_pointer <= 0;
        end
        else if (full == 1'b0 && wren == 1'b1) begin
            wr_pointer <= wr_pointer + 1;
            mem[wr_pointer[POINTER-1 : 0]] <= data_in;
        end
    end
    
    // Synchronization of read pointer with write clock
    always @(posedge wr_clk) begin
        rd_sync_1 <= rd_pointer_g;
        rd_sync_2 <= rd_sync_1;
    end
    
    // Read logic management
    always @(posedge rd_clk or posedge arresetn) begin
        if (arresetn == 1'b0) begin
            // read reset
            rd_pointer <= 0;
        end
        else if (empty == 1'b0 && rden == 1'b1) begin
            rd_pointer <= rd_pointer + 1;
        end
    end
    
    assign data_out = mem[rd_pointer[POINTER-1 : 0]];
    
    // Write pointer synchronization with read clock
    always @(posedge rd_clk) begin
        wr_sync_1 <= wr_pointer_g;
        wr_sync_2 <= wr_sync_1;
    end
    
    //--Combinational logic--//
    //--Binary pointer--//
    assign wr_full = ((wr_pointer[POINTER-1 : 0] == rd_pointer_sync[POINTER-1 : 0]) &&
                    (wr_pointer[POINTER] != rd_pointer_sync[POINTER] ));
    
    //-- Gray pointer--//
    //assign wr_full  = ((wr_pointer[POINTER-2 : 0] == rd_pointer_sync[POINTER-2 : 0]) &&
    //                (wr_pointer[POINTER-1] != rd_pointer_sync[POINTER-1]) &&
    //                (wr_pointer[POINTER] != rd_pointer_sync[POINTER]));
    
    // The FIFO is considered as empty when pointer match the same address
    // No more data remains to read 
    assign rd_empty = ((wr_pointer_sync == rd_pointer) == 0) ? 1'b1 : 1'b0;
    
    
    //--binary code to gray code--//
    assign wr_pointer_g = wr_pointer ^ (wr_pointer >> 1);
    assign rd_pointer_g = rd_pointer ^ (rd_pointer >> 1);
    //--gray code to binary code--//
    assign wr_pointer_sync = wr_sync_2 ^ (wr_sync_2 >> 1) ^
                            (wr_sync_2 >> 2) ^ (wr_sync_2 >> 3);
    assign rd_pointer_sync = rd_sync_2 ^ (rd_sync_2 >> 1) ^
                            (rd_sync_2 >> 2) ^ (rd_sync_2 >> 3);

endmodule

`resetall

