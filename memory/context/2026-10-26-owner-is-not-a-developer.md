# The owner is not a developer: explain in plain words and ask first

- Type: context
- Date: 2026-10-26
- Source: conversation with the owner
- Status: active

## What
The owner of this repository is not a developer. She reads every pull
request and merges every PR herself; agents never merge.

## Why
She has to understand what changes and why in order to decide whether to
merge. Jargon, long diffs without explanation, or surprise decisions make
that impossible.

## How to apply
- Explain results in plain words, without jargon; say what she should check.
- Ask before big decisions (new gems or services, data model changes,
  deleting things, anything costly or hard to undo). Offer options with a
  recommendation.
- Never merge a PR yourself; open it and leave the merge to her.
