# Design and verification practices

Design Lead decides and approves; Senior Designer produces artifacts; Design
Tester independently verifies. QA Lead retains final feature AC responsibility.

## One current design source

Use the project's authoritative UI system and design format. HTML/CSS examples
and clickable mockups are the draft preference when none exists. Keep shared
tokens/components and usage guidance in `docs/ui-system/`; put application-specific
flows/mockups with that application's docs. Preserve user edits, update existing
artifacts, and avoid competing copies of the same component.

Give reusable components stable names, variants/states, usage conditions, accessible
behavior, and implementation mapping. Reuse or extend before adding another near
duplicate. Add the components needed for a feature without blocking it on a
speculative full-library rebuild. For HTML mockups, use shared styles/tokens;
feature layout may be local while reusable component behavior stays consistent.

## Flow, content, and states

For each relevant journey define entry, main action, success, cancellation/back,
validation, permission limits, and recovery. Build a concise applicability matrix
for supported viewports/platforms × relevant states, themes, and languages; do
not manufacture every combination when it adds no information.

Use clear hierarchy, a coherent type scale/spacing rhythm, restrained meaningful
color, and realistic content. Same actions should use consistent labels, icons,
and emphasis. Reserve danger treatment for destructive consequences; ensure
icon-only controls have accessible names. Explain important deviations from the
system rather than creating a universal ban on a visual style.

Put field-specific validation beside the field, and system errors where users
can perceive and recover from them. Toasts may acknowledge transient events but
must not be the only place for durable actionable errors. Define overlay/focus
behavior; avoid stacked blocking dialogs and inaccessible focus traps.

Never prefill stored secret values into a mockup or implemented page. Use
presence-only states, an empty replacement input, and explicit keep/replace/remove
semantics. A reveal control applies only to a value newly entered by the user.

## Accessibility, responsiveness, and assets

Design for keyboard use, visible focus, meaningful names/labels, sensible focus
order/return, semantic structure, readable contrast, zoom/reflow, and reduced-motion
preferences. Use current applicable accessibility guidance for measurable criteria;
do not claim certification from a visual inspection or automated scan alone.
Check longer/localized text, narrow screens, touch interactions, and slow/loading
states for supported platforms.

Use existing approved assets where suitable. For new assets, record purpose,
dimensions, format, source/license where relevant, and intended placement. Prefer
vector sources for icons/logos when appropriate and suitable optimized formats
for raster assets. Use an available image/design tool for actual generation;
if unavailable, provide an actionable brief and state what remains missing.

## Review and handoff

Inspect the rendered design in available browser/device tools. Exercise interactions
and relevant states, not only a static hero screenshot. Retest a correction at
the affected viewport/state. Record observed findings separately from suggestions
and untested concerns; screenshots should identify the artifact/revision/context.

A handoff includes flow/state coverage, component/token changes, interaction and
content rules, assets, responsive behavior, relevant SEO/accessibility decisions,
and known constraints. Design Lead resolves findings with evidence, approves the
scope, and updates the Issue. Technical/QA changes that affect user experience
return to Design Lead; business scope returns to PO.
