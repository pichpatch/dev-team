# Standard stack

This is the human's standard for a new project. An existing project keeps what it
already decided; do not migrate it. For a new project, follow this. A different
choice needs a reason recorded by Technical Lead, and anything that touches scope,
budget, or a new service still needs the human. Not every project needs every
part: create only what the product uses.

## Applications

- **Backend: NestJS by default.** Technical Lead may choose Python or C# when
  the product needs it, and records why. One API for every client, REST plus
  WebSocket where the product needs it. PostgreSQL for data, Redis or Valkey for
  server cache, and a queue or scheduler only when the work needs one.
- **Web: Next.js**, SEO-ready from its first page. A web app that sits entirely
  behind sign-in and needs no SEO is a React single-page app instead.
- **Mobile: React Native**, iOS and Android.
- **Web and mobile both call the API.** Put no business logic or data access in
  Next.js API routes.
- **Standalone Next.js is the one exception.** A web-only product with no mobile
  app and no separate API may be a single Next.js application that holds its own
  business logic and data access, using Prisma. Technical Lead decides this at
  the start; it follows the backend rules below wherever they apply.
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

Every application has its own `docs/`: each mobile app and each web app. When an
app uses something from `frontend-core`, its docs link to the `frontend-core`
document instead of describing it again. The link tells a person or an agent that
the thing is shared, so changing it there changes every app that links to it.
What an app's own docs describe is only what is specific to that app.

Each application has a `README.md` that gives its commands and maps its modules
to their documents and code, and the root `README.md` maps the applications. An
agent reaches any file through those maps instead of searching the code
([navigate by documents](records.md)).

## One typed contract, end to end

The API is the single source of types. A backend change reaches every client
through two commands:

1. In `api/app`, `yarn generate-openapi` writes `api/docs/api-spec/openapi.json`
   from the controllers and DTOs. A Python or C# API provides the same output
   through its own generator behind one documented command.
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
- **Components follow Atomic Design:** atoms, molecules, organisms, and
  templates in `frontend-core`; pages in the app. Build a screen from existing
  parts first, and add a new part at the lowest level that fits.
- **Styling is Tailwind**, with its theme generated from the design tokens. On
  React Native use NativeWind, so the same token classes work on mobile. No
  hand-written CSS files or inline style values that bypass the tokens.
- **Server state goes through TanStack Query** (`useQuery`, `useMutation`) calling
  the SDK. Never fetch server data inside `useEffect`, and never copy it into a
  client store. Clear the whole client cache on login, logout, and user switch.
- **Client state lives at the smallest scope that works.** Go up a step only
  when the one below cannot do the job:

  | Scope | Use | For |
  | --- | --- | --- |
  | Component | `useState` / `useReducer` | State one component owns; it lives and dies with the component |
  | Lifted | The same hooks, in the nearest common parent | State a few sibling components share |
  | Context | React Context | What most screens need: theme, current user, locale, feature flags |
  | Global client store | Zustand | Client state shared across distant screens that Context does not fit |

- **Side effects have one place each,** mirroring the backend's repository and
  service:

  | Where | Holds | Never holds |
  | --- | --- | --- |
  | Zustand store | State, and setters that keep that state consistent with itself: setting one field may reset the fields that depend on it | API calls, navigation, storage, analytics, anything asynchronous |
  | Action hook (`useCheckout.ts`) or service | API calls through TanStack Query and the SDK, multi-step mutations, updates to several stores, navigation and messages that follow a result | Markup |
  | Component | Rendering, and a call to the action hook from an event handler | API calls, multi-step logic, effects that react to store changes |
  | Store `subscribe` | Effects that must run whenever a state changes, wherever the change came from: persisting to local storage, logging, analytics | Business steps that belong to one user action |

  Register each `subscribe` once, in the root component or a dedicated
  initialization file, never inside a screen. A component then reads as
  `const { submit, isPending } = useCheckout()` and `onClick={submit}`. Record
  every global store, what changes when it changes, and every `subscribe` in the
  module's `flows.html#global-state` ([module documents](engineering.md)).
- **One overlay manager.** A single overlay host is rendered once at the app
  root, with a dispatch API (`openModal`, `openPopup`, `confirm`). Screens never
  render their own modal or popup markup. The manager owns the focus trap,
  scroll lock, ESC and backdrop behavior, and layering:
  - Modals never stack: a second modal request waits until the first closes.
  - A popup (a confirm or alert) may appear on top of an open modal, one at a
    time.
  - Layering comes from the design's
    [overlay layer tokens](design.md), never a hard-coded `z-index`.
  - Tooltips, dropdowns, and popovers anchored to their trigger are not routed
    through the manager.
- **Errors go where they belong.** A field error, from client validation or
  returned by the server, shows inline at the field. A system error from a
  submit (network, 500, timeout) shows as a toast through one shared toast host.
  Never put a field error in a toast.
- **Dates display in the user's time zone, through dayjs.** The API sends and
  receives UTC only; convert at the moment of display or input.
- **Every user-facing string goes through the i18n library.** No hard-coded text.
- **Feature flags use Firebase Remote Config.** DevOps sets it up, local
  environment included.
- **Lists:** paginate on the server beyond about 30 items; make a dropdown
  searchable beyond about 10 options; virtualize any list over 100 items
  (`react-virtuoso` or `@tanstack/react-virtual` on web, the virtualized list
  component on React Native); debounce a search
  that calls the API by 600 ms and ignore stale responses, but filter an
  already-loaded list instantly; make every table column sortable, on the server
  for a paginated table.

## Frontend performance

- **Colocate state.** State lifted too high re-renders the whole subtree on
  every change.
- **Split each route into its own bundle** with `React.lazy` and `Suspense`, or
  the framework's route splitting.
- **Server-render when you can.** In Next.js, a component is a Server Component
  unless it needs interaction.
- **Use `useTransition` or `useDeferredValue`** for expensive but tolerable
  updates, such as search-as-you-type over a large loaded set.
- **Memoize only with proof.** Add `React.memo`, `useMemo`, or `useCallback` when
  the React Profiler shows a real problem, and say so in a comment.
- **Do not create objects, arrays, or functions in render to pass as props** to
  a memoized child, as in `<Child config={{ a: 1 }} />`. Hoist constants out.
- **Split a Context that holds unrelated values**, so a consumer re-renders only
  for what it reads.
- **Never call a state setter during render.** Compute the value in render, or
  use an effect.

## Images, compression, and caching

- **Every image is WebP.** The API converts each uploaded image to WebP and
  stores responsive sizes; static images in the repository are WebP too.
- **Serve responsive sizes** (`srcset` and `sizes`, or `next/image`), lazy-load
  images below the fold, and set `width` and `height` on every image so the
  layout does not shift.
- **Serve gzip and Brotli** for text assets and API responses.
- **A CDN sits in front of everything,** Cloudflare by default, with HTTP/2 or
  HTTP/3 at the edge. DevOps sets up compression, the CDN, and these headers:

  | Response | `Cache-Control` |
  | --- | --- |
  | Bundled assets, with a content hash in the filename (`app.a3f7b9.js`) | `public, max-age=31536000, immutable` |
  | `index.html` and other HTML entry documents | `no-cache` |
  | Cacheable API responses | `public, s-maxage=60, stale-while-revalidate=600` |

- **Only public responses are cacheable.** A response that depends on who is
  asking, or carries personal data, is `private, no-store` and never reaches the
  CDN cache. Technical Lead lists the cacheable operations in each module's
  `api-spec.html`.

## Backend

- **Layers: controller, service, repository.** A controller is a transport
  adapter: it handles input validation, permissions, and the response. For a
  cross-service operation, it may invoke a dedicated controller/workflow/
  orchestrator boundary that holds sequencing and recovery; it does not hide
  domain rules in a service. A service holds its domain's business rules. A
  repository is the only place that talks to the database. A controller never
  calls a repository, and a service never builds a query. Service ownership,
  workflow boundaries, and multi-write transaction/recovery requirements are
  defined in [engineering practices](engineering.md).
- **A repository owns one table.** It saves and reads its table and keeps each
  record consistent with itself: when one column changes, it clears or resets
  dependent columns on that same record. It does not update another table,
  trigger external effects, or own another service's data.
- **A service owns its domain and data access.** It may use repositories for
  data owned by that service. Cross-service operations are coordinated by a
  controller, workflow, or orchestrator, not by direct service-to-service
  orchestration. Put an external effect after the required database operation
  commits, or use the documented workflow recovery rules when it spans
  independent transaction boundaries.

  For example, when a user disconnects Google and both records below belong to
  the same Account service domain:

  ```text
  AccountService.unbindGoogle(userId)          Account domain operation
    1. userRepository.clearGoogleId(userId)    also clears google_refresh_token,
                                               a column of the same record
    2. accountStorageRepository.disallowGoogleDrive(userId)
                                               another Account-owned table;
                                               repository keeps table ownership
  ```

  Clearing `google_refresh_token` stays in `userRepository`, because no caller
  should be able to leave a token behind without a `google_id`. If the Drive
  permission belongs to another service, the workflow layer coordinates that
  service through its interface; the Account service does not query its table.
  Record the same-record rule in the module's `data-dict.html` and every side
  effect in its `flows.html#side-effects` ([module documents](engineering.md)).
- **ORM:** TypeORM with NestJS, behind the repositories. Prisma in a standalone
  Next.js application.
- **Runs in 2 GB of memory.** Design for an instance of that size: paginate or
  stream instead of loading a whole table or file, bound every queue, batch, and
  concurrent job, keep long work in the worker, and set the runtime's heap limit
  below the instance size. A design that needs more is raised to the human with
  its cost.
- **Time is UTC, always.** Store `timestamptz`, compute in UTC with dayjs and its
  UTC plugin, and return ISO 8601 with `Z`. Never save or return a local time. A
  time zone the business needs, such as a shop's opening hours, is stored as its
  own named field beside the UTC value.
- **Python uses Poetry:** `pyproject.toml` with a committed `poetry.lock`, a
  `dev` dependency group for the formatter, linter, type checker, and tests, a
  pinned Python version, and tool configuration in `pyproject.toml`. No bare
  `pip` or `requirements.txt` for application dependencies.
- **A secret never comes back out of the API.** Once an API key, token, client
  secret, or password is saved, no endpoint returns it, in a detail, a list, or
  a log:
  - A read returns only whether it is set, for example `{ "hasApiKey": true }`,
    so the screen can show the masked field ([design practices](design.md)).
  - An update is a `PATCH`, where a missing or blank secret field means "keep
    the stored value". A stored secret is never overwritten with empty.
  - A change with a precondition, such as needing the current password, is its
    own `POST`: `POST /account/change-password` with the current and the new.
  - Secrets are encrypted at rest.
- **Immutable data in TypeScript projects, through `readonly` types.** Declare
  fields `readonly` and collections `ReadonlyArray`, `ReadonlyMap`, or
  `ReadonlySet`, use `as const` for fixed values, and return a new value instead
  of changing an argument. Add no immutability library.
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
  the answer in the service's `README.md` so it is not asked again. With
  docker-compose, map backing services to non-default host ports (for example
  PostgreSQL `5436`, Redis `6378`) so they do not clash with ones already
  installed, mount the source for live reload, keep images multi-arch (arm64
  and amd64), and add a small helper script for start, stop, shell, and clean.
- **Never drop, reset, or re-seed a database without the human's explicit OK**,
  every time. The one exception is a worker's own database, below.
- **Each worker gets its own database.** Parallel Seniors and testers must not
  share data, so each creates one on the local database server, named after its
  worktree, for example `myapp_wt_fix_login_2`, runs the migrations and seed
  data, and drops it when its task is finished or abandoned. Redis gets its own
  key prefix or database number per worker.
  - **The human's local connection is the source.** Each human keeps their own
    local database connection where the stack expects local configuration,
    such as `.env`, `.env.local`, or `appsettings.Development.json`, git-ignored.
    Never assume a host, user, or password. If that file does not exist, or
    has no database connection, create it from the keys in `.env.example` (or
    the stack's equivalent template) with the values left empty, and ask the
    human to fill them in. Do not invent values.
  - **Reading it needs the human's OK once per project,** as for any
    credential ([shared contract](contract.md)). Record the answer in the
    service's `README.md` so it is not asked again.
  - **A worker gets only the connection, with its own database name.** The Lead
    copies the host, port, user, and password into the `.env.test` it places in
    the worktree, with the database name replaced by the worker's `_wt_` name.
    Nothing else from the human's file goes into the worktree.
  - **Before dropping, check where the database is.** Drop only when the host is
    `localhost`, `127.0.0.1`, or `::1` and the name is the worker's own `_wt_`
    database. If the host is anything else, do not drop it: leave it, and alert
    the human with the host and database name. The local user may be able to
    drop any database on the server, so these checks are what keep the human's
    own databases safe; never drop a database by any other name.
  - **The drop exception covers only** that case. Anything shared or remote,
    and any other database, still needs the human's OK.

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
  it per feature and do not replace it with another method. A Python or C# API
  ports it line for line and proves the port gives the same output as the
  supplied module for the same inputs.

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
