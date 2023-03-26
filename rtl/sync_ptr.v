// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 1 ps
`default_nettype none

module sync_ptr

    #(
    parameter ASIZE = 4
    )(
    input  wire              dest_clk,
    input  wire              dest_rst_n,
    input  wire [ASIZE:0] src_ptr,
    output reg  [ASIZE:0] dest_ptr
    );

    reg [ASIZE:0] ptr_x;

    always @(posedge dest_clk or negedge dest_rst_n) begin

        if (!dest_rst_n)
            {dest_ptr,ptr_x} <= 0;
        else
            {dest_ptr,ptr_x} <= {ptr_x,src_ptr};
    end

endmodule

`resetall
