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

module fifomem_dp

    #(
    parameter  DATASIZE     = 8,      // Memory data word width
    parameter  ADDRSIZE     = 4,      // Number of mem address bits
    parameter  FALLTHROUGH  = "TRUE"  // First word fall-through
    ) (
    input wire                a_clk,
    input wire [DATASIZE-1:0] a_wdata,
    output reg [DATASIZE-1:0] a_rdata,
    input wire [ADDRSIZE-1:0] a_addr,
    input wire                a_rinc,
    input wire                a_winc,

    input wire                b_clk,
    input wire [DATASIZE-1:0] b_wdata,
    output reg [DATASIZE-1:0] b_rdata,
    input wire [ADDRSIZE-1:0] b_addr,
    input wire                b_rinc,
    input wire                b_winc
    );

generate
  begin : dpram

    localparam DEPTH = 1<<ADDRSIZE;
    reg [DATASIZE-1:0] mem [0:DEPTH-1];

  if (FALLTHROUGH == "TRUE")
    begin : fallthrough

      always @(posedge a_clk)
        if (a_winc)
          mem[a_addr] <= a_wdata;

      always @*
        a_rdata  = mem[a_addr];

      always @(posedge b_clk)
        if (b_winc)
          mem[b_addr] <= b_wdata;

      always @*
        b_rdata  = mem[b_addr];

    end // block: fallthrough
  else
    begin : registered

      wire a_en = a_rinc | a_winc;

      always @(posedge a_clk)
        if (a_en)
          begin
            if (a_winc)
              mem[a_addr] <= a_wdata;
            a_rdata <= mem[a_addr];
          end

      wire b_en = b_rinc | b_winc;

      always @(posedge b_clk)
        if (b_en)
          begin
            if (b_winc)
              mem[b_addr] <= b_wdata;
            b_rdata <= mem[b_addr];
          end
    end // block: registered
  end // block: dpram
endgenerate


endmodule

`resetall
