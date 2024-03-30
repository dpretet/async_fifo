# Asynchronous dual clock FIFO

![CI](https://github.com/dpretet/async_fifo/actions/workflows/ci.yaml/badge.svg?branch=master)
[![GitHub issues](https://img.shields.io/github/issues/dpretet/async_fifo)](https://github.com/dpretet/async_fifo/issues)
[![GitHub forks](https://img.shields.io/github/forks/dpretet/async_fifo)](https://github.com/dpretet/async_fifo/network)
[![GitHub stars](https://img.shields.io/github/stars/dpretet/async_fifo)](https://github.com/dpretet/async_fifo/stargazers)
[![GitHub license](https://img.shields.io/github/license/dpretet/async_fifo)](https://github.com/dpretet/async_fifo/blob/master/LICENSE)

# Overview

This repository stores a verilog description of dual clock FIFO. A FIFO is
a convenient circuit to exchange data between two clock domains. It manages
the RAM addressing internally, the clock domain crossing and informs the user
of the FIFO fillness with "full" and "empty" flags.

It is widely inspired by the excellent article from Clifford Cummings,
[Simulation and Synthesis Techniques for Asynchronous FIFO
Design](http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf).

The simulation testcases available use [Icarus Verilog](http://iverilog.icarus.com) and [SVUT](https://github.com/dpretet/svut) tool to run the tests.

The FIFO is fully functional and used in many successful projects.

# Usage

RTL sources are present in RTL folder under three flavors:
- `rtl/async_fifo.v`: a basic asynchronous dual-clock FIFO
- `rtl/async_bidir_fifo.v`: two instance of the first one into a single top level for full-duplex channel
- `rtl/async_bidir_ramif_fifo.v`: same than previous but with external RAM

The three FIFOs have a list file to get the associated fileset.

The testbench in `sim/` provides an example about the instance and the configuration.

All three top levels have the same parameters:
- `DSIZE`: the size in bits of the datapath
- `ASIZE`: the size in bits of the internal RAM address bus. This implies the FIFO can be configured only with power of 2 depth
- `FALLTHROUGH`: allow to reduce the inner latency and propagate faster the data through the FIFO


# License

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. imitations under the License.
