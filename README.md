# Asynchronous dual clock FIFO

![CI](https://github.com/dpretet/async_fifo/actions/workflows/ci.yaml/badge.svg?branch=master)
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

The FIFO is fully functional and used in many successful projects.

# Usage

RTL sources are present in RTL folder under three flavors:
- `rtl/async_fifo.v`: a basic asynchronous dual-clock FIFO
- `rtl/async_bidir_fifo.v`: two instance of the first one into a single top level for full-duplex channel
- `rtl/async_bidir_ramif_fifo.v`: same than previous but with external RAM

The three FIFOs have a list file to get the associated fileset.

The testbench in `sim/` provides an example about the instance and the configuration.

All three top levels have the same parameters:
- `DSIZE`: the size in bits of the datapath
- `ASIZE`: the size in bits of the internal RAM address bus. This implies the FIFO can be configured only with power of 2 depth
- `FALLTHROUGH`: allow to reduce the inner latency and propagate faster the data through the FIFO

# CDC Bus-Coherence Constraints

**⚠️ CRITICAL: This section must be understood before production use. Failure to apply these constraints can result in data corruption that is undetectable in simulation.**

## Overview

The read and write pointers cross clock domains as Gray-coded buses. Gray coding ensures that only one bit changes between consecutive pointer values, but it does **not** guarantee physical bus coherence. If routing delay or bit-to-bit skew is excessive, the first destination synchronizer register can observe bits from different source-pointer transitions.

The implementation must therefore constrain both the maximum datapath delay and the skew between pointer bits. These constraints are **mandatory** for correct operation in hardware—simulation alone cannot validate them because simulation does not model routing delays or bit-to-bit skew.

## Constraint Principles

Apply constraints from the source-domain Gray pointer registers to the **first register stage only** of the corresponding destination-domain synchronizer:

- `wptr` (write domain) → `rq1_wptr` or `sync_w2r/sync_pipe_reg[0]` (read domain)
- `rptr` (read domain) → `wq1_rptr` or `sync_r2w/sync_pipe_reg[0]` (write domain)

**Do NOT apply constraints through subsequent synchronizer stages.** A conservative constraint limit is no greater than the **shorter of the source and destination clock periods**.

## FPGA Implementation (AMD Vivado/Xilinx)

For FPGA designs, use Vivado's constraint commands in your XDC file. The exact hierarchy and post-synthesis register names depend on your enclosing design and synthesis settings. **Always verify the register names post-synthesis before using them in a project.**

### Example: 4 ns Write Clock, 6 ns Read Clock

```tcl
create_clock -name wclk -period 4.000 [get_ports wclk]
create_clock -name rclk -period 6.000 [get_ports rclk]

# Source-domain Gray-pointer registers
set wptr_src [get_cells -hierarchical -regexp {.*wptr_full/wptr_reg\[[0-9]+\]}]
set rptr_src [get_cells -hierarchical -regexp {.*rptr_empty/rptr_reg\[[0-9]+\]}]

# First destination-domain synchronizer registers only
set wptr_sync0 [get_cells -hierarchical -regexp {.*sync_w2r/sync_pipe_reg\[0\]\[[0-9]+\]}]
set rptr_sync0 [get_cells -hierarchical -regexp {.*sync_r2w/sync_pipe_reg\[0\]\[[0-9]+\]}]

# Four nanoseconds is the shorter clock period in this example
set cdc_coherence_ns 4.000

# Limit bit-to-bit arrival skew across each Gray-coded pointer bus
set_bus_skew -from $wptr_src -to $wptr_sync0 $cdc_coherence_ns
set_bus_skew -from $rptr_src -to $rptr_sync0 $cdc_coherence_ns

# Prevent the corresponding CDC paths from being placed excessively far apart
set_max_delay -datapath_only \
    -from $wptr_src \
    -to $wptr_sync0 \
    $cdc_coherence_ns

set_max_delay -datapath_only \
    -from $rptr_src \
    -to $rptr_sync0 \
    $cdc_coherence_ns

# Each collection should contain ASIZE+1 registers
puts "wptr CDC width: [llength $wptr_src] -> [llength $wptr_sync0]"
puts "rptr CDC width: [llength $rptr_src] -> [llength $rptr_sync0]"

# Verify constraints are active
report_cdc -details
report_bus_skew
```

### Critical Notes for FPGA

- `set_bus_skew` is a timing assertion and can coexist with CDC timing exceptions
- A blanket `set_clock_groups -asynchronous` can override `set_max_delay -datapath_only` and must be avoided for Gray-pointer paths
- If maximum-delay constraints are used for Gray-pointer CDC paths, verify they remain active in timing reports
- Use **targeted timing exceptions** for other asynchronous paths instead of unintentionally disabling pointer constraints
- Reference: AMD Vivado [About Bus Skew Constraints](https://docs.amd.com/r/en-US/ug903-vivado-using-constraints/About-Bus-Skew-Constraints) and [Constraining Asynchronous Signals](https://docs.amd.com/r/en-US/ug903-vivado-using-constraints/Constraining-Asynchronous-Signals)

## ASIC Implementation (Cadence, Synopsys, etc.)

For ASIC designs, equivalent CDC constraints must be applied during Static Timing Analysis (STA), typically in the post-layout phase. Unlike FPGA, ASIC constraints cannot be modified post-tapeout, so layout planning is critical.

### General ASIC Constraints

Apply the following to your STA tool (Primetime, QuestaSim, etc.):

1. **Maximum Propagation Delay** from source Gray pointers to first sync stage:
   - Constraint value: ≤ shorter clock period (e.g., 4 ns in the example above)
   - This ensures all bits of the pointer arrive within one clock cycle

2. **Bus Skew / Inter-bit Arrival Time** on Gray-pointer paths:
   - Constraint value: ≤ shorter clock period
   - This prevents any bit from arriving more than one clock cycle ahead of others

3. **Avoid Blanket Asynchronous Exceptions** on these paths:
   - Do **NOT** use `set_case_analysis`, `set_disable_timing`, or global async clock groups that would disable timing checks on CDC pointer paths
   - CDC pointers are **not** true asynchronous paths—they are carefully synchronized paths

### Example STA Directives (Tool-Dependent Syntax)

```tcl
# Synopsys Primetime example (adjust syntax for your EDA tool)

# Define source and destination registers (verify post-synthesis)
set wptr_src [all_registers -filter "name =~ */wptr_full/wptr_reg*"]
set rptr_src [all_registers -filter "name =~ */rptr_empty/rptr_reg*"]
set wptr_sync0 [all_registers -filter "name =~ */sync_w2r/sync_pipe_reg\[0\]*"]
set rptr_sync0 [all_registers -filter "name =~ */sync_r2w/sync_pipe_reg\[0\]*"]

set cdc_period 4.0

# Constrain maximum delay on CDC pointer paths
set_max_delay $cdc_period -from $wptr_src -to $wptr_sync0
set_max_delay $cdc_period -from $rptr_src -to $rptr_sync0

# Constrain bus skew (tool-specific; some tools use set_bus_skew, others use timing windows)
# Example for tools supporting skew constraints:
# set_bus_skew -from $wptr_src -to $wptr_sync0 $cdc_period
# set_bus_skew -from $rptr_src -to $rptr_sync0 $cdc_period
```

### Layout Considerations for ASIC

- **Route pointer bits in close proximity** to minimize bit-to-bit skew
- **Minimize total routing distance** from source to first sync stage
- **Use matched-delay routing** if available in your design kit
- **Verify in post-layout STA**—constraints checked pre-layout are insufficient; final verification must occur after place-and-route
- **Document any violations**—if the layout cannot meet these constraints, the FIFO configuration (e.g., clock periods, ASIZE) may need adjustment

### Debugging ASIC CDC Issues

- Run `report_timing` on CDC paths and verify skew is within specification
- Generate CDC reports if available in your STA tool
- Compare post-layout results to post-synthesis predictions—if significantly worse, investigate routing congestion or tool settings

## General CDC Validation

Regardless of FPGA or ASIC implementation:

1. **Simulation is not sufficient** for CDC validation—routing delays and skew are not modeled
2. **Post-synthesis timing analysis (FPGA)** or **post-layout STA (ASIC)** is mandatory
3. **Report generation** (Vivado `report_cdc`, Primetime `report_timing`) must show constraints are active and met
4. **Constraint verification** should be part of your design review checklist
5. **Timing closure** on CDC paths is a critical success metric; budget time for iterations if initial placement/routing is poor

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
SOFTWARE.
