# Skills live in .agents/skills, with an identical copy in .claude/skills

- Type: decision
- Date: 2026-10-26
- Source: PR adding the code-review skill
- Status: active

## What
Agent skills (`shared-memory`, `code-review`) are written in
`.agents/skills/<name>/SKILL.md`, the place `AGENTS.md` points to. Each one
has an identical copy in `.claude/skills/<name>/SKILL.md`.
`test/skills_test.rb` fails if a copy is missing or differs, or if a skill's
`name` doesn't match its folder.

## Why
Codex and Junie read `.agents/`, but Claude Code only finds project skills in
`.claude/skills/`. Plain copies work in every tool and on every OS, where
symlinks might not.

## How to apply
Edit the file in `.agents/skills/` and copy it over:
`cp .agents/skills/<name>/SKILL.md .claude/skills/<name>/SKILL.md`.
Never edit only the `.claude` copy.
