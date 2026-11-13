# Stateless delegation and review

## Use real agents

- Use the host's real sub-agent tools or already-authorized CLIs (Claude Code,
  Codex, OpenCode, Antigravity, ...). None is required just because it is named
  here. Read each CLI's `--help` instead of inventing flags. Never install tools
  or change logins as part of routing.
- Pick the model from the [roster](roster.md). Do not silently inherit the
  parent's model when the roster has a binding. A model the human names wins.
- If the bound model cannot be selected, report it and ask when a choice is
  needed. Never fall back to the parent model silently. Only human-approved
  models ([contract](contract.md)).
- Record the model that actually ran, or `unknown`. Never claim a provider ran
  because another model played it.
- If real delegation is impossible, report that and keep the pending work.
  Self-review is never an independent approval.
- Organizer dispatches owners; Leads set Senior tasks and review them. If a
  child agent cannot start its own sub-agents, Organizer dispatches the Senior
  with the Lead's packet and returns the result to that Lead. That moves
  messages only, not authority.

## Who delegates to whom

| Delegates | Runs | Reviews / reports to |
| --- | --- | --- |
| Organizer | Design Lead | Design Lead |
| Design Lead | Senior Designer(s), Design Tester | Design Lead |
| Organizer | Technical Lead | Technical Lead |
| Technical Lead | Senior Developer(s) | Technical Lead |
| Organizer | QA Lead | QA Lead |
| QA Lead | Senior QA(s) | QA Lead |
| Technical Lead | DevOps | Technical Lead |
| Technical Lead | Cybersecurity | Technical Lead; an overruled security requirement goes to the human |

- PO is not delegated: the host plays it in conversation.
- A role the human talks to directly stays in the conversation on its command's
  model; do not spawn a copy of it. DevOps is never talked to directly.
- **Delegated QA Lead and Cybersecurity** always run as separate sub-agents,
  on a different provider from the code's author
  ([independent reviewers](roster.md#independent-reviewers)).
  A different effort level of the same model does not count. If no other
  provider is available, use the role's next approved backup, record that the
  review was not on another provider, and continue.
  Never self-approve. When the human talks to them directly, no sub-agent is
  needed, but that work is not independently verified.
- Technical Lead may share Organizer's context and model.
- Seniors and Design Tester always run as real sub-agents on their roster
  models.
- Add no extra roles and no Senior tiers for PO, DevOps, or Cybersecurity.
  Investigation, unit/integration work, E2E, and design critique go to the
  existing roles.

## Dispatch loop

Before substantial work, the agent checks its runtime: repository root, branch,
worktree status, allowed write paths, and that the Git operations it needs work,
launched without an OS sandbox as the [roster](roster.md#starting-a-run) shows.
If the runtime blocks an allowed operation, stop and fix the launch instead of
restarting workers.

For each dispatch:

1. Identify the role, skills, mechanism, approved model, and scope. Build the
   [task packet](#task-packet).
2. Call the real tool and keep its handle. Pass role instructions and record
   links explicitly. Never pass credentials, unrelated conversation, or a Lead's
   private reasoning.
3. Wait with the host's status mechanism. A submitted job is not finished work.
   Never open the PR while required agents or reviews are still running.
4. Send the result to its owner for review. A Senior returns work, not an
   approval. Record errors, timeouts, and missing output as incomplete.
5. On rejection, return specific corrections to the same Senior (or a named
   replacement), within [the review loop limits](contract.md#every-review-loop-is-bounded).
   On approval, the owner records completion and evidence on the Issue, or in
   the PR when there is none, and the next stage may start.

If a worker fails after starting: confirm it stopped, keep its last verified
progress and diagnostics in its record, check the worktree's Git state, fix the
cause, and resume from that record in the same worktree
([local task delegation](ai-task-delegation.md)).

Keep handoffs lean: relevant diffs, files, findings, decisions, requirements,
and evidence, not the conversation. Keep unaffected approvals; recheck changed
scope and risky dependencies. A live agent may be reused, but never assume it
remembers; rebuild the packet from records when the context or model changes.
Respect concurrency limits and queue extra work. Work that keeps failing or
stops making progress follows the
[review rounds](contract.md#every-review-loop-is-bounded): more evidence the
second time, then a discussion with the human. Otherwise ask the human only for
a decision or authorization.

## Task packet

Use [the handoff template](../assets/handoff.md). Each packet gives:

- the role, and absolute paths to this skill's entrypoint and the role guide;
- other skills needed and where they are (a missing one is reported, not
  improvised);
- the owning Issue, or the branch name and purpose when there is none;
- the worktree path, branch, revision, and uncommitted context;
- the documents to start from, by name: the application `README.md`, the
  module documents, and the requirements, designs, and evidence the task needs;
- for security-scoped work, the `SEC-` requirement with its example inputs and
  expected outcomes copied intact, never summarized;
- the objective and a measurable definition of done;
- the task, constraints, files owned, forbidden changes, dependencies, required
  approvals, and expected outputs;
- milestones, with the tests and evidence expected for each;
- the receiving Lead, reporting and escalation routes, and approvals that apply;
- the absolute path of its `.AI` record, and the record to resume from if any
  ([local task delegation](ai-task-delegation.md)).

Save the assignment and decisions on the Issue or in repository records before
handing off; a packet is never the only copy. Keep the worker's `.AI` record
current. Never assume a child inherited the conversation, even if the tool can
fork it.

## Split and integrate

- A Lead may give independent tasks to several Seniors, on different models.
  Give each a clear file boundary, inputs, outputs, and integration dependency.
- Avoid concurrent edits to the same files or Issue body: serialize, or use
  separate worktrees with a named integrator.
- Seniors return artifact paths, changes, evidence, limits, remaining work, and
  evidenced challenges. They never edit the Issue or approve their own work.
- The Lead inspects, integrates, and approves or returns specific corrections.
  Verify the combined result; separate task success is not integration proof.
- Approved scope is complete; the Lead records it on the Issue (or PR). A
  correct Senior challenge should change the Lead's decision and counts in
  evaluation.

A result record holds: role and instance, model if known, scope and revision,
outcome, evidence, findings and decisions, remaining work, receiving owner.
Owners record approved, changes requested, blocked, or not applicable with a
reason; Seniors report delivered or unfinished. Tool completion, domain
approval, and QA's result are different things.

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

### Paired Developer/QA worktree

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

Branches, commits, and pushing:

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

## Performance evidence

Where useful, Leads keep `docs/evaluation/{feature-slug}-{role}-{model}.html`
from [the evaluation template](../assets/evaluation.html). Judge actual work:
correctness, understanding, independence, decision quality, research and
evidence, risks found, complexity added, standards, corrections needed, useful
challenges, deliverable quality, and observable cost.

- Link artifacts and concrete findings. Summarize Senior ↔ Lead exchanges as
  claims, evidence, responses, and outcomes; never store reasoning or
  transcripts.
- Separate model performance from unclear instructions, missing tools, or
  environment failures. Never invent cost, timings, scores, or model identity.
- Use filesystem-safe slugs, keep the full model identity inside the report,
  and update the existing report for repeated work instead of adding files.
