# Execution, providers, generation, and cutover

> **17 September update:** [Corrected design v9](Fload-Inbox-Revised-Design-v9.md) now defines the reviewed execution, command-history and Usage contracts. Start with the [simple visual summary](summary.html). This supporting document preserves the wider inventory and earlier review evidence; v9 takes precedence where its contracts change these proposals. Implementation and migration validation remain open.

**Documentation status — 16 September 2026.** This is the recommended end state, with an explicit account of the partial implementation used to test the design. Repository baseline: `f0b1af5fc5925d818be7d9b02b42b1fc54556ecc` in `fload-ai/fload-platform`. The prototype is uncommitted, not deployed, and is not a completed platform cutover. Work on that prototype has paused. No live provider writes were used for validation.

**Revised after independent review.** The permanent ticket/revision/approval model remains the recommendation. The paused prototype is not release-ready: recovery has unbounded branches, permanently rejected publication lacks a same-ticket reopening path, and several provider recovery paths are incomplete. The corrections below are proposed design requirements, not newly implemented or tested guarantees. See [Review findings and resolution](Fload-Review-Resolution.md) for the consolidated assessment.

The design keeps one permanent ticket, one immutable description of each proposed change, and one exact approval. Its execution record is a durable obligation to complete or reconcile that approval. BullMQ wakes workers; it does not decide what was approved or whether it succeeded.

## 1. Where control stops

| Fact | Fload controls | Provider controls or must be observed |
|---|---|---|
| Proposal | Exact target, immutable copy/media, author, baseline, content revision | Current store/account facts captured when preparing the proposal |
| Approval | Authorized actor or policy, exact revision and member selection, Undo deadline | Nothing: approval alone does not change a provider |
| Dispatch | Committed attempt, current authorization, resource exclusion, one admitted request | Whether a request arrives or is applied |
| Acknowledgement | Preserving the exact response and native identifiers | Response semantics, asynchronous processing, publication rules |
| Verification | Complete readback, target equality, comparison algorithm, recorded evidence | Editable state, public state, release timing |
| Measurement | Scheduling analysis, preserving the observation window and methodology | Traffic, ranking, conversions, reporting lag and external changes |

“Generated,” “provider acknowledged,” “verified editable,” “verified live,” and “measured” are different facts. A Google Play edit read can prove editable listing content; it cannot establish that the public listing is live. A successful Apple metadata update can still require an app release. Missing or unknown provider states must never mean success.

Equal reply text awaiting moderation is **pending publication**, not satisfaction of an approval requiring a published review response. The revised design must retain a durable publication obligation, lower-frequency observation and supported event wake-ups. A provider acknowledgement may close the mutation phase when its semantics conclusively establish completion, but it must not erase the remaining verification requirement by settling the ticket as complete.

A complete matching observation after a definitive rejection can establish **handled externally**. It must not manufacture a claim that Fload performed the write. An uncertain write followed by a mismatch remains uncertain: an earlier request might still arrive.

## 2. The normalized execution model

The core model has fixed responsibilities. Provider columns belong to provider-specific contracts and receipt leaves, not a general payload bag.

```mermaid
flowchart LR
  A["Ticket<br/>stable identity + shared decision"] --> R["Revision<br/>immutable kind + operation + content"]
  R --> AP["Approval<br/>exact revision + actor/policy + deadline"]
  AP --> E["Execution<br/>durable due obligation + claim + result"]
  E --> S["Ordered steps<br/>approved effect + recovery policy"]
  S --> AT["Attempts<br/>started before I/O + immutable outcome"]
  AT --> P["Provider receipt leaf<br/>native identifiers and evidence"]
  AT --> O["Observation revision<br/>complete typed provider snapshot"]
  E -. wake-up only .-> Q["Existing BullMQ queues"]
```

| Record | Fields that matter to execution | Why it exists |
|---|---|---|
| `action` | organization, asset, parent, current revision, current approval, decision, owner, version, attention version, snooze, archive | One stable object and organization-shared lifecycle |
| `action_revision` | action, kind, operation, purpose, revision number, baseline, generated-from revision, authoring command, digest, seal | Immutable exact subject of review; a request can become listing content on the same ticket |
| `action_membership` | parent revision, child action, child revision, ordinal | Permanent selected membership; each parent revision pins the exact child content |
| `action_approval` | revision, actor/policy attribution, authorization scope, required surface, creation time, Undo deadline | What was authorized, by whom, and when work may start |
| `action_execution` | approval, phase, next run, next step, schedule generation, claim generation/token/expiry, resource guard, plan completeness, writes-closed time, hold reason, result, settlement time | Recoverable obligation after request acceptance |
| `action_execution_step` | execution, ordinal, exact content revision, closed step kind, adapter version, required surface, verification timing, recovery mode/version, retry limits and delays | Individually accountable effect or internal generation |
| `action_execution_attempt` | step, ledger number, kind, claim fence, start/finish, exact subject attempt, bound transport/run, result and evidence/output references | Proves admission occurred before I/O; keeps every attempt and late result |
| `action_resource_guard` | closed scope, provider, canonical remote application or advertising account, holder execution | Serializes conflicting writes independently of connector aliases |
| `action_command` + targets | idempotency, actor, channel, accepted/refused outcome, expected and resulting state | Attributable history and replay-safe commands |
| `action_read` | user, action, read attention version | Personal attention only; never approval, snooze, iteration, or execution |

The provider-neutral TypeScript execution contract is in `packages/core/src/actions/execution.ts`. The current prototype schema is `packages/database/src/schema-actions.ts`, with generated migrations `0146_durable_actions.sql` and `0147_action_progress.sql`. These are paused draft implementation sources. The published current SQL now bundles those exact migrations; the field catalog was exported from their isolated test-database application. Neither represents a production migration or completed cutover.

### Closed execution states

- Phase: `ready | claimed | verification_due | uncertain | blocked | settled | cancelled`.
- Result: `generated | verified_live | verified_editable | handled_externally | acknowledged_only | failed | cancelled`.
- Required evidence surface: `provider_response | editable_listing | live_listing | review_response | advertising_resource | internal_artifact`.
- Write outcome: `acknowledged | known_not_applied | uncertain`.
- Readback outcome: `matched | matched_external | mismatch | unreadable | known_not_applied`.
- Internal output: exact revision, review analysis, agent run, or the closed catch-up no-work reason `no_eligible_reviews`.

Failure/retry facts are explicit. `known_not_applied` distinguishes failure before dispatch, provider rejection, terminal non-application evidence, and an expired uncommitted edit. `uncertain` distinguishes lost transport, expired claim, and invalid response. These are the **current draft** enums. The next design pass must specify closed holds for incomplete plans and bounded observation, plus any publication-waiting distinction, before publishing revised concrete DDL.

The current decoder checks the recovery-policy version, but does not consistently enforce adapter and plan versions. Enforcing every executable contract version at load is a required correction. Unsupported native evidence must remain unreadable/uncertain; version incompatibility should produce an explicit operational hold, not silently run today's adapter against yesterday's contract.

## 3. Acceptance, execution, and recovery

```mermaid
sequenceDiagram
  participant UI as Client
  participant DB as Actions transaction
  participant Q as BullMQ
  participant W as Worker
  participant P as Provider
  UI->>DB: Approve exact revision + idempotency key
  DB->>DB: Lock targets; verify scope; persist approval + execution + due time
  DB-->>UI: Accepted; exact server Undo deadline
  DB-->>Q: Best-effort wake-up after commit
  Q->>W: organization ID + execution ID + schedule generation
  W->>DB: Lock actions then execution; validate deadline and permission
  DB->>DB: Acquire resource; persist claim and started attempt
  DB-->>W: Exact immutable dispatch grant
  W->>P: One native effect
  P-->>W: Native response, or uncertain transport
  W->>DB: Atomic receipt + outcome + next durable obligation
  W->>P: Read back exact target when needed
  W->>DB: Persist complete observation and truthful result
```

The recommended lock order is command idempotency lock, all involved action IDs in lexical order, then executions and provider resources. A worker first resolves scope without a lock and then acquires the same ordered action locks. Structural parents and selected children are included when generation can change a parent manifest.

A claim lease is a fence for Fload's state transitions, not a claim that an external HTTP request was cancelled. A stale worker can append immutable evidence. It cannot change a newer ticket, install generated content, extend a current plan, or claim settlement.

### Recovery matrix

This matrix specifies the recommended end state. The prototype implements important admission and evidence fences, but does **not** yet implement every recovery exit shown here.

| Situation | Required next action | Must not happen |
|---|---|---|
| API commits approval; Redis enqueue fails | SQL recovery finds the still-due execution and enqueues it | Lose work because the request returned |
| Duplicate queue delivery | One worker admits the effect; others observe current claim or stale generation | Duplicate physical write |
| Worker dies before I/O after attempt commit | Treat expired attempt as uncertain; inspect exact provider target | Assume the write never began |
| Provider applies write; confirmation transaction fails | Retry persistence of the same captured response within a bounded budget; after response loss, use supported exact readback | Repeat the provider call as a persistence retry |
| Provider response is malformed or incomplete | Persist uncertainty; perform supported readback | Treat HTTP success as verified content |
| Readback mismatches an uncertain request | Keep uncertainty or require conclusive native non-application evidence | Infer safe retry from a current mismatch |
| Provider definitively rejects request | Record exact rejection; if permanent and every issued effect is resolved, fail the old execution and explicitly reopen the same ticket for a new revision/approval | Spend retries on permanent rejection or abandon the permanent ticket |
| Observation repeatedly mismatches or is unavailable | Back off, exhaust a separate observation budget, enter an actionable hold retaining the original certainty facts | Convert a polling limit into non-application, successful settlement or permission to retry |
| Exact text is pending moderation or approved live surface awaits release | Persist publication/release waiting with durable follow-up | Treat editable or pending content as verified live |
| Dynamic plan remains incomplete | Stop unbounded redispatch; recover the exact native plan under a fresh claim or hold with explicit evidence needs | Invent missing effects, declare success or release uncertain I/O |
| Explicit reconcile command | Schedule readback of prior effects | Authorize a fresh write |
| Explicit retry command | Require current pinned approval, definitive non-application, retryable disposition; extend bounded budget | Reopen a terminal execution or replay successful steps |
| Late successful worker response | Append evidence; current claim decides adoption | Overwrite a newer outcome |
| Permission or policy revoked | Block new effects; allow observation of already-issued effects | Lose accountability for an earlier request |
| Some batch children succeed | Retain parent and every child; retry only eligible failed children | Recreate batch identity or resend successful children |
| Internal generation output committed before crash | Recover exact sealed output from durable run lineage | Run the model a second time merely because acknowledgement was lost |

### Bounded observation without changing the facts

**Confirmed gap:** the draft caps mutation attempts but not repeated mismatch/unreadable observations. Verification repeats at a fixed delay. `awaiting_release` exists in the draft vocabulary but is not assigned by these paths. An incomplete plan can repeatedly reschedule without a hold reason, while runtime plan reconstruction is empty.

The correction needs a closed, versioned observation policy: maximum automatic observations and/or elapsed time, bounded backoff, last meaningful observation fingerprint, next eligible observation, and the exact event or operator action that can resume it. The durable attempt ledger can supply the counts; the design must specify any additional fields rather than hide policy in arbitrary metadata. A fingerprint must exclude capture timestamps and identify the relevant target/content/state, so identical evidence can be recognized.

Distinguish three cases:

1. **Acknowledged effect, verification pending:** no new mutation is permitted. Provider processing or release may justify a slower durable watch.
2. **Uncertain effect, readback cannot resolve it:** stop expensive polling when its budget ends, but retain uncertainty and the conflicting resource exclusion.
3. **Conclusive non-application:** retry is possible only under its explicit disposition and an applicable current authorization; permanent rejection instead permits safe reopening.

Blocked must mean an actionable hold: recorded reason, preserved evidence, next evidence required, and a supported resumption path. A hold does not need to poll forever, and it must not hide the work from the workload view. Event-based resumption also needs a bounded fallback where events can be missed.

### Same-ticket reopening after definitive failure

**Confirmed gap:** the draft leaves a permanently rejected `perform` execution blocked and its ticket approved. Revise/reject/restore/supersede cannot proceed, and retry is unavailable. Existing restore logic only reopens settled failed generation/revision work.

The revised command must atomically validate that every admitted attempt is finished and no uncertain provider effect remains, settle the failed execution, clear the current approval and reopen the same action. Preserve all previous revisions, approvals, successful partial effects and receipts. A new revision requires a fresh approval and a new execution; a terminal old execution remains immutable.

Do not classify a partially applied plan as wholly not applied. Before editing/reapproving its remaining work, capture the current provider state and prepare the new proposal against that baseline. The initial same-ticket regression must include an explicit restore/reopen command between permanent rejection and edit; it must not imply that a revision can bypass the approved-state checks.

### Resource exclusion

**Current prototype:** store writes use a global canonical `(provider, remoteApplicationId)` key. The account field is absent from this key so an API issuer and a browser connector cannot bypass each other when writing the same app. The approved content still pins a provider account, and dispatch must validate that account binding. This safely excludes conflicts but lets an unresolved reply block unrelated listing work.

Advertising writes currently use `(provider, providerAccountId)`. The revised design must document actual conflict domains before narrowing either guard. Independent review responses may use an exact review-level domain when provider semantics permit; two writers of the same review still conflict. Google Play listing edit sessions remain application-wide even when locale fields look independent. ASC listing and App Clip operations need their overlap mapped before separate family guards are accepted. Advertising campaign/resource scopes likewise require evidence about account-wide interactions. A resource-family label alone is not a conflict model.

The guard remains held while any admitted write could still be in flight. It can be released once effects are conclusively closed even when public verification is pending. Definitively blocked executions with no unresolved I/O may release it without claiming success.

An incomplete dynamic plan may enter a hold and release exclusion only when **every issued effect** is conclusively resolved. Reserve acknowledgement alone says nothing about another outstanding attempt. An uncommitted upload reservation remains a recorded partial effect; resumption must revalidate it and the target before extending the plan. Lease expiry, observation exhaustion and a human assertion are not release conditions.

### Evidence-backed operator decisions

An operator may request readback, provide attributable evidence or stop automatic recovery. Any new resolution command must have a closed evidence type, exact attempt/target references, current authorization, immutable attribution and explicit validation rules. A screenshot or absence in a UI cannot prove that a timed-out request will never arrive. Do not add a generic `manual_verification` basis that automatically grants `known_not_applied`.

External completion still requires a complete observation of the approved desired state and appropriate provenance. Resolving uncertain native effects requires provider guarantees such as a terminal rejection, exact expired uncommitted edit, or equivalent conclusive evidence. Where those guarantees do not exist, retain an explicit unresolved hold rather than let an operator manufacture success or safe replay.

## 4. BullMQ stays; the proposed generic job table is withdrawn

The earlier `action_job` design combined obligation, queue transport and attempts. It is withdrawn. The audited repository does **not** contain a standalone SQL `job` table to delete. The cleanup targets are actual pending-action dispatch fields, duplicate capability receipts/authority, per-user overlays and old delivery paths. Existing `agent_run` computation and domain accounting remain owned by Agents.

The current source declares 15 central queues in `services/queue.ts` plus `agent-execution` in `agents/scheduler.ts`. The relevant ownership inventory is:

| Existing lane | Keep / change for Actions |
|---|---|
| `inboxIteration` (`inbox-iteration`) | Reuse the worker pool for canonical execution wake-ups. Replace old mutable inbox-iteration payload authority with durable references. |
| `sync` | Reuse repeatable recovery and existing domain verification/measurement scheduling; remove competing inbox lifecycle updates. |
| `scraping` | Preserve account groups, global capacity and browser/session locking. A readback or reply attempt must not bypass this capacity boundary. |
| `agent-execution` | Keep actual agent computation and `agent_run` identity; Actions links the authorized run and generated output. |
| `reviewSync` (`review-sync`) | Existing scheduler/event compatibility queue has no dedicated worker. It is not a new reply execution owner. |
| `setup`, `syncReports`, `valuation` | Keep their current setup, sync-report and valuation domains. No inbox lifecycle storage is moved into them. |
| `report`, `apptweakReport`, `reportPdf` | Keep generation, provider report work and PDF capacity separation. Generated recommendations use the canonical work producer boundary. |
| `apptweak`, `apptweakScheduler` | Keep market-data throughput and scheduling ownership. A queue completion does not approve a proposed listing. |
| `email`, `alerts`, `support` | Keep communications and support work. Notification delivery is not provider publication evidence. |

Queue names and capacity are implementation facts to recheck before release, not a fixed architecture quota. Preserve the existing BullMQ grouped-job orphan fix; recovery must use supported queue APIs, never repair Redis internals or assume an unknown queue state proves non-application.

The end state uses the existing `inboxIteration` worker pool for `action-execution` wake-ups and the existing `sync` pool for a repeatable `action-execution-recovery` sweep. The prototype registers a 60-second recovery job and a startup recovery pass in the worker, not the API process.

The complete delivery envelope is:

```ts
type ActionExecutionWakeup = {
  organizationId: string;
  executionId: string;
  scheduleGeneration: number;
};
```

No copy, provider target, approval, browser session, or mutable business command travels in that job. Workers reload the authoritative records.

The due scan uses keyset pagination over exact database timestamps and execution IDs. Reading or enqueueing a due row never consumes the obligation. It remains due until a transactional state transition changes it. Queue job IDs include schedule generation, and completed/failed delivery jobs are removed. **Remaining gap:** a still-delayed job with the same ID is returned as a duplicate by BullMQ; adding it again with zero delay does not promote it. The draft sweep counts that operation as enqueued even though delivery did not advance.

The correction must use supported queue APIs to promote a same-generation delayed job once SQL says it is due. Handle races with jobs becoming active, completing or disappearing; distinguish queued, already runnable, promoted and failed outcomes in operational reporting. Do not delete an active job or consume the SQL obligation to repair delivery.

**Clock qualification:** the draft computes delay from the producer's host clock, while BullMQ normally stamps the job with that same host clock. Its delayed score is timestamp plus delay, so the producer offset normally cancels. The specific claim that a producer 30 seconds behind necessarily adds 30 seconds is unsupported. Worker-clock skew and stale delayed jobs remain relevant. A change to database-relative delay must also align the queue timestamp; changing only one side can introduce skew. SQL time remains authoritative for Undo and admission regardless of queue timing.

### Confirmation persistence is a separate retry

The draft calls finalization once. A brief database outage can discard an otherwise usable native response when the invocation exits; recovery then needs provider readback, which some effects do not support. Add a bounded retry for **persisting the same captured response**, not for sending the request again.

This requires an idempotent evidence contract. Re-read the attempt after an ambiguous commit, recognize an identical already-persisted outcome/receipt/observation, reject conflicting evidence, and use late-evidence recording after claim loss. A current worker may extend a plan only under its current fence. Native evidence closures currently retain their response for the invocation, but claim fencing alone does not make every insert or dynamic-plan append idempotent. Process death can still lose that response; the native readback or explicit unresolved path remains necessary.

Source: `services/actions/dispatcher.ts`, `queue-dispatch.ts`, `execution-repository.ts`, `services/worker/process-action-execution-job.ts`, and `worker.ts` in the API package.

## 5. Provider recipes and adapter ownership

Core decides whether an effect may run and what evidence is sufficient. A provider adapter owns native request construction, exact response parsing, native target binding, and readback semantics. Provider packages own native endpoints and transport details. No adapter can silently run a second mutation as a fallback.

| Capability | Explicit effects and evidence |
|---|---|
| ASC listing metadata | Separate app-info localization and version-localization upserts. Editable and live promotional-text surfaces have separate pinned target pairs. Readback compares every approved field on the appropriate surface. |
| ASC review reply | Exact review/source snapshot and send/update intent. One supported API or browser mutation; updates must not hide a delete/create pair. Known locally changed source review prevents dispatch. Readback verifies exact response text/state/target. |
| Google Play review reply | One reply mutation with exact review and account. Readback must be complete and strictly parsed. |
| Google Play listing | Create owned edit → PATCH exact existing listing fields or PUT complete new locale → commit with `ERROR_IF_IN_REVIEW` → create separate inspection edit → read exact listing and persist observation → delete inspection edit. Inspection is never committed. It proves editable state only. |
| ASC App Clip | Freeze experience/version/localization, exact subtitle if creating, immutable image bytes and digests before approval. Optional exact incomplete-header deletion → localization creation if needed → reserve header → persist exact returned upload manifest → individually durable byte chunks → commit. Final readback verifies the approved media/target. |
| Apple Search Ads | Separate campaign status/budget, keyword bid/create, and negative-keyword create/delete effects. Decimal values remain exact strings. Complete native pagination is required; a mixed success/error result is not blanket success. |
| Meta Ads | Existing read integration is not a supported Actions write capability. Unused package write methods do not establish a tested publication path. |

These are the **intended recipes**, not certification of every transport and recovery branch. In particular, Google Play console-cookie authentication on the native publishing path remains a contract-validation gate. Keep the documented `changesInReviewBehavior=ERROR_IF_IN_REVIEW` control: Google's [official edits.commit reference](https://developers.google.com/android-publisher/api-ref/rest/v3/edits/commit) defines it explicitly. `changesNotSentForReview` is a different control, not a replacement. Uncertain Play commit and ASA create without a retained resource ID currently have unsupported readback paths and require an explicit resolution design before release.

### Provider failure classes and comparison

The revised adapters need a closed provider-specific mapping, based on response semantics rather than a blanket HTTP-status rule:

| Class | Required behavior |
|---|---|
| Authentication refresh needed | Reprepare credentials through the canonical binding path; bounded retry only when non-application is established |
| Permission revoked or connector inactive | Explicit permission/readiness hold; no repeated unauthorized mutations |
| Cooldown or rate limit | Durable next eligible time; avoid exhausting mutation retries on a local pre-dispatch wait |
| Provider conflict | Inspect the exact conflicting state; retry only if that provider establishes non-application and the approved target remains valid |
| Permanently invalid content | Preserve rejection evidence; permit safe same-ticket reopen after all effects resolve |
| Transport loss, malformed success or ambiguous response | Uncertain; supported readback or evidence-backed hold, never blind retry |

The draft is too coarse in some 400/401/403/404/409/422 and pre-dispatch classifications. Making every 401/403/409 retryable is not an adequate correction either. Connector activity, grant/account binding, cooldown, adapter/plan version and content validity must be checked at the correct boundary.

ASC readback currently compares approved strings byte-for-byte. The existing `normalizeListingComparisonText` utility supplies the intended limited equivalence: trim outer whitespace, CRLF to LF, and Unicode NFC. Apply a reviewed, versioned comparison while retaining raw approved and observed values. Do not add case folding, punctuation folding, internal-whitespace collapsing or unreadable-to-empty coercion. Review reply normalization belongs at proposal sealing as well as compatible readback, so the user approves the actual canonical text that will be sent. Tests must distinguish equivalent encodings from meaningful content changes.

The prototype has 26 closed step kinds: ten ASC, six Google Play, six Apple Search Ads, and four internal steps. Pause and activate are two approved operations implemented by one closed campaign-status step kind. This enum is a dispatch vocabulary, not a configurable workflow engine.

### App Clip dynamic-plan rule

A reservation response supplies dynamic upload operations. Planning must not fabricate future URLs, headers, offsets, or lengths.

1. The approval contains exact immutable bytes, digests, target, and requested result.
2. The reserve attempt is committed before its request.
3. Its receipt, recognized upload manifest, chunk steps, and reserve outcome are persisted in one transaction.
4. Supported chunks are an explicit bounded contract: encrypted signed URL, PUT method, recognized image content type, byte offset/length, and originating reservation attempt.
5. The complete chunk sequence must cover the exact bytes contiguously before commit is allowed.
6. `planComplete` remains false until all mandatory effects exist. Reserve acknowledgement alone cannot settle or release the resource.
7. If that transaction is lost, the **required corrected design** must reconstruct the exact reservation from supported readback evidence. The paused prototype does not yet satisfy this rule. If the provider cannot supply conclusive evidence, the item must reach a visible unresolved hold; no guessed upload or second reservation is authorized.

Unknown upload methods or headers are unsupported before I/O. Signed URLs are not exposed as public ticket content.

**Verified current behavior:** a current-claim reserve acknowledgement finalizes its receipt, upload plan and attempt outcome atomically. The cited content-type mismatch throws; it does not silently commit acknowledgement while skipping the manifest. Invalid manifest parsing produces uncertainty, retaining any parsed native receipt when finalization succeeds.

**Verified recovery gaps:** after the whole confirmation transaction is lost, reservation readback may find the media and decode upload operations, but the invocation requires a previous acknowledgement or retained media ID before accepting that observation as matched. With neither retained, it remains mismatch and cannot append the recovered plan. Separately, a late acknowledgement is preserved as evidence but cannot append a current plan, and the runtime's plan-reconstruction hook is empty. The latter can leave an incomplete plan repeatedly rescheduling.

The correction must establish reservation identity from sufficient native evidence under a fresh claim, atomically retain its receipt and manifest, and resume only the approved bytes and target. A matching filename and size alone do not establish which request created a reservation; use exact native identity, immutable media facts and temporal/provenance evidence with documented guarantees. If that proof is unavailable, remain unresolved. Do not remove the ownership check merely to make readback return matched, and do not let stale evidence extend the live plan.

### Adding another provider

A new provider should add its closed typed content/target leaf where the approved facts differ, native receipt/step contracts where needed, transport binding, request/readback adapter, and a finite compiler mapping. It must supply tests for target identity, native response ambiguity, retries, publication semantics, and account/resource conflicts.

It should not add provider branches to ticket identity, personal read state, command idempotency, revision history, generic claim logic, or queue infrastructure. Adding an effect without conclusive readback is permitted only with an explicit manual-reconciliation outcome, not invented success.

## 6. Localization: one identity through every stage

```mermaid
flowchart TD
  P1["Parent X / revision 1<br/>10 exact child request revisions"] --> G["Generate approved children"]
  G --> C1["Child A: request r1 → listing r2<br/>same ticket identity"]
  G --> C2["Child B: request r1 → listing r2<br/>same ticket identity"]
  C1 --> P2["Parent X / new immutable manifest<br/>same child IDs and ordinals; fresh revision pins"]
  C2 --> P2
  P2 --> REVIEW["Human reviews generated copy and media"]
  REVIEW --> AP["Fresh publication approval<br/>pins exact selected child revisions"]
  AP --> OUT["8 verified · 1 awaiting release · 1 blocked"]
  OUT --> HISTORY["Parent X still exists<br/>all attempts, approvals and links retained"]
```

A generation approval does not authorize publication. Generation binds an exact input revision and a durable agent run before model work. Output is staged as an immutable revision with exact lineage. Its provider baseline and proposal must commit together.

For individual child generation, the attempt captures the structural parent's input revision under the parent lock. Successful adoption creates an attributed parent manifest revision that replaces only that child's pin while retaining the same IDs and ordinals. Compatible sibling generation can rebase; a manual parent change or active parent generation conflicts. Old sibling approvals remain attached to their original content.

For a parent iteration, all generated child revisions and the replacement parent membership are staged first. Adoption is atomic only if every original child is still current and unapproved, the parent is unchanged, and no conflicting execution exists. One concurrent edit prevents the entire staged batch from becoming current. Staged outputs remain inspectable.

A new locale opportunity creates new work or an explicit new manifest revision. It cannot silently join an earlier approval.

### Proposal preparation

The partial ASO producer prepares exact field changes and fresh provider targets before materialization. ASC proposals pin the app-info and version localization resources, including separate promotional-text surfaces where relevant. Unknown baseline fields remain unreadable; they are not converted to empty strings.

App Clip preparation is read-only: determine the exact target, verify source and header states, download only a recognized image source, validate bounded bytes/dimensions, persist content-addressed immutable storage, then expose approvable content. Existing absent headers and exact incomplete headers have distinct repair semantics. Deletion requires the exact approved incomplete resource.

Generated listing copy retains the existing keyword-removal authority check. An operator's explicit instruction to remove a term must remain distinguishable from unintended model omission.

## 7. Measurement and experiments

This is a required end-state flow; the new execution path has not completed the existing ASO experiment handoff.

```mermaid
flowchart LR
  R["Recommendation / experiment variant"] --> S["Typed revision-source links"]
  S --> A["Approved listing revision"]
  A --> E["Execution + provider evidence"]
  E --> V{"Which surface is verified?"}
  V -->|Editable only| WAIT["Await publication/release evidence"]
  V -->|Required public state| WINDOW["Start defined measurement window"]
  WAIT --> WINDOW
  WINDOW --> M["Existing experiment measurement workers"]
  M --> RESULT["Measured result linked to action + exact revision"]
```

Execution should not report lift or experiment success. The domain handoff needs an idempotent projection from verified execution evidence to existing experiment records, with exact recommendation, variant, baseline, applied field set, timestamps and receipt provenance. The first moment an edit becomes measurable must be specified per provider and experiment type.

Acceptance must cover delayed release, partial locale success, externally handled work, manual provider edits, revert identity, duplicate verification, and a crash between verification and measurement handoff. Existing experiment schedulers remain the transport. Do not introduce a second generic job engine to fill this gap.

## 8. What exists, what is tested, what remains

| Area | Prototype status | Required before completion |
|---|---|---|
| Core execution and SQL adapter | Draft admission/fencing/evidence paths passed focused cases; review found recovery and reopening gaps | Bounded observation/plan holds, evidence-safe reopening, version enforcement and full repository checks |
| Durable SQL due scan and existing queues | Draft exists; queue adapter tests and real DB due-obligation checks passed | Same-ID promotion, clock-aligned scheduling, idempotent confirmation persistence, worker restart/Redis loss drill |
| Review native effect/readback | Draft source-change, crash and concurrency cases passed | Pending-publication lifecycle, canonical text comparison, provider failure classification and legacy-test migration |
| Listing/ASA native adapters and compiler | Draft exists; finite parser/compiler tests do not cover every recovery branch | Play authentication proof; uncertain commit/create resolution; complete evidence and version checks |
| App Clip preparation and dispatch | Read-only preparation unit cases passed; current-claim receipt/manifest finalization is atomic | Lost-receipt reservation reconstruction, late-evidence plan adoption, bounded incomplete-plan hold and exact provider/session coverage |
| Stable ASO listing packages | Implemented; three real DB package/approval/request cases passed | Producer alias convergence, partial-package retry behavior, all old-path parity tests |
| Generation baseline/output recovery | Draft generation and parent/child DB cases passed in earlier focused runs | Actual worker billing context, idempotent charge attribution, field-selection semantics, remaining producer cutover |
| Catalog/backlog/report locale requests | **Still on old generation path** | Replace old request rows and ASOLocaleExpansion producer with typed Actions without losing consent, billing or routing |
| ASO experiments/measurement | **Incomplete handoff** | Attributable idempotent projection from verified Actions to experiment measurement |
| Legacy data and queued work | Migration/alias mechanisms in the paused prototype | Full dry-run/rehearsal, blockers resolved, old writer removal, receipt/link reconciliation |
| Deployment | None | Separate reviewed rollout; not authorized by this document |

### Concrete remaining contract and producer work

The old catalog localization path carries more than a locale list. Its replacement must preserve:

- Selected and excluded metadata fields.
- Routing between immediate metadata updates and full locale creation.
- Explicit overwrite acknowledgement for existing locales.
- The exact catalog card/definition and origin: chat, catalog, backlog or report.
- Durable stage-agent/run provenance.
- Credit affordability checks immediately before admission and actual token billing attributed to the correct origin.
- Source availability, capability readiness, locale validation and exact idempotency.

The current `createLocaleGenerationWork` prototype carries store, locales, operator instructions and generation-only approval. It is not yet a complete catalog replacement. Review confirmed that the worker generation boundary lacks the active billing context required to meter and attribute LLM calls; premium entitlement gating does not replace it. Meter actual consumption and make customer charge attribution idempotent across recovery, failed output adoption and repeated delivery. A closed field-selection/routing contract is needed; do not restore the old open params object.

System/report discovery may create attributed requests. It must not forge a human grant from `createdBy: null`. Automatic generation requires an explicit current policy or separately justified internal authority, with durable scope and provenance.

Current source locations requiring cutover:

- `services/capability-catalog.service.ts`: `createLocalizeTask`, `createLocalizeRequestRow`, `startLocaleGeneration`, `startBacklogGenerationRequest`.
- `services/backlog/stage-on-completion.ts`: report-to-generation handoff.
- `services/backlog/convert-locale-candidates.ts`: derived opportunity/request identity.
- `services/worker/process-aso-locale-expansion.ts`: old generation worker.
- Related experiment revert/measurement and pending-action producer/consumer references found by the final writer census.

### Additional correctness items to close

1. **Migration/producers must converge.** Stable new creation keys must resolve existing migrated aliases and source links. Re-discovery after migration cannot create a second ticket for the same work.
2. **Partial package recovery is explicit.** A producer retry that discovers some already-materialized members must either recover the exact existing package or append a separately attributed new manifest. It cannot silently replace membership.
3. **Play creation must observe existence.** The new locale generation path needs fresh complete evidence about an existing editable locale and explicit overwrite scope; it must not infer absence from a requested operation.
4. **Field states survive generation.** Verify that omitted, dismissed, unchanged and unreadable fields keep their intended semantics when converting generated copy.
5. **API result language stays truthful.** Queued means a durable accepted execution, not published. Refused approval must not be returned as an accepted publication.
6. **Retired entry points cannot bypass Actions.** Existing queue jobs only wake an alias-mapped approved execution. An unmapped job is a migration blocker, never a source of synthesized approval.
7. **Blockers are durable and visible.** A failed legacy delivery log or queue TTL is not sufficient accounting. Preflight must enumerate unresolved jobs and records before writer retirement.
8. **Complete the old test migration.** Tests that previously expected inline provider writes must assert durable acceptance, exact approval, no bypass, and eventual evidence through the worker.
9. **Define retention and erasure before cutover.** Immutable execution/history references to connectors, runs, integrations and source records conflict with existing deletion paths. Specify tombstones, retained evidence and erasure authority per reference; changing FK deletion behavior alone does not bypass immutable-row guards safely.
10. **Use one coordinated release gate.** Reader cutover cannot precede producer convergence, migration and direct-writer retirement. The paused prototype has that split and must not be released as-is. These are prospective blockers, not evidence of production incidents.

## 9. Validation evidence and release acceptance

The last active execution/listing validation completed after implementation paused: **9 of 9 real PostgreSQL integration tests passed** across `actions-execution.test.ts` and `actions-listing-work.test.ts`. Retained output records that bounded result. These used isolated test databases created from the complete migration chain and controlled provider ports. The subsequent independent assessment was read-only and did not run new tests.

Covered in that run:

- A known source-review edit causes zero provider requests.
- Native review response/readback evidence survives a confirmation crash.
- Two workers cannot issue the same admitted effect.
- A provider success followed by database failure recovers by readback.
- Late evidence does not rewrite a newer settlement.
- Listing due obligations does not consume them.
- Concurrent listing discovery creates one stable parent and stable children with immutable baselines.
- Batch approval pins exact content and rejects stale changes.
- Locale request retries preserve identity and authorize generation only.

Earlier checkpoints reported the following focused results; these are historical evidence, not a current combined branch certification:

- Five parent/collection generation integration cases, including ten-locale concurrent sibling completion, manual parent conflict, and all-or-nothing child adoption.
- Three generation integration cases, including atomic baseline/proposal staging and recovery after committed output.
- App Clip preparation, target parsing, execution codec and retired listing writer unit suites.
- Core execution tests for exact Undo boundaries, stale delivery/claims, unsupported readback, definitive non-application, dynamic plan completeness and external completion.

These are bounded results. They do not mean the complete repository suite, migration of live data, every provider capability, or end-to-end product cutover has passed. Retained logs include both failed and later passing runs; a filename containing “green” is not proof. No live publication test was performed. Report the full API typecheck and other suites only from their exact retained results; do not infer a combined green state from these checkpoints.

When implementation resumes, the evidence ledger must record each suite, exact command, timestamp, base commit plus source fingerprint, exit/result and retained output. Re-run missing or nonreconstructible checkpoint claims. Existing CI discovers API/package tests, but the standalone storage-proof command needs explicit pipeline wiring; the uncommitted prototype has not passed CI.

### Required final acceptance

**All rows below are proposed acceptance gates.** They are not assertions that equivalent tests currently exist or pass. Current guarantees are limited to the concrete retained evidence above.

| Scenario | Required assertion |
|---|---|
| Retry every accepted command | Same identity and result; no duplicate approval/run/write |
| Concurrent approval, iteration, revoke, Undo | Exactly one valid state transition; stale caller sees current state |
| Redis unavailable or lost | Accepted SQL obligations remain visible and are re-enqueued after recovery |
| SQL-due execution already has delayed queue job | Supported promotion makes it runnable; active/completed/disappearing races do not lose the obligation or mutate a provider |
| Producer/worker clock offsets | Queue timestamp and delay remain aligned; DB Undo/admission gates hold; due recovery still progresses |
| Crash at each boundary | Before attempt, after attempt, after provider acceptance, before receipt commit, after output staging, before adoption: no lost work or blind replay |
| Brief database failure after native success | Same captured response is persisted once; ambiguous commits are recognized; no second native request; claim loss uses immutable late evidence |
| Unknown/partial provider response | Explicit uncertainty or blocked state, never approved/succeeded fallback |
| Repeated mismatch/unreadable readback | Automatic GET count and elapsed polling are bounded; hold records evidence needs; uncertainty and exclusion remain when the write may still arrive |
| Pending moderation or unreleased listing | Matching text does not satisfy a live requirement; durable lower-frequency follow-up or event wake-up remains |
| Permanent rejection followed by correction | Explicit safe reopen, edit and fresh approval reuse the same action ID; old execution/approval stay immutable; partial successes are not replayed |
| Operator-provided evidence | Unsupported assertion cannot prove non-application; exact validated evidence and attribution are preserved; unresolved requests cannot be cleared by a UI override |
| Incomplete dynamic plan | Bounded transition to an actionable hold; no fabricated completion; release only after every issued effect is conclusively closed |
| App Clip reserve transaction lost | Exact reservation is reconstructed without requiring the lost receipt, or remains explicitly unresolved; no guessed ownership, chunks or second reserve |
| Late App Clip acknowledgement | Evidence is retained; only a fresh claim can validate/adopt the concrete remaining plan; stale worker cannot append it |
| Provider-defined conflict scopes | Independent operations can progress only where proven safe; same review/overlapping listing/App Clip operations serialize; Play edits stay application-wide |
| Provider error classes and cooldown | Authentication, permission, invalid content, conflict and cooldown follow distinct evidence-based policies; local waits do not burn write budgets |
| Text normalization | Trim/CRLF/NFC equivalents match under a recorded comparison version; meaningful differences and unreadable fields do not |
| Play inspection flow | Commit and inspection are separate; readback precedes cleanup; public-live claims require separate evidence |
| New review arrives during approved batch | New work does not join old selection; parent identity remains |
| Ten localization children partially complete | Stable membership, truthful partial progress, fresh approval for generated content |
| Existing locale/source changes | Reprepare/reapprove or record external handling with complete evidence |
| Provider account/connector changes | Exact account binding retained; canonical resource fence cannot be bypassed |
| Migration replay | Same stable IDs and aliases; all historic receipts/links preserved; incompatible records become explicit blockers |
| Legacy queued job after cutover | Wake existing authorized execution only; otherwise durable migration refusal |
| Verification-to-measurement crash | Exactly one attributable handoff; no false measurement start |
| Full product routes | Web, API, chat, MCP, policies and notifications use the same commands and evidence |
| List/count/read | Shared predicates, unbounded traversal through pagination, personal read cannot change lifecycle |

## 10. Cleanup sequence

1. Finalize the corrected recovery/reopening, conflict-domain, evidence, field/routing/billing and retention contracts before resuming implementation. Keep current schema diagrams labeled as the paused draft until revised concrete fields and constraints are approved.
2. Complete provider recipe/readback parity, bounded recovery and measurement handoff, with the acceptance gates above and reproducible retained evidence.
3. Rehearse migrations on an isolated copy; reconcile identities, links, receipt provenance and unresolved executions.
4. Stop admitting old-format work at every producer.
5. Convert or explicitly block queued old jobs without inventing approval.
6. Verify the old direct-write census is empty for supported capabilities.
7. Replace obsolete inline-write tests with durable end-to-end regression coverage, run required repository checks, and prepare the PR.
8. Plan a separately authorized rollout with migration evidence, recovery observability and rollback constraints.

Compatibility during a bounded migration is not the target architecture. The final application must have one Actions authority, typed provider leaves, the existing domain measurement records, and the existing queue transport. Retired pending-action overlays, browser approval timers, reconstructed batch identities, and duplicate direct writers must be removed once their data has been accounted for.

## Source reference

The inspected baseline is [fload-ai/fload-platform at f0b1af5fc](https://github.com/fload-ai/fload-platform/tree/f0b1af5fc5925d818be7d9b02b42b1fc54556ecc). New prototype source names above refer to uncommitted work and are listed for reviewability; they are not claims that those files exist on the baseline or have been merged.
