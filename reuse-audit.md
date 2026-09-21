# FLO-1355: implementation reuse and duplication audit

Assessment date: 2026-09-21. Main: `b5253b2d799cf35863a9d0c31e3481762e44afde`. Local feature HEAD: `d0945bb3ca61370e3d783d4fcec9573f58d66e01`. Published feature HEAD: `693ff696c589e7b5ff5c71281221f585641f9802`. Draft PR: https://github.com/fload-ai/fload-platform/pull/1470.

## Cleanup and policy checkpoint — 21 September 2026

Published feature head: `6b523d74a`, in the same draft PR #1470. New Actions runtime remains inactive.

- Removed duplicate description-only listing client/source; retained meaningful regression cases in the existing full-field reader and catalog tests.
- Removed forced private Chromium setup. Source capture uses the existing SRP session manager, Undici transport and SMS owner; operation and lifetime cancellation are preserved. Individual-key API delivery remains the primary path.
- Routed durable review writes through the existing execution kernel. Exact SQL approval/content/attempt facts feed one grant owner.
- Archived and removed speculative account-wide lifetime locking and browser-execution/schema drafts; proposed listing page/version tables are withdrawn.
- Fixed pagination in existing Apple listing methods, including incomplete locale relationships, scoped cursors and contradictory/duplicate results. Iris refuses incomplete results. Separate screenshot-set pagination is outside this checkpoint.
- Bound the existing Actions permission port to its locked transaction. Canonical auth owns current membership, key and impersonation checks; revoked impersonators no longer silently lose actual-actor attribution.
- Added executor-aware fresh reads to existing subscription, entitlement, feature, Ads connector, billable-app and revenue owners. Tier policy stays in one place; current main-DB facts do not imply an atomic Timescale snapshot.
- Composed retained human/API review authority from those owners. The existing free mechanical reply does not consume a new credit. OAuth and full-agentic authority are still separate integration work.

Validation: **10,463 API unit tests passed**, four existing skips, combined API typecheck and scoped lint. Targeted real SQL:41 transaction cases,22 current-access cases,24 new plus25 surrounding policy cases,9 composed review cases,32 upgrade-fixture cases,3 screenshot integration cases. Those checkpoints replay175 main and13 metrics migrations fresh and repeat unchanged. The review journey proves one request through the native client/existing kernel, retained acknowledgment, replay without resend, and a real membership revocation after inspection preventing POST. Provider transport is synthetic; no customer write was performed.

Earlier combined Actions SQL at `9f411aa3f`: **1,087 tests /105 files**. Earlier pagination proof:528 Apple tests,54 API tests, types, lint and independent review. These are checkpoint-specific evidence, not claims that one final run contains every count.

Remote cleanup CI at `f1db52b43` passed migration journals, typecheck, lint, package units, Actions reliability and deterministic web E2E. API units/integration failed on stale native fixtures and test database shutdown lag; all are repaired with local proof. Replacement CI at `6b523d74a` is pending. No full-green or independent PR-review claim yet.

**Still required:** install request/materializer/recovery permissions; preserve session/API-key/OAuth/chat/channel/agent entrypoints; connect existing ASO and review producers/workers; prove exclusive old-writer handoff and typed conservation; retire superseded lifecycle storage; exercise real UI/MCP, pagination/load and recovery. Main-DB locks cannot span provider POSTs, and mixed deletion/Actions lock order can abort a transaction; errors must not become invented permission denials or extra sends. No production deployment or main merge occurred.

## Original audit finding

The implementation expanded into infrastructure Fload already has. This is a scope and integration failure, not just inaccurate wording about browser execution. Useful durability work exists, but it does not justify a parallel authentication system, duplicate provider endpoint implementations, or two independent write authorities. The original audit required consolidation before further integration; the completed corrections are recorded above. Nothing in this assessment constitutes production readiness.

The following original assessment distinguishes committed inactive code, uncommitted drafts and proposals. Its status statements are historical; the checkpoint above records what has since changed.

## Original audit decisions (historical; cleanup status above)

| Area | Existing working owner | Finding and correction | Current state |
| --- | --- | --- | --- |
| Apple authentication and review delivery | Individual-key `AscApiClient`; SRP `WebSessionManager`; guarded review transport and scraping workers | The new private review runtime deliberately bypasses the reusable session manager and starts fresh Chromium. Reuse API-first delivery and the existing authenticated HTTP transport. Keep exact target/content validation and a physical request outcome, not another login stack. | Private browser source/runtime prototype is committed; further browser execution and migration 0175 are uncommitted. Neither is registered as the new production Actions sender. |
| Account session coordination | Existing login lock, session store and queue concurrency | Do not integrate the proposed global lifetime rollout. It compares a hashed cache key against raw email, causing session-manager calls to reject; existing fallback can hide that by using Chromium. It also serializes an account globally without a working busy-job deferral path. | Uncommitted. Previous narrow tests did not exercise the real manager-to-store contract. No live-provider reproduction was run in this audit. |
| ASO endpoint implementations | Existing Apple client, guarded listing writer, field projections, release and listing readers | New description-only and full-field methods overlap existing endpoint construction. Consolidate into the existing client with explicit one-request behavior, strict decoding and complete pagination. Remove the unshipped description-only aliases/source. | Most new source/native code is committed and inactive; the last six-file native slice is local only. |
| Approve now, await editable release | `pending-action.service.ts`, `apply-time-dependencies.ts`, `needs-build-convergence.ts` | This behavior already works. Adapt its facts and resume policy to durable Actions ownership; do not recreate the product behavior, watcher or approval. Preserve the same ticket and approval while it waits. | Existing implementations are unchanged relative to main. |
| Extra listing binding catalog | Existing native discovery, snapshots, immutable selected revision facts and attempt records | Proposed page/version tables lack a demonstrated missing durable fact. Withdraw the proposal as an implementation plan. Read-only discovery can repeat before final selection is committed; any later schema addition needs a concrete failure case and minimal storage proof. | Proposal only; no migration 0176 was created. |
| Provider write authorization | Existing work-execution lineage, guarded writers and boundary inventory tests | New Actions dispatcher directly invokes the native client through its own durable admission. The old boundary test does not enumerate that new path, and legacy drains do not honor the new guard. Establish one enforced boundary and exclusive ownership of each migrated obligation before activation. Do not blindly wrap the old retry/fallback writer and claim one-request semantics. | Real integration gap in the committed, inactive sender. Current runtime still uses the existing writer. |
| Actions lifecycle | Existing Core `PendingAction`, transactional approval and dispatch-intent service | New `TicketService` and SQL model currently coexist beside unchanged old Core exports. Immutable revisions, batch membership and durable command replay justify new structure; indefinite parallel lifecycle authorities do not. Each migrated producer, command and reader needs an explicit old-owner retirement step. | Parallel models exist in the branch. The complete cutover is not done. |
| Queues, worker lifecycle and Ads infrastructure | Existing BullMQ workers, singleton lease, provider gateways and billing boundaries | No committed replacement of `queue.ts`, `worker.ts` or `work-execution` was found. Actions recovery already reuses the singleton lease but remains an unregistered factory. Integrate with these owners. Do not grow unconsumed Ads identity/dispatch placeholders into another provider framework. | Recovery factory is committed/inactive. Ads identity drafts are uncommitted. Billing and every remaining domain still need caller-level cutover proof. |

## What remains justified

- Permanent organization-owned work identity; explicit parent/child membership; immutable selected content revisions.
- Exact revision approvals, actor history, server Undo deadlines and idempotent command receipts.
- Durable per-request attempts and evidence, crash recovery and readback before any possible resend.
- Personal read state, shared lifecycle, consistent list/count predicates and complete pagination.
- Typed provider-owned evidence attached to the approved work; existing provider credentials, clients and domain policies underneath.

Existing guards are meaningful and must be preserved. However, a process-local single-use grant plus a best-effort post-call log does not retain a lost provider response across a crash. That is the specific durability gap. It is not evidence that provider authentication, ASO or review delivery is missing.

## Original consolidation checklist (checkpoint above records completed items)

1. Preserve the drafts and withdraw the broad lifetime rollout and speculative binding-table proposal from the integration set. Consolidate the inactive description-specific implementation.
2. Share the existing API/SRP transports and endpoint encoders, with explicit no-hidden-write-retry semantics. Prove the actual session-store contract and selected provider identity; a private cookie jar alone does not establish provider-context isolation.
3. Integrate durable admission with the canonical guarded-write boundary, including permission, attribution and billing ownership. Extend the exhaustive boundary inventory. Retire or exclude every old sender for a migrated obligation.
4. Complete one real review journey and one existing approve/wait/resume ASO journey through production entrypoints, worker routing and UI. Test crash-after-provider-write, uncertain outcomes, duplicate delivery, stale approval, conflicting iteration and old/new ownership exclusion.
5. Prove migration conservation and deletion/retirement of superseded writers and storage. Existing snapshots remain discovery/history; only selected immutable facts become approval authority.

## Original audit evidence

Paths are relative to the implementation worktree. The three companion assessments provide detailed caller and line references:

- [Reviews and authenticated transport](reuse-audit-reviews.md)
- [Listing, ASO and Ads](reuse-audit-listing.md)
- [Runtime, queues and session ownership](reuse-audit-runtime.md)

Root inspection additionally confirmed:

- `packages/core/src/actions/index.ts` exports both old PendingAction and new TicketService; old pending-action service/repository are unchanged against main.
- `packages/core/src/actions/pending-action-service.ts:228` already commits approval and dispatch intent in one unit of work.
- `apps/api/src/services/actions/execution-worker.ts:34` and `recovery-worker.ts:28` are factories with no production registration found. Recovery uses the existing `singleton-lease` module.
- `apps/api/src/__tests__/unit/provider-write-boundary.test.ts:83` enumerates old write transports; `services/actions/providers/app-store-connect/review-write-dispatcher.ts:327` calls the new native method directly.
- Existing `queue.ts`, `worker.ts` and `services/work-execution` have no committed main-to-feature differences.

## Original audit validation and limits

This was a source/caller/diff audit; it did not run provider writes or deploy anything. Previous isolated tests do not prove the composed system or justify duplicated architecture. The latest remote feature CI at `693ff696c` is **not green**: API integration and Actions reliability blocks failed. The Actions suite reports 1,096 passed and one failed; the failure compares the new scoped HTTP page with an older expected object missing `context`. That assertion and the separate integration failure remain to be resolved; no full-green claim is made.

This audit establishes concrete reuse and removal decisions for the investigated paths. It does not certify every table or all remaining Google Play, Ads, migration, erasure, billing and load-test work. Table count and isolated test count are not completion criteria.
