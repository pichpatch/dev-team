# Feature and Release Lifecycle

This reference defines ownership order for normal feature/change work.

## Before implementation

Human -> PO -> Design Lead (when applicable) -> Technical Lead -> QA Lead -> Developer.

The human can talk to PO, Design Lead, Technical Lead, and QA Lead in one
session, in the order they choose ([talking to the Leads](orchestration.md));
this is the order the work then runs in.

- PO owns business requirements, rules, and acceptance criteria.
- Design Lead owns the approved implementation-ready UX/UI contract when design is affected.
- Technical Lead owns technical architecture/specification, calls in DevOps and Cybersecurity as needed, and incorporates their requirements. It has the final decision on what is built; a security requirement it does not follow is recorded with the reason and told to the human.
- QA Lead receives the complete business/design/technical/security package and finalizes the complete Definition of Done and test strategy.
- QA Lead loops back only when requirements are ambiguous, contradictory, missing, or untestable.

## After implementation

Developer -> QA verification -> finished PR -> Human requests draft -> Cybersecurity release review -> affected fixes and independent retests -> DevOps draft release -> Human release decision -> DevOps deployment.

A Draft Release is prepared only when the human asks for one ([draft release](orchestration.md)).

- QA verifies every AC and the complete DoD. Failed mandatory criteria remain failed; known issues/risks are reported, not silently waived.
- Draft Release includes QA status/known issues plus DevOps Deployment and Rollback/Recovery plans.
- Cybersecurity independently reviews the release before the draft is created. Technical Lead owns remediation, Cybersecurity retests the bounded scope in the [security report rules](owasp-security.md), Senior QA reruns affected tests, and QA Lead approves updated evidence; unaffected approvals remain valid.
- The human alone accepts residual release risk and authorizes production deployment.
- DevOps executes only after explicit human authorization and performs post-deploy verification.

Passing QA or Security is not deployment authorization.

## Defects

QA is the first investigation point for reported defects. QA reproduces, gathers evidence, narrows the likely layer, performs impact analysis, and routes actionable evidence to the responsible owner. Pure implementation mismatch against an approved Design System can go directly to Development; a defect requiring a new UX/UI decision returns to Design first.

## Ownership boundaries

- **Design** owns what users see and how the approved interface behaves. Development implements it and does not invent a missing UI decision; an unspecified one returns to Design.
- **The Design System** is the UI source of truth. Senior Designers evolve routine components and variants while working; only foundational or product-wide changes go to Design Lead first.
- **QA Lead** owns the complete Definition of Done, the test strategy, and the final quality status. **Senior QA** owns hands-on execution, investigation, impact analysis, and retest evidence.
- **QA verifies every AC.** PO does not repeat that check after implementation when QA's evidence is complete.
- **DevOps** owns deployability, reliability, recoverability, observability, infrastructure reproducibility and cost, and safe production operations. It does not own the release decision.
- **Cybersecurity** owns security truth and constraints. **Technical Lead** owns architecture and patterns and has the final decision on what is built, telling the human when a security requirement is not followed.
- **The human** alone accepts the risk that remains at release and authorizes release and deployment.

