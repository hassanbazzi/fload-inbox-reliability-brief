# Fload inbox — proposed field-level schema

15 September 2026. This is the concrete target-field dictionary, not the deployed database.

**Four additions; two existing tables evolve.** Structural SQL and this dictionary are generated from the same definition. Full migration, authorization/transition guards, RLS policies and provider behavior remain implementation work.

[Open the visual schema](https://hassanbazzi.github.io/fload-inbox-reliability-brief/#schema)

## action — Evolve pending_action

The permanent ticket and its current organization-shared decision.

| Column | SQL type | Required | Key/reference | Default | Meaning |
| --- | --- | --- | --- | --- | --- |
| `id` | `text` | Yes | PK | — | Permanent ID; preserves existing IDs where possible. |
| `organization_id` | `text` | Yes | FK → organization.id | — | Tenant scope. |
| `asset_id` | `text` | No | FK → asset.id | — | Related app; nullable for organization-level work. |
| `kind` | `action_kind` | Yes |  | — | Execution, generation, group, advisory or retained history. |
| `capability` | `action_capability` | Yes |  | — | Closed operation key; immutable for this ticket. |
| `capability_version` | `integer` | Yes |  | 1 | Version of the operation contract. |
| `version` | `bigint` | Yes |  | 1 | Compare-and-set token for shared decisions. |
| `event_sequence` | `bigint` | Yes |  | 0 | Last committed per-ticket history sequence. |
| `current_revision_id` | `text` | Yes | FK → action_revision.id | — | Current proposed content; scoped to this same ticket. |
| `current_authorization_event_id` | `text` | No | FK → action_event.id | — | Active authorization; history remains after it changes. |
| `assigned_to_user_id` | `text` | No | FK → user.id | — | Current responsible teammate; null means unassigned. |
| `state` | `action_state` | Yes |  | 'open' | One shared decision state. |
| `resolution` | `action_resolution` | No |  | — | Explicit terminal outcome when resolved. |
| `priority` | `action_priority` | Yes |  | 'medium' | Shared sort priority. |
| `blocker_code` | `action_blocker` | No |  | — | Closed blocker reason; never inferred from read state. |
| `blocked_by_action_id` | `text` | No | FK → action.id | — | Another ticket that must settle first. |
| `next_check_at` | `timestamptz` | No |  | — | Next scheduled prerequisite/recovery check. |
| `snoozed_until` | `timestamptz` | No |  | — | Organization-shared snooze deadline. |
| `archived_at` | `timestamptz` | No |  | — | Archive timestamp; does not erase evidence. |
| `membership_frozen_at` | `timestamptz` | No |  | — | First accepted selection freezes member identities. |
| `created_at` | `timestamptz` | Yes |  | clock_timestamp() | Creation time. |
| `updated_at` | `timestamptz` | Yes |  | clock_timestamp() | Last shared change. |
| `deleted_at` | `timestamptz` | No |  | — | Retained tombstone; not a cascading delete. |

### Constraints

- `action_org_id_uq` — UNIQUE: `organization_id, id`
- `action_org_id_capability_uq` — UNIQUE: `organization_id, id, capability`
- `action_versions_ck` — CHECK: `version > 0 AND event_sequence >= 0 AND capability_version > 0`
- `action_resolution_ck` — CHECK: `(state = 'resolved') = (resolution IS NOT NULL)`
- `action_batch_freeze_ck` — CHECK: `membership_frozen_at IS NULL OR kind = 'group'`
- `action_dependency_ck` — CHECK: `blocked_by_action_id IS NULL OR blocked_by_action_id <> id`
- `action_org_fk` — FK: `organization_id → organization (id)`
- `action_revision_fk` — FK: `organization_id, id, current_revision_id → action_revision (organization_id, action_id, id)`
- `action_authorization_fk` — FK: `organization_id, id, current_authorization_event_id → action_event (organization_id, action_id, id)`
- `action_blocked_by_fk` — FK: `organization_id, blocked_by_action_id → action (organization_id, id)`
- `action_asset_id_fk` — FK: `asset_id → asset (id)`
- `action_assigned_to_user_id_fk` — FK: `assigned_to_user_id → user (id)`

### Transaction rules still to implement

- Lock or CAS the ticket before shared mutations. Personal read writes never update this row.
- Validate app and assignee organization membership; block archive while an uncertain effect needs attention.
- Every parent and child is a row in this same table.

## action_revision — Add

Every immutable proposal, using explicit columns for each closed content variant.

| Column | SQL type | Required | Key/reference | Default | Meaning |
| --- | --- | --- | --- | --- | --- |
| `id` | `text` | Yes | PK | — | Permanent ID; preserves existing IDs where possible. |
| `organization_id` | `text` | Yes | FK → organization.id | — | Tenant scope. |
| `action_id` | `text` | Yes | FK → action.id | — | Ticket this record belongs to. |
| `revision_number` | `integer` | Yes |  | — | Monotonic within this ticket. |
| `content_kind` | `action_content_kind` | Yes |  | — | Selects the required and forbidden content fields. |
| `operation` | `action_capability` | Yes | FK → action.capability | — | Frozen capability; must match the ticket. |
| `schema_version` | `integer` | Yes |  | 1 | Versioned interpretation of these fields. |
| `canonicalization_version` | `integer` | Yes |  | 1 | Exact normalization/hash algorithm version. |
| `title` | `text` | Yes |  | — | Human-facing proposal title. |
| `reason` | `text` | Yes |  | — | Why this work is proposed. |
| `instructions` | `text` | No |  | — | Specific human or agent revision instructions. |
| `content_digest` | `char(64)` | Yes |  | — | SHA-256 of the explicit authorization-relevant fields. |
| `created_by_event_id` | `text` | Yes | FK → action_event.id | — | Authoring event with actor attribution. |
| `created_at` | `timestamptz` | Yes |  | clock_timestamp() | When this immutable revision was created. |
| `store` | `action_store` | Conditional: review / listing / ads; store is not used by ads |  | — | Store for review/listing content. |
| `connector_id` | `text` | Conditional: review / listing / ads; store is not used by ads | FK → data_connector.id | — | Exact connector/account target; permission rechecked at dispatch. |
| `provider_app_id` | `text` | Conditional: review / listing / ads; store is not used by ads |  | — | Pinned Apple app ID or Android package name. |
| `expected_provider_version` | `text` | Conditional: review / listing / ads; store is not used by ads |  | — | Version precondition if the provider supports one. |
| `review_id` | `text` | Conditional: Required for review | FK → review.id | — | Review receiving this reply. |
| `reply_mode` | `action_reply_mode` | Conditional: Required for review |  | — | Send a new reply or update an existing one. |
| `reply_text` | `text` | Conditional: Required for review |  | — | Exact approved public reply text. |
| `expected_response_id` | `text` | Conditional: Required for update |  | — | Existing provider response being replaced. |
| `original_ai_reply` | `text` | Conditional: review revisions only |  | — | Imported original generated copy when a distinct old revision is unavailable. |
| `generation_model` | `text` | Conditional: review revisions only |  | — | Model identifier preserved with the authored copy. |
| `detected_language` | `text` | Conditional: review revisions only |  | — | Original detected language value; not silently reinterpreted. |
| `prompt_tokens` | `integer` | Conditional: review revisions only |  | — | Retained generation usage count; null means not recorded. |
| `completion_tokens` | `integer` | Conditional: review revisions only |  | — | Retained generation usage count; null means not recorded. |
| `total_tokens` | `integer` | Conditional: review revisions only |  | — | Retained generation usage count; null means not recorded. |
| `locale` | `text` | Conditional: Required for listing |  | — | Canonical store locale; validated against provider support. |
| `source_snapshot_captured_at` | `timestamptz` | Conditional: listing revisions only |  | — | Historical listing snapshot used for restore; values are frozen below. |
| `experiment_id` | `text` | Conditional: Listing only | FK → aso_experiment.id | — | Related listing experiment. |
| `before_title` | `text` | Conditional: listing revisions only |  | — | Exact prior title if known. |
| `before_title_known` | `boolean` | Conditional: Required for listing |  | — | True = prior value was observed; false = unknown. |
| `after_title` | `text` | Conditional: listing revisions only |  | — | Proposed title: NULL = unchanged; empty string = intentional clearing. |
| `before_subtitle` | `text` | Conditional: listing revisions only |  | — | Exact prior subtitle if known. |
| `before_subtitle_known` | `boolean` | Conditional: Required for listing |  | — | True = prior value was observed; false = unknown. |
| `after_subtitle` | `text` | Conditional: listing revisions only |  | — | Proposed subtitle: NULL = unchanged; empty string = intentional clearing. |
| `before_description` | `text` | Conditional: listing revisions only |  | — | Exact prior description if known. |
| `before_description_known` | `boolean` | Conditional: Required for listing |  | — | True = prior value was observed; false = unknown. |
| `after_description` | `text` | Conditional: listing revisions only |  | — | Proposed description: NULL = unchanged; empty string = intentional clearing. |
| `before_short_description` | `text` | Conditional: listing revisions only |  | — | Exact prior short description if known. |
| `before_short_description_known` | `boolean` | Conditional: Required for listing |  | — | True = prior value was observed; false = unknown. |
| `after_short_description` | `text` | Conditional: listing revisions only |  | — | Proposed short description: NULL = unchanged; empty string = intentional clearing. |
| `before_keywords` | `text` | Conditional: listing revisions only |  | — | Exact prior keywords if known. |
| `before_keywords_known` | `boolean` | Conditional: Required for listing |  | — | True = prior value was observed; false = unknown. |
| `after_keywords` | `text` | Conditional: listing revisions only |  | — | Proposed keywords: NULL = unchanged; empty string = intentional clearing. |
| `before_promotional_text` | `text` | Conditional: listing revisions only |  | — | Exact prior promotional text if known. |
| `before_promotional_text_known` | `boolean` | Conditional: Required for listing |  | — | True = prior value was observed; false = unknown. |
| `after_promotional_text` | `text` | Conditional: listing revisions only |  | — | Proposed promotional text: NULL = unchanged; empty string = intentional clearing. |
| `before_whats_new` | `text` | Conditional: listing revisions only |  | — | Exact prior whats new if known. |
| `before_whats_new_known` | `boolean` | Conditional: Required for listing |  | — | True = prior value was observed; false = unknown. |
| `after_whats_new` | `text` | Conditional: listing revisions only |  | — | Proposed whats new: NULL = unchanged; empty string = intentional clearing. |
| `before_support_url` | `text` | Conditional: listing revisions only |  | — | Exact prior support url if known. |
| `before_support_url_known` | `boolean` | Conditional: Required for listing |  | — | True = prior value was observed; false = unknown. |
| `after_support_url` | `text` | Conditional: listing revisions only |  | — | Proposed support url: NULL = unchanged; empty string = intentional clearing. |
| `ads_account_id` | `text` | Conditional: ads revisions only |  | — | Pinned Apple Search Ads account ID. |
| `campaign_id` | `text` | Conditional: ads revisions only |  | — | Target campaign ID. |
| `ad_group_id` | `text` | Conditional: ads revisions only |  | — | Target ad group ID. |
| `keyword_id` | `text` | Conditional: ads revisions only |  | — | Target keyword ID. |
| `negative_keyword_id` | `text` | Conditional: ads revisions only |  | — | Negative keyword to delete. |
| `keyword_text` | `text` | Conditional: ads revisions only |  | — | Exact keyword text to create. |
| `match_type` | `action_match_type` | Conditional: ads revisions only |  | — | Exact or broad match. |
| `daily_budget` | `numeric(20,6)` | Conditional: ads revisions only |  | — | Approved daily budget; decimal, never floating point. |
| `bid_amount` | `numeric(20,6)` | Conditional: ads revisions only |  | — | Approved keyword bid. |
| `currency_code` | `char(3)` | Conditional: ads revisions only |  | — | Uppercase three-letter currency. |
| `before_enabled` | `boolean` | Conditional: ads revisions only |  | — | Prior resource enabled state, if known. |
| `before_daily_budget` | `numeric(20,6)` | Conditional: ads revisions only |  | — | Prior daily budget, if known. |
| `before_bid_amount` | `numeric(20,6)` | Conditional: ads revisions only |  | — | Prior bid, if known. |
| `request_kind` | `action_request_kind` | Conditional: request revisions only |  | — | Closed generation/request handler. |
| `target_agent_id` | `text` | Conditional: request revisions only | FK → agent.id | — | Agent responsible for the requested work. |
| `source_agent_request_id` | `text` | Conditional: request revisions only | FK → agent_request.id | — | Originating Agents-domain request. |
| `source_agent_run_id` | `text` | Conditional: request revisions only | FK → agent_run.id | — | Originating Agents-domain run. |
| `review_window_days` | `integer` | Conditional: request revisions only |  | — | Review catch-up/analysis window, 7–180 days. |
| `publication_mode` | `action_publication_mode` | Conditional: request revisions only |  | — | Manual review or separately authorized policy publication. |
| `generation_policy_version` | `integer` | Conditional: request revisions only |  | — | Exact code/policy version used to authorize generation. |
| `scope_text` | `text` | Conditional: request revisions only |  | — | Named instructions for generation; not an executor selector. |
| `target_locales` | `text[]` | Conditional: request revisions only |  | — | Immutable locale-code values, validated against the selected store; not batch membership. |
| `source_listing_revision_id` | `text` | Conditional: request revisions only | FK → action_revision.id | — | Immutable listing content used as generation input. |

### Constraints

- `action_revision_org_id_uq` — UNIQUE: `organization_id, id`
- `action_revision_owner_id_uq` — UNIQUE: `organization_id, action_id, id`
- `action_revision_number_uq` — UNIQUE: `organization_id, action_id, revision_number`
- `action_revision_versions_ck` — CHECK: `revision_number > 0 AND schema_version > 0 AND canonicalization_version > 0`
- `action_revision_digest_ck` — CHECK: `content_digest ~ '^[0-9a-f]{64}$'`
- `action_revision_review_only_ck` — CHECK: `content_kind = 'review' OR (review_id IS NULL AND reply_mode IS NULL AND reply_text IS NULL AND expected_response_id IS NULL AND original_ai_reply IS NULL AND generation_model IS NULL AND detected_language IS NULL AND prompt_tokens IS NULL AND completion_tokens IS NULL AND total_tokens IS NULL)`
- `action_revision_listing_only_ck` — CHECK: `content_kind = 'listing' OR (locale IS NULL AND source_snapshot_captured_at IS NULL AND experiment_id IS NULL AND before_title IS NULL AND before_title_known IS NULL AND after_title IS NULL AND before_subtitle IS NULL AND before_subtitle_known IS NULL AND after_subtitle IS NULL AND before_description IS NULL AND before_description_known IS NULL AND after_description IS NULL AND before_short_description IS NULL AND before_short_description_known IS NULL AND after_short_description IS NULL AND before_keywords IS NULL AND before_keywords_known IS NULL AND after_keywords IS NULL AND before_promotional_text IS NULL AND before_promotional_text_known IS NULL AND after_promotional_text IS NULL AND before_whats_new IS NULL AND before_whats_new_known IS NULL AND after_whats_new IS NULL AND before_support_url IS NULL AND before_support_url_known IS NULL AND after_support_url IS NULL)`
- `action_revision_ads_only_ck` — CHECK: `content_kind = 'ads' OR (ads_account_id IS NULL AND campaign_id IS NULL AND ad_group_id IS NULL AND keyword_id IS NULL AND negative_keyword_id IS NULL AND keyword_text IS NULL AND match_type IS NULL AND daily_budget IS NULL AND bid_amount IS NULL AND currency_code IS NULL AND before_enabled IS NULL AND before_daily_budget IS NULL AND before_bid_amount IS NULL)`
- `action_revision_request_only_ck` — CHECK: `content_kind = 'request' OR (request_kind IS NULL AND target_agent_id IS NULL AND source_agent_request_id IS NULL AND source_agent_run_id IS NULL AND review_window_days IS NULL AND publication_mode IS NULL AND generation_policy_version IS NULL AND scope_text IS NULL AND target_locales IS NULL AND source_listing_revision_id IS NULL)`
- `action_revision_review_required_ck` — CHECK: `content_kind <> 'review' OR (review_id IS NOT NULL AND reply_mode IS NOT NULL AND reply_text IS NOT NULL AND store IS NOT NULL AND provider_app_id IS NOT NULL)`
- `action_revision_reply_update_ck` — CHECK: `reply_mode IS DISTINCT FROM 'update' OR expected_response_id IS NOT NULL`
- `action_revision_listing_required_ck` — CHECK: `content_kind <> 'listing' OR (store IS NOT NULL AND locale IS NOT NULL AND provider_app_id IS NOT NULL AND before_title_known IS NOT NULL AND before_subtitle_known IS NOT NULL AND before_description_known IS NOT NULL AND before_short_description_known IS NOT NULL AND before_keywords_known IS NOT NULL AND before_promotional_text_known IS NOT NULL AND before_whats_new_known IS NOT NULL AND before_support_url_known IS NOT NULL)`
- `action_revision_listing_after_ck` — CHECK: `content_kind <> 'listing' OR (after_title IS NOT NULL OR after_subtitle IS NOT NULL OR after_description IS NOT NULL OR after_short_description IS NOT NULL OR after_keywords IS NOT NULL OR after_promotional_text IS NOT NULL OR after_whats_new IS NOT NULL OR after_support_url IS NOT NULL)`
- `action_revision_title_before_ck` — CHECK: `before_title IS NULL OR before_title_known IS TRUE`
- `action_revision_subtitle_before_ck` — CHECK: `before_subtitle IS NULL OR before_subtitle_known IS TRUE`
- `action_revision_description_before_ck` — CHECK: `before_description IS NULL OR before_description_known IS TRUE`
- `action_revision_short_description_before_ck` — CHECK: `before_short_description IS NULL OR before_short_description_known IS TRUE`
- `action_revision_keywords_before_ck` — CHECK: `before_keywords IS NULL OR before_keywords_known IS TRUE`
- `action_revision_promotional_text_before_ck` — CHECK: `before_promotional_text IS NULL OR before_promotional_text_known IS TRUE`
- `action_revision_whats_new_before_ck` — CHECK: `before_whats_new IS NULL OR before_whats_new_known IS TRUE`
- `action_revision_support_url_before_ck` — CHECK: `before_support_url IS NULL OR before_support_url_known IS TRUE`
- `action_revision_ads_required_ck` — CHECK: `content_kind <> 'ads' OR (ads_account_id IS NOT NULL AND campaign_id IS NOT NULL)`
- `action_revision_money_ck` — CHECK: `(daily_budget IS NULL OR daily_budget >= 0) AND (bid_amount IS NULL OR bid_amount >= 0) AND (currency_code IS NULL OR currency_code ~ '^[A-Z]{3}$')`
- `action_revision_request_required_ck` — CHECK: `content_kind <> 'request' OR request_kind IS NOT NULL`
- `action_revision_window_ck` — CHECK: `review_window_days IS NULL OR review_window_days BETWEEN 7 AND 180`
- `action_revision_locales_ck` — CHECK: `target_locales IS NULL OR (cardinality(target_locales) > 0 AND array_position(target_locales,NULL) IS NULL)`
- `action_revision_generation_counts_ck` — CHECK: `(prompt_tokens IS NULL OR prompt_tokens >= 0) AND (completion_tokens IS NULL OR completion_tokens >= 0) AND (total_tokens IS NULL OR total_tokens >= 0)`
- `action_revision_review_operation_ck` — CHECK: `content_kind <> 'review' OR operation IN ('post_reply')`
- `action_revision_listing_operation_ck` — CHECK: `content_kind <> 'listing' OR operation IN ('apply_listing_changes', 'update_promo_text', 'create_locale', 'update_description', 'update_short_description', 'revert_experiment', 'aso_revert_listing')`
- `action_revision_ads_operation_ck` — CHECK: `content_kind <> 'ads' OR operation IN ('asa_pause_campaign', 'asa_enable_campaign', 'asa_update_campaign_budget', 'asa_update_keyword_bid', 'asa_create_keyword', 'asa_add_negative_keyword', 'asa_delete_negative_keyword')`
- `action_revision_request_operation_ck` — CHECK: `content_kind <> 'request' OR operation IN ('draft_locale', 'draft_listing', 'review_catch_up_30d', 'generate_review_analysis', 'wake_agent', 'propose_experiment', 'escalate')`
- `action_revision_group_operation_ck` — CHECK: `content_kind <> 'group' OR operation IN ('post_batch', 'apply_listing_changes', 'revert_experiment', 'aso_revert_listing', 'asa_update_keyword_bid', 'draft_locale', 'draft_listing', 'review_catch_up_30d')`
- `action_revision_advisory_operation_ck` — CHECK: `content_kind <> 'advisory' OR operation IN ('flag_issue', 'escalate', 'optimize_keywords', 'improve_retention', 'adjust_monetization', 'update_store_listing', 'review_finding', 'aso_review_needed', 'agent_attention_needed', 'onboarding_audit_recommendation', 'connect_source', 'store_app_access_lost')`
- `action_revision_historical_operation_ck` — CHECK: `content_kind <> 'historical' OR operation IN ('historical_unsupported')`
- `action_revision_store_target_ck` — CHECK: `content_kind IN ('review','listing') OR store IS NULL`
- `action_revision_provider_target_ck` — CHECK: `content_kind IN ('review','listing','ads') OR (connector_id IS NULL AND provider_app_id IS NULL AND expected_provider_version IS NULL)`
- `action_revision_android_fields_ck` — CHECK: `content_kind <> 'listing' OR store <> 'android' OR (after_subtitle IS NULL AND after_keywords IS NULL AND after_promotional_text IS NULL AND after_whats_new IS NULL AND after_support_url IS NULL)`
- `action_revision_ios_fields_ck` — CHECK: `content_kind <> 'listing' OR store <> 'ios' OR after_short_description IS NULL`
- `action_revision_update_promo_text_fields_ck` — CHECK: `operation <> 'update_promo_text' OR (store = 'ios' AND after_promotional_text IS NOT NULL AND after_title IS NULL AND after_subtitle IS NULL AND after_description IS NULL AND after_short_description IS NULL AND after_keywords IS NULL AND after_whats_new IS NULL AND after_support_url IS NULL)`
- `action_revision_update_description_fields_ck` — CHECK: `operation <> 'update_description' OR (store = 'android' AND after_description IS NOT NULL AND after_title IS NULL AND after_subtitle IS NULL AND after_short_description IS NULL AND after_keywords IS NULL AND after_promotional_text IS NULL AND after_whats_new IS NULL AND after_support_url IS NULL)`
- `action_revision_update_short_description_fields_ck` — CHECK: `operation <> 'update_short_description' OR (store = 'android' AND after_short_description IS NOT NULL AND after_title IS NULL AND after_subtitle IS NULL AND after_description IS NULL AND after_keywords IS NULL AND after_promotional_text IS NULL AND after_whats_new IS NULL AND after_support_url IS NULL)`
- `action_revision_create_locale_fields_ck` — CHECK: `operation <> 'create_locale' OR (after_title IS NOT NULL AND after_description IS NOT NULL)`
- `action_revision_asa_pause_campaign_shape_ck` — CHECK: `content_kind <> 'ads' OR operation <> 'asa_pause_campaign' OR (ad_group_id IS NULL AND keyword_id IS NULL AND negative_keyword_id IS NULL AND keyword_text IS NULL AND match_type IS NULL AND daily_budget IS NULL AND bid_amount IS NULL AND currency_code IS NULL AND before_daily_budget IS NULL AND before_bid_amount IS NULL)`
- `action_revision_asa_enable_campaign_shape_ck` — CHECK: `content_kind <> 'ads' OR operation <> 'asa_enable_campaign' OR (ad_group_id IS NULL AND keyword_id IS NULL AND negative_keyword_id IS NULL AND keyword_text IS NULL AND match_type IS NULL AND daily_budget IS NULL AND bid_amount IS NULL AND currency_code IS NULL AND before_daily_budget IS NULL AND before_bid_amount IS NULL)`
- `action_revision_asa_update_campaign_budget_shape_ck` — CHECK: `content_kind <> 'ads' OR operation <> 'asa_update_campaign_budget' OR (daily_budget IS NOT NULL AND currency_code IS NOT NULL AND ad_group_id IS NULL AND keyword_id IS NULL AND negative_keyword_id IS NULL AND keyword_text IS NULL AND match_type IS NULL AND bid_amount IS NULL AND before_enabled IS NULL AND before_bid_amount IS NULL)`
- `action_revision_asa_update_keyword_bid_shape_ck` — CHECK: `content_kind <> 'ads' OR operation <> 'asa_update_keyword_bid' OR (ad_group_id IS NOT NULL AND keyword_id IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL AND negative_keyword_id IS NULL AND keyword_text IS NULL AND match_type IS NULL AND daily_budget IS NULL AND before_enabled IS NULL AND before_daily_budget IS NULL)`
- `action_revision_asa_create_keyword_shape_ck` — CHECK: `content_kind <> 'ads' OR operation <> 'asa_create_keyword' OR (ad_group_id IS NOT NULL AND keyword_text IS NOT NULL AND match_type IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL AND keyword_id IS NULL AND negative_keyword_id IS NULL AND daily_budget IS NULL AND before_enabled IS NULL AND before_daily_budget IS NULL AND before_bid_amount IS NULL)`
- `action_revision_asa_add_negative_keyword_shape_ck` — CHECK: `content_kind <> 'ads' OR operation <> 'asa_add_negative_keyword' OR (keyword_text IS NOT NULL AND match_type IS NOT NULL AND keyword_id IS NULL AND negative_keyword_id IS NULL AND daily_budget IS NULL AND bid_amount IS NULL AND currency_code IS NULL AND before_enabled IS NULL AND before_daily_budget IS NULL AND before_bid_amount IS NULL)`
- `action_revision_asa_delete_negative_keyword_shape_ck` — CHECK: `content_kind <> 'ads' OR operation <> 'asa_delete_negative_keyword' OR (negative_keyword_id IS NOT NULL AND ad_group_id IS NULL AND keyword_id IS NULL AND keyword_text IS NULL AND match_type IS NULL AND daily_budget IS NULL AND bid_amount IS NULL AND currency_code IS NULL AND before_enabled IS NULL AND before_daily_budget IS NULL AND before_bid_amount IS NULL)`
- `action_revision_org_fk` — FK: `organization_id → organization (id)`
- `action_revision_action_fk` — FK: `organization_id, action_id → action (organization_id, id)`
- `action_revision_capability_fk` — FK: `organization_id, action_id, operation → action (organization_id, id, capability)`
- `action_revision_author_fk` — FK: `organization_id, action_id, created_by_event_id → action_event (organization_id, action_id, id)`
- `action_revision_source_fk` — FK: `organization_id, source_listing_revision_id → action_revision (organization_id, id)`
- `action_revision_connector_id_fk` — FK: `connector_id → data_connector (id)`
- `action_revision_review_id_fk` — FK: `review_id → review (id)`
- `action_revision_experiment_id_fk` — FK: `experiment_id → aso_experiment (id)`
- `action_revision_target_agent_id_fk` — FK: `target_agent_id → agent (id)`
- `action_revision_source_agent_request_id_fk` — FK: `source_agent_request_id → agent_request (id)`
- `action_revision_source_agent_run_id_fk` — FK: `source_agent_run_id → agent_run (id)`

### Transaction rules still to implement

- Every column is listed; variant filters hide rows for reading only. Storage is one explicit-column table.
- NULL after_* means leave that listing field unchanged; an empty string is an explicit clear operation.
- Provider field limits, canonical locale membership, operation-specific required/forbidden fields and capability/content-kind mappings are named command validations; structural SQL is not the completed migration.
- Immutable source facts used by restore must be copied into before/after columns before approval, not looked up later.

## action_link — Add

Immutable parent/child and batch revision links.

| Column | SQL type | Required | Key/reference | Default | Meaning |
| --- | --- | --- | --- | --- | --- |
| `id` | `text` | Yes | PK | — | Permanent ID; preserves existing IDs where possible. |
| `organization_id` | `text` | Yes | FK → organization.id | — | Tenant scope. |
| `source_action_id` | `text` | Yes | FK → action.id | — | Parent/source ticket. |
| `source_revision_id` | `text` | No | FK → action_revision.id | — | Exact source revision; mandatory for member links. |
| `target_action_id` | `text` | Yes | FK → action.id | — | Child/target ticket. |
| `target_revision_id` | `text` | No | FK → action_revision.id | — | Exact child content; mandatory for member links. |
| `relation` | `action_relation` | Yes |  | — | Closed relationship meaning. |
| `position` | `integer` | Conditional: member only |  | — | Stable member order; required for member links. |
| `created_by_event_id` | `text` | Yes | FK → action_event.id | — | Who created this relationship. |
| `created_at` | `timestamptz` | Yes |  | clock_timestamp() | Relationship creation time. |

### Constraints

- `action_link_org_id_uq` — UNIQUE: `organization_id, id`
- `action_link_target_revision_id_uq` — UNIQUE: `organization_id, target_action_id, target_revision_id, id`
- `action_link_not_self_ck` — CHECK: `source_action_id <> target_action_id`
- `action_link_member_ck` — CHECK: `(relation = 'member' AND source_revision_id IS NOT NULL AND target_revision_id IS NOT NULL AND position IS NOT NULL AND position >= 0) OR (relation <> 'member' AND position IS NULL)`
- `action_link_org_fk` — FK: `organization_id → organization (id)`
- `action_link_source_fk` — FK: `organization_id, source_action_id → action (organization_id, id)`
- `action_link_source_revision_fk` — FK: `organization_id, source_action_id, source_revision_id → action_revision (organization_id, action_id, id)`
- `action_link_target_fk` — FK: `organization_id, target_action_id → action (organization_id, id)`
- `action_link_target_revision_fk` — FK: `organization_id, target_action_id, target_revision_id → action_revision (organization_id, action_id, id)`
- `action_link_creator_fk` — FK: `organization_id, created_by_event_id → action_event (organization_id, id)`

### Transaction rules still to implement

- Source and target revisions must belong to their named tickets and organization.
- Adoption locks children and ensures at most one active presentation parent. A static unique index cannot determine which historical parent revision is current.
- Cycle checks and first-approval membership freeze run inside the command transaction; these are not implied by a foreign key.

## action_event — Add

Immutable actor history, command receipts, exact approvals and provider evidence.

| Column | SQL type | Required | Key/reference | Default | Meaning |
| --- | --- | --- | --- | --- | --- |
| `id` | `text` | Yes | PK | — | Permanent ID; preserves existing IDs where possible. |
| `organization_id` | `text` | Yes | FK → organization.id | — | Tenant scope. |
| `action_id` | `text` | Yes | FK → action.id | — | Ticket this record belongs to. |
| `sequence` | `bigint` | Yes |  | — | Monotonic history position for this ticket. |
| `action_version` | `bigint` | Yes |  | — | Shared decision version after the event. |
| `event_type` | `action_event_type` | Yes |  | — | Closed event variant. |
| `command_event_id` | `text` | No | FK → action_event.id | — | Root accepted command; null on the root receipt. |
| `command_type` | `action_command_type` | No |  | — | Named command, present only on root receipt. |
| `idempotency_key` | `text` | No |  | — | Client/producer retry key; present only on root receipt. |
| `request_digest` | `char(64)` | No |  | — | Digest of the exact validated request. |
| `result_code` | `action_command_result` | No |  | — | Typed immutable acceptance result. |
| `revision_id` | `text` | No | FK → action_revision.id | — | Exact content affected or authorized. |
| `member_link_id` | `text` | No | FK → action_link.id | — | Exact selected batch membership for a child approval. |
| `job_id` | `text` | No | FK → action_job.id | — | Execution attempt or verification job. |
| `actor_kind` | `action_actor_kind` | Yes |  | — | Actual actor category. |
| `actor_subject_id` | `text` | Yes |  | — | Retained actor identity even after membership changes. |
| `actor_user_id` | `text` | No | FK → user.id | — | Live user reference, when applicable. |
| `actor_agent_id` | `text` | No | FK → agent.id | — | Live agent reference, when applicable. |
| `system_actor` | `action_system_actor` | No |  | — | Closed system actor identity. |
| `initiated_by_user_id` | `text` | No | FK → user.id | — | Human who initiated an automated operation, if known. |
| `actor_label_at_time` | `text` | No |  | — | Historical display label; never used for permission. |
| `authorization_mode` | `action_authorization_mode` | No |  | — | Human, explicit policy or unproven imported authorization. |
| `policy_version` | `integer` | No |  | — | Exact automation policy version. |
| `undo_until` | `timestamptz` | No |  | — | Immutable server-owned deadline. |
| `previous_owner_user_id` | `text` | No | FK → user.id | — | Owner before reassignment. |
| `new_owner_user_id` | `text` | No | FK → user.id | — | Owner after reassignment; null means unassigned. |
| `reason` | `text` | No |  | — | Named human-facing explanation, never behavior metadata. |
| `occurred_at` | `timestamptz` | Yes |  | clock_timestamp() | Server timestamp. |
| `provider` | `action_provider` | No |  | — | Source of the acknowledgement/observation. |
| `connector_id` | `text` | No | FK → data_connector.id | — | Account used for this observation. |
| `provider_request_id` | `text` | No |  | — | Provider correlation identifier if supplied. |
| `provider_resource_id` | `text` | No |  | — | Exact resource observed or changed. |
| `provider_version` | `text` | No |  | — | Provider version observed. |
| `provider_step` | `action_provider_step` | No |  | — | Durable write/delete/create substep marker. |
| `observed_at` | `timestamptz` | No |  | — | When the provider was read. |
| `expected_digest` | `char(64)` | No |  | — | Expected value digest from the pinned revision. |
| `observed_digest` | `char(64)` | No |  | — | Digest from actually observed content; absent if unavailable. |
| `comparison_version` | `integer` | No |  | — | Versioned exact comparison algorithm. |
| `observation_surface` | `action_observation_surface` | No |  | — | Distinguishes editable/live/review/ads/internal state. |
| `availability` | `action_observation_availability` | No |  | — | Complete, partial or unavailable read. |
| `verdict` | `action_observation_verdict` | No |  | — | Match, mismatch, absence or unverifiable. |
| `observed_reply_text` | `text` | No |  | — | Exact observed review reply where needed for retained evidence. |
| `agent_run_id` | `text` | No | FK → agent_run.id | — | Linked Agents execution receipt. |
| `review_analysis_id` | `text` | No | FK → review_analysis.id | — | Saved internal review analysis. |
| `experiment_id` | `text` | No | FK → aso_experiment.id | — | Related listing experiment. |
| `capability_execution_id` | `text` | No | FK → capability_execution.id | — | Existing retained execution receipt. |
| `import_source` | `action_import_source` | No |  | — | Closed source-table family; import events only. |
| `import_source_id` | `text` | No |  | — | Original source identifier for historical links. |
| `imported_type_label` | `text` | No |  | — | Original unsupported type label; diagnostic, never executable. |
| `imported_status_label` | `text` | No |  | — | Original status label when preserving history. |

### Constraints

- `action_event_org_id_uq` — UNIQUE: `organization_id, id`
- `action_event_owner_id_uq` — UNIQUE: `organization_id, action_id, id`
- `action_event_revision_id_uq` — UNIQUE: `organization_id, action_id, revision_id, id`
- `action_event_sequence_uq` — UNIQUE: `organization_id, action_id, sequence`
- `action_event_sequence_ck` — CHECK: `sequence > 0 AND action_version > 0`
- `action_event_command_receipt_ck` — CHECK: `(event_type = 'command_accepted' AND command_event_id IS NULL AND command_type IS NOT NULL AND idempotency_key IS NOT NULL AND request_digest IS NOT NULL AND result_code IS NOT NULL) OR (event_type <> 'command_accepted' AND command_type IS NULL AND idempotency_key IS NULL AND request_digest IS NULL AND result_code IS NULL)`
- `action_event_approval_ck` — CHECK: `(event_type = 'approved' AND revision_id IS NOT NULL AND authorization_mode IS NOT NULL AND undo_until IS NOT NULL AND undo_until >= occurred_at) OR (event_type <> 'approved' AND authorization_mode IS NULL AND policy_version IS NULL AND undo_until IS NULL)`
- `action_event_policy_ck` — CHECK: `authorization_mode IS DISTINCT FROM 'policy' OR (policy_version IS NOT NULL AND policy_version > 0)`
- `action_event_member_approval_ck` — CHECK: `member_link_id IS NULL OR (event_type = 'approved' AND revision_id IS NOT NULL AND command_event_id IS NOT NULL)`
- `action_event_actor_ck` — CHECK: `(actor_kind = 'user' AND actor_agent_id IS NULL AND system_actor IS NULL) OR (actor_kind = 'agent' AND actor_user_id IS NULL AND system_actor IS NULL) OR (actor_kind = 'system' AND actor_user_id IS NULL AND actor_agent_id IS NULL AND system_actor IS NOT NULL) OR (actor_kind = 'historical_unknown' AND actor_user_id IS NULL AND actor_agent_id IS NULL AND system_actor IS NULL AND event_type = 'imported')`
- `action_event_observation_ck` — CHECK: `event_type <> 'provider_observed' OR (job_id IS NOT NULL AND revision_id IS NOT NULL AND provider IS NOT NULL AND observed_at IS NOT NULL AND comparison_version IS NOT NULL AND comparison_version > 0 AND observation_surface IS NOT NULL AND availability IS NOT NULL AND verdict IS NOT NULL)`
- `action_event_match_ck` — CHECK: `verdict IS DISTINCT FROM 'matched' OR (availability IS NOT DISTINCT FROM 'complete' AND expected_digest IS NOT NULL AND observed_digest IS NOT NULL AND observed_digest = expected_digest)`
- `action_event_unavailable_ck` — CHECK: `availability IS DISTINCT FROM 'unavailable' OR (verdict = 'unverifiable' AND observed_digest IS NULL AND observed_reply_text IS NULL)`
- `action_event_import_ck` — CHECK: `(event_type = 'imported' AND import_source IS NOT NULL AND import_source_id IS NOT NULL) OR (event_type <> 'imported' AND import_source IS NULL AND import_source_id IS NULL AND imported_type_label IS NULL AND imported_status_label IS NULL)`
- `action_event_org_fk` — FK: `organization_id → organization (id)`
- `action_event_action_fk` — FK: `organization_id, action_id → action (organization_id, id)`
- `action_event_command_fk` — FK: `organization_id, command_event_id → action_event (organization_id, id)`
- `action_event_revision_fk` — FK: `organization_id, action_id, revision_id → action_revision (organization_id, action_id, id)`
- `action_event_member_fk` — FK: `organization_id, action_id, revision_id, member_link_id → action_link (organization_id, target_action_id, target_revision_id, id)`
- `action_event_job_fk` — FK: `organization_id, action_id, job_id → action_job (organization_id, action_id, id)`
- `action_event_actor_user_id_fk` — FK: `actor_user_id → user (id)`
- `action_event_actor_agent_id_fk` — FK: `actor_agent_id → agent (id)`
- `action_event_initiated_by_user_id_fk` — FK: `initiated_by_user_id → user (id)`
- `action_event_previous_owner_user_id_fk` — FK: `previous_owner_user_id → user (id)`
- `action_event_new_owner_user_id_fk` — FK: `new_owner_user_id → user (id)`
- `action_event_connector_id_fk` — FK: `connector_id → data_connector (id)`
- `action_event_agent_run_id_fk` — FK: `agent_run_id → agent_run (id)`
- `action_event_review_analysis_id_fk` — FK: `review_analysis_id → review_analysis (id)`
- `action_event_experiment_id_fk` — FK: `experiment_id → aso_experiment (id)`
- `action_event_capability_execution_id_fk` — FK: `capability_execution_id → capability_execution (id)`

### Transaction rules still to implement

- Each selected child receives its own approved event, linked to the parent command and exact member link.
- Positive provider evidence is appended even when it arrives from an old worker; only the current lease can decide current state.
- Approve/Undo, actor authorization, evidence-variant forbidden fields and root-command lineage require transaction-level validation in addition to the structural checks shown.

## action_job — Add

Durable effect intent and one execution attempt; queue transport carries this ID.

| Column | SQL type | Required | Key/reference | Default | Meaning |
| --- | --- | --- | --- | --- | --- |
| `id` | `text` | Yes | PK | — | Permanent ID; preserves existing IDs where possible. |
| `organization_id` | `text` | Yes | FK → organization.id | — | Tenant scope. |
| `action_id` | `text` | Yes | FK → action.id | — | Ticket this record belongs to. |
| `revision_id` | `text` | Yes | FK → action_revision.id | — | Exact content this job may use. |
| `authorization_event_id` | `text` | No | FK → action_event.id | — | Exact approved event; execute/generate require it. |
| `caused_by_event_id` | `text` | Yes | FK → action_event.id | — | Command or observation that created this job. |
| `kind` | `action_job_kind` | Yes |  | — | Execute, generate or verify. |
| `effect_key` | `text` | Yes |  | — | Stable logical effect key across safe retries. |
| `attempt_number` | `integer` | Yes |  | 1 | One-based attempt number. |
| `previous_job_id` | `text` | No | FK → action_job.id | — | Prior attempt; never overwritten. |
| `verifies_job_id` | `text` | No | FK → action_job.id | — | Execution attempt this verification observes. |
| `state` | `action_job_state` | Yes |  | 'ready' | Persisted scheduling/attempt state. |
| `outcome` | `action_job_outcome` | No |  | — | Settled attempt result. |
| `available_at` | `timestamptz` | Yes |  | — | Not before the approval Undo deadline. |
| `lease_owner` | `text` | No |  | — | Worker instance currently holding the claim. |
| `lease_epoch` | `bigint` | Yes |  | 0 | Monotonic fence for stale-worker protection. |
| `lease_until` | `timestamptz` | No |  | — | Lease expiry; not permission to resend an uncertain write. |
| `dispatch_started_at` | `timestamptz` | No |  | — | Durable marker before provider I/O. |
| `provider` | `action_provider` | Yes |  | — | Target provider or Fload internal operation. |
| `connector_id` | `text` | No | FK → data_connector.id | — | Exact provider account. |
| `provider_resource_key` | `text` | Yes |  | — | Canonical conflict scope derived from the typed target. |
| `operation_digest` | `char(64)` | Yes |  | — | Digest of exact authorized effect. |
| `provider_idempotency_key` | `text` | No |  | — | Stable native provider key if supported. |
| `recovery_policy` | `action_recovery_policy` | Yes |  | — | Closed retry/readback policy. |
| `recovery_policy_version` | `integer` | Yes |  | 1 | Frozen interpretation of recovery behavior. |
| `created_at` | `timestamptz` | Yes |  | clock_timestamp() | Durable intent creation time. |
| `completed_at` | `timestamptz` | No |  | — | Settled/cancelled time. |

### Constraints

- `action_job_org_id_uq` — UNIQUE: `organization_id, id`
- `action_job_owner_id_uq` — UNIQUE: `organization_id, action_id, id`
- `action_job_revision_id_uq` — UNIQUE: `organization_id, action_id, revision_id, id`
- `action_job_attempt_uq` — UNIQUE: `organization_id, effect_key, attempt_number`
- `action_job_versions_ck` — CHECK: `attempt_number > 0 AND lease_epoch >= 0 AND recovery_policy_version > 0`
- `action_job_authorization_ck` — CHECK: `kind = 'verify' OR authorization_event_id IS NOT NULL`
- `action_job_verify_ck` — CHECK: `(kind = 'verify') = (verifies_job_id IS NOT NULL)`
- `action_job_finished_ck` — CHECK: `(state IN ('settled','cancelled')) = (completed_at IS NOT NULL)`
- `action_job_outcome_ck` — CHECK: `(state = 'settled') = (outcome IS NOT NULL)`
- `action_job_lease_ck` — CHECK: `(lease_owner IS NULL) = (lease_until IS NULL)`
- `action_job_dispatch_ck` — CHECK: `state NOT IN ('dispatching','uncertain') OR dispatch_started_at IS NOT NULL`
- `action_job_digest_ck` — CHECK: `operation_digest ~ '^[0-9a-f]{64}$'`
- `action_job_org_fk` — FK: `organization_id → organization (id)`
- `action_job_action_fk` — FK: `organization_id, action_id → action (organization_id, id)`
- `action_job_revision_fk` — FK: `organization_id, action_id, revision_id → action_revision (organization_id, action_id, id)`
- `action_job_authorization_fk` — FK: `organization_id, action_id, revision_id, authorization_event_id → action_event (organization_id, action_id, revision_id, id)`
- `action_job_cause_fk` — FK: `organization_id, caused_by_event_id → action_event (organization_id, id)`
- `action_job_previous_job_id_fk` — FK: `organization_id, action_id, revision_id, previous_job_id → action_job (organization_id, action_id, revision_id, id)`
- `action_job_verifies_job_id_fk` — FK: `organization_id, action_id, revision_id, verifies_job_id → action_job (organization_id, action_id, revision_id, id)`
- `action_job_connector_id_fk` — FK: `connector_id → data_connector (id)`

### Transaction rules still to implement

- Before claiming, serialize the provider conflict scope across tickets and recheck permission, authorization revision and provider preconditions.
- Validate the referenced event is an approved authorization for this revision and available_at is at/after its deadline. A scoped FK alone cannot prove event meaning.
- An expired dispatch lease becomes uncertain and is read back. Native provider idempotency keys survive safe retries.

## action_read — Evolve inbox_item_state

Only one teammate’s attention; no workflow state.

| Column | SQL type | Required | Key/reference | Default | Meaning |
| --- | --- | --- | --- | --- | --- |
| `organization_id` | `text` | Yes | PK FK → organization.id | — | Tenant scope. |
| `user_id` | `text` | Yes | PK FK → user.id | — | Viewer. |
| `action_id` | `text` | Yes | PK FK → action.id | — | Ticket being read. |
| `seen_revision_id` | `text` | No | FK → action_revision.id | — | Exact content the viewer saw. |
| `seen_event_sequence` | `bigint` | Yes |  | 0 | Last seen history event for this ticket. |
| `explicit_unread_at` | `timestamptz` | No |  | — | A deliberate mark-unread action. |
| `updated_at` | `timestamptz` | Yes |  | clock_timestamp() | Last personal read change. |

### Constraints

- `action_read_sequence_ck` — CHECK: `seen_event_sequence >= 0`
- `action_read_org_fk` — FK: `organization_id → organization (id)`
- `action_read_action_fk` — FK: `organization_id, action_id → action (organization_id, id)`
- `action_read_revision_fk` — FK: `organization_id, action_id, seen_revision_id → action_revision (organization_id, action_id, id)`
- `action_read_user_id_fk` — FK: `user_id → user (id)`

### Transaction rules still to implement

- Primary key is organization + person + ticket.
- Reading neither advances the shared action version nor changes snooze, assignment, approval or outcome.
- Validate seen sequence/revision belongs to this ticket; never mark unseen future events as read.

## Closed enum values

- `action_kind`: `execution`, `generation`, `group`, `advisory`, `historical`
- `action_state`: `open`, `revising`, `authorized`, `rejected`, `cancelled`, `superseded`, `resolved`
- `action_resolution`: `acknowledged`, `delivered`, `verified_editable`, `verified_live`, `measured`, `satisfied_externally`, `failed`
- `action_priority`: `low`, `medium`, `high`
- `action_blocker`: `prerequisite`, `permission`, `provider_conflict`, `uncertain_write`, `unsupported_history`, `migration_conflict`, `retry_exhausted`
- `action_content_kind`: `review`, `listing`, `ads`, `request`, `group`, `advisory`, `historical`
- `action_capability`: `post_reply`, `post_batch`, `apply_listing_changes`, `update_promo_text`, `create_locale`, `update_description`, `update_short_description`, `revert_experiment`, `aso_revert_listing`, `review_catch_up_30d`, `generate_review_analysis`, `asa_pause_campaign`, `asa_enable_campaign`, `asa_update_campaign_budget`, `asa_update_keyword_bid`, `asa_create_keyword`, `asa_add_negative_keyword`, `asa_delete_negative_keyword`, `draft_locale`, `draft_listing`, `wake_agent`, `propose_experiment`, `flag_issue`, `escalate`, `optimize_keywords`, `improve_retention`, `adjust_monetization`, `update_store_listing`, `review_finding`, `aso_review_needed`, `agent_attention_needed`, `onboarding_audit_recommendation`, `connect_source`, `store_app_access_lost`, `historical_unsupported`
- `action_store`: `ios`, `android`
- `action_reply_mode`: `send`, `update`
- `action_match_type`: `EXACT`, `BROAD`
- `action_request_kind`: `locale_hypothesis`, `listing_hypothesis`, `review_catch_up`, `review_analysis`, `agent_wake`, `experiment_proposal`, `escalation`
- `action_publication_mode`: `manual`, `policy`
- `action_relation`: `member`, `derived_from`, `depends_on`, `supersedes`, `executes_for`
- `action_actor_kind`: `user`, `agent`, `system`, `historical_unknown`
- `action_system_actor`: `scheduler`, `worker`, `reconciler`, `migration`
- `action_event_type`: `command_accepted`, `created`, `imported`, `revised`, `assigned`, `iteration_requested`, `iteration_completed`, `approved`, `approval_undone`, `rejected`, `snoozed`, `unsnoozed`, `archived`, `reopened`, `resolved`, `retry_requested`, `dispatch_started`, `provider_step_started`, `provider_acknowledged`, `provider_uncertain`, `provider_observed`
- `action_command_type`: `stage`, `revise`, `assign`, `adopt_children`, `request_iteration`, `approve`, `undo_approval`, `reject`, `snooze`, `unsnooze`, `archive`, `reopen`, `resolve_advisory`, `retry_execution`, `record_outcome`, `record_verification`, `import_history`
- `action_command_result`: `accepted`, `no_change`
- `action_authorization_mode`: `human`, `policy`, `imported_unproven`
- `action_provider`: `app_store_connect`, `google_play`, `apple_search_ads`, `fload`
- `action_observation_surface`: `provider_response`, `editable_listing`, `live_listing`, `review_response`, `advertising_resource`, `internal_artifact`
- `action_observation_availability`: `complete`, `partial`, `unavailable`
- `action_observation_verdict`: `matched`, `mismatched`, `absent`, `unverifiable`
- `action_provider_step`: `write`, `delete_existing_reply`, `create_replacement_reply`
- `action_import_source`: `pending_action`, `agent_request`, `agent_request_event`, `review_draft_reply`, `review_draft_rejection`, `inbox_item_state`, `capability_execution`, `pending_action_batch`, `review_draft_batch`, `agent_activity`
- `action_job_kind`: `execute`, `generate`, `verify`
- `action_job_state`: `ready`, `leased`, `dispatching`, `uncertain`, `settled`, `cancelled`
- `action_job_outcome`: `acknowledged`, `verified`, `no_effect`, `failed`, `unverifiable`
- `action_recovery_policy`: `native_idempotency`, `readback_before_retry`, `manual_resolution`, `internal_idempotent`
