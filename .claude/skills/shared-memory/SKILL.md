---
name: shared-memory
description: Read and maintain the project's shared memory in memory/. Use at the start of every task to load what earlier agents and the human already learned, and at the end of every task to record new decisions, lessons and environment facts. Also use whenever you discover something a future agent would otherwise have to rediscover the hard way.
---

# Shared memory

`memory/` holds what we learned while building this project that is **not**
obvious from the code, `spec/` or `AGENTS.md`: why things are the way they are,
traps we already fell into, and facts about the environment (sandboxes, CI,
tokens). It is shared between all agents and sandboxes through git.

| Folder | Holds | Example |
| --- | --- | --- |
| `memory/decisions/` | A choice and its reason | "Event source is set by the importer, never by the user" |
| `memory/lessons/` | A trap: symptom, cause, fix | "Gemfile.lock made on a Mac needs the Linux platforms, or CI can't install gems" |
| `memory/environment/` | How the tooling around the code works (sandboxes, CI, tokens) | "An agent's worktree branch can be behind main: branch from a fresh origin/main" |
| `memory/context/` | About the project and the people | "The owner is not a developer" |

What goes where: `spec/` says **what** the app does. `AGENTS.md` says **how** to work here.
`memory/` says **why**, and **what we found out**. Don't copy spec or AGENTS.md
into memory; link to them instead.

## Reading (start of every task)

1. List the entries: `grep -h -m1 '^# ' memory/*/*.md` prints one title per entry.
2. Read every entry whose title touches your task. Always read `memory/context/`.
3. Entries with `Status: superseded by ...` are history: follow the pointer.
4. If an entry contradicts the code or the spec, the code and spec win. Tell
   the human, and fix or supersede the entry in your PR.

## Writing (end of every task, same PR as the task)

Write an entry when you:
- made a choice between real alternatives (**decision**);
- hit a problem whose cause was not obvious, so the next agent would hit it too (**lesson**);
- found out how a tool, sandbox, CI or token behaves (**environment**);
- learned a preference or constraint of the human (**context**).

Don't write an entry for:
- anything already stated in `spec/`, `AGENTS.md`, code comments or tests;
- routine work ("added a test for X");
- guesses you haven't confirmed; say "observed once" if unsure, or skip it;
- anything secret: tokens, passwords, keys, personal emails. Never.

### One entry per file

Path: `memory/<folder>/<YYYY-MM-DD>-<short-slug>.md`.
One file per entry means two lanes can add memory in parallel without merge
conflicts. Never collect several entries in one file.

### Format

```markdown
# One-line title that says the point, not the topic

- Type: decision | lesson | environment | context   (must match the folder)
- Date: YYYY-MM-DD
- Source: PR #N, commit abc1234, or "conversation with the owner"
- Status: active | superseded by <file name>

## What
The fact, decision or trap, in two to five sentences.

## Why
The reason, or the cause of the problem.

## How to apply
What a future agent should do (or avoid) because of this.
```

Keep entries short: 10 to 25 lines. A title that states the point beats a topic.

### Updating

- Before writing, search for an existing entry: `grep -ril '<keyword>' memory/`.
- A fact was wrong: fix the entry in place and mention it in the PR.
- A decision changed: write a new entry and set the old one to
  `Status: superseded by <new file name>`. Don't delete it: the history of
  why we changed our mind is useful.

### Checking

`test/memory_test.rb` checks every entry's path, title and fields, and that no
entry looks like it contains a secret. Run `bin/rails test` before you push.
