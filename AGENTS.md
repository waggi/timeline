# AGENTS.md

Instructions for AI agents working on this project.

## Project

Rails application for an interactive timeline of events. Events will come from two sources:

- manual entry by users;
- a crawler that collects events from a blog.

Manual entry exists (the `Event` model and pages); the crawler is not implemented yet.

## Shared memory

`memory/` holds what earlier agents and the owner learned: decisions and their reasons, traps, and how the sandboxes, CI and tokens behave. Use the skill `.agents/skills/shared-memory/SKILL.md` for both steps below.

- **ALWAYS read `memory/` before a task.** List the entries with `grep -h -m1 '^# ' memory/*/*.md`, read every entry related to the task, and always read `memory/context/`.
- **ALWAYS update shared memory with the skill at the end of a task**, in the same pull request: record new decisions, lessons and environment facts. If there is nothing new, say so in the PR description ("memory: nothing new").
- If memory contradicts the code or the spec, the code and spec win: tell the owner and fix the entry.

## Stack

- Ruby 4.0.7 (`.ruby-version`), Bundler 4.0.23
- Rails 8.1.4
- SQLite 3 (`storage/*.sqlite3`); Solid Cache, Solid Queue, Solid Cable
- Puma, Propshaft, Importmap, Hotwire (Turbo + Stimulus), Jbuilder
- Tests: Minitest, Capybara + Selenium for system tests
- Lint/security: RuboCop (rails-omakase), Brakeman, bundler-audit, `importmap audit`
- Deploy: Kamal, Docker, Thruster

## Commands

```sh
bin/setup                 # install gems, prepare DB, start server
bin/setup --skip-server   # same, without starting the server
bin/dev                   # start the dev server (http://localhost:3000)

bin/rails test            # unit/integration tests
bin/rails test:system     # system tests (needs Chrome)
bin/rails test test/models/foo_test.rb:12   # single test

bin/rubocop               # lint (bin/rubocop -a to autocorrect)
bin/brakeman --no-pager   # security static analysis
bin/bundler-audit         # gem vulnerability audit
bin/importmap audit       # JS dependency audit

bin/ci                    # run all of the above locally (see config/ci.rb)
```

GitHub Actions (`.github/workflows/ci.yml`) runs the same checks plus system tests on every PR.

## Workflow rules

- Do every task in its own branch created from an up-to-date `main`.
- Never push to `main` directly — it is protected. All changes go through PRs.
- Before opening a PR, run `bin/ci` and make sure every step is green. Fix failures; do not skip or disable checks.
- Open PRs with `gh pr create`.

## Tests

- Every piece of new code must have tests: models, controllers/requests, jobs, services (e.g. the crawler), and system tests for user-facing flows.
- Bug fixes come with a test that reproduces the bug.
- Put tests in the matching directory under `test/`; use fixtures in `test/fixtures/`.
- Tests must not hit the network — stub external HTTP calls (e.g. the blog crawler).

## Definition of Done

- The work is on its own branch from an up-to-date `main`, in one PR opened with `gh pr create`.
- New code has tests; bug fixes have a test that reproduces the bug.
- `bin/ci` is green locally, and CI is green for the pushed branch.
- The PR description fills in every section of `.github/pull_request_template.md`.
- memory/ updated with the shared-memory skill (or 'memory: nothing new' in the PR).
