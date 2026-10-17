---
name: Git Commit
description: Format async FIFO commit messages using the repository's title and body conventions
---

Use this format for a commit message:

```text
New | Fix | Change: This is the title

This is the body of the comment.
```

Choose one title prefix:

- `New`: a new feature, script, flow, or tool added to the repository.
- `Fix`: a bug fix.
- `Change`: a change that is neither a new feature nor a bug fix.

Keep each body line under 100 characters and split longer lines for readability.
Do not stage files. Before creating a commit, show the exact message and staged
changes and get the user's explicit confirmation. Never amend or push unless the
user separately asks for that action.
