# Stateless delegation and review

For Organizer and the Leads: who dispatches whom, the task packet, and review.
Workers read [worktrees](worktrees.md) instead.

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
- Record the model that actually ran, or `unknown`, and sign every comment,
  review, and report with it ([signature](records.md#durable-updates)). Never
  claim a provider ran because another model played it.
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
   Resume the Senior's session on the same model
   ([resuming a session](roster.md#starting-a-run)) and send only the findings:
   it keeps what it already read, which a new run would pay to read again.
   Start a new session only when the model changes or the session is gone,
   and then send the full packet.
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

Fill every line of [the handoff template](../assets/handoff.md); it is the one
list of what a packet holds.

- Name the documents to start from as `file#section`: the application
  `README.md`, the module documents, and the requirements, designs, and evidence
  the task needs. A worker never searches for its starting point.
- A skill the packet names but the worker cannot find is reported, not
  improvised.
- Copy a `SEC-` requirement's example inputs and expected outcomes intact, never
  summarized.
- The packet is written into the worker's `.AI` card
  ([local task delegation](ai-task-delegation.md#assignment-and-progress)).

**Same shape every time.** Keep the template's fields in the template's order
in every packet: the parts that stay the same first (role, skill paths, Issue,
documents), the parts that change last (task, findings, corrections). Put no
date, time, or run number above them. Text that is identical from the first
character is what a provider can reuse from its cache; one changed character
near the top makes it read everything after it at full price.

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
