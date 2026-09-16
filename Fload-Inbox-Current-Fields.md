# Fload inbox — actual current-capability schema

Generated from the isolated PostgreSQL 17 design proof at 2026-09-15T19:40:07Z.

**25 relations · 464 fields.** This is proposed executable DDL, not the deployed application schema or a production migration.

The [16 September provider boundary amendment](Fload-Provider-Boundary-Review.md) recommends a responsibility/schema split that is not applied to this tested baseline.

All fields below are introspected after all schema guards and domain bindings are applied. JSON is used only to distribute the catalog; no SQL JSON/JSONB or array columns exist.

## Ticket and content version

### `action`

One permanent ticket. Organization, structural parent, owner, current decision and revision.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| id | `text` | no |  |
| organization_id | `text` | no |  |
| creation_key | `uuid` | no | gen_random_uuid() |
| asset_id | `text` | yes |  |
| domain | `text` | no |  |
| parent_action_id | `text` | yes |  |
| decision | `actions_design.action_decision` | no | 'open'::actions_design.action_decision |
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

Constraints:

* `action_asset_id_fkey`: `FOREIGN KEY (asset_id) REFERENCES asset(id)`
* `action_attention_version_check`: `CHECK (attention_version > 0)`
* `action_check`: `CHECK (updated_at >= created_at)`
* `action_check1`: `CHECK ((decision = 'superseded'::actions_design.action_decision) = (successor_action_id IS NOT NULL))`
* `action_check2`: `CHECK (successor_action_id IS DISTINCT FROM id)`
* `action_check3`: `CHECK (parent_action_id IS DISTINCT FROM id)`
* `action_command_head`: `TRIGGER DEFERRABLE INITIALLY DEFERRED`
* `action_domain_check`: `CHECK (domain = ANY (ARRAY['reviews'::text, 'listing'::text, 'ads'::text, 'agent'::text, 'advisory'::text, 'collection'::text]))`
* `action_graph_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED`
* `action_last_command_fk`: `FOREIGN KEY (organization_id, last_command_id) REFERENCES actions_design.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_organization_id_creation_key_key`: `UNIQUE (organization_id, creation_key)`
* `action_organization_id_fkey`: `FOREIGN KEY (organization_id) REFERENCES organization(id)`
* `action_organization_id_id_current_approval_id_fkey`: `FOREIGN KEY (organization_id, id, current_approval_id) REFERENCES actions_design.action_approval(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_organization_id_id_current_revision_id_fkey`: `FOREIGN KEY (organization_id, id, current_revision_id) REFERENCES actions_design.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_organization_id_id_key`: `UNIQUE (organization_id, id)`
* `action_organization_id_parent_action_id_fkey`: `FOREIGN KEY (organization_id, parent_action_id) REFERENCES actions_design.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_organization_id_successor_action_id_fkey`: `FOREIGN KEY (organization_id, successor_action_id) REFERENCES actions_design.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_owner_user_id_fkey`: `FOREIGN KEY (owner_user_id) REFERENCES "user"(id)`
* `action_pkey`: `PRIMARY KEY (id)`
* `action_priority_check`: `CHECK (priority >= 1 AND priority <= 3)`
* `action_version_check`: `CHECK (version > 0)`

### `action_revision`

Immutable typed content. Kind and operation belong here, so a locale ticket can advance from generation request to listing proposal.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| id | `text` | no |  |
| organization_id | `text` | no |  |
| action_id | `text` | no |  |
| purpose | `actions_design.action_revision_purpose` | no |  |
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

Constraints:

* `action_revision_action_id_revision_number_key`: `UNIQUE (action_id, revision_number)`
* `action_revision_canonicalization_version_check`: `CHECK (canonicalization_version > 0)`
* `action_revision_check`: `CHECK (id IS DISTINCT FROM baseline_revision_id AND id IS DISTINCT FROM generated_from_revision_id)`
* `action_revision_content_digest_check`: `CHECK (content_digest ~ '^[0-9a-f]{64}$'::text)`
* `action_revision_organization_id_action_id_baseline_revisio_fkey`: `FOREIGN KEY (organization_id, action_id, baseline_revision_id) REFERENCES actions_design.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_revision_organization_id_action_id_fkey`: `FOREIGN KEY (organization_id, action_id) REFERENCES actions_design.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_revision_organization_id_action_id_generated_from_r_fkey`: `FOREIGN KEY (organization_id, action_id, generated_from_revision_id) REFERENCES actions_design.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_revision_organization_id_action_id_id_key`: `UNIQUE (organization_id, action_id, id)`
* `action_revision_organization_id_authored_command_id_fkey`: `FOREIGN KEY (organization_id, authored_command_id) REFERENCES actions_design.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_revision_organization_id_id_key`: `UNIQUE (organization_id, id)`
* `action_revision_pkey`: `PRIMARY KEY (id)`
* `action_revision_revision_number_check`: `CHECK (revision_number > 0)`
* `provider_content_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED`
* `revision_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED`
* `revision_kind_closed`: `CHECK (kind = ANY (ARRAY['review_reply'::text, 'listing'::text, 'media'::text, 'request'::text, 'ads'::text, 'advisory'::text, 'collection'::text]))`
* `revision_operation_closed`: `CHECK (kind = 'review_reply'::text AND operation = 'post_reply'::text OR kind = 'listing'::text AND (operation = ANY (ARRAY['apply_listing_changes'::text, 'update_promo_text'::text, 'create_locale'::text, 'update_description'::text, 'update_short_description'::text, 'revert_experiment'::text, 'aso_revert_listing'::text])) OR kind = 'media'::text AND operation = 'generate_media'::text OR kind = 'request'::text AND (operation = ANY (ARRAY['generate_locale'::text, 'generate_listing'::text, 'review_catch_up_30d'::text, 'generate_review_analysis'::text, 'run_agent'::text])) OR kind = 'ads'::text AND (operation = ANY (ARRAY['asa_pause_campaign'::text, 'asa_enable_campaign'::text, 'asa_update_campaign_budget'::text, 'asa_update_keyword_bid'::text, 'asa_create_keyword'::text, 'asa_add_negative_keyword'::text, 'asa_delete_negative_keyword'::text])) OR kind = 'advisory'::text AND (operation = ANY (ARRAY['acknowledge'::text, 'resolve_prerequisite'::text])) OR kind = 'collection'::text AND (operation = ANY (ARRAY['post_batch'::text, 'apply_listing_changes'::text, 'localize'::text, 'asa_update_keyword_bid'::text, 'revert_experiment'::text, 'aso_revert_listing'::text])))`

### `action_membership`

A collection revision pins the exact child tickets and child revisions shown for approval.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| parent_revision_id | `text` | no |  |
| child_action_id | `text` | no |  |
| child_revision_id | `text` | no |  |
| ordinal | `integer` | no |  |

Constraints:

* `action_membership_ordinal_check`: `CHECK (ordinal >= 0)`
* `action_membership_organization_id_child_action_id_child_re_fkey`: `FOREIGN KEY (organization_id, child_action_id, child_revision_id) REFERENCES actions_design.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_membership_organization_id_parent_revision_id_child__key`: `UNIQUE (organization_id, parent_revision_id, child_action_id, child_revision_id)`
* `action_membership_organization_id_parent_revision_id_fkey`: `FOREIGN KEY (organization_id, parent_revision_id) REFERENCES actions_design.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_membership_parent_revision_id_ordinal_key`: `UNIQUE (parent_revision_id, ordinal)`
* `action_membership_pkey`: `PRIMARY KEY (parent_revision_id, child_action_id)`

### `action_dependency`

Typed prerequisites between tickets; a child can itself be a ticket with dependencies.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| dependent_action_id | `text` | no |  |
| prerequisite_action_id | `text` | no |  |
| requirement | `actions_design.action_dependency_requirement` | no |  |
| created_command_id | `text` | no |  |

Constraints:

* `action_dependency_check`: `CHECK (dependent_action_id <> prerequisite_action_id)`
* `action_dependency_organization_id_created_command_id_fkey`: `FOREIGN KEY (organization_id, created_command_id) REFERENCES actions_design.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_dependency_organization_id_dependent_action_id_fkey`: `FOREIGN KEY (organization_id, dependent_action_id) REFERENCES actions_design.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_dependency_organization_id_prerequisite_action_id_fkey`: `FOREIGN KEY (organization_id, prerequisite_action_id) REFERENCES actions_design.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_dependency_pkey`: `PRIMARY KEY (dependent_action_id, prerequisite_action_id, requirement)`
* `dependency_no_cycle`: `TRIGGER DEFERRABLE INITIALLY DEFERRED`

### `action_read`

Personal watermark only. Never the owner of snooze, rejection, iteration or approval.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| user_id | `text` | no |  |
| action_id | `text` | no |  |
| seen_attention_version | `bigint` | no |  |
| force_unread | `boolean` | no | false |
| updated_at | `timestamp with time zone` | no |  |

Constraints:

* `action_read_organization_id_action_id_fkey`: `FOREIGN KEY (organization_id, action_id) REFERENCES actions_design.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_read_pkey`: `PRIMARY KEY (organization_id, user_id, action_id)`
* `action_read_seen_attention_version_check`: `CHECK (seen_attention_version >= 0)`
* `action_read_user_id_fkey`: `FOREIGN KEY (user_id) REFERENCES "user"(id)`

## Commands and authority

### `action_command`

Attributable, idempotent request and immutable outcome. Human, API key, agent, policy or system principal.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| id | `text` | no |  |
| organization_id | `text` | no |  |
| idempotency_key | `uuid` | no |  |
| principal_kind | `actions_design.action_principal` | no |  |
| actor_user_id | `text` | yes |  |
| actor_api_key_id | `text` | yes |  |
| actor_agent_run_id | `text` | yes |  |
| actor_policy_revision_id | `text` | yes |  |
| target_policy_revision_id | `text` | yes |  |
| actor_subject_snapshot | `text` | no |  |
| actor_name_snapshot | `text` | yes |  |
| channel | `actions_design.action_channel` | no |  |
| external_actor_id | `text` | yes |  |
| kind | `actions_design.action_command_kind` | no |  |
| request_digest | `character(64)` | no |  |
| digest_version | `integer` | no |  |
| outcome | `actions_design.action_command_outcome` | no |  |
| error | `actions_design.action_command_error` | yes |  |
| message | `text` | yes |  |
| accepted_at | `timestamp with time zone` | no |  |
| actor_slack_integration_id | `text` | yes |  |
| actor_discord_integration_id | `text` | yes |  |
| acting_for_user_id | `text` | yes |  |

Constraints:

* `action_command_acting_for_user_id_fkey`: `FOREIGN KEY (acting_for_user_id) REFERENCES "user"(id)`
* `action_command_actor_agent_run_id_fkey`: `FOREIGN KEY (actor_agent_run_id) REFERENCES agent_run(id)`
* `action_command_actor_api_key_id_fkey`: `FOREIGN KEY (actor_api_key_id) REFERENCES api_key(id)`
* `action_command_actor_discord_integration_id_fkey`: `FOREIGN KEY (actor_discord_integration_id) REFERENCES discord_integration(id)`
* `action_command_actor_slack_integration_id_fkey`: `FOREIGN KEY (actor_slack_integration_id) REFERENCES slack_integration(id)`
* `action_command_actor_user_id_fkey`: `FOREIGN KEY (actor_user_id) REFERENCES "user"(id)`
* `action_command_check`: `CHECK ((outcome = 'accepted'::actions_design.action_command_outcome) = (error IS NULL))`
* `action_command_check1`: `CHECK ((principal_kind <> ALL (ARRAY['user'::actions_design.action_principal, 'api_key'::actions_design.action_principal])) OR actor_user_id IS NOT NULL)`
* `action_command_check2`: `CHECK ((principal_kind = 'api_key'::actions_design.action_principal) = (actor_api_key_id IS NOT NULL))`
* `action_command_check3`: `CHECK ((principal_kind = 'policy'::actions_design.action_principal) = (actor_policy_revision_id IS NOT NULL))`
* `action_command_check4`: `CHECK (principal_kind <> 'agent'::actions_design.action_principal OR actor_agent_run_id IS NOT NULL)`
* `action_command_check5`: `CHECK ((kind <> ALL (ARRAY['grant_policy'::actions_design.action_command_kind, 'revoke_policy'::actions_design.action_command_kind])) OR target_policy_revision_id IS NOT NULL)`
* `action_command_digest_version_check`: `CHECK (digest_version > 0)`
* `action_command_organization_id_actor_policy_revision_id_fkey`: `FOREIGN KEY (organization_id, actor_policy_revision_id) REFERENCES actions_design.action_policy_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_command_organization_id_fkey`: `FOREIGN KEY (organization_id) REFERENCES organization(id)`
* `action_command_organization_id_id_key`: `UNIQUE (organization_id, id)`
* `action_command_organization_id_principal_kind_actor_subject_key`: `UNIQUE (organization_id, principal_kind, actor_subject_snapshot, idempotency_key)`
* `action_command_organization_id_target_policy_revision_id_fkey`: `FOREIGN KEY (organization_id, target_policy_revision_id) REFERENCES actions_design.action_policy_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_command_pkey`: `PRIMARY KEY (id)`
* `action_command_request_digest_check`: `CHECK (request_digest ~ '^[0-9a-f]{64}$'::text)`
* `command_delegation_shape`: `CHECK (acting_for_user_id IS NULL OR principal_kind = 'user'::actions_design.action_principal AND (channel = ANY (ARRAY['operator'::actions_design.action_channel, 'web'::actions_design.action_channel])))`
* `command_external_actor_shape`: `CHECK (channel = 'slack'::actions_design.action_channel AND principal_kind = 'user'::actions_design.action_principal AND external_actor_id IS NOT NULL AND actor_slack_integration_id IS NOT NULL AND actor_discord_integration_id IS NULL OR channel = 'discord'::actions_design.action_channel AND principal_kind = 'user'::actions_design.action_principal AND external_actor_id IS NOT NULL AND actor_discord_integration_id IS NOT NULL AND actor_slack_integration_id IS NULL OR (channel <> ALL (ARRAY['slack'::actions_design.action_channel, 'discord'::actions_design.action_channel])) AND external_actor_id IS NULL AND actor_slack_integration_id IS NULL AND actor_discord_integration_id IS NULL)`
* `command_policy_target_shape`: `CHECK ((kind = ANY (ARRAY['grant_policy'::actions_design.action_command_kind, 'revoke_policy'::actions_design.action_command_kind])) = (target_policy_revision_id IS NOT NULL))`
* `command_principal_exclusive`: `CHECK (principal_kind = 'user'::actions_design.action_principal AND actor_user_id IS NOT NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NULL OR principal_kind = 'api_key'::actions_design.action_principal AND actor_user_id IS NOT NULL AND actor_api_key_id IS NOT NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NULL OR principal_kind = 'agent'::actions_design.action_principal AND actor_user_id IS NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NOT NULL AND actor_policy_revision_id IS NULL OR principal_kind = 'policy'::actions_design.action_principal AND actor_user_id IS NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NOT NULL OR principal_kind = 'system'::actions_design.action_principal AND actor_user_id IS NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NULL)`
* `command_result_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED`
* `command_subject_nonempty`: `CHECK (length(actor_subject_snapshot) > 0)`

### `action_command_target`

Exact per-ticket preconditions and before/after result of a command, including batch children.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| command_id | `text` | no |  |
| action_id | `text` | no |  |
| expected_version | `bigint` | yes |  |
| expected_revision_id | `text` | yes |  |
| expected_parent_revision_id | `text` | yes |  |
| previous_version | `bigint` | yes |  |
| result_version | `bigint` | no |  |
| previous_decision | `actions_design.action_decision` | yes |  |
| result_decision | `actions_design.action_decision` | no |  |
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

Constraints:

* `action_command_target_organization_id_action_id_expected_r_fkey`: `FOREIGN KEY (organization_id, action_id, expected_revision_id) REFERENCES actions_design.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_command_target_organization_id_action_id_fkey`: `FOREIGN KEY (organization_id, action_id) REFERENCES actions_design.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_command_target_organization_id_action_id_previous_r_fkey`: `FOREIGN KEY (organization_id, action_id, previous_revision_id) REFERENCES actions_design.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_command_target_organization_id_action_id_result_rev_fkey`: `FOREIGN KEY (organization_id, action_id, result_revision_id) REFERENCES actions_design.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_command_target_organization_id_command_id_action_id_key`: `UNIQUE (organization_id, command_id, action_id)`
* `action_command_target_organization_id_command_id_fkey`: `FOREIGN KEY (organization_id, command_id) REFERENCES actions_design.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_command_target_organization_id_expected_parent_revi_fkey`: `FOREIGN KEY (organization_id, expected_parent_revision_id) REFERENCES actions_design.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_command_target_pkey`: `PRIMARY KEY (command_id, action_id)`
* `action_command_target_result_version_check`: `CHECK (result_version > 0)`
* `command_target_snapshot`: `TRIGGER DEFERRABLE INITIALLY DEFERRED`
* `target_positive_versions`: `CHECK ((expected_version IS NULL OR expected_version > 0) AND (previous_version IS NULL OR previous_version > 0))`
* `target_previous_approval_fk`: `FOREIGN KEY (organization_id, action_id, previous_approval_id) REFERENCES actions_design.action_approval(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED`
* `target_result_approval_fk`: `FOREIGN KEY (organization_id, action_id, result_approval_id) REFERENCES actions_design.action_approval(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED`

### `action_approval`

Permission for one exact revision and scope; server-owned Undo deadline and policy or human provenance.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| id | `text` | no |  |
| organization_id | `text` | no |  |
| action_id | `text` | no |  |
| revision_id | `text` | no |  |
| command_id | `text` | no |  |
| scope | `actions_design.action_authorization_scope` | no |  |
| policy_revision_id | `text` | yes |  |
| parent_revision_id | `text` | yes |  |
| undo_deadline | `timestamp with time zone` | no |  |
| required_surface | `actions_design.action_surface` | no |  |
| authorization_version | `integer` | no |  |
| created_at | `timestamp with time zone` | no |  |

Constraints:

* `action_approval_authorization_version_check`: `CHECK (authorization_version > 0)`
* `action_approval_check`: `CHECK (undo_deadline >= created_at)`
* `action_approval_command_id_action_id_key`: `UNIQUE (command_id, action_id)`
* `action_approval_organization_id_action_id_id_key`: `UNIQUE (organization_id, action_id, id)`
* `action_approval_organization_id_action_id_revision_id_fkey`: `FOREIGN KEY (organization_id, action_id, revision_id) REFERENCES actions_design.action_revision(organization_id, action_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_approval_organization_id_command_id_action_id_fkey`: `FOREIGN KEY (organization_id, command_id, action_id) REFERENCES actions_design.action_command_target(organization_id, command_id, action_id) DEFERRABLE INITIALLY DEFERRED`
* `action_approval_organization_id_id_key`: `UNIQUE (organization_id, id)`
* `action_approval_organization_id_parent_revision_id_fkey`: `FOREIGN KEY (organization_id, parent_revision_id) REFERENCES actions_design.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_approval_organization_id_policy_revision_id_fkey`: `FOREIGN KEY (organization_id, policy_revision_id) REFERENCES actions_design.action_policy_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_approval_pkey`: `PRIMARY KEY (id)`
* `approval_command_snapshot`: `TRIGGER DEFERRABLE INITIALLY DEFERRED`
* `approval_exact_membership_fk`: `FOREIGN KEY (organization_id, parent_revision_id, action_id, revision_id) REFERENCES actions_design.action_membership(organization_id, parent_revision_id, child_action_id, child_revision_id) DEFERRABLE INITIALLY DEFERRED`

### `action_policy_revision`

Versioned auto-reply/generation grant with attributable one-way revocation.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
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

Constraints:

* `action_policy_revision_asset_id_fkey`: `FOREIGN KEY (asset_id) REFERENCES asset(id)`
* `action_policy_revision_check`: `CHECK (minimum_rating IS NULL OR maximum_rating >= minimum_rating)`
* `action_policy_revision_check1`: `CHECK (policy_kind <> 'agent_generation'::text OR NOT allow_initial_reply AND NOT allow_replace_reply)`
* `action_policy_revision_check2`: `CHECK ((revoked_by_command_id IS NULL) = (revoked_at IS NULL))`
* `action_policy_revision_maximum_rating_check`: `CHECK (maximum_rating >= 1 AND maximum_rating <= 5)`
* `action_policy_revision_minimum_rating_check`: `CHECK (minimum_rating >= 1 AND minimum_rating <= 5)`
* `action_policy_revision_organization_id_asset_id_policy_kind_key`: `UNIQUE (organization_id, asset_id, policy_kind, revision_number)`
* `action_policy_revision_organization_id_granted_by_command__fkey`: `FOREIGN KEY (organization_id, granted_by_command_id) REFERENCES actions_design.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_policy_revision_organization_id_id_key`: `UNIQUE (organization_id, id)`
* `action_policy_revision_organization_id_revoked_by_command__fkey`: `FOREIGN KEY (organization_id, revoked_by_command_id) REFERENCES actions_design.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_policy_revision_pkey`: `PRIMARY KEY (id)`
* `action_policy_revision_policy_kind_check`: `CHECK (policy_kind = ANY (ARRAY['review_auto_reply'::text, 'agent_generation'::text]))`
* `action_policy_revision_revision_number_check`: `CHECK (revision_number > 0)`
* `action_policy_revision_rule_version_check`: `CHECK (rule_version > 0)`
* `policy_permission_shape`: `CHECK (policy_kind = 'agent_generation'::text AND allow_generation AND NOT allow_initial_reply AND NOT allow_replace_reply AND minimum_rating IS NULL OR policy_kind = 'review_auto_reply'::text AND (allow_initial_reply OR allow_replace_reply))`
* `policy_rating_bounds`: `CHECK ((minimum_rating IS NULL) = (maximum_rating IS NULL))`

## Delivery and evidence

### `action_execution`

Durable obligation created atomically with approval. Due time and recovery authority survive queue loss.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| id | `text` | no |  |
| organization_id | `text` | no |  |
| approval_id | `text` | no |  |
| phase | `actions_design.action_execution_phase` | no |  |
| next_run_at | `timestamp with time zone` | yes |  |
| next_step_id | `text` | yes |  |
| schedule_generation | `bigint` | no | 1 |
| claim_generation | `bigint` | no | 0 |
| claim_token | `uuid` | yes |  |
| claim_expires_at | `timestamp with time zone` | yes |  |
| hold_reason | `actions_design.action_hold_reason` | yes |  |
| result | `actions_design.action_execution_result` | yes |  |
| created_at | `timestamp with time zone` | no |  |
| settled_at | `timestamp with time zone` | yes |  |
| resource_guard_id | `uuid` | yes |  |
| plan_version | `integer` | no |  |
| writes_closed_at | `timestamp with time zone` | yes |  |
| cancelled_command_id | `text` | yes |  |

Constraints:

* `action_execution_approval_id_key`: `UNIQUE (approval_id)`
* `action_execution_cancel_command_fk`: `FOREIGN KEY (organization_id, cancelled_command_id) REFERENCES actions_design.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_execution_cancel_command_shape`: `CHECK ((phase = 'cancelled'::actions_design.action_execution_phase) = (cancelled_command_id IS NOT NULL))`
* `action_execution_cancelled_result`: `CHECK ((phase = 'cancelled'::actions_design.action_execution_phase) = (result = 'cancelled'::actions_design.action_execution_result))`
* `action_execution_check`: `CHECK ((claim_token IS NULL) = (claim_expires_at IS NULL))`
* `action_execution_check1`: `CHECK ((phase = 'claimed'::actions_design.action_execution_phase) = (claim_token IS NOT NULL))`
* `action_execution_check2`: `CHECK ((phase = ANY (ARRAY['settled'::actions_design.action_execution_phase, 'cancelled'::actions_design.action_execution_phase])) = (settled_at IS NOT NULL))`
* `action_execution_check3`: `CHECK ((phase = ANY (ARRAY['settled'::actions_design.action_execution_phase, 'cancelled'::actions_design.action_execution_phase])) = (result IS NOT NULL))`
* `action_execution_check4`: `CHECK ((phase <> ALL (ARRAY['ready'::actions_design.action_execution_phase, 'verification_due'::actions_design.action_execution_phase])) OR next_run_at IS NOT NULL)`
* `action_execution_check5`: `CHECK ((phase <> ALL (ARRAY['settled'::actions_design.action_execution_phase, 'cancelled'::actions_design.action_execution_phase])) OR next_run_at IS NULL)`
* `action_execution_check6`: `CHECK (phase <> 'uncertain'::actions_design.action_execution_phase OR hold_reason = 'uncertain_write'::actions_design.action_hold_reason)`
* `action_execution_claim_generation`: `CHECK (phase <> 'claimed'::actions_design.action_execution_phase OR claim_generation > 0)`
* `action_execution_claim_generation_check`: `CHECK (claim_generation >= 0)`
* `action_execution_organization_id_approval_id_fkey`: `FOREIGN KEY (organization_id, approval_id) REFERENCES actions_design.action_approval(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_execution_organization_id_id_key`: `UNIQUE (organization_id, id)`
* `action_execution_organization_id_id_next_step_id_fkey`: `FOREIGN KEY (organization_id, id, next_step_id) REFERENCES actions_design.action_execution_step(organization_id, execution_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_execution_pkey`: `PRIMARY KEY (id)`
* `action_execution_plan_version_check`: `CHECK (plan_version > 0)`
* `action_execution_resource_guard_id_fkey`: `FOREIGN KEY (resource_guard_id) REFERENCES actions_design.action_resource_guard(id)`
* `action_execution_schedule_generation_check`: `CHECK (schedule_generation > 0)`
* `action_execution_settlement_time`: `CHECK (settled_at IS NULL OR settled_at >= created_at)`
* `action_execution_uncertain_due`: `CHECK (phase <> 'uncertain'::actions_design.action_execution_phase OR next_run_at IS NOT NULL)`
* `action_execution_writes_closed_time`: `CHECK (writes_closed_at IS NULL OR writes_closed_at >= created_at)`

### `action_execution_step`

One concrete effect in the frozen execution plan, including endpoint identity and upload chunk coordinates.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| id | `text` | no |  |
| organization_id | `text` | no |  |
| execution_id | `text` | no |  |
| ordinal | `integer` | no |  |
| kind | `actions_design.action_step_kind` | no |  |
| adapter_version | `integer` | no |  |
| input_step_id | `text` | yes |  |
| content_revision_id | `text` | no |  |
| media_slot | `integer` | yes |  |
| upload_offset | `bigint` | yes |  |
| upload_length | `bigint` | yes |  |
| recovery_mode | `actions_design.action_recovery_mode` | no |  |
| recovery_policy_version | `integer` | no |  |
| native_idempotency_key | `text` | yes |  |
| required_surface | `actions_design.action_surface` | no |  |

Constraints:

* `action_execution_step_adapter_version_check`: `CHECK (adapter_version > 0)`
* `action_execution_step_check`: `CHECK (id IS DISTINCT FROM input_step_id)`
* `action_execution_step_check1`: `CHECK ((recovery_mode = 'native_idempotency'::actions_design.action_recovery_mode) = (native_idempotency_key IS NOT NULL))`
* `action_execution_step_check2`: `CHECK ((upload_offset IS NULL) = (upload_length IS NULL))`
* `action_execution_step_chunk_shape`: `CHECK ((kind = 'asc_app_clip_header_upload_chunk'::actions_design.action_step_kind) = (upload_offset IS NOT NULL))`
* `action_execution_step_execution_id_ordinal_key`: `UNIQUE (execution_id, ordinal)`
* `action_execution_step_media_reference`: `FOREIGN KEY (organization_id, content_revision_id, media_slot) REFERENCES actions_design.action_media_content(organization_id, revision_id, slot) DEFERRABLE INITIALLY DEFERRED`
* `action_execution_step_media_shape`: `CHECK ((kind = ANY (ARRAY['asc_app_clip_header_reserve'::actions_design.action_step_kind, 'asc_app_clip_header_upload_chunk'::actions_design.action_step_kind, 'asc_app_clip_header_commit'::actions_design.action_step_kind])) = (media_slot IS NOT NULL))`
* `action_execution_step_media_slot_check`: `CHECK (media_slot >= 0)`
* `action_execution_step_ordinal_check`: `CHECK (ordinal >= 0)`
* `action_execution_step_organization_id_content_revision_id_fkey`: `FOREIGN KEY (organization_id, content_revision_id) REFERENCES actions_design.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_execution_step_organization_id_execution_id_fkey`: `FOREIGN KEY (organization_id, execution_id) REFERENCES actions_design.action_execution(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_execution_step_organization_id_execution_id_id_key`: `UNIQUE (organization_id, execution_id, id)`
* `action_execution_step_organization_id_execution_id_input_s_fkey`: `FOREIGN KEY (organization_id, execution_id, input_step_id) REFERENCES actions_design.action_execution_step(organization_id, execution_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_execution_step_organization_id_id_key`: `UNIQUE (organization_id, id)`
* `action_execution_step_pkey`: `PRIMARY KEY (id)`
* `action_execution_step_recovery_policy_version_check`: `CHECK (recovery_policy_version > 0)`
* `action_execution_step_upload_length_check`: `CHECK (upload_length > 0)`
* `action_execution_step_upload_offset_check`: `CHECK (upload_offset >= 0)`

### `action_execution_attempt`

One actual call, readback or generation with claim fence and immutable evidence. Success cannot conceal another write.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| id | `text` | no |  |
| organization_id | `text` | no |  |
| step_id | `text` | yes |  |
| number | `integer` | yes |  |
| kind | `actions_design.action_attempt_kind` | no |  |
| claim_generation | `bigint` | yes |  |
| subject_attempt_id | `text` | yes |  |
| agent_run_id | `text` | yes |  |
| connector_id | `text` | yes |  |
| transport | `actions_design.action_transport` | yes |  |
| started_at | `timestamp with time zone` | yes |  |
| finished_at | `timestamp with time zone` | yes |  |
| result | `actions_design.action_attempt_result` | yes |  |
| observation_revision_id | `text` | yes |  |
| comparison_version | `integer` | yes |  |
| provider_request_id | `text` | yes |  |
| provider_resource_id | `text` | yes |  |
| provider_version | `text` | yes |  |
| provider_edit_id | `text` | yes |  |
| provider_localization_id | `text` | yes |  |
| provider_media_id | `text` | yes |  |
| provider_error_code | `text` | yes |  |
| failure_class | `actions_design.action_failure_class` | yes |  |
| recorded_at | `timestamp with time zone` | no |  |
| execution_id | `text` | no |  |
| claim_token | `uuid` | no |  |
| input_attempt_id | `text` | yes |  |
| output_kind | `actions_design.action_output_kind` | yes |  |
| output_revision_id | `text` | yes |  |
| output_review_analysis_id | `text` | yes |  |
| output_agent_run_id | `text` | yes |  |
| no_work_reason | `actions_design.action_no_work_reason` | yes |  |
| finalized_claim_generation | `bigint` | yes |  |
| finalized_claim_token | `uuid` | yes |  |
| evidence_command_id | `text` | yes |  |
| observation_surface | `actions_design.action_surface` | yes |  |
| observation_completeness | `actions_design.action_observation_completeness` | yes |  |
| observed_at | `timestamp with time zone` | yes |  |
| non_application_basis | `actions_design.action_non_application_basis` | yes |  |
| provider_edit_expires_at | `timestamp with time zone` | yes |  |

Constraints:

* `action_attempt_active_identity`: `CHECK (step_id IS NOT NULL AND number IS NOT NULL AND claim_generation IS NOT NULL AND started_at IS NOT NULL AND transport IS NOT NULL)`
* `action_attempt_active_kind`: `CHECK (kind = ANY (ARRAY['write'::actions_design.action_attempt_kind, 'readback'::actions_design.action_attempt_kind, 'generation'::actions_design.action_attempt_kind, 'late_evidence'::actions_design.action_attempt_kind]))`
* `action_attempt_evidence_command`: `FOREIGN KEY (organization_id, evidence_command_id) REFERENCES actions_design.action_command(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_attempt_evidence_shape`: `CHECK ((kind = 'late_evidence'::actions_design.action_attempt_kind) = (evidence_command_id IS NOT NULL) AND (kind <> 'late_evidence'::actions_design.action_attempt_kind OR finished_at IS NOT NULL AND finalized_claim_generation IS NULL AND finalized_claim_token IS NULL))`
* `action_attempt_execution_identity`: `UNIQUE (organization_id, execution_id, id)`
* `action_attempt_finalization_fence`: `CHECK (kind = 'late_evidence'::actions_design.action_attempt_kind OR (finished_at IS NOT NULL) = (finalized_claim_generation IS NOT NULL) AND (finalized_claim_generation IS NULL) = (finalized_claim_token IS NULL))`
* `action_attempt_input_same_execution`: `FOREIGN KEY (organization_id, execution_id, input_attempt_id) REFERENCES actions_design.action_execution_attempt(organization_id, execution_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_attempt_no_self_input`: `CHECK (id IS DISTINCT FROM input_attempt_id)`
* `action_attempt_non_application_shape`: `CHECK ((NOT result IS DISTINCT FROM 'known_not_applied'::actions_design.action_attempt_result) = (non_application_basis IS NOT NULL))`
* `action_attempt_output_revision`: `FOREIGN KEY (organization_id, output_revision_id) REFERENCES actions_design.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_attempt_output_shape`: `CHECK ((result IS DISTINCT FROM 'generated'::actions_design.action_attempt_result OR output_kind IS NOT NULL) AND (output_kind IS NULL OR result IS NOT NULL AND (result = ANY (ARRAY['generated'::actions_design.action_attempt_result, 'discarded'::actions_design.action_attempt_result]))) AND (output_kind IS NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 0 OR output_kind = 'revision'::actions_design.action_output_kind AND output_revision_id IS NOT NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 1 OR output_kind = 'review_analysis'::actions_design.action_output_kind AND output_review_analysis_id IS NOT NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 1 OR output_kind = 'agent_run'::actions_design.action_output_kind AND output_agent_run_id IS NOT NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 1 OR output_kind = 'no_work'::actions_design.action_output_kind AND no_work_reason IS NOT NULL AND agent_run_id IS NOT NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 1))`
* `action_attempt_result_by_kind`: `CHECK (result IS NULL OR kind = 'write'::actions_design.action_attempt_kind AND (result = ANY (ARRAY['acknowledged'::actions_design.action_attempt_result, 'known_not_applied'::actions_design.action_attempt_result, 'uncertain'::actions_design.action_attempt_result])) OR kind = 'readback'::actions_design.action_attempt_kind AND (result = ANY (ARRAY['matched'::actions_design.action_attempt_result, 'mismatch'::actions_design.action_attempt_result, 'unreadable'::actions_design.action_attempt_result, 'known_not_applied'::actions_design.action_attempt_result])) OR kind = 'generation'::actions_design.action_attempt_kind AND (result = ANY (ARRAY['generated'::actions_design.action_attempt_result, 'discarded'::actions_design.action_attempt_result, 'known_not_applied'::actions_design.action_attempt_result, 'uncertain'::actions_design.action_attempt_result])) OR kind = 'late_evidence'::actions_design.action_attempt_kind)`
* `action_attempt_step_execution`: `FOREIGN KEY (organization_id, execution_id, step_id) REFERENCES actions_design.action_execution_step(organization_id, execution_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_attempt_step_identity`: `UNIQUE (organization_id, step_id, id)`
* `action_attempt_subject_same_step`: `FOREIGN KEY (organization_id, step_id, subject_attempt_id) REFERENCES actions_design.action_execution_attempt(organization_id, step_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_attempt_verified_observation`: `CHECK ((result <> ALL (ARRAY['matched'::actions_design.action_attempt_result, 'mismatch'::actions_design.action_attempt_result])) AND NOT (kind = 'readback'::actions_design.action_attempt_kind AND result = 'known_not_applied'::actions_design.action_attempt_result) OR observation_revision_id IS NOT NULL AND observation_surface IS NOT NULL AND NOT observation_completeness IS DISTINCT FROM 'complete'::actions_design.action_observation_completeness AND observed_at IS NOT NULL AND comparison_version IS NOT NULL)`
* `action_execution_attempt_agent_run_id_fkey`: `FOREIGN KEY (agent_run_id) REFERENCES agent_run(id)`
* `action_execution_attempt_check`: `CHECK (id IS DISTINCT FROM subject_attempt_id)`
* `action_execution_attempt_check1`: `CHECK (step_id IS NOT NULL AND number IS NOT NULL AND claim_generation IS NOT NULL AND started_at IS NOT NULL AND transport IS NOT NULL)`
* `action_execution_attempt_check2`: `CHECK ((finished_at IS NULL) = (result IS NULL))`
* `action_execution_attempt_check3`: `CHECK (finished_at IS NULL OR started_at IS NULL OR finished_at >= started_at)`
* `action_execution_attempt_check4`: `CHECK ((kind <> ALL (ARRAY['readback'::actions_design.action_attempt_kind, 'late_evidence'::actions_design.action_attempt_kind])) OR subject_attempt_id IS NOT NULL)`
* `action_execution_attempt_check5`: `CHECK ((result <> ALL (ARRAY['matched'::actions_design.action_attempt_result, 'mismatch'::actions_design.action_attempt_result])) OR observation_revision_id IS NOT NULL AND comparison_version IS NOT NULL)`
* `action_execution_attempt_claim_generation_check`: `CHECK (claim_generation > 0)`
* `action_execution_attempt_comparison_version_check`: `CHECK (comparison_version > 0)`
* `action_execution_attempt_connector_id_fkey`: `FOREIGN KEY (connector_id) REFERENCES data_connector(id)`
* `action_execution_attempt_finalized_claim_generation_check`: `CHECK (finalized_claim_generation > 0)`
* `action_execution_attempt_number_check`: `CHECK (number > 0)`
* `action_execution_attempt_organization_id_id_key`: `UNIQUE (organization_id, id)`
* `action_execution_attempt_organization_id_observation_revis_fkey`: `FOREIGN KEY (organization_id, observation_revision_id) REFERENCES actions_design.action_revision(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_execution_attempt_organization_id_step_id_fkey`: `FOREIGN KEY (organization_id, step_id) REFERENCES actions_design.action_execution_step(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_execution_attempt_organization_id_subject_attempt_i_fkey`: `FOREIGN KEY (organization_id, subject_attempt_id) REFERENCES actions_design.action_execution_attempt(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_execution_attempt_output_agent_run_id_fkey`: `FOREIGN KEY (output_agent_run_id) REFERENCES agent_run(id)`
* `action_execution_attempt_output_review_analysis_id_fkey`: `FOREIGN KEY (output_review_analysis_id) REFERENCES review_analysis(id)`
* `action_execution_attempt_pkey`: `PRIMARY KEY (id)`
* `action_execution_attempt_step_id_number_key`: `UNIQUE (step_id, number)`

### `action_resource_guard`

Provider-resource exclusion while writes may be active or uncertain. Released once mutations conclusively close.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| provider | `text` | no |  |
| provider_account_id | `text` | no |  |
| remote_application_id | `text` | yes |  |
| holder_organization_id | `text` | yes |  |
| holder_execution_id | `text` | yes |  |
| acquired_at | `timestamp with time zone` | yes |  |
| id | `uuid` | no | gen_random_uuid() |
| scope | `actions_design.action_resource_scope` | no |  |

Constraints:

* `action_resource_guard_check`: `CHECK ((holder_execution_id IS NULL) = (holder_organization_id IS NULL))`
* `action_resource_guard_check1`: `CHECK ((holder_execution_id IS NULL) = (acquired_at IS NULL))`
* `action_resource_guard_holder_organization_id_holder_execut_fkey`: `FOREIGN KEY (holder_organization_id, holder_execution_id) REFERENCES actions_design.action_execution(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_resource_guard_identity`: `PRIMARY KEY (id)`
* `action_resource_guard_nonempty_account`: `CHECK (length(provider_account_id) > 0)`
* `action_resource_guard_provider_check`: `CHECK (provider = ANY (ARRAY['app_store_connect'::text, 'google_play'::text, 'apple_search_ads'::text]))`
* `action_resource_guard_scope_shape`: `CHECK (provider = 'apple_search_ads'::text AND scope = 'advertising_account'::actions_design.action_resource_scope AND remote_application_id IS NULL OR (provider = ANY (ARRAY['app_store_connect'::text, 'google_play'::text])) AND scope = 'store_application'::actions_design.action_resource_scope AND remote_application_id IS NOT NULL AND length(remote_application_id) > 0)`
* `action_resource_guard_target`: `UNIQUE NULLS NOT DISTINCT (provider, provider_account_id, remote_application_id)`

## Typed content

### `action_review_content`

Exact review reply, provider target and prior-response baseline.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| provider_account_id | `text` | no |  |
| store | `actions_design.store_kind` | no |  |
| provider_app_id | `text` | no |  |
| provider_review_id | `text` | no |  |
| apple_review_resource_id | `text` | yes |  |
| intent | `actions_design.reply_intent` | no |  |
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
| response_availability | `actions_design.observation_availability` | no |  |
| provider_response_id | `text` | yes |  |
| provider_response_text | `text` | yes |  |
| provider_response_modified_at | `timestamp with time zone` | yes |  |
| provider_response_hidden | `boolean` | yes |  |
| observation_captured_at | `timestamp with time zone` | yes |  |
| provider_response_state | `actions_design.review_publication_state` | yes |  |

Constraints:

* `action_review_content_check`: `CHECK ((intent <> ALL (ARRAY['send'::actions_design.reply_intent, 'update'::actions_design.reply_intent])) OR reply_text IS NOT NULL AND length(reply_text) > 0)`
* `action_review_content_check2`: `CHECK (response_availability <> 'present'::actions_design.observation_availability OR provider_response_text IS NOT NULL)`
* `action_review_content_check3`: `CHECK (response_availability <> 'absent'::actions_design.observation_availability OR provider_response_id IS NULL AND provider_response_text IS NULL)`
* `action_review_content_organization_id_original_ai_revision_fkey`: `FOREIGN KEY (organization_id, original_ai_revision_id) REFERENCES actions_design.action_revision(organization_id, id)`
* `action_review_content_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions_design.action_revision(organization_id, id)`
* `action_review_content_pkey`: `PRIMARY KEY (organization_id, revision_id)`
* `action_review_content_review_rating_check`: `CHECK (review_rating >= 1 AND review_rating <= 5)`

### `action_listing_content`

Explicit store fields, target versions, preserved values, App Clip content and Play commit policy.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| provider_account_id | `text` | no |  |
| store | `actions_design.store_kind` | no |  |
| locale | `text` | no |  |
| intent | `actions_design.listing_intent` | no |  |
| provider_app_id | `text` | yes |  |
| package_name | `text` | yes |  |
| app_info_id | `text` | yes |  |
| app_info_localization_id | `text` | yes |  |
| app_version_id | `text` | yes |  |
| app_version_localization_id | `text` | yes |  |
| google_edit_id | `text` | yes |  |
| title_state | `actions_design.content_value_state` | no | 'unspecified'::actions_design.content_value_state |
| title | `text` | yes |  |
| subtitle_state | `actions_design.content_value_state` | no | 'unspecified'::actions_design.content_value_state |
| subtitle | `text` | yes |  |
| description_state | `actions_design.content_value_state` | no | 'unspecified'::actions_design.content_value_state |
| description | `text` | yes |  |
| keywords_state | `actions_design.content_value_state` | no | 'unspecified'::actions_design.content_value_state |
| keywords | `text` | yes |  |
| promotional_text_state | `actions_design.content_value_state` | no | 'unspecified'::actions_design.content_value_state |
| promotional_text | `text` | yes |  |
| short_description_state | `actions_design.content_value_state` | no | 'unspecified'::actions_design.content_value_state |
| short_description | `text` | yes |  |
| whats_new_state | `actions_design.content_value_state` | no | 'unspecified'::actions_design.content_value_state |
| whats_new | `text` | yes |  |
| support_url_state | `actions_design.content_value_state` | no | 'unspecified'::actions_design.content_value_state |
| support_url | `text` | yes |  |
| keyword_analysis | `text` | yes |  |
| operator_instructions | `text` | yes |  |
| source_fingerprint | `text` | yes |  |
| naturalness_check_skipped | `boolean` | yes |  |
| fidelity_check_skipped | `boolean` | yes |  |
| english_title | `text` | yes |  |
| english_subtitle | `text` | yes |  |
| english_promotional_text | `text` | yes |  |
| gloss_status | `actions_design.gloss_status` | yes |  |
| research_country | `text` | yes |  |
| research_coverage | `actions_design.research_coverage` | yes |  |
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
| observation_availability | `actions_design.observation_availability` | yes |  |
| observation_captured_at | `timestamp with time zone` | yes |  |
| source_capture_at | `timestamp with time zone` | yes |  |
| play_commit_policy | `actions_design.play_commit_policy` | yes |  |
| app_clip_operation | `actions_design.app_clip_operation` | no | 'none'::actions_design.app_clip_operation |
| app_clip_id | `text` | yes |  |
| app_clip_experience_id | `text` | yes |  |
| app_clip_release_version_id | `text` | yes |  |
| app_clip_localization_id | `text` | yes |  |
| app_clip_source_localization_id | `text` | yes |  |
| app_clip_subtitle | `text` | yes |  |
| app_clip_header_media_slot | `integer` | yes |  |
| provider_version_state | `actions_design.listing_version_state` | yes |  |
| live_promotional_version_id | `text` | yes |  |
| live_promotional_localization_id | `text` | yes |  |
| live_promotional_text_state | `actions_design.content_value_state` | no | 'unspecified'::actions_design.content_value_state |
| live_promotional_text | `text` | yes |  |
| app_clip_incomplete_header_id | `text` | yes |  |
| app_clip_header_state | `actions_design.app_clip_header_state` | yes |  |

Constraints:

* `action_listing_content_app_tier_check`: `CHECK (app_tier >= 1 AND app_tier <= 3)`
* `action_listing_content_candidate_count_check`: `CHECK (candidate_count >= 0)`
* `action_listing_content_check`: `CHECK (title_state = 'present'::actions_design.content_value_state AND title IS NOT NULL AND length(title) > 0 OR title_state = 'dismissed'::actions_design.content_value_state AND title IS NOT NULL OR title_state = 'empty'::actions_design.content_value_state AND title IS NOT NULL AND title = ''::text OR (title_state = ANY (ARRAY['unspecified'::actions_design.content_value_state, 'unreadable'::actions_design.content_value_state])) AND title IS NULL)`
* `action_listing_content_check1`: `CHECK (subtitle_state = 'present'::actions_design.content_value_state AND subtitle IS NOT NULL AND length(subtitle) > 0 OR subtitle_state = 'dismissed'::actions_design.content_value_state AND subtitle IS NOT NULL OR subtitle_state = 'empty'::actions_design.content_value_state AND subtitle IS NOT NULL AND subtitle = ''::text OR (subtitle_state = ANY (ARRAY['unspecified'::actions_design.content_value_state, 'unreadable'::actions_design.content_value_state])) AND subtitle IS NULL)`
* `action_listing_content_check2`: `CHECK (description_state = 'present'::actions_design.content_value_state AND description IS NOT NULL AND length(description) > 0 OR description_state = 'dismissed'::actions_design.content_value_state AND description IS NOT NULL OR description_state = 'empty'::actions_design.content_value_state AND description IS NOT NULL AND description = ''::text OR (description_state = ANY (ARRAY['unspecified'::actions_design.content_value_state, 'unreadable'::actions_design.content_value_state])) AND description IS NULL)`
* `action_listing_content_check3`: `CHECK (keywords_state = 'present'::actions_design.content_value_state AND keywords IS NOT NULL AND length(keywords) > 0 OR keywords_state = 'dismissed'::actions_design.content_value_state AND keywords IS NOT NULL OR keywords_state = 'empty'::actions_design.content_value_state AND keywords IS NOT NULL AND keywords = ''::text OR (keywords_state = ANY (ARRAY['unspecified'::actions_design.content_value_state, 'unreadable'::actions_design.content_value_state])) AND keywords IS NULL)`
* `action_listing_content_check4`: `CHECK (promotional_text_state = 'present'::actions_design.content_value_state AND promotional_text IS NOT NULL AND length(promotional_text) > 0 OR promotional_text_state = 'dismissed'::actions_design.content_value_state AND promotional_text IS NOT NULL OR promotional_text_state = 'empty'::actions_design.content_value_state AND promotional_text IS NOT NULL AND promotional_text = ''::text OR (promotional_text_state = ANY (ARRAY['unspecified'::actions_design.content_value_state, 'unreadable'::actions_design.content_value_state])) AND promotional_text IS NULL)`
* `action_listing_content_check5`: `CHECK (short_description_state = 'present'::actions_design.content_value_state AND short_description IS NOT NULL AND length(short_description) > 0 OR short_description_state = 'dismissed'::actions_design.content_value_state AND short_description IS NOT NULL OR short_description_state = 'empty'::actions_design.content_value_state AND short_description IS NOT NULL AND short_description = ''::text OR (short_description_state = ANY (ARRAY['unspecified'::actions_design.content_value_state, 'unreadable'::actions_design.content_value_state])) AND short_description IS NULL)`
* `action_listing_content_check6`: `CHECK (whats_new_state = 'present'::actions_design.content_value_state AND whats_new IS NOT NULL AND length(whats_new) > 0 OR whats_new_state = 'dismissed'::actions_design.content_value_state AND whats_new IS NOT NULL OR whats_new_state = 'empty'::actions_design.content_value_state AND whats_new IS NOT NULL AND whats_new = ''::text OR (whats_new_state = ANY (ARRAY['unspecified'::actions_design.content_value_state, 'unreadable'::actions_design.content_value_state])) AND whats_new IS NULL)`
* `action_listing_content_check7`: `CHECK (support_url_state = 'present'::actions_design.content_value_state AND support_url IS NOT NULL AND length(support_url) > 0 OR support_url_state = 'dismissed'::actions_design.content_value_state AND support_url IS NOT NULL OR support_url_state = 'empty'::actions_design.content_value_state AND support_url IS NOT NULL AND support_url = ''::text OR (support_url_state = ANY (ARRAY['unspecified'::actions_design.content_value_state, 'unreadable'::actions_design.content_value_state])) AND support_url IS NULL)`
* `action_listing_content_check8`: `CHECK (conformance_from_table_count IS NULL OR conformance_term_count IS NULL OR conformance_from_table_count <= conformance_term_count)`
* `action_listing_content_conformance_from_table_count_check`: `CHECK (conformance_from_table_count >= 0)`
* `action_listing_content_conformance_term_count_check`: `CHECK (conformance_term_count >= 0)`
* `action_listing_content_judged_count_check`: `CHECK (judged_count >= 0)`
* `action_listing_content_locale_check`: `CHECK (length(locale) > 0)`
* `action_listing_content_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions_design.action_revision(organization_id, id)`
* `action_listing_content_p0_count_check`: `CHECK (p0_count >= 0)`
* `action_listing_content_p1_count_check`: `CHECK (p1_count >= 0)`
* `action_listing_content_p2_count_check`: `CHECK (p2_count >= 0)`
* `action_listing_content_pkey`: `PRIMARY KEY (organization_id, revision_id)`
* `action_listing_content_scored_count_check`: `CHECK (scored_count >= 0)`
* `action_listing_content_with_volume_count_check`: `CHECK (with_volume_count >= 0)`
* `listing_clip_media_fk`: `FOREIGN KEY (organization_id, revision_id, app_clip_header_media_slot) REFERENCES actions_design.action_media_content(organization_id, revision_id, slot) DEFERRABLE INITIALLY DEFERRED`
* `listing_clip_observed_header`: `CHECK (app_clip_operation = 'none'::actions_design.app_clip_operation AND app_clip_incomplete_header_id IS NULL AND app_clip_header_state IS NULL OR (app_clip_operation = ANY (ARRAY['create_localization'::actions_design.app_clip_operation, 'repair_header'::actions_design.app_clip_operation, 'observed'::actions_design.app_clip_operation])) AND (app_clip_incomplete_header_id IS NULL OR length(app_clip_incomplete_header_id) > 0) AND (app_clip_header_state IS NULL OR app_clip_operation = 'observed'::actions_design.app_clip_operation) AND (app_clip_header_state IS DISTINCT FROM 'incomplete'::actions_design.app_clip_header_state OR app_clip_incomplete_header_id IS NOT NULL))`
* `listing_clip_repair_target`: `CHECK (app_clip_operation <> 'repair_header'::actions_design.app_clip_operation OR app_clip_localization_id IS NOT NULL)`
* `listing_clip_subtitle`: `CHECK (app_clip_operation <> 'create_localization'::actions_design.app_clip_operation OR app_clip_subtitle IS NOT NULL AND length(app_clip_subtitle) > 0)`
* `listing_clip_target`: `CHECK (app_clip_operation = 'none'::actions_design.app_clip_operation AND app_clip_id IS NULL AND app_clip_experience_id IS NULL AND app_clip_release_version_id IS NULL AND app_clip_localization_id IS NULL AND app_clip_source_localization_id IS NULL AND app_clip_subtitle IS NULL AND app_clip_header_media_slot IS NULL OR app_clip_operation <> 'none'::actions_design.app_clip_operation AND store = 'ios'::actions_design.store_kind AND app_clip_id IS NOT NULL AND app_clip_experience_id IS NOT NULL AND app_clip_release_version_id IS NOT NULL AND (app_clip_operation = 'observed'::actions_design.app_clip_operation OR app_clip_header_media_slot IS NOT NULL))`
* `listing_clip_utf16_limit`: `CHECK (app_clip_subtitle IS NULL OR actions_design.utf16_length(app_clip_subtitle) <= 56)`
* `listing_live_promo_observed_value`: `CHECK (live_promotional_text_state = 'present'::actions_design.content_value_state AND live_promotional_text IS NOT NULL AND length(live_promotional_text) > 0 OR live_promotional_text_state = 'empty'::actions_design.content_value_state AND live_promotional_text IS NOT NULL AND live_promotional_text = ''::text OR (live_promotional_text_state = ANY (ARRAY['unspecified'::actions_design.content_value_state, 'unreadable'::actions_design.content_value_state])) AND live_promotional_text IS NULL)`
* `listing_live_promo_target`: `CHECK (live_promotional_version_id IS NULL AND live_promotional_localization_id IS NULL OR store = 'ios'::actions_design.store_kind AND live_promotional_version_id IS NOT NULL AND length(live_promotional_version_id) > 0 AND live_promotional_localization_id IS NOT NULL AND length(live_promotional_localization_id) > 0)`
* `listing_live_promo_value_target`: `CHECK (live_promotional_text_state = 'unspecified'::actions_design.content_value_state OR live_promotional_version_id IS NOT NULL)`
* `listing_play_policy_store`: `CHECK (store = 'android'::actions_design.store_kind OR play_commit_policy IS NULL)`
* `listing_supported_locale`: `CHECK (actions_design.is_supported_store_locale(store, locale))`

### `action_media_content`

Ordered immutable media references, byte lengths, checksums and store slots.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| slot | `integer` | no |  |
| kind | `actions_design.media_kind` | no |  |
| store | `actions_design.store_kind` | no |  |
| locale | `text` | no |  |
| source_locale | `text` | yes |  |
| display_type | `actions_design.media_display_type` | yes |  |
| source_provider_resource_id | `text` | yes |  |
| source_object_key | `text` | yes |  |
| source_object_version | `text` | yes |  |
| source_digest | `text` | yes |  |
| output_object_key | `text` | yes |  |
| output_object_version | `text` | yes |  |
| output_digest | `text` | yes |  |
| availability | `actions_design.media_availability` | no |  |
| mime_type | `text` | yes |  |
| width | `integer` | yes |  |
| height | `integer` | yes |  |
| byte_length | `bigint` | yes |  |
| generation_prompt | `text` | yes |  |
| generated_at | `timestamp with time zone` | yes |  |
| storyboard_intent | `text` | yes |  |
| caption | `text` | yes |  |
| first_slot_hook_guidance | `text` | yes |  |
| source_storage_immutability | `actions_design.media_storage_immutability` | yes |  |
| output_storage_immutability | `actions_design.media_storage_immutability` | yes |  |
| provider_md5 | `text` | yes |  |

Constraints:

* `action_media_content_byte_length_check`: `CHECK (byte_length >= 0)`
* `action_media_content_height_check`: `CHECK (height > 0)`
* `action_media_content_mime_type_check`: `CHECK (mime_type = ANY (ARRAY['image/png'::text, 'image/jpeg'::text, 'image/webp'::text, 'video/mp4'::text, 'video/quicktime'::text]))`
* `action_media_content_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions_design.action_revision(organization_id, id)`
* `action_media_content_pkey`: `PRIMARY KEY (organization_id, revision_id, slot)`
* `action_media_content_slot_check`: `CHECK (slot >= 0)`
* `action_media_content_width_check`: `CHECK (width > 0)`
* `media_clip_shape`: `CHECK (kind::text <> 'app_clip_header'::text OR store = 'ios'::actions_design.store_kind AND display_type IS NULL AND mime_type IS NOT NULL AND (mime_type = ANY (ARRAY['image/png'::text, 'image/jpeg'::text])))`
* `media_display_store`: `CHECK (display_type IS NULL OR store = 'android'::actions_design.store_kind AND (display_type = ANY (ARRAY['phoneScreenshots'::actions_design.media_display_type, 'sevenInchScreenshots'::actions_design.media_display_type])) OR store = 'ios'::actions_design.store_kind AND (display_type <> ALL (ARRAY['phoneScreenshots'::actions_design.media_display_type, 'sevenInchScreenshots'::actions_design.media_display_type])))`
* `media_md5_format`: `CHECK (provider_md5 IS NULL OR provider_md5 ~ '^[0-9a-f]{32}$'::text)`
* `media_output_digest_format`: `CHECK (output_digest IS NULL OR output_digest ~ '^sha256:[0-9a-f]{64}$'::text)`
* `media_screenshot_display`: `CHECK (kind::text <> 'screenshot'::text OR display_type IS NOT NULL)`
* `media_source_bytes_immutable`: `CHECK (source_object_key IS NULL AND source_object_version IS NULL AND source_digest IS NULL AND source_storage_immutability IS NULL OR source_object_key IS NOT NULL AND length(source_object_key) > 0 AND source_digest IS NOT NULL AND source_storage_immutability IS NOT NULL AND (source_storage_immutability = 'versioned_object'::actions_design.media_storage_immutability AND source_object_version IS NOT NULL AND length(source_object_version) > 0 OR source_storage_immutability = 'content_addressed_immutable'::actions_design.media_storage_immutability AND source_object_version IS NULL AND POSITION((SUBSTRING(source_digest FROM 8)) IN (source_object_key)) > 0))`
* `media_source_digest_format`: `CHECK (source_digest IS NULL OR source_digest ~ '^sha256:[0-9a-f]{64}$'::text)`
* `media_stored_bytes_immutable`: `CHECK (availability <> 'stored'::actions_design.media_availability OR output_object_key IS NOT NULL AND length(output_object_key) > 0 AND output_digest IS NOT NULL AND byte_length IS NOT NULL AND output_storage_immutability IS NOT NULL AND (output_storage_immutability = 'versioned_object'::actions_design.media_storage_immutability AND output_object_version IS NOT NULL AND length(output_object_version) > 0 OR output_storage_immutability = 'content_addressed_immutable'::actions_design.media_storage_immutability AND output_object_version IS NULL AND POSITION((SUBSTRING(output_digest FROM 8)) IN (output_object_key)) > 0))`
* `media_supported_locale`: `CHECK (actions_design.is_supported_store_locale(store, locale))`
* `media_supported_source_locale`: `CHECK (source_locale IS NULL OR actions_design.is_supported_store_locale(store, source_locale))`

### `action_request_content`

Finite generation/research/agent request inputs and typed outputs; Agents retains actual run ownership.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| intent | `actions_design.request_intent` | no |  |
| store | `actions_design.store_kind` | yes |  |
| locale | `text` | yes |  |
| wave_index | `integer` | yes |  |
| recommendation_type | `actions_design.recommendation_kind` | yes |  |
| plan_source_id | `text` | yes |  |
| experiment_source_id | `text` | yes |  |
| source_capture_at | `timestamp with time zone` | yes |  |
| window_days | `integer` | yes |  |
| review_mode | `text` | yes |  |
| operator_instructions | `text` | yes |  |
| focus | `text` | yes |  |
| context_text | `text` | yes |  |
| hypothesis | `text` | yes |  |
| hypothesize_policy | `actions_design.approval_setting` | yes |  |
| draft_policy | `actions_design.approval_setting` | yes |  |
| execute_policy | `actions_design.approval_setting` | yes |  |
| origin | `actions_design.request_origin` | no |  |
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
| finding_severity | `actions_design.closed_severity` | yes |  |
| requested_agent_id | `text` | yes |  |

Constraints:

* `action_request_content_check`: `CHECK ((intent <> ALL (ARRAY['review_catch_up'::actions_design.request_intent, 'review_analysis'::actions_design.request_intent])) OR window_days IS NOT NULL)`
* `action_request_content_check1`: `CHECK (intent <> 'review_catch_up'::actions_design.request_intent OR review_mode IS NOT NULL)`
* `action_request_content_check2`: `CHECK (intent <> 'locale_expansion'::actions_design.request_intent OR store IS NOT NULL AND locale IS NOT NULL)`
* `action_request_content_demand_lookback_days_check`: `CHECK (demand_lookback_days > 0)`
* `action_request_content_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions_design.action_revision(organization_id, id)`
* `action_request_content_pkey`: `PRIMARY KEY (organization_id, revision_id)`
* `action_request_content_requested_agent_id_fkey`: `FOREIGN KEY (requested_agent_id) REFERENCES agent(id)`
* `action_request_content_review_mode_check`: `CHECK (review_mode = ANY (ARRAY['manual'::text, 'full_agentic'::text]))`
* `action_request_content_wave_index_check`: `CHECK (wave_index >= 0)`
* `action_request_content_window_days_check`: `CHECK (window_days >= 7 AND window_days <= 180)`
* `request_agent_target_complete`: `TRIGGER DEFERRABLE INITIALLY DEFERRED`
* `request_agent_target_shape`: `CHECK ((intent = 'wake_agent'::actions_design.request_intent) = (requested_agent_id IS NOT NULL))`
* `request_supported_locale`: `CHECK (locale IS NULL OR store IS NOT NULL AND actions_design.is_supported_store_locale(store, locale))`

### `action_ad_content`

One constrained relation for all seven supported Apple Search Ads operations; exact decimal amounts and currency.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| intent | `actions_design.ad_intent` | no |  |
| provider_account_id | `text` | no |  |
| provider_campaign_id | `text` | no |  |
| provider_ad_group_id | `text` | yes |  |
| provider_keyword_id | `text` | yes |  |
| provider_negative_keyword_id | `text` | yes |  |
| keyword_text | `text` | yes |  |
| match_type | `actions_design.ad_match_type` | yes |  |
| daily_budget_amount | `numeric` | yes |  |
| bid_amount | `numeric` | yes |  |
| currency_code | `text` | yes |  |
| observed_status | `actions_design.ad_observed_status` | yes |  |
| observation_availability | `actions_design.observation_availability` | yes |  |
| observation_captured_at | `timestamp with time zone` | yes |  |

Constraints:

* `action_ad_content_bid_amount_check`: `CHECK (bid_amount > 0::numeric)`
* `action_ad_content_check`: `CHECK (intent <> 'set_campaign_budget'::actions_design.ad_intent OR daily_budget_amount IS NOT NULL AND currency_code IS NOT NULL)`
* `action_ad_content_check1`: `CHECK (intent <> 'set_keyword_bid'::actions_design.ad_intent OR provider_ad_group_id IS NOT NULL AND provider_keyword_id IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL)`
* `action_ad_content_check10`: `CHECK ((intent = ANY (ARRAY['create_keyword'::actions_design.ad_intent, 'add_negative_keyword'::actions_design.ad_intent, 'observed'::actions_design.ad_intent])) OR keyword_text IS NULL AND match_type IS NULL)`
* `action_ad_content_check11`: `CHECK ((intent = ANY (ARRAY['set_keyword_bid'::actions_design.ad_intent, 'observed'::actions_design.ad_intent])) OR provider_keyword_id IS NULL)`
* `action_ad_content_check12`: `CHECK ((intent = ANY (ARRAY['delete_negative_keyword'::actions_design.ad_intent, 'observed'::actions_design.ad_intent])) OR provider_negative_keyword_id IS NULL)`
* `action_ad_content_check13`: `CHECK ((intent = ANY (ARRAY['set_keyword_bid'::actions_design.ad_intent, 'create_keyword'::actions_design.ad_intent, 'add_negative_keyword'::actions_design.ad_intent, 'observed'::actions_design.ad_intent])) OR provider_ad_group_id IS NULL)`
* `action_ad_content_check2`: `CHECK (intent <> 'create_keyword'::actions_design.ad_intent OR provider_ad_group_id IS NOT NULL AND keyword_text IS NOT NULL AND match_type IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL)`
* `action_ad_content_check3`: `CHECK (intent <> 'add_negative_keyword'::actions_design.ad_intent OR keyword_text IS NOT NULL AND match_type IS NOT NULL)`
* `action_ad_content_check4`: `CHECK (intent <> 'delete_negative_keyword'::actions_design.ad_intent OR provider_negative_keyword_id IS NOT NULL)`
* `action_ad_content_check5`: `CHECK (intent <> 'observed'::actions_design.ad_intent OR observation_availability IS NOT NULL AND observation_captured_at IS NOT NULL)`
* `action_ad_content_check6`: `CHECK (intent = 'observed'::actions_design.ad_intent OR observed_status IS NULL)`
* `action_ad_content_check7`: `CHECK ((intent = ANY (ARRAY['set_campaign_budget'::actions_design.ad_intent, 'observed'::actions_design.ad_intent])) OR daily_budget_amount IS NULL)`
* `action_ad_content_check8`: `CHECK ((intent = ANY (ARRAY['set_keyword_bid'::actions_design.ad_intent, 'create_keyword'::actions_design.ad_intent, 'observed'::actions_design.ad_intent])) OR bid_amount IS NULL)`
* `action_ad_content_check9`: `CHECK ((intent = ANY (ARRAY['set_keyword_bid'::actions_design.ad_intent, 'set_campaign_budget'::actions_design.ad_intent, 'create_keyword'::actions_design.ad_intent, 'observed'::actions_design.ad_intent])) OR currency_code IS NULL)`
* `action_ad_content_currency_code_check`: `CHECK (currency_code ~ '^[A-Z]{3}$'::text)`
* `action_ad_content_daily_budget_amount_check`: `CHECK (daily_budget_amount > 0::numeric)`
* `action_ad_content_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions_design.action_revision(organization_id, id)`
* `action_ad_content_pkey`: `PRIMARY KEY (organization_id, revision_id)`
* `action_ad_content_provider_ad_group_id_check`: `CHECK (provider_ad_group_id ~ '^[1-9][0-9]*$'::text)`
* `action_ad_content_provider_campaign_id_check`: `CHECK (provider_campaign_id ~ '^[1-9][0-9]*$'::text)`
* `action_ad_content_provider_keyword_id_check`: `CHECK (provider_keyword_id ~ '^[1-9][0-9]*$'::text)`
* `action_ad_content_provider_negative_keyword_id_check`: `CHECK (provider_negative_keyword_id ~ '^[1-9][0-9]*$'::text)`

### `action_advisory_content`

Typed evidence, recommendation and prerequisite content. Acknowledgment never pretends to publish.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| kind | `actions_design.advisory_kind` | no |  |
| detail | `text` | yes |  |
| suggestion | `text` | yes |  |
| primary_link_label | `text` | yes |  |
| primary_link_path | `text` | yes |  |
| connector_source_id | `text` | yes |  |
| connector_type | `actions_design.advisory_connector_kind` | yes |  |
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
| impact | `actions_design.closed_severity` | yes |  |
| effort | `actions_design.closed_severity` | yes |  |
| confidence_label | `actions_design.closed_severity` | yes |  |
| confidence_score | `numeric` | yes |  |
| quick_win_source_id | `text` | yes |  |
| recommendation_type | `actions_design.recommendation_kind` | yes |  |
| market_label | `text` | yes |  |
| gate_text | `text` | yes |  |
| capability_tier | `integer` | yes |  |
| proposed_next_step | `text` | yes |  |
| audit_store | `actions_design.store_kind` | yes |  |
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

Constraints:

* `action_advisory_content_capability_tier_check`: `CHECK (capability_tier >= 1 AND capability_tier <= 3)`
* `action_advisory_content_consecutive_failures_check`: `CHECK (consecutive_failures >= 0)`
* `action_advisory_content_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions_design.action_revision(organization_id, id)`
* `action_advisory_content_pkey`: `PRIMARY KEY (organization_id, revision_id)`
* `action_advisory_content_primary_link_path_check`: `CHECK (primary_link_path IS NULL OR primary_link_path ~ '^/[^/]'::text)`
* `action_advisory_content_unblock_cta_path_check`: `CHECK (unblock_cta_path IS NULL OR unblock_cta_path ~ '^/[^/]'::text)`

### `action_content_term`

Ordered multivalued terms and field selections attached to one revision.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| role | `actions_design.term_role` | no |  |
| ordinal | `integer` | no |  |
| term | `text` | no |  |
| meaning | `text` | yes |  |

Constraints:

* `action_content_term_check`: `CHECK (role = 'gloss'::actions_design.term_role AND meaning IS NOT NULL OR role <> 'gloss'::actions_design.term_role AND meaning IS NULL)`
* `action_content_term_ordinal_check`: `CHECK (ordinal >= 0)`
* `action_content_term_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions_design.action_revision(organization_id, id)`
* `action_content_term_pkey`: `PRIMARY KEY (organization_id, revision_id, role, ordinal)`

### `action_content_note`

Ordered notes with a closed role; not a generic key/value payload.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| section | `actions_design.prose_section` | no |  |
| ordinal | `integer` | no |  |
| text_content | `text` | no |  |

Constraints:

* `action_content_note_ordinal_check`: `CHECK (ordinal >= 0)`
* `action_content_note_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions_design.action_revision(organization_id, id)`
* `action_content_note_pkey`: `PRIMARY KEY (organization_id, revision_id, section, ordinal)`

### `action_market_country`

Explicit country targets belonging to a revision.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| role | `actions_design.country_role` | no |  |
| ordinal | `integer` | no |  |
| country | `text` | no |  |

Constraints:

* `action_market_country_ordinal_check`: `CHECK (ordinal >= 0)`
* `action_market_country_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions_design.action_request_content(organization_id, revision_id)`
* `action_market_country_pkey`: `PRIMARY KEY (organization_id, revision_id, role, ordinal)`

### `action_market_competitor`

Explicit competitor targets belonging to a revision.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| ordinal | `integer` | no |  |
| competitor_name | `text` | no |  |

Constraints:

* `action_market_competitor_ordinal_check`: `CHECK (ordinal >= 0)`
* `action_market_competitor_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions_design.action_request_content(organization_id, revision_id)`
* `action_market_competitor_pkey`: `PRIMARY KEY (organization_id, revision_id, ordinal)`

## Provenance and links

### `action_revision_source`

Typed links to existing runs, recommendations, reports, backlog items, experiments or tickets.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| id | `text` | no |  |
| organization_id | `text` | no |  |
| revision_id | `text` | no |  |
| kind | `actions_design.action_source_kind` | no |  |
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

Constraints:

* `action_revision_source_check`: `CHECK (num_nonnulls(source_agent_run_id, source_recommendation_id, source_variant_id, source_report_version_id, source_backlog_id, source_experiment_id, source_action_id) = 1)`
* `action_revision_source_check1`: `CHECK ((kind = 'agent_run'::actions_design.action_source_kind) = (source_agent_run_id IS NOT NULL))`
* `action_revision_source_check2`: `CHECK ((kind = 'recommendation'::actions_design.action_source_kind) = (source_recommendation_id IS NOT NULL))`
* `action_revision_source_check3`: `CHECK ((kind = 'recommendation_variant'::actions_design.action_source_kind) = (source_variant_id IS NOT NULL))`
* `action_revision_source_check4`: `CHECK ((kind = 'report_version'::actions_design.action_source_kind) = (source_report_version_id IS NOT NULL))`
* `action_revision_source_check5`: `CHECK ((kind = 'backlog_item'::actions_design.action_source_kind) = (source_backlog_id IS NOT NULL))`
* `action_revision_source_check6`: `CHECK ((kind = 'experiment'::actions_design.action_source_kind) = (source_experiment_id IS NOT NULL))`
* `action_revision_source_check7`: `CHECK ((kind = 'action'::actions_design.action_source_kind) = (source_action_id IS NOT NULL))`
* `action_revision_source_check8`: `CHECK ((kind = ANY (ARRAY['agent_run'::actions_design.action_source_kind, 'report_version'::actions_design.action_source_kind])) OR source_plan_coordinate IS NULL AND source_finding_coordinate IS NULL AND source_candidate_coordinate IS NULL)`
* `action_revision_source_organization_id_revision_id_fkey`: `FOREIGN KEY (organization_id, revision_id) REFERENCES actions_design.action_revision(organization_id, id)`
* `action_revision_source_organization_id_source_action_id_fkey`: `FOREIGN KEY (organization_id, source_action_id) REFERENCES actions_design.action(organization_id, id)`
* `action_revision_source_pkey`: `PRIMARY KEY (id)`
* `action_revision_source_source_agent_run_id_fkey`: `FOREIGN KEY (source_agent_run_id) REFERENCES agent_run(id)`
* `action_revision_source_source_backlog_id_fkey`: `FOREIGN KEY (source_backlog_id) REFERENCES opportunity_backlog(id)`
* `action_revision_source_source_experiment_id_fkey`: `FOREIGN KEY (source_experiment_id) REFERENCES aso_experiment(id)`
* `action_revision_source_source_recommendation_id_fkey`: `FOREIGN KEY (source_recommendation_id) REFERENCES aso_recommendation(id)`
* `action_revision_source_source_report_version_id_fkey`: `FOREIGN KEY (source_report_version_id) REFERENCES report_version(id)`
* `action_revision_source_source_variant_id_fkey`: `FOREIGN KEY (source_variant_id) REFERENCES aso_recommendation_variant(id)`

### `action_alias`

Stable existing URLs resolve to the permanent ticket; no retired executable payload.

| Field | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| organization_id | `text` | no |  |
| namespace | `actions_design.action_alias_namespace` | no |  |
| old_id | `text` | no |  |
| action_id | `text` | no |  |
| historical_membership_known | `boolean` | no |  |

Constraints:

* `action_alias_organization_id_action_id_fkey`: `FOREIGN KEY (organization_id, action_id) REFERENCES actions_design.action(organization_id, id) DEFERRABLE INITIALLY DEFERRED`
* `action_alias_pkey`: `PRIMARY KEY (organization_id, namespace, old_id)`

## Closed enum values

* `action_alias_namespace`: `pending_action`, `pending_action_batch`, `review_draft`, `review_draft_batch`, `agent_request`, `agent_activity`, `review_history`, `review_draft_rejection`, `capability_execution`, `recommendation`, `recommendation_variant`, `recovery_receipt`
* `action_attempt_kind`: `write`, `readback`, `generation`, `late_evidence`
* `action_attempt_result`: `acknowledged`, `known_not_applied`, `uncertain`, `matched`, `mismatch`, `unreadable`, `generated`, `discarded`
* `action_authorization_scope`: `perform`, `generate`, `revise`
* `action_channel`: `web`, `chat`, `mcp`, `api`, `slack`, `discord`, `agent`, `worker`, `operator`, `migration`
* `action_command_error`: `stale_version`, `stale_revision`, `stale_membership`, `invalid_transition`, `undo_expired`, `execution_started`, `unresolved_write`, `permission_changed`, `billing_required`, `unsupported_operation`, `idempotency_mismatch`, `target_changed`
* `action_command_kind`: `create`, `revise`, `approve`, `undo`, `reject`, `acknowledge`, `snooze`, `unsnooze`, `assign`, `archive`, `restore`, `supersede`, `retry`, `reconcile`, `record_observation`, `record_attempt`, `resolve_dependency`, `grant_policy`, `revoke_policy`
* `action_command_outcome`: `accepted`, `conflict`, `refused`
* `action_decision`: `open`, `approved`, `declined`, `acknowledged`, `cancelled`, `superseded`
* `action_dependency_requirement`: `completed`, `verified_live`, `verified_editable`, `generated`, `permission_restored`, `release_available`
* `action_execution_phase`: `ready`, `claimed`, `verification_due`, `uncertain`, `blocked`, `settled`, `cancelled`
* `action_execution_result`: `generated`, `verified_live`, `verified_editable`, `handled_externally`, `acknowledged_only`, `failed`, `cancelled`
* `action_failure_class`: `permission`, `rate_limit`, `transport`, `target_changed`, `provider_rejected`, `persistence`, `unsupported_readback`, `invalid_content`, `billing`
* `action_hold_reason`: `permission`, `billing`, `resource_busy`, `target_changed`, `uncertain_write`, `retry_exhausted`, `unsupported_readback`, `generation_conflict`, `awaiting_release`
* `action_no_work_reason`: `no_eligible_reviews`
* `action_non_application_basis`: `pre_dispatch_failure`, `provider_rejection`, `provider_terminal_non_application`, `expired_uncommitted_edit`
* `action_observation_completeness`: `complete`, `partial`, `unavailable`
* `action_output_kind`: `revision`, `review_analysis`, `agent_run`, `no_work`
* `action_principal`: `user`, `api_key`, `agent`, `policy`, `system`
* `action_recovery_mode`: `readback_before_retry`, `native_idempotency`, `manual_reconciliation`, `internal_atomic`
* `action_resource_scope`: `store_application`, `advertising_account`
* `action_revision_purpose`: `proposal`, `baseline`, `observation`
* `action_source_kind`: `agent_run`, `recommendation`, `recommendation_variant`, `report_version`, `backlog_item`, `experiment`, `action`
* `action_step_kind`: `asc_app_info_localization_upsert`, `asc_version_localization_upsert`, `asc_live_promotional_text_set`, `asc_editable_promotional_text_set`, `asc_review_response_upsert`, `asc_app_clip_localization_create`, `asc_app_clip_header_reserve`, `asc_app_clip_header_upload_chunk`, `asc_app_clip_header_commit`, `asc_app_clip_incomplete_header_delete`, `play_edit_create`, `play_listing_put`, `play_edit_commit`, `play_review_response_set`, `asa_campaign_status_set`, `asa_campaign_budget_set`, `asa_keyword_bid_set`, `asa_keyword_create`, `asa_negative_keyword_create`, `asa_negative_keyword_delete`, `internal_generate_content`, `internal_revise_content`, `internal_commit_children`, `internal_recheck_prerequisite`
* `action_surface`: `provider_response`, `editable_listing`, `live_listing`, `review_response`, `advertising_resource`, `internal_artifact`
* `action_transport`: `asc_api`, `asc_browser`, `play_api`, `play_session`, `play_browser`, `asa_api`, `internal`
* `ad_intent`: `pause_campaign`, `enable_campaign`, `set_campaign_budget`, `set_keyword_bid`, `create_keyword`, `add_negative_keyword`, `delete_negative_keyword`, `observed`
* `ad_match_type`: `EXACT`, `BROAD`
* `ad_observed_status`: `ENABLED`, `ACTIVE`, `PAUSED`, `DELETED`
* `advisory_connector_kind`: `app_store_connect`, `apple_search_ads`
* `advisory_kind`: `optimize_keywords`, `improve_retention`, `adjust_monetization`, `update_store_listing`, `review_finding`, `aso_review_needed`, `agent_attention_needed`, `onboarding_audit_recommendation`, `connect_source`, `store_app_access_lost`, `flag_issue`, `escalate`, `stage_blocker`
* `app_clip_header_state`: `absent`, `incomplete`, `complete`, `unreadable`
* `app_clip_operation`: `none`, `create_localization`, `repair_header`, `observed`
* `approval_setting`: `auto`, `await`
* `closed_severity`: `low`, `medium`, `high`
* `content_value_state`: `unspecified`, `present`, `empty`, `dismissed`, `unreadable`
* `country_role`: `demand`, `competitor`
* `gloss_status`: `updating`, `ready`, `unavailable`
* `listing_intent`: `create`, `update`, `repair`, `restore`, `observed`
* `listing_version_state`: `editable`, `in_review`, `processing`, `live`, `rejected`, `removed`, `unreadable`
* `media_availability`: `stored`, `missing`, `unreadable`
* `media_display_type`: `APP_APPLE_TV`, `APP_APPLE_VISION_PRO`, `APP_DESKTOP`, `APP_IPAD_105`, `APP_IPAD_97`, `APP_IPAD_PRO_129`, `APP_IPAD_PRO_3GEN_11`, `APP_IPAD_PRO_3GEN_129`, `APP_IPHONE_35`, `APP_IPHONE_40`, `APP_IPHONE_47`, `APP_IPHONE_55`, `APP_IPHONE_58`, `APP_IPHONE_61`, `APP_IPHONE_65`, `APP_IPHONE_67`, `APP_WATCH_SERIES_10`, `APP_WATCH_SERIES_3`, `APP_WATCH_SERIES_4`, `APP_WATCH_SERIES_7`, `APP_WATCH_ULTRA`, `phoneScreenshots`, `sevenInchScreenshots`
* `media_kind`: `screenshot`, `icon`, `app_preview`, `app_clip_header`
* `media_storage_immutability`: `versioned_object`, `content_addressed_immutable`
* `observation_availability`: `present`, `absent`, `unreadable`, `pending`, `unknown`
* `play_commit_policy`: `ERROR_IF_IN_REVIEW`
* `prose_section`: `what_will_happen`, `supporting_evidence`, `description_outline`, `prioritization`, `notes`, `unblock_steps`
* `recommendation_kind`: `keywords`, `promotional_text`, `description`, `screenshots`, `icon`, `app_previews`, `title_subtitle`, `cpp`, `short_description`, `title`, `subtitle`, `locale_expansion`
* `reply_intent`: `send`, `update`, `observed`
* `request_intent`: `locale_expansion`, `listing_change`, `review_catch_up`, `review_analysis`, `wake_agent`, `propose_experiment`, `revert_experiment`, `restore_listing`
* `request_origin`: `scheduled_agent`, `user_directed_chat_or_mcp`, `human`, `system`
* `research_coverage`: `ready`, `cold`
* `review_publication_state`: `published`, `pending_publication`, `hidden`, `deleted`, `unreadable`
* `store_kind`: `ios`, `android`
* `term_role`: `added`, `removed`, `gloss`, `trending`
