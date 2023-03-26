Testplan
========

This document describes the faetures to test,
and the general scenarios to put in place to stress
the IP behavior:

Clock frequency relationship
----------------------------

A first focus is put in write vs read frequency relation:

1. Test the same clock frequency on both sides. Phases can be equal or not.

2. Test slower clock on write side
    - clock can be close to read frequency, but slower
    - clock can be very regarding read frequency

3. Test higher clock on write side
    - clock can be close to read frequency, but higher
    - clock can be very high regarding read frequency

Read/Write enable control assertion
-----------------------------------

A second focus is put on read/write enable assertion:

1. Read enable is always enable, unless empty = 1
    - Write enable is always asserted, data are not corrupted
    - Write enable can be occasionaly asserted, data are not corrupted

2. Write enable is always enable, unless full = 1
    - Read enable is always asserted, data are not corrupted
    - Read enable can be occasionaly asserted, data are not corrupted

3. Read and Write enable can be occasionaly asserted
    - Assertion frequency (either read or write) is periodic (1/2, 1/3, 1/2, ...)
    - Assertion frequecy is (pseudo) random

Test coverage
-------------

To ensure a wide feature feature coverage is performed, both clock frequency scale and
read/write enable assertions have to be tested together. Big range over higher frequency
scale factor doesn't have to considered. Only few combinations can be tested for
good confidence on the IP behavior.
