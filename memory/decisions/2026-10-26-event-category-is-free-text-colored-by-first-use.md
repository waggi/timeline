# Event category is optional free text; colors go by order of first use

- Type: decision
- Date: 2026-10-26
- Source: conversation with the owner; PR #10
- Status: active

## What
`events.category` is an optional string (up to 50 characters, extra spaces
removed). The owner chose free text over a fixed list. The form suggests
existing categories. On the timeline each category gets one of 7 colors
(`category-1`..`category-7` in `events.css`), in the order the categories
were first used (`Event.categories_by_first_use`). Red is left out because
it marks "Delete".

## Why
A hash of the name was tried first: 3 of 5 sample categories got the same
color. With free text no palette can keep every pair apart, so the
category name is always shown as text next to the color.

## How to apply
Don't color by name hash or by alphabetical position (a new category would
repaint the others). Keep the text label wherever a category color is
shown. The crawler may leave `category` empty.
