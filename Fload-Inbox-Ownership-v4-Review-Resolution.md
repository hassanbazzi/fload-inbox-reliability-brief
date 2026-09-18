# Ownership v5 — clarification after the v4 review

18 September 2026 · Documentation only · Platform implementation paused

[Visual comparison](ownership-overview.html) · [Ownership v5](Fload-Inbox-Ownership-Design-v5.md) · [Previous v4](Fload-Inbox-Ownership-Design-v4.md)

The independent v4 review confirms all four prior corrections (N1–N4), finds no design defect and confirms that the public overview accurately represents the proposal. It identifies two low ambiguities. V5 makes both explicit without adding tables, columns or enum values.

| Clarification | Applied in v5 |
|---|---|
| C1: exactly which contract a worker filters before pagination | Use the original unfinished attempt's step, otherwise the execution's existing `next_step_id`. Join that exact step within the same tenant/execution and filter its operation contract against the worker's supported set before LIMIT. Core maintains the next-obligation reference and due time atomically; admission rechecks under locks. |
| C2: release offer after the date gate but before the first cycle | Ignore it without an accepted/refused command or consumed event identity. The original obligation remains due; its first inspection reads current provider readiness. Later offers follow the existing eligibility and deduplication rules. |

C1's suggested “every step must be supported” filter is not adopted. An old worker may be able to safely read back an already-issued S1 while a future S2 requires a newer contract. Requiring support for S2 would unnecessarily delay S1 recovery and could retain the resource guard while a capable recovery worker sits idle. Completed historical steps should not exclude a worker either. Filtering the actual next obligation preserves the intended boundary.

The routing reference is a projection, not new authority. NULL permits only state-only normalization; incomplete plans need a concrete continuation step, and a missing non-NULL reference is an integrity error. Unknown or unsupported work cannot be claimed or decoded through this shortcut. The projection must be rebuilt and checked during cutover; the current prototype does not maintain the stronger invariant on every path. Finishing supported work still records its evidence even when its next step requires a different worker.

For C2, event handling and first admission serialize under the existing locks. No event is assumed to arrive later, no early offer creates extra recovery capacity, and ignored offers do not consume future deduplication identity.

## Verification and remaining work

Checked the proposed rules against the preserved source's next-step FK, neutral operation selection, finalization scheduling, NULL initial plan pointer and late-evidence path. The public overview retains its existing comparisons and walkthroughs, with updated v5 links and the routing field made visible.

These are documentation and artifact checks, not application proof. Required runtime cases include supported recovery with an unsupported successor, unsupported completed history, expired attempts, late evidence, NULL normalization, dynamic-plan continuation, direct delivery crossing a contract boundary, and offers racing first admission in both lock orders.

R2 conflicting-completion retention, R3 historical-evidence source matrices, consolidated DDL and generated types, migration conservation, database-role checks, native decoders, concurrency/crash/retry/load proof all remain open. No platform implementation or production deployment is included.
