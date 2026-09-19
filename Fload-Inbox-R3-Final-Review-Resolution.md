# Final destination review — five clarifications applied

19 September 2026 · Documentation only · Platform implementation paused

The review confirms C1–C6 and the accepted ownership boundaries. D1–D5 are addressed in the existing contracts and matrix; no architecture rewrite or extra table is introduced.

| Finding | Applied result |
|---|---|
| D1 · Two meanings of attention | An attention slot counts a current client-action obligation. `attention_version` is a shared unread change counter; personal `seen_attention_version` is a read watermark. Capacity never reads either. Counter changes are named explicitly in the matrix/contracts |
| D2 · New blocker admission | A refusal on never-admitted work preserves its typed planning reason; a new client-facing card uses the same admission guard and consumes a slot. Exhausted headroom stops additional new-work preparation. Blockers on existing unfinished work always surface, even above five |
| D3 · Human adoption/reconsideration | Admission follows cause, not actor. New historical→work adoption and restart of declined/acknowledged work require room even for a human. Historical-only restore uses zero slots. Undo and proved recovery of an existing unfinished commitment cannot be refused for capacity; all count-affecting commands share the guard and lock order |
| D4 · Reuse wait modes | Existing derived `scheduled`/`automatic` waits use no slot; `recheck_required` uses one. Stronger client-required obligations take precedence, even when automatic read capacity remains. No second wait heuristic or persisted flag |
| D5 · Stale source and copy | Contracts now point to merged `324b05de` and distinguish unchanged schema inventory from changed writers. PR 1447 copy must account for hourly refills and must not claim all apps are full from an any-app test |

The review offered human exemption as one product option. The plan retains the previously selected all-entry-point admission rule: requesting new work manually is not an automatic bypass. This is distinct from editing an admitted task or recovering an existing failed execution. Exact before/after state and accepted admission/obligation lineage, plus execution lineage where applicable, decide the branch, not an old ticket ID or the actor's channel.

A namespaced transaction-scoped advisory guard is preferred over locking the shared asset row, avoiding unnecessary coupling to sync/metadata updates. Its encoding and global lock-order integration still require implementation proof. Proposed closed refusal `client_attention_capacity` reuses immutable command receipts; a replay stays refused even after capacity changes, and a new attempt needs a new key and fresh pins. No open payload or mutable slot counter is added.

[Admission and exact transition rules](Fload-Inbox-R3-Parallel-Work-Coordination.md) · [Historical matrix](Fload-Inbox-R3-Historical-Ticket-Matrix.md) · [Destination fields](Fload-Inbox-R3-Destination-Contracts-v2.md) · [Visual summary](ownership-overview.html#coordination-heading)

The five-client-attention policy remains confirmed; detailed schema proposals are not final DDL. Remaining work: E4 strict child/variant codec, native identity proof, historical leaf matrices, collection adoption, retained review access/erasure, R2 codecs, complete DDL/types and fresh writer/data census with migration/concurrency/crash tests. This pass changes documentation only, with no platform edits, database/provider operations, cleanup, runtime tests or deployment.
