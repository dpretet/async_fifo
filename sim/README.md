# Simulation

## Run and clean

From the repository root:

```sh
./sim/run.sh test
./sim/run.sh clean
```

The test command runs the directed suite and three randomized clock
configurations. Combined simulator output is written to `sim/svut.log`; the
script returns a failing status if a simulator command fails or an error marker
appears in the log. `./flow.sh sim` and `./flow.sh clean` provide the same
operations through the repository flow.

The simulation requires Icarus Verilog and SVUT (`svutRun`) on `PATH`.

## Test suites

* `async_fifo_directed_unit_test.sv` checks idle state, single and multiple
  writes/reads, data ordering, full/empty and almost-full/almost-empty flags,
  and concurrent traffic.
* `async_fifo_random_unit_test.sv` uses LFSR-driven write/read enables and
  checks accepted read data against an ordered sequence. Its payload is an
  incrementing sequence, while the LFSRs vary traffic timing. The test stops
  after the configured transfer count or reports a timeout through SVUT.

The randomized suite runs with write/read clock half-period settings of 1/2,
2/1, and 4/4 ns (full periods of 2/4, 4/2, and 8/8 ns). Both suites default to
`DSIZE=32`, `ASIZE=4`, and `FALLTHROUGH="TRUE"`.
