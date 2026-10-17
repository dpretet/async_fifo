RTL coding and review guidelines
================================

These guidelines apply to changes in ``rtl/`` and their corresponding tests.
Keep changes local to the requested behavior and preserve the public interface
unless an interface change is part of the request.

RTL conventions
---------------

* Use synthesizable Verilog consistent with the surrounding files. Preserve
  ``default_nettype none`` / ``resetall`` conventions and explicit widths.
* Keep binary pointers local to their clock domains for RAM addressing. Cross
  clock domains using Gray-coded pointers and the existing two-register
  synchronizer pattern; do not synchronize binary pointers or data buses using
  ad-hoc single-bit synchronizers.
* Keep full logic in the write domain and empty logic in the read domain. Do not
  use a flag generated in one domain as an unsynchronized control in the other.
* Preserve active-low asynchronous reset behavior for pointer and synchronizer
  state. Do not reset the RAM array unless the memory implementation requires
  it and the change is specifically intended.
* Preserve the internal-memory FIFOs' first-word-fall-through read contract:
  ``rdata`` presents the current head word while ``rempty`` is deasserted. The
  external-RAM wrapper's read timing depends on the attached RAM. Consider
  read-during-write behavior, clock enables, and actual write enables when
  changing RAM wrappers.
* ``ASIZE`` represents address bits and implies a depth of ``2**ASIZE`` words.
  The current full-pointer comparison uses the top two Gray bits; review the
  supported minimum ``ASIZE`` when changing pointer equations or parameter
  checks.
* Keep CDC physical constraints separate from generic Yosys logic synthesis.
  Any implementation-specific XDC/SDC must target the actual first
  synchronizer-stage registers and be validated in the target implementation
  tool. Simulation cannot validate metastability or physical bus skew.

Verification expectations
------------------------

For pointer, flag, or RAM changes, consider tests for:

* empty after reset, first write/read, and ordering across pointer wrap;
* filling to full, draining to empty, and attempts to read/write at the limits;
* simultaneous read/write and stalls while preserving the first-word-fall-through
  read contract;
* unrelated clock periods and phases, including faster-write and faster-read
  cases;
* reset behavior on both sides and the documented requirement to reset both
  sides before use;
* the selected bidirectional direction and inactive-side enables, when changing
  either bidirectional wrapper.

Use the existing SVUT testbench and avoid relying only on waveform inspection.
Keep test data/order checks self-checking. If a case is not tested, identify it
as a limitation rather than implying it is covered.

Review checklist
----------------

Before accepting an RTL change, check:

* no unintended port, parameter, latency, or flag-threshold changes;
* pointer updates and memory enables agree, especially at full/empty and in
  direction-selected wrappers;
* CDC paths still use Gray pointers and the intended synchronizer stages;
* reset, nonblocking assignment, width, wraparound, and parameter behavior;
* tests cover the changed behavior and documentation matches the implementation;
* tool output and exit status were checked, including warnings and limitations.

Report review findings with severity, file/line references, impact, and a
concrete reproducing condition where possible. Separate confirmed defects from
questions or assumptions.
