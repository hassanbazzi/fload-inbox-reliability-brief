# FLO-1355 — R2/R3 v2 review disposition

18 September 2026 · Six clarifications applied · Implementation paused

**The independent review confirms the corrected rules and source inventory.** It found no contradiction with the accepted ownership design, carried behavior or pinned source. Its six low clarifications are now explicit in the [current v2 draft](Fload-Inbox-R2-R3-Schema-Design-v2.md). We retain v2 rather than create another architecture version.

[Visual overview](ownership-overview.html) · [212 source fields](Fload-Inbox-R3-Source-Fields.md) · [Earlier correction assessment](Fload-Inbox-R2-R3-Review-Resolution.md)

## Applied clarifications

| Item | Explicit rule now in v2 | Why it matters |
|---|---|---|
| C1 · Idempotency mismatch | Refuse the command request; preserve the original command/receipt. Existing `outcome='conflict'` plus `error='idempotency_mismatch'` is a response, not a `conflicting_completion` evidence row. | A bad retry cannot manufacture provider evidence, holds or unread changes. |
| C2 · Usage versus execution | The unresolved conflict prevents successful execution settlement. Actual model consumption remains eligible for normal Usage recording and settlement against the original generation attempt. | An execution hold must not drop or indefinitely postpone incurred usage, or charge it twice. |
| C3 · Contradiction after terminal outcome | The planned worker-side operational integrity monitor scans durable conflicting captures independently of due-execution eligibility and surfaces a deduplicated ops finding. | A terminal ticket has no ordinary delivery wake; its contradiction must still reach operators without rewriting its outcome or customer read state. |
| C4 · Expiry while conflict is unresolved | If no definitive completion is available, classify the expired write as `uncertain/claim_expired` through the fenced database-only path, then enter the diagnostic hold. No automatic provider readback or resend follows. | Preserving claim recovery does not authorize ordinary delivery during an evidence conflict. Explicit bounded diagnostic Reconcile retains its existing rules. |
| C5 · Required baseline on imported work | Use fresh evidence. Import performs no provider I/O and leaves the source component blocked when a required baseline is missing. A separate canonical read precedes atomic source/target revalidation and complete adoption. | Historical content cannot silently become the baseline authorizing newly executable work. No invalid ticket skeleton or second work identity is created. Declined review suppression remains intact. |
| C6 · Known system or agent initiator | Preserve positively recorded initiator facts separately from unavailable identity. Missing user identity or a policy setting alone never invents a historical actor or approval. | Known automation stays attributable without labeling unknown authors as “system.” |

C5 selects the conservative fresh-evidence option offered by the review. Required-baseline checks remain in force; no table, new lifecycle state, background API timer or alternative legacy workflow is introduced. The `baseline_required` / `incomplete_revision` names are carried design validation outcomes, not a claim about implemented prototype migration errors.

## What the review closes—and what it does not

This closes the six clarification items. Ownership v6 remains accepted. R2 still needs complete per-provider capture codecs, manifest constraints and executable structural matrices. R3 still needs the exact destination for each source field, nested payload variant and discovered relationship. DDL, runtime safety and migration validation are not complete.

The next substantial document is the **conservation ledger**:

1. Assign every named source column and nested variant an exact typed destination, retained domain reference, reviewed retirement or explicit unresolved blocker.
2. Include same-work consolidation, historical approval/membership proof, old aliases, actor and asset/global scopes, source freshness and required baselines.
3. Justify each final history relation by its owner, determinant, cardinality and constraints. Do not mirror old tables or choose a target table count in advance.
4. Provide value/link conservation, restart, source-change and erasure fixtures. Unknown native outcomes and missing facts must remain explicit.

No further review of unchanged ownership decisions is requested. A concrete newly discovered defect should still be reported.

## Evidence and validation limits

- The reviewer independently confirmed the twelve-table census: 212 declared columns, including 23 JSONB columns across nine tables. `test_plan` belongs to ASO experiments, not recommendations.
- The census remains pinned to `e2cc156994855e401a83399fbb4c3d7be5194875`. Local `origin/main` is now `94685451be84b5199e344f11a614ec1206930657`; read-only comparison shows no changes in the database package or inbox wire contract between those pins. Payload writers still need explicit version checks when completing their decoders.
- C1's existing response semantics were checked in the preserved Core command service. C4 follows the carried diagnostic-hold admission rule. C5 was checked against baseline sealing, declined-review replacement and the prototype importer; C6 against the actual initiator field.
- The [exact reviewed v2](https://github.com/hassanbazzi/fload-inbox-reliability-brief/blob/3d66aa9ff728f52d148e20b0c74a545e6d5c89e9/Fload-Inbox-R2-R3-Schema-Design-v2.md) is preserved. The current v2 adds clarification and status text; the source checklist remains unchanged.
- This is a documentation assessment. No application tests, migrations, provider calls, source retirement or production deployment were performed.
