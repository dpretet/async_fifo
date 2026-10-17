---
description: Run relevant FIFO verification without editing source files
agent: rtl-verifier
subagent: true
---

Verify the current change: $ARGUMENTS

Inspect the worktree, changed files, and affected FIFO top level(s). Run
appropriate existing checks (`./flow.sh lint`, `./flow.sh sim`, and/or
`./flow.sh syn`) when the needed tools are installed. Do not edit source or test
files and do not run cleanup commands. Inspect actual exit statuses and output;
for lint, report relevant warnings from `lint.log` because the wrapper allows a
single Verilator `%Error:` summary line and is not a zero-warning check. Report
exact commands and outcomes, unavailable checks, generated artifacts if any,
and untested risks. RTL checks do not establish physical CDC signoff.
