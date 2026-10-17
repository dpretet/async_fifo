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
* `async_bidir_fifo_random_unit_test.sv` runs an A-to-B phase followed by a
  B-to-A phase. LFSRs vary the active writer and reader enables; per-direction
  counters check accepted data ordering. The inactive direction's enables stay
  low, while requests may still occur at full/empty and are counted only when
  accepted.
* `async_bidir_ramif_fifo_random_unit_test.sv` runs the same traffic and
  scoreboarding against the external-RAM top, using a behavioral dual-port RAM
  model with combinational reads.

The randomized suites run with write/read clock half-period settings of 1/2,
2/1, and 4/4 ns (full periods of 2/4, 4/2, and 8/8 ns). The suites default to
`DSIZE=32` and `ASIZE=4` and exercise the fixed first-word-fall-through read
behavior.
