# Standard stack

The human's standard for a **new** project. An existing project keeps what it
decided; never migrate it. A different choice needs a reason recorded by
Technical Lead; scope, budget, and new services still need the human. Build only
the parts the product uses.

## Applications

- **Backend: NestJS by default.** Technical Lead may choose Python or C# when
  the product needs it, and records why. One API for every client: REST, plus
  WebSocket where needed. PostgreSQL for data, Redis or Valkey for cache, a
  queue or scheduler only when the work needs one.
- **Web: Next.js,** SEO-ready from its first page. A web app entirely behind
  sign-in with no SEO need is a React single-page app instead.
- **Mobile: React Native,** iOS and Android.
- **Web and mobile both call the API.** No business logic or data access in
  Next.js API routes.
- **One exception: standalone Next.js.** A web-only product with no mobile app
  and no separate API may be one Next.js app holding its own logic and data
  access, with Prisma. Technical Lead decides this at the start; the backend
  rules below apply wherever they fit.
- **`frontend-core`** is a shared library with no server. Web and mobile take
  from it the design tokens, shared components, presentation logic, hooks, i18n,
  platform adapters, and the generated API SDK.

## Repository layout

One private monorepo. `frontend_domain_N` is a frontend named after the business
(`customer`, `shop`); a product may have only one:

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
│       ├── components/         atoms/, molecules/, organisms/, templates/
│       ├── frontend_domain_1/  reusable presentation logic for that domain
│       ├── frontend_domain_2/
│       ├── hooks/
│       ├── i18n/
│       ├── platform/           storage, navigation, device adapters
│       └── sdk/                generated API client and types
├── api/
│   ├── docs/
│   │   ├── architecture.html   module map and rules that cross modules
│   │   ├── modules/            one docs folder per module, named like its code folder
│   │   ├── decisions/
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

- Every application (each mobile and each web app) has its own `docs/`. For
  anything from `frontend-core`, its docs link the `frontend-core` document
  instead of repeating it, so it is clear a change there affects every app. An
  app's docs describe only what is specific to it.
- Each application's `README.md` gives its commands and maps its modules to their
  documents and code; the root `README.md` maps the applications
  ([navigate by documents](records.md#navigate-by-documents-not-by-code)).

## One typed contract, end to end

The API is the single source of types. A backend change reaches every client
through two commands:

1. In `api/app`, `yarn generate-openapi` writes `api/docs/api-spec/openapi.json`
   from the controllers and DTOs. A Python or C# API gives the same output
   through its own generator behind one documented command.
2. In `frontend-core`, `yarn generate-spec` reads that file and regenerates the
   typed SDK in `src/sdk/`.

- Web and mobile call the API only through the SDK. They declare no request or
  response types and write no API calls by hand.
- An API change is done only when both commands ran and every app compiles; the
  compiler shows every broken call.
- Both outputs are committed and never edited by hand.
- Both commands need no database, network, or secrets and are deterministic. CI
  runs them and fails on any difference, so a forgotten regeneration cannot
  ship.
- WebSocket messages are not OpenAPI operations: define each payload as a DTO in
  the spec so its type is generated too.
- Document what the schema cannot say: authorization, side effects,
  idempotency, error meaning. Identify external consumers before a breaking
  change.

## Dependencies

- **Pin every version exactly** in `package.json`: `"axios": "1.2.3"`, never
  `^1.2.3` or `~1.2.3`. Commit the lockfile. A range lets in a new release,
  malicious ones included, without anyone choosing it.
- **Install from the lockfile:** `yarn install --immutable` (Yarn 1:
  `--frozen-lockfile`), `npm ci`, or `poetry sync`. CI fails when the lockfile
  would change.
- **Upgrade on purpose:** one dependency per change, through Cybersecurity's
  trust check ([command policy](../roles/cybersecurity.md#command-policy)).
- **Axios:** in March 2026 a maintainer account takeover published two malicious
  axios releases. Wherever axios is used, in an app or the generated SDK, pin
  the same exact version across the repository. Before adding or upgrading,
  confirm the version is a genuine release on the axios GitHub releases page and
  is named in no advisory.

## Shared frontend

- **Shared in full:** tokens, i18n, hooks, presentation logic, the SDK.
- **One interface per UI-system component** in `frontend-core`: props, states,
  behavior. One renderer when the same code works on web and mobile; otherwise a
  web and a native renderer behind that interface. Public web pages still
  produce semantic HTML.
- **An app holds screens, routing, and platform wiring.** It never copies a
  component or logic that belongs in `frontend-core`.
- **Atomic Design:** atoms, molecules, organisms, and templates in
  `frontend-core`; pages in the app. Build screens from existing parts first;
  add a new part at the lowest level that fits.
- **Styling is Tailwind,** with its theme generated from the design tokens;
  NativeWind on React Native so the same classes work. No hand-written CSS files
  or inline values that bypass the tokens.
- **Server state goes through TanStack Query** (`useQuery`, `useMutation`) on
  the SDK. Never fetch server data in `useEffect` or copy it into a client store.
  Clear the whole client cache on login, logout, and user switch.
- **Client state lives at the smallest scope that works;** move up only when the
  smaller one cannot do the job:

  | Scope | Use | For |
  | --- | --- | --- |
  | Component | `useState` / `useReducer` | State one component owns; it lives and dies with it |
  | Lifted | The same hooks, in the nearest common parent | State a few siblings share |
  | Context | React Context | What most screens need: theme, current user, locale, feature flags |
  | Global client store | Zustand | Client state shared across distant screens that Context does not fit |

- **Each side effect has one place,** like the backend's repository and service:

  | Where | Holds | Never holds |
  | --- | --- | --- |
  | Zustand store | State, and setters that keep it consistent with itself: setting one field may reset fields that depend on it | API calls, navigation, storage, analytics, anything asynchronous |
  | Action hook (`useCheckout.ts`) or service | API calls through TanStack Query and the SDK, multi-step mutations, updates to several stores, navigation and messages after a result | Markup |
  | Component | Rendering, and calling the action hook from an event handler | API calls, multi-step logic, effects reacting to store changes |
  | Store `subscribe` | Effects that must run on every change of a state, wherever it came from: persisting to storage, logging, analytics | Business steps that belong to one user action |

  Register each `subscribe` once, at the root component or an init file, never in
  a screen. A component then reads `const { submit, isPending } = useCheckout()`
  and `onClick={submit}`. Record every store slice, what changes with it, and
  every `subscribe` in the module's `flows.html#global-state`
  ([module documents](engineering.md#module-documents-and-rule-identifiers)).
- **Zustand, per its own guides:**
  - One store per app, made of slices (`createCartSlice`, `createFilterSlice`)
    kept in their modules and combined into one bound store. Middleware
    (`persist`, `devtools`) goes on the combined store only.
  - A slice keeps its state and setters together. Update only through `set` or
    `setState`; never mutate.
  - One value per selector: `useBoundStore((s) => s.count)`. For several values,
    wrap the selector in `useShallow`. Never `useBoundStore()` for the whole
    store; it re-renders on every change.
  - Outside React (an action hook's callback, a service, a `subscribe`), use
    `useBoundStore.getState()` and `setState`. React 18 batches these; no
    `unstable_batchedUpdates`.
  - In Next.js, a module-level store is shared by every server request. A store
    with per-user state the server renders is created per request with
    `createStore` inside a Context provider, as Zustand's Next.js guide shows.
  - In tests, reset every store after each test with the `__mocks__/zustand.ts`
    from Zustand's testing guide. Test components with Testing Library and mock
    the network with MSW, not the store.
- **One overlay manager:** a single host rendered once at the app root, with a
  dispatch API (`openModal`, `openPopup`, `confirm`). Screens never render their
  own modal or popup markup. The manager owns focus trap, scroll lock, ESC and
  backdrop behavior, and layering:
  - modals never stack: a second request waits until the first closes;
  - a popup (confirm or alert) may sit on an open modal, one at a time;
  - layering comes from the design's [overlay tokens](design.md#flow-content-and-states),
    never a hard-coded `z-index`;
  - tooltips, dropdowns, and anchored popovers do not go through the manager.
- **Errors go where they belong.** A field error, from the client or the server,
  shows inline at the field. A system error from a submit (network, 500,
  timeout) shows as a toast through one shared toast host. Never a field error
  in a toast.
- **Dates display in the user's time zone with dayjs.** The API sends and
  receives UTC only; convert at display or input.
- **Every user-facing string goes through i18n.** No hard-coded text.
- **Feature flags use Firebase Remote Config.** DevOps sets it up, local
  included.
- **Lists:** paginate on the server beyond about 30 items; make a dropdown
  searchable beyond about 10 options; virtualize any list over 100 items
  (`react-virtuoso` or `@tanstack/react-virtual` on web, the virtualized list on
  React Native); debounce API searches by 600 ms and ignore stale responses, but
  filter an already-loaded list instantly; every table column sortable, on the
  server for a paginated table.

## Frontend performance

- **Colocate state.** State lifted too high re-renders the whole subtree.
- **Split each route into its own bundle** (`React.lazy` and `Suspense`, or the
  framework's route splitting).
- **Server-render when you can.** In Next.js a component is a Server Component
  unless it needs interaction.
- **`useTransition` or `useDeferredValue`** for expensive but tolerable updates,
  such as search-as-you-type over a large loaded set.
- **Memoize only with proof:** add `React.memo`, `useMemo`, or `useCallback`
  when the React Profiler shows a real problem, and say so in a comment.
- **No new objects, arrays, or functions in render passed to a memoized child**
  (`<Child config={{ a: 1 }} />`). Hoist constants.
- **Split a Context holding unrelated values,** so consumers re-render only for
  what they read.
- **Never call a state setter during render.** Compute the value in render, or
  use an effect.

## Images, compression, and caching

- **Every image is WebP.** The API converts each upload to WebP and stores
  responsive sizes; static images in the repo are WebP too.
- **Serve responsive sizes** (`srcset` and `sizes`, or `next/image`), lazy-load
  below the fold, and set `width` and `height` on every image so layout does not
  shift.
- **Serve gzip and Brotli** for text assets and API responses.
- **A CDN in front of everything,** Cloudflare by default, with HTTP/2 or HTTP/3
  at the edge. DevOps sets up compression, the CDN, and these headers:

  | Response | `Cache-Control` |
  | --- | --- |
  | Bundled assets with a content hash in the name (`app.a3f7b9.js`) | `public, max-age=31536000, immutable` |
  | `index.html` and other HTML entry documents | `no-cache` |
  | Cacheable API responses | `public, s-maxage=60, stale-while-revalidate=600` |

- **Only public responses are cacheable.** A response that depends on who asks,
  or carries personal data, is `private, no-store` and never reaches the CDN
  cache. Technical Lead lists the cacheable operations in each module's
  `api-spec.html`.

## Backend

**Layers: controller, service, repository.**

- A **controller** is a transport adapter: input validation, permissions, and
  the response. For a cross-service operation it may call a dedicated
  workflow or orchestrator that holds sequencing and recovery; it never hides
  domain rules.
- A **service** holds its domain's business rules and may use the repositories
  its domain owns. Cross-service operations are coordinated by a controller,
  workflow, or orchestrator, never service to service. Put an external effect
  after the required database write commits, or use the workflow recovery rules
  when it spans transaction boundaries.
- A **repository** is the only thing that talks to the database, and owns one
  table. It saves and reads that table and keeps each record consistent with
  itself: when one column changes, it clears or resets dependent columns of the
  same record. It never updates another table, triggers external effects, or
  owns another service's data.
- A controller never calls a repository; a service never builds a query.
  Ownership, workflows, and multi-write recovery are defined in
  [engineering](engineering.md#implementation-and-data).

Example: a user disconnects Google, and both records belong to the Account
service domain:

```text
AccountService.unbindGoogle(userId)          Account domain operation
  1. userRepository.clearGoogleId(userId)    also clears google_refresh_token,
                                             a column of the same record
  2. accountStorageRepository.disallowGoogleDrive(userId)
                                             another Account-owned table;
                                             repository keeps table ownership
```

Clearing `google_refresh_token` stays in `userRepository`, so no caller can
leave a token behind without a `google_id`. If the Drive permission belonged to
another service, the workflow layer would call that service's interface instead.
Record the same-record rule in `data-dict.html` and every side effect in
`flows.html#side-effects`.

**Runtime and data rules**

- **ORM:** TypeORM with NestJS, behind the repositories; Prisma in a standalone
  Next.js app.
- **Runs in 2 GB of memory.** Paginate or stream instead of loading whole tables
  or files; bound every queue, batch, and concurrent job; keep long work in the
  worker; set the heap limit below the instance size. A design needing more goes
  to the human with its cost.
- **Time is UTC, always.** Store `timestamptz`, compute in UTC with dayjs and its
  UTC plugin, return ISO 8601 with `Z`. Never save or return local time. A time
  zone the business needs (a shop's opening hours) is its own named field beside
  the UTC value.
- **Python uses Poetry:** `pyproject.toml` with a committed `poetry.lock`, a
  `dev` group for formatter, linter, type checker, and tests, a pinned Python
  version, tool config in `pyproject.toml`. No bare `pip` or `requirements.txt`
  for application dependencies.
- **A secret never comes back out of the API.** Once an API key, token, client
  secret, or password is saved, no endpoint returns it, in a detail, a list, or
  a log:
  - a read returns only whether it is set (`{ "hasApiKey": true }`), so the
    screen can show the masked field ([design](design.md#flow-content-and-states));
  - an update is a `PATCH` where a missing or blank secret means "keep"; a
    stored secret is never overwritten with empty;
  - a change with a precondition (the current password) is its own `POST`:
    `POST /account/change-password` with current and new;
  - secrets are encrypted at rest.
- **Immutable data in TypeScript through `readonly`:** `readonly` fields,
  `ReadonlyArray`, `ReadonlyMap`, `ReadonlySet`, `as const` for fixed values,
  and return new values instead of changing arguments. No immutability library.
- **Three logs, in every project:**

  | Log | Records | Kept in |
  | --- | --- | --- |
  | Application log | Requests, errors, and job runs as structured JSON with a request id | Log output, collected by the platform |
  | Audit log | Every create, update, and delete of business data: who, when, what, the record `id`, before and after | An append-only database table |
  | User activity log | What a user did: sign-in and sign-out, key screens and actions, failures they met | A database table, for support and product analysis |

  Never log secrets, tokens, passwords, or full personal data. Cybersecurity
  decides what each log may hold and for how long.
- **Health:** `GET /api/health` returns
  `{status, name, version, release, commit, builtAt}`.
- **Integrations:** every third party has a mock behind the same interface,
  switched by `INTEGRATION_<NAME>_MODE=mock|real`, `mock` by default locally and
  in tests.
- **Caching is refresh-ahead by default:** serve the cached value while a
  background task recomputes it. Use invalidation or write-through only for
  strict data (balances, permissions, stock at checkout), agreed with PO. Record
  the strategy and interval. A cache holding per-user or per-tenant data is
  keyed by that identity or cleared at sign-in.
- **Environment files:** per-environment values live in `.env.{env}`. Only
  `.env.example` is committed, listing every key with an empty or fake value.

**Local databases**

- **Ask first.** Before setting up a local database or Redis, ask the human how
  it should run: docker-compose (recommended), the human sets it up, an existing
  or cloud dev database, or something else. Record the answer in the service's
  `README.md`. With docker-compose: non-default host ports (PostgreSQL `5436`,
  Redis `6378`), source mounted for live reload, multi-arch images (arm64 and
  amd64), and a small start/stop/shell/clean helper script.
- **Never drop, reset, or re-seed a database without the human's explicit OK,**
  every time. Two exceptions, in the
  [command policy](../roles/cybersecurity.md#command-policy): a Lead has full
  access to the human's local dev database and treats it as production, dumping
  it before anything destructive; and a worker may drop its own database
  (below). Seeding a new, empty worker database is not a reset.
- **A worker gets its own database only when its task needs database-backed
  work or verification.** Otherwise none. By default: a fresh local database
  named for its worktree with the `_wt_` marker, migrations run, a small
  deterministic synthetic seed that Senior QA keeps current with every
  migration ([test-first](quality.md#test-first-and-who-writes-which-test)). Parallel workers never share mutable state.
  Redis gets its own key prefix or database number per worker. Drop the worker's
  database when its task finishes or is abandoned.
- **Large snapshots only for a stated test need:** realistic volume or skew,
  migration from existing state, performance or query-plan checks, or anything
  else synthetic data cannot show. Use a sanitized fixture or copy-on-write
  clone. Never unsanitized production data, and never a clone just to isolate
  workers.
- **The human's local connection is the source.** Each human keeps their own
  connection where the stack expects it (`.env`, `.env.local`,
  `appsettings.Development.json`), git-ignored. Never assume a host, user, or
  password. If the file or connection is missing, create it from the keys in
  `.env.example` with empty values and ask the human to fill it in.
- **Reading it needs the human's OK once per project,** recorded in the
  service's `README.md` ([contract](contract.md#access-and-human-authority)).
- **A worker gets only the connection, with its own database name.** The Lead
  copies host, port, user, and password into the worktree's `.env.test`, with
  the database name replaced by the worker's `_wt_` name. Nothing else from the
  human's file.
- **Before dropping, check where the database is.** Drop only when the host is
  `localhost`, `127.0.0.1`, or `::1` and the name is the worker's own `_wt_`
  database. Otherwise leave it and alert the human with the host and name. The
  local user may be able to drop anything on the server; these checks protect
  the human's databases. Anything shared, remote, or differently named needs the
  human's OK.

## Identifiers and public URLs

Every project uses two ids, one purpose each:

| Id | What it is | Used for |
| --- | --- | --- |
| `id` | UUIDv7 primary key on every table | relations, APIs, admin and edit pages, every create, update, and delete |
| `ref_id` | the encrypted sequence number, `char(6)` base62, on tables with public pages | public URLs only |

- **`id` is UUIDv7,** so sorting by it gives creation order. Generate it with
  `uuidv7()` on PostgreSQL 18+, otherwise in the application.
- **`ref_id` is for public URLs only.** Never accept it where an `id` belongs,
  and never tell them apart by length. To resolve one, add an explicit
  `GET /api/<resource>/by-ref/{ref_id}` that returns the record with its `id`.
- **Generate `ref_id` with the supplied module, [ref-id.ts](../assets/ref-id.ts),
  in every project.** Copy it into the API's shared library. Never re-implement
  or replace it. A Python or C# API ports it line for line and proves the port
  gives the same output for the same inputs.

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
  row. Never recomputed. The raw sequence number is never stored or shown; it
  reveals how many rows exist.
- **Do not weaken the module.** It is format-preserving encryption: a 10-round
  Feistel network with HMAC-SHA256. Never swap in a fast hash, cut rounds, or
  drop the range check. Plain base62, Hashids, and Sqids are reversible
  encodings, not acceptable. The entity type is the tweak, so product 42 and
  category 42 differ.
- **Key: `REF_ID_KEY`,** at least 32 random bytes in base64, one per
  environment. DevOps documents it, the human enters the value, `.env.example`
  lists it empty. Keep it stable: a new key can produce a `ref_id` that already
  exists.
- **It is not access control.** It stops enumeration and hides volume; every
  endpoint still checks authorization.

Public URLs are `/{title-slug}-{ref_id}` (`/pick-hand-fan-0l78Xd`), or
`/{category-slug}-{ref_id}/{title-slug}-{ref_id}` when items nest under
categories:

- **The `ref_id` is authoritative; the slug is for people and search.** Take the
  text after the last hyphen, check it with `refId.isValid`, and look up by
  `ref_id`.
- **No slug column.** One shared `slugify` builds the slug from the current
  title in its own language: lowercase, words joined by `-`, about 80 characters
  at most. Add a slug column only if editors need custom slugs.
- **One URL per language,** each from that language's title, all sharing the
  `ref_id`, linked as language alternates ([defaults](project-defaults.md)).
- **A slug that is not current redirects permanently** (301/308) to the
  canonical URL. Never serve the same content on two URLs.
- **A bad or unknown `ref_id` returns 404,** never a 500 or an explanation.
- The canonical tag and sitemap use canonical URLs only. API responses that feed
  public links include `ref_id` and the title.

## Next.js SEO checklist

Every Next.js site follows this from its first page:

- **`app/robots.ts`** allows the site, disallows only non-page paths such as
  `/api/`, blocks the AI training bots by name
  ([AI crawlers](project-defaults.md#ai-crawlers-found-by-ai-answers-not-used-for-training)),
  points to the sitemap, and reads `SITE_ENV` per request, not at build.
- **`app/sitemap.ts`** lists canonical URLs only, with `lastModified` from real
  update times, split with `generateSitemaps` past 50,000 URLs.
- **Non-production is never indexed.** Outside `SITE_ENV=prod`, `robots.txt`
  returns `Disallow: /` and every page sends `noindex`.
- **Hide a private page with `noindex`** and leave it out of the sitemap. Do not
  also block it in `robots.txt`, or the crawler never sees the `noindex`.
- **Metadata on every page:** `metadataBase` and a title template in the root
  layout; per page a unique title and description, the canonical URL,
  `hreflang` alternates with `x-default` and `<html lang>` on a multilingual
  site, and Open Graph and Twitter card data with an image.
- **JSON-LD per page type,** rendered from the server component with `<`
  escaped, matching what the page shows. Validate it with Google's Rich Results
  Test before release.
- **Indexable content is in the initial HTML.** Render public pages as Server
  Components; with TanStack Query, prefetch on the server and hydrate.
- **Real status codes:** `notFound()` for 404, `permanentRedirect()` for a moved
  page. Never a "not found" page that returns 200.
- **Semantic HTML and crawlable links:** one `h1`, logical headings, `<main>`
  and `<nav>`, `alt` text, navigation through real `href`s.
- **Core Web Vitals:** `next/image` with correct `sizes`, `priority` only on the
  largest above-the-fold image, `next/font`, a small client bundle, lazy loading
  below the fold. Check Lighthouse on key page types before release.
