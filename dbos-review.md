# Fload DBOS implementation review

21 September 2026. Reviewed commit `28f0cfbff2c9b32df6aabb1a1107a8852ee06fb8`, SDK 5.0.2.

**Verdict: keep the architecture; changes required before activation.**

[Visual review](https://hassanbazzi.github.io/fload-inbox-reliability-brief/dbos-review.html) · [Full engineering assessment and handover](https://github.com/fload-ai/fload-platform/blob/codex/flo-1355-dbos-review/docs/audits/dbos-implementation-review.md)

## What changed

Four custom runtime modules were retired: the execution worker, recovery worker,
Redis cursor store and sweep traversal. The database trigger now enqueues a DBOS
wake in the same transaction as each scheduling change. DBOS owns delay, queueing
and checkpoints; Fload retains exact approvals, durable identities, attempts,
provider guards, uncertainty and receipts. Only official ASC review upsert is
composed into this runtime. Long waits are delayed engine rows.

## Actual schema

This DBOS slice adds one Fload column, no Fload relation:
`actions.execution.wake_sequence bigint NOT NULL DEFAULT 0`, check `>= 0`.
The trigger advances it on changes to phase, due instant, claim expiry or plan
generation and enqueues through the supported vendor SQL function. The existing
`delivery_generation` remains the plan fence. Both values are strict int64
counters; the four-field wake payload contains identifiers, never credentials or
content. DBOS manages its own vendor schema, including generic serialized/JSONB
internals; Fload domain typing is unchanged.

The visual review shows every actual execution field from snapshot0183.
[Schema and constraints](https://github.com/fload-ai/fload-platform/blob/28f0cfbff2c9b32df6aabb1a1107a8852ee06fb8/packages/database/src/schema-action-execution.ts#L119).

## Findings

### R1 · High · Failed work has no working repair

An ERROR wake cannot be resumed by the pinned SDK. The script only handles PENDING, and the promised alert path has no production caller.

**Required fix:** Use a supported repair that revalidates current domain state, then prove alert → repair → recovery without another unsafe write. [Source](https://github.com/fload-ai/fload-platform/blob/28f0cfbff2c9b32df6aabb1a1107a8852ee06fb8/apps/api/src/services/actions/dbos-delivery-runtime.ts#L118).

### R2 · High · Schema failures can expose credentials

The CLI receives DATABASE_URL in its arguments. On failure, the logged child-process error includes the password. A fake-password probe confirmed this.

**Required fix:** Keep secrets out of command arguments where supported; sanitize every failure channel and regression-test the actual migration logger. [Source](https://github.com/fload-ai/fload-platform/blob/28f0cfbff2c9b32df6aabb1a1107a8852ee06fb8/apps/api/src/services/actions/dbos-schema.ts#L37).

### R3 · Medium · Different IDs can produce one wake

Unescaped colons make distinct valid organization/execution pairs collapse into the same workflow ID. The second payload is silently ignored.

**Required fix:** Use identical unambiguous encoding in SQL and TypeScript. Prove two scopes remain distinct and same-command retries remain idempotent. [Source](https://github.com/fload-ai/fload-platform/blob/28f0cfbff2c9b32df6aabb1a1107a8852ee06fb8/packages/database/drizzle/0183_actions_dbos_wakes.sql#L51).

### R4 · Medium · Operator repair escapes the queue limit

resumeWorkflow(id) defaults to DBOS’s internal queue. It bypasses the Actions queue’s configured concurrency. Normal same-slot startup preserves the queue.

**Required fix:** Pass the Actions queue explicitly and test transfer from a removed executor with more jobs than its concurrency limit. [Source](https://github.com/fload-ai/fload-platform/blob/28f0cfbff2c9b32df6aabb1a1107a8852ee06fb8/apps/api/src/scripts/actions-dbos-recover-executor.ts#L62).

### R5 · Medium · Existing work is not adopted on upgrade

Existing rows receive wake_sequence = 0, with no initial DBOS wake. The design assumes no eligible executions exist, but does not enforce that assumption.

**Required fix:** Either refuse unsupported populated upgrades or adopt due and claimed work transactionally, preserving original deadlines and approvals. [Source](https://github.com/fload-ai/fload-platform/blob/28f0cfbff2c9b32df6aabb1a1107a8852ee06fb8/packages/database/drizzle/0183_actions_dbos_wakes.sql#L1).

### R6 · Medium · Operator recovery reads the whole backlog

listWorkflows has no limit here, and SDK 5.0.2 has no default cap. Large failures become one unbounded memory load and serial operation.

**Required fix:** Bound listing and recovery batches; test tied timestamps, interruption and changing statuses without skipped work. [Source](https://github.com/fload-ai/fload-platform/blob/28f0cfbff2c9b32df6aabb1a1107a8852ee06fb8/apps/api/src/scripts/actions-dbos-recover-executor.ts#L42).

## Evidence and limits

Independent re-run: 23 existing tests passed (6 trigger + 17 worker tests).
184 main and 13 metrics migrations replayed fresh and repeated; DBOS schema
bootstrapped by its real CLI. Four additional diagnostics reproduced R1–R4;
they are defect confirmation, not four acceptance passes.

The existing suites prove same-ID SIGKILL replacement, retained uncertainty,
no second POST and gated runtime draining. Provider HTTP is synthetic. Crash
children also substitute authority and credentials; the separate lifecycle suite
exercises canonical authorization. The readback assertion must count GETs after
the crash frontier, and the clock assertion must sample first-dispatch SQL time.
The child SIGTERM test lacks an in-flight barrier; another test does prove active
runtime stop/drain, so it is inaccurate to call all graceful draining untested.

Still unproved here: simultaneously live overlapping replicas, operator transfer
under concurrency limits, version rollover, many long waits, retention,
large-backlog repair and full browser/listing delivery. Prior author-reported
full API/typecheck evidence is not independently rerun evidence. No current-head
Semaphore pass was established; the old PR's green CI applies to its old head.

Next: fix six findings with negative regressions; complete recovery/operations
proof; validate the merged source and subsequent edits in CI; then resume
remaining provider, source-conservation, entrypoint and UI/MCP cutover work.
The original inbox overhaul is not complete. No production deployment or merge.

## Concurrent work observed

The local implementation branch merged main at `34a381c29` during publication.
The reviewed production DBOS files are unchanged; subsequent uncommitted test
work remains. Tests here certify `28f0cfbff`, not that combined application or
unfinished edits. The full engineering assessment records the exact locations.
