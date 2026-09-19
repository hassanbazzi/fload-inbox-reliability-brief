# Destination contracts v2 — independent review follow-up

19 September 2026 · Documentation only · Implementation paused

The review confirms the ownership, identity and conservation corrections. Its baseline-capture finding is valid; several proposed fixes needed narrower source-grounded rules. The contracts remain v2, with the changes below applied. No new architecture version or final DDL is claimed.

[Updated contracts](Fload-Inbox-R3-Destination-Contracts-v2.md) · [Updated historical-ticket matrix](Fload-Inbox-R3-Historical-Ticket-Matrix.md) · [Related cleanup and cadence work](Fload-Inbox-R3-Parallel-Work-Coordination.md) · [Visual summary](ownership-overview.html#destination-heading)

| Finding | Applied disposition |
|---|---|
| M1 baseline command was forbidden | Added bounded canonical observation paths for historical/open preparation **and** historical/declined source-change preparation. Neither reopens work. Existing failed-perform-reopen rules remain separate; read-start must follow the committed exact boundary |
| M2 overloaded restore | Bound placement/reconsider/unhide into a closed restore_mode, immutable command and digest. Kept exact preimage checks, the historical unhide-only superseded exception, and existing failed non-perform work recovery |
| M3 history group asserted prematurely | Both documents now leave placement explicitly undecided within the single-list product rules; no new tab or verified-success inference |
| L1 finite head shape | Explicit work/historical/historical_deleted purpose branches, NULL-safe committed structure and purpose-aware read/count projection. No blanket widened head guard |
| L2 unnamed adoption link | Reused existing accepted revise target previous_revision_id→result_revision_id. No new adoption column and no generation-provenance overload |
| L3 native association destination | Named an ASC-owned candidate association and exact observation reference. No unproved reverse uniqueness. Cached IDs and first content matches are not identity proof; the strict native proof codec still gates admission |
| L4 replay diagnostics | Preserved original command receipts and idempotency precedence. Independently verified source diagnostics belong in authorized preflight; they never overwrite a receipt or create an open payload |
| L5 archive command | Named attention-neutral import archive after disposition reconciliation. Backlog has archive fields; pending_action does not. Deletion, personal overlays and archived ancestors cannot hide current work |
| L6 legacy suppression behavior | Explicit product note: unknown original rejected content can require present reconsideration even after a store review changes. The old claim does not veto all future decisions forever |
| E4 writer/topology | Corrected the review: aso-agent.ts:1186 writes hypothesis pendingActionId. Locale outputs can reuse protected existing cards and carry create/update/repair, so references cannot prove newly generated children |

Restore modes improve intent and audit clarity; the old exact-version/idempotency guards already prevented replaying one unhide as a different decision. The review's cited approval-principal SQL is not a restore authorization rule. Existing work permissions remain in force.

The new observation paths reuse carried refresh provenance and record_observation. They do not introduce a historical execution or grant delivery authority. Adoption still installs a new exact proposal on the same ID and requires a fresh approval.

## Related work affects integration

The supplied parallel conversation and inspected FLO-1437/FLO-1438 PRs change admission and presentation: five open tasks per app, weekly top-ups, earlier months collapsed and prerequisite-specific check labels. That first checkpoint inspected open PRs. Both have since merged; the [subsequent follow-up](Fload-Inbox-R3-Destination-Followup-Resolution.md) verifies two remaining admission gaps and updates exact source pins. Deployment is not verified. The reported operational expiry is migration input, not a command for this task to repeat it.

The coordination note requires a single durable-work count/admission rule, atomic capacity checks, exact replacement deltas, recovery independent of suggestion capacity, and a fresh post-cleanup/report census. It omits private customer names and operational counts.

Still open: native identity proof and scope; complete historical content/leaf matrices; collection adoption; retained-domain access/erasure; R2 codecs; consolidated DDL and real migration/concurrency/crash tests. The written fixes are not runtime test results. No platform code, database, provider or production deployment changed in this pass.
