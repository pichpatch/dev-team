# Proposal: Context-efficient agent delegation (discussion draft)

Status: **Proposal only — not approved for implementation.** This change is intentionally separate from PR #11. Do not merge or activate until discussed with the human owner.

## Problem
Repeatedly sending full chat histories, large repository documents, and previous tool output to Claude Code or Codex may waste model input tokens and subscription usage. Over-aggressive summarization can omit important requirements and cause rework. The goal is to reduce **total task consumption**, not just initial prompt length.

## Proposed approach: minimum sufficient context
Use three layers for each delegated task:

1. **Essential task packet (always sent):** GitHub issue/revision; objective and definition of done; exact scope and forbidden changes; relevant approved technical decisions; security and privacy constraints; dependencies; worktree and branch; expected verification and escalation path.
2. **On-demand authoritative references:** links or precise paths to original GitHub requirements, architecture decisions, relevant source files, and supporting documents. Never treat a generated summary as a substitute for the authoritative source. Worker reads more when a reference is necessary or a task is ambiguous.
3. **Execution and handover record:** the existing local gitignored `.AI/<feature>/...` worker packet containing milestones, completed work, blockers, evidence pointers, and uncertain side effects. On resume, inspect actual code/worktree and verification evidence rather than trusting status text alone.

## Safety and correctness guardrails
- Never omit approved requirements, acceptance criteria, security constraints, or consequential decisions solely to shrink a prompt. If essential details cannot fit, pause and retrieve/split work rather than silently discard them.
- Workers confirm their interpretation of objective, boundaries, and completion criteria before substantial implementation. Escalate genuine ambiguity to Technical Lead; avoid routine expensive review for trivial work.
- Reference original GitHub records for business scope and permanent decisions. Keep `.AI` for transient execution only, consistent with PR #11.
- Don't repeatedly resend huge context blobs when an exact file/section reference will suffice; don't force multiple retrieval calls when a small necessary excerpt is more efficient.
- Preserve existing confidentiality, model-selection, human approval, and worktree rules. This proposal does not authorize changing those policies.
- Summaries and compaction are lossy; prompt caching may affect API billing differently from subscription usage. Do not promise fixed percentage savings.

## Experiment before adoption
Compare a representative set of tasks under existing delegation and the proposed layered approach. Record available per-task input/output tokens or provider usage indicators, number of tool/model calls, elapsed time, completed acceptance criteria, rework, and failed handovers. Note that subscription five-hour/weekly quotas may not map directly to raw token totals.

Accept only if the new approach maintains correctness and shows a meaningful reduction in overall resource use; otherwise revise or abandon it.

## Open questions for later discussion
- Which exact details belong in the always-sent packet versus fetched on demand?
- How should the Organizer choose relevant source references without expensive exploratory calls?
- What is the smallest useful preflight confirmation, and when should Technical Lead review it?
- How can Claude Code and Codex usage be measured comparably without inventing quota equivalences?
- Should context optimization be a general delegation policy or an optional experiment flag?

**Out of scope:** changing role/model bindings, replacing the Organizer with a subagent, runtime automation, editing PR #11, or merging any PR.
