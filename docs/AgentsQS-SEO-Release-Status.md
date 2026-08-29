# AgentsQS SEO release

Release timestamp: 2026-08-29 22:31 CST

Source revision before publication: `a053c9b2a02e9f536b9c6f86351aaa363f3717c1`

Release archive: `releases/AgentsQS-20260829-223149-seo-indexing.tar.gz`

SHA-256: `8b2e50c2e1acc4f84ac7cddf3105c20bf49fa3b2244152701da178861a64f87a`

## Scope

- Add an index/follow robots directive and canonical URL for the AgentsQS product page.
- Add Open Graph and X/Twitter sharing metadata using the existing AgentsQS product image.
- Add `WebApplication` JSON-LD structured data with the research-only financial disclaimer.
- Add the public product page to the root sitemap.

## Validation

- JSON-LD parses successfully and identifies the canonical AgentsQS URL.
- `xmllint --noout site/sitemap.xml` passed.
- `git diff --check` passed.

## Indexing follow-up

After production deployment, submit `https://www.agentsbin.com/sitemap.xml` in Google Search Console and use URL Inspection to request indexing for `https://www.agentsbin.com/agentsqs/`.

## Rollback

Restore the immediately previous Cloudflare Pages deployment, or redeploy the prior release archive.
