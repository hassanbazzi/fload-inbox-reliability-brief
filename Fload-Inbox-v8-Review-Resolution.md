# FLO-1355 — v8 review disposition and v9 corrections

17 September 2026 · Documentation only · Implementation paused

The independent review confirmed all eleven v7 findings were resolved in v8. It found one high and one medium gap, plus four smaller clarifications. The [consolidated v9 design](Fload-Inbox-Revised-Design-v9.md) integrates the corrections into the governing contracts. Start with the [simple overview](summary.html) for the team walkthrough.

| Finding | Disposition and correction |
|---|---|
| R1 · Exhausted verification cannot reach reopen | Confirmed. Add total readback outcome and deadline-expiry transitions. A final write with complete required-surface mismatch can enter blocked/target_changed and the existing reopen flow. Any non-final issued write instead preserves uncertainty and exclusion. A recovery wake can normalize state without admitting another observation. |
| R2 · Binding and prewrite outcomes overlap | Confirmed. Give binding its own closed no_editable_release reason, requiring a successful complete provider check. Preserve awaiting_release after timer capacity expires; an eligible deduplicated release event grants one new binding inspection. Transport failure is not proof that no release exists. |
| R3 · Inspection terminal flag | Clarified. A matched/mismatch inspection records terminal_outcome=FALSE; unfinished/unreadable inspections use NULL. The same rule applies to late inspection evidence. An inspection does not finalize an issued mutation. |
| R4 · retry_exhausted has two meanings | Accepted without another hold enum. Current read models and capabilities require a closed attempt-derived qualifier. History uses a qualifier only with immutable causal anchors and an established evidence cutoff; otherwise it reports the reason unavailable diagnostically. Inspection-only exhaustion cannot be shown as a rejected write or offer mutation Retry. |
| R5 · Pricing versions between calls | Confirmed. The first committed invocation pins pricing/policy versions for the attempt; later calls copy those versions under the existing Usage lock. Concurrent first calls serialize. Missing pinned pricing refuses model I/O instead of repricing history. |
| R6 · Failed cache zeros versus nullable completed counts | Clarified while retaining the strict CHECK. Failed means proven zero consumption, so cache/token/cost zeros are known facts. Completed may omit an unreported cache breakdown only with exact known cost. Ambiguous consumption remains unknown. Making both statuses equally nullable would discard useful evidence. |

Two adjustments to the suggested fixes preserve the current invariants. An exhausted unresolved write becomes blocked/uncertain_write with no due time; retaining phase uncertain with a NULL due would violate the retained phase constraint. A release event is scoped, deduplicated and subject to current execution/authority checks; it does not unconditionally bypass readiness. Publication waiting requires typed pending evidence at the exact target and surface, not generic mismatch.

The design adds **no tables in this pass**. Total scope remains 28 Actions relations, two new Usage relations and one modified existing Usage log: 31 touched relations. The [prototype field explorer](Fload-Inbox-Current-Fields.md) and [DDL](Fload-Inbox-Current-Schema.sql) remain unchanged historical evidence, not regenerated v9 schema.

Required implementation fixtures now explicitly include final ACK → six mismatches → target_changed → reopen → fresh baseline/revision/approval; expiry between deliveries; unresolved sibling writes; release appearing after binding exhaustion; duplicate release events; inspection flag rejection; historical hold qualifiers; concurrent first invocation admission; pricing changes between calls; and the consumption-evidence status matrix. These are required cases, not executed application tests.

All 215 recorded prototype entries and its base commit remain unchanged. No platform code, migration execution, application test run or provider write occurred. The existing per-operation recovery decoder, target adoption, transactional Usage settlement, migration/queue rehearsals, complete producer/reader/writer cutover and repository checks remain implementation gates. Review those gates separately from design consistency.
