# Implemented Actions schema

20 September 2026 · Local implementation snapshot; not production cutover.

Generated from Drizzle snapshot 0168: 19 relations, 286 fields. Runtime provider dispatch, historical import, erasure and UI cutover are not complete.

## `actions.action`

The permanent ticket and its current shared state.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `id` | text | No | PK; FK → actions.revision.action_id; FK → actions.approval.action_id |
| `organization_id` | text | No | FK → public.organization.id; FK → public.asset.organizationId; FK → actions.action.organization_id; FK → actions.action.organization_id; FK → actions.revision.organization_id; FK → actions.approval.organization_id |
| `creation_key` | uuid | No | — |
| `asset_id` | text | Yes | FK → public.asset.id |
| `domain` | domain: reviews, listing, ads, agent, advisory, collection | No | — |
| `record_kind` | record_kind: work, historical, historical_deleted | No | Default: 'work' |
| `parent_action_id` | text | Yes | FK → actions.action.id |
| `decision` | decision: open, approved, declined, acknowledged, handled_externally, cancelled, superseded | No | Default: 'open' |
| `version` | bigint | No | Default: 1 |
| `attention_version` | bigint | No | Default: 1 |
| `current_revision_id` | text | No | FK → actions.revision.id; FK → actions.approval.revision_id |
| `current_approval_id` | text | Yes | FK → actions.approval.id |
| `owner_user_id` | text | Yes | FK → public.user.id |
| `priority` | smallint | No | Default: 2 |
| `snoozed_until` | timestamp with time zone | Yes | — |
| `scheduled_for` | timestamp with time zone | Yes | — |
| `archived_at` | timestamp with time zone | Yes | — |
| `successor_action_id` | text | Yes | FK → actions.action.id |
| `created_at` | timestamp with time zone | No | Default: now() |
| `updated_at` | timestamp with time zone | No | Default: now() |

```sql
action_scope_page: INDEX (organization_id ASC, created_at DESC, "id" COLLATE "C" DESC ASC)
action_inbox_scope_page: INDEX (organization_id ASC, parent_action_id ASC, created_at DESC, "id" COLLATE "C" DESC ASC) WHERE "actions"."action"."record_kind" = 'work' AND "actions"."action"."archived_at" IS NULL
action_asset_scope_index: INDEX (organization_id ASC, asset_id ASC, created_at DESC, "id" COLLATE "C" DESC ASC)
action_tenant_identity: UNIQUE (organization_id, id)
action_creation_identity: UNIQUE (organization_id, creation_key)
action_organization_id_organization_id_fk: (organization_id) → public.organization (id)
action_owner_user_id_user_id_fk: (owner_user_id) → public.user (id)
action_asset_scope: (organization_id, asset_id) → public.asset (organizationId, id)
action_parent_scope: (organization_id, parent_action_id) → actions.action (organization_id, id)
action_successor_scope: (organization_id, successor_action_id) → actions.action (organization_id, id)
action_head_scope: (organization_id, id, current_revision_id) → actions.revision (organization_id, action_id, id)
action_approval_scope: (organization_id, id, current_revision_id, current_approval_id) → actions.approval (organization_id, action_id, revision_id, id)
action_instant_bounds: ("actions"."action"."created_at" IS NULL OR "actions"."action"."created_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."action"."updated_at" IS NULL OR "actions"."action"."updated_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."action"."snoozed_until" IS NULL OR "actions"."action"."snoozed_until" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."action"."scheduled_for" IS NULL OR "actions"."action"."scheduled_for" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."action"."archived_at" IS NULL OR "actions"."action"."archived_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)
action_versions_positive: "actions"."action"."version" > 0 AND "actions"."action"."attention_version" > 0 AND "actions"."action"."attention_version" <= "actions"."action"."version"
action_priority_valid: "actions"."action"."priority" BETWEEN 1 AND 3
action_successor_shape: ("actions"."action"."decision" = 'superseded') = ("actions"."action"."successor_action_id" IS NOT NULL) AND "actions"."action"."successor_action_id" IS DISTINCT FROM "actions"."action"."id"
action_parent_not_self: "actions"."action"."parent_action_id" IS DISTINCT FROM "actions"."action"."id"
action_time_order: "actions"."action"."updated_at" >= "actions"."action"."created_at"
action_historical_non_authorizing: "actions"."action"."record_kind" = 'work' OR ("actions"."action"."current_approval_id" IS NULL AND "actions"."action"."decision" IN ('open', 'declined', 'superseded'))
action_approval_pointer_shape: ("actions"."action"."decision" = 'approved') = ("actions"."action"."current_approval_id" IS NOT NULL)
```

## `actions.revision`

One sealed content snapshot. Editing creates another revision.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `id` | text | No | PK |
| `organization_id` | text | No | FK → actions.action.organization_id; FK → actions.command.organization_id; FK → actions.revision.organization_id; FK → actions.revision.organization_id |
| `action_id` | text | No | FK → actions.action.id; FK → actions.revision.action_id; FK → actions.revision.action_id |
| `purpose` | revision_purpose: proposal, baseline, observation, historical | No | — |
| `kind` | revision_kind: review_reply, listing, request, ads, advisory, collection | No | — |
| `revision_number` | bigint | No | — |
| `authored_command_id` | text | No | FK → actions.command.id |
| `baseline_revision_id` | text | Yes | FK → actions.revision.id |
| `generated_from_revision_id` | text | Yes | FK → actions.revision.id |
| `title` | text | No | — |
| `summary` | text | No | — |
| `rationale` | text | Yes | — |
| `content_digest` | text | No | — |
| `canonicalization_version` | integer | No | — |
| `sealed` | boolean | No | Default: False |
| `created_at` | timestamp with time zone | No | Default: now() |

```sql
revision_tenant_identity: UNIQUE (organization_id, id)
revision_action_identity: UNIQUE (organization_id, action_id, id)
revision_purpose_identity: UNIQUE (organization_id, id, purpose)
revision_number_unique: UNIQUE (action_id, revision_number)
revision_action_scope: (organization_id, action_id) → actions.action (organization_id, id)
revision_author_scope: (organization_id, authored_command_id) → actions.command (organization_id, id)
revision_baseline_scope: (organization_id, action_id, baseline_revision_id) → actions.revision (organization_id, action_id, id)
revision_generation_scope: (organization_id, action_id, generated_from_revision_id) → actions.revision (organization_id, action_id, id)
revision_instant_bounds: ("actions"."revision"."created_at" IS NULL OR "actions"."revision"."created_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)
revision_number_positive: "actions"."revision"."revision_number" > 0
revision_digest_shape: "actions"."revision"."content_digest" ~ '^[0-9a-f]{64}$' AND "actions"."revision"."canonicalization_version" = 1
revision_not_own_source: "actions"."revision"."id" IS DISTINCT FROM "actions"."revision"."baseline_revision_id" AND "actions"."revision"."id" IS DISTINCT FROM "actions"."revision"."generated_from_revision_id"
```

## `actions.command`

Who asked for what, when it was accepted, and the immutable recovery-cycle scope.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `id` | text | No | PK |
| `organization_id` | text | No | FK → public.organization.id; FK → actions.execution.organization_id; FK → actions.execution_step.organization_id; FK → actions.execution_attempt.organization_id; FK → actions.execution_step.organization_id; FK → actions.command.organization_id |
| `idempotency_key` | uuid | No | — |
| `principal_kind` | principal_kind: user, api_key, agent, policy, system | No | — |
| `actor_user_id` | text | Yes | FK → public.user.id |
| `actor_acting_for_user_id` | text | Yes | FK → public.user.id |
| `actor_api_key_id` | text | Yes | FK → public.api_key.id |
| `actor_agent_run_id` | text | Yes | — |
| `actor_policy_revision_id` | text | Yes | — |
| `actor_subject_snapshot` | text | No | — |
| `actor_name_snapshot` | text | Yes | — |
| `channel` | channel: web, chat, mcp, api, slack, discord, agent, worker, operator, migration | No | — |
| `external_actor_id` | text | Yes | — |
| `kind` | command_kind: create, reconcile, record_observation, record_attempt, record_progress, resolve_external, resolve_dependency, grant_policy, revoke_policy, approve, undo, reject, acknowledge, snooze, unsnooze, assign, archive, restore, supersede, retry, revise, reopen, open_recovery, resume_hold, schedule, unschedule, abandon | No | — |
| `restore_mode` | restore_mode: placement, reconsider, unhide | Yes | — |
| `request_digest` | text | No | — |
| `digest_version` | integer | No | — |
| `outcome` | command_outcome: accepted, conflict, refused | No | — |
| `error` | command_error: not_found, stale_version, stale_revision, stale_membership, invalid_transition, undo_expired, execution_started, unresolved_write, permission_changed, billing_required, unsupported_operation, idempotency_mismatch, target_changed, incomplete_revision, client_attention_capacity | Yes | — |
| `message` | text | Yes | — |
| `progress_execution_id` | text | Yes | FK → actions.execution.id; FK → actions.execution_step.execution_id; FK → actions.execution_attempt.execution_id; FK → actions.execution_step.execution_id |
| `progress_step_id` | text | Yes | FK → actions.execution_step.id; FK → actions.execution_attempt.step_id |
| `progress_subject_attempt_id` | text | Yes | FK → actions.execution_attempt.id |
| `cycle_purpose` | cycle_purpose: binding, prewrite, readback, cleanup | Yes | — |
| `cycle_planned_step_id` | text | Yes | FK → actions.execution_step.id |
| `cycle_predecessor_command_id` | text | Yes | FK → actions.command.id |
| `cycle_contract_id` | text | Yes | FK → composition.operation_contract.id |
| `cycle_anchor_at` | timestamp with time zone | Yes | — |
| `cycle_decisive_after_at` | timestamp with time zone | Yes | — |
| `accepted_at` | timestamp with time zone | No | Default: now() |

```sql
execution_cycle_successor: UNIQUE INDEX (organization_id ASC, cycle_predecessor_command_id ASC) WHERE "actions"."command"."kind" IN ('reconcile','resume_hold') AND "actions"."command"."outcome" = 'accepted' AND "actions"."command"."cycle_predecessor_command_id" IS NOT NULL
execution_attempt_completion_command: UNIQUE INDEX (organization_id ASC, progress_subject_attempt_id ASC) WHERE "actions"."command"."kind" = 'record_attempt' AND "actions"."command"."outcome" = 'accepted'
command_history_page: INDEX (organization_id ASC, accepted_at DESC, "id" COLLATE "C" DESC ASC)
command_execution_step_identity: UNIQUE (organization_id, progress_execution_id, progress_step_id, id)
command_tenant_identity: UNIQUE (organization_id, id)
command_replay_identity: UNIQUE (organization_id, principal_kind, actor_subject_snapshot, idempotency_key)
command_organization_id_organization_id_fk: (organization_id) → public.organization (id)
command_actor_user_id_user_id_fk: (actor_user_id) → public.user (id)
command_actor_acting_for_user_id_user_id_fk: (actor_acting_for_user_id) → public.user (id)
command_actor_api_key_id_api_key_id_fk: (actor_api_key_id) → public.api_key (id)
command_cycle_contract_id_operation_contract_id_fk: (cycle_contract_id) → composition.operation_contract (id)
command_execution_scope: (organization_id, progress_execution_id) → actions.execution (organization_id, id)
command_step_scope: (organization_id, progress_execution_id, progress_step_id) → actions.execution_step (organization_id, execution_id, id)
command_subject_scope: (organization_id, progress_execution_id, progress_step_id, progress_subject_attempt_id) → actions.execution_attempt (organization_id, execution_id, step_id, id)
command_planned_step_scope: (organization_id, progress_execution_id, cycle_planned_step_id) → actions.execution_step (organization_id, execution_id, id)
command_cycle_predecessor_scope: (organization_id, cycle_predecessor_command_id) → actions.command (organization_id, id)
command_instant_bounds: ("actions"."command"."accepted_at" IS NULL OR "actions"."command"."accepted_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command"."cycle_anchor_at" IS NULL OR "actions"."command"."cycle_anchor_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command"."cycle_decisive_after_at" IS NULL OR "actions"."command"."cycle_decisive_after_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)
command_cycle_shape: CASE
        WHEN "actions"."command"."kind" IN ('open_recovery','reconcile','resume_hold') AND "actions"."command"."outcome" = 'accepted' THEN
          num_nonnulls("actions"."command"."progress_execution_id", "actions"."command"."progress_step_id", "actions"."command"."cycle_purpose", "actions"."command"."cycle_contract_id", "actions"."command"."cycle_anchor_at") = 5
          AND CASE "actions"."command"."kind"
            WHEN 'open_recovery' THEN "actions"."command"."principal_kind" = 'system' AND "actions"."command"."cycle_predecessor_command_id" IS NULL
            WHEN 'reconcile' THEN "actions"."command"."principal_kind" IN ('user','api_key') AND "actions"."command"."cycle_predecessor_command_id" IS NOT NULL
            WHEN 'resume_hold' THEN "actions"."command"."principal_kind" = 'system' AND "actions"."command"."cycle_predecessor_command_id" IS NOT NULL
            ELSE false END
          AND CASE "actions"."command"."cycle_purpose"
            WHEN 'binding' THEN "actions"."command"."progress_subject_attempt_id" IS NULL AND "actions"."command"."cycle_planned_step_id" IS NULL
            WHEN 'prewrite' THEN "actions"."command"."progress_subject_attempt_id" IS NULL AND "actions"."command"."cycle_planned_step_id" IS NOT NULL
            WHEN 'readback' THEN "actions"."command"."progress_subject_attempt_id" IS NOT NULL AND "actions"."command"."cycle_planned_step_id" IS NULL
            WHEN 'cleanup' THEN "actions"."command"."progress_subject_attempt_id" IS NOT NULL AND "actions"."command"."cycle_planned_step_id" IS NULL
            ELSE false END
        WHEN "actions"."command"."kind" = 'record_attempt' AND "actions"."command"."outcome" = 'accepted' THEN
          num_nonnulls("actions"."command"."progress_execution_id", "actions"."command"."progress_step_id", "actions"."command"."progress_subject_attempt_id") = 3
          AND "actions"."command"."principal_kind" = 'system' AND "actions"."command"."channel" = 'worker'
          AND num_nonnulls("actions"."command"."cycle_purpose", "actions"."command"."cycle_planned_step_id", "actions"."command"."cycle_predecessor_command_id", "actions"."command"."cycle_contract_id", "actions"."command"."cycle_anchor_at", "actions"."command"."cycle_decisive_after_at") = 0
        ELSE num_nonnulls("actions"."command"."progress_execution_id", "actions"."command"."progress_step_id", "actions"."command"."progress_subject_attempt_id", "actions"."command"."cycle_purpose", "actions"."command"."cycle_planned_step_id", "actions"."command"."cycle_predecessor_command_id", "actions"."command"."cycle_contract_id", "actions"."command"."cycle_anchor_at", "actions"."command"."cycle_decisive_after_at") = 0
        END
command_cycle_planned_step_distinct: "actions"."command"."cycle_planned_step_id" IS NULL OR "actions"."command"."cycle_planned_step_id" IS DISTINCT FROM "actions"."command"."progress_step_id"
command_cycle_not_own_predecessor: "actions"."command"."id" IS DISTINCT FROM "actions"."command"."cycle_predecessor_command_id"
command_digest_shape: "actions"."command"."request_digest" ~ '^[0-9a-f]{64}$' AND "actions"."command"."digest_version" = 1
command_outcome_shape: ("actions"."command"."outcome" = 'accepted') = ("actions"."command"."error" IS NULL)
command_restore_shape: ("actions"."command"."kind" = 'restore') = ("actions"."command"."restore_mode" IS NOT NULL) AND ("actions"."command"."restore_mode" IS NULL OR "actions"."command"."restore_mode" IN ('placement', 'reconsider', 'unhide'))
command_actor_shape: 
    ("actions"."command"."principal_kind" NOT IN ('user', 'api_key') OR "actions"."command"."actor_user_id" IS NOT NULL)
    AND (("actions"."command"."principal_kind" = 'api_key') = ("actions"."command"."actor_api_key_id" IS NOT NULL))
    AND (("actions"."command"."principal_kind" = 'agent') = ("actions"."command"."actor_agent_run_id" IS NOT NULL))
    AND (("actions"."command"."principal_kind" = 'policy') = ("actions"."command"."actor_policy_revision_id" IS NOT NULL))
    AND ("actions"."command"."principal_kind" <> 'system' OR "actions"."command"."actor_user_id" IS NULL)
    AND ("actions"."command"."actor_acting_for_user_id" IS NULL OR "actions"."command"."principal_kind" = 'user')
    AND length("actions"."command"."actor_subject_snapshot") > 0
  
```

## `actions.command_target`

The exact ticket state before and after one accepted command.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `organization_id` | text | No | FK → actions.command.organization_id; FK → actions.action.organization_id; FK → actions.revision.organization_id; FK → actions.revision.organization_id; FK → actions.revision.organization_id; FK → actions.revision.organization_id; FK → actions.revision.organization_id; FK → actions.approval.organization_id; FK → actions.approval.organization_id; FK → actions.action.organization_id; FK → actions.action.organization_id |
| `command_id` | text | No | PK; FK → actions.command.id |
| `action_id` | text | No | PK; FK → actions.action.id; FK → actions.revision.action_id; FK → actions.revision.action_id; FK → actions.revision.action_id; FK → actions.approval.action_id; FK → actions.approval.action_id |
| `expected_version` | bigint | Yes | — |
| `expected_revision_id` | text | Yes | FK → actions.revision.id |
| `expected_parent_revision_id` | text | Yes | FK → actions.revision.id |
| `evidence_revision_id` | text | Yes | FK → actions.revision.id |
| `previous_version` | bigint | Yes | — |
| `result_version` | bigint | No | — |
| `previous_decision` | decision: open, approved, declined, acknowledged, handled_externally, cancelled, superseded | Yes | — |
| `result_decision` | decision: open, approved, declined, acknowledged, handled_externally, cancelled, superseded | No | — |
| `previous_record_kind` | record_kind: work, historical, historical_deleted | Yes | — |
| `result_record_kind` | record_kind: work, historical, historical_deleted | No | — |
| `previous_approval_id` | text | Yes | FK → actions.approval.id |
| `result_approval_id` | text | Yes | FK → actions.approval.id |
| `previous_successor_action_id` | text | Yes | FK → actions.action.id |
| `result_successor_action_id` | text | Yes | FK → actions.action.id |
| `previous_priority` | smallint | Yes | — |
| `result_priority` | smallint | No | — |
| `previous_revision_id` | text | Yes | FK → actions.revision.id |
| `result_revision_id` | text | No | FK → actions.revision.id |
| `previous_attention_version` | bigint | Yes | — |
| `result_attention_version` | bigint | No | — |
| `previous_owner_user_id` | text | Yes | — |
| `result_owner_user_id` | text | Yes | — |
| `previous_snoozed_until` | timestamp with time zone | Yes | — |
| `result_snoozed_until` | timestamp with time zone | Yes | — |
| `previous_scheduled_for` | timestamp with time zone | Yes | — |
| `result_scheduled_for` | timestamp with time zone | Yes | — |
| `previous_archived_at` | timestamp with time zone | Yes | — |
| `result_archived_at` | timestamp with time zone | Yes | — |

```sql
command_target_command_id_action_id_pk: PRIMARY KEY (command_id, action_id)
command_target_scope_identity: UNIQUE (organization_id, command_id, action_id)
command_target_version_unique: UNIQUE (organization_id, action_id, result_version)
target_command_scope: (organization_id, command_id) → actions.command (organization_id, id)
target_action_scope: (organization_id, action_id) → actions.action (organization_id, id)
target_expected_revision_scope: (organization_id, action_id, expected_revision_id) → actions.revision (organization_id, action_id, id)
target_previous_revision_scope: (organization_id, action_id, previous_revision_id) → actions.revision (organization_id, action_id, id)
target_result_revision_scope: (organization_id, action_id, result_revision_id) → actions.revision (organization_id, action_id, id)
target_expected_parent_scope: (organization_id, expected_parent_revision_id) → actions.revision (organization_id, id)
target_evidence_scope: (organization_id, evidence_revision_id) → actions.revision (organization_id, id)
target_previous_approval_scope: (organization_id, action_id, previous_approval_id) → actions.approval (organization_id, action_id, id)
target_result_approval_scope: (organization_id, action_id, result_approval_id) → actions.approval (organization_id, action_id, id)
target_previous_successor_scope: (organization_id, previous_successor_action_id) → actions.action (organization_id, id)
target_result_successor_scope: (organization_id, result_successor_action_id) → actions.action (organization_id, id)
target_instant_bounds: ("actions"."command_target"."previous_snoozed_until" IS NULL OR "actions"."command_target"."previous_snoozed_until" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command_target"."result_snoozed_until" IS NULL OR "actions"."command_target"."result_snoozed_until" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command_target"."previous_scheduled_for" IS NULL OR "actions"."command_target"."previous_scheduled_for" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command_target"."result_scheduled_for" IS NULL OR "actions"."command_target"."result_scheduled_for" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command_target"."previous_archived_at" IS NULL OR "actions"."command_target"."previous_archived_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command_target"."result_archived_at" IS NULL OR "actions"."command_target"."result_archived_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)
target_priority_shape: "actions"."command_target"."result_priority" BETWEEN 1 AND 3 AND ("actions"."command_target"."previous_priority" IS NULL OR "actions"."command_target"."previous_priority" BETWEEN 1 AND 3) AND ("actions"."command_target"."previous_version" IS NULL) = ("actions"."command_target"."previous_priority" IS NULL)
target_version_increment: "actions"."command_target"."result_version" = coalesce("actions"."command_target"."previous_version", 0) + 1
target_attention_increment: "actions"."command_target"."result_attention_version" > 0 AND "actions"."command_target"."result_attention_version" - coalesce("actions"."command_target"."previous_attention_version", 0) BETWEEN 0 AND 1
target_creation_shape: ("actions"."command_target"."previous_version" IS NULL) = ("actions"."command_target"."previous_decision" IS NULL) AND ("actions"."command_target"."previous_version" IS NULL) = ("actions"."command_target"."previous_revision_id" IS NULL) AND ("actions"."command_target"."previous_version" IS NULL) = ("actions"."command_target"."previous_record_kind" IS NULL) AND ("actions"."command_target"."previous_version" IS NULL) = ("actions"."command_target"."previous_attention_version" IS NULL)
target_creation_has_no_predecessor: "actions"."command_target"."previous_version" IS NOT NULL OR ("actions"."command_target"."previous_approval_id" IS NULL AND "actions"."command_target"."previous_successor_action_id" IS NULL AND "actions"."command_target"."previous_owner_user_id" IS NULL AND "actions"."command_target"."previous_snoozed_until" IS NULL AND "actions"."command_target"."previous_scheduled_for" IS NULL AND "actions"."command_target"."previous_archived_at" IS NULL AND "actions"."command_target"."expected_version" IS NULL AND "actions"."command_target"."expected_revision_id" IS NULL)
```

## `actions.approval`

Who authorized this exact content, its scope, and the server-owned Undo deadline.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `id` | text | No | PK |
| `organization_id` | text | No | FK → actions.revision.organization_id; FK → actions.command_target.organization_id; FK → actions.revision.organization_id |
| `action_id` | text | No | FK → actions.revision.action_id; FK → actions.command_target.action_id |
| `revision_id` | text | No | FK → actions.revision.id |
| `command_id` | text | No | FK → actions.command_target.command_id |
| `scope` | approval_scope: perform, generate, revise | No | — |
| `revision_instructions` | text | Yes | — |
| `parent_revision_id` | text | Yes | FK → actions.revision.id |
| `undo_deadline` | timestamp with time zone | No | — |
| `required_surface` | surface: provider_response, editable_listing, live_listing, review_response, advertising_resource, internal_artifact | No | — |
| `created_at` | timestamp with time zone | No | Default: now() |

```sql
approval_tenant_identity: UNIQUE (organization_id, id)
approval_action_identity: UNIQUE (organization_id, action_id, id)
approval_revision_identity: UNIQUE (organization_id, action_id, revision_id, id)
approval_command_unique: UNIQUE (command_id, action_id)
approval_revision_scope: (organization_id, action_id, revision_id) → actions.revision (organization_id, action_id, id)
approval_command_target_scope: (organization_id, command_id, action_id) → actions.command_target (organization_id, command_id, action_id)
approval_parent_scope: (organization_id, parent_revision_id) → actions.revision (organization_id, id)
approval_instant_bounds: ("actions"."approval"."undo_deadline" IS NULL OR "actions"."approval"."undo_deadline" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."approval"."created_at" IS NULL OR "actions"."approval"."created_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)
approval_revision_instructions_shape: ("actions"."approval"."scope" = 'revise') = ("actions"."approval"."revision_instructions" IS NOT NULL) AND ("actions"."approval"."revision_instructions" IS NULL OR length(btrim("actions"."approval"."revision_instructions")) > 0)
approval_undo_order: "actions"."approval"."undo_deadline" >= "actions"."approval"."created_at"
```

## `actions.membership`

A parent revision’s stable child tickets, exact child revisions, and order.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `organization_id` | text | No | FK → actions.revision.organization_id; FK → actions.revision.organization_id |
| `parent_revision_id` | text | No | PK; FK → actions.revision.id |
| `child_action_id` | text | No | PK; FK → actions.revision.action_id |
| `child_revision_id` | text | No | FK → actions.revision.id |
| `ordinal` | integer | No | — |

```sql
membership_parent_revision_id_child_action_id_pk: PRIMARY KEY (parent_revision_id, child_action_id)
membership_child_lookup: INDEX (organization_id ASC, child_action_id ASC, parent_revision_id ASC)
membership_order_unique: UNIQUE (parent_revision_id, ordinal)
membership_parent_scope: (organization_id, parent_revision_id) → actions.revision (organization_id, id)
membership_child_scope: (organization_id, child_action_id, child_revision_id) → actions.revision (organization_id, action_id, id)
membership_ordinal_nonnegative: "actions"."membership"."ordinal" >= 0
```

## `actions.read`

One person’s read watermark and compare-and-swap version. A delayed acknowledgement cannot undo a newer personal choice.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `organization_id` | text | No | PK; FK → actions.action.organization_id |
| `user_id` | text | No | PK; FK → public.user.id |
| `action_id` | text | No | PK; FK → actions.action.id |
| `read_version` | bigint | No | Default: 1 |
| `seen_attention_version` | bigint | No | — |
| `force_unread` | boolean | No | Default: False |
| `updated_at` | timestamp with time zone | No | Default: now() |

```sql
read_organization_id_user_id_action_id_pk: PRIMARY KEY (organization_id, user_id, action_id)
read_user_id_user_id_fk: (user_id) → public.user (id)
read_action_scope: (organization_id, action_id) → actions.action (organization_id, id)
read_instant_bounds: ("actions"."read"."updated_at" IS NULL OR "actions"."read"."updated_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)
read_watermark_nonnegative: "actions"."read"."seen_attention_version" >= 0
read_version_positive: "actions"."read"."read_version" > 0
```

## `actions.alias`

An old identifier that still leads to the permanent ticket.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `organization_id` | text | No | PK; FK → actions.action.organization_id |
| `namespace` | alias_namespace: pending_action, pending_action_batch, review_draft, review_draft_batch, agent_request, agent_activity, review_history, review_draft_rejection, capability_execution, recommendation, recommendation_variant, recovery_receipt | No | PK |
| `old_id` | text | No | PK |
| `action_id` | text | No | FK → actions.action.id |
| `historical_membership_known` | boolean | No | — |

```sql
alias_organization_id_namespace_old_id_pk: PRIMARY KEY (organization_id, namespace, old_id)
alias_action_lookup: INDEX (organization_id ASC, action_id ASC)
alias_action_scope: (organization_id, action_id) → actions.action (organization_id, id)
```

## `actions.dependency`

An explicit prerequisite between durable tickets.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `organization_id` | text | No | FK → actions.action.organization_id; FK → actions.action.organization_id; FK → actions.command.organization_id |
| `dependent_action_id` | text | No | PK; FK → actions.action.id |
| `prerequisite_action_id` | text | No | PK; FK → actions.action.id |
| `requirement` | dependency_requirement: completed, verified_live, verified_editable, generated, permission_restored, release_available | No | PK |
| `created_command_id` | text | No | FK → actions.command.id |

```sql
dependency_dependent_action_id_prerequisite_action_id_requirement_pk: PRIMARY KEY (dependent_action_id, prerequisite_action_id, requirement)
dependency_dependent_scope: (organization_id, dependent_action_id) → actions.action (organization_id, id)
dependency_prerequisite_scope: (organization_id, prerequisite_action_id) → actions.action (organization_id, id)
dependency_command_scope: (organization_id, created_command_id) → actions.command (organization_id, id)
dependency_not_self: "actions"."dependency"."dependent_action_id" <> "actions"."dependency"."prerequisite_action_id"
```

## `actions.execution`

One durable obligation for an exact approval. SQL owns its due time and current responsibility.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `id` | text | No | PK; FK → actions.execution_step.execution_id |
| `organization_id` | text | No | FK → public.organization.id; FK → actions.approval.organization_id; FK → actions.execution_step.organization_id; FK → actions.command.organization_id |
| `approval_id` | text | No | FK → actions.approval.id |
| `phase` | execution_phase: ready, claimed, verification_due, uncertain, blocked, settled, cancelled | No | — |
| `next_run_at` | timestamp with time zone | Yes | — |
| `next_step_id` | text | Yes | FK → actions.execution_step.id |
| `delivery_generation` | bigint | No | Default: 1 |
| `claim_generation` | bigint | No | Default: 0 |
| `claim_token` | uuid | Yes | — |
| `claim_expires_at` | timestamp with time zone | Yes | — |
| `hold_reason` | execution_hold_reason: permission, billing, resource_busy, target_changed, uncertain_write, retry_exhausted, unsupported_readback, generation_conflict, awaiting_release, awaiting_publication, plan_incomplete, evidence_conflict | Yes | — |
| `resolution_owner` | execution_resolution_owner: client, fload, provider | Yes | — |
| `result` | execution_result: generated, verified_live, verified_editable, handled_externally, acknowledged_only, failed, cancelled | Yes | — |
| `created_at` | timestamp with time zone | No | Default: now() |
| `settled_at` | timestamp with time zone | Yes | — |
| `resource_guard_id` | uuid | Yes | FK → actions.resource_guard.id |
| `plan_version` | integer | No | — |
| `writes_closed_at` | timestamp with time zone | Yes | — |
| `cancelled_command_id` | text | Yes | FK → actions.command.id |
| `plan_complete` | boolean | No | Default: False |

```sql
execution_due: INDEX (next_run_at ASC, "organization_id" COLLATE "C" ASC, "id" COLLATE "C" ASC) WHERE "actions"."execution"."phase" IN ('ready','verification_due','uncertain')
execution_blocked_due: INDEX (next_run_at ASC, "organization_id" COLLATE "C" ASC, "id" COLLATE "C" ASC) WHERE "actions"."execution"."phase" = 'blocked' AND "actions"."execution"."next_run_at" IS NOT NULL
execution_claim_expiry: INDEX (claim_expires_at ASC, "organization_id" COLLATE "C" ASC, "id" COLLATE "C" ASC) WHERE "actions"."execution"."phase" = 'claimed'
execution_tenant_identity: UNIQUE (organization_id, id)
execution_approval_unique: UNIQUE (organization_id, approval_id)
execution_organization_id_organization_id_fk: (organization_id) → public.organization (id)
execution_approval_scope: (organization_id, approval_id) → actions.approval (organization_id, id)
execution_next_step_scope: (organization_id, id, next_step_id) → actions.execution_step (organization_id, execution_id, id)
execution_cancel_command_scope: (organization_id, cancelled_command_id) → actions.command (organization_id, id)
execution_resource_guard_identity: (resource_guard_id) → actions.resource_guard (id)
execution_identity_nonempty: length("actions"."execution"."id") > 0 AND length("actions"."execution"."approval_id") > 0
execution_generations: "actions"."execution"."delivery_generation" > 0 AND "actions"."execution"."claim_generation" >= 0 AND "actions"."execution"."plan_version" > 0
execution_claim_shape: ("actions"."execution"."phase" = 'claimed') = ("actions"."execution"."claim_token" IS NOT NULL) AND ("actions"."execution"."claim_token" IS NULL) = ("actions"."execution"."claim_expires_at" IS NULL) AND ("actions"."execution"."phase" <> 'claimed' OR "actions"."execution"."claim_generation" > 0)
execution_terminal_shape: ("actions"."execution"."phase" IN ('settled','cancelled')) = ("actions"."execution"."settled_at" IS NOT NULL) AND ("actions"."execution"."phase" IN ('settled','cancelled')) = ("actions"."execution"."result" IS NOT NULL) AND ("actions"."execution"."phase" = 'cancelled') = ("actions"."execution"."result" IS NOT DISTINCT FROM 'cancelled') AND ("actions"."execution"."phase" = 'cancelled') = ("actions"."execution"."cancelled_command_id" IS NOT NULL)
execution_due_shape: ("actions"."execution"."phase" NOT IN ('ready','verification_due','uncertain') OR "actions"."execution"."next_run_at" IS NOT NULL) AND ("actions"."execution"."phase" NOT IN ('settled','cancelled') OR ("actions"."execution"."next_run_at" IS NULL AND "actions"."execution"."next_step_id" IS NULL))
execution_hold_shape: ("actions"."execution"."phase" IN ('blocked','uncertain')) = ("actions"."execution"."hold_reason" IS NOT NULL) AND ("actions"."execution"."phase" <> 'uncertain' OR "actions"."execution"."hold_reason" IS NOT DISTINCT FROM 'uncertain_write') AND ("actions"."execution"."phase" <> 'blocked' OR "actions"."execution"."next_run_at" IS NULL OR "actions"."execution"."hold_reason" IN ('awaiting_release','awaiting_publication','resource_busy','evidence_conflict'))
execution_resolution_owner_shape: ("actions"."execution"."phase" IN ('blocked','uncertain') OR ("actions"."execution"."phase" = 'settled' AND "actions"."execution"."result" IS NOT DISTINCT FROM 'failed')) = ("actions"."execution"."resolution_owner" IS NOT NULL)
execution_time_order: ("actions"."execution"."settled_at" IS NULL OR "actions"."execution"."settled_at" >= "actions"."execution"."created_at") AND ("actions"."execution"."writes_closed_at" IS NULL OR "actions"."execution"."writes_closed_at" >= "actions"."execution"."created_at")
execution_instant_bounds: ("actions"."execution"."next_run_at" IS NULL OR "actions"."execution"."next_run_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."execution"."claim_expires_at" IS NULL OR "actions"."execution"."claim_expires_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."execution"."created_at" IS NULL OR "actions"."execution"."created_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."execution"."settled_at" IS NULL OR "actions"."execution"."settled_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."execution"."writes_closed_at" IS NULL OR "actions"."execution"."writes_closed_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)
```

## `actions.execution_step`

An immutable ordered operation with pinned content, surface, and contract.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `id` | text | No | PK |
| `organization_id` | text | No | FK → actions.execution.organization_id; FK → actions.execution_step.organization_id; FK → actions.revision.organization_id |
| `execution_id` | text | No | FK → actions.execution.id; FK → actions.execution_step.execution_id |
| `ordinal` | integer | No | — |
| `operation_contract_id` | text | No | FK → composition.operation_contract.id |
| `required_surface` | surface: provider_response, editable_listing, live_listing, review_response, advertising_resource, internal_artifact | No | — |
| `verification_timing` | verification_timing: before_successor, after_effects | No | — |
| `recovery_policy_version` | integer | No | — |
| `input_step_id` | text | Yes | FK → actions.execution_step.id |
| `content_revision_id` | text | No | FK → actions.revision.id |
| `native_idempotency_key` | text | Yes | — |

```sql
step_tenant_identity: UNIQUE (organization_id, id)
step_execution_identity: UNIQUE (organization_id, execution_id, id)
step_ordinal_unique: UNIQUE (organization_id, execution_id, ordinal)
execution_step_operation_contract_id_operation_contract_id_fk: (operation_contract_id) → composition.operation_contract (id)
step_execution_scope: (organization_id, execution_id) → actions.execution (organization_id, id)
step_input_scope: (organization_id, execution_id, input_step_id) → actions.execution_step (organization_id, execution_id, id)
step_content_scope: (organization_id, content_revision_id) → actions.revision (organization_id, id)
step_identity_nonempty: length("actions"."execution_step"."id") > 0 AND length("actions"."execution_step"."execution_id") > 0 AND length("actions"."execution_step"."content_revision_id") > 0 AND ("actions"."execution_step"."native_idempotency_key" IS NULL OR length("actions"."execution_step"."native_idempotency_key") > 0)
step_structural_shape: "actions"."execution_step"."ordinal" >= 0 AND "actions"."execution_step"."recovery_policy_version" > 0 AND "actions"."execution_step"."id" IS DISTINCT FROM "actions"."execution_step"."input_step_id"
```

## `actions.execution_attempt`

One admitted interaction, its fence, and its retained outcome. It is not a queue job.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `id` | text | No | PK |
| `organization_id` | text | No | FK → actions.execution_step.organization_id; FK → actions.execution_attempt.organization_id; FK → actions.execution_attempt.organization_id; FK → actions.execution_attempt.organization_id; FK → actions.execution_step.organization_id; FK → actions.command.organization_id; FK → actions.command.organization_id; FK → actions.revision.organization_id; FK → actions.revision.organization_id; FK → actions.revision.organization_id |
| `execution_id` | text | No | FK → actions.execution_step.execution_id; FK → actions.execution_attempt.execution_id; FK → actions.execution_attempt.execution_id; FK → actions.execution_attempt.execution_id; FK → actions.execution_step.execution_id; FK → actions.command.progress_execution_id |
| `step_id` | text | No | FK → actions.execution_step.id; FK → actions.execution_attempt.step_id; FK → actions.command.progress_step_id |
| `number` | integer | No | — |
| `kind` | attempt_kind: write, readback, inspection, generation, manual_observation, late_evidence, conflicting_completion | No | — |
| `claim_generation` | bigint | No | — |
| `claim_token` | uuid | No | — |
| `subject_attempt_id` | text | Yes | FK → actions.execution_attempt.id |
| `input_attempt_id` | text | Yes | FK → actions.execution_attempt.id |
| `input_parent_revision_id` | text | Yes | FK → actions.revision.id |
| `connector_id` | text | Yes | — |
| `agent_run_id` | text | Yes | — |
| `started_at` | timestamp with time zone | No | — |
| `recorded_at` | timestamp with time zone | No | — |
| `finished_at` | timestamp with time zone | Yes | — |
| `result` | attempt_result: acknowledged, known_not_applied, uncertain, generated, discarded, matched, matched_external, mismatch, unreadable | Yes | — |
| `failure_class` | failure_class: permission, rate_limit, transport, target_changed, provider_rejected, persistence, unsupported_readback, invalid_content, billing | Yes | — |
| `non_application_basis` | non_application_basis: provider_rejection, pre_dispatch_failure, provider_proved_non_application | Yes | — |
| `retry_disposition` | retry_disposition: retryable, permanent | Yes | — |
| `uncertainty_reason` | uncertainty_reason: transport_lost, claim_expired, invalid_response, accepted_pending | Yes | — |
| `unreadable_reason` | unreadable_reason: unavailable, partial, unsupported, cancelled, no_editable_release | Yes | — |
| `terminal_outcome` | boolean | Yes | — |
| `semantic_fingerprint` | text | Yes | — |
| `fingerprint_version` | integer | Yes | — |
| `observation_revision_id` | text | Yes | FK → actions.revision.id |
| `comparison_version` | integer | Yes | — |
| `observation_surface` | surface: provider_response, editable_listing, live_listing, review_response, advertising_resource, internal_artifact | Yes | — |
| `observation_completeness` | observation_completeness: complete, partial, unavailable | Yes | — |
| `finalized_claim_generation` | bigint | Yes | — |
| `finalized_claim_token` | uuid | Yes | — |
| `inspection_purpose` | inspection_purpose: binding, prewrite | Yes | — |
| `planned_write_step_id` | text | Yes | FK → actions.execution_step.id |
| `prewrite_attempt_id` | text | Yes | FK → actions.execution_attempt.id |
| `resource_guard_generation` | bigint | Yes | — |
| `cycle_command_id` | text | Yes | FK → actions.command.id |
| `evidence_command_id` | text | Yes | FK → actions.command.id |
| `output_kind` | output_kind: revision, review_analysis, agent_run, no_work | Yes | — |
| `output_revision_id` | text | Yes | FK → actions.revision.id |
| `output_review_analysis_id` | text | Yes | — |
| `output_agent_run_id` | text | Yes | — |
| `no_work_reason` | no_work_reason: no_eligible_reviews | Yes | — |
| `capture_digest` | text | Yes | — |
| `capture_digest_version` | integer | Yes | — |

```sql
attempt_one_unfinished: UNIQUE INDEX (organization_id ASC, execution_id ASC) WHERE "actions"."execution_attempt"."finished_at" IS NULL AND "actions"."execution_attempt"."kind" IN ('write','readback','inspection','generation','manual_observation')
attempt_one_late_completion: UNIQUE INDEX (organization_id ASC, subject_attempt_id ASC) WHERE "actions"."execution_attempt"."kind" = 'late_evidence'
attempt_conflicting_capture_replay: UNIQUE INDEX (organization_id ASC, subject_attempt_id ASC, capture_digest_version ASC, capture_digest ASC) WHERE "actions"."execution_attempt"."kind" = 'conflicting_completion'
attempt_prewrite_consumed_once: UNIQUE INDEX (organization_id ASC, prewrite_attempt_id ASC) WHERE "actions"."execution_attempt"."kind" = 'write' AND "actions"."execution_attempt"."prewrite_attempt_id" IS NOT NULL
attempt_cycle_starts: INDEX (organization_id ASC, cycle_command_id ASC, started_at ASC, id ASC)
attempt_step_history: INDEX (organization_id ASC, execution_id ASC, step_id ASC, number ASC)
attempt_subject_evidence: INDEX (organization_id ASC, subject_attempt_id ASC, kind ASC)
attempt_conflict_monitor: INDEX (recorded_at ASC, organization_id ASC, id ASC) WHERE "actions"."execution_attempt"."kind" = 'conflicting_completion'
attempt_tenant_identity: UNIQUE (organization_id, id)
attempt_execution_identity: UNIQUE (organization_id, execution_id, id)
attempt_step_identity: UNIQUE (organization_id, execution_id, step_id, id)
attempt_number_unique: UNIQUE (organization_id, step_id, number)
attempt_step_scope: (organization_id, execution_id, step_id) → actions.execution_step (organization_id, execution_id, id)
attempt_subject_scope: (organization_id, execution_id, step_id, subject_attempt_id) → actions.execution_attempt (organization_id, execution_id, step_id, id)
attempt_input_scope: (organization_id, execution_id, input_attempt_id) → actions.execution_attempt (organization_id, execution_id, id)
attempt_prewrite_scope: (organization_id, execution_id, prewrite_attempt_id) → actions.execution_attempt (organization_id, execution_id, id)
attempt_planned_write_scope: (organization_id, execution_id, planned_write_step_id) → actions.execution_step (organization_id, execution_id, id)
attempt_cycle_scope: (organization_id, execution_id, step_id, cycle_command_id) → actions.command (organization_id, progress_execution_id, progress_step_id, id)
attempt_evidence_command_scope: (organization_id, evidence_command_id) → actions.command (organization_id, id)
attempt_observation_scope: (organization_id, observation_revision_id) → actions.revision (organization_id, id)
attempt_parent_revision_scope: (organization_id, input_parent_revision_id) → actions.revision (organization_id, id)
attempt_output_revision_scope: (organization_id, output_revision_id) → actions.revision (organization_id, id)
attempt_identity_nonempty: length("actions"."execution_attempt"."id") > 0 AND length("actions"."execution_attempt"."execution_id") > 0 AND length("actions"."execution_attempt"."step_id") > 0
attempt_counters: "actions"."execution_attempt"."number" > 0 AND "actions"."execution_attempt"."claim_generation" > 0 AND ("actions"."execution_attempt"."finalized_claim_generation" IS NULL OR "actions"."execution_attempt"."finalized_claim_generation" > 0) AND ("actions"."execution_attempt"."resource_guard_generation" IS NULL OR "actions"."execution_attempt"."resource_guard_generation" > 0)
attempt_finish_shape: ("actions"."execution_attempt"."finished_at" IS NULL) = ("actions"."execution_attempt"."result" IS NULL) AND ("actions"."execution_attempt"."finished_at" IS NULL OR "actions"."execution_attempt"."finished_at" >= "actions"."execution_attempt"."started_at")
attempt_reason_shape: ("actions"."execution_attempt"."result" IS NOT DISTINCT FROM 'known_not_applied') = ("actions"."execution_attempt"."non_application_basis" IS NOT NULL) AND ("actions"."execution_attempt"."result" IS NOT DISTINCT FROM 'known_not_applied') = ("actions"."execution_attempt"."retry_disposition" IS NOT NULL) AND ("actions"."execution_attempt"."result" IS NOT DISTINCT FROM 'uncertain') = ("actions"."execution_attempt"."uncertainty_reason" IS NOT NULL) AND ("actions"."execution_attempt"."result" IS NOT DISTINCT FROM 'unreadable') = ("actions"."execution_attempt"."unreadable_reason" IS NOT NULL)
attempt_fingerprint_shape: ("actions"."execution_attempt"."semantic_fingerprint" IS NULL) = ("actions"."execution_attempt"."fingerprint_version" IS NULL) AND ("actions"."execution_attempt"."semantic_fingerprint" IS NULL OR ("actions"."execution_attempt"."semantic_fingerprint" ~ '^[0-9a-f]{64}$' AND "actions"."execution_attempt"."fingerprint_version" > 0))
attempt_observation_shape: num_nonnulls("actions"."execution_attempt"."observation_revision_id", "actions"."execution_attempt"."comparison_version", "actions"."execution_attempt"."observation_surface", "actions"."execution_attempt"."observation_completeness") IN (0,4) AND ("actions"."execution_attempt"."comparison_version" IS NULL OR "actions"."execution_attempt"."comparison_version" > 0)
attempt_subject_shape: ("actions"."execution_attempt"."kind" IN ('readback','manual_observation','late_evidence','conflicting_completion')) = ("actions"."execution_attempt"."subject_attempt_id" IS NOT NULL) AND "actions"."execution_attempt"."id" IS DISTINCT FROM "actions"."execution_attempt"."subject_attempt_id" AND "actions"."execution_attempt"."id" IS DISTINCT FROM "actions"."execution_attempt"."input_attempt_id" AND "actions"."execution_attempt"."id" IS DISTINCT FROM "actions"."execution_attempt"."prewrite_attempt_id"
attempt_cycle_shape: ("actions"."execution_attempt"."kind" IN ('readback','inspection')) = ("actions"."execution_attempt"."cycle_command_id" IS NOT NULL)
attempt_inspection_shape: "actions"."execution_attempt"."kind" IN ('late_evidence','conflicting_completion') OR (
    ("actions"."execution_attempt"."kind" = 'inspection') = ("actions"."execution_attempt"."inspection_purpose" IS NOT NULL)
    AND ("actions"."execution_attempt"."inspection_purpose" IS NOT DISTINCT FROM 'prewrite') = ("actions"."execution_attempt"."planned_write_step_id" IS NOT NULL)
    AND ("actions"."execution_attempt"."kind" = 'write' OR "actions"."execution_attempt"."inspection_purpose" IS NOT DISTINCT FROM 'prewrite') = ("actions"."execution_attempt"."resource_guard_generation" IS NOT NULL)
    AND ("actions"."execution_attempt"."prewrite_attempt_id" IS NULL OR "actions"."execution_attempt"."kind" = 'write'))
attempt_capture_shape: ("actions"."execution_attempt"."kind" = 'conflicting_completion') = ("actions"."execution_attempt"."capture_digest" IS NOT NULL) AND ("actions"."execution_attempt"."capture_digest" IS NULL) = ("actions"."execution_attempt"."capture_digest_version" IS NULL) AND ("actions"."execution_attempt"."capture_digest" IS NULL OR ("actions"."execution_attempt"."capture_digest" ~ '^[0-9a-f]{64}$' AND "actions"."execution_attempt"."capture_digest_version" = 1))
attempt_fence_shape: CASE WHEN "actions"."execution_attempt"."kind" IN ('late_evidence','conflicting_completion') THEN "actions"."execution_attempt"."finished_at" IS NOT NULL AND "actions"."execution_attempt"."finalized_claim_generation" IS NULL AND "actions"."execution_attempt"."finalized_claim_token" IS NULL ELSE ("actions"."execution_attempt"."finished_at" IS NOT NULL) = ("actions"."execution_attempt"."finalized_claim_generation" IS NOT NULL) AND ("actions"."execution_attempt"."finalized_claim_generation" IS NULL) = ("actions"."execution_attempt"."finalized_claim_token" IS NULL) END
attempt_evidence_command_shape: CASE WHEN "actions"."execution_attempt"."kind" IN ('late_evidence','conflicting_completion','manual_observation') THEN "actions"."execution_attempt"."evidence_command_id" IS NOT NULL AND "actions"."execution_attempt"."finished_at" IS NOT NULL WHEN "actions"."execution_attempt"."kind" = 'inspection' AND "actions"."execution_attempt"."result" IS NOT DISTINCT FROM 'unreadable' AND "actions"."execution_attempt"."unreadable_reason" IS NOT DISTINCT FROM 'cancelled' THEN "actions"."execution_attempt"."evidence_command_id" IS NOT NULL AND "actions"."execution_attempt"."finished_at" IS NOT NULL ELSE "actions"."execution_attempt"."evidence_command_id" IS NULL END
attempt_unfinished_empty: "actions"."execution_attempt"."finished_at" IS NOT NULL OR num_nonnulls("actions"."execution_attempt"."failure_class","actions"."execution_attempt"."terminal_outcome","actions"."execution_attempt"."semantic_fingerprint","actions"."execution_attempt"."fingerprint_version","actions"."execution_attempt"."observation_revision_id","actions"."execution_attempt"."output_kind") = 0
attempt_result_marks: CASE
    WHEN "actions"."execution_attempt"."result" IS NULL THEN "actions"."execution_attempt"."terminal_outcome" IS NULL AND "actions"."execution_attempt"."semantic_fingerprint" IS NULL
    WHEN "actions"."execution_attempt"."kind" IN ('late_evidence','conflicting_completion') THEN true
    WHEN "actions"."execution_attempt"."kind" = 'write' THEN "actions"."execution_attempt"."result" IN ('acknowledged','known_not_applied','uncertain') AND "actions"."execution_attempt"."terminal_outcome" IS NULL AND "actions"."execution_attempt"."semantic_fingerprint" IS NULL
    WHEN "actions"."execution_attempt"."kind" = 'generation' THEN "actions"."execution_attempt"."result" IN ('generated','discarded','known_not_applied','uncertain') AND "actions"."execution_attempt"."terminal_outcome" IS NULL AND "actions"."execution_attempt"."semantic_fingerprint" IS NULL
    WHEN "actions"."execution_attempt"."kind" = 'readback' AND "actions"."execution_attempt"."result" IN ('matched','matched_external','mismatch') THEN "actions"."execution_attempt"."semantic_fingerprint" IS NOT NULL AND "actions"."execution_attempt"."terminal_outcome" IS NOT NULL
    WHEN "actions"."execution_attempt"."kind" = 'readback' AND "actions"."execution_attempt"."result" = 'known_not_applied' THEN "actions"."execution_attempt"."semantic_fingerprint" IS NULL AND "actions"."execution_attempt"."terminal_outcome" IS NOT DISTINCT FROM true
    WHEN "actions"."execution_attempt"."kind" = 'inspection' AND "actions"."execution_attempt"."result" IN ('matched','mismatch') THEN "actions"."execution_attempt"."semantic_fingerprint" IS NOT NULL AND "actions"."execution_attempt"."terminal_outcome" IS NOT DISTINCT FROM false
    WHEN "actions"."execution_attempt"."kind" = 'manual_observation' AND "actions"."execution_attempt"."result" IN ('matched_external','mismatch') THEN "actions"."execution_attempt"."semantic_fingerprint" IS NOT NULL AND "actions"."execution_attempt"."terminal_outcome" IS NULL
    WHEN "actions"."execution_attempt"."kind" IN ('readback','inspection','manual_observation') AND "actions"."execution_attempt"."result" = 'unreadable' THEN "actions"."execution_attempt"."semantic_fingerprint" IS NULL AND "actions"."execution_attempt"."terminal_outcome" IS NULL
    ELSE false END
attempt_verified_observation: "actions"."execution_attempt"."result" IS NULL OR ("actions"."execution_attempt"."result" NOT IN ('matched','matched_external','mismatch') AND NOT ("actions"."execution_attempt"."kind" = 'readback' AND "actions"."execution_attempt"."result" = 'known_not_applied')) OR ("actions"."execution_attempt"."observation_revision_id" IS NOT NULL AND "actions"."execution_attempt"."observation_completeness" IS NOT DISTINCT FROM 'complete')
attempt_output_shape: ("actions"."execution_attempt"."result" IS DISTINCT FROM 'generated' OR "actions"."execution_attempt"."output_kind" IS NOT NULL)
    AND ("actions"."execution_attempt"."output_kind" IS NULL OR ("actions"."execution_attempt"."result" IS NOT NULL AND "actions"."execution_attempt"."result" IN ('generated','discarded')))
    AND CASE WHEN "actions"."execution_attempt"."output_kind" IS NULL THEN num_nonnulls("actions"."execution_attempt"."output_revision_id","actions"."execution_attempt"."output_review_analysis_id","actions"."execution_attempt"."output_agent_run_id","actions"."execution_attempt"."no_work_reason") = 0
    WHEN "actions"."execution_attempt"."output_kind" = 'revision' THEN "actions"."execution_attempt"."output_revision_id" IS NOT NULL AND num_nonnulls("actions"."execution_attempt"."output_review_analysis_id","actions"."execution_attempt"."output_agent_run_id","actions"."execution_attempt"."no_work_reason") = 0
    WHEN "actions"."execution_attempt"."output_kind" = 'review_analysis' THEN "actions"."execution_attempt"."output_review_analysis_id" IS NOT NULL AND num_nonnulls("actions"."execution_attempt"."output_revision_id","actions"."execution_attempt"."output_agent_run_id","actions"."execution_attempt"."no_work_reason") = 0
    WHEN "actions"."execution_attempt"."output_kind" = 'agent_run' THEN "actions"."execution_attempt"."output_agent_run_id" IS NOT NULL AND num_nonnulls("actions"."execution_attempt"."output_revision_id","actions"."execution_attempt"."output_review_analysis_id","actions"."execution_attempt"."no_work_reason") = 0
    WHEN "actions"."execution_attempt"."output_kind" = 'no_work' THEN "actions"."execution_attempt"."no_work_reason" IS NOT NULL AND "actions"."execution_attempt"."agent_run_id" IS NOT NULL AND num_nonnulls("actions"."execution_attempt"."output_revision_id","actions"."execution_attempt"."output_review_analysis_id","actions"."execution_attempt"."output_agent_run_id") = 0 ELSE false END
attempt_parent_context_shape: "actions"."execution_attempt"."input_parent_revision_id" IS NULL OR "actions"."execution_attempt"."kind" IN ('generation','late_evidence','conflicting_completion')
attempt_instant_bounds: ("actions"."execution_attempt"."started_at" IS NULL OR "actions"."execution_attempt"."started_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."execution_attempt"."recorded_at" IS NULL OR "actions"."execution_attempt"."recorded_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."execution_attempt"."finished_at" IS NULL OR "actions"."execution_attempt"."finished_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)
```

## `actions.resource_guard`

A stable global resource identity with one unresolved Fload writer.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `id` | uuid | No | PK; Default: gen_random_uuid() |
| `provider` | provider: internal, app_store_connect, google_play, apple_search_ads | No | — |
| `resource_key` | text | No | — |
| `key_version` | integer | No | — |
| `holder_organization_id` | text | Yes | FK → actions.execution.organization_id |
| `holder_execution_id` | text | Yes | FK → actions.execution.id |
| `acquired_at` | timestamp with time zone | Yes | — |
| `acquisition_generation` | bigint | No | Default: 0 |

```sql
resource_guard_global_identity: UNIQUE (provider, resource_key)
resource_guard_holder_scope: (holder_organization_id, holder_execution_id) → actions.execution (organization_id, id)
resource_guard_key_shape: "actions"."resource_guard"."provider" <> 'internal' AND length("actions"."resource_guard"."resource_key") > 0 AND "actions"."resource_guard"."key_version" = 1
resource_guard_holder_shape: ("actions"."resource_guard"."holder_organization_id" IS NULL) = ("actions"."resource_guard"."holder_execution_id" IS NULL) AND ("actions"."resource_guard"."holder_execution_id" IS NULL) = ("actions"."resource_guard"."acquired_at" IS NULL)
resource_guard_generation_shape: "actions"."resource_guard"."acquisition_generation" >= 0 AND ("actions"."resource_guard"."holder_execution_id" IS NULL OR "actions"."resource_guard"."acquisition_generation" > 0)
resource_guard_instant_bounds: ("actions"."resource_guard"."acquired_at" IS NULL OR "actions"."resource_guard"."acquired_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)
```

## `agent_work.attention_advisory`

Typed agent-attention content, independent of personal reads.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `organization_id` | text | No | PK; FK → actions.revision.organization_id |
| `revision_id` | text | No | PK; FK → actions.revision.id |
| `purpose` | revision_purpose: proposal, baseline, observation, historical | No | FK → actions.revision.purpose |
| `agent_source_id` | text | No | — |
| `agent_type` | attention_agent_type: orchestrator, review, aso, custom | No | — |
| `last_error` | text | No | — |
| `consecutive_failures` | integer | No | — |

```sql
attention_advisory_organization_id_revision_id_pk: PRIMARY KEY (organization_id, revision_id)
attention_revision_scope: (organization_id, revision_id, purpose) → actions.revision (organization_id, id, purpose)
attention_proposal_only: "agent_work"."attention_advisory"."purpose" = 'proposal'
attention_failure_count: "agent_work"."attention_advisory"."consecutive_failures" >= 0
```

## `review_work.reply_content`

Exact review and reply values for proposals, baselines, and observations.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `organization_id` | text | No | PK; FK → actions.revision.organization_id; FK → review_work.reply_content.organization_id |
| `revision_id` | text | No | PK; FK → actions.revision.id |
| `purpose` | revision_purpose: proposal, baseline, observation, historical | No | FK → actions.revision.purpose |
| `store` | store: ios, android | No | — |
| `provider_app_id` | text | No | — |
| `provider_review_id` | text | No | — |
| `intent` | reply_intent: send, update | Yes | — |
| `reply_text` | text | Yes | — |
| `original_ai_revision_id` | text | Yes | FK → review_work.reply_content.revision_id |
| `detected_language_name` | text | Yes | — |
| `review_snapshot_availability` | snapshot_availability: present, absent, unreadable, unknown | No | — |
| `review_rating` | integer | Yes | — |
| `review_title` | text | Yes | — |
| `review_body` | text | Yes | — |
| `review_nickname` | text | Yes | — |
| `review_storefront` | text | Yes | — |
| `review_app_version` | text | Yes | — |
| `review_created_at` | timestamp with time zone | Yes | — |
| `review_modified_at` | timestamp with time zone | Yes | — |
| `review_edited` | boolean | Yes | — |
| `captured_at` | timestamp with time zone | Yes | — |
| `response_availability` | response_availability: present, absent, unreadable, pending, unknown | Yes | — |
| `response_text` | text | Yes | — |
| `response_modified_at` | timestamp with time zone | Yes | — |
| `response_hidden` | boolean | Yes | — |
| `publication_state` | publication_state: published, pending_publication, hidden, deleted, unreadable | Yes | — |

```sql
reply_content_organization_id_revision_id_pk: PRIMARY KEY (organization_id, revision_id)
review_content_revision_scope: (organization_id, revision_id, purpose) → actions.revision (organization_id, id, purpose)
review_content_original_ai_scope: (organization_id, original_ai_revision_id) → review_work.reply_content (organization_id, revision_id)
review_content_identity: length("review_work"."reply_content"."provider_app_id") > 0 AND length("review_work"."reply_content"."provider_review_id") > 0 AND "review_work"."reply_content"."original_ai_revision_id" IS DISTINCT FROM "review_work"."reply_content"."revision_id"
review_content_purpose: "review_work"."reply_content"."purpose" IN ('proposal', 'baseline', 'observation')
review_content_proposal_shape: "review_work"."reply_content"."purpose" <> 'proposal' OR (
    "review_work"."reply_content"."intent" IS NOT NULL AND "review_work"."reply_content"."reply_text" IS NOT NULL AND length("review_work"."reply_content"."reply_text") > 0
    AND "review_work"."reply_content"."review_snapshot_availability" = 'present'
    AND "review_work"."reply_content"."captured_at" IS NULL AND "review_work"."reply_content"."response_availability" IS NULL AND "review_work"."reply_content"."response_text" IS NULL
    AND "review_work"."reply_content"."response_modified_at" IS NULL AND "review_work"."reply_content"."response_hidden" IS NULL AND "review_work"."reply_content"."publication_state" IS NULL)
review_content_observed_shape: "review_work"."reply_content"."purpose" = 'proposal' OR (
    "review_work"."reply_content"."intent" IS NULL AND "review_work"."reply_content"."reply_text" IS NULL AND "review_work"."reply_content"."original_ai_revision_id" IS NULL AND "review_work"."reply_content"."detected_language_name" IS NULL
    AND "review_work"."reply_content"."captured_at" IS NOT NULL AND "review_work"."reply_content"."response_availability" IS NOT NULL)
review_content_response_shape: "review_work"."reply_content"."purpose" = 'proposal' OR (
    ("review_work"."reply_content"."response_availability" = 'present' AND "review_work"."reply_content"."response_text" IS NOT NULL AND "review_work"."reply_content"."publication_state" IS NOT NULL)
    OR ("review_work"."reply_content"."response_availability" <> 'present' AND "review_work"."reply_content"."response_text" IS NULL AND "review_work"."reply_content"."response_modified_at" IS NULL
      AND "review_work"."reply_content"."response_hidden" IS NULL AND "review_work"."reply_content"."publication_state" IS NULL))
review_content_snapshot_shape: (
    "review_work"."reply_content"."review_snapshot_availability" = 'present' AND "review_work"."reply_content"."review_rating" IS NOT NULL AND "review_work"."reply_content"."review_title" IS NOT NULL
    AND "review_work"."reply_content"."review_body" IS NOT NULL AND "review_work"."reply_content"."review_nickname" IS NOT NULL
  ) OR (
    "review_work"."reply_content"."review_snapshot_availability" <> 'present' AND "review_work"."reply_content"."review_rating" IS NULL AND "review_work"."reply_content"."review_title" IS NULL
    AND "review_work"."reply_content"."review_body" IS NULL AND "review_work"."reply_content"."review_nickname" IS NULL AND "review_work"."reply_content"."review_storefront" IS NULL
    AND "review_work"."reply_content"."review_app_version" IS NULL AND "review_work"."reply_content"."review_created_at" IS NULL AND "review_work"."reply_content"."review_modified_at" IS NULL AND "review_work"."reply_content"."review_edited" IS NULL
  )
review_content_rating: "review_work"."reply_content"."review_rating" IS NULL OR "review_work"."reply_content"."review_rating" BETWEEN 1 AND 5
review_content_instant_range: ("review_work"."reply_content"."review_created_at" IS NULL OR "review_work"."reply_content"."review_created_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("review_work"."reply_content"."review_modified_at" IS NULL OR "review_work"."reply_content"."review_modified_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("review_work"."reply_content"."response_modified_at" IS NULL OR "review_work"."reply_content"."response_modified_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("review_work"."reply_content"."captured_at" IS NULL OR "review_work"."reply_content"."captured_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)
```

## `app_store_connect.review_target`

Exact native review/response identities, selected source link and connector, and the actual individual or team signing principal. No inferred Apple account ID.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `organization_id` | text | No | PK; FK → actions.revision.organization_id |
| `revision_id` | text | No | PK; FK → actions.revision.id |
| `purpose` | revision_purpose: proposal, baseline, observation, historical | No | FK → actions.revision.purpose |
| `source_asset_data_source_id` | text | No | — |
| `source_connector_id` | text | No | — |
| `credential_kind` | review_credential_kind: individual, team | No | — |
| `credential_key_id` | text | No | — |
| `credential_team_issuer_id` | text | Yes | — |
| `review_resource_id` | text | Yes | — |
| `response_id` | text | Yes | — |
| `native_state_source` | review_native_state_source: api_publication, browser_pending | Yes | — |
| `native_state` | review_native_state: PUBLISHED, PENDING_PUBLISH, NONE, PENDING_CREATE, PENDING_UPDATE, PENDING_DELETE | Yes | — |

```sql
review_target_organization_id_revision_id_pk: PRIMARY KEY (organization_id, revision_id)
asc_review_revision_scope: (organization_id, revision_id, purpose) → actions.revision (organization_id, id, purpose)
asc_review_target_purpose: "app_store_connect"."review_target"."purpose" IN ('proposal', 'baseline', 'observation')
asc_review_target_identity: length("app_store_connect"."review_target"."source_asset_data_source_id") > 0 AND length("app_store_connect"."review_target"."source_connector_id") > 0 AND length("app_store_connect"."review_target"."credential_key_id") > 0
        AND ("app_store_connect"."review_target"."review_resource_id" IS NULL OR length("app_store_connect"."review_target"."review_resource_id") > 0) AND ("app_store_connect"."review_target"."response_id" IS NULL OR length("app_store_connect"."review_target"."response_id") > 0)
asc_review_target_credential_shape: ("app_store_connect"."review_target"."credential_kind" = 'individual' AND "app_store_connect"."review_target"."credential_team_issuer_id" IS NULL)
          OR ("app_store_connect"."review_target"."credential_kind" = 'team' AND "app_store_connect"."review_target"."credential_team_issuer_id" IS NOT NULL AND length("app_store_connect"."review_target"."credential_team_issuer_id") > 0)
asc_review_target_proposal_state: "app_store_connect"."review_target"."purpose" <> 'proposal' OR ("app_store_connect"."review_target"."native_state" IS NULL AND "app_store_connect"."review_target"."native_state_source" IS NULL)
asc_review_target_state_source: 
        ("app_store_connect"."review_target"."native_state" IS NULL OR "app_store_connect"."review_target"."native_state_source" IS NOT NULL)
        AND ("app_store_connect"."review_target"."native_state_source" IS DISTINCT FROM 'api_publication' OR "app_store_connect"."review_target"."native_state" IS NULL OR "app_store_connect"."review_target"."native_state" IN ('PUBLISHED', 'PENDING_PUBLISH'))
        AND ("app_store_connect"."review_target"."native_state_source" IS DISTINCT FROM 'browser_pending' OR "app_store_connect"."review_target"."native_state" IS NULL OR "app_store_connect"."review_target"."native_state" IN ('NONE', 'PENDING_CREATE', 'PENDING_UPDATE', 'PENDING_DELETE'))
```

## `google_play.review_target`

Google-owned account identity for a retained review revision.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `organization_id` | text | No | PK; FK → actions.revision.organization_id |
| `revision_id` | text | No | PK; FK → actions.revision.id |
| `purpose` | revision_purpose: proposal, baseline, observation, historical | No | FK → actions.revision.purpose |
| `provider_account_id` | text | No | — |

```sql
review_target_organization_id_revision_id_pk: PRIMARY KEY (organization_id, revision_id)
play_review_revision_scope: (organization_id, revision_id, purpose) → actions.revision (organization_id, id, purpose)
play_review_target_purpose: "google_play"."review_target"."purpose" IN ('proposal', 'baseline', 'observation')
play_review_target_identity: length("google_play"."review_target"."provider_account_id") > 0
```

## `app_store_connect.attempt_receipt`

The immutable native HTTP response attached to one admitted attempt.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `organization_id` | text | No | PK; FK → actions.execution_attempt.organization_id |
| `attempt_id` | text | No | PK; FK → actions.execution_attempt.id |
| `transport` | review_receipt_transport: asc_api | No | — |
| `response_kind` | review_receipt_kind: accepted, deleted, http_error, invalid_response | No | — |
| `response_status` | integer | No | — |
| `provider_resource_id` | text | Yes | — |
| `response_body` | text | Yes | — |
| `native_state` | review_native_state: PUBLISHED, PENDING_PUBLISH, NONE, PENDING_CREATE, PENDING_UPDATE, PENDING_DELETE | Yes | — |
| `error_code` | text | Yes | — |

```sql
attempt_receipt_organization_id_attempt_id_pk: PRIMARY KEY (organization_id, attempt_id)
asc_receipt_attempt_scope: (organization_id, attempt_id) → actions.execution_attempt (organization_id, id)
asc_receipt_status: "app_store_connect"."attempt_receipt"."response_status" BETWEEN 100 AND 599
asc_receipt_identity: ("app_store_connect"."attempt_receipt"."provider_resource_id" IS NULL OR length("app_store_connect"."attempt_receipt"."provider_resource_id") > 0) AND ("app_store_connect"."attempt_receipt"."error_code" IS NULL OR length("app_store_connect"."attempt_receipt"."error_code") > 0)
asc_receipt_native_shape: CASE "app_store_connect"."attempt_receipt"."response_kind"
    WHEN 'accepted' THEN "app_store_connect"."attempt_receipt"."response_status"=201 AND "app_store_connect"."attempt_receipt"."provider_resource_id" IS NOT NULL AND "app_store_connect"."attempt_receipt"."error_code" IS NULL AND ("app_store_connect"."attempt_receipt"."native_state" IS NULL OR "app_store_connect"."attempt_receipt"."native_state" IN ('PUBLISHED','PENDING_PUBLISH'))
    WHEN 'deleted' THEN "app_store_connect"."attempt_receipt"."response_status"=204 AND num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state","app_store_connect"."attempt_receipt"."error_code")=0
    WHEN 'http_error' THEN "app_store_connect"."attempt_receipt"."response_status">=400 AND num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state")=0
    WHEN 'invalid_response' THEN num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state","app_store_connect"."attempt_receipt"."error_code")=0
    ELSE false END
```

## `composition.operation_contract`

The immutable routing and policy definition selected by a versioned recipe.

| Field | SQL type / enum | Nullable | Key / default |
| --- | --- | --- | --- |
| `id` | text | No | PK |
| `provider` | provider: internal, app_store_connect, google_play, apple_search_ads | No | — |
| `operation_key` | text | No | — |
| `contract_version` | integer | No | — |
| `expansion` | expansion: ordinary, expansion | No | — |
| `default_required_surface` | required_surface: provider_response, editable_listing, live_listing, review_response, advertising_resource, internal_artifact | No | — |
| `default_verification_timing` | verification_timing: before_successor, after_effects | No | — |
| `terminal_on_acknowledgement` | boolean | No | — |
| `resource_scope_kind` | resource_scope: none, store_application, advertising_account | No | — |
| `max_observations` | integer | No | — |
| `observation_window_ms` | integer | No | — |
| `backoff_initial_ms` | integer | No | — |
| `backoff_max_ms` | integer | No | — |
| `backoff_factor` | double precision | No | — |
| `registered_at` | timestamp with time zone | No | Default: now() |

```sql
operation_semantic_identity: UNIQUE (provider, operation_key, contract_version)
operation_id_version: "composition"."operation_contract"."contract_version" > 0 AND "composition"."operation_contract"."id" ~ '^[a-z][a-z0-9_.-]*@[1-9][0-9]*$' AND "composition"."operation_contract"."id" LIKE ('%@' || "composition"."operation_contract"."contract_version"::text)
operation_key_shape: "composition"."operation_contract"."operation_key" ~ '^[a-z][a-z0-9_.-]*$'
operation_positive_policy: "composition"."operation_contract"."max_observations" > 0 AND "composition"."operation_contract"."observation_window_ms" > 0 AND "composition"."operation_contract"."backoff_initial_ms" > 0 AND "composition"."operation_contract"."backoff_max_ms" >= "composition"."operation_contract"."backoff_initial_ms" AND "composition"."operation_contract"."backoff_factor" >= 1 AND "composition"."operation_contract"."backoff_factor" < 'Infinity'::double precision
```

