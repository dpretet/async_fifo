Specification
=============

This document lists all the features the FIFO supports

* The module is a full synchronized module, working on clock rising edge.

* It can be put under reset on both sides. For proper behavior, both side
  have to be reset at the same time before any data transmission/reception.

* It can be synthetized either for Xilinx and Altera FPGAs.

* It supports built-in RAM of the FPGAs, used by inference. This
  ensures an easy way to include the module in a design, regardless
  the FPGA family.

* It can be configured for any data bus width, specified in bits.

* Its depth can be configured in bytes.

    * If the FIFO depth is not modulo the datapath, the real FIFO
      depth infered is round up to the next datapath width.
      For instance, if the datapath width is 16 bytes and the depth
      specified being 20 bytes, the effective FIFO size will be 32 bytes

    * If the depth is modulo the datapath, the specified depth
      will be the effective depth

* The FIFO handles for the user all the RAM addressing.

* The FIFO is composed by two asynchronous sides

    * Write side uses:

       * A write enable control (wren), enabling the data recording. This control
         increments the write pointer to point the next RAM address to write.

            * wren doesn't have to be asserted when "full" flag is asserted. The word
              passed to the write side will be losted.

            * wren can be asserted continuously, or occasionally.

        * A full flag, asserted when the FIFO is full. The flag is  asserted
          on the next clock cycle the last available word has been written.

        * A data bus, passing the information to store.

    * Read side uses:

        * A read enable control (rden), enabling the data read. This control increments
          the read pointer to address the next word to read.

            * rden doesn't have to be asserted when empty flag is enabled. If asserted,
              the data under read can be a valid data.

            * rden can be asserted continuously, or occasionally.

        * An empty flag, asserted when the FIFO is empty. The flag is asserted on the
          next clock cycle last available word has been read.

        * A data bus, receiving the information to read.

