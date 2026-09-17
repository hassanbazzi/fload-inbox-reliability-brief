# FLO-1355 — review the applied v9 corrections

17 September 2026 · Documentation only · Implementation paused

Read the [simple overview](summary.html), [v8 review disposition](Fload-Inbox-v8-Review-Resolution.md), and [consolidated v9 design](Fload-Inbox-Revised-Design-v9.md). V8 remains available as frozen historical context.

## Copyable review task

Review v9 against the v8 R1–R6 findings. Verify that supported fixes are integrated without contradicting retained constraints. Give remaining defects a severity, exact section/source reference, concrete failing interleaving and smallest coherent correction. Acknowledge resolved findings and separate design contradictions from unimplemented requirements.

Focus on readback exhaustion and window expiry, global request finality, before_successor versus after_effects, typed publication waiting, binding versus prewrite failure, event deduplication/authority, inspection terminal flags, historical retry_exhausted qualifiers, first-invocation pricing pins, and proven zero-consumption versus unknown cache evidence. Check the six transaction walkthroughs and the strict field matrices against these corrections.

The uncertain phase still requires a due time: an exhausted unresolved write uses blocked/uncertain_write with NULL due. No release event bypasses current gates. Failed invocation zeros are supported by definitive non-consumption; completed cache NULLs mean an unreported breakdown with exact cost still required.

Review only. Do not reset/stash/rebase/pull into or alter the preserved worktree, regenerate/run migrations, resume implementation, commit/push platform code, run provider writes or deploy. The separate private handover provides exact design, assessment, worktree, source-manifest and output paths. A clone alone does not contain the preserved uncommitted prototype.

## Evidence and implementation gates

All 215 source-manifest entries and platform HEAD f0b1af5fc5925d818be7d9b02b42b1fc54556ecc were rechecked unchanged. No new application tests were run. Documentation consistency and publication checks do not establish runtime correctness.

The [full specification](Fload-Inbox-End-to-End-Specification.md), [migration plan](Fload-Migration-and-Data-Plan.md), [provider boundary](Fload-Provider-Boundary-Review.md), [entrypoint inventory](Fload-Entrypoint-and-Ownership-Plan.md) and [evidence checkpoint](Fload-Implementation-Checkpoint.md) supply the wider packet. V9 governs changed contracts. The prototype catalog is unchanged; the revised design touches 28 Actions relations, adds two Usage relations and modifies the existing usage log. This pass adds no tables.
