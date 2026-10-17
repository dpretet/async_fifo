# OpenCode workflow for this IP

The repository provides project-local OpenCode commands in `.opencode/commands/`
and specialist agents in `.opencode/agents/`. The reviewer is read-only; the
verifier runs checks without editing source files. They do not select a model or
change global OpenCode configuration; they use the model active in the current
session unless the user has configured one.

## Commands

| Command | Use |
| --- | --- |
| `/rtl-plan <request>` | Inspect the design and propose a scoped RTL/test/documentation plan without editing files. |
| `/rtl-implement <request>` | Implement a scoped change, preserve unrelated work, and run appropriate checks. |
| `/rtl-review` | Review staged and unstaged tracked changes for RTL correctness and regression risks. A read-only reviewer runs as a child session. |
| `/rtl-verify` | Run appropriate available checks without editing source; report exact commands, results, and gaps. |

For a typical contribution: run ``/rtl-plan``, then ``/rtl-implement``; use
``/rtl-review`` and ``/rtl-verify`` before preparing a pull request. The commands
are prompts, not a substitute for engineering review or CI.

## Repository checks

From the repository root:

* ``./flow.sh lint`` runs the Verilator lint flow.
* ``./flow.sh sim`` runs the directed and randomized SVUT/Icarus tests. The
  same test and cleanup commands are available directly as
  ``./sim/run.sh test`` and ``./sim/run.sh clean``.
* ``./flow.sh syn`` runs the Yosys ASIC synthesis script.

Run checks relevant to the change and report tools that are unavailable. The
lint wrapper interprets Verilator's log rather than its exit status: it allows
one ``%Error:`` line (which can be Verilator's summary when warnings are
treated as fatal) and reports failure when there are more. This is a
warning-tolerant policy, not a zero-warning check. Inspect and report relevant
warnings in ``lint.log``. Simulation and synthesis are also limited to the
configured top level and parameters; additional configurations may need
separate runs.

## Handling support and contribution requests

For a bug report, first capture the affected top level, parameters, clock periods
and phase relationship, reset sequence, enables, expected/observed behavior, and
a minimal reproducible test. Ask for tool versions and relevant logs when a
failure depends on simulation, lint, or synthesis. Do not ask contributors to
publish proprietary design data or secrets.

For a proposed change, identify whether it affects the basic FIFO, either
bidirectional wrapper, or all of them. Keep the implementation, self-checking
tests, and documentation aligned. In the final report, summarize behavior
changed, files touched, commands run with their results, and known limitations.
Do not claim physical CDC signoff from RTL simulation or the Yosys flow.
