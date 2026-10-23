# AGENTS.md

Instructions for AI agents working on this project.

## Project

Rails application for an interactive timeline of events. Events will come from two sources:

- manual entry by users;
- a crawler that collects events from a blog.

Neither is implemented yet — the app is currently a fresh Rails skeleton.

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
