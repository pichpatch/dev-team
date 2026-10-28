# Project defaults

These are the human's standard choices for a **new** project. An existing project
keeps what it decided; never migrate it to match. A different choice needs a
reason recorded by the owning role. Scope, budget, buying services,
authentication, and production actions still need the human.

## Product and design

- **Responsive, mobile-first web** for web products. Do not add mobile apps just
  because the stack supports them.
- **Editable HTML/CSS UI-system examples and clickable HTML mockups** when no
  design format exists. Existing design tools stay valid; record one
  authoritative source and how it maps to code.
- **Thai/English and light/dark themes:** propose them for a new user-facing
  product. PO settles scope; Design Lead specifies behavior. Never silently add
  languages or themes to a feature agreed with one.
- **Social login:** when in scope, consider Google and Apple first against the
  audience and platforms. Existing SSO or agreed authentication wins. This never
  authorizes creating accounts or providers.
- **Tables** are sortable by every column by default. PO names any column that
  should not be, with the reason, in the AC.
- **Public entity pages** (product, category, article, profile) use
  `/{title-slug}-{ref_id}`, for example `/pick-hand-fan-0l78Xd`, with `ref_id`
  from the [standard stack](stack.md#identifiers-and-public-urls).
  - The slug comes from the title in its own language: a Thai title gives a Thai
    slug. Do not transliterate unless agreed.
  - One URL per language: each from that language's title, all sharing the
    `ref_id`, linked as language alternates.
  - An outdated or wrong slug redirects to the current URL; an unknown `ref_id`
    returns 404.
  - PO states this behavior in the AC; Technical Lead decides how a request's
    language is determined.
- **AI crawlers:** a public site is found by AI answers but not used for
  training ([below](#ai-crawlers-found-by-ai-answers-not-used-for-training)).
- **Onboarding:** keep helpful empty and first-use states, and document new
  concepts as features add them. A separate product tour is later scope, only
  when agreed, and never delays essential setup.

## AI crawlers: found by AI answers, not used for training

The default for every public site (the human's decision; PO records any
exception): **AI answer engines may read the site, so people can find the
business through ChatGPT, Claude, Perplexity, Gemini, and others. AI training
bots are blocked.**

**Allowed search and answer bots (never block):**
`Googlebot` (Google Search, including AI Overviews and AI Mode) · `Bingbot` (Bing
and Copilot; other AI search tools use Bing's index too) · `OAI-SearchBot`,
`ChatGPT-User` (ChatGPT) · `Claude-SearchBot`, `Claude-User` (Claude) ·
`PerplexityBot`, `Perplexity-User` (Perplexity) · `Applebot` (Siri, Spotlight) ·
`DuckAssistBot` (DuckDuckGo) · `MistralAI-User` (Le Chat) ·
`Meta-ExternalFetcher` (Meta AI, user-requested)

**Blocked training and dataset bots:**
`GPTBot` (OpenAI) · `ClaudeBot` (Anthropic) · `Google-Extended` (Gemini) ·
`Applebot-Extended` (Apple) · `Meta-ExternalAgent` (Meta) · `CCBot` (Common Crawl) ·
`Bytespider` (ByteDance) · `cohere-training-data-crawler` (Cohere)

Keep the blocked list in **one module** per project (for example
`src/seo/ai-crawlers.ts`) that the robots file reads. Every bot not on it falls
under `*` and stays allowed. For Next.js:

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

- **`Google-Extended` is the one judgment call.** Blocking it keeps content out
  of Gemini training and may keep the site out of Gemini app answers. Google
  Search, AI Overviews, and AI Mode are unaffected; they use `Googlebot`.
- **robots.txt is a request, not a lock.** Blocking bots that ignore it is
  Cloudflare's job (DevOps). DevOps also makes sure Cloudflare never blocks the
  answer bots and a managed robots.txt never contradicts the site's rules.
- **Cybersecurity checks the lists at every release** of a public site, because
  bot names change. **Lists last checked: 2026-09-26.** When they change, the
  project's module is updated, the human is told, and these lists and the date
  are updated too.
- **Help AI answers use the site well:** concrete facts in the HTML (what it is,
  price, location, contact, policies), consistent entity names, FAQ content with
  `FAQPage` JSON-LD, public help content, trust signals (reviews, policies,
  update dates), and optionally an `llms.txt` summary at the root (major crawlers
  do not reliably use it yet). Avoid vague marketing copy that hides the facts.

**Launch checks for a public site:**

- On production, `/robots.txt` and `/sitemap.xml` load and point to each other.
  Every non-production environment returns `Disallow: /` and `noindex`. An
  indexed test site is a blocker.
- `robots.txt` blocks the training bots by name and no answer bot; Cloudflare
  does not block the answer bots either.
- DevOps has verified the domain in Google Search Console and Bing Webmaster
  Tools, production credentials are set, and one real submission from the
  backend has succeeded ([below](#search-engine-submission)).

## Search engine submission

A public site tells Google and Bing about itself from the backend, never by
hand. ChatGPT search, Copilot, and other AI tools lean on Bing's index, so Bing
matters as much as Google.

**Backend (Technical Lead, Senior Developer):** build submission in from the
start. Once the keys exist, every new, changed, or removed public page reaches
the search engines with no manual step:

| Event | Site | Bing and other IndexNow engines | Google |
| --- | --- | --- | --- |
| Page added | Appears in the sitemap with `lastmod` | IndexNow call with the URL | Sitemap resubmitted |
| Page changed | `lastmod` updated; old slug redirects | IndexNow call with the new URL, and the old one if the slug changed | Sitemap resubmitted |
| Page removed | Leaves the sitemap; URL returns 404 or 410 | IndexNow call with the removed URL | Sitemap resubmitted |

- **Bing: IndexNow.** One call covers add, change, and remove, for one URL or a
  batch, shared with other IndexNow engines. It needs a key and a key file the
  site serves. Microsoft recommends it over the older URL Submission API.
- **Google: resubmit the sitemap through the Search Console API.** Google has no
  general per-URL call; its Indexing API is only for job-posting and livestream
  pages. Keep the sitemap exact and batch resubmissions.
- A page with several language URLs submits each.
- Read every credential from the environment, and list each key in
  `.env.example` with an empty value and a comment:

  ```dotenv
  # Search engine submission. Production only; leave empty elsewhere.
  GOOGLE_SEARCH_CONSOLE_SITE_URL=
  GOOGLE_SEARCH_CONSOLE_CLIENT_EMAIL=
  GOOGLE_SEARCH_CONSOLE_PRIVATE_KEY=
  INDEXNOW_KEY=
  ```

- Submit only in production. With a missing credential or outside production,
  the call does nothing and logs the skip. A failed submission is logged and
  retried; it never fails the user's action.
- Put the calls behind one interface with a mock for tests.
- Check each vendor's current API docs before building (last checked
  2026-10-11). Keep the project's existing key names.

**DevOps:** verify the domain in Google Search Console and Bing Webmaster Tools,
create the API credentials the backend reads, and document their names,
consumers, and environments. The human signs in and enters the real values in
the production secret store. If Cloudflare Crawler Hints already sends IndexNow,
say so, so the backend does not send it twice.

## Engineering

Follow the [standard stack](stack.md): NestJS for the API by default, Next.js or
a React single-page app for web, React Native for mobile, a shared
`frontend-core`, one typed contract generated from the API, the repository
layout, the `id` and `ref_id` rules, and the Next.js SEO checklist.

## Quality

Coverage target: at least 80% overall for a new project; for an existing project
with no policy, at least 80% on new or changed code with no drop overall. QA Lead
sets the metric (line, branch, ...), scope, exclusions, and command before
implementation. An existing project policy comes first; record justified
adaptations. Never hide exclusions or confuse coverage with AC verification. An
unmet agreed gate stays a visible gap.

## Infrastructure and release

- Consider PostgreSQL, Portainer, Redis, and Cloudflare where available and
  useful. Check the real environment instead of assuming this stack. New
  services need a cost and access decision.
- External service names prefer `{project}-{env}`.
- When tag-driven releases fit, use a documented pattern such as
  `v1.2.0-web-prod` (`v{version}-{platform}-{env}`). DevOps owns the trigger and
  safeguards. A sample is never permission to publish.
- Daily backups with 30-day retention are a planning baseline for durable
  stores, adjusted to data value, change rate, recovery goals, cost, and privacy.
  Include real restore tests; do not back up disposable caches by habit.
- Choose local, test, staging, and production needs from risk and context.
  Nothing here authorizes testing on production or reading secrets.

No arbitrary research quotas, fixed agent time limits, mandatory critique
counts, or provider-specific approvals. Scale evidence and effort to the
decision, within the human's workflow.
