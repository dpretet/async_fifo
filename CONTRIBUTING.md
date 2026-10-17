# Contributing

Thanks for helping improve the asynchronous FIFO IP. Before proposing an RTL
change, read [`docs/coding-guidelines.rst`](docs/coding-guidelines.rst) and the
relevant module documentation. OpenCode users can follow
[`docs/agent-workflow.md`](docs/agent-workflow.md) for the project commands.

## Bug reports and support

Please include, where applicable:

* the affected top level and parameter values (`DSIZE`, `ASIZE`, and
  `FALLTHROUGH`);
* write/read clock periods and phase relationship;
* reset sequence and relevant write/read enables;
* expected and observed behavior, with a minimal reproducible test;
* simulator/synthesis tool versions and the exact command/output.

Please remove confidential design information and credentials from logs.

## Pull requests

* Explain the behavior being changed and why.
* Include or update self-checking tests for functional changes.
* Update documentation when interface, parameter, latency, flag, or reset
  behavior changes.
* Run the relevant repository checks and include exact commands and results.
  Distinguish unavailable checks from passing checks; inspect `lint.log` because
  the lint wrapper tolerates a single Verilator `%Error:` summary line, which
  can occur when warnings are treated as fatal. Report relevant warnings; a
  successful wrapper result does not mean the lint was warning-free.
* Keep unrelated formatting and generated files out of the change.

RTL simulation and logical synthesis do not constitute physical CDC signoff.
Implementation-specific timing/skew constraints must be checked in the target
FPGA/ASIC implementation flow.
