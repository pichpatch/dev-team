# Draft sources and adaptations

This is the expanded role draft, based on the user's 17-section team specification,
the local `ai-skills` working tree, and general product/engineering/design/quality
practices. The latest user specification controls whenever the sources conflict.
The skill is self-contained and does not invoke or require the old `my-*` skills.

## Role adaptation

| Draft role | Main source and adaptation |
| --- | --- |
| PO | `PO/SKILL.md` and AC/research references: purpose, scope, phases, business rules, market research with a business viability verdict, challenging the direction before agreeing, discoverability, testable AC with mandatory identifiers; a short purpose on the Issue; feature Issue creation follows human agreement. Carried out by the host in conversation, not delegated. |
| Technical Lead | `FullstackDev/SKILL.md` engineering-lead practices: architecture, impact, contracts, delegation, integration, code review; now owns the single model-independent technical authority. Delegated, and reachable in conversation through `/tech-lead` to clear technical questions with the human. |
| Senior Developer | Fullstack implementation/testing/API/dependency practices: bounded implementation, unit/integration verification, docs, and evidence returned to Technical Lead. |
| Design Lead | `UX_UI/SKILL.md`: flows, direction, shared UI system, design decisions, feasibility, and approval; delegates production and verification. |
| Senior Designer | UX/UI production methods: reusable components, editable artifacts, states, accessibility, realistic content, self-inspection, and handoff. |
| Design Tester | UX/UI critique and QA design checks: independent rendered-design verification, reproducible findings, correction retest; reports to Design Lead. |
| QA Lead | `QA/SKILL.md` and defect/edge-case practices: strategy, testability, cases and coverage, plus the new authoritative support requirements and final AC verification. |
| Senior QA | QA execution/E2E/regression methods: actual results and defects returned to QA Lead; no Issue management or self-awarded final verdict. |
| DevOps | `DevOps/SKILL.md` and CI/CD references: infrastructure, environments, configuration names, pipelines, recovery, costs, and handoff under technical direction. |
| Cybersecurity | Security/privacy responsibilities formerly mixed into DevOps/QA: dedicated domain authority, threat/controls review, evidence, and targeted follow-up. |

Organizer borrows useful coordination mechanics from the old PM/team workflow,
but remains the host orchestrator, not a role or domain decision-maker. The one
exception is PO, which the host carries out itself because it needs a live
discussion with the human.

## Conflicts resolved by the latest document

| Older convention | Current rule |
| --- | --- |
| PM role and repeated human workflow gates | Organizer coordinates; human + PO agree scope, owners execute, human receives the finished PR unless a genuine decision is needed. |
| Model/provider-bound seats and approval gates | Ten model-independent roles; real delegation and truthful execution identity. Each Lead reviews its own team's work; there is no Claude or other provider gate. |
| Local progress dashboard as exclusive tracker | Feature Issue holds durable lifetime work/history; repository docs hold current truth. |
| Per-bug/CR work packages and new tracking entries | Continue the legitimate original feature Issue; update existing truth and retain history. A change to agreed AC is a numbered change record comment on that Issue, not a separate CR file. |
| HTML project documentation with `README.md` indexes | Kept: HTML documents, with `README.md` files as the index chain from the root README down to each application's documents. Per-work-item packages and `CHANGELOG.html` are not carried over. |
| Always-active role notes under `.AI` | Only resumable unfinished state on pause/interruption/blockage/context handoff, kept as Markdown; remove after completion. |
| DevOps as security owner | Cybersecurity owns security/privacy; DevOps implements infrastructure under technical direction. |
| Worker execution mixed with Issue coordination | Leads own their Issue updates and review; Seniors return work and evidence. |
| PO return for routine final business review | QA Lead verifies every AC from actual evidence; PO returns only for business ambiguity/gaps. |
| Implementation/engineering approval dependent on the old gate order | Responsible Lead reviews implementation, then QA executes and QA Lead completes final quality/AC review, then PR. |
| Broad role access to operational credentials | Human authenticates; every agent asks before reading any credential, in any environment. |
| `ocw` launcher, trusted-repo tiers, and OS sandbox | No launcher. Every repository is private and goes only to models the human approved as safe; Seniors work in worktrees that hold no real env file; Cybersecurity checks ignore rules and tracked secret files before delivery. These are instructions, not OS enforcement. |
| Organizer does small edits itself | Organizer makes trivial, no-behavior-change edits itself; a small behavior change takes a short owner route. |
| Work on any Git host | GitHub only; another host stops for a human decision. |

## Draft judgments to review

Useful old preferences are retained in
[project defaults](../skills/dev-team/references/project-defaults.md), including
stack candidates, HTML mockups, TH/EN and theme proposals, social login preference,
the 80% coverage starting target, service naming, release-tag examples, and backup
planning. They do not change existing project decisions or add agreed feature scope.

The synthesis also replaces rigid implementation prescriptions with owner judgment:
research effort scales to the design decision; E2E placement follows QA/DevOps needs;
recovery need not mean an unsafe database downgrade; environments are chosen from
real risk rather than assuming production access; custom cryptography is not copied.
Arbitrary ten-product research quotas, mandatory critique counts, automatic tours,
fixed task durations, and universal UI/ID/cache rules are not enforced.

These are drafting choices, distinct from the user's locked authority and workflow
rules. They can be adjusted without redesigning the team contract.

## Review boundaries

The draft covers role behavior and orchestration instructions, not a separate CLI
runner. Hosts use their actual agent tools or authorized CLIs with explicit task
packets. Installation/check scripts remain independent of GitHub login and models.
Structural validation and installer tests do not prove real agents will comply;
live workflow evaluation remains separate from those checks.
