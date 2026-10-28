---
name: my-dev-team
description: Coordinate a role-based software delivery team through real sub-agents or authorized CLIs, with feature Issues, durable handoffs, domain approvals, and verified PR delivery. Use for team-led feature delivery, related bugs or gaps, and pause/resume of team work.
---

# Dev Team

Organizer is the host running this skill (Claude Code, Codex, OpenCode, ...).
It is not a role. It coordinates agents, handoffs, the repository host,
pause/resume, and delivery. It makes no business, design, technical, quality,
or security decision, and edits the repository only for trivial corrections.
The human has final authority.

## What to read

- **Always:** [the shared contract](references/contract.md).
- **Assigned a role:** that role's guide below, plus only the references your
  task needs.
- **Organizing:** [orchestration](references/orchestration.md),
  [delegation](references/delegation.md), and the [PO guide](roles/po.md).

Do not load every guide into every agent.

| Role | Guide | Owns | Runs |
| --- | --- | --- | --- |
| PO | [PO](roles/po.md) | Business requirement and AC | Conversation only |
| Technical Lead | [Technical Lead](roles/technical-lead.md) | Technical direction and approval | Delegated or conversation |
| Senior Developer | [Senior Developer](roles/senior-developer.md) | Implementation | Delegated |
| Design Lead | [Design Lead](roles/design-lead.md) | Design direction and approval | Delegated or conversation |
| Senior Designer | [Senior Designer](roles/senior-designer.md) | Design execution | Delegated |
| Design Tester | [Design Tester](roles/design-tester.md) | Design verification | Delegated |
| QA Lead | [QA Lead](roles/qa-lead.md) | Quality, Definition of Done, final AC check | Delegated or conversation |
| Senior QA | [Senior QA](roles/senior-qa.md) | Test execution and evidence | Delegated |
| DevOps | [DevOps](roles/devops.md) | Infrastructure, under Technical Lead | Delegated |
| Cybersecurity | [Cybersecurity](roles/cybersecurity.md) | Security and privacy, under Technical Lead | Delegated or conversation |

The guides name no model; the [roster](references/roster.md) does. This skill
is self-contained. Other installed skills may add detail but never override
the contract.

## References

Read only what the task needs:

| Reference | Read it for |
| --- | --- |
| [Records](references/records.md) | Docs as HTML, `README.md` indexes, the feature Issue, changing AC |
| [Local task delegation](references/ai-task-delegation.md) | The `.AI` board, model handover, worktree cleanup |
| [Release lifecycle](references/release-lifecycle.md) | Who owns what, before and after implementation |
| [Pause and resume](references/checkpoints.md) | Checkpoints in `.AI` |
| [Engineering](references/engineering.md) | Any engineering task |
| [Standard stack](references/stack.md) | A new project or application, and any implementation |
| [Project defaults](references/project-defaults.md) | A new project: the human's standard choices |
| [Design](references/design.md) | Design tasks and UI implementation |
| [Quality](references/quality.md) | QA tasks and test planning |
| [OWASP security](references/owasp-security.md) | Security design, review, and draft releases |

Defaults and the stack apply to new projects. They never authorize migrating
an existing project or adding scope.

Templates (starting points, not required files):
[handoff](assets/handoff.md), [checkpoint](assets/checkpoint.md),
[document](assets/document.html), [evaluation](assets/evaluation.html),
[security report](assets/security-report.html).
