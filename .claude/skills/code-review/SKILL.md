---
name: code-review
description: Review a pull request in this repository and post the review on GitHub with gh. Use when asked to review a PR (by number or branch). Produces a short overall review (what the PR does, main risks) plus line comments, each with the file and line, the problem and how to reproduce it. Checks the rules in AGENTS.md and skips style that RuboCop already enforces.
---

# Code review

A review has two parts, both posted on the PR:

1. **Overall review**: 3 to 5 sentences. What the PR does, the main risks,
   and whether anything must be fixed before merge.
2. **Line comments**: one per concrete problem, attached to the exact line in
   the diff. Each says where the problem is, what it is, and how to reproduce it.

The owner reads every review and merges herself (see `memory/context/`).
Write in plain words, without jargon, so she can decide what to do.

## Before you start

1. Read `memory/` with the skill `.agents/skills/shared-memory/SKILL.md`:
   always `memory/context/`, plus every entry related to the PR.
2. Load the PR (`N` is the PR number):

   ```sh
   gh pr view N --json number,title,body,headRefName,headRefOid,baseRefName,files
   gh pr diff N
   gh pr checks N
   ```

3. Check out the branch to run and reproduce things: `gh pr checkout N`.
   Run the tests that the PR touches, and `bin/ci` if the change is large.

## What to check

The rules come from `AGENTS.md`. For each rule that is broken, leave a
comment, or a line in the overall review if it has no single line in the diff.

- **Branch and PR**: one task, one branch from an up-to-date `main`, one PR.
  `gh pr view N --json commits` and the base branch show this.
- **Tests**: new code has tests in the matching folder under `test/`
  (models, controllers/requests, jobs, services, system tests for user-facing
  flows). Bug fixes have a test that fails without the fix. Tests use fixtures
  from `test/fixtures/` and never hit the network (external HTTP is stubbed).
- **CI**: all five required checks are green (`scan_ruby`, `scan_js`, `lint`,
  `test`, `system-test`); see `memory/environment/`. No check was skipped or
  disabled to make it pass.
- **PR description**: every section of `.github/pull_request_template.md` is
  filled in (Summary, Test plan, Memory).
- **Memory**: `memory/` is updated in the same PR, or the description says
  "memory: nothing new". New entries follow the shared-memory skill.
- **Decisions**: the change doesn't contradict `memory/decisions/` (e.g. event
  source is set by importers, event URLs are http or https only).
- **Secrets and credentials**: no tokens, keys or passwords in code, fixtures,
  memory or the PR. Code doesn't rely on `config/master.key` or
  `Rails.application.credentials`, which are absent in sandboxes and CI.

Then review the code itself, which no tool checks for you:

- **Correctness**: wrong logic, missing edge cases (empty input, `nil`, dates
  and time zones, duplicates), broken flows a user could hit.
- **Security beyond Brakeman**: missing authorization, unsafe params, HTML or
  URLs rendered from user input, data from the crawler trusted blindly.
- **Data**: migrations that lose data or can't be rolled back, missing
  validations or database constraints, N+1 queries on pages that list events.
- **Tests that don't test**: assertions that pass even when the code is broken.

## What not to comment on

- Anything that `bin/rubocop` (rails-omakase), Brakeman, bundler-audit or
  `importmap audit` already check: formatting, quotes, spacing, line length,
  method style. If CI is red for these, one sentence in the overall review is
  enough.
- Matters of taste with no concrete harm. If you can't say what goes wrong,
  don't comment.

## Writing a line comment

Attach each comment to a line that appears in the diff, on the new side of
the file. Use this format:

```markdown
**Problem:** what is wrong and why it matters, in one or two sentences.

**How to reproduce:** concrete steps, input or a command, e.g.
`bin/rails test test/models/event_test.rb:42`, a request with curl, or
"open /events/new, leave the date empty, press Save".

**Suggestion:** how to fix it (optional, short).
```

The file and line are given by where the comment is attached. If you
mention another place in the code, write it as `path/to/file.rb:12`.
If you could not reproduce the problem, say so and phrase it as a question,
not as a bug.

## Posting the review

Write all line comments into one JSON file and post them as one review, so
they arrive together. `commit_id` is `headRefOid` from `gh pr view`.

```sh
cat > /tmp/review-N.json <<'JSON'
{
  "commit_id": "<headRefOid>",
  "event": "COMMENT",
  "comments": [
    {
      "path": "app/models/event.rb",
      "line": 12,
      "side": "RIGHT",
      "body": "**Problem:** ...\n\n**How to reproduce:** ...\n\n**Suggestion:** ..."
    }
  ]
}
JSON
gh api repos/{owner}/{repo}/pulls/N/reviews -X POST --input /tmp/review-N.json
```

- For a comment over several lines, add `"start_line"` and `"start_side": "RIGHT"`;
  `"line"` is then the last line.
- If GitHub answers `422` ("line must be part of the diff"), the line is not
  in the diff. Fix the line number, or move that comment into the overall
  review with `file:line`.

Then post the overall review:

```sh
gh pr review N --comment --body-file /tmp/review-N-summary.md
```

Rules for posting:

- Always use `--comment` (`"event": "COMMENT"`). Never approve, never request
  changes, never merge: the owner decides.
- Post each review once. If you need to add something, post a new comment;
  don't delete and repost.
- If you found nothing, still post the overall review and say what you checked.

## At the end

Tell the owner, in plain words: the PR link, how many comments you left, and
which of them must be fixed before merge.
