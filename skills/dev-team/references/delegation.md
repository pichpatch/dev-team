# Stateless delegation and review

## Real agents and portable hosts

Use the host's actual available sub-agent tools or already-authorized external
CLIs. A host may route between OpenCode, Claude Code, Codex, AGY, and other available
agents, but none is required merely because it appears in this list. Inspect the
installed tool/CLI help for supported invocation and resume mechanisms instead
of inventing command flags. Do not install tools or alter authentication as an
implicit part of routing work.

Roles do not bind to models. Respect the human's explicit model/provider choices;
otherwise use the configured available defaults, limited in both cases to models
the human has approved as safe for private code ([contract](contract.md)). Record actual model identity
when observable, and `unknown` when it is not. Do not claim a named provider ran
because another model role-played it. If genuine delegation is unavailable, report
that limitation and preserve pending work rather than presenting self-review as
independent role approval.

Organizer dispatches owners; Leads determine Senior tasks and review their work.
If nested agent calls are unavailable, Organizer can dispatch a Senior on a Lead's
behalf using the Lead's task packet and return the output to that Lead. This is a
transport adaptation, not transfer of domain authority.

## Routing and invocation loop

PO is not in this table: the host carries it out itself in conversation with the
human ([orchestration](orchestration.md)).

| Delegating owner | Execution role | Approval/reporting owner |
| --- | --- | --- |
| Organizer | Design Lead | Design Lead |
| Design Lead | Senior Designer(s), Design Tester | Design Lead |
| Organizer | Technical Lead | Technical Lead |
| Technical Lead | Senior Developer(s) | Technical Lead |
| Organizer | QA Lead | QA Lead |
| QA Lead | Senior QA(s) | QA Lead |
| Organizer, coordinated with Technical Lead | DevOps | Technical Lead for technical integration; DevOps for infrastructure expertise |
| Organizer | Cybersecurity | Cybersecurity |

Do not add extra reviewer/worker roles from the old team. Assign investigation,
unit/integration work, E2E, and design critique to the appropriate existing role.
PO, DevOps, and Cybersecurity do not gain invented Senior tiers.

For each actual dispatch:

1. Identify the required role, relevant skills, available execution mechanism,
   authorized model choice, and scope. Construct the task packet below.
2. Invoke the real tool/CLI and retain its task/session handle for this run. Pass
   role instructions and durable artifact references explicitly. Do not transfer
   raw credentials, unrelated conversation, or the Lead's private reasoning.
3. Continue independent work or await progress using the host's supported wait/
   status mechanism. A submitted job is not completed work. Do not open the final
   PR while required agents/reviews are still running or uncollected.
4. Receive the artifacts and execution result; send them to the responsible owner
   for review. A Senior returns delivered work, not an approval. Record tool errors,
   timeouts, and missing outputs as incomplete rather than inventing a verdict.
5. On rejection, return actionable corrections to the same Senior or an explicitly
   reassigned instance, with updated artifact context. On approval, the owner records
   completion and evidence on the Issue and the next dependent stage can proceed.

Reuse a live agent when useful, but do not assume it remembers decisions. Rebuild
the packet from persistent records when changing context/model or resuming. Respect
tool/runtime limits; queue excess work. If repeated attempts make no progress,
have the owner diagnose the blocker rather than launching an endless review loop.
Ask the human only when resolving it requires a human decision or authorization.

## Task packet

Use [the handoff template](../assets/handoff.md) as needed. Each invocation gets:

- Assigned role and the absolute path to this skill's entrypoint and role guide.
- Applicable additional skills and where to load them; missing required skills
  are a reported dependency, not something an agent silently invents.
- Owning feature Issue URL/identifier.
- Repository/worktree path, relevant branch/revision and uncommitted work context.
- Links/paths to current requirements, decisions, designs, and verification evidence.
- Concrete task, constraints, scope/files owned, dependencies, and expected outputs.
- Decision owner/receiving Lead, reporting route, and the existing approvals that apply.
- Optional unfinished checkpoint, only if one exists for a valid reason.

Persist the meaningful assignment and decisions in the owning Issue/repo before
handoff. A transient packet may carry links and execution details, but must not be
the only copy of important knowledge. Do not create `.AI` checkpoints for routine active
assignments. The parent must not assume a child inherited conversation context,
even if a tool can technically fork it.

## Split and integrate

A Lead may use two or more Seniors on independent tasks and different models.
Give each a clear file/scope boundary, inputs, outputs, and integration dependency.
Avoid concurrent edits to the same files or Issue body; serialize shared changes
or use isolated worktrees with explicit integration responsibility. Respect the
host's concurrency limit; queue extra work without creating not-started checkpoints.

Seniors return artifact paths, changes, test/research evidence, limitations,
remaining work, and evidenced challenges. They do not update the Issue or approve
their own work. The Lead inspects outputs and relevant evidence, integrates them,
and approves or returns specific corrections. Verify the integrated result where
combination can change behavior; individual task success is not integration proof.

Approved scope is complete. The Lead records the outcome on the Issue and routes
the durable handoff. A rejected scope remains unfinished. Correct Senior challenges
should change the Lead's decision when warranted and count positively in evaluation.

Use a concise result record: role/instance, actual model if observable, scope and
revision/artifacts, outcome, evidence, material findings/decisions, remaining work,
and receiving owner. Owners may record approved, changes requested, blocked, or
reasoned not applicable; Seniors report delivered or unfinished work. Keep tool
completion, domain approval, and QA's tested outcome distinct. These are record
fields, not another status ceremony after approval.

## Worktrees keep secrets out of delegated work

The main checkout is the human's workspace and may hold real secrets in ignored
files such as `.env`. A git worktree contains tracked files only, so it starts
without them. All repository writes for a feature happen in worktrees:

```text
projects/
  my-app/                                     main checkout: the human's, real `.env`
  worktrees/my-app/
    meetup-create-event/                      feature branch: Leads integrate here
    meetup-create-event-senior-developer-1/   `.env.example` only (fake values)
    meetup-create-event-senior-qa/            `.env.test` (test-only credentials)
```

- Technical Lead creates the worktrees, outside the repository, at
  `../worktrees/{repo}/{feature-slug}` for the feature branch and
  `../worktrees/{repo}/{feature-slug}-{instance}` for each Senior, unless the
  project already has a convention. One worktree and branch per agent instance.
- Do not switch branches or leave uncommitted changes in the main checkout.
- Never copy a real env file into a worktree. When the work needs runnable
  configuration, provide values derived from `.env.example`, or a `.env.test`
  holding test-only credentials the human supplied for that purpose.
- Name the worktree in the task packet. A Senior stays inside its worktree and
  does not read the main checkout, other worktrees, or the user's home directory.
- Other Leads ask Technical Lead for a worktree when their Seniors write to the
  repository. When a Lead cannot run git itself, Organizer creates the worktree
  on that Lead's instruction.
- Remove a worktree once its work is integrated, never while it holds unfinished
  work or a checkpoint.

A Lead can reach the main checkout and its real files. The human accepted that
exposure; the contract's ask-before-reading rule still applies to Leads. A
worktree keeps secrets out of a Senior's working directory but does not stop a
process from opening another path, so the rule matters for Seniors too.

## Performance evidence

Leads maintain `docs/evaluation/{feature-slug}-{role}-{model}.html` using
[the evaluation template](../assets/evaluation.html) where helpful. Evaluate actual
work: correctness, understanding, independence, reasoning quality visible in
decisions, research/evidence, risks discovered, introduced complexity, standards,
corrections needed, useful challenges, deliverable quality, and observable efficiency/cost.

Link artifacts and concrete review findings; capture meaningful Senior ↔ Lead
discussion as concise claims, evidence, responses, and outcomes. Do not store
chain-of-thought or whole transcripts. Distinguish model performance from unclear
instructions, missing tools, or environment failures. Never invent cost, timings,
scores, or a model identity that is not observable.

Use filesystem-safe slugs; preserve the full observed role/model identity inside
the report. If normalization causes a collision, disambiguate the model slug.
For repeated work by the same feature/role/model, update the existing report and
retain task/revision context instead of creating unrequested evaluation files.
