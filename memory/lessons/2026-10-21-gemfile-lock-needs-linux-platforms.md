# Gemfile.lock made on a Mac needs the Linux platforms, or CI can't install gems

- Type: lesson
- Date: 2026-10-21
- Source: PR #5
- Status: active

## What
Symptom: `bundle install` fails on GitHub Actions (ubuntu) or in the Docker
build, although it works on the Mac. Cause: `rails new` on macOS writes only
`arm64-darwin-23` under `PLATFORMS` in `Gemfile.lock`. Fix (PR #5):
`bundle lock --add-platform x86_64-linux aarch64-linux`.

## Why
Bundler only resolves gems for the platforms listed in the lockfile, and
gems with native code have separate builds per platform.

## How to apply
Keep all three platforms in `Gemfile.lock`. After changing gems, check that
`PLATFORMS` still lists `aarch64-linux`, `arm64-darwin-23` and
`x86_64-linux` before pushing.
