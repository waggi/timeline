# There is no master.key in sandboxes or CI: don't rely on credentials

- Type: environment
- Date: 2026-10-26
- Source: checked in an agent worktree and in .github/workflows/ci.yml
- Status: active

## What
`config/credentials.yml.enc` is committed, but `config/master.key` is
git-ignored and not present in agent worktrees. CI does not set
`RAILS_MASTER_KEY` (the line in `ci.yml` is commented out).

## Why
The key is a secret and is kept out of git on purpose.

## How to apply
Code and tests must work without `Rails.application.credentials`. If a
feature needs a secret (e.g. an API key for the crawler), ask the owner how
to provide it; never commit the key or paste it into memory or a PR.
