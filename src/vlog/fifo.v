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

module fifo
    #(
    parameter DSIZE = 8,
    parameter ASIZE = 4
    )(
    input  [DSIZE-1:0] wdata,
    input winc, wclk, wrst_n,
    input rinc, rclk, rrst_n,
    output [DSIZE-1:0] rdata,
    output             wfull,
    output             rempty
    );

    wire   [ASIZE-1:0] waddr, raddr;
    wire   [ASIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;
    
    sync_r2w sync_r2w (
    .wq2_rptr   (wq2_rptr), 
    .rptr       (rptr),
    .wclk       (wclk),
    .wrst_n     (wrst_n)
    );
    
    sync_w2r sync_w2r (
    .rq2_wptr   (rq2_wptr),
    .wptr       (wptr),
    .rclk       (rclk),
    .rrst_n     (rrst_n)
    );

    fifomem 
    #(DSIZE, ASIZE) 
    fifomem (
    .rdata  (rdata),
    .wdata  (wdata),
    .waddr  (waddr), 
    .raddr  (raddr),
    .wclken (winc),
    .wfull  (wfull),
    .wclk   (wclk)
    );

    rptr_empty 
    #(ASIZE) 
    rptr_empty (
    .rempty     (rempty),
    .raddr      (raddr),
    .rptr       (rptr), 
    .rq2_wptr   (rq2_wptr), 
    .rinc       (rinc), 
    .rclk       (rclk), 
    .rrst_n     (rrst_n)
    );


    wptr_full  
    #(ASIZE) 
    wptr_full (
    .wfull      (wfull), 
    .waddr      (waddr),
    .wptr       (wptr), 
    .wq2_rptr   (wq2_rptr),
    .winc       (winc),
    .wclk       (wclk),
    .wrst_n     (wrst_n)
    );

endmodule

`resetall


