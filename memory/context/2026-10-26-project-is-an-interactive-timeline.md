# The project is an interactive timeline of events, built by AI agents

- Type: context
- Date: 2026-10-26
- Source: commit 3924d47, PR #6, PR #8
- Status: active

## What
A Rails app that shows events on an interactive timeline. Events come from
manual entry (done in PR #8) and, later, from a crawler that collects events
from a blog. The `source` column also allows `file`, for a future file import.
The repo started on 2026-10-21 as a fresh `rails new` app ("Initial Rails
app", commit 3924d47). Since then the code is written by AI agents (Claude
Code, Codex, Junie) in separate lanes, and the owner reviews and merges.

## Why
Knowing the goal and that several agents work on it explains why the rules
in `AGENTS.md` and this shared memory exist: no agent sees what the others
learned unless it is written down in git.

## How to apply
Keep features in line with the timeline goal; check `memory/decisions/`
before changing how events are stored or imported. The blog crawler does
not exist yet: ask the owner which blog before building it.
