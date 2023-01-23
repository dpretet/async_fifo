# Asynchronous dual clock FIFO

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

# Documentation

* [specification](doc/specification.rst)
* [testplan](doc/testplan.rst)

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
