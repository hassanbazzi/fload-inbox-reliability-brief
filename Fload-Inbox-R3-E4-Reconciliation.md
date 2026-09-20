# E4 reconciliation — keep the evidence model, close the integration gaps

20 September 2026 · Documentation only · Implementation remains paused

**Verdict:** the parallel work improved the migration design. It did not replace Actions with another workflow engine or introduce provider fields into Core. Keep its conservative reference model. The claim that the entire E4 mapping was ready to implement was too broad: two schema integration gaps remained, plus ambiguous normalization wording. [Revision 4.2](Fload-Inbox-R3-E4-Variant-Child-Codec.md) reconciles those points with the governing documents.

## What actually changed

| Area | Earlier E4 proposal | Reconciled approach |
|---|---|---|
| Draft authorship | Infer generated/reused work from current timestamps, run IDs and matching mutable text | Preserve the recorded reference. Do not claim authorship without retained proof |
| Request → listing | Infer child successors from those same signals | Keep separate request and listing identities with exact typed reference navigation |
| Package outputs | A package-root reference could be confused with a child ticket | Expand the exact sealed package membership into its pinned child revisions |
| Deleted/recreated IDs | A currently present deterministic ID could look like the original output | Preserve missing-target and proved-recreation facts; show replacements honestly |
| Repeated completions | Current columns or one event could hide earlier references | Preserve every source occurrence, event identity and ordinal |
| Parent notes | Attach agent notes to a generic collection, despite its forbidden-leaf rule | G1: finish one explicit typed owner and sealing contract; preserve source and block unsupported import meanwhile |
| Repaired outcome | Admit differing data while claiming an existing destination | G2: equality-only retirement remains; unequal shapes wait for a lossless closed codec |
| Diagnostics | Potentially store several summaries of already retained facts | G4: compute closed, versioned projections; keep source occurrences and snapshot bindings authoritative |

The first five changes are improvements. They concern what can truthfully be imported from old records. New runtime work must still record actual generation, actors, immutable content, exact approvals, durable children and outcomes. Conservative migration does not weaken those future requirements.

## The remaining schema gaps, precisely

**G1 — request-parent prose.** E4 placed `whatWillHappen` and directed `supportingEvidence` on collection-parent content notes. Ownership v6 allows membership only for the generic collection proposal. Pick one canonical typed owner, integrate proposal/historical sealing and reader/erasure rules, and avoid duplicating parent text onto every locale. This could reuse the existing notes relation through an explicit closed shape; no new physical table is approved by this review. The affected import stays blocked until the shape exists.

**G2 — repaired `proposedOutcome`.** The conservation ledger retires it only when it exactly equals the documented projection of `evidence`. FLO-822 can leave a different shape, and it spreads prior keys. The accepted documents do not yet name a lossless destination or reconstruction codec for every admitted difference. Preserve the source and block that component as `unmapped_content`; do not erase differences, default a store, or accept an arbitrary payload. Finish the strict shape inventory and value/presence/ordinal mapping before admitting these rows.

**G3 — unfinished obligations.** This is an existing cutover rule made explicit, not a new architecture: stopping old workers does not complete approved drafting, verification or delivery. Every unfinished obligation requires a reviewed durable successor or an explicit authorized non-executing disposition before source retirement. Unknown outcomes remain recovery blockers. A migration cannot fabricate a new approval to bridge the gap.

**G4 — normalized diagnostics.** Preserve immutable evidence once. Reset flags, approval-basis summaries, recreation conclusions and their witness set are typed read projections over source facts and the pinned interpretation. The two stored output-link CHECKs enforce target-pair completeness and column ordinal; calculated diagnostics do not become SQL columns merely to duplicate the same evidence. Consolidate the overlap between event-output occurrence storage and request-output links in final DDL.

## Decisions retained after independent challenge

- Missing historical store evidence stays a counted preflight blocker. Today's single-store asset state does not prove an old request's scope. A history-only fallback requires an actual typed conservation design, not a one-line exception to component atomicity.
- For an approved request with valid explicit evidence and `approvedAt`, the inventoried writers support latest-approval manifest proof without ordering equal timestamps. Historical V1d still requires proved writer provenance; the directed constructor generates a new attempt ID internally. No same-key directed-upsert defect was reproduced.
- The five-client-attention policy, positive admission checks, exact replay and durable producer rediscovery remain unchanged. No new generic job table or provider-native Core column is introduced.

## Versions and verification

The supplied review covered revision 4 (`358022f8…`), while the working document had advanced to 4.1. The parallel handover embedded in its review was updated, but this task's handover, public overview and Linear checkpoint still said E4 was next. They now point to revision 4.2 and this reconciliation. Earlier reviews remain dated evidence rather than being rewritten as current verdicts.

Source checks used exact commit `e7c094c81b54e13e52d329f39157a39fb99a3c98`; remote main was independently verified at the same commit on 20 September. The preserved prototype still matched all 212 recorded file hashes, three recorded absent paths and 145 status entries. No reset, pull, rebase or platform edit was performed.

Three bounded independent audits covered source writers, architecture and schema/test semantics. The supplied 43 Python model tests passed. They do not run the importer, database constraints, application writers, real roles, concurrency, crash recovery or migrations; the revised specification lists 27 implementation fixture groups. No production data was inspected.

## Next work

Use the [implementation-readiness checklist](Fload-Inbox-Implementation-Readiness.md). Finish the named contracts and consolidated schema, then build in tested vertical slices. Do not repeat a broad architecture redesign or treat every future test as a prerequisite to starting code.

[Current E4 specification](Fload-Inbox-R3-E4-Variant-Child-Codec.md) · [Destination contracts](Fload-Inbox-R3-Destination-Contracts-v2.md) · [Historical lifecycle](Fload-Inbox-R3-Historical-Ticket-Matrix.md) · [Visual overview](ownership-overview.html#e4-heading)
