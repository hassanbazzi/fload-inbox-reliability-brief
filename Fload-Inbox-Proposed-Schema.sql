-- Fload inbox — proposed structural schema, 15 September 2026.
-- NOT A MIGRATION. Do not run against the application database.
-- Creates target tables for design review. Existing pending_action/inbox_item_state
-- must be evolved by a separately generated and tested Drizzle migration.
-- Requires existing domain tables in the search path; external ownership guards,
-- RLS policies/grants, data backfill, command transaction guards and cutover are not implemented here.
-- No JSON / JSONB / serialized metadata columns.

CREATE TYPE "action_kind" AS ENUM ('execution', 'generation', 'group', 'advisory', 'historical');
CREATE TYPE "action_state" AS ENUM ('open', 'revising', 'authorized', 'rejected', 'cancelled', 'superseded', 'resolved');
CREATE TYPE "action_resolution" AS ENUM ('acknowledged', 'delivered', 'verified_editable', 'verified_live', 'measured', 'satisfied_externally', 'failed');
CREATE TYPE "action_priority" AS ENUM ('low', 'medium', 'high');
CREATE TYPE "action_blocker" AS ENUM ('prerequisite', 'permission', 'provider_conflict', 'uncertain_write', 'unsupported_history', 'migration_conflict', 'retry_exhausted');
CREATE TYPE "action_content_kind" AS ENUM ('review', 'listing', 'ads', 'request', 'group', 'advisory', 'historical');
CREATE TYPE "action_capability" AS ENUM ('post_reply', 'post_batch', 'apply_listing_changes', 'update_promo_text', 'create_locale', 'update_description', 'update_short_description', 'revert_experiment', 'aso_revert_listing', 'review_catch_up_30d', 'generate_review_analysis', 'asa_pause_campaign', 'asa_enable_campaign', 'asa_update_campaign_budget', 'asa_update_keyword_bid', 'asa_create_keyword', 'asa_add_negative_keyword', 'asa_delete_negative_keyword', 'draft_locale', 'draft_listing', 'wake_agent', 'propose_experiment', 'flag_issue', 'escalate', 'optimize_keywords', 'improve_retention', 'adjust_monetization', 'update_store_listing', 'review_finding', 'aso_review_needed', 'agent_attention_needed', 'onboarding_audit_recommendation', 'connect_source', 'store_app_access_lost', 'historical_unsupported');
CREATE TYPE "action_store" AS ENUM ('ios', 'android');
CREATE TYPE "action_reply_mode" AS ENUM ('send', 'update');
CREATE TYPE "action_match_type" AS ENUM ('EXACT', 'BROAD');
CREATE TYPE "action_request_kind" AS ENUM ('locale_hypothesis', 'listing_hypothesis', 'review_catch_up', 'review_analysis', 'agent_wake', 'experiment_proposal', 'escalation');
CREATE TYPE "action_publication_mode" AS ENUM ('manual', 'policy');
CREATE TYPE "action_relation" AS ENUM ('member', 'derived_from', 'depends_on', 'supersedes', 'executes_for');
CREATE TYPE "action_actor_kind" AS ENUM ('user', 'agent', 'system', 'historical_unknown');
CREATE TYPE "action_system_actor" AS ENUM ('scheduler', 'worker', 'reconciler', 'migration');
CREATE TYPE "action_event_type" AS ENUM ('command_accepted', 'created', 'imported', 'revised', 'assigned', 'iteration_requested', 'iteration_completed', 'approved', 'approval_undone', 'rejected', 'snoozed', 'unsnoozed', 'archived', 'reopened', 'resolved', 'retry_requested', 'dispatch_started', 'provider_step_started', 'provider_acknowledged', 'provider_uncertain', 'provider_observed');
CREATE TYPE "action_command_type" AS ENUM ('stage', 'revise', 'assign', 'adopt_children', 'request_iteration', 'approve', 'undo_approval', 'reject', 'snooze', 'unsnooze', 'archive', 'reopen', 'resolve_advisory', 'retry_execution', 'record_outcome', 'record_verification', 'import_history');
CREATE TYPE "action_command_result" AS ENUM ('accepted', 'no_change');
CREATE TYPE "action_authorization_mode" AS ENUM ('human', 'policy', 'imported_unproven');
CREATE TYPE "action_provider" AS ENUM ('app_store_connect', 'google_play', 'apple_search_ads', 'fload');
CREATE TYPE "action_observation_surface" AS ENUM ('provider_response', 'editable_listing', 'live_listing', 'review_response', 'advertising_resource', 'internal_artifact');
CREATE TYPE "action_observation_availability" AS ENUM ('complete', 'partial', 'unavailable');
CREATE TYPE "action_observation_verdict" AS ENUM ('matched', 'mismatched', 'absent', 'unverifiable');
CREATE TYPE "action_provider_step" AS ENUM ('write', 'delete_existing_reply', 'create_replacement_reply');
CREATE TYPE "action_import_source" AS ENUM ('pending_action', 'agent_request', 'agent_request_event', 'review_draft_reply', 'review_draft_rejection', 'inbox_item_state', 'capability_execution', 'pending_action_batch', 'review_draft_batch', 'agent_activity');
CREATE TYPE "action_job_kind" AS ENUM ('execute', 'generate', 'verify');
CREATE TYPE "action_job_state" AS ENUM ('ready', 'leased', 'dispatching', 'uncertain', 'settled', 'cancelled');
CREATE TYPE "action_job_outcome" AS ENUM ('acknowledged', 'verified', 'no_effect', 'failed', 'unverifiable');
CREATE TYPE "action_recovery_policy" AS ENUM ('native_idempotency', 'readback_before_retry', 'manual_resolution', 'internal_idempotent');

-- Evolve pending_action — The permanent ticket and its current organization-shared decision.
CREATE TABLE "action" (
  "id" text NOT NULL,
  "organization_id" text NOT NULL,
  "asset_id" text,
  "kind" action_kind NOT NULL,
  "capability" action_capability NOT NULL,
  "capability_version" integer NOT NULL DEFAULT 1,
  "version" bigint NOT NULL DEFAULT 1,
  "event_sequence" bigint NOT NULL DEFAULT 0,
  "current_revision_id" text NOT NULL,
  "current_authorization_event_id" text,
  "assigned_to_user_id" text,
  "state" action_state NOT NULL DEFAULT 'open',
  "resolution" action_resolution,
  "priority" action_priority NOT NULL DEFAULT 'medium',
  "blocker_code" action_blocker,
  "blocked_by_action_id" text,
  "next_check_at" timestamptz,
  "snoozed_until" timestamptz,
  "archived_at" timestamptz,
  "membership_frozen_at" timestamptz,
  "created_at" timestamptz NOT NULL DEFAULT clock_timestamp(),
  "updated_at" timestamptz NOT NULL DEFAULT clock_timestamp(),
  "deleted_at" timestamptz,
  CONSTRAINT "action_pk" PRIMARY KEY ("id"),
  CONSTRAINT "action_org_id_uq" UNIQUE ("organization_id", "id"),
  CONSTRAINT "action_org_id_capability_uq" UNIQUE ("organization_id", "id", "capability"),
  CONSTRAINT "action_versions_ck" CHECK (version > 0 AND event_sequence >= 0 AND capability_version > 0),
  CONSTRAINT "action_resolution_ck" CHECK ((state = 'resolved') = (resolution IS NOT NULL)),
  CONSTRAINT "action_batch_freeze_ck" CHECK (membership_frozen_at IS NULL OR kind = 'group'),
  CONSTRAINT "action_dependency_ck" CHECK (blocked_by_action_id IS NULL OR blocked_by_action_id <> id)
 );

-- Add — Every immutable proposal, using explicit columns for each closed content variant.
CREATE TABLE "action_revision" (
  "id" text NOT NULL,
  "organization_id" text NOT NULL,
  "action_id" text NOT NULL,
  "revision_number" integer NOT NULL,
  "content_kind" action_content_kind NOT NULL,
  "operation" action_capability NOT NULL,
  "schema_version" integer NOT NULL DEFAULT 1,
  "canonicalization_version" integer NOT NULL DEFAULT 1,
  "title" text NOT NULL,
  "reason" text NOT NULL,
  "instructions" text,
  "content_digest" char(64) NOT NULL,
  "created_by_event_id" text NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT clock_timestamp(),
  "store" action_store,
  "connector_id" text,
  "provider_app_id" text,
  "expected_provider_version" text,
  "review_id" text,
  "reply_mode" action_reply_mode,
  "reply_text" text,
  "expected_response_id" text,
  "original_ai_reply" text,
  "generation_model" text,
  "detected_language" text,
  "prompt_tokens" integer,
  "completion_tokens" integer,
  "total_tokens" integer,
  "locale" text,
  "source_snapshot_captured_at" timestamptz,
  "experiment_id" text,
  "before_title" text,
  "before_title_known" boolean,
  "after_title" text,
  "before_subtitle" text,
  "before_subtitle_known" boolean,
  "after_subtitle" text,
  "before_description" text,
  "before_description_known" boolean,
  "after_description" text,
  "before_short_description" text,
  "before_short_description_known" boolean,
  "after_short_description" text,
  "before_keywords" text,
  "before_keywords_known" boolean,
  "after_keywords" text,
  "before_promotional_text" text,
  "before_promotional_text_known" boolean,
  "after_promotional_text" text,
  "before_whats_new" text,
  "before_whats_new_known" boolean,
  "after_whats_new" text,
  "before_support_url" text,
  "before_support_url_known" boolean,
  "after_support_url" text,
  "ads_account_id" text,
  "campaign_id" text,
  "ad_group_id" text,
  "keyword_id" text,
  "negative_keyword_id" text,
  "keyword_text" text,
  "match_type" action_match_type,
  "daily_budget" numeric(20,6),
  "bid_amount" numeric(20,6),
  "currency_code" char(3),
  "before_enabled" boolean,
  "before_daily_budget" numeric(20,6),
  "before_bid_amount" numeric(20,6),
  "request_kind" action_request_kind,
  "target_agent_id" text,
  "source_agent_request_id" text,
  "source_agent_run_id" text,
  "review_window_days" integer,
  "publication_mode" action_publication_mode,
  "generation_policy_version" integer,
  "scope_text" text,
  "target_locales" text[],
  "source_listing_revision_id" text,
  CONSTRAINT "action_revision_pk" PRIMARY KEY ("id"),
  CONSTRAINT "action_revision_org_id_uq" UNIQUE ("organization_id", "id"),
  CONSTRAINT "action_revision_owner_id_uq" UNIQUE ("organization_id", "action_id", "id"),
  CONSTRAINT "action_revision_number_uq" UNIQUE ("organization_id", "action_id", "revision_number"),
  CONSTRAINT "action_revision_versions_ck" CHECK (revision_number > 0 AND schema_version > 0 AND canonicalization_version > 0),
  CONSTRAINT "action_revision_digest_ck" CHECK (content_digest ~ '^[0-9a-f]{64}$'),
  CONSTRAINT "action_revision_review_only_ck" CHECK (content_kind = 'review' OR (review_id IS NULL AND reply_mode IS NULL AND reply_text IS NULL AND expected_response_id IS NULL AND original_ai_reply IS NULL AND generation_model IS NULL AND detected_language IS NULL AND prompt_tokens IS NULL AND completion_tokens IS NULL AND total_tokens IS NULL)),
  CONSTRAINT "action_revision_listing_only_ck" CHECK (content_kind = 'listing' OR (locale IS NULL AND source_snapshot_captured_at IS NULL AND experiment_id IS NULL AND before_title IS NULL AND before_title_known IS NULL AND after_title IS NULL AND before_subtitle IS NULL AND before_subtitle_known IS NULL AND after_subtitle IS NULL AND before_description IS NULL AND before_description_known IS NULL AND after_description IS NULL AND before_short_description IS NULL AND before_short_description_known IS NULL AND after_short_description IS NULL AND before_keywords IS NULL AND before_keywords_known IS NULL AND after_keywords IS NULL AND before_promotional_text IS NULL AND before_promotional_text_known IS NULL AND after_promotional_text IS NULL AND before_whats_new IS NULL AND before_whats_new_known IS NULL AND after_whats_new IS NULL AND before_support_url IS NULL AND before_support_url_known IS NULL AND after_support_url IS NULL)),
  CONSTRAINT "action_revision_ads_only_ck" CHECK (content_kind = 'ads' OR (ads_account_id IS NULL AND campaign_id IS NULL AND ad_group_id IS NULL AND keyword_id IS NULL AND negative_keyword_id IS NULL AND keyword_text IS NULL AND match_type IS NULL AND daily_budget IS NULL AND bid_amount IS NULL AND currency_code IS NULL AND before_enabled IS NULL AND before_daily_budget IS NULL AND before_bid_amount IS NULL)),
  CONSTRAINT "action_revision_request_only_ck" CHECK (content_kind = 'request' OR (request_kind IS NULL AND target_agent_id IS NULL AND source_agent_request_id IS NULL AND source_agent_run_id IS NULL AND review_window_days IS NULL AND publication_mode IS NULL AND generation_policy_version IS NULL AND scope_text IS NULL AND target_locales IS NULL AND source_listing_revision_id IS NULL)),
  CONSTRAINT "action_revision_review_required_ck" CHECK (content_kind <> 'review' OR (review_id IS NOT NULL AND reply_mode IS NOT NULL AND reply_text IS NOT NULL AND store IS NOT NULL AND provider_app_id IS NOT NULL)),
  CONSTRAINT "action_revision_reply_update_ck" CHECK (reply_mode IS DISTINCT FROM 'update' OR expected_response_id IS NOT NULL),
  CONSTRAINT "action_revision_listing_required_ck" CHECK (content_kind <> 'listing' OR (store IS NOT NULL AND locale IS NOT NULL AND provider_app_id IS NOT NULL AND before_title_known IS NOT NULL AND before_subtitle_known IS NOT NULL AND before_description_known IS NOT NULL AND before_short_description_known IS NOT NULL AND before_keywords_known IS NOT NULL AND before_promotional_text_known IS NOT NULL AND before_whats_new_known IS NOT NULL AND before_support_url_known IS NOT NULL)),
  CONSTRAINT "action_revision_listing_after_ck" CHECK (content_kind <> 'listing' OR (after_title IS NOT NULL OR after_subtitle IS NOT NULL OR after_description IS NOT NULL OR after_short_description IS NOT NULL OR after_keywords IS NOT NULL OR after_promotional_text IS NOT NULL OR after_whats_new IS NOT NULL OR after_support_url IS NOT NULL)),
  CONSTRAINT "action_revision_title_before_ck" CHECK (before_title IS NULL OR before_title_known IS TRUE),
  CONSTRAINT "action_revision_subtitle_before_ck" CHECK (before_subtitle IS NULL OR before_subtitle_known IS TRUE),
  CONSTRAINT "action_revision_description_before_ck" CHECK (before_description IS NULL OR before_description_known IS TRUE),
  CONSTRAINT "action_revision_short_description_before_ck" CHECK (before_short_description IS NULL OR before_short_description_known IS TRUE),
  CONSTRAINT "action_revision_keywords_before_ck" CHECK (before_keywords IS NULL OR before_keywords_known IS TRUE),
  CONSTRAINT "action_revision_promotional_text_before_ck" CHECK (before_promotional_text IS NULL OR before_promotional_text_known IS TRUE),
  CONSTRAINT "action_revision_whats_new_before_ck" CHECK (before_whats_new IS NULL OR before_whats_new_known IS TRUE),
  CONSTRAINT "action_revision_support_url_before_ck" CHECK (before_support_url IS NULL OR before_support_url_known IS TRUE),
  CONSTRAINT "action_revision_ads_required_ck" CHECK (content_kind <> 'ads' OR (ads_account_id IS NOT NULL AND campaign_id IS NOT NULL)),
  CONSTRAINT "action_revision_money_ck" CHECK ((daily_budget IS NULL OR daily_budget >= 0) AND (bid_amount IS NULL OR bid_amount >= 0) AND (currency_code IS NULL OR currency_code ~ '^[A-Z]{3}$')),
  CONSTRAINT "action_revision_request_required_ck" CHECK (content_kind <> 'request' OR request_kind IS NOT NULL),
  CONSTRAINT "action_revision_window_ck" CHECK (review_window_days IS NULL OR review_window_days BETWEEN 7 AND 180),
  CONSTRAINT "action_revision_locales_ck" CHECK (target_locales IS NULL OR (cardinality(target_locales) > 0 AND array_position(target_locales,NULL) IS NULL)),
  CONSTRAINT "action_revision_generation_counts_ck" CHECK ((prompt_tokens IS NULL OR prompt_tokens >= 0) AND (completion_tokens IS NULL OR completion_tokens >= 0) AND (total_tokens IS NULL OR total_tokens >= 0)),
  CONSTRAINT "action_revision_review_operation_ck" CHECK (content_kind <> 'review' OR operation IN ('post_reply')),
  CONSTRAINT "action_revision_listing_operation_ck" CHECK (content_kind <> 'listing' OR operation IN ('apply_listing_changes', 'update_promo_text', 'create_locale', 'update_description', 'update_short_description', 'revert_experiment', 'aso_revert_listing')),
  CONSTRAINT "action_revision_ads_operation_ck" CHECK (content_kind <> 'ads' OR operation IN ('asa_pause_campaign', 'asa_enable_campaign', 'asa_update_campaign_budget', 'asa_update_keyword_bid', 'asa_create_keyword', 'asa_add_negative_keyword', 'asa_delete_negative_keyword')),
  CONSTRAINT "action_revision_request_operation_ck" CHECK (content_kind <> 'request' OR operation IN ('draft_locale', 'draft_listing', 'review_catch_up_30d', 'generate_review_analysis', 'wake_agent', 'propose_experiment', 'escalate')),
  CONSTRAINT "action_revision_group_operation_ck" CHECK (content_kind <> 'group' OR operation IN ('post_batch', 'apply_listing_changes', 'revert_experiment', 'aso_revert_listing', 'asa_update_keyword_bid', 'draft_locale', 'draft_listing', 'review_catch_up_30d')),
  CONSTRAINT "action_revision_advisory_operation_ck" CHECK (content_kind <> 'advisory' OR operation IN ('flag_issue', 'escalate', 'optimize_keywords', 'improve_retention', 'adjust_monetization', 'update_store_listing', 'review_finding', 'aso_review_needed', 'agent_attention_needed', 'onboarding_audit_recommendation', 'connect_source', 'store_app_access_lost')),
  CONSTRAINT "action_revision_historical_operation_ck" CHECK (content_kind <> 'historical' OR operation IN ('historical_unsupported')),
  CONSTRAINT "action_revision_store_target_ck" CHECK (content_kind IN ('review','listing') OR store IS NULL),
  CONSTRAINT "action_revision_provider_target_ck" CHECK (content_kind IN ('review','listing','ads') OR (connector_id IS NULL AND provider_app_id IS NULL AND expected_provider_version IS NULL)),
  CONSTRAINT "action_revision_android_fields_ck" CHECK (content_kind <> 'listing' OR store <> 'android' OR (after_subtitle IS NULL AND after_keywords IS NULL AND after_promotional_text IS NULL AND after_whats_new IS NULL AND after_support_url IS NULL)),
  CONSTRAINT "action_revision_ios_fields_ck" CHECK (content_kind <> 'listing' OR store <> 'ios' OR after_short_description IS NULL),
  CONSTRAINT "action_revision_update_promo_text_fields_ck" CHECK (operation <> 'update_promo_text' OR (store = 'ios' AND after_promotional_text IS NOT NULL AND after_title IS NULL AND after_subtitle IS NULL AND after_description IS NULL AND after_short_description IS NULL AND after_keywords IS NULL AND after_whats_new IS NULL AND after_support_url IS NULL)),
  CONSTRAINT "action_revision_update_description_fields_ck" CHECK (operation <> 'update_description' OR (store = 'android' AND after_description IS NOT NULL AND after_title IS NULL AND after_subtitle IS NULL AND after_short_description IS NULL AND after_keywords IS NULL AND after_promotional_text IS NULL AND after_whats_new IS NULL AND after_support_url IS NULL)),
  CONSTRAINT "action_revision_update_short_description_fields_ck" CHECK (operation <> 'update_short_description' OR (store = 'android' AND after_short_description IS NOT NULL AND after_title IS NULL AND after_subtitle IS NULL AND after_description IS NULL AND after_keywords IS NULL AND after_promotional_text IS NULL AND after_whats_new IS NULL AND after_support_url IS NULL)),
  CONSTRAINT "action_revision_create_locale_fields_ck" CHECK (operation <> 'create_locale' OR (after_title IS NOT NULL AND after_description IS NOT NULL)),
  CONSTRAINT "action_revision_asa_pause_campaign_shape_ck" CHECK (content_kind <> 'ads' OR operation <> 'asa_pause_campaign' OR (ad_group_id IS NULL AND keyword_id IS NULL AND negative_keyword_id IS NULL AND keyword_text IS NULL AND match_type IS NULL AND daily_budget IS NULL AND bid_amount IS NULL AND currency_code IS NULL AND before_daily_budget IS NULL AND before_bid_amount IS NULL)),
  CONSTRAINT "action_revision_asa_enable_campaign_shape_ck" CHECK (content_kind <> 'ads' OR operation <> 'asa_enable_campaign' OR (ad_group_id IS NULL AND keyword_id IS NULL AND negative_keyword_id IS NULL AND keyword_text IS NULL AND match_type IS NULL AND daily_budget IS NULL AND bid_amount IS NULL AND currency_code IS NULL AND before_daily_budget IS NULL AND before_bid_amount IS NULL)),
  CONSTRAINT "action_revision_asa_update_campaign_budget_shape_ck" CHECK (content_kind <> 'ads' OR operation <> 'asa_update_campaign_budget' OR (daily_budget IS NOT NULL AND currency_code IS NOT NULL AND ad_group_id IS NULL AND keyword_id IS NULL AND negative_keyword_id IS NULL AND keyword_text IS NULL AND match_type IS NULL AND bid_amount IS NULL AND before_enabled IS NULL AND before_bid_amount IS NULL)),
  CONSTRAINT "action_revision_asa_update_keyword_bid_shape_ck" CHECK (content_kind <> 'ads' OR operation <> 'asa_update_keyword_bid' OR (ad_group_id IS NOT NULL AND keyword_id IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL AND negative_keyword_id IS NULL AND keyword_text IS NULL AND match_type IS NULL AND daily_budget IS NULL AND before_enabled IS NULL AND before_daily_budget IS NULL)),
  CONSTRAINT "action_revision_asa_create_keyword_shape_ck" CHECK (content_kind <> 'ads' OR operation <> 'asa_create_keyword' OR (ad_group_id IS NOT NULL AND keyword_text IS NOT NULL AND match_type IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL AND keyword_id IS NULL AND negative_keyword_id IS NULL AND daily_budget IS NULL AND before_enabled IS NULL AND before_daily_budget IS NULL AND before_bid_amount IS NULL)),
  CONSTRAINT "action_revision_asa_add_negative_keyword_shape_ck" CHECK (content_kind <> 'ads' OR operation <> 'asa_add_negative_keyword' OR (keyword_text IS NOT NULL AND match_type IS NOT NULL AND keyword_id IS NULL AND negative_keyword_id IS NULL AND daily_budget IS NULL AND bid_amount IS NULL AND currency_code IS NULL AND before_enabled IS NULL AND before_daily_budget IS NULL AND before_bid_amount IS NULL)),
  CONSTRAINT "action_revision_asa_delete_negative_keyword_shape_ck" CHECK (content_kind <> 'ads' OR operation <> 'asa_delete_negative_keyword' OR (negative_keyword_id IS NOT NULL AND ad_group_id IS NULL AND keyword_id IS NULL AND keyword_text IS NULL AND match_type IS NULL AND daily_budget IS NULL AND bid_amount IS NULL AND currency_code IS NULL AND before_enabled IS NULL AND before_daily_budget IS NULL AND before_bid_amount IS NULL))
 );

-- Add — Immutable parent/child and batch revision links.
CREATE TABLE "action_link" (
  "id" text NOT NULL,
  "organization_id" text NOT NULL,
  "source_action_id" text NOT NULL,
  "source_revision_id" text,
  "target_action_id" text NOT NULL,
  "target_revision_id" text,
  "relation" action_relation NOT NULL,
  "position" integer,
  "created_by_event_id" text NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT clock_timestamp(),
  CONSTRAINT "action_link_pk" PRIMARY KEY ("id"),
  CONSTRAINT "action_link_org_id_uq" UNIQUE ("organization_id", "id"),
  CONSTRAINT "action_link_target_revision_id_uq" UNIQUE ("organization_id", "target_action_id", "target_revision_id", "id"),
  CONSTRAINT "action_link_not_self_ck" CHECK (source_action_id <> target_action_id),
  CONSTRAINT "action_link_member_ck" CHECK ((relation = 'member' AND source_revision_id IS NOT NULL AND target_revision_id IS NOT NULL AND position IS NOT NULL AND position >= 0) OR (relation <> 'member' AND position IS NULL))
 );

-- Add — Immutable actor history, command receipts, exact approvals and provider evidence.
CREATE TABLE "action_event" (
  "id" text NOT NULL,
  "organization_id" text NOT NULL,
  "action_id" text NOT NULL,
  "sequence" bigint NOT NULL,
  "action_version" bigint NOT NULL,
  "event_type" action_event_type NOT NULL,
  "command_event_id" text,
  "command_type" action_command_type,
  "idempotency_key" text,
  "request_digest" char(64),
  "result_code" action_command_result,
  "revision_id" text,
  "member_link_id" text,
  "job_id" text,
  "actor_kind" action_actor_kind NOT NULL,
  "actor_subject_id" text NOT NULL,
  "actor_user_id" text,
  "actor_agent_id" text,
  "system_actor" action_system_actor,
  "initiated_by_user_id" text,
  "actor_label_at_time" text,
  "authorization_mode" action_authorization_mode,
  "policy_version" integer,
  "undo_until" timestamptz,
  "previous_owner_user_id" text,
  "new_owner_user_id" text,
  "reason" text,
  "occurred_at" timestamptz NOT NULL DEFAULT clock_timestamp(),
  "provider" action_provider,
  "connector_id" text,
  "provider_request_id" text,
  "provider_resource_id" text,
  "provider_version" text,
  "provider_step" action_provider_step,
  "observed_at" timestamptz,
  "expected_digest" char(64),
  "observed_digest" char(64),
  "comparison_version" integer,
  "observation_surface" action_observation_surface,
  "availability" action_observation_availability,
  "verdict" action_observation_verdict,
  "observed_reply_text" text,
  "agent_run_id" text,
  "review_analysis_id" text,
  "experiment_id" text,
  "capability_execution_id" text,
  "import_source" action_import_source,
  "import_source_id" text,
  "imported_type_label" text,
  "imported_status_label" text,
  CONSTRAINT "action_event_pk" PRIMARY KEY ("id"),
  CONSTRAINT "action_event_org_id_uq" UNIQUE ("organization_id", "id"),
  CONSTRAINT "action_event_owner_id_uq" UNIQUE ("organization_id", "action_id", "id"),
  CONSTRAINT "action_event_revision_id_uq" UNIQUE ("organization_id", "action_id", "revision_id", "id"),
  CONSTRAINT "action_event_sequence_uq" UNIQUE ("organization_id", "action_id", "sequence"),
  CONSTRAINT "action_event_sequence_ck" CHECK (sequence > 0 AND action_version > 0),
  CONSTRAINT "action_event_command_receipt_ck" CHECK ((event_type = 'command_accepted' AND command_event_id IS NULL AND command_type IS NOT NULL AND idempotency_key IS NOT NULL AND request_digest IS NOT NULL AND result_code IS NOT NULL) OR (event_type <> 'command_accepted' AND command_type IS NULL AND idempotency_key IS NULL AND request_digest IS NULL AND result_code IS NULL)),
  CONSTRAINT "action_event_approval_ck" CHECK ((event_type = 'approved' AND revision_id IS NOT NULL AND authorization_mode IS NOT NULL AND undo_until IS NOT NULL AND undo_until >= occurred_at) OR (event_type <> 'approved' AND authorization_mode IS NULL AND policy_version IS NULL AND undo_until IS NULL)),
  CONSTRAINT "action_event_policy_ck" CHECK (authorization_mode IS DISTINCT FROM 'policy' OR (policy_version IS NOT NULL AND policy_version > 0)),
  CONSTRAINT "action_event_member_approval_ck" CHECK (member_link_id IS NULL OR (event_type = 'approved' AND revision_id IS NOT NULL AND command_event_id IS NOT NULL)),
  CONSTRAINT "action_event_actor_ck" CHECK ((actor_kind = 'user' AND actor_agent_id IS NULL AND system_actor IS NULL) OR (actor_kind = 'agent' AND actor_user_id IS NULL AND system_actor IS NULL) OR (actor_kind = 'system' AND actor_user_id IS NULL AND actor_agent_id IS NULL AND system_actor IS NOT NULL) OR (actor_kind = 'historical_unknown' AND actor_user_id IS NULL AND actor_agent_id IS NULL AND system_actor IS NULL AND event_type = 'imported')),
  CONSTRAINT "action_event_observation_ck" CHECK (event_type <> 'provider_observed' OR (job_id IS NOT NULL AND revision_id IS NOT NULL AND provider IS NOT NULL AND observed_at IS NOT NULL AND comparison_version IS NOT NULL AND comparison_version > 0 AND observation_surface IS NOT NULL AND availability IS NOT NULL AND verdict IS NOT NULL)),
  CONSTRAINT "action_event_match_ck" CHECK (verdict IS DISTINCT FROM 'matched' OR (availability IS NOT DISTINCT FROM 'complete' AND expected_digest IS NOT NULL AND observed_digest IS NOT NULL AND observed_digest = expected_digest)),
  CONSTRAINT "action_event_unavailable_ck" CHECK (availability IS DISTINCT FROM 'unavailable' OR (verdict = 'unverifiable' AND observed_digest IS NULL AND observed_reply_text IS NULL)),
  CONSTRAINT "action_event_import_ck" CHECK ((event_type = 'imported' AND import_source IS NOT NULL AND import_source_id IS NOT NULL) OR (event_type <> 'imported' AND import_source IS NULL AND import_source_id IS NULL AND imported_type_label IS NULL AND imported_status_label IS NULL))
 );

-- Add — Durable effect intent and one execution attempt; queue transport carries this ID.
CREATE TABLE "action_job" (
  "id" text NOT NULL,
  "organization_id" text NOT NULL,
  "action_id" text NOT NULL,
  "revision_id" text NOT NULL,
  "authorization_event_id" text,
  "caused_by_event_id" text NOT NULL,
  "kind" action_job_kind NOT NULL,
  "effect_key" text NOT NULL,
  "attempt_number" integer NOT NULL DEFAULT 1,
  "previous_job_id" text,
  "verifies_job_id" text,
  "state" action_job_state NOT NULL DEFAULT 'ready',
  "outcome" action_job_outcome,
  "available_at" timestamptz NOT NULL,
  "lease_owner" text,
  "lease_epoch" bigint NOT NULL DEFAULT 0,
  "lease_until" timestamptz,
  "dispatch_started_at" timestamptz,
  "provider" action_provider NOT NULL,
  "connector_id" text,
  "provider_resource_key" text NOT NULL,
  "operation_digest" char(64) NOT NULL,
  "provider_idempotency_key" text,
  "recovery_policy" action_recovery_policy NOT NULL,
  "recovery_policy_version" integer NOT NULL DEFAULT 1,
  "created_at" timestamptz NOT NULL DEFAULT clock_timestamp(),
  "completed_at" timestamptz,
  CONSTRAINT "action_job_pk" PRIMARY KEY ("id"),
  CONSTRAINT "action_job_org_id_uq" UNIQUE ("organization_id", "id"),
  CONSTRAINT "action_job_owner_id_uq" UNIQUE ("organization_id", "action_id", "id"),
  CONSTRAINT "action_job_revision_id_uq" UNIQUE ("organization_id", "action_id", "revision_id", "id"),
  CONSTRAINT "action_job_attempt_uq" UNIQUE ("organization_id", "effect_key", "attempt_number"),
  CONSTRAINT "action_job_versions_ck" CHECK (attempt_number > 0 AND lease_epoch >= 0 AND recovery_policy_version > 0),
  CONSTRAINT "action_job_authorization_ck" CHECK (kind = 'verify' OR authorization_event_id IS NOT NULL),
  CONSTRAINT "action_job_verify_ck" CHECK ((kind = 'verify') = (verifies_job_id IS NOT NULL)),
  CONSTRAINT "action_job_finished_ck" CHECK ((state IN ('settled','cancelled')) = (completed_at IS NOT NULL)),
  CONSTRAINT "action_job_outcome_ck" CHECK ((state = 'settled') = (outcome IS NOT NULL)),
  CONSTRAINT "action_job_lease_ck" CHECK ((lease_owner IS NULL) = (lease_until IS NULL)),
  CONSTRAINT "action_job_dispatch_ck" CHECK (state NOT IN ('dispatching','uncertain') OR dispatch_started_at IS NOT NULL),
  CONSTRAINT "action_job_digest_ck" CHECK (operation_digest ~ '^[0-9a-f]{64}$')
 );

-- Evolve inbox_item_state — Only one teammate’s attention; no workflow state.
CREATE TABLE "action_read" (
  "organization_id" text NOT NULL,
  "user_id" text NOT NULL,
  "action_id" text NOT NULL,
  "seen_revision_id" text,
  "seen_event_sequence" bigint NOT NULL DEFAULT 0,
  "explicit_unread_at" timestamptz,
  "updated_at" timestamptz NOT NULL DEFAULT clock_timestamp(),
  CONSTRAINT "action_read_pk" PRIMARY KEY ("organization_id", "user_id", "action_id"),
  CONSTRAINT "action_read_sequence_ck" CHECK (seen_event_sequence >= 0)
 );
ALTER TABLE "action" ADD CONSTRAINT "action_org_fk" FOREIGN KEY ("organization_id") REFERENCES "organization" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action" ADD CONSTRAINT "action_revision_fk" FOREIGN KEY ("organization_id", "id", "current_revision_id") REFERENCES "action_revision" ("organization_id", "action_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action" ADD CONSTRAINT "action_authorization_fk" FOREIGN KEY ("organization_id", "id", "current_authorization_event_id") REFERENCES "action_event" ("organization_id", "action_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action" ADD CONSTRAINT "action_blocked_by_fk" FOREIGN KEY ("organization_id", "blocked_by_action_id") REFERENCES "action" ("organization_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action" ADD CONSTRAINT "action_asset_id_fk" FOREIGN KEY ("asset_id") REFERENCES "asset" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action" ADD CONSTRAINT "action_assigned_to_user_id_fk" FOREIGN KEY ("assigned_to_user_id") REFERENCES "user" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "action_inbox_idx" ON "action" ("organization_id", "state", "priority", "updated_at", "id");
CREATE INDEX "action_asset_idx" ON "action" ("organization_id", "asset_id", "state");
CREATE INDEX "action_blocker_due_idx" ON "action" ("next_check_at") WHERE blocker_code IS NOT NULL;
ALTER TABLE "action" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "action_revision" ADD CONSTRAINT "action_revision_org_fk" FOREIGN KEY ("organization_id") REFERENCES "organization" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_revision" ADD CONSTRAINT "action_revision_action_fk" FOREIGN KEY ("organization_id", "action_id") REFERENCES "action" ("organization_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_revision" ADD CONSTRAINT "action_revision_capability_fk" FOREIGN KEY ("organization_id", "action_id", "operation") REFERENCES "action" ("organization_id", "id", "capability") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_revision" ADD CONSTRAINT "action_revision_author_fk" FOREIGN KEY ("organization_id", "action_id", "created_by_event_id") REFERENCES "action_event" ("organization_id", "action_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_revision" ADD CONSTRAINT "action_revision_source_fk" FOREIGN KEY ("organization_id", "source_listing_revision_id") REFERENCES "action_revision" ("organization_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_revision" ADD CONSTRAINT "action_revision_connector_id_fk" FOREIGN KEY ("connector_id") REFERENCES "data_connector" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_revision" ADD CONSTRAINT "action_revision_review_id_fk" FOREIGN KEY ("review_id") REFERENCES "review" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_revision" ADD CONSTRAINT "action_revision_experiment_id_fk" FOREIGN KEY ("experiment_id") REFERENCES "aso_experiment" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_revision" ADD CONSTRAINT "action_revision_target_agent_id_fk" FOREIGN KEY ("target_agent_id") REFERENCES "agent" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_revision" ADD CONSTRAINT "action_revision_source_agent_request_id_fk" FOREIGN KEY ("source_agent_request_id") REFERENCES "agent_request" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_revision" ADD CONSTRAINT "action_revision_source_agent_run_id_fk" FOREIGN KEY ("source_agent_run_id") REFERENCES "agent_run" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "action_revision_timeline_idx" ON "action_revision" ("organization_id", "action_id", "revision_number");
ALTER TABLE "action_revision" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "action_link" ADD CONSTRAINT "action_link_org_fk" FOREIGN KEY ("organization_id") REFERENCES "organization" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_link" ADD CONSTRAINT "action_link_source_fk" FOREIGN KEY ("organization_id", "source_action_id") REFERENCES "action" ("organization_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_link" ADD CONSTRAINT "action_link_source_revision_fk" FOREIGN KEY ("organization_id", "source_action_id", "source_revision_id") REFERENCES "action_revision" ("organization_id", "action_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_link" ADD CONSTRAINT "action_link_target_fk" FOREIGN KEY ("organization_id", "target_action_id") REFERENCES "action" ("organization_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_link" ADD CONSTRAINT "action_link_target_revision_fk" FOREIGN KEY ("organization_id", "target_action_id", "target_revision_id") REFERENCES "action_revision" ("organization_id", "action_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_link" ADD CONSTRAINT "action_link_creator_fk" FOREIGN KEY ("organization_id", "created_by_event_id") REFERENCES "action_event" ("organization_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
CREATE UNIQUE INDEX "action_link_member_identity_uq" ON "action_link" ("organization_id", "source_revision_id", "target_action_id") WHERE relation = 'member';
CREATE UNIQUE INDEX "action_link_member_position_uq" ON "action_link" ("organization_id", "source_revision_id", "position") WHERE relation = 'member';
CREATE INDEX "action_link_target_idx" ON "action_link" ("organization_id", "target_action_id", "relation");
ALTER TABLE "action_link" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_org_fk" FOREIGN KEY ("organization_id") REFERENCES "organization" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_action_fk" FOREIGN KEY ("organization_id", "action_id") REFERENCES "action" ("organization_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_command_fk" FOREIGN KEY ("organization_id", "command_event_id") REFERENCES "action_event" ("organization_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_revision_fk" FOREIGN KEY ("organization_id", "action_id", "revision_id") REFERENCES "action_revision" ("organization_id", "action_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_member_fk" FOREIGN KEY ("organization_id", "action_id", "revision_id", "member_link_id") REFERENCES "action_link" ("organization_id", "target_action_id", "target_revision_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_job_fk" FOREIGN KEY ("organization_id", "action_id", "job_id") REFERENCES "action_job" ("organization_id", "action_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_actor_user_id_fk" FOREIGN KEY ("actor_user_id") REFERENCES "user" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_actor_agent_id_fk" FOREIGN KEY ("actor_agent_id") REFERENCES "agent" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_initiated_by_user_id_fk" FOREIGN KEY ("initiated_by_user_id") REFERENCES "user" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_previous_owner_user_id_fk" FOREIGN KEY ("previous_owner_user_id") REFERENCES "user" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_new_owner_user_id_fk" FOREIGN KEY ("new_owner_user_id") REFERENCES "user" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_connector_id_fk" FOREIGN KEY ("connector_id") REFERENCES "data_connector" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_agent_run_id_fk" FOREIGN KEY ("agent_run_id") REFERENCES "agent_run" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_review_analysis_id_fk" FOREIGN KEY ("review_analysis_id") REFERENCES "review_analysis" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_experiment_id_fk" FOREIGN KEY ("experiment_id") REFERENCES "aso_experiment" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_event" ADD CONSTRAINT "action_event_capability_execution_id_fk" FOREIGN KEY ("capability_execution_id") REFERENCES "capability_execution" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
CREATE UNIQUE INDEX "action_event_command_uq" ON "action_event" ("organization_id", "actor_kind", "actor_subject_id", "idempotency_key") WHERE event_type = 'command_accepted';
CREATE INDEX "action_event_timeline_idx" ON "action_event" ("organization_id", "action_id", "sequence");
CREATE INDEX "action_event_import_idx" ON "action_event" ("organization_id", "import_source", "import_source_id") WHERE event_type = 'imported';
ALTER TABLE "action_event" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "action_job" ADD CONSTRAINT "action_job_org_fk" FOREIGN KEY ("organization_id") REFERENCES "organization" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_job" ADD CONSTRAINT "action_job_action_fk" FOREIGN KEY ("organization_id", "action_id") REFERENCES "action" ("organization_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_job" ADD CONSTRAINT "action_job_revision_fk" FOREIGN KEY ("organization_id", "action_id", "revision_id") REFERENCES "action_revision" ("organization_id", "action_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_job" ADD CONSTRAINT "action_job_authorization_fk" FOREIGN KEY ("organization_id", "action_id", "revision_id", "authorization_event_id") REFERENCES "action_event" ("organization_id", "action_id", "revision_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_job" ADD CONSTRAINT "action_job_cause_fk" FOREIGN KEY ("organization_id", "caused_by_event_id") REFERENCES "action_event" ("organization_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_job" ADD CONSTRAINT "action_job_previous_job_id_fk" FOREIGN KEY ("organization_id", "action_id", "revision_id", "previous_job_id") REFERENCES "action_job" ("organization_id", "action_id", "revision_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_job" ADD CONSTRAINT "action_job_verifies_job_id_fk" FOREIGN KEY ("organization_id", "action_id", "revision_id", "verifies_job_id") REFERENCES "action_job" ("organization_id", "action_id", "revision_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_job" ADD CONSTRAINT "action_job_connector_id_fk" FOREIGN KEY ("connector_id") REFERENCES "data_connector" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "action_job_due_idx" ON "action_job" ("available_at", "id") WHERE state = 'ready';
CREATE INDEX "action_job_recovery_idx" ON "action_job" ("lease_until", "id") WHERE state IN ('leased','dispatching');
CREATE UNIQUE INDEX "action_job_resource_claim_uq" ON "action_job" ("organization_id", "provider", "provider_resource_key") WHERE kind = 'execute' AND state IN ('leased','dispatching','uncertain');
ALTER TABLE "action_job" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "action_read" ADD CONSTRAINT "action_read_org_fk" FOREIGN KEY ("organization_id") REFERENCES "organization" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_read" ADD CONSTRAINT "action_read_action_fk" FOREIGN KEY ("organization_id", "action_id") REFERENCES "action" ("organization_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_read" ADD CONSTRAINT "action_read_revision_fk" FOREIGN KEY ("organization_id", "action_id", "seen_revision_id") REFERENCES "action_revision" ("organization_id", "action_id", "id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "action_read" ADD CONSTRAINT "action_read_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "user" ("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "action_read_viewer_idx" ON "action_read" ("organization_id", "user_id", "action_id");
ALTER TABLE "action_read" ENABLE ROW LEVEL SECURITY;

CREATE FUNCTION action_reject_history_mutation() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'Immutable Actions history cannot be updated or deleted'; END; $$;
CREATE TRIGGER "action_revision_immutable" BEFORE UPDATE OR DELETE ON "action_revision" FOR EACH ROW EXECUTE FUNCTION action_reject_history_mutation();
CREATE TRIGGER "action_link_immutable" BEFORE UPDATE OR DELETE ON "action_link" FOR EACH ROW EXECUTE FUNCTION action_reject_history_mutation();
CREATE TRIGGER "action_event_immutable" BEFORE UPDATE OR DELETE ON "action_event" FOR EACH ROW EXECUTE FUNCTION action_reject_history_mutation();
