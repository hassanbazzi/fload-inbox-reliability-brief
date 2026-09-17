# FLO-1355 — review the applied v7 design fixes

17 September 2026 · Documentation only · Implementation paused

Start with the [simple visual overview](summary.html), then [corrected design v7](Fload-Inbox-Revised-Design-v7.md). V7 directly applies the fixes to v6; review the resulting contracts rather than requesting the same edits again.

## Copyable review task

Review v7 against the preserved prototype and the full supporting packet. Follow all six transaction walkthroughs through the actual required/optional/forbidden field matrices. Check concurrency, crash boundaries, effective receipt/outcome resolution, guard-before-read admission, bounded observation and per-step effect permission after reconciliation. Verify schedule snapshots, command abandonment, zero-write cancellation and the fresh post-reopen baseline. Inspect Usage lock order, immutable consumption and version pairs, serial delta charging and fixed-identifier metering recovery.

Current authorization gates apply to new writes/generation; narrowly scoped read-only recovery of already-issued requests must survive revocation. Diagnostic evidence conflicts permit only explicit bounded readbacks and no automatic clearance. A successful prewrite after reconciliation may authorize a never-attempted step only under its still-current original approval; reconciliation alone never authorizes a resend.

For every remaining finding, provide severity, the exact v7 section and source reference, a concrete failing interleaving, and the smallest coherent correction. Distinguish a documentation inconsistency from an unimplemented requirement. Report acceptance gates honestly; do not claim runtime proofs from transaction prose.

Keep this a design review. Do not resume platform implementation, rewrite migrations, reset or stash the preserved worktree, commit/push application code, run live provider actions or deploy. The local prototype is uncommitted; the requester has a private handover with exact paths and a fingerprint.

## What was fixed

- Resource exclusion begins before prewrite inspection; inspection purpose, grant source and single-use consumption are distinct.
- Rescheduling preserves approval and records exact before/after dates; reopen demands a fresh attributed baseline.
- Late evidence resolves its outcome, receipt and generated output together. Manual observations cannot prove native finality.
- Cancellation obeys immediate guards, partial packages retain evidence, and external console races are stated honestly.
- Usage stores exact consumption and policy facts with tenant-safe settlement; metering reuses a frozen identifier and payload within a bounded delivery window.
- Never-sent expired metering is blocked; ambiguous sent metering remains uncertain. Aggregate totals do not justify replay.

## Reading order and status

1. [Corrected v7 field contracts and six traces](Fload-Inbox-Revised-Design-v7.md)
2. [Full inventory and end-to-end specification](Fload-Inbox-End-to-End-Specification.md)
3. [Earlier review findings and acceptance gates](Fload-Review-Resolution.md)
4. [Implementation evidence and limits](Fload-Implementation-Checkpoint.md)
5. [Preserved prototype field catalog](Fload-Inbox-Current-Fields.md) and [DDL](Fload-Inbox-Current-Schema.sql)

V7 touches 28 Actions relations, adds two Usage relations and modifies the existing usage_credit_log: **31 touched relations, not 31 new tables**. The separate historical prototype catalog contains 31 physical tables / 497 columns; it has not been regenerated as v7 DDL. Platform source checkpoint remains f0b1af5fc5925d818be7d9b02b42b1fc54556ecc plus the preserved prototype. No platform edits or fresh application tests occurred during this documentation correction.

---

## Earlier review relay — historical context

# FLO-1355 — handover for the next architecture review

16 September 2026. Documentation updated after independently checking the external review. Implementation remains paused.

## Copyable task

Review the updated Fload inbox reliability packet and reconcile your previous findings with the response. Start with [Review resolution R01–R12](Fload-Review-Resolution.md), then the [specification](Fload-Inbox-End-to-End-Specification.md), [checkpoint](Fload-Implementation-Checkpoint.md), and specialized plans linked below.

Keep permanent tickets, immutable revisions, exact revision approvals, stable batch membership, attributable history and personal-read separation. Challenge schema layout and constraints with concrete alternatives. Strict finite contracts and relational storage are required: no JSONB, serialized JSON payloads, arbitrary key/value fields or catch-all variants.

This is a documentation/design review. Do not resume implementation, rewrite migrations, reset/stash the worktree, commit/push application code, run live provider operations or deploy. The application prototype is uncommitted; a GitHub clone alone does not contain it. The requester has a separate local-access handover with the exact Mac, worktree, branch, test isolation and source fingerprint.

For each R01–R12, give: accepted/disputed/unverified; exact source or official contract evidence; the required architectural change; and a meaningful failing-then-passing regression. Distinguish behavior verified by inspection from runtime reproduction. Produce one coherent proposed design and an explicit unresolved-decision list rather than another competing implementation.

## What changed since your review

- Recovery now requires bounded automatic observation, explicit holds, safe same-ticket reopening after definitive failure, and receipt-persistence recovery without resending provider writes.
- Schema docs no longer treat named nullable columns as sufficient strictness or defend 31 tables as a target. Subtype field matrices and constraint-preserving consolidation are design gates.
- Migration docs now cover search-path leakage, deletion/retention versus immutable guards, missing tenant references and actual application/worker role testing.
- Entrypoint docs now call out partial writer/reader cutover, review identity divergence, generation accounting and impersonated web-chat attribution.
- Inbox docs distinguish correct shared predicates from unresolved parent/child counting and attention semantics.
- Test claims have been qualified against retained logs. No full passing branch, completed migration cutover or deployment is claimed.

## Corrections to address explicitly

Google documents `changesInReviewBehavior`; validate authentication separately. BullMQ's producer timestamp normally cancels the cited producer-clock offset, although duplicate delayed jobs still need promotion. Microsecond fixture inserts are real. Progress deduplication and shared list/count predicates exist. Normal acknowledgement persists its manifest atomically; late evidence is the more precise continuation gap. Dependency has a detail reader. Production RLS bypass and MCP impersonation are not established by the cited evidence. The normal existing-draft UI uses iteration; the generation HTTP endpoint remains problematic.

Do not turn bounded observation into proof of failure, accept an unsupported manual assertion as safe retry permission, or mark pending publication as verified live. Do not use an arbitrary smaller table count as the success criterion.

## Reading map

1. [Review response and acceptance gates](Fload-Review-Resolution.md)
2. [End-to-end specification](Fload-Inbox-End-to-End-Specification.md)
3. [Implementation checkpoint and evidence limits](Fload-Implementation-Checkpoint.md)
4. [Actual unchanged draft fields](Fload-Inbox-Current-Fields.md) and [DDL](Fload-Inbox-Current-Schema.sql)
5. [Provider ownership and consolidation options](Fload-Provider-Boundary-Review.md)
6. [Entrypoints, actors, billing and cutover](Fload-Entrypoint-and-Ownership-Plan.md)
7. [Execution, queues and safe recovery](Fload-Execution-and-Cutover-Plan.md)
8. [Migration, history retention and deletion](Fload-Migration-and-Data-Plan.md)

Public visual artifact: https://hassanbazzi.github.io/fload-inbox-reliability-brief/

Documentation repository: https://github.com/hassanbazzi/fload-inbox-reliability-brief

Platform review baseline: `f0b1af5fc5925d818be7d9b02b42b1fc54556ecc` plus the preserved local uncommitted prototype. The 31-table / 497-column catalog remains a description of that paused draft, not the final corrected design. No new main pull was performed for this documentation response.
