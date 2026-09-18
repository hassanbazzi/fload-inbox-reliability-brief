# FLO-1355 — current source field inventory

18 September 2026 · Source declarations only · Destination mapping unfinished

Pinned source: `e2cc156994855e401a83399fbb4c3d7be5194875`, `packages/database/src/schema.ts`. Read-only TypeScript AST census: **12 named tables, 212 declared columns, 23 JSONB columns**. No customer rows or live database were read.

This is an exact field checklist for the twelve sources named in the first R2/R3 proposal. It is not the complete dependency graph or destination DDL. Every field still needs an explicit typed destination, retained-domain reference, reviewed retirement or unresolved disposition before cutover. A listed TypeScript enum hint does not prove a database CHECK exists. Table-level constraints and nested payload variants require separate inspection.

[Corrected R2/R3 rules](Fload-Inbox-R2-R3-Schema-Design-v2.md) · [Visual architecture](ownership-overview.html)

| Source | Columns | JSONB columns |
|---|---:|---|
| `review_draft_reply` | 17 | None |
| `review_draft_rejection` | 11 | `draft_snapshot` |
| `review_history` | 13 | `developer_response`, `draft_reply` |
| `aso_recommendation` | 14 | `evidence`, `proposal` |
| `aso_recommendation_variant` | 13 | `proposal` |
| `pending_action` | 33 | `params`, `beforeState`, `afterState`, `checkBackResult` |
| `inbox_recovery_run` | 6 | `manifest` |
| `agent_request` | 30 | `evidence`, `proposedOutcome`, `whatWillHappen`, `approvalPolicy`, `blockerContext`, `unblockGuide`, `recommendationIds` |
| `agent_request_event` | 8 | `data` |
| `inbox_item_state` | 10 | None |
| `opportunity_backlog` | 42 | `work_params`, `work_preview`, `work_preflight_receipt`, `evidence_refs` |
| `capability_execution` | 15 | None |

## review_draft_reply

Declared at `packages/database/src/schema.ts:1209`.

| SQL column | SQL type | Nullable | Declared reference / enum hint |
|---|---|---|---|
| `id` | `text` | No | Primary key |
| `review_id` | `text` | No | FK: () => review.id, { onDelete: 'cascade' } |
| `asset_id` | `text` | No | FK: () => asset.id, { onDelete: 'cascade' } |
| `reply` | `text` | No | — |
| `original_ai_reply` | `text` | Yes | — |
| `model` | `text` | Yes | — |
| `language` | `text` | Yes | — |
| `prompt_tokens` | `integer` | Yes | — |
| `completion_tokens` | `integer` | Yes | — |
| `total_tokens` | `integer` | Yes | — |
| `pending_send_at` | `timestamp with time zone` | Yes | — |
| `sent_at` | `timestamp with time zone` | Yes | — |
| `send_attempts` | `integer` | No | — |
| `last_send_error` | `text` | Yes | — |
| `readback_scheduled_at` | `timestamp with time zone` | Yes | — |
| `created_at` | `timestamp with time zone` | No | — |
| `updated_at` | `timestamp with time zone` | No | — |

Concrete mapping gaps found in the first draft:

- review_id and asset_id omitted from delivery claim; identity cannot rely on optional action link.

## review_draft_rejection

Declared at `packages/database/src/schema.ts:1311`.

| SQL column | SQL type | Nullable | Declared reference / enum hint |
|---|---|---|---|
| `id` | `text` | No | Primary key |
| `organization_id` | `text` | No | FK: () => organization.id, { onDelete: 'cascade' } |
| `asset_id` | `text` | No | FK: () => asset.id, { onDelete: 'cascade' } |
| `review_id` | `text` | No | FK: () => review.id, { onDelete: 'cascade' } |
| `rejected_by` | `text` | Yes | FK: () => user.id, {       onDelete: 'set null',     } |
| `source_draft_id` | `text` | No | — |
| `fingerprint_version` | `integer` | No | — |
| `review_fingerprint` | `text` | No | — |
| `draft_snapshot` | `jsonb` | No | — |
| `reason` | `text` | Yes | — |
| `created_at` | `timestamp with time zone` | No | — |

Concrete mapping gaps found in the first draft:

- draft_snapshot is ReviewDraftSnapshot (schema.ts1293–1306); destination retains reply only, proposes nonexistent snapshot_source, omits remaining eleven facts.
- asset_id has no history destination.

## review_history

Declared at `packages/database/src/schema.ts:1357`.

| SQL column | SQL type | Nullable | Declared reference / enum hint |
|---|---|---|---|
| `id` | `text` | No | Primary key |
| `review_id` | `text` | No | FK: () => review.id, { onDelete: 'cascade' } |
| `rating` | `integer` | No | — |
| `title` | `text` | No | — |
| `body` | `text` | No | — |
| `nickname` | `text` | No | — |
| `store_front` | `text` | Yes | — |
| `app_version_string` | `text` | Yes | — |
| `last_modified` | `timestamp without time zone` | No | — |
| `edited` | `boolean` | No | — |
| `developer_response` | `jsonb` | Yes | — |
| `draft_reply` | `jsonb` | Yes | — |
| `captured_at` | `timestamp without time zone` | No | — |

Concrete mapping gaps found in the first draft:

- Tenant and asset derive through review ownership; historical response does not contain provider account/publication facts needed for a present authoritative observation.

## aso_recommendation

Declared at `packages/database/src/schema.ts:3955`.

| SQL column | SQL type | Nullable | Declared reference / enum hint |
|---|---|---|---|
| `id` | `text` | No | Primary key |
| `assetId` | `text` | No | FK: () => asset.id, { onDelete: 'cascade' } |
| `store` | `text` | No | TS enum: ios, android |
| `locale` | `text` | Yes | — |
| `type` | `text` | No | TS enum: keywords, promotional_text, description, screenshots, icon, app_previews, title_subtitle, cpp, short_description, title, locale_expansion |
| `riskLevel` | `text` | No | TS enum: low, medium, high |
| `evidence` | `jsonb` | No | — |
| `proposal` | `jsonb` | Yes | — |
| `status` | `text` | No | TS enum: draft, partially_approved, approved, partially_applied, applied, rejected, failed, expired |
| `createdBy` | `text` | Yes | FK: () => user.id, {       onDelete: 'set null',     } |
| `approvedBy` | `text` | Yes | FK: () => user.id, {       onDelete: 'set null',     } |
| `appliedAt` | `timestamp without time zone` | Yes | — |
| `createdAt` | `timestamp without time zone` | No | — |
| `updatedAt` | `timestamp without time zone` | No | — |

Concrete mapping gaps found in the first draft:

- test_plan does not exist on this source; actual test_plan belongs to aso_experiment.
- All statuses cannot become open work merely because proposal decodes.

## aso_recommendation_variant

Declared at `packages/database/src/schema.ts:4015`.

| SQL column | SQL type | Nullable | Declared reference / enum hint |
|---|---|---|---|
| `id` | `text` | No | Primary key |
| `recommendationId` | `text` | No | FK: () => asoRecommendation.id, { onDelete: 'cascade' } |
| `locale` | `text` | No | — |
| `proposal` | `jsonb` | No | — |
| `status` | `text` | No | TS enum: draft, approved, rejected, applied, failed, expired |
| `supersededByVariantId` | `text` | Yes | FK: (): AnyPgColumn => asoRecommendationVariant.id, { onDelete: 'set null' } |
| `approvedBy` | `text` | Yes | FK: () => user.id, {       onDelete: 'set null',     } |
| `approvedAt` | `timestamp without time zone` | Yes | — |
| `appliedBy` | `text` | Yes | FK: () => user.id, {       onDelete: 'set null',     } |
| `appliedAt` | `timestamp without time zone` | Yes | — |
| `lastError` | `text` | Yes | — |
| `createdAt` | `timestamp without time zone` | No | — |
| `updatedAt` | `timestamp without time zone` | No | — |

Concrete mapping gaps found in the first draft:

- recommendationId and approvedAt omitted.
- No test_plan column; asset/store/type derive through parent rather than existing on variant.

## pending_action

Declared at `packages/database/src/schema.ts:4677`.

| SQL column | SQL type | Nullable | Declared reference / enum hint |
|---|---|---|---|
| `id` | `text` | No | Primary key |
| `organizationId` | `text` | No | FK: () => organization.id, { onDelete: 'cascade' } |
| `orchestratorRunId` | `text` | No | FK: () => agentRun.id, { onDelete: 'cascade' } |
| `assetId` | `text` | Yes | FK: () => asset.id, {       onDelete: 'cascade',     } |
| `agentType` | `text` | No | — |
| `action` | `text` | No | — |
| `params` | `jsonb` | No | — |
| `reason` | `text` | No | — |
| `priority` | `text` | No | — |
| `mode` | `text` | No | — |
| `status` | `text` | No | — |
| `approvedBy` | `text` | Yes | FK: () => user.id |
| `approvedAt` | `timestamp without time zone` | Yes | — |
| `rejectedBy` | `text` | Yes | FK: () => user.id |
| `rejectedAt` | `timestamp without time zone` | Yes | — |
| `rejectedReason` | `text` | Yes | — |
| `deletedAt` | `timestamp with time zone` | Yes | — |
| `deletedBy` | `text` | Yes | FK: () => user.id, {       onDelete: 'set null',     } |
| `failureReason` | `text` | Yes | — |
| `supersededByPendingActionId` | `text` | Yes | — |
| `sourceAgentRunId` | `text` | Yes | — |
| `sourceRecommendationIndex` | `integer` | Yes | — |
| `executedAt` | `timestamp without time zone` | Yes | — |
| `resultRunId` | `text` | Yes | FK: () => agentRun.id |
| `completedAt` | `timestamp without time zone` | Yes | — |
| `beforeState` | `jsonb` | Yes | — |
| `afterState` | `jsonb` | Yes | — |
| `experimentId` | `text` | Yes | FK: () => asoExperiment.id, {       onDelete: 'set null',     } |
| `checkBackAt` | `timestamp without time zone` | Yes | — |
| `checkBackRunId` | `text` | Yes | FK: () => agentRun.id |
| `checkBackResult` | `jsonb` | Yes | — |
| `createdAt` | `timestamp without time zone` | No | — |
| `updatedAt` | `timestamp without time zone` | No | — |

Concrete mapping gaps found in the first draft:

- No concrete columns on imported_decision for supersededByPendingActionId, resultRunId, checkBackRunId, checkBackAt.
- Evidence-only unsupported source rows have no explicit content/reason/priority/mode/source linkage destination.

## inbox_recovery_run

Declared at `packages/database/src/schema.ts:4812`.

| SQL column | SQL type | Nullable | Declared reference / enum hint |
|---|---|---|---|
| `id` | `text` | No | Primary key |
| `manifest_hash` | `text` | No | — |
| `organization_id` | `text` | Yes | FK: () => organization.id, {       onDelete: 'cascade',     } |
| `manifest` | `jsonb` | No | — |
| `applied_at` | `timestamp with time zone` | No | — |
| `created_at` | `timestamp with time zone` | No | — |

Concrete mapping gaps found in the first draft:

- organization_id is nullable; proposed all-tenant history cannot import global manifest by arbitrary tenant.

## agent_request

Declared at `packages/database/src/schema.ts:4840`.

| SQL column | SQL type | Nullable | Declared reference / enum hint |
|---|---|---|---|
| `id` | `text` | No | Primary key |
| `organizationId` | `text` | No | FK: () => organization.id, { onDelete: 'cascade' } |
| `assetId` | `text` | Yes | FK: () => asset.id, {       onDelete: 'cascade',     } |
| `agentType` | `text` | No | — |
| `sourceAgentRunId` | `text` | Yes | FK: () => agentRun.id, {       onDelete: 'set null',     } |
| `kind` | `text` | No | TS enum: hypothesis, investigation, draft, execution, blocked, informational |
| `phase` | `text` | No | TS enum: hypothesis, investigation, draft, execution, measurement |
| `status` | `text` | No | TS enum: open, approved, rejected, blocked, failed, superseded, completed |
| `title` | `text` | No | — |
| `summary` | `text` | No | — |
| `evidence` | `jsonb` | No | — |
| `proposedOutcome` | `jsonb` | No | — |
| `whatWillHappen` | `jsonb` | No | — |
| `approvalPolicy` | `jsonb` | No | — |
| `blockerCode` | `text` | Yes | — |
| `blockerContext` | `jsonb` | No | — |
| `unblockGuide` | `jsonb` | No | — |
| `pendingActionId` | `text` | Yes | FK: () => pendingAction.id, {         onDelete: 'set null',       } |
| `recommendationIds` | `jsonb` | No | — |
| `scenarioId` | `text` | Yes | — |
| `experimentId` | `text` | Yes | — |
| `idempotencyKey` | `text` | No | — |
| `supersededByAgentRequestId` | `text` | Yes | FK: (): AnyPgColumn => agentRequest.id, { onDelete: 'set null' } |
| `approvedBy` | `text` | Yes | FK: () => user.id |
| `approvedAt` | `timestamp without time zone` | Yes | — |
| `rejectedBy` | `text` | Yes | FK: () => user.id |
| `rejectedAt` | `timestamp without time zone` | Yes | — |
| `rejectionReason` | `text` | Yes | — |
| `createdAt` | `timestamp without time zone` | No | — |
| `updatedAt` | `timestamp without time zone` | No | — |

Concrete mapping gaps found in the first draft:

- No concrete historical home for agentType, kind, phase, title, summary, sourceAgentRunId, idempotencyKey, pendingActionId, scenarioId, experimentId, supersededByAgentRequestId when row is not imported as work.

## agent_request_event

Declared at `packages/database/src/schema.ts:4955`.

| SQL column | SQL type | Nullable | Declared reference / enum hint |
|---|---|---|---|
| `id` | `text` | No | Primary key |
| `agentRequestId` | `text` | No | FK: () => agentRequest.id, { onDelete: 'cascade' } |
| `eventType` | `text` | No | TS enum: created, approved, rejected, blocked, retried, superseded, completed, failed |
| `actorUserId` | `text` | Yes | FK: () => user.id |
| `sourceAgentRunId` | `text` | Yes | FK: () => agentRun.id, {       onDelete: 'set null',     } |
| `message` | `text` | Yes | — |
| `data` | `jsonb` | No | — |
| `createdAt` | `timestamp without time zone` | No | — |

Concrete mapping gaps found in the first draft:

- agentRequestId relation absent from imported_request_event.

## inbox_item_state

Declared at `packages/database/src/schema.ts:5042`.

| SQL column | SQL type | Nullable | Declared reference / enum hint |
|---|---|---|---|
| `id` | `text` | No | Primary key |
| `organization_id` | `text` | No | FK: () => organization.id, { onDelete: 'cascade' } |
| `user_id` | `text` | No | FK: () => user.id, { onDelete: 'cascade' } |
| `source_type` | `text` | No | — |
| `source_id` | `text` | No | — |
| `status` | `text` | No | TS enum: unread, read, snoozed, dismissed, archived, iterating |
| `snoozed_until` | `timestamp without time zone` | Yes | — |
| `note` | `text` | Yes | — |
| `created_at` | `timestamp without time zone` | No | — |
| `updated_at` | `timestamp without time zone` | No | — |

Concrete mapping gaps found in the first draft:

- sourceId (target ID) absent from imported_overlay.
- sourceType is open SQL text; the current wire contract is agent_request | pending_action | pending_action_batch | review_draft_batch | agent_activity, unlike the stale schema comment. Historical review_draft requires separate census-backed compatibility mapping.
- unread needs personal read-state mapping, not shared lifecycle resolution.

## opportunity_backlog

Declared at `packages/database/src/schema.ts:6479`.

| SQL column | SQL type | Nullable | Declared reference / enum hint |
|---|---|---|---|
| `id` | `text` | No | Primary key |
| `organization_id` | `text` | No | FK: () => organization.id, { onDelete: 'cascade' } |
| `asset_id` | `text` | Yes | FK: () => asset.id, {       onDelete: 'cascade',     } |
| `title` | `text` | No | — |
| `description` | `text` | No | — |
| `market` | `text` | Yes | — |
| `gate` | `text` | Yes | — |
| `priority` | `text` | No | — |
| `impact` | `text` | Yes | — |
| `risk` | `text` | Yes | — |
| `capability_tier` | `integer` | Yes | — |
| `work_definition_key` | `text` | Yes | — |
| `work_execution_mode` | `text` | Yes | — |
| `work_params` | `jsonb` | Yes | — |
| `work_preview` | `jsonb` | Yes | — |
| `work_preflight_receipt` | `jsonb` | Yes | — |
| `staged_intent_identity` | `text` | Yes | — |
| `status` | `text` | No | — |
| `source` | `text` | No | — |
| `source_report_version_id` | `text` | Yes | FK: () => reportVersion.id, { onDelete: 'set null' } |
| `source_report_id` | `text` | Yes | FK: () => report.id, {       onDelete: 'set null',     } |
| `candidate_key` | `text` | Yes | — |
| `candidate_source_kind` | `text` | Yes | — |
| `content_hash` | `text` | Yes | — |
| `evidence_refs` | `jsonb` | Yes | — |
| `latest_seen_report_version_id` | `text` | Yes | FK: () => reportVersion.id, { onDelete: 'set null' } |
| `retirement_reason` | `text` | Yes | — |
| `supersedes_backlog_item_id` | `text` | Yes | FK: (): AnyPgColumn => opportunityBacklog.id, { onDelete: 'set null' } |
| `staged_pending_action_id` | `text` | Yes | FK: () => pendingAction.id, { onDelete: 'set null' } |
| `staged_at` | `timestamp without time zone` | Yes | — |
| `staged_by` | `text` | Yes | FK: () => user.id, {       onDelete: 'set null',     } |
| `available_at` | `timestamp without time zone` | Yes | — |
| `schedule_month` | `integer` | Yes | — |
| `stage_attempted_at` | `timestamp without time zone` | Yes | — |
| `stage_refusal_reason` | `text` | Yes | — |
| `rejected_at` | `timestamp without time zone` | Yes | — |
| `rejected_intent_identity` | `text` | Yes | — |
| `archived_at` | `timestamp without time zone` | Yes | — |
| `archived_by` | `text` | Yes | FK: () => user.id, {       onDelete: 'set null',     } |
| `created_by` | `text` | Yes | FK: () => user.id, {       onDelete: 'set null',     } |
| `created_at` | `timestamp without time zone` | No | — |
| `updated_at` | `timestamp without time zone` | No | — |

Concrete mapping gaps found in the first draft:

- assetId and createdBy omitted from imported_backlog_item.
- stagedPendingActionId requires consolidation with pending_action importer, not a second ticket.

## capability_execution

Declared at `packages/database/src/schema.ts:8287`.

| SQL column | SQL type | Nullable | Declared reference / enum hint |
|---|---|---|---|
| `id` | `text` | No | Primary key |
| `organization_id` | `text` | No | FK: () => organization.id, { onDelete: 'cascade' } |
| `capability_key` | `text` | No | — |
| `work_id` | `text` | Yes | — |
| `pending_action_id` | `text` | Yes | — |
| `initiator` | `text` | No | TS enum: human, agent, system |
| `actor_user_id` | `text` | Yes | FK: () => user.id, {       onDelete: 'set null',     } |
| `outcome` | `text` | No | TS enum: executed, failed, partial |
| `unit_count` | `integer` | No | — |
| `failed_unit_count` | `integer` | No | — |
| `credits_charged` | `integer` | No | — |
| `verification_outcome` | `text` | Yes | TS enum: confirmed, mismatch, unverifiable |
| `verified_at` | `timestamp with time zone` | Yes | — |
| `verification_detail` | `text` | Yes | — |
| `created_at` | `timestamp with time zone` | No | — |

Concrete mapping gaps found in the first draft:

- Field mapping substantially matches source; claim must not create a charge or proof of provider HTTP response.

## Boundary of this inventory

`aso_experiment.test_plan` exists on the experiment; it is not a field on either recommendation table. Experiments, runs, assets, existing native receipt stores and derived aliases may extend the migration dependency graph. Retain their independent domain ownership and inventory the actual relationships before deciding what to migrate or remove. No final new-table count follows from these twelve source tables.
