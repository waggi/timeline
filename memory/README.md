# Shared memory

This folder is the project's shared memory: what agents and the owner learned
while building the timeline that is **not** obvious from the code or
`AGENTS.md`. Why things are the way they are, traps we already fell into, and
how the sandboxes, CI and tokens behave. It lives in git, so every agent in
every sandbox, branch or chat sees the same memory.

| Folder | Holds | Example |
| --- | --- | --- |
| `decisions/` | A choice and its reason | "Event source is set by the importer, never by the user" |
| `lessons/` | A trap: symptom, cause, fix | "Gemfile.lock made on a Mac needs the Linux platforms, or CI can't install gems" |
| `environment/` | How the tooling around the code works (sandboxes, CI, tokens) | "An agent's worktree branch can be behind main: branch from a fresh origin/main" |
| `context/` | About the project and the people | "The owner is not a developer" |

One entry per file: `memory/<folder>/<YYYY-MM-DD>-<short-slug>.md`.

List all entries (one title per entry):

```sh
grep -h -m1 '^# ' memory/*/*.md
```

How to read and write entries: the skill
[`.agents/skills/shared-memory/SKILL.md`](../.agents/skills/shared-memory/SKILL.md).
`test/memory_test.rb` checks the format.
