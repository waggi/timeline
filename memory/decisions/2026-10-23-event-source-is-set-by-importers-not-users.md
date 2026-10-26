# Event source is set by the importer, never by the user

- Type: decision
- Date: 2026-10-23
- Source: PR #8 (same choice in the competing PR #7)
- Status: active

## What
`events.source` is one of `manual`, `file`, `blog`, `NOT NULL` with database
default `manual`. The event form has no source field and `EventsController`
does not permit `source`, so everything entered by hand is `manual`. Only
importers (the future blog crawler, a file import) set `file` or `blog`.

## Why
The source says where an event came from. If users could pick it, a hand-made
event could pretend to come from the blog. The database constraint keeps data
valid even when an importer skips model validations (e.g. `insert_all`).

## How to apply
Never add `source` to the permitted params or the form. A crawler or importer
sets `source` explicitly. A new source value needs both the model's
`inclusion` list and a decision entry here.
