# What remains before implementation

20 September 2026 · Current build-readiness checklist · Implementation remains paused

**We do not need another whole-system redesign.** Ownership is settled and the conservative E4 migration direction is worth keeping. We need one consolidated build contract that resolves the remaining concrete schema/command gaps. Writing that schema and its tests is the first implementation phase; production migration proof comes later.

## Finish these contracts before the affected implementation slice

| Deliverable | Exact remaining work | Done means |
|---|---|---|
| **1. One schema and type bundle** | Consolidate Actions, content domains, provider-owned native leaves, Usage and history. Decide physical relations by owner, determinant, cardinality and erasure lifecycle. Include all columns, closed enums, NULL/absence rules, PKs/FKs, uniqueness, immutability, indexes, roles and erasure order. Derived facts stay projections. | One versioned DDL/Drizzle and strict Zod/TypeScript contract set; one fact has one owner; no JSONB/EAV/open payload escape hatch. The frozen prototype is reference material, not a migration to replay |
| **2. Remaining content/history shapes** | E4 G1 parent-prose owner/sealing; G2 unequal repaired-outcome conservation; per-leaf historical-purpose matrices; exact import command payloads and audit anchors; collection adoption; old-link result shapes and retained review identity/access/erasure. Resolve missing snapshot/proof FKs and approval-policy presence shapes. | Every enabled branch is precisely representable. Unsupported branches are explicitly blocked with a truthful visible disposition; no guessed content, silent dropped source or permission-by-status |
| **3. Enabled provider contracts** | Exact identity proofs and scope for ASC/Play, plus typed receipt/evidence/observation/manifests and replay tuples for conflicting/late completions (R2). Close provider enum and capture-presence matrices, immutable operation/plan contracts and uncertain-outcome behavior for each enabled operation. | An adapter has an exhaustive closed input/output/proof contract. Unproved ASC association remains disabled; provider-native facts remain outside Core. This does not require inventing future Meta/TikTok integrations |
| **4. Producer, queue and read contracts** | Refresh changed writers/readers against the chosen main commit. For every current entry point, name canonical command, permanent creation key versus command key, SQL obligation/eligibility query, queue wakeup and restart recovery. Fix package/child attention counting and list/count/pagination agreement; exact re-check replacement scope; deterministic deferral/re-offer; common lock order. | No second lifecycle writer, lost queue-only obligation, browser-only acceptance or ambiguous counting unit. Existing queues have named responsibilities; no competing generic jobs lifecycle |
| **5. A bounded build and migration plan** | Sequence schema, canonical commands, reads, dispatch/providers, source adapters and cutover. For each slice list acceptance fixtures and old paths to convert/remove. State the positive disposition protocol for outstanding accepted work. | Reviewable PR boundaries and deletion criteria; one authority after cutover. No permanent compatibility workflow and no unsafe one-shot switch |

G1/G2 are design gaps discovered during E4 integration. The other rows consolidate already identified work; they are not five new architecture projects. The exact physical table count follows this consolidation, not a quota.

## What can begin without waiting for every later branch

Start in a **new repository-managed, isolated worktree from verified main**, leaving the preserved prototype intact. The first slice should establish canonical identity, immutable revisions, attributable command/history, shared workflow versus personal read state, and list/count queries for one existing non-provider advisory kind. Write the relevant schema and strict wire contract first, then test them through the real repository adapters. This avoids beginning with the hardest provider write or an incomplete historical import.

The slice may be built behind an inactive path while the old product remains authoritative. Do not run two authoritative writers for the same work. It must not cut over existing data until its migration/consumer closure is proved. The advisory slice does not claim the full overhaul is delivered.

After its schema/command contract is fixed, other domain codecs can be built independently against that contract. G1/G2 block affected historical-request imports, not every pure Core function. Native proof gaps block their provider branch, not read-state separation. Keep these dependencies explicit instead of imposing a global pause for unrelated tests.

## During implementation — this is work to do, not proof required before writing code

- Generate fresh Drizzle migrations from current main; never apply the prototype's colliding migration numbers or use db:push.
- Implement the canonical commands/transaction adapter and strict API/client types. Test conflict/replay, revision-pinned approval, iteration versus approval, Undo deadlines, actor history and tenant scope.
- Implement SQL dispatch/recovery and queue wakeups. Test retries, crashes at every persistence/I/O boundary, duplicate workers, stale fences, lost notifications and uncertain provider outcomes.
- Implement ASO/localization, review replies/batches, agent requests, advisory and historical adapters. Verify fixed identities, immutable membership and revision references, reused human-edited drafts and exact handoffs.
- Test real PostgreSQL constraints/roles, erasure, sealed content, migration round trips and list/count pagination using repository test requirements. The 43 E4 Python vectors are supplemental design checks only.
- Convert every producer and consumer, including reports, detail URLs, reset/admin tools and retained ASO/review tables. Remove superseded workflow authority when cutover criteria pass.

## Before migrating or enabling the new system

These are rollout gates, not reasons to postpone the first coding slice:

1. Read-only representative data investigation, with actual counts for missing references, legacy store ambiguity, source-shape differences, timestamp provenance and suppression preimages. Use findings to complete any affected blocked decoder before migration.
2. A fresh authoritative census after all concurrent cleanup/report changes and under the writer fence; exact value/link/receipt conservation and a rehearsed importer with crash/replay checks.
3. Drain/reconcile every accepted unfinished obligation or assign its reviewed durable successor/explicit disposition. Stopping queues is insufficient; uncertain writes require their proper readback/recovery evidence.
4. Prove converted readers/writers, access controls, telemetry and rollback/cutover procedure. A phased deployment may be temporary; it must not leave a permanent parallel legacy workflow.
5. Satisfy repository CI and review requirements. Production deployment is outside the current authorization.

## The immediate next deliverable

A consolidated **schema-and-command build specification**, with a dependency map and first PR acceptance criteria. Close G1/G2 in that pass; do not ask for another general “is this architecture good?” review. Then start the first implementation slice when implementation is resumed. Final physical DDL and production readiness are not claimed complete today.

[Drift assessment](Fload-Inbox-R3-E4-Reconciliation.md) · [E4 revision 4.2](Fload-Inbox-R3-E4-Variant-Child-Codec.md) · [Owner boundaries](Fload-Inbox-Ownership-Design-v6.md) · [Current destination contracts](Fload-Inbox-R3-Destination-Contracts-v2.md)
