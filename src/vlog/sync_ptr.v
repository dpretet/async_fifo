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
