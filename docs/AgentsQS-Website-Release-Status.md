# AgentsQS Website Release Status

## 2026-08-29 — Product homepage

- Source revision: AgentsBin commit to be recorded at publication.
- Change: promoted AgentsQS to the released product catalogue and added a dedicated bilingual (English / Simplified Chinese) product homepage.
- Product page: `/agentsqs/`; the live screener remains at `https://agentsqs.pages.dev/`.
- Content: iPhone-style live UI illustration, the public Trend Confluence strategy, MA20 / MA5 / RSI(14) / volume rule explanations, and research-only disclosures.
- Immutable artifact: `releases/AgentsQS-20260829-153000-product-homepage.tar.gz`.
- SHA-256: `b46b951a95a0cf86b71ee545d8bacf515e705eb0909da30810aabe2e3f19cffc`.
- Validation: HTML structure check, static screenshot review, and `git diff --check` passed.
- Rollback: restore the previous AgentsBin Pages deployment or remove the `/agentsqs/` route and return the catalogue entry to In Development.
