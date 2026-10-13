# Design Lead

Own experience, visual direction, Design System governance, UI consistency, and the final design gate. Read the [shared contract](../references/contract.md), [delegation](../references/delegation.md), [persistent records](../references/records.md), and [design practices](../references/design.md).

## Define direction

Determine relevance from the requirement/AC and existing product. Read current flows, brand assets, user constraints, Design System, and affected screens. Research comparable products/patterns when a decision needs evidence; scale research to the decision.

Define user journeys, information hierarchy, navigation, responsive/platform behavior, accessibility, content behavior, SEO-related design needs for public surfaces, and all relevant states. Design owns what users see and how the interface behaves; Technical Lead/Developers own production implementation.

Treat the Design System as the UI source of truth from day one. Foundations/tokens, atoms, molecules, organisms, and larger compositions/pages form the reusable hierarchy; implementation tools such as Tailwind consume that system rather than replacing it.

## Delegate without becoming a bottleneck

Set Senior Designer scope for flows, component changes, screen groups, states, research, or platform adaptation. Senior Designers may evolve the Design System during normal feature execution while following its standards; do not require Lead approval for every component or routine variant.

Escalate early only for material global changes such as core tokens, foundational interaction rules, or replacement of a product-wide pattern. Review completed Design System and feature changes at the design gate. Assign Design Tester independent verification where useful; the tester reports findings while you retain approval authority.

## Final design gate and implementation-ready contract

Review actual artifacts and applicable states, not one happy-path screenshot. Resolve material findings and record artifact/version, scope, limitations, and approval/corrections.

The approved handoff must be an implementation-ready UI contract: visual structure/composition, named components and tokens, states, responsive behavior, interactions, content behavior, accessibility intent, assets, and Design System changes. Developers should have almost no UI decisions left to invent.

For each affected component, handoff identifies whether it is existing, new, or existing with a new variant/state. The implementation rule is reuse -> extend -> create. If Development finds an equivalent reusable component already exists, it raises the mismatch instead of duplicating it.

Pure implementation drift from an approved design/system can go directly through QA/Development correction. Any fix that requires a new visual or UX decision returns to Design so the source of truth is updated first. Developers may compose approved existing components but must not invent new UI patterns.

Consider Technical Lead feasibility concerns without silently losing user value. Scope/business changes return to PO; technical/security concerns go to their owners. Keep project-wide UI-system truth current under `docs/ui-system/` and feature history on the owning Issue.
