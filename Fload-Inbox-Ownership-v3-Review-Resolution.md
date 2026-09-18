# Ownership v4 — what changed after the v3 review

18 September 2026 · Documentation proposal · Platform implementation paused

[Visual old/new comparison](ownership-overview.html) · [Ownership design v4](Fload-Inbox-Ownership-Design-v4.md) · [Earlier v15 baseline](Fload-Inbox-Revised-Design-v15.md)

The architecture keeps durable tickets and exact approvals while moving native content, receipts and evidence to their domain and provider owners. Actions retains the workflow. Usage owns settlement and metering delivery. SQL retains accepted obligations; queues wake eligible workers.

## The latest four corrections

| Review finding | Correction in v4 | Why it matters |
|---|---|---|
| N1: scheduled work can exhaust an unused inspection window | Open the initial binding/prewrite cycle in the transaction admitting the first eligible inspection, at the same database instant. | Approving work months ahead does not consume its recovery window before it can run. |
| N2: an incompatible worker can claim first | Filter support before decoding, pagination and claims. Recover directly on a compatible worker using the existing leased background lifecycle. | Mixed worker builds cannot manufacture a customer blocker or unread notification. |
| N3: the new system command has unclear ticket effects | `open_recovery` is targetless, execution-scoped, attributable and idempotent. It does not change ticket or attention versions. | Recovery history stays visible without pretending the user changed the ticket. |
| N4: a redundant receipt-policy selector has undefined values | Remove the catalogue column. The immutable operation contract selects an exhaustive provider-owned typed receipt/evidence matrix. | One owner defines each contract; there is no second selector that can disagree. |

Two reviewer suggestions were adjusted deliberately. An atomic transaction cannot leave only the cycle opening committed if it crashes between inserts: both rows roll back before commit, and both survive after commit. A new SQL worker heartbeat table would not prove absence of compatible workers; this design uses support admission plus existing worker leases and operational monitoring instead. Missing worker coverage never becomes a customer decision.

## What changed from v15

- Core owns neutral workflow decisions; one canonical application writer applies policy. The database enforces structure, immutability and concurrency boundaries.
- Product domains own proposal, baseline and observation content. Provider schemas own native identities, fields, receipts, decoders and proof.
- Immutable registered operation contracts replace an expanding shared step-kind enum. Adding a provider requires its typed module and registration; it does not add that provider's columns to the ticket.
- One active recovery cycle owns future read admissions for an exact obligation. Replacing a cycle does not erase prior evidence or cancel an admitted read.
- Usage owns immutable settlement batches and its typed delivery outbox. The existing credit log remains an equality-checked projection.

This is not a claim that fewer tables automatically make the model better. The goal is one authority per fact and clear dependencies. Typed provider relations remain necessary where native facts differ.

## What stays

Permanent IDs and old links; shared lifecycle and personal read marks; immutable revisions; exact approvals and actor history; persistent parent/child and batch membership; server-owned Undo; atomic commands and replay receipts; durable dispatch; provider readback before unsafe retries; honest uncertainty; one Fload writer per native resource; approve now and wait for a release; attributable model usage; migration that does not invent approval.

## What is still unfinished

- R2: the complete field matrix for contradictory completion evidence, including manifests and generated outputs.
- R3: field-by-field historical evidence migration and authority/provenance rules for each actual source.
- Complete consolidated DDL, generated closed types, structural checks and executable migrations.
- Application, database-role, provider-decoder, concurrency, retry, crash, migration-conservation and load proof.

The visual page contains selected proposed columns, not the final DDL. The older public schema explorer remains the preserved prototype. Nothing in this publication claims that the new design is implemented or deployed.
