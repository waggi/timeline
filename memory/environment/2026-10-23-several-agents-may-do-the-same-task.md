# Several agents may work on the same task in parallel; only one PR is merged

- Type: environment
- Date: 2026-10-23
- Source: PR #7 (claude/events) and PR #8 (codex/events)
- Status: active

## What
The owner can give the same task to several agents at once. "Add manual
event entry" was built twice: PR #7 by Claude Code and PR #8 by Codex/Junie.
PR #8 was merged; PR #7 is still open and now conflicts with `main`.

## Why
The owner compares the results and merges the one she prefers. The other
PRs are not closed automatically.

## How to apply
Before starting, check `gh pr list` for open PRs on the same topic and
mention them in your PR. Don't build on code from an unmerged competing PR;
only `main` counts. Memory entries are one file each so parallel lanes
don't conflict.
