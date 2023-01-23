Specification
=============

* The module is a full synchronized module, working on clock rising edge.

* It can be put under reset on both sides. For proper behavior, both sides
  have to be reset at the same time before any usage.

* It can be synthetized either for ASIC or FPGAs.

* It can be configured for any data bus width, specified in bits.

* Its depth can be configured in bytes.

  * If the FIFO depth is not modulo the datapath, the real FIFO depth infered
    is round up to the next datapath width. For instance, if the datapath width
    is 16 bytes and the depth specified being 20 bytes, the effective FIFO size
    will be 32 bytes

  * If the depth is modulo the datapath, the specified depth will be the
    effective depth


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
