# AgentsBin analytics coverage release

Release timestamp: 2026-08-29 23:00 CST

## Scope

- Add a page-view event to the AgentsBin product page.
- Classify homepage and product-page web events as desktop, mobile, or tablet.
- Include page views, downloads, app opens, agent opens, and engagements in the admin event-category table.

## Validation

- JavaScript syntax checks pass for the updated analytics, stats, and admin code.
- The D1 aggregation remains anonymous and groups only by event kind, name, source, and product.
- Unrelated working-tree changes are excluded from the release commit.

## Interpretation

The dashboard now measures coverage consistently, but event volume still depends on real visitors. Review at least 7–14 days of traffic after publication before making channel decisions.

## Rollback

Restore the previous Cloudflare Pages deployment or redeploy the preceding release archive.
