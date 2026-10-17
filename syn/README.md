# Synthesis

## Overview

This directory contains a Yosys-based logical synthesis flow for the
`async_fifo` top level. It synthesizes the RTL using the default parameters
(`DSIZE=8`, `ASIZE=4`, `FALLTHROUGH="TRUE"`), maps sequential cells and
combinational logic against the included `cmos.lib`, and writes the generated
netlist to `syn/async_fifo_syn.v`.

### Running synthesis

Install Yosys and make sure `yosys` is available on `PATH`. From the repository
root, run:

```sh
./flow.sh syn
```

Alternatively, run the synthesis script from this directory:

```sh
cd syn
./syn_asic.sh
```

The script accepts an optional Yosys script path relative to `syn/`, for
example `./syn_asic.sh ./fifo.ys`. The flow reads the RTL listed in `fifo.ys`,
runs `synth -top async_fifo`, maps flip-flops and logic using `cmos.lib`, then
emits the Verilog netlist. The generated netlist is a build artifact and is not
the RTL source of record.

This is a logical synthesis and technology-mapping flow only. It does not run
static timing analysis, place and route, or apply the example CDC constraints
below. Use the target FPGA/ASIC implementation flow to apply and validate
device-specific timing and CDC constraints. The current script synthesizes only
the `async_fifo` top level with its default parameters; the bidirectional
wrappers are not included in this synthesis script.

## CDC bus-coherence constraints

The read and write pointers cross clock domains as Gray-coded buses. Gray coding
ensures that only one bit changes between consecutive pointer values, but it does
not by itself guarantee physical bus coherence. If routing delay or bit-to-bit
skew is excessive, the first destination synchronizer stage can observe bits
from different source-pointer transitions. The implementation must therefore
constrain both the maximum datapath delay and the skew between pointer bits.

Apply these constraints from the source-domain Gray pointer registers to the
first register in the destination-domain synchronizer. In this RTL, the write
pointer crosses into `sync_w2r.rq1_wptr`, and the read pointer crosses into
`sync_r2w.wq1_rptr`. Do not apply the constraints through the second
synchronizer stage. A conservative bound is no greater than the shorter of the
source and destination clock periods. The exact hierarchy and post-synthesis
register names depend on the enclosing design, so verify every collection
before using it in a project XDC.

For example, given a 4 ns write clock and a 6 ns read clock, the following
illustrates the intended Vivado constraints:

```tcl
create_clock -name wclk -period 4.000 [get_ports wclk]
create_clock -name rclk -period 6.000 [get_ports rclk]

# Source Gray-pointer registers.
set wptr_src [get_cells -hierarchical -regexp {.*wptr_full/wptr_reg\[[0-9]+\]}]
set rptr_src [get_cells -hierarchical -regexp {.*rptr_empty/rptr_reg\[[0-9]+\]}]

# First-stage synchronizer registers in this RTL are rq1_wptr and wq1_rptr.
set wptr_sync0 [get_cells -hierarchical -regexp {.*sync_w2r/rq1_wptr_reg\[[0-9]+\]}]
set rptr_sync0 [get_cells -hierarchical -regexp {.*sync_r2w/wq1_rptr_reg\[[0-9]+\]}]

# Four nanoseconds is the shorter clock period in this example.
set cdc_coherence_ns 4.000

set_bus_skew -from $wptr_src -to $wptr_sync0 $cdc_coherence_ns
set_bus_skew -from $rptr_src -to $rptr_sync0 $cdc_coherence_ns

set_max_delay -datapath_only -from $wptr_src -to $wptr_sync0 $cdc_coherence_ns
set_max_delay -datapath_only -from $rptr_src -to $rptr_sync0 $cdc_coherence_ns

# Confirm that each collection contains ASIZE+1 registers and inspect results.
puts "wptr CDC width: [llength $wptr_src] -> [llength $wptr_sync0]"
puts "rptr CDC width: [llength $rptr_src] -> [llength $rptr_sync0]"
report_cdc -details
report_bus_skew
```

`set_bus_skew` is a timing assertion and can coexist with CDC timing
exceptions. A blanket `set_clock_groups -asynchronous`, however, can override
`set_max_delay -datapath_only`. If maximum-delay constraints are used for these
pointer paths, ensure they remain active and use targeted exceptions for other
asynchronous paths instead of unintentionally disabling them. See AMD Vivado
[About Bus Skew Constraints](https://docs.amd.com/r/en-US/ug903-vivado-using-constraints/About-Bus-Skew-Constraints)
and [Constraining Asynchronous Signals](https://docs.amd.com/r/en-US/ug903-vivado-using-constraints/Constraining-Asynchronous-Signals).
