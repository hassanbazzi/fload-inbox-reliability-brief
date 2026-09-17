# Fload inbox reliability — architecture and delivery specification

> **17 September update:** [Corrected design v11](Fload-Inbox-Revised-Design-v11.md) now defines the reviewed execution, command-history and Usage contracts. Start with the [simple visual summary](summary.html). This supporting document preserves the wider inventory and earlier review evidence; v11 takes precedence where its contracts change these proposals. Implementation and migration validation remain open.

16 September 2026 · FLO-1355 · Source baseline `f0b1af5fc`

**Documentation is the current deliverable. Implementation is paused.** This packet describes the recommended end state, the actual schema now drafted in the repository, evidence from focused tests, and the remaining work required before a clean cutover. It does not claim the overhaul is implemented or ready to ship.

**Independent review update:** retain the durable-ticket foundation and revise the architecture before implementation resumes. Recovery exits, strict subtype constraints, deletion/retention, tenant references, producer convergence and reproducible evidence are release gates. [Review response R01–R12](Fload-Review-Resolution.md) records confirmed findings, corrections and acceptance tests; [reviewer handover](Fload-Reviewer-Relay.md) explains the next review task. The actual DDL/catalog remains unchanged and is not the corrected final design.

[Visual walkthrough](https://hassanbazzi.github.io/fload-inbox-reliability-brief/) · [Every field and constraint](Fload-Inbox-Current-Fields.md) · [Exact draft migration SQL](Fload-Inbox-Current-Schema.sql) · [Implementation checkpoint](Fload-Implementation-Checkpoint.md)

## 1. The team walkthrough

A ticket is the permanent record of a commitment. The inbox is a filtered view of those tickets.

1. **Create work once.** Discovery turns a fact into an actionable ticket using a stable source identity. Opening the inbox does not create work or reconstruct identity.
2. **Save exact content.** Every proposal is an immutable revision. Store targets, reply text, listing fields, selected locales and material provider effects belong to the reviewed revision.
3. **Record who decided.** Approval is a separate grant for that revision, with the responsible person or explicit automation policy and a server-owned Undo deadline.
4. **Deliver durably.** Acceptance atomically creates an execution obligation. Existing queues wake workers; losing a browser, queue message or worker does not erase the obligation.
5. **Keep evidence.** Submission, saved editable content, verified live content and measured results remain different facts. Unknown provider outcomes stay uncertain.
6. **Retain the same ticket.** Revision, iteration, partial completion, retry, external handling and completion remain attached to the same identity and URL.

A parent is an ordinary ticket. A child is an ordinary ticket. A collection revision freezes which child revisions a batch decision concerns.

## 2. The problems being addressed

| Existing failure window | Required guarantee | Draft evidence / remaining work |
|---|---|---|
| Marking read overwrites a lifecycle overlay | Personal read state cannot mutate shared workflow | Separate relation and real database tests exist |
| Workflow overlays differ indefinitely between teammates | Organization owns decision, snooze, owner and lifecycle | Commands and shared projection exist; old consumers still need removal |
| Browser waits before sending approval | Send immediately; acknowledge only after database commit; Undo is a server deadline | New hook and commands exist; stalled-Redis HTTP regression still requires a fix |
| Batch disappears or reuses identity | Persist parent identity and revision-specific membership | Collection/materialization tests exist; old producers must converge |
| Approval races iteration | One ordered lock and exact version/revision check | Core and database concurrency tests exist |
| Unknown status becomes approved | Closed enums and explicit refusal; no success fallback | New model is closed; all migration categories require explicit dispositions |
| Caps hide work or list/count disagree | One eligibility predicate, counts before pagination, keyset cursor | Shared model and pagination tests exist; remaining summary consumers need cutover |
| Provider succeeds before confirmation commits | Intent before I/O; uncertainty; exact provider readback before replay | Native crash/readback tests exist; provider and migration recovery acceptance remains required |

The source audit is retained as a dated investigation. The [entrypoint plan](Fload-Entrypoint-and-Ownership-Plan.md) is the current convergence checklist.

## 3. What Fload controls, and what it observes

| Layer | Owns | Does not establish |
|---|---|---|
| Actions | Ticket identity, immutable decisions, revision authorization, Undo, shared workflow, ownership and history | That a remote write succeeded |
| Reviews / Listings / Ads / Agents | Domain content, generation policy, current supported capabilities, actual agent runs and usage | Another domain's lifecycle or an implicit publish grant |
| Provider integration | Exact native target/units/protocol, typed receipts and readback decoding | A universal meaning for every provider's “budget” or “status” |
| BullMQ / browser infrastructure | Delivery wakeups, concurrency lanes, resource sessions and transport | Approval, durable business completion or exact-once remote effects |
| External provider | Its current resource state, moderation and publication | Exclusive Fload control; another user may change it later |
| Experiments / analytics | Measurement windows and results | That “submitted” means “measured” |

The current draft uses one PostgreSQL database with schemas `actions`, `apple_ads`, `app_store_connect`, `google_play`. These are Fload-owned namespaces, not provider access or separate services. Retaining four namespaces is a design choice to evaluate through ownership, grants and operational cost; normalization does not require it. Provider-specific types and protocols remain explicit in either physical layout.

A future Meta implementation adds only its actual native contract, adapter, permissions, migration and tests. It does not add Meta-specific fields to `actions.action`, reinterpret Apple budget fields, clone the lifecycle, or introduce an open provider payload. There is no speculative Meta write schema in this design.

Read the [provider ownership review](Fload-Provider-Boundary-Review.md) for the classification method and concrete examples.

## 4. The actual proposed schema

The explorer is generated from the exact repository migrations loaded in an isolated synthetic test database: **31 physical tables, 497 fields, three relational views**. It is not a drawing of hypothetical column names.

| Responsibility | Physical tables | Count |
|---|---|---:|
| Identity, content identity and personal attention | action, action_revision, action_membership, action_dependency, action_read | 5 |
| Decisions and attribution | action_command, action_command_target, action_approval, action_policy_revision | 4 |
| Execution and recovery | action_execution, action_execution_step, action_execution_attempt, action_resource_guard | 4 |
| Typed Fload content and repeating facts | review, listing, media, request, advisory content; terms, notes, countries, competitors | 9 |
| Source links | action_revision_source, action_alias | 2 |
| Apple Search Ads | action_content, attempt_receipt | 2 |
| App Store Connect | listing_contract, step_contract, attempt_receipt | 3 |
| Google Play | listing_contract, attempt_receipt | 2 |
| **Total** | | **31** |

The earlier 25-table design mixed provider fields into common relations. Moving Ads content into `apple_ads` changes its owner without adding a table. The separate ASC/Play listing contracts, ASC step contract and three provider receipts add six tables. That accounts for the full 25 → 31 change.

This is the paused replacement-domain draft, not an approved table-count target or a claim that 31 tables are the net production increase. Receipt and listing-contract consolidation are under review; each smaller alternative must preserve ownership, transport compatibility and immutability. The net change cannot be stated honestly until the old-table retirement and historical-evidence migration are complete. No additional generic job table, event store, parent-ticket table or table per operation is proposed.

### Read the central records

| Relation | Key fields and meaning |
|---|---|
| action | `id`, `organization_id`, `creation_key`, `asset_id`, `domain`, `parent_action_id`, `decision`, `version`, `attention_version`, `current_revision_id`, `current_approval_id`, `owner_user_id`, `snoozed_until`, `archived_at`, `successor_action_id`, `last_command_id` |
| action_revision | `id`, `action_id`, `purpose`, `kind`, `operation`, `revision_number`, `authored_command_id`, `baseline_revision_id`, `generated_from_revision_id`, `content_digest`, `canonicalization_version`, `sealed` |
| action_membership | `parent_revision_id`, `child_action_id`, `child_revision_id`, `ordinal`: exactly what a collection revision contains |
| action_approval | `action_id`, `revision_id`, `command_id`, `scope`, `policy_revision_id`, `parent_revision_id`, `undo_deadline`, `required_surface`, `authorization_version` |
| action_execution | `approval_id`, `phase`, `next_run_at`, `next_step_id`, `schedule_generation`, `claim_generation`, `claim_token`, `claim_expires_at`, `hold_reason`, `result`, `resource_guard_id`, `plan_complete` |
| action_read | Composite identity `organization_id + user_id + action_id`; `seen_attention_version`, `force_unread`, `updated_at` |

These are an orientation, not the complete field list. [All 497 fields, constraints, enum values and view definitions](Fload-Inbox-Current-Fields.md) are available directly.

### Normalization and explicit types

The grain of each relation is deliberate: one ticket, one revision, one membership, one command target, one approval, one native effect, one attempt, one personal read watermark. Those identities have different cardinalities and lifetimes.

A revision can contain several terms, countries, competitors or media slots. They are ordered child rows with explicit fields and closed roles. They cannot invent new property names. **The existing advisory/request subtype constraints are incomplete:** named typed columns still admit invalid combinations. The revised design must specify required, forbidden and optional fields for every variant and enforce that matrix in wire contracts and SQL. A generic ordered-item merge must preserve request ownership of countries/competitors and the distinct value semantics of terms/notes.

A revision owns title, summary and rationale once. Approval points to the revision instead of copying its content. History is projected from immutable records rather than maintained as another lifecycle database. Provider detail rows point to their revision, step or attempt with real foreign keys.

`current_revision_id`, `current_approval_id`, version counters and execution position are deliberate current-state pointers. They are justified by transaction and query needs and protected by invariant checks; their presence is not a claim that normalization forbids all stored projections.

The public schema catalog is JSON for the viewer. The proposed SQL storage and wire command unions have no arbitrary JSON/JSONB content, generic parameter maps or SQL array payloads. External provider JSON is decoded at the integration boundary into finite typed records.

## 5. Lifecycle, ownership and history

Decision and execution are distinct dimensions.

- Decision: `open | approved | declined | acknowledged | handled_externally | cancelled | superseded`.
- Execution phase: `ready | claimed | verification_due | uncertain | blocked | settled | cancelled`.
- Execution result: `generated | verified_live | verified_editable | handled_externally | acknowledged_only | failed | cancelled`.
- Authorization scope: `generate | revise | perform`.

Approval is not completion. Archive/snooze are shared placement choices; they cannot erase uncertainty. Read/unread remains personal. Generated content returns to an open unapproved revision. A rejected ticket keeps its identity and content. Restoration cannot silently restore publication authority.

The required command contract records accepted/refused/conflicting outcomes with actor kind, stable subject, available user/API-key/agent-run/policy identity, channel, idempotency key, digest, timestamp and exact target changes. Assignment identifies the current owner; approval attribution comes from the immutable approval command, not from whoever owns the ticket now.

API impersonation must record the real authorized operator and the represented organization/member context. Slack/Discord integration installation is not proof of sender membership. Until a verified member mapping exists, those channels link to the permanent ticket for a signed-in decision.

Policy grants are explicit and versioned. An old “automatic” mode setting is not a policy grant. Workers recheck revocation and current entitlement before dispatch. The audit preserves original opaque actor identity even if a deleted member's personal name must be scrubbed.

The prototype still has attribution gaps: impersonated web chat conflicts with its stored channel/delegation CHECK, and some API-key, actor-run and attempt-connector references lack tenant invariants. Database conflicts can bypass intended typed command history. These are unfinished implementation requirements, not reasons to weaken actor attribution. A full retention matrix must preserve truthful history when connectors, integrations or agent runs are removed.

## 6. Atomic commands and exact approvals

The command envelope contains a stable idempotency UUID and exact `actionId + expectedVersion + expectedRevisionId`. Batch commands also supply explicit child pins. The same key and same request replay the recorded outcome. Reusing the key for different content is a conflict.

In one transaction:

1. Resolve canonical organization/principal authorization.
2. Lock the idempotency identity, then relevant tickets in deterministic order.
3. Check target version, content revision, membership and current permissions.
4. Save immutable command/target history.
5. For approval, create the exact grant and its durable execution obligation.
6. Commit before returning acceptance.

No provider I/O belongs inside this transaction. No browser timer owns whether acceptance occurs. Undo cancels only before the server deadline and before the execution claim has crossed the cancellation boundary; its ticket/approval/execution changes are atomic.

Iteration and approval share the same ticket lock and version condition. One wins; the other receives the current pins and asks the caller to review the changed state. Accepted commands survive UI refresh failure and can be safely retried after a lost response.

## 7. End-to-end work families

### Review reply and batch

The Reviews domain supplies the native review and source snapshot. The actionable reply becomes a durable child with exact response text, intent, target and baseline. A parent revision pins its children in order. A fresh incoming review does not join an already approved decision scope.

The current catch-up producer and ordinary reply producer do not yet share a convergent identity rule. Historical rejection suppression and changed-source reopening must be defined once across generation and discovery. The existing-draft UI already iterates canonically; the separate generation HTTP endpoint can still return old human-owned content while charging usage. These are cutover gates.

Approval selects child revisions. Each child has its own execution, retry and result. The parent continues to show partial progress. Retry skips confirmed effects and inspects uncertain outcomes before any new send.

If a reply appears outside Fload, persist an observation and a non-authorizing “handled externally” resolution. Do not manufacture an approval or claim that Fload posted it. If the source review changes, the exact source snapshot is a precondition; a known local mismatch prevents dispatch. External API limitations still prevent a universal remote compare-and-swap guarantee.

### Derived localization

A missing-locale fact can be computed. An actionable localization commitment is persisted.

Create parent L and one child for each store/locale. Generation approval pins the selected locale, field scope, source context, overwrite consent and policy. It permits content generation only. The agent run, billing context and exact output are attributable to that request.

Generation commits a sealed proposal and captured provider baseline. It installs that output only while the approved input remains valid. The child keeps its ID. Updating the parent creates a new manifest revision with the same child identities; it cannot rewrite historical membership or inherit publishing approval.

The reviewer inspects actual text and media. A second approval authorizes publication of that exact revision. Eight successful locales and two blocked locales remain ten children of the same parent. New locale opportunities create new explicitly reviewable work.

**Unfinished contract parity is explicit:** selected/excluded fields, immediate-update routing, overwrite consent, affordability, credit attribution and report/catalog origin must survive every producer handoff. The current prototype helper does not yet carry all of these. See the [execution plan](Fload-Execution-and-Cutover-Plan.md).

### ASO listing and App Clip

Freeze the concrete provider account, app, locale, editable/live target identity, proposed fields, preserved fields and baseline. Field constraints remain store-specific.

App Clip work additionally freezes media bytes, object identity, checksums, dimensions and intended subtitle/header operation. Approval must preview those exact bytes. Native reservation/upload/commit steps may be materialized from a typed reservation receipt only where that protocol does not change the reviewed material content. A changed payload or target requires a new revision.

“Saved in editable release” and “verified live” remain separate. Pending publication needs a durable waiting obligation and bounded observation. Release mutation exclusion only after all issued writes are resolved; elapsed time or a polling budget is not proof of non-application. App Clip lost-confirmation recovery must reconstruct the exact reserved resource from sufficient typed evidence without requiring the missing old receipt. Revert work requires the exact prior snapshot and a fresh approval; it is not a pointer instructing a future worker to guess the old text.

### Apple Search Ads

Current supported writes are pause campaign, enable campaign, update campaign budget, update keyword bid, create keyword, add negative keyword and delete negative keyword.

Store exact provider IDs, money as exact decimals, currency and native match semantics. The adapter creates one native effect per step, stores typed receipts and verifies the exact resource. The API returns durable acceptance, not a manufactured synchronous success. A bid package is a persistent collection with individually pinned children.

### Agent requests and advisories

Generation, analysis and wake requests use a closed request type and real agent-run provenance. A request ticket is the commitment; an agent run is the computation. Do not create a fake agent run solely to obtain a parent ID.

Advisories are stable typed tickets with attributed revision history. Recovery may acknowledge a prerequisite with evidence; recurrence appends/reopens under explicit rules. Human dismissal is not silently overwritten by rediscovery. Acknowledging advice never masquerades as publishing content.

## 8. Queues, job-table scrutiny and provider recovery

There is **no new generic job table** and no second SQL scheduler.

`action_execution` records the obligation that must survive transport loss. `action_execution_step` records ordered native effects. `action_execution_attempt` records what was actually tried and what evidence exists. BullMQ transports only organization, execution and schedule-generation references on existing workers.

The worker-owned recovery scan uses database due times and pagination. It repairs lost wakeups and expired claims. API replicas remain stateless and own no polling loop.

Before I/O, a worker validates current authority and target, claims the relevant provider resource and commits a started attempt. After I/O, it atomically persists the receipt, result and next obligation. Persist the same captured outcome again after a transient confirmation failure, recognizing an already-committed result after ambiguous commit. Do not resend the provider call to save a receipt. If usable confirmation is lost, the started attempt remains unresolved and requires provider reconciliation.

A lease fence protects database transitions; it cannot cancel an HTTP request already inside a provider. An absent/mismatched readback does not, by itself, prove a timed-out write will never apply. Only conclusive non-application or an applicable native idempotency guarantee permits another effect.

Automatic observation must have durable budgets and backoff, then a visible waiting or reconciliation hold. Stopping polling does not change mutation certainty. Incomplete plans need deterministic continuation or an explicit hold, never completion. Definitive permanent rejection may settle the old execution and reopen the same ticket only when all issued effects are resolved; a new proposal needs fresh approval. Same-ID delayed queue jobs need actual promotion/reconciliation, not another duplicate add. Resource scope must follow native conflicts, and actual consumption must retain idempotent billing provenance. These are revisions required by [R01–R04 and R09](Fload-Review-Resolution.md), not guarantees already completed in the prototype.

The earlier proposed `action_job` relation is withdrawn; there is no standalone `job` table in the audited current schema. Existing capability-execution records, dispatch fields on pending actions, agent runs and old inbox iteration queue jobs must be classified by their actual owner. Retain transport observability and business-domain outputs; remove duplicated approval, retry and completion authority after migration. The [execution and cutover plan](Fload-Execution-and-Cutover-Plan.md) gives the queue inventory, provider recipes and deletion gates.

## 9. List, count, attention and permanent links

List and count use the same organization/asset/parent/domain/owner/view predicate. Count all eligible tickets before applying the page limit. Use stable keyset cursors with database timestamp precision and ID tie-breaking. A limit is a page size, not a hidden total cap.

Selecting an app includes organization-wide work, so connector advisories remain reachable. Parents and children are independently addressable tickets; list/count must explicitly use the same counting unit. Do not display a parent count beside a child-work total. The prototype currently includes parent and child rows and treats queued/working/verifying work as needs_attention; shared filters do not settle those product choices. The recommended design separates decision-needed and processing views, with an explicit top-level versus child scope. Parent summaries must expose actionable children even when a filter matches only a child. Finalize and test that view contract before claiming counting correctness.

Personal read state is a monotonic seen-attention watermark plus an explicit unread flag. Meaningful progress, a new revision or a newly blocked outcome can advance attention. Repeated polling/claims with no material change stay silent.

Namespaced aliases resolve old URLs to permanent IDs. Ambiguous source IDs fail rather than select an arbitrary ticket. History supports pagination and inspection of exact saved revisions, approvals and provider evidence.

## 10. Clean migration and removal

The migration is not “copy old status into new enum.”

Inventory every source and queue page; fingerprint the records used to prepare the plan. Produce deterministic typed mappings and stable identity/alias resolution. Apply in bounded transactions with source rechecks. Replaying an import must return the same identities and never create a second executable obligation.

Separate current content, original approval facts, personal overlays, native receipts and queue state. Conflicting personal snooze/dismissal values require an explicit shared-workflow disposition. Unknown statuses block classification. Historical membership is not inferred from today's pending rows.

Migration DDL must be fully qualified; session search_path currently leaks across migration files sharing a transaction. Add a sentinel migration to that same chain/connection. Specify per-reference retention/erasure behavior and tenant/worker roles before changing FKs or RLS. Deletion must preserve receipts and approvals without creating impossible actor rows.

Current unapproved imports have focused test coverage. Historical rejection snapshots, review history, request events, previously approved/failed work, edited original AI content, restore snapshots and uncertain delivery require further implementation.

**An unresolved storage decision is retained visibly:** the current schema cannot honestly import a native receipt as a new approved execution when the original actor or reviewed revision is unprovable. The final migration must retain that evidence in a closed, non-authorizing factual representation or an independently owned audit destination. It must not fabricate an approval to satisfy foreign keys. Final DDL and reconciliation tests for that case are a cutover gate; the 31-table draft is not presented as a completed historical importer.

After conservation checks prove identity, content, membership, attribution and receipt links, remove old writers and readers, resolve old queued work, then remove obsolete tables/columns and compatibility code. A bounded operational transition may be necessary; it is not a permanent second architecture.

The [migration/data plan](Fload-Migration-and-Data-Plan.md) contains the source-by-status matrix, overlay decisions, blocker taxonomy, reconciliation proofs and retirement order.

## 11. Required proof before implementation is ready

| Area | Required scenarios |
|---|---|
| Commands | Same-key retries; altered-key payload conflicts; approve versus iterate; undo versus worker claim; lost HTTP response |
| Revisions | Stale content refused; immutable baseline; user edit preserved; generation output committed then worker crash |
| Collections | Stable batch handoff; new review excluded; partial results; selected child pin mismatch; sibling generation and parent revision races |
| Providers | Success then failed confirmation; ambiguous commit deduplication; lost reservation receipt; late success/plan continuation; bounded unreadable/mismatch observation; pending publication; permanent rejection and safe reopen; adapter-version mismatch |
| Localizations | Derivation convergence; exact locale/field/consent and credit scope; existing external locale; App Clip bytes/steps; editable versus live |
| Migration | Full journal plus same-connection sentinel; replay; more than former caps; duplicates; unknown states; incomplete approval evidence; alias conservation; deletion/erasure retention; real app/worker role constraints; unresolved queue work |
| Authorization | Cross-tenant denial; API-key scope; membership revocation; policy revocation; deleted asset; real impersonating operator; external sender mapping |
| Read model | Same list/count predicate; microsecond cursor ordering; organization advisories under app filter; personal reads never mutate workflow |
| Product | Exact content/media preview; ownership/history; unknown acceptance retry; partial batch display; all entrypoints use the same commands |
| Repository | Typecheck, lint, relevant unit/integration/build checks, authorization/provider-boundary inventories and Semaphore CI |

The [checkpoint](Fload-Implementation-Checkpoint.md) distinguishes retained historical passes, failing logs, unsupported aggregate claims and unvalidated current behavior. No fresh application tests were run for this documentation response. The claimed 22 core pass and combined advisory/ads pass require reconstructible evidence; a file named progress-green actually records a failure. Each next validation needs its exact command, timestamp, source fingerprint and retained result. No production deployment is part of this work.

## 12. What changed after independent review

- Added [R01–R12](Fload-Review-Resolution.md), with confirmed blockers, qualified findings, rejected unsafe remedies and acceptance evidence.
- Kept the actual schema catalog unchanged while explicitly requiring subtype constraints, retention rules and constraint-preserving consolidation decisions.
- Expanded recovery to cover bounded observation, safe failure reopening, lost confirmation, incomplete plans and actual delayed-job promotion.
- Added migration search-path, deletable-reference and tenant-role gates; updated producer identity, billing, attribution, counting and attention requirements.
- Corrected overstated test claims and distinguished source inspection from runtime proof.
- Added a public reviewer relay; preserved the local implementation and current field explorer for comparison. No application change, new main pull, PR or deployment was made for this update.
