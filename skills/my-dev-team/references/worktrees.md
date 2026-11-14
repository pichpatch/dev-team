# Worktrees, pairs, and branches

Every delegated worker reads this. Technical Lead creates the worktrees; a
worker stays inside the one its packet names.

## Worktrees keep secrets out of delegated work

The main checkout is the human's and may hold real secrets in ignored files. A
git worktree holds tracked files only, so it starts without them. All repository
writes for a feature happen in worktrees. What is agreed with the human before
implementation stays on the Issue
([talking to the Leads](orchestration.md#talking-to-the-leads)).

```text
projects/
  my-app/                                     main checkout: the human's, real `.env`
  worktrees/my-app/
    meetup-create-event/                      feature branch: Leads integrate here
    meetup-create-event-dev-qa/                paired Dev/QA branch, `.env.test`
    meetup-create-event-senior-designer-1/     `.env.example` only (fake values)
```

- **Technical Lead creates the worktrees** outside the repository:
  `../worktrees/{repo}/{feature-slug}` for the feature branch and
  `../worktrees/{repo}/{feature-slug}-{instance}` per independent worker,
  unless the project has its own convention. Each API or data slice gets a pair: a
  Senior Developer and a Senior QA share one paired worktree and branch for their
  concurrent work on separate files. A UI-only slice has no pair: its Senior Developer keeps a
  separate worktree and QA covers it with end-to-end checks. Independent slices
  and pairs run in parallel, up to the
  [Senior Developer cap](roster.md#delegated-roles): at most two Senior
  Developers on Claude at once. A third pair waits for a free place or starts
  its Senior Developer on its first Go backup. Other
  Leads ask Technical Lead for one; if a Lead cannot run git, Organizer creates
  it on that Lead's instruction.
- **Never copy a real env file into a worktree.** For runnable config, use
  values from `.env.example`, or a `.env.test` with test-only credentials the
  human supplied. Add a connection to the worker's [own database](stack.md)
  only when the task needs one.
- **No OS sandbox,** for any CLI, Codex included. The worktree and the packet
  keep the worker in place, so it can reach its local database, commit, write
  its `.AI` record, and start other CLIs.
- **A Senior stays in its worktree.** It does not read the main checkout, other
  worktrees, or the home directory. The one exception: its own
  [checkpoint](checkpoints.md) file at the path the packet gives.
- **A Developer/QA pair shares one worktree** and works at the same time. Follow
  [Paired Developer/QA worktree](#paired-developerqa-worktree).
- **Do not switch branches or leave uncommitted changes in the main checkout,**
  except for work the human explicitly authorized there
  ([direct-checkout exception](ai-task-delegation.md)); then tell the human
  what is uncommitted.
- **After integration,** remove the worker's (or pair's) worktree and local
  branch once its changes are preserved, all processes have stopped, and no
  review needs it
  ([cleanup safeguards](ai-task-delegation.md)).

## Paired Developer/QA worktree

One pair per API or data slice: one Senior Developer, one Senior QA, one worktree,
one branch. They work at the same time, in different files.

**Who owns which files**

- Senior QA: integration tests and seed data.
- Senior Developer: unit tests, implementation, migrations.
- Never edit a file the other one owns. If you need a change there, ask your own
  Lead: Senior Developer asks Technical Lead, Senior QA asks QA Lead.
- You may *run* the other's files (QA's seed script, Developer's migrations);
  you never edit them.

**Commit only your own files.** You share the working tree, so the other agent's
unfinished files are in it too.

- Stage files by path: `git add src/orders/refund.service.ts`.
- Never `git add -A`, `git add .`, or `git commit -a`.
- Before each commit, run `git diff --cached --name-only` and check that every
  file listed is yours. Unstage any that is not: `git restore --staged <file>`.
- Never switch branches, stash, reset, or check out files in the pair's
  worktree.

**The pair lock.** Take it before you edit a shared file (one neither of you
owns, such as a route index or a package file), run code generation or an
install, or run `git add` or `git commit`.

1. Take it: `mkdir "$(git rev-parse --git-dir)/pair.lock"`. If the command
   fails, the other agent holds the lock: wait one minute and try again. After
   10 failed tries, stop and report to your Lead.
2. Do the operation.
3. Release it at once: `rmdir "$(git rev-parse --git-dir)/pair.lock"`.

Never hold the lock during a test run or a long task. Only Technical Lead removes
a lock it did not take, and only after confirming the holder's process has
stopped.

**Databases.** Each agent migrates and seeds its own database with the project's
commands, and runs its tests only there, with its own output folder. The names
are in [stack](stack.md), under "Local databases".

**Order of work**

1. **Start together.** Senior QA writes the integration tests from the
   implementation documents. Senior Developer writes each unit test first, then
   the code.
2. **Senior QA's test runs before the freeze are for its own use.** Senior
   Developer's code is unfinished then, so a failure is not a code defect. Never
   report a code defect from these runs.
3. **QA Lead approves the integration tests** when Senior QA has finished them.
   Senior Developer runs only approved integration tests.
4. **Migrations.** Before each test run, Senior QA lists migration changes since
   its last check: `git log --name-only <last-checked-commit>..HEAD -- <migrations folder>`.
   If any are listed, it updates the seed, re-migrates and re-seeds its database,
   then runs the tests. Senior Developer also names each migration it adds or
   edits in its result.
5. **Senior Developer is done** when its unit tests and the approved integration
   tests pass on its own database. It commits its files and reports done.
6. **Technical Lead freezes the revision:** it records the commit hash and tells
   both Seniors. Nobody edits code or test files until Senior QA reports.
7. **Senior QA checks the revision before verifying:** `git rev-parse HEAD`
   must equal the hash, and `git status --porcelain` must print nothing. If
   either fails, do not verify: report it to QA Lead.
8. **Senior QA verifies** on the `_verify` database, freshly migrated and
   seeded, and reports one of: pass, test defect, or code defect. A code defect
   includes the reproduction steps, the expected and actual result, and the
   suspected area.
9. **Fixes.** Senior QA fixes a test defect; QA Lead approves first if the
   expected behavior changes. Senior Developer fixes a code defect. After any
   fix, go back to step 6. The [review loop limits](contract.md#every-review-loop-is-bounded)
   apply.
10. **After both Leads approve,** Technical Lead merges the pair's branch into
    the feature branch.

## Branches, commits, and pushing

- Feature branch: `feat/{issue-number}-{slug}`. Issue-free bugs and small
  changes: `fix/{descriptive-slug}`. An independent Senior's branch is the
  owning branch plus `-{instance}`. The Senior Developer and Senior QA of a
  pair share one branch named with `-dev-qa-{slice}`, unless the project has its own
  convention.
- A Senior commits in small commits that name the Issue (or the task when there
  is none). Paired agents commit their own changes to the shared branch only
  while holding the pair lock (above); neither edits the other's files. Seniors never merge,
  push, or touch another branch.
- The responsible Lead reviews; Technical Lead merges approved branches into the
  feature branch and verifies the result.
- Organizer pushes only the feature branch and opens the PR.
- Nobody commits to the default branch. Documents and code reach it only
  through a PR the human merges. Nobody force-pushes or rewrites pushed
  history.
- Remove the feature worktree after feature-branch verification when no review
  needs it; keep the feature branch for the PR. After the human merges, Technical
  Lead (or Organizer for it) removes the local feature branch when safe.

A Lead can reach the main checkout and its real files; the human accepted that.
The ask-before-reading rule still applies. A worktree keeps secrets out of a
Senior's folder but cannot stop a process opening another path, so the rule
matters for Seniors too.
