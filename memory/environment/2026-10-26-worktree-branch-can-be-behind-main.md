# An agent's worktree branch can be behind main: branch from a fresh origin/main

- Type: environment
- Date: 2026-10-26
- Source: observed while creating the shared-memory PR
- Status: active

## What
Agents on the owner's Mac work in git worktrees under
`~/.air/worktrees/temporary/timeline-<name>`, on a branch like
`air/main-<name>`. That branch is created from the local `main` when the
lane starts and was missing PR #8, which was already merged on GitHub. The
git stash is shared between all worktrees.

## Why
The local `main` is not updated automatically when PRs are merged on GitHub.

## How to apply
Start every task with `git fetch origin` and
`git checkout -b <task-branch> origin/main`. Don't use a bare `git stash`
or `git stash pop`; use a temporary commit instead.
