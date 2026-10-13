# Role Review Notes — 2026-10

Reviewed roles in this change: Design Lead, Senior Designer, QA Lead, Senior QA, and DevOps.

Key boundaries:

- Design owns what users see and how approved interface behavior works; Development implements it and must not invent missing UI decisions.
- Design System is the UI source of truth; routine component evolution does not require per-component Design Lead approval.
- QA Lead owns complete DoD/test strategy and the final quality verdict; Senior QA owns hands-on execution, investigation, evidence, impact analysis, and fix verification.
- QA verifies all AC; PO does not need a redundant post-implementation AC pass when QA evidence is complete.
- DevOps owns deployability, reliability, recoverability, observability, infrastructure reproducibility/cost, and safe production operations; it does not own the release decision.
- Cybersecurity owns security truth/constraints; Technical Lead owns technical architecture/patterns; human owns residual-risk acceptance and final release/deploy authorization.
- Senior Developer review is intentionally outside this change and remains a separate follow-up.
