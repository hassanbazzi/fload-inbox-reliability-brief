# Fload inbox — actual proposed fields

16 September 2026 · FLO-1355 · Main source baseline f0b1af5fc

**31 physical tables · 497 fields · 3 relational views · four PostgreSQL schemas.**

Exported from the exact repository migrations applied to an isolated synthetic test database. This is the paused prototype’s proposed schema, not the deployed schema. Full implementation and migration cutover remain incomplete.

The public catalog format is JSON for browser distribution. The database model has no JSON/JSONB, array or arbitrary key/value columns. No customer rows are included.

[Walkthrough](Fload-Inbox-End-to-End-Specification.md) · [Migration plan](Fload-Migration-and-Data-Plan.md) · [Validation checkpoint](Fload-Implementation-Checkpoint.md)

## Identity & personal attention

### actions.action

One permanent organization-owned ticket. A parent is also a ticket. Its current revision and approval are pointers into retained history.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| id | `text` | no |  |
| organization_id | `text` | no |  |
| creation_key | `uuid` | no | gen_random_uuid() |
| asset_id | `text` | yes |  |
| domain | `text` | no |  |
| parent_action_id | `text` | yes |  |
| decision | `actions.action_decision` | no | 'open'::actions.action_decision |
| version | `bigint` | no | 1 |
| attention_version | `bigint` | no | 1 |
| current_revision_id | `text` | yes |  |
| current_approval_id | `text` | yes |  |
| owner_user_id | `text` | yes |  |
| priority | `smallint` | no | 2 |
| snoozed_until | `timestamp with time zone` | yes |  |
| archived_at | `timestamp with time zone` | yes |  |
| successor_action_id | `text` | yes |  |
| created_at | `timestamp with time zone` | no |  |
| updated_at | `timestamp with time zone` | no |  |
| last_command_id | `text` | no |  |

Keys and constraints:

- `action_asset_id_fkey`: `FOREIGN KEY (asset_id) REFERENCES asset(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_attention_version_check`: `CHECK (attention_version > 0)`
- `action_check`: `CHECK (updated_at >= created_at)`
- `action_check1`: `CHECK ((decision = 'superseded'::actions.action_decision) = (successor_action_id IS NOT NULL))`
- `action_check2`: `CHECK (successor_action_id IS DISTINCT FROM id)`
- `action_check3`: `CHECK (parent_action_id IS DISTINCT FROM id)`
- `action_command_head`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_domain_check`: `CHECK (domain = ANY (ARRAY['reviews'::text, 'listing'::text, 'ads'::text, 'agent'::text, 'advisory'::text, 'collection'::text]))`
- `action_graph_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_last_command_fk`: `FOREIGN KEY (organization_id, last_command_id) REFERENCES actions.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_organization_id_creation_key_key`: `UNIQUE (organization_id, creation_key)`
- `action_organization_id_fkey`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_organization_id_id_current_approval_id_fkey`: `FOREIGN KEY (organization_id, id, current_approval_id) REFERENCES actions.action_approval(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_organization_id_id_current_revision_id_fkey`: `FOREIGN KEY (organization_id, id, current_revision_id) REFERENCES actions.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_organization_id_id_key`: `UNIQUE (organization_id, id)`
- `action_organization_id_parent_action_id_fkey`: `FOREIGN KEY (organization_id, parent_action_id) REFERENCES actions.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_organization_id_successor_action_id_fkey`: `FOREIGN KEY (organization_id, successor_action_id) REFERENCES actions.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_owner_user_id_fkey`: `FOREIGN KEY (owner_user_id) REFERENCES "user"(id) ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_pkey`: `PRIMARY KEY (id)`
- `action_priority_check`: `CHECK (priority >= 1 AND priority <= 3)`
- `action_version_check`: `CHECK (version > 0)`

### actions.action_revision

One immutable proposal, baseline or observation. Revision numbers cover all three; a new proposal requires new authorization.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| id | `text` | no |  |
| organization_id | `text` | no |  |
| action_id | `text` | no |  |
| purpose | `actions.action_revision_purpose` | no |  |
| kind | `text` | no |  |
| operation | `text` | no |  |
| revision_number | `bigint` | no |  |
| authored_command_id | `text` | no |  |
| baseline_revision_id | `text` | yes |  |
| generated_from_revision_id | `text` | yes |  |
| title | `text` | no |  |
| summary | `text` | no |  |
| rationale | `text` | yes |  |
| content_digest | `character(64)` | no |  |
| canonicalization_version | `integer` | no |  |
| sealed | `boolean` | no | false |
| created_at | `timestamp with time zone` | no |  |

Keys and constraints:

- `action_revision_action_id_revision_number_key`: `UNIQUE (action_id, revision_number)`
- `action_revision_canonicalization_version_check`: `CHECK (canonicalization_version > 0)`
- `action_revision_check`: `CHECK (id IS DISTINCT FROM baseline_revision_id AND id IS DISTINCT FROM generated_from_revision_id)`
- `action_revision_content_digest_check`: `CHECK (content_digest ~ '^[0-9a-f]{64}$'::text)`
- `action_revision_organization_id_action_id_baseline_revisio_fkey`: `FOREIGN KEY (organization_id, action_id, baseline_revision_id) REFERENCES actions.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_revision_organization_id_action_id_fkey`: `FOREIGN KEY (organization_id, action_id) REFERENCES actions.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_revision_organization_id_action_id_generated_from_r_fkey`: `FOREIGN KEY (organization_id, action_id, generated_from_revision_id) REFERENCES actions.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_revision_organization_id_action_id_id_key`: `UNIQUE (organization_id, action_id, id)`
- `action_revision_organization_id_authored_command_id_fkey`: `FOREIGN KEY (organization_id, authored_command_id) REFERENCES actions.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_revision_organization_id_id_key`: `UNIQUE (organization_id, id)`
- `action_revision_pkey`: `PRIMARY KEY (id)`
- `action_revision_revision_number_check`: `CHECK (revision_number > 0)`
- `actionsSchema_action_revision_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `provider_content_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `revision_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `revision_kind_closed`: `CHECK (kind = ANY (ARRAY['review_reply'::text, 'listing'::text, 'request'::text, 'ads'::text, 'advisory'::text, 'collection'::text]))`
- `revision_operation_closed`: `CHECK (kind = 'review_reply'::text AND operation = 'post_reply'::text OR kind = 'listing'::text AND (operation = ANY (ARRAY['apply_listing_changes'::text, 'update_promo_text'::text, 'create_locale'::text, 'update_description'::text, 'update_short_description'::text, 'revert_experiment'::text, 'aso_revert_listing'::text])) OR kind = 'request'::text AND (operation = ANY (ARRAY['generate_locale'::text, 'generate_listing'::text, 'review_catch_up_30d'::text, 'generate_review_analysis'::text, 'run_agent'::text])) OR kind = 'ads'::text AND (operation = ANY (ARRAY['asa_pause_campaign'::text, 'asa_enable_campaign'::text, 'asa_update_campaign_budget'::text, 'asa_update_keyword_bid'::text, 'asa_create_keyword'::text, 'asa_add_negative_keyword'::text, 'asa_delete_negative_keyword'::text])) OR kind = 'advisory'::text AND (operation = ANY (ARRAY['acknowledge'::text, 'resolve_prerequisite'::text])) OR kind = 'collection'::text AND (operation = ANY (ARRAY['post_batch'::text, 'apply_listing_changes'::text, 'localize'::text, 'asa_update_keyword_bid'::text, 'revert_experiment'::text, 'aso_revert_listing'::text])))`

### actions.action_membership

One child at one ordinal of one parent revision, pinned to an exact child revision. Structural parent identity is separate from approved membership.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| parent_revision_id | `text` | no |  |
| child_action_id | `text` | no |  |
| child_revision_id | `text` | no |  |
| ordinal | `integer` | no |  |

Keys and constraints:

- `action_membership_ordinal_check`: `CHECK (ordinal >= 0)`
- `action_membership_organization_id_child_action_id_child_re_fkey`: `FOREIGN KEY (organization_id, child_action_id, child_revision_id) REFERENCES actions.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_membership_organization_id_parent_revision_id_child__key`: `UNIQUE (organization_id, parent_revision_id, child_action_id, child_revision_id)`
- `action_membership_organization_id_parent_revision_id_fkey`: `FOREIGN KEY (organization_id, parent_revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_membership_parent_revision_id_ordinal_key`: `UNIQUE (parent_revision_id, ordinal)`
- `action_membership_pkey`: `PRIMARY KEY (parent_revision_id, child_action_id)`
- `actionsSchema_action_membership_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_dependency

One typed prerequisite between tickets. Workflow changes never recreate the dependent ticket.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| dependent_action_id | `text` | no |  |
| prerequisite_action_id | `text` | no |  |
| requirement | `actions.action_dependency_requirement` | no |  |
| created_command_id | `text` | no |  |

Keys and constraints:

- `action_dependency_check`: `CHECK (dependent_action_id <> prerequisite_action_id)`
- `action_dependency_organization_id_created_command_id_fkey`: `FOREIGN KEY (organization_id, created_command_id) REFERENCES actions.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_dependency_organization_id_dependent_action_id_fkey`: `FOREIGN KEY (organization_id, dependent_action_id) REFERENCES actions.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_dependency_organization_id_prerequisite_action_id_fkey`: `FOREIGN KEY (organization_id, prerequisite_action_id) REFERENCES actions.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_dependency_pkey`: `PRIMARY KEY (dependent_action_id, prerequisite_action_id, requirement)`
- `actionsSchema_action_dependency_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `dependency_no_cycle`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_read

One member’s attention watermark for one ticket. Contains no workflow status, snooze, owner or approval.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| user_id | `text` | no |  |
| action_id | `text` | no |  |
| seen_attention_version | `bigint` | no |  |
| force_unread | `boolean` | no | false |
| updated_at | `timestamp with time zone` | no |  |

Keys and constraints:

- `action_read_organization_id_action_id_fkey`: `FOREIGN KEY (organization_id, action_id) REFERENCES actions.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_read_pkey`: `PRIMARY KEY (organization_id, user_id, action_id)`
- `action_read_seen_attention_version_check`: `CHECK (seen_attention_version >= 0)`
- `action_read_user_id_fkey`: `FOREIGN KEY (user_id) REFERENCES "user"(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `actionsSchema_action_read_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

## Decisions & attribution

### actions.action_command

One attributable idempotent command and result. Exact principal, channel and delegation are retained. Worker progress cites its execution and closed outcome.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| id | `text` | no |  |
| organization_id | `text` | no |  |
| idempotency_key | `uuid` | no |  |
| principal_kind | `actions.action_principal` | no |  |
| actor_user_id | `text` | yes |  |
| actor_api_key_id | `text` | yes |  |
| actor_agent_run_id | `text` | yes |  |
| actor_policy_revision_id | `text` | yes |  |
| target_policy_revision_id | `text` | yes |  |
| actor_subject_snapshot | `text` | no |  |
| actor_name_snapshot | `text` | yes |  |
| channel | `actions.action_channel` | no |  |
| external_actor_id | `text` | yes |  |
| kind | `actions.action_command_kind` | no |  |
| request_digest | `character(64)` | no |  |
| digest_version | `integer` | no |  |
| outcome | `actions.action_command_outcome` | no |  |
| error | `actions.action_command_error` | yes |  |
| message | `text` | yes |  |
| accepted_at | `timestamp with time zone` | no |  |
| actor_slack_integration_id | `text` | yes |  |
| actor_discord_integration_id | `text` | yes |  |
| acting_for_user_id | `text` | yes |  |
| progress_execution_id | `text` | yes |  |
| progress_phase | `actions.action_execution_phase` | yes |  |
| progress_result | `actions.action_execution_result` | yes |  |
| progress_hold_reason | `actions.action_hold_reason` | yes |  |

Keys and constraints:

- `action_command_acting_for_user_id_fkey`: `FOREIGN KEY (acting_for_user_id) REFERENCES "user"(id) ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_actor_agent_run_id_fkey`: `FOREIGN KEY (actor_agent_run_id) REFERENCES agent_run(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_actor_api_key_id_fkey`: `FOREIGN KEY (actor_api_key_id) REFERENCES api_key(id) ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_actor_discord_integration_id_fkey`: `FOREIGN KEY (actor_discord_integration_id) REFERENCES discord_integration(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_actor_slack_integration_id_fkey`: `FOREIGN KEY (actor_slack_integration_id) REFERENCES slack_integration(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_actor_user_id_fkey`: `FOREIGN KEY (actor_user_id) REFERENCES "user"(id) ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_check`: `CHECK ((outcome = 'accepted'::actions.action_command_outcome) = (error IS NULL))`
- `action_command_check1`: `CHECK (actor_user_id IS NULL OR (principal_kind = ANY (ARRAY['user'::actions.action_principal, 'api_key'::actions.action_principal])))`
- `action_command_check2`: `CHECK (actor_api_key_id IS NULL OR principal_kind = 'api_key'::actions.action_principal)`
- `action_command_check3`: `CHECK ((principal_kind = 'policy'::actions.action_principal) = (actor_policy_revision_id IS NOT NULL))`
- `action_command_check4`: `CHECK (principal_kind <> 'agent'::actions.action_principal OR actor_agent_run_id IS NOT NULL)`
- `action_command_check5`: `CHECK (outcome <> 'accepted'::actions.action_command_outcome OR (kind <> ALL (ARRAY['grant_policy'::actions.action_command_kind, 'revoke_policy'::actions.action_command_kind])) OR target_policy_revision_id IS NOT NULL)`
- `action_command_digest_version_check`: `CHECK (digest_version > 0)`
- `action_command_organization_id_actor_policy_revision_id_fkey`: `FOREIGN KEY (organization_id, actor_policy_revision_id) REFERENCES actions.action_policy_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_organization_id_fkey`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_organization_id_id_key`: `UNIQUE (organization_id, id)`
- `action_command_organization_id_principal_kind_actor_subject_key`: `UNIQUE (organization_id, principal_kind, actor_subject_snapshot, idempotency_key)`
- `action_command_organization_id_target_policy_revision_id_fkey`: `FOREIGN KEY (organization_id, target_policy_revision_id) REFERENCES actions.action_policy_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_pkey`: `PRIMARY KEY (id)`
- `action_command_progress_execution_fk`: `FOREIGN KEY (organization_id, progress_execution_id) REFERENCES actions.action_execution(organization_id, id)`
- `action_command_progress_shape`: `CHECK (kind::text = 'record_progress'::text AND progress_execution_id IS NOT NULL AND progress_phase IS NOT NULL AND (progress_phase = ANY (ARRAY['verification_due'::actions.action_execution_phase, 'uncertain'::actions.action_execution_phase, 'blocked'::actions.action_execution_phase, 'settled'::actions.action_execution_phase])) AND principal_kind = 'system'::actions.action_principal AND channel = 'worker'::actions.action_channel AND outcome = 'accepted'::actions.action_command_outcome AND (progress_phase = 'settled'::actions.action_execution_phase) = (progress_result IS NOT NULL) AND ((progress_phase <> ALL (ARRAY['blocked'::actions.action_execution_phase, 'uncertain'::actions.action_execution_phase])) OR progress_hold_reason IS NOT NULL) OR kind::text <> 'record_progress'::text AND progress_execution_id IS NULL AND progress_phase IS NULL AND progress_result IS NULL AND progress_hold_reason IS NULL)`
- `action_command_request_digest_check`: `CHECK (request_digest ~ '^[0-9a-f]{64}$'::text)`
- `command_delegation_shape`: `CHECK (acting_for_user_id IS NULL OR principal_kind = 'user'::actions.action_principal AND (channel = ANY (ARRAY['operator'::actions.action_channel, 'web'::actions.action_channel])))`
- `command_external_actor_shape`: `CHECK (channel = 'slack'::actions.action_channel AND principal_kind = 'user'::actions.action_principal AND (external_actor_id IS NOT NULL OR actor_user_id IS NULL) AND actor_slack_integration_id IS NOT NULL AND actor_discord_integration_id IS NULL OR channel = 'discord'::actions.action_channel AND principal_kind = 'user'::actions.action_principal AND (external_actor_id IS NOT NULL OR actor_user_id IS NULL) AND actor_discord_integration_id IS NOT NULL AND actor_slack_integration_id IS NULL OR (channel <> ALL (ARRAY['slack'::actions.action_channel, 'discord'::actions.action_channel])) AND external_actor_id IS NULL AND actor_slack_integration_id IS NULL AND actor_discord_integration_id IS NULL)`
- `command_policy_target_shape`: `CHECK ((kind = ANY (ARRAY['grant_policy'::actions.action_command_kind, 'revoke_policy'::actions.action_command_kind])) OR target_policy_revision_id IS NULL)`
- `command_principal_exclusive`: `CHECK (principal_kind = 'user'::actions.action_principal AND actor_api_key_id IS NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NULL OR principal_kind = 'api_key'::actions.action_principal AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NULL OR principal_kind = 'agent'::actions.action_principal AND actor_user_id IS NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NOT NULL AND actor_policy_revision_id IS NULL OR principal_kind = 'policy'::actions.action_principal AND actor_user_id IS NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NOT NULL OR principal_kind = 'system'::actions.action_principal AND actor_user_id IS NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NULL)`
- `command_result_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `command_subject_nonempty`: `CHECK (length(actor_subject_snapshot) > 0)`

### actions.action_command_target

One ticket’s expected state and before/after state within a command. Collections have several targets in the same transaction.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| command_id | `text` | no |  |
| action_id | `text` | no |  |
| expected_version | `bigint` | yes |  |
| expected_revision_id | `text` | yes |  |
| expected_parent_revision_id | `text` | yes |  |
| previous_version | `bigint` | yes |  |
| result_version | `bigint` | no |  |
| previous_decision | `actions.action_decision` | yes |  |
| result_decision | `actions.action_decision` | no |  |
| previous_revision_id | `text` | yes |  |
| result_revision_id | `text` | yes |  |
| previous_owner_user_id | `text` | yes |  |
| result_owner_user_id | `text` | yes |  |
| previous_snoozed_until | `timestamp with time zone` | yes |  |
| result_snoozed_until | `timestamp with time zone` | yes |  |
| previous_archived_at | `timestamp with time zone` | yes |  |
| result_archived_at | `timestamp with time zone` | yes |  |
| previous_approval_id | `text` | yes |  |
| result_approval_id | `text` | yes |  |
| evidence_revision_id | `text` | yes |  |

Keys and constraints:

- `action_command_target_evidence_revision_tenant_action_fk`: `FOREIGN KEY (organization_id, action_id, evidence_revision_id) REFERENCES actions.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_target_organization_id_action_id_expected_r_fkey`: `FOREIGN KEY (organization_id, action_id, expected_revision_id) REFERENCES actions.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_target_organization_id_action_id_fkey`: `FOREIGN KEY (organization_id, action_id) REFERENCES actions.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_target_organization_id_action_id_previous_r_fkey`: `FOREIGN KEY (organization_id, action_id, previous_revision_id) REFERENCES actions.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_target_organization_id_action_id_result_rev_fkey`: `FOREIGN KEY (organization_id, action_id, result_revision_id) REFERENCES actions.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_target_organization_id_command_id_action_id_key`: `UNIQUE (organization_id, command_id, action_id)`
- `action_command_target_organization_id_command_id_fkey`: `FOREIGN KEY (organization_id, command_id) REFERENCES actions.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_target_organization_id_expected_parent_revi_fkey`: `FOREIGN KEY (organization_id, expected_parent_revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_command_target_pkey`: `PRIMARY KEY (command_id, action_id)`
- `action_command_target_result_version_check`: `CHECK (result_version > 0)`
- `actionsSchema_action_command_target_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `command_target_snapshot`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `target_positive_versions`: `CHECK ((expected_version IS NULL OR expected_version > 0) AND (previous_version IS NULL OR previous_version > 0))`
- `target_previous_approval_fk`: `FOREIGN KEY (organization_id, action_id, previous_approval_id) REFERENCES actions.action_approval(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `target_result_approval_fk`: `FOREIGN KEY (organization_id, action_id, result_approval_id) REFERENCES actions.action_approval(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_approval

One grant for one exact revision and scope, with its source command, optional policy and parent pins, and server Undo deadline.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| id | `text` | no |  |
| organization_id | `text` | no |  |
| action_id | `text` | no |  |
| revision_id | `text` | no |  |
| command_id | `text` | no |  |
| scope | `actions.action_authorization_scope` | no |  |
| policy_revision_id | `text` | yes |  |
| parent_revision_id | `text` | yes |  |
| undo_deadline | `timestamp with time zone` | no |  |
| required_surface | `actions.action_surface` | no |  |
| authorization_version | `integer` | no |  |
| created_at | `timestamp with time zone` | no |  |
| revision_instructions | `text` | yes |  |

Keys and constraints:

- `action_approval_authorization_version_check`: `CHECK (authorization_version > 0)`
- `action_approval_check`: `CHECK (undo_deadline >= created_at)`
- `action_approval_command_id_action_id_key`: `UNIQUE (command_id, action_id)`
- `action_approval_organization_id_action_id_id_key`: `UNIQUE (organization_id, action_id, id)`
- `action_approval_organization_id_action_id_revision_id_fkey`: `FOREIGN KEY (organization_id, action_id, revision_id) REFERENCES actions.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_approval_organization_id_command_id_action_id_fkey`: `FOREIGN KEY (organization_id, command_id, action_id) REFERENCES actions.action_command_target(organization_id, command_id, action_id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_approval_organization_id_id_key`: `UNIQUE (organization_id, id)`
- `action_approval_organization_id_parent_revision_id_fkey`: `FOREIGN KEY (organization_id, parent_revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_approval_organization_id_policy_revision_id_fkey`: `FOREIGN KEY (organization_id, policy_revision_id) REFERENCES actions.action_policy_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_approval_pkey`: `PRIMARY KEY (id)`
- `action_approval_revision_instructions`: `CHECK ((scope = 'revise'::actions.action_authorization_scope) = (revision_instructions IS NOT NULL))`
- `actionsSchema_action_approval_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `approval_command_snapshot`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `approval_exact_membership_fk`: `FOREIGN KEY (organization_id, parent_revision_id, action_id, revision_id) REFERENCES actions.action_membership(organization_id, parent_revision_id, child_action_id, child_revision_id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_policy_revision

One explicit sealed automation grant. Policy revocation is attributable and checked again before work executes.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| id | `text` | no |  |
| organization_id | `text` | no |  |
| asset_id | `text` | no |  |
| granted_by_command_id | `text` | no |  |
| policy_kind | `text` | no |  |
| revision_number | `bigint` | no |  |
| minimum_rating | `smallint` | yes |  |
| maximum_rating | `smallint` | yes |  |
| allow_initial_reply | `boolean` | no |  |
| allow_replace_reply | `boolean` | no | false |
| allow_generation | `boolean` | no |  |
| rule_version | `integer` | no |  |
| revoked_by_command_id | `text` | yes |  |
| revoked_at | `timestamp with time zone` | yes |  |
| created_at | `timestamp with time zone` | no |  |

Keys and constraints:

- `action_policy_revision_asset_id_fkey`: `FOREIGN KEY (asset_id) REFERENCES asset(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_policy_revision_check`: `CHECK (minimum_rating IS NULL OR maximum_rating >= minimum_rating)`
- `action_policy_revision_check1`: `CHECK (policy_kind <> 'agent_generation'::text OR NOT allow_initial_reply AND NOT allow_replace_reply)`
- `action_policy_revision_check2`: `CHECK ((revoked_by_command_id IS NULL) = (revoked_at IS NULL))`
- `action_policy_revision_maximum_rating_check`: `CHECK (maximum_rating >= 1 AND maximum_rating <= 5)`
- `action_policy_revision_minimum_rating_check`: `CHECK (minimum_rating >= 1 AND minimum_rating <= 5)`
- `action_policy_revision_organization_id_asset_id_policy_kind_key`: `UNIQUE (organization_id, asset_id, policy_kind, revision_number)`
- `action_policy_revision_organization_id_granted_by_command__fkey`: `FOREIGN KEY (organization_id, granted_by_command_id) REFERENCES actions.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_policy_revision_organization_id_id_key`: `UNIQUE (organization_id, id)`
- `action_policy_revision_organization_id_revoked_by_command__fkey`: `FOREIGN KEY (organization_id, revoked_by_command_id) REFERENCES actions.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_policy_revision_pkey`: `PRIMARY KEY (id)`
- `action_policy_revision_policy_kind_check`: `CHECK (policy_kind = ANY (ARRAY['review_auto_reply'::text, 'agent_generation'::text]))`
- `action_policy_revision_revision_number_check`: `CHECK (revision_number > 0)`
- `action_policy_revision_rule_version_check`: `CHECK (rule_version > 0)`
- `actionsSchema_action_policy_revision_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `policy_permission_shape`: `CHECK (policy_kind = 'agent_generation'::text AND allow_generation AND NOT allow_initial_reply AND NOT allow_replace_reply AND minimum_rating IS NULL OR policy_kind = 'review_auto_reply'::text AND (allow_initial_reply OR allow_replace_reply))`
- `policy_rating_bounds`: `CHECK ((minimum_rating IS NULL) = (maximum_rating IS NULL))`

## Execution & recovery

### actions.action_execution

One durable approved obligation. This is not a second job queue: it stores eligibility, plan position, uncertainty and recovery deadlines.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| id | `text` | no |  |
| organization_id | `text` | no |  |
| approval_id | `text` | no |  |
| phase | `actions.action_execution_phase` | no |  |
| next_run_at | `timestamp with time zone` | yes |  |
| next_step_id | `text` | yes |  |
| schedule_generation | `bigint` | no | 1 |
| claim_generation | `bigint` | no | 0 |
| claim_token | `uuid` | yes |  |
| claim_expires_at | `timestamp with time zone` | yes |  |
| hold_reason | `actions.action_hold_reason` | yes |  |
| result | `actions.action_execution_result` | yes |  |
| created_at | `timestamp with time zone` | no |  |
| settled_at | `timestamp with time zone` | yes |  |
| resource_guard_id | `uuid` | yes |  |
| plan_version | `integer` | no |  |
| writes_closed_at | `timestamp with time zone` | yes |  |
| cancelled_command_id | `text` | yes |  |
| plan_complete | `boolean` | no | false |

Keys and constraints:

- `action_execution_approval_id_key`: `UNIQUE (approval_id)`
- `action_execution_cancel_command_fk`: `FOREIGN KEY (organization_id, cancelled_command_id) REFERENCES actions.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_cancel_command_shape`: `CHECK ((phase = 'cancelled'::actions.action_execution_phase) = (cancelled_command_id IS NOT NULL))`
- `action_execution_cancelled_result`: `CHECK ((phase = 'cancelled'::actions.action_execution_phase) = (result = 'cancelled'::actions.action_execution_result))`
- `action_execution_check`: `CHECK ((claim_token IS NULL) = (claim_expires_at IS NULL))`
- `action_execution_check1`: `CHECK ((phase = 'claimed'::actions.action_execution_phase) = (claim_token IS NOT NULL))`
- `action_execution_check2`: `CHECK ((phase = ANY (ARRAY['settled'::actions.action_execution_phase, 'cancelled'::actions.action_execution_phase])) = (settled_at IS NOT NULL))`
- `action_execution_check3`: `CHECK ((phase = ANY (ARRAY['settled'::actions.action_execution_phase, 'cancelled'::actions.action_execution_phase])) = (result IS NOT NULL))`
- `action_execution_check4`: `CHECK ((phase <> ALL (ARRAY['ready'::actions.action_execution_phase, 'verification_due'::actions.action_execution_phase])) OR next_run_at IS NOT NULL)`
- `action_execution_check5`: `CHECK ((phase <> ALL (ARRAY['settled'::actions.action_execution_phase, 'cancelled'::actions.action_execution_phase])) OR next_run_at IS NULL)`
- `action_execution_check6`: `CHECK (phase <> 'uncertain'::actions.action_execution_phase OR hold_reason = 'uncertain_write'::actions.action_hold_reason)`
- `action_execution_claim_generation`: `CHECK (phase <> 'claimed'::actions.action_execution_phase OR claim_generation > 0)`
- `action_execution_claim_generation_check`: `CHECK (claim_generation >= 0)`
- `action_execution_organization_id_approval_id_fkey`: `FOREIGN KEY (organization_id, approval_id) REFERENCES actions.action_approval(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_organization_id_id_key`: `UNIQUE (organization_id, id)`
- `action_execution_organization_id_id_next_step_id_fkey`: `FOREIGN KEY (organization_id, id, next_step_id) REFERENCES actions.action_execution_step(organization_id, execution_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_pkey`: `PRIMARY KEY (id)`
- `action_execution_plan_version_check`: `CHECK (plan_version > 0)`
- `action_execution_resource_guard_id_fkey`: `FOREIGN KEY (resource_guard_id) REFERENCES actions.action_resource_guard(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_schedule_generation_check`: `CHECK (schedule_generation > 0)`
- `action_execution_settlement_time`: `CHECK (settled_at IS NULL OR settled_at >= created_at)`
- `action_execution_uncertain_due`: `CHECK (phase <> 'uncertain'::actions.action_execution_phase OR next_run_at IS NOT NULL)`
- `action_execution_writes_closed_time`: `CHECK (writes_closed_at IS NULL OR writes_closed_at >= created_at)`
- `actionsSchema_action_execution_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_execution_step

One frozen effect in an approved plan. Native effects can need several ordered steps and separate readback timing.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| id | `text` | no |  |
| organization_id | `text` | no |  |
| execution_id | `text` | no |  |
| ordinal | `integer` | no |  |
| kind | `actions.action_step_kind` | no |  |
| adapter_version | `integer` | no |  |
| input_step_id | `text` | yes |  |
| content_revision_id | `text` | no |  |
| recovery_mode | `actions.action_recovery_mode` | no |  |
| recovery_policy_version | `integer` | no |  |
| native_idempotency_key | `text` | yes |  |
| required_surface | `actions.action_surface` | no |  |
| verification_timing | `actions.action_verification_timing` | no | 'after_effects'::actions.action_verification_timing |

Keys and constraints:

- `action_execution_step_adapter_version_check`: `CHECK (adapter_version > 0)`
- `action_execution_step_check`: `CHECK (id IS DISTINCT FROM input_step_id)`
- `action_execution_step_check1`: `CHECK ((recovery_mode = 'native_idempotency'::actions.action_recovery_mode) = (native_idempotency_key IS NOT NULL))`
- `action_execution_step_execution_id_ordinal_key`: `UNIQUE (execution_id, ordinal)`
- `action_execution_step_ordinal_check`: `CHECK (ordinal >= 0)`
- `action_execution_step_organization_id_content_revision_id_fkey`: `FOREIGN KEY (organization_id, content_revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_step_organization_id_execution_id_fkey`: `FOREIGN KEY (organization_id, execution_id) REFERENCES actions.action_execution(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_step_organization_id_execution_id_id_key`: `UNIQUE (organization_id, execution_id, id)`
- `action_execution_step_organization_id_execution_id_input_s_fkey`: `FOREIGN KEY (organization_id, execution_id, input_step_id) REFERENCES actions.action_execution_step(organization_id, execution_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_step_organization_id_id_key`: `UNIQUE (organization_id, id)`
- `action_execution_step_pkey`: `PRIMARY KEY (id)`
- `action_execution_step_recovery_policy_version_check`: `CHECK (recovery_policy_version > 0)`
- `action_step_verification_timing_shape`: `CHECK ((kind <> 'play_inspection_edit_create'::actions.action_step_kind OR verification_timing = 'before_successor'::actions.action_verification_timing AND required_surface = 'editable_listing'::actions.action_surface) AND (kind <> 'play_inspection_edit_delete'::actions.action_step_kind OR verification_timing = 'after_effects'::actions.action_verification_timing AND required_surface = 'provider_response'::actions.action_surface))`
- `actionsSchema_action_execution_step_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_execution_attempt

One actual dispatch, readback or generation attempt. Started intent persists before I/O; result, claim fence and evidence remain attributable.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| id | `text` | no |  |
| organization_id | `text` | no |  |
| step_id | `text` | no |  |
| number | `integer` | no |  |
| kind | `actions.action_attempt_kind` | no |  |
| claim_generation | `bigint` | no |  |
| subject_attempt_id | `text` | yes |  |
| agent_run_id | `text` | yes |  |
| connector_id | `text` | yes |  |
| transport | `actions.action_transport` | no |  |
| started_at | `timestamp with time zone` | no |  |
| finished_at | `timestamp with time zone` | yes |  |
| result | `actions.action_attempt_result` | yes |  |
| observation_revision_id | `text` | yes |  |
| comparison_version | `integer` | yes |  |
| failure_class | `actions.action_failure_class` | yes |  |
| recorded_at | `timestamp with time zone` | no |  |
| execution_id | `text` | no |  |
| claim_token | `uuid` | no |  |
| input_attempt_id | `text` | yes |  |
| input_parent_revision_id | `text` | yes |  |
| output_kind | `actions.action_output_kind` | yes |  |
| output_revision_id | `text` | yes |  |
| output_review_analysis_id | `text` | yes |  |
| output_agent_run_id | `text` | yes |  |
| no_work_reason | `actions.action_no_work_reason` | yes |  |
| finalized_claim_generation | `bigint` | yes |  |
| finalized_claim_token | `uuid` | yes |  |
| evidence_command_id | `text` | yes |  |
| observation_surface | `actions.action_surface` | yes |  |
| observation_completeness | `actions.action_observation_completeness` | yes |  |
| observed_at | `timestamp with time zone` | yes |  |
| non_application_basis | `actions.action_non_application_basis` | yes |  |
| retry_disposition | `actions.action_retry_disposition` | yes |  |
| uncertainty_reason | `actions.action_uncertainty_reason` | yes |  |
| unreadable_reason | `actions.action_unreadable_reason` | yes |  |

Keys and constraints:

- `action_attempt_active_identity`: `CHECK (step_id IS NOT NULL AND number IS NOT NULL AND claim_generation IS NOT NULL AND started_at IS NOT NULL AND transport IS NOT NULL)`
- `action_attempt_active_kind`: `CHECK (kind = ANY (ARRAY['write'::actions.action_attempt_kind, 'readback'::actions.action_attempt_kind, 'generation'::actions.action_attempt_kind, 'late_evidence'::actions.action_attempt_kind]))`
- `action_attempt_evidence_command`: `FOREIGN KEY (organization_id, evidence_command_id) REFERENCES actions.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_attempt_evidence_shape`: `CHECK ((kind = 'late_evidence'::actions.action_attempt_kind) = (evidence_command_id IS NOT NULL) AND (kind <> 'late_evidence'::actions.action_attempt_kind OR finished_at IS NOT NULL AND finalized_claim_generation IS NULL AND finalized_claim_token IS NULL))`
- `action_attempt_execution_identity`: `UNIQUE (organization_id, execution_id, id)`
- `action_attempt_finalization_fence`: `CHECK (kind = 'late_evidence'::actions.action_attempt_kind OR (finished_at IS NOT NULL) = (finalized_claim_generation IS NOT NULL) AND (finalized_claim_generation IS NULL) = (finalized_claim_token IS NULL))`
- `action_attempt_input_parent_revision_tenant_fk`: `FOREIGN KEY (organization_id, input_parent_revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_attempt_input_same_execution`: `FOREIGN KEY (organization_id, execution_id, input_attempt_id) REFERENCES actions.action_execution_attempt(organization_id, execution_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_attempt_no_self_input`: `CHECK (id IS DISTINCT FROM input_attempt_id)`
- `action_attempt_non_application_shape`: `CHECK ((NOT result IS DISTINCT FROM 'known_not_applied'::actions.action_attempt_result) = (non_application_basis IS NOT NULL))`
- `action_attempt_output_revision`: `FOREIGN KEY (organization_id, output_revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_attempt_output_shape`: `CHECK ((result IS DISTINCT FROM 'generated'::actions.action_attempt_result OR output_kind IS NOT NULL) AND (output_kind IS NULL OR result IS NOT NULL AND (result = ANY (ARRAY['generated'::actions.action_attempt_result, 'discarded'::actions.action_attempt_result]))) AND (output_kind IS NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 0 OR output_kind = 'revision'::actions.action_output_kind AND output_revision_id IS NOT NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 1 OR output_kind = 'review_analysis'::actions.action_output_kind AND output_review_analysis_id IS NOT NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 1 OR output_kind = 'agent_run'::actions.action_output_kind AND output_agent_run_id IS NOT NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 1 OR output_kind = 'no_work'::actions.action_output_kind AND no_work_reason IS NOT NULL AND agent_run_id IS NOT NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 1))`
- `action_attempt_parent_context_kind`: `CHECK (input_parent_revision_id IS NULL OR (kind = ANY (ARRAY['generation'::actions.action_attempt_kind, 'late_evidence'::actions.action_attempt_kind])))`
- `action_attempt_result_by_kind`: `CHECK (result IS NULL OR kind = 'write'::actions.action_attempt_kind AND (result = ANY (ARRAY['acknowledged'::actions.action_attempt_result, 'known_not_applied'::actions.action_attempt_result, 'uncertain'::actions.action_attempt_result])) OR kind = 'readback'::actions.action_attempt_kind AND (result = ANY (ARRAY['matched'::actions.action_attempt_result, 'matched_external'::actions.action_attempt_result, 'mismatch'::actions.action_attempt_result, 'unreadable'::actions.action_attempt_result, 'known_not_applied'::actions.action_attempt_result])) OR kind = 'generation'::actions.action_attempt_kind AND (result = ANY (ARRAY['generated'::actions.action_attempt_result, 'discarded'::actions.action_attempt_result, 'known_not_applied'::actions.action_attempt_result, 'uncertain'::actions.action_attempt_result])) OR kind = 'late_evidence'::actions.action_attempt_kind)`
- `action_attempt_retry_disposition_shape`: `CHECK ((NOT result IS DISTINCT FROM 'known_not_applied'::actions.action_attempt_result) = (retry_disposition IS NOT NULL))`
- `action_attempt_step_execution`: `FOREIGN KEY (organization_id, execution_id, step_id) REFERENCES actions.action_execution_step(organization_id, execution_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_attempt_step_identity`: `UNIQUE (organization_id, step_id, id)`
- `action_attempt_subject_same_step`: `FOREIGN KEY (organization_id, step_id, subject_attempt_id) REFERENCES actions.action_execution_attempt(organization_id, step_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_attempt_uncertainty_reason_shape`: `CHECK ((NOT result IS DISTINCT FROM 'uncertain'::actions.action_attempt_result) = (uncertainty_reason IS NOT NULL))`
- `action_attempt_unreadable_reason_shape`: `CHECK ((NOT result IS DISTINCT FROM 'unreadable'::actions.action_attempt_result) = (unreadable_reason IS NOT NULL))`
- `action_attempt_verified_observation`: `CHECK ((result <> ALL (ARRAY['matched'::actions.action_attempt_result, 'matched_external'::actions.action_attempt_result, 'mismatch'::actions.action_attempt_result])) AND NOT (kind = 'readback'::actions.action_attempt_kind AND result = 'known_not_applied'::actions.action_attempt_result) OR observation_revision_id IS NOT NULL AND observation_surface IS NOT NULL AND NOT observation_completeness IS DISTINCT FROM 'complete'::actions.action_observation_completeness AND observed_at IS NOT NULL AND comparison_version IS NOT NULL)`
- `action_execution_attempt_agent_run_id_fkey`: `FOREIGN KEY (agent_run_id) REFERENCES agent_run(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_attempt_check`: `CHECK (id IS DISTINCT FROM subject_attempt_id)`
- `action_execution_attempt_check1`: `CHECK (step_id IS NOT NULL AND number IS NOT NULL AND claim_generation IS NOT NULL AND started_at IS NOT NULL AND transport IS NOT NULL)`
- `action_execution_attempt_check2`: `CHECK ((finished_at IS NULL) = (result IS NULL))`
- `action_execution_attempt_check3`: `CHECK (finished_at IS NULL OR started_at IS NULL OR finished_at >= started_at)`
- `action_execution_attempt_check4`: `CHECK ((kind <> ALL (ARRAY['readback'::actions.action_attempt_kind, 'late_evidence'::actions.action_attempt_kind])) OR subject_attempt_id IS NOT NULL)`
- `action_execution_attempt_check5`: `CHECK ((result <> ALL (ARRAY['matched'::actions.action_attempt_result, 'matched_external'::actions.action_attempt_result, 'mismatch'::actions.action_attempt_result])) OR observation_revision_id IS NOT NULL AND comparison_version IS NOT NULL)`
- `action_execution_attempt_claim_generation_check`: `CHECK (claim_generation > 0)`
- `action_execution_attempt_comparison_version_check`: `CHECK (comparison_version > 0)`
- `action_execution_attempt_connector_id_fkey`: `FOREIGN KEY (connector_id) REFERENCES data_connector(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_attempt_finalized_claim_generation_check`: `CHECK (finalized_claim_generation > 0)`
- `action_execution_attempt_number_check`: `CHECK (number > 0)`
- `action_execution_attempt_organization_id_id_key`: `UNIQUE (organization_id, id)`
- `action_execution_attempt_organization_id_observation_revis_fkey`: `FOREIGN KEY (organization_id, observation_revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_attempt_organization_id_step_id_fkey`: `FOREIGN KEY (organization_id, step_id) REFERENCES actions.action_execution_step(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_attempt_organization_id_subject_attempt_i_fkey`: `FOREIGN KEY (organization_id, subject_attempt_id) REFERENCES actions.action_execution_attempt(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_attempt_output_agent_run_id_fkey`: `FOREIGN KEY (output_agent_run_id) REFERENCES agent_run(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_attempt_output_review_analysis_id_fkey`: `FOREIGN KEY (output_review_analysis_id) REFERENCES review_analysis(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_execution_attempt_pkey`: `PRIMARY KEY (id)`
- `action_execution_attempt_step_id_number_key`: `UNIQUE (step_id, number)`
- `actionsSchema_action_execution_attempt_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_resource_guard

One provider resource exclusion key shared across conflicting tickets. Claim expiry does not prove a timed-out provider write stopped.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| provider | `text` | no |  |
| provider_account_id | `text` | yes |  |
| remote_application_id | `text` | yes |  |
| holder_organization_id | `text` | yes |  |
| holder_execution_id | `text` | yes |  |
| acquired_at | `timestamp with time zone` | yes |  |
| id | `uuid` | no | gen_random_uuid() |
| scope | `actions.action_resource_scope` | no |  |

Keys and constraints:

- `action_resource_guard_check`: `CHECK ((holder_execution_id IS NULL) = (holder_organization_id IS NULL))`
- `action_resource_guard_check1`: `CHECK ((holder_execution_id IS NULL) = (acquired_at IS NULL))`
- `action_resource_guard_holder_organization_id_holder_execut_fkey`: `FOREIGN KEY (holder_organization_id, holder_execution_id) REFERENCES actions.action_execution(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_resource_guard_identity`: `PRIMARY KEY (id)`
- `action_resource_guard_nonempty_account`: `CHECK (length(provider_account_id) > 0)`
- `action_resource_guard_provider_check`: `CHECK (provider = ANY (ARRAY['app_store_connect'::text, 'google_play'::text, 'apple_search_ads'::text]))`
- `action_resource_guard_scope_shape`: `CHECK (provider = 'apple_search_ads'::text AND scope = 'advertising_account'::actions.action_resource_scope AND provider_account_id IS NOT NULL AND remote_application_id IS NULL OR (provider = ANY (ARRAY['app_store_connect'::text, 'google_play'::text])) AND scope = 'store_application'::actions.action_resource_scope AND provider_account_id IS NULL AND remote_application_id IS NOT NULL AND length(remote_application_id) > 0)`

## Typed Fload content

### actions.action_review_content

Exact reviewed customer snapshot, proposed reply and response identity. This is not a mutable replacement for the Reviews domain’s current observations.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| provider_account_id | `text` | no |  |
| store | `actions.store_kind` | no |  |
| provider_app_id | `text` | no |  |
| provider_review_id | `text` | no |  |
| apple_review_resource_id | `text` | yes |  |
| intent | `actions.reply_intent` | no |  |
| reply_text | `text` | yes |  |
| original_ai_revision_id | `text` | yes |  |
| detected_language_name | `text` | yes |  |
| review_rating | `integer` | yes |  |
| review_title | `text` | yes |  |
| review_body | `text` | yes |  |
| review_nickname | `text` | yes |  |
| review_storefront | `text` | yes |  |
| review_app_version | `text` | yes |  |
| review_modified_at | `timestamp with time zone` | yes |  |
| review_edited | `boolean` | yes |  |
| response_availability | `actions.observation_availability` | no |  |
| provider_response_id | `text` | yes |  |
| provider_response_text | `text` | yes |  |
| provider_response_modified_at | `timestamp with time zone` | yes |  |
| provider_response_hidden | `boolean` | yes |  |
| observation_captured_at | `timestamp with time zone` | yes |  |
| provider_response_state | `actions.review_publication_state` | yes |  |

Keys and constraints:

- `action_review_content_check`: `CHECK ((intent <> ALL (ARRAY['send'::actions.reply_intent, 'update'::actions.reply_intent])) OR reply_text IS NOT NULL AND length(reply_text) > 0)`
- `action_review_content_check2`: `CHECK (response_availability <> 'present'::actions.observation_availability OR provider_response_text IS NOT NULL)`
- `action_review_content_check3`: `CHECK (response_availability <> 'absent'::actions.observation_availability OR provider_response_id IS NULL AND provider_response_text IS NULL)`
- `action_review_content_organization_id_original_ai_revision_fkey`: `FOREIGN KEY (organization_id, original_ai_revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_review_content_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_review_content_pkey`: `PRIMARY KEY (organization_id, revision_id)`
- `action_review_content_review_rating_check`: `CHECK (review_rating >= 1 AND review_rating <= 5)`
- `actionsSchema_action_review_content_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_listing_content

Common immutable listing field values and their explicit presence states. Provider protocol details live in provider contracts.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| store | `actions.store_kind` | no |  |
| locale | `text` | no |  |
| intent | `actions.listing_intent` | no |  |
| title_state | `actions.content_value_state` | no | 'unspecified'::actions.content_value_state |
| title | `text` | yes |  |
| subtitle_state | `actions.content_value_state` | no | 'unspecified'::actions.content_value_state |
| subtitle | `text` | yes |  |
| description_state | `actions.content_value_state` | no | 'unspecified'::actions.content_value_state |
| description | `text` | yes |  |
| keywords_state | `actions.content_value_state` | no | 'unspecified'::actions.content_value_state |
| keywords | `text` | yes |  |
| promotional_text_state | `actions.content_value_state` | no | 'unspecified'::actions.content_value_state |
| promotional_text | `text` | yes |  |
| short_description_state | `actions.content_value_state` | no | 'unspecified'::actions.content_value_state |
| short_description | `text` | yes |  |
| whats_new_state | `actions.content_value_state` | no | 'unspecified'::actions.content_value_state |
| whats_new | `text` | yes |  |
| support_url_state | `actions.content_value_state` | no | 'unspecified'::actions.content_value_state |
| support_url | `text` | yes |  |
| keyword_analysis | `text` | yes |  |
| operator_instructions | `text` | yes |  |
| source_fingerprint | `text` | yes |  |
| naturalness_check_skipped | `boolean` | yes |  |
| fidelity_check_skipped | `boolean` | yes |  |
| english_title | `text` | yes |  |
| english_subtitle | `text` | yes |  |
| english_promotional_text | `text` | yes |  |
| gloss_status | `actions.gloss_status` | yes |  |
| research_country | `text` | yes |  |
| research_coverage | `actions.research_coverage` | yes |  |
| research_model_source | `text` | yes |  |
| research_model_version | `text` | yes |  |
| research_model_formula | `text` | yes |  |
| app_tier | `integer` | yes |  |
| app_tier_resolved | `boolean` | yes |  |
| candidate_count | `bigint` | yes |  |
| judged_count | `bigint` | yes |  |
| scored_count | `bigint` | yes |  |
| p0_count | `bigint` | yes |  |
| p1_count | `bigint` | yes |  |
| p2_count | `bigint` | yes |  |
| with_volume_count | `bigint` | yes |  |
| conformance_term_count | `bigint` | yes |  |
| conformance_from_table_count | `bigint` | yes |  |
| observation_availability | `actions.observation_availability` | yes |  |
| observation_captured_at | `timestamp with time zone` | yes |  |
| source_capture_at | `timestamp with time zone` | yes |  |
| provider_version_state | `actions.listing_version_state` | yes |  |

Keys and constraints:

- `action_listing_content_app_tier_check`: `CHECK (app_tier >= 1 AND app_tier <= 3)`
- `action_listing_content_candidate_count_check`: `CHECK (candidate_count >= 0)`
- `action_listing_content_check`: `CHECK (title_state = 'present'::actions.content_value_state AND title IS NOT NULL AND length(title) > 0 OR title_state = 'dismissed'::actions.content_value_state AND title IS NOT NULL OR title_state = 'empty'::actions.content_value_state AND title IS NOT NULL AND title = ''::text OR (title_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND title IS NULL)`
- `action_listing_content_check1`: `CHECK (subtitle_state = 'present'::actions.content_value_state AND subtitle IS NOT NULL AND length(subtitle) > 0 OR subtitle_state = 'dismissed'::actions.content_value_state AND subtitle IS NOT NULL OR subtitle_state = 'empty'::actions.content_value_state AND subtitle IS NOT NULL AND subtitle = ''::text OR (subtitle_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND subtitle IS NULL)`
- `action_listing_content_check2`: `CHECK (description_state = 'present'::actions.content_value_state AND description IS NOT NULL AND length(description) > 0 OR description_state = 'dismissed'::actions.content_value_state AND description IS NOT NULL OR description_state = 'empty'::actions.content_value_state AND description IS NOT NULL AND description = ''::text OR (description_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND description IS NULL)`
- `action_listing_content_check3`: `CHECK (keywords_state = 'present'::actions.content_value_state AND keywords IS NOT NULL AND length(keywords) > 0 OR keywords_state = 'dismissed'::actions.content_value_state AND keywords IS NOT NULL OR keywords_state = 'empty'::actions.content_value_state AND keywords IS NOT NULL AND keywords = ''::text OR (keywords_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND keywords IS NULL)`
- `action_listing_content_check4`: `CHECK (promotional_text_state = 'present'::actions.content_value_state AND promotional_text IS NOT NULL AND length(promotional_text) > 0 OR promotional_text_state = 'dismissed'::actions.content_value_state AND promotional_text IS NOT NULL OR promotional_text_state = 'empty'::actions.content_value_state AND promotional_text IS NOT NULL AND promotional_text = ''::text OR (promotional_text_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND promotional_text IS NULL)`
- `action_listing_content_check5`: `CHECK (short_description_state = 'present'::actions.content_value_state AND short_description IS NOT NULL AND length(short_description) > 0 OR short_description_state = 'dismissed'::actions.content_value_state AND short_description IS NOT NULL OR short_description_state = 'empty'::actions.content_value_state AND short_description IS NOT NULL AND short_description = ''::text OR (short_description_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND short_description IS NULL)`
- `action_listing_content_check6`: `CHECK (whats_new_state = 'present'::actions.content_value_state AND whats_new IS NOT NULL AND length(whats_new) > 0 OR whats_new_state = 'dismissed'::actions.content_value_state AND whats_new IS NOT NULL OR whats_new_state = 'empty'::actions.content_value_state AND whats_new IS NOT NULL AND whats_new = ''::text OR (whats_new_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND whats_new IS NULL)`
- `action_listing_content_check7`: `CHECK (support_url_state = 'present'::actions.content_value_state AND support_url IS NOT NULL AND length(support_url) > 0 OR support_url_state = 'dismissed'::actions.content_value_state AND support_url IS NOT NULL OR support_url_state = 'empty'::actions.content_value_state AND support_url IS NOT NULL AND support_url = ''::text OR (support_url_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND support_url IS NULL)`
- `action_listing_content_check8`: `CHECK (conformance_from_table_count IS NULL OR conformance_term_count IS NULL OR conformance_from_table_count <= conformance_term_count)`
- `action_listing_content_conformance_from_table_count_check`: `CHECK (conformance_from_table_count >= 0)`
- `action_listing_content_conformance_term_count_check`: `CHECK (conformance_term_count >= 0)`
- `action_listing_content_judged_count_check`: `CHECK (judged_count >= 0)`
- `action_listing_content_locale_check`: `CHECK (length(locale) > 0)`
- `action_listing_content_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_listing_content_p0_count_check`: `CHECK (p0_count >= 0)`
- `action_listing_content_p1_count_check`: `CHECK (p1_count >= 0)`
- `action_listing_content_p2_count_check`: `CHECK (p2_count >= 0)`
- `action_listing_content_pkey`: `PRIMARY KEY (organization_id, revision_id)`
- `action_listing_content_scored_count_check`: `CHECK (scored_count >= 0)`
- `action_listing_content_with_volume_count_check`: `CHECK (with_volume_count >= 0)`
- `actionsSchema_action_listing_content_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `listing_supported_locale`: `CHECK (actions.is_supported_store_locale(store, locale))`

### actions.action_media_content

One ordered media slot with immutable object identity, byte length, digest, MIME type and dimensions.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| slot | `integer` | no |  |
| kind | `actions.media_kind` | no |  |
| store | `actions.store_kind` | no |  |
| locale | `text` | no |  |
| source_locale | `text` | yes |  |
| display_type | `actions.media_display_type` | yes |  |
| source_provider_resource_id | `text` | yes |  |
| source_object_key | `text` | yes |  |
| source_object_version | `text` | yes |  |
| source_digest | `text` | yes |  |
| output_object_key | `text` | yes |  |
| output_object_version | `text` | yes |  |
| output_digest | `text` | yes |  |
| availability | `actions.media_availability` | no |  |
| mime_type | `text` | yes |  |
| width | `integer` | yes |  |
| height | `integer` | yes |  |
| byte_length | `bigint` | yes |  |
| generation_prompt | `text` | yes |  |
| generated_at | `timestamp with time zone` | yes |  |
| storyboard_intent | `text` | yes |  |
| caption | `text` | yes |  |
| first_slot_hook_guidance | `text` | yes |  |
| source_storage_immutability | `actions.media_storage_immutability` | yes |  |
| output_storage_immutability | `actions.media_storage_immutability` | yes |  |
| provider_md5 | `text` | yes |  |
| source_byte_length | `bigint` | yes |  |

Keys and constraints:

- `action_media_content_byte_length_check`: `CHECK (byte_length >= 0)`
- `action_media_content_height_check`: `CHECK (height > 0)`
- `action_media_content_mime_type_check`: `CHECK (mime_type = ANY (ARRAY['image/png'::text, 'image/jpeg'::text, 'image/webp'::text, 'video/mp4'::text, 'video/quicktime'::text]))`
- `action_media_content_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_media_content_pkey`: `PRIMARY KEY (organization_id, revision_id, slot)`
- `action_media_content_slot_check`: `CHECK (slot >= 0)`
- `action_media_content_width_check`: `CHECK (width > 0)`
- `actionsSchema_action_media_content_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `media_clip_shape`: `CHECK (kind::text <> 'app_clip_header'::text OR store = 'ios'::actions.store_kind AND display_type IS NULL AND mime_type IS NOT NULL AND (mime_type = ANY (ARRAY['image/png'::text, 'image/jpeg'::text])))`
- `media_display_store`: `CHECK (display_type IS NULL OR store = 'android'::actions.store_kind AND (display_type = ANY (ARRAY['phoneScreenshots'::actions.media_display_type, 'sevenInchScreenshots'::actions.media_display_type])) OR store = 'ios'::actions.store_kind AND (display_type <> ALL (ARRAY['phoneScreenshots'::actions.media_display_type, 'sevenInchScreenshots'::actions.media_display_type])))`
- `media_md5_format`: `CHECK (provider_md5 IS NULL OR provider_md5 ~ '^[0-9a-f]{32}$'::text)`
- `media_output_digest_format`: `CHECK (output_digest IS NULL OR output_digest ~ '^sha256:[0-9a-f]{64}$'::text)`
- `media_screenshot_display`: `CHECK (kind::text <> 'screenshot'::text OR display_type IS NOT NULL)`
- `media_source_bytes_immutable`: `CHECK (source_object_key IS NULL AND source_object_version IS NULL AND source_digest IS NULL AND source_storage_immutability IS NULL OR source_object_key IS NOT NULL AND length(source_object_key) > 0 AND source_digest IS NOT NULL AND source_storage_immutability IS NOT NULL AND (source_storage_immutability = 'versioned_object'::actions.media_storage_immutability AND source_object_version IS NOT NULL AND length(source_object_version) > 0 OR source_storage_immutability = 'content_addressed_immutable'::actions.media_storage_immutability AND source_object_version IS NULL AND POSITION((SUBSTRING(source_digest FROM 8)) IN (source_object_key)) > 0))`
- `media_source_digest_format`: `CHECK (source_digest IS NULL OR source_digest ~ '^sha256:[0-9a-f]{64}$'::text)`
- `media_source_length`: `CHECK ((source_object_key IS NOT NULL) = (source_byte_length IS NOT NULL) AND (source_byte_length IS NULL OR source_byte_length > 0))`
- `media_stored_bytes_immutable`: `CHECK (availability <> 'stored'::actions.media_availability OR output_object_key IS NOT NULL AND length(output_object_key) > 0 AND output_digest IS NOT NULL AND byte_length IS NOT NULL AND output_storage_immutability IS NOT NULL AND (output_storage_immutability = 'versioned_object'::actions.media_storage_immutability AND output_object_version IS NOT NULL AND length(output_object_version) > 0 OR output_storage_immutability = 'content_addressed_immutable'::actions.media_storage_immutability AND output_object_version IS NULL AND POSITION((SUBSTRING(output_digest FROM 8)) IN (output_object_key)) > 0))`
- `media_supported_locale`: `CHECK (actions.is_supported_store_locale(store, locale))`
- `media_supported_source_locale`: `CHECK (source_locale IS NULL OR actions.is_supported_store_locale(store, source_locale))`

### actions.action_request_content

One closed request subtype with language, review window, research facts or actual agent target. Required producer parity extensions are listed in the cutover plan.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| intent | `actions.request_intent` | no |  |
| store | `actions.store_kind` | yes |  |
| locale | `text` | yes |  |
| wave_index | `integer` | yes |  |
| recommendation_type | `actions.recommendation_kind` | yes |  |
| plan_source_id | `text` | yes |  |
| source_capture_at | `timestamp with time zone` | yes |  |
| window_days | `integer` | yes |  |
| review_mode | `text` | yes |  |
| operator_instructions | `text` | yes |  |
| focus | `text` | yes |  |
| context_text | `text` | yes |  |
| hypothesize_policy | `actions.approval_setting` | yes |  |
| draft_policy | `actions.approval_setting` | yes |  |
| execute_policy | `actions.approval_setting` | yes |  |
| origin | `actions.request_origin` | no |  |
| language | `text` | yes |  |
| reasoning | `text` | yes |  |
| score | `numeric` | yes |  |
| demand_lookback_days | `integer` | yes |  |
| downloads | `numeric` | yes |  |
| revenue_usd | `numeric` | yes |  |
| impressions | `numeric` | yes |  |
| review_count | `bigint` | yes |  |
| competitor_strength | `numeric` | yes |  |
| localized_competitor_count | `bigint` | yes |  |
| top_chart_count | `bigint` | yes |  |
| estimated_market_downloads | `numeric` | yes |  |
| market_research_note | `text` | yes |  |
| finding_title | `text` | yes |  |
| finding_rationale | `text` | yes |  |
| finding_severity | `actions.closed_severity` | yes |  |
| requested_agent_id | `text` | yes |  |

Keys and constraints:

- `action_request_content_check`: `CHECK ((intent <> ALL (ARRAY['review_catch_up'::actions.request_intent, 'review_analysis'::actions.request_intent])) OR window_days IS NOT NULL)`
- `action_request_content_check1`: `CHECK (intent <> 'review_catch_up'::actions.request_intent OR review_mode IS NOT NULL)`
- `action_request_content_check2`: `CHECK (intent <> 'locale_expansion'::actions.request_intent OR store IS NOT NULL AND locale IS NOT NULL)`
- `action_request_content_demand_lookback_days_check`: `CHECK (demand_lookback_days > 0)`
- `action_request_content_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_request_content_pkey`: `PRIMARY KEY (organization_id, revision_id)`
- `action_request_content_requested_agent_id_fkey`: `FOREIGN KEY (requested_agent_id) REFERENCES agent(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_request_content_review_mode_check`: `CHECK (review_mode = ANY (ARRAY['manual'::text, 'full_agentic'::text]))`
- `action_request_content_wave_index_check`: `CHECK (wave_index >= 0)`
- `action_request_content_window_days_check`: `CHECK (window_days >= 7 AND window_days <= 180)`
- `actionsSchema_action_request_content_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `request_agent_target_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `request_agent_target_shape`: `CHECK ((intent = 'wake_agent'::actions.request_intent) = (requested_agent_id IS NOT NULL))`
- `request_supported_locale`: `CHECK (locale IS NULL OR store IS NOT NULL AND actions.is_supported_store_locale(store, locale))`

### actions.action_advisory_content

One typed informational or prerequisite item. Acknowledgment records a decision without pretending that an external effect occurred.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| kind | `actions.advisory_kind` | no |  |
| detail | `text` | yes |  |
| suggestion | `text` | yes |  |
| primary_link_label | `text` | yes |  |
| primary_link_path | `text` | yes |  |
| connector_source_id | `text` | yes |  |
| connector_type | `actions.advisory_connector_kind` | yes |  |
| connector_name_snapshot | `text` | yes |  |
| source_label | `text` | yes |  |
| benefit | `text` | yes |  |
| app_name_snapshot | `text` | yes |  |
| bundle_id_snapshot | `text` | yes |  |
| scraping_account_email_snapshot | `text` | yes |  |
| agent_source_id | `text` | yes |  |
| consecutive_failures | `bigint` | yes |  |
| last_success_at | `timestamp with time zone` | yes |  |
| last_error | `text` | yes |  |
| impact | `actions.closed_severity` | yes |  |
| effort | `actions.closed_severity` | yes |  |
| confidence_label | `actions.closed_severity` | yes |  |
| confidence_score | `numeric` | yes |  |
| quick_win_source_id | `text` | yes |  |
| recommendation_type | `actions.recommendation_kind` | yes |  |
| market_label | `text` | yes |  |
| gate_text | `text` | yes |  |
| capability_tier | `integer` | yes |  |
| proposed_next_step | `text` | yes |  |
| audit_store | `actions.store_kind` | yes |  |
| audit_store_app_id | `text` | yes |  |
| audit_country | `text` | yes |  |
| audit_locale | `text` | yes |  |
| audit_generated_at | `timestamp with time zone` | yes |  |
| blocker_reason_text | `text` | yes |  |
| blocker_reasoning | `text` | yes |  |
| unblock_title | `text` | yes |  |
| unblock_what_happened | `text` | yes |  |
| unblock_why_it_matters | `text` | yes |  |
| unblock_next | `text` | yes |  |
| unblock_cta_label | `text` | yes |  |
| unblock_cta_path | `text` | yes |  |

Keys and constraints:

- `action_advisory_content_capability_tier_check`: `CHECK (capability_tier >= 1 AND capability_tier <= 3)`
- `action_advisory_content_consecutive_failures_check`: `CHECK (consecutive_failures >= 0)`
- `action_advisory_content_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_advisory_content_pkey`: `PRIMARY KEY (organization_id, revision_id)`
- `action_advisory_content_primary_link_path_check`: `CHECK (primary_link_path IS NULL OR primary_link_path ~ '^/[^/]'::text)`
- `action_advisory_content_unblock_cta_path_check`: `CHECK (unblock_cta_path IS NULL OR unblock_cta_path ~ '^/[^/]'::text)`
- `actionsSchema_action_advisory_content_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_content_term

One ordered value with a finite role such as a selected field or keyword term. It cannot invent arbitrary property names.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| role | `actions.term_role` | no |  |
| ordinal | `integer` | no |  |
| term | `text` | no |  |
| meaning | `text` | yes |  |

Keys and constraints:

- `action_content_term_check`: `CHECK (role = 'gloss'::actions.term_role AND meaning IS NOT NULL OR role <> 'gloss'::actions.term_role AND meaning IS NULL)`
- `action_content_term_ordinal_check`: `CHECK (ordinal >= 0)`
- `action_content_term_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_content_term_pkey`: `PRIMARY KEY (organization_id, revision_id, role, ordinal)`
- `actionsSchema_action_content_term_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_content_note

One ordered prose note under a closed section role. It is content, not an executable payload.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| section | `actions.prose_section` | no |  |
| ordinal | `integer` | no |  |
| text_content | `text` | no |  |

Keys and constraints:

- `action_content_note_ordinal_check`: `CHECK (ordinal >= 0)`
- `action_content_note_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_content_note_pkey`: `PRIMARY KEY (organization_id, revision_id, section, ordinal)`
- `actionsSchema_action_content_note_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_market_country

One selected country for a revision; normalized repeating values instead of an array.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| role | `actions.country_role` | no |  |
| ordinal | `integer` | no |  |
| country | `text` | no |  |

Keys and constraints:

- `action_market_country_ordinal_check`: `CHECK (ordinal >= 0)`
- `action_market_country_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_request_content(organization_id, revision_id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_market_country_pkey`: `PRIMARY KEY (organization_id, revision_id, role, ordinal)`
- `actionsSchema_action_market_country_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_market_competitor

One explicit competitor target for a revision; normalized repeating values instead of an array.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| ordinal | `integer` | no |  |
| competitor_name | `text` | no |  |

Keys and constraints:

- `action_market_competitor_ordinal_check`: `CHECK (ordinal >= 0)`
- `action_market_competitor_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_request_content(organization_id, revision_id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_market_competitor_pkey`: `PRIMARY KEY (organization_id, revision_id, ordinal)`
- `actionsSchema_action_market_competitor_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

## Source links

### actions.action_revision_source

One typed link from a revision to an existing domain record. Real foreign keys preserve provenance.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| id | `text` | no |  |
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| kind | `actions.action_source_kind` | no |  |
| source_agent_run_id | `text` | yes |  |
| source_recommendation_id | `text` | yes |  |
| source_variant_id | `text` | yes |  |
| source_report_version_id | `text` | yes |  |
| source_backlog_id | `text` | yes |  |
| source_experiment_id | `text` | yes |  |
| source_action_id | `text` | yes |  |
| source_plan_coordinate | `text` | yes |  |
| source_finding_coordinate | `text` | yes |  |
| source_candidate_coordinate | `text` | yes |  |

Keys and constraints:

- `action_revision_source_check`: `CHECK (num_nonnulls(source_agent_run_id, source_recommendation_id, source_variant_id, source_report_version_id, source_backlog_id, source_experiment_id, source_action_id) = 1)`
- `action_revision_source_check1`: `CHECK ((kind = 'agent_run'::actions.action_source_kind) = (source_agent_run_id IS NOT NULL))`
- `action_revision_source_check2`: `CHECK ((kind = 'recommendation'::actions.action_source_kind) = (source_recommendation_id IS NOT NULL))`
- `action_revision_source_check3`: `CHECK ((kind = 'recommendation_variant'::actions.action_source_kind) = (source_variant_id IS NOT NULL))`
- `action_revision_source_check4`: `CHECK ((kind = 'report_version'::actions.action_source_kind) = (source_report_version_id IS NOT NULL))`
- `action_revision_source_check5`: `CHECK ((kind = 'backlog_item'::actions.action_source_kind) = (source_backlog_id IS NOT NULL))`
- `action_revision_source_check6`: `CHECK ((kind = 'experiment'::actions.action_source_kind) = (source_experiment_id IS NOT NULL))`
- `action_revision_source_check7`: `CHECK ((kind = 'action'::actions.action_source_kind) = (source_action_id IS NOT NULL))`
- `action_revision_source_check8`: `CHECK ((kind = ANY (ARRAY['agent_run'::actions.action_source_kind, 'report_version'::actions.action_source_kind])) OR source_plan_coordinate IS NULL AND source_finding_coordinate IS NULL AND source_candidate_coordinate IS NULL)`
- `action_revision_source_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_revision_source_organization_id_source_action_id_fkey`: `FOREIGN KEY (organization_id, source_action_id) REFERENCES actions.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_revision_source_pkey`: `PRIMARY KEY (id)`
- `action_revision_source_source_agent_run_id_fkey`: `FOREIGN KEY (source_agent_run_id) REFERENCES agent_run(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_revision_source_source_backlog_id_fkey`: `FOREIGN KEY (source_backlog_id) REFERENCES opportunity_backlog(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_revision_source_source_experiment_id_fkey`: `FOREIGN KEY (source_experiment_id) REFERENCES aso_experiment(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_revision_source_source_recommendation_id_fkey`: `FOREIGN KEY (source_recommendation_id) REFERENCES aso_recommendation(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_revision_source_source_report_version_id_fkey`: `FOREIGN KEY (source_report_version_id) REFERENCES report_version(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_revision_source_source_variant_id_fkey`: `FOREIGN KEY (source_variant_id) REFERENCES aso_recommendation_variant(id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `actionsSchema_action_revision_source_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### actions.action_alias

One namespace-qualified existing URL identity pointing to a permanent ticket. It carries no executable legacy parameters.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| namespace | `actions.action_alias_namespace` | no |  |
| old_id | `text` | no |  |
| action_id | `text` | no |  |
| historical_membership_known | `boolean` | no |  |

Keys and constraints:

- `action_alias_organization_id_action_id_fkey`: `FOREIGN KEY (organization_id, action_id) REFERENCES actions.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_alias_pkey`: `PRIMARY KEY (organization_id, namespace, old_id)`
- `actionsSchema_action_alias_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

## Apple Search Ads

### apple_ads.action_content

Apple Search Ads target IDs, operation, keyword match type, budget/bid decimal values and currency. All seven current operations share this constrained relation.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| intent | `apple_ads.ad_intent` | no |  |
| provider_account_id | `text` | no |  |
| provider_campaign_id | `text` | no |  |
| provider_ad_group_id | `text` | yes |  |
| provider_keyword_id | `text` | yes |  |
| provider_negative_keyword_id | `text` | yes |  |
| keyword_text | `text` | yes |  |
| match_type | `apple_ads.ad_match_type` | yes |  |
| daily_budget_amount | `numeric` | yes |  |
| bid_amount | `numeric` | yes |  |
| currency_code | `text` | yes |  |
| observed_status | `apple_ads.ad_observed_status` | yes |  |
| observation_availability | `actions.observation_availability` | yes |  |
| observation_captured_at | `timestamp with time zone` | yes |  |

Keys and constraints:

- `action_ad_content_bid_amount_check`: `CHECK (bid_amount > 0::numeric)`
- `action_ad_content_check`: `CHECK (intent <> 'set_campaign_budget'::apple_ads.ad_intent OR daily_budget_amount IS NOT NULL AND currency_code IS NOT NULL)`
- `action_ad_content_check1`: `CHECK (intent <> 'set_keyword_bid'::apple_ads.ad_intent OR provider_ad_group_id IS NOT NULL AND provider_keyword_id IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL)`
- `action_ad_content_check10`: `CHECK ((intent = ANY (ARRAY['create_keyword'::apple_ads.ad_intent, 'add_negative_keyword'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR keyword_text IS NULL AND match_type IS NULL)`
- `action_ad_content_check11`: `CHECK ((intent = ANY (ARRAY['set_keyword_bid'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR provider_keyword_id IS NULL)`
- `action_ad_content_check12`: `CHECK ((intent = ANY (ARRAY['delete_negative_keyword'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR provider_negative_keyword_id IS NULL)`
- `action_ad_content_check13`: `CHECK ((intent = ANY (ARRAY['set_keyword_bid'::apple_ads.ad_intent, 'create_keyword'::apple_ads.ad_intent, 'add_negative_keyword'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR provider_ad_group_id IS NULL)`
- `action_ad_content_check2`: `CHECK (intent <> 'create_keyword'::apple_ads.ad_intent OR provider_ad_group_id IS NOT NULL AND keyword_text IS NOT NULL AND match_type IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL)`
- `action_ad_content_check3`: `CHECK (intent <> 'add_negative_keyword'::apple_ads.ad_intent OR keyword_text IS NOT NULL AND match_type IS NOT NULL)`
- `action_ad_content_check4`: `CHECK (intent <> 'delete_negative_keyword'::apple_ads.ad_intent OR provider_negative_keyword_id IS NOT NULL)`
- `action_ad_content_check5`: `CHECK (intent <> 'observed'::apple_ads.ad_intent OR observation_availability IS NOT NULL AND observation_captured_at IS NOT NULL)`
- `action_ad_content_check6`: `CHECK (intent = 'observed'::apple_ads.ad_intent OR observed_status IS NULL)`
- `action_ad_content_check7`: `CHECK ((intent = ANY (ARRAY['set_campaign_budget'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR daily_budget_amount IS NULL)`
- `action_ad_content_check8`: `CHECK ((intent = ANY (ARRAY['set_keyword_bid'::apple_ads.ad_intent, 'create_keyword'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR bid_amount IS NULL)`
- `action_ad_content_check9`: `CHECK ((intent = ANY (ARRAY['set_keyword_bid'::apple_ads.ad_intent, 'set_campaign_budget'::apple_ads.ad_intent, 'create_keyword'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR currency_code IS NULL)`
- `action_ad_content_currency_code_check`: `CHECK (currency_code ~ '^[A-Z]{3}$'::text)`
- `action_ad_content_daily_budget_amount_check`: `CHECK (daily_budget_amount > 0::numeric)`
- `action_ad_content_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `action_ad_content_pkey`: `PRIMARY KEY (organization_id, revision_id)`
- `action_ad_content_provider_ad_group_id_check`: `CHECK (provider_ad_group_id ~ '^[1-9][0-9]*$'::text)`
- `action_ad_content_provider_campaign_id_check`: `CHECK (provider_campaign_id ~ '^[1-9][0-9]*$'::text)`
- `action_ad_content_provider_keyword_id_check`: `CHECK (provider_keyword_id ~ '^[1-9][0-9]*$'::text)`
- `action_ad_content_provider_negative_keyword_id_check`: `CHECK (provider_negative_keyword_id ~ '^[1-9][0-9]*$'::text)`
- `appleAdsSchema_action_content_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

### apple_ads.attempt_receipt

Apple Search Ads native receipt/resource identity for one attempt. It is not a common lifecycle state.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| attempt_id | `text` | no |  |
| provider_request_id | `text` | yes |  |
| provider_resource_id | `text` | yes |  |
| provider_error_code | `text` | yes |  |

Keys and constraints:

- `appleAdsSchema_attempt_receipt_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `attempt_receipt_apple_ads_owner_fk`: `FOREIGN KEY (organization_id, attempt_id) REFERENCES actions.action_execution_attempt(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `attempt_receipt_organization_id_attempt_id_pk`: `PRIMARY KEY (organization_id, attempt_id)`
- `provider_fact_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

## App Store Connect

### app_store_connect.listing_contract

ASC app-info/version/localization and App Clip contract for one revision; isolated from Play edit semantics.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| provider_account_id | `text` | no |  |
| provider_app_id | `text` | yes |  |
| app_info_id | `text` | yes |  |
| app_info_localization_id | `text` | yes |  |
| app_version_id | `text` | yes |  |
| app_version_localization_id | `text` | yes |  |
| live_promotional_version_id | `text` | yes |  |
| live_promotional_localization_id | `text` | yes |  |
| app_clip_operation | `app_store_connect.app_clip_operation` | no | 'none'::app_store_connect.app_clip_operation |
| app_clip_id | `text` | yes |  |
| app_clip_experience_id | `text` | yes |  |
| app_clip_release_version_id | `text` | yes |  |
| app_clip_localization_id | `text` | yes |  |
| app_clip_source_localization_id | `text` | yes |  |
| app_clip_subtitle | `text` | yes |  |
| app_clip_header_media_slot | `integer` | yes |  |
| app_clip_incomplete_header_id | `text` | yes |  |
| app_clip_header_state | `app_store_connect.app_clip_header_state` | yes |  |
| live_promotional_text_state | `actions.content_value_state` | no | 'unspecified'::actions.content_value_state |
| live_promotional_text | `text` | yes |  |

Keys and constraints:

- `appStoreConnectSchema_listing_contract_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `asc_listing_header_media_fk`: `FOREIGN KEY (organization_id, revision_id, app_clip_header_media_slot) REFERENCES actions.action_media_content(organization_id, revision_id, slot) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `listing_contract_app_store_connect_owner_fk`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_listing_content(organization_id, revision_id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `listing_contract_organization_id_revision_id_pk`: `PRIMARY KEY (organization_id, revision_id)`

### app_store_connect.step_contract

ASC App Clip reservation and upload-step coordinates, bound to the source reservation attempt and frozen media slot.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| step_id | `text` | no |  |
| media_slot | `integer` | yes |  |
| upload_offset | `bigint` | yes |  |
| upload_length | `bigint` | yes |  |
| source_reserve_attempt_id | `text` | yes |  |
| upload_url_ciphertext | `text` | yes |  |
| upload_method | `app_store_connect.upload_method` | yes |  |
| upload_content_type | `app_store_connect.upload_content_type` | yes |  |

Keys and constraints:

- `appStoreConnectSchema_step_contract_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `asc_step_source_reserve_attempt_fk`: `FOREIGN KEY (organization_id, source_reserve_attempt_id) REFERENCES actions.action_execution_attempt(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `asc_step_upload_contract_shape`: `CHECK ((upload_offset IS NOT NULL) = (source_reserve_attempt_id IS NOT NULL) AND (upload_offset IS NOT NULL) = (upload_url_ciphertext IS NOT NULL) AND (upload_offset IS NOT NULL) = (upload_method IS NOT NULL) AND (upload_content_type IS NULL OR upload_offset IS NOT NULL) AND (upload_url_ciphertext IS NULL OR length(upload_url_ciphertext) > 0))`
- `provider_fact_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `step_contract_app_store_connect_owner_fk`: `FOREIGN KEY (organization_id, step_id) REFERENCES actions.action_execution_step(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `step_contract_organization_id_step_id_pk`: `PRIMARY KEY (organization_id, step_id)`

### app_store_connect.attempt_receipt

ASC native resource, upload reservation or receipt facts for one attempt.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| attempt_id | `text` | no |  |
| provider_request_id | `text` | yes |  |
| provider_resource_id | `text` | yes |  |
| provider_localization_id | `text` | yes |  |
| provider_media_id | `text` | yes |  |
| provider_error_code | `text` | yes |  |

Keys and constraints:

- `appStoreConnectSchema_attempt_receipt_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `attempt_receipt_app_store_connect_owner_fk`: `FOREIGN KEY (organization_id, attempt_id) REFERENCES actions.action_execution_attempt(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `attempt_receipt_organization_id_attempt_id_pk`: `PRIMARY KEY (organization_id, attempt_id)`
- `provider_fact_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

## Google Play

### google_play.listing_contract

Play package/edit contract and explicit commit policy for one listing revision.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| provider_account_id | `text` | no |  |
| package_name | `text` | yes |  |
| google_edit_id | `text` | yes |  |
| play_commit_policy | `google_play.play_commit_policy` | yes |  |

Keys and constraints:

- `googlePlaySchema_listing_contract_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `listing_contract_google_play_owner_fk`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions.action_listing_content(organization_id, revision_id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `listing_contract_organization_id_revision_id_pk`: `PRIMARY KEY (organization_id, revision_id)`

### google_play.attempt_receipt

Play edit identity, expiry and native outcome for one attempt.

| Field | PostgreSQL type | Nullable | Default |
|---|---|---|---|
| organization_id | `text` | no |  |
| attempt_id | `text` | no |  |
| provider_request_id | `text` | yes |  |
| provider_resource_id | `text` | yes |  |
| provider_edit_id | `text` | yes |  |
| provider_edit_expires_at | `timestamp with time zone` | yes |  |
| provider_error_code | `text` | yes |  |

Keys and constraints:

- `attempt_receipt_google_play_owner_fk`: `FOREIGN KEY (organization_id, attempt_id) REFERENCES actions.action_execution_attempt(organization_id, id) DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `attempt_receipt_organization_id_attempt_id_pk`: `PRIMARY KEY (organization_id, attempt_id)`
- `googlePlaySchema_attempt_receipt_org_erase_fk`: `FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred
- `provider_fact_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED` · deferrable initially deferred

## Closed enum values

- `actions.action_alias_namespace`: `pending_action`, `pending_action_batch`, `review_draft`, `review_draft_batch`, `agent_request`, `agent_activity`, `review_history`, `review_draft_rejection`, `capability_execution`, `recommendation`, `recommendation_variant`, `recovery_receipt`
- `actions.action_attempt_kind`: `write`, `readback`, `generation`, `late_evidence`
- `actions.action_attempt_result`: `acknowledged`, `known_not_applied`, `uncertain`, `matched`, `matched_external`, `mismatch`, `unreadable`, `generated`, `discarded`
- `actions.action_authorization_scope`: `perform`, `generate`, `revise`
- `actions.action_channel`: `web`, `chat`, `mcp`, `api`, `slack`, `discord`, `agent`, `worker`, `operator`, `migration`
- `actions.action_command_error`: `stale_version`, `stale_revision`, `stale_membership`, `invalid_transition`, `undo_expired`, `execution_started`, `unresolved_write`, `permission_changed`, `billing_required`, `unsupported_operation`, `idempotency_mismatch`, `target_changed`, `not_found`
- `actions.action_command_kind`: `create`, `revise`, `approve`, `undo`, `reject`, `acknowledge`, `snooze`, `unsnooze`, `assign`, `archive`, `restore`, `supersede`, `retry`, `reconcile`, `record_observation`, `record_attempt`, `record_progress`, `resolve_dependency`, `resolve_external`, `grant_policy`, `revoke_policy`
- `actions.action_command_outcome`: `accepted`, `conflict`, `refused`
- `actions.action_decision`: `open`, `approved`, `declined`, `acknowledged`, `handled_externally`, `cancelled`, `superseded`
- `actions.action_dependency_requirement`: `completed`, `verified_live`, `verified_editable`, `generated`, `permission_restored`, `release_available`
- `actions.action_execution_phase`: `ready`, `claimed`, `verification_due`, `uncertain`, `blocked`, `settled`, `cancelled`
- `actions.action_execution_result`: `generated`, `verified_live`, `verified_editable`, `handled_externally`, `acknowledged_only`, `failed`, `cancelled`
- `actions.action_failure_class`: `permission`, `rate_limit`, `transport`, `target_changed`, `provider_rejected`, `persistence`, `unsupported_readback`, `invalid_content`, `billing`
- `actions.action_hold_reason`: `permission`, `billing`, `resource_busy`, `target_changed`, `uncertain_write`, `retry_exhausted`, `unsupported_readback`, `generation_conflict`, `awaiting_release`
- `actions.action_no_work_reason`: `no_eligible_reviews`
- `actions.action_non_application_basis`: `pre_dispatch_failure`, `provider_rejection`, `provider_terminal_non_application`, `expired_uncommitted_edit`
- `actions.action_observation_completeness`: `complete`, `partial`, `unavailable`
- `actions.action_output_kind`: `revision`, `review_analysis`, `agent_run`, `no_work`
- `actions.action_principal`: `user`, `api_key`, `agent`, `policy`, `system`
- `actions.action_recovery_mode`: `readback_before_retry`, `native_idempotency`, `manual_reconciliation`, `internal_atomic`
- `actions.action_resource_scope`: `store_application`, `advertising_account`
- `actions.action_retry_disposition`: `retryable`, `permanent`
- `actions.action_revision_purpose`: `proposal`, `baseline`, `observation`
- `actions.action_source_kind`: `agent_run`, `recommendation`, `recommendation_variant`, `report_version`, `backlog_item`, `experiment`, `action`
- `actions.action_step_kind`: `asc_app_info_localization_upsert`, `asc_version_localization_upsert`, `asc_live_promotional_text_set`, `asc_editable_promotional_text_set`, `asc_review_response_upsert`, `asc_app_clip_localization_create`, `asc_app_clip_header_reserve`, `asc_app_clip_header_upload_chunk`, `asc_app_clip_header_commit`, `asc_app_clip_incomplete_header_delete`, `play_edit_create`, `play_listing_set`, `play_edit_commit`, `play_inspection_edit_create`, `play_inspection_edit_delete`, `play_review_response_set`, `asa_campaign_status_set`, `asa_campaign_budget_set`, `asa_keyword_bid_set`, `asa_keyword_create`, `asa_negative_keyword_create`, `asa_negative_keyword_delete`, `internal_generate_content`, `internal_revise_content`, `internal_commit_children`, `internal_recheck_prerequisite`
- `actions.action_surface`: `provider_response`, `editable_listing`, `live_listing`, `review_response`, `advertising_resource`, `internal_artifact`
- `actions.action_transport`: `asc_api`, `asc_browser`, `play_api`, `play_session`, `play_browser`, `asa_api`, `internal`
- `actions.action_uncertainty_reason`: `transport_lost`, `claim_expired`, `invalid_response`
- `actions.action_unreadable_reason`: `unavailable`, `partial`, `unsupported`
- `actions.action_verification_timing`: `before_successor`, `after_effects`
- `actions.advisory_connector_kind`: `app_store_connect`, `apple_search_ads`
- `actions.advisory_kind`: `optimize_keywords`, `improve_retention`, `adjust_monetization`, `update_store_listing`, `review_finding`, `aso_review_needed`, `agent_attention_needed`, `onboarding_audit_recommendation`, `connect_source`, `store_app_access_lost`, `flag_issue`, `escalate`, `stage_blocker`
- `actions.approval_setting`: `auto`, `await`
- `actions.closed_severity`: `low`, `medium`, `high`
- `actions.content_value_state`: `unspecified`, `present`, `empty`, `dismissed`, `unreadable`
- `actions.country_role`: `demand`, `competitor`
- `actions.gloss_status`: `updating`, `ready`, `unavailable`
- `actions.listing_intent`: `create`, `update`, `repair`, `restore`, `observed`
- `actions.listing_version_state`: `editable`, `in_review`, `processing`, `live`, `rejected`, `removed`, `unreadable`
- `actions.media_availability`: `stored`, `missing`, `unreadable`
- `actions.media_display_type`: `APP_APPLE_TV`, `APP_APPLE_VISION_PRO`, `APP_DESKTOP`, `APP_IPAD_105`, `APP_IPAD_97`, `APP_IPAD_PRO_129`, `APP_IPAD_PRO_3GEN_11`, `APP_IPAD_PRO_3GEN_129`, `APP_IPHONE_35`, `APP_IPHONE_40`, `APP_IPHONE_47`, `APP_IPHONE_55`, `APP_IPHONE_58`, `APP_IPHONE_61`, `APP_IPHONE_65`, `APP_IPHONE_67`, `APP_WATCH_SERIES_10`, `APP_WATCH_SERIES_3`, `APP_WATCH_SERIES_4`, `APP_WATCH_SERIES_7`, `APP_WATCH_ULTRA`, `phoneScreenshots`, `sevenInchScreenshots`
- `actions.media_kind`: `screenshot`, `icon`, `app_preview`, `app_clip_header`
- `actions.media_storage_immutability`: `versioned_object`, `content_addressed_immutable`
- `actions.observation_availability`: `present`, `absent`, `unreadable`, `pending`, `unknown`
- `actions.prose_section`: `what_will_happen`, `supporting_evidence`, `description_outline`, `prioritization`, `notes`, `unblock_steps`
- `actions.recommendation_kind`: `keywords`, `promotional_text`, `description`, `screenshots`, `icon`, `app_previews`, `title_subtitle`, `cpp`, `short_description`, `title`, `subtitle`, `locale_expansion`
- `actions.reply_intent`: `send`, `update`, `observed`
- `actions.request_intent`: `locale_expansion`, `listing_change`, `review_catch_up`, `review_analysis`, `wake_agent`
- `actions.request_origin`: `scheduled_agent`, `user_directed_chat_or_mcp`, `human`, `system`
- `actions.research_coverage`: `ready`, `cold`
- `actions.review_publication_state`: `published`, `pending_publication`, `hidden`, `deleted`, `unreadable`
- `actions.store_kind`: `ios`, `android`
- `actions.term_role`: `added`, `removed`, `gloss`, `trending`
- `app_store_connect.app_clip_header_state`: `absent`, `incomplete`, `complete`, `unreadable`
- `app_store_connect.app_clip_operation`: `none`, `create_localization`, `repair_header`, `observed`
- `app_store_connect.upload_content_type`: `image/png`, `image/jpeg`
- `app_store_connect.upload_method`: `PUT`
- `apple_ads.ad_intent`: `pause_campaign`, `enable_campaign`, `set_campaign_budget`, `set_keyword_bid`, `create_keyword`, `add_negative_keyword`, `delete_negative_keyword`, `observed`
- `apple_ads.ad_match_type`: `EXACT`, `BROAD`
- `apple_ads.ad_observed_status`: `ENABLED`, `ACTIVE`, `PAUSED`, `DELETED`
- `google_play.play_commit_policy`: `ERROR_IF_IN_REVIEW`

## Relational projections

### actions.action_execution_attempt_contract

```sql
 SELECT base.id,
    base.organization_id,
    base.step_id,
    base.number,
    base.kind,
    base.claim_generation,
    base.subject_attempt_id,
    base.agent_run_id,
    base.connector_id,
    base.transport,
    base.started_at,
    base.finished_at,
    base.result,
    base.observation_revision_id,
    base.comparison_version,
    COALESCE(asc_contract.provider_request_id, play.provider_request_id, asa.provider_request_id) AS provider_request_id,
    COALESCE(asc_contract.provider_resource_id, play.provider_resource_id, asa.provider_resource_id) AS provider_resource_id,
    play.provider_edit_id,
    asc_contract.provider_localization_id,
    asc_contract.provider_media_id,
    COALESCE(asc_contract.provider_error_code, play.provider_error_code, asa.provider_error_code) AS provider_error_code,
    base.failure_class,
    base.recorded_at,
    base.execution_id,
    base.claim_token,
    base.input_attempt_id,
    base.input_parent_revision_id,
    base.output_kind,
    base.output_revision_id,
    base.output_review_analysis_id,
    base.output_agent_run_id,
    base.no_work_reason,
    base.finalized_claim_generation,
    base.finalized_claim_token,
    base.evidence_command_id,
    base.observation_surface,
    base.observation_completeness,
    base.observed_at,
    base.non_application_basis,
    play.provider_edit_expires_at,
    base.retry_disposition,
    base.uncertainty_reason,
    base.unreadable_reason
   FROM (((actions.action_execution_attempt base
     LEFT JOIN app_store_connect.attempt_receipt asc_contract ON (((asc_contract.organization_id = base.organization_id) AND (asc_contract.attempt_id = base.id))))
     LEFT JOIN google_play.attempt_receipt play ON (((play.organization_id = base.organization_id) AND (play.attempt_id = base.id))))
     LEFT JOIN apple_ads.attempt_receipt asa ON (((asa.organization_id = base.organization_id) AND (asa.attempt_id = base.id))));
```

### actions.action_execution_step_contract

```sql
 SELECT base.id,
    base.organization_id,
    base.execution_id,
    base.ordinal,
    base.kind,
    base.adapter_version,
    base.input_step_id,
    base.content_revision_id,
    asc_contract.media_slot,
    asc_contract.upload_offset,
    asc_contract.upload_length,
    base.recovery_mode,
    base.recovery_policy_version,
    base.native_idempotency_key,
    base.required_surface,
    asc_contract.source_reserve_attempt_id,
    asc_contract.upload_url_ciphertext,
    asc_contract.upload_method,
    asc_contract.upload_content_type,
    base.verification_timing
   FROM (actions.action_execution_step base
     LEFT JOIN app_store_connect.step_contract asc_contract ON (((asc_contract.organization_id = base.organization_id) AND (asc_contract.step_id = base.id))));
```

### actions.action_listing_contract

```sql
 SELECT base.organization_id,
    base.revision_id,
    COALESCE(asc_contract.provider_account_id, play.provider_account_id) AS provider_account_id,
    base.store,
    base.locale,
    base.intent,
    asc_contract.provider_app_id,
    play.package_name,
    asc_contract.app_info_id,
    asc_contract.app_info_localization_id,
    asc_contract.app_version_id,
    asc_contract.app_version_localization_id,
    play.google_edit_id,
    base.title_state,
    base.title,
    base.subtitle_state,
    base.subtitle,
    base.description_state,
    base.description,
    base.keywords_state,
    base.keywords,
    base.promotional_text_state,
    base.promotional_text,
    base.short_description_state,
    base.short_description,
    base.whats_new_state,
    base.whats_new,
    base.support_url_state,
    base.support_url,
    base.keyword_analysis,
    base.operator_instructions,
    base.source_fingerprint,
    base.naturalness_check_skipped,
    base.fidelity_check_skipped,
    base.english_title,
    base.english_subtitle,
    base.english_promotional_text,
    base.gloss_status,
    base.research_country,
    base.research_coverage,
    base.research_model_source,
    base.research_model_version,
    base.research_model_formula,
    base.app_tier,
    base.app_tier_resolved,
    base.candidate_count,
    base.judged_count,
    base.scored_count,
    base.p0_count,
    base.p1_count,
    base.p2_count,
    base.with_volume_count,
    base.conformance_term_count,
    base.conformance_from_table_count,
    base.observation_availability,
    base.observation_captured_at,
    base.source_capture_at,
    play.play_commit_policy,
    COALESCE(asc_contract.app_clip_operation, 'none'::app_store_connect.app_clip_operation) AS app_clip_operation,
    asc_contract.app_clip_id,
    asc_contract.app_clip_experience_id,
    asc_contract.app_clip_release_version_id,
    asc_contract.app_clip_localization_id,
    asc_contract.app_clip_source_localization_id,
    asc_contract.app_clip_subtitle,
    asc_contract.app_clip_header_media_slot,
    base.provider_version_state,
    asc_contract.live_promotional_version_id,
    asc_contract.live_promotional_localization_id,
    COALESCE(asc_contract.live_promotional_text_state, 'unspecified'::actions.content_value_state) AS live_promotional_text_state,
    asc_contract.live_promotional_text,
    asc_contract.app_clip_incomplete_header_id,
    asc_contract.app_clip_header_state
   FROM ((actions.action_listing_content base
     LEFT JOIN app_store_connect.listing_contract asc_contract ON (((asc_contract.organization_id = base.organization_id) AND (asc_contract.revision_id = base.revision_id))))
     LEFT JOIN google_play.listing_contract play ON (((play.organization_id = base.organization_id) AND (play.revision_id = base.revision_id))));
```

