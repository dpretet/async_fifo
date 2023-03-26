//-----------------------------------------------------------------------------
// Copyright 2017 Damien Pretet ThotIP
// Copyright 2018 Julius Baxter
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

module async_bidir_fifo

  #(
    parameter DSIZE         = 8,
    parameter ASIZE         = 4,
    parameter FALLTHROUGH   = "TRUE" // First word fall-through
    ) (
       input wire              a_clk,
       input wire              a_rst_n,
       input wire              a_winc,
       input wire [DSIZE-1:0]  a_wdata,
       input wire              a_rinc,
       output wire [DSIZE-1:0] a_rdata,
       output wire             a_full,
       output wire             a_afull,
       output wire             a_empty,
       output wire             a_aempty,
       input wire              a_dir, // dir = 1: this side is writing, dir = 0: this side is reading


       input wire              b_clk,
       input wire              b_rst_n,
       input wire              b_winc,
       input wire [DSIZE-1:0]  b_wdata,
       input wire              b_rinc,
       output wire [DSIZE-1:0] b_rdata,
       output wire             b_full,
       output wire             b_afull,
       output wire             b_empty,
       output wire             b_aempty,
       input wire              b_dir // dir = 1: this side is writing, dir = 0: this side is reading
       );

  wire [ASIZE-1:0]             a_addr, b_addr;
  wire [ASIZE-1:0]             a_waddr, a_raddr, b_waddr, b_raddr;
  wire [  ASIZE:0]             a_wptr, b_rptr, a2b_wptr, b2a_rptr;
  wire [  ASIZE:0]             a_rptr, b_wptr, a2b_rptr, b2a_wptr;

  assign a_addr = a_dir ? a_waddr : a_raddr;
  assign b_addr = b_dir ? b_waddr : b_raddr;

  //////////////////////////////////////////////////////////////////////////////
  // A-side logic
  //////////////////////////////////////////////////////////////////////////////

  // Sync b write pointer to a domain
  sync_ptr #(ASIZE)
  sync_b2a_wptr
    (
     .dest_clk   (a_clk),
     .dest_rst_n (a_rst_n),
     .src_ptr    (b_wptr),
     .dest_ptr   (b2a_wptr)
     );

  // Sync b read pointer to a domain
  sync_ptr #(ASIZE)
  sync_b2a_rptr
    (
     .dest_clk   (a_clk),
     .dest_rst_n (a_rst_n),
     .src_ptr    (b_rptr),
     .dest_ptr   (b2a_rptr)
     );

  // The module handling the write requests
  // outputs valid when dir == 0 (a is writing)
  wptr_full #(ASIZE)
  a_wptr_inst
    (
     .wclk     (a_clk),
     .wrst_n   (a_rst_n),
     .winc     (a_winc),
     .wq2_rptr (b2a_rptr),
     .awfull   (a_afull),
     .wfull    (a_full),
     .waddr    (a_waddr),
     .wptr     (a_wptr)
     );

  // dir == 1 read pointer on a side calculation
  rptr_empty #(ASIZE)
  a_rptr_inst
    (
     .rclk     (a_clk),
     .rrst_n   (a_rst_n),
     .rinc     (a_rinc),
     .rq2_wptr (b2a_wptr),
     .arempty  (a_aempty),
     .rempty   (a_empty),
     .raddr    (a_raddr),
     .rptr     (a_rptr)
     );

  //////////////////////////////////////////////////////////////////////////////
  // B-side logic
  //////////////////////////////////////////////////////////////////////////////

  // Sync a write pointer to b domain
  sync_ptr #(ASIZE)
  sync_a2b_wptr
    (
     .dest_clk   (b_clk),
     .dest_rst_n (b_rst_n),
     .src_ptr    (a_wptr),
     .dest_ptr   (a2b_wptr)
     );

  // Sync a read pointer to b domain
  sync_ptr #(ASIZE)
  sync_a2b_rptr
    (
     .dest_clk   (b_clk),
     .dest_rst_n (b_rst_n),
     .src_ptr    (a_rptr),
     .dest_ptr   (a2b_rptr)
     );

  // The module handling the write requests
  // outputs valid when dir == 0 (b is writing)
  wptr_full #(ASIZE)
  b_wptr_inst
    (
     .wclk     (b_clk),
     .wrst_n   (b_rst_n),
     .winc     (b_winc),
     .wq2_rptr (a2b_rptr),
     .awfull   (b_afull),
     .wfull    (b_full),
     .waddr    (b_waddr),
     .wptr     (b_wptr)
     );

  // dir == 1 read pointer on b side calculation
  rptr_empty #(ASIZE)
  b_rptr_inst
    (
     .rclk     (b_clk),
     .rrst_n   (b_rst_n),
     .rinc     (b_rinc),
     .rq2_wptr (a2b_wptr),
     .arempty  (b_aempty),
     .rempty   (b_empty),
     .raddr    (b_raddr),
     .rptr     (b_rptr)
     );

  //////////////////////////////////////////////////////////////////////////////
  // FIFO RAM
  //////////////////////////////////////////////////////////////////////////////

  fifomem_dp #(DSIZE, ASIZE, FALLTHROUGH)
  fifomem_dp
    (
     .a_clk   (a_clk),
     .a_wdata (a_wdata),
     .a_rdata (a_rdata),
     .a_addr  (a_addr),
     .a_rinc  (a_rinc & !a_dir),
     .a_winc  (a_winc & a_dir),

     .b_clk   (b_clk),
     .b_wdata (b_wdata),
     .b_rdata (b_rdata),
     .b_addr  (b_addr),
     .b_rinc  (b_rinc & !b_dir),
     .b_winc  (b_winc & b_dir)
     );



endmodule

`resetall
