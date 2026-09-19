# R3 destination contracts — review and corrections

**Latest follow-up:** [Destination v2 independent review](Fload-Inbox-R3-Destination-v2-Review-Resolution.md) applies the capture/restore/source clarifications and records [parallel cap, UI and cleanup work](Fload-Inbox-R3-Parallel-Work-Coordination.md). No implementation or migration proof is implied.


19 September 2026 · Documentation only · Implementation paused

The new proposal makes real progress on concrete fields, but its claim that B9–B13 were complete was premature. The corrected v2 and historical-ticket companion preserve the settled ownership architecture and repair the specific contracts below. These are documentation changes; no application schema or migration has been applied.

[Corrected destination contracts](Fload-Inbox-R3-Destination-Contracts-v2.md) · [Historical-ticket matrix](Fload-Inbox-R3-Historical-Ticket-Matrix.md) · [Visual summary](ownership-overview.html#destination-heading)

| Issue in the submitted proposal | Correction |
|---|---|
| ASC/Play aliases added to Core | Native identity mapping stays in provider schemas; Core keeps only old Fload aliases |
| Per-edge keys could conflict on a normal backlog→request→card handoff | Compute proved same-work classes first, select one canonical anchor, include E14 lineage in closure, compare full identity tuples on hash-key conflicts |
| Play bridge claimed more proof than its retained evidence supplies | Separate frozen pair values from historical mapping proof; disable unsupported evidence origins; keep account scope/cardinality and exact erasure references explicit |
| Historical revision could become proposal in place; execution params became execution proof | Create a separate new proposal; preserve source-to-snapshot references without inventing execution proof |
| Rejection fingerprint uniqueness could lose separate rejection events | Uniqueness follows source rejection identity; fingerprint lookup is nonunique; future proof uses exact rejected revision/source snapshot |
| Agent actor inferred from event shape | Require row-linked actor provenance; otherwise preserve the run link with actor unavailable |
| Keyword context and successful release verification were incompletely mapped | Enumerate all 13 keyword fields and all three provider verification fields; preserve presence, NULL, order and duplicates |
| Nullable gloss check and field/value historical storage | Require both gloss pins explicitly; use concrete named before-listing columns, not EAV |
| Replay could return before command digest checks; schedule ran after reject | Validate the entire command/mapping/source plan before replay; initialize valid schedules while open, then apply terminal decisions |
| Historical completion implied success; deleted rows could hide unresolved sends | Whole-component effect disposition first; neutral non-authorizing history with honest list/count semantics |
| Immutable historical kind stranded future work at the permanent review ID | Concrete head/command matrix: deliberate restoration and fresh revise can adopt work on the same ID, with no inherited approval |
| Old batch associations were presented as decision membership | Evidence-scoped member identity, unknown group completeness, independent decision-manifest proof and honest unavailable reasons |

The companion historical-ticket matrix adds no new command kind or table. It proposes a finite record-kind/head rule and before/after kind snapshots in existing command targets. Review and tests must validate those branches before acceptance. Collection adoption with unproved membership stays explicitly gated.

There is **no approved final new-table count**. Candidate relations must still be consolidated by owner, cardinality, lifecycle and erasure; ten candidates relative to earlier candidates was not a count against shipped main. Retained review/ASO domains still need their typed schemas, authorized readers and writer cleanup.

Remaining work: exact E4 handoff variants and provider identity proof; complete historical content/proof FKs and strict codecs; review/integrate the historical matrix; retained-domain access/erasure; R2 provider codecs; consolidated DDL; authorized data census and migration/runtime proof. The distinction between source evidence, a written design and executed tests remains explicit.
