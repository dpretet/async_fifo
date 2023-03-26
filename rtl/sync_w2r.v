// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 1 ps
`default_nettype none

module sync_w2r

    #(
    parameter ASIZE = 4
    )(
    input  wire              rclk,
    input  wire              rrst_n,
    output reg  [ASIZE:0] rq2_wptr,
    input  wire [ASIZE:0] wptr
    );

    reg [ASIZE:0] rq1_wptr;

    always @(posedge rclk or negedge rrst_n) begin

        if (!rrst_n)
            {rq2_wptr,rq1_wptr} <= 0;
        else
            {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};

    end

endmodule

`resetall
