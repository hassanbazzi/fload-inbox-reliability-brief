# FLO-1355 — ownership design v4: explicit ownership and compatible recovery

18 September 2026 · Corrected documentation draft · Implementation paused

This draft applies N1–N4 from the ownership-design-v3 review. It supersedes ownership draft v3; published v15 remains the behavioural baseline where this draft explicitly carries its rules. This is a documentation proposal, not a description of shipped behaviour or complete executable DDL. R2/R3, full schema/type generation and implementation proof remain outstanding. Platform implementation remains paused.

The [v3 review resolution](Fload-Inbox-Ownership-v3-Review-Resolution.md) records the disposition and required verification. See the [visual comparison](ownership-overview.html) and [v15 behavioural baseline](Fload-Inbox-Revised-Design-v15.md). The new visual comparison distinguishes the originally audited inbox, the earlier v15 proposal and this ownership design. The preserved prototype is a frozen audit baseline, not a fresh claim about production. No platform code, migrations or provider calls are changed by this documentation pass.

---

## 1. Disposition

| Finding | Disposition | Resolved in |
|---|---|---|
| O1 · observed values and review identities lost | Accepted. v1 kept proposals and dropped observed field values, ads amounts and the review response identity. Every revision purpose now has a value snapshot; provider leaves carry `purpose` so proposal, baseline and observation rows share storage under purpose-dependent CHECKs. | §3.3, §3.4, §5.2 |
| O2 · composite FK by provider is not expressible | Accepted. One composition-owned catalogue `composition.operation_contract` is the single FK target; provider recipes register in code against it; the step pins its surface and timing; finalization dispatches on the full closed shape. Receipt requirement becomes an outcome matrix, not a boolean. | §3.1, §3.2, §5.1, §5.3 |
| O3 · trusted-writer claim overstated | Accepted. The model is a trusted application writer: one transaction adapter, pure Core policy, least-privilege runtime role with DML, database structure and concurrency constraints independent of code. No SELECT+EXECUTE claim. | §4 |
| O4 · guards must be global | Accepted. `action_resource_guard` and `composition.operation_contract` are the two explicit global exceptions to tenant qualification; the guard's identity is `(provider, resource_key)` with a tenant-qualified holder and a key-continuity rule. | §3.2, §5.4 |
| O5 · cycle durability undefined | Accepted. Cycles are opened by commands with immutable identity, scope, policy pin, time anchor, trigger and predecessor; one active cycle per exact obligation is a uniqueness invariant; replacement closes future admissions only. | §3.2, §5.5 |
| O6 · settlement membership weakened | Accepted. Pairs reference the batch directly; the batch owns identity, amount and time; the credit-log row is a one-to-one equality-checked projection; the new transaction never uses the audit wrapper. | §3.5, §5.6 |
| O7 · attribution and manual observation changed silently | Accepted. `matched_external`, `handled_externally` and `manual_observation` are retained by default exactly as v15 defines them. The v1 proposal is recorded as a future product decision, not part of this design. | §3.2, §6 |
| Proportionality | Accepted. No relation exists to follow a template: provider recipes have no table; `purpose` reuse avoids proposal/observation table pairs; `captured_at` has one authority per revision. | throughout |

Withdrawals from v1 that stand: public-store Play verification, the shared alert table, any length target.

Carried v3 corrections: filter cycle indexes to accepted cycle-opening commands and define nullable scope fields; renew replacement windows at accepted command time; retain all purpose-specific value states and scope-relative evidence completeness; restore mandatory nonterminal inspection receipts; allow compatible mixed-version operation catalogs; require a quiesced resource-key cutover; freeze billing/reporting timestamps to the same settlement instant. These change no provider-ownership boundary and introduce no additional relation.

V4 corrections: initial binding/prewrite windows open at the first eligible inspection admission; workers filter contract support before claiming; compatible workers recover directly from SQL under the existing leased worker lifecycle; `open_recovery` is a targetless execution-scoped command; the redundant catalogue `receipt_policy` column is removed. §5.7 defines mixed-build recovery. No worker-heartbeat SQL table is added.

---

## 2. Boundaries

Unchanged from v1 and the decision: one database, one modular monolith; schemas are namespaces, ownership is enforced by grants, foreign keys and import rules. Core (`packages/core/src/actions`) imports only its own types and neutral ports; domain and provider modules register through composition at startup.

Two relations are deliberately global, not tenant-qualified: the operation catalogue (definitions) and the resource guard (identity). Everything else carries `organization_id` in its key and FKs.

---

## 3. Revised schema

Every tenant-owned relation has `organization_id` with a composite FK; it is omitted below. "Closed" means a PostgreSQL enum mirrored by a Zod union and a Core type generated from one source. `purpose` is the revision's `proposal | baseline | observation`, carried redundantly into leaves via FK `(organization_id, revision_id, purpose) → action_revision(organization_id, id, purpose)` so that purpose-dependent CHECKs stay within one row.

### 3.1 Composition catalogue (global)

| Relation | Columns | Constraints |
|---|---|---|
| `composition.operation_contract` | `id` text PK (stable, e.g. `asc.version_localization_upsert@2`), `provider` (closed: `app_store_connect`, `google_play`, `apple_search_ads`, `internal`), `operation_key`, `contract_version` int, `default_required_surface`, `default_verification_timing`, `terminal_on_acknowledgement` bool, `resource_scope_kind` (closed: `store_application`, `advertising_account`, `none`), `max_observations`, `observation_window_ms`, `backoff_initial_ms`, `backoff_max_ms`, `backoff_factor`, `registered_at` | `UNIQUE (provider, operation_key, contract_version)`; rows immutable; internal generation and readback-only contracts are registered like any other |

Provider recipes (request encoding, decoding, readback, resource key, decisive-read timing) live in code. Startup validates that this build has no duplicate recipes, that every recipe it advertises has an identical immutable catalog contract, and that the process has its required baseline contracts. A missing or incompatible definition for an advertised recipe fails readiness. Extra catalog rows for older/newer builds do not fail startup. Catalog identity/version agreement includes the neutral policy definition, not just the key.

Dispatch admits only obligations supported by the running worker, before any claim or workflow mutation. The scan filters before pagination and admission rechecks the actual required contract under locks, including unfinished attempts and recovery (§5.7). An unsupported delivery is a no-op: no provider I/O, claim-generation change, hold, attention, cycle opening or self-reenqueue. There is no recipe fallback.

Missing worker coverage is an operational availability problem. The obligation stays due and appears in operational due-age and recovery-health monitoring; it does not become customer `needs_decision`. This replaces v3's proposed `unsupported_contract` customer hold. A compatible worker resumes ordinary admission without a user Re-check or approval change. No lease absence or transient heartbeat failure proves that no compatible worker exists.
Activation order: add immutable contract rows, roll out compatible recipes while retaining versions needed by active work, verify worker coverage, then enable producers of the new contract. Test old workers restarting after the additive migration and rollback with new-version work still present. Initial cutover must drain or fence pre-gate worker binaries; a new eligibility rule cannot constrain an already-running old implementation. This is compatibility across builds, not a requirement that every historical row be executable by every binary.

### 3.2 Actions (workflow)

| Relation | Columns | Notes |
|---|---|---|
| `action`, `action_revision`, `action_membership`, `action_dependency`, `action_read`, `action_approval`, `action_policy_revision`, `action_alias`, `action_revision_source` | as v1 | `action_revision` adds `UNIQUE (organization_id, id, purpose)` as the leaf FK target. `authorization_version` removed as in v8. |
| `action_command` | identity and actor columns as today; `kind` closed and extended with `reopen`, `open_recovery`, `resume_hold`, `schedule`, `unschedule`, `abandon`; progress columns as v15 (`progress_execution_id`, `progress_phase`, `progress_result`, `progress_hold_reason`, `progress_exhaustion_reason`, `progress_step_id`, `progress_subject_attempt_id`); cycle columns: `cycle_purpose` (closed: `binding`, `prewrite`, `readback`, `cleanup`), `cycle_planned_step_id`, `cycle_predecessor_command_id`, `cycle_contract_id` FK → `composition.operation_contract`, `cycle_anchor_at`, `cycle_decisive_after_at`; event columns `resume_event_kind`, `resume_provider_resource_version`, `resume_schedule_command_id` | Accepted cycle openers have the purpose-specific required/nullable/forbidden matrix in §5.5. Ordinary and refused commands carry no authoritative cycle facts. Initial predecessor and untimed decisive-after values are NULL; there is no all-columns-non-NULL rule. |
| `action_command_target` | as v15 | Accepted `open_recovery` is the explicit targetless system-command exception (§5.5); it never updates the ticket head. Other accepted ticket mutations retain their required targets. |
| `action_execution` | as v1 | `result` keeps `handled_externally` (O7). |
| `action_execution_step` | `id`, `execution_id`, `ordinal`, `operation_contract_id` FK → `composition.operation_contract(id)` NOT NULL, `required_surface`, `verification_timing`, `recovery_policy_version`, `input_step_id`, `content_revision_id`, `native_idempotency_key` | The 26-value step-kind enum is retired. `required_surface` and `verification_timing` are pinned at planning and authoritative thereafter; the catalogue defaults cannot override an accepted step. Immutable after insert. |
| `action_execution_attempt` | identity, claim and fence columns as today; `kind` (closed: `write`, `readback`, `inspection`, `generation`, `manual_observation`, `late_evidence`, `conflicting_completion`); `result` (closed as v15 incl. `matched_external`); `non_application_basis` (closed: `provider_rejection`, `pre_dispatch_failure`, `provider_proved_non_application`); `retry_disposition`; `uncertainty_reason`; `unreadable_reason` (closed as v15); `terminal_outcome`, `semantic_fingerprint`, `fingerprint_version`; observation link columns; `subject_attempt_id`, `input_attempt_id`; `inspection_purpose`, `planned_write_step_id`, `prewrite_attempt_id`, `resource_guard_generation`; `cycle_command_id` FK → `action_command` (replaces `grant_kind`/`grant_command_id`); `evidence_command_id`; output columns | No receipt columns. `conflicting_completion` is the R2 direction: non-authoritative, excluded from every selector, matrix still owed (§6). |
| `action_resource_guard` (**global**) | `id`, `provider` (closed), `resource_key` text, `key_version` int, `holder_organization_id`, `holder_execution_id`, `acquired_at`, `acquisition_generation` | `UNIQUE (provider, resource_key)`; `(holder_organization_id, holder_execution_id)` FK → `action_execution`; no organization on the identity. Replaces `scope`, `provider_account_id`, `remote_application_id` and the provider-shaped CHECK. |

### 3.3 Domain content (values for every purpose)

Each domain has one content relation whose rows exist for proposal, baseline and observation revisions, with purpose-dependent required/forbidden columns. Storage retains the existing closed `content_value_state` union: `unspecified`, `present`, `empty`, `dismissed`, `unreadable`. Proposal fields permit `unspecified`, `present`, `empty`, and `dismissed`; baseline/observation fields permit `unspecified`, `present`, `empty`, and `unreadable`. `present` carries the exact nonempty value; `dismissed` preserves its existing text payload and is not a write effect; other states follow the existing no-value rules. Resource availability and per-field unreadability are separate facts. Do not collapse an unreadable field, an empty value, an unspecified field and a dismissed proposal. Observed values are never reconstructed from a proposal.

| Relation | Columns | Purpose rules |
|---|---|---|
| `review_work.reply_content` | `revision_id`, `purpose`, `store`, `provider_app_id`, `provider_review_id`, `intent`, `reply_text`, `original_ai_revision_id`, `detected_language_name`, review snapshot (`review_rating`, `review_title`, `review_body`, `review_nickname`, `review_storefront`, `review_app_version`, `review_modified_at`, `review_edited`), `response_availability`, `response_text`, `response_modified_at`, `response_hidden`, `publication_state` (closed domain enum as today), `captured_at` | proposal: `intent`, `reply_text` required; response columns forbidden. baseline/observation: `intent` forbidden; `response_availability`, `captured_at` required; response text/state required when present. Review identity columns required for every purpose; `reviewWorkCreationKey` derives from them. |
| `listing_work.listing_content` | `revision_id`, `purpose`, `store`, `locale`, `intent`, shared fields with state columns (`title`, `description`, `support_url`), `operator_instructions`, `source_fingerprint`, `naturalness_check_skipped`, `fidelity_check_skipped`, `english_title`, `english_promotional_text`, `gloss_status`, `availability`, `captured_at`, `source_capture_at`, `version_state` (closed domain enum as today) | proposal: `intent` required, observation columns forbidden. baseline/observation: `availability`, `captured_at` required; field values carry what the provider returned, including explicit absent. |
| `listing_work.listing_research` | as v1 | proposal only |
| `listing_work.media`, `listing_work.content_term` | as prototype minus provider upload columns | |
| `ads_work.ads_content` | `revision_id`, `purpose`, `intent`, `keyword_text`, `match_type`, `daily_budget_amount`, `bid_amount`, `currency_code`, `observed_status` (closed neutral: `enabled`, `active`, `paused`, `deleted`), `availability`, `captured_at` | proposal: intent-dependent required amounts/keyword; observation: observed amounts, currency, keyword text, match type and status as returned (`apple-ads.ts:368–388` compares exactly these). |
| `agent_work.request`, `agent_work.advisory`, `agent_work.request_country`, `agent_work.request_competitor`, `agent_work.content_note` | v15 matrices; repeated facts keep the request owner and FK grain | |

`captured_at` has exactly one authority: the domain content row of the observation revision. Provider leaves carry none.

### 3.4 Provider schemas

Leaves carry `purpose` and reference the revision; receipts and evidence reference the attempt. Provider recipes have no table.

| Relation | Columns | Purpose rules |
|---|---|---|
| `app_store_connect.listing_target` | `revision_id`, `purpose`, `provider_account_id`, `provider_app_id`, `app_info_id`, `app_info_localization_id`, `app_version_id`, `app_version_localization_id`, `live_promotional_version_id`, `live_promotional_localization_id`, `release_selection` (closed), App Clip columns as the prototype's `listing_contract`, `app_store_state` (native closed), `observed_localization_id` | proposal: `release_selection` required and pinned by the approval through the revision; `next_editable_release` requires NULL version ids and a baseline. observation: native state required only when that observation actually establishes the state of an exact version; absent/unreadable and other-scope observations must not invent one. |
| `app_store_connect.listing_fields` | `revision_id`, `purpose`, `subtitle`, `keywords`, `promotional_text`, `whats_new`, `live_promotional_text`, each with its state column | every purpose; observation rows hold observed values. UTF-16 limits enforced here. |
| `app_store_connect.review_target` | `revision_id`, `purpose`, `provider_account_id`, `review_resource_id`, `response_id`, `native_state` (closed: `PUBLISHED`, `PENDING_PUBLISH`, `PENDING`, `NONE`) | proposal: `response_id` required when `intent='update'` (the update PUT needs it, `reviews-native.ts:97–108`). baseline/observation: `response_id` required when a response is present. |
| `app_store_connect.step_contract`, `app_store_connect.media_upload` | as v1 | |
| `app_store_connect.attempt_receipt` | `attempt_id` PK, `transport` (`asc_api`, `asc_browser`), `response_status`, `provider_request_id`, `provider_resource_id`, `localization_id`, `media_id`, `version_id`, `error_code` | matrix in §5.3 |
| `app_store_connect.attempt_evidence` | `attempt_id` PK, `evidence_kind` (closed), typed columns per kind: `correlated_request_id` for `terminal_correlation`; `bound_version_id`, `bound_localization_id`, `native_version_state` for `editable_release_bound`; `collection_complete` bool and `page_count` for `no_editable_release`; `live_version_id` for `version_live`; `response_id`, `native_state` for `response_published` | exhaustive kind/column matrix; unlisted columns NULL |
| `google_play.listing_target` | `revision_id`, `purpose`, `provider_account_id`, `package_name`, `play_commit_policy`, `edit_id` | proposal: `package_name`, `play_commit_policy` required, `edit_id` forbidden. observation: `edit_id` required when the declared observation is scoped to an exact edit; other preserved observation sources must not invent one. This does not introduce public-store verification. |
| `google_play.listing_fields` | `revision_id`, `purpose`, `short_description` with state | every purpose |
| `google_play.review_target` | `revision_id`, `purpose`, `provider_account_id` | Play exposes no response id; none is invented. |
| `google_play.attempt_receipt` | `attempt_id` PK, `transport` (`play_api`, `play_session`, `play_browser`), `response_status`, `provider_request_id`, `provider_resource_id`, `edit_id`, `edit_expires_at`, `error_code` | matrix in §5.3 |
| `google_play.attempt_evidence` | `attempt_id` PK, `evidence_kind` (closed: `expired_uncommitted_edit`, `inspection_edit_present`, `inspection_edit_unusable`, `delete_acknowledged`), `edit_id`, `edit_expires_at`, `returned_expiry`, `native_reason` (closed set pinned per decoder version), `observed_at` | `expired_uncommitted_edit` requires `edit_id`, `edit_expires_at`, `observed_at`; `inspection_edit_unusable` requires `native_reason`; Core sees only `provider_proved_non_application` or `terminal_outcome` |
| `apple_search_ads.target` | `revision_id`, `purpose`, `provider_account_id`, `campaign_id`, `ad_group_id`, `keyword_id`, `negative_keyword_id`, `native_status` (closed: `ENABLED`, `ACTIVE`, `PAUSED`, `DELETED`) | observation: `native_status` required when present; domain `observed_status` is its neutral mapping |
| `apple_search_ads.attempt_receipt` | `attempt_id` PK, `transport` (`asa_api`), `response_status`, `provider_request_id`, `provider_resource_id`, `error_code` | |
| `apple_search_ads.attempt_evidence` | `attempt_id` PK, `evidence_kind` (`terminal_correlation`), `correlated_request_id` | |

Two provider-owned functions complete the boundary, both pure and versioned in code: `resource_key(target) → (key, key_version)` and `decisive_after(source_receipt) → instant | none`. The Play implementation returns the inspection-create receipt's `edit_expires_at`; it never reads a later GET.

### 3.5 Usage

| Relation | Columns | Constraints |
|---|---|---|
| `usage.llm_invocation` | as v15 | |
| `usage.settlement_batch` | `id`, `attempt_ref`, `batch_no`, `pricing_version`, `policy_version`, `settlement_key` (69 chars), `amount` int ≥ 0, `settled_at`, `credit_log_id` NOT NULL | `UNIQUE (organization_id, attempt_ref, batch_no)`; `UNIQUE (organization_id, settlement_key)`; `UNIQUE (credit_log_id)` with FK → `public.usage_credit_log(id)`; immutable. The batch is the authority for Actions settlement identity, amount and time. |
| `usage.llm_invocation_settlement` | `invocation_id`, `usage_version`, `kind` (`charged`, `waived`, `unknown`), `settlement_batch_id`, `settled_at` | PK `(invocation_id, usage_version)`; composite FK `(organization_id, settlement_batch_id)` → batch; `CHECK ((kind='unknown') = (settlement_batch_id IS NULL))`; immutable. Pairs reference the batch, never the log. |
| `usage.metering_delivery` | as v1 (`settlement_batch_id` PK/FK, `identifier` = `settlement_key`, frozen payload, seven-state machine, lease and retry columns) | mutable only through the delivery entry point under its row lock |
| `public.usage_credit_log` | no new columns | gains: an immutability trigger for rows referenced by a batch; a deferred equality check `log.amount = batch.amount AND log.organizationId = batch.organization_id AND log.createdAt = (batch.settled_at AT TIME ZONE 'UTC')`; the existing `metadata` JSONB holds no settlement, delivery or replay fact. These are migrations even though the column list is unchanged. |

The Actions settlement transaction writes batch, known pairs, the credit-log projection, the quota counter delta and, when overage exists, the delivery obligation, in one transaction under the per-tenant Usage advisory key, and never calls `recordCreditAudit` (`usage/index.ts:109–125`), whose swallowed failure is incompatible with financial atomicity.

`batch.settled_at` is the authoritative immutable `timestamptz`. The new projection's existing timestamp-without-time-zone `createdAt` stores that instant as UTC wall time explicitly; decoding it for comparison uses UTC, never the session timezone. Delivery `occurred_at` is the same instant and is checked against its batch. Native transport precision conversion is deterministic at the adapter boundary, not another mutable occurrence time. This rule applies to new Actions settlement projections; historical timestamps are not reinterpreted without a proved source conversion. Retain v15 Usage erasure/retention and global amount/rounding rules.

---

## 4. Trusted-writer model, stated accurately

Business policy — budgets and cycles, capacity and presentation, finality selection, attention deltas, effect authorization, plan expansion — is pure TypeScript in Core. One transaction adapter (the unit-of-work in `apps/api/src/services/actions`) loads and locks facts under the fixed lock order, invokes Core, and persists command, targets, results and obligations atomically before any queue notification or provider I/O.

Runtime roles are least-privilege but hold DML: the API and worker connect as a role with SELECT/INSERT/UPDATE on the Actions, domain, provider and Usage schemas, no DDL, no `BYPASSRLS`, no EXECUTE on erasure functions. Erasure and migration roles are separate. Import and write rules in code (the same shape as the repo's canonical-authorization lint) plus integration tests restrict and audit the path. The database independently enforces tenant relationships, closed structure, immutability, uniqueness, fencing and the concurrency invariants in §5. It does not prove that a writer executed Core policy; a compromised writer credential or a table owner can write wrong values. That is stated, not hidden. A SELECT+EXECUTE-only runtime is not claimed; if adopted later, its SQL entry points must re-check whatever policy they are said to enforce.

Attention is derived by the writer from prior snapshot, new snapshot and cause. The database checks only that each accepted target increments `version` by one and `attention_version` by zero or one. The v15 fixtures for first wait, silent restoration, schedule and unschedule remain the acceptance set; transaction-membership introspection is not used.

---

## 5. Contracts and invariants

### 5.1 Revision finalization by closed shape

Sealing a revision dispatches on `(domain, purpose, provider-of-target)` and requires exactly the leaves for that shape. The dispatch is a generated structural validator in the database integration layer, with provider-specific leaf checks owned by the provider.

| Shape | Required leaves | Forbidden |
|---|---|---|
| `reviews`, any purpose, `ios` | `review_work.reply_content`, `app_store_connect.review_target` | Play leaves |
| `reviews`, any purpose, `android` | `review_work.reply_content`, `google_play.review_target` | ASC leaves |
| `listing`, any purpose, `ios` | `listing_work.listing_content`, `app_store_connect.listing_target`, `app_store_connect.listing_fields`; `listing_research` only for proposals | Play leaves |
| `listing`, any purpose, `android` | `listing_work.listing_content`, `google_play.listing_target`, `google_play.listing_fields` | ASC leaves |
| `ads`, any purpose | `ads_work.ads_content`, `apple_search_ads.target` | |
| `request`, `advisory` (proposal) | `agent_work.request` or `agent_work.advisory` with their repeated facts | provider leaves |
| `collection` (proposal) | membership rows only | content leaves |

Completeness is relative to the observation's closed scope and declared surface. Listing-content verification requires readable values for every relevant approved field; an unrelated field may remain `unspecified`. Exact temporary-edit presence/absence is a complete resource observation with exact target, receipt and required native facts, while listing-copy fields remain `unspecified` because no copy was read. Such a resource observation cannot satisfy a listing-content obligation. Partial/unreadable evidence is storable with its truthful shape and cannot be promoted to `matched` for a content comparison. Native version/localization/edit identities and states are required only when the closed scope proves them; do not invent values to pass a general observation CHECK.

### 5.2 Value preservation

Proposal, baseline and observation values are independent rows. An observation of a budget of 90 against a proposal of 100 stores 90 in `ads_work.ads_content` with `purpose='observation'`; the owning domain/provider comparison validates the exact scope and two immutable snapshots, then supplies a closed result to workflow Core with their evidence identities. Core does not import native field contracts. Round-trip fixtures cover every closed content variant in `actions-content.ts`, missing-versus-empty values, connector replacement (identity columns unchanged), and editing a known response (`response_id` present on the baseline).

### 5.3 Receipt and evidence matrix

The immutable `operation_contract_id` and its version select the exact provider-owned receipt/evidence contract. There is no separate `receipt_policy` catalogue column: that would duplicate the contract's meaning and invite mismatched combinations. Each versioned contract exhaustively maps the admitted attempt kind, outcome and closed observation scope to `required | optional | forbidden` and its typed native fields. Unknown or unregistered combinations fail closed. Provider modules own those matrices and decoder fixtures; composition verifies total coverage at registration and schema generation. Core consumes neutral typed results and evidence identities, not native receipt structures. Each provider receipt table enforces its structural shape; composition owns the cross-schema exactly-one/forbidden check. This is closed typed dispatch, never an open runtime map or payload bag.

| Attempt kind and outcome | Receipt |
|---|---|
| write `acknowledged` | required; status; creation identity per contract (Play edit id, ASC localization or media id, ASA resource id) |
| write `known_not_applied` / `provider_rejection` | required; status ≥ 400 or typed error code |
| write `known_not_applied` / `pre_dispatch_failure` | forbidden |
| write `uncertain` / `invalid_response`, `accepted_pending` | required; status |
| write `uncertain` / `transport_lost`, `claim_expired` | forbidden on the original row |
| readback with `terminal_outcome=TRUE`, or `known_not_applied` | required, plus the exact provider evidence kind/correlation or expiry/quiescence proof; never infer finality from identical content or a clock |
| readback: exact Play inspection edit present | required successful GET receipt, exact edit ID and finite returned expiry; complete resource-presence observation; listing fields unspecified; terminal outcome FALSE |
| readback: exact temporary-edit quiescence | required exact edit/HTTP receipt and pinned decoder proof from a newly admitted recovery read; sealed exact absence; terminal outcome TRUE only under v15's quiescence contract |
| ASC binding/prewrite inspection `matched` | required status and exact ASC version ID, with exact localization presence/absence evidence; terminal outcome FALSE |
| binding inspection `unreadable/no_editable_release` | required successful HTTP 2xx collection-read receipt with complete pagination and exact account/app scope; native version/localization identities are not invented; terminal/fingerprint marks NULL |
| other readback/inspection branches | retain the exhaustive v15 contract-specific required/optional/forbidden matrix; optional only where that matrix permits it |
| generation, manual observation, internal | forbidden |

An inspection cannot set terminal outcome TRUE. Matched/mismatch inspections retain FALSE and their required marks; unreadable inspections retain NULL marks. Late completions follow their original interaction's contract and fence. This summary does not relax v15's evidence or receipt requirements; R2's conflicting-completion retention matrix remains separately open.

### 5.4 Global resource exclusion

Guard identity is `(provider, resource_key)` and is shared by every organization and connector that writes to the same remote resource (two organizations targeting one Play package contend on one row; the loser sees `resource_busy` without learning the holder's tenant). Keys are canonical: ASC `app:<providerAppId>`, Play `package:<packageName>`, ASA `account:<providerAccountId>`, the same native identities the prototype's unique indexes use today. `key_version` records the encoding and never participates in uniqueness. The normal release path keeps this persisted identity encoding stable.

A future encoding change requires a quiesced writer cutover, not an online rewrite justified only by an advisory lock: stop/fence every old guard resolver and acquisition path, verify that no holders or unresolved issued effects remain, lock and migrate guard identities without changing their row IDs, verify collision-free native-resource mapping, activate the one supported encoding, then restore admission only for compatible writers. If quiescence or old-writer exclusion cannot be proved, do not run the migration. Advisory locks coordinate only participating callers; a migration-only lock cannot fence ordinary workers. Test old/new workers attempting to acquire during cutover and reject old encodings after it. Tenant erasure releases an eligible holder under the existing rules and never deletes guard identity.

### 5.5 Recovery cycles

A cycle is opened by an accepted command of kind `open_recovery` (system, initial), `reconcile` (user replacement) or `resume_hold` (provider-offer replacement). Ordinary commands and refused openers never create a cycle or consume uniqueness. An initial binding/prewrite opening is created only by the transaction admitting its first eligible inspection. Before then, the execution, immutable planned step and indexed `next_run_at` retain the obligation; an unused time window has not started. After Undo, schedule, authority, resource and worker-support gates pass under the ordered locks, capture one database instant, insert the accepted `open_recovery` with that anchor, and insert its first inspection referencing the cycle at the same instant. Commit both before provider I/O. A crash before commit rolls back both; a crash after commit retains both, and the admitted start counts even if the network call never began. Never create an initial binding/prewrite cycle merely because approval or a future schedule exists. Initial readback/cleanup openings retain their original subject-finalization anchor; schedules never postpone reconciliation.

`open_recovery` is an accepted, attributable **targetless system command** scoped through the exact execution, step and obligation FKs. Its idempotent receipt returns the cycle identity. It inserts no `action_command_target`, increments neither ticket `version` nor `attention_version`, and never changes the content head. History resolves it through execution → approval → action and shows the system actor and acceptance time. The accepted-command shape matrix names this exception explicitly; it does not weaken target requirements for user mutations. Ordinary claim/progress effects in the same transaction retain their own rules and attribution.

| Fact | Required / nullable / forbidden rule |
|---|---|
| execution, step, `cycle_purpose`, `cycle_contract_id`, `cycle_anchor_at` | required for every accepted opener; pinned to the exact same-tenant obligation and immutable policy |
| `cycle_predecessor_command_id` | NULL on initial `open_recovery`; required on accepted replacements; points to the current head of the same obligation, with no branching or cycles |
| binding scope | exact binding step; original subject NULL; planned-write step NULL because binding creates the write steps later |
| prewrite scope | exact inspection step and required existing planned-write step in the same execution; original subject NULL |
| readback/cleanup scope | exact original issued-write subject belonging to the step; planned-write step NULL |
| `cycle_decisive_after_at` | nullable when the native timing port returns none; timed cleanup copies the exact immutable source-receipt expiry, never a later GET or local current time |
| non-openers and refused commands | authoritative cycle columns absent; requested inputs may be retained as non-authorizing command facts under the existing receipt model |

The initial-cycle unique index is a **partial unique index**, using `NULLS NOT DISTINCT`, over `(organization_id, progress_execution_id, progress_step_id, progress_subject_attempt_id, cycle_planned_step_id, cycle_purpose)` **only where** `kind='open_recovery' AND outcome='accepted' AND cycle_predecessor_command_id IS NULL`. The predecessor unique index covers `(organization_id, cycle_predecessor_command_id)` only where `kind IN ('reconcile','resume_hold') AND outcome='accepted' AND cycle_predecessor_command_id IS NOT NULL`. These filters exclude ordinary and refused commands. Same-obligation FK/shape validation and ordered execution locks are required in addition to uniqueness; an arbitrary predecessor ID cannot authorize another execution or subject.

Invariants:

1. One initial opening and one current chain head exist per exact obligation; each accepted replacement names that head. Command replay returns the original receipt, including when its cycle has since been superseded. Duplicate/reordered provider events obey the carried v15 exact target/version/schedule-context identity and cannot renew a cycle.
2. Original reads reference the head's `cycle_command_id` at admission under the execution lock. Opening/replacement, current head selection and indexed next due time commit together. Every admitted start counts, including failure, cancellation and claim expiry; finalization adds no second start.
3. Replacement closes the predecessor to future admissions only. It never cancels, refunds or re-fences an admitted read, and does not release its guard. The replacement waits for normal finalization/expiry under the one-unfinished-attempt rule.
4. Valid finality evidence from a predecessor cycle remains authoritative for its exact subject. Content evidence retains original ordering. A late inspection cannot append a plan under a displaced fence or reuse an old prewrite.
5. Initial readback/cleanup cycles anchor their window at the original subject's immutable `finished_at`. Initial binding/prewrite cycles anchor at their **first eligible inspection admission**, with opening and inspection inserted atomically at that one instant as specified above. Future scheduling, resource contention and unsupported workers consume neither their initial count nor their window. Every accepted replacement anchors its renewed window at **that replacement command's immutable `accepted_at`**; it does not inherit an expired original window. Accepted replacement renews the cycle-local count/window deliberately; duplicate/replayed commands do not.
6. Native expiry E remains pinned to the original inspection-create receipt. For the exact protected cleanup policy, `D = cycle_anchor_at + O`, `R = E + B`, and `H = max(D, R + G)`, with the carried exclusive deadline/backoff and one-protected-start count rules. Do not apply protected placement to unrelated operations. Copying E preserves native evidence; renewing a cycle changes D by the declared policy. Time never establishes request finality.
7. Completion/closure, authority/date gates, no-editable-release behavior and readback-result rules remain scope-specific under the carried v15 contracts, adjusted only for one active cycle replacing coexisting grants. The existence of a head alone does not prove current capacity. No new cycle may widen content approval or permit a blind mutation resend.

Required traces: two ordinary commands in one org; rejected Re-check then accepted Re-check; duplicate initial opening; concurrent replacement; approve in September for November with a full initial window in November; first-admission rollback before commit and crash after commit; contention/support/date gates without budget use; Re-check after the original window expired; same event after supersession; in-flight replacement; immutable expiry despite later GETs; earlier/later protected deadlines; stale delivery and old-cycle late evidence. These are design requirements until implemented and tested against actual DDL.

### 5.6 Settlement atomicity

Batch, pairs, projection, quota delta and delivery commit together under the per-tenant Usage advisory key, in the Actions → Usage lock order. Pairs cannot exist without a batch except as `unknown`; a batch cannot exist without its projection; no two batches share a log row; the projection cannot differ from the batch in tenant, amount or the explicitly converted settlement time; delivery occurrence is the same frozen instant. Failure to write the projection rolls back the batch. Delivery retries never consult current billing configuration; they send the frozen payload under the fixed identifier.

### 5.7 Compatible worker recovery and queue ownership

SQL owns obligations, `next_run_at`, execution claims and resource guards. BullMQ remains a low-latency wake-up hint. Redis leases coordinate background sweeps only; neither Redis nor a worker-presence registry authorizes an effect.

1. **Support before decoding and claims.** Read the minimal immutable contract/scope projection before decoding provider payloads or newer enum variants. Resolve the actual next obligation, including unfinished-attempt readback, binding, prewrite, cleanup and internal generation; checking only `next_step_id` is insufficient. Apply the build's immutable supported-contract manifest before the scan's LIMIT, then revalidate the exact contract under action → execution → guard locks before expiring attempts, incrementing claims, opening cycles or changing progress. A mismatch returns `unsupported_by_this_worker` as a process-local result and changes no workflow state.
2. **Compatible local delivery.** Add a bounded recovery service to the existing worker background lifecycle, reusing `createSingletonLease` and the non-overlapping loop pattern. Lease identity includes the canonical immutable supported-contract manifest, so an old build cannot monopolize a global recovery lease. Register it on every execution-capable worker independently of the `startSchedulers` switch. The compatible lease owner scans SQL and invokes normal execution delivery **on itself**, through the same bounded concurrency limiter as queue delivery. Do not put these recovered rows back onto a mixed-build queue where an incompatible consumer could take them again.
3. **Bounded, fair scanning.** Cap rows and wall time per pass; use a stable keyset cursor across passes and a finite captured due frontier, then wrap fairly. Apply support eligibility before pagination. Keep the typed operational cursor in the existing Redis lease namespace if needed to preserve progress across lease-owner turnover. Losing it restarts a scan, never loses SQL obligations or grants new authority. No claim that bounded rediscovery holds during continual infrastructure resets or exhausted capacity; those are measured operational failures. Replace the prototype's unbounded global `recover → enqueue every due row` loop, rather than leave it generating unsupported redeliveries.
4. **Lifecycle and failure.** Lease loss/drain stops new sweep admissions; already-admitted attempts follow their normal fencing and evidence rules. SQL locks, attempt fencing and resource guards remain the safety boundary even if two sweeps overlap. Unsupported/stale queue deliveries finish without self-reenqueue. Missing queue schedules and lost hints are recovered by the worker loop. Redis interruption or absent compatible capacity leaves due obligations durable, with operational alarms on oldest due age and failed sweeps, never customer unread churn or fabricated provider failure.
5. **Acceptance proof.** Mixed old/new workers; support-filtering beyond a page of unsupported rows; unknown contract before strict decoding; missing queue repeatable; owner drain; Redis interruption; sustained page backlog and bounded healthy-capacity rediscovery; expired claim after an uncertain write. Assert no unsupported claim, hold, budget renewal, guard release or resend. The existing rediscovery/recovery targets remain targets until measured under representative load.

No additional SQL heartbeat/capability table is proposed. A live-worker lease is not proof of execution capability or lack of it. The deployment manifest and operational health expose coverage; the support gate and compatible local sweep provide execution correctness and recovery. The current prototype does not implement this mechanism yet.

---

## 6. Kept visible, not resolved

- **Contradictory completion (R2).** `conflicting_completion` is in the closed kind list, non-authoritative, excluded from every selector, and owns its own receipt and evidence rows. The scalar, manifest and generated-output retention matrix is still owed; R2 is not closed.
- **Historical evidence (R3).** The `history` schema skeleton from v1 stands (`imported_evidence` envelope with separate content, approval and membership proof states; `imported_execution_claim` mapping `capability_execution` field for field; `imported_native_receipt` with provider-partial target variants). Per-source field matrices are still owed; R3 is not closed.
- **Attribution.** `matched_external` and `handled_externally` keep v15's definitions and predicates. Removing them would require the transition the assessment specifies (final-and-non-applied request plus satisfying authoritative observation settles without resend); that is a future product decision and is not part of this design.
- **Manual observation.** Retained as v15 defines it: manager-attributed, `terminal_outcome` NULL, never native finality.
- **Decided earlier and carried:** R4 refusal of erasure across a surviving command; R8 current-membership display ownership with flat packages and atomic head adoption.

---

## 7. Behaviour changes

1. Storage relocation to provider and domain owners, catalogue-referenced steps and opaque guard keys: no behaviour change.
2. One active recovery cycle per obligation: a Re-check or applicable offer supersedes the current cycle for future admissions while an in-flight read completes normally. Declared change from v15's coexisting grants.
3. Play non-application proof and metering delivery move owner: no behaviour change.
4. Attention derived by the writer without transaction introspection: no user-visible change.
5. Attribution and manual observation: no change (O7).
6. First eligible initial inspection starts binding/prewrite capacity: restores the carried v15 scheduling guarantee; no idle-time exhaustion.
7. Unsupported build coverage is operational, not a customer hold: removes v3's artificial attention transition. No change to content authorization or provider outcome semantics.
8. Targetless `open_recovery` records system history without changing ticket versions. Receipt requirements are selected by the existing immutable operation contract, without a duplicate policy selector.

---

## 8. Representative traces

- **Approve, wait, bind, write, verify.** Seal proposal R1 (`listing_work.listing_content` + ASC target with `release_selection=next_editable_release` + ASC fields); approve pins R1. Step S1 references `asc.editable_release_bind@2`; when due after Undo, first admission atomically creates initial `open_recovery` cycle C0 and I1; I1 returns `no_editable_release` with ASC evidence `collection_complete=true`; hold `awaiting_release`. Offer arrives → `resume_hold` C1 with predecessor C0; I2 matched → ASC evidence `editable_release_bound`; static steps appended; prewrite, write W1 with `app_store_connect.attempt_receipt`; readback matched at `live_listing` with observation revision holding observed ASC field values; settle `verified_live`.
- **Lost cleanup DELETE.** W5 uncertain; `open_recovery` cycle with `cycle_decisive_after_at` = the inspection-create receipt's `edit_expires_at`; reads return `inspection_edit_present` evidence as complete mismatch until the protected read after expiry returns `inspection_edit_unusable`; readback matched with `terminal_outcome=TRUE`; cleanup resolved; hold restored; guard released.
- **Re-check during a live cycle.** User `reconcile` C2 names predecessor C1 while read R3 under C1 is in flight; C2 commits (index 2 permits one successor); R3 finalizes under its claim; its evidence counts; the next admission requires `cycle_command_id = C2`.
- **Two organizations, one app.** Org A holds `(google_play, package:com.x)`; Org B's execution enters `resource_busy` with no holder detail; A's settlement releases the guard; B acquires at the next generation.
- **Key-format upgrade with an outstanding uncertain write.** Cutover refuses while any holder/unresolved effect exists. A migration-only advisory lock is insufficient. After safe resolution, all old resolvers/acquirers are quiesced before identity conversion, and only compatible writers resume.
- **Late Re-check.** Original readback window has expired; an accepted replacement anchors at its own acceptance and has fresh bounded capacity. Native edit expiry remains unchanged. A replay returns the same replacement without another renewal.
- **Ordinary commands.** Two accepted ordinary commands in one org do not enter either cycle index and both can commit under their own normal identities.
- **Scheduled first inspection.** Approval on 1 September schedules work for 1 November. No initial binding/prewrite cycle exists before eligibility. On 1 November, one transaction records opening C0 and first inspection I1 with the same instant and a full window. Before-commit crash preserves the original due obligation; after-commit crash preserves C0/I1 and counts the admitted start.
- **Mixed-version rollout.** A new contract row exists before all workers support it. An old worker consumes its queue hint and makes no workflow mutation. The compatible manifest's leased sweep selects the due row before its page limit and runs delivery locally. No unsupported hold, unread change or recipe fallback occurs; an unknown provider payload is not decoded by the old worker.
- **Settlement with projection failure.** Batch and pairs inserted; `usage_credit_log` insert fails; the transaction rolls back; no quota delta, no delivery row. A month-boundary fixture in non-UTC database sessions proves projection and delivery both use the batch's original settlement instant.
- **Sealing with a missing leaf.** An iOS listing proposal without `app_store_connect.listing_fields` fails the shape validator with `incomplete_revision`.

---

## 9. Relation inventory, for orientation

`composition` 1 · `actions` 15 · `review_work` 1 · `listing_work` 4 · `ads_work` 1 · `agent_work` 5 · `app_store_connect` 7 · `google_play` 5 · `apple_search_ads` 3 · `usage` 4 new plus the unchanged credit log · `history` 3 (unresolved). Counts follow from ownership; none exists to follow a template.

Implementation remains paused. This is the corrected ownership draft for review; complete DDL, R2/R3 matrices and application/migration/concurrency proof remain outstanding. No platform change is authorized by this document alone.
