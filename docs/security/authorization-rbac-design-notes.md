# Authorization and RBAC design discussion (project-specific guidance)

Status: **Proposed discussion notes for Claude review; not a mandatory universal security standard or an approved application specification.**

## Agreed design direction
- Keep **authentication** (identity/session verification) separate from **authorization** (permitted actions and resources), and separate from AI-team agent roles.
- For projects selecting RBAC, model **users ↔ roles ↔ permissions**: a role can hold many permissions, a user can hold multiple roles, and a permission can be reused by multiple roles.
- Users receive the union of their assigned roles' permissions, subject to resource-specific constraints. Do not grant direct per-user permission overrides by default; any exceptions need explicit project requirements.
- Enforce permissions **server-side** at protected operations; hiding frontend actions is not an authorization check.
- A broad role permission does not bypass **resource ownership, organization/tenant isolation, or other contextual access constraints**. Test cross-account and cross-tenant denials.
- Roles such as Admin, Staff, and Operations are **examples only**, not mandated roles.

## Deferred to the project's Product Owner
- The actual roles, permission catalog, role membership policies, and which actions each role may perform.
- Whether administrators may configure roles/permissions at runtime.
- Whether a role hierarchy exists, its ordering, and which users may view, edit, assign roles to, disable, or otherwise manage other users. **No hierarchy-based editing/viewing rule was approved as a universal standard.**
- Special cases such as separation of duties, privilege delegation, and sensitive approval workflows.

## Implementation and verification handoff
- **PO** defines project business authorization requirements and acceptance criteria.
- **Technical Lead** designs the data model and authorization checks consistent with those requirements; deny by default and prevent privilege escalation.
- **Cybersecurity** independently tests horizontal and vertical privilege escalation, multi-role combinations, ownership/tenant boundaries, unauthorized role/permission changes, and server-side enforcement where applicable.
- **QA Lead** verifies project acceptance criteria and relevant regressions.
- Reuse the shared OWASP playbook's **OW-01** access-control verification and evidence workflow; do not duplicate or redefine the baseline.

## Claude review requested
Confirm that these are correctly marked as project-specific design guidance rather than mandatory RBAC for every application; verify that multi-role permission union cannot override ownership/tenant restrictions; check consistency with existing role responsibilities and OW-01. Correct issues before merging.
