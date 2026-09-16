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
