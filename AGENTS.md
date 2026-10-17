# Agent guidance

This repository contains synthesizable Verilog RTL for asynchronous FIFOs. Follow
the existing module boundaries and coding style, and read
[`docs/coding-guidelines.rst`](docs/coding-guidelines.rst) before changing RTL.

## Before changing anything

- Inspect `git status` and the relevant RTL, tests, and documentation first.
- Treat existing modifications and untracked files as user work. Do not overwrite,
  discard, or reformat unrelated changes.
- Confirm which top level is in scope: `async_fifo`, `async_bidir_fifo`, or
  `async_bidir_ramif_fifo`.
- If the request is ambiguous or an interface/behavior change is needed, state
  the assumption or ask before expanding scope.

## Design facts to preserve

- FIFO storage depth is `2**ASIZE` words, not an arbitrary byte depth.
- Binary pointers address the RAM locally; Gray-coded pointers cross clock
  domains through two-stage synchronizers.
- Reset is active-low. Both sides must be reset before normal operation.
- Internal-memory FIFO variants use a fixed first-word-fall-through read path:
  `rdata` presents the head word while `rempty` is deasserted. The external-RAM
  wrapper's read timing depends on the attached RAM.
- The Yosys flow is logical synthesis; it does not establish physical CDC bus
  skew or routing constraints.
- Do not assume the bidirectional wrappers have the same enable/full protection
  as `async_fifo`. Inspect the selected wrapper and its RAM interface carefully.

## Change workflow

1. For non-trivial requests, make a short plan identifying affected top levels,
   pointer/CDC implications, and tests before editing.
2. Make the smallest coherent RTL, test, and documentation change. Preserve
   public ports and parameter behavior unless the request explicitly changes
   them.
3. Run the relevant checks when tools are available. Report exact commands,
   pass/fail status, and any unavailable tools. Do not claim simulation or
   synthesis passed based only on inspection.
4. Review the final diff for unintended changes and report remaining risks.
5. Do not commit, push, or modify generated artifacts unless explicitly asked.

Useful OpenCode commands are documented in
[`docs/agent-workflow.md`](docs/agent-workflow.md): `/rtl-plan`, `/rtl-implement`,
`/rtl-review`, and `/rtl-verify`.
