Asynchronous dual clock FIFO
============================

Overview
--------

This repository stores a verilog description of dual clock FIFO. A FIFO is
a convinient circuit to exchange data between two clock domains. It manages 
the RAM addressing internally, the clock domain crossing and informs the user 
of the FIFO fillness with "full" and "empty" flags.

It is widely inspired by the excellent article from Clifford Cummings,
`Simulation and Synthesis Techniques for Asynchronous FIFO Design 
<http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf>`_

The simulation available use Icarus Verilog and `SVUT <https://github.com/ThotIP/svut>`_
tool to run the test

Documentation
-------------

A full documentation of this IP, its architecture and the test plan
can be found in the doc folder. A release note is also available tracking the 
updates and the known issues.

* `specification <doc/specification.rst>`_
* `architecture <doc/architecture.rst>`_
* `testplan <doc/testplan.rst>`_
* `release note <doc/release.rst>`_

