# Shared memory lives in git, one file per entry

- Type: decision
- Date: 2026-10-26
- Source: conversation with the owner; PR adding memory/
- Status: active

## What
What agents learn is stored in `memory/` in this repo, one Markdown file per
entry, in four folders (decisions, lessons, environment, context). The rules
are in `.agents/skills/shared-memory/SKILL.md`; `test/memory_test.rb`
enforces the format and blocks obvious secrets.

## Why
Agents run in different sandboxes and chats and don't share any memory
outside git. A wiki or a single notes file would either be invisible to them
or cause merge conflicts when lanes write in parallel.

## How to apply
Read memory at the start of a task and add entries in the same PR as the
work. Don't move memory elsewhere without asking the owner.
