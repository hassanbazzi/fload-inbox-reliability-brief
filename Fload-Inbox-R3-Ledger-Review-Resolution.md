# R3 ledger review — what changed

19 September 2026 · Documentation only · Implementation paused

The first ledger named **all 212 columns across 12 source tables**. That is useful coverage, but it did not yet prove every fact survives migration. Source review found incorrect inferences, missing nested fields and unresolved destination contracts. Those rules are corrected in [ledger v2](Fload-Inbox-R3-Conservation-Ledger-v2.md); the remaining schema work is explicitly blocked rather than presented as finished.

[Visual walkthrough](ownership-overview.html#conservation-heading) · [Exact source types and writer evidence](Fload-Inbox-R3-Source-Type-Inventory.md) · [All source fields](Fload-Inbox-R3-Source-Fields.md)

## The simple version

| Old data | What the migration must do |
|---|---|
| Work that can be proved complete enough to adopt | One durable identity, exact typed content and stable links. Executable work still needs fresh authorization. |
| Historical decisions, deliveries and observations | Preserve what the records actually say, with known actors and times. Historical claims never grant new permission or prove success by themselves. |
| Missing, conflicting or uncertain evidence | Keep the source and explain the blocker. Do not guess, resend, declare success or drop the record. |

## Corrections applied

| Finding | Corrected rule |
|---|---|
| Any matching capability row was treated as proof Fload sent a reply. | Require exact operation/content/target evidence. A failed or unrelated attempt and a mirrored provider reply prove neither authorship nor completion. |
| Auto-staged requests were attributed to a system approver. | Preserve initiation policy separately. No separate approval means no fabricated approval event. |
| Current matching batch hashes were treated as historical approval membership. | Verify the original hash algorithm, scope and decision-time manifest separately from the new revision digest. |
| Blocked imports could become immutable successful-import records. | Read-only preflight blockers remain retryable. Persist successful component records atomically with successful import only. |
| Re-reading known rows missed newly connected sources and changed domain facts. | Revalidate complete graph closure and every consumed source dependency; separately enforce command replay and source identity. |
| Old batch URLs disappeared with fewer than two open members. | Preserve stable resolution even for empty, single-member, reused and unknown-membership groups. |
| Unread notes and localization details had no destination. | Preserve personal snapshots; explicitly map page views, all gloss fields and revision pins. Exact missing destination fields remain gates. |
| Fingerprint-version changes could reopen declined reviews. | Preserve original suppression. Incomparable historical fingerprints never mean meaningful source change. |
| Retained domain tables were described as already finished. | Ownership stays in domains; strict schemas, erasure, report consumers and removal of secondary approval authority still require migration. |
| Present database timezone was treated as historical proof. | Convert naive timestamps only with established writer/period provenance. Unknown provenance blocks conversion. |

## Architecture consequence

There is **no newly approved table count**. A separate table is justified by ownership, identity, cardinality, lifecycle or access rules—not merely because it copies one old source table. Shared history cannot become a provider field bag. Native release, verification and before-state facts belong to their provider schemas.

Keeping real review, ASO and calibration facts in their own domains avoids unnecessary duplicate ledgers. It does not exempt their old JSONB or workflow authorities from the final clean schema. In particular, weekly and monthly reports currently join capability history to pending_action; those readers must change before that table can be dropped.

## Still required

1. Exact field-level destination DDL and variant matrices, including the known gaps in B10. Source types are now enumerated in the appendix; they are not a substitute for SQL constraints.
2. Final per-kind identity/relationship classification, historical-only work presentation and all old-link resolver shapes.
3. Migration command/audit attribution for multi-command and history-only components.
4. Domain-owned normalization, consumer/writer conversion and tested erasure.
5. Representative data rehearsal and executable conservation, concurrency, crash, retry and cutover tests.

Ownership v6 and the clarified R2/R3 rules remain the accepted design direction. This review changes migration proposals, not the live platform. Validation here is source inspection, document coverage and artifact checks; no runtime tests, production-data census, platform migrations or deployment were performed.
