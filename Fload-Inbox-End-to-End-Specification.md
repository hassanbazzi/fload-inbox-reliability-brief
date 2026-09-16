# Fload inbox: current-capability implementation specification

15 September 2026 · FLO-1355 · Source baseline `63275b2f51ac5b5a151a9a6683c813423e682785`

> **16 September amendment:** [Provider boundary review](Fload-Provider-Boundary-Review.md) refines ownership of content, targets and evidence. The SQL/field catalog below remains the validated baseline, not an implemented or validated multi-schema refactor. Common Actions lifecycle guarantees remain; the final physical schema requires this responsibility split.

## Scope and decision

Build one durable Actions model for the capabilities that are supported and used today. The inbox is a view over that model. It is not another owner of workflow state. Existing BullMQ queues deliver work; the existing agent runtime owns agent computation and usage. Reports, reviews, experiments and observed store data retain their domain ownership.

The target does not include retired Ads/Product executors, historical parameter unions or tables whose only purpose is accommodating abandoned behavior. The source census retains a migration appendix so old receipts and links are not accidentally destroyed. That appendix does not define new runtime types.

**This is an implementation specification and a database design proof, not a shipped overhaul.** Application command handlers, production migrations and provider integration changes must be built and validated against the contract below. The field catalog is generated from the SQL actually loaded by the isolated PostgreSQL design harness; it is not a separate hand-maintained schema illustration.

## What changed since the prior review

1. Completed independent audits of entrypoints, current content, providers and queues, and reconciled their findings.
2. Ran a read-only production database census and getter-only census of all 16 declared queues, including Pro groups. Exact results remain private; no customer text or identifiers are published.
3. Removed retired-only schema variants following the requested scope correction.
4. Moved the operation and content family onto the immutable revision. A permanent locale ticket can progress from a generation request to a concrete listing proposal without changing identity.
5. Separated the approved execution from its provider steps and attempts. Step-specific outcomes cover partial writes and hidden adapter retries.
6. Replaced a universal event table with a history projection over attributable commands, revisions, approvals and attempts. There is one owner for each fact.
7. Added concrete field definitions, relational constraints, sealing rules, authorization rules, recovery schedules, cutover steps and implementation/test workstreams.

## 1. The smallest useful mental model

| Object | Owns | Does not own |
| --- | --- | --- |
| Ticket | Permanent ID, organization, asset, structural parent, owner, current shared decision, current revision and approval pointers | Provider response, personal read marker, copied queue status |
| Revision | Exact typed request/proposal/observation, operation, content family, baseline and authored provenance | Mutable current draft or a guessed previous approval |
| Command | Who requested a transition, channel, idempotency identity, exact preconditions and immutable response facts | Arbitrary JSON request/response payloads |
| Approval | Exact revision, selected membership, human or policy authorization, permitted scope, server Undo deadline | Permission to publish unseen generated content |
| Execution | One accepted obligation, its next due step, claim fence and recovery state | BullMQ waiting lists or agent runtime ownership |
| Step and attempt | A concrete provider effect and each actual call/check, with attributable evidence | One receipt that conceals several independent mutations |
| Personal read | What a particular teammate has seen | Snooze, dismissal, assignment, approval or iteration |

One ticket can be a child and a parent. A structural parent is permanent lineage. A collection revision freezes the selected child revisions presented for a particular decision. Neither relationship is reconstructed from today's pending rows.

## 2. Current capability boundary

The source manifest declares **18 registered work definitions**. The census also covers chat/tool aliases, HTTP entrypoints, internal producers and advisory surfaces. All mutations converge on Actions commands; aliases do not retain independent execution logic.

| Current work | Unit of durable work | Preparation and provider behavior |
| --- | --- | --- |
| `post_reply` | One review reply, explicit send/update intent | Exact review/account, text and prior-response baseline; provider readback |
| `post_batch` | Permanent collection and individually tracked reply children | Explicit membership pins; transport batching may not change approval scope |
| `apply_listing_changes` | One child per store/locale, with a collection for multiple locales | Frozen changed and preserved fields; distinct app-info/version/promo steps |
| `update_promo_text` | One locale's promo change | Pin live/editable surfaces that will be changed; no silent future-version targeting |
| `create_locale` | One locale request/proposal ticket | Generation revision and publication revision are distinct; store-specific fields |
| `update_description`, `update_short_description` | One Android locale change | Pin full replacement listing and explicit Play commit policy |
| `revert_experiment`, `aso_revert_listing` | Restore collection with one concrete listing child per locale | Resolve and freeze restore bytes before approval; preserve experiment/snapshot provenance |
| `review_catch_up_30d` | Generation request with an explicit window and publication policy | Creates durable reply children; generation acceptance is not a public-write receipt |
| `generate_review_analysis` | Internal analysis request | Retain real run/output references and usage; no provider-publication claim |
| Seven `asa_*` operations | One campaign/keyword/negative-keyword unit | Absolute decimal amounts, currency and provider account/IDs pinned; bid batches become child selections |
| Derived localization / listing generation | Existing target ticket plus new typed revision | Stable derivation key; human edits and dismissed fields win over stale generation |
| Screenshot / media generation | Immutable source/output media slots attached to revision | Versioned content-addressed storage; no reused output paths |
| Agent requests and prerequisite work | Typed request or advisory/prerequisite revision | Actual Agents runs remain in Agents; typed Actions handoff replaces embedded scheduler state |
| Informational / advisory work | Acknowledgeable ticket | Explicit acknowledgment/dismissal; never provider execution or default approval |

The complete finite entrypoint inventory is in [the entrypoint audit](audit-entrypoints.md). It covers **61 manifest entries, 160 HTTP registrations, 144 source-table writes and 99 named boundary calls**. These numbers are source occurrences, not distinct user capabilities or deployed traffic counts.

## 3. Identity, typing and normalization

The [actual SQL](Fload-Inbox-Current-Schema.sql) and [generated field catalog](Fload-Inbox-Current-Fields.md) define names, types, nullability, checks, foreign keys and indexes. The key design decisions are:

* `ticket_id` determines stable ownership/scope and current coordination facts. `revision_id` determines operation and content. Operation is not redundantly copied onto executions, attempts and queue payloads.
* Revisions use a closed family: review reply, listing, media, request, ads, advisory or collection. Closed operation/family checks and subtype sealing reject incompatible combinations.
* One constrained Ads content relation covers the seven supported operations. A different table per verb would not improve normalization.
* Ordered child membership, terms, media slots and evidence lists are relations because they are genuinely multivalued. There are no locale arrays, arbitrary key/value content rows, JSON/JSONB payloads or serialized JSON columns.
* Baselines and provider observations use the same concrete content families as proposals. Purpose is explicit, and only a sealed proposal can be the ticket's current actionable revision.
* Tenant columns on related rows are deliberate security denormalization, enforced by composite keys and RLS. A copied field is not called normalized merely because it is convenient.
* Provider IDs, error codes and diagnostic state strings are named scalar facts. They cannot select handlers or authorize a transition. All behavior-driving classifications are closed enums/checked unions.
* Scalar source coordinates from an immutable report/run are provenance, not new executable payloads. Domain references must resolve to the owning organization; ephemeral model coordinates must be paired with their exact immutable source version.

Adding a supported capability requires an explicit contract/schema migration, producer mapping, effect/readback rules and regression fixtures. It cannot be enabled by inserting a new string into an open payload. Existing source/diagnostic text never selects runtime behavior.

All runtime layers consume one strict contract: Zod `.strict()` discriminated unions in shared-types, branded identity types and exhaustive operations in Core, Drizzle enums/checks/FKs in storage, and the same contracts in the typed SDK and web. No `Record<string, unknown>`, `any`, permissive `.passthrough()`, string fallthrough or unknown-status-to-success behavior is permitted in the new path. JSON remains the HTTP encoding format; it is not an open database payload model.

### Physical relations and rejected simplifications

The loaded design currently has **25 relations**: 5 ticket/revision/relationship/read, 4 command/authority, 4 execution/evidence/resource, 10 typed content/multivalued content, and 2 provenance/link relations. This is the replacement domain contract, not 25 additional independent workflow owners. The generated catalog gives the exact current field count; no approximate diagram takes precedence over it.

Normalization does not require every one-to-one split. We removed duplicate advisory title/summary and listing rationale fields: the revision owns those values. Approval could be folded into a command target mechanically, but that would add optional authorization fields to every other command and obscure grant references; the explicit approval relation is retained as a deliberate domain boundary.

We rejected a generic job table because BullMQ already owns queue transport. We rejected a universal event table because commands, approvals and attempts already own the immutable facts needed for history. Seven supported Ads verbs share one constrained relation. Parent and child tickets share one identity table. Multivalued membership, terms, countries and competitors stay relational; merging them into arrays, JSON, delimiter strings or generic name/value rows would lose the requested closed typing and keys. Explicit repeated tenant IDs are justified security denormalization, enforced by composite constraints.

`action.creation_key` is immutable and unique per organization. Direct user creation may use its random UUID default. Every derived producer must supply a deterministic versioned UUID derived from its owned source identity, semantic target and proposal cycle. Retrying a cycle returns the existing ticket; discovering new work starts an explicit new cycle. An asset/locale alone is not a forever key, and a list request must never invent a cycle.

Structural parent changes are forbidden. Collection membership is immutable per sealed revision; children can belong to later review selections without changing lineage. Collection/dependency graph edits run at SERIALIZABLE isolation with sorted affected-ticket locks, rejecting cycles and retrying serialization failures through the same idempotency key. The design suite does not yet prove every concurrent graph insertion schedule.

## 4. Commands, actors and ownership

Every mutating entrypoint follows the same transaction protocol:

1. Resolve the principal and organization through the canonical authorization plugin. Validate the closed request contract, permission, asset visibility and capability.
2. Canonicalize the request and compute its versioned digest. The idempotency key is scoped to organization and stable principal. An existing key with a different digest is a conflict; an identical replay returns the stored original result.
3. Lock affected tickets in sorted ID order. Lock the parent selection and all selected children for batch commands. Compare expected ticket versions, exact revision IDs and exact parent membership.
4. Validate the current transition. A generation/publication race has one winner. The loser receives a typed conflict containing the current version/revision to refetch.
5. Insert the immutable command, target preimages/results, approval(s) and execution obligation(s), then update ticket heads in the same transaction. Server time determines Undo. No browser timer is part of acceptance.
6. Commit. Return accepted command ID, ticket result versions, approval IDs, execution IDs and Undo deadline. Enqueue is best-effort acceleration after commit; the durable due record guarantees recovery.

| Caller | Required attribution and authority |
| --- | --- |
| Web / direct HTTP | Authenticated Fload user, organization permission and exact revision |
| Chat | The initiating user and tool channel; never an undefined approver |
| Public MCP / API key | API key identity plus its owner/delegation and current scopes; do not flatten to owner alone |
| Slack / Discord | Verify callback signature and installation, map external actor to an authorized organization member, validate a signed exact-revision token; raw provider user ID is not a Fload user FK |
| Policy auto-publish | Immutable policy grant/version, issuing actor, asset and evaluated conditions; one explicit authorization per output revision |
| Agent | Actual agent run plus authority delegated by the initiating user or policy; the worker is not the human approver |
| Recovery / operator | Named recovery command and operator/system attribution; it may verify an old attempt, not invent an approval |

Ownership is organization-shared. Assign/unassign records previous and new owner in command history. Actor snapshots preserve the identity shown at the event even if a profile changes. Removing a user's access revokes future command authority; it does not rewrite past approvals. Organization erasure and identity retention follow the existing deletion policy and must be covered by domain-FK migration tests.

Policy grants have one-way, attributable revocation and a unique active grant per organization/asset/policy kind. Queued work rechecks revocation and current permission before a write. Readback of an already uncertain write remains allowed for recovery.

## 5. End-to-end flows

### Single reply

Observed review → durable child ticket → immutable proposed reply and expected prior response → approve exact revision → server Undo window → claim execution and provider resource → commit attempt before I/O → submit explicit send/update operation → persist acknowledgment → read back exact response → record visible/pending/mismatch/unreadable evidence → project status.

An externally written reply does not erase the ticket. Record already handled externally only after exact target/content evidence; if it differs, show a conflict. An edit of an existing response must not take the old drain's “response already exists, mark sent” branch.

### Review batch

Create one collection ID and child IDs when the package is formed. The shown revision contains every child/revision pair in a stable order. A batch approve validates the complete requested selection atomically and creates one grant/execution per selected child. A new review cannot join that approved selection. Partial delivery is child progress, not a reconstructed new batch. Retrying targets only eligible unsuccessful children after uncertainty checks. Editing membership appends a new collection revision and makes an old screen's approval stale.

### Localization derivation

Facts such as missing locales remain derived. When work is proposed, materialize the collection and target locale tickets with a stable producer identity. Approving a generation request pins its inputs and policy. Generation writes a new concrete listing revision on the same locale ticket only if the input revision is still current. It clears publication authority and requests fresh approval. A stale generation result can be retained as a non-current result, but cannot overwrite a human edit or revive a dismissed field.

Membership presented for publication pins the generated output revisions explicitly. Newly discovered locales form new work; they do not expand an earlier approval. Report regeneration preserves committed ticket identity and human changes. Source disappearance becomes an attributable resolution/supersession decision, not deletion of the ticket.

### Generation output contracts

Generation success is a closed, operation-specific output contract. It never means merely that an LLM returned text:

| Approved input | Required durable output | Ticket behavior |
| --- | --- | --- |
| Locale/listing generation or revision | Sealed revision derived from the exact approved input, with store/locale/provider target continuity | Adopt using current-version CAS; clear publication approval; retain stale output without adopting |
| `review_catch_up_30d` | Sealed `post_batch` collection with exact reply children, or `no_work` with `no_eligible_reviews` evidence from a completed run | Create the ticket in collection domain; request r1 can become collection r2 on the same permanent ID; generation never approves the replies |
| `generate_review_analysis` | Existing `review_analysis` row tied to the actual completed run | Link the result and complete the generation obligation; do not create a new actionable request |
| `run_agent` | Existing completed run of the exact `requested_agent_id` pinned in the request | Keep run ownership and usage with Agents; same-asset but different-agent output is rejected; result does not imply provider publication |

Output IDs have concrete FKs and organization checks. The generated output cannot change review target, store app, account or locale while reusing a permanent target ticket. A different target is new work. Empty review catch-up is a valid result, not an empty batch with manufactured approval.

### Listing and media

Resolve target provider account, app, locale, exact store version, required preserved values and any App Clip subtitle/image fallback before approval. Approval pins all effective content, including immutable media versions/digests. Promo changes explicitly pin both live and editable version targets when both are affected. App Clip recovery pins the exact incomplete header reservation and its observed state before any deletion; it cannot choose a different image after approval. The compiler emits only named supported provider steps. Each endpoint's effect has its own stable identity and attempts. A crash after one endpoint succeeds cannot repeat it as part of a blind whole-operation retry.

Saved editable content, live content and measured impact are separate facts. A provider acknowledgment cannot claim any later state. Release-gated work can release the write resource guard after all mutations are known finished while later publication verification waits for the user's release. Experiment measurement stays with the existing experiment domain.

### Ads

Resolve the actual Apple account and platform IDs before staging. Store money as exact decimal values and pin currency. A bid batch is a selection of keyword children. Begin with one provider mutation per child; do not reintroduce opaque bulk partial-success handling merely for transport efficiency. Create operations require complete scoped duplicate/readback evidence before retry; ambiguous creation remains uncertain when uniqueness cannot be established.

### Advisory / prerequisite

Acknowledgment is an explicit shared decision with an actor and history. A prerequisite has a named dependency and a typed recovery check. Restoring access or creating an editable release resumes/re-stages the actual proposal through the same command path. A placeholder card cannot be “executed” into success.

## 6. Queue and provider recovery contract

Keep existing resource lanes. The short Actions reconciler runs in worker infrastructure with a distributed lease and bounded pages; it never performs provider I/O or LLM work itself. It must not share a starvation-prone lane with the long jobs it repairs. No new API startup timers, SQL waiting-list engine or manipulation of BullMQ's internal Redis indexes.

The queue envelope contains only the versioned execution/step identity and scheduling generation. The worker reloads authoritative approved content. Queue retention, missing jobs and Redis loss do not change business outcome.

| Boundary | Required recovery |
| --- | --- |
| DB commit succeeds, enqueue fails | Reconciler enqueues the still-due generation |
| Queue accepts, publisher crashes | Duplicate delivery is rejected/coalesced by DB generation and claim |
| Worker crashes before provider call | Durable attempt exists; inspect possible I/O before deciding write eligibility |
| Provider succeeds, DB confirmation fails | Keep uncertain; read back or use a documented native idempotency key; never ordinary blind retry |
| Lease expires while original process may still run | Fence DB state; do not assume remote side effects are fenced. Keep resource guard until uncertainty resolves |
| Old worker returns evidence after losing claim | Append deduplicated late evidence against the exact attempt; it cannot overwrite current state |
| Provider step succeeds, next endpoint fails | Resume only the unfinished step; preserve each previous receipt |
| All writes finish but publication waits | Close the mutation plan and release resource exclusion; continue durable readback without holding app writes for weeks |
| Admin retries retained BullMQ job | Same execution eligibility gate applies; stale payload cannot revive cancelled approval |
| Redis queue/group state looks inconsistent | Use supported APIs and DB obligations; no private index cleanup or inferred “not executed” outcome |

Native idempotency remains disabled for adapters that do not demonstrate provider support. The audit found none in the current ASC/ASA/Play writers. Absolute updates may still conflict with outside changes; they are not automatically safe to replay because their API resembles a setter.

Two concrete provider corrections must precede activation: Apple's current documentation supports response POST upsert, while the code's delete/create replacement relies on an older assumption; Google Play commit must explicitly protect changes already in review rather than inherit the cancellation default. These are verified documentation/code discrepancies, not completed integration probes. See the source-backed [dispatch audit](audit-dispatch-recovery.md).

## 7. Read, list, count and history semantics

Personal read writes touch only `action_read`. Unread is `force_unread OR seen_attention_version < ticket.attention_version`. A shared workflow command cannot be implemented through that row. Marking read cannot clear snooze, dismissal or iteration. Clients may mark only a version they actually received; a future read watermark is rejected.

The server owns one scoped eligibility query. Organization, visible/non-deleted asset, filters, lifecycle, snooze time and parent/child policy are composed once. The page and exact count execute from the same query snapshot before `LIMIT`. No source-specific 200/500 cap. Use keyset pagination with stable `(created_at,id)` ordering and a signed cursor bound to the organization and filters. Each page is a fresh consistent snapshot; the API does not promise a long-lived MVCC snapshot across requests.

Expose both **ticket count** and **actionable child count** with explicit labels. A grouped page counts the same collection/ticket rows it returns; child workload is a separate measure. An actionable child can be reached directly by ID and in the flat work view even when its parent is closed or archived. Parent progress is derived from the exact child identities; hiding a parent cannot hide outstanding child work.

A collection's `decision='approved'` records the parent's decision; it does not mean every child was selected or completed. Root eligibility must include outstanding pinned children independently of the parent's decision. For the current parent revision, a child that is open, blocked, uncertain or due for verification keeps the collection discoverable under the corresponding filter. A changed child revision appears as changed/needs review, never as approved under the old membership. The flat child view uses each child's own current head and never depends on the parent being open.

Lifecycle display uses explicit precedence: unresolved external write → uncertain; applicable execution hold → blocked; active generation → revising/generating; claimed write → executing; verification due → verifying/awaiting release; settled output → generated result or explicit no-work; settled external resolution → handled externally; settled failure → failed; settled acknowledgment → acknowledged; confirmed required-surface result → verified live or verified editable; cancelled obligation → cancelled unless Undo has already reopened the current ticket; current approval before deadline → Undo available; ready approval → queued; otherwise the exact shared decision (open, declined, acknowledged, cancelled or superseded). Only the current approval/obligation supplies the current execution label; previous approvals and attempts remain history, with unresolved external effects separately blocking conflicting writes. Snooze and archive are shared placement facts, not evidence of completion. Unrecognized combinations fail validation and surface an operational error; no default maps to approved. Lists and counts call this same classifier and predicate.

The history view unions immutable command targets, revisions, approvals and attempts. It retains distinct event identities and deterministic time/ID ordering. It does not duplicate provider evidence into another event payload. Show who proposed, edited, approved, cancelled, assigned, executed and verified; expose the exact revision and selected children behind every approval.

Realtime is invalidation, not acceptance. Existing event fanout may prompt refetch after commit, and clients resynchronize after reconnect. Dropping an event cannot drop work. No browser state, toast or optimistic label is proof of durable acceptance or publication.

## 8. Migration and cleanup

| Phase | Concrete work and exit condition |
| --- | --- |
| Inventory | Keep the source/entrypoint census reproducible. Re-run schema, current capability, in-flight job, receipt and identity checks at the exact cutover revision. Current private results are a point-in-time input, not a future guarantee. |
| Expand | Generate Drizzle migrations for current typed relations, enums, constraints and required tenant keys. Apply the complete migration chain in a safe test DB. Prebuild large indexes/backfills outside release startup per repository guidance. |
| Backfill current work | Deterministic IDs preserve supported ticket/receipt URLs. Materialize current derived work and stable collections. Copy exact content and known attribution. An unproven old approval becomes needs-review/uncertain; it cannot authorize current mutable text. |
| Preserve excluded history | Inventory original receipts and links, retain the bounded audit material required by the existing retention contract, and verify restoration/link mapping. Do not invent new runtime variants for retired Ads/Product behavior. No destructive historical cleanup is implied by this design. |
| Quiesce old writers | Gate all audited producers, direct writes, admin retries and transport adapters. Drain or explicitly reconcile in-flight old provider effects. Delayed verification payloads must be translated to exact durable subjects or drained before queue removal. A rolling queue snapshot does not prove quiescence. |
| Catch up and validate | Compare IDs, supported current rows, exact content digests, approval proof, links, child membership, attribution, resource holds, list/count and due obligations. Unmapped current work blocks cutover; it does not fall into a generic payload bag. |
| Activate one owner | New commands and worker claim protocol become authoritative together. Old queued payloads cannot bypass authorization. Canary on controlled preview/provider fixtures; test rollback before the first new external write. |
| Contract | Remove old action params/overlays/draft scheduler fields and duplicate workflow writers/readers after their migration checks pass. Retire the unused review-sync queue only after producer census and live inspection. Keep unrelated queue lanes and domain-owned run/report/experiment facts. |

Rollback after a provider write is not “restore the DB backup.” First stop new writes, keep immutable commands/evidence, reconcile outstanding remote effects, and choose an explicit compensating action if authorized. A previous application image that ignores new approval/claim rules cannot be allowed to execute new work.

## 9. Implementation workstreams and acceptance tests

| Workstream | Main code ownership | Required proof |
| --- | --- | --- |
| Strict contracts and catalogue | `packages/shared-types`, Core Actions manifest, typed client | All current operation variants; unknown key/status rejected; exhaustive compiler and UI handling; no open contracts |
| Storage and migration | `packages/database` Drizzle schema/migrations | Whole migration chain; RLS/tenant FKs; immutable revisions; deterministic rerun; supported receipts/links preserved; no current unmapped rows |
| Atomic commands | Core Actions service/repository and API Drizzle UoW | Approve vs revise, simultaneous approve, identical/different idempotency replay, stale batch, server Undo vs claim, revoked permission/policy |
| Derivation and content | ASO generators, Reviews draft generation, backlog/report staging | Same IDs across refresh; human edit wins; dismissed fields preserved; new locale/review cannot join existing approval; versioned media survives regeneration |
| Delivery and recovery | Work execution, queue producers/processors, provider adapters | Every crash boundary in section6; hidden adapter retry disabled; exact step resume; stale worker fence; late evidence; uncertain write readback; admin retries |
| UI and read model | Inbox service/routes, SDK, web inbox/review/report surfaces | Read-state isolation; refresh/reconnect; actor timeline; distinct saved/live/measured states; flat child reachability; page/count equivalence beyond old caps |
| Cross-surface cleanup | Chat/MCP, Slack/Discord, direct routes, admin, worker hooks | Every audited path reaches same commands; no raw provider ID as user; no browser acceptance timer; no old JSON/overlay scheduler authority |

Repository protocol remains mandatory: reproduce each actual bug with a failing test before fixing it. Prefer real DB/Redis integration tests; import the safe test DB module, never the production singleton. Run the surrounding suite, typecheck/lint and relevant web checks. Semaphore is authoritative CI; prepare a reviewable PR with the final behavior and evidence. **Do not deploy production.**

## 10. Data and validation boundaries

The private database census used an explicit read-only repeatable-read transaction and per-query timeouts. It inspected schema, aggregate lifecycle/type counts, nested key/type shapes and receipt/link/delivery conditions; it did not retrieve customer text or identifiers. The queue census used supported getters, disabled queue metadata updates and inspected all declared lanes and group states. It made no queue, database or provider mutations.

The source review, live census and isolated database design proof answer different questions. The isolated suite additionally exercises real two-session row-lock contention and stale-version rejection, while using synthetic provider evidence. None proves the new application is implemented, a full production migration has passed, or provider behavior has been live-probed. The implementation gates above are concrete remaining work, not unspecified architecture decisions.

Read the supporting audits for exact file/line links and detailed matrices: [entrypoints](audit-entrypoints.md), [content and migration](audit-content-migration.md), [dispatch and recovery](audit-dispatch-recovery.md), [command invariants](schema-command-guards.md).

## 11. Specific integration gates before cutover

* Verify the documented ASC response upsert with controlled provider fixtures. Keep transport semantics explicit; no silent delete/create fallback.
* Verify explicit Play `ERROR_IF_IN_REVIEW`, edit expiry, app-level interference and readback finality. A negative observation alone cannot authorize retry of a timed-out write.
* Verify immutable media/object versions, complete upload chunk coverage, exact App Clip reservation identity and both promo target versions.
* Bind the design FKs to the full real domain schema and rehearse user/org/integration deletion. Preserve immutable actor subject/name snapshots; account erasure must not cascade away commands or approvals. The isolated identity stubs do not validate that retention path.
* Run provider and actor permissions at command time and again before a new write; policy revocation serializes with dispatch. Observation and late evidence may still be recorded after revocation.
* Run list/count and history queries against seeded current data beyond existing caps, with partial batches, hidden parents, organization isolation, and concurrent transitions.

These are implementation acceptance gates with known test targets, not reasons to add retired capabilities or open-ended schema payloads.
