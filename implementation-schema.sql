-- FLO-1355 implementation snapshot. Depends on existing repository schema.
-- Not a standalone deployment or historical data import. No production deployment.

-- 0155_actions_reliability_foundation.sql
CREATE SCHEMA "actions";
--> statement-breakpoint
CREATE SCHEMA "agent_work";
--> statement-breakpoint
CREATE SCHEMA "composition";
--> statement-breakpoint
CREATE SCHEMA "review_work";
--> statement-breakpoint
CREATE SCHEMA "app_store_connect";
--> statement-breakpoint
CREATE SCHEMA "google_play";
--> statement-breakpoint
CREATE TYPE "actions"."alias_namespace" AS ENUM('pending_action', 'pending_action_batch', 'review_draft', 'review_draft_batch', 'agent_request', 'agent_activity', 'review_history', 'review_draft_rejection', 'capability_execution', 'recommendation', 'recommendation_variant', 'recovery_receipt');--> statement-breakpoint
CREATE TYPE "actions"."approval_scope" AS ENUM('perform', 'generate', 'revise');--> statement-breakpoint
CREATE TYPE "actions"."channel" AS ENUM('web', 'chat', 'mcp', 'api', 'slack', 'discord', 'agent', 'worker', 'operator', 'migration');--> statement-breakpoint
CREATE TYPE "actions"."command_error" AS ENUM('not_found', 'stale_version', 'stale_revision', 'stale_membership', 'invalid_transition', 'undo_expired', 'execution_started', 'unresolved_write', 'permission_changed', 'billing_required', 'unsupported_operation', 'idempotency_mismatch', 'target_changed', 'incomplete_revision', 'client_attention_capacity');--> statement-breakpoint
CREATE TYPE "actions"."command_kind" AS ENUM('create', 'reconcile', 'record_observation', 'record_attempt', 'record_progress', 'resolve_external', 'resolve_dependency', 'grant_policy', 'revoke_policy', 'approve', 'undo', 'reject', 'acknowledge', 'snooze', 'unsnooze', 'assign', 'archive', 'restore', 'supersede', 'retry', 'revise', 'reopen', 'open_recovery', 'resume_hold', 'schedule', 'unschedule', 'abandon');--> statement-breakpoint
CREATE TYPE "actions"."command_outcome" AS ENUM('accepted', 'conflict', 'refused');--> statement-breakpoint
CREATE TYPE "actions"."cycle_purpose" AS ENUM('binding', 'prewrite', 'readback', 'cleanup');--> statement-breakpoint
CREATE TYPE "actions"."decision" AS ENUM('open', 'approved', 'declined', 'acknowledged', 'handled_externally', 'cancelled', 'superseded');--> statement-breakpoint
CREATE TYPE "actions"."dependency_requirement" AS ENUM('completed', 'verified_live', 'verified_editable', 'generated', 'permission_restored', 'release_available');--> statement-breakpoint
CREATE TYPE "actions"."domain" AS ENUM('reviews', 'listing', 'ads', 'agent', 'advisory', 'collection');--> statement-breakpoint
CREATE TYPE "actions"."principal_kind" AS ENUM('user', 'api_key', 'agent', 'policy', 'system');--> statement-breakpoint
CREATE TYPE "actions"."record_kind" AS ENUM('work', 'historical', 'historical_deleted');--> statement-breakpoint
CREATE TYPE "actions"."restore_mode" AS ENUM('placement', 'reconsider', 'unhide');--> statement-breakpoint
CREATE TYPE "actions"."revision_kind" AS ENUM('review_reply', 'listing', 'request', 'ads', 'advisory', 'collection');--> statement-breakpoint
CREATE TYPE "actions"."revision_purpose" AS ENUM('proposal', 'baseline', 'observation', 'historical');--> statement-breakpoint
CREATE TYPE "actions"."surface" AS ENUM('provider_response', 'editable_listing', 'live_listing', 'review_response', 'advertising_resource', 'internal_artifact');--> statement-breakpoint
CREATE TYPE "agent_work"."attention_agent_type" AS ENUM('orchestrator', 'review', 'aso', 'custom');--> statement-breakpoint
CREATE TYPE "composition"."expansion" AS ENUM('ordinary', 'expansion');--> statement-breakpoint
CREATE TYPE "composition"."provider" AS ENUM('internal', 'app_store_connect', 'google_play', 'apple_search_ads');--> statement-breakpoint
CREATE TYPE "composition"."resource_scope" AS ENUM('none', 'store_application', 'advertising_account');--> statement-breakpoint
CREATE TYPE "composition"."required_surface" AS ENUM('provider_response', 'editable_listing', 'live_listing', 'review_response', 'advertising_resource', 'internal_artifact');--> statement-breakpoint
CREATE TYPE "composition"."verification_timing" AS ENUM('before_successor', 'after_effects');--> statement-breakpoint
CREATE TYPE "review_work"."publication_state" AS ENUM('published', 'pending_publication', 'hidden', 'deleted', 'unreadable');--> statement-breakpoint
CREATE TYPE "review_work"."reply_intent" AS ENUM('send', 'update');--> statement-breakpoint
CREATE TYPE "review_work"."response_availability" AS ENUM('present', 'absent', 'unreadable', 'pending', 'unknown');--> statement-breakpoint
CREATE TYPE "review_work"."snapshot_availability" AS ENUM('present', 'absent', 'unreadable', 'unknown');--> statement-breakpoint
CREATE TYPE "review_work"."store" AS ENUM('ios', 'android');--> statement-breakpoint
CREATE TYPE "app_store_connect"."review_credential_kind" AS ENUM('individual', 'team');--> statement-breakpoint
CREATE TYPE "app_store_connect"."review_native_state" AS ENUM('PUBLISHED', 'PENDING_PUBLISH', 'NONE', 'PENDING_CREATE', 'PENDING_UPDATE', 'PENDING_DELETE');--> statement-breakpoint
CREATE TYPE "app_store_connect"."review_native_state_source" AS ENUM('api_publication', 'browser_pending');--> statement-breakpoint
CREATE TYPE "app_store_connect"."review_receipt_kind" AS ENUM('accepted', 'deleted', 'http_error', 'invalid_response');--> statement-breakpoint
CREATE TYPE "app_store_connect"."review_receipt_transport" AS ENUM('asc_api');--> statement-breakpoint
CREATE TYPE "actions"."attempt_kind" AS ENUM('write', 'readback', 'inspection', 'generation', 'manual_observation', 'late_evidence', 'conflicting_completion');--> statement-breakpoint
CREATE TYPE "actions"."attempt_result" AS ENUM('acknowledged', 'known_not_applied', 'uncertain', 'generated', 'discarded', 'matched', 'matched_external', 'mismatch', 'unreadable');--> statement-breakpoint
CREATE TYPE "actions"."execution_hold_reason" AS ENUM('permission', 'billing', 'resource_busy', 'target_changed', 'uncertain_write', 'retry_exhausted', 'unsupported_readback', 'generation_conflict', 'awaiting_release', 'awaiting_publication', 'plan_incomplete', 'evidence_conflict');--> statement-breakpoint
CREATE TYPE "actions"."execution_phase" AS ENUM('ready', 'claimed', 'verification_due', 'uncertain', 'blocked', 'settled', 'cancelled');--> statement-breakpoint
CREATE TYPE "actions"."execution_resolution_owner" AS ENUM('client', 'fload', 'provider');--> statement-breakpoint
CREATE TYPE "actions"."execution_result" AS ENUM('generated', 'verified_live', 'verified_editable', 'handled_externally', 'acknowledged_only', 'failed', 'cancelled');--> statement-breakpoint
CREATE TYPE "actions"."failure_class" AS ENUM('permission', 'rate_limit', 'transport', 'target_changed', 'provider_rejected', 'persistence', 'unsupported_readback', 'invalid_content', 'billing');--> statement-breakpoint
CREATE TYPE "actions"."inspection_purpose" AS ENUM('binding', 'prewrite');--> statement-breakpoint
CREATE TYPE "actions"."no_work_reason" AS ENUM('no_eligible_reviews');--> statement-breakpoint
CREATE TYPE "actions"."non_application_basis" AS ENUM('provider_rejection', 'pre_dispatch_failure', 'provider_proved_non_application');--> statement-breakpoint
CREATE TYPE "actions"."observation_completeness" AS ENUM('complete', 'partial', 'unavailable');--> statement-breakpoint
CREATE TYPE "actions"."output_kind" AS ENUM('revision', 'review_analysis', 'agent_run', 'no_work');--> statement-breakpoint
CREATE TYPE "actions"."retry_disposition" AS ENUM('retryable', 'permanent');--> statement-breakpoint
CREATE TYPE "actions"."uncertainty_reason" AS ENUM('transport_lost', 'claim_expired', 'invalid_response', 'accepted_pending');--> statement-breakpoint
CREATE TYPE "actions"."unreadable_reason" AS ENUM('unavailable', 'partial', 'unsupported', 'cancelled', 'no_editable_release');--> statement-breakpoint
CREATE TABLE "actions"."action" (
	"id" text PRIMARY KEY NOT NULL,
	"organization_id" text NOT NULL,
	"creation_key" uuid NOT NULL,
	"asset_id" text,
	"domain" "actions"."domain" NOT NULL,
	"record_kind" "actions"."record_kind" DEFAULT 'work' NOT NULL,
	"parent_action_id" text,
	"decision" "actions"."decision" DEFAULT 'open' NOT NULL,
	"version" bigint DEFAULT 1 NOT NULL,
	"attention_version" bigint DEFAULT 1 NOT NULL,
	"current_revision_id" text NOT NULL,
	"current_approval_id" text,
	"owner_user_id" text,
	"priority" smallint DEFAULT 2 NOT NULL,
	"snoozed_until" timestamp with time zone,
	"scheduled_for" timestamp with time zone,
	"archived_at" timestamp with time zone,
	"successor_action_id" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "action_tenant_identity" UNIQUE("organization_id","id"),
	CONSTRAINT "action_creation_identity" UNIQUE("organization_id","creation_key"),
	CONSTRAINT "action_instant_bounds" CHECK (("actions"."action"."created_at" IS NULL OR "actions"."action"."created_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."action"."updated_at" IS NULL OR "actions"."action"."updated_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."action"."snoozed_until" IS NULL OR "actions"."action"."snoozed_until" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."action"."scheduled_for" IS NULL OR "actions"."action"."scheduled_for" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."action"."archived_at" IS NULL OR "actions"."action"."archived_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)),
	CONSTRAINT "action_versions_positive" CHECK ("actions"."action"."version" > 0 AND "actions"."action"."attention_version" > 0 AND "actions"."action"."attention_version" <= "actions"."action"."version"),
	CONSTRAINT "action_priority_valid" CHECK ("actions"."action"."priority" BETWEEN 1 AND 3),
	CONSTRAINT "action_successor_shape" CHECK (("actions"."action"."decision" = 'superseded') = ("actions"."action"."successor_action_id" IS NOT NULL) AND "actions"."action"."successor_action_id" IS DISTINCT FROM "actions"."action"."id"),
	CONSTRAINT "action_parent_not_self" CHECK ("actions"."action"."parent_action_id" IS DISTINCT FROM "actions"."action"."id"),
	CONSTRAINT "action_time_order" CHECK ("actions"."action"."updated_at" >= "actions"."action"."created_at"),
	CONSTRAINT "action_historical_non_authorizing" CHECK ("actions"."action"."record_kind" = 'work' OR ("actions"."action"."current_approval_id" IS NULL AND "actions"."action"."decision" IN ('open', 'declined', 'superseded'))),
	CONSTRAINT "action_approval_pointer_shape" CHECK (("actions"."action"."decision" = 'approved') = ("actions"."action"."current_approval_id" IS NOT NULL))
);
--> statement-breakpoint
ALTER TABLE "actions"."action" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."alias" (
	"organization_id" text NOT NULL,
	"namespace" "actions"."alias_namespace" NOT NULL,
	"old_id" text NOT NULL,
	"action_id" text NOT NULL,
	"historical_membership_known" boolean NOT NULL,
	CONSTRAINT "alias_organization_id_namespace_old_id_pk" PRIMARY KEY("organization_id","namespace","old_id")
);
--> statement-breakpoint
ALTER TABLE "actions"."alias" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."approval" (
	"id" text PRIMARY KEY NOT NULL,
	"organization_id" text NOT NULL,
	"action_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"command_id" text NOT NULL,
	"scope" "actions"."approval_scope" NOT NULL,
	"revision_instructions" text,
	"parent_revision_id" text,
	"undo_deadline" timestamp with time zone NOT NULL,
	"required_surface" "actions"."surface" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "approval_tenant_identity" UNIQUE("organization_id","id"),
	CONSTRAINT "approval_action_identity" UNIQUE("organization_id","action_id","id"),
	CONSTRAINT "approval_revision_identity" UNIQUE("organization_id","action_id","revision_id","id"),
	CONSTRAINT "approval_command_unique" UNIQUE("command_id","action_id"),
	CONSTRAINT "approval_instant_bounds" CHECK (("actions"."approval"."undo_deadline" IS NULL OR "actions"."approval"."undo_deadline" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."approval"."created_at" IS NULL OR "actions"."approval"."created_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)),
	CONSTRAINT "approval_revision_instructions_shape" CHECK (("actions"."approval"."scope" = 'revise') = ("actions"."approval"."revision_instructions" IS NOT NULL) AND ("actions"."approval"."revision_instructions" IS NULL OR length(btrim("actions"."approval"."revision_instructions")) > 0)),
	CONSTRAINT "approval_undo_order" CHECK ("actions"."approval"."undo_deadline" >= "actions"."approval"."created_at")
);
--> statement-breakpoint
ALTER TABLE "actions"."approval" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."command" (
	"id" text PRIMARY KEY NOT NULL,
	"organization_id" text NOT NULL,
	"idempotency_key" uuid NOT NULL,
	"principal_kind" "actions"."principal_kind" NOT NULL,
	"actor_user_id" text,
	"actor_acting_for_user_id" text,
	"actor_api_key_id" text,
	"actor_agent_run_id" text,
	"actor_policy_revision_id" text,
	"actor_subject_snapshot" text NOT NULL,
	"actor_name_snapshot" text,
	"channel" "actions"."channel" NOT NULL,
	"external_actor_id" text,
	"kind" "actions"."command_kind" NOT NULL,
	"restore_mode" "actions"."restore_mode",
	"request_digest" text NOT NULL,
	"digest_version" integer NOT NULL,
	"outcome" "actions"."command_outcome" NOT NULL,
	"error" "actions"."command_error",
	"message" text,
	"progress_execution_id" text,
	"progress_step_id" text,
	"progress_subject_attempt_id" text,
	"cycle_purpose" "actions"."cycle_purpose",
	"cycle_planned_step_id" text,
	"cycle_predecessor_command_id" text,
	"cycle_contract_id" text,
	"cycle_anchor_at" timestamp with time zone,
	"cycle_decisive_after_at" timestamp with time zone,
	"accepted_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "command_execution_step_identity" UNIQUE("organization_id","progress_execution_id","progress_step_id","id"),
	CONSTRAINT "command_tenant_identity" UNIQUE("organization_id","id"),
	CONSTRAINT "command_replay_identity" UNIQUE("organization_id","principal_kind","actor_subject_snapshot","idempotency_key"),
	CONSTRAINT "command_instant_bounds" CHECK (("actions"."command"."accepted_at" IS NULL OR "actions"."command"."accepted_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command"."cycle_anchor_at" IS NULL OR "actions"."command"."cycle_anchor_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command"."cycle_decisive_after_at" IS NULL OR "actions"."command"."cycle_decisive_after_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)),
	CONSTRAINT "command_cycle_shape" CHECK (CASE
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
        END),
	CONSTRAINT "command_cycle_planned_step_distinct" CHECK ("actions"."command"."cycle_planned_step_id" IS NULL OR "actions"."command"."cycle_planned_step_id" IS DISTINCT FROM "actions"."command"."progress_step_id"),
	CONSTRAINT "command_cycle_not_own_predecessor" CHECK ("actions"."command"."id" IS DISTINCT FROM "actions"."command"."cycle_predecessor_command_id"),
	CONSTRAINT "command_digest_shape" CHECK ("actions"."command"."request_digest" ~ '^[0-9a-f]{64}$' AND "actions"."command"."digest_version" = 1),
	CONSTRAINT "command_outcome_shape" CHECK (("actions"."command"."outcome" = 'accepted') = ("actions"."command"."error" IS NULL)),
	CONSTRAINT "command_restore_shape" CHECK (("actions"."command"."kind" = 'restore') = ("actions"."command"."restore_mode" IS NOT NULL) AND ("actions"."command"."restore_mode" IS NULL OR "actions"."command"."restore_mode" IN ('placement', 'reconsider', 'unhide'))),
	CONSTRAINT "command_actor_shape" CHECK (
    ("actions"."command"."principal_kind" NOT IN ('user', 'api_key') OR "actions"."command"."actor_user_id" IS NOT NULL)
    AND (("actions"."command"."principal_kind" = 'api_key') = ("actions"."command"."actor_api_key_id" IS NOT NULL))
    AND (("actions"."command"."principal_kind" = 'agent') = ("actions"."command"."actor_agent_run_id" IS NOT NULL))
    AND (("actions"."command"."principal_kind" = 'policy') = ("actions"."command"."actor_policy_revision_id" IS NOT NULL))
    AND ("actions"."command"."principal_kind" <> 'system' OR "actions"."command"."actor_user_id" IS NULL)
    AND ("actions"."command"."actor_acting_for_user_id" IS NULL OR "actions"."command"."principal_kind" = 'user')
    AND length("actions"."command"."actor_subject_snapshot") > 0
  )
);
--> statement-breakpoint
ALTER TABLE "actions"."command" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."command_target" (
	"organization_id" text NOT NULL,
	"command_id" text NOT NULL,
	"action_id" text NOT NULL,
	"expected_version" bigint,
	"expected_revision_id" text,
	"expected_parent_revision_id" text,
	"evidence_revision_id" text,
	"previous_version" bigint,
	"result_version" bigint NOT NULL,
	"previous_decision" "actions"."decision",
	"result_decision" "actions"."decision" NOT NULL,
	"previous_record_kind" "actions"."record_kind",
	"result_record_kind" "actions"."record_kind" NOT NULL,
	"previous_approval_id" text,
	"result_approval_id" text,
	"previous_successor_action_id" text,
	"result_successor_action_id" text,
	"previous_priority" smallint,
	"result_priority" smallint NOT NULL,
	"previous_revision_id" text,
	"result_revision_id" text NOT NULL,
	"previous_attention_version" bigint,
	"result_attention_version" bigint NOT NULL,
	"previous_owner_user_id" text,
	"result_owner_user_id" text,
	"previous_snoozed_until" timestamp with time zone,
	"result_snoozed_until" timestamp with time zone,
	"previous_scheduled_for" timestamp with time zone,
	"result_scheduled_for" timestamp with time zone,
	"previous_archived_at" timestamp with time zone,
	"result_archived_at" timestamp with time zone,
	CONSTRAINT "command_target_command_id_action_id_pk" PRIMARY KEY("command_id","action_id"),
	CONSTRAINT "command_target_scope_identity" UNIQUE("organization_id","command_id","action_id"),
	CONSTRAINT "command_target_version_unique" UNIQUE("organization_id","action_id","result_version"),
	CONSTRAINT "target_instant_bounds" CHECK (("actions"."command_target"."previous_snoozed_until" IS NULL OR "actions"."command_target"."previous_snoozed_until" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command_target"."result_snoozed_until" IS NULL OR "actions"."command_target"."result_snoozed_until" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command_target"."previous_scheduled_for" IS NULL OR "actions"."command_target"."previous_scheduled_for" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command_target"."result_scheduled_for" IS NULL OR "actions"."command_target"."result_scheduled_for" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command_target"."previous_archived_at" IS NULL OR "actions"."command_target"."previous_archived_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."command_target"."result_archived_at" IS NULL OR "actions"."command_target"."result_archived_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)),
	CONSTRAINT "target_priority_shape" CHECK ("actions"."command_target"."result_priority" BETWEEN 1 AND 3 AND ("actions"."command_target"."previous_priority" IS NULL OR "actions"."command_target"."previous_priority" BETWEEN 1 AND 3) AND ("actions"."command_target"."previous_version" IS NULL) = ("actions"."command_target"."previous_priority" IS NULL)),
	CONSTRAINT "target_version_increment" CHECK ("actions"."command_target"."result_version" = coalesce("actions"."command_target"."previous_version", 0) + 1),
	CONSTRAINT "target_attention_increment" CHECK ("actions"."command_target"."result_attention_version" > 0 AND "actions"."command_target"."result_attention_version" - coalesce("actions"."command_target"."previous_attention_version", 0) BETWEEN 0 AND 1),
	CONSTRAINT "target_creation_shape" CHECK (("actions"."command_target"."previous_version" IS NULL) = ("actions"."command_target"."previous_decision" IS NULL) AND ("actions"."command_target"."previous_version" IS NULL) = ("actions"."command_target"."previous_revision_id" IS NULL) AND ("actions"."command_target"."previous_version" IS NULL) = ("actions"."command_target"."previous_record_kind" IS NULL) AND ("actions"."command_target"."previous_version" IS NULL) = ("actions"."command_target"."previous_attention_version" IS NULL)),
	CONSTRAINT "target_creation_has_no_predecessor" CHECK ("actions"."command_target"."previous_version" IS NOT NULL OR ("actions"."command_target"."previous_approval_id" IS NULL AND "actions"."command_target"."previous_successor_action_id" IS NULL AND "actions"."command_target"."previous_owner_user_id" IS NULL AND "actions"."command_target"."previous_snoozed_until" IS NULL AND "actions"."command_target"."previous_scheduled_for" IS NULL AND "actions"."command_target"."previous_archived_at" IS NULL AND "actions"."command_target"."expected_version" IS NULL AND "actions"."command_target"."expected_revision_id" IS NULL))
);
--> statement-breakpoint
ALTER TABLE "actions"."command_target" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."dependency" (
	"organization_id" text NOT NULL,
	"dependent_action_id" text NOT NULL,
	"prerequisite_action_id" text NOT NULL,
	"requirement" "actions"."dependency_requirement" NOT NULL,
	"created_command_id" text NOT NULL,
	CONSTRAINT "dependency_dependent_action_id_prerequisite_action_id_requirement_pk" PRIMARY KEY("dependent_action_id","prerequisite_action_id","requirement"),
	CONSTRAINT "dependency_not_self" CHECK ("actions"."dependency"."dependent_action_id" <> "actions"."dependency"."prerequisite_action_id")
);
--> statement-breakpoint
ALTER TABLE "actions"."dependency" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."membership" (
	"organization_id" text NOT NULL,
	"parent_revision_id" text NOT NULL,
	"child_action_id" text NOT NULL,
	"child_revision_id" text NOT NULL,
	"ordinal" integer NOT NULL,
	CONSTRAINT "membership_parent_revision_id_child_action_id_pk" PRIMARY KEY("parent_revision_id","child_action_id"),
	CONSTRAINT "membership_order_unique" UNIQUE("parent_revision_id","ordinal"),
	CONSTRAINT "membership_ordinal_nonnegative" CHECK ("actions"."membership"."ordinal" >= 0)
);
--> statement-breakpoint
ALTER TABLE "actions"."membership" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."read" (
	"organization_id" text NOT NULL,
	"user_id" text NOT NULL,
	"action_id" text NOT NULL,
	"read_version" bigint DEFAULT 1 NOT NULL,
	"seen_attention_version" bigint NOT NULL,
	"force_unread" boolean DEFAULT false NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "read_organization_id_user_id_action_id_pk" PRIMARY KEY("organization_id","user_id","action_id"),
	CONSTRAINT "read_instant_bounds" CHECK (("actions"."read"."updated_at" IS NULL OR "actions"."read"."updated_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)),
	CONSTRAINT "read_watermark_nonnegative" CHECK ("actions"."read"."seen_attention_version" >= 0),
	CONSTRAINT "read_version_positive" CHECK ("actions"."read"."read_version" > 0)
);
--> statement-breakpoint
ALTER TABLE "actions"."read" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."revision" (
	"id" text PRIMARY KEY NOT NULL,
	"organization_id" text NOT NULL,
	"action_id" text NOT NULL,
	"purpose" "actions"."revision_purpose" NOT NULL,
	"kind" "actions"."revision_kind" NOT NULL,
	"revision_number" bigint NOT NULL,
	"authored_command_id" text NOT NULL,
	"baseline_revision_id" text,
	"generated_from_revision_id" text,
	"title" text NOT NULL,
	"summary" text NOT NULL,
	"rationale" text,
	"content_digest" text NOT NULL,
	"canonicalization_version" integer NOT NULL,
	"sealed" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "revision_tenant_identity" UNIQUE("organization_id","id"),
	CONSTRAINT "revision_action_identity" UNIQUE("organization_id","action_id","id"),
	CONSTRAINT "revision_purpose_identity" UNIQUE("organization_id","id","purpose"),
	CONSTRAINT "revision_number_unique" UNIQUE("action_id","revision_number"),
	CONSTRAINT "revision_instant_bounds" CHECK (("actions"."revision"."created_at" IS NULL OR "actions"."revision"."created_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz)),
	CONSTRAINT "revision_number_positive" CHECK ("actions"."revision"."revision_number" > 0),
	CONSTRAINT "revision_digest_shape" CHECK ("actions"."revision"."content_digest" ~ '^[0-9a-f]{64}$' AND "actions"."revision"."canonicalization_version" = 1),
	CONSTRAINT "revision_not_own_source" CHECK ("actions"."revision"."id" IS DISTINCT FROM "actions"."revision"."baseline_revision_id" AND "actions"."revision"."id" IS DISTINCT FROM "actions"."revision"."generated_from_revision_id")
);
--> statement-breakpoint
ALTER TABLE "actions"."revision" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "agent_work"."attention_advisory" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"purpose" "actions"."revision_purpose" NOT NULL,
	"agent_source_id" text NOT NULL,
	"agent_type" "agent_work"."attention_agent_type" NOT NULL,
	"last_error" text NOT NULL,
	"consecutive_failures" integer NOT NULL,
	CONSTRAINT "attention_advisory_organization_id_revision_id_pk" PRIMARY KEY("organization_id","revision_id"),
	CONSTRAINT "attention_proposal_only" CHECK ("agent_work"."attention_advisory"."purpose" = 'proposal'),
	CONSTRAINT "attention_failure_count" CHECK ("agent_work"."attention_advisory"."consecutive_failures" >= 0)
);
--> statement-breakpoint
ALTER TABLE "agent_work"."attention_advisory" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "composition"."operation_contract" (
	"id" text PRIMARY KEY NOT NULL,
	"provider" "composition"."provider" NOT NULL,
	"operation_key" text NOT NULL,
	"contract_version" integer NOT NULL,
	"expansion" "composition"."expansion" NOT NULL,
	"default_required_surface" "composition"."required_surface" NOT NULL,
	"default_verification_timing" "composition"."verification_timing" NOT NULL,
	"terminal_on_acknowledgement" boolean NOT NULL,
	"resource_scope_kind" "composition"."resource_scope" NOT NULL,
	"max_observations" integer NOT NULL,
	"observation_window_ms" integer NOT NULL,
	"backoff_initial_ms" integer NOT NULL,
	"backoff_max_ms" integer NOT NULL,
	"backoff_factor" double precision NOT NULL,
	"registered_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "operation_semantic_identity" UNIQUE("provider","operation_key","contract_version"),
	CONSTRAINT "operation_id_version" CHECK ("composition"."operation_contract"."contract_version" > 0 AND "composition"."operation_contract"."id" ~ '^[a-z][a-z0-9_.-]*@[1-9][0-9]*$' AND "composition"."operation_contract"."id" LIKE ('%@' || "composition"."operation_contract"."contract_version"::text)),
	CONSTRAINT "operation_key_shape" CHECK ("composition"."operation_contract"."operation_key" ~ '^[a-z][a-z0-9_.-]*$'),
	CONSTRAINT "operation_positive_policy" CHECK ("composition"."operation_contract"."max_observations" > 0 AND "composition"."operation_contract"."observation_window_ms" > 0 AND "composition"."operation_contract"."backoff_initial_ms" > 0 AND "composition"."operation_contract"."backoff_max_ms" >= "composition"."operation_contract"."backoff_initial_ms" AND "composition"."operation_contract"."backoff_factor" >= 1 AND "composition"."operation_contract"."backoff_factor" < 'Infinity'::double precision)
);
--> statement-breakpoint
ALTER TABLE "composition"."operation_contract" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "review_work"."reply_content" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"purpose" "actions"."revision_purpose" NOT NULL,
	"store" "review_work"."store" NOT NULL,
	"provider_app_id" text NOT NULL,
	"provider_review_id" text NOT NULL,
	"intent" "review_work"."reply_intent",
	"reply_text" text,
	"original_ai_revision_id" text,
	"detected_language_name" text,
	"review_snapshot_availability" "review_work"."snapshot_availability" NOT NULL,
	"review_rating" integer,
	"review_title" text,
	"review_body" text,
	"review_nickname" text,
	"review_storefront" text,
	"review_app_version" text,
	"review_created_at" timestamp with time zone,
	"review_modified_at" timestamp with time zone,
	"review_edited" boolean,
	"captured_at" timestamp with time zone,
	"response_availability" "review_work"."response_availability",
	"response_text" text,
	"response_modified_at" timestamp with time zone,
	"response_hidden" boolean,
	"publication_state" "review_work"."publication_state",
	CONSTRAINT "reply_content_organization_id_revision_id_pk" PRIMARY KEY("organization_id","revision_id"),
	CONSTRAINT "review_content_identity" CHECK (length("review_work"."reply_content"."provider_app_id") > 0 AND length("review_work"."reply_content"."provider_review_id") > 0 AND "review_work"."reply_content"."original_ai_revision_id" IS DISTINCT FROM "review_work"."reply_content"."revision_id"),
	CONSTRAINT "review_content_purpose" CHECK ("review_work"."reply_content"."purpose" IN ('proposal', 'baseline', 'observation')),
	CONSTRAINT "review_content_proposal_shape" CHECK ("review_work"."reply_content"."purpose" <> 'proposal' OR (
    "review_work"."reply_content"."intent" IS NOT NULL AND "review_work"."reply_content"."reply_text" IS NOT NULL AND length("review_work"."reply_content"."reply_text") > 0
    AND "review_work"."reply_content"."review_snapshot_availability" = 'present'
    AND "review_work"."reply_content"."captured_at" IS NULL AND "review_work"."reply_content"."response_availability" IS NULL AND "review_work"."reply_content"."response_text" IS NULL
    AND "review_work"."reply_content"."response_modified_at" IS NULL AND "review_work"."reply_content"."response_hidden" IS NULL AND "review_work"."reply_content"."publication_state" IS NULL)),
	CONSTRAINT "review_content_observed_shape" CHECK ("review_work"."reply_content"."purpose" = 'proposal' OR (
    "review_work"."reply_content"."intent" IS NULL AND "review_work"."reply_content"."reply_text" IS NULL AND "review_work"."reply_content"."original_ai_revision_id" IS NULL AND "review_work"."reply_content"."detected_language_name" IS NULL
    AND "review_work"."reply_content"."captured_at" IS NOT NULL AND "review_work"."reply_content"."response_availability" IS NOT NULL)),
	CONSTRAINT "review_content_response_shape" CHECK ("review_work"."reply_content"."purpose" = 'proposal' OR (
    ("review_work"."reply_content"."response_availability" = 'present' AND "review_work"."reply_content"."response_text" IS NOT NULL AND "review_work"."reply_content"."publication_state" IS NOT NULL)
    OR ("review_work"."reply_content"."response_availability" <> 'present' AND "review_work"."reply_content"."response_text" IS NULL AND "review_work"."reply_content"."response_modified_at" IS NULL
      AND "review_work"."reply_content"."response_hidden" IS NULL AND "review_work"."reply_content"."publication_state" IS NULL))),
	CONSTRAINT "review_content_snapshot_shape" CHECK ((
    "review_work"."reply_content"."review_snapshot_availability" = 'present' AND "review_work"."reply_content"."review_rating" IS NOT NULL AND "review_work"."reply_content"."review_title" IS NOT NULL
    AND "review_work"."reply_content"."review_body" IS NOT NULL AND "review_work"."reply_content"."review_nickname" IS NOT NULL
  ) OR (
    "review_work"."reply_content"."review_snapshot_availability" <> 'present' AND "review_work"."reply_content"."review_rating" IS NULL AND "review_work"."reply_content"."review_title" IS NULL
    AND "review_work"."reply_content"."review_body" IS NULL AND "review_work"."reply_content"."review_nickname" IS NULL AND "review_work"."reply_content"."review_storefront" IS NULL
    AND "review_work"."reply_content"."review_app_version" IS NULL AND "review_work"."reply_content"."review_created_at" IS NULL AND "review_work"."reply_content"."review_modified_at" IS NULL AND "review_work"."reply_content"."review_edited" IS NULL
  )),
	CONSTRAINT "review_content_rating" CHECK ("review_work"."reply_content"."review_rating" IS NULL OR "review_work"."reply_content"."review_rating" BETWEEN 1 AND 5),
	CONSTRAINT "review_content_instant_range" CHECK (("review_work"."reply_content"."review_created_at" IS NULL OR "review_work"."reply_content"."review_created_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("review_work"."reply_content"."review_modified_at" IS NULL OR "review_work"."reply_content"."review_modified_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("review_work"."reply_content"."response_modified_at" IS NULL OR "review_work"."reply_content"."response_modified_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("review_work"."reply_content"."captured_at" IS NULL OR "review_work"."reply_content"."captured_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz))
);
--> statement-breakpoint
ALTER TABLE "review_work"."reply_content" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "app_store_connect"."attempt_receipt" (
	"organization_id" text NOT NULL,
	"attempt_id" text NOT NULL,
	"transport" "app_store_connect"."review_receipt_transport" NOT NULL,
	"response_kind" "app_store_connect"."review_receipt_kind" NOT NULL,
	"response_status" integer NOT NULL,
	"provider_resource_id" text,
	"response_body" text,
	"native_state" "app_store_connect"."review_native_state",
	"error_code" text,
	CONSTRAINT "attempt_receipt_organization_id_attempt_id_pk" PRIMARY KEY("organization_id","attempt_id"),
	CONSTRAINT "asc_receipt_status" CHECK ("app_store_connect"."attempt_receipt"."response_status" BETWEEN 100 AND 599),
	CONSTRAINT "asc_receipt_identity" CHECK (("app_store_connect"."attempt_receipt"."provider_resource_id" IS NULL OR length("app_store_connect"."attempt_receipt"."provider_resource_id") > 0) AND ("app_store_connect"."attempt_receipt"."error_code" IS NULL OR length("app_store_connect"."attempt_receipt"."error_code") > 0)),
	CONSTRAINT "asc_receipt_native_shape" CHECK (CASE "app_store_connect"."attempt_receipt"."response_kind"
    WHEN 'accepted' THEN "app_store_connect"."attempt_receipt"."response_status"=201 AND "app_store_connect"."attempt_receipt"."provider_resource_id" IS NOT NULL AND "app_store_connect"."attempt_receipt"."error_code" IS NULL AND ("app_store_connect"."attempt_receipt"."native_state" IS NULL OR "app_store_connect"."attempt_receipt"."native_state" IN ('PUBLISHED','PENDING_PUBLISH'))
    WHEN 'deleted' THEN "app_store_connect"."attempt_receipt"."response_status"=204 AND num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state","app_store_connect"."attempt_receipt"."error_code")=0
    WHEN 'http_error' THEN "app_store_connect"."attempt_receipt"."response_status">=400 AND num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state")=0
    WHEN 'invalid_response' THEN num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state","app_store_connect"."attempt_receipt"."error_code")=0
    ELSE false END)
);
--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "app_store_connect"."review_target" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"purpose" "actions"."revision_purpose" NOT NULL,
	"source_asset_data_source_id" text NOT NULL,
	"source_connector_id" text NOT NULL,
	"credential_kind" "app_store_connect"."review_credential_kind" NOT NULL,
	"credential_key_id" text NOT NULL,
	"credential_team_issuer_id" text,
	"review_resource_id" text,
	"response_id" text,
	"native_state_source" "app_store_connect"."review_native_state_source",
	"native_state" "app_store_connect"."review_native_state",
	CONSTRAINT "review_target_organization_id_revision_id_pk" PRIMARY KEY("organization_id","revision_id"),
	CONSTRAINT "asc_review_target_purpose" CHECK ("app_store_connect"."review_target"."purpose" IN ('proposal', 'baseline', 'observation')),
	CONSTRAINT "asc_review_target_identity" CHECK (length("app_store_connect"."review_target"."source_asset_data_source_id") > 0 AND length("app_store_connect"."review_target"."source_connector_id") > 0 AND length("app_store_connect"."review_target"."credential_key_id") > 0
        AND ("app_store_connect"."review_target"."review_resource_id" IS NULL OR length("app_store_connect"."review_target"."review_resource_id") > 0) AND ("app_store_connect"."review_target"."response_id" IS NULL OR length("app_store_connect"."review_target"."response_id") > 0)),
	CONSTRAINT "asc_review_target_credential_shape" CHECK (("app_store_connect"."review_target"."credential_kind" = 'individual' AND "app_store_connect"."review_target"."credential_team_issuer_id" IS NULL)
          OR ("app_store_connect"."review_target"."credential_kind" = 'team' AND "app_store_connect"."review_target"."credential_team_issuer_id" IS NOT NULL AND length("app_store_connect"."review_target"."credential_team_issuer_id") > 0)),
	CONSTRAINT "asc_review_target_proposal_state" CHECK ("app_store_connect"."review_target"."purpose" <> 'proposal' OR ("app_store_connect"."review_target"."native_state" IS NULL AND "app_store_connect"."review_target"."native_state_source" IS NULL)),
	CONSTRAINT "asc_review_target_state_source" CHECK (
        ("app_store_connect"."review_target"."native_state" IS NULL OR "app_store_connect"."review_target"."native_state_source" IS NOT NULL)
        AND ("app_store_connect"."review_target"."native_state_source" IS DISTINCT FROM 'api_publication' OR "app_store_connect"."review_target"."native_state" IS NULL OR "app_store_connect"."review_target"."native_state" IN ('PUBLISHED', 'PENDING_PUBLISH'))
        AND ("app_store_connect"."review_target"."native_state_source" IS DISTINCT FROM 'browser_pending' OR "app_store_connect"."review_target"."native_state" IS NULL OR "app_store_connect"."review_target"."native_state" IN ('NONE', 'PENDING_CREATE', 'PENDING_UPDATE', 'PENDING_DELETE')))
);
--> statement-breakpoint
ALTER TABLE "app_store_connect"."review_target" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "google_play"."review_target" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"purpose" "actions"."revision_purpose" NOT NULL,
	"provider_account_id" text NOT NULL,
	CONSTRAINT "review_target_organization_id_revision_id_pk" PRIMARY KEY("organization_id","revision_id"),
	CONSTRAINT "play_review_target_purpose" CHECK ("google_play"."review_target"."purpose" IN ('proposal', 'baseline', 'observation')),
	CONSTRAINT "play_review_target_identity" CHECK (length("google_play"."review_target"."provider_account_id") > 0)
);
--> statement-breakpoint
ALTER TABLE "google_play"."review_target" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."execution" (
	"id" text PRIMARY KEY NOT NULL,
	"organization_id" text NOT NULL,
	"approval_id" text NOT NULL,
	"phase" "actions"."execution_phase" NOT NULL,
	"next_run_at" timestamp with time zone,
	"next_step_id" text,
	"delivery_generation" bigint DEFAULT 1 NOT NULL,
	"claim_generation" bigint DEFAULT 0 NOT NULL,
	"claim_token" uuid,
	"claim_expires_at" timestamp with time zone,
	"hold_reason" "actions"."execution_hold_reason",
	"resolution_owner" "actions"."execution_resolution_owner",
	"result" "actions"."execution_result",
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"settled_at" timestamp with time zone,
	"resource_guard_id" uuid,
	"plan_version" integer NOT NULL,
	"writes_closed_at" timestamp with time zone,
	"cancelled_command_id" text,
	"plan_complete" boolean DEFAULT false NOT NULL,
	CONSTRAINT "execution_tenant_identity" UNIQUE("organization_id","id"),
	CONSTRAINT "execution_approval_unique" UNIQUE("organization_id","approval_id"),
	CONSTRAINT "execution_identity_nonempty" CHECK (length("actions"."execution"."id") > 0 AND length("actions"."execution"."approval_id") > 0),
	CONSTRAINT "execution_generations" CHECK ("actions"."execution"."delivery_generation" > 0 AND "actions"."execution"."claim_generation" >= 0 AND "actions"."execution"."plan_version" > 0),
	CONSTRAINT "execution_claim_shape" CHECK (("actions"."execution"."phase" = 'claimed') = ("actions"."execution"."claim_token" IS NOT NULL) AND ("actions"."execution"."claim_token" IS NULL) = ("actions"."execution"."claim_expires_at" IS NULL) AND ("actions"."execution"."phase" <> 'claimed' OR "actions"."execution"."claim_generation" > 0)),
	CONSTRAINT "execution_terminal_shape" CHECK (("actions"."execution"."phase" IN ('settled','cancelled')) = ("actions"."execution"."settled_at" IS NOT NULL) AND ("actions"."execution"."phase" IN ('settled','cancelled')) = ("actions"."execution"."result" IS NOT NULL) AND ("actions"."execution"."phase" = 'cancelled') = ("actions"."execution"."result" IS NOT DISTINCT FROM 'cancelled') AND ("actions"."execution"."phase" = 'cancelled') = ("actions"."execution"."cancelled_command_id" IS NOT NULL)),
	CONSTRAINT "execution_due_shape" CHECK (("actions"."execution"."phase" NOT IN ('ready','verification_due','uncertain') OR "actions"."execution"."next_run_at" IS NOT NULL) AND ("actions"."execution"."phase" NOT IN ('settled','cancelled') OR ("actions"."execution"."next_run_at" IS NULL AND "actions"."execution"."next_step_id" IS NULL))),
	CONSTRAINT "execution_hold_shape" CHECK (("actions"."execution"."phase" IN ('blocked','uncertain')) = ("actions"."execution"."hold_reason" IS NOT NULL) AND ("actions"."execution"."phase" <> 'uncertain' OR "actions"."execution"."hold_reason" IS NOT DISTINCT FROM 'uncertain_write') AND ("actions"."execution"."phase" <> 'blocked' OR "actions"."execution"."next_run_at" IS NULL OR "actions"."execution"."hold_reason" IN ('awaiting_release','awaiting_publication','resource_busy','evidence_conflict'))),
	CONSTRAINT "execution_resolution_owner_shape" CHECK (("actions"."execution"."phase" IN ('blocked','uncertain') OR ("actions"."execution"."phase" = 'settled' AND "actions"."execution"."result" IS NOT DISTINCT FROM 'failed')) = ("actions"."execution"."resolution_owner" IS NOT NULL)),
	CONSTRAINT "execution_time_order" CHECK (("actions"."execution"."settled_at" IS NULL OR "actions"."execution"."settled_at" >= "actions"."execution"."created_at") AND ("actions"."execution"."writes_closed_at" IS NULL OR "actions"."execution"."writes_closed_at" >= "actions"."execution"."created_at")),
	CONSTRAINT "execution_instant_bounds" CHECK (("actions"."execution"."next_run_at" IS NULL OR "actions"."execution"."next_run_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."execution"."claim_expires_at" IS NULL OR "actions"."execution"."claim_expires_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."execution"."created_at" IS NULL OR "actions"."execution"."created_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."execution"."settled_at" IS NULL OR "actions"."execution"."settled_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."execution"."writes_closed_at" IS NULL OR "actions"."execution"."writes_closed_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz))
);
--> statement-breakpoint
ALTER TABLE "actions"."execution" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."execution_attempt" (
	"id" text PRIMARY KEY NOT NULL,
	"organization_id" text NOT NULL,
	"execution_id" text NOT NULL,
	"step_id" text NOT NULL,
	"number" integer NOT NULL,
	"kind" "actions"."attempt_kind" NOT NULL,
	"claim_generation" bigint NOT NULL,
	"claim_token" uuid NOT NULL,
	"subject_attempt_id" text,
	"input_attempt_id" text,
	"input_parent_revision_id" text,
	"connector_id" text,
	"agent_run_id" text,
	"started_at" timestamp with time zone NOT NULL,
	"recorded_at" timestamp with time zone NOT NULL,
	"finished_at" timestamp with time zone,
	"result" "actions"."attempt_result",
	"failure_class" "actions"."failure_class",
	"non_application_basis" "actions"."non_application_basis",
	"retry_disposition" "actions"."retry_disposition",
	"uncertainty_reason" "actions"."uncertainty_reason",
	"unreadable_reason" "actions"."unreadable_reason",
	"terminal_outcome" boolean,
	"semantic_fingerprint" text,
	"fingerprint_version" integer,
	"observation_revision_id" text,
	"comparison_version" integer,
	"observation_surface" "actions"."surface",
	"observation_completeness" "actions"."observation_completeness",
	"finalized_claim_generation" bigint,
	"finalized_claim_token" uuid,
	"inspection_purpose" "actions"."inspection_purpose",
	"planned_write_step_id" text,
	"prewrite_attempt_id" text,
	"resource_guard_generation" bigint,
	"cycle_command_id" text,
	"evidence_command_id" text,
	"output_kind" "actions"."output_kind",
	"output_revision_id" text,
	"output_review_analysis_id" text,
	"output_agent_run_id" text,
	"no_work_reason" "actions"."no_work_reason",
	"capture_digest" text,
	"capture_digest_version" integer,
	CONSTRAINT "attempt_tenant_identity" UNIQUE("organization_id","id"),
	CONSTRAINT "attempt_execution_identity" UNIQUE("organization_id","execution_id","id"),
	CONSTRAINT "attempt_step_identity" UNIQUE("organization_id","execution_id","step_id","id"),
	CONSTRAINT "attempt_number_unique" UNIQUE("organization_id","step_id","number"),
	CONSTRAINT "attempt_identity_nonempty" CHECK (length("actions"."execution_attempt"."id") > 0 AND length("actions"."execution_attempt"."execution_id") > 0 AND length("actions"."execution_attempt"."step_id") > 0),
	CONSTRAINT "attempt_counters" CHECK ("actions"."execution_attempt"."number" > 0 AND "actions"."execution_attempt"."claim_generation" > 0 AND ("actions"."execution_attempt"."finalized_claim_generation" IS NULL OR "actions"."execution_attempt"."finalized_claim_generation" > 0) AND ("actions"."execution_attempt"."resource_guard_generation" IS NULL OR "actions"."execution_attempt"."resource_guard_generation" > 0)),
	CONSTRAINT "attempt_finish_shape" CHECK (("actions"."execution_attempt"."finished_at" IS NULL) = ("actions"."execution_attempt"."result" IS NULL) AND ("actions"."execution_attempt"."finished_at" IS NULL OR "actions"."execution_attempt"."finished_at" >= "actions"."execution_attempt"."started_at")),
	CONSTRAINT "attempt_reason_shape" CHECK (("actions"."execution_attempt"."result" IS NOT DISTINCT FROM 'known_not_applied') = ("actions"."execution_attempt"."non_application_basis" IS NOT NULL) AND ("actions"."execution_attempt"."result" IS NOT DISTINCT FROM 'known_not_applied') = ("actions"."execution_attempt"."retry_disposition" IS NOT NULL) AND ("actions"."execution_attempt"."result" IS NOT DISTINCT FROM 'uncertain') = ("actions"."execution_attempt"."uncertainty_reason" IS NOT NULL) AND ("actions"."execution_attempt"."result" IS NOT DISTINCT FROM 'unreadable') = ("actions"."execution_attempt"."unreadable_reason" IS NOT NULL)),
	CONSTRAINT "attempt_fingerprint_shape" CHECK (("actions"."execution_attempt"."semantic_fingerprint" IS NULL) = ("actions"."execution_attempt"."fingerprint_version" IS NULL) AND ("actions"."execution_attempt"."semantic_fingerprint" IS NULL OR ("actions"."execution_attempt"."semantic_fingerprint" ~ '^[0-9a-f]{64}$' AND "actions"."execution_attempt"."fingerprint_version" > 0))),
	CONSTRAINT "attempt_observation_shape" CHECK (num_nonnulls("actions"."execution_attempt"."observation_revision_id", "actions"."execution_attempt"."comparison_version", "actions"."execution_attempt"."observation_surface", "actions"."execution_attempt"."observation_completeness") IN (0,4) AND ("actions"."execution_attempt"."comparison_version" IS NULL OR "actions"."execution_attempt"."comparison_version" > 0)),
	CONSTRAINT "attempt_subject_shape" CHECK (("actions"."execution_attempt"."kind" IN ('readback','manual_observation','late_evidence','conflicting_completion')) = ("actions"."execution_attempt"."subject_attempt_id" IS NOT NULL) AND "actions"."execution_attempt"."id" IS DISTINCT FROM "actions"."execution_attempt"."subject_attempt_id" AND "actions"."execution_attempt"."id" IS DISTINCT FROM "actions"."execution_attempt"."input_attempt_id" AND "actions"."execution_attempt"."id" IS DISTINCT FROM "actions"."execution_attempt"."prewrite_attempt_id"),
	CONSTRAINT "attempt_cycle_shape" CHECK (("actions"."execution_attempt"."kind" IN ('readback','inspection')) = ("actions"."execution_attempt"."cycle_command_id" IS NOT NULL)),
	CONSTRAINT "attempt_inspection_shape" CHECK ("actions"."execution_attempt"."kind" IN ('late_evidence','conflicting_completion') OR (
    ("actions"."execution_attempt"."kind" = 'inspection') = ("actions"."execution_attempt"."inspection_purpose" IS NOT NULL)
    AND ("actions"."execution_attempt"."inspection_purpose" IS NOT DISTINCT FROM 'prewrite') = ("actions"."execution_attempt"."planned_write_step_id" IS NOT NULL)
    AND ("actions"."execution_attempt"."kind" = 'write' OR "actions"."execution_attempt"."inspection_purpose" IS NOT DISTINCT FROM 'prewrite') = ("actions"."execution_attempt"."resource_guard_generation" IS NOT NULL)
    AND ("actions"."execution_attempt"."prewrite_attempt_id" IS NULL OR "actions"."execution_attempt"."kind" = 'write'))),
	CONSTRAINT "attempt_capture_shape" CHECK (("actions"."execution_attempt"."kind" = 'conflicting_completion') = ("actions"."execution_attempt"."capture_digest" IS NOT NULL) AND ("actions"."execution_attempt"."capture_digest" IS NULL) = ("actions"."execution_attempt"."capture_digest_version" IS NULL) AND ("actions"."execution_attempt"."capture_digest" IS NULL OR ("actions"."execution_attempt"."capture_digest" ~ '^[0-9a-f]{64}$' AND "actions"."execution_attempt"."capture_digest_version" = 1))),
	CONSTRAINT "attempt_fence_shape" CHECK (CASE WHEN "actions"."execution_attempt"."kind" IN ('late_evidence','conflicting_completion') THEN "actions"."execution_attempt"."finished_at" IS NOT NULL AND "actions"."execution_attempt"."finalized_claim_generation" IS NULL AND "actions"."execution_attempt"."finalized_claim_token" IS NULL ELSE ("actions"."execution_attempt"."finished_at" IS NOT NULL) = ("actions"."execution_attempt"."finalized_claim_generation" IS NOT NULL) AND ("actions"."execution_attempt"."finalized_claim_generation" IS NULL) = ("actions"."execution_attempt"."finalized_claim_token" IS NULL) END),
	CONSTRAINT "attempt_evidence_command_shape" CHECK (CASE WHEN "actions"."execution_attempt"."kind" IN ('late_evidence','conflicting_completion','manual_observation') THEN "actions"."execution_attempt"."evidence_command_id" IS NOT NULL AND "actions"."execution_attempt"."finished_at" IS NOT NULL WHEN "actions"."execution_attempt"."kind" = 'inspection' AND "actions"."execution_attempt"."result" IS NOT DISTINCT FROM 'unreadable' AND "actions"."execution_attempt"."unreadable_reason" IS NOT DISTINCT FROM 'cancelled' THEN "actions"."execution_attempt"."evidence_command_id" IS NOT NULL AND "actions"."execution_attempt"."finished_at" IS NOT NULL ELSE "actions"."execution_attempt"."evidence_command_id" IS NULL END),
	CONSTRAINT "attempt_unfinished_empty" CHECK ("actions"."execution_attempt"."finished_at" IS NOT NULL OR num_nonnulls("actions"."execution_attempt"."failure_class","actions"."execution_attempt"."terminal_outcome","actions"."execution_attempt"."semantic_fingerprint","actions"."execution_attempt"."fingerprint_version","actions"."execution_attempt"."observation_revision_id","actions"."execution_attempt"."output_kind") = 0),
	CONSTRAINT "attempt_result_marks" CHECK (CASE
    WHEN "actions"."execution_attempt"."result" IS NULL THEN "actions"."execution_attempt"."terminal_outcome" IS NULL AND "actions"."execution_attempt"."semantic_fingerprint" IS NULL
    WHEN "actions"."execution_attempt"."kind" IN ('late_evidence','conflicting_completion') THEN true
    WHEN "actions"."execution_attempt"."kind" = 'write' THEN "actions"."execution_attempt"."result" IN ('acknowledged','known_not_applied','uncertain') AND "actions"."execution_attempt"."terminal_outcome" IS NULL AND "actions"."execution_attempt"."semantic_fingerprint" IS NULL
    WHEN "actions"."execution_attempt"."kind" = 'generation' THEN "actions"."execution_attempt"."result" IN ('generated','discarded','known_not_applied','uncertain') AND "actions"."execution_attempt"."terminal_outcome" IS NULL AND "actions"."execution_attempt"."semantic_fingerprint" IS NULL
    WHEN "actions"."execution_attempt"."kind" = 'readback' AND "actions"."execution_attempt"."result" IN ('matched','matched_external','mismatch') THEN "actions"."execution_attempt"."semantic_fingerprint" IS NOT NULL AND "actions"."execution_attempt"."terminal_outcome" IS NOT NULL
    WHEN "actions"."execution_attempt"."kind" = 'readback' AND "actions"."execution_attempt"."result" = 'known_not_applied' THEN "actions"."execution_attempt"."semantic_fingerprint" IS NULL AND "actions"."execution_attempt"."terminal_outcome" IS NOT DISTINCT FROM true
    WHEN "actions"."execution_attempt"."kind" = 'inspection' AND "actions"."execution_attempt"."result" IN ('matched','mismatch') THEN "actions"."execution_attempt"."semantic_fingerprint" IS NOT NULL AND "actions"."execution_attempt"."terminal_outcome" IS NOT DISTINCT FROM false
    WHEN "actions"."execution_attempt"."kind" = 'manual_observation' AND "actions"."execution_attempt"."result" IN ('matched_external','mismatch') THEN "actions"."execution_attempt"."semantic_fingerprint" IS NOT NULL AND "actions"."execution_attempt"."terminal_outcome" IS NULL
    WHEN "actions"."execution_attempt"."kind" IN ('readback','inspection','manual_observation') AND "actions"."execution_attempt"."result" = 'unreadable' THEN "actions"."execution_attempt"."semantic_fingerprint" IS NULL AND "actions"."execution_attempt"."terminal_outcome" IS NULL
    ELSE false END),
	CONSTRAINT "attempt_verified_observation" CHECK ("actions"."execution_attempt"."result" IS NULL OR ("actions"."execution_attempt"."result" NOT IN ('matched','matched_external','mismatch') AND NOT ("actions"."execution_attempt"."kind" = 'readback' AND "actions"."execution_attempt"."result" = 'known_not_applied')) OR ("actions"."execution_attempt"."observation_revision_id" IS NOT NULL AND "actions"."execution_attempt"."observation_completeness" IS NOT DISTINCT FROM 'complete')),
	CONSTRAINT "attempt_output_shape" CHECK (("actions"."execution_attempt"."result" IS DISTINCT FROM 'generated' OR "actions"."execution_attempt"."output_kind" IS NOT NULL)
    AND ("actions"."execution_attempt"."output_kind" IS NULL OR ("actions"."execution_attempt"."result" IS NOT NULL AND "actions"."execution_attempt"."result" IN ('generated','discarded')))
    AND CASE WHEN "actions"."execution_attempt"."output_kind" IS NULL THEN num_nonnulls("actions"."execution_attempt"."output_revision_id","actions"."execution_attempt"."output_review_analysis_id","actions"."execution_attempt"."output_agent_run_id","actions"."execution_attempt"."no_work_reason") = 0
    WHEN "actions"."execution_attempt"."output_kind" = 'revision' THEN "actions"."execution_attempt"."output_revision_id" IS NOT NULL AND num_nonnulls("actions"."execution_attempt"."output_review_analysis_id","actions"."execution_attempt"."output_agent_run_id","actions"."execution_attempt"."no_work_reason") = 0
    WHEN "actions"."execution_attempt"."output_kind" = 'review_analysis' THEN "actions"."execution_attempt"."output_review_analysis_id" IS NOT NULL AND num_nonnulls("actions"."execution_attempt"."output_revision_id","actions"."execution_attempt"."output_agent_run_id","actions"."execution_attempt"."no_work_reason") = 0
    WHEN "actions"."execution_attempt"."output_kind" = 'agent_run' THEN "actions"."execution_attempt"."output_agent_run_id" IS NOT NULL AND num_nonnulls("actions"."execution_attempt"."output_revision_id","actions"."execution_attempt"."output_review_analysis_id","actions"."execution_attempt"."no_work_reason") = 0
    WHEN "actions"."execution_attempt"."output_kind" = 'no_work' THEN "actions"."execution_attempt"."no_work_reason" IS NOT NULL AND "actions"."execution_attempt"."agent_run_id" IS NOT NULL AND num_nonnulls("actions"."execution_attempt"."output_revision_id","actions"."execution_attempt"."output_review_analysis_id","actions"."execution_attempt"."output_agent_run_id") = 0 ELSE false END),
	CONSTRAINT "attempt_parent_context_shape" CHECK ("actions"."execution_attempt"."input_parent_revision_id" IS NULL OR "actions"."execution_attempt"."kind" IN ('generation','late_evidence','conflicting_completion')),
	CONSTRAINT "attempt_instant_bounds" CHECK (("actions"."execution_attempt"."started_at" IS NULL OR "actions"."execution_attempt"."started_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."execution_attempt"."recorded_at" IS NULL OR "actions"."execution_attempt"."recorded_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("actions"."execution_attempt"."finished_at" IS NULL OR "actions"."execution_attempt"."finished_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz))
);
--> statement-breakpoint
ALTER TABLE "actions"."execution_attempt" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."execution_step" (
	"id" text PRIMARY KEY NOT NULL,
	"organization_id" text NOT NULL,
	"execution_id" text NOT NULL,
	"ordinal" integer NOT NULL,
	"operation_contract_id" text NOT NULL,
	"required_surface" "actions"."surface" NOT NULL,
	"verification_timing" "composition"."verification_timing" NOT NULL,
	"recovery_policy_version" integer NOT NULL,
	"input_step_id" text,
	"content_revision_id" text NOT NULL,
	"native_idempotency_key" text,
	CONSTRAINT "step_tenant_identity" UNIQUE("organization_id","id"),
	CONSTRAINT "step_execution_identity" UNIQUE("organization_id","execution_id","id"),
	CONSTRAINT "step_ordinal_unique" UNIQUE("organization_id","execution_id","ordinal"),
	CONSTRAINT "step_identity_nonempty" CHECK (length("actions"."execution_step"."id") > 0 AND length("actions"."execution_step"."execution_id") > 0 AND length("actions"."execution_step"."content_revision_id") > 0 AND ("actions"."execution_step"."native_idempotency_key" IS NULL OR length("actions"."execution_step"."native_idempotency_key") > 0)),
	CONSTRAINT "step_structural_shape" CHECK ("actions"."execution_step"."ordinal" >= 0 AND "actions"."execution_step"."recovery_policy_version" > 0 AND "actions"."execution_step"."id" IS DISTINCT FROM "actions"."execution_step"."input_step_id")
);
--> statement-breakpoint
ALTER TABLE "actions"."execution_step" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "actions"."resource_guard" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"provider" "composition"."provider" NOT NULL,
	"resource_key" text NOT NULL,
	"key_version" integer NOT NULL,
	"holder_organization_id" text,
	"holder_execution_id" text,
	"acquired_at" timestamp with time zone,
	"acquisition_generation" bigint DEFAULT 0 NOT NULL,
	CONSTRAINT "resource_guard_global_identity" UNIQUE("provider","resource_key"),
	CONSTRAINT "resource_guard_key_shape" CHECK ("actions"."resource_guard"."provider" <> 'internal' AND length("actions"."resource_guard"."resource_key") > 0 AND "actions"."resource_guard"."key_version" = 1),
	CONSTRAINT "resource_guard_holder_shape" CHECK (("actions"."resource_guard"."holder_organization_id" IS NULL) = ("actions"."resource_guard"."holder_execution_id" IS NULL) AND ("actions"."resource_guard"."holder_execution_id" IS NULL) = ("actions"."resource_guard"."acquired_at" IS NULL)),
	CONSTRAINT "resource_guard_generation_shape" CHECK ("actions"."resource_guard"."acquisition_generation" >= 0 AND ("actions"."resource_guard"."holder_execution_id" IS NULL OR "actions"."resource_guard"."acquisition_generation" > 0)),
	CONSTRAINT "resource_guard_instant_bounds" CHECK (("actions"."resource_guard"."acquired_at" IS NULL OR "actions"."resource_guard"."acquired_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz))
);
--> statement-breakpoint
ALTER TABLE "actions"."resource_guard" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
-- Tenant-qualified Actions references require this public unique key first.
-- Existing assets require an operator-prepared concurrent index; deployment
-- never scans a populated heap to build it. See docs/actions-asset-identity-preparation.md.
DO $asset_identity$
DECLARE
  index_id oid;
  previous_lock_timeout text := current_setting('lock_timeout');
BEGIN
  IF NOT pg_try_advisory_xact_lock(hashtextextended('fload:actions-asset-tenant-identity', 0)) THEN
    RAISE EXCEPTION 'Asset identity preparation or adoption is already running';
  END IF;
  PERFORM set_config('lock_timeout', '5s', true);
  LOCK TABLE public.asset IN ACCESS EXCLUSIVE MODE;
  index_id := to_regclass('public.asset_tenant_identity');
  IF index_id IS NULL THEN
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='public.asset'::regclass AND conname='asset_tenant_identity') THEN
      RAISE EXCEPTION 'public.asset_tenant_identity has a mismatched constraint owner; operator inspection is required';
    END IF;
    -- Physical emptiness under this lock is sufficient, without a row scan or
    -- stale planner estimate. Previously populated empty heaps also require preparation.
    IF pg_relation_size('public.asset'::regclass) <> 0 THEN
      RAISE EXCEPTION 'Prepare public.asset_tenant_identity before migration: run packages/database/scripts/prepare-actions-asset-identity.ts --database-name NAME --execute with the explicitly selected DATABASE_URL';
    END IF;
    CREATE UNIQUE INDEX asset_tenant_identity ON public.asset USING btree ("organizationId", id);
    index_id := 'public.asset_tenant_identity'::regclass;
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_index i JOIN pg_class c ON c.oid=i.indexrelid
    WHERE i.indexrelid=index_id AND i.indrelid='public.asset'::regclass
      AND c.relkind='i' AND i.indisunique AND i.indisvalid AND i.indisready AND i.indislive AND i.indimmediate
      AND NOT i.indisprimary AND NOT i.indisexclusion AND NOT i.indnullsnotdistinct
      AND i.indnkeyatts=2 AND i.indnatts=2 AND i.indpred IS NULL AND i.indexprs IS NULL
      AND pg_get_indexdef(i.indexrelid,0,false)='CREATE UNIQUE INDEX asset_tenant_identity ON public.asset USING btree ("organizationId", id)'
      AND NOT EXISTS (SELECT 1 FROM pg_constraint k WHERE k.conindid=i.indexrelid AND k.contype IN ('u','p','x')
        AND NOT (k.contype='u' AND k.conrelid='public.asset'::regclass AND k.conname='asset_tenant_identity' AND NOT k.condeferrable AND k.convalidated))
      AND NOT EXISTS (SELECT 1 FROM pg_constraint k WHERE k.conrelid='public.asset'::regclass AND k.conname='asset_tenant_identity' AND k.conindid<>i.indexrelid)
  ) THEN
    RAISE EXCEPTION 'public.asset_tenant_identity has a mismatched definition, constraint owner, or invalid build state; operator inspection is required';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='public.asset'::regclass AND conname='asset_tenant_identity' AND contype='u') THEN
    ALTER TABLE public.asset ADD CONSTRAINT asset_tenant_identity UNIQUE USING INDEX asset_tenant_identity;
  END IF;
  PERFORM set_config('lock_timeout', previous_lock_timeout, true);
END;
$asset_identity$;
--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_organization_id_organization_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_owner_user_id_user_id_fk" FOREIGN KEY ("owner_user_id") REFERENCES "public"."user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_asset_scope" FOREIGN KEY ("organization_id","asset_id") REFERENCES "public"."asset"("organizationId","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_parent_scope" FOREIGN KEY ("organization_id","parent_action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_successor_scope" FOREIGN KEY ("organization_id","successor_action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_head_scope" FOREIGN KEY ("organization_id","id","current_revision_id") REFERENCES "actions"."revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action" ADD CONSTRAINT "action_approval_scope" FOREIGN KEY ("organization_id","id","current_revision_id","current_approval_id") REFERENCES "actions"."approval"("organization_id","action_id","revision_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."alias" ADD CONSTRAINT "alias_action_scope" FOREIGN KEY ("organization_id","action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."approval" ADD CONSTRAINT "approval_revision_scope" FOREIGN KEY ("organization_id","action_id","revision_id") REFERENCES "actions"."revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."approval" ADD CONSTRAINT "approval_command_target_scope" FOREIGN KEY ("organization_id","command_id","action_id") REFERENCES "actions"."command_target"("organization_id","command_id","action_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."approval" ADD CONSTRAINT "approval_parent_scope" FOREIGN KEY ("organization_id","parent_revision_id") REFERENCES "actions"."revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command" ADD CONSTRAINT "command_organization_id_organization_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command" ADD CONSTRAINT "command_actor_user_id_user_id_fk" FOREIGN KEY ("actor_user_id") REFERENCES "public"."user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command" ADD CONSTRAINT "command_actor_acting_for_user_id_user_id_fk" FOREIGN KEY ("actor_acting_for_user_id") REFERENCES "public"."user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command" ADD CONSTRAINT "command_actor_api_key_id_api_key_id_fk" FOREIGN KEY ("actor_api_key_id") REFERENCES "public"."api_key"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command" ADD CONSTRAINT "command_cycle_contract_id_operation_contract_id_fk" FOREIGN KEY ("cycle_contract_id") REFERENCES "composition"."operation_contract"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command" ADD CONSTRAINT "command_execution_scope" FOREIGN KEY ("organization_id","progress_execution_id") REFERENCES "actions"."execution"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command" ADD CONSTRAINT "command_step_scope" FOREIGN KEY ("organization_id","progress_execution_id","progress_step_id") REFERENCES "actions"."execution_step"("organization_id","execution_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command" ADD CONSTRAINT "command_subject_scope" FOREIGN KEY ("organization_id","progress_execution_id","progress_step_id","progress_subject_attempt_id") REFERENCES "actions"."execution_attempt"("organization_id","execution_id","step_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command" ADD CONSTRAINT "command_planned_step_scope" FOREIGN KEY ("organization_id","progress_execution_id","cycle_planned_step_id") REFERENCES "actions"."execution_step"("organization_id","execution_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command" ADD CONSTRAINT "command_cycle_predecessor_scope" FOREIGN KEY ("organization_id","cycle_predecessor_command_id") REFERENCES "actions"."command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command_target" ADD CONSTRAINT "target_command_scope" FOREIGN KEY ("organization_id","command_id") REFERENCES "actions"."command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command_target" ADD CONSTRAINT "target_action_scope" FOREIGN KEY ("organization_id","action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command_target" ADD CONSTRAINT "target_expected_revision_scope" FOREIGN KEY ("organization_id","action_id","expected_revision_id") REFERENCES "actions"."revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command_target" ADD CONSTRAINT "target_previous_revision_scope" FOREIGN KEY ("organization_id","action_id","previous_revision_id") REFERENCES "actions"."revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command_target" ADD CONSTRAINT "target_result_revision_scope" FOREIGN KEY ("organization_id","action_id","result_revision_id") REFERENCES "actions"."revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command_target" ADD CONSTRAINT "target_expected_parent_scope" FOREIGN KEY ("organization_id","expected_parent_revision_id") REFERENCES "actions"."revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command_target" ADD CONSTRAINT "target_evidence_scope" FOREIGN KEY ("organization_id","evidence_revision_id") REFERENCES "actions"."revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command_target" ADD CONSTRAINT "target_previous_approval_scope" FOREIGN KEY ("organization_id","action_id","previous_approval_id") REFERENCES "actions"."approval"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command_target" ADD CONSTRAINT "target_result_approval_scope" FOREIGN KEY ("organization_id","action_id","result_approval_id") REFERENCES "actions"."approval"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command_target" ADD CONSTRAINT "target_previous_successor_scope" FOREIGN KEY ("organization_id","previous_successor_action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."command_target" ADD CONSTRAINT "target_result_successor_scope" FOREIGN KEY ("organization_id","result_successor_action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."dependency" ADD CONSTRAINT "dependency_dependent_scope" FOREIGN KEY ("organization_id","dependent_action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."dependency" ADD CONSTRAINT "dependency_prerequisite_scope" FOREIGN KEY ("organization_id","prerequisite_action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."dependency" ADD CONSTRAINT "dependency_command_scope" FOREIGN KEY ("organization_id","created_command_id") REFERENCES "actions"."command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."membership" ADD CONSTRAINT "membership_parent_scope" FOREIGN KEY ("organization_id","parent_revision_id") REFERENCES "actions"."revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."membership" ADD CONSTRAINT "membership_child_scope" FOREIGN KEY ("organization_id","child_action_id","child_revision_id") REFERENCES "actions"."revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."read" ADD CONSTRAINT "read_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."read" ADD CONSTRAINT "read_action_scope" FOREIGN KEY ("organization_id","action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."revision" ADD CONSTRAINT "revision_action_scope" FOREIGN KEY ("organization_id","action_id") REFERENCES "actions"."action"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."revision" ADD CONSTRAINT "revision_author_scope" FOREIGN KEY ("organization_id","authored_command_id") REFERENCES "actions"."command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."revision" ADD CONSTRAINT "revision_baseline_scope" FOREIGN KEY ("organization_id","action_id","baseline_revision_id") REFERENCES "actions"."revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."revision" ADD CONSTRAINT "revision_generation_scope" FOREIGN KEY ("organization_id","action_id","generated_from_revision_id") REFERENCES "actions"."revision"("organization_id","action_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_work"."attention_advisory" ADD CONSTRAINT "attention_revision_scope" FOREIGN KEY ("organization_id","revision_id","purpose") REFERENCES "actions"."revision"("organization_id","id","purpose") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "review_work"."reply_content" ADD CONSTRAINT "review_content_revision_scope" FOREIGN KEY ("organization_id","revision_id","purpose") REFERENCES "actions"."revision"("organization_id","id","purpose") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "review_work"."reply_content" ADD CONSTRAINT "review_content_original_ai_scope" FOREIGN KEY ("organization_id","original_ai_revision_id") REFERENCES "review_work"."reply_content"("organization_id","revision_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" ADD CONSTRAINT "asc_receipt_attempt_scope" FOREIGN KEY ("organization_id","attempt_id") REFERENCES "actions"."execution_attempt"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_store_connect"."review_target" ADD CONSTRAINT "asc_review_revision_scope" FOREIGN KEY ("organization_id","revision_id","purpose") REFERENCES "actions"."revision"("organization_id","id","purpose") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "google_play"."review_target" ADD CONSTRAINT "play_review_revision_scope" FOREIGN KEY ("organization_id","revision_id","purpose") REFERENCES "actions"."revision"("organization_id","id","purpose") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution" ADD CONSTRAINT "execution_organization_id_organization_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organization"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution" ADD CONSTRAINT "execution_approval_scope" FOREIGN KEY ("organization_id","approval_id") REFERENCES "actions"."approval"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution" ADD CONSTRAINT "execution_next_step_scope" FOREIGN KEY ("organization_id","id","next_step_id") REFERENCES "actions"."execution_step"("organization_id","execution_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution" ADD CONSTRAINT "execution_cancel_command_scope" FOREIGN KEY ("organization_id","cancelled_command_id") REFERENCES "actions"."command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution" ADD CONSTRAINT "execution_resource_guard_identity" FOREIGN KEY ("resource_guard_id") REFERENCES "actions"."resource_guard"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_attempt" ADD CONSTRAINT "attempt_step_scope" FOREIGN KEY ("organization_id","execution_id","step_id") REFERENCES "actions"."execution_step"("organization_id","execution_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_attempt" ADD CONSTRAINT "attempt_subject_scope" FOREIGN KEY ("organization_id","execution_id","step_id","subject_attempt_id") REFERENCES "actions"."execution_attempt"("organization_id","execution_id","step_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_attempt" ADD CONSTRAINT "attempt_input_scope" FOREIGN KEY ("organization_id","execution_id","input_attempt_id") REFERENCES "actions"."execution_attempt"("organization_id","execution_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_attempt" ADD CONSTRAINT "attempt_prewrite_scope" FOREIGN KEY ("organization_id","execution_id","prewrite_attempt_id") REFERENCES "actions"."execution_attempt"("organization_id","execution_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_attempt" ADD CONSTRAINT "attempt_planned_write_scope" FOREIGN KEY ("organization_id","execution_id","planned_write_step_id") REFERENCES "actions"."execution_step"("organization_id","execution_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_attempt" ADD CONSTRAINT "attempt_cycle_scope" FOREIGN KEY ("organization_id","execution_id","step_id","cycle_command_id") REFERENCES "actions"."command"("organization_id","progress_execution_id","progress_step_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_attempt" ADD CONSTRAINT "attempt_evidence_command_scope" FOREIGN KEY ("organization_id","evidence_command_id") REFERENCES "actions"."command"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_attempt" ADD CONSTRAINT "attempt_observation_scope" FOREIGN KEY ("organization_id","observation_revision_id") REFERENCES "actions"."revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_attempt" ADD CONSTRAINT "attempt_parent_revision_scope" FOREIGN KEY ("organization_id","input_parent_revision_id") REFERENCES "actions"."revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_attempt" ADD CONSTRAINT "attempt_output_revision_scope" FOREIGN KEY ("organization_id","output_revision_id") REFERENCES "actions"."revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_step" ADD CONSTRAINT "execution_step_operation_contract_id_operation_contract_id_fk" FOREIGN KEY ("operation_contract_id") REFERENCES "composition"."operation_contract"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_step" ADD CONSTRAINT "step_execution_scope" FOREIGN KEY ("organization_id","execution_id") REFERENCES "actions"."execution"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_step" ADD CONSTRAINT "step_input_scope" FOREIGN KEY ("organization_id","execution_id","input_step_id") REFERENCES "actions"."execution_step"("organization_id","execution_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."execution_step" ADD CONSTRAINT "step_content_scope" FOREIGN KEY ("organization_id","content_revision_id") REFERENCES "actions"."revision"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."resource_guard" ADD CONSTRAINT "resource_guard_holder_scope" FOREIGN KEY ("holder_organization_id","holder_execution_id") REFERENCES "actions"."execution"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "action_scope_page" ON "actions"."action" USING btree ("organization_id","created_at" DESC NULLS LAST,"id" COLLATE "C" DESC);--> statement-breakpoint
CREATE INDEX "action_inbox_scope_page" ON "actions"."action" USING btree ("organization_id","parent_action_id","created_at" DESC NULLS LAST,"id" COLLATE "C" DESC) WHERE "actions"."action"."record_kind" = 'work' AND "actions"."action"."archived_at" IS NULL;--> statement-breakpoint
CREATE INDEX "action_asset_scope_index" ON "actions"."action" USING btree ("organization_id","asset_id","created_at" DESC NULLS LAST,"id" COLLATE "C" DESC);--> statement-breakpoint
CREATE INDEX "alias_action_lookup" ON "actions"."alias" USING btree ("organization_id","action_id");--> statement-breakpoint
CREATE UNIQUE INDEX "execution_cycle_successor" ON "actions"."command" USING btree ("organization_id","cycle_predecessor_command_id") WHERE "actions"."command"."kind" IN ('reconcile','resume_hold') AND "actions"."command"."outcome" = 'accepted' AND "actions"."command"."cycle_predecessor_command_id" IS NOT NULL;--> statement-breakpoint
CREATE UNIQUE INDEX "execution_attempt_completion_command" ON "actions"."command" USING btree ("organization_id","progress_subject_attempt_id") WHERE "actions"."command"."kind" = 'record_attempt' AND "actions"."command"."outcome" = 'accepted';--> statement-breakpoint
CREATE INDEX "command_history_page" ON "actions"."command" USING btree ("organization_id","accepted_at" DESC NULLS LAST,"id" COLLATE "C" DESC);--> statement-breakpoint
CREATE INDEX "membership_child_lookup" ON "actions"."membership" USING btree ("organization_id","child_action_id","parent_revision_id");--> statement-breakpoint
CREATE INDEX "execution_due" ON "actions"."execution" USING btree ("next_run_at","organization_id" COLLATE "C","id" COLLATE "C") WHERE "actions"."execution"."phase" IN ('ready','verification_due','uncertain');--> statement-breakpoint
CREATE INDEX "execution_blocked_due" ON "actions"."execution" USING btree ("next_run_at","organization_id" COLLATE "C","id" COLLATE "C") WHERE "actions"."execution"."phase" = 'blocked' AND "actions"."execution"."next_run_at" IS NOT NULL;--> statement-breakpoint
CREATE INDEX "execution_claim_expiry" ON "actions"."execution" USING btree ("claim_expires_at","organization_id" COLLATE "C","id" COLLATE "C") WHERE "actions"."execution"."phase" = 'claimed';--> statement-breakpoint
CREATE UNIQUE INDEX "attempt_one_unfinished" ON "actions"."execution_attempt" USING btree ("organization_id","execution_id") WHERE "actions"."execution_attempt"."finished_at" IS NULL AND "actions"."execution_attempt"."kind" IN ('write','readback','inspection','generation','manual_observation');--> statement-breakpoint
CREATE UNIQUE INDEX "attempt_one_late_completion" ON "actions"."execution_attempt" USING btree ("organization_id","subject_attempt_id") WHERE "actions"."execution_attempt"."kind" = 'late_evidence';--> statement-breakpoint
CREATE UNIQUE INDEX "attempt_conflicting_capture_replay" ON "actions"."execution_attempt" USING btree ("organization_id","subject_attempt_id","capture_digest_version","capture_digest") WHERE "actions"."execution_attempt"."kind" = 'conflicting_completion';--> statement-breakpoint
CREATE UNIQUE INDEX "attempt_prewrite_consumed_once" ON "actions"."execution_attempt" USING btree ("organization_id","prewrite_attempt_id") WHERE "actions"."execution_attempt"."kind" = 'write' AND "actions"."execution_attempt"."prewrite_attempt_id" IS NOT NULL;--> statement-breakpoint
CREATE INDEX "attempt_cycle_starts" ON "actions"."execution_attempt" USING btree ("organization_id","cycle_command_id","started_at","id");--> statement-breakpoint
CREATE INDEX "attempt_step_history" ON "actions"."execution_attempt" USING btree ("organization_id","execution_id","step_id","number");--> statement-breakpoint
CREATE INDEX "attempt_subject_evidence" ON "actions"."execution_attempt" USING btree ("organization_id","subject_attempt_id","kind");--> statement-breakpoint
CREATE INDEX "attempt_conflict_monitor" ON "actions"."execution_attempt" USING btree ("recorded_at","organization_id","id") WHERE "actions"."execution_attempt"."kind" = 'conflicting_completion';--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."action" AS PERMISSIVE FOR ALL TO public USING ("actions"."action"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."action"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."alias" AS PERMISSIVE FOR ALL TO public USING ("actions"."alias"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."alias"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."approval" AS PERMISSIVE FOR ALL TO public USING ("actions"."approval"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."approval"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."command" AS PERMISSIVE FOR ALL TO public USING ("actions"."command"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."command"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."command_target" AS PERMISSIVE FOR ALL TO public USING ("actions"."command_target"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."command_target"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."dependency" AS PERMISSIVE FOR ALL TO public USING ("actions"."dependency"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."dependency"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."membership" AS PERMISSIVE FOR ALL TO public USING ("actions"."membership"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."membership"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."read" AS PERMISSIVE FOR ALL TO public USING ("actions"."read"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."read"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."revision" AS PERMISSIVE FOR ALL TO public USING ("actions"."revision"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."revision"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "agent_work"."attention_advisory" AS PERMISSIVE FOR ALL TO public USING ("agent_work"."attention_advisory"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("agent_work"."attention_advisory"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "global_definitions_read" ON "composition"."operation_contract" AS PERMISSIVE FOR SELECT TO public USING (true);--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "review_work"."reply_content" AS PERMISSIVE FOR ALL TO public USING ("review_work"."reply_content"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("review_work"."reply_content"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "app_store_connect"."attempt_receipt" AS PERMISSIVE FOR ALL TO public USING ("app_store_connect"."attempt_receipt"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("app_store_connect"."attempt_receipt"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "app_store_connect"."review_target" AS PERMISSIVE FOR ALL TO public USING ("app_store_connect"."review_target"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("app_store_connect"."review_target"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "google_play"."review_target" AS PERMISSIVE FOR ALL TO public USING ("google_play"."review_target"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("google_play"."review_target"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."execution" AS PERMISSIVE FOR ALL TO public USING ("actions"."execution"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."execution"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."execution_attempt" AS PERMISSIVE FOR ALL TO public USING ("actions"."execution_attempt"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."execution_attempt"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "actions"."execution_step" AS PERMISSIVE FOR ALL TO public USING ("actions"."execution_step"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("actions"."execution_step"."organization_id" = current_setting('fload.organization_id', true));
--> statement-breakpoint
-- Structural constraints that Drizzle does not model: deferred graph references,
-- immutable evidence and closed owner seals. These are the final definitions.
ALTER TABLE "actions"."action" ALTER CONSTRAINT "action_organization_id_organization_id_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."action" ALTER CONSTRAINT "action_owner_user_id_user_id_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."action" ALTER CONSTRAINT "action_asset_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."action" ALTER CONSTRAINT "action_parent_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."action" ALTER CONSTRAINT "action_successor_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."action" ALTER CONSTRAINT "action_head_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."action" ALTER CONSTRAINT "action_approval_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."alias" ALTER CONSTRAINT "alias_action_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."approval" ALTER CONSTRAINT "approval_revision_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."approval" ALTER CONSTRAINT "approval_command_target_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."approval" ALTER CONSTRAINT "approval_parent_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command" ALTER CONSTRAINT "command_organization_id_organization_id_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command" ALTER CONSTRAINT "command_actor_user_id_user_id_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command" ALTER CONSTRAINT "command_actor_acting_for_user_id_user_id_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command" ALTER CONSTRAINT "command_actor_api_key_id_api_key_id_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command_target" ALTER CONSTRAINT "target_command_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command_target" ALTER CONSTRAINT "target_action_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command_target" ALTER CONSTRAINT "target_expected_revision_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command_target" ALTER CONSTRAINT "target_previous_revision_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command_target" ALTER CONSTRAINT "target_result_revision_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command_target" ALTER CONSTRAINT "target_expected_parent_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command_target" ALTER CONSTRAINT "target_evidence_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command_target" ALTER CONSTRAINT "target_previous_approval_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command_target" ALTER CONSTRAINT "target_result_approval_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command_target" ALTER CONSTRAINT "target_previous_successor_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."command_target" ALTER CONSTRAINT "target_result_successor_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."dependency" ALTER CONSTRAINT "dependency_dependent_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."dependency" ALTER CONSTRAINT "dependency_prerequisite_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."dependency" ALTER CONSTRAINT "dependency_command_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."membership" ALTER CONSTRAINT "membership_parent_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."membership" ALTER CONSTRAINT "membership_child_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."read" ALTER CONSTRAINT "read_user_id_user_id_fk" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."read" ALTER CONSTRAINT "read_action_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."revision" ALTER CONSTRAINT "revision_action_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."revision" ALTER CONSTRAINT "revision_author_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."revision" ALTER CONSTRAINT "revision_baseline_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "actions"."revision" ALTER CONSTRAINT "revision_generation_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "agent_work"."attention_advisory" ALTER CONSTRAINT "attention_revision_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "review_work"."reply_content" ALTER CONSTRAINT "review_content_revision_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "review_work"."reply_content" ALTER CONSTRAINT "review_content_original_ai_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "app_store_connect"."review_target" ALTER CONSTRAINT "asc_review_revision_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE "google_play"."review_target" ALTER CONSTRAINT "play_review_revision_scope" DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.execution ALTER CONSTRAINT execution_next_step_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.execution ALTER CONSTRAINT execution_cancel_command_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.execution ALTER CONSTRAINT execution_resource_guard_identity DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.execution ALTER CONSTRAINT execution_approval_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.resource_guard ALTER CONSTRAINT resource_guard_holder_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.execution_step ALTER CONSTRAINT step_execution_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.execution_attempt ALTER CONSTRAINT attempt_cycle_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.execution_attempt ALTER CONSTRAINT attempt_evidence_command_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.execution_attempt ALTER CONSTRAINT attempt_subject_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.execution_attempt ALTER CONSTRAINT attempt_input_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.execution_attempt ALTER CONSTRAINT attempt_prewrite_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.command ALTER CONSTRAINT command_execution_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.command ALTER CONSTRAINT command_step_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.command ALTER CONSTRAINT command_subject_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.command ALTER CONSTRAINT command_planned_step_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE actions.command ALTER CONSTRAINT command_cycle_predecessor_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
ALTER TABLE app_store_connect.attempt_receipt ALTER CONSTRAINT asc_receipt_attempt_scope DEFERRABLE INITIALLY DEFERRED;
--> statement-breakpoint
CREATE FUNCTION actions.reject_fact_mutation() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'Immutable Actions fact: %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = '23514';
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION actions.guard_revision() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'Revision deletion requires the separate erasure authority' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'INSERT' AND NEW.sealed THEN
    RAISE EXCEPTION 'Build content before sealing its revision' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'UPDATE' THEN
    IF OLD.sealed OR ROW(NEW.id, NEW.organization_id, NEW.action_id, NEW.purpose, NEW.kind, NEW.revision_number, NEW.authored_command_id, NEW.created_at)
      IS DISTINCT FROM ROW(OLD.id, OLD.organization_id, OLD.action_id, OLD.purpose, OLD.kind, OLD.revision_number, OLD.authored_command_id, OLD.created_at) THEN
      RAISE EXCEPTION 'A sealed revision and revision identity are immutable' USING ERRCODE = '23514';
    END IF;
    IF NEW.sealed THEN
      -- Each later owner extends this closed dispatch with its complete leaves.
      -- A contract enum alone never enables a content or provider branch.
      IF NEW.kind = 'advisory' AND NEW.purpose = 'proposal' THEN
        IF NOT EXISTS (SELECT 1 FROM agent_work.attention_advisory c WHERE c.organization_id = NEW.organization_id AND c.revision_id = NEW.id)
          OR EXISTS (SELECT 1 FROM actions.membership m WHERE m.organization_id = NEW.organization_id AND m.parent_revision_id = NEW.id) THEN
          RAISE EXCEPTION 'Incomplete attention advisory content' USING ERRCODE = '23514';
        END IF;
      ELSIF NEW.kind = 'collection' AND NEW.purpose = 'proposal' THEN
        IF NOT EXISTS (SELECT 1 FROM actions.membership m WHERE m.organization_id = NEW.organization_id AND m.parent_revision_id = NEW.id)
          OR EXISTS (SELECT 1 FROM agent_work.attention_advisory c WHERE c.organization_id = NEW.organization_id AND c.revision_id = NEW.id)
          OR EXISTS (SELECT 1 FROM actions.membership m LEFT JOIN actions.revision c ON c.organization_id = m.organization_id AND c.id = m.child_revision_id
            WHERE m.organization_id = NEW.organization_id AND m.parent_revision_id = NEW.id
            AND (c.id IS NULL OR c.kind = 'collection' OR NOT c.sealed OR c.purpose <> 'proposal' OR c.action_id = NEW.action_id)) THEN
          RAISE EXCEPTION 'Incomplete sealed collection membership' USING ERRCODE = '23514';
        END IF;
      ELSIF NEW.kind = 'review_reply' AND NEW.purpose IN ('proposal', 'baseline', 'observation') THEN
        PERFORM composition.check_review_revision_seal(NEW);
      ELSE
        RAISE EXCEPTION 'Content owner is not yet installed for this revision shape' USING ERRCODE = '23514';
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.guard_content() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE content_revision_id text; content_tenant_id text; is_sealed boolean;
BEGIN
  IF TG_OP = 'DELETE' THEN content_revision_id := OLD.revision_id; content_tenant_id := OLD.organization_id;
  ELSE content_revision_id := NEW.revision_id; content_tenant_id := NEW.organization_id; END IF;
  IF TG_OP = 'UPDATE' AND ROW(NEW.revision_id, NEW.organization_id) IS DISTINCT FROM ROW(OLD.revision_id, OLD.organization_id) THEN
    RAISE EXCEPTION 'Content cannot move to another revision' USING ERRCODE = '23514';
  END IF;
  SELECT r.sealed INTO is_sealed FROM actions.revision r WHERE r.id = content_revision_id AND r.organization_id = content_tenant_id FOR UPDATE;
  IF NOT FOUND OR is_sealed THEN
    RAISE EXCEPTION 'Content requires an existing unsealed revision' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.guard_membership() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_id text; tenant_id text; is_sealed boolean;
BEGIN
  IF TG_OP = 'DELETE' THEN parent_id := OLD.parent_revision_id; tenant_id := OLD.organization_id;
  ELSE parent_id := NEW.parent_revision_id; tenant_id := NEW.organization_id; END IF;
  IF TG_OP = 'UPDATE' AND ROW(NEW.parent_revision_id, NEW.organization_id) IS DISTINCT FROM ROW(OLD.parent_revision_id, OLD.organization_id) THEN
    RAISE EXCEPTION 'Membership cannot move to another revision' USING ERRCODE = '23514';
  END IF;
  SELECT r.sealed INTO is_sealed FROM actions.revision r WHERE r.id = parent_id AND r.organization_id = tenant_id FOR UPDATE;
  IF NOT FOUND OR is_sealed THEN RAISE EXCEPTION 'Membership requires an existing unsealed parent' USING ERRCODE = '23514'; END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.guard_action_identity() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN RAISE EXCEPTION 'Ticket deletion requires the separate erasure authority' USING ERRCODE = '23514'; END IF;
  IF TG_OP = 'INSERT' THEN
    IF NEW.version <> 1 OR NEW.attention_version <> 1 THEN
      RAISE EXCEPTION 'A new ticket starts at version one without invented history' USING ERRCODE = '23514';
    END IF;
    RETURN NEW;
  END IF;
  IF ROW(NEW.id, NEW.organization_id, NEW.creation_key, NEW.asset_id, NEW.domain, NEW.parent_action_id, NEW.created_at)
    IS DISTINCT FROM ROW(OLD.id, OLD.organization_id, OLD.creation_key, OLD.asset_id, OLD.domain, OLD.parent_action_id, OLD.created_at) THEN
    RAISE EXCEPTION 'Permanent ticket identity cannot change' USING ERRCODE = '23514';
  END IF;
  IF NEW.version <> OLD.version + 1 OR NEW.attention_version - OLD.attention_version NOT BETWEEN 0 AND 1 THEN
    RAISE EXCEPTION 'Ticket writes require a version increment and bounded attention increment' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION actions.check_committed_action() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE head actions.revision; target actions.command_target; receipt actions.command;
BEGIN
  SELECT * INTO head FROM actions.revision r WHERE r.organization_id = NEW.organization_id AND r.action_id = NEW.id AND r.id = NEW.current_revision_id;
  IF NOT FOUND OR NOT head.sealed OR (NEW.record_kind = 'work' AND head.purpose <> 'proposal') OR (NEW.record_kind <> 'work' AND head.purpose <> 'historical') THEN
    RAISE EXCEPTION 'Committed ticket requires a sealed head of the correct purpose' USING ERRCODE = '23514';
  END IF;
  IF NOT ((NEW.domain = 'reviews' AND head.kind = 'review_reply') OR (NEW.domain = 'listing' AND head.kind = 'listing')
    OR (NEW.domain = 'ads' AND head.kind = 'ads') OR (NEW.domain = 'agent' AND head.kind = 'request')
    OR (NEW.domain = 'advisory' AND head.kind = 'advisory') OR (NEW.domain = 'collection' AND head.kind = 'collection')) THEN
    RAISE EXCEPTION 'Ticket domain differs from its content owner' USING ERRCODE = '23514';
  END IF;
  SELECT * INTO target FROM actions.command_target t WHERE t.organization_id = NEW.organization_id AND t.action_id = NEW.id AND t.result_version = NEW.version;
  IF NOT FOUND OR ROW(target.result_decision, target.result_record_kind, target.result_revision_id, target.result_approval_id, target.result_attention_version, target.result_owner_user_id, target.result_snoozed_until, target.result_scheduled_for, target.result_archived_at, target.result_priority, target.result_successor_action_id)
    IS DISTINCT FROM ROW(NEW.decision, NEW.record_kind, NEW.current_revision_id, NEW.current_approval_id, NEW.attention_version, NEW.owner_user_id, NEW.snoozed_until, NEW.scheduled_for, NEW.archived_at, NEW.priority, NEW.successor_action_id) THEN
    RAISE EXCEPTION 'Ticket change requires its exact immutable command target' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'UPDATE' AND ROW(target.previous_version, target.previous_decision, target.previous_record_kind, target.previous_revision_id, target.previous_approval_id, target.previous_attention_version, target.previous_owner_user_id, target.previous_snoozed_until, target.previous_scheduled_for, target.previous_archived_at, target.previous_priority, target.previous_successor_action_id)
    IS DISTINCT FROM ROW(OLD.version, OLD.decision, OLD.record_kind, OLD.current_revision_id, OLD.current_approval_id, OLD.attention_version, OLD.owner_user_id, OLD.snoozed_until, OLD.scheduled_for, OLD.archived_at, OLD.priority, OLD.successor_action_id) THEN
    RAISE EXCEPTION 'Command target does not preserve the exact previous state' USING ERRCODE = '23514';
  END IF;
  SELECT * INTO receipt FROM actions.command c WHERE c.organization_id = target.organization_id AND c.id = target.command_id;
  IF NOT FOUND OR receipt.outcome <> 'accepted' THEN RAISE EXCEPTION 'Ticket mutation requires an accepted command' USING ERRCODE = '23514'; END IF;
  IF TG_OP = 'INSERT' AND (target.previous_version IS NOT NULL OR receipt.kind <> 'create') THEN
    RAISE EXCEPTION 'Initial ticket history requires a create command without a predecessor' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'INSERT' THEN
    IF NEW.scheduled_for IS NOT NULL THEN
      RAISE EXCEPTION 'Initial work starts unscheduled; historical schedule import is not installed' USING ERRCODE = '23514';
    END IF;
  ELSIF receipt.kind IN ('schedule', 'unschedule') THEN
    IF NEW.record_kind <> 'work' OR OLD.record_kind <> 'work' OR OLD.decision NOT IN ('open', 'approved') THEN
      RAISE EXCEPTION 'Scheduling requires current open or approved work' USING ERRCODE = '23514';
    END IF;
    IF ROW(NEW.decision, NEW.record_kind, NEW.current_revision_id, NEW.current_approval_id, NEW.attention_version, NEW.owner_user_id, NEW.snoozed_until, NEW.archived_at, NEW.priority, NEW.successor_action_id)
      IS DISTINCT FROM ROW(OLD.decision, OLD.record_kind, OLD.current_revision_id, OLD.current_approval_id, OLD.attention_version, OLD.owner_user_id, OLD.snoozed_until, OLD.archived_at, OLD.priority, OLD.successor_action_id) THEN
      RAISE EXCEPTION 'Scheduling preserves content, approval, attention and other workflow fields' USING ERRCODE = '23514';
    END IF;
    IF receipt.kind = 'schedule' AND (NEW.scheduled_for IS NULL OR NEW.scheduled_for <= receipt.accepted_at) THEN
      RAISE EXCEPTION 'Schedule must be strictly after original command admission' USING ERRCODE = '23514';
    END IF;
    IF receipt.kind = 'unschedule' AND NEW.scheduled_for IS NOT NULL THEN
      RAISE EXCEPTION 'Unschedule must clear the exact schedule' USING ERRCODE = '23514';
    END IF;
  ELSIF NEW.scheduled_for IS DISTINCT FROM OLD.scheduled_for THEN
    RAISE EXCEPTION 'Other commands must preserve scheduling' USING ERRCODE = '23514';
  END IF;
  RETURN NULL;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION actions.check_approval_revision() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE r actions.revision; e actions.execution;
BEGIN
  SELECT * INTO r FROM actions.revision WHERE organization_id=NEW.organization_id AND action_id=NEW.action_id AND id=NEW.revision_id;
  IF NOT FOUND OR NOT r.sealed OR r.purpose<>'proposal' OR r.kind='advisory'
    OR (r.kind='collection' AND (NEW.scope NOT IN ('generate','revise') OR NEW.required_surface<>'internal_artifact')) THEN
    RAISE EXCEPTION 'Approval requires its exact sealed executable proposal' USING ERRCODE='23514';
  END IF;
  SELECT * INTO e FROM actions.execution WHERE organization_id=NEW.organization_id AND approval_id=NEW.id;
  IF NOT FOUND OR NOT EXISTS(SELECT 1 FROM actions.execution_step s WHERE s.organization_id=e.organization_id AND s.execution_id=e.id AND s.content_revision_id=r.id) THEN
    RAISE EXCEPTION 'Approval requires its atomic durable execution and plan' USING ERRCODE='23514';
  END IF;
  IF NEW.parent_revision_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM actions.membership m JOIN actions.revision p ON p.organization_id=m.organization_id AND p.id=m.parent_revision_id
    WHERE m.organization_id=NEW.organization_id AND m.parent_revision_id=NEW.parent_revision_id AND m.child_action_id=NEW.action_id AND m.child_revision_id=NEW.revision_id AND p.sealed AND p.kind='collection') THEN
    RAISE EXCEPTION 'Approval must pin its exact sealed parent membership' USING ERRCODE='23514';
  END IF;
  RETURN NULL;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.check_committed_revision() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE retained actions.revision;
BEGIN
  SELECT * INTO retained FROM actions.revision r WHERE r.organization_id = NEW.organization_id AND r.id = NEW.id;
  IF NOT FOUND OR NOT retained.sealed THEN RAISE EXCEPTION 'No incomplete revision may survive commit' USING ERRCODE = '23514'; END IF;
  IF NOT EXISTS (SELECT 1 FROM actions.command c WHERE c.organization_id = retained.organization_id AND c.id = retained.authored_command_id AND c.outcome = 'accepted') THEN
    RAISE EXCEPTION 'Revision authorship requires an accepted command' USING ERRCODE = '23514';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM actions.command_target t WHERE t.organization_id = retained.organization_id AND t.command_id = retained.authored_command_id
    AND t.action_id = retained.action_id AND (t.result_revision_id = retained.id OR t.evidence_revision_id = retained.id)) THEN
    RAISE EXCEPTION 'Revision authorship requires its exact command history edge' USING ERRCODE = '23514';
  END IF;
  RETURN NULL;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION actions.check_command_targets() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.outcome='accepted' AND NEW.kind='open_recovery' AND NEW.principal_kind='system'
    AND NEW.cycle_purpose IS NOT NULL AND NEW.progress_execution_id IS NOT NULL AND NEW.progress_step_id IS NOT NULL
    AND NEW.cycle_contract_id IS NOT NULL AND NEW.cycle_anchor_at IS NOT NULL AND NEW.cycle_predecessor_command_id IS NULL THEN
    IF EXISTS (SELECT 1 FROM actions.command_target t WHERE t.organization_id=NEW.organization_id AND t.command_id=NEW.id) THEN
      RAISE EXCEPTION 'Initial recovery commands are targetless and cannot mutate ticket history' USING ERRCODE='23514';
    END IF;
  ELSIF NEW.outcome='accepted' AND NOT EXISTS (
    SELECT 1 FROM actions.command_target t WHERE t.organization_id=NEW.organization_id AND t.command_id=NEW.id
  ) THEN
    RAISE EXCEPTION 'An accepted ticket command requires durable targets' USING ERRCODE='23514';
  END IF;
  IF NEW.outcome<>'accepted' AND EXISTS (
    SELECT 1 FROM actions.command_target t WHERE t.organization_id=NEW.organization_id AND t.command_id=NEW.id
  ) THEN
    RAISE EXCEPTION 'Refused commands cannot mutate tickets' USING ERRCODE='23514';
  END IF;
  RETURN NULL;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION actions.check_target_snapshot() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM actions.command c WHERE c.organization_id=NEW.organization_id
    AND c.id=NEW.command_id AND c.kind='open_recovery') THEN
    RAISE EXCEPTION 'Initial recovery commands are targetless and cannot mutate ticket history' USING ERRCODE='23514';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM actions.action a JOIN actions.command c ON c.organization_id=a.organization_id AND c.id=NEW.command_id
    WHERE a.organization_id=NEW.organization_id AND a.id=NEW.action_id AND a.version>=NEW.result_version AND c.outcome='accepted') THEN
    RAISE EXCEPTION 'Command targets must describe committed ticket versions' USING ERRCODE='23514';
  END IF;
  RETURN NULL;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.check_actor_admission() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.principal_kind = 'agent' THEN
    PERFORM 1 FROM public.agent_run r WHERE r.id = NEW.actor_agent_run_id AND r."organizationId" = NEW.organization_id FOR KEY SHARE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Agent actor requires a live run in the same organization' USING ERRCODE = '23514'; END IF;
  ELSIF NEW.principal_kind = 'api_key' THEN
    PERFORM 1 FROM public.api_key k WHERE k.id = NEW.actor_api_key_id AND k."organizationId" = NEW.organization_id AND k."userId" = NEW.actor_user_id FOR KEY SHARE;
    IF NOT FOUND THEN RAISE EXCEPTION 'API actor key, user and organization must agree' USING ERRCODE = '23514'; END IF;
  ELSIF NEW.principal_kind = 'policy' THEN
    RAISE EXCEPTION 'Policy owner is not installed for Actions admission' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION agent_work.check_attention_source_admission() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM 1 FROM public.agent a WHERE a.id = NEW.agent_source_id AND a."organizationId" = NEW.organization_id AND a.type = NEW.agent_type::text FOR KEY SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Attention content requires its exact live agent and tenant at admission' USING ERRCODE = '23514'; END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION review_work.guard_review_owner() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  IF NOT EXISTS (SELECT 1 FROM actions.revision r WHERE r.organization_id = NEW.organization_id
    AND r.id = NEW.revision_id AND r.purpose = NEW.purpose AND r.kind = 'review_reply') THEN
    RAISE EXCEPTION 'Review leaves require the exact review revision owner and purpose' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION app_store_connect.check_review_revision_seal(revision actions.revision) RETURNS void LANGUAGE plpgsql AS $$
DECLARE content review_work.reply_content; target app_store_connect.review_target;
  baseline app_store_connect.review_target; expected_publication text;
BEGIN
  SELECT * INTO content FROM review_work.reply_content c WHERE c.organization_id = revision.organization_id AND c.revision_id = revision.id;
  IF NOT FOUND OR content.store <> 'ios' THEN RAISE EXCEPTION 'ASC review target requires iOS review content' USING ERRCODE = '23514'; END IF;
  SELECT * INTO target FROM app_store_connect.review_target t WHERE t.organization_id = revision.organization_id AND t.revision_id = revision.id;
  IF NOT FOUND OR target.purpose <> revision.purpose THEN RAISE EXCEPTION 'Missing exact ASC review target leaf' USING ERRCODE = '23514'; END IF;
  IF revision.purpose = 'proposal' THEN
    IF (content.intent = 'update') IS DISTINCT FROM (target.response_id IS NOT NULL) OR target.native_state IS NOT NULL OR target.native_state_source IS NOT NULL THEN
      RAISE EXCEPTION 'ASC updates require the exact existing response identity' USING ERRCODE = '23514';
    END IF;
    IF target.review_resource_id IS NULL THEN
      RAISE EXCEPTION 'ASC proposals require an exact native review identity' USING ERRCODE = '23514';
    END IF;
    SELECT * INTO baseline FROM app_store_connect.review_target t WHERE t.organization_id = revision.organization_id AND t.revision_id = revision.baseline_revision_id;
      IF NOT FOUND OR ROW(baseline.source_asset_data_source_id, baseline.source_connector_id, baseline.credential_kind, baseline.credential_key_id, baseline.credential_team_issuer_id, baseline.review_resource_id, baseline.response_id) IS DISTINCT FROM ROW(target.source_asset_data_source_id, target.source_connector_id, target.credential_kind, target.credential_key_id, target.credential_team_issuer_id, target.review_resource_id, target.response_id) THEN
        RAISE EXCEPTION 'ASC proposal target differs from its captured response baseline' USING ERRCODE = '23514';
      END IF;
  ELSIF content.response_availability = 'present' THEN
    IF target.response_id IS NULL OR target.native_state_source IS NULL THEN
      RAISE EXCEPTION 'ASC observed responses require actual identity and a declared native-state source' USING ERRCODE = '23514';
    END IF;
    -- Current web/client.ts getAppReviews maps unknown/missing pending flags
    -- to NONE (6460-6465); NONE is not publication proof. Current API readback
    -- only trusts PUBLISHED: review-applied-readback.ts compareResponseState.
    expected_publication := CASE
      WHEN content.response_hidden IS TRUE THEN 'hidden'
      WHEN target.native_state_source = 'api_publication' AND target.native_state = 'PUBLISHED' THEN 'published'
      WHEN target.native_state_source = 'api_publication' AND target.native_state = 'PENDING_PUBLISH' THEN 'pending_publication'
      WHEN target.native_state_source = 'browser_pending' AND target.native_state IN ('PENDING_CREATE', 'PENDING_UPDATE') THEN 'pending_publication'
      ELSE 'unreadable'
    END;
    IF content.publication_state::text IS DISTINCT FROM expected_publication THEN
      RAISE EXCEPTION 'ASC native state does not support the claimed neutral publication state' USING ERRCODE = '23514';
    END IF;
  ELSIF target.response_id IS NOT NULL OR target.native_state IS NOT NULL OR target.native_state_source IS NOT NULL THEN
    RAISE EXCEPTION 'Unavailable ASC responses cannot carry invented response facts' USING ERRCODE = '23514';
  END IF;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION google_play.check_review_revision_seal(revision actions.revision) RETURNS void LANGUAGE plpgsql AS $$
DECLARE content review_work.reply_content; target google_play.review_target;
BEGIN
  SELECT * INTO content FROM review_work.reply_content c WHERE c.organization_id = revision.organization_id AND c.revision_id = revision.id;
  IF NOT FOUND OR content.store <> 'android' THEN RAISE EXCEPTION 'Play review target requires Android review content' USING ERRCODE = '23514'; END IF;
  SELECT * INTO target FROM google_play.review_target t WHERE t.organization_id = revision.organization_id AND t.revision_id = revision.id;
  IF NOT FOUND OR target.purpose <> revision.purpose THEN RAISE EXCEPTION 'Missing exact Play review target leaf' USING ERRCODE = '23514'; END IF;
  IF revision.purpose = 'proposal' AND NOT EXISTS (
    SELECT 1 FROM google_play.review_target b WHERE b.organization_id = revision.organization_id
    AND b.revision_id = revision.baseline_revision_id AND b.provider_account_id = target.provider_account_id
  ) THEN RAISE EXCEPTION 'Play proposal target differs from its captured account baseline' USING ERRCODE = '23514'; END IF;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION review_work.check_revision_seal(revision actions.revision) RETURNS void LANGUAGE plpgsql AS $$
DECLARE content review_work.reply_content; original actions.revision; original_content review_work.reply_content;
  baseline actions.revision; baseline_content review_work.reply_content;
BEGIN
  SELECT * INTO content FROM review_work.reply_content c WHERE c.organization_id = revision.organization_id AND c.revision_id = revision.id;
  IF NOT FOUND OR revision.kind <> 'review_reply' OR revision.purpose NOT IN ('proposal', 'baseline', 'observation')
    OR content.purpose <> revision.purpose THEN
    RAISE EXCEPTION 'Incomplete review content or unsupported purpose' USING ERRCODE = '23514';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM actions.action a WHERE a.organization_id = revision.organization_id AND a.id = revision.action_id AND a.domain = 'reviews') THEN
    RAISE EXCEPTION 'Review revisions require their sole content owner' USING ERRCODE = '23514';
  END IF;
  IF EXISTS (SELECT 1 FROM actions.revision r JOIN review_work.reply_content c ON c.organization_id = r.organization_id AND c.revision_id = r.id
    WHERE r.organization_id = revision.organization_id AND r.action_id = revision.action_id
    AND ROW(c.store, c.provider_app_id, c.provider_review_id) IS DISTINCT FROM ROW(content.store, content.provider_app_id, content.provider_review_id)) THEN
    RAISE EXCEPTION 'Review identity cannot change between ticket revisions' USING ERRCODE = '23514';
  END IF;

  IF content.original_ai_revision_id IS NOT NULL THEN
    -- This is an immutable content-lineage edge. Actual AI authorship still
    -- requires the generation owner's invocation evidence; the link alone
    -- never supplies that evidence or grants execution authority.
    SELECT * INTO original FROM actions.revision r WHERE r.organization_id = revision.organization_id AND r.id = content.original_ai_revision_id;
    IF NOT FOUND OR original.action_id <> revision.action_id OR original.kind <> 'review_reply' OR original.purpose <> 'proposal'
      OR NOT original.sealed OR original.revision_number >= revision.revision_number THEN
      RAISE EXCEPTION 'Original AI reference requires an earlier sealed proposal on this review ticket' USING ERRCODE = '23514';
    END IF;
    SELECT * INTO original_content FROM review_work.reply_content c WHERE c.organization_id = revision.organization_id AND c.revision_id = original.id;
    IF NOT FOUND OR ROW(original_content.store, original_content.provider_app_id, original_content.provider_review_id)
      IS DISTINCT FROM ROW(content.store, content.provider_app_id, content.provider_review_id) THEN
      RAISE EXCEPTION 'Original AI content must belong to the exact review identity' USING ERRCODE = '23514';
    END IF;
  END IF;

  IF revision.baseline_revision_id IS NOT NULL THEN
    SELECT * INTO baseline FROM actions.revision r WHERE r.organization_id = revision.organization_id AND r.id = revision.baseline_revision_id;
    IF NOT FOUND OR baseline.action_id <> revision.action_id OR baseline.kind <> 'review_reply' OR baseline.purpose <> 'baseline' OR NOT baseline.sealed OR baseline.revision_number >= revision.revision_number THEN
      RAISE EXCEPTION 'Review baseline requires an exact sealed baseline on this ticket' USING ERRCODE = '23514';
    END IF;
    SELECT * INTO baseline_content FROM review_work.reply_content c WHERE c.organization_id = revision.organization_id AND c.revision_id = baseline.id;
    IF NOT FOUND OR ROW(baseline_content.store, baseline_content.provider_app_id, baseline_content.provider_review_id)
      IS DISTINCT FROM ROW(content.store, content.provider_app_id, content.provider_review_id) THEN
      RAISE EXCEPTION 'Review baseline identity differs from its proposal' USING ERRCODE = '23514';
    END IF;
  END IF;
  IF revision.purpose = 'proposal' THEN
    IF content.intent = 'send' AND (revision.baseline_revision_id IS NULL OR baseline_content.response_availability IS DISTINCT FROM 'absent') THEN
      RAISE EXCEPTION 'A reply send requires an exact absent-response baseline' USING ERRCODE = '23514';
    END IF;
    IF content.intent = 'update' AND (revision.baseline_revision_id IS NULL OR baseline_content.response_availability IS DISTINCT FROM 'present') THEN
      RAISE EXCEPTION 'A reply update requires the exact existing-response baseline' USING ERRCODE = '23514';
    END IF;
    IF ROW(baseline_content.review_snapshot_availability, baseline_content.review_rating,
      baseline_content.review_title, baseline_content.review_body, baseline_content.review_nickname,
      baseline_content.review_storefront, baseline_content.review_app_version, baseline_content.review_created_at,
      baseline_content.review_modified_at, baseline_content.review_edited)
      IS DISTINCT FROM ROW(content.review_snapshot_availability, content.review_rating,
      content.review_title, content.review_body, content.review_nickname,
      content.review_storefront, content.review_app_version, content.review_created_at,
      content.review_modified_at, content.review_edited) THEN
      RAISE EXCEPTION 'Review proposal must retain its exact baseline review snapshot' USING ERRCODE = '23514';
    END IF;
  END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION composition.check_review_revision_seal(revision actions.revision) RETURNS void LANGUAGE plpgsql AS $$
DECLARE review_store review_work.store;
BEGIN
  PERFORM review_work.check_revision_seal(revision);
  IF EXISTS (SELECT 1 FROM agent_work.attention_advisory c WHERE c.organization_id = revision.organization_id AND c.revision_id = revision.id)
    OR EXISTS (SELECT 1 FROM actions.membership m WHERE m.organization_id = revision.organization_id AND m.parent_revision_id = revision.id) THEN
    RAISE EXCEPTION 'Review revision cannot contain another domain content family' USING ERRCODE = '23514';
  END IF;
  SELECT c.store INTO review_store FROM review_work.reply_content c WHERE c.organization_id = revision.organization_id AND c.revision_id = revision.id;
  IF review_store = 'ios' THEN
    IF EXISTS (SELECT 1 FROM google_play.review_target t WHERE t.organization_id = revision.organization_id AND t.revision_id = revision.id) THEN
      RAISE EXCEPTION 'An iOS review cannot contain a Play target leaf' USING ERRCODE = '23514';
    END IF;
    PERFORM app_store_connect.check_review_revision_seal(revision);
  ELSE
    IF EXISTS (SELECT 1 FROM app_store_connect.review_target t WHERE t.organization_id = revision.organization_id AND t.revision_id = revision.id) THEN
      RAISE EXCEPTION 'A Play review cannot contain an ASC target leaf' USING ERRCODE = '23514';
    END IF;
    PERFORM google_play.check_review_revision_seal(revision);
  END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.guard_execution_structure() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN RAISE EXCEPTION 'Execution deletion requires erasure authority' USING ERRCODE='23514'; END IF;
  IF TG_OP = 'INSERT' THEN
    IF NEW.phase <> 'ready' OR NEW.claim_generation <> 0 OR NEW.delivery_generation <> 1
      OR NEW.writes_closed_at IS NOT NULL OR NEW.plan_complete THEN
      RAISE EXCEPTION 'A new execution starts ready without invented history' USING ERRCODE='23514';
    END IF;
  ELSE
    IF ROW(NEW.id,NEW.organization_id,NEW.approval_id,NEW.created_at,NEW.plan_version,NEW.resource_guard_id)
      IS DISTINCT FROM ROW(OLD.id,OLD.organization_id,OLD.approval_id,OLD.created_at,OLD.plan_version,OLD.resource_guard_id) THEN
      RAISE EXCEPTION 'Execution identity and plan pin are immutable' USING ERRCODE='23514';
    END IF;
    IF OLD.phase IN ('settled','cancelled') AND NEW IS DISTINCT FROM OLD THEN
      RAISE EXCEPTION 'Terminal execution is immutable' USING ERRCODE='23514';
    END IF;
    IF NEW.claim_generation < OLD.claim_generation OR NEW.delivery_generation < OLD.delivery_generation
      OR NEW.claim_generation > OLD.claim_generation + 1 OR NEW.delivery_generation > OLD.delivery_generation + 1
      OR (OLD.plan_complete AND NOT NEW.plan_complete)
      OR (OLD.writes_closed_at IS NOT NULL AND NEW.writes_closed_at IS DISTINCT FROM OLD.writes_closed_at) THEN
      RAISE EXCEPTION 'Execution generations and closure facts cannot rewind or skip' USING ERRCODE='23514';
    END IF;
    IF NEW.claim_token IS NOT NULL AND NEW.claim_token IS DISTINCT FROM OLD.claim_token AND NEW.claim_generation <> OLD.claim_generation + 1 THEN
      RAISE EXCEPTION 'A new claim token requires the next generation' USING ERRCODE='23514';
    END IF;
    IF OLD.claim_token IS NOT NULL AND NEW.claim_token = OLD.claim_token
      AND (NEW.claim_generation <> OLD.claim_generation OR NEW.claim_expires_at IS DISTINCT FROM OLD.claim_expires_at) THEN
      RAISE EXCEPTION 'A retained claim cannot change its fence or expiry' USING ERRCODE='23514';
    END IF;
  END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.assert_execution_graph(scope_organization text, scope_execution text) RETURNS void LANGUAGE plpgsql AS $$
DECLARE e actions.execution; ap actions.approval; a actions.action; unfinished actions.execution_attempt;
BEGIN
  SELECT * INTO e FROM actions.execution WHERE organization_id=scope_organization AND id=scope_execution;
  SELECT * INTO ap FROM actions.approval WHERE organization_id=e.organization_id AND id=e.approval_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Execution requires its exact approval' USING ERRCODE='23514'; END IF;
  SELECT * INTO a FROM actions.action WHERE organization_id=ap.organization_id AND id=ap.action_id;
  IF NOT FOUND OR (e.phase NOT IN ('settled','cancelled') AND
    (a.current_approval_id IS DISTINCT FROM ap.id OR a.current_revision_id IS DISTINCT FROM ap.revision_id OR a.decision <> 'approved')) THEN
    RAISE EXCEPTION 'Active execution must retain the exact current approval and revision' USING ERRCODE='23514';
  END IF;
  IF NOT EXISTS(SELECT 1 FROM actions.execution_step s WHERE s.organization_id=e.organization_id AND s.execution_id=e.id) THEN
    RAISE EXCEPTION 'Execution requires durable scoped plan steps' USING ERRCODE='23514';
  END IF;
  SELECT * INTO unfinished FROM actions.execution_attempt x WHERE x.organization_id=e.organization_id AND x.execution_id=e.id AND x.finished_at IS NULL;
  IF (e.phase='claimed') IS DISTINCT FROM (unfinished.id IS NOT NULL)
    OR (unfinished.id IS NOT NULL AND (unfinished.claim_generation <> e.claim_generation OR unfinished.claim_token IS DISTINCT FROM e.claim_token)) THEN
    RAISE EXCEPTION 'Committed claim and unfinished original attempt must agree' USING ERRCODE='23514';
  END IF;
  IF e.phase IN ('ready','verification_due','uncertain','claimed') AND e.next_step_id IS NULL THEN
    RAISE EXCEPTION 'Active execution requires a concrete routing step' USING ERRCODE='23514';
  END IF;
  IF e.phase='cancelled' AND NOT EXISTS(SELECT 1 FROM actions.command c JOIN actions.command_target t ON t.organization_id=c.organization_id AND t.command_id=c.id
      WHERE c.organization_id=e.organization_id AND c.id=e.cancelled_command_id AND c.outcome='accepted' AND c.kind IN ('undo','revise','reject') AND t.action_id=ap.action_id) THEN
    RAISE EXCEPTION 'Execution cancellation requires its exact accepted ticket command' USING ERRCODE='23514';
  END IF;
  IF e.phase IN ('settled','cancelled') AND EXISTS(SELECT 1 FROM actions.resource_guard g WHERE g.holder_organization_id=e.organization_id AND g.holder_execution_id=e.id) THEN
    RAISE EXCEPTION 'Terminal execution cannot retain a resource holder' USING ERRCODE='23514';
  END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.check_execution_graph() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM actions.assert_execution_graph(NEW.organization_id, NEW.id);
  RETURN NULL;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.check_action_execution_graph() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE candidate record;
BEGIN
  FOR candidate IN SELECT e.id FROM actions.execution e JOIN actions.approval ap ON ap.organization_id=e.organization_id AND ap.id=e.approval_id
    WHERE ap.organization_id=NEW.organization_id AND ap.action_id=NEW.id AND e.phase NOT IN ('settled','cancelled') LOOP
    PERFORM actions.assert_execution_graph(NEW.organization_id,candidate.id);
  END LOOP;
  RETURN NULL;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION actions.guard_execution_step() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE e actions.execution; ap actions.approval; r actions.revision;
BEGIN
  IF TG_OP <> 'INSERT' THEN RAISE EXCEPTION 'Execution steps are immutable' USING ERRCODE='23514'; END IF;
  SELECT * INTO e FROM actions.execution WHERE organization_id=NEW.organization_id AND id=NEW.execution_id FOR UPDATE;
  IF NOT FOUND OR e.phase IN ('settled','cancelled') OR e.plan_complete OR e.writes_closed_at IS NOT NULL THEN
    RAISE EXCEPTION 'A step requires an existing open execution plan' USING ERRCODE='23514';
  END IF;
  IF EXISTS(SELECT 1 FROM actions.execution_attempt c WHERE c.organization_id=NEW.organization_id
    AND c.execution_id=NEW.execution_id AND c.kind='conflicting_completion') THEN
    RAISE EXCEPTION 'Unresolved capture conflict forbids plan expansion' USING ERRCODE='23514';
  END IF;
  SELECT * INTO ap FROM actions.approval WHERE organization_id=e.organization_id AND id=e.approval_id;
  SELECT * INTO r FROM actions.revision WHERE organization_id=NEW.organization_id AND id=NEW.content_revision_id;
  IF NOT FOUND OR NOT r.sealed OR r.purpose<>'proposal' OR ap.id IS NULL OR r.id IS DISTINCT FROM ap.revision_id OR r.action_id IS DISTINCT FROM ap.action_id THEN
    RAISE EXCEPTION 'Step content must be the exact sealed approved proposal' USING ERRCODE='23514';
  END IF;
  IF NEW.input_step_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM actions.execution_step s WHERE s.organization_id=NEW.organization_id AND s.execution_id=NEW.execution_id AND s.id=NEW.input_step_id AND s.ordinal<NEW.ordinal) THEN
    RAISE EXCEPTION 'Step input must be an earlier immutable step in this execution' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION composition.check_execution_attempt_owner(candidate actions.execution_attempt) RETURNS void LANGUAGE plpgsql AS $$
DECLARE provider_kind composition.provider; contract_id text;
BEGIN
  SELECT c.provider,c.id INTO provider_kind,contract_id FROM actions.execution_step s JOIN composition.operation_contract c ON c.id=s.operation_contract_id
    WHERE s.organization_id=candidate.organization_id AND s.execution_id=candidate.execution_id AND s.id=candidate.step_id;
  IF NOT FOUND OR provider_kind='internal' THEN
    RAISE EXCEPTION 'Execution attempt owner is not installed for this shape' USING ERRCODE='23514';
  END IF;
  IF candidate.prewrite_attempt_id IS NOT NULL OR candidate.input_attempt_id IS NOT NULL THEN
    RAISE EXCEPTION 'Execution input evidence owner is not installed' USING ERRCODE='23514';
  END IF;
  IF contract_id='asc.review_response_upsert@1' THEN
    PERFORM app_store_connect.check_review_write_receipt(candidate);
    RETURN;
  END IF;
  IF candidate.kind<>'write' THEN RAISE EXCEPTION 'Captured evidence owner is not installed for this operation' USING ERRCODE='23514'; END IF;
  IF EXISTS(SELECT 1 FROM app_store_connect.attempt_receipt r WHERE r.organization_id=candidate.organization_id AND r.attempt_id=candidate.id) THEN
    RAISE EXCEPTION 'ASC receipt cannot finalize another operation' USING ERRCODE='23514';
  END IF;
  IF candidate.finished_at IS NOT NULL AND NOT (
    (candidate.result='known_not_applied' AND candidate.non_application_basis='pre_dispatch_failure')
    OR (candidate.result='uncertain' AND candidate.uncertainty_reason IN ('transport_lost','claim_expired'))
  ) THEN
    RAISE EXCEPTION 'Provider completion evidence owner is not installed' USING ERRCODE='23514';
  END IF;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION actions.guard_execution_attempt() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE e actions.execution; g actions.resource_guard;
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Attempt deletion requires erasure authority' USING ERRCODE='23514'; END IF;
  SELECT * INTO e FROM actions.execution WHERE organization_id=NEW.organization_id AND id=NEW.execution_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Attempt requires its exact execution' USING ERRCODE='23514'; END IF;
  IF TG_OP='UPDATE' THEN
    IF OLD.finished_at IS NOT NULL THEN RAISE EXCEPTION 'Finished attempt is immutable' USING ERRCODE='23514'; END IF;
    IF ROW(NEW.id,NEW.organization_id,NEW.execution_id,NEW.step_id,NEW.number,NEW.kind,NEW.claim_generation,NEW.claim_token,NEW.subject_attempt_id,NEW.input_attempt_id,NEW.input_parent_revision_id,NEW.connector_id,NEW.agent_run_id,NEW.started_at,NEW.recorded_at,NEW.inspection_purpose,NEW.planned_write_step_id,NEW.prewrite_attempt_id,NEW.resource_guard_generation,NEW.cycle_command_id,NEW.capture_digest,NEW.capture_digest_version)
      IS DISTINCT FROM ROW(OLD.id,OLD.organization_id,OLD.execution_id,OLD.step_id,OLD.number,OLD.kind,OLD.claim_generation,OLD.claim_token,OLD.subject_attempt_id,OLD.input_attempt_id,OLD.input_parent_revision_id,OLD.connector_id,OLD.agent_run_id,OLD.started_at,OLD.recorded_at,OLD.inspection_purpose,OLD.planned_write_step_id,OLD.prewrite_attempt_id,OLD.resource_guard_generation,OLD.cycle_command_id,OLD.capture_digest,OLD.capture_digest_version) THEN
      RAISE EXCEPTION 'Attempt admission identity is immutable' USING ERRCODE='23514';
    END IF;
    IF NEW.finished_at IS NULL THEN RAISE EXCEPTION 'An original attempt can only be updated to finalize once' USING ERRCODE='23514'; END IF;
  ELSE
    IF NEW.kind IN ('write','readback','inspection','generation') AND NEW.finished_at IS NOT NULL THEN
      RAISE EXCEPTION 'Original worker attempts must be durably admitted unfinished' USING ERRCODE='23514';
    END IF;
    IF NEW.kind NOT IN ('late_evidence','conflicting_completion') AND NEW.connector_id IS NOT NULL THEN
      PERFORM 1 FROM public.data_connector c WHERE c.id=NEW.connector_id AND c."organizationId"=NEW.organization_id FOR KEY SHARE;
      IF NOT FOUND THEN RAISE EXCEPTION 'Attempt connector must exist in its tenant at admission' USING ERRCODE='23514'; END IF;
    END IF;
    IF NEW.kind NOT IN ('late_evidence','conflicting_completion') AND NEW.agent_run_id IS NOT NULL THEN
      PERFORM 1 FROM public.agent_run r WHERE r.id=NEW.agent_run_id AND r."organizationId"=NEW.organization_id FOR KEY SHARE;
      IF NOT FOUND THEN RAISE EXCEPTION 'Attempt run must exist in its tenant at admission' USING ERRCODE='23514'; END IF;
    END IF;
  END IF;
  PERFORM actions.check_write_capture_shape(NEW);
  PERFORM composition.check_execution_attempt_owner(NEW);
  -- Evidence keeps the original fence; a later worker claim has no authority over it.
  IF NEW.kind IN ('late_evidence','conflicting_completion') THEN RETURN NEW; END IF;
  IF TG_OP='INSERT' AND EXISTS(SELECT 1 FROM actions.execution_attempt c WHERE c.organization_id=NEW.organization_id AND c.execution_id=NEW.execution_id AND c.kind='conflicting_completion') THEN
    RAISE EXCEPTION 'Unresolved capture conflict forbids new automatic interactions' USING ERRCODE='23514';
  END IF;
  IF e.phase<>'claimed' OR e.claim_token IS NULL OR e.claim_expires_at IS NULL THEN
    RAISE EXCEPTION 'Original attempt requires the execution claim' USING ERRCODE='23514';
  END IF;
  IF TG_OP='INSERT' THEN
    IF NEW.claim_generation<>e.claim_generation OR NEW.claim_token<>e.claim_token OR clock_timestamp()>=e.claim_expires_at THEN
      RAISE EXCEPTION 'Attempt admission fence must be current and unexpired' USING ERRCODE='23514';
    END IF;
    IF NEW.kind='write' THEN
      SELECT * INTO g FROM actions.resource_guard WHERE id=e.resource_guard_id FOR UPDATE;
      IF NOT FOUND OR g.holder_organization_id IS DISTINCT FROM e.organization_id OR g.holder_execution_id IS DISTINCT FROM e.id OR g.acquisition_generation IS DISTINCT FROM NEW.resource_guard_generation THEN
        RAISE EXCEPTION 'Write requires the exact held resource generation' USING ERRCODE='23514';
      END IF;
    END IF;
  ELSE
    IF NEW.finalized_claim_generation IS DISTINCT FROM e.claim_generation OR NEW.finalized_claim_token IS DISTINCT FROM e.claim_token
      OR (clock_timestamp()>=e.claim_expires_at AND NOT (NEW.result='uncertain' AND NEW.uncertainty_reason='claim_expired')) THEN
      RAISE EXCEPTION 'Attempt finalization requires the exact current fence' USING ERRCODE='23514';
    END IF;
    -- Expiry is database-only uncertainty, never a claim that the write failed.
    IF NEW.result='uncertain' AND NEW.uncertainty_reason='claim_expired' AND clock_timestamp()<e.claim_expires_at THEN
      RAISE EXCEPTION 'A live claim cannot be classified as expired' USING ERRCODE='23514';
    END IF;
  END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.check_attempt_commit() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE e actions.execution; a actions.execution_attempt;
BEGIN
  SELECT * INTO a FROM actions.execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.id;
  SELECT * INTO e FROM actions.execution WHERE organization_id=a.organization_id AND id=a.execution_id;
  PERFORM actions.assert_execution_graph(a.organization_id, a.execution_id);
  RETURN NULL;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION actions.guard_resource_identity() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Global resource identity cannot be deleted by runtime' USING ERRCODE='23514'; END IF;
  IF TG_OP='INSERT' THEN
    IF NEW.holder_execution_id IS NOT NULL OR NEW.acquisition_generation<>0 THEN
      RAISE EXCEPTION 'A resource identity starts unheld at generation zero' USING ERRCODE='23514';
    END IF;
  ELSE
    IF ROW(NEW.id,NEW.provider,NEW.resource_key,NEW.key_version) IS DISTINCT FROM ROW(OLD.id,OLD.provider,OLD.resource_key,OLD.key_version) THEN
      RAISE EXCEPTION 'Global resource identity is immutable' USING ERRCODE='23514';
    END IF;
    IF OLD.holder_execution_id IS NOT NULL AND NEW.holder_execution_id IS NULL AND EXISTS (
      SELECT 1 FROM actions.execution_attempt c WHERE c.organization_id=OLD.holder_organization_id
        AND c.execution_id=OLD.holder_execution_id AND c.kind='conflicting_completion'
    ) THEN RAISE EXCEPTION 'Unresolved capture conflict forbids resource release' USING ERRCODE='23514'; END IF;
    IF OLD.holder_execution_id IS NOT NULL AND NEW.holder_execution_id IS NULL AND EXISTS (
      SELECT 1 FROM actions.execution_attempt a
      WHERE a.organization_id=OLD.holder_organization_id AND a.execution_id=OLD.holder_execution_id
        AND a.kind IN ('write','readback','inspection','generation','manual_observation')
        AND (a.finished_at IS NULL OR (a.kind='write' AND NOT (
          a.result IS NOT DISTINCT FROM 'known_not_applied'
          AND a.non_application_basis IS NOT DISTINCT FROM 'pre_dispatch_failure')))
    ) THEN
      -- Narrow installed primitive: no effect was dispatched. Native finality,
      -- late evidence and cleanup must replace this with their full owner proof.
      RAISE EXCEPTION 'Resource release requires proved finality for every original interaction' USING ERRCODE='23514';
    END IF;
    IF OLD.holder_execution_id IS NULL AND NEW.holder_execution_id IS NOT NULL THEN
      IF NEW.acquisition_generation<>OLD.acquisition_generation+1 THEN RAISE EXCEPTION 'Resource acquisition requires next generation' USING ERRCODE='23514'; END IF;
    ELSIF NEW.acquisition_generation<>OLD.acquisition_generation THEN
      RAISE EXCEPTION 'Resource generation changes only on acquisition' USING ERRCODE='23514';
    END IF;
    IF OLD.holder_execution_id IS NOT NULL AND NEW.holder_execution_id IS NOT NULL
      AND ROW(NEW.holder_organization_id,NEW.holder_execution_id,NEW.acquired_at) IS DISTINCT FROM ROW(OLD.holder_organization_id,OLD.holder_execution_id,OLD.acquired_at) THEN
      RAISE EXCEPTION 'A held resource cannot change holder or acquisition time' USING ERRCODE='23514';
    END IF;
  END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.check_resource_holder() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE g actions.resource_guard;
BEGIN
  SELECT * INTO g FROM actions.resource_guard WHERE id=NEW.id;
  IF g.holder_execution_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM actions.execution e WHERE e.organization_id=g.holder_organization_id AND e.id=g.holder_execution_id AND e.resource_guard_id=g.id AND e.phase NOT IN ('settled','cancelled')) THEN
    RAISE EXCEPTION 'Resource holder must name this exact active execution guard' USING ERRCODE='23514';
  END IF;
  RETURN NULL;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.guard_recovery_cycle() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE planned actions.execution_step; subject actions.execution_attempt; predecessor actions.command;
BEGIN
  IF NEW.outcome <> 'accepted' OR NEW.cycle_purpose IS NULL THEN RETURN NEW; END IF;
  SELECT * INTO planned FROM actions.execution_step s
    WHERE s.organization_id=NEW.organization_id AND s.execution_id=NEW.progress_execution_id AND s.id=NEW.progress_step_id;
  IF NOT FOUND OR planned.operation_contract_id IS DISTINCT FROM NEW.cycle_contract_id THEN
    RAISE EXCEPTION 'Recovery cycle requires its exact scoped step and immutable contract' USING ERRCODE='23514';
  END IF;
  IF NEW.cycle_planned_step_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM actions.execution_step s WHERE s.organization_id=NEW.organization_id
      AND s.execution_id=NEW.progress_execution_id AND s.id=NEW.cycle_planned_step_id
  ) THEN
    RAISE EXCEPTION 'Prewrite cycle planned step must belong to its exact execution' USING ERRCODE='23514';
  END IF;
  IF NEW.progress_subject_attempt_id IS NOT NULL THEN
    SELECT * INTO subject FROM actions.execution_attempt a
      WHERE a.organization_id=NEW.organization_id AND a.execution_id=NEW.progress_execution_id
        AND a.step_id=NEW.progress_step_id AND a.id=NEW.progress_subject_attempt_id;
    IF NOT FOUND OR subject.kind<>'write' OR subject.finished_at IS NULL THEN
      RAISE EXCEPTION 'Readback or cleanup cycle requires its finished original write subject' USING ERRCODE='23514';
    END IF;
  END IF;
  IF NEW.cycle_predecessor_command_id IS NULL THEN
    IF NEW.kind <> 'open_recovery' OR NEW.cycle_anchor_at > NEW.accepted_at OR
      (NEW.cycle_purpose IN ('binding','prewrite') AND NEW.cycle_anchor_at IS DISTINCT FROM NEW.accepted_at) OR
      (NEW.cycle_purpose IN ('readback','cleanup') AND NEW.cycle_anchor_at IS DISTINCT FROM subject.finished_at) THEN
      RAISE EXCEPTION 'Initial recovery anchor must preserve its original admission or finalization' USING ERRCODE='23514';
    END IF;
  ELSE
    -- Requiring an already retained immutable predecessor forbids forward links
    -- and cycles. Partial successor uniqueness forbids concurrent branching.
    SELECT * INTO predecessor FROM actions.command c
      WHERE c.organization_id=NEW.organization_id AND c.id=NEW.cycle_predecessor_command_id;
    IF NOT FOUND OR predecessor.outcome<>'accepted' OR predecessor.cycle_purpose IS NULL OR
      ROW(NEW.progress_execution_id,NEW.progress_step_id,NEW.progress_subject_attempt_id,NEW.cycle_planned_step_id,NEW.cycle_purpose,NEW.cycle_contract_id,NEW.cycle_decisive_after_at)
      IS DISTINCT FROM ROW(predecessor.progress_execution_id,predecessor.progress_step_id,predecessor.progress_subject_attempt_id,predecessor.cycle_planned_step_id,predecessor.cycle_purpose,predecessor.cycle_contract_id,predecessor.cycle_decisive_after_at) THEN
      RAISE EXCEPTION 'Recovery replacement must retain the exact predecessor obligation and policy pins' USING ERRCODE='23514';
    END IF;
    IF NEW.cycle_anchor_at IS DISTINCT FROM NEW.accepted_at OR NEW.accepted_at < predecessor.accepted_at THEN
      RAISE EXCEPTION 'Recovery replacement anchors at its own acceptance after its predecessor' USING ERRCODE='23514';
    END IF;
  END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.check_recovery_cycle_commit() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE ticket_id text;
BEGIN
  IF NEW.outcome<>'accepted' OR NEW.cycle_purpose IS NULL THEN RETURN NULL; END IF;
  SELECT ap.action_id INTO ticket_id FROM actions.execution e JOIN actions.approval ap
    ON ap.organization_id=e.organization_id AND ap.id=e.approval_id
    WHERE e.organization_id=NEW.organization_id AND e.id=NEW.progress_execution_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Recovery history requires its exact execution approval and ticket' USING ERRCODE='23514'; END IF;
  IF NEW.kind<>'open_recovery' AND NOT EXISTS (
    SELECT 1 FROM actions.command_target t WHERE t.organization_id=NEW.organization_id AND t.command_id=NEW.id AND t.action_id=ticket_id
  ) THEN
    RAISE EXCEPTION 'Recovery replacement requires its exact ticket history target' USING ERRCODE='23514';
  END IF;
  IF NEW.kind='open_recovery' AND NEW.cycle_purpose IN ('binding','prewrite') AND NOT EXISTS (
    SELECT 1 FROM actions.execution_attempt a WHERE a.organization_id=NEW.organization_id
      AND a.execution_id=NEW.progress_execution_id AND a.step_id=NEW.progress_step_id
      AND a.cycle_command_id=NEW.id AND a.kind='inspection'
      AND a.inspection_purpose::text=NEW.cycle_purpose::text
      AND a.planned_write_step_id IS NOT DISTINCT FROM NEW.cycle_planned_step_id
      AND a.started_at=NEW.cycle_anchor_at
  ) THEN
    RAISE EXCEPTION 'Initial inspection cycle requires its atomic first admission at the anchor' USING ERRCODE='23514';
  END IF;
  RETURN NULL;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION app_store_connect.check_review_write_receipt(candidate actions.execution_attempt) RETURNS void LANGUAGE plpgsql AS $$
DECLARE c composition.operation_contract; r app_store_connect.attempt_receipt; target app_store_connect.review_target; content review_work.reply_content; head actions.revision;
BEGIN
  SELECT oc.* INTO c FROM actions.execution_step s JOIN composition.operation_contract oc ON oc.id=s.operation_contract_id
    WHERE s.organization_id=candidate.organization_id AND s.execution_id=candidate.execution_id AND s.id=candidate.step_id;
  IF NOT FOUND OR c.id IS DISTINCT FROM 'asc.review_response_upsert@1' OR c.provider IS DISTINCT FROM 'app_store_connect' OR c.operation_key IS DISTINCT FROM 'review_response_upsert' OR c.contract_version IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'ASC review receipt requires the exact immutable upsert definition' USING ERRCODE='23514';
  END IF;
  IF candidate.kind NOT IN ('write','late_evidence','conflicting_completion') THEN RAISE EXCEPTION 'ASC review receipt owner requires a write capture' USING ERRCODE='23514'; END IF;
  IF num_nonnulls(candidate.terminal_outcome,candidate.semantic_fingerprint,candidate.fingerprint_version,candidate.observation_revision_id,candidate.comparison_version,candidate.observation_surface,candidate.observation_completeness,candidate.output_kind,candidate.output_revision_id,candidate.output_review_analysis_id,candidate.output_agent_run_id,candidate.no_work_reason)>0 THEN
    RAISE EXCEPTION 'ASC write capture cannot carry readback or generation evidence' USING ERRCODE='23514';
  END IF;
  SELECT rev.* INTO head FROM actions.execution_step s JOIN actions.revision rev ON rev.organization_id=s.organization_id AND rev.id=s.content_revision_id
    WHERE s.organization_id=candidate.organization_id AND s.execution_id=candidate.execution_id AND s.id=candidate.step_id;
  SELECT * INTO target FROM app_store_connect.review_target WHERE organization_id=candidate.organization_id AND revision_id=head.id;
  SELECT * INTO content FROM review_work.reply_content WHERE organization_id=candidate.organization_id AND revision_id=head.id;
  IF head.id IS NULL OR NOT head.sealed OR head.kind<>'review_reply' OR head.purpose<>'proposal' OR target.review_resource_id IS NULL OR target.purpose<>'proposal' OR content.store IS DISTINCT FROM 'ios' THEN
    RAISE EXCEPTION 'ASC review receipt requires its exact sealed and bound review target' USING ERRCODE='23514';
  END IF;
  SELECT * INTO r FROM app_store_connect.attempt_receipt WHERE organization_id=candidate.organization_id AND attempt_id=candidate.id;
  IF candidate.finished_at IS NULL THEN
    IF r.attempt_id IS NOT NULL THEN RAISE EXCEPTION 'ASC receipt and attempt finalization must commit together' USING ERRCODE='23514'; END IF;
    RETURN;
  END IF;
  IF (candidate.result='known_not_applied' AND candidate.non_application_basis='pre_dispatch_failure') OR (candidate.result='uncertain' AND candidate.uncertainty_reason IN ('transport_lost','claim_expired')) THEN
    IF r.attempt_id IS NOT NULL THEN RAISE EXCEPTION 'Receipt is forbidden for receipt-free outcomes' USING ERRCODE='23514'; END IF;
    RETURN;
  END IF;
  IF r.attempt_id IS NULL OR r.transport<>'asc_api' THEN RAISE EXCEPTION 'ASC review completion requires its exact API receipt' USING ERRCODE='23514'; END IF;
  IF r.response_kind='accepted' THEN
    IF candidate.result IS DISTINCT FROM 'acknowledged' OR (r.response_body IS NOT NULL AND r.response_body IS DISTINCT FROM content.reply_text) THEN
      RAISE EXCEPTION 'Acknowledgement must retain the accepted exact review response' USING ERRCODE='23514';
    END IF;
  ELSIF r.response_kind='http_error' AND r.error_code IS NOT NULL AND r.response_status IN (400,401,403,409,422,429) THEN
    IF candidate.result IS DISTINCT FROM 'known_not_applied' OR candidate.non_application_basis IS DISTINCT FROM 'provider_rejection' OR candidate.retry_disposition IS NULL OR candidate.failure_class IS NULL THEN
      RAISE EXCEPTION 'ASC decoded rejection requires its neutral non-application shape' USING ERRCODE='23514';
    END IF;
  ELSIF r.response_kind IN ('http_error','invalid_response') THEN
    IF candidate.result IS DISTINCT FROM 'uncertain' OR candidate.uncertainty_reason IS DISTINCT FROM 'invalid_response' THEN
      RAISE EXCEPTION 'Unproved ASC response remains uncertain' USING ERRCODE='23514';
    END IF;
  ELSE RAISE EXCEPTION 'Receipt is not admitted by the ASC upsert operation' USING ERRCODE='23514';
  END IF;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION app_store_connect.guard_review_receipt() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE a actions.execution_attempt; parent_execution text;
BEGIN
  IF TG_OP<>'INSERT' THEN RAISE EXCEPTION 'ASC attempt receipts are immutable' USING ERRCODE='23514'; END IF;
  SELECT execution_id INTO parent_execution FROM actions.execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.attempt_id;
  -- A new finished evidence parent may be inserted later in this transaction.
  -- The deferred FK and receipt commit trigger require that exact scoped parent.
  IF parent_execution IS NULL THEN RETURN NEW; END IF;
  PERFORM 1 FROM actions.execution WHERE organization_id=NEW.organization_id AND id=parent_execution FOR UPDATE;
  SELECT * INTO a FROM actions.execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.attempt_id;
  IF NOT FOUND OR a.kind<>'write' OR a.finished_at IS NOT NULL THEN RAISE EXCEPTION 'ASC receipt cannot attach to finalized or non-write history' USING ERRCODE='23514'; END IF;
  -- At this instant the row is unfinished and no receipt has been inserted yet.
  PERFORM app_store_connect.check_review_write_receipt(a);
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE FUNCTION app_store_connect.check_review_receipt_commit() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE a actions.execution_attempt;
BEGIN
  SELECT * INTO a FROM actions.execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.attempt_id;
  IF NOT FOUND OR a.finished_at IS NULL THEN RAISE EXCEPTION 'ASC receipt requires atomic original finalization' USING ERRCODE='23514'; END IF;
  PERFORM app_store_connect.check_review_write_receipt(a);
  RETURN NULL;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.check_write_capture_shape(candidate actions.execution_attempt) RETURNS void LANGUAGE plpgsql AS $$
DECLARE original actions.execution_attempt;
BEGIN
  IF candidate.kind IN ('write','late_evidence','conflicting_completion') AND candidate.finished_at IS NOT NULL THEN
    IF (candidate.result='acknowledged' AND candidate.failure_class IS NOT NULL)
      OR (candidate.result='known_not_applied' AND candidate.failure_class IS NULL)
      OR (candidate.result='uncertain' AND candidate.uncertainty_reason IS DISTINCT FROM 'claim_expired' AND candidate.failure_class IS NULL)
      OR (candidate.result='uncertain' AND candidate.uncertainty_reason IS NOT DISTINCT FROM 'claim_expired' AND candidate.failure_class IS NOT NULL) THEN
      RAISE EXCEPTION 'Write outcome requires its closed failure-class shape' USING ERRCODE='23514';
    END IF;
  END IF;
  IF candidate.kind NOT IN ('late_evidence','conflicting_completion') THEN RETURN; END IF;
  SELECT * INTO original FROM actions.execution_attempt
    WHERE organization_id=candidate.organization_id AND execution_id=candidate.execution_id
      AND step_id=candidate.step_id AND id=candidate.subject_attempt_id;
  IF NOT FOUND OR original.kind<>'write' OR candidate.number<=original.number THEN
    RAISE EXCEPTION 'Write capture requires its exact earlier original write' USING ERRCODE='23514';
  END IF;
  IF ROW(candidate.claim_generation,candidate.claim_token,candidate.started_at,candidate.connector_id,
      candidate.agent_run_id,candidate.input_attempt_id,candidate.input_parent_revision_id,
      candidate.inspection_purpose,candidate.planned_write_step_id,candidate.prewrite_attempt_id,
      candidate.resource_guard_generation)
    IS DISTINCT FROM ROW(original.claim_generation,original.claim_token,original.started_at,original.connector_id,
      original.agent_run_id,original.input_attempt_id,original.input_parent_revision_id,
      original.inspection_purpose,original.planned_write_step_id,original.prewrite_attempt_id,
      original.resource_guard_generation) THEN
    RAISE EXCEPTION 'Write capture must preserve the complete original admission identity' USING ERRCODE='23514';
  END IF;
  IF candidate.finished_at IS NULL OR candidate.finished_at>candidate.recorded_at
    OR candidate.result IS NULL OR candidate.result NOT IN ('acknowledged','known_not_applied','uncertain')
    OR candidate.uncertainty_reason IS NOT DISTINCT FROM 'claim_expired'
    OR num_nonnulls(candidate.terminal_outcome,candidate.semantic_fingerprint,candidate.fingerprint_version,
      candidate.observation_revision_id,candidate.comparison_version,candidate.observation_surface,
      candidate.observation_completeness,candidate.output_kind,candidate.output_revision_id,
      candidate.output_review_analysis_id,candidate.output_agent_run_id,candidate.no_work_reason)>0 THEN
    RAISE EXCEPTION 'Write capture requires closed original write result fields and original completion time' USING ERRCODE='23514';
  END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION actions.check_attempt_completion_command() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE c actions.command; captured actions.execution_attempt; ticket_id text;
BEGIN
  IF TG_TABLE_NAME='command' THEN
    c:=NEW;
    IF c.kind<>'record_attempt' OR c.outcome<>'accepted' THEN RETURN NULL; END IF;
    SELECT * INTO captured FROM actions.execution_attempt WHERE organization_id=c.organization_id
      AND execution_id=c.progress_execution_id AND step_id=c.progress_step_id AND id=c.progress_subject_attempt_id;
  ELSE
    SELECT * INTO captured FROM actions.execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.id;
    IF captured.finished_at IS NULL THEN RETURN NULL; END IF;
    IF captured.kind IN ('late_evidence','conflicting_completion') THEN
      SELECT * INTO c FROM actions.command WHERE organization_id=captured.organization_id AND id=captured.evidence_command_id;
    ELSIF captured.kind IN ('write','readback','inspection','generation')
      AND NOT (captured.kind='write' AND captured.result='uncertain' AND captured.uncertainty_reason IS NOT DISTINCT FROM 'claim_expired') THEN
      SELECT * INTO c FROM actions.command WHERE organization_id=captured.organization_id
        AND kind='record_attempt' AND outcome='accepted' AND progress_subject_attempt_id=captured.id;
    ELSE RETURN NULL;
    END IF;
  END IF;
  IF captured.id IS NULL OR captured.finished_at IS NULL OR c.id IS NULL
    OR c.kind<>'record_attempt' OR c.outcome<>'accepted' OR c.principal_kind<>'system' OR c.channel<>'worker'
    OR c.progress_execution_id IS DISTINCT FROM captured.execution_id
    OR c.progress_step_id IS DISTINCT FROM captured.step_id
    OR c.progress_subject_attempt_id IS DISTINCT FROM captured.id
    OR c.accepted_at<captured.finished_at
    OR (captured.kind IN ('late_evidence','conflicting_completion') AND captured.evidence_command_id IS DISTINCT FROM c.id) THEN
    RAISE EXCEPTION 'Captured completion requires its exact accepted system command' USING ERRCODE='23514';
  END IF;
  SELECT ap.action_id INTO ticket_id FROM actions.execution e JOIN actions.approval ap
    ON ap.organization_id=e.organization_id AND ap.id=e.approval_id
    WHERE e.organization_id=captured.organization_id AND e.id=captured.execution_id;
  IF NOT EXISTS(SELECT 1 FROM actions.command_target t WHERE t.organization_id=c.organization_id
    AND t.command_id=c.id AND t.action_id=ticket_id) OR EXISTS(SELECT 1 FROM actions.command_target t
    WHERE t.organization_id=c.organization_id AND t.command_id=c.id AND t.action_id<>ticket_id) THEN
    RAISE EXCEPTION 'Captured completion history must target its exact approved ticket' USING ERRCODE='23514';
  END IF;
  PERFORM composition.check_execution_attempt_owner(captured);
  RETURN NULL;
END $$;
--> statement-breakpoint
CREATE TRIGGER command_immutable BEFORE UPDATE OR DELETE ON actions.command FOR EACH ROW EXECUTE FUNCTION actions.reject_fact_mutation();
--> statement-breakpoint
CREATE TRIGGER command_target_immutable BEFORE UPDATE OR DELETE ON actions.command_target FOR EACH ROW EXECUTE FUNCTION actions.reject_fact_mutation();
--> statement-breakpoint
CREATE TRIGGER approval_immutable BEFORE UPDATE OR DELETE ON actions.approval FOR EACH ROW EXECUTE FUNCTION actions.reject_fact_mutation();
--> statement-breakpoint
CREATE TRIGGER alias_immutable BEFORE UPDATE OR DELETE ON actions.alias FOR EACH ROW EXECUTE FUNCTION actions.reject_fact_mutation();
--> statement-breakpoint
CREATE TRIGGER dependency_immutable BEFORE UPDATE OR DELETE ON actions.dependency FOR EACH ROW EXECUTE FUNCTION actions.reject_fact_mutation();
--> statement-breakpoint
CREATE TRIGGER revision_guard BEFORE INSERT OR UPDATE OR DELETE ON actions.revision FOR EACH ROW EXECUTE FUNCTION actions.guard_revision();
--> statement-breakpoint
CREATE TRIGGER attention_content_guard BEFORE INSERT OR UPDATE OR DELETE ON agent_work.attention_advisory FOR EACH ROW EXECUTE FUNCTION actions.guard_content();
--> statement-breakpoint
CREATE TRIGGER membership_guard BEFORE INSERT OR UPDATE OR DELETE ON actions.membership FOR EACH ROW EXECUTE FUNCTION actions.guard_membership();
--> statement-breakpoint
CREATE TRIGGER action_identity_guard BEFORE INSERT OR UPDATE OR DELETE ON actions.action FOR EACH ROW EXECUTE FUNCTION actions.guard_action_identity();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER action_committed_guard AFTER INSERT OR UPDATE ON actions.action DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.check_committed_action();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER approval_revision_guard AFTER INSERT ON actions.approval DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.check_approval_revision();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER revision_committed_guard AFTER INSERT OR UPDATE ON actions.revision DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.check_committed_revision();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER command_targets_guard AFTER INSERT ON actions.command DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.check_command_targets();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER target_snapshot_guard AFTER INSERT ON actions.command_target DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.check_target_snapshot();
--> statement-breakpoint
CREATE TRIGGER command_actor_admission BEFORE INSERT ON actions.command FOR EACH ROW EXECUTE FUNCTION actions.check_actor_admission();
--> statement-breakpoint
CREATE TRIGGER attention_source_admission BEFORE INSERT OR UPDATE ON agent_work.attention_advisory FOR EACH ROW EXECUTE FUNCTION agent_work.check_attention_source_admission();
--> statement-breakpoint
CREATE TRIGGER operation_definition_immutable BEFORE UPDATE OR DELETE ON composition.operation_contract FOR EACH ROW EXECUTE FUNCTION actions.reject_fact_mutation();
--> statement-breakpoint
CREATE TRIGGER review_reply_content_guard BEFORE INSERT OR UPDATE OR DELETE ON review_work.reply_content FOR EACH ROW EXECUTE FUNCTION actions.guard_content();
--> statement-breakpoint
CREATE TRIGGER review_reply_owner_guard BEFORE INSERT OR UPDATE OR DELETE ON review_work.reply_content FOR EACH ROW EXECUTE FUNCTION review_work.guard_review_owner();
--> statement-breakpoint
CREATE TRIGGER asc_review_content_guard BEFORE INSERT OR UPDATE OR DELETE ON app_store_connect.review_target FOR EACH ROW EXECUTE FUNCTION actions.guard_content();
--> statement-breakpoint
CREATE TRIGGER asc_review_owner_guard BEFORE INSERT OR UPDATE OR DELETE ON app_store_connect.review_target FOR EACH ROW EXECUTE FUNCTION review_work.guard_review_owner();
--> statement-breakpoint
CREATE TRIGGER play_review_content_guard BEFORE INSERT OR UPDATE OR DELETE ON google_play.review_target FOR EACH ROW EXECUTE FUNCTION actions.guard_content();
--> statement-breakpoint
CREATE TRIGGER play_review_owner_guard BEFORE INSERT OR UPDATE OR DELETE ON google_play.review_target FOR EACH ROW EXECUTE FUNCTION review_work.guard_review_owner();
--> statement-breakpoint
CREATE TRIGGER execution_structure BEFORE INSERT OR UPDATE OR DELETE ON actions.execution FOR EACH ROW EXECUTE FUNCTION actions.guard_execution_structure();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER execution_graph AFTER INSERT OR UPDATE ON actions.execution DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.check_execution_graph();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER action_execution_graph AFTER INSERT OR UPDATE ON actions.action DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.check_action_execution_graph();
--> statement-breakpoint
CREATE TRIGGER execution_step_structure BEFORE INSERT OR UPDATE OR DELETE ON actions.execution_step FOR EACH ROW EXECUTE FUNCTION actions.guard_execution_step();
--> statement-breakpoint
CREATE TRIGGER execution_attempt_structure BEFORE INSERT OR UPDATE OR DELETE ON actions.execution_attempt FOR EACH ROW EXECUTE FUNCTION actions.guard_execution_attempt();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER execution_attempt_commit AFTER INSERT OR UPDATE ON actions.execution_attempt DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.check_attempt_commit();
--> statement-breakpoint
CREATE TRIGGER resource_guard_structure BEFORE INSERT OR UPDATE OR DELETE ON actions.resource_guard FOR EACH ROW EXECUTE FUNCTION actions.guard_resource_identity();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER resource_guard_holder AFTER INSERT OR UPDATE ON actions.resource_guard DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.check_resource_holder();
--> statement-breakpoint
CREATE TRIGGER command_recovery_cycle BEFORE INSERT ON actions.command FOR EACH ROW EXECUTE FUNCTION actions.guard_recovery_cycle();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER command_recovery_cycle_commit AFTER INSERT ON actions.command
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.check_recovery_cycle_commit();
--> statement-breakpoint
CREATE TRIGGER asc_review_receipt_structure BEFORE INSERT OR UPDATE OR DELETE ON app_store_connect.attempt_receipt FOR EACH ROW EXECUTE FUNCTION app_store_connect.guard_review_receipt();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER asc_review_receipt_commit AFTER INSERT ON app_store_connect.attempt_receipt DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION app_store_connect.check_review_receipt_commit();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER command_attempt_completion_commit AFTER INSERT ON actions.command
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.check_attempt_completion_command();
--> statement-breakpoint
CREATE CONSTRAINT TRIGGER attempt_completion_command_commit AFTER INSERT OR UPDATE ON actions.execution_attempt
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions.check_attempt_completion_command();
--> statement-breakpoint
INSERT INTO composition.operation_contract
  (id, provider, operation_key, contract_version, expansion, default_required_surface,
   default_verification_timing, terminal_on_acknowledgement, resource_scope_kind,
   max_observations, observation_window_ms, backoff_initial_ms, backoff_max_ms, backoff_factor)
VALUES ('asc.review_response_upsert@1', 'app_store_connect', 'review_response_upsert', 1,
  'ordinary', 'review_response', 'after_effects', true, 'store_application',
  6, 604800000, 3600000, 86400000, 2);

--> statement-breakpoint
-- Drizzle 0.45 cannot represent partial NULLS NOT DISTINCT indexes. Keep this
-- exact predicate: refused openers and ordinary commands consume no identity.
CREATE UNIQUE INDEX execution_initial_cycle
ON actions.command (organization_id,progress_execution_id,progress_step_id,
  progress_subject_attempt_id,cycle_planned_step_id,cycle_purpose)
NULLS NOT DISTINCT
WHERE kind='open_recovery' AND outcome='accepted' AND cycle_predecessor_command_id IS NULL;

-- 0156_rainy_naoko.sql
CREATE SCHEMA "listing_work";
--> statement-breakpoint
CREATE TYPE "listing_work"."field_state" AS ENUM('unspecified', 'present', 'empty', 'dismissed', 'unreadable');--> statement-breakpoint
CREATE TYPE "listing_work"."intent" AS ENUM('create', 'update', 'repair', 'restore');--> statement-breakpoint
CREATE TYPE "listing_work"."store" AS ENUM('ios', 'android');--> statement-breakpoint
CREATE TYPE "app_store_connect"."listing_native_state" AS ENUM('PREPARE_FOR_SUBMISSION', 'DEVELOPER_REJECTED', 'REJECTED', 'METADATA_REJECTED', 'WAITING_FOR_REVIEW', 'READY_FOR_SALE', 'READY_FOR_DISTRIBUTION');--> statement-breakpoint
CREATE TYPE "app_store_connect"."listing_native_state_kind" AS ENUM('known', 'unreadable', 'not_observed');--> statement-breakpoint
CREATE TYPE "app_store_connect"."listing_release_selection" AS ENUM('exact_release', 'next_editable_release');--> statement-breakpoint
CREATE TYPE "app_store_connect"."listing_resource_availability" AS ENUM('unspecified', 'present', 'absent', 'unreadable');--> statement-breakpoint
CREATE TYPE "app_store_connect"."listing_resource_operation" AS ENUM('omit', 'create', 'update');--> statement-breakpoint
ALTER TYPE "app_store_connect"."review_credential_kind" RENAME TO "credential_kind";--> statement-breakpoint
CREATE TABLE "listing_work"."listing_content" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"purpose" "actions"."revision_purpose" NOT NULL,
	"store" "listing_work"."store" NOT NULL,
	"locale" text NOT NULL,
	"intent" "listing_work"."intent",
	"title_state" "listing_work"."field_state" NOT NULL,
	"title" text,
	"description_state" "listing_work"."field_state" NOT NULL,
	"description" text,
	"support_url_state" "listing_work"."field_state" NOT NULL,
	"support_url" text,
	"operator_instructions" text,
	"keyword_analysis" text,
	"source_fingerprint" text,
	"captured_at" timestamp with time zone,
	"source_capture_at" timestamp with time zone,
	CONSTRAINT "listing_content_organization_id_revision_id_pk" PRIMARY KEY("organization_id","revision_id"),
	CONSTRAINT "listing_content_purpose" CHECK ("listing_work"."listing_content"."purpose" IN ('proposal','baseline','observation')),
	CONSTRAINT "listing_content_locale" CHECK ((
    ("listing_work"."listing_content"."store" = 'ios' AND "listing_work"."listing_content"."locale" IN ('ar-SA', 'bn-BD', 'ca', 'zh-Hans', 'zh-Hant', 'hr', 'cs', 'da', 'nl-NL', 'en-AU', 'en-CA', 'en-GB', 'en-US', 'fi', 'fr-FR', 'fr-CA', 'de-DE', 'el', 'gu-IN', 'he', 'hi', 'hu', 'id', 'it', 'ja', 'kn-IN', 'ko', 'ms', 'ml-IN', 'mr-IN', 'no', 'or-IN', 'pl', 'pt-BR', 'pt-PT', 'pa-IN', 'ro', 'ru', 'sk', 'sl-SI', 'es-MX', 'es-ES', 'sv', 'ta-IN', 'te-IN', 'th', 'tr', 'uk', 'ur-PK', 'vi'))
    OR ("listing_work"."listing_content"."store" = 'android' AND "listing_work"."listing_content"."locale" IN ('af', 'am', 'ar', 'az-AZ', 'be', 'bg', 'bn-BD', 'ca', 'cs-CZ', 'da-DK', 'de-DE', 'el-GR', 'en-AU', 'en-CA', 'en-GB', 'en-IN', 'en-SG', 'en-US', 'en-ZA', 'es-419', 'es-ES', 'es-US', 'et', 'eu-ES', 'fa', 'fi-FI', 'fil', 'fr-CA', 'fr-FR', 'gl-ES', 'gu', 'hi-IN', 'hr', 'hu-HU', 'hy-AM', 'id', 'is-IS', 'it-IT', 'iw-IL', 'ja-JP', 'ka-GE', 'kk', 'km-KH', 'kn-IN', 'ko-KR', 'ky-KG', 'lo-LA', 'lt', 'lv', 'mk-MK', 'ml-IN', 'mn-MN', 'mr-IN', 'ms', 'ms-MY', 'my-MM', 'nb-NO', 'ne-NP', 'nl-NL', 'no-NO', 'pa', 'pl-PL', 'pt-BR', 'pt-PT', 'ro', 'ru-RU', 'si-LK', 'sk', 'sl', 'sq', 'sr', 'sv-SE', 'sw', 'ta-IN', 'te-IN', 'th', 'tr-TR', 'uk', 'ur', 'vi', 'zh-CN', 'zh-HK', 'zh-TW', 'zu'))
  ) IS TRUE),
	CONSTRAINT "listing_content_purpose_shape" CHECK ((CASE WHEN "listing_work"."listing_content"."purpose" = 'proposal'
    THEN "listing_work"."listing_content"."intent" IS NOT NULL AND "listing_work"."listing_content"."captured_at" IS NULL AND "listing_work"."listing_content"."source_capture_at" IS NULL
    ELSE "listing_work"."listing_content"."intent" IS NULL AND "listing_work"."listing_content"."operator_instructions" IS NULL AND "listing_work"."listing_content"."keyword_analysis" IS NULL
      AND "listing_work"."listing_content"."source_fingerprint" IS NULL AND "listing_work"."listing_content"."captured_at" IS NOT NULL
    END) IS TRUE),
	CONSTRAINT "listing_content_fingerprint" CHECK ("listing_work"."listing_content"."source_fingerprint" IS NULL OR length("listing_work"."listing_content"."source_fingerprint") > 0),
	CONSTRAINT "listing_title_shape" CHECK ((CASE "listing_work"."listing_content"."title_state"
    WHEN 'unspecified' THEN "listing_work"."listing_content"."title" IS NULL
    WHEN 'present' THEN "listing_work"."listing_content"."title" IS NOT NULL AND length("listing_work"."listing_content"."title") > 0
    WHEN 'empty' THEN "listing_work"."listing_content"."title" IS NOT NULL AND "listing_work"."listing_content"."title" = ''
    WHEN 'dismissed' THEN "listing_work"."listing_content"."purpose" = 'proposal' AND "listing_work"."listing_content"."title" IS NOT NULL
    WHEN 'unreadable' THEN "listing_work"."listing_content"."purpose" IN ('baseline','observation') AND "listing_work"."listing_content"."title" IS NULL
    ELSE false END) IS TRUE),
	CONSTRAINT "listing_description_shape" CHECK ((CASE "listing_work"."listing_content"."description_state"
    WHEN 'unspecified' THEN "listing_work"."listing_content"."description" IS NULL
    WHEN 'present' THEN "listing_work"."listing_content"."description" IS NOT NULL AND length("listing_work"."listing_content"."description") > 0
    WHEN 'empty' THEN "listing_work"."listing_content"."description" IS NOT NULL AND "listing_work"."listing_content"."description" = ''
    WHEN 'dismissed' THEN "listing_work"."listing_content"."purpose" = 'proposal' AND "listing_work"."listing_content"."description" IS NOT NULL
    WHEN 'unreadable' THEN "listing_work"."listing_content"."purpose" IN ('baseline','observation') AND "listing_work"."listing_content"."description" IS NULL
    ELSE false END) IS TRUE),
	CONSTRAINT "listing_support_url_shape" CHECK ((CASE "listing_work"."listing_content"."support_url_state"
    WHEN 'unspecified' THEN "listing_work"."listing_content"."support_url" IS NULL
    WHEN 'present' THEN "listing_work"."listing_content"."support_url" IS NOT NULL AND length("listing_work"."listing_content"."support_url") > 0
    WHEN 'empty' THEN "listing_work"."listing_content"."support_url" IS NOT NULL AND "listing_work"."listing_content"."support_url" = ''
    WHEN 'dismissed' THEN "listing_work"."listing_content"."purpose" = 'proposal' AND "listing_work"."listing_content"."support_url" IS NOT NULL
    WHEN 'unreadable' THEN "listing_work"."listing_content"."purpose" IN ('baseline','observation') AND "listing_work"."listing_content"."support_url" IS NULL
    ELSE false END) IS TRUE),
	CONSTRAINT "listing_content_instant_range" CHECK (("listing_work"."listing_content"."captured_at" IS NULL OR "listing_work"."listing_content"."captured_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz) AND ("listing_work"."listing_content"."source_capture_at" IS NULL OR "listing_work"."listing_content"."source_capture_at" BETWEEN '0001-01-01T00:00:00Z'::timestamptz AND '9999-12-31T23:59:59.999999Z'::timestamptz))
);
--> statement-breakpoint
ALTER TABLE "listing_work"."listing_content" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "app_store_connect"."listing_content" (
	"organization_id" text NOT NULL,
	"revision_id" text NOT NULL,
	"purpose" "actions"."revision_purpose" NOT NULL,
	"source_asset_data_source_id" text NOT NULL,
	"source_connector_id" text NOT NULL,
	"credential_kind" "app_store_connect"."credential_kind" NOT NULL,
	"credential_key_id" text NOT NULL,
	"credential_team_issuer_id" text,
	"provider_app_id" text NOT NULL,
	"release_selection" "app_store_connect"."listing_release_selection",
	"app_info_operation" "app_store_connect"."listing_resource_operation",
	"app_info_availability" "app_store_connect"."listing_resource_availability",
	"app_info_id" text,
	"app_info_localization_id" text,
	"app_info_native_state_kind" "app_store_connect"."listing_native_state_kind",
	"app_info_native_state" "app_store_connect"."listing_native_state",
	"version_operation" "app_store_connect"."listing_resource_operation",
	"version_availability" "app_store_connect"."listing_resource_availability",
	"app_version_id" text,
	"app_version_localization_id" text,
	"version_native_state_kind" "app_store_connect"."listing_native_state_kind",
	"version_native_state" "app_store_connect"."listing_native_state",
	"live_promotional_operation" "app_store_connect"."listing_resource_operation",
	"live_promotional_availability" "app_store_connect"."listing_resource_availability",
	"live_promotional_version_id" text,
	"live_promotional_localization_id" text,
	"live_promotional_native_state_kind" "app_store_connect"."listing_native_state_kind",
	"live_promotional_native_state" "app_store_connect"."listing_native_state",
	"subtitle_state" "listing_work"."field_state" NOT NULL,
	"subtitle" text,
	"keywords_state" "listing_work"."field_state" NOT NULL,
	"keywords" text,
	"promotional_text_state" "listing_work"."field_state" NOT NULL,
	"promotional_text" text,
	"whats_new_state" "listing_work"."field_state" NOT NULL,
	"whats_new" text,
	"live_promotional_text_state" "listing_work"."field_state" NOT NULL,
	"live_promotional_text" text,
	CONSTRAINT "listing_content_organization_id_revision_id_pk" PRIMARY KEY("organization_id","revision_id"),
	CONSTRAINT "asc_listing_purpose" CHECK ("app_store_connect"."listing_content"."purpose" IN ('proposal','baseline','observation')),
	CONSTRAINT "asc_listing_identity" CHECK (length("app_store_connect"."listing_content"."source_asset_data_source_id") > 0 AND length("app_store_connect"."listing_content"."source_connector_id") > 0 AND length("app_store_connect"."listing_content"."credential_key_id") > 0 AND length("app_store_connect"."listing_content"."provider_app_id") > 0 AND ("app_store_connect"."listing_content"."app_info_id" IS NULL OR length("app_store_connect"."listing_content"."app_info_id") > 0) AND ("app_store_connect"."listing_content"."app_info_localization_id" IS NULL OR length("app_store_connect"."listing_content"."app_info_localization_id") > 0) AND ("app_store_connect"."listing_content"."app_version_id" IS NULL OR length("app_store_connect"."listing_content"."app_version_id") > 0) AND ("app_store_connect"."listing_content"."app_version_localization_id" IS NULL OR length("app_store_connect"."listing_content"."app_version_localization_id") > 0) AND ("app_store_connect"."listing_content"."live_promotional_version_id" IS NULL OR length("app_store_connect"."listing_content"."live_promotional_version_id") > 0) AND ("app_store_connect"."listing_content"."live_promotional_localization_id" IS NULL OR length("app_store_connect"."listing_content"."live_promotional_localization_id") > 0)),
	CONSTRAINT "asc_listing_credential_shape" CHECK (("app_store_connect"."listing_content"."credential_kind" = 'individual' AND "app_store_connect"."listing_content"."credential_team_issuer_id" IS NULL) OR ("app_store_connect"."listing_content"."credential_kind" = 'team' AND "app_store_connect"."listing_content"."credential_team_issuer_id" IS NOT NULL AND length("app_store_connect"."listing_content"."credential_team_issuer_id") > 0)),
	CONSTRAINT "asc_listing_release_shape" CHECK (("app_store_connect"."listing_content"."purpose" = 'proposal') = ("app_store_connect"."listing_content"."release_selection" IS NOT NULL)),
	CONSTRAINT "asc_listing_app_info_shape" CHECK ((CASE WHEN "app_store_connect"."listing_content"."purpose" = 'proposal' THEN
    "app_store_connect"."listing_content"."app_info_availability" IS NULL AND "app_store_connect"."listing_content"."app_info_native_state_kind" IS NULL AND "app_store_connect"."listing_content"."app_info_native_state" IS NULL AND
    CASE "app_store_connect"."listing_content"."release_selection"
      WHEN 'next_editable_release' THEN "app_store_connect"."listing_content"."app_info_operation" IS NULL AND "app_store_connect"."listing_content"."app_info_id" IS NULL AND "app_store_connect"."listing_content"."app_info_localization_id" IS NULL
      WHEN 'exact_release' THEN CASE "app_store_connect"."listing_content"."app_info_operation"
        WHEN 'omit' THEN "app_store_connect"."listing_content"."app_info_id" IS NULL AND "app_store_connect"."listing_content"."app_info_localization_id" IS NULL
        WHEN 'create' THEN true AND "app_store_connect"."listing_content"."app_info_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_info_localization_id" IS NULL
        WHEN 'update' THEN "app_store_connect"."listing_content"."app_info_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_info_localization_id" IS NOT NULL
        ELSE false END
      ELSE false END
    ELSE "app_store_connect"."listing_content"."app_info_operation" IS NULL AND CASE "app_store_connect"."listing_content"."app_info_availability"
      WHEN 'unspecified' THEN num_nonnulls("app_store_connect"."listing_content"."app_info_id","app_store_connect"."listing_content"."app_info_localization_id","app_store_connect"."listing_content"."app_info_native_state_kind","app_store_connect"."listing_content"."app_info_native_state") = 0
      WHEN 'present' THEN "app_store_connect"."listing_content"."app_info_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_info_localization_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_info_native_state_kind" IS NOT NULL
      WHEN 'absent' THEN "app_store_connect"."listing_content"."app_info_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_info_localization_id" IS NULL AND "app_store_connect"."listing_content"."app_info_native_state_kind" IS NOT NULL
      WHEN 'unreadable' THEN "app_store_connect"."listing_content"."app_info_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_info_native_state_kind" IS NOT NULL
      ELSE false END
    END) IS TRUE),
	CONSTRAINT "asc_listing_version_shape" CHECK ((CASE WHEN "app_store_connect"."listing_content"."purpose" = 'proposal' THEN
    "app_store_connect"."listing_content"."version_availability" IS NULL AND "app_store_connect"."listing_content"."version_native_state_kind" IS NULL AND "app_store_connect"."listing_content"."version_native_state" IS NULL AND
    CASE "app_store_connect"."listing_content"."release_selection"
      WHEN 'next_editable_release' THEN "app_store_connect"."listing_content"."version_operation" IS NULL AND "app_store_connect"."listing_content"."app_version_id" IS NULL AND "app_store_connect"."listing_content"."app_version_localization_id" IS NULL
      WHEN 'exact_release' THEN CASE "app_store_connect"."listing_content"."version_operation"
        WHEN 'omit' THEN "app_store_connect"."listing_content"."app_version_id" IS NULL AND "app_store_connect"."listing_content"."app_version_localization_id" IS NULL
        WHEN 'create' THEN true AND "app_store_connect"."listing_content"."app_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_version_localization_id" IS NULL
        WHEN 'update' THEN "app_store_connect"."listing_content"."app_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_version_localization_id" IS NOT NULL
        ELSE false END
      ELSE false END
    ELSE "app_store_connect"."listing_content"."version_operation" IS NULL AND CASE "app_store_connect"."listing_content"."version_availability"
      WHEN 'unspecified' THEN num_nonnulls("app_store_connect"."listing_content"."app_version_id","app_store_connect"."listing_content"."app_version_localization_id","app_store_connect"."listing_content"."version_native_state_kind","app_store_connect"."listing_content"."version_native_state") = 0
      WHEN 'present' THEN "app_store_connect"."listing_content"."app_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_version_localization_id" IS NOT NULL AND "app_store_connect"."listing_content"."version_native_state_kind" IS NOT NULL
      WHEN 'absent' THEN "app_store_connect"."listing_content"."app_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_version_localization_id" IS NULL AND "app_store_connect"."listing_content"."version_native_state_kind" IS NOT NULL
      WHEN 'unreadable' THEN "app_store_connect"."listing_content"."app_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."version_native_state_kind" IS NOT NULL
      ELSE false END
    END) IS TRUE),
	CONSTRAINT "asc_listing_live_promo_shape" CHECK ((CASE WHEN "app_store_connect"."listing_content"."purpose" = 'proposal' THEN
    "app_store_connect"."listing_content"."live_promotional_availability" IS NULL AND "app_store_connect"."listing_content"."live_promotional_native_state_kind" IS NULL AND "app_store_connect"."listing_content"."live_promotional_native_state" IS NULL AND
    CASE "app_store_connect"."listing_content"."release_selection"
      WHEN 'next_editable_release' THEN "app_store_connect"."listing_content"."live_promotional_operation" IS NULL AND "app_store_connect"."listing_content"."live_promotional_version_id" IS NULL AND "app_store_connect"."listing_content"."live_promotional_localization_id" IS NULL
      WHEN 'exact_release' THEN CASE "app_store_connect"."listing_content"."live_promotional_operation"
        WHEN 'omit' THEN "app_store_connect"."listing_content"."live_promotional_version_id" IS NULL AND "app_store_connect"."listing_content"."live_promotional_localization_id" IS NULL
        WHEN 'create' THEN false AND "app_store_connect"."listing_content"."live_promotional_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."live_promotional_localization_id" IS NULL
        WHEN 'update' THEN "app_store_connect"."listing_content"."live_promotional_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."live_promotional_localization_id" IS NOT NULL
        ELSE false END
      ELSE false END
    ELSE "app_store_connect"."listing_content"."live_promotional_operation" IS NULL AND CASE "app_store_connect"."listing_content"."live_promotional_availability"
      WHEN 'unspecified' THEN num_nonnulls("app_store_connect"."listing_content"."live_promotional_version_id","app_store_connect"."listing_content"."live_promotional_localization_id","app_store_connect"."listing_content"."live_promotional_native_state_kind","app_store_connect"."listing_content"."live_promotional_native_state") = 0
      WHEN 'present' THEN "app_store_connect"."listing_content"."live_promotional_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."live_promotional_localization_id" IS NOT NULL AND "app_store_connect"."listing_content"."live_promotional_native_state_kind" IS NOT NULL
      WHEN 'absent' THEN "app_store_connect"."listing_content"."live_promotional_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."live_promotional_localization_id" IS NULL AND "app_store_connect"."listing_content"."live_promotional_native_state_kind" IS NOT NULL
      WHEN 'unreadable' THEN "app_store_connect"."listing_content"."live_promotional_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."live_promotional_native_state_kind" IS NOT NULL
      ELSE false END
    END) IS TRUE),
	CONSTRAINT "asc_listing_app_info_state" CHECK ((CASE
    WHEN "app_store_connect"."listing_content"."app_info_native_state_kind" = 'known' THEN "app_store_connect"."listing_content"."app_info_native_state" IS NOT NULL
    ELSE "app_store_connect"."listing_content"."app_info_native_state" IS NULL END) IS TRUE),
	CONSTRAINT "asc_listing_version_state" CHECK ((CASE
    WHEN "app_store_connect"."listing_content"."version_native_state_kind" = 'known' THEN "app_store_connect"."listing_content"."version_native_state" IS NOT NULL
    ELSE "app_store_connect"."listing_content"."version_native_state" IS NULL END) IS TRUE),
	CONSTRAINT "asc_listing_live_promo_state" CHECK ((CASE
    WHEN "app_store_connect"."listing_content"."live_promotional_native_state_kind" = 'known' THEN "app_store_connect"."listing_content"."live_promotional_native_state" IS NOT NULL
    ELSE "app_store_connect"."listing_content"."live_promotional_native_state" IS NULL END) IS TRUE),
	CONSTRAINT "asc_listing_subtitle_shape" CHECK ((CASE "app_store_connect"."listing_content"."subtitle_state"
    WHEN 'unspecified' THEN "app_store_connect"."listing_content"."subtitle" IS NULL
    WHEN 'present' THEN "app_store_connect"."listing_content"."subtitle" IS NOT NULL AND length("app_store_connect"."listing_content"."subtitle") > 0
    WHEN 'empty' THEN "app_store_connect"."listing_content"."subtitle" IS NOT NULL AND "app_store_connect"."listing_content"."subtitle" = ''
    WHEN 'dismissed' THEN "app_store_connect"."listing_content"."purpose" = 'proposal' AND "app_store_connect"."listing_content"."subtitle" IS NOT NULL
    WHEN 'unreadable' THEN "app_store_connect"."listing_content"."purpose" IN ('baseline','observation') AND "app_store_connect"."listing_content"."subtitle" IS NULL
    ELSE false END) IS TRUE),
	CONSTRAINT "asc_listing_keywords_shape" CHECK ((CASE "app_store_connect"."listing_content"."keywords_state"
    WHEN 'unspecified' THEN "app_store_connect"."listing_content"."keywords" IS NULL
    WHEN 'present' THEN "app_store_connect"."listing_content"."keywords" IS NOT NULL AND length("app_store_connect"."listing_content"."keywords") > 0
    WHEN 'empty' THEN "app_store_connect"."listing_content"."keywords" IS NOT NULL AND "app_store_connect"."listing_content"."keywords" = ''
    WHEN 'dismissed' THEN "app_store_connect"."listing_content"."purpose" = 'proposal' AND "app_store_connect"."listing_content"."keywords" IS NOT NULL
    WHEN 'unreadable' THEN "app_store_connect"."listing_content"."purpose" IN ('baseline','observation') AND "app_store_connect"."listing_content"."keywords" IS NULL
    ELSE false END) IS TRUE),
	CONSTRAINT "asc_listing_promo_text_shape" CHECK ((CASE "app_store_connect"."listing_content"."promotional_text_state"
    WHEN 'unspecified' THEN "app_store_connect"."listing_content"."promotional_text" IS NULL
    WHEN 'present' THEN "app_store_connect"."listing_content"."promotional_text" IS NOT NULL AND length("app_store_connect"."listing_content"."promotional_text") > 0
    WHEN 'empty' THEN "app_store_connect"."listing_content"."promotional_text" IS NOT NULL AND "app_store_connect"."listing_content"."promotional_text" = ''
    WHEN 'dismissed' THEN "app_store_connect"."listing_content"."purpose" = 'proposal' AND "app_store_connect"."listing_content"."promotional_text" IS NOT NULL
    WHEN 'unreadable' THEN "app_store_connect"."listing_content"."purpose" IN ('baseline','observation') AND "app_store_connect"."listing_content"."promotional_text" IS NULL
    ELSE false END) IS TRUE),
	CONSTRAINT "asc_listing_whats_new_shape" CHECK ((CASE "app_store_connect"."listing_content"."whats_new_state"
    WHEN 'unspecified' THEN "app_store_connect"."listing_content"."whats_new" IS NULL
    WHEN 'present' THEN "app_store_connect"."listing_content"."whats_new" IS NOT NULL AND length("app_store_connect"."listing_content"."whats_new") > 0
    WHEN 'empty' THEN "app_store_connect"."listing_content"."whats_new" IS NOT NULL AND "app_store_connect"."listing_content"."whats_new" = ''
    WHEN 'dismissed' THEN "app_store_connect"."listing_content"."purpose" = 'proposal' AND "app_store_connect"."listing_content"."whats_new" IS NOT NULL
    WHEN 'unreadable' THEN "app_store_connect"."listing_content"."purpose" IN ('baseline','observation') AND "app_store_connect"."listing_content"."whats_new" IS NULL
    ELSE false END) IS TRUE),
	CONSTRAINT "asc_listing_live_promo_text_shape" CHECK ((CASE "app_store_connect"."listing_content"."live_promotional_text_state"
    WHEN 'unspecified' THEN "app_store_connect"."listing_content"."live_promotional_text" IS NULL
    WHEN 'present' THEN "app_store_connect"."listing_content"."live_promotional_text" IS NOT NULL AND length("app_store_connect"."listing_content"."live_promotional_text") > 0
    WHEN 'empty' THEN "app_store_connect"."listing_content"."live_promotional_text" IS NOT NULL AND "app_store_connect"."listing_content"."live_promotional_text" = ''
    WHEN 'dismissed' THEN "app_store_connect"."listing_content"."purpose" = 'proposal' AND "app_store_connect"."listing_content"."live_promotional_text" IS NOT NULL
    WHEN 'unreadable' THEN "app_store_connect"."listing_content"."purpose" IN ('baseline','observation') AND "app_store_connect"."listing_content"."live_promotional_text" IS NULL
    ELSE false END) IS TRUE),
	CONSTRAINT "asc_listing_app_info_observed_fields" CHECK ((CASE WHEN "app_store_connect"."listing_content"."purpose" = 'proposal' THEN true
    WHEN "app_store_connect"."listing_content"."app_info_availability" = 'present' THEN true
    WHEN "app_store_connect"."listing_content"."app_info_availability" = 'unreadable' THEN "app_store_connect"."listing_content"."subtitle_state" IN ('unspecified','unreadable')
    ELSE "app_store_connect"."listing_content"."subtitle_state" = 'unspecified' END) IS TRUE),
	CONSTRAINT "asc_listing_version_observed_fields" CHECK ((CASE WHEN "app_store_connect"."listing_content"."purpose" = 'proposal' THEN true
    WHEN "app_store_connect"."listing_content"."version_availability" = 'present' THEN true
    WHEN "app_store_connect"."listing_content"."version_availability" = 'unreadable' THEN "app_store_connect"."listing_content"."keywords_state" IN ('unspecified','unreadable') AND "app_store_connect"."listing_content"."promotional_text_state" IN ('unspecified','unreadable') AND "app_store_connect"."listing_content"."whats_new_state" IN ('unspecified','unreadable')
    ELSE "app_store_connect"."listing_content"."keywords_state" = 'unspecified' AND "app_store_connect"."listing_content"."promotional_text_state" = 'unspecified' AND "app_store_connect"."listing_content"."whats_new_state" = 'unspecified' END) IS TRUE),
	CONSTRAINT "asc_listing_live_observed_fields" CHECK ((CASE WHEN "app_store_connect"."listing_content"."purpose" = 'proposal' THEN true
    WHEN "app_store_connect"."listing_content"."live_promotional_availability" = 'present' THEN true
    WHEN "app_store_connect"."listing_content"."live_promotional_availability" = 'unreadable' THEN "app_store_connect"."listing_content"."live_promotional_text_state" IN ('unspecified','unreadable')
    ELSE "app_store_connect"."listing_content"."live_promotional_text_state" = 'unspecified' END) IS TRUE),
	CONSTRAINT "asc_listing_live_version_state" CHECK ((CASE WHEN "app_store_connect"."listing_content"."live_promotional_availability" IN ('present','absent') THEN "app_store_connect"."listing_content"."live_promotional_native_state_kind" = 'known' AND "app_store_connect"."listing_content"."live_promotional_native_state" IN ('READY_FOR_SALE','READY_FOR_DISTRIBUTION') ELSE true END) IS TRUE),
	CONSTRAINT "asc_listing_same_localization_parent" CHECK ((CASE WHEN "app_store_connect"."listing_content"."app_version_localization_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_version_localization_id" = "app_store_connect"."listing_content"."live_promotional_localization_id" THEN "app_store_connect"."listing_content"."app_version_id" = "app_store_connect"."listing_content"."live_promotional_version_id" ELSE true END) IS TRUE),
	CONSTRAINT "asc_listing_same_version_state" CHECK ((CASE WHEN "app_store_connect"."listing_content"."app_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_version_id" = "app_store_connect"."listing_content"."live_promotional_version_id" AND "app_store_connect"."listing_content"."version_native_state_kind" = 'known' AND "app_store_connect"."listing_content"."live_promotional_native_state_kind" = 'known' THEN "app_store_connect"."listing_content"."version_native_state" = "app_store_connect"."listing_content"."live_promotional_native_state" ELSE true END) IS TRUE),
	CONSTRAINT "asc_listing_same_version_observation" CHECK ((CASE WHEN "app_store_connect"."listing_content"."app_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_version_id" = "app_store_connect"."listing_content"."live_promotional_version_id" AND "app_store_connect"."listing_content"."version_availability" IN ('present','absent') AND "app_store_connect"."listing_content"."live_promotional_availability" IN ('present','absent') THEN "app_store_connect"."listing_content"."version_availability" = "app_store_connect"."listing_content"."live_promotional_availability" AND ("app_store_connect"."listing_content"."version_availability" = 'absent' OR "app_store_connect"."listing_content"."app_version_localization_id" = "app_store_connect"."listing_content"."live_promotional_localization_id") ELSE true END) IS TRUE),
	CONSTRAINT "asc_listing_same_version_proposal" CHECK ((CASE WHEN "app_store_connect"."listing_content"."app_version_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_version_id" = "app_store_connect"."listing_content"."live_promotional_version_id" AND "app_store_connect"."listing_content"."version_operation" IN ('create','update') AND "app_store_connect"."listing_content"."live_promotional_operation" = 'update' THEN "app_store_connect"."listing_content"."version_operation" = 'update' AND "app_store_connect"."listing_content"."app_version_localization_id" = "app_store_connect"."listing_content"."live_promotional_localization_id" ELSE true END) IS TRUE),
	CONSTRAINT "asc_listing_same_localization_promo" CHECK ((CASE WHEN "app_store_connect"."listing_content"."app_version_localization_id" IS NOT NULL AND "app_store_connect"."listing_content"."app_version_localization_id" = "app_store_connect"."listing_content"."live_promotional_localization_id" AND "app_store_connect"."listing_content"."promotional_text_state" IN ('present','empty') AND "app_store_connect"."listing_content"."live_promotional_text_state" IN ('present','empty') THEN "app_store_connect"."listing_content"."promotional_text" = "app_store_connect"."listing_content"."live_promotional_text" ELSE true END) IS TRUE)
);
--> statement-breakpoint
ALTER TABLE "app_store_connect"."listing_content" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
ALTER TABLE "listing_work"."listing_content" ADD CONSTRAINT "listing_content_revision_scope" FOREIGN KEY ("organization_id","revision_id","purpose") REFERENCES "actions"."revision"("organization_id","id","purpose") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_store_connect"."listing_content" ADD CONSTRAINT "asc_listing_revision_scope" FOREIGN KEY ("organization_id","revision_id","purpose") REFERENCES "actions"."revision"("organization_id","id","purpose") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_store_connect"."listing_content" ADD CONSTRAINT "asc_listing_domain_scope" FOREIGN KEY ("organization_id","revision_id") REFERENCES "listing_work"."listing_content"("organization_id","revision_id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "listing_work"."listing_content" AS PERMISSIVE FOR ALL TO public USING ("listing_work"."listing_content"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("listing_work"."listing_content"."organization_id" = current_setting('fload.organization_id', true));--> statement-breakpoint
CREATE POLICY "tenant_scope" ON "app_store_connect"."listing_content" AS PERMISSIVE FOR ALL TO public USING ("app_store_connect"."listing_content"."organization_id" = current_setting('fload.organization_id', true)) WITH CHECK ("app_store_connect"."listing_content"."organization_id" = current_setting('fload.organization_id', true));
--> statement-breakpoint
-- Typed listing ownership and immutable content. These guards prove structural
-- relations; provider admission, write limits, availability and retries remain
-- in the canonical code owner.
CREATE FUNCTION listing_work.guard_listing_owner() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM actions.revision r JOIN actions.action a
    ON a.organization_id=r.organization_id AND a.id=r.action_id
    WHERE r.organization_id=NEW.organization_id AND r.id=NEW.revision_id
      AND r.kind='listing' AND r.purpose=NEW.purpose AND a.domain='listing') THEN
    RAISE EXCEPTION 'Listing content requires its exact listing revision and domain' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint
CREATE TRIGGER listing_content_guard BEFORE INSERT OR UPDATE OR DELETE ON listing_work.listing_content
FOR EACH ROW EXECUTE FUNCTION actions.guard_content();
--> statement-breakpoint
CREATE TRIGGER listing_owner_guard BEFORE INSERT OR UPDATE ON listing_work.listing_content
FOR EACH ROW EXECUTE FUNCTION listing_work.guard_listing_owner();
--> statement-breakpoint
CREATE TRIGGER asc_listing_content_guard BEFORE INSERT OR UPDATE OR DELETE ON app_store_connect.listing_content
FOR EACH ROW EXECUTE FUNCTION actions.guard_content();
--> statement-breakpoint
CREATE TRIGGER asc_listing_owner_guard BEFORE INSERT OR UPDATE ON app_store_connect.listing_content
FOR EACH ROW EXECUTE FUNCTION listing_work.guard_listing_owner();
--> statement-breakpoint
CREATE FUNCTION listing_work.check_revision_seal(revision actions.revision) RETURNS void LANGUAGE plpgsql AS $$
DECLARE content listing_work.listing_content; baseline actions.revision; before_content listing_work.listing_content;
BEGIN
  SELECT * INTO content FROM listing_work.listing_content c
    WHERE c.organization_id=revision.organization_id AND c.revision_id=revision.id;
  IF NOT FOUND OR revision.kind<>'listing' OR content.purpose<>revision.purpose
    OR revision.purpose NOT IN ('proposal','baseline','observation') THEN
    RAISE EXCEPTION 'Incomplete listing content or unsupported purpose' USING ERRCODE='23514';
  END IF;
  IF EXISTS (SELECT 1 FROM actions.revision r JOIN listing_work.listing_content c
    ON c.organization_id=r.organization_id AND c.revision_id=r.id
    WHERE r.organization_id=revision.organization_id AND r.action_id=revision.action_id
      AND ROW(c.store,c.locale) IS DISTINCT FROM ROW(content.store,content.locale)) THEN
    RAISE EXCEPTION 'Store and locale identity cannot change between listing ticket revisions' USING ERRCODE='23514';
  END IF;
  IF revision.purpose='proposal' AND revision.baseline_revision_id IS NULL THEN
    RAISE EXCEPTION 'Listing proposal requires its exact captured baseline' USING ERRCODE='23514';
  END IF;
  IF revision.baseline_revision_id IS NOT NULL THEN
    SELECT * INTO baseline FROM actions.revision r
      WHERE r.organization_id=revision.organization_id AND r.id=revision.baseline_revision_id;
    IF NOT FOUND OR baseline.action_id<>revision.action_id OR baseline.kind<>'listing'
      OR baseline.purpose<>'baseline' OR NOT baseline.sealed OR baseline.revision_number>=revision.revision_number THEN
      RAISE EXCEPTION 'Listing baseline must be an earlier sealed baseline on the exact ticket' USING ERRCODE='23514';
    END IF;
    SELECT * INTO before_content FROM listing_work.listing_content c
      WHERE c.organization_id=revision.organization_id AND c.revision_id=baseline.id;
    IF NOT FOUND OR ROW(before_content.store,before_content.locale) IS DISTINCT FROM ROW(content.store,content.locale) THEN
      RAISE EXCEPTION 'Listing baseline identity differs from its proposal' USING ERRCODE='23514';
    END IF;
  END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION app_store_connect.check_listing_revision_seal(revision actions.revision) RETURNS void LANGUAGE plpgsql AS $$
DECLARE content listing_work.listing_content; target app_store_connect.listing_content;
  before_content listing_work.listing_content; baseline app_store_connect.listing_content;
  info_effect boolean; version_effect boolean; live_effect boolean;
BEGIN
  SELECT * INTO content FROM listing_work.listing_content c
    WHERE c.organization_id=revision.organization_id AND c.revision_id=revision.id;
  IF NOT FOUND OR content.store<>'ios' THEN
    RAISE EXCEPTION 'ASC listing content requires iOS domain content' USING ERRCODE='23514';
  END IF;
  SELECT * INTO target FROM app_store_connect.listing_content c
    WHERE c.organization_id=revision.organization_id AND c.revision_id=revision.id;
  IF NOT FOUND OR target.purpose<>revision.purpose THEN
    RAISE EXCEPTION 'Missing exact ASC listing content leaf' USING ERRCODE='23514';
  END IF;
  IF EXISTS (SELECT 1 FROM actions.revision r JOIN app_store_connect.listing_content c
    ON c.organization_id=r.organization_id AND c.revision_id=r.id
    WHERE r.organization_id=revision.organization_id AND r.action_id=revision.action_id
      AND c.provider_app_id IS DISTINCT FROM target.provider_app_id) THEN
    RAISE EXCEPTION 'Native app identity cannot change between listing ticket revisions' USING ERRCODE='23514';
  END IF;
  IF revision.purpose<>'proposal' THEN
    IF (target.app_info_availability IN ('absent','unspecified') AND content.title_state<>'unspecified')
      OR (target.app_info_availability='unreadable' AND content.title_state NOT IN ('unspecified','unreadable'))
      OR (target.version_availability IN ('absent','unspecified') AND (content.description_state<>'unspecified' OR content.support_url_state<>'unspecified'))
      OR (target.version_availability='unreadable' AND (content.description_state NOT IN ('unspecified','unreadable') OR content.support_url_state NOT IN ('unspecified','unreadable'))) THEN
      RAISE EXCEPTION 'Unobserved listing resources cannot carry observed domain values' USING ERRCODE='23514';
    END IF;
    RETURN;
  END IF;
  SELECT * INTO baseline FROM app_store_connect.listing_content c
    WHERE c.organization_id=revision.organization_id AND c.revision_id=revision.baseline_revision_id;
  IF NOT FOUND OR ROW(baseline.source_asset_data_source_id,baseline.source_connector_id,baseline.credential_kind,baseline.credential_key_id,baseline.credential_team_issuer_id,baseline.provider_app_id)
    IS DISTINCT FROM ROW(target.source_asset_data_source_id,target.source_connector_id,target.credential_kind,target.credential_key_id,target.credential_team_issuer_id,target.provider_app_id) THEN
    RAISE EXCEPTION 'Listing proposal source and app must match the exact baseline' USING ERRCODE='23514';
  END IF;
  SELECT * INTO before_content FROM listing_work.listing_content c
    WHERE c.organization_id=revision.organization_id AND c.revision_id=revision.baseline_revision_id;
  info_effect := content.title_state IN ('present','empty') OR target.subtitle_state IN ('present','empty');
  version_effect := content.description_state IN ('present','empty') OR content.support_url_state IN ('present','empty')
    OR target.keywords_state IN ('present','empty') OR target.promotional_text_state IN ('present','empty') OR target.whats_new_state IN ('present','empty');
  live_effect := target.live_promotional_text_state IN ('present','empty');
  IF NOT (info_effect OR version_effect OR live_effect) THEN
    RAISE EXCEPTION 'Listing proposal must retain an effective selected field' USING ERRCODE='23514';
  END IF;
  IF baseline.app_info_availability='absent' AND info_effect AND content.title_state<>'present' THEN
    RAISE EXCEPTION 'Creating an app information localization requires its reviewed name' USING ERRCODE='23514';
  END IF;
  IF EXISTS (
    SELECT 1 FROM (VALUES
      (content.title_state,before_content.title_state,baseline.app_info_availability),
      (target.subtitle_state,baseline.subtitle_state,baseline.app_info_availability),
      (content.description_state,before_content.description_state,baseline.version_availability),
      (content.support_url_state,before_content.support_url_state,baseline.version_availability),
      (target.keywords_state,baseline.keywords_state,baseline.version_availability),
      (target.promotional_text_state,baseline.promotional_text_state,baseline.version_availability),
      (target.whats_new_state,baseline.whats_new_state,baseline.version_availability),
      (target.live_promotional_text_state,baseline.live_promotional_text_state,baseline.live_promotional_availability)
    ) AS fields(effect,before_state,availability)
    WHERE effect IN ('present','empty') AND NOT (availability='absent' OR (availability='present' AND before_state IN ('present','empty')))
  ) THEN
    RAISE EXCEPTION 'Each selected listing field requires exact readable baseline or observed absence' USING ERRCODE='23514';
  END IF;
  IF target.release_selection='next_editable_release' THEN
    IF live_effect OR content.intent NOT IN ('create','update') THEN
      RAISE EXCEPTION 'Future-release listing proposal cannot contain an immediate live effect or restore/repair intent' USING ERRCODE='23514';
    END IF;
    RETURN;
  END IF;
  IF (target.app_info_operation<>'omit') IS DISTINCT FROM info_effect
    OR (target.version_operation<>'omit') IS DISTINCT FROM version_effect
    OR (target.live_promotional_operation<>'omit') IS DISTINCT FROM live_effect THEN
    RAISE EXCEPTION 'Exact listing resources must match the selected field families' USING ERRCODE='23514';
  END IF;
  IF target.app_info_operation='create' AND content.title_state<>'present' THEN
    RAISE EXCEPTION 'App information creation requires an exact reviewed name' USING ERRCODE='23514';
  END IF;
  IF EXISTS (
    SELECT 1 FROM (VALUES
      (target.app_info_operation,target.app_info_id,target.app_info_localization_id,baseline.app_info_availability,baseline.app_info_id,baseline.app_info_localization_id),
      (target.version_operation,target.app_version_id,target.app_version_localization_id,baseline.version_availability,baseline.app_version_id,baseline.app_version_localization_id),
      (target.live_promotional_operation,target.live_promotional_version_id,target.live_promotional_localization_id,baseline.live_promotional_availability,baseline.live_promotional_version_id,baseline.live_promotional_localization_id)
    ) AS resources(operation,parent_id,localization_id,availability,before_parent_id,before_localization_id)
    WHERE operation<>'omit' AND (parent_id IS DISTINCT FROM before_parent_id
      OR (operation='create' AND availability<>'absent')
      OR (operation='update' AND (availability<>'present' OR localization_id IS DISTINCT FROM before_localization_id)))
  ) THEN
    RAISE EXCEPTION 'Exact listing target differs from the captured baseline resource' USING ERRCODE='23514';
  END IF;
END $$;
--> statement-breakpoint
CREATE FUNCTION composition.check_listing_revision_seal(revision actions.revision) RETURNS void LANGUAGE plpgsql AS $$
DECLARE listing_store listing_work.store;
BEGIN
  PERFORM listing_work.check_revision_seal(revision);
  IF EXISTS (SELECT 1 FROM agent_work.attention_advisory c WHERE c.organization_id=revision.organization_id AND c.revision_id=revision.id)
    OR EXISTS (SELECT 1 FROM actions.membership m WHERE m.organization_id=revision.organization_id AND m.parent_revision_id=revision.id) THEN
    RAISE EXCEPTION 'Listing revision cannot contain another domain content family' USING ERRCODE='23514';
  END IF;
  SELECT c.store INTO listing_store FROM listing_work.listing_content c
    WHERE c.organization_id=revision.organization_id AND c.revision_id=revision.id;
  IF listing_store='ios' THEN
    PERFORM app_store_connect.check_listing_revision_seal(revision);
  ELSE
    RAISE EXCEPTION 'Listing provider content owner is not installed' USING ERRCODE='23514';
  END IF;
END $$;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION actions.guard_revision() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'Revision deletion requires the separate erasure authority' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'INSERT' AND NEW.sealed THEN
    RAISE EXCEPTION 'Build content before sealing its revision' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'UPDATE' THEN
    IF OLD.sealed OR ROW(NEW.id, NEW.organization_id, NEW.action_id, NEW.purpose, NEW.kind, NEW.revision_number, NEW.authored_command_id, NEW.created_at)
      IS DISTINCT FROM ROW(OLD.id, OLD.organization_id, OLD.action_id, OLD.purpose, OLD.kind, OLD.revision_number, OLD.authored_command_id, OLD.created_at) THEN
      RAISE EXCEPTION 'A sealed revision and revision identity are immutable' USING ERRCODE = '23514';
    END IF;
    IF NEW.sealed THEN
      -- Each later owner extends this closed dispatch with its complete leaves.
      -- A contract enum alone never enables a content or provider branch.
      IF NEW.kind = 'advisory' AND NEW.purpose = 'proposal' THEN
        IF NOT EXISTS (SELECT 1 FROM agent_work.attention_advisory c WHERE c.organization_id = NEW.organization_id AND c.revision_id = NEW.id)
          OR EXISTS (SELECT 1 FROM actions.membership m WHERE m.organization_id = NEW.organization_id AND m.parent_revision_id = NEW.id) THEN
          RAISE EXCEPTION 'Incomplete attention advisory content' USING ERRCODE = '23514';
        END IF;
      ELSIF NEW.kind = 'collection' AND NEW.purpose = 'proposal' THEN
        IF NOT EXISTS (SELECT 1 FROM actions.membership m WHERE m.organization_id = NEW.organization_id AND m.parent_revision_id = NEW.id)
          OR EXISTS (SELECT 1 FROM agent_work.attention_advisory c WHERE c.organization_id = NEW.organization_id AND c.revision_id = NEW.id)
          OR EXISTS (SELECT 1 FROM actions.membership m LEFT JOIN actions.revision c ON c.organization_id = m.organization_id AND c.id = m.child_revision_id
            WHERE m.organization_id = NEW.organization_id AND m.parent_revision_id = NEW.id
            AND (c.id IS NULL OR c.kind = 'collection' OR NOT c.sealed OR c.purpose <> 'proposal' OR c.action_id = NEW.action_id)) THEN
          RAISE EXCEPTION 'Incomplete sealed collection membership' USING ERRCODE = '23514';
        END IF;
      ELSIF NEW.kind = 'review_reply' AND NEW.purpose IN ('proposal', 'baseline', 'observation') THEN
        PERFORM composition.check_review_revision_seal(NEW);
      ELSIF NEW.kind = 'listing' AND NEW.purpose IN ('proposal', 'baseline', 'observation') THEN
        PERFORM composition.check_listing_revision_seal(NEW);
      ELSE
        RAISE EXCEPTION 'Content owner is not yet installed for this revision shape' USING ERRCODE = '23514';
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END $$;

-- 0157_pink_freak.sql
CREATE INDEX "attempt_unresolved_effect" ON "actions"."execution_attempt" USING btree ("organization_id","execution_id") WHERE "actions"."execution_attempt"."kind" = 'conflicting_completion' OR ("actions"."execution_attempt"."kind" = 'write' AND NOT ("actions"."execution_attempt"."finished_at" IS NOT NULL AND "actions"."execution_attempt"."result" IS NOT DISTINCT FROM 'known_not_applied' AND "actions"."execution_attempt"."non_application_basis" IS NOT DISTINCT FROM 'pre_dispatch_failure'));
--> statement-breakpoint

-- The two evidence-capture kinds are structurally required to be finished.
-- Name every original kind explicitly so the existing partial authority index
-- proves absence without reading completed attempt history.
CREATE OR REPLACE FUNCTION actions.assert_execution_graph(scope_organization text, scope_execution text) RETURNS void LANGUAGE plpgsql AS $$
DECLARE e actions.execution; ap actions.approval; a actions.action; unfinished actions.execution_attempt;
BEGIN
  SELECT * INTO e FROM actions.execution WHERE organization_id=scope_organization AND id=scope_execution;
  SELECT * INTO ap FROM actions.approval WHERE organization_id=e.organization_id AND id=e.approval_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Execution requires its exact approval' USING ERRCODE='23514'; END IF;
  SELECT * INTO a FROM actions.action WHERE organization_id=ap.organization_id AND id=ap.action_id;
  IF NOT FOUND OR (e.phase NOT IN ('settled','cancelled') AND
    (a.current_approval_id IS DISTINCT FROM ap.id OR a.current_revision_id IS DISTINCT FROM ap.revision_id OR a.decision <> 'approved')) THEN
    RAISE EXCEPTION 'Active execution must retain the exact current approval and revision' USING ERRCODE='23514';
  END IF;
  IF NOT EXISTS(SELECT 1 FROM actions.execution_step s WHERE s.organization_id=e.organization_id AND s.execution_id=e.id) THEN
    RAISE EXCEPTION 'Execution requires durable scoped plan steps' USING ERRCODE='23514';
  END IF;
  SELECT * INTO unfinished FROM actions.execution_attempt x WHERE x.organization_id=e.organization_id AND x.execution_id=e.id AND x.finished_at IS NULL AND x.kind IN ('write','readback','inspection','generation','manual_observation');
  IF (e.phase='claimed') IS DISTINCT FROM (unfinished.id IS NOT NULL)
    OR (unfinished.id IS NOT NULL AND (unfinished.claim_generation <> e.claim_generation OR unfinished.claim_token IS DISTINCT FROM e.claim_token)) THEN
    RAISE EXCEPTION 'Committed claim and unfinished original attempt must agree' USING ERRCODE='23514';
  END IF;
  IF e.phase IN ('ready','verification_due','uncertain','claimed') AND e.next_step_id IS NULL THEN
    RAISE EXCEPTION 'Active execution requires a concrete routing step' USING ERRCODE='23514';
  END IF;
  IF e.phase='cancelled' AND NOT EXISTS(SELECT 1 FROM actions.command c JOIN actions.command_target t ON t.organization_id=c.organization_id AND t.command_id=c.id
      WHERE c.organization_id=e.organization_id AND c.id=e.cancelled_command_id AND c.outcome='accepted' AND c.kind IN ('undo','revise','reject') AND t.action_id=ap.action_id) THEN
    RAISE EXCEPTION 'Execution cancellation requires its exact accepted ticket command' USING ERRCODE='23514';
  END IF;
  IF e.phase IN ('settled','cancelled') AND EXISTS(SELECT 1 FROM actions.resource_guard g WHERE g.holder_organization_id=e.organization_id AND g.holder_execution_id=e.id) THEN
    RAISE EXCEPTION 'Terminal execution cannot retain a resource holder' USING ERRCODE='23514';
  END IF;
END $$;

-- 0158_fine_agent_brand.sql
CREATE TYPE "app_store_connect"."review_read_invalid_reason" AS ENUM('malformed_body', 'unexpected_status', 'redirect', 'identity_mismatch', 'missing_response_linkage', 'missing_included_response', 'duplicate_resource', 'unrelated_included_response', 'invalid_continuation');--> statement-breakpoint
CREATE TYPE "app_store_connect"."review_read_not_sent_reason" AS ENUM('invalid_input', 'credentials_unavailable', 'rate_limited', 'aborted');--> statement-breakpoint
ALTER TYPE "app_store_connect"."review_receipt_kind" ADD VALUE 'read_review';--> statement-breakpoint
ALTER TYPE "app_store_connect"."review_receipt_kind" ADD VALUE 'read_unavailable';--> statement-breakpoint
ALTER TYPE "app_store_connect"."review_receipt_kind" ADD VALUE 'read_not_sent';--> statement-breakpoint
ALTER TYPE "app_store_connect"."review_receipt_kind" ADD VALUE 'read_transport_lost';--> statement-breakpoint
ALTER TYPE "actions"."unreadable_reason" ADD VALUE 'claim_expired' BEFORE 'unavailable';--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" DROP CONSTRAINT "asc_receipt_status";--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" DROP CONSTRAINT "asc_receipt_native_shape";--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" ALTER COLUMN "response_status" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" ADD COLUMN "read_not_sent_reason" "app_store_connect"."review_read_not_sent_reason";--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" ADD COLUMN "read_invalid_reason" "app_store_connect"."review_read_invalid_reason";--> statement-breakpoint
ALTER TABLE "app_store_connect"."review_target" ADD COLUMN "review_created_date" text;--> statement-breakpoint
ALTER TABLE "app_store_connect"."review_target" ADD COLUMN "response_last_modified_date" text;--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" ADD CONSTRAINT "asc_receipt_read_reasons" CHECK (("app_store_connect"."attempt_receipt"."response_kind"::text = 'read_not_sent') = ("app_store_connect"."attempt_receipt"."read_not_sent_reason" IS NOT NULL)
        AND ("app_store_connect"."attempt_receipt"."read_invalid_reason" IS NULL OR "app_store_connect"."attempt_receipt"."response_kind"::text = 'invalid_response'));--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" ADD CONSTRAINT "asc_receipt_status" CHECK (("app_store_connect"."attempt_receipt"."response_status" IS NULL) = ("app_store_connect"."attempt_receipt"."response_kind"::text IN ('read_not_sent','read_transport_lost')) AND ("app_store_connect"."attempt_receipt"."response_status" IS NULL OR "app_store_connect"."attempt_receipt"."response_status" BETWEEN 100 AND 599));--> statement-breakpoint
ALTER TABLE "app_store_connect"."attempt_receipt" ADD CONSTRAINT "asc_receipt_native_shape" CHECK (CASE "app_store_connect"."attempt_receipt"."response_kind"::text
    WHEN 'accepted' THEN "app_store_connect"."attempt_receipt"."response_status"=201 AND "app_store_connect"."attempt_receipt"."provider_resource_id" IS NOT NULL AND "app_store_connect"."attempt_receipt"."error_code" IS NULL AND ("app_store_connect"."attempt_receipt"."native_state" IS NULL OR "app_store_connect"."attempt_receipt"."native_state" IN ('PUBLISHED','PENDING_PUBLISH'))
    WHEN 'deleted' THEN "app_store_connect"."attempt_receipt"."response_status"=204 AND num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state","app_store_connect"."attempt_receipt"."error_code")=0
    WHEN 'http_error' THEN "app_store_connect"."attempt_receipt"."response_status">=400 AND num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state")=0
    WHEN 'invalid_response' THEN num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state","app_store_connect"."attempt_receipt"."error_code")=0
    WHEN 'read_review' THEN "app_store_connect"."attempt_receipt"."response_status"=200 AND num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state","app_store_connect"."attempt_receipt"."error_code")=0
    WHEN 'read_unavailable' THEN "app_store_connect"."attempt_receipt"."response_status"=404 AND num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state","app_store_connect"."attempt_receipt"."error_code")=0
    WHEN 'read_not_sent' THEN "app_store_connect"."attempt_receipt"."response_status" IS NULL AND num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state","app_store_connect"."attempt_receipt"."error_code")=0
    WHEN 'read_transport_lost' THEN "app_store_connect"."attempt_receipt"."response_status" IS NULL AND num_nonnulls("app_store_connect"."attempt_receipt"."provider_resource_id","app_store_connect"."attempt_receipt"."response_body","app_store_connect"."attempt_receipt"."native_state","app_store_connect"."attempt_receipt"."error_code")=0
    ELSE false END);--> statement-breakpoint
ALTER TABLE "app_store_connect"."review_target" ADD CONSTRAINT "asc_review_raw_dates_scope" CHECK ("app_store_connect"."review_target"."purpose" = 'observation' OR num_nonnulls("app_store_connect"."review_target"."review_created_date","app_store_connect"."review_target"."response_last_modified_date")=0);--> statement-breakpoint
ALTER TABLE "app_store_connect"."review_target" ADD CONSTRAINT "asc_review_raw_dates_shape" CHECK (("app_store_connect"."review_target"."review_created_date" IS NULL OR length("app_store_connect"."review_target"."review_created_date") BETWEEN 17 AND 128)
          AND ("app_store_connect"."review_target"."response_last_modified_date" IS NULL OR (length("app_store_connect"."review_target"."response_last_modified_date") BETWEEN 17 AND 128 AND "app_store_connect"."review_target"."response_id" IS NOT NULL)));
--> statement-breakpoint

-- Strict native metadata validation. It admits the native decoder's optional
-- seconds/offset spelling without implying a representable domain instant.
CREATE FUNCTION app_store_connect.review_native_date_valid(value text) RETURNS boolean LANGUAGE plpgsql IMMUTABLE STRICT AS $$
BEGIN
  IF length(value)>128 OR value !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T([01][0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9](\.[0-9]+)?)?(Z|[+-][0-9]{2}:?[0-9]{2})$' OR left(value,4)='0000' THEN RETURN false; END IF;
  PERFORM make_date(substr(value,1,4)::integer,substr(value,6,2)::integer,substr(value,9,2)::integer);
  RETURN true;
EXCEPTION WHEN datetime_field_overflow THEN RETURN false;
END $$;
--> statement-breakpoint
-- Same representability boundary as ActionInstant. Fractional digits are never
-- rounded and timezone arithmetic uses integral minutes, even beyond PG's offset
-- input range. NULL is unavailable normalized time; raw metadata stays retained.
CREATE FUNCTION app_store_connect.review_native_date_instant(value text) RETURNS timestamptz LANGUAGE plpgsql IMMUTABLE STRICT AS $$
DECLARE parts text[]; whole timestamptz; micros integer; offset_minutes integer;
BEGIN
  IF NOT app_store_connect.review_native_date_valid(value) THEN RETURN NULL; END IF;
  parts := regexp_match(value, '^([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2})(\.([0-9]{1,6}))?(Z|([+-])([0-9]{2}):([0-9]{2}))$');
  IF parts IS NULL OR (parts[6] IS NOT NULL AND (parts[6]::integer>23 OR parts[7]::integer>59)) THEN RETURN NULL; END IF;
  whole := (parts[1]||'Z')::timestamptz;
  micros := rpad(coalesce(parts[3],''),6,'0')::integer;
  offset_minutes := coalesce(parts[6]::integer*60+parts[7]::integer,0) * CASE WHEN parts[5]='-' THEN -1 ELSE 1 END;
  whole := whole + micros*interval '1 microsecond' - offset_minutes*interval '1 minute';
  IF whole < timestamptz '0001-01-01 00:00:00+00' OR whole >= timestamptz '10000-01-01 00:00:00+00' THEN RETURN NULL; END IF;
  RETURN whole;
END $$;
--> statement-breakpoint

CREATE FUNCTION app_store_connect.check_review_readback_receipt(candidate actions.execution_attempt) RETURNS void LANGUAGE plpgsql AS $$
DECLARE original actions.execution_attempt; subject actions.execution_attempt; step actions.execution_step;
  head actions.revision; expected review_work.reply_content; target app_store_connect.review_target;
  r app_store_connect.attempt_receipt; observation actions.revision; observed review_work.reply_content;
  native app_store_connect.review_target; cycle actions.command; expected_result text; expected_reason text;
BEGIN
  IF candidate.kind='readback' THEN original:=candidate;
  ELSIF candidate.kind IN ('late_evidence','conflicting_completion') THEN
    SELECT * INTO original FROM actions.execution_attempt WHERE organization_id=candidate.organization_id AND execution_id=candidate.execution_id AND step_id=candidate.step_id AND id=candidate.subject_attempt_id;
  ELSE RAISE EXCEPTION 'ASC read owner requires an original readback or its exact capture' USING ERRCODE='23514'; END IF;
  IF original.kind IS DISTINCT FROM 'readback' THEN RAISE EXCEPTION 'ASC read capture requires its exact original readback' USING ERRCODE='23514'; END IF;
  SELECT * INTO step FROM actions.execution_step WHERE organization_id=candidate.organization_id AND execution_id=candidate.execution_id AND id=candidate.step_id;
  SELECT * INTO head FROM actions.revision WHERE organization_id=candidate.organization_id AND id=step.content_revision_id;
  SELECT * INTO expected FROM review_work.reply_content WHERE organization_id=candidate.organization_id AND revision_id=head.id;
  SELECT * INTO target FROM app_store_connect.review_target WHERE organization_id=candidate.organization_id AND revision_id=head.id;
  SELECT * INTO subject FROM actions.execution_attempt WHERE organization_id=candidate.organization_id AND execution_id=candidate.execution_id AND step_id=candidate.step_id AND id=original.subject_attempt_id;
  SELECT * INTO cycle FROM actions.command WHERE organization_id=candidate.organization_id AND id=original.cycle_command_id;
  IF step.operation_contract_id IS DISTINCT FROM 'asc.review_response_upsert@1' OR head.id IS NULL OR NOT head.sealed OR head.purpose<>'proposal' OR head.kind<>'review_reply'
    OR expected.store IS DISTINCT FROM 'ios' OR target.review_resource_id IS NULL OR target.review_resource_id IS DISTINCT FROM expected.provider_review_id
    OR original.connector_id IS DISTINCT FROM target.source_connector_id
    OR subject.kind IS DISTINCT FROM 'write' OR subject.finished_at IS NULL OR subject.finished_at>original.started_at OR subject.number>=original.number
    OR cycle.outcome IS DISTINCT FROM 'accepted' OR cycle.cycle_purpose IS DISTINCT FROM 'readback' OR cycle.cycle_contract_id IS DISTINCT FROM step.operation_contract_id
    OR cycle.progress_execution_id IS DISTINCT FROM candidate.execution_id OR cycle.progress_step_id IS DISTINCT FROM candidate.step_id
    OR cycle.progress_subject_attempt_id IS DISTINCT FROM subject.id OR cycle.accepted_at>original.started_at
    OR num_nonnulls(candidate.input_attempt_id,candidate.prewrite_attempt_id,candidate.input_parent_revision_id,candidate.agent_run_id,candidate.inspection_purpose,candidate.planned_write_step_id,candidate.resource_guard_generation,candidate.failure_class,candidate.output_kind,candidate.output_revision_id,candidate.output_review_analysis_id,candidate.output_agent_run_id,candidate.no_work_reason)>0 THEN
    RAISE EXCEPTION 'ASC readback requires its exact sealed source, finished write, cycle and closed admission' USING ERRCODE='23514';
  END IF;
  SELECT * INTO r FROM app_store_connect.attempt_receipt WHERE organization_id=candidate.organization_id AND attempt_id=candidate.id;
  IF candidate.finished_at IS NULL THEN
    IF r.attempt_id IS NOT NULL THEN
      RAISE EXCEPTION 'Unfinished ASC read cannot carry a fabricated receipt' USING ERRCODE='23514';
    END IF;
    IF NOT EXISTS(SELECT 1 FROM actions.execution e JOIN actions.resource_guard g ON g.id=e.resource_guard_id
      WHERE e.organization_id=candidate.organization_id AND e.id=candidate.execution_id AND g.holder_organization_id=e.organization_id AND g.holder_execution_id=e.id) THEN
      RAISE EXCEPTION 'ASC readback requires its retained application exclusion guard' USING ERRCODE='23514';
    END IF;
    RETURN;
  END IF;
  IF candidate.result='unreadable' AND candidate.unreadable_reason::text='claim_expired' THEN
    IF candidate.kind<>'readback' OR r.attempt_id IS NOT NULL OR num_nonnulls(candidate.observation_revision_id,candidate.semantic_fingerprint,candidate.terminal_outcome)>0 THEN
      RAISE EXCEPTION 'Expired read is database-only unreadability without native evidence' USING ERRCODE='23514';
    END IF;
    RETURN;
  END IF;
  IF r.attempt_id IS NULL OR r.transport<>'asc_api' THEN RAISE EXCEPTION 'ASC read completion requires its exact native interaction receipt' USING ERRCODE='23514'; END IF;
  IF r.response_kind::text='read_review' THEN
    SELECT * INTO observation FROM actions.revision WHERE organization_id=candidate.organization_id AND id=candidate.observation_revision_id;
    SELECT * INTO observed FROM review_work.reply_content WHERE organization_id=candidate.organization_id AND revision_id=observation.id;
    SELECT * INTO native FROM app_store_connect.review_target WHERE organization_id=candidate.organization_id AND revision_id=observation.id;
    IF observation.id IS NULL OR NOT observation.sealed OR observation.purpose<>'observation' OR observation.kind<>'review_reply' OR observation.action_id IS DISTINCT FROM head.action_id
      OR observed.store IS DISTINCT FROM 'ios' OR observed.review_snapshot_availability IS DISTINCT FROM 'present' OR observed.captured_at IS DISTINCT FROM candidate.finished_at
      OR ROW(observed.provider_app_id,observed.provider_review_id) IS DISTINCT FROM ROW(expected.provider_app_id,expected.provider_review_id)
      OR ROW(native.source_asset_data_source_id,native.source_connector_id,native.credential_kind,native.credential_key_id,native.credential_team_issuer_id,native.review_resource_id)
        IS DISTINCT FROM ROW(target.source_asset_data_source_id,target.source_connector_id,target.credential_kind,target.credential_key_id,target.credential_team_issuer_id,target.review_resource_id)
      OR num_nonnulls(observed.review_app_version,observed.review_modified_at,observed.review_edited,observed.response_hidden)>0
      OR (observed.review_storefront IS NOT NULL AND observed.review_storefront !~ '^[A-Z]{3}$')
      OR (native.review_created_date IS NOT NULL AND NOT app_store_connect.review_native_date_valid(native.review_created_date))
      OR (native.response_last_modified_date IS NOT NULL AND NOT app_store_connect.review_native_date_valid(native.response_last_modified_date))
      OR observed.review_created_at IS DISTINCT FROM app_store_connect.review_native_date_instant(native.review_created_date)
      OR observed.response_modified_at IS DISTINCT FROM app_store_connect.review_native_date_instant(native.response_last_modified_date)
      OR candidate.comparison_version IS DISTINCT FROM 1 OR candidate.observation_surface IS DISTINCT FROM 'review_response' THEN
      RAISE EXCEPTION 'ASC read observation must retain exact native source, scope, metadata and completion time' USING ERRCODE='23514';
    END IF;
    IF observed.response_availability='absent' THEN
      IF num_nonnulls(native.response_id,native.native_state,native.native_state_source,native.response_last_modified_date)>0 THEN RAISE EXCEPTION 'ASC explicit absence cannot carry response facts' USING ERRCODE='23514'; END IF;
      expected_result:='mismatch';
    ELSIF observed.response_availability='present' AND native.native_state_source='api_publication' AND native.native_state='PENDING_PUBLISH' THEN
      expected_result:='unreadable'; expected_reason:='partial';
    ELSIF observed.response_availability='present' AND native.native_state_source='api_publication' AND native.native_state='PUBLISHED' THEN
      expected_result:=CASE WHEN observed.response_text=expected.reply_text THEN 'matched' ELSE 'mismatch' END;
    ELSE RAISE EXCEPTION 'ASC read requires known native response presence and publication' USING ERRCODE='23514'; END IF;
    IF candidate.result::text IS DISTINCT FROM expected_result OR
      (expected_result='unreadable' AND (candidate.unreadable_reason::text IS DISTINCT FROM 'partial' OR candidate.observation_completeness IS DISTINCT FROM 'partial' OR num_nonnulls(candidate.semantic_fingerprint,candidate.terminal_outcome)>0)) OR
      (expected_result<>'unreadable' AND (candidate.observation_completeness IS DISTINCT FROM 'complete' OR candidate.terminal_outcome IS DISTINCT FROM false OR candidate.semantic_fingerprint IS NULL OR candidate.fingerprint_version IS DISTINCT FROM 1)) THEN
      RAISE EXCEPTION 'ASC read comparison differs from its exact observed published response surface' USING ERRCODE='23514';
    END IF;
    RETURN;
  END IF;
  IF num_nonnulls(candidate.observation_revision_id,candidate.comparison_version,candidate.observation_surface,candidate.observation_completeness,candidate.semantic_fingerprint,candidate.terminal_outcome)>0 THEN
    RAISE EXCEPTION 'Unavailable ASC read cannot fabricate an observation' USING ERRCODE='23514';
  END IF;
  expected_reason:='unavailable';
  CASE r.response_kind::text
    WHEN 'read_not_sent' THEN expected_reason:=CASE r.read_not_sent_reason WHEN 'invalid_input' THEN 'unsupported' WHEN 'aborted' THEN 'cancelled' ELSE 'unavailable' END;
    WHEN 'read_unavailable' THEN NULL;
    WHEN 'read_transport_lost' THEN NULL;
    WHEN 'http_error' THEN
      IF r.response_status=404 THEN RAISE EXCEPTION 'ASC read 404 requires unavailable receipt' USING ERRCODE='23514'; END IF;
    WHEN 'invalid_response' THEN
      IF r.read_invalid_reason IS NULL OR NOT (CASE r.read_invalid_reason
        WHEN 'redirect' THEN true
        WHEN 'malformed_body' THEN r.response_status<>404 AND (r.response_status<300 OR r.response_status>=400)
        WHEN 'unexpected_status' THEN r.response_status<300 AND r.response_status<>200
        ELSE r.response_status=200 END) THEN
        RAISE EXCEPTION 'ASC read invalid response requires exact decoder reason and status' USING ERRCODE='23514';
      END IF;
    ELSE RAISE EXCEPTION 'ASC read cannot use a write receipt' USING ERRCODE='23514';
  END CASE;
  IF candidate.result IS DISTINCT FROM 'unreadable' OR candidate.unreadable_reason::text IS DISTINCT FROM expected_reason THEN RAISE EXCEPTION 'ASC read failure differs from its exact native event' USING ERRCODE='23514'; END IF;
END $$;
--> statement-breakpoint

-- Existing authority functions extended only for the installed readback owner.
CREATE OR REPLACE FUNCTION composition.check_execution_attempt_owner(candidate actions.execution_attempt) RETURNS void LANGUAGE plpgsql AS $$
DECLARE provider_kind composition.provider; contract_id text; original_kind text;
BEGIN
  SELECT c.provider,c.id INTO provider_kind,contract_id FROM actions.execution_step s JOIN composition.operation_contract c ON c.id=s.operation_contract_id
    WHERE s.organization_id=candidate.organization_id AND s.execution_id=candidate.execution_id AND s.id=candidate.step_id;
  IF NOT FOUND OR provider_kind='internal' THEN
    RAISE EXCEPTION 'Execution attempt owner is not installed for this shape' USING ERRCODE='23514';
  END IF;
  IF candidate.prewrite_attempt_id IS NOT NULL OR candidate.input_attempt_id IS NOT NULL THEN
    RAISE EXCEPTION 'Execution input evidence owner is not installed' USING ERRCODE='23514';
  END IF;
  IF contract_id='asc.review_response_upsert@1' THEN
    original_kind:=candidate.kind::text;
    IF candidate.kind IN ('late_evidence','conflicting_completion') THEN
      SELECT a.kind::text INTO original_kind FROM actions.execution_attempt a WHERE a.organization_id=candidate.organization_id AND a.execution_id=candidate.execution_id AND a.step_id=candidate.step_id AND a.id=candidate.subject_attempt_id;
    END IF;
    IF original_kind='readback' THEN PERFORM app_store_connect.check_review_readback_receipt(candidate);
    ELSE PERFORM app_store_connect.check_review_write_receipt(candidate); END IF;
    RETURN;
  END IF;
  IF candidate.kind<>'write' THEN RAISE EXCEPTION 'Captured evidence owner is not installed for this operation' USING ERRCODE='23514'; END IF;
  IF EXISTS(SELECT 1 FROM app_store_connect.attempt_receipt r WHERE r.organization_id=candidate.organization_id AND r.attempt_id=candidate.id) THEN
    RAISE EXCEPTION 'ASC receipt cannot finalize another operation' USING ERRCODE='23514';
  END IF;
  IF candidate.finished_at IS NOT NULL AND NOT (
    (candidate.result='known_not_applied' AND candidate.non_application_basis='pre_dispatch_failure')
    OR (candidate.result='uncertain' AND candidate.uncertainty_reason IN ('transport_lost','claim_expired'))
  ) THEN
    RAISE EXCEPTION 'Provider completion evidence owner is not installed' USING ERRCODE='23514';
  END IF;
END $$;
--> statement-breakpoint

CREATE OR REPLACE FUNCTION actions.guard_execution_attempt() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE e actions.execution; g actions.resource_guard;
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Attempt deletion requires erasure authority' USING ERRCODE='23514'; END IF;
  SELECT * INTO e FROM actions.execution WHERE organization_id=NEW.organization_id AND id=NEW.execution_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Attempt requires its exact execution' USING ERRCODE='23514'; END IF;
  IF TG_OP='UPDATE' THEN
    IF OLD.finished_at IS NOT NULL THEN RAISE EXCEPTION 'Finished attempt is immutable' USING ERRCODE='23514'; END IF;
    IF ROW(NEW.id,NEW.organization_id,NEW.execution_id,NEW.step_id,NEW.number,NEW.kind,NEW.claim_generation,NEW.claim_token,NEW.subject_attempt_id,NEW.input_attempt_id,NEW.input_parent_revision_id,NEW.connector_id,NEW.agent_run_id,NEW.started_at,NEW.recorded_at,NEW.inspection_purpose,NEW.planned_write_step_id,NEW.prewrite_attempt_id,NEW.resource_guard_generation,NEW.cycle_command_id,NEW.capture_digest,NEW.capture_digest_version)
      IS DISTINCT FROM ROW(OLD.id,OLD.organization_id,OLD.execution_id,OLD.step_id,OLD.number,OLD.kind,OLD.claim_generation,OLD.claim_token,OLD.subject_attempt_id,OLD.input_attempt_id,OLD.input_parent_revision_id,OLD.connector_id,OLD.agent_run_id,OLD.started_at,OLD.recorded_at,OLD.inspection_purpose,OLD.planned_write_step_id,OLD.prewrite_attempt_id,OLD.resource_guard_generation,OLD.cycle_command_id,OLD.capture_digest,OLD.capture_digest_version) THEN
      RAISE EXCEPTION 'Attempt admission identity is immutable' USING ERRCODE='23514';
    END IF;
    IF NEW.finished_at IS NULL THEN RAISE EXCEPTION 'An original attempt can only be updated to finalize once' USING ERRCODE='23514'; END IF;
  ELSE
    IF NEW.kind IN ('write','readback','inspection','generation') AND NEW.finished_at IS NOT NULL THEN
      RAISE EXCEPTION 'Original worker attempts must be durably admitted unfinished' USING ERRCODE='23514';
    END IF;
    IF NEW.kind NOT IN ('late_evidence','conflicting_completion') AND NEW.connector_id IS NOT NULL THEN
      PERFORM 1 FROM public.data_connector c WHERE c.id=NEW.connector_id AND c."organizationId"=NEW.organization_id FOR KEY SHARE;
      IF NOT FOUND THEN RAISE EXCEPTION 'Attempt connector must exist in its tenant at admission' USING ERRCODE='23514'; END IF;
    END IF;
    IF NEW.kind NOT IN ('late_evidence','conflicting_completion') AND NEW.agent_run_id IS NOT NULL THEN
      PERFORM 1 FROM public.agent_run r WHERE r.id=NEW.agent_run_id AND r."organizationId"=NEW.organization_id FOR KEY SHARE;
      IF NOT FOUND THEN RAISE EXCEPTION 'Attempt run must exist in its tenant at admission' USING ERRCODE='23514'; END IF;
    END IF;
  END IF;
  PERFORM actions.check_write_capture_shape(NEW);
  PERFORM composition.check_execution_attempt_owner(NEW);
  -- Evidence keeps the original fence; a later worker claim has no authority over it.
  IF NEW.kind IN ('late_evidence','conflicting_completion') THEN RETURN NEW; END IF;
  IF TG_OP='INSERT' AND EXISTS(SELECT 1 FROM actions.execution_attempt c WHERE c.organization_id=NEW.organization_id AND c.execution_id=NEW.execution_id AND c.kind='conflicting_completion') THEN
    RAISE EXCEPTION 'Unresolved capture conflict forbids new automatic interactions' USING ERRCODE='23514';
  END IF;
  IF e.phase<>'claimed' OR e.claim_token IS NULL OR e.claim_expires_at IS NULL THEN
    RAISE EXCEPTION 'Original attempt requires the execution claim' USING ERRCODE='23514';
  END IF;
  IF TG_OP='INSERT' THEN
    -- Current-cycle admission is checked only when issuing a new original.
    -- A later cycle handoff must not prevent retaining an already-issued read.
    IF NEW.kind='readback' AND EXISTS(SELECT 1 FROM actions.command c
      WHERE c.organization_id=NEW.organization_id AND c.cycle_predecessor_command_id=NEW.cycle_command_id) THEN
      RAISE EXCEPTION 'Read admission requires the current recovery cycle' USING ERRCODE='23514';
    END IF;
    IF NEW.claim_generation<>e.claim_generation OR NEW.claim_token<>e.claim_token OR clock_timestamp()>=e.claim_expires_at THEN
      RAISE EXCEPTION 'Attempt admission fence must be current and unexpired' USING ERRCODE='23514';
    END IF;
    IF NEW.kind='write' THEN
      SELECT * INTO g FROM actions.resource_guard WHERE id=e.resource_guard_id FOR UPDATE;
      IF NOT FOUND OR g.holder_organization_id IS DISTINCT FROM e.organization_id OR g.holder_execution_id IS DISTINCT FROM e.id OR g.acquisition_generation IS DISTINCT FROM NEW.resource_guard_generation THEN
        RAISE EXCEPTION 'Write requires the exact held resource generation' USING ERRCODE='23514';
      END IF;
    END IF;
  ELSE
    IF NEW.finalized_claim_generation IS DISTINCT FROM e.claim_generation OR NEW.finalized_claim_token IS DISTINCT FROM e.claim_token
      OR (clock_timestamp()>=e.claim_expires_at AND NOT (
        (NEW.kind='write' AND NEW.result IS NOT DISTINCT FROM 'uncertain' AND NEW.uncertainty_reason IS NOT DISTINCT FROM 'claim_expired')
        OR (NEW.kind='readback' AND NEW.result IS NOT DISTINCT FROM 'unreadable' AND NEW.unreadable_reason::text IS NOT DISTINCT FROM 'claim_expired'))) THEN
      RAISE EXCEPTION 'Attempt finalization requires the exact current fence' USING ERRCODE='23514';
    END IF;
    -- Expiry is database-only uncertainty, never a claim that the write failed.
    IF ((NEW.kind='write' AND NEW.result='uncertain' AND NEW.uncertainty_reason='claim_expired') OR
      (NEW.kind='readback' AND NEW.result='unreadable' AND NEW.unreadable_reason::text='claim_expired')) AND clock_timestamp()<e.claim_expires_at THEN
      RAISE EXCEPTION 'A live claim cannot be classified as expired' USING ERRCODE='23514';
    END IF;
  END IF;
  RETURN NEW;
END $$;
--> statement-breakpoint

CREATE OR REPLACE FUNCTION actions.check_write_capture_shape(candidate actions.execution_attempt) RETURNS void LANGUAGE plpgsql AS $$
DECLARE original actions.execution_attempt;
BEGIN
  IF candidate.kind IN ('write','late_evidence','conflicting_completion') AND candidate.finished_at IS NOT NULL THEN
    IF (candidate.result='acknowledged' AND candidate.failure_class IS NOT NULL)
      OR (candidate.result='known_not_applied' AND candidate.failure_class IS NULL)
      OR (candidate.result='uncertain' AND candidate.uncertainty_reason IS DISTINCT FROM 'claim_expired' AND candidate.failure_class IS NULL)
      OR (candidate.result='uncertain' AND candidate.uncertainty_reason IS NOT DISTINCT FROM 'claim_expired' AND candidate.failure_class IS NOT NULL) THEN
      RAISE EXCEPTION 'Write outcome requires its closed failure-class shape' USING ERRCODE='23514';
    END IF;
  END IF;
  IF candidate.kind NOT IN ('late_evidence','conflicting_completion') THEN RETURN; END IF;
  SELECT * INTO original FROM actions.execution_attempt
    WHERE organization_id=candidate.organization_id AND execution_id=candidate.execution_id
      AND step_id=candidate.step_id AND id=candidate.subject_attempt_id;
  IF NOT FOUND OR original.kind NOT IN ('write','readback') OR candidate.number<=original.number THEN
    RAISE EXCEPTION 'Write capture requires its exact earlier original write' USING ERRCODE='23514';
  END IF;
  IF ROW(candidate.claim_generation,candidate.claim_token,candidate.started_at,candidate.connector_id,
      candidate.agent_run_id,candidate.input_attempt_id,candidate.input_parent_revision_id,
      candidate.inspection_purpose,candidate.planned_write_step_id,candidate.prewrite_attempt_id,
      candidate.resource_guard_generation)
    IS DISTINCT FROM ROW(original.claim_generation,original.claim_token,original.started_at,original.connector_id,
      original.agent_run_id,original.input_attempt_id,original.input_parent_revision_id,
      original.inspection_purpose,original.planned_write_step_id,original.prewrite_attempt_id,
      original.resource_guard_generation) THEN
    RAISE EXCEPTION 'Write capture must preserve the complete original admission identity' USING ERRCODE='23514';
  END IF;
  IF original.kind='readback' THEN
    IF original.finished_at IS NULL OR candidate.finished_at IS NULL OR candidate.finished_at>candidate.recorded_at
      OR candidate.result IS NULL OR candidate.result NOT IN ('matched','mismatch','unreadable')
      OR candidate.unreadable_reason::text IS NOT DISTINCT FROM 'claim_expired'
      OR candidate.failure_class IS NOT NULL
      OR num_nonnulls(candidate.output_kind,candidate.output_revision_id,candidate.output_review_analysis_id,candidate.output_agent_run_id,candidate.no_work_reason)>0 THEN
      RAISE EXCEPTION 'Read capture requires its finished original and closed native observation result' USING ERRCODE='23514';
    END IF;
    RETURN;
  END IF;
  IF candidate.finished_at IS NULL OR candidate.finished_at>candidate.recorded_at
    OR candidate.result IS NULL OR candidate.result NOT IN ('acknowledged','known_not_applied','uncertain')
    OR candidate.uncertainty_reason IS NOT DISTINCT FROM 'claim_expired'
    OR num_nonnulls(candidate.terminal_outcome,candidate.semantic_fingerprint,candidate.fingerprint_version,
      candidate.observation_revision_id,candidate.comparison_version,candidate.observation_surface,
      candidate.observation_completeness,candidate.output_kind,candidate.output_revision_id,
      candidate.output_review_analysis_id,candidate.output_agent_run_id,candidate.no_work_reason)>0 THEN
    RAISE EXCEPTION 'Write capture requires closed original write result fields and original completion time' USING ERRCODE='23514';
  END IF;
END $$;
--> statement-breakpoint

CREATE OR REPLACE FUNCTION app_store_connect.guard_review_receipt() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE a actions.execution_attempt; parent_execution text;
BEGIN
  IF TG_OP<>'INSERT' THEN RAISE EXCEPTION 'ASC attempt receipts are immutable' USING ERRCODE='23514'; END IF;
  SELECT execution_id INTO parent_execution FROM actions.execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.attempt_id;
  -- A new finished evidence parent may be inserted later in this transaction.
  -- The deferred FK and receipt commit trigger require that exact scoped parent.
  IF parent_execution IS NULL THEN RETURN NEW; END IF;
  PERFORM 1 FROM actions.execution WHERE organization_id=NEW.organization_id AND id=parent_execution FOR UPDATE;
  SELECT * INTO a FROM actions.execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.attempt_id;
  IF NOT FOUND OR a.kind NOT IN ('write','readback') OR a.finished_at IS NOT NULL THEN RAISE EXCEPTION 'ASC receipt cannot attach to finalized or non-write history' USING ERRCODE='23514'; END IF;
  -- At this instant the row is unfinished and no receipt has been inserted yet.
  PERFORM composition.check_execution_attempt_owner(a);
  RETURN NEW;
END $$;
--> statement-breakpoint

CREATE OR REPLACE FUNCTION app_store_connect.check_review_receipt_commit() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE a actions.execution_attempt;
BEGIN
  SELECT * INTO a FROM actions.execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.attempt_id;
  IF NOT FOUND OR a.finished_at IS NULL THEN RAISE EXCEPTION 'ASC receipt requires atomic original finalization' USING ERRCODE='23514'; END IF;
  PERFORM composition.check_execution_attempt_owner(a);
  RETURN NULL;
END $$;
--> statement-breakpoint

CREATE OR REPLACE FUNCTION app_store_connect.check_review_write_receipt(candidate actions.execution_attempt) RETURNS void LANGUAGE plpgsql AS $$
DECLARE c composition.operation_contract; r app_store_connect.attempt_receipt; target app_store_connect.review_target; content review_work.reply_content; head actions.revision;
BEGIN
  SELECT oc.* INTO c FROM actions.execution_step s JOIN composition.operation_contract oc ON oc.id=s.operation_contract_id
    WHERE s.organization_id=candidate.organization_id AND s.execution_id=candidate.execution_id AND s.id=candidate.step_id;
  IF NOT FOUND OR c.id IS DISTINCT FROM 'asc.review_response_upsert@1' OR c.provider IS DISTINCT FROM 'app_store_connect' OR c.operation_key IS DISTINCT FROM 'review_response_upsert' OR c.contract_version IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'ASC review receipt requires the exact immutable upsert definition' USING ERRCODE='23514';
  END IF;
  IF candidate.kind NOT IN ('write','late_evidence','conflicting_completion') THEN RAISE EXCEPTION 'ASC review receipt owner requires a write capture' USING ERRCODE='23514'; END IF;
  IF num_nonnulls(candidate.terminal_outcome,candidate.semantic_fingerprint,candidate.fingerprint_version,candidate.observation_revision_id,candidate.comparison_version,candidate.observation_surface,candidate.observation_completeness,candidate.output_kind,candidate.output_revision_id,candidate.output_review_analysis_id,candidate.output_agent_run_id,candidate.no_work_reason)>0 THEN
    RAISE EXCEPTION 'ASC write capture cannot carry readback or generation evidence' USING ERRCODE='23514';
  END IF;
  SELECT rev.* INTO head FROM actions.execution_step s JOIN actions.revision rev ON rev.organization_id=s.organization_id AND rev.id=s.content_revision_id
    WHERE s.organization_id=candidate.organization_id AND s.execution_id=candidate.execution_id AND s.id=candidate.step_id;
  SELECT * INTO target FROM app_store_connect.review_target WHERE organization_id=candidate.organization_id AND revision_id=head.id;
  SELECT * INTO content FROM review_work.reply_content WHERE organization_id=candidate.organization_id AND revision_id=head.id;
  IF head.id IS NULL OR NOT head.sealed OR head.kind<>'review_reply' OR head.purpose<>'proposal' OR target.review_resource_id IS NULL OR target.purpose<>'proposal' OR content.store IS DISTINCT FROM 'ios' THEN
    RAISE EXCEPTION 'ASC review receipt requires its exact sealed and bound review target' USING ERRCODE='23514';
  END IF;
  SELECT * INTO r FROM app_store_connect.attempt_receipt WHERE organization_id=candidate.organization_id AND attempt_id=candidate.id;
  IF r.read_not_sent_reason IS NOT NULL OR r.read_invalid_reason IS NOT NULL THEN
    RAISE EXCEPTION 'ASC write receipt cannot contain read interaction facts' USING ERRCODE='23514';
  END IF;
  IF candidate.finished_at IS NULL THEN
    IF r.attempt_id IS NOT NULL THEN RAISE EXCEPTION 'ASC receipt and attempt finalization must commit together' USING ERRCODE='23514'; END IF;
    RETURN;
  END IF;
  IF (candidate.result='known_not_applied' AND candidate.non_application_basis='pre_dispatch_failure') OR (candidate.result='uncertain' AND candidate.uncertainty_reason IN ('transport_lost','claim_expired')) THEN
    IF r.attempt_id IS NOT NULL THEN RAISE EXCEPTION 'Receipt is forbidden for receipt-free outcomes' USING ERRCODE='23514'; END IF;
    RETURN;
  END IF;
  IF r.attempt_id IS NULL OR r.transport<>'asc_api' THEN RAISE EXCEPTION 'ASC review completion requires its exact API receipt' USING ERRCODE='23514'; END IF;
  IF r.response_kind='accepted' THEN
    IF candidate.result IS DISTINCT FROM 'acknowledged' OR (r.response_body IS NOT NULL AND r.response_body IS DISTINCT FROM content.reply_text) THEN
      RAISE EXCEPTION 'Acknowledgement must retain the accepted exact review response' USING ERRCODE='23514';
    END IF;
  ELSIF r.response_kind='http_error' AND r.error_code IS NOT NULL AND r.response_status IN (400,401,403,409,422,429) THEN
    IF candidate.result IS DISTINCT FROM 'known_not_applied' OR candidate.non_application_basis IS DISTINCT FROM 'provider_rejection' OR candidate.retry_disposition IS NULL OR candidate.failure_class IS NULL THEN
      RAISE EXCEPTION 'ASC decoded rejection requires its neutral non-application shape' USING ERRCODE='23514';
    END IF;
  ELSIF r.response_kind IN ('http_error','invalid_response') THEN
    IF candidate.result IS DISTINCT FROM 'uncertain' OR candidate.uncertainty_reason IS DISTINCT FROM 'invalid_response' THEN
      RAISE EXCEPTION 'Unproved ASC response remains uncertain' USING ERRCODE='23514';
    END IF;
  ELSE RAISE EXCEPTION 'Receipt is not admitted by the ASC upsert operation' USING ERRCODE='23514';
  END IF;
END $$;
--> statement-breakpoint

CREATE OR REPLACE FUNCTION app_store_connect.check_review_revision_seal(revision actions.revision) RETURNS void LANGUAGE plpgsql AS $$
DECLARE content review_work.reply_content; target app_store_connect.review_target;
  baseline app_store_connect.review_target; expected_publication text;
BEGIN
  SELECT * INTO content FROM review_work.reply_content c WHERE c.organization_id = revision.organization_id AND c.revision_id = revision.id;
  IF NOT FOUND OR content.store <> 'ios' THEN RAISE EXCEPTION 'ASC review target requires iOS review content' USING ERRCODE = '23514'; END IF;
  SELECT * INTO target FROM app_store_connect.review_target t WHERE t.organization_id = revision.organization_id AND t.revision_id = revision.id;
  IF NOT FOUND OR target.purpose <> revision.purpose THEN RAISE EXCEPTION 'Missing exact ASC review target leaf' USING ERRCODE = '23514'; END IF;
  IF (target.review_created_date IS NOT NULL AND (NOT app_store_connect.review_native_date_valid(target.review_created_date)
      OR content.review_created_at IS DISTINCT FROM app_store_connect.review_native_date_instant(target.review_created_date)))
    OR (target.response_last_modified_date IS NOT NULL AND (NOT app_store_connect.review_native_date_valid(target.response_last_modified_date)
      OR content.response_modified_at IS DISTINCT FROM app_store_connect.review_native_date_instant(target.response_last_modified_date))) THEN
    RAISE EXCEPTION 'ASC raw metadata must retain its exact available normalized instant' USING ERRCODE='23514';
  END IF;
  IF revision.purpose = 'proposal' THEN
    IF (content.intent = 'update') IS DISTINCT FROM (target.response_id IS NOT NULL) OR target.native_state IS NOT NULL OR target.native_state_source IS NOT NULL THEN
      RAISE EXCEPTION 'ASC updates require the exact existing response identity' USING ERRCODE = '23514';
    END IF;
    IF target.review_resource_id IS NULL THEN
      RAISE EXCEPTION 'ASC proposals require an exact native review identity' USING ERRCODE = '23514';
    END IF;
    SELECT * INTO baseline FROM app_store_connect.review_target t WHERE t.organization_id = revision.organization_id AND t.revision_id = revision.baseline_revision_id;
      IF NOT FOUND OR ROW(baseline.source_asset_data_source_id, baseline.source_connector_id, baseline.credential_kind, baseline.credential_key_id, baseline.credential_team_issuer_id, baseline.review_resource_id, baseline.response_id) IS DISTINCT FROM ROW(target.source_asset_data_source_id, target.source_connector_id, target.credential_kind, target.credential_key_id, target.credential_team_issuer_id, target.review_resource_id, target.response_id) THEN
        RAISE EXCEPTION 'ASC proposal target differs from its captured response baseline' USING ERRCODE = '23514';
      END IF;
  ELSIF content.response_availability = 'present' THEN
    IF target.response_id IS NULL OR target.native_state_source IS NULL THEN
      RAISE EXCEPTION 'ASC observed responses require actual identity and a declared native-state source' USING ERRCODE = '23514';
    END IF;
    -- Current web/client.ts getAppReviews maps unknown/missing pending flags
    -- to NONE (6460-6465); NONE is not publication proof. Current API readback
    -- only trusts PUBLISHED: review-applied-readback.ts compareResponseState.
    expected_publication := CASE
      WHEN content.response_hidden IS TRUE THEN 'hidden'
      WHEN target.native_state_source = 'api_publication' AND target.native_state = 'PUBLISHED' THEN 'published'
      WHEN target.native_state_source = 'api_publication' AND target.native_state = 'PENDING_PUBLISH' THEN 'pending_publication'
      WHEN target.native_state_source = 'browser_pending' AND target.native_state IN ('PENDING_CREATE', 'PENDING_UPDATE') THEN 'pending_publication'
      ELSE 'unreadable'
    END;
    IF content.publication_state::text IS DISTINCT FROM expected_publication THEN
      RAISE EXCEPTION 'ASC native state does not support the claimed neutral publication state' USING ERRCODE = '23514';
    END IF;
  ELSIF target.response_id IS NOT NULL OR target.native_state IS NOT NULL OR target.native_state_source IS NOT NULL THEN
    RAISE EXCEPTION 'Unavailable ASC responses cannot carry invented response facts' USING ERRCODE = '23514';
  END IF;
END $$;
--> statement-breakpoint

--> statement-breakpoint
CREATE OR REPLACE FUNCTION actions.check_attempt_completion_command() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE c actions.command; captured actions.execution_attempt; ticket_id text;
BEGIN
  IF TG_TABLE_NAME='command' THEN
    c:=NEW;
    IF c.kind<>'record_attempt' OR c.outcome<>'accepted' THEN RETURN NULL; END IF;
    SELECT * INTO captured FROM actions.execution_attempt WHERE organization_id=c.organization_id
      AND execution_id=c.progress_execution_id AND step_id=c.progress_step_id AND id=c.progress_subject_attempt_id;
  ELSE
    SELECT * INTO captured FROM actions.execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.id;
    IF captured.finished_at IS NULL THEN RETURN NULL; END IF;
    IF captured.kind IN ('late_evidence','conflicting_completion') THEN
      SELECT * INTO c FROM actions.command WHERE organization_id=captured.organization_id AND id=captured.evidence_command_id;
    ELSIF captured.kind IN ('write','readback','inspection','generation')
      AND NOT (captured.kind='write' AND captured.result='uncertain' AND captured.uncertainty_reason IS NOT DISTINCT FROM 'claim_expired') THEN
      SELECT * INTO c FROM actions.command WHERE organization_id=captured.organization_id
        AND kind='record_attempt' AND outcome='accepted' AND progress_subject_attempt_id=captured.id;
    ELSE RETURN NULL;
    END IF;
  END IF;
  IF captured.id IS NULL OR captured.finished_at IS NULL OR c.id IS NULL
    OR c.kind<>'record_attempt' OR c.outcome<>'accepted' OR c.principal_kind<>'system' OR c.channel<>'worker'
    OR c.progress_execution_id IS DISTINCT FROM captured.execution_id
    OR c.progress_step_id IS DISTINCT FROM captured.step_id
    OR c.progress_subject_attempt_id IS DISTINCT FROM captured.id
    OR c.accepted_at<captured.finished_at
    OR (captured.kind IN ('late_evidence','conflicting_completion') AND captured.evidence_command_id IS DISTINCT FROM c.id) THEN
    RAISE EXCEPTION 'Captured completion requires its exact accepted system command' USING ERRCODE='23514';
  END IF;
  SELECT ap.action_id INTO ticket_id FROM actions.execution e JOIN actions.approval ap
    ON ap.organization_id=e.organization_id AND ap.id=e.approval_id
    WHERE e.organization_id=captured.organization_id AND e.id=captured.execution_id;
  IF NOT EXISTS(SELECT 1 FROM actions.command_target t WHERE t.organization_id=c.organization_id
    AND t.command_id=c.id AND t.action_id=ticket_id) OR EXISTS(SELECT 1 FROM actions.command_target t
    WHERE t.organization_id=c.organization_id AND t.command_id=c.id AND t.action_id<>ticket_id) THEN
    RAISE EXCEPTION 'Captured completion history must target its exact approved ticket' USING ERRCODE='23514';
  END IF;
  -- Completion history references the exact capture observation, including
  -- NULL for a read that obtained no native observation. Late/conflict rows
  -- derive their interaction kind from the retained original, never arrival order.
  IF (captured.kind='readback' OR (captured.kind IN ('late_evidence','conflicting_completion')
    AND EXISTS(SELECT 1 FROM actions.execution_attempt original WHERE original.organization_id=captured.organization_id
      AND original.execution_id=captured.execution_id AND original.step_id=captured.step_id
      AND original.id=captured.subject_attempt_id AND original.kind='readback')))
    AND EXISTS(SELECT 1 FROM actions.command_target t WHERE t.organization_id=c.organization_id
      AND t.command_id=c.id AND t.action_id=ticket_id
      AND t.evidence_revision_id IS DISTINCT FROM captured.observation_revision_id) THEN
    RAISE EXCEPTION 'Read completion history must reference its exact observation or explicit absence of evidence' USING ERRCODE='23514';
  END IF;
  PERFORM composition.check_execution_attempt_owner(captured);
  RETURN NULL;
END $$;

-- 0159_chunky_maggott.sql
-- Generated index definition: CREATE INDEX "aso_experiment_applied_sweep_idx"
-- ON "aso_experiment" USING btree ("createdAt","id" COLLATE "C")
-- WHERE "aso_experiment"."status" = 'applied';
-- A populated table must be prepared CONCURRENTLY outside the migration's
-- transaction. See docs/aso-applied-sweep-index-preparation.md.
DO $applied_sweep_index$
DECLARE
  index_id oid;
  previous_lock_timeout text := current_setting('lock_timeout');
BEGIN
  IF NOT pg_try_advisory_xact_lock(hashtextextended('fload:aso-applied-sweep-index', 0)) THEN
    RAISE EXCEPTION 'Applied sweep index preparation or migration is already running';
  END IF;
  PERFORM set_config('lock_timeout', '5s', true);
  -- Stabilize the index definition while allowing ordinary row writes when
  -- an operator already prepared it. Only a missing index needs the stronger
  -- lock below, to prove emptiness without racing an insert.
  LOCK TABLE public.aso_experiment IN SHARE UPDATE EXCLUSIVE MODE;
  index_id := to_regclass('public.aso_experiment_applied_sweep_idx');
  IF index_id IS NULL THEN
    LOCK TABLE public.aso_experiment IN SHARE MODE;
    -- Physical emptiness under this lock is sufficient. A previously populated
    -- heap remains conservative: do not trust row estimates or scan its rows.
    IF pg_relation_size('public.aso_experiment'::regclass) <> 0 THEN
      RAISE EXCEPTION 'Prepare public.aso_experiment_applied_sweep_idx before migration: run packages/database/scripts/prepare-aso-applied-sweep-index.ts --database-name NAME --execute with the explicitly selected DATABASE_URL';
    END IF;
    CREATE INDEX aso_experiment_applied_sweep_idx ON public.aso_experiment USING btree ("createdAt", id COLLATE "C") WHERE status='applied';
    index_id := 'public.aso_experiment_applied_sweep_idx'::regclass;
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_index i JOIN pg_class c ON c.oid=i.indexrelid
    WHERE i.indexrelid=index_id AND i.indrelid='public.aso_experiment'::regclass AND c.relkind='i'
      AND NOT i.indisunique AND i.indisvalid AND i.indisready AND i.indislive AND i.indimmediate
      AND NOT i.indisprimary AND NOT i.indisexclusion AND NOT i.indnullsnotdistinct
      AND i.indnkeyatts=2 AND i.indnatts=2 AND i.indpred IS NOT NULL AND i.indexprs IS NULL
      AND pg_get_indexdef(i.indexrelid,0,false)='CREATE INDEX aso_experiment_applied_sweep_idx ON public.aso_experiment USING btree ("createdAt", id COLLATE "C") WHERE (status = ''applied''::text)'
      AND NOT EXISTS(SELECT 1 FROM pg_constraint k WHERE k.conindid=i.indexrelid)
  ) THEN
    RAISE EXCEPTION 'public.aso_experiment_applied_sweep_idx has a mismatched definition, constraint owner, or invalid build state; operator inspection is required';
  END IF;
  PERFORM set_config('lock_timeout', previous_lock_timeout, true);
END;
$applied_sweep_index$;
