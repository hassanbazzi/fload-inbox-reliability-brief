CREATE SCHEMA "actions";
--> statement-breakpoint
CREATE SCHEMA "app_store_connect";
--> statement-breakpoint
CREATE SCHEMA "apple_ads";
--> statement-breakpoint
CREATE SCHEMA "google_play";
--> statement-breakpoint
CREATE TYPE "actions"."action_alias_namespace" AS ENUM('pending_action', 'pending_action_batch', 'review_draft', 'review_draft_batch', 'agent_request', 'agent_activity', 'review_history', 'review_draft_rejection', 'capability_execution', 'recommendation', 'recommendation_variant', 'recovery_receipt');--> statement-breakpoint
CREATE TYPE "actions"."action_attempt_kind" AS ENUM('write', 'readback', 'generation', 'late_evidence');--> statement-breakpoint
CREATE TYPE "actions"."action_attempt_result" AS ENUM('acknowledged', 'known_not_applied', 'uncertain', 'matched', 'matched_external', 'mismatch', 'unreadable', 'generated', 'discarded');--> statement-breakpoint
CREATE TYPE "actions"."action_authorization_scope" AS ENUM('perform', 'generate', 'revise');--> statement-breakpoint
CREATE TYPE "actions"."action_channel" AS ENUM('web', 'chat', 'mcp', 'api', 'slack', 'discord', 'agent', 'worker', 'operator', 'migration');--> statement-breakpoint
CREATE TYPE "actions"."action_command_error" AS ENUM('stale_version', 'stale_revision', 'stale_membership', 'invalid_transition', 'undo_expired', 'execution_started', 'unresolved_write', 'permission_changed', 'billing_required', 'unsupported_operation', 'idempotency_mismatch', 'target_changed', 'not_found');--> statement-breakpoint
CREATE TYPE "actions"."action_command_kind" AS ENUM('create', 'revise', 'approve', 'undo', 'reject', 'acknowledge', 'snooze', 'unsnooze', 'assign', 'archive', 'restore', 'supersede', 'retry', 'reconcile', 'record_observation', 'record_attempt', 'resolve_dependency', 'resolve_external', 'grant_policy', 'revoke_policy');--> statement-breakpoint
CREATE TYPE "actions"."action_command_outcome" AS ENUM('accepted', 'conflict', 'refused');--> statement-breakpoint
CREATE TYPE "actions"."action_decision" AS ENUM('open', 'approved', 'declined', 'acknowledged', 'handled_externally', 'cancelled', 'superseded');--> statement-breakpoint
CREATE TYPE "actions"."action_dependency_requirement" AS ENUM('completed', 'verified_live', 'verified_editable', 'generated', 'permission_restored', 'release_available');--> statement-breakpoint
CREATE TYPE "actions"."action_execution_phase" AS ENUM('ready', 'claimed', 'verification_due', 'uncertain', 'blocked', 'settled', 'cancelled');--> statement-breakpoint
CREATE TYPE "actions"."action_execution_result" AS ENUM('generated', 'verified_live', 'verified_editable', 'handled_externally', 'acknowledged_only', 'failed', 'cancelled');--> statement-breakpoint
CREATE TYPE "actions"."action_failure_class" AS ENUM('permission', 'rate_limit', 'transport', 'target_changed', 'provider_rejected', 'persistence', 'unsupported_readback', 'invalid_content', 'billing');--> statement-breakpoint
CREATE TYPE "actions"."action_hold_reason" AS ENUM('permission', 'billing', 'resource_busy', 'target_changed', 'uncertain_write', 'retry_exhausted', 'unsupported_readback', 'generation_conflict', 'awaiting_release');--> statement-breakpoint
CREATE TYPE "actions"."action_no_work_reason" AS ENUM('no_eligible_reviews');--> statement-breakpoint
CREATE TYPE "actions"."action_non_application_basis" AS ENUM('pre_dispatch_failure', 'provider_rejection', 'provider_terminal_non_application', 'expired_uncommitted_edit');--> statement-breakpoint
CREATE TYPE "actions"."action_observation_completeness" AS ENUM('complete', 'partial', 'unavailable');--> statement-breakpoint
CREATE TYPE "actions"."action_output_kind" AS ENUM('revision', 'review_analysis', 'agent_run', 'no_work');--> statement-breakpoint
CREATE TYPE "actions"."action_principal" AS ENUM('user', 'api_key', 'agent', 'policy', 'system');--> statement-breakpoint
CREATE TYPE "actions"."action_recovery_mode" AS ENUM('readback_before_retry', 'native_idempotency', 'manual_reconciliation', 'internal_atomic');--> statement-breakpoint
CREATE TYPE "actions"."action_resource_scope" AS ENUM('store_application', 'advertising_account');--> statement-breakpoint
CREATE TYPE "actions"."action_retry_disposition" AS ENUM('retryable', 'permanent');--> statement-breakpoint
CREATE TYPE "actions"."action_revision_purpose" AS ENUM('proposal', 'baseline', 'observation');--> statement-breakpoint
CREATE TYPE "actions"."action_source_kind" AS ENUM('agent_run', 'recommendation', 'recommendation_variant', 'report_version', 'backlog_item', 'experiment', 'action');--> statement-breakpoint
CREATE TYPE "actions"."action_step_kind" AS ENUM('asc_app_info_localization_upsert', 'asc_version_localization_upsert', 'asc_live_promotional_text_set', 'asc_editable_promotional_text_set', 'asc_review_response_upsert', 'asc_app_clip_localization_create', 'asc_app_clip_header_reserve', 'asc_app_clip_header_upload_chunk', 'asc_app_clip_header_commit', 'asc_app_clip_incomplete_header_delete', 'play_edit_create', 'play_listing_set', 'play_edit_commit', 'play_inspection_edit_create', 'play_inspection_edit_delete', 'play_review_response_set', 'asa_campaign_status_set', 'asa_campaign_budget_set', 'asa_keyword_bid_set', 'asa_keyword_create', 'asa_negative_keyword_create', 'asa_negative_keyword_delete', 'internal_generate_content', 'internal_revise_content', 'internal_commit_children', 'internal_recheck_prerequisite');--> statement-breakpoint
CREATE TYPE "actions"."action_surface" AS ENUM('provider_response', 'editable_listing', 'live_listing', 'review_response', 'advertising_resource', 'internal_artifact');--> statement-breakpoint
CREATE TYPE "actions"."action_transport" AS ENUM('asc_api', 'asc_browser', 'play_api', 'play_session', 'play_browser', 'asa_api', 'internal');--> statement-breakpoint
CREATE TYPE "actions"."action_uncertainty_reason" AS ENUM('transport_lost', 'claim_expired', 'invalid_response');--> statement-breakpoint
CREATE TYPE "actions"."action_unreadable_reason" AS ENUM('unavailable', 'partial', 'unsupported');--> statement-breakpoint
CREATE TYPE "actions"."action_verification_timing" AS ENUM('before_successor', 'after_effects');--> statement-breakpoint
CREATE TYPE "apple_ads"."ad_intent" AS ENUM('pause_campaign', 'enable_campaign', 'set_campaign_budget', 'set_keyword_bid', 'create_keyword', 'add_negative_keyword', 'delete_negative_keyword', 'observed');--> statement-breakpoint
CREATE TYPE "apple_ads"."ad_match_type" AS ENUM('EXACT', 'BROAD');--> statement-breakpoint
CREATE TYPE "apple_ads"."ad_observed_status" AS ENUM('ENABLED', 'ACTIVE', 'PAUSED', 'DELETED');--> statement-breakpoint
CREATE TYPE "actions"."advisory_connector_kind" AS ENUM('app_store_connect', 'apple_search_ads');--> statement-breakpoint
CREATE TYPE "actions"."advisory_kind" AS ENUM('optimize_keywords', 'improve_retention', 'adjust_monetization', 'update_store_listing', 'review_finding', 'aso_review_needed', 'agent_attention_needed', 'onboarding_audit_recommendation', 'connect_source', 'store_app_access_lost', 'flag_issue', 'escalate', 'stage_blocker');--> statement-breakpoint
CREATE TYPE "app_store_connect"."app_clip_header_state" AS ENUM('absent', 'incomplete', 'complete', 'unreadable');--> statement-breakpoint
CREATE TYPE "app_store_connect"."app_clip_operation" AS ENUM('none', 'create_localization', 'repair_header', 'observed');--> statement-breakpoint
CREATE TYPE "actions"."approval_setting" AS ENUM('auto', 'await');--> statement-breakpoint
CREATE TYPE "actions"."closed_severity" AS ENUM('low', 'medium', 'high');--> statement-breakpoint
CREATE TYPE "actions"."content_value_state" AS ENUM('unspecified', 'present', 'empty', 'dismissed', 'unreadable');--> statement-breakpoint
CREATE TYPE "actions"."country_role" AS ENUM('demand', 'competitor');--> statement-breakpoint
CREATE TYPE "actions"."gloss_status" AS ENUM('updating', 'ready', 'unavailable');--> statement-breakpoint
CREATE TYPE "actions"."listing_intent" AS ENUM('create', 'update', 'repair', 'restore', 'observed');--> statement-breakpoint
CREATE TYPE "actions"."listing_version_state" AS ENUM('editable', 'in_review', 'processing', 'live', 'rejected', 'removed', 'unreadable');--> statement-breakpoint
CREATE TYPE "actions"."media_availability" AS ENUM('stored', 'missing', 'unreadable');--> statement-breakpoint
CREATE TYPE "actions"."media_display_type" AS ENUM('APP_APPLE_TV', 'APP_APPLE_VISION_PRO', 'APP_DESKTOP', 'APP_IPAD_105', 'APP_IPAD_97', 'APP_IPAD_PRO_129', 'APP_IPAD_PRO_3GEN_11', 'APP_IPAD_PRO_3GEN_129', 'APP_IPHONE_35', 'APP_IPHONE_40', 'APP_IPHONE_47', 'APP_IPHONE_55', 'APP_IPHONE_58', 'APP_IPHONE_61', 'APP_IPHONE_65', 'APP_IPHONE_67', 'APP_WATCH_SERIES_10', 'APP_WATCH_SERIES_3', 'APP_WATCH_SERIES_4', 'APP_WATCH_SERIES_7', 'APP_WATCH_ULTRA', 'phoneScreenshots', 'sevenInchScreenshots');--> statement-breakpoint
CREATE TYPE "actions"."media_kind" AS ENUM('screenshot', 'icon', 'app_preview', 'app_clip_header');--> statement-breakpoint
CREATE TYPE "actions"."media_storage_immutability" AS ENUM('versioned_object', 'content_addressed_immutable');--> statement-breakpoint
CREATE TYPE "actions"."observation_availability" AS ENUM('present', 'absent', 'unreadable', 'pending', 'unknown');--> statement-breakpoint
CREATE TYPE "google_play"."play_commit_policy" AS ENUM('ERROR_IF_IN_REVIEW');--> statement-breakpoint
CREATE TYPE "actions"."prose_section" AS ENUM('what_will_happen', 'supporting_evidence', 'description_outline', 'prioritization', 'notes', 'unblock_steps');--> statement-breakpoint
CREATE TYPE "actions"."recommendation_kind" AS ENUM('keywords', 'promotional_text', 'description', 'screenshots', 'icon', 'app_previews', 'title_subtitle', 'cpp', 'short_description', 'title', 'subtitle', 'locale_expansion');--> statement-breakpoint
CREATE TYPE "actions"."reply_intent" AS ENUM('send', 'update', 'observed');--> statement-breakpoint
CREATE TYPE "actions"."request_intent" AS ENUM('locale_expansion', 'listing_change', 'review_catch_up', 'review_analysis', 'wake_agent');--> statement-breakpoint
CREATE TYPE "actions"."request_origin" AS ENUM('scheduled_agent', 'user_directed_chat_or_mcp', 'human', 'system');--> statement-breakpoint
CREATE TYPE "actions"."research_coverage" AS ENUM('ready', 'cold');--> statement-breakpoint
CREATE TYPE "actions"."review_publication_state" AS ENUM('published', 'pending_publication', 'hidden', 'deleted', 'unreadable');--> statement-breakpoint
CREATE TYPE "actions"."store_kind" AS ENUM('ios', 'android');--> statement-breakpoint
CREATE TYPE "actions"."term_role" AS ENUM('added', 'removed', 'gloss', 'trending');--> statement-breakpoint
CREATE TYPE "app_store_connect"."upload_content_type" AS ENUM('image/png', 'image/jpeg');--> statement-breakpoint
CREATE TYPE "app_store_connect"."upload_method" AS ENUM('PUT');--> statement-breakpoint
CREATE FUNCTION actions.is_supported_store_locale(p_store actions.store_kind,p_locale text)
RETURNS boolean LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$ SELECT CASE p_store
 WHEN 'ios' THEN p_locale IN ('ar-SA','bn-BD','ca','zh-Hans','zh-Hant','hr','cs','da','nl-NL','en-AU','en-CA','en-GB','en-US','fi','fr-FR','fr-CA','de-DE','el','gu-IN','he','hi','hu','id','it','ja','kn-IN','ko','ms','ml-IN','mr-IN','no','or-IN','pl','pt-BR','pt-PT','pa-IN','ro','ru','sk','sl-SI','es-MX','es-ES','sv','ta-IN','te-IN','th','tr','uk','ur-PK','vi')
 WHEN 'android' THEN p_locale IN ('af','am','ar','az-AZ','be','bg','bn-BD','ca','cs-CZ','da-DK','de-DE','el-GR','en-AU','en-CA','en-GB','en-IN','en-SG','en-US','en-ZA','es-419','es-ES','es-US','et','eu-ES','fa','fi-FI','fil','fr-CA','fr-FR','gl-ES','gu','hi-IN','hr','hu-HU','hy-AM','id','is-IS','it-IT','iw-IL','ja-JP','ka-GE','kk','km-KH','kn-IN','ko-KR','ky-KG','lo-LA','lt','lv','mk-MK','ml-IN','mn-MN','mr-IN','ms','ms-MY','my-MM','nb-NO','ne-NP','nl-NL','no-NO','pa','pl-PL','pt-BR','pt-PT','ro','ru-RU','si-LK','sk','sl','sq','sr','sv-SE','sw','ta-IN','te-IN','th','tr-TR','uk','ur','vi','zh-CN','zh-HK','zh-TW','zu')
 END $$;
--> statement-breakpoint
CREATE FUNCTION actions.utf16_length(p_value text)
RETURNS bigint LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
 SELECT coalesce(sum(CASE WHEN ascii(substring(p_value FROM i FOR 1))>65535 THEN 2 ELSE 1 END),0)::bigint
 FROM generate_series(1,length(p_value)) AS n(i)
$$;
--> statement-breakpoint
CREATE FUNCTION actions.is_content_write(p_state actions.content_value_state)
RETURNS boolean LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
 SELECT p_state IN ('present','empty')
$$;

--> statement-breakpoint

--> statement-breakpoint
CREATE TABLE "actions"."action" (
	"id" text NOT NULL,
	"organization_id" text NOT NULL,
	"creation_key" uuid DEFAULT gen_random_uuid() NOT NULL,
	"asset_id" text,
	"domain" text NOT NULL,
	"parent_action_id" text,
	"decision" "actions"."action_decision" DEFAULT 'open'::actions.action_decision NOT NULL,
	"version" bigint DEFAULT 1 NOT NULL,
	"attention_version" bigint DEFAULT 1 NOT NULL,
	"current_revision_id" text,
	"current_approval_id" text,
	"owner_user_id" text,
	"priority" smallint DEFAULT 2 NOT NULL,
	"snoozed_until" timestamp with time zone,
	"archived_at" timestamp with time zone,
	"successor_action_id" text,
	"created_at" timestamp with time zone NOT NULL,
	"updated_at" timestamp with time zone NOT NULL,
	"last_command_id" text NOT NULL,
	CONSTRAINT "action_pkey" PRIMARY KEY("id"),
	CONSTRAINT "action_organization_id_creation_key_key" UNIQUE("organization_id","creation_key"),
	CONSTRAINT "action_organization_id_id_key" UNIQUE("organization_id","id"),
	CONSTRAINT "action_attention_version_check" CHECK (attention_version > 0),
	CONSTRAINT "action_check" CHECK (updated_at >= created_at),
	CONSTRAINT "action_check1" CHECK ((decision = 'superseded'::actions.action_decision) = (successor_action_id IS NOT NULL)),
	CONSTRAINT "action_check2" CHECK (successor_action_id IS DISTINCT FROM id),
	CONSTRAINT "action_check3" CHECK (parent_action_id IS DISTINCT FROM id),
	CONSTRAINT "action_domain_check" CHECK (domain = ANY (ARRAY['reviews'::text, 'listing'::text, 'ads'::text, 'agent'::text, 'advisory'::text, 'collection'::text])),
	CONSTRAINT "action_priority_check" CHECK (priority >= 1 AND priority <= 3),
	CONSTRAINT "action_version_check" CHECK (version > 0)
);
--> statement-breakpoint
ALTER TABLE "actions"."action" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_advisory_content" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"kind" "actions"."advisory_kind" NOT NULL,
	"detail" text,
	"suggestion" text,
	"primary_link_label" text,
	"primary_link_path" text,
	"connector_source_id" text,
	"connector_type" "actions"."advisory_connector_kind",
	"connector_name_snapshot" text,
	"source_label" text,
	"benefit" text,
	"app_name_snapshot" text,
	"bundle_id_snapshot" text,
	"scraping_account_email_snapshot" text,
	"agent_source_id" text,
	"consecutive_failures" bigint,
	"last_success_at" timestamp with time zone,
	"last_error" text,
	"impact" "actions"."closed_severity",
	"effort" "actions"."closed_severity",
	"confidence_label" "actions"."closed_severity",
	"confidence_score" numeric,
	"quick_win_source_id" text,
	"recommendation_type" "actions"."recommendation_kind",
	"market_label" text,
	"gate_text" text,
	"capability_tier" integer,
	"proposed_next_step" text,
	"audit_store" "actions"."store_kind",
	"audit_store_app_id" text,
	"audit_country" text,
	"audit_locale" text,
	"audit_generated_at" timestamp with time zone,
	"blocker_reason_text" text,
	"blocker_reasoning" text,
	"unblock_title" text,
	"unblock_what_happened" text,
	"unblock_why_it_matters" text,
	"unblock_next" text,
	"unblock_cta_label" text,
	"unblock_cta_path" text,
	CONSTRAINT "action_advisory_content_pkey" PRIMARY KEY("organization_id","revision_id"),
	CONSTRAINT "action_advisory_content_capability_tier_check" CHECK (capability_tier >= 1 AND capability_tier <= 3),
	CONSTRAINT "action_advisory_content_consecutive_failures_check" CHECK (consecutive_failures >= 0),
	CONSTRAINT "action_advisory_content_primary_link_path_check" CHECK (primary_link_path IS NULL OR primary_link_path ~ '^/[^/]'::text),
	CONSTRAINT "action_advisory_content_unblock_cta_path_check" CHECK (unblock_cta_path IS NULL OR unblock_cta_path ~ '^/[^/]'::text)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_advisory_content" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_alias" (
	"organization_id" text NOT NULL,
	"namespace" "actions"."action_alias_namespace" NOT NULL,
	"old_id" text NOT NULL,
	"action_id" text NOT NULL,
	"historical_membership_known" boolean NOT NULL,
	CONSTRAINT "action_alias_pkey" PRIMARY KEY("organization_id","namespace","old_id")
);
--> statement-breakpoint
ALTER TABLE "actions"."action_alias" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_approval" (
	"id" text NOT NULL,
	"organization_id" text NOT NULL,
	"action_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"command_id" text NOT NULL,
	"scope" "actions"."action_authorization_scope" NOT NULL,
	"policy_revision_id" text,
	"parent_revision_id" text,
	"undo_deadline" timestamp with time zone NOT NULL,
	"required_surface" "actions"."action_surface" NOT NULL,
	"authorization_version" integer NOT NULL,
	"created_at" timestamp with time zone NOT NULL,
	"revision_instructions" text,
	CONSTRAINT "action_approval_pkey" PRIMARY KEY("id"),
	CONSTRAINT "action_approval_command_id_action_id_key" UNIQUE("command_id","action_id"),
	CONSTRAINT "action_approval_organization_id_action_id_id_key" UNIQUE("organization_id","action_id","id"),
	CONSTRAINT "action_approval_organization_id_id_key" UNIQUE("organization_id","id"),
	CONSTRAINT "action_approval_authorization_version_check" CHECK (authorization_version > 0),
	CONSTRAINT "action_approval_check" CHECK (undo_deadline >= created_at),
	CONSTRAINT "action_approval_revision_instructions" CHECK ((scope = 'revise') = (revision_instructions IS NOT NULL))
);
--> statement-breakpoint
ALTER TABLE "actions"."action_approval" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_command" (
	"id" text NOT NULL,
	"organization_id" text NOT NULL,
	"idempotency_key" uuid NOT NULL,
	"principal_kind" "actions"."action_principal" NOT NULL,
	"actor_user_id" text,
	"actor_api_key_id" text,
	"actor_agent_run_id" text,
	"actor_policy_revision_id" text,
	"target_policy_revision_id" text,
	"actor_subject_snapshot" text NOT NULL,
	"actor_name_snapshot" text,
	"channel" "actions"."action_channel" NOT NULL,
	"external_actor_id" text,
	"kind" "actions"."action_command_kind" NOT NULL,
	"request_digest" char(64) NOT NULL,
	"digest_version" integer NOT NULL,
	"outcome" "actions"."action_command_outcome" NOT NULL,
	"error" "actions"."action_command_error",
	"message" text,
	"accepted_at" timestamp with time zone NOT NULL,
	"actor_slack_integration_id" text,
	"actor_discord_integration_id" text,
	"acting_for_user_id" text,
	CONSTRAINT "action_command_pkey" PRIMARY KEY("id"),
	CONSTRAINT "action_command_organization_id_id_key" UNIQUE("organization_id","id"),
	CONSTRAINT "action_command_organization_id_principal_kind_actor_subject_key" UNIQUE("organization_id","principal_kind","actor_subject_snapshot","idempotency_key"),
	CONSTRAINT "action_command_check" CHECK ((outcome = 'accepted'::actions.action_command_outcome) = (error IS NULL)),
	CONSTRAINT "action_command_check1" CHECK (actor_user_id IS NULL OR principal_kind IN ('user','api_key')),
	CONSTRAINT "action_command_check2" CHECK (actor_api_key_id IS NULL OR principal_kind='api_key'),
	CONSTRAINT "action_command_check3" CHECK ((principal_kind = 'policy'::actions.action_principal) = (actor_policy_revision_id IS NOT NULL)),
	CONSTRAINT "action_command_check4" CHECK (principal_kind <> 'agent'::actions.action_principal OR actor_agent_run_id IS NOT NULL),
	CONSTRAINT "action_command_check5" CHECK (outcome <> 'accepted'::actions.action_command_outcome OR (kind <> ALL (ARRAY['grant_policy'::actions.action_command_kind, 'revoke_policy'::actions.action_command_kind])) OR target_policy_revision_id IS NOT NULL),
	CONSTRAINT "action_command_digest_version_check" CHECK (digest_version > 0),
	CONSTRAINT "action_command_request_digest_check" CHECK (request_digest ~ '^[0-9a-f]{64}$'::text),
	CONSTRAINT "command_delegation_shape" CHECK (acting_for_user_id IS NULL OR principal_kind = 'user'::actions.action_principal AND (channel = ANY (ARRAY['operator'::actions.action_channel, 'web'::actions.action_channel]))),
	CONSTRAINT "command_external_actor_shape" CHECK (channel = 'slack'::actions.action_channel AND principal_kind = 'user'::actions.action_principal AND (external_actor_id IS NOT NULL OR actor_user_id IS NULL) AND actor_slack_integration_id IS NOT NULL AND actor_discord_integration_id IS NULL OR channel = 'discord'::actions.action_channel AND principal_kind = 'user'::actions.action_principal AND (external_actor_id IS NOT NULL OR actor_user_id IS NULL) AND actor_discord_integration_id IS NOT NULL AND actor_slack_integration_id IS NULL OR (channel <> ALL (ARRAY['slack'::actions.action_channel, 'discord'::actions.action_channel])) AND external_actor_id IS NULL AND actor_slack_integration_id IS NULL AND actor_discord_integration_id IS NULL),
	CONSTRAINT "command_policy_target_shape" CHECK ((kind = ANY (ARRAY['grant_policy'::actions.action_command_kind, 'revoke_policy'::actions.action_command_kind])) OR target_policy_revision_id IS NULL),
	CONSTRAINT "command_principal_exclusive" CHECK (principal_kind = 'user'::actions.action_principal AND actor_api_key_id IS NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NULL OR principal_kind = 'api_key'::actions.action_principal AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NULL OR principal_kind = 'agent'::actions.action_principal AND actor_user_id IS NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NOT NULL AND actor_policy_revision_id IS NULL OR principal_kind = 'policy'::actions.action_principal AND actor_user_id IS NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NOT NULL OR principal_kind = 'system'::actions.action_principal AND actor_user_id IS NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NULL),
	CONSTRAINT "command_subject_nonempty" CHECK (length(actor_subject_snapshot) > 0)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_command" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_command_target" (
	"organization_id" text NOT NULL,
	"command_id" text NOT NULL,
	"action_id" text NOT NULL,
	"expected_version" bigint,
	"expected_revision_id" text,
	"expected_parent_revision_id" text,
	"previous_version" bigint,
	"result_version" bigint NOT NULL,
	"previous_decision" "actions"."action_decision",
	"result_decision" "actions"."action_decision" NOT NULL,
	"previous_revision_id" text,
	"result_revision_id" text,
	"previous_owner_user_id" text,
	"result_owner_user_id" text,
	"previous_snoozed_until" timestamp with time zone,
	"result_snoozed_until" timestamp with time zone,
	"previous_archived_at" timestamp with time zone,
	"result_archived_at" timestamp with time zone,
	"previous_approval_id" text,
	"result_approval_id" text,
	"evidence_revision_id" text,
	CONSTRAINT "action_command_target_pkey" PRIMARY KEY("command_id","action_id"),
	CONSTRAINT "action_command_target_organization_id_command_id_action_id_key" UNIQUE("organization_id","command_id","action_id"),
	CONSTRAINT "action_command_target_result_version_check" CHECK (result_version > 0),
	CONSTRAINT "target_positive_versions" CHECK ((expected_version IS NULL OR expected_version > 0) AND (previous_version IS NULL OR previous_version > 0))
);
--> statement-breakpoint
ALTER TABLE "actions"."action_command_target" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_content_note" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"section" "actions"."prose_section" NOT NULL,
	"ordinal" integer NOT NULL,
	"text_content" text NOT NULL,
	CONSTRAINT "action_content_note_pkey" PRIMARY KEY("organization_id","revision_id","section","ordinal"),
	CONSTRAINT "action_content_note_ordinal_check" CHECK (ordinal >= 0)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_content_note" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_content_term" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"role" "actions"."term_role" NOT NULL,
	"ordinal" integer NOT NULL,
	"term" text NOT NULL,
	"meaning" text,
	CONSTRAINT "action_content_term_pkey" PRIMARY KEY("organization_id","revision_id","role","ordinal"),
	CONSTRAINT "action_content_term_check" CHECK (role = 'gloss'::actions.term_role AND meaning IS NOT NULL OR role <> 'gloss'::actions.term_role AND meaning IS NULL),
	CONSTRAINT "action_content_term_ordinal_check" CHECK (ordinal >= 0)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_content_term" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_dependency" (
	"organization_id" text NOT NULL,
	"dependent_action_id" text NOT NULL,
	"prerequisite_action_id" text NOT NULL,
	"requirement" "actions"."action_dependency_requirement" NOT NULL,
	"created_command_id" text NOT NULL,
	CONSTRAINT "action_dependency_pkey" PRIMARY KEY("dependent_action_id","prerequisite_action_id","requirement"),
	CONSTRAINT "action_dependency_check" CHECK (dependent_action_id <> prerequisite_action_id)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_dependency" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_execution" (
	"id" text NOT NULL,
	"organization_id" text NOT NULL,
	"approval_id" text NOT NULL,
	"phase" "actions"."action_execution_phase" NOT NULL,
	"next_run_at" timestamp with time zone,
	"next_step_id" text,
	"schedule_generation" bigint DEFAULT 1 NOT NULL,
	"claim_generation" bigint DEFAULT 0 NOT NULL,
	"claim_token" uuid,
	"claim_expires_at" timestamp with time zone,
	"hold_reason" "actions"."action_hold_reason",
	"result" "actions"."action_execution_result",
	"created_at" timestamp with time zone NOT NULL,
	"settled_at" timestamp with time zone,
	"resource_guard_id" uuid,
	"plan_version" integer NOT NULL,
	"writes_closed_at" timestamp with time zone,
	"cancelled_command_id" text,
	"plan_complete" boolean DEFAULT false NOT NULL,
	CONSTRAINT "action_execution_pkey" PRIMARY KEY("id"),
	CONSTRAINT "action_execution_approval_id_key" UNIQUE("approval_id"),
	CONSTRAINT "action_execution_organization_id_id_key" UNIQUE("organization_id","id"),
	CONSTRAINT "action_execution_cancel_command_shape" CHECK ((phase = 'cancelled'::actions.action_execution_phase) = (cancelled_command_id IS NOT NULL)),
	CONSTRAINT "action_execution_cancelled_result" CHECK ((phase = 'cancelled'::actions.action_execution_phase) = (result = 'cancelled'::actions.action_execution_result)),
	CONSTRAINT "action_execution_check" CHECK ((claim_token IS NULL) = (claim_expires_at IS NULL)),
	CONSTRAINT "action_execution_check1" CHECK ((phase = 'claimed'::actions.action_execution_phase) = (claim_token IS NOT NULL)),
	CONSTRAINT "action_execution_check2" CHECK ((phase = ANY (ARRAY['settled'::actions.action_execution_phase, 'cancelled'::actions.action_execution_phase])) = (settled_at IS NOT NULL)),
	CONSTRAINT "action_execution_check3" CHECK ((phase = ANY (ARRAY['settled'::actions.action_execution_phase, 'cancelled'::actions.action_execution_phase])) = (result IS NOT NULL)),
	CONSTRAINT "action_execution_check4" CHECK ((phase <> ALL (ARRAY['ready'::actions.action_execution_phase, 'verification_due'::actions.action_execution_phase])) OR next_run_at IS NOT NULL),
	CONSTRAINT "action_execution_check5" CHECK ((phase <> ALL (ARRAY['settled'::actions.action_execution_phase, 'cancelled'::actions.action_execution_phase])) OR next_run_at IS NULL),
	CONSTRAINT "action_execution_check6" CHECK (phase <> 'uncertain'::actions.action_execution_phase OR hold_reason = 'uncertain_write'::actions.action_hold_reason),
	CONSTRAINT "action_execution_claim_generation" CHECK (phase <> 'claimed'::actions.action_execution_phase OR claim_generation > 0),
	CONSTRAINT "action_execution_claim_generation_check" CHECK (claim_generation >= 0),
	CONSTRAINT "action_execution_plan_version_check" CHECK (plan_version > 0),
	CONSTRAINT "action_execution_schedule_generation_check" CHECK (schedule_generation > 0),
	CONSTRAINT "action_execution_settlement_time" CHECK (settled_at IS NULL OR settled_at >= created_at),
	CONSTRAINT "action_execution_uncertain_due" CHECK (phase <> 'uncertain'::actions.action_execution_phase OR next_run_at IS NOT NULL),
	CONSTRAINT "action_execution_writes_closed_time" CHECK (writes_closed_at IS NULL OR writes_closed_at >= created_at)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_execution" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_execution_attempt" (
	"id" text NOT NULL,
	"organization_id" text NOT NULL,
	"step_id" text NOT NULL,
	"number" integer NOT NULL,
	"kind" "actions"."action_attempt_kind" NOT NULL,
	"claim_generation" bigint NOT NULL,
	"subject_attempt_id" text,
	"agent_run_id" text,
	"connector_id" text,
	"transport" "actions"."action_transport" NOT NULL,
	"started_at" timestamp with time zone NOT NULL,
	"finished_at" timestamp with time zone,
	"result" "actions"."action_attempt_result",
	"observation_revision_id" text,
	"comparison_version" integer,
	"failure_class" "actions"."action_failure_class",
	"recorded_at" timestamp with time zone NOT NULL,
	"execution_id" text NOT NULL,
	"claim_token" uuid NOT NULL,
	"input_attempt_id" text,
	"input_parent_revision_id" text,
	"output_kind" "actions"."action_output_kind",
	"output_revision_id" text,
	"output_review_analysis_id" text,
	"output_agent_run_id" text,
	"no_work_reason" "actions"."action_no_work_reason",
	"finalized_claim_generation" bigint,
	"finalized_claim_token" uuid,
	"evidence_command_id" text,
	"observation_surface" "actions"."action_surface",
	"observation_completeness" "actions"."action_observation_completeness",
	"observed_at" timestamp with time zone,
	"non_application_basis" "actions"."action_non_application_basis",
	"retry_disposition" "actions"."action_retry_disposition",
	"uncertainty_reason" "actions"."action_uncertainty_reason",
	"unreadable_reason" "actions"."action_unreadable_reason",
	CONSTRAINT "action_execution_attempt_pkey" PRIMARY KEY("id"),
	CONSTRAINT "action_attempt_execution_identity" UNIQUE("organization_id","execution_id","id"),
	CONSTRAINT "action_attempt_step_identity" UNIQUE("organization_id","step_id","id"),
	CONSTRAINT "action_execution_attempt_organization_id_id_key" UNIQUE("organization_id","id"),
	CONSTRAINT "action_execution_attempt_step_id_number_key" UNIQUE("step_id","number"),
	CONSTRAINT "action_attempt_active_identity" CHECK (step_id IS NOT NULL AND number IS NOT NULL AND claim_generation IS NOT NULL AND started_at IS NOT NULL AND transport IS NOT NULL),
	CONSTRAINT "action_attempt_active_kind" CHECK (kind = ANY (ARRAY['write'::actions.action_attempt_kind, 'readback'::actions.action_attempt_kind, 'generation'::actions.action_attempt_kind, 'late_evidence'::actions.action_attempt_kind])),
	CONSTRAINT "action_attempt_evidence_shape" CHECK ((kind = 'late_evidence'::actions.action_attempt_kind) = (evidence_command_id IS NOT NULL) AND (kind <> 'late_evidence'::actions.action_attempt_kind OR finished_at IS NOT NULL AND finalized_claim_generation IS NULL AND finalized_claim_token IS NULL)),
	CONSTRAINT "action_attempt_finalization_fence" CHECK (kind = 'late_evidence'::actions.action_attempt_kind OR (finished_at IS NOT NULL) = (finalized_claim_generation IS NOT NULL) AND (finalized_claim_generation IS NULL) = (finalized_claim_token IS NULL)),
	CONSTRAINT "action_attempt_no_self_input" CHECK (id IS DISTINCT FROM input_attempt_id),
	CONSTRAINT "action_attempt_non_application_shape" CHECK ((NOT result IS DISTINCT FROM 'known_not_applied'::actions.action_attempt_result) = (non_application_basis IS NOT NULL)),
	CONSTRAINT "action_attempt_output_shape" CHECK ((result IS DISTINCT FROM 'generated'::actions.action_attempt_result OR output_kind IS NOT NULL) AND (output_kind IS NULL OR result IS NOT NULL AND (result = ANY (ARRAY['generated'::actions.action_attempt_result, 'discarded'::actions.action_attempt_result]))) AND (output_kind IS NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 0 OR output_kind = 'revision'::actions.action_output_kind AND output_revision_id IS NOT NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 1 OR output_kind = 'review_analysis'::actions.action_output_kind AND output_review_analysis_id IS NOT NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 1 OR output_kind = 'agent_run'::actions.action_output_kind AND output_agent_run_id IS NOT NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 1 OR output_kind = 'no_work'::actions.action_output_kind AND no_work_reason IS NOT NULL AND agent_run_id IS NOT NULL AND num_nonnulls(output_revision_id, output_review_analysis_id, output_agent_run_id, no_work_reason) = 1)),
	CONSTRAINT "action_attempt_result_by_kind" CHECK (result IS NULL OR kind = 'write'::actions.action_attempt_kind AND (result = ANY (ARRAY['acknowledged'::actions.action_attempt_result, 'known_not_applied'::actions.action_attempt_result, 'uncertain'::actions.action_attempt_result])) OR kind = 'readback'::actions.action_attempt_kind AND (result = ANY (ARRAY['matched'::actions.action_attempt_result, 'matched_external'::actions.action_attempt_result, 'mismatch'::actions.action_attempt_result, 'unreadable'::actions.action_attempt_result, 'known_not_applied'::actions.action_attempt_result])) OR kind = 'generation'::actions.action_attempt_kind AND (result = ANY (ARRAY['generated'::actions.action_attempt_result, 'discarded'::actions.action_attempt_result, 'known_not_applied'::actions.action_attempt_result, 'uncertain'::actions.action_attempt_result])) OR kind = 'late_evidence'::actions.action_attempt_kind),
	CONSTRAINT "action_attempt_verified_observation" CHECK ((result <> ALL (ARRAY['matched'::actions.action_attempt_result, 'matched_external'::actions.action_attempt_result, 'mismatch'::actions.action_attempt_result])) AND NOT (kind = 'readback'::actions.action_attempt_kind AND result = 'known_not_applied'::actions.action_attempt_result) OR observation_revision_id IS NOT NULL AND observation_surface IS NOT NULL AND NOT observation_completeness IS DISTINCT FROM 'complete'::actions.action_observation_completeness AND observed_at IS NOT NULL AND comparison_version IS NOT NULL),
	CONSTRAINT "action_execution_attempt_check" CHECK (id IS DISTINCT FROM subject_attempt_id),
	CONSTRAINT "action_execution_attempt_check1" CHECK (step_id IS NOT NULL AND number IS NOT NULL AND claim_generation IS NOT NULL AND started_at IS NOT NULL AND transport IS NOT NULL),
	CONSTRAINT "action_execution_attempt_check2" CHECK ((finished_at IS NULL) = (result IS NULL)),
	CONSTRAINT "action_execution_attempt_check3" CHECK (finished_at IS NULL OR started_at IS NULL OR finished_at >= started_at),
	CONSTRAINT "action_execution_attempt_check4" CHECK ((kind <> ALL (ARRAY['readback'::actions.action_attempt_kind, 'late_evidence'::actions.action_attempt_kind])) OR subject_attempt_id IS NOT NULL),
	CONSTRAINT "action_execution_attempt_check5" CHECK ((result <> ALL (ARRAY['matched'::actions.action_attempt_result, 'matched_external'::actions.action_attempt_result, 'mismatch'::actions.action_attempt_result])) OR observation_revision_id IS NOT NULL AND comparison_version IS NOT NULL),
	CONSTRAINT "action_execution_attempt_claim_generation_check" CHECK (claim_generation > 0),
	CONSTRAINT "action_execution_attempt_comparison_version_check" CHECK (comparison_version > 0),
	CONSTRAINT "action_execution_attempt_finalized_claim_generation_check" CHECK (finalized_claim_generation > 0),
	CONSTRAINT "action_execution_attempt_number_check" CHECK (number > 0),
	CONSTRAINT "action_attempt_parent_context_kind" CHECK (input_parent_revision_id IS NULL OR kind IN ('generation','late_evidence')),
	CONSTRAINT "action_attempt_retry_disposition_shape" CHECK ((result IS NOT DISTINCT FROM 'known_not_applied') = (retry_disposition IS NOT NULL)),
	CONSTRAINT "action_attempt_uncertainty_reason_shape" CHECK ((result IS NOT DISTINCT FROM 'uncertain') = (uncertainty_reason IS NOT NULL)),
	CONSTRAINT "action_attempt_unreadable_reason_shape" CHECK ((result IS NOT DISTINCT FROM 'unreadable') = (unreadable_reason IS NOT NULL))
);
--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_execution_step" (
	"id" text NOT NULL,
	"organization_id" text NOT NULL,
	"execution_id" text NOT NULL,
	"ordinal" integer NOT NULL,
	"kind" "actions"."action_step_kind" NOT NULL,
	"adapter_version" integer NOT NULL,
	"input_step_id" text,
	"content_revision_id" text NOT NULL,
	"recovery_mode" "actions"."action_recovery_mode" NOT NULL,
	"recovery_policy_version" integer NOT NULL,
	"native_idempotency_key" text,
	"required_surface" "actions"."action_surface" NOT NULL,
	"verification_timing" "actions"."action_verification_timing" DEFAULT 'after_effects' NOT NULL,
	CONSTRAINT "action_execution_step_pkey" PRIMARY KEY("id"),
	CONSTRAINT "action_execution_step_execution_id_ordinal_key" UNIQUE("execution_id","ordinal"),
	CONSTRAINT "action_execution_step_organization_id_execution_id_id_key" UNIQUE("organization_id","execution_id","id"),
	CONSTRAINT "action_execution_step_organization_id_id_key" UNIQUE("organization_id","id"),
	CONSTRAINT "action_step_verification_timing_shape" CHECK ((kind <> 'play_inspection_edit_create' OR verification_timing = 'before_successor' AND required_surface = 'editable_listing') AND (kind <> 'play_inspection_edit_delete' OR verification_timing = 'after_effects' AND required_surface = 'provider_response')),
	CONSTRAINT "action_execution_step_adapter_version_check" CHECK (adapter_version > 0),
	CONSTRAINT "action_execution_step_check" CHECK (id IS DISTINCT FROM input_step_id),
	CONSTRAINT "action_execution_step_check1" CHECK ((recovery_mode = 'native_idempotency'::actions.action_recovery_mode) = (native_idempotency_key IS NOT NULL)),
	CONSTRAINT "action_execution_step_ordinal_check" CHECK (ordinal >= 0),
	CONSTRAINT "action_execution_step_recovery_policy_version_check" CHECK (recovery_policy_version > 0)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_execution_step" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_listing_content" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"store" "actions"."store_kind" NOT NULL,
	"locale" text NOT NULL,
	"intent" "actions"."listing_intent" NOT NULL,
	"title_state" "actions"."content_value_state" DEFAULT 'unspecified'::actions.content_value_state NOT NULL,
	"title" text,
	"subtitle_state" "actions"."content_value_state" DEFAULT 'unspecified'::actions.content_value_state NOT NULL,
	"subtitle" text,
	"description_state" "actions"."content_value_state" DEFAULT 'unspecified'::actions.content_value_state NOT NULL,
	"description" text,
	"keywords_state" "actions"."content_value_state" DEFAULT 'unspecified'::actions.content_value_state NOT NULL,
	"keywords" text,
	"promotional_text_state" "actions"."content_value_state" DEFAULT 'unspecified'::actions.content_value_state NOT NULL,
	"promotional_text" text,
	"short_description_state" "actions"."content_value_state" DEFAULT 'unspecified'::actions.content_value_state NOT NULL,
	"short_description" text,
	"whats_new_state" "actions"."content_value_state" DEFAULT 'unspecified'::actions.content_value_state NOT NULL,
	"whats_new" text,
	"support_url_state" "actions"."content_value_state" DEFAULT 'unspecified'::actions.content_value_state NOT NULL,
	"support_url" text,
	"keyword_analysis" text,
	"operator_instructions" text,
	"source_fingerprint" text,
	"naturalness_check_skipped" boolean,
	"fidelity_check_skipped" boolean,
	"english_title" text,
	"english_subtitle" text,
	"english_promotional_text" text,
	"gloss_status" "actions"."gloss_status",
	"research_country" text,
	"research_coverage" "actions"."research_coverage",
	"research_model_source" text,
	"research_model_version" text,
	"research_model_formula" text,
	"app_tier" integer,
	"app_tier_resolved" boolean,
	"candidate_count" bigint,
	"judged_count" bigint,
	"scored_count" bigint,
	"p0_count" bigint,
	"p1_count" bigint,
	"p2_count" bigint,
	"with_volume_count" bigint,
	"conformance_term_count" bigint,
	"conformance_from_table_count" bigint,
	"observation_availability" "actions"."observation_availability",
	"observation_captured_at" timestamp with time zone,
	"source_capture_at" timestamp with time zone,
	"provider_version_state" "actions"."listing_version_state",
	CONSTRAINT "action_listing_content_pkey" PRIMARY KEY("organization_id","revision_id"),
	CONSTRAINT "action_listing_content_app_tier_check" CHECK (app_tier >= 1 AND app_tier <= 3),
	CONSTRAINT "action_listing_content_candidate_count_check" CHECK (candidate_count >= 0),
	CONSTRAINT "action_listing_content_check" CHECK (title_state = 'present'::actions.content_value_state AND title IS NOT NULL AND length(title) > 0 OR title_state = 'dismissed'::actions.content_value_state AND title IS NOT NULL OR title_state = 'empty'::actions.content_value_state AND title IS NOT NULL AND title = ''::text OR (title_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND title IS NULL),
	CONSTRAINT "action_listing_content_check1" CHECK (subtitle_state = 'present'::actions.content_value_state AND subtitle IS NOT NULL AND length(subtitle) > 0 OR subtitle_state = 'dismissed'::actions.content_value_state AND subtitle IS NOT NULL OR subtitle_state = 'empty'::actions.content_value_state AND subtitle IS NOT NULL AND subtitle = ''::text OR (subtitle_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND subtitle IS NULL),
	CONSTRAINT "action_listing_content_check2" CHECK (description_state = 'present'::actions.content_value_state AND description IS NOT NULL AND length(description) > 0 OR description_state = 'dismissed'::actions.content_value_state AND description IS NOT NULL OR description_state = 'empty'::actions.content_value_state AND description IS NOT NULL AND description = ''::text OR (description_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND description IS NULL),
	CONSTRAINT "action_listing_content_check3" CHECK (keywords_state = 'present'::actions.content_value_state AND keywords IS NOT NULL AND length(keywords) > 0 OR keywords_state = 'dismissed'::actions.content_value_state AND keywords IS NOT NULL OR keywords_state = 'empty'::actions.content_value_state AND keywords IS NOT NULL AND keywords = ''::text OR (keywords_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND keywords IS NULL),
	CONSTRAINT "action_listing_content_check4" CHECK (promotional_text_state = 'present'::actions.content_value_state AND promotional_text IS NOT NULL AND length(promotional_text) > 0 OR promotional_text_state = 'dismissed'::actions.content_value_state AND promotional_text IS NOT NULL OR promotional_text_state = 'empty'::actions.content_value_state AND promotional_text IS NOT NULL AND promotional_text = ''::text OR (promotional_text_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND promotional_text IS NULL),
	CONSTRAINT "action_listing_content_check5" CHECK (short_description_state = 'present'::actions.content_value_state AND short_description IS NOT NULL AND length(short_description) > 0 OR short_description_state = 'dismissed'::actions.content_value_state AND short_description IS NOT NULL OR short_description_state = 'empty'::actions.content_value_state AND short_description IS NOT NULL AND short_description = ''::text OR (short_description_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND short_description IS NULL),
	CONSTRAINT "action_listing_content_check6" CHECK (whats_new_state = 'present'::actions.content_value_state AND whats_new IS NOT NULL AND length(whats_new) > 0 OR whats_new_state = 'dismissed'::actions.content_value_state AND whats_new IS NOT NULL OR whats_new_state = 'empty'::actions.content_value_state AND whats_new IS NOT NULL AND whats_new = ''::text OR (whats_new_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND whats_new IS NULL),
	CONSTRAINT "action_listing_content_check7" CHECK (support_url_state = 'present'::actions.content_value_state AND support_url IS NOT NULL AND length(support_url) > 0 OR support_url_state = 'dismissed'::actions.content_value_state AND support_url IS NOT NULL OR support_url_state = 'empty'::actions.content_value_state AND support_url IS NOT NULL AND support_url = ''::text OR (support_url_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND support_url IS NULL),
	CONSTRAINT "action_listing_content_check8" CHECK (conformance_from_table_count IS NULL OR conformance_term_count IS NULL OR conformance_from_table_count <= conformance_term_count),
	CONSTRAINT "action_listing_content_conformance_from_table_count_check" CHECK (conformance_from_table_count >= 0),
	CONSTRAINT "action_listing_content_conformance_term_count_check" CHECK (conformance_term_count >= 0),
	CONSTRAINT "action_listing_content_judged_count_check" CHECK (judged_count >= 0),
	CONSTRAINT "action_listing_content_locale_check" CHECK (length(locale) > 0),
	CONSTRAINT "action_listing_content_p0_count_check" CHECK (p0_count >= 0),
	CONSTRAINT "action_listing_content_p1_count_check" CHECK (p1_count >= 0),
	CONSTRAINT "action_listing_content_p2_count_check" CHECK (p2_count >= 0),
	CONSTRAINT "action_listing_content_scored_count_check" CHECK (scored_count >= 0),
	CONSTRAINT "action_listing_content_with_volume_count_check" CHECK (with_volume_count >= 0),
	CONSTRAINT "listing_supported_locale" CHECK (actions.is_supported_store_locale(store, locale))
);
--> statement-breakpoint
ALTER TABLE "actions"."action_listing_content" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_market_competitor" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"ordinal" integer NOT NULL,
	"competitor_name" text NOT NULL,
	CONSTRAINT "action_market_competitor_pkey" PRIMARY KEY("organization_id","revision_id","ordinal"),
	CONSTRAINT "action_market_competitor_ordinal_check" CHECK (ordinal >= 0)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_market_competitor" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_market_country" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"role" "actions"."country_role" NOT NULL,
	"ordinal" integer NOT NULL,
	"country" text NOT NULL,
	CONSTRAINT "action_market_country_pkey" PRIMARY KEY("organization_id","revision_id","role","ordinal"),
	CONSTRAINT "action_market_country_ordinal_check" CHECK (ordinal >= 0)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_market_country" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_media_content" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"slot" integer NOT NULL,
	"kind" "actions"."media_kind" NOT NULL,
	"store" "actions"."store_kind" NOT NULL,
	"locale" text NOT NULL,
	"source_locale" text,
	"display_type" "actions"."media_display_type",
	"source_provider_resource_id" text,
	"source_object_key" text,
	"source_object_version" text,
	"source_digest" text,
	"output_object_key" text,
	"output_object_version" text,
	"output_digest" text,
	"availability" "actions"."media_availability" NOT NULL,
	"mime_type" text,
	"width" integer,
	"height" integer,
	"byte_length" bigint,
	"generation_prompt" text,
	"generated_at" timestamp with time zone,
	"storyboard_intent" text,
	"caption" text,
	"first_slot_hook_guidance" text,
	"source_storage_immutability" "actions"."media_storage_immutability",
	"output_storage_immutability" "actions"."media_storage_immutability",
	"provider_md5" text,
	"source_byte_length" bigint,
	CONSTRAINT "action_media_content_pkey" PRIMARY KEY("organization_id","revision_id","slot"),
	CONSTRAINT "action_media_content_byte_length_check" CHECK (byte_length >= 0),
	CONSTRAINT "action_media_content_height_check" CHECK (height > 0),
	CONSTRAINT "action_media_content_mime_type_check" CHECK (mime_type = ANY (ARRAY['image/png'::text, 'image/jpeg'::text, 'image/webp'::text, 'video/mp4'::text, 'video/quicktime'::text])),
	CONSTRAINT "action_media_content_slot_check" CHECK (slot >= 0),
	CONSTRAINT "action_media_content_width_check" CHECK (width > 0),
	CONSTRAINT "media_clip_shape" CHECK (kind::text <> 'app_clip_header'::text OR store = 'ios'::actions.store_kind AND display_type IS NULL AND mime_type IS NOT NULL AND (mime_type = ANY (ARRAY['image/png'::text, 'image/jpeg'::text]))),
	CONSTRAINT "media_display_store" CHECK (display_type IS NULL OR store = 'android'::actions.store_kind AND (display_type = ANY (ARRAY['phoneScreenshots'::actions.media_display_type, 'sevenInchScreenshots'::actions.media_display_type])) OR store = 'ios'::actions.store_kind AND (display_type <> ALL (ARRAY['phoneScreenshots'::actions.media_display_type, 'sevenInchScreenshots'::actions.media_display_type]))),
	CONSTRAINT "media_md5_format" CHECK (provider_md5 IS NULL OR provider_md5 ~ '^[0-9a-f]{32}$'::text),
	CONSTRAINT "media_output_digest_format" CHECK (output_digest IS NULL OR output_digest ~ '^sha256:[0-9a-f]{64}$'::text),
	CONSTRAINT "media_screenshot_display" CHECK (kind::text <> 'screenshot'::text OR display_type IS NOT NULL),
	CONSTRAINT "media_source_bytes_immutable" CHECK (source_object_key IS NULL AND source_object_version IS NULL AND source_digest IS NULL AND source_storage_immutability IS NULL OR source_object_key IS NOT NULL AND length(source_object_key) > 0 AND source_digest IS NOT NULL AND source_storage_immutability IS NOT NULL AND (source_storage_immutability = 'versioned_object'::actions.media_storage_immutability AND source_object_version IS NOT NULL AND length(source_object_version) > 0 OR source_storage_immutability = 'content_addressed_immutable'::actions.media_storage_immutability AND source_object_version IS NULL AND POSITION((SUBSTRING(source_digest FROM 8)) IN (source_object_key)) > 0)),
	CONSTRAINT "media_source_digest_format" CHECK (source_digest IS NULL OR source_digest ~ '^sha256:[0-9a-f]{64}$'::text),
	CONSTRAINT "media_stored_bytes_immutable" CHECK (availability <> 'stored'::actions.media_availability OR output_object_key IS NOT NULL AND length(output_object_key) > 0 AND output_digest IS NOT NULL AND byte_length IS NOT NULL AND output_storage_immutability IS NOT NULL AND (output_storage_immutability = 'versioned_object'::actions.media_storage_immutability AND output_object_version IS NOT NULL AND length(output_object_version) > 0 OR output_storage_immutability = 'content_addressed_immutable'::actions.media_storage_immutability AND output_object_version IS NULL AND POSITION((SUBSTRING(output_digest FROM 8)) IN (output_object_key)) > 0)),
	CONSTRAINT "media_supported_locale" CHECK (actions.is_supported_store_locale(store, locale)),
	CONSTRAINT "media_supported_source_locale" CHECK (source_locale IS NULL OR actions.is_supported_store_locale(store, source_locale)),
	CONSTRAINT "media_source_length" CHECK ((source_object_key IS NOT NULL) = (source_byte_length IS NOT NULL) AND (source_byte_length IS NULL OR source_byte_length > 0))
);
--> statement-breakpoint
ALTER TABLE "actions"."action_media_content" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_membership" (
	"organization_id" text NOT NULL,
	"parent_revision_id" text NOT NULL,
	"child_action_id" text NOT NULL,
	"child_revision_id" text NOT NULL,
	"ordinal" integer NOT NULL,
	CONSTRAINT "action_membership_pkey" PRIMARY KEY("parent_revision_id","child_action_id"),
	CONSTRAINT "action_membership_organization_id_parent_revision_id_child__key" UNIQUE("organization_id","parent_revision_id","child_action_id","child_revision_id"),
	CONSTRAINT "action_membership_parent_revision_id_ordinal_key" UNIQUE("parent_revision_id","ordinal"),
	CONSTRAINT "action_membership_ordinal_check" CHECK (ordinal >= 0)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_membership" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_policy_revision" (
	"id" text NOT NULL,
	"organization_id" text NOT NULL,
	"asset_id" text NOT NULL,
	"granted_by_command_id" text NOT NULL,
	"policy_kind" text NOT NULL,
	"revision_number" bigint NOT NULL,
	"minimum_rating" smallint,
	"maximum_rating" smallint,
	"allow_initial_reply" boolean NOT NULL,
	"allow_replace_reply" boolean DEFAULT false NOT NULL,
	"allow_generation" boolean NOT NULL,
	"rule_version" integer NOT NULL,
	"revoked_by_command_id" text,
	"revoked_at" timestamp with time zone,
	"created_at" timestamp with time zone NOT NULL,
	CONSTRAINT "action_policy_revision_pkey" PRIMARY KEY("id"),
	CONSTRAINT "action_policy_revision_organization_id_asset_id_policy_kind_key" UNIQUE("organization_id","asset_id","policy_kind","revision_number"),
	CONSTRAINT "action_policy_revision_organization_id_id_key" UNIQUE("organization_id","id"),
	CONSTRAINT "action_policy_revision_check" CHECK (minimum_rating IS NULL OR maximum_rating >= minimum_rating),
	CONSTRAINT "action_policy_revision_check1" CHECK (policy_kind <> 'agent_generation'::text OR NOT allow_initial_reply AND NOT allow_replace_reply),
	CONSTRAINT "action_policy_revision_check2" CHECK ((revoked_by_command_id IS NULL) = (revoked_at IS NULL)),
	CONSTRAINT "action_policy_revision_maximum_rating_check" CHECK (maximum_rating >= 1 AND maximum_rating <= 5),
	CONSTRAINT "action_policy_revision_minimum_rating_check" CHECK (minimum_rating >= 1 AND minimum_rating <= 5),
	CONSTRAINT "action_policy_revision_policy_kind_check" CHECK (policy_kind = ANY (ARRAY['review_auto_reply'::text, 'agent_generation'::text])),
	CONSTRAINT "action_policy_revision_revision_number_check" CHECK (revision_number > 0),
	CONSTRAINT "action_policy_revision_rule_version_check" CHECK (rule_version > 0),
	CONSTRAINT "policy_permission_shape" CHECK (policy_kind = 'agent_generation'::text AND allow_generation AND NOT allow_initial_reply AND NOT allow_replace_reply AND minimum_rating IS NULL OR policy_kind = 'review_auto_reply'::text AND (allow_initial_reply OR allow_replace_reply)),
	CONSTRAINT "policy_rating_bounds" CHECK ((minimum_rating IS NULL) = (maximum_rating IS NULL))
);
--> statement-breakpoint
ALTER TABLE "actions"."action_policy_revision" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_read" (
	"organization_id" text NOT NULL,
	"user_id" text NOT NULL,
	"action_id" text NOT NULL,
	"seen_attention_version" bigint NOT NULL,
	"force_unread" boolean DEFAULT false NOT NULL,
	"updated_at" timestamp with time zone NOT NULL,
	CONSTRAINT "action_read_pkey" PRIMARY KEY("organization_id","user_id","action_id"),
	CONSTRAINT "action_read_seen_attention_version_check" CHECK (seen_attention_version >= 0)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_read" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_request_content" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"intent" "actions"."request_intent" NOT NULL,
	"store" "actions"."store_kind",
	"locale" text,
	"wave_index" integer,
	"recommendation_type" "actions"."recommendation_kind",
	"plan_source_id" text,
	"source_capture_at" timestamp with time zone,
	"window_days" integer,
	"review_mode" text,
	"operator_instructions" text,
	"focus" text,
	"context_text" text,
	"hypothesize_policy" "actions"."approval_setting",
	"draft_policy" "actions"."approval_setting",
	"execute_policy" "actions"."approval_setting",
	"origin" "actions"."request_origin" NOT NULL,
	"language" text,
	"reasoning" text,
	"score" numeric,
	"demand_lookback_days" integer,
	"downloads" numeric,
	"revenue_usd" numeric,
	"impressions" numeric,
	"review_count" bigint,
	"competitor_strength" numeric,
	"localized_competitor_count" bigint,
	"top_chart_count" bigint,
	"estimated_market_downloads" numeric,
	"market_research_note" text,
	"finding_title" text,
	"finding_rationale" text,
	"finding_severity" "actions"."closed_severity",
	"requested_agent_id" text,
	CONSTRAINT "action_request_content_pkey" PRIMARY KEY("organization_id","revision_id"),
	CONSTRAINT "action_request_content_check" CHECK ((intent <> ALL (ARRAY['review_catch_up'::actions.request_intent, 'review_analysis'::actions.request_intent])) OR window_days IS NOT NULL),
	CONSTRAINT "action_request_content_check1" CHECK (intent <> 'review_catch_up'::actions.request_intent OR review_mode IS NOT NULL),
	CONSTRAINT "action_request_content_check2" CHECK (intent <> 'locale_expansion'::actions.request_intent OR store IS NOT NULL AND locale IS NOT NULL),
	CONSTRAINT "action_request_content_demand_lookback_days_check" CHECK (demand_lookback_days > 0),
	CONSTRAINT "action_request_content_review_mode_check" CHECK (review_mode = ANY (ARRAY['manual'::text, 'full_agentic'::text])),
	CONSTRAINT "action_request_content_wave_index_check" CHECK (wave_index >= 0),
	CONSTRAINT "action_request_content_window_days_check" CHECK (window_days >= 7 AND window_days <= 180),
	CONSTRAINT "request_agent_target_shape" CHECK ((intent = 'wake_agent'::actions.request_intent) = (requested_agent_id IS NOT NULL)),
	CONSTRAINT "request_supported_locale" CHECK (locale IS NULL OR store IS NOT NULL AND actions.is_supported_store_locale(store, locale))
);
--> statement-breakpoint
ALTER TABLE "actions"."action_request_content" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_resource_guard" (
	"provider" text NOT NULL,
	"provider_account_id" text,
	"remote_application_id" text,
	"holder_organization_id" text,
	"holder_execution_id" text,
	"acquired_at" timestamp with time zone,
	"id" uuid DEFAULT gen_random_uuid() NOT NULL,
	"scope" "actions"."action_resource_scope" NOT NULL,
	CONSTRAINT "action_resource_guard_identity" PRIMARY KEY("id"),
	CONSTRAINT "action_resource_guard_check" CHECK ((holder_execution_id IS NULL) = (holder_organization_id IS NULL)),
	CONSTRAINT "action_resource_guard_check1" CHECK ((holder_execution_id IS NULL) = (acquired_at IS NULL)),
	CONSTRAINT "action_resource_guard_nonempty_account" CHECK (length(provider_account_id) > 0),
	CONSTRAINT "action_resource_guard_provider_check" CHECK (provider = ANY (ARRAY['app_store_connect'::text, 'google_play'::text, 'apple_search_ads'::text])),
	CONSTRAINT "action_resource_guard_scope_shape" CHECK (provider = 'apple_search_ads'::text AND scope = 'advertising_account'::actions.action_resource_scope AND provider_account_id IS NOT NULL AND remote_application_id IS NULL OR (provider = ANY (ARRAY['app_store_connect'::text, 'google_play'::text])) AND scope = 'store_application'::actions.action_resource_scope AND provider_account_id IS NULL AND remote_application_id IS NOT NULL AND length(remote_application_id) > 0)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_resource_guard" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_review_content" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"provider_account_id" text NOT NULL,
	"store" "actions"."store_kind" NOT NULL,
	"provider_app_id" text NOT NULL,
	"provider_review_id" text NOT NULL,
	"apple_review_resource_id" text,
	"intent" "actions"."reply_intent" NOT NULL,
	"reply_text" text,
	"original_ai_revision_id" text,
	"detected_language_name" text,
	"review_rating" integer,
	"review_title" text,
	"review_body" text,
	"review_nickname" text,
	"review_storefront" text,
	"review_app_version" text,
	"review_modified_at" timestamp with time zone,
	"review_edited" boolean,
	"response_availability" "actions"."observation_availability" NOT NULL,
	"provider_response_id" text,
	"provider_response_text" text,
	"provider_response_modified_at" timestamp with time zone,
	"provider_response_hidden" boolean,
	"observation_captured_at" timestamp with time zone,
	"provider_response_state" "actions"."review_publication_state",
	CONSTRAINT "action_review_content_pkey" PRIMARY KEY("organization_id","revision_id"),
	CONSTRAINT "action_review_content_check" CHECK ((intent <> ALL (ARRAY['send'::actions.reply_intent, 'update'::actions.reply_intent])) OR reply_text IS NOT NULL AND length(reply_text) > 0),
	CONSTRAINT "action_review_content_check2" CHECK (response_availability <> 'present'::actions.observation_availability OR provider_response_text IS NOT NULL),
	CONSTRAINT "action_review_content_check3" CHECK (response_availability <> 'absent'::actions.observation_availability OR provider_response_id IS NULL AND provider_response_text IS NULL),
	CONSTRAINT "action_review_content_review_rating_check" CHECK (review_rating >= 1 AND review_rating <= 5)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_review_content" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_revision" (
	"id" text NOT NULL,
	"organization_id" text NOT NULL,
	"action_id" text NOT NULL,
	"purpose" "actions"."action_revision_purpose" NOT NULL,
	"kind" text NOT NULL,
	"operation" text NOT NULL,
	"revision_number" bigint NOT NULL,
	"authored_command_id" text NOT NULL,
	"baseline_revision_id" text,
	"generated_from_revision_id" text,
	"title" text NOT NULL,
	"summary" text NOT NULL,
	"rationale" text,
	"content_digest" char(64) NOT NULL,
	"canonicalization_version" integer NOT NULL,
	"sealed" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone NOT NULL,
	CONSTRAINT "action_revision_pkey" PRIMARY KEY("id"),
	CONSTRAINT "action_revision_action_id_revision_number_key" UNIQUE("action_id","revision_number"),
	CONSTRAINT "action_revision_organization_id_action_id_id_key" UNIQUE("organization_id","action_id","id"),
	CONSTRAINT "action_revision_organization_id_id_key" UNIQUE("organization_id","id"),
	CONSTRAINT "action_revision_canonicalization_version_check" CHECK (canonicalization_version > 0),
	CONSTRAINT "action_revision_check" CHECK (id IS DISTINCT FROM baseline_revision_id AND id IS DISTINCT FROM generated_from_revision_id),
	CONSTRAINT "action_revision_content_digest_check" CHECK (content_digest ~ '^[0-9a-f]{64}$'::text),
	CONSTRAINT "action_revision_revision_number_check" CHECK (revision_number > 0),
	CONSTRAINT "revision_kind_closed" CHECK (kind = ANY (ARRAY['review_reply'::text, 'listing'::text, 'request'::text, 'ads'::text, 'advisory'::text, 'collection'::text])),
	CONSTRAINT "revision_operation_closed" CHECK (kind = 'review_reply'::text AND operation = 'post_reply'::text OR kind = 'listing'::text AND (operation = ANY (ARRAY['apply_listing_changes'::text, 'update_promo_text'::text, 'create_locale'::text, 'update_description'::text, 'update_short_description'::text, 'revert_experiment'::text, 'aso_revert_listing'::text])) OR kind = 'request'::text AND (operation = ANY (ARRAY['generate_locale'::text, 'generate_listing'::text, 'review_catch_up_30d'::text, 'generate_review_analysis'::text, 'run_agent'::text])) OR kind = 'ads'::text AND (operation = ANY (ARRAY['asa_pause_campaign'::text, 'asa_enable_campaign'::text, 'asa_update_campaign_budget'::text, 'asa_update_keyword_bid'::text, 'asa_create_keyword'::text, 'asa_add_negative_keyword'::text, 'asa_delete_negative_keyword'::text])) OR kind = 'advisory'::text AND (operation = ANY (ARRAY['acknowledge'::text, 'resolve_prerequisite'::text])) OR kind = 'collection'::text AND (operation = ANY (ARRAY['post_batch'::text, 'apply_listing_changes'::text, 'localize'::text, 'asa_update_keyword_bid'::text, 'revert_experiment'::text, 'aso_revert_listing'::text])))
);
--> statement-breakpoint
ALTER TABLE "actions"."action_revision" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."action_revision_source" (
	"id" text NOT NULL,
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"kind" "actions"."action_source_kind" NOT NULL,
	"source_agent_run_id" text,
	"source_recommendation_id" text,
	"source_variant_id" text,
	"source_report_version_id" text,
	"source_backlog_id" text,
	"source_experiment_id" text,
	"source_action_id" text,
	"source_plan_coordinate" text,
	"source_finding_coordinate" text,
	"source_candidate_coordinate" text,
	CONSTRAINT "action_revision_source_pkey" PRIMARY KEY("id"),
	CONSTRAINT "action_revision_source_check" CHECK (num_nonnulls(source_agent_run_id, source_recommendation_id, source_variant_id, source_report_version_id, source_backlog_id, source_experiment_id, source_action_id) = 1),
	CONSTRAINT "action_revision_source_check1" CHECK ((kind = 'agent_run'::actions.action_source_kind) = (source_agent_run_id IS NOT NULL)),
	CONSTRAINT "action_revision_source_check2" CHECK ((kind = 'recommendation'::actions.action_source_kind) = (source_recommendation_id IS NOT NULL)),
	CONSTRAINT "action_revision_source_check3" CHECK ((kind = 'recommendation_variant'::actions.action_source_kind) = (source_variant_id IS NOT NULL)),
	CONSTRAINT "action_revision_source_check4" CHECK ((kind = 'report_version'::actions.action_source_kind) = (source_report_version_id IS NOT NULL)),
	CONSTRAINT "action_revision_source_check5" CHECK ((kind = 'backlog_item'::actions.action_source_kind) = (source_backlog_id IS NOT NULL)),
	CONSTRAINT "action_revision_source_check6" CHECK ((kind = 'experiment'::actions.action_source_kind) = (source_experiment_id IS NOT NULL)),
	CONSTRAINT "action_revision_source_check7" CHECK ((kind = 'action'::actions.action_source_kind) = (source_action_id IS NOT NULL)),
	CONSTRAINT "action_revision_source_check8" CHECK ((kind = ANY (ARRAY['agent_run'::actions.action_source_kind, 'report_version'::actions.action_source_kind])) OR source_plan_coordinate IS NULL AND source_finding_coordinate IS NULL AND source_candidate_coordinate IS NULL)
);
--> statement-breakpoint
ALTER TABLE "actions"."action_revision_source" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "app_store_connect"."attempt_receipt" (
	"organization_id" text NOT NULL,
	"attempt_id" text NOT NULL,
	"provider_request_id" text,
	"provider_resource_id" text,
	"provider_localization_id" text,
	"provider_media_id" text,
	"provider_error_code" text,
	CONSTRAINT "attempt_receipt_organization_id_attempt_id_pk" PRIMARY KEY("organization_id","attempt_id")
);
--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "app_store_connect"."listing_contract" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"provider_account_id" text NOT NULL,
	"provider_app_id" text,
	"app_info_id" text,
	"app_info_localization_id" text,
	"app_version_id" text,
	"app_version_localization_id" text,
	"live_promotional_version_id" text,
	"live_promotional_localization_id" text,
	"app_clip_operation" "app_store_connect"."app_clip_operation" DEFAULT 'none'::app_store_connect.app_clip_operation NOT NULL,
	"app_clip_id" text,
	"app_clip_experience_id" text,
	"app_clip_release_version_id" text,
	"app_clip_localization_id" text,
	"app_clip_source_localization_id" text,
	"app_clip_subtitle" text,
	"app_clip_header_media_slot" integer,
	"app_clip_incomplete_header_id" text,
	"app_clip_header_state" "app_store_connect"."app_clip_header_state",
	"live_promotional_text_state" "actions"."content_value_state" DEFAULT 'unspecified'::actions.content_value_state NOT NULL,
	"live_promotional_text" text,
	CONSTRAINT "listing_contract_organization_id_revision_id_pk" PRIMARY KEY("organization_id","revision_id")
);
--> statement-breakpoint
ALTER TABLE "app_store_connect"."listing_contract" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "app_store_connect"."step_contract" (
	"organization_id" text NOT NULL,
	"step_id" text NOT NULL,
	"media_slot" integer,
	"upload_offset" bigint,
	"upload_length" bigint,
	"source_reserve_attempt_id" text,
	"upload_url_ciphertext" text,
	"upload_method" "app_store_connect"."upload_method",
	"upload_content_type" "app_store_connect"."upload_content_type",
	CONSTRAINT "step_contract_organization_id_step_id_pk" PRIMARY KEY("organization_id","step_id"),
	CONSTRAINT "asc_step_upload_contract_shape" CHECK ((upload_offset IS NOT NULL) = (source_reserve_attempt_id IS NOT NULL) AND (upload_offset IS NOT NULL) = (upload_url_ciphertext IS NOT NULL) AND (upload_offset IS NOT NULL) = (upload_method IS NOT NULL) AND (upload_content_type IS NULL OR upload_offset IS NOT NULL) AND (upload_url_ciphertext IS NULL OR length(upload_url_ciphertext) > 0))
);
--> statement-breakpoint
ALTER TABLE "app_store_connect"."step_contract" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "apple_ads"."action_content" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"intent" "apple_ads"."ad_intent" NOT NULL,
	"provider_account_id" text NOT NULL,
	"provider_campaign_id" text NOT NULL,
	"provider_ad_group_id" text,
	"provider_keyword_id" text,
	"provider_negative_keyword_id" text,
	"keyword_text" text,
	"match_type" "apple_ads"."ad_match_type",
	"daily_budget_amount" numeric,
	"bid_amount" numeric,
	"currency_code" text,
	"observed_status" "apple_ads"."ad_observed_status",
	"observation_availability" "actions"."observation_availability",
	"observation_captured_at" timestamp with time zone,
	CONSTRAINT "action_ad_content_pkey" PRIMARY KEY("organization_id","revision_id"),
	CONSTRAINT "action_ad_content_bid_amount_check" CHECK (bid_amount > 0::numeric),
	CONSTRAINT "action_ad_content_check" CHECK (intent <> 'set_campaign_budget'::apple_ads.ad_intent OR daily_budget_amount IS NOT NULL AND currency_code IS NOT NULL),
	CONSTRAINT "action_ad_content_check1" CHECK (intent <> 'set_keyword_bid'::apple_ads.ad_intent OR provider_ad_group_id IS NOT NULL AND provider_keyword_id IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL),
	CONSTRAINT "action_ad_content_check10" CHECK ((intent = ANY (ARRAY['create_keyword'::apple_ads.ad_intent, 'add_negative_keyword'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR keyword_text IS NULL AND match_type IS NULL),
	CONSTRAINT "action_ad_content_check11" CHECK ((intent = ANY (ARRAY['set_keyword_bid'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR provider_keyword_id IS NULL),
	CONSTRAINT "action_ad_content_check12" CHECK ((intent = ANY (ARRAY['delete_negative_keyword'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR provider_negative_keyword_id IS NULL),
	CONSTRAINT "action_ad_content_check13" CHECK ((intent = ANY (ARRAY['set_keyword_bid'::apple_ads.ad_intent, 'create_keyword'::apple_ads.ad_intent, 'add_negative_keyword'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR provider_ad_group_id IS NULL),
	CONSTRAINT "action_ad_content_check2" CHECK (intent <> 'create_keyword'::apple_ads.ad_intent OR provider_ad_group_id IS NOT NULL AND keyword_text IS NOT NULL AND match_type IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL),
	CONSTRAINT "action_ad_content_check3" CHECK (intent <> 'add_negative_keyword'::apple_ads.ad_intent OR keyword_text IS NOT NULL AND match_type IS NOT NULL),
	CONSTRAINT "action_ad_content_check4" CHECK (intent <> 'delete_negative_keyword'::apple_ads.ad_intent OR provider_negative_keyword_id IS NOT NULL),
	CONSTRAINT "action_ad_content_check5" CHECK (intent <> 'observed'::apple_ads.ad_intent OR observation_availability IS NOT NULL AND observation_captured_at IS NOT NULL),
	CONSTRAINT "action_ad_content_check6" CHECK (intent = 'observed'::apple_ads.ad_intent OR observed_status IS NULL),
	CONSTRAINT "action_ad_content_check7" CHECK ((intent = ANY (ARRAY['set_campaign_budget'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR daily_budget_amount IS NULL),
	CONSTRAINT "action_ad_content_check8" CHECK ((intent = ANY (ARRAY['set_keyword_bid'::apple_ads.ad_intent, 'create_keyword'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR bid_amount IS NULL),
	CONSTRAINT "action_ad_content_check9" CHECK ((intent = ANY (ARRAY['set_keyword_bid'::apple_ads.ad_intent, 'set_campaign_budget'::apple_ads.ad_intent, 'create_keyword'::apple_ads.ad_intent, 'observed'::apple_ads.ad_intent])) OR currency_code IS NULL),
	CONSTRAINT "action_ad_content_currency_code_check" CHECK (currency_code ~ '^[A-Z]{3}$'::text),
	CONSTRAINT "action_ad_content_daily_budget_amount_check" CHECK (daily_budget_amount > 0::numeric),
	CONSTRAINT "action_ad_content_provider_ad_group_id_check" CHECK (provider_ad_group_id ~ '^[1-9][0-9]*$'::text),
	CONSTRAINT "action_ad_content_provider_campaign_id_check" CHECK (provider_campaign_id ~ '^[1-9][0-9]*$'::text),
	CONSTRAINT "action_ad_content_provider_keyword_id_check" CHECK (provider_keyword_id ~ '^[1-9][0-9]*$'::text),
	CONSTRAINT "action_ad_content_provider_negative_keyword_id_check" CHECK (provider_negative_keyword_id ~ '^[1-9][0-9]*$'::text)
);
--> statement-breakpoint
ALTER TABLE "apple_ads"."action_content" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "apple_ads"."attempt_receipt" (
	"organization_id" text NOT NULL,
	"attempt_id" text NOT NULL,
	"provider_request_id" text,
	"provider_resource_id" text,
	"provider_error_code" text,
	CONSTRAINT "attempt_receipt_organization_id_attempt_id_pk" PRIMARY KEY("organization_id","attempt_id")
);
--> statement-breakpoint
ALTER TABLE "apple_ads"."attempt_receipt" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "google_play"."attempt_receipt" (
	"organization_id" text NOT NULL,
	"attempt_id" text NOT NULL,
	"provider_request_id" text,
	"provider_resource_id" text,
	"provider_edit_id" text,
	"provider_edit_expires_at" timestamp with time zone,
	"provider_error_code" text,
	CONSTRAINT "attempt_receipt_organization_id_attempt_id_pk" PRIMARY KEY("organization_id","attempt_id")
);
--> statement-breakpoint
ALTER TABLE "google_play"."attempt_receipt" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "google_play"."listing_contract" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"provider_account_id" text NOT NULL,
	"package_name" text,
	"google_edit_id" text,
	"play_commit_policy" "google_play"."play_commit_policy",
	CONSTRAINT "listing_contract_organization_id_revision_id_pk" PRIMARY KEY("organization_id","revision_id")
);
--> statement-breakpoint
ALTER TABLE "google_play"."listing_contract" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_asset_id_fkey" FOREIGN KEY ("asset_id") REFERENCES "public"."asset"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_last_command_fk" FOREIGN KEY ("organization_id","last_command_id") REFERENCES "actions"."action_command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_organization_id_id_current_approval_id_fkey" FOREIGN KEY ("organization_id","id","current_approval_id") REFERENCES "actions"."action_approval"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_organization_id_id_current_revision_id_fkey" FOREIGN KEY ("organization_id","id","current_revision_id") REFERENCES "actions"."action_revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_organization_id_parent_action_id_fkey" FOREIGN KEY ("organization_id","parent_action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_organization_id_successor_action_id_fkey" FOREIGN KEY ("organization_id","successor_action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_owner_user_id_fkey" FOREIGN KEY ("owner_user_id") REFERENCES "public"."user"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_advisory_content" ADD CONSTRAINT "actionsSchema_action_advisory_content_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_advisory_content" ADD CONSTRAINT "action_advisory_content_organization_id_revision_id_fkey" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_alias" ADD CONSTRAINT "actionsSchema_action_alias_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_alias" ADD CONSTRAINT "action_alias_organization_id_action_id_fkey" FOREIGN KEY ("organization_id","action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_approval" ADD CONSTRAINT "actionsSchema_action_approval_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_approval" ADD CONSTRAINT "action_approval_organization_id_action_id_revision_id_fkey" FOREIGN KEY ("organization_id","action_id","revision_id") REFERENCES "actions"."action_revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_approval" ADD CONSTRAINT "action_approval_organization_id_command_id_action_id_fkey" FOREIGN KEY ("organization_id","command_id","action_id") REFERENCES "actions"."action_command_target"("organization_id","command_id","action_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_approval" ADD CONSTRAINT "action_approval_organization_id_parent_revision_id_fkey" FOREIGN KEY ("organization_id","parent_revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_approval" ADD CONSTRAINT "action_approval_organization_id_policy_revision_id_fkey" FOREIGN KEY ("organization_id","policy_revision_id") REFERENCES "actions"."action_policy_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_approval" ADD CONSTRAINT "approval_exact_membership_fk" FOREIGN KEY ("organization_id","parent_revision_id","action_id","revision_id") REFERENCES "actions"."action_membership"("organization_id","parent_revision_id","child_action_id","child_revision_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD CONSTRAINT "action_command_acting_for_user_id_fkey" FOREIGN KEY ("acting_for_user_id") REFERENCES "public"."user"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD CONSTRAINT "action_command_actor_agent_run_id_fkey" FOREIGN KEY ("actor_agent_run_id") REFERENCES "public"."agent_run"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD CONSTRAINT "action_command_actor_api_key_id_fkey" FOREIGN KEY ("actor_api_key_id") REFERENCES "public"."api_key"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD CONSTRAINT "action_command_actor_discord_integration_id_fkey" FOREIGN KEY ("actor_discord_integration_id") REFERENCES "public"."discord_integration"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD CONSTRAINT "action_command_actor_slack_integration_id_fkey" FOREIGN KEY ("actor_slack_integration_id") REFERENCES "public"."slack_integration"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD CONSTRAINT "action_command_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "public"."user"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD CONSTRAINT "action_command_organization_id_actor_policy_revision_id_fkey" FOREIGN KEY ("organization_id","actor_policy_revision_id") REFERENCES "actions"."action_policy_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD CONSTRAINT "action_command_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD CONSTRAINT "action_command_organization_id_target_policy_revision_id_fkey" FOREIGN KEY ("organization_id","target_policy_revision_id") REFERENCES "actions"."action_policy_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command_target" ADD CONSTRAINT "actionsSchema_action_command_target_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command_target" ADD CONSTRAINT "action_command_target_evidence_revision_tenant_action_fk" FOREIGN KEY ("organization_id","action_id","evidence_revision_id") REFERENCES "actions"."action_revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command_target" ADD CONSTRAINT "action_command_target_organization_id_action_id_expected_r_fkey" FOREIGN KEY ("organization_id","action_id","expected_revision_id") REFERENCES "actions"."action_revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command_target" ADD CONSTRAINT "action_command_target_organization_id_action_id_fkey" FOREIGN KEY ("organization_id","action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command_target" ADD CONSTRAINT "action_command_target_organization_id_action_id_previous_r_fkey" FOREIGN KEY ("organization_id","action_id","previous_revision_id") REFERENCES "actions"."action_revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command_target" ADD CONSTRAINT "action_command_target_organization_id_action_id_result_rev_fkey" FOREIGN KEY ("organization_id","action_id","result_revision_id") REFERENCES "actions"."action_revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command_target" ADD CONSTRAINT "action_command_target_organization_id_command_id_fkey" FOREIGN KEY ("organization_id","command_id") REFERENCES "actions"."action_command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command_target" ADD CONSTRAINT "action_command_target_organization_id_expected_parent_revi_fkey" FOREIGN KEY ("organization_id","expected_parent_revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command_target" ADD CONSTRAINT "target_previous_approval_fk" FOREIGN KEY ("organization_id","action_id","previous_approval_id") REFERENCES "actions"."action_approval"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command_target" ADD CONSTRAINT "target_result_approval_fk" FOREIGN KEY ("organization_id","action_id","result_approval_id") REFERENCES "actions"."action_approval"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_content_note" ADD CONSTRAINT "actionsSchema_action_content_note_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_content_note" ADD CONSTRAINT "action_content_note_organization_id_revision_id_fkey" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_content_term" ADD CONSTRAINT "actionsSchema_action_content_term_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_content_term" ADD CONSTRAINT "action_content_term_organization_id_revision_id_fkey" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_dependency" ADD CONSTRAINT "actionsSchema_action_dependency_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_dependency" ADD CONSTRAINT "action_dependency_organization_id_created_command_id_fkey" FOREIGN KEY ("organization_id","created_command_id") REFERENCES "actions"."action_command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_dependency" ADD CONSTRAINT "action_dependency_organization_id_dependent_action_id_fkey" FOREIGN KEY ("organization_id","dependent_action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_dependency" ADD CONSTRAINT "action_dependency_organization_id_prerequisite_action_id_fkey" FOREIGN KEY ("organization_id","prerequisite_action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution" ADD CONSTRAINT "actionsSchema_action_execution_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution" ADD CONSTRAINT "action_execution_cancel_command_fk" FOREIGN KEY ("organization_id","cancelled_command_id") REFERENCES "actions"."action_command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution" ADD CONSTRAINT "action_execution_organization_id_approval_id_fkey" FOREIGN KEY ("organization_id","approval_id") REFERENCES "actions"."action_approval"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution" ADD CONSTRAINT "action_execution_organization_id_id_next_step_id_fkey" FOREIGN KEY ("organization_id","id","next_step_id") REFERENCES "actions"."action_execution_step"("organization_id","execution_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution" ADD CONSTRAINT "action_execution_resource_guard_id_fkey" FOREIGN KEY ("resource_guard_id") REFERENCES "actions"."action_resource_guard"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "actionsSchema_action_execution_attempt_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_attempt_evidence_command" FOREIGN KEY ("organization_id","evidence_command_id") REFERENCES "actions"."action_command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_attempt_input_same_execution" FOREIGN KEY ("organization_id","execution_id","input_attempt_id") REFERENCES "actions"."action_execution_attempt"("organization_id","execution_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_attempt_output_revision" FOREIGN KEY ("organization_id","output_revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_attempt_step_execution" FOREIGN KEY ("organization_id","execution_id","step_id") REFERENCES "actions"."action_execution_step"("organization_id","execution_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_attempt_subject_same_step" FOREIGN KEY ("organization_id","step_id","subject_attempt_id") REFERENCES "actions"."action_execution_attempt"("organization_id","step_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_execution_attempt_agent_run_id_fkey" FOREIGN KEY ("agent_run_id") REFERENCES "public"."agent_run"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_execution_attempt_connector_id_fkey" FOREIGN KEY ("connector_id") REFERENCES "public"."data_connector"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_attempt_input_parent_revision_tenant_fk" FOREIGN KEY ("organization_id","input_parent_revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_execution_attempt_organization_id_observation_revis_fkey" FOREIGN KEY ("organization_id","observation_revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_execution_attempt_organization_id_step_id_fkey" FOREIGN KEY ("organization_id","step_id") REFERENCES "actions"."action_execution_step"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_execution_attempt_organization_id_subject_attempt_i_fkey" FOREIGN KEY ("organization_id","subject_attempt_id") REFERENCES "actions"."action_execution_attempt"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_execution_attempt_output_agent_run_id_fkey" FOREIGN KEY ("output_agent_run_id") REFERENCES "public"."agent_run"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_attempt" ADD CONSTRAINT "action_execution_attempt_output_review_analysis_id_fkey" FOREIGN KEY ("output_review_analysis_id") REFERENCES "public"."review_analysis"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_step" ADD CONSTRAINT "actionsSchema_action_execution_step_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_step" ADD CONSTRAINT "action_execution_step_organization_id_content_revision_id_fkey" FOREIGN KEY ("organization_id","content_revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_step" ADD CONSTRAINT "action_execution_step_organization_id_execution_id_fkey" FOREIGN KEY ("organization_id","execution_id") REFERENCES "actions"."action_execution"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_execution_step" ADD CONSTRAINT "action_execution_step_organization_id_execution_id_input_s_fkey" FOREIGN KEY ("organization_id","execution_id","input_step_id") REFERENCES "actions"."action_execution_step"("organization_id","execution_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_listing_content" ADD CONSTRAINT "actionsSchema_action_listing_content_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_listing_content" ADD CONSTRAINT "action_listing_content_organization_id_revision_id_fkey" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_market_competitor" ADD CONSTRAINT "actionsSchema_action_market_competitor_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_market_competitor" ADD CONSTRAINT "action_market_competitor_organization_id_revision_id_fkey" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_request_content"("organization_id","revision_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_market_country" ADD CONSTRAINT "actionsSchema_action_market_country_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_market_country" ADD CONSTRAINT "action_market_country_organization_id_revision_id_fkey" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_request_content"("organization_id","revision_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_media_content" ADD CONSTRAINT "actionsSchema_action_media_content_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_media_content" ADD CONSTRAINT "action_media_content_organization_id_revision_id_fkey" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_membership" ADD CONSTRAINT "actionsSchema_action_membership_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_membership" ADD CONSTRAINT "action_membership_organization_id_child_action_id_child_re_fkey" FOREIGN KEY ("organization_id","child_action_id","child_revision_id") REFERENCES "actions"."action_revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_membership" ADD CONSTRAINT "action_membership_organization_id_parent_revision_id_fkey" FOREIGN KEY ("organization_id","parent_revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_policy_revision" ADD CONSTRAINT "actionsSchema_action_policy_revision_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_policy_revision" ADD CONSTRAINT "action_policy_revision_asset_id_fkey" FOREIGN KEY ("asset_id") REFERENCES "public"."asset"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_policy_revision" ADD CONSTRAINT "action_policy_revision_organization_id_granted_by_command__fkey" FOREIGN KEY ("organization_id","granted_by_command_id") REFERENCES "actions"."action_command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_policy_revision" ADD CONSTRAINT "action_policy_revision_organization_id_revoked_by_command__fkey" FOREIGN KEY ("organization_id","revoked_by_command_id") REFERENCES "actions"."action_command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_read" ADD CONSTRAINT "actionsSchema_action_read_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_read" ADD CONSTRAINT "action_read_organization_id_action_id_fkey" FOREIGN KEY ("organization_id","action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_read" ADD CONSTRAINT "action_read_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_request_content" ADD CONSTRAINT "actionsSchema_action_request_content_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_request_content" ADD CONSTRAINT "action_request_content_organization_id_revision_id_fkey" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_request_content" ADD CONSTRAINT "action_request_content_requested_agent_id_fkey" FOREIGN KEY ("requested_agent_id") REFERENCES "public"."agent"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_resource_guard" ADD CONSTRAINT "action_resource_guard_holder_organization_id_holder_execut_fkey" FOREIGN KEY ("holder_organization_id","holder_execution_id") REFERENCES "actions"."action_execution"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_review_content" ADD CONSTRAINT "actionsSchema_action_review_content_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_review_content" ADD CONSTRAINT "action_review_content_organization_id_original_ai_revision_fkey" FOREIGN KEY ("organization_id","original_ai_revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_review_content" ADD CONSTRAINT "action_review_content_organization_id_revision_id_fkey" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision" ADD CONSTRAINT "actionsSchema_action_revision_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision" ADD CONSTRAINT "action_revision_organization_id_action_id_baseline_revisio_fkey" FOREIGN KEY ("organization_id","action_id","baseline_revision_id") REFERENCES "actions"."action_revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision" ADD CONSTRAINT "action_revision_organization_id_action_id_fkey" FOREIGN KEY ("organization_id","action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision" ADD CONSTRAINT "action_revision_organization_id_action_id_generated_from_r_fkey" FOREIGN KEY ("organization_id","action_id","generated_from_revision_id") REFERENCES "actions"."action_revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision" ADD CONSTRAINT "action_revision_organization_id_authored_command_id_fkey" FOREIGN KEY ("organization_id","authored_command_id") REFERENCES "actions"."action_command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision_source" ADD CONSTRAINT "actionsSchema_action_revision_source_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision_source" ADD CONSTRAINT "action_revision_source_organization_id_revision_id_fkey" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision_source" ADD CONSTRAINT "action_revision_source_organization_id_source_action_id_fkey" FOREIGN KEY ("organization_id","source_action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision_source" ADD CONSTRAINT "action_revision_source_source_agent_run_id_fkey" FOREIGN KEY ("source_agent_run_id") REFERENCES "public"."agent_run"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision_source" ADD CONSTRAINT "action_revision_source_source_backlog_id_fkey" FOREIGN KEY ("source_backlog_id") REFERENCES "public"."opportunity_backlog"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision_source" ADD CONSTRAINT "action_revision_source_source_experiment_id_fkey" FOREIGN KEY ("source_experiment_id") REFERENCES "public"."aso_experiment"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision_source" ADD CONSTRAINT "action_revision_source_source_recommendation_id_fkey" FOREIGN KEY ("source_recommendation_id") REFERENCES "public"."aso_recommendation"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision_source" ADD CONSTRAINT "action_revision_source_source_report_version_id_fkey" FOREIGN KEY ("source_report_version_id") REFERENCES "public"."report_version"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_revision_source" ADD CONSTRAINT "action_revision_source_source_variant_id_fkey" FOREIGN KEY ("source_variant_id") REFERENCES "public"."aso_recommendation_variant"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" ADD CONSTRAINT "appStoreConnectSchema_attempt_receipt_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" ADD CONSTRAINT "attempt_receipt_app_store_connect_owner_fk" FOREIGN KEY ("organization_id","attempt_id") REFERENCES "actions"."action_execution_attempt"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_store_connect"."listing_contract" ADD CONSTRAINT "appStoreConnectSchema_listing_contract_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_store_connect"."listing_contract" ADD CONSTRAINT "listing_contract_app_store_connect_owner_fk" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_listing_content"("organization_id","revision_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_store_connect"."listing_contract" ADD CONSTRAINT "asc_listing_header_media_fk" FOREIGN KEY ("organization_id","revision_id","app_clip_header_media_slot") REFERENCES "actions"."action_media_content"("organization_id","revision_id","slot") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_store_connect"."step_contract" ADD CONSTRAINT "appStoreConnectSchema_step_contract_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_store_connect"."step_contract" ADD CONSTRAINT "step_contract_app_store_connect_owner_fk" FOREIGN KEY ("organization_id","step_id") REFERENCES "actions"."action_execution_step"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_store_connect"."step_contract" ADD CONSTRAINT "asc_step_source_reserve_attempt_fk" FOREIGN KEY ("organization_id","source_reserve_attempt_id") REFERENCES "actions"."action_execution_attempt"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "apple_ads"."action_content" ADD CONSTRAINT "appleAdsSchema_action_content_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "apple_ads"."action_content" ADD CONSTRAINT "action_ad_content_organization_id_revision_id_fkey" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "apple_ads"."attempt_receipt" ADD CONSTRAINT "appleAdsSchema_attempt_receipt_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "apple_ads"."attempt_receipt" ADD CONSTRAINT "attempt_receipt_apple_ads_owner_fk" FOREIGN KEY ("organization_id","attempt_id") REFERENCES "actions"."action_execution_attempt"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "google_play"."attempt_receipt" ADD CONSTRAINT "googlePlaySchema_attempt_receipt_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "google_play"."attempt_receipt" ADD CONSTRAINT "attempt_receipt_google_play_owner_fk" FOREIGN KEY ("organization_id","attempt_id") REFERENCES "actions"."action_execution_attempt"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "google_play"."listing_contract" ADD CONSTRAINT "googlePlaySchema_listing_contract_org_erase_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "google_play"."listing_contract" ADD CONSTRAINT "listing_contract_google_play_owner_fk" FOREIGN KEY ("organization_id","revision_id") REFERENCES "actions"."action_listing_content"("organization_id","revision_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "action_open_scope" ON "actions"."action" USING btree ("organization_id","decision","created_at" DESC NULLS LAST,"id" DESC NULLS LAST) WHERE (archived_at IS NULL);--> statement-breakpoint
CREATE INDEX "action_owner_scope" ON "actions"."action" USING btree ("organization_id","owner_user_id","created_at" DESC NULLS LAST,"id" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "action_scope_page" ON "actions"."action" USING btree ("organization_id","created_at" DESC NULLS LAST,"id" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "action_command_target_timeline" ON "actions"."action_command_target" USING btree ("action_id","result_version","command_id");--> statement-breakpoint
CREATE UNIQUE INDEX "target_one_change_per_version" ON "actions"."action_command_target" USING btree ("action_id","result_version") WHERE ((previous_version IS NULL) OR (result_version <> previous_version));--> statement-breakpoint
CREATE INDEX "action_execution_due" ON "actions"."action_execution" USING btree ("next_run_at","id") WHERE (phase = ANY (ARRAY['ready'::actions.action_execution_phase, 'verification_due'::actions.action_execution_phase, 'uncertain'::actions.action_execution_phase]));--> statement-breakpoint
CREATE INDEX "action_execution_expired_claim" ON "actions"."action_execution" USING btree ("claim_expires_at","id") WHERE (phase = 'claimed'::actions.action_execution_phase);--> statement-breakpoint
CREATE INDEX "action_attempt_step_history" ON "actions"."action_execution_attempt" USING btree ("step_id","number");--> statement-breakpoint
CREATE UNIQUE INDEX "action_late_evidence_replay" ON "actions"."action_execution_attempt" USING btree ("subject_attempt_id","evidence_command_id") WHERE (kind = 'late_evidence'::actions.action_attempt_kind);--> statement-breakpoint
CREATE UNIQUE INDEX "action_one_active_attempt_per_execution" ON "actions"."action_execution_attempt" USING btree ("execution_id") WHERE ((finished_at IS NULL) AND (kind <> 'late_evidence'::actions.action_attempt_kind));--> statement-breakpoint
CREATE UNIQUE INDEX "action_execution_step_native_key" ON "actions"."action_execution_step" USING btree ("native_idempotency_key") WHERE (native_idempotency_key IS NOT NULL);--> statement-breakpoint
CREATE UNIQUE INDEX "action_execution_step_single_effect" ON "actions"."action_execution_step" USING btree ("execution_id","kind") WHERE (kind <> 'asc_app_clip_header_upload_chunk'::actions.action_step_kind);--> statement-breakpoint
CREATE INDEX "action_membership_child" ON "actions"."action_membership" USING btree ("child_action_id","parent_revision_id");--> statement-breakpoint
CREATE UNIQUE INDEX "action_policy_one_active" ON "actions"."action_policy_revision" USING btree ("organization_id","asset_id","policy_kind") WHERE (revoked_at IS NULL);--> statement-breakpoint
CREATE UNIQUE INDEX "action_resource_guard_store_target" ON "actions"."action_resource_guard" USING btree ("provider","remote_application_id") WHERE scope = 'store_application'::actions.action_resource_scope;--> statement-breakpoint
CREATE UNIQUE INDEX "action_resource_guard_ads_target" ON "actions"."action_resource_guard" USING btree ("provider","provider_account_id") WHERE scope = 'advertising_account'::actions.action_resource_scope;--> statement-breakpoint
CREATE INDEX "action_revision_source_owner" ON "actions"."action_revision_source" USING btree ("organization_id","revision_id");--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action" AS PERMISSIVE FOR ALL TO public USING ("actions"."action"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_advisory_content" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_advisory_content"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_advisory_content"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_alias" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_alias"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_alias"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_approval" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_approval"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_approval"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_command" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_command"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_command"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_command_target" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_command_target"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_command_target"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_content_note" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_content_note"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_content_note"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_content_term" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_content_term"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_content_term"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_dependency" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_dependency"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_dependency"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_execution" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_execution"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_execution"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_execution_attempt" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_execution_attempt"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_execution_attempt"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_execution_step" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_execution_step"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_execution_step"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_listing_content" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_listing_content"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_listing_content"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_market_competitor" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_market_competitor"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_market_competitor"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_market_country" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_market_country"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_market_country"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_media_content" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_media_content"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_media_content"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_membership" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_membership"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_membership"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_policy_revision" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_policy_revision"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_policy_revision"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_read" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_read"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_read"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_request_content" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_request_content"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_request_content"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_review_content" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_review_content"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_review_content"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_revision" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_revision"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_revision"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action_revision_source" AS PERMISSIVE FOR ALL TO public USING ("actions"."action_revision_source"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action_revision_source"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "app_store_connect"."attempt_receipt" AS PERMISSIVE FOR ALL TO public USING ("app_store_connect"."attempt_receipt"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("app_store_connect"."attempt_receipt"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "app_store_connect"."listing_contract" AS PERMISSIVE FOR ALL TO public USING ("app_store_connect"."listing_contract"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("app_store_connect"."listing_contract"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "app_store_connect"."step_contract" AS PERMISSIVE FOR ALL TO public USING ("app_store_connect"."step_contract"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("app_store_connect"."step_contract"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "apple_ads"."action_content" AS PERMISSIVE FOR ALL TO public USING ("apple_ads"."action_content"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("apple_ads"."action_content"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "apple_ads"."attempt_receipt" AS PERMISSIVE FOR ALL TO public USING ("apple_ads"."attempt_receipt"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("apple_ads"."attempt_receipt"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "google_play"."attempt_receipt" AS PERMISSIVE FOR ALL TO public USING ("google_play"."attempt_receipt"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("google_play"."attempt_receipt"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "google_play"."listing_contract" AS PERMISSIVE FOR ALL TO public USING ("google_play"."listing_contract"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("google_play"."listing_contract"."organization_id" = current_setting('fload.organization_id', true));
--> statement-breakpoint
-- Durable Actions invariants. No source-data rewrite occurs in this migration.
--> statement-breakpoint
SET search_path=actions,apple_ads,app_store_connect,google_play,public;
--> statement-breakpoint
ALTER TABLE actions.action ALTER CONSTRAINT "action_last_command_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action ALTER CONSTRAINT "action_organization_id_id_current_approval_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action ALTER CONSTRAINT "action_organization_id_id_current_revision_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action ALTER CONSTRAINT "action_organization_id_parent_action_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action ALTER CONSTRAINT "action_organization_id_successor_action_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_alias ALTER CONSTRAINT "action_alias_organization_id_action_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_approval ALTER CONSTRAINT "action_approval_organization_id_action_id_revision_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_approval ALTER CONSTRAINT "action_approval_organization_id_command_id_action_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_approval ALTER CONSTRAINT "action_approval_organization_id_parent_revision_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_approval ALTER CONSTRAINT "action_approval_organization_id_policy_revision_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_approval ALTER CONSTRAINT "approval_exact_membership_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_command ALTER CONSTRAINT "action_command_organization_id_actor_policy_revision_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_command ALTER CONSTRAINT "action_command_organization_id_target_policy_revision_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_command_target ALTER CONSTRAINT "action_command_target_organization_id_action_id_expected_r_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_command_target ALTER CONSTRAINT "action_command_target_organization_id_action_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_command_target ALTER CONSTRAINT "action_command_target_organization_id_action_id_previous_r_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_command_target ALTER CONSTRAINT "action_command_target_organization_id_action_id_result_rev_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_command_target ALTER CONSTRAINT "action_command_target_organization_id_command_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_command_target ALTER CONSTRAINT "action_command_target_organization_id_expected_parent_revi_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_command_target ALTER CONSTRAINT "target_previous_approval_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_command_target ALTER CONSTRAINT "target_result_approval_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_dependency ALTER CONSTRAINT "action_dependency_organization_id_created_command_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_dependency ALTER CONSTRAINT "action_dependency_organization_id_dependent_action_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_dependency ALTER CONSTRAINT "action_dependency_organization_id_prerequisite_action_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution ALTER CONSTRAINT "action_execution_cancel_command_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution ALTER CONSTRAINT "action_execution_organization_id_approval_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution ALTER CONSTRAINT "action_execution_organization_id_id_next_step_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution_attempt ALTER CONSTRAINT "action_attempt_evidence_command" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution_attempt ALTER CONSTRAINT "action_attempt_input_same_execution" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution_attempt ALTER CONSTRAINT "action_attempt_output_revision" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution_attempt ALTER CONSTRAINT "action_attempt_step_execution" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution_attempt ALTER CONSTRAINT "action_attempt_subject_same_step" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution_attempt ALTER CONSTRAINT "action_execution_attempt_organization_id_observation_revis_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution_attempt ALTER CONSTRAINT "action_execution_attempt_organization_id_step_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution_attempt ALTER CONSTRAINT "action_execution_attempt_organization_id_subject_attempt_i_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution_step ALTER CONSTRAINT "action_execution_step_organization_id_content_revision_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution_step ALTER CONSTRAINT "action_execution_step_organization_id_execution_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_execution_step ALTER CONSTRAINT "action_execution_step_organization_id_execution_id_input_s_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_membership ALTER CONSTRAINT "action_membership_organization_id_child_action_id_child_re_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_membership ALTER CONSTRAINT "action_membership_organization_id_parent_revision_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_policy_revision ALTER CONSTRAINT "action_policy_revision_organization_id_granted_by_command__fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_policy_revision ALTER CONSTRAINT "action_policy_revision_organization_id_revoked_by_command__fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_read ALTER CONSTRAINT "action_read_organization_id_action_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_resource_guard ALTER CONSTRAINT "action_resource_guard_holder_organization_id_holder_execut_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_revision ALTER CONSTRAINT "action_revision_organization_id_action_id_baseline_revisio_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_revision ALTER CONSTRAINT "action_revision_organization_id_action_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_revision ALTER CONSTRAINT "action_revision_organization_id_action_id_generated_from_r_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.action_revision ALTER CONSTRAINT "action_revision_organization_id_authored_command_id_fkey" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE app_store_connect.listing_contract ALTER CONSTRAINT "listing_contract_app_store_connect_owner_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE app_store_connect.listing_contract ALTER CONSTRAINT "asc_listing_header_media_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE google_play.listing_contract ALTER CONSTRAINT "listing_contract_google_play_owner_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE app_store_connect.step_contract ALTER CONSTRAINT "step_contract_app_store_connect_owner_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE app_store_connect.step_contract ALTER CONSTRAINT "asc_step_source_reserve_attempt_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE app_store_connect.attempt_receipt ALTER CONSTRAINT "attempt_receipt_app_store_connect_owner_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE google_play.attempt_receipt ALTER CONSTRAINT "attempt_receipt_google_play_owner_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE apple_ads.attempt_receipt ALTER CONSTRAINT "attempt_receipt_apple_ads_owner_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
CREATE VIEW actions.action_listing_contract WITH (security_invoker=true) AS
SELECT
 base.organization_id AS organization_id,
 base.revision_id AS revision_id,
 coalesce(asc_contract.provider_account_id,play.provider_account_id) AS provider_account_id,
 base.store AS store,
 base.locale AS locale,
 base.intent AS intent,
 asc_contract.provider_app_id AS provider_app_id,
 play.package_name AS package_name,
 asc_contract.app_info_id AS app_info_id,
 asc_contract.app_info_localization_id AS app_info_localization_id,
 asc_contract.app_version_id AS app_version_id,
 asc_contract.app_version_localization_id AS app_version_localization_id,
 play.google_edit_id AS google_edit_id,
 base.title_state AS title_state,
 base.title AS title,
 base.subtitle_state AS subtitle_state,
 base.subtitle AS subtitle,
 base.description_state AS description_state,
 base.description AS description,
 base.keywords_state AS keywords_state,
 base.keywords AS keywords,
 base.promotional_text_state AS promotional_text_state,
 base.promotional_text AS promotional_text,
 base.short_description_state AS short_description_state,
 base.short_description AS short_description,
 base.whats_new_state AS whats_new_state,
 base.whats_new AS whats_new,
 base.support_url_state AS support_url_state,
 base.support_url AS support_url,
 base.keyword_analysis AS keyword_analysis,
 base.operator_instructions AS operator_instructions,
 base.source_fingerprint AS source_fingerprint,
 base.naturalness_check_skipped AS naturalness_check_skipped,
 base.fidelity_check_skipped AS fidelity_check_skipped,
 base.english_title AS english_title,
 base.english_subtitle AS english_subtitle,
 base.english_promotional_text AS english_promotional_text,
 base.gloss_status AS gloss_status,
 base.research_country AS research_country,
 base.research_coverage AS research_coverage,
 base.research_model_source AS research_model_source,
 base.research_model_version AS research_model_version,
 base.research_model_formula AS research_model_formula,
 base.app_tier AS app_tier,
 base.app_tier_resolved AS app_tier_resolved,
 base.candidate_count AS candidate_count,
 base.judged_count AS judged_count,
 base.scored_count AS scored_count,
 base.p0_count AS p0_count,
 base.p1_count AS p1_count,
 base.p2_count AS p2_count,
 base.with_volume_count AS with_volume_count,
 base.conformance_term_count AS conformance_term_count,
 base.conformance_from_table_count AS conformance_from_table_count,
 base.observation_availability AS observation_availability,
 base.observation_captured_at AS observation_captured_at,
 base.source_capture_at AS source_capture_at,
 play.play_commit_policy AS play_commit_policy,
 coalesce(asc_contract.app_clip_operation,'none'::app_store_connect.app_clip_operation) AS app_clip_operation,
 asc_contract.app_clip_id AS app_clip_id,
 asc_contract.app_clip_experience_id AS app_clip_experience_id,
 asc_contract.app_clip_release_version_id AS app_clip_release_version_id,
 asc_contract.app_clip_localization_id AS app_clip_localization_id,
 asc_contract.app_clip_source_localization_id AS app_clip_source_localization_id,
 asc_contract.app_clip_subtitle AS app_clip_subtitle,
 asc_contract.app_clip_header_media_slot AS app_clip_header_media_slot,
 base.provider_version_state AS provider_version_state,
 asc_contract.live_promotional_version_id AS live_promotional_version_id,
 asc_contract.live_promotional_localization_id AS live_promotional_localization_id,
 coalesce(asc_contract.live_promotional_text_state,'unspecified'::actions.content_value_state) AS live_promotional_text_state,
 asc_contract.live_promotional_text AS live_promotional_text,
 asc_contract.app_clip_incomplete_header_id AS app_clip_incomplete_header_id,
 asc_contract.app_clip_header_state AS app_clip_header_state
FROM actions.action_listing_content base
LEFT JOIN app_store_connect.listing_contract asc_contract ON asc_contract.organization_id=base.organization_id AND asc_contract.revision_id=base.revision_id
LEFT JOIN google_play.listing_contract play ON play.organization_id=base.organization_id AND play.revision_id=base.revision_id;
--> statement-breakpoint
CREATE VIEW actions.action_execution_step_contract WITH (security_invoker=true) AS
SELECT
 base.id AS id,
 base.organization_id AS organization_id,
 base.execution_id AS execution_id,
 base.ordinal AS ordinal,
 base.kind AS kind,
 base.adapter_version AS adapter_version,
 base.input_step_id AS input_step_id,
 base.content_revision_id AS content_revision_id,
 asc_contract.media_slot AS media_slot,
 asc_contract.upload_offset AS upload_offset,
 asc_contract.upload_length AS upload_length,
 base.recovery_mode AS recovery_mode,
 base.recovery_policy_version AS recovery_policy_version,
 base.native_idempotency_key AS native_idempotency_key,
 base.required_surface AS required_surface,
 asc_contract.source_reserve_attempt_id AS source_reserve_attempt_id,
 asc_contract.upload_url_ciphertext AS upload_url_ciphertext,
 asc_contract.upload_method AS upload_method,
 asc_contract.upload_content_type AS upload_content_type,
 base.verification_timing AS verification_timing
FROM actions.action_execution_step base
LEFT JOIN app_store_connect.step_contract asc_contract ON asc_contract.organization_id=base.organization_id AND asc_contract.step_id=base.id;
--> statement-breakpoint
CREATE FUNCTION actions.project_execution_step(candidate actions.action_execution_step) RETURNS actions.action_execution_step_contract LANGUAGE sql STABLE SET search_path=actions,app_store_connect,google_play,apple_ads,public AS $$
SELECT
 base.id AS id,
 base.organization_id AS organization_id,
 base.execution_id AS execution_id,
 base.ordinal AS ordinal,
 base.kind AS kind,
 base.adapter_version AS adapter_version,
 base.input_step_id AS input_step_id,
 base.content_revision_id AS content_revision_id,
 asc_contract.media_slot AS media_slot,
 asc_contract.upload_offset AS upload_offset,
 asc_contract.upload_length AS upload_length,
 base.recovery_mode AS recovery_mode,
 base.recovery_policy_version AS recovery_policy_version,
 base.native_idempotency_key AS native_idempotency_key,
 base.required_surface AS required_surface,
 asc_contract.source_reserve_attempt_id AS source_reserve_attempt_id,
 asc_contract.upload_url_ciphertext AS upload_url_ciphertext,
 asc_contract.upload_method AS upload_method,
 asc_contract.upload_content_type AS upload_content_type,
 base.verification_timing AS verification_timing
FROM (SELECT (candidate).*) base
LEFT JOIN app_store_connect.step_contract asc_contract ON asc_contract.organization_id=base.organization_id AND asc_contract.step_id=base.id
$$;
--> statement-breakpoint
CREATE VIEW actions.action_execution_attempt_contract WITH (security_invoker=true) AS
SELECT
 base.id AS id,
 base.organization_id AS organization_id,
 base.step_id AS step_id,
 base.number AS number,
 base.kind AS kind,
 base.claim_generation AS claim_generation,
 base.subject_attempt_id AS subject_attempt_id,
 base.agent_run_id AS agent_run_id,
 base.connector_id AS connector_id,
 base.transport AS transport,
 base.started_at AS started_at,
 base.finished_at AS finished_at,
 base.result AS result,
 base.observation_revision_id AS observation_revision_id,
 base.comparison_version AS comparison_version,
 coalesce(asc_contract.provider_request_id,play.provider_request_id,asa.provider_request_id) AS provider_request_id,
 coalesce(asc_contract.provider_resource_id,play.provider_resource_id,asa.provider_resource_id) AS provider_resource_id,
 play.provider_edit_id AS provider_edit_id,
 asc_contract.provider_localization_id AS provider_localization_id,
 asc_contract.provider_media_id AS provider_media_id,
 coalesce(asc_contract.provider_error_code,play.provider_error_code,asa.provider_error_code) AS provider_error_code,
 base.failure_class AS failure_class,
 base.recorded_at AS recorded_at,
 base.execution_id AS execution_id,
 base.claim_token AS claim_token,
 base.input_attempt_id AS input_attempt_id,
 base.input_parent_revision_id AS input_parent_revision_id,
 base.output_kind AS output_kind,
 base.output_revision_id AS output_revision_id,
 base.output_review_analysis_id AS output_review_analysis_id,
 base.output_agent_run_id AS output_agent_run_id,
 base.no_work_reason AS no_work_reason,
 base.finalized_claim_generation AS finalized_claim_generation,
 base.finalized_claim_token AS finalized_claim_token,
 base.evidence_command_id AS evidence_command_id,
 base.observation_surface AS observation_surface,
 base.observation_completeness AS observation_completeness,
 base.observed_at AS observed_at,
 base.non_application_basis AS non_application_basis,
 play.provider_edit_expires_at AS provider_edit_expires_at,
 base.retry_disposition AS retry_disposition,
 base.uncertainty_reason AS uncertainty_reason,
 base.unreadable_reason AS unreadable_reason
FROM actions.action_execution_attempt base
LEFT JOIN app_store_connect.attempt_receipt asc_contract ON asc_contract.organization_id=base.organization_id AND asc_contract.attempt_id=base.id
LEFT JOIN google_play.attempt_receipt play ON play.organization_id=base.organization_id AND play.attempt_id=base.id
LEFT JOIN apple_ads.attempt_receipt asa ON asa.organization_id=base.organization_id AND asa.attempt_id=base.id;
--> statement-breakpoint
CREATE FUNCTION actions.project_execution_attempt(candidate actions.action_execution_attempt) RETURNS actions.action_execution_attempt_contract LANGUAGE sql STABLE SET search_path=actions,app_store_connect,google_play,apple_ads,public AS $$
SELECT
 base.id AS id,
 base.organization_id AS organization_id,
 base.step_id AS step_id,
 base.number AS number,
 base.kind AS kind,
 base.claim_generation AS claim_generation,
 base.subject_attempt_id AS subject_attempt_id,
 base.agent_run_id AS agent_run_id,
 base.connector_id AS connector_id,
 base.transport AS transport,
 base.started_at AS started_at,
 base.finished_at AS finished_at,
 base.result AS result,
 base.observation_revision_id AS observation_revision_id,
 base.comparison_version AS comparison_version,
 coalesce(asc_contract.provider_request_id,play.provider_request_id,asa.provider_request_id) AS provider_request_id,
 coalesce(asc_contract.provider_resource_id,play.provider_resource_id,asa.provider_resource_id) AS provider_resource_id,
 play.provider_edit_id AS provider_edit_id,
 asc_contract.provider_localization_id AS provider_localization_id,
 asc_contract.provider_media_id AS provider_media_id,
 coalesce(asc_contract.provider_error_code,play.provider_error_code,asa.provider_error_code) AS provider_error_code,
 base.failure_class AS failure_class,
 base.recorded_at AS recorded_at,
 base.execution_id AS execution_id,
 base.claim_token AS claim_token,
 base.input_attempt_id AS input_attempt_id,
 base.input_parent_revision_id AS input_parent_revision_id,
 base.output_kind AS output_kind,
 base.output_revision_id AS output_revision_id,
 base.output_review_analysis_id AS output_review_analysis_id,
 base.output_agent_run_id AS output_agent_run_id,
 base.no_work_reason AS no_work_reason,
 base.finalized_claim_generation AS finalized_claim_generation,
 base.finalized_claim_token AS finalized_claim_token,
 base.evidence_command_id AS evidence_command_id,
 base.observation_surface AS observation_surface,
 base.observation_completeness AS observation_completeness,
 base.observed_at AS observed_at,
 base.non_application_basis AS non_application_basis,
 play.provider_edit_expires_at AS provider_edit_expires_at,
 base.retry_disposition AS retry_disposition,
 base.uncertainty_reason AS uncertainty_reason,
 base.unreadable_reason AS unreadable_reason
FROM (SELECT (candidate).*) base
LEFT JOIN app_store_connect.attempt_receipt asc_contract ON asc_contract.organization_id=base.organization_id AND asc_contract.attempt_id=base.id
LEFT JOIN google_play.attempt_receipt play ON play.organization_id=base.organization_id AND play.attempt_id=base.id
LEFT JOIN apple_ads.attempt_receipt asa ON asa.organization_id=base.organization_id AND asa.attempt_id=base.id
$$;
--> statement-breakpoint
CREATE FUNCTION actions.assert_listing_contract(p_revision text) RETURNS void LANGUAGE plpgsql SET search_path=actions,app_store_connect,google_play,apple_ads,public AS $$
DECLARE ok boolean; r actions.action_listing_contract;
BEGIN
 SELECT * INTO r FROM actions.action_listing_contract WHERE revision_id=p_revision;
 IF NOT FOUND THEN RETURN; END IF;
 IF (r.store='ios' AND (NOT EXISTS(SELECT 1 FROM app_store_connect.listing_contract WHERE organization_id=r.organization_id AND revision_id=r.revision_id) OR EXISTS(SELECT 1 FROM google_play.listing_contract WHERE organization_id=r.organization_id AND revision_id=r.revision_id)))
 OR (r.store='android' AND (NOT EXISTS(SELECT 1 FROM google_play.listing_contract WHERE organization_id=r.organization_id AND revision_id=r.revision_id) OR EXISTS(SELECT 1 FROM app_store_connect.listing_contract WHERE organization_id=r.organization_id AND revision_id=r.revision_id)))
 THEN RAISE EXCEPTION 'listing requires exactly its store contract' USING ERRCODE='23514'; END IF;
 SELECT (app_clip_operation = 'none'::app_store_connect.app_clip_operation AND app_clip_incomplete_header_id IS NULL AND app_clip_header_state IS NULL OR (app_clip_operation = ANY (ARRAY['create_localization'::app_store_connect.app_clip_operation, 'repair_header'::app_store_connect.app_clip_operation, 'observed'::app_store_connect.app_clip_operation])) AND (app_clip_incomplete_header_id IS NULL OR length(app_clip_incomplete_header_id) > 0) AND (app_clip_header_state IS NULL OR app_clip_operation = 'observed'::app_store_connect.app_clip_operation) AND (app_clip_header_state IS DISTINCT FROM 'incomplete'::app_store_connect.app_clip_header_state OR app_clip_incomplete_header_id IS NOT NULL)) INTO ok FROM actions.action_listing_contract WHERE revision_id=p_revision;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates listing_clip_observed_header' USING ERRCODE='23514'; END IF;
 SELECT (app_clip_operation <> 'repair_header'::app_store_connect.app_clip_operation OR app_clip_localization_id IS NOT NULL) INTO ok FROM actions.action_listing_contract WHERE revision_id=p_revision;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates listing_clip_repair_target' USING ERRCODE='23514'; END IF;
 SELECT (app_clip_operation <> 'create_localization'::app_store_connect.app_clip_operation OR app_clip_subtitle IS NOT NULL AND length(app_clip_subtitle) > 0) INTO ok FROM actions.action_listing_contract WHERE revision_id=p_revision;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates listing_clip_subtitle' USING ERRCODE='23514'; END IF;
 SELECT (app_clip_operation = 'none'::app_store_connect.app_clip_operation AND app_clip_id IS NULL AND app_clip_experience_id IS NULL AND app_clip_release_version_id IS NULL AND app_clip_localization_id IS NULL AND app_clip_source_localization_id IS NULL AND app_clip_subtitle IS NULL AND app_clip_header_media_slot IS NULL OR app_clip_operation <> 'none'::app_store_connect.app_clip_operation AND store = 'ios'::actions.store_kind AND app_clip_id IS NOT NULL AND app_clip_experience_id IS NOT NULL AND app_clip_release_version_id IS NOT NULL AND (app_clip_operation = 'observed'::app_store_connect.app_clip_operation OR app_clip_header_media_slot IS NOT NULL)) INTO ok FROM actions.action_listing_contract WHERE revision_id=p_revision;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates listing_clip_target' USING ERRCODE='23514'; END IF;
 SELECT (app_clip_subtitle IS NULL OR actions.utf16_length(app_clip_subtitle) <= 56) INTO ok FROM actions.action_listing_contract WHERE revision_id=p_revision;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates listing_clip_utf16_limit' USING ERRCODE='23514'; END IF;
 SELECT (live_promotional_text_state = 'present'::actions.content_value_state AND live_promotional_text IS NOT NULL AND length(live_promotional_text) > 0 OR live_promotional_text_state = 'empty'::actions.content_value_state AND live_promotional_text IS NOT NULL AND live_promotional_text = ''::text OR (live_promotional_text_state = ANY (ARRAY['unspecified'::actions.content_value_state, 'unreadable'::actions.content_value_state])) AND live_promotional_text IS NULL) INTO ok FROM actions.action_listing_contract WHERE revision_id=p_revision;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates listing_live_promo_observed_value' USING ERRCODE='23514'; END IF;
 SELECT (live_promotional_version_id IS NULL AND live_promotional_localization_id IS NULL OR store = 'ios'::actions.store_kind AND live_promotional_version_id IS NOT NULL AND length(live_promotional_version_id) > 0 AND live_promotional_localization_id IS NOT NULL AND length(live_promotional_localization_id) > 0) INTO ok FROM actions.action_listing_contract WHERE revision_id=p_revision;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates listing_live_promo_target' USING ERRCODE='23514'; END IF;
 SELECT (live_promotional_text_state = 'unspecified'::actions.content_value_state OR live_promotional_version_id IS NOT NULL) INTO ok FROM actions.action_listing_contract WHERE revision_id=p_revision;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates listing_live_promo_value_target' USING ERRCODE='23514'; END IF;
 SELECT (store = 'android'::actions.store_kind OR play_commit_policy IS NULL) INTO ok FROM actions.action_listing_contract WHERE revision_id=p_revision;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates listing_play_policy_store' USING ERRCODE='23514'; END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.assert_step_contract(projected actions.action_execution_step_contract) RETURNS void LANGUAGE plpgsql SET search_path=actions,app_store_connect,google_play,apple_ads,public AS $$
DECLARE ok boolean;
BEGIN
 IF projected.media_slot IS NOT NULL AND NOT EXISTS(SELECT 1 FROM actions.action_media_content WHERE organization_id=projected.organization_id AND revision_id=projected.content_revision_id AND slot=projected.media_slot)
 THEN RAISE EXCEPTION 'step media must belong to its approved revision' USING ERRCODE='23514'; END IF;
 SELECT ((upload_offset IS NULL) = (upload_length IS NULL)) INTO ok FROM (SELECT (projected).*) provider_contract;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates action_execution_step_check2' USING ERRCODE='23514'; END IF;
 SELECT ((kind = 'asc_app_clip_header_upload_chunk'::actions.action_step_kind) = (upload_offset IS NOT NULL)) INTO ok FROM (SELECT (projected).*) provider_contract;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates action_execution_step_chunk_shape' USING ERRCODE='23514'; END IF;
 SELECT ((kind = ANY (ARRAY['asc_app_clip_header_reserve'::actions.action_step_kind, 'asc_app_clip_header_upload_chunk'::actions.action_step_kind, 'asc_app_clip_header_commit'::actions.action_step_kind])) = (media_slot IS NOT NULL)) INTO ok FROM (SELECT (projected).*) provider_contract;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates action_execution_step_media_shape' USING ERRCODE='23514'; END IF;
 SELECT (media_slot >= 0) INTO ok FROM (SELECT (projected).*) provider_contract;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates action_execution_step_media_slot_check' USING ERRCODE='23514'; END IF;
 SELECT (upload_length > 0) INTO ok FROM (SELECT (projected).*) provider_contract;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates action_execution_step_upload_length_check' USING ERRCODE='23514'; END IF;
 SELECT (upload_offset >= 0) INTO ok FROM (SELECT (projected).*) provider_contract;
 IF ok IS FALSE THEN RAISE EXCEPTION 'provider contract violates action_execution_step_upload_offset_check' USING ERRCODE='23514'; END IF;
END $$;
--> statement-breakpoint

CREATE FUNCTION actions.guard_provider_fact_insert() RETURNS trigger LANGUAGE plpgsql
SET search_path=actions,app_store_connect,google_play,apple_ads,public AS $$
DECLARE parent actions.action_execution_attempt; execution actions.action_execution;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF TG_OP<>'INSERT' THEN RAISE EXCEPTION 'provider contract and evidence are immutable' USING ERRCODE='23514'; END IF;
 IF TG_TABLE_NAME='attempt_receipt' THEN
  SELECT * INTO parent FROM actions.action_execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.attempt_id FOR UPDATE;
  IF FOUND AND parent.finished_at IS NOT NULL THEN RAISE EXCEPTION 'append late evidence instead of changing a finished attempt' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE FUNCTION actions.provider_fact_complete_at_commit() RETURNS trigger LANGUAGE plpgsql
SET search_path=actions,app_store_connect,google_play,apple_ads,public AS $$
DECLARE a actions.action_execution_attempt; s actions.action_execution_step; count_receipts integer;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF TG_TABLE_NAME='step_contract' THEN
  SELECT * INTO s FROM actions.action_execution_step WHERE organization_id=NEW.organization_id AND id=NEW.step_id;
  IF s.id IS NULL OR s.kind NOT IN ('asc_app_clip_header_reserve','asc_app_clip_header_upload_chunk','asc_app_clip_header_commit')
  THEN RAISE EXCEPTION 'ASC step contract requires its exact media effect' USING ERRCODE='23514'; END IF;
  IF s.kind='asc_app_clip_header_upload_chunk' THEN
   SELECT * INTO a FROM actions.action_execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.source_reserve_attempt_id;
   IF a.id IS NULL OR a.step_id IS DISTINCT FROM s.input_step_id OR a.execution_id IS DISTINCT FROM s.execution_id
    OR a.finished_at IS NULL OR a.result NOT IN ('acknowledged','matched')
    OR NOT EXISTS(SELECT 1 FROM app_store_connect.attempt_receipt receipt WHERE receipt.organization_id=a.organization_id AND receipt.attempt_id=a.id AND receipt.provider_media_id IS NOT NULL)
   THEN RAISE EXCEPTION 'upload manifest requires exact persisted reservation evidence' USING ERRCODE='23514'; END IF;
  END IF;
 ELSE
  SELECT * INTO a FROM actions.action_execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.attempt_id;
  IF a.id IS NULL OR a.finished_at IS NULL OR a.transport='internal'
    OR (TG_TABLE_SCHEMA='app_store_connect' AND a.transport NOT IN ('asc_api','asc_browser'))
    OR (TG_TABLE_SCHEMA='google_play' AND a.transport NOT IN ('play_api','play_session','play_browser'))
    OR (TG_TABLE_SCHEMA='apple_ads' AND a.transport<>'asa_api')
  THEN RAISE EXCEPTION 'receipt requires a finalized interaction with its exact provider' USING ERRCODE='23514'; END IF;
  SELECT (EXISTS(SELECT 1 FROM app_store_connect.attempt_receipt WHERE organization_id=a.organization_id AND attempt_id=a.id))::int
   +(EXISTS(SELECT 1 FROM google_play.attempt_receipt WHERE organization_id=a.organization_id AND attempt_id=a.id))::int
   +(EXISTS(SELECT 1 FROM apple_ads.attempt_receipt WHERE organization_id=a.organization_id AND attempt_id=a.id))::int INTO count_receipts;
  IF count_receipts<>1 THEN RAISE EXCEPTION 'attempt may have only one provider receipt' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NEW;
END $$;

--> statement-breakpoint
CREATE FUNCTION actions.require_plan_effect(p_execution text,p_kind actions.action_step_kind) RETURNS void
LANGUAGE plpgsql SET search_path=actions,app_store_connect,google_play,apple_ads,public AS $$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM actions.action_execution_step WHERE execution_id=p_execution AND kind=p_kind)
 THEN RAISE EXCEPTION 'approved effect is missing from execution plan: %',p_kind USING ERRCODE='23514'; END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.assert_plan_complete(candidate actions.action_execution) RETURNS void
LANGUAGE plpgsql SET search_path=actions,app_store_connect,google_play,apple_ads,public AS $$
DECLARE ap actions.action_approval; r actions.action_revision; listing actions.action_listing_contract; reply actions.action_review_content;
BEGIN
 SELECT * INTO STRICT ap FROM actions.action_approval WHERE organization_id=candidate.organization_id AND id=candidate.approval_id;
 SELECT * INTO STRICT r FROM actions.action_revision WHERE organization_id=ap.organization_id AND id=ap.revision_id;
 IF ap.scope='revise' THEN PERFORM actions.require_plan_effect(candidate.id,'internal_revise_content'); RETURN; END IF;
 IF ap.scope='generate' THEN
  PERFORM actions.require_plan_effect(candidate.id,CASE WHEN r.operation='review_catch_up_30d' THEN 'internal_commit_children'::actions.action_step_kind ELSE 'internal_generate_content'::actions.action_step_kind END);
  RETURN;
 END IF;
 IF r.kind='review_reply' THEN
  SELECT * INTO STRICT reply FROM actions.action_review_content WHERE organization_id=ap.organization_id AND revision_id=r.id;
  PERFORM actions.require_plan_effect(candidate.id,CASE WHEN reply.store='ios' THEN 'asc_review_response_upsert'::actions.action_step_kind ELSE 'play_review_response_set'::actions.action_step_kind END);
 ELSIF r.kind='ads' THEN
  PERFORM actions.require_plan_effect(candidate.id,CASE r.operation
   WHEN 'asa_pause_campaign' THEN 'asa_campaign_status_set'::actions.action_step_kind
   WHEN 'asa_enable_campaign' THEN 'asa_campaign_status_set'::actions.action_step_kind
   WHEN 'asa_update_campaign_budget' THEN 'asa_campaign_budget_set'::actions.action_step_kind
   WHEN 'asa_update_keyword_bid' THEN 'asa_keyword_bid_set'::actions.action_step_kind
   WHEN 'asa_create_keyword' THEN 'asa_keyword_create'::actions.action_step_kind
   WHEN 'asa_add_negative_keyword' THEN 'asa_negative_keyword_create'::actions.action_step_kind
   WHEN 'asa_delete_negative_keyword' THEN 'asa_negative_keyword_delete'::actions.action_step_kind END);
 ELSIF r.kind='listing' THEN
  SELECT * INTO STRICT listing FROM actions.action_listing_contract WHERE organization_id=ap.organization_id AND revision_id=r.id;
  IF listing.store='android' THEN
   PERFORM actions.require_plan_effect(candidate.id,'play_edit_create');
   PERFORM actions.require_plan_effect(candidate.id,'play_listing_set');
   PERFORM actions.require_plan_effect(candidate.id,'play_edit_commit');
   PERFORM actions.require_plan_effect(candidate.id,'play_inspection_edit_create');
   PERFORM actions.require_plan_effect(candidate.id,'play_inspection_edit_delete');
  ELSE
   IF actions.is_content_write(listing.title_state) OR actions.is_content_write(listing.subtitle_state) THEN
    PERFORM actions.require_plan_effect(candidate.id,'asc_app_info_localization_upsert');
   END IF;
   IF actions.is_content_write(listing.description_state) OR actions.is_content_write(listing.keywords_state)
    OR actions.is_content_write(listing.whats_new_state) OR actions.is_content_write(listing.support_url_state) THEN
    PERFORM actions.require_plan_effect(candidate.id,'asc_version_localization_upsert');
   END IF;
   IF actions.is_content_write(listing.promotional_text_state) THEN
    IF listing.live_promotional_version_id IS NOT NULL THEN PERFORM actions.require_plan_effect(candidate.id,'asc_live_promotional_text_set'); END IF;
    IF listing.app_version_id IS NOT NULL THEN
     IF r.operation='create_locale' AND listing.app_version_localization_id IS NULL THEN
      PERFORM actions.require_plan_effect(candidate.id,'asc_version_localization_upsert');
     ELSE PERFORM actions.require_plan_effect(candidate.id,'asc_editable_promotional_text_set'); END IF;
    END IF;
   END IF;
   IF listing.app_clip_operation='create_localization' THEN PERFORM actions.require_plan_effect(candidate.id,'asc_app_clip_localization_create'); END IF;
   IF listing.app_clip_operation IN ('create_localization','repair_header') THEN
    IF listing.app_clip_incomplete_header_id IS NOT NULL THEN PERFORM actions.require_plan_effect(candidate.id,'asc_app_clip_incomplete_header_delete'); END IF;
    PERFORM actions.require_plan_effect(candidate.id,'asc_app_clip_header_reserve');
    PERFORM actions.require_plan_effect(candidate.id,'asc_app_clip_header_upload_chunk');
    PERFORM actions.require_plan_effect(candidate.id,'asc_app_clip_header_commit');
    IF NOT EXISTS(SELECT 1 FROM actions.action_media_content m WHERE m.organization_id=ap.organization_id AND m.revision_id=r.id
      AND m.slot=listing.app_clip_header_media_slot AND m.byte_length>0
      AND m.byte_length=(SELECT sum(s.upload_length) FROM actions.action_execution_step_contract s WHERE s.execution_id=candidate.id
        AND s.kind='asc_app_clip_header_upload_chunk' AND s.media_slot=m.slot))
    THEN RAISE EXCEPTION 'complete App Clip plan must cover every exact approved byte' USING ERRCODE='23514'; END IF;
   END IF;
  END IF;
 ELSIF r.operation='resolve_prerequisite' THEN
  PERFORM actions.require_plan_effect(candidate.id,'internal_recheck_prerequisite');
 ELSE RAISE EXCEPTION 'unsupported approved plan content' USING ERRCODE='23514';
 END IF;
END $$;

--> statement-breakpoint
CREATE FUNCTION actions.assert_same_provider_content_target(
 p_org text, p_subject text, p_observation text
) RETURNS void LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE sr actions.action_revision%ROWTYPE;
 orr actions.action_revision%ROWTYPE;
 sreview actions.action_review_content%ROWTYPE;
 oreview actions.action_review_content%ROWTYPE;
 slisting actions.action_listing_contract%ROWTYPE;
 olisting actions.action_listing_contract%ROWTYPE;
 sad apple_ads.action_content%ROWTYPE;
 oad apple_ads.action_content%ROWTYPE;
BEGIN
 SELECT * INTO STRICT sr FROM actions.action_revision WHERE organization_id=p_org AND id=p_subject;
 SELECT * INTO STRICT orr FROM actions.action_revision WHERE organization_id=p_org AND id=p_observation;
 IF sr.action_id IS DISTINCT FROM orr.action_id OR sr.kind IS DISTINCT FROM orr.kind
   OR NOT orr.sealed OR orr.purpose NOT IN ('baseline','observation')
 THEN RAISE EXCEPTION 'Observation must belong to the same ticket and content family'; END IF;
 IF sr.kind='review_reply' THEN
  SELECT * INTO STRICT sreview FROM actions.action_review_content WHERE organization_id=p_org AND revision_id=p_subject;
  SELECT * INTO STRICT oreview FROM actions.action_review_content WHERE organization_id=p_org AND revision_id=p_observation;
  IF ROW(sreview.provider_account_id,sreview.store,sreview.provider_app_id,sreview.provider_review_id)
    IS DISTINCT FROM ROW(oreview.provider_account_id,oreview.store,oreview.provider_app_id,oreview.provider_review_id)
    OR (sreview.apple_review_resource_id IS NOT NULL AND sreview.apple_review_resource_id IS DISTINCT FROM oreview.apple_review_resource_id)
  THEN RAISE EXCEPTION 'Review observation changed the approved target'; END IF;
 ELSIF sr.kind='listing' THEN
  SELECT * INTO STRICT slisting FROM actions.action_listing_contract WHERE organization_id=p_org AND revision_id=p_subject;
  SELECT * INTO STRICT olisting FROM actions.action_listing_contract WHERE organization_id=p_org AND revision_id=p_observation;
  IF ROW(slisting.provider_account_id,slisting.store,slisting.locale,slisting.provider_app_id,slisting.package_name)
    IS DISTINCT FROM ROW(olisting.provider_account_id,olisting.store,olisting.locale,olisting.provider_app_id,olisting.package_name)
    OR (slisting.live_promotional_version_id IS NOT NULL AND slisting.live_promotional_version_id IS DISTINCT FROM olisting.live_promotional_version_id)
    OR (slisting.live_promotional_localization_id IS NOT NULL AND slisting.live_promotional_localization_id IS DISTINCT FROM olisting.live_promotional_localization_id)
    OR (slisting.app_clip_id IS NOT NULL AND slisting.app_clip_id IS DISTINCT FROM olisting.app_clip_id)
    OR (slisting.app_clip_localization_id IS NOT NULL AND slisting.app_clip_localization_id IS DISTINCT FROM olisting.app_clip_localization_id)
    OR (slisting.app_info_localization_id IS NOT NULL AND slisting.app_info_localization_id IS DISTINCT FROM olisting.app_info_localization_id)
    OR (slisting.app_version_localization_id IS NOT NULL AND slisting.app_version_localization_id IS DISTINCT FROM olisting.app_version_localization_id)
    OR (slisting.app_info_id IS NOT NULL AND slisting.app_info_id IS DISTINCT FROM olisting.app_info_id)
    OR (slisting.app_version_id IS NOT NULL AND slisting.app_version_id IS DISTINCT FROM olisting.app_version_id)
    OR (slisting.app_clip_experience_id IS NOT NULL AND slisting.app_clip_experience_id IS DISTINCT FROM olisting.app_clip_experience_id)
    OR (slisting.app_clip_release_version_id IS NOT NULL AND slisting.app_clip_release_version_id IS DISTINCT FROM olisting.app_clip_release_version_id)
  THEN RAISE EXCEPTION 'Listing observation changed the approved target'; END IF;
 ELSIF sr.kind='ads' THEN
  SELECT * INTO STRICT sad FROM apple_ads.action_content WHERE organization_id=p_org AND revision_id=p_subject;
  SELECT * INTO STRICT oad FROM apple_ads.action_content WHERE organization_id=p_org AND revision_id=p_observation;
  IF ROW(sad.provider_account_id,sad.provider_campaign_id,sad.provider_ad_group_id)
    IS DISTINCT FROM ROW(oad.provider_account_id,oad.provider_campaign_id,oad.provider_ad_group_id)
    OR (sad.provider_keyword_id IS NOT NULL AND sad.provider_keyword_id IS DISTINCT FROM oad.provider_keyword_id)
    OR (sad.provider_negative_keyword_id IS NOT NULL AND sad.provider_negative_keyword_id IS DISTINCT FROM oad.provider_negative_keyword_id)
  THEN RAISE EXCEPTION 'Ads observation changed the approved target'; END IF;
 ELSE RAISE EXCEPTION 'Provider observation unsupported for this content family';
 END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.assert_provider_content_complete(p_revision text)
RETURNS void LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE r action_revision; review action_review_content; listing action_listing_contract;
 ad apple_ads.action_content; req action_request_content; media action_media_content;
 original action_revision; expected text; writable integer;
BEGIN
 SELECT * INTO r FROM action_revision WHERE id=p_revision;
 IF NOT FOUND THEN RETURN; END IF;
 PERFORM actions.assert_listing_contract(r.id);
 IF NOT r.sealed THEN RAISE EXCEPTION 'provider content revision must be sealed' USING ERRCODE='23514'; END IF;
 IF r.kind='review_reply' THEN
  SELECT * INTO STRICT review FROM action_review_content WHERE organization_id=r.organization_id AND revision_id=r.id;
  IF length(review.provider_account_id)=0 OR length(review.provider_app_id)=0 OR length(review.provider_review_id)=0
   OR (review.store='android' AND review.apple_review_resource_id IS NOT NULL)
   OR ((r.purpose='proposal') IS DISTINCT FROM (review.intent IN ('send','update')))
  THEN RAISE EXCEPTION 'invalid review target or intent' USING ERRCODE='23514'; END IF;
  IF review.intent='update' AND r.baseline_revision_id IS NULL THEN RAISE EXCEPTION 'reply update requires exact prior response baseline' USING ERRCODE='23514'; END IF;
  IF r.purpose<>'proposal' AND (review.reply_text IS NOT NULL OR review.observation_captured_at IS NULL
    OR (review.response_availability='present' AND review.provider_response_state IS NULL))
  THEN RAISE EXCEPTION 'review observation requires captured response facts, not proposed copy' USING ERRCODE='23514'; END IF;
  IF review.original_ai_revision_id IS NOT NULL THEN
   SELECT * INTO original FROM action_revision WHERE id=review.original_ai_revision_id AND organization_id=r.organization_id;
   IF original.id IS NULL OR NOT original.sealed OR original.action_id<>r.action_id OR original.kind<>'review_reply'
    OR original.purpose<>'proposal' OR original.revision_number>=r.revision_number
   THEN RAISE EXCEPTION 'original AI reply must be an earlier sealed proposal on this ticket' USING ERRCODE='23514'; END IF;
   IF NOT EXISTS(SELECT 1 FROM action_review_content old WHERE old.revision_id=original.id
    AND (old.provider_account_id,old.store,old.provider_app_id,old.provider_review_id)=
     (review.provider_account_id,review.store,review.provider_app_id,review.provider_review_id))
   THEN RAISE EXCEPTION 'original AI reply target mismatch' USING ERRCODE='23514'; END IF;
  END IF;
 ELSIF r.kind='listing' THEN
  SELECT * INTO STRICT listing FROM action_listing_contract WHERE organization_id=r.organization_id AND revision_id=r.id;
  IF length(listing.provider_account_id)=0
   OR (listing.store='ios' AND (listing.provider_app_id IS NULL OR length(listing.provider_app_id)=0 OR listing.package_name IS NOT NULL))
   OR (listing.store='android' AND (listing.package_name IS NULL OR length(listing.package_name)=0 OR listing.provider_app_id IS NOT NULL
    OR listing.app_info_id IS NOT NULL OR listing.app_info_localization_id IS NOT NULL
    OR listing.app_version_id IS NOT NULL OR listing.app_version_localization_id IS NOT NULL))
   OR (listing.store='ios' AND (listing.short_description_state<>'unspecified' OR listing.google_edit_id IS NOT NULL))
   OR (listing.store='android' AND (listing.subtitle_state<>'unspecified' OR listing.keywords_state<>'unspecified'
    OR listing.promotional_text_state<>'unspecified' OR listing.whats_new_state<>'unspecified' OR listing.support_url_state<>'unspecified'))
   OR ((r.purpose='proposal') IS DISTINCT FROM (listing.intent<>'observed'))
  THEN RAISE EXCEPTION 'invalid listing target, field/store pair, or intent' USING ERRCODE='23514'; END IF;
  IF r.purpose<>'proposal' THEN
   IF listing.observation_captured_at IS NULL OR listing.observation_availability IS NULL
    OR listing.play_commit_policy IS NOT NULL OR listing.app_clip_operation NOT IN ('none','observed')
    OR (listing.app_clip_operation='observed' AND listing.app_clip_header_state IS NULL)
   THEN RAISE EXCEPTION 'listing snapshot requires observation facts' USING ERRCODE='23514'; END IF;
  ELSE
   IF listing.title_state='unreadable' OR listing.subtitle_state='unreadable' OR listing.description_state='unreadable'
    OR listing.keywords_state='unreadable' OR listing.promotional_text_state='unreadable'
    OR listing.short_description_state='unreadable' OR listing.whats_new_state='unreadable' OR listing.support_url_state='unreadable'
    OR listing.app_clip_operation='observed' OR listing.google_edit_id IS NOT NULL
    OR listing.live_promotional_text_state<>'unspecified' OR listing.app_clip_header_state IS NOT NULL
    OR (listing.live_promotional_version_id IS NOT NULL AND NOT is_content_write(listing.promotional_text_state))
   THEN RAISE EXCEPTION 'unreadable fields cannot be proposed or approved' USING ERRCODE='23514'; END IF;
   IF listing.store='android' AND listing.play_commit_policy IS DISTINCT FROM 'ERROR_IF_IN_REVIEW'::play_commit_policy
   THEN RAISE EXCEPTION 'Play writes require explicit safe commit policy' USING ERRCODE='23514'; END IF;
   writable=is_content_write(listing.title_state)::int+is_content_write(listing.subtitle_state)::int+
    is_content_write(listing.description_state)::int+is_content_write(listing.keywords_state)::int+
    is_content_write(listing.promotional_text_state)::int+is_content_write(listing.short_description_state)::int+
    is_content_write(listing.whats_new_state)::int+is_content_write(listing.support_url_state)::int;
   IF writable=0 AND listing.app_clip_operation='none' THEN RAISE EXCEPTION 'listing proposal has no authorized effect' USING ERRCODE='23514'; END IF;
   IF (r.operation='create_locale' AND listing.intent NOT IN ('create','update','repair'))
    OR (r.operation IN ('apply_listing_changes','update_promo_text','update_description','update_short_description') AND listing.intent<>'update')
    OR (r.operation IN ('revert_experiment','aso_revert_listing') AND (listing.intent<>'restore' OR r.baseline_revision_id IS NULL))
    OR (r.operation='update_promo_text' AND (listing.store<>'ios' OR writable<>1 OR NOT is_content_write(listing.promotional_text_state)))
    OR (r.operation='update_description' AND (listing.store<>'android' OR writable<>1 OR NOT is_content_write(listing.description_state)))
    OR (r.operation='update_short_description' AND (listing.store<>'android' OR writable<>1 OR NOT is_content_write(listing.short_description_state)))
    OR (listing.app_clip_operation<>'none' AND r.operation<>'create_locale')
   THEN RAISE EXCEPTION 'listing revision operation disagrees with exact content effect' USING ERRCODE='23514'; END IF;
   -- Never resolve editable app info/version IDs from current provider state
   -- after approval. New locale resource IDs may remain null until reserved.
   IF listing.store='ios' AND ((is_content_write(listing.title_state) OR is_content_write(listing.subtitle_state)) AND listing.app_info_id IS NULL
    OR (is_content_write(listing.description_state) OR is_content_write(listing.keywords_state)
     OR (is_content_write(listing.promotional_text_state) AND listing.live_promotional_version_id IS NULL) OR is_content_write(listing.whats_new_state)
     OR is_content_write(listing.support_url_state)) AND listing.app_version_id IS NULL)
   THEN RAISE EXCEPTION 'Apple write target app info/version must be pinned' USING ERRCODE='23514'; END IF;
   IF (listing.store='ios' AND ((is_content_write(listing.title_state) AND utf16_length(listing.title)>30)
     OR (is_content_write(listing.subtitle_state) AND utf16_length(listing.subtitle)>30)
     OR (is_content_write(listing.keywords_state) AND utf16_length(listing.keywords)>100)
     OR (is_content_write(listing.promotional_text_state) AND utf16_length(listing.promotional_text)>170)))
    OR (listing.store='android' AND ((is_content_write(listing.title_state) AND length(listing.title)>30)
     OR (is_content_write(listing.short_description_state) AND length(listing.short_description)>80)))
    OR (is_content_write(listing.description_state) AND length(listing.description)>4000)
   THEN RAISE EXCEPTION 'listing proposal exceeds provider field limits' USING ERRCODE='23514'; END IF;
   IF listing.app_clip_operation='repair_header' AND (r.baseline_revision_id IS NULL OR NOT EXISTS(
    SELECT 1 FROM action_listing_contract b WHERE b.organization_id=r.organization_id AND b.revision_id=r.baseline_revision_id
     AND b.observation_availability='present' AND b.app_clip_localization_id=listing.app_clip_localization_id
     AND ((b.app_clip_header_state='absent' AND listing.app_clip_incomplete_header_id IS NULL)
       OR (b.app_clip_header_state='incomplete' AND b.app_clip_incomplete_header_id=listing.app_clip_incomplete_header_id))
   )) THEN RAISE EXCEPTION 'App Clip repair requires an exact absent or incomplete header baseline' USING ERRCODE='23514'; END IF;
   IF listing.app_clip_incomplete_header_id IS NOT NULL AND (listing.app_clip_operation<>'repair_header'
    OR r.baseline_revision_id IS NULL OR NOT EXISTS(SELECT 1 FROM action_listing_contract b
     WHERE b.organization_id=r.organization_id AND b.revision_id=r.baseline_revision_id
      AND b.app_clip_header_state='incomplete' AND b.app_clip_incomplete_header_id=listing.app_clip_incomplete_header_id))
   THEN RAISE EXCEPTION 'App Clip deletion target requires exact incomplete baseline' USING ERRCODE='23514'; END IF;
   IF listing.app_clip_operation<>'none' THEN
    SELECT * INTO STRICT media FROM action_media_content WHERE organization_id=r.organization_id AND revision_id=r.id AND slot=listing.app_clip_header_media_slot;
    IF media.kind::text<>'app_clip_header' OR media.store<>listing.store OR media.locale<>listing.locale OR media.availability<>'stored'
     OR media.provider_md5 IS NULL OR listing.app_clip_release_version_id IS DISTINCT FROM listing.app_version_id
    THEN RAISE EXCEPTION 'App Clip approval must pin same-locale immutable header and exact release target' USING ERRCODE='23514'; END IF;
   END IF;
  END IF;
  IF EXISTS(SELECT 1 FROM action_media_content m WHERE m.revision_id=r.id AND
   (m.store<>listing.store OR m.locale<>listing.locale OR
    (r.purpose='proposal' AND (m.availability<>'stored' OR m.kind::text<>'app_clip_header'))))
  THEN RAISE EXCEPTION 'listing media must match locale; current write capability supports frozen App Clip headers only' USING ERRCODE='23514'; END IF;
 ELSIF r.kind='ads' THEN
  SELECT * INTO STRICT ad FROM apple_ads.action_content WHERE organization_id=r.organization_id AND revision_id=r.id;
  IF length(ad.provider_account_id)=0 OR ((r.purpose='proposal') IS DISTINCT FROM (ad.intent<>'observed'))
  THEN RAISE EXCEPTION 'invalid ads account or intent' USING ERRCODE='23514'; END IF;
  IF r.purpose='proposal' THEN
   expected=CASE r.operation WHEN 'asa_pause_campaign' THEN 'pause_campaign' WHEN 'asa_enable_campaign' THEN 'enable_campaign'
    WHEN 'asa_update_campaign_budget' THEN 'set_campaign_budget' WHEN 'asa_update_keyword_bid' THEN 'set_keyword_bid'
    WHEN 'asa_create_keyword' THEN 'create_keyword' WHEN 'asa_add_negative_keyword' THEN 'add_negative_keyword'
    WHEN 'asa_delete_negative_keyword' THEN 'delete_negative_keyword' END;
   IF expected IS NULL OR ad.intent::text<>expected OR (ad.intent='add_negative_keyword' AND ad.provider_ad_group_id IS NOT NULL)
   THEN RAISE EXCEPTION 'ads operation mismatch or unsupported ad-group negative keyword scope' USING ERRCODE='23514'; END IF;
  END IF;
 ELSIF r.kind='request' THEN
  SELECT * INTO STRICT req FROM action_request_content WHERE organization_id=r.organization_id AND revision_id=r.id;
  IF r.purpose<>'proposal'
   OR (r.operation='generate_locale' AND req.intent<>'locale_expansion')
   OR (r.operation='generate_listing' AND req.intent<>'listing_change')
   OR (r.operation='review_catch_up_30d' AND req.intent<>'review_catch_up')
   OR (r.operation='generate_review_analysis' AND req.intent<>'review_analysis')
   OR (r.operation='run_agent' AND req.intent<>'wake_agent')
  THEN RAISE EXCEPTION 'request purpose or operation mismatch' USING ERRCODE='23514'; END IF;
 END IF;
 IF r.generated_from_revision_id IS NOT NULL AND r.purpose='proposal' THEN
  PERFORM assert_revision_target_continuity(r.organization_id,r.generated_from_revision_id,r.id);
 END IF;
 IF r.kind IN ('review_reply','listing','ads') AND r.baseline_revision_id IS NOT NULL THEN
  PERFORM assert_same_provider_content_target(r.organization_id,r.id,r.baseline_revision_id);
 END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.provider_content_complete_at_commit()
RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;
 PERFORM actions.assert_provider_content_complete(NEW.id); RETURN NEW; END $$;
--> statement-breakpoint
CREATE FUNCTION actions.assert_revision_target_continuity(p_org text,p_previous text,p_next text)
RETURNS void LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE previous action_revision; next action_revision; pr action_review_content; nr action_review_content;
 pl action_listing_contract; nl action_listing_contract; pa apple_ads.action_content; na apple_ads.action_content;
 pq action_request_content; nq action_request_content;
BEGIN
 SELECT * INTO STRICT previous FROM action_revision WHERE organization_id=p_org AND id=p_previous;
 SELECT * INTO STRICT next FROM action_revision WHERE organization_id=p_org AND id=p_next;
 IF previous.action_id<>next.action_id OR previous.purpose<>'proposal' OR next.purpose<>'proposal'
  OR NOT previous.sealed OR NOT next.sealed OR previous.revision_number>=next.revision_number
 THEN RAISE EXCEPTION 'ticket target cannot change: invalid revision predecessor' USING ERRCODE='23514'; END IF;
 IF previous.kind='request' AND next.kind='listing' THEN
  SELECT * INTO STRICT pq FROM action_request_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT nl FROM action_listing_contract WHERE organization_id=p_org AND revision_id=p_next;
  IF previous.operation NOT IN ('generate_locale','generate_listing') OR pq.store IS NULL OR pq.locale IS NULL
   OR ROW(pq.store,pq.locale) IS DISTINCT FROM ROW(nl.store,nl.locale)
  THEN RAISE EXCEPTION 'ticket target cannot change: generated listing differs from requested store/locale' USING ERRCODE='23514'; END IF;
 ELSIF previous.kind='request' AND next.kind='collection' THEN
  SELECT * INTO STRICT pq FROM action_request_content WHERE organization_id=p_org AND revision_id=p_previous;
  IF previous.operation<>'review_catch_up_30d' OR pq.intent<>'review_catch_up' OR next.operation<>'post_batch'
   OR NOT EXISTS(SELECT 1 FROM action parent WHERE parent.organization_id=p_org AND parent.id=next.action_id AND parent.domain='collection' AND parent.asset_id IS NOT NULL)
   OR EXISTS(SELECT 1 FROM action_membership m
    JOIN action_revision child_revision ON child_revision.organization_id=m.organization_id AND child_revision.id=m.child_revision_id
    JOIN action child ON child.organization_id=m.organization_id AND child.id=m.child_action_id
    JOIN action parent ON parent.organization_id=p_org AND parent.id=next.action_id
    LEFT JOIN action_review_content child_content ON child_content.organization_id=m.organization_id AND child_content.revision_id=m.child_revision_id
    WHERE m.organization_id=p_org AND m.parent_revision_id=p_next
     AND (child_revision.kind<>'review_reply' OR child.asset_id IS DISTINCT FROM parent.asset_id
      OR child_content.revision_id IS NULL OR (pq.store IS NOT NULL AND child_content.store<>pq.store)))
  THEN RAISE EXCEPTION 'ticket target cannot change: catch-up batch differs from requested asset/store' USING ERRCODE='23514'; END IF;
 ELSIF previous.kind<>next.kind THEN
  RAISE EXCEPTION 'ticket target cannot change: unsupported content family transition' USING ERRCODE='23514';
 ELSIF next.kind='review_reply' THEN
  SELECT * INTO STRICT pr FROM action_review_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT nr FROM action_review_content WHERE organization_id=p_org AND revision_id=p_next;
  IF ROW(pr.provider_account_id,pr.store,pr.provider_app_id,pr.provider_review_id)
   IS DISTINCT FROM ROW(nr.provider_account_id,nr.store,nr.provider_app_id,nr.provider_review_id)
   OR (pr.apple_review_resource_id IS NOT NULL AND pr.apple_review_resource_id IS DISTINCT FROM nr.apple_review_resource_id)
  THEN RAISE EXCEPTION 'ticket target cannot change: review identity drift' USING ERRCODE='23514'; END IF;
 ELSIF next.kind='listing' THEN
  SELECT * INTO STRICT pl FROM action_listing_contract WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT nl FROM action_listing_contract WHERE organization_id=p_org AND revision_id=p_next;
  IF ROW(pl.provider_account_id,pl.store,pl.provider_app_id,pl.package_name,pl.locale)
   IS DISTINCT FROM ROW(nl.provider_account_id,nl.store,nl.provider_app_id,nl.package_name,nl.locale)
  THEN RAISE EXCEPTION 'ticket target cannot change: listing identity drift' USING ERRCODE='23514'; END IF;
 ELSIF next.kind='ads' THEN
  SELECT * INTO STRICT pa FROM apple_ads.action_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT na FROM apple_ads.action_content WHERE organization_id=p_org AND revision_id=p_next;
  IF ROW(pa.provider_account_id,pa.provider_campaign_id,pa.provider_ad_group_id,pa.provider_keyword_id,pa.provider_negative_keyword_id)
   IS DISTINCT FROM ROW(na.provider_account_id,na.provider_campaign_id,na.provider_ad_group_id,na.provider_keyword_id,na.provider_negative_keyword_id)
  THEN RAISE EXCEPTION 'ticket target cannot change: ads identity drift' USING ERRCODE='23514'; END IF;
 ELSIF next.kind='request' THEN
  SELECT * INTO STRICT pq FROM action_request_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT nq FROM action_request_content WHERE organization_id=p_org AND revision_id=p_next;
  IF ROW(pq.intent,pq.store,pq.locale,pq.requested_agent_id) IS DISTINCT FROM ROW(nq.intent,nq.store,nq.locale,nq.requested_agent_id)
  THEN RAISE EXCEPTION 'ticket target cannot change: request identity drift' USING ERRCODE='23514'; END IF;

 END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.guard_action_target_continuity()
RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF OLD.current_revision_id IS NOT NULL AND NEW.current_revision_id IS DISTINCT FROM OLD.current_revision_id THEN
  PERFORM actions.assert_revision_target_continuity(NEW.organization_id,OLD.current_revision_id,NEW.current_revision_id);
 END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.request_agent_target_at_commit() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF NEW.intent='wake_agent' AND NOT EXISTS(
  SELECT 1 FROM public.agent target
  JOIN actions.action_revision r ON r.organization_id=NEW.organization_id AND r.id=NEW.revision_id
  JOIN actions.action a ON a.organization_id=r.organization_id AND a.id=r.action_id
  WHERE target.id=NEW.requested_agent_id AND target."organizationId"=a.organization_id
   AND target."assetId" IS NOT DISTINCT FROM a.asset_id
 ) THEN RAISE EXCEPTION 'requested agent must belong to exact organization and asset' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
-- Parent-row absence is the authorization boundary for retention exceptions.
-- No session flag or trigger disabling can authorize a live-tenant history edit.
CREATE FUNCTION actions.is_erased_owner_only(before_row actions.action, after_row actions.action)
RETURNS boolean LANGUAGE plpgsql STABLE SET search_path=actions,public AS $$
DECLARE expected actions.action;
BEGIN
 IF before_row.owner_user_id IS NULL OR after_row.owner_user_id IS NOT NULL
   OR EXISTS(SELECT 1 FROM public."user" WHERE id=before_row.owner_user_id) THEN RETURN false; END IF;
 expected:=before_row; expected.owner_user_id:=NULL;
 RETURN after_row IS NOT DISTINCT FROM expected;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.guard_command_erasure() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,public AS $$
DECLARE expected actions.action_command; changed boolean:=false;
BEGIN
 IF TG_OP='DELETE' AND NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 IF TG_OP<>'UPDATE' THEN RAISE EXCEPTION 'immutable command row' USING ERRCODE='23514'; END IF;
 expected:=OLD;
 IF OLD.actor_user_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public."user" WHERE id=OLD.actor_user_id) THEN
  expected.actor_user_id:=NULL; expected.actor_name_snapshot:='Deleted user'; expected.external_actor_id:=NULL; NEW.actor_user_id:=NULL;
  NEW.actor_name_snapshot:='Deleted user'; NEW.external_actor_id:=NULL; changed:=true;
 END IF;
 IF OLD.acting_for_user_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public."user" WHERE id=OLD.acting_for_user_id) THEN expected.acting_for_user_id:=NULL; NEW.acting_for_user_id:=NULL; changed:=true; END IF;
 IF OLD.actor_api_key_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.api_key WHERE id=OLD.actor_api_key_id) THEN expected.actor_api_key_id:=NULL; NEW.actor_api_key_id:=NULL; changed:=true; END IF;
 IF changed AND NEW IS NOT DISTINCT FROM expected THEN RETURN NEW; END IF;
 RAISE EXCEPTION 'immutable command row' USING ERRCODE='23514';
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.erase_user_ticket_references() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,public AS $$
BEGIN
 IF EXISTS(SELECT 1 FROM public."user" WHERE id=OLD.id) THEN RAISE EXCEPTION 'user erasure requires removed identity'; END IF;
 UPDATE actions.action_command_target
 SET previous_owner_user_id=CASE WHEN previous_owner_user_id=OLD.id THEN NULL ELSE previous_owner_user_id END,
     result_owner_user_id=CASE WHEN result_owner_user_id=OLD.id THEN NULL ELSE result_owner_user_id END
 WHERE previous_owner_user_id=OLD.id OR result_owner_user_id=OLD.id;
 RETURN OLD;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.erase_organization_resource_holders() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,public AS $$
BEGIN
 IF EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.id) THEN RAISE EXCEPTION 'organization erasure requires removed tenant'; END IF;
 UPDATE actions.action_resource_guard SET holder_organization_id=NULL,holder_execution_id=NULL,acquired_at=NULL WHERE holder_organization_id=OLD.id;
 RETURN OLD;
END $$;
--> statement-breakpoint
CREATE FUNCTION reject_immutable_change() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE expected action_command_target; changed boolean:=false;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF TG_OP='UPDATE' AND TG_TABLE_NAME='action_command_target' THEN
  expected:=OLD;
  IF OLD.previous_owner_user_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public."user" WHERE id=OLD.previous_owner_user_id) THEN expected.previous_owner_user_id:=NULL; changed:=true; END IF;
  IF OLD.result_owner_user_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public."user" WHERE id=OLD.result_owner_user_id) THEN expected.result_owner_user_id:=NULL; changed:=true; END IF;
  IF changed AND NEW IS NOT DISTINCT FROM expected THEN RETURN NEW; END IF;
 END IF;
 RAISE EXCEPTION 'immutable % row', TG_TABLE_NAME USING ERRCODE='23514';
END $$;
--> statement-breakpoint
CREATE FUNCTION guard_revision_content_edit() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE revision_key text; tenant_key text; is_sealed boolean;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF TG_OP='DELETE' THEN revision_key=OLD.revision_id;tenant_key=OLD.organization_id;
 ELSE revision_key=NEW.revision_id;tenant_key=NEW.organization_id; END IF;
 IF TG_OP='UPDATE' AND (NEW.revision_id,NEW.organization_id) IS DISTINCT FROM (OLD.revision_id,OLD.organization_id) THEN
  RAISE EXCEPTION 'content cannot move revisions' USING ERRCODE='23514';
 END IF;
 SELECT sealed INTO is_sealed FROM action_revision WHERE id=revision_key AND organization_id=tenant_key FOR UPDATE;
 IF is_sealed IS DISTINCT FROM false THEN RAISE EXCEPTION 'sealed or missing content owner' USING ERRCODE='23514'; END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF; RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION guard_membership_edit() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE owner_key text; tenant_key text; parent_row action_revision; child_row action_revision;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF TG_OP='DELETE' THEN owner_key=OLD.parent_revision_id;tenant_key=OLD.organization_id;
 ELSE owner_key=NEW.parent_revision_id;tenant_key=NEW.organization_id; END IF;
 SELECT * INTO parent_row FROM action_revision WHERE id=owner_key AND organization_id=tenant_key FOR UPDATE;
 IF parent_row.sealed IS DISTINCT FROM false OR parent_row.kind<>'collection' THEN RAISE EXCEPTION 'membership owner must be unsealed collection' USING ERRCODE='23514'; END IF;
 IF TG_OP='UPDATE' AND (NEW.parent_revision_id,NEW.organization_id) IS DISTINCT FROM (OLD.parent_revision_id,OLD.organization_id) THEN RAISE EXCEPTION 'membership cannot move' USING ERRCODE='23514'; END IF;
 IF TG_OP<>'DELETE' THEN
  SELECT * INTO child_row FROM action_revision WHERE id=NEW.child_revision_id AND organization_id=NEW.organization_id;
  IF child_row.sealed IS DISTINCT FROM true OR child_row.purpose<>'proposal' OR child_row.action_id=parent_row.action_id THEN RAISE EXCEPTION 'invalid membership child' USING ERRCODE='23514'; END IF;
 END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION assert_revision_complete(revision_key text) RETURNS void LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE r action_revision; a action; primary_count integer; expected_present boolean; baseline action_revision;
BEGIN
 SELECT * INTO r FROM action_revision WHERE id=revision_key;
 IF NOT FOUND THEN RETURN; END IF;
 IF NOT r.sealed THEN RAISE EXCEPTION 'unsealed revision cannot commit' USING ERRCODE='23514'; END IF;
 SELECT * INTO a FROM action WHERE id=r.action_id AND organization_id=r.organization_id;
 SELECT
  (EXISTS(SELECT 1 FROM action_review_content WHERE revision_id=r.id))::int+
  (EXISTS(SELECT 1 FROM action_listing_contract WHERE revision_id=r.id))::int+
  (EXISTS(SELECT 1 FROM action_request_content WHERE revision_id=r.id))::int+
  (EXISTS(SELECT 1 FROM apple_ads.action_content WHERE revision_id=r.id))::int+
  (EXISTS(SELECT 1 FROM action_advisory_content WHERE revision_id=r.id))::int
 INTO primary_count;
 expected_present=CASE r.kind
  WHEN 'review_reply' THEN EXISTS(SELECT 1 FROM action_review_content WHERE revision_id=r.id)
  WHEN 'listing' THEN EXISTS(SELECT 1 FROM action_listing_contract WHERE revision_id=r.id)
  WHEN 'request' THEN EXISTS(SELECT 1 FROM action_request_content WHERE revision_id=r.id)
  WHEN 'ads' THEN EXISTS(SELECT 1 FROM apple_ads.action_content WHERE revision_id=r.id)
  WHEN 'advisory' THEN EXISTS(SELECT 1 FROM action_advisory_content WHERE revision_id=r.id)
  WHEN 'collection' THEN EXISTS(SELECT 1 FROM action_membership WHERE parent_revision_id=r.id)
  ELSE false END;
 IF NOT expected_present OR primary_count<>(CASE WHEN r.kind='collection' THEN 0 ELSE 1 END) THEN RAISE EXCEPTION 'wrong or absent content subtype' USING ERRCODE='23514'; END IF;
 IF r.kind<>'listing' AND EXISTS(SELECT 1 FROM action_media_content WHERE revision_id=r.id) THEN RAISE EXCEPTION 'media incompatible with revision' USING ERRCODE='23514'; END IF;
 IF r.kind<>'listing' AND EXISTS(SELECT 1 FROM action_content_term WHERE revision_id=r.id) THEN RAISE EXCEPTION 'terms incompatible with revision' USING ERRCODE='23514'; END IF;
 IF r.kind<>'collection' AND EXISTS(SELECT 1 FROM action_membership WHERE parent_revision_id=r.id) THEN RAISE EXCEPTION 'membership incompatible with revision' USING ERRCODE='23514'; END IF;
 IF r.kind='collection' AND EXISTS(
  SELECT 1 FROM action_membership m
  JOIN action_revision child ON child.organization_id=m.organization_id AND child.id=m.child_revision_id
  JOIN action child_ticket ON child_ticket.organization_id=m.organization_id AND child_ticket.id=m.child_action_id
  WHERE m.organization_id=r.organization_id AND m.parent_revision_id=r.id
   AND (child_ticket.asset_id IS DISTINCT FROM a.asset_id OR NOT (
    (r.operation='post_batch' AND child.kind='review_reply' AND child.operation='post_reply')
    OR (r.operation='localize' AND ((child.kind='request' AND child.operation='generate_locale') OR child.kind='listing'))
    OR (r.operation IN ('apply_listing_changes','revert_experiment','aso_revert_listing') AND child.kind='listing')
    OR (r.operation='apply_listing_changes' AND child.kind='request' AND child.operation='generate_listing')
    OR (r.operation='asa_update_keyword_bid' AND child.kind='ads' AND child.operation='asa_update_keyword_bid')
   ))
 ) THEN RAISE EXCEPTION 'collection child differs from declared operation or asset' USING ERRCODE='23514'; END IF;

 IF r.baseline_revision_id IS NOT NULL THEN
  SELECT * INTO baseline FROM action_revision WHERE id=r.baseline_revision_id;
  IF baseline.sealed IS DISTINCT FROM true OR baseline.purpose NOT IN ('baseline','observation') OR baseline.action_id<>r.action_id OR baseline.kind<>r.kind THEN RAISE EXCEPTION 'invalid baseline' USING ERRCODE='23514'; END IF;
 END IF;
 IF r.generated_from_revision_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM action_revision source WHERE source.id=r.generated_from_revision_id AND source.action_id=r.action_id AND source.sealed AND source.revision_number<r.revision_number) THEN RAISE EXCEPTION 'invalid generation predecessor' USING ERRCODE='23514'; END IF;
 IF (r.kind IN ('review_reply') AND a.domain<>'reviews') OR (r.kind='listing' AND a.domain<>'listing') OR (r.kind='ads' AND a.domain<>'ads') OR (r.kind='advisory' AND a.domain<>'advisory') OR (r.kind='collection' AND a.domain<>'collection') THEN RAISE EXCEPTION 'revision domain mismatch' USING ERRCODE='23514'; END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION revision_complete_at_commit() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;
 PERFORM assert_revision_complete(NEW.id);RETURN NEW; END $$;
--> statement-breakpoint
CREATE FUNCTION guard_revision_update() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF TG_OP='DELETE' OR OLD.sealed THEN RAISE EXCEPTION 'immutable revision' USING ERRCODE='23514'; END IF;
 IF (NEW.id,NEW.organization_id,NEW.action_id,NEW.purpose,NEW.kind,NEW.operation,NEW.revision_number,NEW.authored_command_id,NEW.baseline_revision_id,NEW.generated_from_revision_id,NEW.title,NEW.summary,NEW.rationale,NEW.content_digest,NEW.canonicalization_version,NEW.created_at) IS DISTINCT FROM (OLD.id,OLD.organization_id,OLD.action_id,OLD.purpose,OLD.kind,OLD.operation,OLD.revision_number,OLD.authored_command_id,OLD.baseline_revision_id,OLD.generated_from_revision_id,OLD.title,OLD.summary,OLD.rationale,OLD.content_digest,OLD.canonicalization_version,OLD.created_at) THEN RAISE EXCEPTION 'revision fields immutable even before seal' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION guard_action_graph() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF TG_OP='UPDATE' AND (NEW.id,NEW.organization_id,NEW.asset_id,NEW.domain,NEW.parent_action_id,NEW.creation_key,NEW.created_at) IS DISTINCT FROM (OLD.id,OLD.organization_id,OLD.asset_id,OLD.domain,OLD.parent_action_id,OLD.creation_key,OLD.created_at) THEN RAISE EXCEPTION 'ticket identity and structural parent are permanent' USING ERRCODE='23514'; END IF;
 IF NEW.current_revision_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM action_revision WHERE id=NEW.current_revision_id AND action_id=NEW.id AND organization_id=NEW.organization_id AND purpose='proposal' AND sealed) THEN RAISE EXCEPTION 'invalid current revision' USING ERRCODE='23514'; END IF;
 IF NEW.parent_action_id IS NOT NULL AND EXISTS(WITH RECURSIVE ancestors AS (SELECT id,parent_action_id FROM action WHERE id=NEW.parent_action_id UNION SELECT a.id,a.parent_action_id FROM action a JOIN ancestors p ON a.id=p.parent_action_id) SELECT 1 FROM ancestors WHERE id=NEW.id) THEN RAISE EXCEPTION 'parent cycle' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION dependency_acyclic() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF EXISTS(WITH RECURSIVE ancestors AS (SELECT prerequisite_action_id AS id FROM action_dependency WHERE dependent_action_id=NEW.prerequisite_action_id UNION SELECT d.prerequisite_action_id FROM action_dependency d JOIN ancestors a ON d.dependent_action_id=a.id) SELECT 1 FROM ancestors WHERE id=NEW.dependent_action_id) THEN RAISE EXCEPTION 'dependency cycle' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION command_target_matches_action(t action_command_target,a action) RETURNS boolean
 LANGUAGE sql IMMUTABLE SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$ SELECT
 (t.result_version,t.result_decision,t.result_revision_id,t.result_approval_id,t.result_owner_user_id,t.result_snoozed_until,t.result_archived_at)
 IS NOT DISTINCT FROM
 (a.version,a.decision,a.current_revision_id,a.current_approval_id,a.owner_user_id,a.snoozed_until,a.archived_at) $$;
--> statement-breakpoint
CREATE FUNCTION guard_action_command_mutation() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE c action_command; t action_command_target; old_ap action_approval; is_initial boolean;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'permanent ticket cannot be deleted by workflow' USING ERRCODE='23514'; END IF;
 IF TG_OP='UPDATE' AND actions.is_erased_owner_only(OLD,NEW) THEN RETURN NEW; END IF;
 SELECT * INTO c FROM action_command WHERE organization_id=NEW.organization_id AND id=NEW.last_command_id;
 IF c.id IS NULL OR c.outcome<>'accepted' THEN RAISE EXCEPTION 'action mutation needs accepted command' USING ERRCODE='23514'; END IF;
 IF TG_OP='INSERT' THEN
  IF c.kind<>'create' OR NEW.version<>1 OR NEW.attention_version<>1 OR NEW.decision<>'open' OR NEW.current_revision_id IS NOT NULL OR NEW.current_approval_id IS NOT NULL
  THEN RAISE EXCEPTION 'create must start one skeletal open ticket' USING ERRCODE='23514'; END IF;
  RETURN NEW;
 END IF;
 SELECT * INTO t FROM action_command_target WHERE organization_id=NEW.organization_id AND command_id=c.id AND action_id=NEW.id;
 IF t.command_id IS NULL OR NOT command_target_matches_action(t,NEW) THEN RAISE EXCEPTION 'mutation must match immutable command result' USING ERRCODE='23514'; END IF;
 is_initial=c.kind='create' AND OLD.last_command_id=c.id AND OLD.current_revision_id IS NULL AND OLD.version=1;
 IF is_initial THEN
  IF NEW.version<>1 OR NEW.current_revision_id IS NULL OR t.previous_version IS NOT NULL OR t.expected_version IS NOT NULL OR t.expected_revision_id IS NOT NULL
  THEN RAISE EXCEPTION 'invalid create initialization' USING ERRCODE='23514'; END IF;
 ELSE
  IF c.kind IN ('create','grant_policy','revoke_policy') OR NEW.last_command_id=OLD.last_command_id OR NEW.version<>OLD.version+1
  THEN RAISE EXCEPTION 'new mutation requires one new command/version' USING ERRCODE='23514'; END IF;
  IF t.expected_version IS DISTINCT FROM OLD.version OR t.expected_revision_id IS DISTINCT FROM OLD.current_revision_id OR t.expected_revision_id IS NULL
  THEN RAISE EXCEPTION 'stale or absent expected version/revision' USING ERRCODE='23514'; END IF;
  IF (t.previous_version,t.previous_decision,t.previous_revision_id,t.previous_approval_id,t.previous_owner_user_id,t.previous_snoozed_until,t.previous_archived_at)
   IS DISTINCT FROM (OLD.version,OLD.decision,OLD.current_revision_id,OLD.current_approval_id,OLD.owner_user_id,OLD.snoozed_until,OLD.archived_at)
  THEN RAISE EXCEPTION 'forged command preimage' USING ERRCODE='23514'; END IF;
 END IF;
 IF NEW.updated_at IS DISTINCT FROM c.accepted_at OR NEW.attention_version<OLD.attention_version OR NEW.attention_version>OLD.attention_version+1
 THEN RAISE EXCEPTION 'invalid mutation timestamp/attention version' USING ERRCODE='23514'; END IF;
 IF NOT is_initial AND NEW.current_revision_id IS DISTINCT FROM OLD.current_revision_id THEN
  IF c.kind<>'revise' OR NEW.current_revision_id IS NULL OR NEW.decision<>'open' OR NEW.current_approval_id IS NOT NULL
  THEN RAISE EXCEPTION 'revision advance must open an unapproved head' USING ERRCODE='23514'; END IF;
  IF EXISTS(SELECT 1 FROM action_execution e JOIN action_approval ap ON ap.id=e.approval_id WHERE ap.action_id=NEW.id AND e.phase NOT IN ('settled','cancelled'))
  THEN RAISE EXCEPTION 'unsettled effect prevents revision replacement' USING ERRCODE='23514'; END IF;
 END IF;
 IF NOT is_initial AND NEW.current_approval_id IS DISTINCT FROM OLD.current_approval_id AND OLD.current_approval_id IS NOT NULL THEN
  SELECT * INTO old_ap FROM action_approval WHERE id=OLD.current_approval_id;
  IF c.kind='undo' THEN
   IF c.accepted_at>=old_ap.undo_deadline OR clock_timestamp()>=old_ap.undo_deadline OR NEW.current_approval_id IS NOT NULL OR NEW.decision<>'open'
   THEN RAISE EXCEPTION 'Undo expired or invalid target decision' USING ERRCODE='23514'; END IF;
   IF EXISTS(SELECT 1 FROM action_execution e WHERE e.approval_id=old_ap.id AND e.claim_generation>0)
    OR EXISTS(SELECT 1 FROM action_execution_attempt_contract x JOIN action_execution_step_contract s ON s.id=x.step_id JOIN action_execution e ON e.id=s.execution_id WHERE e.approval_id=old_ap.id AND x.kind IN ('write','generation'))
   THEN RAISE EXCEPTION 'Undo cannot cross execution claim' USING ERRCODE='23514'; END IF;
  ELSIF EXISTS(SELECT 1 FROM action_execution WHERE approval_id=old_ap.id AND phase NOT IN ('settled','cancelled')) THEN
   RAISE EXCEPTION 'active authorization cannot be displaced' USING ERRCODE='23514';
  END IF;
 END IF;
 IF NOT is_initial AND NEW.decision IS DISTINCT FROM OLD.decision THEN
  IF NOT (
   (c.kind IN ('approve','revise') AND OLD.decision='open' AND NEW.decision='approved') OR
   (c.kind='undo' AND OLD.decision='approved' AND NEW.decision='open') OR
   (c.kind='restore' AND OLD.decision IN ('declined','acknowledged') AND NEW.decision='open' AND NEW.current_revision_id=OLD.current_revision_id AND NEW.current_approval_id IS NULL) OR
   (c.kind='restore' AND OLD.decision='approved' AND NEW.decision='open' AND NEW.current_revision_id=OLD.current_revision_id AND NEW.current_approval_id IS NULL
    AND EXISTS(SELECT 1 FROM action_approval ap JOIN action_execution e ON e.organization_id=ap.organization_id AND e.approval_id=ap.id
      WHERE ap.organization_id=OLD.organization_id AND ap.id=OLD.current_approval_id AND ap.scope IN ('generate','revise') AND e.phase='settled' AND e.result='failed')
    AND NOT EXISTS(SELECT 1 FROM action_execution e JOIN action_approval ap ON ap.organization_id=e.organization_id AND ap.id=e.approval_id
      WHERE ap.organization_id=OLD.organization_id AND ap.action_id=OLD.id AND e.phase NOT IN ('settled','cancelled'))) OR
   (c.kind='reject' AND OLD.decision='open' AND NEW.decision='declined') OR
   (c.kind='acknowledge' AND OLD.decision='open' AND NEW.decision='acknowledged') OR
   (c.kind='resolve_external' AND OLD.decision='open' AND NEW.decision='handled_externally') OR
   (c.kind='supersede' AND NEW.decision='superseded') OR
   (c.kind='revise' AND NEW.decision='open' AND NEW.current_revision_id IS DISTINCT FROM OLD.current_revision_id))
  THEN RAISE EXCEPTION 'invalid command decision transition' USING ERRCODE='23514'; END IF;
 END IF;
 IF NOT is_initial AND NEW.priority IS DISTINCT FROM OLD.priority THEN RAISE EXCEPTION 'priority change requires an explicit future command contract' USING ERRCODE='23514'; END IF;
 IF NOT is_initial AND NEW.successor_action_id IS DISTINCT FROM OLD.successor_action_id AND c.kind<>'supersede' THEN RAISE EXCEPTION 'successor change requires supersede' USING ERRCODE='23514'; END IF;
 IF NOT is_initial AND NEW.owner_user_id IS DISTINCT FROM OLD.owner_user_id AND c.kind<>'assign' THEN RAISE EXCEPTION 'owner change requires assign' USING ERRCODE='23514'; END IF;
 IF NOT is_initial AND NEW.snoozed_until IS DISTINCT FROM OLD.snoozed_until AND c.kind NOT IN ('snooze','unsnooze') THEN RAISE EXCEPTION 'snooze change requires snooze command' USING ERRCODE='23514'; END IF;
 IF NOT is_initial AND NEW.archived_at IS DISTINCT FROM OLD.archived_at AND c.kind NOT IN ('archive','restore') THEN RAISE EXCEPTION 'archive change requires archive command' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION assert_action_command_head(action_key text) RETURNS void LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE a action; t action_command_target; ap action_approval; r action_revision;
BEGIN
 SELECT * INTO a FROM action WHERE id=action_key;
 IF NOT FOUND THEN RAISE EXCEPTION 'missing command action' USING ERRCODE='23514'; END IF;
 SELECT * INTO t FROM action_command_target WHERE command_id=a.last_command_id AND action_id=a.id AND organization_id=a.organization_id;
 IF t.command_id IS NULL OR NOT command_target_matches_action(t,a) THEN RAISE EXCEPTION 'action head lacks matching history' USING ERRCODE='23514'; END IF;
 SELECT * INTO r FROM action_revision WHERE id=a.current_revision_id AND action_id=a.id AND organization_id=a.organization_id;
 IF r.id IS NULL OR NOT r.sealed OR r.purpose<>'proposal' THEN RAISE EXCEPTION 'action needs sealed proposal head' USING ERRCODE='23514'; END IF;
 IF a.current_approval_id IS NOT NULL THEN
  SELECT * INTO ap FROM action_approval WHERE id=a.current_approval_id AND action_id=a.id AND organization_id=a.organization_id;
  IF ap.id IS NULL OR ap.revision_id IS DISTINCT FROM a.current_revision_id OR a.decision<>'approved' THEN RAISE EXCEPTION 'current approval incoherent' USING ERRCODE='23514'; END IF;
 ELSIF a.decision='approved' AND r.kind<>'collection' THEN RAISE EXCEPTION 'approved effect requires current approval' USING ERRCODE='23514'; END IF;
 IF EXISTS(SELECT 1 FROM action_command_target x JOIN action_command c ON c.id=x.command_id WHERE x.action_id=a.id AND c.outcome='accepted' AND x.result_version>a.version)
 THEN RAISE EXCEPTION 'accepted target did not update action' USING ERRCODE='23514'; END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION action_head_at_commit() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;
 PERFORM assert_action_command_head(NEW.id);RETURN NEW;END $$;
--> statement-breakpoint
-- Evidence records the snapshot at its position in a transaction. A later command
-- may advance that head in the same transaction without rewriting this evidence.
CREATE FUNCTION guard_evidence_target_snapshot() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE c action_command; current_ticket action;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 SELECT * INTO c FROM action_command WHERE id=NEW.command_id AND organization_id=NEW.organization_id;
 IF c.id IS NULL THEN RAISE EXCEPTION 'missing target command' USING ERRCODE='23514'; END IF;
 IF c.outcome='accepted' AND c.kind IN ('record_observation','record_attempt') THEN
  SELECT * INTO current_ticket FROM action WHERE organization_id=NEW.organization_id AND id=NEW.action_id FOR UPDATE;
  IF current_ticket.id IS NULL OR
   ROW(current_ticket.version,current_ticket.decision,current_ticket.current_revision_id,current_ticket.current_approval_id,current_ticket.owner_user_id,current_ticket.snoozed_until,current_ticket.archived_at)
    IS DISTINCT FROM ROW(NEW.previous_version,NEW.previous_decision,NEW.previous_revision_id,NEW.previous_approval_id,NEW.previous_owner_user_id,NEW.previous_snoozed_until,NEW.previous_archived_at)
  THEN RAISE EXCEPTION 'evidence command must preserve exact ticket snapshot' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION command_target_at_commit() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE c action_command; parent_r action_revision; parent_t action_command_target; evidence action_revision; proposal action_revision; observed_review action_review_content; observed_listing action_listing_contract; proposed_listing action_listing_contract; observed_ad apple_ads.action_content;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 SELECT * INTO c FROM action_command WHERE id=NEW.command_id AND organization_id=NEW.organization_id;
 IF c.id IS NULL THEN RAISE EXCEPTION 'missing target command' USING ERRCODE='23514'; END IF;
 IF c.outcome='accepted' THEN
  IF c.kind='create' THEN
   IF NEW.previous_version IS NOT NULL OR NEW.expected_version IS NOT NULL OR NEW.expected_revision_id IS NOT NULL OR NEW.result_version<>1 OR NEW.result_decision<>'open' OR NEW.previous_approval_id IS NOT NULL OR NEW.result_approval_id IS NOT NULL
   THEN RAISE EXCEPTION 'invalid create history target' USING ERRCODE='23514'; END IF;
  ELSIF c.kind IN ('record_observation','record_attempt') THEN
   IF NEW.previous_version IS NULL OR NEW.expected_version IS DISTINCT FROM NEW.previous_version
    OR NEW.expected_revision_id IS NULL OR NEW.expected_revision_id IS DISTINCT FROM NEW.previous_revision_id
    OR ROW(NEW.result_version,NEW.result_decision,NEW.result_revision_id,NEW.result_approval_id,NEW.result_owner_user_id,NEW.result_snoozed_until,NEW.result_archived_at)
     IS DISTINCT FROM ROW(NEW.previous_version,NEW.previous_decision,NEW.previous_revision_id,NEW.previous_approval_id,NEW.previous_owner_user_id,NEW.previous_snoozed_until,NEW.previous_archived_at)
   THEN RAISE EXCEPTION 'evidence command must preserve exact ticket snapshot' USING ERRCODE='23514'; END IF;
  ELSE
   IF NEW.previous_version IS NULL OR NEW.expected_version IS DISTINCT FROM NEW.previous_version OR NEW.expected_revision_id IS NULL OR NEW.expected_revision_id IS DISTINCT FROM NEW.previous_revision_id OR NEW.result_version<>NEW.previous_version+1
   THEN RAISE EXCEPTION 'accepted mutation requires expected snapshot and next version' USING ERRCODE='23514'; END IF;
  END IF;
  IF c.kind='undo' AND (
    NEW.previous_decision IS DISTINCT FROM 'approved' OR NEW.result_decision IS DISTINCT FROM 'open' OR NEW.result_approval_id IS NOT NULL
    OR (NEW.previous_approval_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM action_execution e WHERE e.approval_id=NEW.previous_approval_id AND e.phase='cancelled' AND e.cancelled_command_id=c.id))
  ) THEN RAISE EXCEPTION 'Undo must atomically reopen target and cancel its durable execution' USING ERRCODE='23514'; END IF;
  PERFORM assert_action_command_head(NEW.action_id);
 ELSE
  IF NEW.previous_version IS NULL OR NEW.result_version IS DISTINCT FROM NEW.previous_version OR NEW.result_decision IS DISTINCT FROM NEW.previous_decision OR NEW.result_revision_id IS DISTINCT FROM NEW.previous_revision_id OR NEW.result_approval_id IS DISTINCT FROM NEW.previous_approval_id OR NEW.result_owner_user_id IS DISTINCT FROM NEW.previous_owner_user_id OR NEW.result_snoozed_until IS DISTINCT FROM NEW.previous_snoozed_until OR NEW.result_archived_at IS DISTINCT FROM NEW.previous_archived_at
  THEN RAISE EXCEPTION 'refused command cannot change state' USING ERRCODE='23514'; END IF;
 END IF;
 IF c.outcome='accepted' AND c.kind='resolve_external' THEN
  SELECT * INTO evidence FROM action_revision WHERE organization_id=NEW.organization_id AND id=NEW.evidence_revision_id;
  SELECT * INTO proposal FROM action_revision WHERE organization_id=NEW.organization_id AND id=NEW.previous_revision_id;
  IF c.principal_kind NOT IN ('system','agent') OR NEW.evidence_revision_id IS NULL
    OR NEW.previous_decision IS DISTINCT FROM 'open' OR NEW.result_decision IS DISTINCT FROM 'handled_externally'
    OR NEW.previous_approval_id IS NOT NULL OR NEW.result_approval_id IS NOT NULL
    OR NEW.result_revision_id IS DISTINCT FROM NEW.previous_revision_id
    OR evidence.id IS NULL OR NOT evidence.sealed OR evidence.purpose<>'observation'
    OR evidence.action_id IS DISTINCT FROM NEW.action_id OR evidence.kind IS DISTINCT FROM proposal.kind
    OR evidence.operation IS DISTINCT FROM proposal.operation
    OR EXISTS(SELECT 1 FROM action_execution execution JOIN action_approval approval ON approval.id=execution.approval_id
      WHERE approval.organization_id=NEW.organization_id AND approval.action_id=NEW.action_id AND execution.phase NOT IN ('settled','cancelled'))
  THEN RAISE EXCEPTION 'external resolution requires an open exact ticket and complete attributable observation' USING ERRCODE='23514'; END IF;
  PERFORM assert_same_provider_content_target(NEW.organization_id,proposal.id,evidence.id);
  IF evidence.kind='review_reply' THEN
   SELECT * INTO observed_review FROM action_review_content WHERE revision_id=evidence.id;
   IF observed_review.response_availability<>'present' OR observed_review.provider_response_text IS NULL
   THEN RAISE EXCEPTION 'external review resolution requires a readable existing response' USING ERRCODE='23514'; END IF;
  ELSIF evidence.kind='listing' THEN
   SELECT * INTO observed_listing FROM action_listing_contract WHERE revision_id=evidence.id;
   SELECT * INTO proposed_listing FROM action_listing_contract WHERE revision_id=proposal.id;
   IF observed_listing.observation_availability<>'present'
    OR (is_content_write(proposed_listing.title_state) AND observed_listing.title_state NOT IN ('present','empty'))
    OR (is_content_write(proposed_listing.subtitle_state) AND observed_listing.subtitle_state NOT IN ('present','empty'))
    OR (is_content_write(proposed_listing.description_state) AND observed_listing.description_state NOT IN ('present','empty'))
    OR (is_content_write(proposed_listing.keywords_state) AND observed_listing.keywords_state NOT IN ('present','empty'))
    OR (is_content_write(proposed_listing.promotional_text_state) AND observed_listing.promotional_text_state NOT IN ('present','empty'))
    OR (is_content_write(proposed_listing.short_description_state) AND observed_listing.short_description_state NOT IN ('present','empty'))
    OR (is_content_write(proposed_listing.whats_new_state) AND observed_listing.whats_new_state NOT IN ('present','empty'))
    OR (is_content_write(proposed_listing.support_url_state) AND observed_listing.support_url_state NOT IN ('present','empty'))
    OR (proposed_listing.app_clip_operation<>'none' AND observed_listing.app_clip_header_state IS DISTINCT FROM 'complete')
   THEN RAISE EXCEPTION 'external listing resolution requires complete relevant observed fields' USING ERRCODE='23514'; END IF;
  ELSIF evidence.kind='ads' THEN
   SELECT * INTO observed_ad FROM apple_ads.action_content WHERE revision_id=evidence.id;
   IF observed_ad.observation_availability<>'present' THEN RAISE EXCEPTION 'external ads resolution requires a readable resource' USING ERRCODE='23514'; END IF;
  ELSE RAISE EXCEPTION 'external resolution requires concrete provider work' USING ERRCODE='23514'; END IF;
 ELSIF NEW.evidence_revision_id IS NOT NULL THEN RAISE EXCEPTION 'only accepted external resolution may link resolution evidence' USING ERRCODE='23514'; END IF;
 IF NEW.expected_parent_revision_id IS NOT NULL THEN
  SELECT * INTO parent_r FROM action_revision WHERE id=NEW.expected_parent_revision_id AND organization_id=NEW.organization_id;
  SELECT * INTO parent_t FROM action_command_target WHERE command_id=NEW.command_id AND action_id=parent_r.action_id AND organization_id=NEW.organization_id;
  IF parent_r.kind IS DISTINCT FROM 'collection' OR parent_r.sealed IS DISTINCT FROM true OR parent_t.expected_revision_id IS DISTINCT FROM parent_r.id OR parent_t.previous_revision_id IS DISTINCT FROM parent_r.id
   OR NOT EXISTS(SELECT 1 FROM action_membership WHERE parent_revision_id=parent_r.id AND child_action_id=NEW.action_id AND child_revision_id=NEW.expected_revision_id)
  THEN RAISE EXCEPTION 'batch command requires exact parent snapshot and member' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION approval_command_at_commit() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE c action_command; t action_command_target; r action_revision; a action; p action_policy_revision; rc action_review_content;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 SELECT * INTO c FROM action_command WHERE id=NEW.command_id AND organization_id=NEW.organization_id;
 SELECT * INTO t FROM action_command_target WHERE command_id=NEW.command_id AND action_id=NEW.action_id AND organization_id=NEW.organization_id;
 SELECT * INTO r FROM action_revision WHERE id=NEW.revision_id AND organization_id=NEW.organization_id;
 SELECT * INTO a FROM action WHERE id=NEW.action_id AND organization_id=NEW.organization_id;
 IF c.outcome IS DISTINCT FROM 'accepted' OR NOT ((c.kind='approve' AND NEW.scope IN ('perform','generate')) OR (c.kind='revise' AND NEW.scope='revise'))
  OR c.principal_kind NOT IN ('user','api_key','policy') OR t.result_decision IS DISTINCT FROM 'approved' OR t.previous_decision IS DISTINCT FROM 'open'
  OR t.result_approval_id IS DISTINCT FROM NEW.id OR t.result_revision_id IS DISTINCT FROM NEW.revision_id OR t.expected_revision_id IS DISTINCT FROM NEW.revision_id
  OR t.expected_parent_revision_id IS DISTINCT FROM NEW.parent_revision_id OR r.sealed IS DISTINCT FROM true OR r.purpose IS DISTINCT FROM 'proposal'
  OR NEW.created_at IS DISTINCT FROM c.accepted_at
 THEN RAISE EXCEPTION 'approval must pin accepted exact command result' USING ERRCODE='23514'; END IF;
 IF NOT (
  (NEW.scope='perform' AND ((r.kind='review_reply' AND NEW.required_surface='review_response') OR (r.kind='listing' AND NEW.required_surface IN ('editable_listing','live_listing')) OR (r.kind='ads' AND NEW.required_surface='advertising_resource'))) OR
  (NEW.scope='generate' AND r.kind='request' AND NEW.required_surface='internal_artifact') OR
  (NEW.scope='revise' AND r.kind IN ('request','listing','review_reply','collection') AND NEW.required_surface='internal_artifact'))
 THEN RAISE EXCEPTION 'revision kind/scope/surface cannot authorize this effect' USING ERRCODE='23514'; END IF;
 IF NEW.policy_revision_id IS DISTINCT FROM c.actor_policy_revision_id THEN RAISE EXCEPTION 'policy decision attribution mismatch' USING ERRCODE='23514'; END IF;
 IF NEW.policy_revision_id IS NOT NULL THEN
  SELECT * INTO p FROM action_policy_revision WHERE id=NEW.policy_revision_id AND organization_id=NEW.organization_id;
  IF p.id IS NULL OR p.revoked_at IS NOT NULL OR p.asset_id IS DISTINCT FROM a.asset_id THEN RAISE EXCEPTION 'policy inactive or wrong target' USING ERRCODE='23514'; END IF;
  IF NEW.scope='perform' THEN
   SELECT * INTO rc FROM action_review_content WHERE revision_id=r.id AND organization_id=r.organization_id;
   IF p.policy_kind<>'review_auto_reply' OR r.kind<>'review_reply' OR NOT ((rc.intent='send' AND p.allow_initial_reply) OR (rc.intent='update' AND p.allow_replace_reply))
    OR (p.minimum_rating IS NOT NULL AND (rc.review_rating IS NULL OR rc.review_rating NOT BETWEEN p.minimum_rating AND p.maximum_rating))
   THEN RAISE EXCEPTION 'policy does not authorize exact reply intent' USING ERRCODE='23514'; END IF;
  ELSIF p.policy_kind<>'agent_generation' OR NOT p.allow_generation THEN RAISE EXCEPTION 'generation policy required' USING ERRCODE='23514'; END IF;
 END IF;
 IF NEW.parent_revision_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM action_revision pr WHERE pr.id=NEW.parent_revision_id AND pr.action_id=a.parent_action_id AND pr.organization_id=a.organization_id)
 THEN RAISE EXCEPTION 'batch selection must name structural parent' USING ERRCODE='23514'; END IF;
 IF NOT EXISTS(SELECT 1 FROM action_execution WHERE approval_id=NEW.id) THEN RAISE EXCEPTION 'accepted approval requires durable execution obligation' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION guard_policy_command() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE c action_command;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'policy revision cannot be deleted' USING ERRCODE='23514'; END IF;
 IF TG_OP='INSERT' THEN
  SELECT * INTO c FROM action_command WHERE id=NEW.granted_by_command_id AND organization_id=NEW.organization_id;
  IF c.kind IS DISTINCT FROM 'grant_policy' OR c.outcome IS DISTINCT FROM 'accepted' OR c.principal_kind NOT IN ('user','api_key') OR c.target_policy_revision_id IS DISTINCT FROM NEW.id OR NEW.created_at IS DISTINCT FROM c.accepted_at OR NEW.revoked_at IS NOT NULL
  THEN RAISE EXCEPTION 'policy creation requires accepted targeted grant' USING ERRCODE='23514'; END IF;
 ELSE
  IF (NEW.id,NEW.organization_id,NEW.asset_id,NEW.granted_by_command_id,NEW.policy_kind,NEW.revision_number,NEW.minimum_rating,NEW.maximum_rating,NEW.allow_initial_reply,NEW.allow_replace_reply,NEW.allow_generation,NEW.rule_version,NEW.created_at)
   IS DISTINCT FROM (OLD.id,OLD.organization_id,OLD.asset_id,OLD.granted_by_command_id,OLD.policy_kind,OLD.revision_number,OLD.minimum_rating,OLD.maximum_rating,OLD.allow_initial_reply,OLD.allow_replace_reply,OLD.allow_generation,OLD.rule_version,OLD.created_at)
   OR OLD.revoked_at IS NOT NULL OR NEW.revoked_at IS NULL OR NEW.revoked_by_command_id IS NULL
  THEN RAISE EXCEPTION 'only one-way policy revocation is mutable' USING ERRCODE='23514'; END IF;
  SELECT * INTO c FROM action_command WHERE id=NEW.revoked_by_command_id AND organization_id=NEW.organization_id;
  IF c.kind IS DISTINCT FROM 'revoke_policy' OR c.outcome IS DISTINCT FROM 'accepted' OR c.principal_kind NOT IN ('user','api_key') OR c.target_policy_revision_id IS DISTINCT FROM NEW.id OR NEW.revoked_at IS DISTINCT FROM c.accepted_at OR NEW.revoked_at<OLD.created_at
  THEN RAISE EXCEPTION 'revocation requires accepted targeted revoke' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION command_completion_at_commit() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF NEW.outcome<>'accepted' THEN RETURN NEW; END IF;
 IF NEW.kind='approve' AND NOT EXISTS(SELECT 1 FROM action_approval WHERE command_id=NEW.id AND organization_id=NEW.organization_id)
 THEN RAISE EXCEPTION 'approve command requires at least one exact selected approval' USING ERRCODE='23514'; END IF;
 IF NEW.kind='undo' AND NOT EXISTS(SELECT 1 FROM action_execution WHERE cancelled_command_id=NEW.id AND organization_id=NEW.organization_id AND phase='cancelled')
 THEN RAISE EXCEPTION 'Undo command requires a cancelled execution' USING ERRCODE='23514'; END IF;
 IF NEW.kind='grant_policy' THEN
  IF NOT EXISTS(SELECT 1 FROM action_policy_revision WHERE id=NEW.target_policy_revision_id AND organization_id=NEW.organization_id AND granted_by_command_id=NEW.id) THEN RAISE EXCEPTION 'grant command lacks policy result' USING ERRCODE='23514'; END IF;
 ELSIF NEW.kind='revoke_policy' THEN
  IF NOT EXISTS(SELECT 1 FROM action_policy_revision WHERE id=NEW.target_policy_revision_id AND organization_id=NEW.organization_id AND revoked_by_command_id=NEW.id) THEN RAISE EXCEPTION 'revoke command lacks policy result' USING ERRCODE='23514'; END IF;
 ELSIF NOT EXISTS(SELECT 1 FROM action_command_target WHERE command_id=NEW.id AND organization_id=NEW.organization_id) THEN
  RAISE EXCEPTION 'accepted command lacks typed result targets' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION guard_personal_read() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE latest bigint;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 SELECT attention_version INTO latest FROM action WHERE id=NEW.action_id AND organization_id=NEW.organization_id;
 IF latest IS NULL OR NEW.seen_attention_version>latest THEN RAISE EXCEPTION 'read watermark is beyond visible history' USING ERRCODE='23514'; END IF;
 IF TG_OP='UPDATE' AND ((NEW.organization_id,NEW.user_id,NEW.action_id) IS DISTINCT FROM (OLD.organization_id,OLD.user_id,OLD.action_id) OR NEW.seen_attention_version<OLD.seen_attention_version)
 THEN RAISE EXCEPTION 'personal read identity/watermark cannot regress' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION action_write_has_resolution(write_id text) RETURNS boolean LANGUAGE sql STABLE SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
 SELECT EXISTS (
  SELECT 1 FROM action_execution_attempt_contract evidence
  JOIN action_execution_attempt_contract subject ON subject.id=evidence.subject_attempt_id
  WHERE evidence.finished_at IS NOT NULL AND (
    evidence.subject_attempt_id=write_id
    OR (evidence.kind='late_evidence' AND subject.kind='readback' AND subject.subject_attempt_id=write_id)
  ) AND (
    (evidence.result IN ('matched','matched_external','known_not_applied') AND evidence.observation_completeness='complete')
    OR (evidence.kind='late_evidence' AND subject.kind='write' AND evidence.result IN ('acknowledged','known_not_applied'))
  )
 );
$$;
--> statement-breakpoint
CREATE FUNCTION action_guard_execution_transition() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE a action_approval%ROWTYPE; c action_command%ROWTYPE;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'executions are retained'; END IF;
 IF TG_OP='INSERT' AND (NEW.phase<>'ready' OR NEW.claim_generation<>0 OR NEW.schedule_generation<>1 OR NEW.writes_closed_at IS NOT NULL OR NEW.plan_complete)
 THEN RAISE EXCEPTION 'new execution begins ready with an unclaimed open plan'; END IF;
 IF TG_OP='UPDATE' AND OLD.plan_complete AND NOT NEW.plan_complete THEN RAISE EXCEPTION 'complete plan cannot reopen'; END IF;
 IF NEW.writes_closed_at IS NOT NULL OR (NEW.phase='settled' AND NEW.result<>'failed') THEN
  IF NOT NEW.plan_complete THEN RAISE EXCEPTION 'incomplete approved plan cannot close or succeed'; END IF;
 END IF;
 IF NEW.plan_complete THEN PERFORM actions.assert_plan_complete(NEW); END IF;
 IF TG_OP='UPDATE' THEN
  IF ROW(NEW.id,NEW.organization_id,NEW.approval_id,NEW.resource_guard_id,NEW.plan_version,NEW.created_at)
     IS DISTINCT FROM ROW(OLD.id,OLD.organization_id,OLD.approval_id,OLD.resource_guard_id,OLD.plan_version,OLD.created_at)
  THEN RAISE EXCEPTION 'execution identity, approval, resource, and plan version are immutable'; END IF;
  IF OLD.phase IN ('settled','cancelled') AND NEW IS DISTINCT FROM OLD
  THEN RAISE EXCEPTION 'settled execution cannot be rewritten'; END IF;
  IF OLD.writes_closed_at IS NOT NULL AND NEW.writes_closed_at IS DISTINCT FROM OLD.writes_closed_at
  THEN RAISE EXCEPTION 'closed mutation phase cannot be reopened'; END IF;
  IF NEW.schedule_generation<OLD.schedule_generation OR NEW.claim_generation<OLD.claim_generation
  THEN RAISE EXCEPTION 'execution generations must not decrease'; END IF;
  IF NEW.phase='claimed' AND (OLD.phase<>'claimed' OR NEW.claim_token IS DISTINCT FROM OLD.claim_token) THEN
   IF NEW.claim_generation<>OLD.claim_generation+1 THEN RAISE EXCEPTION 'new claim requires next generation'; END IF;
   IF OLD.phase='claimed' AND OLD.claim_expires_at>clock_timestamp() THEN RAISE EXCEPTION 'existing claim remains live'; END IF;
   IF OLD.next_run_at>clock_timestamp() THEN RAISE EXCEPTION 'execution is not due'; END IF;
  ELSIF NEW.phase='claimed' AND NEW.claim_generation<>OLD.claim_generation
  THEN RAISE EXCEPTION 'renewal keeps original claim generation'; END IF;
 END IF;
 SELECT * INTO a FROM action_approval WHERE organization_id=NEW.organization_id AND id=NEW.approval_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'approval required before execution'; END IF;
 IF NEW.phase='claimed' AND (NEW.claim_expires_at<=clock_timestamp() OR a.undo_deadline>clock_timestamp())
 THEN RAISE EXCEPTION 'claim must be live and beyond Undo deadline'; END IF;
 IF NEW.writes_closed_at IS NOT NULL AND NOT EXISTS(SELECT 1 FROM action_execution_step_contract WHERE execution_id=NEW.id)
 THEN RAISE EXCEPTION 'empty plan cannot close its mutation phase'; END IF;
 IF NEW.writes_closed_at IS NOT NULL AND (
  EXISTS(SELECT 1 FROM action_execution_attempt_contract x WHERE x.execution_id=NEW.id AND x.finished_at IS NULL AND x.kind='write')
  OR EXISTS(SELECT 1 FROM action_execution_step_contract s WHERE s.execution_id=NEW.id
    AND s.kind NOT IN ('internal_generate_content','internal_revise_content','internal_commit_children','internal_recheck_prerequisite')
    AND NOT EXISTS(SELECT 1 FROM action_execution_attempt_contract x WHERE x.step_id=s.id AND x.finished_at IS NOT NULL
      AND (x.result='acknowledged' OR (x.result IN ('matched','matched_external') AND x.observation_completeness='complete'))))
 ) THEN RAISE EXCEPTION 'close mutation phase only after every planned effect has evidence'; END IF;
 IF NEW.writes_closed_at IS NOT NULL AND EXISTS(
  SELECT 1 FROM action_execution_attempt_contract w WHERE w.execution_id=NEW.id AND w.kind='write' AND w.result='uncertain'
    AND NOT action_write_has_resolution(w.id)
 ) THEN RAISE EXCEPTION 'unresolved write prevents closing mutation phase'; END IF;
 IF NEW.phase IN ('settled','cancelled') AND EXISTS (
  SELECT 1 FROM action_execution_attempt_contract x WHERE x.execution_id=NEW.id AND x.finished_at IS NULL
 ) THEN RAISE EXCEPTION 'cannot settle while an I/O attempt remains open'; END IF;
 IF NEW.phase IN ('settled','cancelled') AND EXISTS (
  SELECT 1 FROM action_execution_attempt_contract w WHERE w.execution_id=NEW.id AND w.kind='write' AND w.result='uncertain'
    AND NOT action_write_has_resolution(w.id)
 ) THEN RAISE EXCEPTION 'uncertain provider effect cannot be hidden by terminal state'; END IF;
 IF NEW.phase='cancelled' AND EXISTS (
  SELECT 1 FROM action_execution_attempt_contract x WHERE x.execution_id=NEW.id AND x.kind IN ('write','generation')
 ) THEN RAISE EXCEPTION 'Undo cannot cancel an execution after work started'; END IF;
 IF NEW.phase='cancelled' THEN
  SELECT * INTO c FROM action_command WHERE organization_id=NEW.organization_id AND id=NEW.cancelled_command_id;
  IF c.id IS NULL OR c.kind<>'undo' OR c.outcome<>'accepted' OR a.undo_deadline<clock_timestamp()
   OR NOT EXISTS(SELECT 1 FROM action_command_target t WHERE t.organization_id=NEW.organization_id AND t.command_id=c.id AND t.action_id=a.action_id)
  THEN RAISE EXCEPTION 'Undo needs accepted targeted command before server deadline'; END IF;
 END IF;
 IF NEW.phase='settled' AND NEW.result='handled_externally' AND EXISTS(
  SELECT 1 FROM action_execution_step_contract step WHERE step.execution_id=NEW.id AND NOT EXISTS(
   SELECT 1 FROM action_execution_attempt_contract evidence WHERE evidence.step_id=step.id
    AND evidence.result='matched_external' AND evidence.observation_completeness='complete'
    AND evidence.observation_surface=step.required_surface AND evidence.finished_at IS NOT NULL)
 ) THEN RAISE EXCEPTION 'handled externally requires external completion evidence for every planned step'; END IF;
 IF NEW.phase='settled' AND NEW.result<>'failed' THEN
  IF NOT EXISTS(SELECT 1 FROM action_execution_step_contract s WHERE s.execution_id=NEW.id)
   OR EXISTS(SELECT 1 FROM action_execution_step_contract s WHERE s.execution_id=NEW.id AND NOT EXISTS(
    SELECT 1 FROM action_execution_attempt_contract x WHERE x.step_id=s.id AND x.finished_at IS NOT NULL AND (
      (x.result IN ('matched','matched_external') AND x.observation_completeness='complete' AND x.observation_surface=s.required_surface)
      OR (x.result='acknowledged' AND s.required_surface='provider_response')
      OR (x.result='generated' AND s.required_surface='internal_artifact'))))
  THEN RAISE EXCEPTION 'successful execution requires evidence for every planned step'; END IF;
  IF a.required_surface NOT IN ('provider_response','internal_artifact') AND NOT EXISTS(
    SELECT 1 FROM action_execution_attempt_contract x WHERE x.execution_id=NEW.id AND x.finished_at IS NOT NULL
      AND x.result IN ('matched','matched_external') AND x.observation_completeness='complete' AND x.observation_surface=a.required_surface
  ) THEN RAISE EXCEPTION 'terminal success must satisfy approval surface, not only intermediate step acknowledgements'; END IF;
  IF (NEW.result='acknowledged_only' AND a.required_surface<>'provider_response')
   OR (NEW.result='verified_editable' AND a.required_surface<>'editable_listing')
   OR (NEW.result='verified_live' AND a.required_surface NOT IN ('live_listing','review_response','advertising_resource'))
   OR (NEW.result='generated' AND (a.scope NOT IN ('generate','revise') OR a.required_surface<>'internal_artifact'))
  THEN RAISE EXCEPTION 'execution result does not meet approval evidence contract'; END IF;
 END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION action_guard_approval_execution_authority() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE r action_revision%ROWTYPE; a action%ROWTYPE; c action_command%ROWTYPE;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF TG_OP<>'INSERT' THEN RAISE EXCEPTION 'approval is immutable'; END IF;
 SELECT * INTO a FROM action WHERE organization_id=NEW.organization_id AND id=NEW.action_id FOR UPDATE;
 SELECT * INTO r FROM action_revision WHERE organization_id=NEW.organization_id AND id=NEW.revision_id;
 SELECT * INTO c FROM action_command WHERE organization_id=NEW.organization_id AND id=NEW.command_id;
 IF r.id IS NULL OR NOT r.sealed OR r.purpose<>'proposal' OR r.action_id<>a.id
 THEN RAISE EXCEPTION 'approval requires sealed proposal of the same ticket'; END IF;
 IF a.current_revision_id IS DISTINCT FROM r.id THEN RAISE EXCEPTION 'cannot approve stale revision'; END IF;
 IF c.id IS NULL OR c.outcome<>'accepted' OR NOT ((NEW.scope IN ('perform','generate') AND c.kind='approve') OR (NEW.scope='revise' AND c.kind='revise'))
 THEN RAISE EXCEPTION 'approval requires accepted command of matching kind'; END IF;
 IF NEW.policy_revision_id IS DISTINCT FROM c.actor_policy_revision_id
 THEN RAISE EXCEPTION 'policy grant and command actor must agree'; END IF;
 IF NEW.parent_revision_id IS NOT NULL AND NOT EXISTS (
  SELECT 1 FROM action_membership m JOIN action_revision p ON p.organization_id=m.organization_id AND p.id=m.parent_revision_id
  WHERE m.organization_id=NEW.organization_id AND m.parent_revision_id=NEW.parent_revision_id
   AND m.child_action_id=NEW.action_id AND m.child_revision_id=NEW.revision_id AND p.sealed
 ) THEN RAISE EXCEPTION 'approval does not name exact sealed membership'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION action_guard_execution_step() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE projected action_execution_step_contract; e action_execution%ROWTYPE; ap action_approval%ROWTYPE; r action_revision%ROWTYPE;
 pred action_execution_step_contract%ROWTYPE; g action_resource_guard%ROWTYPE;
 rc action_review_content%ROWTYPE; lc action_listing_contract%ROWTYPE;
 ad apple_ads.action_content%ROWTYPE;
 actual_provider text; actual_account text; actual_app text;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 SELECT * INTO projected FROM actions.project_execution_step(NEW);
 PERFORM actions.assert_step_contract(projected);
 IF TG_OP<>'INSERT' THEN RAISE EXCEPTION 'execution steps are immutable'; END IF;
 SELECT * INTO e FROM action_execution WHERE organization_id=NEW.organization_id AND id=NEW.execution_id FOR UPDATE;
 SELECT * INTO ap FROM action_approval WHERE organization_id=e.organization_id AND id=e.approval_id;
 SELECT * INTO r FROM action_revision WHERE organization_id=ap.organization_id AND id=ap.revision_id;
 IF e.id IS NULL OR e.phase IN ('settled','cancelled') OR e.writes_closed_at IS NOT NULL OR e.plan_complete THEN RAISE EXCEPTION 'step requires active open plan'; END IF;
 IF NEW.content_revision_id IS DISTINCT FROM ap.revision_id THEN RAISE EXCEPTION 'step must bind exact approved revision'; END IF;
 IF NEW.input_step_id IS NOT NULL THEN
  SELECT * INTO pred FROM action_execution_step_contract WHERE organization_id=NEW.organization_id AND id=NEW.input_step_id;
  IF pred.execution_id IS DISTINCT FROM NEW.execution_id OR pred.ordinal>=NEW.ordinal
  THEN RAISE EXCEPTION 'step dependency must precede it within same execution'; END IF;
 END IF;
 IF (NEW.kind='play_listing_set' AND pred.kind IS DISTINCT FROM 'play_edit_create')
  OR (NEW.kind='play_edit_commit' AND pred.kind IS DISTINCT FROM 'play_listing_set')
  OR (NEW.kind='play_inspection_edit_create' AND pred.kind IS DISTINCT FROM 'play_edit_commit')
  OR (NEW.kind='play_inspection_edit_delete' AND pred.kind IS DISTINCT FROM 'play_inspection_edit_create')
  OR (NEW.kind IN ('asc_app_clip_header_upload_chunk','asc_app_clip_header_commit') AND pred.kind IS DISTINCT FROM 'asc_app_clip_header_reserve')
 THEN RAISE EXCEPTION 'provider step lacks its exact typed predecessor'; END IF;
 IF NEW.kind='asc_app_clip_header_upload_chunk' THEN
  IF NOT EXISTS(SELECT 1 FROM action_media_content m WHERE m.organization_id=NEW.organization_id
   AND m.revision_id=NEW.content_revision_id AND m.slot=projected.media_slot
   AND m.availability='stored' AND projected.upload_offset+projected.upload_length<=m.byte_length)
   OR EXISTS(SELECT 1 FROM action_execution_step_contract other WHERE other.execution_id=e.id
    AND other.kind='asc_app_clip_header_upload_chunk' AND other.media_slot=projected.media_slot
    AND projected.upload_offset<other.upload_offset+other.upload_length
    AND other.upload_offset<projected.upload_offset+projected.upload_length)
  THEN RAISE EXCEPTION 'upload chunk must fit exact pinned bytes without overlap'; END IF;
 END IF;
 IF EXISTS(SELECT 1 FROM action_execution_attempt_contract WHERE execution_id=e.id) AND EXISTS(
  SELECT 1 FROM action_execution_step_contract WHERE execution_id=e.id AND ordinal>=NEW.ordinal
 ) THEN RAISE EXCEPTION 'running plan only permits appended steps'; END IF;
 IF NEW.kind IN ('internal_generate_content','internal_revise_content','internal_commit_children','internal_recheck_prerequisite') THEN
  IF NEW.recovery_mode<>'internal_atomic' OR projected.media_slot IS NOT NULL
   OR NOT ((NEW.kind IN ('internal_generate_content','internal_commit_children') AND ap.scope='generate')
      OR (NEW.kind='internal_revise_content' AND ap.scope='revise')
      OR (NEW.kind='internal_recheck_prerequisite' AND r.operation='resolve_prerequisite'))
  THEN RAISE EXCEPTION 'internal step does not match typed authorization'; END IF;
  RETURN NEW;
 END IF;
 IF ap.scope<>'perform' THEN RAISE EXCEPTION 'provider mutation requires perform authorization'; END IF;
 -- No currently audited adapter has a native-key contract. Enable one only by
 -- extending this closed adapter-version policy with provider contract tests.
 IF NEW.recovery_mode NOT IN ('readback_before_retry','manual_reconciliation')
 THEN RAISE EXCEPTION 'provider recovery mode unsupported by current adapter contracts'; END IF;
 SELECT * INTO rc FROM action_review_content WHERE organization_id=NEW.organization_id AND revision_id=NEW.content_revision_id;
 SELECT * INTO lc FROM action_listing_contract WHERE organization_id=NEW.organization_id AND revision_id=NEW.content_revision_id;
 SELECT * INTO ad FROM apple_ads.action_content WHERE organization_id=NEW.organization_id AND revision_id=NEW.content_revision_id;
 IF NEW.kind IN ('asc_review_response_upsert','play_review_response_set') THEN
  IF r.operation<>'post_reply' OR rc.intent NOT IN ('send','update') OR rc.revision_id IS NULL
  THEN RAISE EXCEPTION 'reply step needs approved reply content'; END IF;
  IF (NEW.kind='asc_review_response_upsert') IS DISTINCT FROM (rc.store='ios') THEN RAISE EXCEPTION 'reply transport/store mismatch'; END IF;
  actual_provider:=CASE WHEN rc.store='ios' THEN 'app_store_connect' ELSE 'google_play' END;
  actual_account:=rc.provider_account_id; actual_app:=rc.provider_app_id;
 ELSIF NEW.kind IN ('asa_campaign_status_set','asa_campaign_budget_set','asa_keyword_bid_set','asa_keyword_create','asa_negative_keyword_create','asa_negative_keyword_delete') THEN
  IF ad.revision_id IS NULL OR NOT ((NEW.kind='asa_campaign_status_set' AND r.operation IN ('asa_pause_campaign','asa_enable_campaign') AND ad.intent IN ('pause_campaign','enable_campaign'))
   OR (NEW.kind='asa_campaign_budget_set' AND r.operation='asa_update_campaign_budget' AND ad.intent='set_campaign_budget')
   OR (NEW.kind='asa_keyword_bid_set' AND r.operation='asa_update_keyword_bid' AND ad.intent='set_keyword_bid')
   OR (NEW.kind='asa_keyword_create' AND r.operation='asa_create_keyword' AND ad.intent='create_keyword')
   OR (NEW.kind='asa_negative_keyword_create' AND r.operation='asa_add_negative_keyword' AND ad.intent='add_negative_keyword')
   OR (NEW.kind='asa_negative_keyword_delete' AND r.operation='asa_delete_negative_keyword' AND ad.intent='delete_negative_keyword'))
  THEN RAISE EXCEPTION 'ads step does not match exact approved operation'; END IF;
  actual_provider:='apple_search_ads'; actual_account:=ad.provider_account_id; actual_app:=NULL;
 ELSE
  IF lc.revision_id IS NULL OR lc.intent NOT IN ('create','update','repair','restore')
  THEN RAISE EXCEPTION 'listing step needs concrete approved listing content'; END IF;
  IF NEW.kind IN ('play_edit_create','play_listing_set','play_edit_commit','play_inspection_edit_create','play_inspection_edit_delete') THEN
   IF lc.store<>'android' OR r.operation NOT IN ('create_locale','update_description','update_short_description','apply_listing_changes','aso_revert_listing','revert_experiment')
   THEN RAISE EXCEPTION 'Play listing step operation/store mismatch'; END IF;
  ELSE
   IF lc.store<>'ios' OR r.operation NOT IN ('create_locale','apply_listing_changes','update_promo_text','aso_revert_listing','revert_experiment')
   THEN RAISE EXCEPTION 'ASC listing step operation/store mismatch'; END IF;
   IF NEW.kind='asc_live_promotional_text_set' AND (lc.live_promotional_version_id IS NULL OR lc.live_promotional_localization_id IS NULL)
   THEN RAISE EXCEPTION 'live promotional mutation needs its exact approved live version and localization'; END IF;
   IF NEW.kind='asc_editable_promotional_text_set' AND (lc.app_version_id IS NULL OR lc.app_version_localization_id IS NULL)
   THEN RAISE EXCEPTION 'editable promotional mutation needs its exact approved editable version and localization'; END IF;
   IF NEW.kind IN ('asc_live_promotional_text_set','asc_editable_promotional_text_set') AND lc.promotional_text_state NOT IN ('present','empty')
   THEN RAISE EXCEPTION 'promotional mutation requires explicit approved promotional text'; END IF;
   IF NEW.kind='asc_app_clip_incomplete_header_delete' AND (
    lc.app_clip_operation<>'repair_header' OR lc.app_clip_incomplete_header_id IS NULL
    OR NOT EXISTS(SELECT 1 FROM action_listing_contract baseline WHERE baseline.organization_id=r.organization_id
      AND baseline.revision_id=r.baseline_revision_id AND baseline.app_clip_header_state='incomplete'
      AND baseline.app_clip_incomplete_header_id=lc.app_clip_incomplete_header_id)
   ) THEN RAISE EXCEPTION 'header deletion requires exact reviewed incomplete reservation and baseline'; END IF;
   IF NEW.kind IN ('asc_app_clip_localization_create','asc_app_clip_header_reserve','asc_app_clip_header_upload_chunk','asc_app_clip_header_commit','asc_app_clip_incomplete_header_delete') AND r.operation<>'create_locale'
   THEN RAISE EXCEPTION 'App Clip side effect requires explicit create-locale plan'; END IF;
   IF NEW.kind IN ('asc_app_clip_localization_create','asc_app_clip_header_reserve','asc_app_clip_header_upload_chunk','asc_app_clip_header_commit','asc_app_clip_incomplete_header_delete')
    AND (lc.app_clip_operation='none' OR lc.app_clip_experience_id IS NULL OR lc.app_clip_release_version_id IS NULL)
   THEN RAISE EXCEPTION 'App Clip effect requires pinned experience and release version'; END IF;
   IF NEW.kind='asc_app_clip_localization_create' AND (lc.app_clip_operation<>'create_localization' OR lc.app_clip_subtitle IS NULL)
   THEN RAISE EXCEPTION 'App Clip creation needs explicit create-localization authorization'; END IF;
   IF projected.media_slot IS NOT NULL AND projected.media_slot IS DISTINCT FROM lc.app_clip_header_media_slot
   THEN RAISE EXCEPTION 'App Clip image must use exact approved media slot'; END IF;
  END IF;
  actual_provider:=CASE WHEN lc.store='ios' THEN 'app_store_connect' ELSE 'google_play' END;
  actual_account:=lc.provider_account_id; actual_app:=CASE WHEN lc.store='ios' THEN lc.provider_app_id ELSE lc.package_name END;
 END IF;
 SELECT * INTO g FROM action_resource_guard WHERE id=e.resource_guard_id;
 IF actual_account IS NULL OR g.id IS NULL OR g.provider IS DISTINCT FROM actual_provider
  OR g.provider_account_id IS DISTINCT FROM (CASE WHEN actual_provider='apple_search_ads' THEN actual_account ELSE NULL END) OR g.remote_application_id IS DISTINCT FROM actual_app
 THEN RAISE EXCEPTION 'execution guard must identify approved canonical provider resource'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION action_guard_attempt() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE projected action_execution_attempt_contract; e action_execution%ROWTYPE; s action_execution_step_contract%ROWTYPE;
 subject action_execution_attempt_contract%ROWTYPE; input_row action_execution_attempt_contract%ROWTYPE;
 c action_command%ROWTYPE; g action_resource_guard%ROWTYPE; r action_revision%ROWTYPE;
 approved_revision action_revision%ROWTYPE; ap action_approval%ROWTYPE; a action%ROWTYPE; policy action_policy_revision%ROWTYPE;
external_write action_execution_attempt_contract%ROWTYPE;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 SELECT * INTO projected FROM actions.project_execution_attempt(NEW);
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'attempt evidence is retained'; END IF;
 SELECT * INTO s FROM action_execution_step_contract WHERE organization_id=NEW.organization_id AND id=NEW.step_id;
 SELECT * INTO e FROM action_execution WHERE organization_id=NEW.organization_id AND id=s.execution_id FOR UPDATE;
 SELECT * INTO ap FROM action_approval WHERE organization_id=e.organization_id AND id=e.approval_id;
 SELECT * INTO approved_revision FROM action_revision WHERE organization_id=ap.organization_id AND id=ap.revision_id;
 SELECT * INTO a FROM action WHERE organization_id=ap.organization_id AND id=ap.action_id FOR UPDATE;
 IF s.id IS NULL OR e.id IS NULL OR NEW.execution_id IS DISTINCT FROM e.id THEN RAISE EXCEPTION 'attempt requires exact execution step'; END IF;
 IF TG_OP='UPDATE' THEN
  IF OLD.finished_at IS NOT NULL THEN RAISE EXCEPTION 'finalized attempt is immutable; append evidence'; END IF;
  IF ROW(NEW.id,NEW.organization_id,NEW.execution_id,NEW.step_id,NEW.number,NEW.kind,NEW.claim_generation,NEW.claim_token,NEW.subject_attempt_id,NEW.input_attempt_id,NEW.input_parent_revision_id,NEW.started_at,NEW.transport,NEW.connector_id,NEW.agent_run_id,NEW.recorded_at)
   IS DISTINCT FROM ROW(OLD.id,OLD.organization_id,OLD.execution_id,OLD.step_id,OLD.number,OLD.kind,OLD.claim_generation,OLD.claim_token,OLD.subject_attempt_id,OLD.input_attempt_id,OLD.input_parent_revision_id,OLD.started_at,OLD.transport,OLD.connector_id,OLD.agent_run_id,OLD.recorded_at)
  THEN RAISE EXCEPTION 'attempt start identity is immutable'; END IF;
  IF NEW.finished_at IS NULL OR e.phase<>'claimed' OR e.claim_token IS DISTINCT FROM NEW.finalized_claim_token
   OR e.claim_generation IS DISTINCT FROM NEW.finalized_claim_generation OR e.claim_expires_at<=clock_timestamp()
  THEN RAISE EXCEPTION 'attempt settlement requires live current execution claim'; END IF;
 ELSE
  IF NEW.number<>(SELECT coalesce(max(number),0)+1 FROM action_execution_attempt_contract WHERE step_id=s.id)
  THEN RAISE EXCEPTION 'attempt number must append within locked execution'; END IF;
  IF NEW.kind='late_evidence' THEN
   SELECT * INTO c FROM action_command WHERE organization_id=NEW.organization_id AND id=NEW.evidence_command_id;
   SELECT * INTO subject FROM action_execution_attempt_contract WHERE organization_id=NEW.organization_id AND id=NEW.subject_attempt_id;
   IF c.id IS NULL OR c.outcome<>'accepted' OR c.kind NOT IN ('record_observation','record_attempt')
    OR NOT EXISTS(SELECT 1 FROM action_command_target t WHERE t.organization_id=NEW.organization_id AND t.command_id=c.id AND t.action_id=ap.action_id)
    OR subject.step_id IS DISTINCT FROM NEW.step_id OR subject.kind='late_evidence'
    OR NEW.claim_generation IS DISTINCT FROM subject.claim_generation OR NEW.claim_token IS DISTINCT FROM subject.claim_token
    OR NEW.transport IS DISTINCT FROM subject.transport OR NEW.started_at IS DISTINCT FROM subject.started_at
    OR NEW.input_parent_revision_id IS DISTINCT FROM subject.input_parent_revision_id
   THEN RAISE EXCEPTION 'late evidence must name original attempt and attributable evidence command'; END IF;
   IF NOT ((subject.kind='write' AND NEW.result IN ('acknowledged','known_not_applied','uncertain'))
    OR (subject.kind='readback' AND NEW.result IN ('matched','matched_external','mismatch','unreadable','known_not_applied'))
    OR (subject.kind='generation' AND NEW.result IN ('generated','discarded','known_not_applied','uncertain')))
   THEN RAISE EXCEPTION 'late evidence must preserve original interaction semantics'; END IF;
   IF subject.kind='readback' AND NEW.result='known_not_applied'
     AND (NEW.observation_revision_id IS NULL OR NEW.observation_completeness IS DISTINCT FROM 'complete'
       OR NEW.observation_surface IS NULL OR NEW.observed_at IS NULL OR NEW.comparison_version IS NULL)
   THEN RAISE EXCEPTION 'late absent readback requires complete typed observation'; END IF;
  ELSE
   IF NEW.finished_at IS NOT NULL OR e.phase<>'claimed' OR e.next_step_id IS DISTINCT FROM s.id
    OR e.claim_token IS DISTINCT FROM NEW.claim_token OR e.claim_generation IS DISTINCT FROM NEW.claim_generation
    OR e.claim_expires_at<=clock_timestamp()
   THEN RAISE EXCEPTION 'attempt start requires live current claim and scheduled step'; END IF;
   IF NEW.kind='generation' THEN
    IF (a.parent_action_id IS NULL) IS DISTINCT FROM (NEW.input_parent_revision_id IS NULL)
     OR (a.parent_action_id IS NOT NULL AND NOT EXISTS(
       SELECT 1 FROM action parent_ticket
       JOIN action_revision parent_revision ON parent_revision.organization_id=parent_ticket.organization_id AND parent_revision.id=parent_ticket.current_revision_id
       JOIN action_membership member ON member.organization_id=parent_revision.organization_id AND member.parent_revision_id=parent_revision.id
       WHERE parent_ticket.organization_id=NEW.organization_id AND parent_ticket.id=a.parent_action_id
        AND parent_revision.id=NEW.input_parent_revision_id AND parent_revision.kind='collection' AND parent_revision.sealed
        AND member.child_action_id=a.id AND member.child_revision_id=approved_revision.id
     ))
    THEN RAISE EXCEPTION 'generation must capture the exact structural parent membership before work starts'; END IF;
   END IF;
   IF NEW.kind='generation' AND approved_revision.operation='run_agent'
    AND EXISTS(SELECT 1 FROM action_request_content request WHERE request.organization_id=ap.organization_id AND request.revision_id=ap.revision_id AND request.intent='wake_agent')
    AND NOT EXISTS(
      SELECT 1 FROM action_request_content request
      JOIN public.agent_run started ON started.id=NEW.agent_run_id AND started."agentId"=request.requested_agent_id
      JOIN public.agent owner_agent ON owner_agent.id=started."agentId"
      WHERE request.organization_id=ap.organization_id AND request.revision_id=ap.revision_id
       AND started."organizationId"=NEW.organization_id AND owner_agent."organizationId"=NEW.organization_id
       AND owner_agent."assetId" IS NOT DISTINCT FROM a.asset_id
    ) THEN RAISE EXCEPTION 'generation attempt must name the requested agent run before work starts'; END IF;
   IF NEW.kind IN ('write','generation') AND ap.policy_revision_id IS NOT NULL THEN
    SELECT * INTO policy FROM action_policy_revision WHERE organization_id=NEW.organization_id AND id=ap.policy_revision_id FOR UPDATE;
    IF policy.id IS NULL OR policy.revoked_at IS NOT NULL
    THEN RAISE EXCEPTION 'revoked or missing policy cannot authorize another effect'; END IF;
   END IF;
   IF NEW.kind IN ('write','generation') AND (a.current_approval_id IS DISTINCT FROM ap.id OR a.current_revision_id IS DISTINCT FROM ap.revision_id)
   THEN RAISE EXCEPTION 'new effects require current exact authorization; older work may only reconcile'; END IF;
   IF NEW.kind IN ('write','generation') AND EXISTS(
    SELECT 1 FROM action_execution_step_contract prior WHERE prior.execution_id=e.id AND prior.ordinal<s.ordinal
      AND NOT EXISTS(SELECT 1 FROM action_execution_attempt_contract done WHERE done.step_id=prior.id AND done.finished_at IS NOT NULL
        AND ((done.result IN ('matched','matched_external') AND done.observation_completeness='complete' AND done.observation_surface=prior.required_surface)
          OR (done.result='acknowledged' AND (prior.required_surface='provider_response' OR prior.verification_timing='after_effects'))
          OR (done.result='generated' AND prior.required_surface='internal_artifact')))
   ) THEN RAISE EXCEPTION 'earlier planned steps must satisfy their required evidence before next mutation'; END IF;
   IF NEW.kind='write' THEN
    IF e.writes_closed_at IS NOT NULL THEN RAISE EXCEPTION 'mutation phase closed; only readback remains'; END IF;
    IF EXISTS(SELECT 1 FROM action_execution_attempt_contract done WHERE done.step_id=s.id AND done.finished_at IS NOT NULL
      AND done.result IN ('acknowledged','matched','matched_external'))
    THEN RAISE EXCEPTION 'effect already applied; further requests may only verify'; END IF;
    IF s.kind IN ('internal_generate_content','internal_revise_content','internal_commit_children','internal_recheck_prerequisite')
    THEN RAISE EXCEPTION 'internal step cannot issue provider write'; END IF;
    IF s.kind='asc_app_clip_header_commit' AND NOT EXISTS(
      SELECT 1 FROM action_media_content m WHERE m.organization_id=s.organization_id
       AND m.revision_id=s.content_revision_id AND m.slot=s.media_slot AND m.byte_length>0
       AND m.byte_length=(SELECT sum(ch.upload_length) FROM action_execution_step_contract ch
        WHERE ch.execution_id=e.id AND ch.kind='asc_app_clip_header_upload_chunk' AND ch.media_slot=s.media_slot AND ch.ordinal<s.ordinal)
    ) THEN RAISE EXCEPTION 'header commit requires every pinned byte represented by preceding nonoverlapping chunks'; END IF;
    SELECT * INTO g FROM action_resource_guard WHERE id=e.resource_guard_id;
    IF g.holder_execution_id IS DISTINCT FROM e.id OR g.holder_organization_id IS DISTINCT FROM e.organization_id
    THEN RAISE EXCEPTION 'provider write requires held canonical resource guard'; END IF;
    IF EXISTS(SELECT 1 FROM action_execution_attempt_contract w WHERE w.execution_id=e.id AND w.kind='write' AND w.result='uncertain'
      AND NOT action_write_has_resolution(w.id))
    THEN RAISE EXCEPTION 'unresolved earlier write permits readback only'; END IF;
   END IF;
   IF NEW.kind='generation' AND (NEW.transport<>'internal' OR s.kind NOT IN ('internal_generate_content','internal_revise_content','internal_commit_children','internal_recheck_prerequisite'))
   THEN RAISE EXCEPTION 'generation requires internal typed step'; END IF;
  END IF;
 END IF;
 IF NEW.subject_attempt_id IS NOT NULL THEN
  SELECT * INTO subject FROM action_execution_attempt_contract WHERE organization_id=NEW.organization_id AND id=NEW.subject_attempt_id;
  IF subject.step_id IS DISTINCT FROM NEW.step_id OR subject.number>=NEW.number OR subject.kind='late_evidence'
  THEN RAISE EXCEPTION 'observation subject must be earlier actual attempt on same step'; END IF;
 END IF;
 IF NEW.result='matched_external' THEN
  IF NEW.kind='late_evidence' AND subject.kind='readback' THEN
   SELECT * INTO external_write FROM action_execution_attempt_contract WHERE organization_id=NEW.organization_id AND id=subject.subject_attempt_id;
  ELSE external_write:=subject; END IF;
  IF (NEW.kind<>'readback' AND NOT (NEW.kind='late_evidence' AND subject.kind='readback'))
    OR external_write.kind IS DISTINCT FROM 'write' OR external_write.result IS DISTINCT FROM 'known_not_applied'
    OR external_write.finished_at IS NULL OR external_write.step_id IS DISTINCT FROM NEW.step_id
  THEN RAISE EXCEPTION 'external match requires a definitively unapplied original write and exact readback'; END IF;
 END IF;
 IF NEW.input_attempt_id IS NOT NULL THEN
  SELECT * INTO input_row FROM action_execution_attempt_contract WHERE organization_id=NEW.organization_id AND id=NEW.input_attempt_id;
  IF input_row.execution_id IS DISTINCT FROM e.id OR input_row.step_id IS DISTINCT FROM s.input_step_id
   OR input_row.finished_at IS NULL OR input_row.result NOT IN ('acknowledged','matched','matched_external','generated')
  THEN RAISE EXCEPTION 'input must reference recorded successful result of declared predecessor'; END IF;
 ELSIF s.input_step_id IS NOT NULL AND NEW.kind IN ('write','generation') THEN
  RAISE EXCEPTION 'dependent request requires exact input attempt result';
 END IF;
 IF s.kind='play_inspection_edit_delete' AND NEW.result='acknowledged' AND
   (input_row.id IS NULL OR projected.provider_edit_id IS DISTINCT FROM input_row.provider_edit_id)
 THEN RAISE EXCEPTION 'inspection cleanup must delete the exact persisted inspection edit'; END IF;
 IF s.kind='play_inspection_edit_create' AND NEW.result IN ('matched','matched_external') AND (
   subject.id IS NULL OR subject.provider_edit_id IS NULL OR projected.provider_edit_id IS DISTINCT FROM subject.provider_edit_id
   OR NOT EXISTS(SELECT 1 FROM google_play.listing_contract snapshot WHERE snapshot.organization_id=NEW.organization_id
      AND snapshot.revision_id=NEW.observation_revision_id AND snapshot.google_edit_id=subject.provider_edit_id)
 ) THEN RAISE EXCEPTION 'inspection match must observe the exact persisted inspection edit'; END IF;
 IF NEW.output_kind IS NOT NULL THEN
  IF ap.scope='revise' THEN
   IF NEW.output_kind<>'revision' THEN RAISE EXCEPTION 'iteration produces a new reviewed-content revision'; END IF;
  ELSIF approved_revision.operation='generate_review_analysis' THEN
   IF NEW.output_kind<>'review_analysis' THEN RAISE EXCEPTION 'analysis generation must name its actual saved analysis'; END IF;
  ELSIF approved_revision.operation='run_agent' THEN
   IF NEW.output_kind<>'agent_run' THEN RAISE EXCEPTION 'agent request must name its completed run'; END IF;
  ELSIF approved_revision.operation='review_catch_up_30d' THEN
   IF NEW.output_kind NOT IN ('revision','no_work') THEN RAISE EXCEPTION 'catch-up produces a fixed review package or explicit no-work result'; END IF;
  ELSIF NEW.output_kind<>'revision' THEN
   RAISE EXCEPTION 'content generation requires exact sealed output revision';
  END IF;
  IF NEW.output_kind='review_analysis' AND NOT EXISTS(
   SELECT 1 FROM public.review_analysis output WHERE output.id=NEW.output_review_analysis_id
    AND output.organization_id=NEW.organization_id AND output.asset_id=a.asset_id
    AND output.total_reviews_analyzed>0
  ) THEN RAISE EXCEPTION 'analysis result must exist for exact organization and asset with an actual review sample'; END IF;
  IF NEW.output_kind='agent_run' AND (NEW.output_agent_run_id IS DISTINCT FROM NEW.agent_run_id OR NOT EXISTS(
   SELECT 1 FROM public.agent_run output JOIN public.agent owner_agent ON owner_agent.id=output."agentId"
    WHERE output.id=NEW.output_agent_run_id AND output."organizationId"=NEW.organization_id
     AND owner_agent."organizationId"=NEW.organization_id AND owner_agent."assetId" IS NOT DISTINCT FROM a.asset_id
     AND (SELECT request.intent<>'wake_agent' OR request.requested_agent_id=output."agentId"
          FROM action_request_content request WHERE request.organization_id=ap.organization_id AND request.revision_id=ap.revision_id)
     AND output.status='completed' AND output."completedAt" IS NOT NULL
  )) THEN RAISE EXCEPTION 'agent result must match requested agent and exact started run completed on approved organization and asset'; END IF;
  IF NEW.output_kind='no_work' AND (
    approved_revision.operation<>'review_catch_up_30d' OR NEW.no_work_reason IS DISTINCT FROM 'no_eligible_reviews'
    OR NOT EXISTS(SELECT 1 FROM public.agent_run output JOIN public.agent owner_agent ON owner_agent.id=output."agentId"
      WHERE output.id=NEW.agent_run_id AND output."organizationId"=NEW.organization_id
       AND owner_agent."organizationId"=NEW.organization_id AND owner_agent."assetId" IS NOT DISTINCT FROM a.asset_id
       AND output.status='completed' AND output."completedAt" IS NOT NULL)
  ) THEN RAISE EXCEPTION 'no-work catch-up requires exact reason and completed scoped generation run'; END IF;
 END IF;
 IF NEW.output_revision_id IS NOT NULL THEN
  SELECT * INTO r FROM action_revision WHERE organization_id=NEW.organization_id AND id=NEW.output_revision_id;
  IF r.id IS NULL OR NOT r.sealed OR r.purpose<>'proposal' OR r.action_id IS DISTINCT FROM ap.action_id
   OR r.generated_from_revision_id IS DISTINCT FROM ap.revision_id
  THEN RAISE EXCEPTION 'generated output must be sealed content derived from exact approved input on same ticket'; END IF;
  IF ap.scope<>'revise' AND approved_revision.operation='review_catch_up_30d' AND (r.kind<>'collection' OR r.operation<>'post_batch')
  THEN RAISE EXCEPTION 'catch-up output must be a sealed concrete review package'; END IF;
 END IF;
 IF NEW.observation_revision_id IS NOT NULL THEN
  SELECT * INTO r FROM action_revision WHERE organization_id=NEW.organization_id AND id=NEW.observation_revision_id;
  IF r.id IS NULL OR NOT r.sealed OR r.purpose<>'observation'
   OR r.action_id IS DISTINCT FROM approved_revision.action_id OR r.kind IS DISTINCT FROM approved_revision.kind
   OR r.operation IS DISTINCT FROM approved_revision.operation
  THEN RAISE EXCEPTION 'verification evidence requires sealed observation revision'; END IF;
  PERFORM assert_same_provider_content_target(NEW.organization_id,ap.revision_id,r.id);
 END IF;
 IF NEW.result='known_not_applied' THEN
  IF NEW.kind='readback' OR (NEW.kind='late_evidence' AND subject.kind='readback') THEN
   IF NEW.non_application_basis NOT IN ('provider_terminal_non_application','expired_uncommitted_edit')
    OR (NEW.non_application_basis='provider_terminal_non_application' AND (projected.provider_request_id IS NULL OR subject.provider_request_id IS NULL OR projected.provider_request_id IS DISTINCT FROM subject.provider_request_id))
    OR (NEW.non_application_basis='expired_uncommitted_edit' AND (
      s.kind<>'play_listing_set' OR projected.provider_edit_id IS NULL
      OR NOT EXISTS(SELECT 1 FROM action_execution_attempt_contract created JOIN action_execution_step_contract create_step ON create_step.id=created.step_id
        WHERE create_step.execution_id=e.id AND create_step.kind='play_edit_create' AND created.result IN ('acknowledged','matched') AND created.provider_edit_id=projected.provider_edit_id)
      OR projected.provider_edit_expires_at IS NULL OR projected.provider_edit_expires_at>NEW.observed_at
      OR EXISTS(SELECT 1 FROM action_execution_step_contract commit_step JOIN action_execution_attempt_contract commit_attempt ON commit_attempt.step_id=commit_step.id
        WHERE commit_step.execution_id=e.id AND commit_step.kind='play_edit_commit' AND commit_attempt.kind='write')
    ))
   THEN RAISE EXCEPTION 'negative read is not proof of final non-application'; END IF;
  ELSIF NEW.non_application_basis NOT IN ('pre_dispatch_failure','provider_rejection') THEN
   RAISE EXCEPTION 'direct failure requires pre-dispatch or definitive provider rejection evidence';
  END IF;
 END IF;
 IF NEW.result IN ('acknowledged','matched','matched_external') THEN
  IF (s.kind IN ('play_edit_create','play_inspection_edit_create','play_inspection_edit_delete') AND projected.provider_edit_id IS NULL)
   OR (s.kind IN ('asc_app_info_localization_upsert','asc_version_localization_upsert','asc_app_clip_localization_create') AND projected.provider_localization_id IS NULL)
   OR (s.kind='asc_app_clip_header_reserve' AND projected.provider_media_id IS NULL)
   OR (s.kind IN ('asa_keyword_create','asa_negative_keyword_create') AND projected.provider_resource_id IS NULL)
  THEN RAISE EXCEPTION 'successful provider creation requires its typed durable result identifier'; END IF;
 END IF;
 IF ((s.kind IN ('internal_generate_content','internal_revise_content','internal_commit_children','internal_recheck_prerequisite')) AND NEW.transport<>'internal')
  OR ((s.kind IN ('play_edit_create','play_listing_set','play_edit_commit','play_inspection_edit_create','play_inspection_edit_delete','play_review_response_set')) AND NEW.transport NOT IN ('play_api','play_session','play_browser'))
  OR ((s.kind IN ('asa_campaign_status_set','asa_campaign_budget_set','asa_keyword_bid_set','asa_keyword_create','asa_negative_keyword_create','asa_negative_keyword_delete')) AND NEW.transport<>'asa_api')
  OR ((s.kind IN ('asc_app_info_localization_upsert','asc_version_localization_upsert','asc_live_promotional_text_set','asc_editable_promotional_text_set','asc_review_response_upsert','asc_app_clip_localization_create','asc_app_clip_header_reserve','asc_app_clip_header_upload_chunk','asc_app_clip_header_commit','asc_app_clip_incomplete_header_delete')) AND NEW.transport NOT IN ('asc_api','asc_browser'))
 THEN RAISE EXCEPTION 'attempt transport does not implement its typed provider step'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION action_guard_resource_holder() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE old_execution action_execution%ROWTYPE; new_execution action_execution%ROWTYPE;
BEGIN
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'canonical resource guard rows are retained'; END IF;
 IF TG_OP='UPDATE' AND OLD.holder_organization_id IS NOT NULL
   AND NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.holder_organization_id)
   AND NEW.holder_execution_id IS NULL AND NEW.holder_organization_id IS NULL AND NEW.acquired_at IS NULL
   AND ROW(NEW.id,NEW.provider,NEW.provider_account_id,NEW.remote_application_id,NEW.scope) IS NOT DISTINCT FROM ROW(OLD.id,OLD.provider,OLD.provider_account_id,OLD.remote_application_id,OLD.scope)
 THEN RETURN NEW; END IF;
 IF TG_OP='UPDATE' THEN
  IF ROW(NEW.id,NEW.provider,NEW.provider_account_id,NEW.remote_application_id,NEW.scope)
    IS DISTINCT FROM ROW(OLD.id,OLD.provider,OLD.provider_account_id,OLD.remote_application_id,OLD.scope)
  THEN RAISE EXCEPTION 'canonical resource identity is immutable'; END IF;
  IF OLD.holder_execution_id IS NOT NULL AND NEW.holder_execution_id IS DISTINCT FROM OLD.holder_execution_id THEN
   SELECT * INTO old_execution FROM action_execution WHERE id=OLD.holder_execution_id FOR UPDATE;
   IF old_execution.phase NOT IN ('settled','cancelled') AND old_execution.writes_closed_at IS NULL
     AND NOT (old_execution.phase='blocked'
       AND NOT EXISTS(SELECT 1 FROM action_execution_attempt_contract pending WHERE pending.execution_id=old_execution.id AND pending.finished_at IS NULL)
       AND NOT EXISTS(SELECT 1 FROM action_execution_attempt_contract uncertain WHERE uncertain.execution_id=old_execution.id AND uncertain.kind='write' AND uncertain.result='uncertain' AND NOT action_write_has_resolution(uncertain.id)))
   THEN RAISE EXCEPTION 'resource remains excluded until writes close or execution settles; lease expiry is insufficient'; END IF;
  END IF;
 END IF;
 IF NEW.holder_execution_id IS NOT NULL THEN
  SELECT * INTO new_execution FROM action_execution WHERE id=NEW.holder_execution_id FOR UPDATE;
  IF new_execution.id IS NULL OR new_execution.organization_id IS DISTINCT FROM NEW.holder_organization_id
    OR new_execution.resource_guard_id IS DISTINCT FROM NEW.id OR new_execution.phase IN ('settled','cancelled')
  THEN RAISE EXCEPTION 'resource holder must be active execution approved for this exact guard'; END IF;
 END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION validate_domain_tenant() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
DECLARE owner_id text;
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF TG_TABLE_NAME IN ('action','action_policy_revision') THEN
  IF NEW.asset_id IS NOT NULL THEN
   SELECT "organizationId" INTO owner_id FROM public.asset WHERE id=NEW.asset_id;
   IF owner_id IS DISTINCT FROM NEW.organization_id THEN RAISE EXCEPTION 'asset tenant mismatch' USING ERRCODE='23514'; END IF;
  END IF;
 ELSE
  CASE NEW.kind
   WHEN 'agent_run' THEN SELECT "organizationId" INTO owner_id FROM public.agent_run WHERE id=NEW.source_agent_run_id;
   WHEN 'report_version' THEN SELECT organization_id INTO owner_id FROM public.report_version WHERE id=NEW.source_report_version_id;
   WHEN 'backlog_item' THEN SELECT organization_id INTO owner_id FROM public.opportunity_backlog WHERE id=NEW.source_backlog_id;
   WHEN 'recommendation' THEN SELECT a."organizationId" INTO owner_id FROM public.aso_recommendation s JOIN public.asset a ON a.id=s."assetId" WHERE s.id=NEW.source_recommendation_id;
   WHEN 'recommendation_variant' THEN SELECT a."organizationId" INTO owner_id FROM public.aso_recommendation_variant v JOIN public.aso_recommendation s ON s.id=v."recommendationId" JOIN public.asset a ON a.id=s."assetId" WHERE v.id=NEW.source_variant_id;
   WHEN 'experiment' THEN SELECT a."organizationId" INTO owner_id FROM public.aso_experiment e JOIN public.asset a ON a.id=e."assetId" WHERE e.id=NEW.source_experiment_id;
   WHEN 'action' THEN SELECT organization_id INTO owner_id FROM action WHERE id=NEW.source_action_id;
  END CASE;
  IF owner_id IS DISTINCT FROM NEW.organization_id THEN RAISE EXCEPTION 'source tenant mismatch' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION validate_command_integration_tenant() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,apple_ads,app_store_connect,google_play,public AS $$
BEGIN
 IF TG_OP='DELETE' THEN
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=OLD.organization_id) THEN RETURN OLD; END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM public.organization WHERE id=NEW.organization_id) THEN RETURN NEW; END IF;
 END IF;

 IF NEW.principal_kind IN ('user','api_key') AND NEW.actor_user_id IS NULL
  OR NEW.principal_kind='api_key' AND NEW.actor_api_key_id IS NULL
  OR NEW.channel IN ('slack','discord') AND NEW.external_actor_id IS NULL
 THEN RAISE EXCEPTION 'new command requires live attributable principal' USING ERRCODE='23514'; END IF;
 IF NEW.actor_slack_integration_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.slack_integration WHERE id=NEW.actor_slack_integration_id AND organization_id=NEW.organization_id) THEN RAISE EXCEPTION 'Slack integration tenant mismatch' USING ERRCODE='23514'; END IF;
 IF NEW.actor_discord_integration_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.discord_integration WHERE id=NEW.actor_discord_integration_id AND organization_id=NEW.organization_id) THEN RAISE EXCEPTION 'Discord integration tenant mismatch' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER provider_content_complete AFTER INSERT OR UPDATE ON actions.action_revision
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.provider_content_complete_at_commit();
--> statement-breakpoint
CREATE TRIGGER action_target_continuity BEFORE UPDATE ON actions.action
 FOR EACH ROW EXECUTE FUNCTION actions.guard_action_target_continuity();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER request_agent_target_complete AFTER INSERT OR UPDATE ON actions.action_request_content
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.request_agent_target_at_commit();
--> statement-breakpoint
CREATE TRIGGER membership_immutable BEFORE INSERT OR UPDATE OR DELETE ON action_membership FOR EACH ROW EXECUTE FUNCTION guard_membership_edit();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER revision_complete AFTER INSERT OR UPDATE ON action_revision DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION revision_complete_at_commit();
--> statement-breakpoint
CREATE TRIGGER revision_immutable BEFORE UPDATE OR DELETE ON action_revision FOR EACH ROW EXECUTE FUNCTION guard_revision_update();
--> statement-breakpoint
CREATE TRIGGER action_identity BEFORE UPDATE ON action FOR EACH ROW EXECUTE FUNCTION guard_action_graph();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER action_graph_complete AFTER INSERT ON action DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION guard_action_graph();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER dependency_no_cycle AFTER INSERT ON action_dependency DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION dependency_acyclic();
--> statement-breakpoint
CREATE TRIGGER action_command_mutation BEFORE INSERT OR UPDATE OR DELETE ON action FOR EACH ROW EXECUTE FUNCTION guard_action_command_mutation();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER action_command_head AFTER INSERT OR UPDATE ON action DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION action_head_at_commit();
--> statement-breakpoint
CREATE TRIGGER evidence_target_snapshot BEFORE INSERT ON action_command_target FOR EACH ROW EXECUTE FUNCTION guard_evidence_target_snapshot();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER command_target_snapshot AFTER INSERT ON action_command_target DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION command_target_at_commit();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER approval_command_snapshot AFTER INSERT ON action_approval DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION approval_command_at_commit();
--> statement-breakpoint
CREATE TRIGGER policy_command_guard BEFORE INSERT OR UPDATE OR DELETE ON action_policy_revision FOR EACH ROW EXECUTE FUNCTION guard_policy_command();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER command_result_complete AFTER INSERT ON action_command DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION command_completion_at_commit();
--> statement-breakpoint
CREATE TRIGGER personal_read_guard BEFORE INSERT OR UPDATE ON action_read FOR EACH ROW EXECUTE FUNCTION guard_personal_read();
--> statement-breakpoint
CREATE TRIGGER action_execution_transition BEFORE INSERT OR UPDATE OR DELETE ON action_execution
 FOR EACH ROW EXECUTE FUNCTION action_guard_execution_transition();
--> statement-breakpoint
CREATE TRIGGER action_approval_authority BEFORE INSERT OR UPDATE OR DELETE ON action_approval
 FOR EACH ROW EXECUTE FUNCTION action_guard_approval_execution_authority();
--> statement-breakpoint
CREATE TRIGGER action_execution_step_guard BEFORE INSERT OR UPDATE OR DELETE ON action_execution_step
 FOR EACH ROW EXECUTE FUNCTION action_guard_execution_step();
--> statement-breakpoint
CREATE TRIGGER action_execution_attempt_guard BEFORE INSERT OR UPDATE OR DELETE ON action_execution_attempt
 FOR EACH ROW EXECUTE FUNCTION action_guard_attempt();
--> statement-breakpoint
CREATE TRIGGER action_resource_holder_guard BEFORE INSERT OR UPDATE OR DELETE ON action_resource_guard
 FOR EACH ROW EXECUTE FUNCTION action_guard_resource_holder();
--> statement-breakpoint
CREATE TRIGGER provenance_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON action_revision_source FOR EACH ROW EXECUTE FUNCTION guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER action_domain_scope BEFORE INSERT OR UPDATE ON action FOR EACH ROW EXECUTE FUNCTION validate_domain_tenant();
--> statement-breakpoint
CREATE TRIGGER provenance_domain_scope BEFORE INSERT OR UPDATE ON action_revision_source FOR EACH ROW EXECUTE FUNCTION validate_domain_tenant();
--> statement-breakpoint
CREATE TRIGGER policy_domain_scope BEFORE INSERT OR UPDATE ON action_policy_revision FOR EACH ROW EXECUTE FUNCTION validate_domain_tenant();
--> statement-breakpoint
CREATE TRIGGER command_integration_scope BEFORE INSERT ON action_command FOR EACH ROW EXECUTE FUNCTION validate_command_integration_tenant();
--> statement-breakpoint
CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON actions.action_review_content FOR EACH ROW EXECUTE FUNCTION actions.guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON actions.action_listing_content FOR EACH ROW EXECUTE FUNCTION actions.guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON actions.action_content_term FOR EACH ROW EXECUTE FUNCTION actions.guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON actions.action_media_content FOR EACH ROW EXECUTE FUNCTION actions.guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON actions.action_request_content FOR EACH ROW EXECUTE FUNCTION actions.guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON actions.action_market_country FOR EACH ROW EXECUTE FUNCTION actions.guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON actions.action_market_competitor FOR EACH ROW EXECUTE FUNCTION actions.guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON actions.action_content_note FOR EACH ROW EXECUTE FUNCTION actions.guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON actions.action_advisory_content FOR EACH ROW EXECUTE FUNCTION actions.guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON apple_ads.action_content FOR EACH ROW EXECUTE FUNCTION actions.guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON app_store_connect.listing_contract FOR EACH ROW EXECUTE FUNCTION actions.guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON google_play.listing_contract FOR EACH ROW EXECUTE FUNCTION actions.guard_revision_content_edit();
--> statement-breakpoint
CREATE TRIGGER immutable_fact BEFORE UPDATE OR DELETE ON actions.action_command FOR EACH ROW EXECUTE FUNCTION actions.guard_command_erasure();
--> statement-breakpoint
CREATE TRIGGER immutable_fact BEFORE UPDATE OR DELETE ON actions.action_command_target FOR EACH ROW EXECUTE FUNCTION actions.reject_immutable_change();
--> statement-breakpoint
CREATE TRIGGER immutable_fact BEFORE UPDATE OR DELETE ON actions.action_approval FOR EACH ROW EXECUTE FUNCTION actions.reject_immutable_change();
--> statement-breakpoint
CREATE TRIGGER immutable_fact BEFORE UPDATE OR DELETE ON actions.action_dependency FOR EACH ROW EXECUTE FUNCTION actions.reject_immutable_change();
--> statement-breakpoint
CREATE TRIGGER immutable_fact BEFORE UPDATE OR DELETE ON actions.action_alias FOR EACH ROW EXECUTE FUNCTION actions.reject_immutable_change();
--> statement-breakpoint
CREATE TRIGGER provider_fact_immutable BEFORE INSERT OR UPDATE OR DELETE ON app_store_connect.step_contract FOR EACH ROW EXECUTE FUNCTION actions.guard_provider_fact_insert();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER provider_fact_complete AFTER INSERT ON app_store_connect.step_contract DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.provider_fact_complete_at_commit();
--> statement-breakpoint
CREATE TRIGGER provider_fact_immutable BEFORE INSERT OR UPDATE OR DELETE ON app_store_connect.attempt_receipt FOR EACH ROW EXECUTE FUNCTION actions.guard_provider_fact_insert();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER provider_fact_complete AFTER INSERT ON app_store_connect.attempt_receipt DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.provider_fact_complete_at_commit();
--> statement-breakpoint
CREATE TRIGGER provider_fact_immutable BEFORE INSERT OR UPDATE OR DELETE ON google_play.attempt_receipt FOR EACH ROW EXECUTE FUNCTION actions.guard_provider_fact_insert();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER provider_fact_complete AFTER INSERT ON google_play.attempt_receipt DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.provider_fact_complete_at_commit();
--> statement-breakpoint
CREATE TRIGGER provider_fact_immutable BEFORE INSERT OR UPDATE OR DELETE ON apple_ads.attempt_receipt FOR EACH ROW EXECUTE FUNCTION actions.guard_provider_fact_insert();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER provider_fact_complete AFTER INSERT ON apple_ads.attempt_receipt DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.provider_fact_complete_at_commit();

--> statement-breakpoint
CREATE TRIGGER actions_retire_user_references AFTER DELETE ON public."user" FOR EACH ROW EXECUTE FUNCTION actions.erase_user_ticket_references();
--> statement-breakpoint
CREATE TRIGGER actions_release_erased_organization AFTER DELETE ON public.organization FOR EACH ROW EXECUTE FUNCTION actions.erase_organization_resource_holders();
--> statement-breakpoint
-- Defer identity checks through a single tenant-erasure statement, including cycles.
DO $$ DECLARE fk record; BEGIN
 FOR fk IN SELECT conrelid::regclass AS relation,conname FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname IN ('actions','app_store_connect','google_play','apple_ads') AND c.contype='f'
 LOOP EXECUTE format('ALTER TABLE %s ALTER CONSTRAINT %I DEFERRABLE INITIALLY DEFERRED',fk.relation,fk.conname); END LOOP;
END $$;
