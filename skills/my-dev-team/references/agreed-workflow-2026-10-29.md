# Agreed workflow and testing policy (2026-10-29)

This policy clarifies the existing role instructions. Where older instructions conflict, follow this policy until the original instructions are reconciled.

## Issue-first planning
For new features, PO creates one GitHub Issue and captures business requirements and acceptance criteria. Organizer switches visibly through PO, Design Lead, Technical Lead, and QA Lead, with Cybersecurity and DevOps consulted through Technical Lead as relevant. Each stage discusses its decisions with the human; research delegation within a stage does not replace the conversation. Readiness of one stage means readiness for the next, not implementation.

All planning, including OpenAPI contract drafts, design, security, acceptance criteria and Definition of Done, stays in the Issue. No role writes feature requirement documents to main. Once all required planning owners approve, Technical Lead creates a feature branch, transfers approved documents into repository files, and only then starts implementation.

## API and service documentation
Technical Lead owns API/data contracts and service-level documentation. OpenAPI is the standard format for REST contracts. Specify routes, methods, request and response schemas, validation, error cases, authorization, persistence effects, compatibility and dependencies. Technical Lead resolves contract gaps before dependent implementation. Service docs explain which entry point to use, why, and what it handles (for example, session validation and caching), so callers do not duplicate behavior.

## Test ownership and TDD
QA Lead owns test strategy, acceptance scenarios and Definition of Done. Senior QA owns integration test code and checks API behavior and database effects against the approved contract. Senior Developer owns unit tests and implements through unit-level TDD. Integration tests can be prepared in parallel once contracts and safe fixtures are defined. If tests and code disagree, first compare both to the contract: QA fixes incorrect tests, Developer fixes incorrect implementation, Technical Lead clarifies ambiguous contracts.

## Navigation and change impact
Test location is flexible, but names or indexes must make relevant unit and integration tests discoverable. Code comments should explain method responsibility, significant dependencies and callers, side effects, change impact, and reference key behavioral tests when useful. Do not require an exhaustive list of tests in every comment. Developers update implementation comments when code changes; Technical Lead maintains service-level docs and reviews their alignment. Follow references to relevant tests and run appropriate verification; references do not substitute for testing.

## Delegation and delivery
Organizer never silently delegates away the interactive new-feature planning sequence. Leads may delegate bounded research, review and implementation tasks within their stage, but must present decisions and preserve gates. Developers implement after branch/doc readiness; Technical Lead reviews, QA verifies, Cybersecurity checks relevant risks, then Organizer opens a PR for human review. No automatic merge or deployment.
