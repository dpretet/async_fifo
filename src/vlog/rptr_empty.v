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

module rptr_empty 
    
    #(
    parameter ADDRSIZE = 4
    )(
    input  wire                rclk,
    input  wire                rrst_n,
    input  wire                rinc,
    input  wire [ADDRSIZE  :0] rq2_wptr,
    output reg                 rempty,
    output reg                 arempty,
    output wire [ADDRSIZE-1:0] raddr,
    output reg  [ADDRSIZE  :0] rptr
    );
    
    reg  [ADDRSIZE:0] rbin;
    wire [ADDRSIZE:0] rgraynext, rbinnext, rgraynextm1;
    wire              arempty_val, rempty_val;

    //-------------------
    // GRAYSTYLE2 pointer
    //-------------------
    always @(posedge rclk or negedge rrst_n) begin

        if (!rrst_n) 
            {rbin, rptr} <= 0;
        else         
            {rbin, rptr} <= {rbinnext, rgraynext};

    end
    
    // Memory read-address pointer (okay to use binary to address memory)
    assign raddr     = rbin[ADDRSIZE-1:0];
    assign rbinnext  = rbin + (rinc & ~rempty);
    assign rgraynext = (rbinnext >> 1) ^ rbinnext;
    assign rgraynextm1 = ((rbinnext + 1'b1) >> 1) ^ (rbinnext + 1'b1);
    
    //--------------------------------------------------------------- 
    // FIFO empty when the next rptr == synchronized wptr or on reset 
    //--------------------------------------------------------------- 
    assign rempty_val = (rgraynext == rq2_wptr);
    assign arempty_val = (rgraynextm1 == rq2_wptr);
    
    always @ (posedge rclk or negedge rrst_n) begin

        if (!rrst_n) begin
            arempty <= 1'b0;
            rempty <= 1'b1;
        end
        else begin
            arempty <= arempty_val;
            rempty <= rempty_val;
        end

    end

endmodule

`resetall
