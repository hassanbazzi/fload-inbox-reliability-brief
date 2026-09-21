# FLO-1355: implementation reuse and duplication audit

> **Current update, 21 September 2026:** DBOS 5.0.2 is implemented at
> `28f0cfbff`; changes are required before activation. The independent review
> passed 23 existing tests and reproduced four defects. Read the
> [visual review](https://hassanbazzi.github.io/fload-inbox-reliability-brief/dbos-review.html)
> for the actual schema, six findings and remaining work. The earlier
> checkpoints below are historical and do not describe current readiness.


## Current recheck: existing owners, durable recovery

Published feature `d84893a63`, based on main `b5253b2d7`, in the same draft [PR1470](https://github.com/fload-ai/fload-platform/pull/1470). [All required CI blocks passed at this exact head](https://fload.semaphoreci.com/workflows/4e142074-8565-4ffd-b615-5d0ba96f8def?pipeline_id=b0b1bda6-5b97-4c40-9fc6-d0b21703571d). The preceding `7ede8666e` run exposed stale test fixtures and insufficient compiler heap; the new head fixes those and verifies the complete pipeline. The direct-branch review block ran no independent review job. No application deployment or main merge.

**New research:** [durable workflow engine comparison](workflow-engines.html), covering DBOS, Restate, Temporal, Hatchet, Inngest, Trigger.dev and our current runtime. The separate `codex/flo-1355-dbos` branch starts at `d84893a63`; no engine is installed or selected yet. This evaluates replacing custom orchestration while preserving existing domain and provider owners.

- Removed or consolidated duplicate provider request code, private session/cache/lock handling and the unused browser-write prototype. Existing Apple API/SRP clients and guarded writers remain the owners.
- The existing ASO snapshot pass now resumes exhausted release waits when a genuinely new release appears, preserving the same ticket, revision and approval. Same-release captures cannot repeatedly replenish capacity. Native PATCH connection remains in progress.
- The existing agent-run terminal transaction retains attention callbacks, and the existing reconciler recovers them. No new queue or callback table. A false result cannot emit recovery; later consumed events prevent stale callbacks from reopening old work.
- The existing paginated ticket-history endpoint now exposes conserved source facts with exact counts, access checks and bounded payload hydration. These remain reported facts, not fabricated approvals or provider receipts.
- Personal read labels and superseded attention notices are conserved without inventing workflow decisions. Personal snooze/dismiss/archive claims still need explicit shared-workflow disposition.
- Shared Actions SQL now delegates revision/content validation through composition to domain owners. Migration 0181 changes functions only; all existing predicates remain enforced.

**Newly confirmed coverage gap:** API-key provisioning is not guaranteed for every existing headless account. The durable review planner currently accepts API targets only. Retiring the established headless sender now would remove supported functionality. Complete truthful integration through the existing owner first; do not guess an API/WebObjects ID mapping or inherit an approval across namespaces.

**Local evidence:** release waits 23 SQL +36 unit cases; source history 246 SQL +33 contract/SDK unit cases; agent callbacks 81 SQL +8 unit cases. The composed final checkpoint passed 100 SQL cases across six suites, applying 182 main and 13 metrics migrations fresh and repeated. Provider HTTP is synthetic; this is component evidence, not a live-provider or final-handoff certification.

**Remaining:** full native writes/readback and other domains, retained OAuth attribution and all producer doors, conservation of unsettled/linked work, exclusive old-writer/lifecycle retirement, complete UI/MCP/load journeys. Old PendingAction and new Actions still coexist. Commands and provider workers remain unregistered.

### Actual schema change: four fields on the existing agent run

The feature still adds 32 relations through snapshot 0181, with no new JSONB. Migration 0180 adds four nullable, no-default fields to **existing `public.agent_run`**; no new relation:

| Field | Actual SQL type | Meaning |
| --- | --- | --- |
| `attentionEventKind` | nullable `text` | Closed failure/recovery event tied to the terminal run |
| `attentionAssetId` | nullable `text` | Exact source asset; NULL with an event means organization scope |
| `attentionFailureCount` | nullable `integer` | Exact failure threshold; NULL for recovery |
| `attentionProcessedAt` | nullable `timestamp` | Consumption committed with the existing attention writer |

A structural check allows only `failure` or `recovery` with matching terminal facts; historical rows keep all four fields NULL. The partial index `agent_run_attention_pending_idx` orders `(completedAt, id COLLATE "C")` for an event whose `attentionProcessedAt IS NULL`. Populated heaps are prepared and validated through the existing agent-history preparer; migration 0180 adopts exact objects. Migration 0181 moves existing validators only.

Flow: existing terminal run transaction → retained event on that run → existing reconciliation job → existing attention writer + consumption in one transaction. This closes crashes after terminal commit; it does not establish exactly-once provider effects before that commit or concurrent execution of an unfinished run.

## Earlier cleanup and integration checkpoint — 21 September 2026

Published feature head: `c80b4ac46`, in the same draft PR #1470. Reliability cleanup is recorded at `27160b8a0`; remaining provider consolidation and unused browser-write removal at `85a0cf35c`. The branch registers Actions reads and personal read-state operations. Command and provider-worker activation remain unfinished; nothing is deployed.

- Removed the duplicate description-only listing implementation and forced private Chromium setup. Reuse the existing Apple API client, SRP session manager, Undici transport and SMS owner.
- Removed the remaining private review cookie store and extra account lease. Capture now shares the existing encrypted cache and login lock, so a waiting login sees the session another worker publishes. Native context checks remain evidence; they do not prove remote session isolation.
- Consolidated old and durable review writes into one Apple request encoder. Editing uses the existing create/update POST. Removed delete/recreate and its repair retry. No deletion precedes the edit; an uncertain request requires readback to determine what happened. Legacy fallback still exists until exclusive sender retirement.
- All four materializers now authorize original receipt targets and every originally pinned child before replay or conflict details. Recovery commands reuse the same canonical request authority. Current access never comes from changed input or newer membership.
- Durable review writes enter the existing execution kernel with the exact SQL approval, content and attempt. No replacement queue or login system was added.
- Withdrew speculative account-wide locking, browser-execution and extra binding-table drafts. Existing ASO approve/wait/resume behavior keeps its existing owner.
- Improved pagination in existing Apple readers. Actions read routes now use the existing authorization boundary; HTTP/database tests cover page/count agreement, tenant access and personal read isolation.
- Current request, retained human/key and agent review permissions reuse canonical auth and existing entitlement/feature owners. Shared review policy lives outside the Apple provider directory. Sending approved reply text keeps its existing zero-credit cost.
- Canonical OAuth now exposes verified delegation and exact current-consent checks. Persisted OAuth Actions actors and their entrypoints remain unfinished. The prepared command route supports existing `write:agents` API keys and sessions; unrepresentable OAuth actors receive an explicit 403.
- The existing selected-credential loader now constructs a client from the already selected row. Its mixed-key signer bug is fixed: a valid team key cannot cause selection of an unvalidated individual key.
- Command acceptance is sampled after asynchronous validation/planning. A database wait that consumes a positive Undo window rolls back the command, allowing same-key retry. Explicit zero-window approval remains immediate. Commit/network latency can still reduce the visible window.

**Composed journey:** SDK → canonical session/API-key authorization → durable command → SQL worker → existing encrypted credential loader and write kernel → one native POST → acknowledgment/readback. Tests lose the first HTTP receipt and duplicate delivery hints without a second POST. Revoking membership after inspection retains evidence and prevents sending. Marking read leaves shared state, attention and capacity unchanged. Provider HTTP is synthetic; producer materialization is fixture setup, so this does not prove the old-producer handoff.

**Identity correction:** the existing review registry now distinguishes official Apple API IDs, original WebObjects IDs and Google Play IDs. Migration0175 adds one required enum column and rewrites only derived registry metadata. It adds no table, removes the fallback content scan/index, and preserves permanent ticket IDs, creation keys, immutable content and old command/receipt bytes. Unprovable, mixed or duplicate retained identities abort the migration atomically. Old digest versions remain readable for exact replay; new creations use the qualified identity.

The registry's actual fields are `organization_id text`, `identity_key uuid`, `codec_version integer`, `namespace review_work.identity_namespace`, `store review_work.store`, `provider_app_id text`, `provider_review_id text`, `action_id text`, and `witness_revision_id text`. All are required. The composite primary key is `(organization_id, identity_key)`; `(organization_id, action_id)` is unique. Action and witness links are tenant-scoped foreign keys. Namespace values are exactly `asc_customer_review`, `apple_original_review`, and `google_play_review`. The identity correction introduced no new relation. The feature now has 32 added relations through snapshot0177, with no new JSONB column; its two new conservation leaves are detailed below.

**Validation:** the previous `fced04cfc` checkpoint passed every required CI block, including migration/reliability, integration, unit, types, lint and deterministic web checks. Its full local suite passed 10,512 API unit tests (four existing skips), with 1,196 Actions SQL cases at the preceding clock checkpoint. The namespace correction passed 198 SQL cases across 15 suites, 45 unit cases, API/database/shared types and scoped lint. All migration runs apply 176 main and 13 metrics migrations fresh and repeat unchanged. Populated upgrades preserve accepted/refused v1/v2 receipts and package membership; invalid native identities roll back atomically.

The composed worker suite now passes eleven cases. Session and API-key approvals cover both new replies and updates to published or pending responses. Updates use the existing API upsert with one POST, no delete/recreate, and unchanged sealed baseline. Root's combined API typecheck and scoped lint passed. Native HTTP remains synthetic; producer setup remains explicitly outside this proof.

**Current cleanup validation:** 10,514 API unit tests pass (four existing skips), alongside 532 Apple package tests, 23 session tests, 77 focused SQL cases and five existing review-drain cases. API/Apple types and scoped lint pass. The full Actions SQL suite passed 1,247 cases across 116 files; all eleven composed worker cases passed using disposable Redis. Both verified 176 main and 13 metrics migrations fresh and repeat unchanged. The subsequent provider cleanup passed all 531 remaining Apple tests, Apple/API types, scoped lint and eighteen source-capture SQL cases. Eight removed tests belonged to the withdrawn unused write API.

[CI for the previous `1fe6dd25a` head](https://fload.semaphoreci.com/workflows/b2c5ecd3-c2f4-4494-b565-de0eb57ec8b0?pipeline_id=3da151de-1d3a-489f-b647-b9271a30163f) finished with two namespace fixture failures and a web tracking teardown failure; all three are corrected in this published checkpoint. Other required blocks passed. All required test blocks passed at `f76b2262c`, including ordinary integration, Actions migrations/reliability and deterministic web checks. The direct-branch review block had no review job. All required test blocks also passed for [integration head `641b73b86`](https://fload.semaphoreci.com/workflows/9a14a295-4bf9-4a53-9c8b-cb6c08d98a00?pipeline_id=21442280-f36f-4400-9b0c-f4712ec37b6e). These checks do not prove the unfinished producer cutover or independent GitHub PR review. No independent GitHub PR-review or full-readiness claim.

**Further overlap removed:** the ASO one-request adapter now shares its version-localization PATCH encoder with the existing Apple client. The unused native browser-write method and its browser-only binding adapter are removed; authenticated original-review capture exposes reads only. The new recovery loop remains unregistered and must integrate into the existing worker lifecycle; its SQL obligations are distinct from queue delivery.

**Remaining native-identity boundary:** distinct identifier namespaces do not prove whether two different IDs identify the same physical review. The cached `appleReviewResourceId` and text matching cannot transfer an approval. An exclusive app-level old-sender handoff and explicit native target approval remain necessary; no guessed crosswalk table or second sender is introduced.

**New integration:** review intake at `22d995042` uses the existing source capture, canonical authorization and single insertion owner. Codec4 hashes authored input, enabling exact receipt replay before recapture. Migration0176 extends the existing digest constraint/deferred guard only, adding no table or column. Old codec1/2/3 receipts survive populated upgrades; 154 SQL cases, API types and lint pass. Machine-read access at `641b73b86` reuses the existing `read:agents` machine policy for all four GET routes, while personal read-state POSTs remain session-only. Fifteen SQL cases and 52 route/authorization cases cover page/count agreement, pinned membership, tenant separation, remembered-session precedence and saved-cursor revocation. API types and lint pass. Both SQL checkpoints verify 177 main and thirteen metrics migrations fresh and repeat unchanged. These changes do not activate producers or provider workers.

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
| Extra listing binding catalog | Existing native discovery, snapshots, immutable selected revision facts and attempt records | Proposed page/version tables lack a demonstrated missing durable fact. Withdraw the proposal as an implementation plan. Read-only discovery can repeat before final selection is committed; any later schema addition needs a concrete failure case and minimal storage proof. | Proposal only; no extra binding-catalog migration was created. |
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

## Review conservation checkpoint0177

The importer retains drafts and rejected draft snapshots using existing tickets, sealed reply content, identity registry, aliases and conservation ledger. Ordinary dates belong to the source record. The new leaves hold typed source metadata and rejection facts; neither creates an approval, provider receipt, model invocation or usage charge.

Validation at2bda:110 SQL cases across five suites,41 units across three suites, API/database/shared types and scoped lint. Main178+metrics13 migration journals apply fresh and repeat unchanged. Exact source restoration, concurrency, rollback/retry, stale source refusal and alias namespace collisions are covered.

Only provably quiescent draft/rejection components are admitted. Queued, claimed, sent, uncertain and externally linked components refuse atomically. Required remaining work: external writer quiescence, full linked-edge refusal census, historical browsing, explicit proposal/resumption, remaining source families and old-writer retirement. These refusals cannot be used to discard outstanding work. Tests use a fixture-supplied external quiescence proof, not a real production handoff.

Fields below are generated from committed snapshot0177. Both tables have immutable rows, RLS tenant policies and composite primary key `(organization_id, record_id)`. The draft claim references the source ledger and exact reply revision; the revision link is unique per tenant. The rejection claim references its draft claim. Snapshot timestamps exist only for the embedded rejection snapshot, not ordinary draft source dates.

### `review_work.draft_source_claim`

| Field | SQL type | Nullable |
| --- | --- | --- |
| `organization_id` | `text` | No |
| `record_id` | `text` | No |
| `source_revision_id` | `text` | No |
| `source_draft_id` | `text` | No |
| `source_shape` | `review_work.draft_source_shape` | No |
| `identity_namespace` | `review_work.identity_namespace` | No |
| `model` | `text` | Yes |
| `prompt_tokens` | `integer` | Yes |
| `completion_tokens` | `integer` | Yes |
| `total_tokens` | `integer` | Yes |
| `pending_send_at` | `timestamp with time zone` | Yes |
| `sent_at` | `timestamp with time zone` | Yes |
| `send_attempts` | `integer` | No |
| `last_send_error` | `text` | Yes |
| `readback_scheduled_at` | `timestamp with time zone` | Yes |
| `snapshot_created_at` | `timestamp with time zone` | Yes |
| `snapshot_updated_at` | `timestamp with time zone` | Yes |

### `review_work.rejection_source_claim`

| Field | SQL type | Nullable |
| --- | --- | --- |
| `organization_id` | `text` | No |
| `record_id` | `text` | No |
| `rejected_by_user_id` | `text` | Yes |
| `fingerprint_version` | `integer` | No |
| `review_fingerprint` | `text` | No |
| `reason` | `text` | Yes |
