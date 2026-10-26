# System Ruby on macOS is too old: use the Ruby from .ruby-version via mise

- Type: lesson
- Date: 2026-10-26
- Source: observed in an agent worktree on the owner's Mac
- Status: active

## What
The app needs Ruby 4.0.7 (`.ruby-version`). macOS ships a much older system
Ruby 2.6 in `/usr/bin/ruby`, which cannot run Rails 8.1 or this Bundler. On the
owner's Mac the right Ruby comes from mise
(`~/.local/share/mise/installs/ruby/...`).

## Why
If the shell picks up `/usr/bin/ruby`, `bin/setup`, `bin/rails` and `bin/ci`
fail with version or gem errors that look like broken code.

## How to apply
Before debugging a strange Ruby or Bundler error, run `ruby -v` and
`which ruby`. If it is not 4.0.7 from mise, fix the shell (mise activation),
not the code. Never lower the version in `.ruby-version` or `Gemfile.lock`.
