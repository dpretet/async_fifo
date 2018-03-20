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

module fifomem 
    
    #(
    parameter  DATASIZE = 8,    // Memory data word width
    parameter  ADDRSIZE = 4     // Number of mem address bits
    ) (
    input  wire                wclk,
    input  wire                wclken,
    input  wire [ADDRSIZE-1:0] waddr,
    input  wire [DATASIZE-1:0] wdata,
    input  wire                wfull,
    input  wire [ADDRSIZE-1:0] raddr,
    output wire [DATASIZE-1:0] rdata
    );
    
    localparam DEPTH = 1<<ADDRSIZE;
    
    reg [DATASIZE-1:0] mem [0:DEPTH-1];
    
    always @(posedge wclk) begin
        if (wclken && !wfull) 
            mem[waddr] <= wdata;
    end
    
    assign rdata = mem[raddr];

endmodule

`resetall
