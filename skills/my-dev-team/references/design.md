# Design and verification practices

Design Lead decides and approves; Senior Designer produces artifacts; Design
Tester independently verifies. QA Lead retains final feature AC responsibility.

## One current design source

Use the project's authoritative UI system and design format. When none exists,
use HTML examples and clickable mockups. Keep shared tokens/components and usage
guidance in `docs/ui-system/`; put application-specific flows/mockups with that
application's docs. UI-system pages are HTML [documents](records.md) with a
section `id` per token group and per component, so anyone can be pointed at
`docs/ui-system/components.html#button`. Preserve user edits, update existing
artifacts, and avoid competing copies of the same component.

On the [standard stack](stack.md), the design tokens are the single source of
colors, spacing, and typography: the Tailwind theme is generated from them, and
mockups use the same values. Group components by Atomic Design level (atoms,
molecules, organisms, templates) under the names `frontend-core` uses, so a
component in the UI system and its code are found by one name.

Give reusable components stable names, variants/states, usage conditions, accessible
behavior, and implementation mapping. Reuse or extend before adding another near
duplicate. Add the components needed for a feature without blocking it on a
speculative full-library rebuild. For HTML mockups, use shared styles/tokens;
feature layout may be local while reusable component behavior stays consistent.

## Components and actions

Every component in the UI system carries a usage block beside its rendered
examples. A component without one is incomplete, and a screen that breaks one
is a defect:

```text
Component: Button / Secondary
Purpose:        a lower-emphasis action that must still read as clickable
Use when:       the action matters but is not the view's main goal (Cancel,
                Back, Edit), or for row and toolbar actions
Don't use when: it is the main action (use Button / Primary), it destroys data
                (use Button / Destructive), or it navigates in text (use Link)
Variants:       sm in table rows and toolbars; md in forms and dialogs
Why it looks this way: outlined, so it is visibly a button without competing
                with Primary
```

Name components `Category / Variant` and keep the names stable. One component
per pattern: when two are nearly the same, merge them into one with variants.

Define one action system, with each variant chosen by what the action means,
not by taste per screen:

| Variant | Meaning | Examples |
| --- | --- | --- |
| Primary | The main action of the view | Save, Submit, Continue |
| Secondary | Important but not the main action; the default for lower emphasis | Cancel, Back, Edit, filters, row actions |
| Icon button | A well-known action where a label would crowd; the icon sits in a visible container | Row edit, toolbar actions |
| Destructive | Irreversible or data-losing | Delete, Remove, Revoke |
| Confirm | Accepting a positive outcome | Approve, Accept, Publish |
| Link | Navigation inside text | "See all", "Learn more" |
| Ghost | No border, no fill; an exception with a recorded reason | A dialog's close `x`, a dense editor toolbar |

- **The same action looks the same everywhere.** Delete is always Destructive;
  Approve is always Confirm, with the same icon on every screen.
- **One primary action per view or section.**
- **Avoid ghost buttons.** A borderless, fill-less button reads as unfinished
  and is easy to miss. Use Secondary or an Icon button with a visible container,
  and record the reason whenever a ghost button is used.
- **Paired actions have equal weight.** Approve and Reject, or Save and Cancel,
  are the same size and treatment and differ only in color, label, and icon.
  Never one solid danger button beside one borderless icon.
- **Icons match the meaning and pair coherently:** approve `check` with reject
  `x`; keep `ban` for actually blocking someone. Every icon-only control has an
  accessible name, and a destructive icon action also asks for confirmation.
- **Every variant defines all its states:** default, hover, focus with a visible
  ring, active, disabled, and loading, on a fixed size scale.
- **Every style has a reason.** If you cannot say why an element has its border,
  fill, color, or icon, change it.

Before handoff, check each screen: every element comes from the UI system with
nothing restyled locally; each component is used within its usage conditions;
no ghost button without a recorded reason; the same action has the same variant
and icon everywhere; paired actions match; there is one primary per view; and
no near-duplicate components remain.

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
must not be the only place for durable actionable errors.

Define the overlay layers as tokens in the UI system, in this fixed order:
`base < dropdown/popover < modal backdrop < modal < popup < toast`. A modal is a
blocking dialog with a backdrop. A popup is a small interrupt, a confirm or an
alert, and is the only thing that may appear over a modal, as in "Discard
changes?" over an edit form. Never design a modal over a modal. Toasts sit above
everything. The frontend's [overlay manager](stack.md) implements these tokens.

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
vector sources (SVG) for icons/logos. Deliver raster assets as WebP in the
responsive sizes the layout needs, and record each one's width and height so the
page can reserve its space.

### Generating an image or a logo

Write the brief before generating anything, and record it with the design:

- **A logo:** the brand name and what it does, three to five words for how it
  should feel, the symbol or idea, the style (line, geometric, wordmark,
  lettermark, mascot), the palette with the reason for each color, and a
  one-color version. Deliverables: the primary logo, the one-color version, an
  app icon and favicon crop, and the clear-space rule.
- **An image:** where it is used, the subject, action, setting and mood, the
  style consistent with the product, the aspect ratio, and any area that must
  stay clear for text.

Then produce a prompt pack:

1. **The primary prompt:** one to three clear sentences, with constraints and
   exclusions at the end.
2. **Three to five variations,** each changing exactly one thing (palette,
   layout, lighting), labeled with what changed, so it is clear what improved.
3. **Settings:** size and aspect ratio, background (transparent for a logo),
   and format.
4. **For a logo:** the exact wordmark text, kept short, and a one-color prompt.

Text inside a generated image is fragile: state the exact words and check the
spelling in the result. Image models produce raster files, so a logo comes back
as a PNG master to be redrawn as SVG; mark it "needs vectorizing". Never copy a
competitor's mark.

### Images are generated with the Codex CLI

Every image and logo is generated through the Codex CLI, on the human's ChatGPT
sign-in. It is the team's one image tool, whichever host is organizing. Do not
generate images with another model or service, and never with a pay-as-you-go
API key.

1. **Write the brief as an HTML document** in the owning frontend's docs,
   listed in its `README.md`. Give each asset a section with its own `id`: name,
   purpose, the prompt, the variations, final size, format, background, the
   exact path to save to, and `Status: pending`.
2. **Run Codex on the brief,** from the worktree the assets belong to, with no
   OS sandbox like every CLI in the team ([delegation](delegation.md)):

   ```bash
   codex exec --sandbox danger-full-access \
     "Read frontend_domain_1/docs/assets/image-brief.html and generate every asset marked pending, exactly as it says."
   ```

   Check `codex exec --help` for the flags the installed version supports
   instead of assuming these.
3. **The brief tells Codex what to do with each result:** save it at its exact
   path, resize or convert it to the final size and format, never overwrite an
   existing file (write `name-v2` beside it), keep scratch files and variations
   out of the repository, mark a logo's PNG master "needs vectorizing", and
   report a table of asset, path, size, and status.
4. **Check every result against the design** before using it: spelling of any
   text in the image, the brand colors, and that it fits the layout at its
   recorded width and height. Update each asset's status in the brief, and
   commit the accepted files.

Who runs it:

- **When the host is Codex,** as Organizer or as Design Lead in conversation,
  generate directly with Codex's built-in image tool from the same brief; do not
  start a second Codex.
- **On any other host,** the role that needs the image runs the command: Design
  Lead, or a Senior Designer inside its worktree. A role that cannot start a CLI
  returns the brief, and Organizer runs Codex on its behalf.

If Codex is not installed, is signed out, or has reached its limit, do not
substitute another generator. Leave the assets `pending`, tell the human what
to do (`codex login`, or wait for the limit), and continue the work that does
not depend on them.

## Review and handoff

Inspect the rendered design in available browser/device tools. Exercise interactions
and relevant states, not only a static hero screenshot. Retest a correction at
the affected viewport/state. Record observed findings separately from suggestions
and untested concerns; screenshots should identify the artifact/revision/context.

A handoff includes flow/state coverage, component/token changes, interaction and
content rules, assets, responsive behavior, relevant SEO/accessibility decisions,
and known constraints, each pointing at its document as `file#section`. Design
Lead resolves findings with evidence, approves the scope, and updates the Issue. Technical/QA changes that affect user experience
return to Design Lead; business scope returns to PO.
