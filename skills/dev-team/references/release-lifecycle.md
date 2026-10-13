# Feature and Release Lifecycle

This reference defines ownership order for normal feature/change work.

## Before implementation

Human -> PO -> Design Lead (when applicable) -> Technical Lead -> QA Lead -> Developer.

- PO owns business requirements, rules, and acceptance criteria.
- Design Lead owns the approved implementation-ready UX/UI contract when design is affected.
- Technical Lead owns technical architecture/specification and incorporates security requirements, involving Cybersecurity as needed.
- QA Lead receives the complete business/design/technical/security package and finalizes the complete Definition of Done and test strategy.
- QA Lead loops back only when requirements are ambiguous, contradictory, missing, or untestable.

## After implementation

Developer -> QA verification -> Draft Release -> Cybersecurity release review -> Human release decision -> DevOps deployment.

- QA verifies every AC and the complete DoD. Failed mandatory criteria remain failed; known issues/risks are reported, not silently waived.
- Draft Release includes QA status/known issues plus DevOps Deployment and Rollback/Recovery plans.
- Cybersecurity independently reviews the actual release according to the applicable security scope and reports findings/known risks.
- The human alone accepts residual release risk and authorizes production deployment.
- DevOps executes only after explicit human authorization and performs post-deploy verification.

Passing QA or Security is not deployment authorization.

## Defects

QA is the first investigation point for reported defects. QA reproduces, gathers evidence, narrows the likely layer, performs impact analysis, and routes actionable evidence to the responsible owner. Pure implementation mismatch against an approved Design System can go directly to Development; a defect requiring a new UX/UI decision returns to Design first.
