# FLO-1355 — v12 review disposition and v13 corrections

18 September 2026 · Documentation only · Implementation paused

The v12 review accepts M4/L6 and identifies M5, M6 and L7. The [v13 design](Fload-Inbox-Revised-Design-v13.md) applies all three; the [visual summary](summary.html) shows the resulting product behavior.

| Finding | Applied correction |
|---|---|
| M5 · Never-sent cleanup DELETE leaves a present edit and exhausted recovery | A valid exact-present edit becomes complete cleanup mismatch/FALSE. Reserve one initial automatic read after the recorded native expiry, with fixed count/deadline rules and bounded grace. Actual native unusability remains required for quiescence. |
| M6 · Exhausted waiting is hidden in in_progress with no unread change | Release/publication waits are in_progress only with feasible automatic recovery. Exhausted waits become needs_decision, expose Re-check now on the row and record one deduplicated attention change. |
| L7 · Guard release waits for human reopen | After complete mutation work, final writes and resolved cleanup, restore the exhausted-verification hold, close further writes and release the app guard in the same transaction. A second ticket can proceed before the first is reopened. |

## Automatic cleanup recovery is a reserved opportunity

Extending a deadline alone would not fix M5 if earlier failures consumed every start. V13 reserves one of the existing N starts. With F=the original uncertain DELETE finish, E=the exact inspection-create receipt expiry, O=the pinned ordinary window, B=initial backoff and G=backoff cap:

```text
tail_due     = max(E + B, F + B)
initial_end  = max(F + O, tail_due + G)
ordinary_end = min(tail_due, F + O)
```

At most N−1 starts occur before tail_due; at most one initial start occurs in [tail_due, initial_end). Unused early slots are forfeited. All original failed/expired starts count. The reserved read is scheduled promptly from the actual expiry, with a fixed late-worker interval, rather than waiting unnecessarily near the end of a long ordinary window. No retry, later GET, queued job or restored credential can move the anchor or reset the budget.

The cleanup policy-2 numerical profile is explicitly N=6, O=168h, B=1h, G=24h, factor 2; this is a documented operation-policy choice, not shipped behavior or a universal provider policy. SQL/Core selection, I/O admission, due scans and normalization must use the same ordinary/tail rules. A future reserved slot remains capacity even after early slots are consumed. Existing Reconcile grants remain separate and bounded.

Google exposes the edit's absolute expiry and GET representation. Those facts support scheduling and complete-present classification; they do not guarantee a successful request after expiry. A valid returned edit is mismatch/FALSE even if its stated expiry passed. Permission errors, transport failure, a generic 404 and a clock cannot prove cleanup. If workers/provider access remain unavailable beyond the fixed opportunity, uncertainty and an explicit Reconcile remain visible. No resend exception is introduced. [AppEdit resource](https://developers.google.com/android-publisher/api-ref/rest/v3/edits), [GET edit](https://developers.google.com/android-publisher/api-ref/rest/v3/edits/get).

## A waiting ticket must say when it needs a person

The closed derived waiting mode is automatic or recheck_required. One classifier and database snapshot govern list, count, detail, parent aggregation and progress. A normalization-only due timestamp or the possibility of a future event is not automatic capacity. This changes placement while retaining the approval and dated prerequisite evidence.

| Waiting mode | Inbox category | Row action / attention |
|---|---|---|
| automatic | in_progress | Existing bounded checks continue; no per-poll unread churn |
| recheck_required | needs_decision | Re-check now is visible; one unread update for the newly exhausted cycle |

Reuse the existing proposed command reason/step/subject fields. Exhausted release waits record binding_observation_budget and the binding step; exhausted publication waits record readback_observation_budget and the exact step/original-write subject. Automatic snapshots have those fields NULL. New records preserve history; old commands never change.

A grant restoring capacity appends a separate attention-neutral progress snapshot in that same transaction. That gives the next exhaustion a distinct prior transition, so identical later cycles are not suppressed forever. Phase/result/hold/reason/step/subject all participate in deduplication, ordered by the execution ticket's target version. Duplicate delivery or an unchanged poll appends nothing.

Scheduling retains its no-unread promise. A feasible-capacity change actually caused by schedule/unschedule, with the same waiting hold and scope, is normalized with attention-neutral progress in that scheduling transaction. Pre-existing unrecorded expiry remains ordinary attention-bearing progress. The SQL guard must verify transaction-local admission of the exact preceding grant/schedule command independently of historical target-version adjacency; timestamps or a user-settable session variable are insufficient. No client-chosen attention flag or new stored cause field is added.

## Other tickets need not wait for reopen

The safe exhausted-verification transition records existing writes_closed_at and releases only the guard holder/generation belonging to that execution. It requires a completed mutation phase, every issued write final, no unfinished attempt/conflict and every required cleanup resolved. It does not weaken incomplete-package or unresolved-write protection. The approval/history remain until normal reopen; that old execution can never mutate again. Late evidence cannot release a newer ticket's guard.

## Implementation proof still required

Required failing→passing cases cover before-send crash and present edit; reserved count and exact deadline boundaries; worker lateness, tail crash and late evidence; provider-stated expiry before/after the ordinary window; invalid/missing expiry; post-expiry present/error responses; concurrent Reconcile; same-hold exhaustion; repeated restore/exhaust cycles; parent/list/count consistency under a shared snapshot; personal mark-read races; schedule neutrality and forged silent transitions; and second-ticket guard acquisition before user reopen.

No stored fields or tables are added. The existing progress-field matrix, attention guard, policy selector, normalized read model and writes-closed/release transaction must change together. Scope stays 28 Actions relations + two new Usage relations + one modified Usage log = 31 touched relations. The [prototype catalog](Fload-Inbox-Current-Fields.md) remains preserved historical evidence.

Platform HEAD and all 215 recorded prototype entries remain unchanged. No platform implementation, application tests, migrations, provider writes or production deployment occurred in this documentation pass. Native decoder evidence, migration rehearsal, full cutover and repository-required tests remain open implementation gates.

## Final consistency corrections

Independent cross-checks of the consolidated v13 contract identified and corrected six restatements/races before publication:

- A reserved tail start uses max(tail_due, applicable backoff_not_before, DB_now) and must remain strictly before initial_end; a delayed ordinary read cannot bypass backoff.
- Exhausting the initial tail blocks only when no other applicable grant retains capacity. A separately admitted Reconcile keeps its own scope and due.
- The command-field matrix explicitly names both attention-neutral progress exceptions: restored waiting capacity and schedule-caused same-wait mode change.
- A schedule-caused capacity change is recorded in that same transaction, even when the new date immediately makes every start infeasible; it does not wait for a deadline wake.
- Exhausted waiting state, NULL due and its required immutable progress snapshot commit atomically. A missing snapshot cannot fall outside the indexed due scan: runtime guards reject that commit, and migration activation rejects unrepaired eligible rows. Later unrelated command versions do not need to equal the historical progress version.
- If a grant wins the race against expiry normalization, it first records the pre-existing exhaustion, then admits capacity and records silent restoration under one locked command chain. The unread cycle cannot disappear.

The acceptance matrix now includes these backoff, concurrent-grant, scheduling, missing-snapshot and admission-race cases. These are verified documentation corrections; the implementation tests are still required.
