# FLO-1355 — review the applied v8 corrections

17 September 2026 · Documentation only · Implementation paused

Start with the [simple overview](summary.html), [v7 review disposition](Fload-Inbox-v7-Review-Resolution.md), then the [consolidated v8 design](Fload-Inbox-Revised-Design-v8.md). V8 applies the remaining review fixes directly; v7 remains available as historical context.

## Copyable review task

Review the resulting v8 contracts against the preserved prototype. Check all six transaction walkthroughs and required/optional/forbidden field matrices. Give each remaining issue a severity, exact section/source reference, concrete failing interleaving and smallest coherent correction. Acknowledge resolved findings; distinguish an unimplemented requirement from an inconsistent design.

Concentrate on:

- Post-effects mismatch reopening: every issued write final, no unfinished attempt, latest eligible required-surface evidence, fresh post-reopen baseline and new approval.
- Same-transaction guard release before prewrite backoff, including earlier unresolved writes and stale acquisition generations.
- Independent content equality and request finality. Terminal ACK without a native request ID may combine with complete surface evidence; uncertain writes cannot gain finality from matching text alone.
- Scheduling during claimed inspections, remaining/exhausted grants, version-only attention and source-proven imported dates.
- Fixed-length settlement identity, zero-credit batch evidence and identical confirmation persistence without repeating provider I/O.
- Removal of the unused authorization_version without dropping real policy/recovery authority.

V8 narrows the review's suggested fixes where necessary: it does not require a mismatch or ordinary content match to invent request correlation; it checks unresolved writes globally before guard release; and it avoids ready executions with NULL due times. Meter identifiers hash an unambiguous length-prefixed identity rather than concatenating unconstrained text.

This is a design review. Do not resume implementation, rewrite migrations, reset/stash/rebase the preserved worktree, commit/push platform code, run live provider writes or deploy. The user has a separate private handover with exact device/worktree/assessment paths. A clone alone does not contain the uncommitted prototype.

## Evidence and next gates

All 215 source-manifest entries and platform HEAD f0b1af5fc5925d818be7d9b02b42b1fc54556ecc were rechecked unchanged. No new application tests were run. Source inspection and official contract verification support the design findings, not an implementation pass.

The prototype [field catalog](Fload-Inbox-Current-Fields.md) and [DDL](Fload-Inbox-Current-Schema.sql) remain unchanged historical evidence. V8 touches 28 Actions relations, adds two Usage relations and modifies the existing usage log: 31 touched relations. Its corrections add no tables.

The [full specification](Fload-Inbox-End-to-End-Specification.md), [migration plan](Fload-Migration-and-Data-Plan.md), [provider boundary](Fload-Provider-Boundary-Review.md), [entrypoint inventory](Fload-Entrypoint-and-Ownership-Plan.md) and [evidence checkpoint](Fload-Implementation-Checkpoint.md) supply the wider packet. V8 takes precedence where a contract changed. Full repository checks, migration/queue handoff rehearsal, the provider policy table and coordinated writer/reader cutover remain required before an implementation PR.
