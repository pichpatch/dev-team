# Design and verification practices

Design Lead decides and approves; Senior Designer produces; Design Tester
verifies independently. QA Lead keeps final responsibility for feature AC.

## One current design source

- Use the project's own UI system and design format. When there is none, use
  HTML examples and clickable mockups.
- Shared tokens, components, and usage rules live in `docs/ui-system/`;
  application flows and mockups live with that application's docs.
- UI-system pages are HTML [documents](records.md) with a section `id` per token
  group and component, so anyone can be pointed at
  `docs/ui-system/components.html#button`.
- Keep the human's edits, update existing artifacts, and never keep competing
  copies of one component.
- On the [standard stack](stack.md), the design tokens are the single source of
  colors, spacing, and type: the Tailwind theme is generated from them, and
  mockups use the same values. Group components by Atomic Design level (atoms,
  molecules, organisms, templates) under the names `frontend-core` uses, so a
  component and its code share one name.
- Give reusable components stable names, variants and states, usage
  conditions, accessible behavior, and their code mapping. Reuse or extend
  before adding a near-duplicate. Add what a feature needs; do not block it on
  rebuilding the whole library. Mockups use shared styles and tokens; layout may
  be local, component behavior may not.

## Components and actions

Every UI-system component has a usage block beside its examples. Without one it
is incomplete, and a screen that breaks it has a defect:

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
per pattern: merge near-duplicates into one with variants.

One action system, with the variant chosen by what the action means:

| Variant | Meaning | Examples |
| --- | --- | --- |
| Primary | The main action of the view | Save, Submit, Continue |
| Secondary | Important but not main; the default lower emphasis | Cancel, Back, Edit, filters, row actions |
| Icon button | A well-known action where a label would crowd; icon in a visible container | Row edit, toolbar actions |
| Destructive | Irreversible or data-losing | Delete, Remove, Revoke |
| Confirm | Accepting a positive outcome | Approve, Accept, Publish |
| Link | Navigation inside text | "See all", "Learn more" |
| Ghost | No border, no fill; an exception with a recorded reason | A dialog's close `x`, a dense editor toolbar |

- **The same action looks the same everywhere.** Delete is always Destructive;
  Approve is always Confirm, with the same icon.
- **One primary action per view or section.**
- **Avoid ghost buttons;** they look unfinished and are easy to miss. Use
  Secondary or a contained Icon button, and record the reason for any ghost.
- **Paired actions have equal weight** (Approve/Reject, Save/Cancel): same size
  and treatment, differing only in color, label, and icon. Never a solid danger
  button beside a borderless icon.
- **Icons match meaning and pair coherently:** approve `check` with reject `x`;
  keep `ban` for actually blocking someone. Every icon-only control has an
  accessible name; a destructive icon action asks for confirmation.
- **Every variant defines every state:** default, hover, focus with a visible
  ring, active, disabled, loading, on a fixed size scale.
- **Every style has a reason.** If you cannot say why an element has its border,
  fill, color, or icon, change it.

**Before handoff, check each screen:** every element comes from the UI system,
nothing restyled locally; each component is used within its usage conditions; no
unexplained ghost button; same action, same variant and icon everywhere; paired
actions match; one primary per view; no near-duplicate components.

## Flow, content, and states

- For each journey define entry, main action, success, cancel and back,
  validation, permission limits, and recovery. Build a short matrix of supported
  viewports or platforms × relevant states, themes, and languages; skip
  combinations that add nothing.
- Use clear hierarchy, a coherent type scale and spacing rhythm, restrained
  meaningful color, and realistic content. Keep labels, icons, and emphasis
  consistent for the same action. Reserve danger styling for destructive
  results. Explain important deviations instead of banning a style outright.
- Field errors sit beside the field; system errors go where users can see and
  recover from them. A toast may acknowledge a passing event but is never the
  only place for an error the user must act on.
- **Overlay layers** are UI-system tokens, in this fixed order:
  `base < dropdown/popover < modal backdrop < modal < popup < toast`. A modal is
  a blocking dialog with a backdrop. A popup (a confirm or alert) is the only
  thing that may appear over a modal, as in "Discard changes?" over an edit
  form. Never a modal over a modal. Toasts sit above everything. The frontend's
  [overlay manager](stack.md#shared-frontend) implements these.
- **Never prefill a stored secret** into a mockup or page. Show presence only,
  an empty replacement input, and explicit keep, replace, or remove. A reveal
  control applies only to a value the user just typed.

## Accessibility, responsiveness, and assets

- Design for keyboard use, visible focus, meaningful names and labels, sensible
  focus order and return, semantic structure, readable contrast, zoom and
  reflow, and reduced motion. Use current accessibility guidance for measurable
  criteria; never claim conformance from a visual check or an automated scan.
- Check longer translated text, narrow screens, touch, and slow or loading
  states on supported platforms.
- Reuse approved assets where suitable. For a new asset, record its purpose,
  size, format, source or license, and placement. Prefer SVG for icons and
  logos. Deliver raster images as WebP in the responsive sizes the layout
  needs, with each width and height recorded so the page can reserve space.

### Generating an image or a logo

Write the brief first, and keep it with the design:

- **Logo:** brand name and what it does; three to five words for the feel; the
  symbol or idea; the style (line, geometric, wordmark, lettermark, mascot); the
  palette with a reason per color; a one-color version. Deliverables: primary
  logo, one-color version, app icon and favicon crops, clear-space rule.
- **Image:** where it is used; subject, action, setting, and mood; a style
  matching the product; the aspect ratio; any area that must stay clear for
  text.

Then a prompt pack:

1. **Primary prompt:** one to three clear sentences, constraints and exclusions
   last.
2. **Three to five variations,** each changing one thing (palette, layout,
   lighting) and labeled with what changed.
3. **Settings:** size and aspect ratio, background (transparent for a logo),
   format.
4. **For a logo:** the exact short wordmark text, and a one-color prompt.

Text in generated images is fragile: give the exact words and check the
spelling. Image models produce raster files, so a logo comes back as a PNG
master marked "needs vectorizing", to be redrawn as SVG. Never copy a
competitor's mark.

### Images are generated with the Codex CLI

Every image and logo is generated through the Codex CLI, on the human's ChatGPT
sign-in, whichever host is organizing. No other model or service, and never a
pay-as-you-go API key.

1. **Write the brief as an HTML document** in the owning frontend's docs, listed
   in its `README.md`. One section per asset with its own `id`: name, purpose,
   prompt, variations, final size, format, background, the exact save path, and
   `Status: pending`.
2. **Run Codex on the brief** from the worktree the assets belong to, with no OS
   sandbox like every CLI in the team ([delegation](delegation.md)):

   ```bash
   codex exec --sandbox danger-full-access \
     "Read frontend_domain_1/docs/assets/image-brief.html and generate every asset marked pending, exactly as it says."
   ```

   Check `codex exec --help` for the flags the installed version supports.
3. **The brief tells Codex what to do with each result:** save it at its exact
   path; resize or convert it to the final size and format; never overwrite a
   file (write `name-v2` beside it); keep scratch files and variations out of the
   repository; mark a logo's PNG master "needs vectorizing"; report a table of
   asset, path, size, and status.
4. **Check every result** against the design: spelling of any text, brand
   colors, fit at the recorded size. Update each asset's status in the brief and
   commit the accepted files.

Who runs it:

- **On Codex** (as Organizer or as Design Lead in conversation): use Codex's
  built-in image tool on the same brief; do not start a second Codex.
- **On any other host:** the role that needs the image runs the command: Design
  Lead, or a Senior Designer in its worktree. A role that cannot start a CLI
  returns the brief and Organizer runs Codex for it.

If Codex is missing, signed out, or at its limit, do not use another generator.
Leave the assets `pending`, tell the human what to do (`codex login`, or wait
for the limit), and continue the work that does not need them.

## Review and handoff

- Inspect the rendered design in browser or device tools. Exercise
  interactions and states, not one static screenshot. Retest a fix at the
  affected viewport and state, within the
  [review loop limits](contract.md#every-review-loop-is-bounded).
- Record observed findings separately from suggestions and untested concerns.
  Screenshots name the artifact, revision, and context.
- A handoff covers flows and states, component and token changes, interaction
  and content rules, assets, responsive behavior, SEO and accessibility
  decisions, and known limits, each as `file#section`.
- Design Lead resolves findings with evidence, approves the scope, and updates
  the Issue. Technical or QA changes that affect the experience return to Design
  Lead; business scope returns to PO.
