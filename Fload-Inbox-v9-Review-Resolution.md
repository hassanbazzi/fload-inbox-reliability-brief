# FLO-1355 — v9 review disposition and v10 corrections

17 September 2026 · Documentation only · Implementation paused

The v9 review confirms R1–R6 from the previous round are resolved. It identifies one high and two medium gaps, plus three smaller follow-ups. The [consolidated v10 design](Fload-Inbox-Revised-Design-v10.md) applies the corrections. The [visual overview](summary.html) remains the compact team introduction.

| Finding | Disposition and correction |
|---|---|
| H1 · Play verification cannot reopen | Confirmed. Reopen uses the exact failed verification scope, whether before_successor or after_effects. The existing Play inspection DELETE gets a narrowly checked cleanup path after exhausted complete mismatch; it cannot authorize another listing change. Preserve exact failed-scope evidence through cleanup. |
| M1 · Scheduling loses proved release wait | Confirmed. Claimed and unclaimed paths recompute the hold from immutable readiness evidence. Cancelling a fallback inspection does not erase an unsuperseded complete no-release fact. The original approval and execution remain. |
| M2 · One transient event-read failure strands work | Confirmed. Each accepted event supplies a fixed bounded count/window grant. Remove the attempt-level uniqueness that limited it to one start; retain event-command deduplication and serialized capacity checks. Repeated events do not create fresh budgets. |
| L1 · Transient exhaustion mislabeled unsupported | Confirmed. Unavailable/partial observation exhaustion becomes retry_exhausted with the correct prewrite/readback qualifier. Unsupported remains reserved for unsupported adapter/surface evidence. |
| L2 · Transport-only binding exhaustion cannot resume | Accepted. An applicable release event may recover the exact zero-effect binding obligation from awaiting_release or retry_exhausted/binding_observation_budget. It does not invent a no-release fact or bypass authority/date gates. |
| L3 · Historical explanation has no durable cause | Accepted with a precise addition. Three typed fields on the existing command capture step, subject and closed exhaustion reason. New progress history reads that immutable snapshot; later evidence cannot rewrite the reason. The step/subject fields also pin event-grant scope. No new table. |

**Adjusted recommendations.** The suggested Play expiry shortcut is unsupported by the preserved code: expired_uncommitted_edit applies to the original uncommitted listing edit with no admitted commit, not the later inspection edit. A confirmed inspection edit therefore requires its existing exact cleanup before failure settlement; ambiguous cleanup retains uncertainty and exclusion. The narrow exception must exist in both Core selection and the SQL predecessor guard. Do not claim cleanup from elapsed time.

A complete observation that still proves publication pending can continue within the event budget; blindly closing every complete mismatch would strand that case again. Event grants otherwise stop on decisive scoped results, fixed exhaustion or cancellation. Repeated successful syncs offer current typed readiness so an event ignored before a scheduled date is not lost forever; accepted event identity still cannot renew its budget.

The history addition is **progress_step_id text**, **progress_subject_attempt_id text**, and **progress_exhaustion_reason actions.action_exhaustion_reason**. The reason has six closed values. Required/forbidden matrices, tenant/execution FKs, insertion validation, immutability, deduplication and erasure order are specified in v10. A pair of identities alone cannot preserve the cause known before a late completion, which is why the reason snapshot is included. No JSON or open payload is introduced.

The review's proposed shorter mismatch polling policy is left as an explicit future versioned policy decision. V10 does not infer non-application from repeated fingerprints or silently change the pinned operation policy. Reopening still follows the declared bounded verification and finality rules.

Implementation gates now explicitly include the indexed due scan for eligible blocked rows and deadline-only normalization, typed events from existing sync workers, complete collection validation, and an immutable versioned code price/policy catalog retained across releases with SQL first-invocation version checks. Existing migration, provider decoder, target adoption, settlement, cutover and repository-test requirements remain.

Required regression traces include Play mismatch → durable exact cleanup → reopen → fresh baseline; crash/replay and ambiguous cleanup; reschedule during fallback with proved no-release evidence; an event read failing once then succeeding under the same grant; duplicate/concurrent event offers; future-date ignored/re-offered events; transport-only binding recovery; typed reason/step/subject rejection and historical reason stability after late evidence. These are requirements, not executed application tests.

No tables added. Scope remains 28 Actions relations + two new Usage relations + one modified existing Usage log = 31 touched relations. The [prototype catalog](Fload-Inbox-Current-Fields.md) and [DDL](Fload-Inbox-Current-Schema.sql) remain unchanged historical evidence. All 215 recorded prototype entries and platform HEAD are preserved. No application tests, platform edits, migrations, provider writes or production deployment occurred in this documentation pass.
