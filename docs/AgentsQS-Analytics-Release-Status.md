# AgentsQS analytics release

Release timestamp: 2026-08-29 16:16 CST

Release archive: `releases/AgentsQS-20260829-161625-analytics-device-categories.tar.gz`
SHA-256: `a7bb38d16c187da7361695b923af4ead59f5b2cf3d7fd2f1fa96905562a2c2e6`

## Scope

- Capture anonymous AgentsQS product engagement events.
- Label web events as desktop, mobile, or tablet.
- Show AgentsQS event categories and device totals in the private admin dashboard.

## Events

- `product_page_view`
- `open_product_page`
- `open_screener`
- `view_strategy`
- `language_switch`

## Validation

- JavaScript syntax checks passed for the tracking and dashboard Functions.
- Cloudflare Pages Functions build completed successfully with Wrangler 4.127.1.
- Only the files listed in this release are staged; unrelated working-tree changes are excluded.

## Privacy

Event payloads contain an event category, product, version, and coarse device type only. They do not include account identifiers, search input, or strategy parameters.
