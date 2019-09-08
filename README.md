Asynchronous dual clock FIFO
============================

[![GitHub issues](https://img.shields.io/github/issues/damofthemoon/async_fifo)](https://github.com/damofthemoon/async_fifo/issues)
[![GitHub forks](https://img.shields.io/github/forks/damofthemoon/async_fifo)](https://github.com/damofthemoon/async_fifo/network)
[![GitHub stars](https://img.shields.io/github/stars/damofthemoon/async_fifo)](https://github.com/damofthemoon/async_fifo/stargazers)
[![GitHub license](https://img.shields.io/github/license/damofthemoon/async_fifo)](https://github.com/damofthemoon/async_fifo/blob/master/LICENSE)
[![Twitter](https://img.shields.io/twitter/url/https/github.com/damofthemoon/async_fifo?style=social)](https://twitter.com/intent/tweet?text=Wow:&url=https%3A%2F%2Fgithub.com%2Fdamofthemoon%2Fasync_fifo)

Overview
--------

This repository stores a verilog description of dual clock FIFO. A FIFO is
a convenient circuit to exchange data between two clock domains. It manages
the RAM addressing internally, the clock domain crossing and informs the user
of the FIFO fillness with "full" and "empty" flags.

It is widely inspired by the excellent article from Clifford Cummings,
`Simulation and Synthesis Techniques for Asynchronous FIFO Design
<http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf>`_

The simulation testcases available use `Icarus Verilog <http://iverilog.icarus.com>`_
and `SVUT <https://github.com/ThotIP/svut>`_ tool to run the tests.

Documentation
-------------

* [specification](doc/specification.rst)
* [testplan](doc/testplan.rst)

