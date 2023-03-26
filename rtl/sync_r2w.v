// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 1 ps
`default_nettype none

module sync_r2w

    #(
    parameter ASIZE = 4
    )(
    input  wire              wclk,
    input  wire              wrst_n,
    input  wire [ASIZE:0] rptr,
    output reg  [ASIZE:0] wq2_rptr
    );

    reg [ASIZE:0] wq1_rptr;

    always @(posedge wclk or negedge wrst_n) begin

        if (!wrst_n)
            {wq2_rptr,wq1_rptr} <= 0;
        else
            {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};

    end

endmodule

`resetall
