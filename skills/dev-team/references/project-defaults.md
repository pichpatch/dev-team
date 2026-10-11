# Draft project defaults

These are starting preferences adapted from `ai-skills`, not locked team rules.
Use them only where a project has not already chosen. The relevant owner records
the choice and rationale in existing project docs. Routine owner decisions do not
need an extra human gate; scope, budget, service purchases, authentication, and
production actions still need the appropriate human decision/authorization.

## Product and design

- Prefer responsive web and mobile-first design for applicable web products.
  Do not add mobile applications merely because the stack can support them.
- Prefer editable HTML/CSS UI-system examples and clickable HTML mockups when no
  design format is established. Existing design tools/assets remain valid; record
  one authoritative source and its relationship to code.
- For a new user-facing product, propose Thai/English support and light/dark themes.
  PO settles product scope; Design Lead specifies behavior. Do not silently add
  languages or themes to an agreed single-language/theme feature.
- When social login is in scope, consider Google/Apple-first entry points against
  audience/platform needs. Existing enterprise SSO or other agreed authentication
  takes precedence. These preferences do not authorize new account/provider setup.
- A data table is sortable by every column by default. PO names any column that
  should not be sortable, with the reason, in the AC.
- A public entity page (product, category, article, profile) uses the URL
  `/{title-slug}-{ref_id}`, for example `/pick-hand-fan-0l78Xd`. The slug comes
  from the entity's title in the language it is written in, so a Thai title
  gives a Thai slug; do not transliterate unless that is agreed. An entity with
  one language has one URL. An entity with several languages has one URL per
  language, each from that language's title and all sharing the same `ref_id`,
  linked to each other as language alternates for search engines. An outdated or
  wrong slug redirects to a current URL; an unknown `ref_id` returns 404. PO
  states this behavior in the AC; Technical Lead settles how the language of a
  request is determined.
- A public site is found by AI answers and not used for AI training; follow
  [AI crawlers](#ai-crawlers-found-by-ai-answers-not-used-for-training) below.
- Preserve helpful empty/first-use states and document onboarding concepts as
  features emerge. A separate product tour is later scope only when agreed; it
  must not delay essential setup needed to use the feature.

## AI crawlers: found by AI answers, not used for training

The default for every public site (the human's decision; PO records any
exception): **AI answer engines may read the site, so people can find the business
through ChatGPT, Claude, Perplexity, Gemini, and others. AI training bots are
blocked.**

**Allowed, search and answer bots (never block these):**
`Googlebot` (Google Search, including AI Overviews and AI Mode) · `Bingbot` (Bing
and Copilot; other AI search tools use Bing's index too) · `OAI-SearchBot`,
`ChatGPT-User` (ChatGPT) · `Claude-SearchBot`, `Claude-User` (Claude) ·
`PerplexityBot`, `Perplexity-User` (Perplexity) · `Applebot` (Siri, Spotlight) ·
`DuckAssistBot` (DuckDuckGo) · `MistralAI-User` (Le Chat) ·
`Meta-ExternalFetcher` (Meta AI, user-requested)

**Blocked, training and dataset bots:**
`GPTBot` (OpenAI) · `ClaudeBot` (Anthropic) · `Google-Extended` (Gemini) ·
`Applebot-Extended` (Apple) · `Meta-ExternalAgent` (Meta) · `CCBot` (Common Crawl) ·
`Bytespider` (ByteDance) · `cohere-training-data-crawler` (Cohere)

Keep the blocked list in **one module** per project (for example
`src/seo/ai-crawlers.ts`) that the robots file reads. Every bot not on it falls
under the `*` rule and stays allowed. For Next.js:

```ts
// app/robots.ts
import type { MetadataRoute } from "next";
import { AI_TRAINING_BOTS } from "@/seo/ai-crawlers";
export const dynamic = "force-dynamic"; // read SITE_ENV per request, not at build

export default function robots(): MetadataRoute.Robots {
  if (process.env.SITE_ENV !== "prod") return { rules: { userAgent: "*", disallow: "/" } };
  return {
    rules: [
      { userAgent: "*", allow: "/", disallow: "/api/" },
      { userAgent: AI_TRAINING_BOTS, disallow: "/" },
    ],
    sitemap: "https://<domain>/sitemap.xml",
  };
}
```

- **`Google-Extended` is the one judgment call.** Blocking it keeps content out of
  Gemini training, and it may also keep the site out of answers in the Gemini
  app. Google Search, including AI Overviews and AI Mode, is unaffected because
  that runs on `Googlebot`.
- robots.txt is a request, not a lock: well-behaved bots follow it, and blocking
  bots that ignore it is Cloudflare's job (DevOps). DevOps also makes sure
  Cloudflare never blocks the answer bots, and that a managed robots.txt does not
  contradict the site's rules.
- **Cybersecurity checks the lists at every release of a public site** and
  reports the result, because bot names change and new bots appear. **Lists last
  checked: 2026-09-26.** When they change, the project's module is updated and
  the human is told, so these default lists and the date are updated too.
- To help AI answers use the site well: concrete facts in the HTML (what it is,
  price, location, contact, policies), consistent entity names, FAQ content with
  `FAQPage` JSON-LD, public help content that explains what the product does,
  trust signals such as reviews, policies, and update dates, and optionally an
  `llms.txt` summary at the site root (the major crawlers do not reliably use it
  yet). Avoid vague marketing copy that hides the facts search engines, AI
  assistants, and users need.

Launch checks for a public site:

- On the production domain, `/robots.txt` and `/sitemap.xml` load and point to
  each other; every non-production environment returns `Disallow: /` and
  `noindex`. An indexed test site is a blocker.
- `robots.txt` blocks the AI training bots by name and blocks no answer bot;
  Cloudflare is not blocking the answer bots either.
- DevOps has verified the domain in Google Search Console and Bing Webmaster
  Tools, the production credentials are set, and one real submission from the
  backend has succeeded (see below).

## Search engine submission

A public site tells Google and Bing about itself from the backend, not by hand.
ChatGPT search, Copilot, and other AI answer tools lean on Bing's index, so Bing
matters as much as Google.

**Backend (Technical Lead, Senior Developer):** build the submission into the
backend from the start. Once the keys exist, a new, changed, or removed public
page reaches the search engines with no manual step:

| Event | Site | Bing and other IndexNow engines | Google |
| --- | --- | --- | --- |
| Page added | Appears in the sitemap with `lastmod` | IndexNow call with the URL | Sitemap resubmitted |
| Page changed | `lastmod` updated; old slug redirects | IndexNow call with the new URL, and the old one if the slug changed | Sitemap resubmitted |
| Page removed | Leaves the sitemap; URL returns 404 or 410 | IndexNow call with the removed URL | Sitemap resubmitted |

- **Bing: IndexNow.** One call covers add, change, and removal, for one URL or a
  batch, and is shared with the other IndexNow engines. It needs a key, and a
  key file the site serves. Microsoft recommends it over the older Bing URL
  Submission API.
- **Google: the sitemap, resubmitted through the Search Console API.** Google has
  no general per-URL add/remove call. Its Indexing API does take update and
  delete notices, but only for job-posting and livestream pages, so use it only
  for those. Keep the sitemap exact and group resubmissions instead of sending
  one per change.
- A page with several language URLs submits each of them.
- Read every credential from the environment. Add each key to `.env.example`
  with an empty value and a comment, so the needed keys are visible:

  ```dotenv
  # Search engine submission. Production only; leave empty elsewhere.
  GOOGLE_SEARCH_CONSOLE_SITE_URL=
  GOOGLE_SEARCH_CONSOLE_CLIENT_EMAIL=
  GOOGLE_SEARCH_CONSOLE_PRIVATE_KEY=
  INDEXNOW_KEY=
  ```

- Submit only in production. With a credential missing, or outside production,
  the call does nothing and logs that it was skipped. A failed submission is
  logged and retried; it never fails the user's action.
- Put the calls behind one interface with a mock for tests.
- Check each vendor's current API documentation before implementing; these APIs
  were last checked on 2026-10-11. Keep the project's own key names when it
  already has them.

**DevOps (technical task):** verify the domain in Google Search Console and Bing
Webmaster Tools, create the API credentials the backend reads, and document
their names, consumers, and environments. The human signs in to the accounts and
enters the real values in the production secret store. If Cloudflare Crawler
Hints already sends IndexNow for the site, say so, so the backend does not send
it twice.

## Engineering

- Consider Next.js for web; React Native for an agreed mobile app; NestJS, .NET,
  Python, or the existing web backend when a separate service is justified.
- Prefer PostgreSQL for relational needs; consider Redis where cache/session/work
  requirements justify it. Do not add a cache or queue just to match a default.
- Prefer a monorepo of actual applications/services with their own docs when a
  new project needs several domains. Preserve an existing repository structure.
- Prefer generated OpenAPI contracts and typed clients when the chosen API stack
  supports them; use the project's package manager and deterministic generation.
- For React-family server state, consider TanStack Query with the shared API client
  rather than duplicating data fetching/cache logic. Keep established equivalents.
- Select identifiers for real product and compatibility needs. UUIDv7 for internal
  keys and a short stable opaque `ref_id` for public URLs (see the public entity
  page default above) are candidates, not an instruction to migrate IDs.
  Identifier obscurity never replaces authorization.

## Quality

The inherited draft coverage target is at least 80% overall automated coverage
for a new project, or at least 80% for changed/new code in an existing project with
no drop in overall coverage. QA Lead establishes the actual metric (line, branch,
etc.), scope, exclusions, and measurement command before implementation. Honor an
existing project policy first, and record justified adaptations when this target
does not fit the work/tooling. Do not hide exclusions or confuse coverage with AC
verification. An unmet agreed gate remains a visible quality gap.

## Infrastructure and release

- Consider PostgreSQL, Portainer, Redis, and Cloudflare where available and useful;
  verify the real environment rather than claiming this user's stack exists in
  every project. New services need the appropriate cost/access decision.
- External service application names prefer `{project}-{env}` where supported.
- When tag-driven GitHub releases fit the project, use an explicit documented
  pattern such as `v1.2.0-web-prod` (`v{version}-{platform}-{env}`). DevOps owns
  the exact trigger and safeguards. A sample is never permission to publish it.
- Daily backups with 30-day retention are a planning baseline for durable stores,
  adjusted to data value, change rate, recovery objectives, cost, and privacy.
  Include actual restore validation; do not back up disposable caches by habit.
- Choose local/test/staging/production needs from risk and infrastructure context.
  The old prod-first rule does not authorize testing on production or secret access.

Do not carry over arbitrary research quotas, fixed agent time boxes, mandatory
repeat critique counts, or provider-specific approvals. Scale evidence and effort
to the decision while preserving the user's locked workflow.
