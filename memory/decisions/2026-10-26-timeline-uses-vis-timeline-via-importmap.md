# The timeline is drawn with vis-timeline, pinned through importmap

- Type: decision
- Date: 2026-10-26
- Source: PR "Interactive timeline UI" (branch claude/timeline-ui)
- Status: active

## What
The home page draws events with vis-timeline 8.5.5 (standalone ESM build,
vendored by `bin/importmap pin vis-timeline/standalone`). Its CSS is vendored
in `vendor/assets/stylesheets/`, added to the Propshaft path in
`config/initializers/assets.rb` and linked before the app styles. Alternatives
were TimelineJS (a slideshow, weak zoom, not ESM) and a custom D3 timeline
(too much own code).

## Why
vis-timeline gives horizontal pan/zoom, touch gestures and item selection out
of the box and works with importmap without a Node build.

## How to apply
Upgrade with `bin/importmap pin vis-timeline/standalone` and download the CSS
of the same version. Build item content as DOM nodes (`textContent`), never
HTML strings, so titles can't inject markup. The dialog form sends
`inline=1`; only then `create` answers with a turbo-stream, other forms keep
the redirect. Frames named `event_details` use `target="_top"`, or links in
them stay inside the frame.
