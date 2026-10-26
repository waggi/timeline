# Event URLs must be http or https, because they are rendered as links

- Type: decision
- Date: 2026-10-23
- Source: PR #8
- Status: active

## What
`Event#url` may be blank, but if present it must parse as an `http` or
`https` URL with a host (`Event#url_must_be_http`). Other schemes are
rejected with "must be an HTTP or HTTPS URL".

## Why
The URL is shown as a clickable link. A `javascript:` URL would run code in
the visitor's browser (XSS). Blog posts are always http(s), so nothing
legitimate is lost.

## How to apply
Keep this validation when the crawler or importer creates events; don't
bypass it with `insert_all` or `update_column` for URLs. The show page also
passes the link through `sanitize` (only `<a href>` allowed); keep both.
