Specification
=============

* The module is a full synchronized module, working on clock rising edge.

* It can be put under reset on both sides. For proper behavior, both sides
  have to be reset at the same time before any usage.

* It can be synthetized either for ASIC or FPGAs.

* The data word width is configured by ``DSIZE`` and is measured in bits.

* The FIFO depth is configured by ``ASIZE``, the number of RAM address bits.
  The depth is exactly ``2**ASIZE`` words; the RTL does not accept an arbitrary
  byte-depth parameter or round a requested depth up to a supported size. The
  total storage capacity is ``DSIZE * 2**ASIZE`` bits.


* Write interface usage:

  * A write enable control (`wren`), enabling the data recording. This control
    increments the write pointer to point the next RAM address to write. `wren`
    doesn't have to be asserted when "full" flag is asserted. The word passed
    to the write side will be losted. `wren` can be asserted continuously, or
    occasionally.

  * A full flag is asserted when the FIFO is full. The flag is asserted on the
    next clock cycle the last available word has been written if no data has
    been read.

* Read interface usage:

  * A read enable control (`rden`), enabling the data read. This control
    increments the read pointer to address the next word to read. `rden`
    doesn't have to be asserted when empty flag is enabled. If asserted, the
    data under read can be a valid data. `rden` can be asserted continuously,
    or occasionally.

  * An empty flag is asserted when the FIFO is empty. The flag is asserted on
    the next clock cycle last available word has been read if no further info
    has been stored.
