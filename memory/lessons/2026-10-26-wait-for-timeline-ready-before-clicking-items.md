# Wait for data-timeline-ready before clicking timeline items in system tests

- Type: lesson
- Date: 2026-10-26
- Source: PR #10 (system-test failed on GitHub, then ~1 in 5 runs locally)
- Status: active

## What
Symptom: a system test clicks a `[data-testid=timeline-item]`, but the
details panel stays empty and nothing is selected. Cause: right after load,
vis-timeline re-lays out items a few times while it measures them; Capybara
finds the item, it moves, and the click lands on empty canvas. Fix: the
timeline controller sets `data-timeline-ready` once redraws stop for 250 ms;
tests wait for `[data-timeline-ready]` before clicking items.

## Why
Capybara reads an element's position and clicks those coordinates; it can't
know that a canvas library is still moving things.

## How to apply
In system tests, assert `[data-timeline-ready]` before clicking anything on
the timeline. Details open on the browser's own `click` (not vis's `select`,
which detects taps by timing). Run new timeline tests several times in a row.
