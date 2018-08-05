//-----------------------------------------------------------------------------
// Copyright 2017 Damien Pretet ThotIP
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------------------

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
