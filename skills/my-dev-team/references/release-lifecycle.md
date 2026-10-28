# Feature and release lifecycle

Who owns what, in order.

## Before implementation

Human → PO → Design Lead (when needed) → Technical Lead, with DevOps and
Cybersecurity (when needed) → QA Lead → Developer.

The human can talk to PO, Design Lead, Technical Lead, QA Lead, and
Cybersecurity in one session, in any order
([talking to the Leads](orchestration.md#talking-to-the-leads)); the work then
runs in this order.

- **PO:** business requirements, rules, and AC.
- **Design Lead:** the approved, implementation-ready UI contract, when design
  is affected.
- **Technical Lead:** architecture and specification; calls in DevOps and
  Cybersecurity and builds in their requirements. It decides what is built; a
  security requirement it does not follow is recorded with the reason and told
  to the human.
- **QA Lead:** receives the complete package and finalizes the DoD and test
  strategy. Loops back only for something ambiguous, contradictory, missing, or
  untestable.

## After implementation

Developer → Technical Lead review → QA verification → Cybersecurity feature
check → finished PR → (when the human asks) Cybersecurity release review →
fixes and independent retests → DevOps draft release → human release decision →
DevOps deployment.

- QA verifies every AC and the complete DoD. Failed mandatory criteria stay
  failed; known issues are reported, never silently waived.
- A draft release is prepared only when the human asks
  ([draft release](orchestration.md#draft-release)). It includes QA's status and
  known issues, and DevOps's Deployment and Rollback/Recovery plans.
- Cybersecurity reviews the release before the draft is created. Technical Lead
  owns fixes; Cybersecurity retests the bounded scope
  ([security report rules](owasp-security.md)); Senior QA reruns affected tests;
  QA Lead approves the new evidence. Unaffected approvals stay valid.
- The human alone accepts remaining risk and authorizes deployment. DevOps acts
  only after that, then verifies the deployment.

Passing QA or security is never deployment authorization.

## Defects

QA investigates reported defects first: reproduce, gather evidence, narrow the
layer, analyze impact, then route the evidence to the owner. A pure mismatch
with the approved Design System can go straight to Development; a defect that
needs a new UX or UI decision goes to Design first.

## Ownership boundaries

- **Design** owns what users see and how the interface behaves. Development
  implements it and never invents a missing UI decision.
- **The Design System** is the UI source of truth. Senior Designers evolve
  routine components while working; only foundational or product-wide changes
  go to Design Lead first.
- **QA Lead** owns the DoD, the test strategy, and the final quality status.
  **Senior QA** owns hands-on testing, investigation, impact analysis, and
  retests. PO does not re-check AC once QA's evidence is complete.
- **DevOps** owns deployability, reliability, recovery, observability,
  reproducible infrastructure, cost, and safe production operations, not the
  release decision.
- **Cybersecurity** owns security truth and constraints. **Technical Lead** owns
  architecture and decides what is built, telling the human when a security
  requirement is not followed.
- **The human** alone accepts remaining risk and authorizes release and
  deployment.
