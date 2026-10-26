# Event source is set by the importer, never by the user

- Type: decision
- Date: 2026-10-23
- Source: PR #8 (same choice in the competing PR #7)
- Status: active

## What
`events.source` is validated by `Event` as one of `manual`, `file`, `blog`. The
database column is `NOT NULL` with default `manual`, but it has no constraint
limiting the allowed values. The event form has no source field and
`EventsController` does not permit `source`, so everything entered by hand is
`manual`. Only importers set `file` or `blog`.

## Why
The source says where an event came from. If users could pick it, a hand-made
event could pretend to come from the blog. The original entry incorrectly
claimed a database inclusion constraint: a test confirmed `insert_all!` can
store an unsupported value.

## How to apply
Never add `source` to the permitted params or the form. A crawler or importer
sets `source` explicitly and should use model validations until a database
constraint exists. A new source value needs the model's `inclusion` list and a
decision entry here.
