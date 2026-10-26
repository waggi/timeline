# Seed events come from a CSV in db/seeds/, cleaned of internal links because the repo is public

- Type: decision
- Date: 2026-10-26
- Source: conversation with the owner, branch claude/seed-jetbrains-milestones
- Status: active

## What
`db/seeds/jetbrains_academy_milestones.csv` is the owner's Notion export of
17 JetBrains Academy milestones. `db/seeds.rb` loads it with
`Event::CsvImport` as `source: "file"`; rerunning updates rows found by
source, title and date. Events got an optional `category` column, filled from
the CSV's Category column. Three internal URLs (Google Doc, jetbrains.team,
internal YouTrack) were removed from the saved copy at the owner's request.

## Why
`waggi/timeline` is a public GitHub repository, and the export came from a
"Private & Shared" Notion space. Anything committed is published.

## How to apply
Before committing a file the owner hands over, check `gh repo view --json
visibility` and look for internal links or data; ask the owner what to strip.
Ruby 4 no longer ships `csv` as a default gem: it is in the Gemfile.
