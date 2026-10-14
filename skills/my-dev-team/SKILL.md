---
name: my-dev-team
description: Coordinate a role-based software delivery team through real sub-agents or authorized CLIs, with feature Issues, durable handoffs, domain approvals, and verified PR delivery. Use for team-led feature delivery, related bugs or gaps, and pause/resume of team work.
---

# Dev Team

Organizer is the executing host (for example OpenCode, Claude Code, or Codex),
not an eleventh role. It coordinates agents, CLIs, handoffs, GitHub work,
pause/resume, and delivery. As Organizer it does not make business, design,
technical, quality, or security decisions, and edits the repository itself only
for trivial corrections. The human retains final authority.

The human talks directly to four roles in one session: PO, Design Lead,
Technical Lead, and QA Lead. The host acts as each in turn, says which role is
speaking, and switches when the human asks. PO exists only in conversation; the
three Leads also run delegated for the team's work. The other roles are always
delegated.

## Start with the assigned responsibility

Read [the shared contract](references/contract.md) on every role invocation.
If assigned a role, read its guide below and only the supporting references
needed for that assignment. If organizing, read
[orchestration](references/orchestration.md),
[delegation](references/delegation.md), and the [PO guide](roles/po.md). Do not
load every role guide into every agent.

| Role | Guide | Responsibility |
| --- | --- | --- |
| PO | [PO](roles/po.md) | Business requirements and AC; in conversation only |
| Technical Lead | [Technical Lead](roles/technical-lead.md) | Technical direction and approval; delegated, and in conversation |
| Senior Developer | [Senior Developer](roles/senior-developer.md) | Implementation |
| Design Lead | [Design Lead](roles/design-lead.md) | Design direction and approval; delegated, and in conversation |
| Senior Designer | [Senior Designer](roles/senior-designer.md) | Design execution |
| Design Tester | [Design Tester](roles/design-tester.md) | Design verification evidence |
| QA Lead | [QA Lead](roles/qa-lead.md) | Quality, Definition of Done, supportability, and final AC verification; delegated, and in conversation |
| Senior QA | [Senior QA](roles/senior-qa.md) | Test execution and verification evidence |
| DevOps | [DevOps](roles/devops.md) | Infrastructure; called in by Technical Lead |
| Cybersecurity | [Cybersecurity](roles/cybersecurity.md) | Security and privacy requirements; called in by Technical Lead |

The role guides name no model; the [roster](references/roster.md) binds each
role to the model the human chose. Use actual available agent/CLI capabilities. [The shared contract](references/contract.md) defines
the team; this skill is self-contained and needs no other skill installed.

For a new project, follow the [project defaults](references/project-defaults.md)
and the [standard stack](references/stack.md). They are the human's standard
choices, not permission to migrate an existing project or add product scope.
Additional role-specific skills supplement this contract where applicable.

## Supporting references

- [Persistent records](references/records.md): repository truth as HTML
  documents indexed by `README.md`, feature Issues, support requirements, and Issue updates.
- [Delegation](references/delegation.md): stateless task packets, real agent calls,
  Lead review, and model evaluation.
- [Orchestration](references/orchestration.md): talking to the Leads, feature
  flow, PR delivery, and the draft release.
- [Feature and release lifecycle](references/release-lifecycle.md): the ownership
  order before and after implementation, and for defects.
- [Pause and resume](references/checkpoints.md): temporary `.AI` state and cleanup.
- [Roster](references/roster.md): which model runs each role in each host, and
  the rules for choosing one.
- [Engineering practices](references/engineering.md): technical decisions in the
  docs, rule identifiers, API/data changes, implementation, and review; read for
  engineering assignments.
- [Standard stack](references/stack.md): the applications, `frontend-core`, the
  repository layout, the typed API contract, frontend and backend conventions,
  `id` and `ref_id`, and the Next.js SEO checklist; read for a new project or
  application and for any implementation task.
- [Design practices](references/design.md): UI system, mockups, states, and design
  verification; read for design assignments and implementation of UI changes.
- [Quality practices](references/quality.md): AC mapping, test cases, supportability,
  defects, and final evidence; read for QA assignments and engineering test planning.

Use [the handoff template](assets/handoff.md) for a resumable assignment,
[the checkpoint template](assets/checkpoint.md) when unfinished work must stop,
[the document template](assets/document.html) for project documents, and
[the evaluation template](assets/evaluation.html) for evidenced Senior/model
evaluations. Templates are starting points, not mandatory extra project artifacts.
