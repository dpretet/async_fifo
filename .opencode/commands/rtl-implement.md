---
description: Implement a scoped FIFO RTL change with matching tests and documentation
agent: build
---

Implement this repository change: $ARGUMENTS

First inspect `git status` and relevant files. Preserve all existing user
changes and do not broaden scope. Follow `AGENTS.md` and
`docs/coding-guidelines.rst`. Make the smallest coherent RTL/test/documentation
change, then run relevant available checks. Inspect actual tool output and
status, especially warnings in `lint.log`. The lint wrapper tolerates one
Verilator `%Error:` summary line, so success does not mean warning-free. Do not
commit, push, or claim physical CDC signoff. Finish with a concise summary of
files changed, behavior, exact checks/results, and remaining risks.
