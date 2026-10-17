// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 1 ps
`default_nettype none

///////////////////////////////////////////////////////////////////////////////
//
// LFSR with a 32 taps polynomial. Found at Xilinx:
// https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
//
// X^32 + X^22 + X^2 + X^1
//
// Explanation of LFSR:
// https://en.wikipedia.org/wiki/Linear-feedback_shift_register
//
///////////////////////////////////////////////////////////////////////////////

module lfsr32

    #(
    parameter KEY = 'hFFFFFFFF
    )(
    input  logic        aclk,
    input  logic        aresetn,
    input  logic        srst,
    input  logic        en,
    output logic [31:0] lfsr
    );

    always @ (posedge aclk or negedge aresetn) begin

        if (~aresetn) begin
            lfsr <= KEY;
        end else if (srst) begin
            lfsr <= KEY;
        end else begin
            if (en) begin
                lfsr[31:1] <= lfsr[30:0];
                lfsr[0] <= lfsr[0] ~^ lfsr[1] ~^ lfsr[21] ~^ lfsr[31];
            end
        end
    end

endmodule

`resetall

