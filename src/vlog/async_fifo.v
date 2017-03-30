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
    parameter WIDTH     = 8,
    parameter POINTER   = 4
    )(
    // Write side of the FIFO
    input  wire             wr_clk,
    input  wire             wr_arstn,
    input  wire             wr_en,
    input  wire [WIDTH-1:0] wr_data,
    output wire             wr_full,
    // Read side of the FIFO
    input  wire             rd_clk,
    input  wire             rd_arstn,
    input  wire             rd_en,
    output wire [WIDTH-1:0] rd_data,
    output wire             rd_empty
    );

    localparam DEPTH = 1 << POINTER;

    // Read pointer managed by rd_clk
    reg  [POINTER:0] rd_pointer;
    // Write pointer managed by wr_clk
    reg  [POINTER:0] wr_pointer;

    // Pointers used to pass between the domains
    reg  [POINTER:0] rd_sync_1;
    reg  [POINTER:0] wr_sync_1;
    reg  [POINTER:0] rd_sync_2;
    reg  [POINTER:0] wr_sync_2;
    wire [POINTER:0] rd_pointer_g;
    wire [POINTER:0] wr_pointer_g;

    // Pointers used across the domains:

    // Used in write domain
    wire [POINTER:0] rd_pointer_sync;
    // Used in read domain
    wire [POINTER:0] wr_pointer_sync;

    // The memory block RAM used to store and
    // pass the information
    reg  [WIDTH-1:0] mem [DEPTH-1 : 0];

    // Write logic management
    always @(posedge wr_clk or negedge wr_arstn) begin
        if (wr_arstn == 1'b0) begin
            wr_pointer <= 0;
        end
        else if (wr_full == 1'b0 && wr_en == 1'b1) begin
            wr_pointer <= wr_pointer + 1;
            mem[wr_pointer[POINTER-1 : 0]] <= wr_data;
        end
    end

    // Synchronization of read pointer with write clock
    always @(posedge wr_clk) begin
        rd_sync_1 <= rd_pointer_g;
        rd_sync_2 <= rd_sync_1;
    end

    // Read logic management
    always @(posedge rd_clk or negedge rd_arstn) begin
        if (rd_arstn == 1'b0) begin
            rd_pointer <= 0;
        end
        else if (rd_empty == 1'b0 && rd_en == 1'b1) begin
            rd_pointer <= rd_pointer + 1;
        end
    end

    assign rd_data = mem[rd_pointer[POINTER-1 : 0]];

    // Write pointer synchronization with read clock
    always @(posedge rd_clk) begin
        wr_sync_1 <= wr_pointer_g;
        wr_sync_2 <= wr_sync_1;
    end

    // Binary pointer comparaison
    //assign wr_full = ((wr_pointer[POINTER-1 : 0] == rd_pointer_sync[POINTER-1 : 0]) &&
    //                  (wr_pointer[POINTER] != rd_pointer_sync[POINTER] )) ? 1'b1 : 1'b0;

    // Gray counter comparaison
    assign wr_full  = ((wr_pointer[POINTER-2 : 0] == rd_pointer_sync[POINTER-2 : 0]) &&
                       (wr_pointer[POINTER-1] != rd_pointer_sync[POINTER-1]) &&
                       (wr_pointer[POINTER] != rd_pointer_sync[POINTER])) ? 1'b1 : 1'b0;

    // The FIFO is considered as empty when pointer match the same address
    // No more data remains to read
    assign rd_empty = ((wr_pointer_sync == rd_pointer) == 0) ? 1'b1 : 1'b0;


    // Convert to gray before moving the pointers
    // to the destination clock domain
    assign wr_pointer_g = wr_pointer ^ (wr_pointer >> 1);
    assign rd_pointer_g = rd_pointer ^ (rd_pointer >> 1);


    // Convert back to binary after the synchronization from
    // the source domain
    assign wr_pointer_sync = wr_sync_2 ^ (wr_sync_2 >> 1) ^ (wr_sync_2 >> 2) ^ (wr_sync_2 >> 3);

    assign rd_pointer_sync = rd_sync_2 ^ (rd_sync_2 >> 1) ^ (rd_sync_2 >> 2) ^ (rd_sync_2 >> 3);

endmodule

`resetall

