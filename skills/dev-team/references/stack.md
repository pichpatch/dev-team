# Standard stack

This is the human's standard for a new project. An existing project keeps what it
already decided; do not migrate it. For a new project, follow this. A different
choice needs a reason recorded by Technical Lead, and anything that touches scope,
budget, or a new service still needs the human. Not every project needs every
part: create only what the product uses.

## Applications

- **Backend: NestJS.** One API for every client, REST plus WebSocket where the
  product needs it. PostgreSQL for data, Redis or Valkey for server cache, and a
  queue or scheduler only when the work needs one.
- **Web: Next.js**, SEO-ready from its first page. A web app that sits entirely
  behind sign-in and needs no SEO is a React single-page app instead.
- **Mobile: React Native**, iOS and Android.
- **Web and mobile both call the NestJS API.** Put no business logic or data
  access in Next.js API routes.
- **`frontend-core`** is a shared library with no running server. Web and mobile
  take from it the design tokens, shared components, presentation logic, hooks,
  i18n, platform adapters, and the generated API SDK.

## Repository layout

One private monorepo. `frontend_domain_N` stands for a frontend domain named
after the business, such as `customer` or `shop`; a product may have only one:

```text
alpha-food/
├── docs/                       requirements, UI system, project reports
├── frontend_domain_1/
│   ├── docs/                   mobile flows, mockups, decisions
│   └── app/                    React Native: iOS + Android
├── frontend_domain_2/
│   ├── docs/
│   └── app/                    React Native: iOS + Android
├── web/
│   ├── frontend_domain_1/      independent Next.js application
│   │   └── docs/               web flows, mockups, decisions
│   └── frontend_domain_2/      independent Next.js application
│       └── docs/
├── frontend-core/              shared library; no running server
│   ├── docs/
│   └── src/
│       ├── tokens/             colors, spacing, typography
│       ├── components/         shared component interfaces and renderers
│       ├── frontend_domain_1/  reusable presentation logic for that domain
│       ├── frontend_domain_2/
│       ├── hooks/
│       ├── i18n/
│       ├── platform/           storage, navigation, device adapters
│       └── sdk/                generated API client and types
├── api/
│   ├── docs/
│   │   └── api-spec/openapi.json
│   └── app/
│       ├── modules/            business modules, REST + WebSocket
│       ├── jobs/               background handlers
│       └── entrypoints/        API and separate worker startup
└── infra/
    ├── docs/
    ├── cache/                  Redis/Valkey configuration
    ├── queue/                  SQS configuration
    ├── scheduler/              scheduling configuration
    ├── containers/
    └── terraform/
```

Every application has its own `docs/`: each mobile app and each web app. When an
app uses something from `frontend-core`, its docs link to the `frontend-core`
document instead of describing it again. The link tells a person or an agent that
the thing is shared, so changing it there changes every app that links to it.
What an app's own docs describe is only what is specific to that app.

Each folder with documents has a `README.md` that indexes them
([records](records.md)).

## One typed contract, end to end

The API is the single source of types. A backend change reaches every client
through two commands:

1. In `api/app`, `yarn generate-openapi` writes `api/docs/api-spec/openapi.json`
   from the NestJS controllers and DTOs.
2. In `frontend-core`, `yarn generate-spec` reads that file and regenerates the
   typed SDK in `src/sdk/`.

- Web and mobile call the API only through the SDK from `frontend-core`. They
  declare no request or response types and write no API calls by hand.
- An API change is not done until both commands have run and every app compiles.
  The compiler shows each call the change broke.
- Both outputs are committed and never edited by hand.
- Both commands need no database, network, or secrets, and give the same output
  for the same input. CI runs them and fails on any difference, so a forgotten
  regeneration cannot ship.
- WebSocket messages are not OpenAPI operations. Define each message payload as a
  DTO included in the spec, so its type is generated too.
- Document what the schema cannot say: authorization, side effects, idempotency,
  and what each error means. Identify external consumers before a breaking change.

## Shared frontend

- Tokens, i18n, hooks, presentation logic, and the SDK are shared in full.
- Each named UI-system component has one interface in `frontend-core`: its props,
  states, and behavior. It has one renderer when the same code works on web and
  mobile, otherwise a web renderer and a native renderer behind that interface.
  Public web pages must still produce semantic HTML.
- An app holds screens, routing, and platform wiring. It does not copy a
  component or repeat logic that belongs in `frontend-core`.
- **Server state goes through TanStack Query** (`useQuery`, `useMutation`) calling
  the SDK. Never fetch server data inside `useEffect`. Clear the whole client
  cache on login, logout, and user switch.
- **Every user-facing string goes through the i18n library.** No hard-coded text.
- **Feature flags use Firebase Remote Config.** DevOps sets it up, local
  environment included.
- **Lists:** paginate on the server beyond about 30 items; make a dropdown
  searchable beyond about 10 options; virtualize long lists; debounce a search
  that calls the API by 600 ms and ignore stale responses, but filter an
  already-loaded list instantly; make every table column sortable, on the server
  for a paginated table.

## Backend

- **Health:** `GET /api/health` returns
  `{status, name, version, release, commit, builtAt}`.
- **Integrations:** every third-party integration has a mock behind the same
  interface, switched by `INTEGRATION_<NAME>_MODE=mock|real`, and `mock` by
  default in local and test.
- **Caching: refresh-ahead by default.** Serve the cached value while a
  background task recomputes it. Use invalidation or write-through only for data
  that needs strict correctness, such as balances, permissions, or stock at
  checkout, agreed with PO. Record the strategy and the refresh interval. A cache
  that can hold per-user or per-tenant data is keyed by that identity or cleared
  at the sign-in boundary.
- **Environment files:** per-environment values live in `.env.{env}`. Only
  `.env.example` is committed, listing every key with an empty or fake value.
- **Local database: ask first.** Before setting up a local database or Redis,
  ask the human how it should run: docker-compose (recommended), the human sets
  it up, an existing or cloud development database, or something else. Record
  the answer in the service's `README.md` so it is not asked again.
- **Never drop, reset, or re-seed a database without the human's explicit OK**,
  every time.

## Identifiers and public URLs

Every project uses two ids, one purpose each:

| Id | What it is | Used for |
| --- | --- | --- |
| `id` | UUIDv7 primary key on every table | relations, APIs, admin and edit pages, every create, update, and delete |
| `ref_id` | the encrypted sequence number, `char(6)` base62, on tables with public pages | public URLs only |

- **`id` is UUIDv7**, so sorting by it gives creation order. Generate it with
  `uuidv7()` on PostgreSQL 18+, otherwise in the application.
- **`ref_id` is for public URLs only.** Never accept it where an `id` belongs, and
  never tell the two apart by length. When a client needs to resolve one, add an
  explicit `GET /api/<resource>/by-ref/{ref_id}` that returns the record with its
  `id`.
- **Generate `ref_id` with the supplied module, [ref-id.ts](../assets/ref-id.ts),
  in every project.** Copy it into the API's shared library. Do not re-implement
  it per feature and do not replace it with another method.

  ```sql
  CREATE SEQUENCE products_ref_seq MAXVALUE 4294967295; -- stays inside the module's 32-bit range
  CREATE TABLE products (
    id      uuid PRIMARY KEY DEFAULT uuidv7(),
    ref_id  char(6) NOT NULL UNIQUE,  -- encrypted sequence number, public URLs only
    ...
  );
  ```

- **Created once, on insert.** The create operation takes the next sequence
  value, encrypts it with `refId.encode("product", n)`, and inserts it with the
  row. It is never recomputed. The raw sequence number is never stored in a
  column or shown anywhere, because it reveals how many rows exist.
- **Do not weaken the module.** It is format-preserving encryption: a 10-round
  Feistel network with HMAC-SHA256. Never swap in a fast hash, cut the rounds, or
  drop the input range check. Plain base62, Hashids, and Sqids are encodings
  anyone can reverse, so they are not acceptable. The entity type is the tweak,
  so product 42 and category 42 get different values.
- **Key: `REF_ID_KEY`**, at least 32 random bytes in base64, one per environment.
  DevOps documents it, the human enters the value, and `.env.example` lists the
  key empty. Keep it stable: a new key can produce a `ref_id` that already exists.
- **It is not access control.** It stops enumeration and hides volume; every
  endpoint still checks authorization.

Public URLs are `/{title-slug}-{ref_id}`, for example `/pick-hand-fan-0l78Xd`, or
`/{category-slug}-{ref_id}/{title-slug}-{ref_id}` when items nest under
categories:

- **The `ref_id` is authoritative; the slug is for people and search.** Take the
  text after the last hyphen as the `ref_id`, check it with `refId.isValid`, and
  look the row up by `ref_id`.
- **No slug column.** One shared `slugify` builds the slug from the current title
  in that title's language: lowercase, words joined by `-`, about 80 characters
  at most. Add a slug column only if editors need custom slugs.
- **One URL per language.** An entity with one language has one URL; one with
  several has a URL per language, each from that language's title, all sharing
  the `ref_id` and linked as language alternates
  ([project defaults](project-defaults.md)).
- **A slug that is not current redirects permanently** (301/308) to the canonical
  URL. Never serve the same content on two URLs.
- **A bad or unknown `ref_id` returns 404**, never a 500 or an explanation.
- The canonical tag and the sitemap use canonical URLs only. API responses that
  feed public links include `ref_id` and the title.

## Next.js SEO checklist

Every Next.js site is built this way from its first page:

- **`app/robots.ts`** allows the site, disallows only non-page paths such as
  `/api/`, blocks the AI training bots by name
  ([AI crawlers](project-defaults.md)), and points to the sitemap. It reads
  `SITE_ENV` per request, not at build.
- **`app/sitemap.ts`** lists canonical URLs only, with `lastModified` from real
  update times, split with `generateSitemaps` past 50,000 URLs.
- **Non-production is never indexed.** Outside `SITE_ENV=prod`, `robots.txt`
  returns `Disallow: /` and every page sends `noindex`.
- **Hide a private page with `noindex`** and leave it out of the sitemap. Do not
  also block it in `robots.txt`, or the crawler never sees the `noindex`.
- **Metadata on every page:** `metadataBase` and a title template in the root
  layout; per page a unique title and description, the canonical URL, `hreflang`
  alternates with `x-default` and `<html lang>` on a multilingual site, and Open
  Graph and Twitter card data with an image.
- **JSON-LD per page type**, rendered from the server component with `<` escaped,
  with values that match what the page shows. Validate it with Google's Rich
  Results Test before release.
- **Indexable content is in the initial HTML.** Render public pages as Server
  Components; with TanStack Query, prefetch on the server and hydrate.
- **Real status codes:** `notFound()` for 404 and `permanentRedirect()` for a
  moved page. Never a "not found" page that returns 200.
- **Semantic HTML and crawlable links:** one `h1`, logical headings, `<main>` and
  `<nav>`, `alt` text, and navigation through real `href`s.
- **Core Web Vitals:** `next/image` with correct `sizes` and `priority` only on
  the largest above-the-fold image, `next/font`, a small client bundle, and lazy
  loading below the fold. Check Lighthouse on the key page types before release.
