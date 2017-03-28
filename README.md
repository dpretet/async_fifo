# Dual clock FIFO

This repository stores a verilog descrition of dual clock FIFO to use
to exchange data between two clock domains. It manages the RAM management
as the cross clock domain crossing, for a pure dual clock domain as 
a regular IP using hte same clock on each side.

It is widely inspired by the excellent article from Clifford Cummings,
[Simulation and Synthesis Techniques for Asynchronous FIFO Design](http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf)
