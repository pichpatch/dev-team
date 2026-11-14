# Performance: bulk data, indexes, endpoints, and jobs

Hard rules for work that writes many rows, adds an index, serves slow data, or
runs in the background. They apply to every stack, and to existing projects
too. Read only the section your task touches.

## Bulk writes: batches of 500

- Any insert, update, or delete that can touch more than 500 rows runs in
  batches of 500. Never one statement, and never one loaded list, over the
  whole set. A single 600,000-row update has already exhausted memory.
- Order by a stable key (`id`) and continue after the last key processed.
  Never page by offset.
- One batch is one transaction. A batch that runs twice must not apply twice.
- When the total cannot finish inside one request, run the batches as a
  [background job](#jobs-cursor-and-continue).
- 500 is also the batch size of Firebase push notifications; keep the two the
  same.

**Optional: a work table.** For a large change on a busy table, copy the rows
to process into a temporary work table with an auto-increment number, batch by
that number, and delete each batch from the work table once it is applied. The
live table is then touched one batch at a time and never locked for the whole
run. A work table is the one place an auto-increment key is right; real tables
keep `id` as UUIDv7 ([identifiers](stack.md#identifiers-and-public-urls)).

## Indexes: prove, propose, then add

An index makes reads faster and every write slower.

- Never add a performance index on your own.
- Run a proof of concept first, on realistic volume: a sanitized fixture or
  clone ([local databases](stack.md#backend)). Never a near-empty table, never
  unsanitized production data. If no realistic data exists, say so and report
  no numbers.
- Measure both sides, before and after the index:
  - **read:** the query plan and timing of the query it serves (`EXPLAIN
    ANALYZE`, or the database's equivalent);
  - **write:** the timing of one 500-row batch insert and one 500-row batch
    update on that table.
- Propose it in your return: table, columns, the query it serves, and the
  before and after measurements. Technical Lead lists every proposal in the PR.
- The human decides. Add an index only when the human, or a task packet quoting
  the human's decision, names it. The proof of concept is still required.
- Primary keys and the unique constraints `data-dict.html` specifies are
  schema, not performance indexes. This rule does not cover them.

## Endpoints: split by speed

- Never one big endpoint for a screen. Fast data and slow data get separate
  endpoints.
- The screen shows the fast data first. Each slow part loads after it, with its
  own loading state. Slow data never blocks fast data.
- Technical Lead sets the split in `api-spec.html`; Senior Developer raises a
  slow part the documents did not expect.

## Jobs: cursor and continue

For every job that loops over data (update, delete, export, sync, sending), on
any runner. No exception for "small" data: you cannot know how many rows
production holds.

Every runner stops a job at a hard time limit: AWS Lambda at 15 minutes,
Hangfire at 30 minutes. A job that reaches the limit is killed or run again
from the start. Find the limit of the project's runner and record it beside the
job in the module's `flows.html`.

1. Process in batches of 500, ordered by a stable key.
2. After each batch, save the cursor (the last key processed) in durable
   storage, never only in memory.
3. After each batch, check the elapsed time. At **half** the runner's limit
   (Lambda 7.5 minutes, Hangfire 15 minutes), enqueue a child job that carries
   the cursor, then exit normally.
4. The child continues after the cursor. Repeat until no rows are left.

- Never let a job reach the limit.
- A crash or retry restarts from the saved cursor: no row twice, no row
  skipped.
- Use the job system as a queue, not only as a scheduler. Work a request cannot
  finish, and every continuation, is an enqueued job. A scheduled job only
  starts the first one.
- One chain per job at a time: a new scheduled run does not start while the
  previous chain is still running (Hangfire: `DisableConcurrentExecution`).
- Log each batch (job id, cursor, rows, elapsed time) and each hand-off (parent
  job id, child job id, cursor).
