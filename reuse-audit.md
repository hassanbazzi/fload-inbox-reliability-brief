# FLO-1355: implementation reuse and duplication audit

Original audit basis (2026-09-21). Main: `b5253b2d799cf35863a9d0c31e3481762e44afde`. Local feature HEAD: `d0945bb3ca61370e3d783d4fcec9573f58d66e01`. Published feature HEAD: `693ff696c589e7b5ff5c71281221f585641f9802`. Draft PR: https://github.com/fload-ai/fload-platform/pull/1470.

## Cleanup and integration checkpoint — 21 September 2026

Published feature head: `fced04cfc`, in the same draft PR #1470. The branch registers Actions reads and personal read-state operations. Command and provider-worker activation remain unfinished; nothing is deployed.

- Removed the duplicate description-only listing implementation and forced private Chromium setup. Reuse the existing Apple API client, SRP session manager, Undici transport and SMS owner.
- Durable review writes enter the existing execution kernel with the exact SQL approval, content and attempt. No replacement queue or login system was added.
- Withdrew speculative account-wide locking, browser-execution and extra binding-table drafts. Existing ASO approve/wait/resume behavior keeps its existing owner.
- Improved pagination in existing Apple readers. Actions read routes now use the existing authorization boundary; HTTP/database tests cover page/count agreement, tenant access and personal read isolation.
- Current request, retained human/key and agent review permissions reuse canonical auth and existing entitlement/feature owners. Shared review policy lives outside the Apple provider directory. Sending approved reply text keeps its existing zero-credit cost.
- Canonical OAuth now exposes verified delegation and exact current-consent checks. Persisted OAuth Actions actors and their entrypoints remain unfinished. The prepared command route supports existing `write:agents` API keys and sessions; unrepresentable OAuth actors receive an explicit 403.
- The existing selected-credential loader now constructs a client from the already selected row. Its mixed-key signer bug is fixed: a valid team key cannot cause selection of an unvalidated individual key.
- Command acceptance is sampled after asynchronous validation/planning. A database wait that consumes a positive Undo window rolls back the command, allowing same-key retry. Explicit zero-window approval remains immediate. Commit/network latency can still reduce the visible window.

**Composed journey:** SDK → canonical session/API-key authorization → durable command → SQL worker → existing encrypted credential loader and write kernel → one native POST → acknowledgment/readback. Tests lose the first HTTP receipt and duplicate delivery hints without a second POST. Revoking membership after inspection retains evidence and prevents sending. Marking read leaves shared state, attention and capacity unchanged. Provider HTTP is synthetic; producer materialization is fixture setup, so this does not prove the old-producer handoff.

**Validation:** 10,512 API unit tests passed (four existing skips); full Actions SQL passed 1,196 tests across 113 files at `5dc65ff60`. The composed checkpoint adds seven worker cases and passes 39 surrounding SQL cases, using disposable Redis and real PostgreSQL. All SQL runs apply 175 main and 13 metrics migrations fresh and repeat them unchanged. Combined API/Core types and scoped lint passed. Independent bounded source reviews found no additional duplicated owner in the integrated auth/client/read/clock changes.

All required Semaphore blocks passed at `6b523d74a`. CI for the newly published `fced04cfc` is pending; the older green result does not certify this head. No independent GitHub PR-review or full-readiness claim.

**Concrete remaining identity defect:** official Apple API resource IDs and original WebObjects review IDs are different namespaces. Current text matching and cached `appleReviewResourceId` do not prove correspondence. The current registry lacks that distinction: equal strings can wrongly block work, while different strings cannot establish different physical reviews. A correction in the existing registry is in progress; no crosswalk table is proposed. It must preserve ticket IDs, old creation keys, exact receipts and replay bytes. Neither text matching nor an old cache may transfer approval authority.

**Still required:** complete producer/materializer/recovery and OAuth/channel/automatic entrypoints; connect existing ASO and review producers/workers; prove exclusive app-level old-writer handoff; complete typed conservation and retire the old PendingAction lifecycle; exercise complete inbox/Mission Control/MCP and load journeys. The old and new lifecycle models still coexist in this draft. No main merge or production deployment occurred.

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
