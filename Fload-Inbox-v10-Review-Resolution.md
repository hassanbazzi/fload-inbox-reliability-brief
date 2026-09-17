# FLO-1355 — v10 review disposition and v11 corrections

17 September 2026 · Documentation only · Implementation paused

The v10 review confirms the previous H1/M1/M2/L1–L3 corrections, then identifies one high, one medium and two low findings. The [consolidated v11 design](Fload-Inbox-Revised-Design-v11.md) applies all four, with the refinements below. The [visual summary](summary.html) explains the architecture in plain language.

| Finding | Applied correction |
|---|---|
| H2 · Invalidated Play inspection edit strands verification | Confirmed. Separate the latest attempt from the latest complete content evidence. Exhausted unsuccessful verification selects the exact existing cleanup, then permits an honest unverified reopen once every request is final and cleanup is resolved. This includes no complete observation and mismatch followed by unreadable results. |
| M3 · Same release cannot resume after rescheduling | Confirmed. A release grant belongs to the immutable command that last actually changed the date. A later actual change admits one fresh bounded grant for the same release after its gate; repeated events and no-op date changes do not renew capacity. |
| L4 · Eligibility text omits release recovery | Corrected. Eligible binding exhaustion can resume through an applicable release event as well as explicit Reconcile. |
| L5 · New history links form a deletion cycle | Corrected. The command→step/attempt, grant→command, evidence→command and schedule-context references use deferred constraints. Authorized erasure removes the complete permitted graph in one transaction; cross-scope survivors still refuse deletion. |

## What changed in the schema

No new relation is added. One typed nullable column is added to the existing command:

| Table | Field | Type | Meaning and constraint |
|---|---|---|---|
| actions.action_command | resume_schedule_command_id | text NULL | For release_detected only: the accepted same-action schedule/unschedule command that last actually changed the date; NULL means no prior actual change. Tenant-qualified deferred self-FK. All other command variants require NULL. |

The exact event uniqueness and worker idempotency tuple is organization, execution, step, original-write subject, event kind, native resource identity, schedule-command context. A partial unique index for resume_hold uses NULLS NOT DISTINCT for the binding subject and initial schedule context. Without step/subject scope, two different obligations could accidentally share one grant. PostgreSQL supports this null treatment and deferred foreign-key checks; the target constraints are described in the design. Sources: [CREATE INDEX](https://www.postgresql.org/docs/17/sql-createindex.html), [CREATE TABLE](https://www.postgresql.org/docs/17/sql-createtable.html).

The unverified reopen variant reuses progress_execution_id, progress_step_id, progress_subject_attempt_id and progress_exhaustion_reason=readback_observation_budget, with an optional complete evidence_revision_id. Its scope is server-derived under the execution lock. Other progress fields remain forbidden, and other reopen variants keep their existing shape. No JSON, open payload or generic job table is introduced.

Scope remains **28 Actions relations + two new Usage relations + one modified existing Usage log = 31 touched relations**. The unchanged [prototype fields](Fload-Inbox-Current-Fields.md) and [prototype DDL](Fload-Inbox-Current-Schema.sql) remain historical source evidence; they do not claim to implement v11.

## Why the recommendations were adjusted

**Do not resurrect stale success.** A later unreadable attempt cannot erase a dated mismatch, but retaining an earlier complete match cannot make it current verification. The design keeps latest_attempt and latest_complete separate. A newer complete match supersedes the mismatch; finality and required-surface checks still apply.

**A rejected DELETE does not itself prove cleanup.** A validated terminal successful DELETE can resolve the exact cleanup. Otherwise every DELETE must independently be final and a complete native observation must prove that the exact inspection edit is absent/invalid. Permission errors, throttling, local expiry time and generic 404s are insufficient. A timeout plus resource absence still leaves the request unresolved. Controlled exact-resource decoder fixtures are a required implementation gate; the current generic 404 branch must be strengthened. No undocumented provider error name is invented.

Google documents that console changes and committed edits invalidate other open edits, and that expiry ends edit validity. Those facts justify an unreadable-verification exit; they do not establish a DELETE's finality. Google's DELETE reference also does not establish that 204 is its only successful response. Sources: [Edits guide](https://developers.google.com/android-publisher/edits), [AppEdit resource](https://developers.google.com/android-publisher/api-ref/rest/v3/edits), [DELETE contract](https://developers.google.com/android-publisher/api-ref/rest/v3/edits/delete).

**Use a scheduling decision, not only a date.** A timestamp key still fails A→B→A: the second A would recover the first A's old grant. The latest actual accepted schedule-change command has permanent identity and handles that sequence. No-op A→A and unrelated commands cannot mint capacity. Unchanged-schedule permission/billing restoration does not reset an exhausted grant; explicit Reconcile remains the bounded escape.

**Use the native identity each provider actually exposes.** Closed event recipes cover ASC editable-version, review-response and live-version identities. Current Play review observations have no response ID, and current Play listing verification is editable-surface verification. Their normal readback remains supported; v11 adds no hypothetical Play publication event family. The same native resource observed through different transports receives the same key. Same-ID edits do not silently renew a grant.

## Recovery and proof requirements

Play: final create/set/commit → inspection edit → invalidation → unreadable reads exhaust → durable exact cleanup → restore original verification hold → same-ticket reopen → fresh baseline → new revision/approval. Never replace the listing evidence with a cleanup receipt. A concurrent Reconcile accepted first can defer cleanup; once cleanup is admitted it fences new content-read grants through that edit. Deleted/invalid edit paths expose safe reopen instead of accepting unusable Reconcile grants.

Required failing→passing cases include no complete observation, mismatch→unreadable, match→unreadable without stale success, later complete match, exact absent edit versus permission/transport errors, cleanup crash/replay and unresolved DELETE, Reconcile/cleanup races, accepted event→reschedule beyond its window→same version, A→B→A, no-op A→A, simultaneous event offers, exact native identity across transports, and whole-graph erasure at commit. These are test requirements, not application tests run in this pass.

The shared exhaustion classifier, SQL/Core parity, due scan/index, typed sync producers, policy-2 decoders, versioned price catalogue, data migration rehearsal and complete producer/reader/writer cutover remain required. The first candidate for a future versioned policy change is a shorter Play editable-verification window to reduce app-level exclusion; the current pinned limits are unchanged here.

The public packet and visual navigation are updated. Platform HEAD and all 215 recorded prototype entries are preserved. No platform edits, main refresh, application tests, migrations, provider writes or production deployment occurred during this documentation pass.
