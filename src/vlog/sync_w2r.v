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
