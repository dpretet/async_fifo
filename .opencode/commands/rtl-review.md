---
description: Read-only review of staged and unstaged tracked changes for FIFO RTL issues
agent: rtl-reviewer
subagent: true
---

Review the current repository changes. The following status and tracked diffs
are provided as context; also inspect relevant source, tests, and documentation
by reading repository files. Do not edit files.

Working tree status:
!`git status --short`

Unstaged diff:
!`git --no-pager diff --no-ext-diff --`

Staged diff:
!`git --no-pager diff --no-ext-diff --cached --`

Include untracked files shown in the status by reading them if relevant. Follow
`AGENTS.md` and `docs/coding-guidelines.rst`. Report only actionable findings,
sorted by severity, with file/line references and impact. State residual test
gaps separately; do not modify anything.
