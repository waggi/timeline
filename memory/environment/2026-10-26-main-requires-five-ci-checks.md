# main needs five green CI checks, and even admins can't skip them

- Type: environment
- Date: 2026-10-26
- Source: GitHub branch protection of waggi/timeline (read with gh api)
- Status: active

## What
Branch protection on `main` requires the checks `scan_ruby`, `scan_js`,
`lint`, `test` and `system-test` from `.github/workflows/ci.yml`, with
`enforce_admins` on. Force pushes and deletion of `main` are blocked.

## Why
`bin/ci` (see `config/ci.rb`) does not run system tests, but CI does. A PR
that is green with `bin/ci` can still be blocked by `system-test`.

## How to apply
Before opening a PR that touches views or user flows, also run
`bin/rails test:system`. After pushing, watch the checks with
`gh pr checks <number> --watch` and fix failures before handing over.
