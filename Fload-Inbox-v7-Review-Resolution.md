# FLO-1355 — v7 review resolved in v8

17 September 2026 · Documentation only · Implementation paused

The independent review found the six principal v7 paths coherent, then identified one high-severity gap, two medium issues and eight smaller completions. Those findings were checked against the preserved prototype and the relevant provider contracts. The [consolidated v8 design](Fload-Inbox-Revised-Design-v8.md) applies the supported corrections directly. The [simple overview](summary.html) remains the team introduction.

| Finding | Disposition and applied correction |
|---|---|
| D1 · Reopen after post-write mismatch | Confirmed. Add a third reopen branch for complete required-surface mismatch after every issued write is final and no attempt is unfinished. Preserve applied effects; fresh content and approval require a post-reopen baseline. A mismatch alone does not prove finality or external authorship. |
| D2 · Guard retained during prewrite backoff | Confirmed. Release the inspection reservation in the finalization transaction when its acquisition generation has no writes and the entire execution has no unresolved write or evidence conflict. Later acquisition needs a fresh prewrite. |
| D3 · Meter identifier length | Confirmed. Persist a fixed 69-character hash identifier derived from unambiguous length-prefixed business identity. Validate the identifier and configured event-name limits before sending. Keep the relational business key. |
| D4 · Meaning of matched/external | Clarification accepted; the proposed blanket correlation requirement is rejected. Content equality and request finality are separate. Terminal acknowledgement plus a complete surface match can verify success without a request ID. Uncorrelated content alone cannot finalize an uncertain write. Native external handling requires proven non-application. |
| D5 · Digest extension dependency | Confirmed. Use PostgreSQL core sha256(bytea), preserving the exact prior bytes and result. No extension dependency. |
| D6 · Claimed inspection after rescheduling | Confirmed. Do not reconstruct a lost prior hold. Remaining capacity yields ready with a non-null due; exhausted capacity yields inspection-only blocked/retry_exhausted with no timer and Reconcile/Edit. The existing ready/non-null SQL constraint remains valid. |
| D7 · Successor prewrite coverage | Clarified explicitly: first write, guard reacquisition, or explicit retry requires prewrite. Ordinary successors use the actual declared prerequisite/verification checks and dispatch fence; no imaginary provider read is implied. |
| D8 · Scheduling attention | Scheduling changes workflow version and immutable history, never attention or personal reads, regardless of actor/owner. A date change is not an assignment. |
| D9 · Zero-credit settlement | Confirmed. The transactional settlement path writes zero-credit batch evidence and its known pairs with no quota increment or metering. Current record/consume wrappers are not that transaction. |
| D10 · Confirmation persistence | Confirmed. Bound retries of the same captured completion; detect already-committed identical finalization before late handling. Never repeat the provider call to repair local confirmation. |
| D11 · Unused approval version | Confirmed with precision: the field is serialized, but not interpreted for authorization. Remove authorization_version from the proposed DB/wire contract; retain actual policy revisions and meaningful recovery versions. |

The schedule migration mapping is now explicit too: initialize from a proven source available_at, allowing historical dates only through the authorized importer. Preserve the source instant and actual import actor/time. A missing timezone convention or ambiguous source is a migration blocker, not a guessed date. Ordinary public schedule commands remain future-only.

The review's proposed D1 condition that the mismatch itself must have terminal_outcome=TRUE was narrowed: write finality may already be proved by its terminal acknowledgement. Requiring an unrelated GET to supply native request correlation would recreate the stranded-ticket problem. The shared finality predicate still applies to every issued write.

Source verification: the draft ready-state constraint and matched_external guard, current claim handling, response projection, zero-amount Usage filtering, separate audit-event delivery and policy-1-only decoder support the dispositions above. The official contracts confirm [Stripe's bounded identifier/event-name fields](https://docs.stripe.com/api/billing/meter-event/create) and [PostgreSQL 17 core SHA-256](https://www.postgresql.org/docs/17/functions-binarystring.html).

No platform changes, migration execution, application tests or provider writes occurred. All 215 recorded prototype entries and its base commit remain unchanged. The application suites, full migration rehearsal, typed per-operation recovery policy, provider target adoption and coordinated cutover remain implementation gates. A design review is not proof that those gates pass.

The revised count remains **28 Actions relations + two new Usage relations + one modified existing Usage log = 31 touched relations**. This pass adds no tables.
