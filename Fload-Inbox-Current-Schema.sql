-- FLO-1355 design contract. This is NOT a production migration.
-- Run only through the isolated design harness, with referenced domain tables supplied.
CREATE SCHEMA actions_design;
SET search_path = actions_design, public;

CREATE TYPE action_decision AS ENUM ('open','approved','declined','acknowledged','cancelled','superseded');
CREATE TYPE action_revision_purpose AS ENUM ('proposal','baseline','observation');
CREATE TYPE action_principal AS ENUM ('user','api_key','agent','policy','system');
CREATE TYPE action_channel AS ENUM ('web','chat','mcp','api','slack','discord','agent','worker','operator','migration');
CREATE TYPE action_command_kind AS ENUM ('create','revise','approve','undo','reject','acknowledge','snooze','unsnooze','assign','archive','restore','supersede','retry','reconcile','record_observation','record_attempt','resolve_dependency','grant_policy','revoke_policy');
CREATE TYPE action_command_outcome AS ENUM ('accepted','conflict','refused');
CREATE TYPE action_command_error AS ENUM ('stale_version','stale_revision','stale_membership','invalid_transition','undo_expired','execution_started','unresolved_write','permission_changed','billing_required','unsupported_operation','idempotency_mismatch','target_changed');
CREATE TYPE action_authorization_scope AS ENUM ('perform','generate','revise');
CREATE TYPE action_execution_phase AS ENUM ('ready','claimed','verification_due','uncertain','blocked','settled','cancelled');
CREATE TYPE action_execution_result AS ENUM ('generated','verified_live','verified_editable','handled_externally','acknowledged_only','failed','cancelled');
CREATE TYPE action_attempt_kind AS ENUM ('write','readback','generation','late_evidence');
CREATE TYPE action_attempt_result AS ENUM ('acknowledged','known_not_applied','uncertain','matched','mismatch','unreadable','generated','discarded');
CREATE TYPE action_transport AS ENUM ('asc_api','asc_browser','play_api','play_session','play_browser','asa_api','internal');
CREATE TYPE action_recovery_mode AS ENUM ('readback_before_retry','native_idempotency','manual_reconciliation','internal_atomic');
CREATE TYPE action_hold_reason AS ENUM ('permission','billing','resource_busy','target_changed','uncertain_write','retry_exhausted','unsupported_readback','generation_conflict','awaiting_release');
CREATE TYPE action_surface AS ENUM ('provider_response','editable_listing','live_listing','review_response','advertising_resource','internal_artifact');
CREATE TYPE action_failure_class AS ENUM ('permission','rate_limit','transport','target_changed','provider_rejected','persistence','unsupported_readback','invalid_content','billing');
CREATE TYPE action_dependency_requirement AS ENUM ('completed','verified_live','verified_editable','generated','permission_restored','release_available');
CREATE TYPE action_alias_namespace AS ENUM ('pending_action','pending_action_batch','review_draft','review_draft_batch','agent_request','agent_activity','review_history','review_draft_rejection','capability_execution','recommendation','recommendation_variant','recovery_receipt');

CREATE TABLE action (
 id text PRIMARY KEY,
 organization_id text NOT NULL,
 creation_key uuid NOT NULL DEFAULT gen_random_uuid(),
 asset_id text,
 domain text NOT NULL CHECK(domain IN ('reviews','listing','ads','agent','advisory','collection')),
 parent_action_id text,
 decision action_decision NOT NULL DEFAULT 'open',
 version bigint NOT NULL DEFAULT 1 CHECK (version > 0),
 attention_version bigint NOT NULL DEFAULT 1 CHECK (attention_version > 0),
 current_revision_id text,
 current_approval_id text,
 owner_user_id text,
 priority smallint NOT NULL DEFAULT 2 CHECK (priority BETWEEN 1 AND 3),
 snoozed_until timestamptz,
 archived_at timestamptz,
 successor_action_id text,
 created_at timestamptz NOT NULL,
 updated_at timestamptz NOT NULL,
 UNIQUE (organization_id,id),
 UNIQUE (organization_id,creation_key),
 CHECK (updated_at >= created_at),
 CHECK ((decision='superseded')=(successor_action_id IS NOT NULL)),
 CHECK (successor_action_id IS DISTINCT FROM id),
 CHECK (parent_action_id IS DISTINCT FROM id),
 FOREIGN KEY (organization_id,parent_action_id) REFERENCES action(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,successor_action_id) REFERENCES action(organization_id,id) DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE action_command (
 id text PRIMARY KEY,
 organization_id text NOT NULL,
 idempotency_key uuid NOT NULL,
 principal_kind action_principal NOT NULL,
 actor_user_id text,
 actor_api_key_id text,
 actor_agent_run_id text,
 actor_policy_revision_id text,
 target_policy_revision_id text,
 actor_subject_snapshot text NOT NULL,
 actor_name_snapshot text,
 channel action_channel NOT NULL,
 external_actor_id text,
 kind action_command_kind NOT NULL,
 request_digest char(64) NOT NULL CHECK (request_digest ~ '^[0-9a-f]{64}$'),
 digest_version integer NOT NULL CHECK (digest_version > 0),
 outcome action_command_outcome NOT NULL,
 error action_command_error,
 message text,
 accepted_at timestamptz NOT NULL,
 UNIQUE (organization_id,id),
 UNIQUE (organization_id,principal_kind,actor_subject_snapshot,idempotency_key),
 CHECK ((outcome='accepted')=(error IS NULL)),
 CHECK (principal_kind NOT IN ('user','api_key') OR actor_user_id IS NOT NULL),
 CHECK ((principal_kind='api_key')=(actor_api_key_id IS NOT NULL)),
 CHECK ((principal_kind='policy')=(actor_policy_revision_id IS NOT NULL)),
 CHECK (principal_kind<>'agent' OR actor_agent_run_id IS NOT NULL),
 CHECK (kind NOT IN ('grant_policy','revoke_policy') OR target_policy_revision_id IS NOT NULL)
);

CREATE TABLE action_revision (
 id text PRIMARY KEY,
 organization_id text NOT NULL,
 action_id text NOT NULL,
 purpose action_revision_purpose NOT NULL,
 kind text NOT NULL, -- constrained to the exact closed family set in schema-guards.sql
 operation text NOT NULL, -- constrained to the enumerated operation/family matrix
 revision_number bigint NOT NULL CHECK (revision_number>0),
 authored_command_id text NOT NULL,
 baseline_revision_id text,
 generated_from_revision_id text,
 title text NOT NULL,
 summary text NOT NULL,
 rationale text,
 content_digest char(64) NOT NULL CHECK (content_digest ~ '^[0-9a-f]{64}$'),
 canonicalization_version integer NOT NULL CHECK (canonicalization_version>0),
 sealed boolean NOT NULL DEFAULT false,
 created_at timestamptz NOT NULL,
 UNIQUE (organization_id,id),
 UNIQUE (organization_id,action_id,id),
 UNIQUE (action_id,revision_number),
 FOREIGN KEY (organization_id,action_id) REFERENCES action(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,authored_command_id) REFERENCES action_command(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,action_id,baseline_revision_id) REFERENCES action_revision(organization_id,action_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,action_id,generated_from_revision_id) REFERENCES action_revision(organization_id,action_id,id) DEFERRABLE INITIALLY DEFERRED,
 CHECK (id IS DISTINCT FROM baseline_revision_id AND id IS DISTINCT FROM generated_from_revision_id)
);
ALTER TABLE action ADD FOREIGN KEY (organization_id,id,current_revision_id) REFERENCES action_revision(organization_id,action_id,id) DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE action_membership (
 organization_id text NOT NULL,
 parent_revision_id text NOT NULL,
 child_action_id text NOT NULL,
 child_revision_id text NOT NULL,
 ordinal integer NOT NULL CHECK (ordinal>=0),
 PRIMARY KEY (parent_revision_id,child_action_id),
 UNIQUE (parent_revision_id,ordinal),
 FOREIGN KEY (organization_id,parent_revision_id) REFERENCES action_revision(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,child_action_id,child_revision_id) REFERENCES action_revision(organization_id,action_id,id) DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE action_dependency (
 organization_id text NOT NULL,
 dependent_action_id text NOT NULL,
 prerequisite_action_id text NOT NULL,
 requirement action_dependency_requirement NOT NULL,
 created_command_id text NOT NULL,
 PRIMARY KEY (dependent_action_id,prerequisite_action_id,requirement),
 CHECK (dependent_action_id<>prerequisite_action_id),
 FOREIGN KEY (organization_id,dependent_action_id) REFERENCES action(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,prerequisite_action_id) REFERENCES action(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,created_command_id) REFERENCES action_command(organization_id,id) DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE action_command_target (
 organization_id text NOT NULL,
 command_id text NOT NULL,
 action_id text NOT NULL,
 expected_version bigint,
 expected_revision_id text,
 expected_parent_revision_id text,
 previous_version bigint,
 result_version bigint NOT NULL CHECK (result_version>0),
 previous_decision action_decision,
 result_decision action_decision NOT NULL,
 previous_revision_id text,
 result_revision_id text,
 previous_owner_user_id text,
 result_owner_user_id text,
 previous_snoozed_until timestamptz,
 result_snoozed_until timestamptz,
 previous_archived_at timestamptz,
 result_archived_at timestamptz,
 PRIMARY KEY (command_id,action_id),
 UNIQUE (organization_id,command_id,action_id),
 FOREIGN KEY (organization_id,command_id) REFERENCES action_command(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,action_id) REFERENCES action(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,action_id,expected_revision_id) REFERENCES action_revision(organization_id,action_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,action_id,previous_revision_id) REFERENCES action_revision(organization_id,action_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,action_id,result_revision_id) REFERENCES action_revision(organization_id,action_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,expected_parent_revision_id) REFERENCES action_revision(organization_id,id) DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE action_policy_revision (
 id text PRIMARY KEY,
 organization_id text NOT NULL,
 asset_id text NOT NULL,
 granted_by_command_id text NOT NULL,
 policy_kind text NOT NULL CHECK (policy_kind IN ('review_auto_reply','agent_generation')),
 revision_number bigint NOT NULL CHECK (revision_number>0),
 minimum_rating smallint CHECK (minimum_rating BETWEEN 1 AND 5),
 maximum_rating smallint CHECK (maximum_rating BETWEEN 1 AND 5),
 allow_initial_reply boolean NOT NULL,
 allow_replace_reply boolean NOT NULL DEFAULT false,
 allow_generation boolean NOT NULL,
 rule_version integer NOT NULL CHECK (rule_version>0),
 revoked_by_command_id text,
 revoked_at timestamptz,
 created_at timestamptz NOT NULL,
 UNIQUE (organization_id,id),
 UNIQUE (organization_id,asset_id,policy_kind,revision_number),
 CHECK (minimum_rating IS NULL OR maximum_rating>=minimum_rating),
 CHECK (policy_kind<>'agent_generation' OR (NOT allow_initial_reply AND NOT allow_replace_reply)),
 CHECK ((revoked_by_command_id IS NULL)=(revoked_at IS NULL)),
 FOREIGN KEY (organization_id,revoked_by_command_id) REFERENCES action_command(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,granted_by_command_id) REFERENCES action_command(organization_id,id) DEFERRABLE INITIALLY DEFERRED
);
CREATE UNIQUE INDEX action_policy_one_active ON action_policy_revision(organization_id,asset_id,policy_kind) WHERE revoked_at IS NULL;
ALTER TABLE action_command ADD FOREIGN KEY (organization_id,actor_policy_revision_id) REFERENCES action_policy_revision(organization_id,id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE action_command ADD FOREIGN KEY (organization_id,target_policy_revision_id) REFERENCES action_policy_revision(organization_id,id) DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE action_approval (
 id text PRIMARY KEY,
 organization_id text NOT NULL,
 action_id text NOT NULL,
 revision_id text NOT NULL,
 command_id text NOT NULL,
 scope action_authorization_scope NOT NULL,
 policy_revision_id text,
 parent_revision_id text,
 undo_deadline timestamptz NOT NULL,
 required_surface action_surface NOT NULL,
 authorization_version integer NOT NULL CHECK (authorization_version>0),
 created_at timestamptz NOT NULL,
 UNIQUE (organization_id,id),
 UNIQUE (organization_id,action_id,id),
 UNIQUE (command_id,action_id),
 CHECK (undo_deadline>=created_at),
 FOREIGN KEY (organization_id,action_id,revision_id) REFERENCES action_revision(organization_id,action_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,command_id,action_id) REFERENCES action_command_target(organization_id,command_id,action_id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,policy_revision_id) REFERENCES action_policy_revision(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,parent_revision_id) REFERENCES action_revision(organization_id,id) DEFERRABLE INITIALLY DEFERRED
);

ALTER TABLE action ADD FOREIGN KEY (organization_id,id,current_approval_id) REFERENCES action_approval(organization_id,action_id,id) DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE action_execution (
 id text PRIMARY KEY,
 organization_id text NOT NULL,
 approval_id text NOT NULL UNIQUE,
 phase action_execution_phase NOT NULL,
 next_run_at timestamptz,
 next_step_id text,
 schedule_generation bigint NOT NULL DEFAULT 1 CHECK (schedule_generation>0),
 claim_generation bigint NOT NULL DEFAULT 0 CHECK (claim_generation>=0),
 claim_token uuid,
 claim_expires_at timestamptz,
 hold_reason action_hold_reason,
 result action_execution_result,
 created_at timestamptz NOT NULL,
 settled_at timestamptz,
 UNIQUE (organization_id,id),
 FOREIGN KEY (organization_id,approval_id) REFERENCES action_approval(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 CHECK ((claim_token IS NULL)=(claim_expires_at IS NULL)),
 CHECK ((phase='claimed')=(claim_token IS NOT NULL)),
 CHECK ((phase IN ('settled','cancelled'))=(settled_at IS NOT NULL)),
 CHECK ((phase IN ('settled','cancelled'))=(result IS NOT NULL)),
 CHECK (phase NOT IN ('ready','verification_due') OR next_run_at IS NOT NULL),
 CHECK (phase NOT IN ('settled','cancelled') OR next_run_at IS NULL),
 CHECK (phase<>'uncertain' OR hold_reason='uncertain_write')
);

CREATE TABLE action_execution_step (
 id text PRIMARY KEY,
 organization_id text NOT NULL,
 execution_id text NOT NULL,
 ordinal integer NOT NULL CHECK (ordinal>=0),
 kind text NOT NULL, -- exhaustive closed step CHECK added with provider matrix
 adapter_version integer NOT NULL CHECK (adapter_version>0),
 input_step_id text,
 content_revision_id text NOT NULL,
 media_slot integer CHECK (media_slot>=0),
 upload_offset bigint CHECK (upload_offset>=0),
 upload_length bigint CHECK (upload_length>0),
 recovery_mode action_recovery_mode NOT NULL,
 recovery_policy_version integer NOT NULL CHECK (recovery_policy_version>0),
 native_idempotency_key text,
 required_surface action_surface NOT NULL,
 UNIQUE (organization_id,id),
 UNIQUE (organization_id,execution_id,id),
 UNIQUE (execution_id,ordinal),
 CHECK (id IS DISTINCT FROM input_step_id),
 CHECK ((recovery_mode='native_idempotency')=(native_idempotency_key IS NOT NULL)),
 CHECK ((upload_offset IS NULL)=(upload_length IS NULL)),
 FOREIGN KEY (organization_id,execution_id) REFERENCES action_execution(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,execution_id,input_step_id) REFERENCES action_execution_step(organization_id,execution_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,content_revision_id) REFERENCES action_revision(organization_id,id) DEFERRABLE INITIALLY DEFERRED
);
ALTER TABLE action_execution ADD FOREIGN KEY (organization_id,id,next_step_id) REFERENCES action_execution_step(organization_id,execution_id,id) DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE action_execution_attempt (
 id text PRIMARY KEY,
 organization_id text NOT NULL,
 step_id text,
 number integer CHECK (number>0),
 kind action_attempt_kind NOT NULL,
 claim_generation bigint CHECK (claim_generation>0),
 subject_attempt_id text,
 agent_run_id text,
 connector_id text,
 transport action_transport,
 started_at timestamptz,
 finished_at timestamptz,
 result action_attempt_result,
 observation_revision_id text,
 comparison_version integer CHECK (comparison_version>0),
 provider_request_id text,
 provider_resource_id text,
 provider_version text,
 provider_edit_id text,
 provider_localization_id text,
 provider_media_id text,
 provider_error_code text,
 failure_class action_failure_class,
 recorded_at timestamptz NOT NULL,
 UNIQUE (organization_id,id),
 UNIQUE (step_id,number),
 FOREIGN KEY (organization_id,step_id) REFERENCES action_execution_step(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,subject_attempt_id) REFERENCES action_execution_attempt(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 FOREIGN KEY (organization_id,observation_revision_id) REFERENCES action_revision(organization_id,id) DEFERRABLE INITIALLY DEFERRED,
 CHECK (id IS DISTINCT FROM subject_attempt_id),
 CHECK (step_id IS NOT NULL AND number IS NOT NULL AND claim_generation IS NOT NULL AND started_at IS NOT NULL AND transport IS NOT NULL),
 CHECK ((finished_at IS NULL)=(result IS NULL)),
 CHECK (finished_at IS NULL OR started_at IS NULL OR finished_at>=started_at),
 CHECK (kind NOT IN ('readback','late_evidence') OR subject_attempt_id IS NOT NULL),
 CHECK (result NOT IN ('matched','mismatch') OR (observation_revision_id IS NOT NULL AND comparison_version IS NOT NULL))
);

-- Provider-level exclusion is global across organizations that address the same remote app/account.
-- A lost lease is NOT permission to clear this guard. Keep uncertain holders until reconciliation.
CREATE TABLE action_resource_guard (
 provider text NOT NULL CHECK (provider IN ('app_store_connect','google_play','apple_search_ads')),
 provider_account_id text NOT NULL,
 remote_application_id text NOT NULL,
 holder_organization_id text,
 holder_execution_id text,
 acquired_at timestamptz,
 PRIMARY KEY (provider,provider_account_id,remote_application_id),
 CHECK ((holder_execution_id IS NULL)=(holder_organization_id IS NULL)),
 CHECK ((holder_execution_id IS NULL)=(acquired_at IS NULL)),
 FOREIGN KEY (holder_organization_id,holder_execution_id) REFERENCES action_execution(organization_id,id) DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE action_read (
 organization_id text NOT NULL,
 user_id text NOT NULL,
 action_id text NOT NULL,
 seen_attention_version bigint NOT NULL CHECK (seen_attention_version>=0),
 force_unread boolean NOT NULL DEFAULT false,
 updated_at timestamptz NOT NULL,
 PRIMARY KEY (organization_id,user_id,action_id),
 FOREIGN KEY (organization_id,action_id) REFERENCES action(organization_id,id) DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE action_alias (
 organization_id text NOT NULL,
 namespace action_alias_namespace NOT NULL,
 old_id text NOT NULL,
 action_id text NOT NULL,
 historical_membership_known boolean NOT NULL,
 PRIMARY KEY (organization_id,namespace,old_id),
 FOREIGN KEY (organization_id,action_id) REFERENCES action(organization_id,id) DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX action_scope_page ON action(organization_id,created_at DESC,id DESC);
CREATE INDEX action_open_scope ON action(organization_id,decision,created_at DESC,id DESC) WHERE archived_at IS NULL;
CREATE INDEX action_owner_scope ON action(organization_id,owner_user_id,created_at DESC,id DESC);
CREATE INDEX action_execution_due ON action_execution(next_run_at,id) WHERE phase IN ('ready','verification_due','uncertain');
CREATE INDEX action_execution_expired_claim ON action_execution(claim_expires_at,id) WHERE phase='claimed';
CREATE INDEX action_membership_child ON action_membership(child_action_id,parent_revision_id);
CREATE INDEX action_attempt_step_history ON action_execution_attempt(step_id,number);
CREATE INDEX action_command_target_timeline ON action_command_target(action_id,result_version,command_id);


-- FLO-1355 DESIGN CONTRACT ONLY. Not a deployable migration.
-- Requires actions_design.action_revision UNIQUE (organization_id,id).
-- All content is immutable once its owning revision is sealed.
-- Cross-table validation requirements are listed at the end.

CREATE TYPE actions_design.store_kind AS ENUM ('ios','android');
CREATE TYPE actions_design.content_value_state AS ENUM ('unspecified','present','empty','dismissed','unreadable');
CREATE TYPE actions_design.reply_intent AS ENUM ('send','update','observed');
CREATE TYPE actions_design.listing_intent AS ENUM ('create','update','repair','restore','observed');
CREATE TYPE actions_design.term_role AS ENUM ('added','removed','gloss','trending');
CREATE TYPE actions_design.media_kind AS ENUM ('screenshot','icon','app_preview');
CREATE TYPE actions_design.media_availability AS ENUM ('stored','missing','unreadable');
CREATE TYPE actions_design.request_intent AS ENUM ('locale_expansion','listing_change','review_catch_up','review_analysis','wake_agent','propose_experiment','revert_experiment','restore_listing');
CREATE TYPE actions_design.approval_setting AS ENUM ('auto','await');
CREATE TYPE actions_design.request_origin AS ENUM ('scheduled_agent','user_directed_chat_or_mcp','human','system');
CREATE TYPE actions_design.recommendation_kind AS ENUM ('keywords','promotional_text','description','screenshots','icon','app_previews','title_subtitle','cpp','short_description','title','subtitle','locale_expansion');
CREATE TYPE actions_design.advisory_connector_kind AS ENUM ('app_store_connect','apple_search_ads');
CREATE TYPE actions_design.closed_severity AS ENUM ('low','medium','high');
CREATE TYPE actions_design.research_coverage AS ENUM ('ready','cold');
CREATE TYPE actions_design.gloss_status AS ENUM ('updating','ready','unavailable');
CREATE TYPE actions_design.country_role AS ENUM ('demand','competitor');
CREATE TYPE actions_design.prose_section AS ENUM ('what_will_happen','supporting_evidence','description_outline','prioritization','notes','unblock_steps');
CREATE TYPE actions_design.ad_match_type AS ENUM ('EXACT','BROAD');
CREATE TYPE actions_design.advisory_kind AS ENUM ('optimize_keywords','improve_retention','adjust_monetization','update_store_listing','review_finding','aso_review_needed','agent_attention_needed','onboarding_audit_recommendation','connect_source','store_app_access_lost','flag_issue','escalate','stage_blocker');
CREATE TYPE actions_design.observation_availability AS ENUM ('present','absent','unreadable','pending','unknown');

CREATE TABLE actions_design.action_review_content (
  organization_id text NOT NULL,
  revision_id text NOT NULL,
  provider_account_id text NOT NULL,
  store actions_design.store_kind NOT NULL,
  provider_app_id text NOT NULL,
  provider_review_id text NOT NULL,
  apple_review_resource_id text,
  intent actions_design.reply_intent NOT NULL,
  reply_text text,
  original_ai_revision_id text,
  baseline_revision_id text,
  detected_language_name text,
  review_rating integer CHECK (review_rating BETWEEN 1 AND 5),
  review_title text,
  review_body text,
  review_nickname text,
  review_storefront text,
  review_app_version text,
  review_modified_at timestamptz,
  review_edited boolean,
  response_availability actions_design.observation_availability NOT NULL,
  provider_response_id text,
  provider_response_text text,
  provider_response_modified_at timestamptz,
  provider_response_hidden boolean,
  provider_response_state_text text,
  observation_captured_at timestamptz,
  PRIMARY KEY (organization_id,revision_id),
  FOREIGN KEY (organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  FOREIGN KEY (organization_id,original_ai_revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  FOREIGN KEY (organization_id,baseline_revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK (intent NOT IN ('send','update') OR (reply_text IS NOT NULL AND length(reply_text) > 0)),
  CHECK (intent <> 'update' OR baseline_revision_id IS NOT NULL),
  CHECK (response_availability <> 'present' OR provider_response_text IS NOT NULL),
  CHECK (response_availability <> 'absent' OR (provider_response_id IS NULL AND provider_response_text IS NULL))
);

CREATE TABLE actions_design.action_listing_content (
  organization_id text NOT NULL,
  revision_id text NOT NULL,
  provider_account_id text NOT NULL,
  store actions_design.store_kind NOT NULL,
  locale text NOT NULL CHECK (length(locale)>0),
  intent actions_design.listing_intent NOT NULL,
  provider_app_id text,
  package_name text,
  app_info_id text,
  app_info_localization_id text,
  app_version_id text,
  app_version_localization_id text,
  google_edit_id text,
  baseline_revision_id text,
  title_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', title text,
  subtitle_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', subtitle text,
  description_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', description text,
  keywords_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', keywords text,
  promotional_text_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', promotional_text text,
  short_description_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', short_description text,
  whats_new_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', whats_new text,
  support_url_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', support_url text,
  keyword_analysis text,
  operator_instructions text,
  source_fingerprint text,
  naturalness_check_skipped boolean,
  fidelity_check_skipped boolean,
  english_title text,
  english_subtitle text,
  english_promotional_text text,
  gloss_status actions_design.gloss_status,
  research_country text,
  research_coverage actions_design.research_coverage,
  research_model_source text,
  research_model_version text,
  research_model_formula text,
  app_tier integer CHECK (app_tier BETWEEN 1 AND 3),
  app_tier_resolved boolean,
  candidate_count bigint CHECK (candidate_count>=0),
  judged_count bigint CHECK (judged_count>=0),
  scored_count bigint CHECK (scored_count>=0),
  p0_count bigint CHECK (p0_count>=0),
  p1_count bigint CHECK (p1_count>=0),
  p2_count bigint CHECK (p2_count>=0),
  with_volume_count bigint CHECK (with_volume_count>=0),
  conformance_term_count bigint CHECK (conformance_term_count>=0),
  conformance_from_table_count bigint CHECK (conformance_from_table_count>=0),
  observation_availability actions_design.observation_availability,
  provider_state_text text,
  observation_captured_at timestamptz,
  source_capture_at timestamptz,
  PRIMARY KEY (organization_id,revision_id),
  FOREIGN KEY (organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  FOREIGN KEY (organization_id,baseline_revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK ((title_state='present' AND title IS NOT NULL AND length(title)>0) OR (title_state='dismissed' AND title IS NOT NULL) OR (title_state='empty' AND title IS NOT NULL AND title='') OR (title_state IN ('unspecified','unreadable') AND title IS NULL)),
  CHECK ((subtitle_state='present' AND subtitle IS NOT NULL AND length(subtitle)>0) OR (subtitle_state='dismissed' AND subtitle IS NOT NULL) OR (subtitle_state='empty' AND subtitle IS NOT NULL AND subtitle='') OR (subtitle_state IN ('unspecified','unreadable') AND subtitle IS NULL)),
  CHECK ((description_state='present' AND description IS NOT NULL AND length(description)>0) OR (description_state='dismissed' AND description IS NOT NULL) OR (description_state='empty' AND description IS NOT NULL AND description='') OR (description_state IN ('unspecified','unreadable') AND description IS NULL)),
  CHECK ((keywords_state='present' AND keywords IS NOT NULL AND length(keywords)>0) OR (keywords_state='dismissed' AND keywords IS NOT NULL) OR (keywords_state='empty' AND keywords IS NOT NULL AND keywords='') OR (keywords_state IN ('unspecified','unreadable') AND keywords IS NULL)),
  CHECK ((promotional_text_state='present' AND promotional_text IS NOT NULL AND length(promotional_text)>0) OR (promotional_text_state='dismissed' AND promotional_text IS NOT NULL) OR (promotional_text_state='empty' AND promotional_text IS NOT NULL AND promotional_text='') OR (promotional_text_state IN ('unspecified','unreadable') AND promotional_text IS NULL)),
  CHECK ((short_description_state='present' AND short_description IS NOT NULL AND length(short_description)>0) OR (short_description_state='dismissed' AND short_description IS NOT NULL) OR (short_description_state='empty' AND short_description IS NOT NULL AND short_description='') OR (short_description_state IN ('unspecified','unreadable') AND short_description IS NULL)),
  CHECK ((whats_new_state='present' AND whats_new IS NOT NULL AND length(whats_new)>0) OR (whats_new_state='dismissed' AND whats_new IS NOT NULL) OR (whats_new_state='empty' AND whats_new IS NOT NULL AND whats_new='') OR (whats_new_state IN ('unspecified','unreadable') AND whats_new IS NULL)),
  CHECK ((support_url_state='present' AND support_url IS NOT NULL AND length(support_url)>0) OR (support_url_state='dismissed' AND support_url IS NOT NULL) OR (support_url_state='empty' AND support_url IS NOT NULL AND support_url='') OR (support_url_state IN ('unspecified','unreadable') AND support_url IS NULL)),
  CHECK (conformance_from_table_count IS NULL OR conformance_term_count IS NULL OR conformance_from_table_count<=conformance_term_count)
);

CREATE TABLE actions_design.action_content_term (
  organization_id text NOT NULL, revision_id text NOT NULL,
  role actions_design.term_role NOT NULL, ordinal integer NOT NULL CHECK(ordinal>=0),
  term text NOT NULL, meaning text,
  PRIMARY KEY(organization_id,revision_id,role,ordinal),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK ((role='gloss' AND meaning IS NOT NULL) OR (role<>'gloss' AND meaning IS NULL))
);

CREATE TABLE actions_design.action_media_content (
  organization_id text NOT NULL, revision_id text NOT NULL,
  slot integer NOT NULL CHECK(slot>=0), kind actions_design.media_kind NOT NULL,
  store actions_design.store_kind NOT NULL, locale text NOT NULL, source_locale text,
  display_type text, source_provider_resource_id text,
  source_object_key text, source_object_version text, source_digest text,
  output_object_key text, output_object_version text, output_digest text,
  availability actions_design.media_availability NOT NULL,
  mime_type text CHECK(mime_type IN ('image/png','image/jpeg','image/webp','video/mp4','video/quicktime')),
  width integer CHECK(width>0), height integer CHECK(height>0), byte_length bigint CHECK(byte_length>=0),
  generation_prompt text, generated_at timestamptz,
  storyboard_intent text, caption text, first_slot_hook_guidance text,
  PRIMARY KEY(organization_id,revision_id,slot),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK(availability<>'stored' OR (output_object_key IS NOT NULL AND output_object_version IS NOT NULL AND output_digest IS NOT NULL AND byte_length IS NOT NULL))
);

CREATE TABLE actions_design.action_request_content (
  organization_id text NOT NULL, revision_id text NOT NULL,
  intent actions_design.request_intent NOT NULL,
  store actions_design.store_kind, locale text,
  wave_index integer CHECK(wave_index>=0),
  recommendation_type actions_design.recommendation_kind,
  plan_source_id text, experiment_source_id text, source_capture_at timestamptz,
  window_days integer CHECK(window_days BETWEEN 7 AND 180),
  review_mode text CHECK(review_mode IN ('manual','full_agentic')),
  operator_instructions text, focus text, context_text text, hypothesis text,
  hypothesize_policy actions_design.approval_setting,
  draft_policy actions_design.approval_setting,
  execute_policy actions_design.approval_setting,
  origin actions_design.request_origin NOT NULL,
  language text, reasoning text, score numeric,
  demand_lookback_days integer CHECK(demand_lookback_days>0),
  downloads numeric, revenue_usd numeric, impressions numeric, review_count bigint,
  competitor_strength numeric, localized_competitor_count bigint,
  top_chart_count bigint, estimated_market_downloads numeric,
  market_research_note text, finding_title text, finding_rationale text,
  finding_severity actions_design.closed_severity,
  PRIMARY KEY(organization_id,revision_id),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK(intent NOT IN ('review_catch_up','review_analysis') OR window_days IS NOT NULL),
  CHECK(intent<>'review_catch_up' OR review_mode IS NOT NULL),
  CHECK(intent<>'locale_expansion' OR (store IS NOT NULL AND locale IS NOT NULL))
);

CREATE TABLE actions_design.action_market_country (
  organization_id text NOT NULL, revision_id text NOT NULL,
  role actions_design.country_role NOT NULL, ordinal integer NOT NULL CHECK(ordinal>=0),
  country text NOT NULL,
  PRIMARY KEY(organization_id,revision_id,role,ordinal),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_request_content(organization_id,revision_id)
);
CREATE TABLE actions_design.action_market_competitor (
  organization_id text NOT NULL, revision_id text NOT NULL,
  ordinal integer NOT NULL CHECK(ordinal>=0), competitor_name text NOT NULL,
  PRIMARY KEY(organization_id,revision_id,ordinal),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_request_content(organization_id,revision_id)
);
CREATE TABLE actions_design.action_content_note (
  organization_id text NOT NULL, revision_id text NOT NULL,
  section actions_design.prose_section NOT NULL, ordinal integer NOT NULL CHECK(ordinal>=0), text_content text NOT NULL,
  PRIMARY KEY(organization_id,revision_id,section,ordinal),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id)
);




CREATE TABLE actions_design.action_advisory_content (
  organization_id text NOT NULL, revision_id text NOT NULL,
  kind actions_design.advisory_kind NOT NULL,
  detail text, suggestion text,
  primary_link_label text, primary_link_path text,
  connector_source_id text, connector_type actions_design.advisory_connector_kind, connector_name_snapshot text,
  source_label text, benefit text, app_name_snapshot text, bundle_id_snapshot text,
  scraping_account_email_snapshot text,
  agent_source_id text,
  consecutive_failures bigint CHECK(consecutive_failures>=0), last_success_at timestamptz, last_error text,
  impact actions_design.closed_severity, effort actions_design.closed_severity,
  confidence_label actions_design.closed_severity, confidence_score numeric,
  quick_win_source_id text, recommendation_type actions_design.recommendation_kind,
  market_label text, gate_text text, capability_tier integer CHECK(capability_tier BETWEEN 1 AND 3),
  proposed_next_step text,
  audit_store actions_design.store_kind, audit_store_app_id text, audit_country text, audit_locale text, audit_generated_at timestamptz,
  blocker_reason_text text, blocker_reasoning text,
  unblock_title text, unblock_what_happened text, unblock_why_it_matters text,
  unblock_next text, unblock_cta_label text, unblock_cta_path text,
  PRIMARY KEY(organization_id,revision_id),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK(primary_link_path IS NULL OR primary_link_path ~ '^/[^/]'),
  CHECK(unblock_cta_path IS NULL OR unblock_cta_path ~ '^/[^/]')
);

CREATE TYPE actions_design.ad_intent AS ENUM ('pause_campaign','enable_campaign','set_campaign_budget','set_keyword_bid','create_keyword','add_negative_keyword','delete_negative_keyword','observed');
CREATE TYPE actions_design.ad_observed_status AS ENUM ('ENABLED','ACTIVE','PAUSED','DELETED');
CREATE TABLE actions_design.action_ad_content (
  organization_id text NOT NULL, revision_id text NOT NULL,
  intent actions_design.ad_intent NOT NULL,
  provider_account_id text NOT NULL,
  provider_campaign_id text NOT NULL CHECK(provider_campaign_id ~ '^[1-9][0-9]*$'),
  provider_ad_group_id text CHECK(provider_ad_group_id ~ '^[1-9][0-9]*$'),
  provider_keyword_id text CHECK(provider_keyword_id ~ '^[1-9][0-9]*$'),
  provider_negative_keyword_id text CHECK(provider_negative_keyword_id ~ '^[1-9][0-9]*$'),
  keyword_text text, match_type actions_design.ad_match_type,
  daily_budget_amount numeric CHECK(daily_budget_amount>0),
  bid_amount numeric CHECK(bid_amount>0),
  currency_code text CHECK(currency_code ~ '^[A-Z]{3}$'),
  observed_status actions_design.ad_observed_status,
  observation_availability actions_design.observation_availability,
  observation_captured_at timestamptz,
  baseline_revision_id text,
  PRIMARY KEY(organization_id,revision_id),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  FOREIGN KEY(organization_id,baseline_revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK(intent<>'set_campaign_budget' OR (daily_budget_amount IS NOT NULL AND currency_code IS NOT NULL)),
  CHECK(intent<>'set_keyword_bid' OR (provider_ad_group_id IS NOT NULL AND provider_keyword_id IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL)),
  CHECK(intent<>'create_keyword' OR (provider_ad_group_id IS NOT NULL AND keyword_text IS NOT NULL AND match_type IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL)),
  CHECK(intent<>'add_negative_keyword' OR (keyword_text IS NOT NULL AND match_type IS NOT NULL)),
  CHECK(intent<>'delete_negative_keyword' OR provider_negative_keyword_id IS NOT NULL),
  CHECK(intent<>'observed' OR (observation_availability IS NOT NULL AND observation_captured_at IS NOT NULL)),
  CHECK(intent='observed' OR observed_status IS NULL),
  CHECK(intent IN ('set_campaign_budget','observed') OR daily_budget_amount IS NULL),
  CHECK(intent IN ('set_keyword_bid','create_keyword','observed') OR bid_amount IS NULL),
  CHECK(intent IN ('set_keyword_bid','set_campaign_budget','create_keyword','observed') OR currency_code IS NULL),
  CHECK(intent IN ('create_keyword','add_negative_keyword','observed') OR (keyword_text IS NULL AND match_type IS NULL)),
  CHECK(intent IN ('set_keyword_bid','observed') OR provider_keyword_id IS NULL),
  CHECK(intent IN ('delete_negative_keyword','observed') OR provider_negative_keyword_id IS NULL),
  CHECK(intent IN ('set_keyword_bid','create_keyword','add_negative_keyword','observed') OR provider_ad_group_id IS NULL)
);

-- REQUIRED CENTRAL GUARDS (root schema seals transactions):
-- 1. Every proposal/baseline/observation revision has exactly the permitted
--    primary subtype for action_revision.kind. Kind interface: review_reply, listing,
--    media, request, ads, advisory, collection. Auxiliary relations cannot
--    float on incompatible revisions. Collection carries immutable membership.
-- 2. Any insert/update/delete here locks the parent revision, rejects sealed,
--    and sealing validates the whole content graph atomically.
-- 3. Baseline and original-AI references must be same organization, correct
--    purpose, sealed and same concrete target. Reject self/cyclic references.
-- 4. Listing locale uses the closed supported-store catalog. Android supports
--    title/description/shortDescription; iOS excludes shortDescription. New
--    unsupported fields reject at command validation before persistence.
-- 5. Proposal present/empty means intended set/clear; unspecified means keep;
--    dismissed preserves reviewed copy but omits that field from execution.
--    Only observations permit unreadable. Clear supported only where adapter
--    explicitly implements it. Approval preview and compiler use same schema.
-- 6. Generation provenance refers to immutable run/attempts in core; do not
--    duplicate billing usage totals in content rows. Generation output from
--    stale base revision may be retained but never becomes current silently.
-- 7. Media approved for publication requires stored immutable version/digest;
--    provider display_type parsed through the supported typed device catalog.
--    Unknown provider display types fail typed parsing and cannot enter the closed catalog. Media source/output rows
--    reference actual storage inventory by FK where canonical assets exist.
-- 8. Request child has exactly one locale; parent membership freezes its set.
--    Generation approval and publication approval are distinct scopes.
-- 9. Root concrete provenance relations carry source run, recommendation,
--    variant, report, backlog, experiment, source snapshot, receipt identity;
--    connect source placeholders here to those checked FK relations.
-- 10. Revert rationale references the existing experiment-owned outcome;
--     executable restore bytes are frozen concrete listing child revisions.
-- 11. RLS/indexes/grants/sealed-content triggers apply to every relation here.
-- 12. Old retired capability data is outside live schema. Preserve existing
--     links/receipts through bounded migration handling; no retired executor,
--     historical param bag or archive-specific variant in this runtime.
-- 13. Current ad content uses one relation because all seven shapes have the
--     same revision key/lifetime; operation CHECKs enforce exact variants.
--     No ad-group mutation/campaign-create handler is implied.
-- 14. Active ASA negative-keyword create rejects ad-group scope until adapter
--     supports it. Provider account+campaign target must be bound at staging.


-- FLO-1355 current provider content contract additions, not a migration.
-- Apply after schema-content.sql; all references target actions_design.
-- No new relations: App Clip fields share the locale revision and pin a media
-- member of that same revision. Independent locale operations remain children.

-- One baseline authority, already owned by root action_revision.
ALTER TABLE actions_design.action_review_content DROP COLUMN baseline_revision_id;
ALTER TABLE actions_design.action_listing_content DROP COLUMN baseline_revision_id;
ALTER TABLE actions_design.action_ad_content DROP COLUMN baseline_revision_id;
-- Dropping the review column also drops its dependent local CHECK; the central
-- revision validator must require a sealed baseline for reply intent=update.

-- Current source commits omit this query policy. This is a deliberate fix:
-- https://developers.google.com/android-publisher/api-ref/rest/v3/edits/commit
-- Omission defaults to CANCEL_IN_REVIEW_AND_SUBMIT. Broader cancellation is
-- outside current scope; the closed policy has exactly one permitted value.
CREATE TYPE actions_design.play_commit_policy AS ENUM ('ERROR_IF_IN_REVIEW');
CREATE TYPE actions_design.app_clip_operation AS ENUM ('none','create_localization','repair_header','observed');
ALTER TABLE actions_design.action_listing_content
 ADD COLUMN play_commit_policy actions_design.play_commit_policy,
 ADD COLUMN app_clip_operation actions_design.app_clip_operation NOT NULL DEFAULT 'none',
 ADD COLUMN app_clip_id text,
 ADD COLUMN app_clip_experience_id text,
 ADD COLUMN app_clip_release_version_id text,
 ADD COLUMN app_clip_localization_id text,
 ADD COLUMN app_clip_source_localization_id text,
 ADD COLUMN app_clip_subtitle text,
 ADD COLUMN app_clip_header_media_slot integer,
 ADD CONSTRAINT listing_play_policy_store CHECK(store='android' OR play_commit_policy IS NULL),
 ADD CONSTRAINT listing_clip_target CHECK(
  (app_clip_operation='none' AND app_clip_id IS NULL AND app_clip_experience_id IS NULL
   AND app_clip_release_version_id IS NULL AND app_clip_localization_id IS NULL
   AND app_clip_source_localization_id IS NULL AND app_clip_subtitle IS NULL
   AND app_clip_header_media_slot IS NULL)
  OR
  (app_clip_operation<>'none' AND store='ios' AND app_clip_id IS NOT NULL
   AND app_clip_experience_id IS NOT NULL AND app_clip_release_version_id IS NOT NULL
   AND (app_clip_operation='observed' OR app_clip_header_media_slot IS NOT NULL))
 ),
 ADD CONSTRAINT listing_clip_subtitle CHECK(app_clip_operation<>'create_localization'
  OR (app_clip_subtitle IS NOT NULL AND length(app_clip_subtitle)>0)),
 ADD CONSTRAINT listing_clip_repair_target CHECK(app_clip_operation<>'repair_header'
  OR app_clip_localization_id IS NOT NULL),
 ADD CONSTRAINT listing_clip_media_fk FOREIGN KEY(organization_id,revision_id,app_clip_header_media_slot)
  REFERENCES actions_design.action_media_content(organization_id,revision_id,slot)
  DEFERRABLE INITIALLY DEFERRED;

-- Current promo code writes the same proposed copy to independently pinned
-- live and editable destinations. Snapshot values can differ, so retain a
-- separate live value only as observation evidence; desired copy stays singular.
CREATE TYPE actions_design.app_clip_header_state AS ENUM ('absent','incomplete','complete','unreadable');
CREATE TYPE actions_design.review_publication_state AS ENUM ('published','pending_publication','hidden','deleted','unreadable');
CREATE TYPE actions_design.listing_version_state AS ENUM ('editable','in_review','processing','live','rejected','removed','unreadable');
ALTER TABLE actions_design.action_review_content DROP COLUMN provider_response_state_text;
ALTER TABLE actions_design.action_review_content ADD COLUMN provider_response_state actions_design.review_publication_state;
ALTER TABLE actions_design.action_listing_content DROP COLUMN provider_state_text;
ALTER TABLE actions_design.action_listing_content
 ADD COLUMN provider_version_state actions_design.listing_version_state,
 ADD COLUMN live_promotional_version_id text,
 ADD COLUMN live_promotional_localization_id text,
 ADD COLUMN live_promotional_text_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified',
 ADD COLUMN live_promotional_text text,
 ADD COLUMN app_clip_incomplete_header_id text,
 ADD COLUMN app_clip_header_state actions_design.app_clip_header_state,
 ADD CONSTRAINT listing_live_promo_target CHECK(
  (live_promotional_version_id IS NULL AND live_promotional_localization_id IS NULL)
  OR (store='ios' AND live_promotional_version_id IS NOT NULL AND length(live_promotional_version_id)>0
   AND live_promotional_localization_id IS NOT NULL AND length(live_promotional_localization_id)>0)),
 ADD CONSTRAINT listing_live_promo_observed_value CHECK(
  (live_promotional_text_state='present' AND live_promotional_text IS NOT NULL AND length(live_promotional_text)>0)
  OR (live_promotional_text_state='empty' AND live_promotional_text IS NOT NULL AND live_promotional_text='')
  OR (live_promotional_text_state IN ('unspecified','unreadable') AND live_promotional_text IS NULL)),
 ADD CONSTRAINT listing_live_promo_value_target CHECK(live_promotional_text_state='unspecified' OR live_promotional_version_id IS NOT NULL),
 ADD CONSTRAINT listing_clip_observed_header CHECK(
  (app_clip_operation='none' AND app_clip_incomplete_header_id IS NULL AND app_clip_header_state IS NULL)
  OR (app_clip_operation IN ('create_localization','repair_header','observed')
   AND (app_clip_incomplete_header_id IS NULL OR length(app_clip_incomplete_header_id)>0)
   AND (app_clip_header_state IS NULL OR app_clip_operation='observed')
   AND (app_clip_header_state IS DISTINCT FROM 'incomplete'::actions_design.app_clip_header_state
    OR app_clip_incomplete_header_id IS NOT NULL)));

-- Apple's current official ScreenshotDisplayType enum, verified 2026-09-15:
-- https://developer.apple.com/documentation/appstoreconnectapi/screenshotdisplaytype
-- These are accepted observation/display identities, not a claim that Fload
-- has an upload executor for every device. Publication remains capability-gated.
CREATE TYPE actions_design.media_display_type AS ENUM (
 'APP_APPLE_TV','APP_APPLE_VISION_PRO','APP_DESKTOP','APP_IPAD_105','APP_IPAD_97',
 'APP_IPAD_PRO_129','APP_IPAD_PRO_3GEN_11','APP_IPAD_PRO_3GEN_129',
 'APP_IPHONE_35','APP_IPHONE_40','APP_IPHONE_47','APP_IPHONE_55','APP_IPHONE_58',
 'APP_IPHONE_61','APP_IPHONE_65','APP_IPHONE_67','APP_WATCH_SERIES_10',
 'APP_WATCH_SERIES_3','APP_WATCH_SERIES_4','APP_WATCH_SERIES_7','APP_WATCH_ULTRA',
 -- Current Play read source supports precisely these screenshot sets.
 'phoneScreenshots','sevenInchScreenshots'
);
ALTER TYPE actions_design.media_kind ADD VALUE 'app_clip_header';
-- Avoid using the new enum literal until the DDL transaction commits. Guards
-- below compare kind::text. The completed contract is tested after commit.
CREATE TYPE actions_design.media_storage_immutability AS ENUM ('versioned_object','content_addressed_immutable');
ALTER TABLE actions_design.action_media_content
 ALTER COLUMN display_type TYPE actions_design.media_display_type USING display_type::actions_design.media_display_type,
 ADD COLUMN source_storage_immutability actions_design.media_storage_immutability,
 ADD COLUMN output_storage_immutability actions_design.media_storage_immutability,
 ADD COLUMN provider_md5 text,
 ADD CONSTRAINT media_source_digest_format CHECK(source_digest IS NULL OR source_digest ~ '^sha256:[0-9a-f]{64}$'),
 ADD CONSTRAINT media_output_digest_format CHECK(output_digest IS NULL OR output_digest ~ '^sha256:[0-9a-f]{64}$'),
 ADD CONSTRAINT media_md5_format CHECK(provider_md5 IS NULL OR provider_md5 ~ '^[0-9a-f]{32}$'),
 ADD CONSTRAINT media_display_store CHECK(display_type IS NULL
   OR (store='android' AND display_type IN ('phoneScreenshots','sevenInchScreenshots'))
   OR (store='ios' AND display_type NOT IN ('phoneScreenshots','sevenInchScreenshots'))),
 ADD CONSTRAINT media_screenshot_display CHECK(kind::text<>'screenshot' OR display_type IS NOT NULL),
 ADD CONSTRAINT media_clip_shape CHECK(kind::text<>'app_clip_header'
   OR (store='ios' AND display_type IS NULL AND mime_type IS NOT NULL AND mime_type IN ('image/png','image/jpeg')));

-- The old design CHECK forced a provider object-version on every stored file.
-- R2 can instead use a content-addressed key, conditional creation, and a
-- storage service that rejects replacement/deletion while any revision pins it.
-- This is the known auto-generated name from the supplied contract, not an
-- application migration that guesses an arbitrary deployed constraint name.
ALTER TABLE actions_design.action_media_content DROP CONSTRAINT action_media_content_check;
ALTER TABLE actions_design.action_media_content ADD CONSTRAINT media_stored_bytes_immutable CHECK(
 availability<>'stored' OR
 (output_object_key IS NOT NULL AND length(output_object_key)>0
  AND output_digest IS NOT NULL AND byte_length IS NOT NULL
  AND output_storage_immutability IS NOT NULL
  AND (
   (output_storage_immutability='versioned_object' AND output_object_version IS NOT NULL AND length(output_object_version)>0)
   OR
   (output_storage_immutability='content_addressed_immutable'
    AND output_object_version IS NULL
    AND position(substring(output_digest FROM 8) IN output_object_key)>0)
  ))
);

-- Call this validator when linking a baseline or attaching a provider readback
-- to a subject revision. Organization and action equality also required by
-- root FKs; new server-assigned IDs may fill a subject's previously null slot.
-- The root invokes this before accepting an observation or sealing a proposal.
CREATE FUNCTION actions_design.assert_same_provider_content_target(
 p_org text, p_subject text, p_observation text
) RETURNS void LANGUAGE plpgsql AS $$
DECLARE sr actions_design.action_revision%ROWTYPE;
 orr actions_design.action_revision%ROWTYPE;
 sreview actions_design.action_review_content%ROWTYPE;
 oreview actions_design.action_review_content%ROWTYPE;
 slisting actions_design.action_listing_content%ROWTYPE;
 olisting actions_design.action_listing_content%ROWTYPE;
 sad actions_design.action_ad_content%ROWTYPE;
 oad actions_design.action_ad_content%ROWTYPE;
BEGIN
 SELECT * INTO STRICT sr FROM actions_design.action_revision WHERE organization_id=p_org AND id=p_subject;
 SELECT * INTO STRICT orr FROM actions_design.action_revision WHERE organization_id=p_org AND id=p_observation;
 IF sr.action_id IS DISTINCT FROM orr.action_id OR sr.kind IS DISTINCT FROM orr.kind
   OR NOT orr.sealed OR orr.purpose NOT IN ('baseline','observation')
 THEN RAISE EXCEPTION 'Observation must belong to the same ticket and content family'; END IF;
 IF sr.kind='review_reply' THEN
  SELECT * INTO STRICT sreview FROM actions_design.action_review_content WHERE organization_id=p_org AND revision_id=p_subject;
  SELECT * INTO STRICT oreview FROM actions_design.action_review_content WHERE organization_id=p_org AND revision_id=p_observation;
  IF ROW(sreview.provider_account_id,sreview.store,sreview.provider_app_id,sreview.provider_review_id)
    IS DISTINCT FROM ROW(oreview.provider_account_id,oreview.store,oreview.provider_app_id,oreview.provider_review_id)
    OR (sreview.apple_review_resource_id IS NOT NULL AND sreview.apple_review_resource_id IS DISTINCT FROM oreview.apple_review_resource_id)
  THEN RAISE EXCEPTION 'Review observation changed the approved target'; END IF;
 ELSIF sr.kind='listing' THEN
  SELECT * INTO STRICT slisting FROM actions_design.action_listing_content WHERE organization_id=p_org AND revision_id=p_subject;
  SELECT * INTO STRICT olisting FROM actions_design.action_listing_content WHERE organization_id=p_org AND revision_id=p_observation;
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
  SELECT * INTO STRICT sad FROM actions_design.action_ad_content WHERE organization_id=p_org AND revision_id=p_subject;
  SELECT * INTO STRICT oad FROM actions_design.action_ad_content WHERE organization_id=p_org AND revision_id=p_observation;
  IF ROW(sad.provider_account_id,sad.provider_campaign_id,sad.provider_ad_group_id)
    IS DISTINCT FROM ROW(oad.provider_account_id,oad.provider_campaign_id,oad.provider_ad_group_id)
    OR (sad.provider_keyword_id IS NOT NULL AND sad.provider_keyword_id IS DISTINCT FROM oad.provider_keyword_id)
    OR (sad.provider_negative_keyword_id IS NOT NULL AND sad.provider_negative_keyword_id IS DISTINCT FROM oad.provider_negative_keyword_id)
  THEN RAISE EXCEPTION 'Ads observation changed the approved target'; END IF;
 ELSE RAISE EXCEPTION 'Provider observation unsupported for this content family';
 END IF;
END $$;

-- Finite canonical locale domain generated from packages/utils/src/storefront-data.ts
-- on main 63275b2f5. Input normalization resolves aliases before persistence;
-- ambiguity is an error. Adding a supported locale is a schema+contract change.
CREATE FUNCTION actions_design.is_supported_store_locale(p_store actions_design.store_kind,p_locale text)
RETURNS boolean LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$ SELECT CASE p_store
 WHEN 'ios' THEN p_locale IN ('ar-SA','bn-BD','ca','zh-Hans','zh-Hant','hr','cs','da','nl-NL','en-AU','en-CA','en-GB','en-US','fi','fr-FR','fr-CA','de-DE','el','gu-IN','he','hi','hu','id','it','ja','kn-IN','ko','ms','ml-IN','mr-IN','no','or-IN','pl','pt-BR','pt-PT','pa-IN','ro','ru','sk','sl-SI','es-MX','es-ES','sv','ta-IN','te-IN','th','tr','uk','ur-PK','vi')
 WHEN 'android' THEN p_locale IN ('af','am','ar','az-AZ','be','bg','bn-BD','ca','cs-CZ','da-DK','de-DE','el-GR','en-AU','en-CA','en-GB','en-IN','en-SG','en-US','en-ZA','es-419','es-ES','es-US','et','eu-ES','fa','fi-FI','fil','fr-CA','fr-FR','gl-ES','gu','hi-IN','hr','hu-HU','hy-AM','id','is-IS','it-IT','iw-IL','ja-JP','ka-GE','kk','km-KH','kn-IN','ko-KR','ky-KG','lo-LA','lt','lv','mk-MK','ml-IN','mn-MN','mr-IN','ms','ms-MY','my-MM','nb-NO','ne-NP','nl-NL','no-NO','pa','pl-PL','pt-BR','pt-PT','ro','ru-RU','si-LK','sk','sl','sq','sr','sv-SE','sw','ta-IN','te-IN','th','tr-TR','uk','ur','vi','zh-CN','zh-HK','zh-TW','zu')
 END $$;
ALTER TABLE actions_design.action_listing_content ADD CONSTRAINT listing_supported_locale
 CHECK(actions_design.is_supported_store_locale(store,locale));
ALTER TABLE actions_design.action_media_content ADD CONSTRAINT media_supported_locale
 CHECK(actions_design.is_supported_store_locale(store,locale));
ALTER TABLE actions_design.action_media_content ADD CONSTRAINT media_supported_source_locale
 CHECK(source_locale IS NULL OR actions_design.is_supported_store_locale(store,source_locale));
ALTER TABLE actions_design.action_request_content ADD CONSTRAINT request_supported_locale
 CHECK(locale IS NULL OR (store IS NOT NULL AND actions_design.is_supported_store_locale(store,locale)));

-- PostgreSQL length counts Unicode code points; Apple and JS use UTF-16 units.
CREATE FUNCTION actions_design.utf16_length(p_value text)
RETURNS bigint LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
 SELECT coalesce(sum(CASE WHEN ascii(substring(p_value FROM i FOR 1))>65535 THEN 2 ELSE 1 END),0)::bigint
 FROM generate_series(1,length(p_value)) AS n(i)
$$;
CREATE FUNCTION actions_design.is_content_write(p_state actions_design.content_value_state)
RETURNS boolean LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
 SELECT p_state IN ('present','empty')
$$;
ALTER TABLE actions_design.action_listing_content ADD CONSTRAINT listing_clip_utf16_limit
 CHECK(app_clip_subtitle IS NULL OR actions_design.utf16_length(app_clip_subtitle)<=56);
ALTER TABLE actions_design.action_media_content ADD CONSTRAINT media_source_bytes_immutable CHECK(
 (source_object_key IS NULL AND source_object_version IS NULL AND source_digest IS NULL AND source_storage_immutability IS NULL)
 OR (source_object_key IS NOT NULL AND length(source_object_key)>0 AND source_digest IS NOT NULL
  AND source_storage_immutability IS NOT NULL AND
  ((source_storage_immutability='versioned_object' AND source_object_version IS NOT NULL AND length(source_object_version)>0)
   OR (source_storage_immutability='content_addressed_immutable' AND source_object_version IS NULL
    AND position(substring(source_digest FROM 8) IN source_object_key)>0)))
);

-- Every seal is validated from committed content, including INSERT + later
-- content + seal in one transaction. Root owns subtype/membership/digest guards.
-- This trigger supplements those guards rather than replacing their function.
CREATE FUNCTION actions_design.assert_provider_content_complete(p_revision text)
RETURNS void LANGUAGE plpgsql SET search_path=actions_design,public AS $$
DECLARE r action_revision; review action_review_content; listing action_listing_content;
 ad action_ad_content; req action_request_content; media action_media_content;
 original action_revision; expected text; writable integer;
BEGIN
 SELECT * INTO r FROM action_revision WHERE id=p_revision;
 IF NOT FOUND THEN RETURN; END IF;
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
  SELECT * INTO STRICT listing FROM action_listing_content WHERE organization_id=r.organization_id AND revision_id=r.id;
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
    OR (r.operation='apply_listing_changes' AND listing.store<>'ios')
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
   IF listing.app_clip_incomplete_header_id IS NOT NULL AND (listing.app_clip_operation<>'repair_header'
    OR r.baseline_revision_id IS NULL OR NOT EXISTS(SELECT 1 FROM action_listing_content b
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
  SELECT * INTO STRICT ad FROM action_ad_content WHERE organization_id=r.organization_id AND revision_id=r.id;
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
   OR (r.operation='run_agent' AND req.intent NOT IN ('wake_agent','propose_experiment','revert_experiment','restore_listing'))
  THEN RAISE EXCEPTION 'request purpose or operation mismatch' USING ERRCODE='23514'; END IF;
 END IF;
 IF r.generated_from_revision_id IS NOT NULL AND r.purpose='proposal' THEN
  PERFORM assert_revision_target_continuity(r.organization_id,r.generated_from_revision_id,r.id);
 END IF;
 IF r.kind IN ('review_reply','listing','ads') AND r.baseline_revision_id IS NOT NULL THEN
  PERFORM assert_same_provider_content_target(r.organization_id,r.id,r.baseline_revision_id);
 END IF;
 IF r.kind='media' AND r.purpose='proposal' AND EXISTS(SELECT 1 FROM action_media_content m WHERE m.revision_id=r.id
   AND m.source_provider_resource_id IS NOT NULL AND m.source_digest IS NULL)
 THEN RAISE EXCEPTION 'generation source requires immutable pinned bytes, not only a provider URL/resource' USING ERRCODE='23514'; END IF;
END $$;
CREATE FUNCTION actions_design.provider_content_complete_at_commit()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN PERFORM actions_design.assert_provider_content_complete(NEW.id); RETURN NEW; END $$;
CREATE CONSTRAINT TRIGGER provider_content_complete AFTER INSERT OR UPDATE ON actions_design.action_revision
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions_design.provider_content_complete_at_commit();

-- Transport/compiler contract: write changesInReviewBehavior=ERROR_IF_IN_REVIEW
-- on EVERY Play commit; compile App Clip source/subtitle before review and use
-- only frozen output bytes after approval. Never choose fallback copy later.
-- For App Clip reservation repair, pin the exact observed incomplete resource
-- ID on the execution step before deletion. Existing matching card is evidence;
-- a conflicting card is an explicit blocker, never a replay overwrite.
-- R2 immutability constraints prove pin shape, not storage behavior/existence:
-- creation must be conditional, pinned objects protected from replacement and
-- deletion, and bytes rehashed before any provider upload.


-- Permanent ticket target continuity. Version/localization write targets may
-- change in a freshly reviewed revision; account/app/store/locale identity may
-- not. A genuinely different target requires a new linked child ticket.
CREATE FUNCTION actions_design.assert_revision_target_continuity(p_org text,p_previous text,p_next text)
RETURNS void LANGUAGE plpgsql SET search_path=actions_design,public AS $$
DECLARE previous action_revision; next action_revision; pr action_review_content; nr action_review_content;
 pl action_listing_content; nl action_listing_content; pa action_ad_content; na action_ad_content;
 pq action_request_content; nq action_request_content;
BEGIN
 SELECT * INTO STRICT previous FROM action_revision WHERE organization_id=p_org AND id=p_previous;
 SELECT * INTO STRICT next FROM action_revision WHERE organization_id=p_org AND id=p_next;
 IF previous.action_id<>next.action_id OR previous.purpose<>'proposal' OR next.purpose<>'proposal'
  OR NOT previous.sealed OR NOT next.sealed OR previous.revision_number>=next.revision_number
 THEN RAISE EXCEPTION 'ticket target cannot change: invalid revision predecessor' USING ERRCODE='23514'; END IF;
 IF previous.kind='request' AND next.kind='listing' THEN
  SELECT * INTO STRICT pq FROM action_request_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT nl FROM action_listing_content WHERE organization_id=p_org AND revision_id=p_next;
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
  SELECT * INTO STRICT pl FROM action_listing_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT nl FROM action_listing_content WHERE organization_id=p_org AND revision_id=p_next;
  IF ROW(pl.provider_account_id,pl.store,pl.provider_app_id,pl.package_name,pl.locale)
   IS DISTINCT FROM ROW(nl.provider_account_id,nl.store,nl.provider_app_id,nl.package_name,nl.locale)
  THEN RAISE EXCEPTION 'ticket target cannot change: listing identity drift' USING ERRCODE='23514'; END IF;
 ELSIF next.kind='ads' THEN
  SELECT * INTO STRICT pa FROM action_ad_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT na FROM action_ad_content WHERE organization_id=p_org AND revision_id=p_next;
  IF ROW(pa.provider_account_id,pa.provider_campaign_id,pa.provider_ad_group_id,pa.provider_keyword_id,pa.provider_negative_keyword_id)
   IS DISTINCT FROM ROW(na.provider_account_id,na.provider_campaign_id,na.provider_ad_group_id,na.provider_keyword_id,na.provider_negative_keyword_id)
  THEN RAISE EXCEPTION 'ticket target cannot change: ads identity drift' USING ERRCODE='23514'; END IF;
 ELSIF next.kind='request' THEN
  SELECT * INTO STRICT pq FROM action_request_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT nq FROM action_request_content WHERE organization_id=p_org AND revision_id=p_next;
  IF ROW(pq.intent,pq.store,pq.locale,pq.requested_agent_id) IS DISTINCT FROM ROW(nq.intent,nq.store,nq.locale,nq.requested_agent_id)
  THEN RAISE EXCEPTION 'ticket target cannot change: request identity drift' USING ERRCODE='23514'; END IF;
 ELSIF next.kind='media' THEN
  -- Per-slot generation images may change; their store/locale target cannot.
  IF EXISTS(SELECT 1 FROM action_media_content old WHERE old.organization_id=p_org AND old.revision_id=p_previous
   AND NOT EXISTS(SELECT 1 FROM action_media_content fresh WHERE fresh.organization_id=p_org AND fresh.revision_id=p_next
    AND (fresh.store,fresh.locale)=(old.store,old.locale)))
   OR EXISTS(SELECT 1 FROM action_media_content fresh WHERE fresh.organization_id=p_org AND fresh.revision_id=p_next
    AND NOT EXISTS(SELECT 1 FROM action_media_content old WHERE old.organization_id=p_org AND old.revision_id=p_previous
     AND (fresh.store,fresh.locale)=(old.store,old.locale)))
  THEN RAISE EXCEPTION 'ticket target cannot change: media store/locale drift' USING ERRCODE='23514'; END IF;
 END IF;
END $$;
CREATE FUNCTION actions_design.guard_action_target_continuity()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF OLD.current_revision_id IS NOT NULL AND NEW.current_revision_id IS DISTINCT FROM OLD.current_revision_id THEN
  PERFORM actions_design.assert_revision_target_continuity(NEW.organization_id,OLD.current_revision_id,NEW.current_revision_id);
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER action_target_continuity BEFORE UPDATE ON actions_design.action
 FOR EACH ROW EXECUTE FUNCTION actions_design.guard_action_target_continuity();


-- Current wake_agent intent resolves the exact existing agent before approval.
-- A different agent on the same asset cannot satisfy this approved request.
ALTER TABLE actions_design.action_request_content
 ADD COLUMN requested_agent_id text REFERENCES public.agent(id),
 ADD CONSTRAINT request_agent_target_shape CHECK((intent='wake_agent')=(requested_agent_id IS NOT NULL));
CREATE FUNCTION actions_design.request_agent_target_at_commit() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.intent='wake_agent' AND NOT EXISTS(
  SELECT 1 FROM public.agent target
  JOIN actions_design.action_revision r ON r.organization_id=NEW.organization_id AND r.id=NEW.revision_id
  JOIN actions_design.action a ON a.organization_id=r.organization_id AND a.id=r.action_id
  WHERE target.id=NEW.requested_agent_id AND target."organizationId"=a.organization_id
   AND target."assetId" IS NOT DISTINCT FROM a.asset_id
 ) THEN RAISE EXCEPTION 'requested agent must belong to exact organization and asset' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE CONSTRAINT TRIGGER request_agent_target_complete AFTER INSERT OR UPDATE ON actions_design.action_request_content
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions_design.request_agent_target_at_commit();


SET search_path=actions_design,public;

ALTER TABLE action_revision ADD CONSTRAINT revision_kind_closed CHECK(kind IN ('review_reply','listing','media','request','ads','advisory','collection'));
ALTER TABLE action_revision ADD CONSTRAINT revision_operation_closed CHECK(
 (kind='review_reply' AND operation='post_reply') OR
 (kind='listing' AND operation IN ('apply_listing_changes','update_promo_text','create_locale','update_description','update_short_description','revert_experiment','aso_revert_listing')) OR
 (kind='media' AND operation='generate_media') OR
 (kind='request' AND operation IN ('generate_locale','generate_listing','review_catch_up_30d','generate_review_analysis','run_agent')) OR
 (kind='ads' AND operation IN ('asa_pause_campaign','asa_enable_campaign','asa_update_campaign_budget','asa_update_keyword_bid','asa_create_keyword','asa_add_negative_keyword','asa_delete_negative_keyword')) OR
 (kind='advisory' AND operation IN ('acknowledge','resolve_prerequisite')) OR
 (kind='collection' AND operation IN ('post_batch','apply_listing_changes','localize','asa_update_keyword_bid','revert_experiment','aso_revert_listing'))
);
ALTER TABLE action_membership ADD UNIQUE(organization_id,parent_revision_id,child_action_id,child_revision_id);
ALTER TABLE action_approval ADD CONSTRAINT approval_exact_membership_fk FOREIGN KEY(organization_id,parent_revision_id,action_id,revision_id) REFERENCES action_membership(organization_id,parent_revision_id,child_action_id,child_revision_id) DEFERRABLE INITIALLY DEFERRED;

CREATE FUNCTION reject_immutable_change() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION 'immutable % row', TG_TABLE_NAME USING ERRCODE='23514'; END $$;

CREATE FUNCTION guard_revision_content_edit() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE revision_key text; tenant_key text; is_sealed boolean;
BEGIN
 IF TG_OP='DELETE' THEN revision_key=OLD.revision_id;tenant_key=OLD.organization_id;
 ELSE revision_key=NEW.revision_id;tenant_key=NEW.organization_id; END IF;
 IF TG_OP='UPDATE' AND (NEW.revision_id,NEW.organization_id) IS DISTINCT FROM (OLD.revision_id,OLD.organization_id) THEN
  RAISE EXCEPTION 'content cannot move revisions' USING ERRCODE='23514';
 END IF;
 SELECT sealed INTO is_sealed FROM action_revision WHERE id=revision_key AND organization_id=tenant_key FOR UPDATE;
 IF is_sealed IS DISTINCT FROM false THEN RAISE EXCEPTION 'sealed or missing content owner' USING ERRCODE='23514'; END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF; RETURN NEW;
END $$;

CREATE FUNCTION guard_membership_edit() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE owner_key text; tenant_key text; parent_row action_revision; child_row action_revision;
BEGIN
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
CREATE TRIGGER membership_immutable BEFORE INSERT OR UPDATE OR DELETE ON action_membership FOR EACH ROW EXECUTE FUNCTION guard_membership_edit();

CREATE FUNCTION assert_revision_complete(revision_key text) RETURNS void LANGUAGE plpgsql AS $$
DECLARE r action_revision; a action; primary_count integer; expected_present boolean; baseline action_revision;
BEGIN
 SELECT * INTO r FROM action_revision WHERE id=revision_key;
 IF NOT FOUND THEN RETURN; END IF;
 IF NOT r.sealed THEN RAISE EXCEPTION 'unsealed revision cannot commit' USING ERRCODE='23514'; END IF;
 SELECT * INTO a FROM action WHERE id=r.action_id AND organization_id=r.organization_id;
 SELECT
  (EXISTS(SELECT 1 FROM action_review_content WHERE revision_id=r.id))::int+
  (EXISTS(SELECT 1 FROM action_listing_content WHERE revision_id=r.id))::int+
  (EXISTS(SELECT 1 FROM action_request_content WHERE revision_id=r.id))::int+
  (EXISTS(SELECT 1 FROM action_ad_content WHERE revision_id=r.id))::int+
  (EXISTS(SELECT 1 FROM action_advisory_content WHERE revision_id=r.id))::int
 INTO primary_count;
 expected_present=CASE r.kind
  WHEN 'review_reply' THEN EXISTS(SELECT 1 FROM action_review_content WHERE revision_id=r.id)
  WHEN 'listing' THEN EXISTS(SELECT 1 FROM action_listing_content WHERE revision_id=r.id)
  WHEN 'request' THEN EXISTS(SELECT 1 FROM action_request_content WHERE revision_id=r.id)
  WHEN 'ads' THEN EXISTS(SELECT 1 FROM action_ad_content WHERE revision_id=r.id)
  WHEN 'advisory' THEN EXISTS(SELECT 1 FROM action_advisory_content WHERE revision_id=r.id)
  WHEN 'media' THEN EXISTS(SELECT 1 FROM action_media_content WHERE revision_id=r.id)
  WHEN 'collection' THEN EXISTS(SELECT 1 FROM action_membership WHERE parent_revision_id=r.id)
  ELSE false END;
 IF NOT expected_present OR primary_count<>(CASE WHEN r.kind IN ('collection','media') THEN 0 ELSE 1 END) THEN RAISE EXCEPTION 'wrong or absent content subtype' USING ERRCODE='23514'; END IF;
 IF r.kind NOT IN ('media','listing') AND EXISTS(SELECT 1 FROM action_media_content WHERE revision_id=r.id) THEN RAISE EXCEPTION 'media incompatible with revision' USING ERRCODE='23514'; END IF;
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
    OR (r.operation='asa_update_keyword_bid' AND child.kind='ads' AND child.operation='asa_update_keyword_bid')
   ))
 ) THEN RAISE EXCEPTION 'collection child differs from declared operation or asset' USING ERRCODE='23514'; END IF;

 IF r.baseline_revision_id IS NOT NULL THEN
  SELECT * INTO baseline FROM action_revision WHERE id=r.baseline_revision_id;
  IF baseline.sealed IS DISTINCT FROM true OR baseline.purpose NOT IN ('baseline','observation') OR baseline.action_id<>r.action_id OR baseline.kind<>r.kind THEN RAISE EXCEPTION 'invalid baseline' USING ERRCODE='23514'; END IF;
 END IF;
 IF r.generated_from_revision_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM action_revision source WHERE source.id=r.generated_from_revision_id AND source.action_id=r.action_id AND source.sealed AND source.revision_number<r.revision_number) THEN RAISE EXCEPTION 'invalid generation predecessor' USING ERRCODE='23514'; END IF;
 IF (r.kind IN ('review_reply') AND a.domain<>'reviews') OR (r.kind IN ('listing','media') AND a.domain<>'listing') OR (r.kind='ads' AND a.domain<>'ads') OR (r.kind='advisory' AND a.domain<>'advisory') OR (r.kind='collection' AND a.domain<>'collection') THEN RAISE EXCEPTION 'revision domain mismatch' USING ERRCODE='23514'; END IF;
END $$;

CREATE FUNCTION revision_complete_at_commit() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN PERFORM assert_revision_complete(NEW.id);RETURN NEW; END $$;
CREATE CONSTRAINT TRIGGER revision_complete AFTER INSERT OR UPDATE ON action_revision DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION revision_complete_at_commit();

CREATE FUNCTION guard_revision_update() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF TG_OP='DELETE' OR OLD.sealed THEN RAISE EXCEPTION 'immutable revision' USING ERRCODE='23514'; END IF;
 IF (NEW.id,NEW.organization_id,NEW.action_id,NEW.purpose,NEW.kind,NEW.operation,NEW.revision_number,NEW.authored_command_id,NEW.baseline_revision_id,NEW.generated_from_revision_id,NEW.title,NEW.summary,NEW.rationale,NEW.content_digest,NEW.canonicalization_version,NEW.created_at) IS DISTINCT FROM (OLD.id,OLD.organization_id,OLD.action_id,OLD.purpose,OLD.kind,OLD.operation,OLD.revision_number,OLD.authored_command_id,OLD.baseline_revision_id,OLD.generated_from_revision_id,OLD.title,OLD.summary,OLD.rationale,OLD.content_digest,OLD.canonicalization_version,OLD.created_at) THEN RAISE EXCEPTION 'revision fields immutable even before seal' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER revision_immutable BEFORE UPDATE OR DELETE ON action_revision FOR EACH ROW EXECUTE FUNCTION guard_revision_update();

CREATE FUNCTION guard_action_graph() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF TG_OP='UPDATE' AND (NEW.id,NEW.organization_id,NEW.asset_id,NEW.domain,NEW.parent_action_id,NEW.creation_key,NEW.created_at) IS DISTINCT FROM (OLD.id,OLD.organization_id,OLD.asset_id,OLD.domain,OLD.parent_action_id,OLD.creation_key,OLD.created_at) THEN RAISE EXCEPTION 'ticket identity and structural parent are permanent' USING ERRCODE='23514'; END IF;
 IF NEW.current_revision_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM action_revision WHERE id=NEW.current_revision_id AND action_id=NEW.id AND organization_id=NEW.organization_id AND purpose='proposal' AND sealed) THEN RAISE EXCEPTION 'invalid current revision' USING ERRCODE='23514'; END IF;
 IF NEW.parent_action_id IS NOT NULL AND EXISTS(WITH RECURSIVE ancestors AS (SELECT id,parent_action_id FROM action WHERE id=NEW.parent_action_id UNION SELECT a.id,a.parent_action_id FROM action a JOIN ancestors p ON a.id=p.parent_action_id) SELECT 1 FROM ancestors WHERE id=NEW.id) THEN RAISE EXCEPTION 'parent cycle' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER action_identity BEFORE UPDATE ON action FOR EACH ROW EXECUTE FUNCTION guard_action_graph();
CREATE CONSTRAINT TRIGGER action_graph_complete AFTER INSERT ON action DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION guard_action_graph();

CREATE FUNCTION dependency_acyclic() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF EXISTS(WITH RECURSIVE ancestors AS (SELECT prerequisite_action_id AS id FROM action_dependency WHERE dependent_action_id=NEW.prerequisite_action_id UNION SELECT d.prerequisite_action_id FROM action_dependency d JOIN ancestors a ON d.dependent_action_id=a.id) SELECT 1 FROM ancestors WHERE id=NEW.dependent_action_id) THEN RAISE EXCEPTION 'dependency cycle' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE CONSTRAINT TRIGGER dependency_no_cycle AFTER INSERT ON action_dependency DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION dependency_acyclic();

DO $$ DECLARE t text; BEGIN
 FOREACH t IN ARRAY ARRAY['action_review_content','action_listing_content','action_content_term','action_media_content','action_request_content','action_market_country','action_market_competitor','action_content_note','action_advisory_content','action_ad_content'] LOOP
  EXECUTE format('CREATE TRIGGER content_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON %I FOR EACH ROW EXECUTE FUNCTION guard_revision_content_edit()',t);
 END LOOP;
 FOREACH t IN ARRAY ARRAY['action_command','action_command_target','action_approval','action_dependency','action_alias'] LOOP
  EXECUTE format('CREATE TRIGGER immutable_fact BEFORE UPDATE OR DELETE ON %I FOR EACH ROW EXECUTE FUNCTION reject_immutable_change()',t);
 END LOOP;
END $$;

-- Application sessions SET LOCAL fload.organization_id from canonical authorization.
-- The cross-tenant resource guard is worker-only: no public/API grants.
DO $$ DECLARE t text; BEGIN
 FOR t IN SELECT tablename FROM pg_tables WHERE schemaname='actions_design' AND tablename<>'action_resource_guard' LOOP
  EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY',t);
  EXECUTE format('CREATE POLICY tenant_scope ON %I USING (organization_id = current_setting(''fload.organization_id'',true)) WITH CHECK (organization_id = current_setting(''fload.organization_id'',true))',t);
 END LOOP;
 ALTER TABLE action_resource_guard ENABLE ROW LEVEL SECURITY;
END $$;


-- FLO-1355 executable DESIGN proof, not an application migration.
-- Apply after core/content/revision guards, before execution guards.
-- These guards prove relational shapes and transitions. Canonical auth still
-- resolves memberships, credential validity, external-member mapping and scopes.
SET search_path=actions_design,public;

ALTER TABLE action ADD COLUMN last_command_id text NOT NULL;
ALTER TABLE action ADD CONSTRAINT action_last_command_fk FOREIGN KEY(organization_id,last_command_id)
 REFERENCES action_command(organization_id,id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE action_command_target ADD COLUMN previous_approval_id text;
ALTER TABLE action_command_target ADD COLUMN result_approval_id text;
ALTER TABLE action_command_target ADD CONSTRAINT target_previous_approval_fk FOREIGN KEY(organization_id,action_id,previous_approval_id)
 REFERENCES action_approval(organization_id,action_id,id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE action_command_target ADD CONSTRAINT target_result_approval_fk FOREIGN KEY(organization_id,action_id,result_approval_id)
 REFERENCES action_approval(organization_id,action_id,id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE action_command_target ADD CONSTRAINT target_positive_versions CHECK(
 (expected_version IS NULL OR expected_version>0) AND (previous_version IS NULL OR previous_version>0));
CREATE UNIQUE INDEX target_one_change_per_version ON action_command_target(action_id,result_version)
 WHERE previous_version IS NULL OR result_version<>previous_version;

-- Provider integration IDs are typed by channel. Real domain FKs and member
-- mapping belong to the final adapter; a nonempty ID does not prove membership.
ALTER TABLE action_command ADD COLUMN actor_slack_integration_id text;
ALTER TABLE action_command ADD COLUMN actor_discord_integration_id text;
ALTER TABLE action_command ADD COLUMN acting_for_user_id text;
ALTER TABLE action_command ADD CONSTRAINT command_principal_exclusive CHECK(
 (principal_kind='user' AND actor_user_id IS NOT NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NULL) OR
 (principal_kind='api_key' AND actor_user_id IS NOT NULL AND actor_api_key_id IS NOT NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NULL) OR
 (principal_kind='agent' AND actor_user_id IS NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NOT NULL AND actor_policy_revision_id IS NULL) OR
 (principal_kind='policy' AND actor_user_id IS NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NOT NULL) OR
 (principal_kind='system' AND actor_user_id IS NULL AND actor_api_key_id IS NULL AND actor_agent_run_id IS NULL AND actor_policy_revision_id IS NULL));
ALTER TABLE action_command ADD CONSTRAINT command_external_actor_shape CHECK(
 (channel='slack' AND principal_kind='user' AND external_actor_id IS NOT NULL AND actor_slack_integration_id IS NOT NULL AND actor_discord_integration_id IS NULL) OR
 (channel='discord' AND principal_kind='user' AND external_actor_id IS NOT NULL AND actor_discord_integration_id IS NOT NULL AND actor_slack_integration_id IS NULL) OR
 (channel NOT IN ('slack','discord') AND external_actor_id IS NULL AND actor_slack_integration_id IS NULL AND actor_discord_integration_id IS NULL));
ALTER TABLE action_command ADD CONSTRAINT command_delegation_shape CHECK(acting_for_user_id IS NULL OR (principal_kind='user' AND channel IN ('operator','web')));
ALTER TABLE action_command ADD CONSTRAINT command_subject_nonempty CHECK(length(actor_subject_snapshot)>0);
ALTER TABLE action_command ADD CONSTRAINT command_policy_target_shape CHECK((kind IN ('grant_policy','revoke_policy'))=(target_policy_revision_id IS NOT NULL));
ALTER TABLE action_policy_revision ADD CONSTRAINT policy_rating_bounds CHECK((minimum_rating IS NULL)=(maximum_rating IS NULL));
ALTER TABLE action_policy_revision ADD CONSTRAINT policy_permission_shape CHECK(
 (policy_kind='agent_generation' AND allow_generation AND NOT allow_initial_reply AND NOT allow_replace_reply AND minimum_rating IS NULL) OR
 (policy_kind='review_auto_reply' AND (allow_initial_reply OR allow_replace_reply)));

CREATE FUNCTION command_target_matches_action(t action_command_target,a action) RETURNS boolean
 LANGUAGE sql IMMUTABLE AS $$ SELECT
 (t.result_version,t.result_decision,t.result_revision_id,t.result_approval_id,t.result_owner_user_id,t.result_snoozed_until,t.result_archived_at)
 IS NOT DISTINCT FROM
 (a.version,a.decision,a.current_revision_id,a.current_approval_id,a.owner_user_id,a.snoozed_until,a.archived_at) $$;

CREATE FUNCTION guard_action_command_mutation() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE c action_command; t action_command_target; old_ap action_approval; is_initial boolean;
BEGIN
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'permanent ticket cannot be deleted by workflow' USING ERRCODE='23514'; END IF;
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
    OR EXISTS(SELECT 1 FROM action_execution_attempt x JOIN action_execution_step s ON s.id=x.step_id JOIN action_execution e ON e.id=s.execution_id WHERE e.approval_id=old_ap.id AND x.kind IN ('write','generation'))
   THEN RAISE EXCEPTION 'Undo cannot cross execution claim' USING ERRCODE='23514'; END IF;
  ELSIF EXISTS(SELECT 1 FROM action_execution WHERE approval_id=old_ap.id AND phase NOT IN ('settled','cancelled')) THEN
   RAISE EXCEPTION 'active authorization cannot be displaced' USING ERRCODE='23514';
  END IF;
 END IF;
 IF NOT is_initial AND NEW.decision IS DISTINCT FROM OLD.decision THEN
  IF NOT (
   (c.kind IN ('approve','revise') AND OLD.decision='open' AND NEW.decision='approved') OR
   (c.kind='undo' AND OLD.decision='approved' AND NEW.decision='open') OR
   (c.kind='reject' AND OLD.decision='open' AND NEW.decision='declined') OR
   (c.kind='acknowledge' AND OLD.decision='open' AND NEW.decision='acknowledged') OR
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
CREATE TRIGGER action_command_mutation BEFORE INSERT OR UPDATE OR DELETE ON action FOR EACH ROW EXECUTE FUNCTION guard_action_command_mutation();

CREATE FUNCTION assert_action_command_head(action_key text) RETURNS void LANGUAGE plpgsql AS $$
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
CREATE FUNCTION action_head_at_commit() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN PERFORM assert_action_command_head(NEW.id);RETURN NEW;END $$;
CREATE CONSTRAINT TRIGGER action_command_head AFTER INSERT OR UPDATE ON action DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION action_head_at_commit();

CREATE FUNCTION command_target_at_commit() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE c action_command; parent_r action_revision; parent_t action_command_target;
BEGIN
 SELECT * INTO c FROM action_command WHERE id=NEW.command_id AND organization_id=NEW.organization_id;
 IF c.id IS NULL THEN RAISE EXCEPTION 'missing target command' USING ERRCODE='23514'; END IF;
 IF c.outcome='accepted' THEN
  IF c.kind='create' THEN
   IF NEW.previous_version IS NOT NULL OR NEW.expected_version IS NOT NULL OR NEW.expected_revision_id IS NOT NULL OR NEW.result_version<>1 OR NEW.result_decision<>'open' OR NEW.previous_approval_id IS NOT NULL OR NEW.result_approval_id IS NOT NULL
   THEN RAISE EXCEPTION 'invalid create history target' USING ERRCODE='23514'; END IF;
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
 IF NEW.expected_parent_revision_id IS NOT NULL THEN
  SELECT * INTO parent_r FROM action_revision WHERE id=NEW.expected_parent_revision_id AND organization_id=NEW.organization_id;
  SELECT * INTO parent_t FROM action_command_target WHERE command_id=NEW.command_id AND action_id=parent_r.action_id AND organization_id=NEW.organization_id;
  IF parent_r.kind IS DISTINCT FROM 'collection' OR parent_r.sealed IS DISTINCT FROM true OR parent_t.expected_revision_id IS DISTINCT FROM parent_r.id OR parent_t.previous_revision_id IS DISTINCT FROM parent_r.id
   OR NOT EXISTS(SELECT 1 FROM action_membership WHERE parent_revision_id=parent_r.id AND child_action_id=NEW.action_id AND child_revision_id=NEW.expected_revision_id)
  THEN RAISE EXCEPTION 'batch command requires exact parent snapshot and member' USING ERRCODE='23514'; END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE CONSTRAINT TRIGGER command_target_snapshot AFTER INSERT ON action_command_target DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION command_target_at_commit();

CREATE FUNCTION approval_command_at_commit() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE c action_command; t action_command_target; r action_revision; a action; p action_policy_revision; rc action_review_content;
BEGIN
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
  (NEW.scope='generate' AND r.kind IN ('request','media') AND NEW.required_surface='internal_artifact') OR
  (NEW.scope='revise' AND r.kind IN ('request','media','listing','review_reply','collection') AND NEW.required_surface='internal_artifact'))
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
CREATE CONSTRAINT TRIGGER approval_command_snapshot AFTER INSERT ON action_approval DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION approval_command_at_commit();

CREATE FUNCTION guard_policy_command() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE c action_command;
BEGIN
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
CREATE TRIGGER policy_command_guard BEFORE INSERT OR UPDATE OR DELETE ON action_policy_revision FOR EACH ROW EXECUTE FUNCTION guard_policy_command();

CREATE FUNCTION command_completion_at_commit() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
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
CREATE CONSTRAINT TRIGGER command_result_complete AFTER INSERT ON action_command DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION command_completion_at_commit();

CREATE FUNCTION guard_personal_read() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE latest bigint;
BEGIN
 SELECT attention_version INTO latest FROM action WHERE id=NEW.action_id AND organization_id=NEW.organization_id;
 IF latest IS NULL OR NEW.seen_attention_version>latest THEN RAISE EXCEPTION 'read watermark is beyond visible history' USING ERRCODE='23514'; END IF;
 IF TG_OP='UPDATE' AND ((NEW.organization_id,NEW.user_id,NEW.action_id) IS DISTINCT FROM (OLD.organization_id,OLD.user_id,OLD.action_id) OR NEW.seen_attention_version<OLD.seen_attention_version)
 THEN RAISE EXCEPTION 'personal read identity/watermark cannot regress' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER personal_read_guard BEFORE INSERT OR UPDATE ON action_read FOR EACH ROW EXECUTE FUNCTION guard_personal_read();

-- SERVICE-ONLY AUTHORIZATION (not proven by these SQL constraints):
-- canonical principal/session creation; current org membership and operation scope;
-- API-key owner/revocation; Slack/Discord signed interaction plus member mapping;
-- real admin versus acting-for identity; policy rules/content semantics and billing.
-- The service locks a policy row while accepting policy authorization; workers lock
-- it before a new write/generation claim. Revoked authority permits readback only.
-- The service canonicalizes typed input and compares digest/version on key replay;
-- original immutable command/target/approval/execution rows reconstruct its response.


-- FLO-1355 ACTIVE design hardening, not a migration or deployment.
-- Apply after schema-core.sql and schema-content.sql in the disposable design harness.
-- No retired operation or historical receipt can enter these execution tables.
-- Requires PostgreSQL 15+ for NULLS NOT DISTINCT. Core parent owns RLS/domain FKs.
SET search_path = actions_design, public;

CREATE TYPE action_step_kind AS ENUM (
 'asc_app_info_localization_upsert','asc_version_localization_upsert',
 'asc_live_promotional_text_set','asc_editable_promotional_text_set',
 'asc_review_response_upsert','asc_app_clip_localization_create',
 'asc_app_clip_header_reserve','asc_app_clip_header_upload_chunk',
 'asc_app_clip_header_commit','asc_app_clip_incomplete_header_delete',
 'play_edit_create','play_listing_put','play_edit_commit','play_review_response_set',
 'asa_campaign_status_set','asa_campaign_budget_set','asa_keyword_bid_set',
 'asa_keyword_create','asa_negative_keyword_create','asa_negative_keyword_delete',
 'internal_generate_content','internal_revise_content','internal_commit_children',
 'internal_recheck_prerequisite'
);
CREATE TYPE action_resource_scope AS ENUM ('store_application','advertising_account');
CREATE TYPE action_observation_completeness AS ENUM ('complete','partial','unavailable');
CREATE TYPE action_output_kind AS ENUM ('revision','review_analysis','agent_run','no_work');
CREATE TYPE action_no_work_reason AS ENUM ('no_eligible_reviews');
CREATE TYPE action_non_application_basis AS ENUM ('pre_dispatch_failure','provider_rejection','provider_terminal_non_application','expired_uncommitted_edit');

-- These account IDs are immutable approved target facts, not connector row IDs.
ALTER TABLE action_review_content ADD COLUMN IF NOT EXISTS provider_account_id text;
ALTER TABLE action_listing_content ADD COLUMN IF NOT EXISTS provider_account_id text;
ALTER TABLE action_ad_content ADD COLUMN IF NOT EXISTS provider_account_id text;

-- An ASA account is not a store app. No fake remote_application_id sentinel.
ALTER TABLE action_resource_guard DROP CONSTRAINT action_resource_guard_pkey;
ALTER TABLE action_resource_guard ALTER COLUMN remote_application_id DROP NOT NULL;
ALTER TABLE action_resource_guard ADD COLUMN id uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE action_resource_guard ADD COLUMN scope action_resource_scope NOT NULL;
ALTER TABLE action_resource_guard ADD CONSTRAINT action_resource_guard_identity PRIMARY KEY(id);
ALTER TABLE action_resource_guard ADD CONSTRAINT action_resource_guard_target
 UNIQUE NULLS NOT DISTINCT(provider,provider_account_id,remote_application_id);
ALTER TABLE action_resource_guard ADD CONSTRAINT action_resource_guard_scope_shape CHECK (
 (provider='apple_search_ads' AND scope='advertising_account' AND remote_application_id IS NULL)
 OR (provider IN ('app_store_connect','google_play') AND scope='store_application'
     AND remote_application_id IS NOT NULL AND length(remote_application_id)>0)
);
ALTER TABLE action_resource_guard ADD CONSTRAINT action_resource_guard_nonempty_account
 CHECK(length(provider_account_id)>0);
ALTER TABLE action_execution ADD COLUMN resource_guard_id uuid REFERENCES action_resource_guard(id);
ALTER TABLE action_execution ADD COLUMN plan_version integer NOT NULL CHECK(plan_version>0);
ALTER TABLE action_execution ADD COLUMN writes_closed_at timestamptz;
ALTER TABLE action_execution ADD CONSTRAINT action_execution_writes_closed_time
 CHECK(writes_closed_at IS NULL OR writes_closed_at>=created_at);
ALTER TABLE action_execution ADD COLUMN cancelled_command_id text;
ALTER TABLE action_execution ADD CONSTRAINT action_execution_cancel_command_fk
 FOREIGN KEY(organization_id,cancelled_command_id) REFERENCES action_command(organization_id,id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE action_execution ADD CONSTRAINT action_execution_cancel_command_shape
 CHECK((phase='cancelled')=(cancelled_command_id IS NOT NULL));
ALTER TABLE action_execution ADD CONSTRAINT action_execution_cancelled_result
 CHECK((phase='cancelled')=(result='cancelled'));
ALTER TABLE action_execution ADD CONSTRAINT action_execution_settlement_time
 CHECK(settled_at IS NULL OR settled_at>=created_at);
ALTER TABLE action_execution ADD CONSTRAINT action_execution_uncertain_due
 CHECK(phase<>'uncertain' OR next_run_at IS NOT NULL);
ALTER TABLE action_execution ADD CONSTRAINT action_execution_claim_generation
 CHECK(phase<>'claimed' OR claim_generation>0);

ALTER TABLE action_execution_step ALTER COLUMN kind TYPE action_step_kind USING kind::action_step_kind;
ALTER TABLE action_execution_step ADD CONSTRAINT action_execution_step_media_reference
 FOREIGN KEY(organization_id,content_revision_id,media_slot)
 REFERENCES action_media_content(organization_id,revision_id,slot) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE action_execution_step ADD CONSTRAINT action_execution_step_chunk_shape CHECK (
 (kind='asc_app_clip_header_upload_chunk')=(upload_offset IS NOT NULL)
);
ALTER TABLE action_execution_step ADD CONSTRAINT action_execution_step_media_shape CHECK (
 (kind IN ('asc_app_clip_header_reserve','asc_app_clip_header_upload_chunk','asc_app_clip_header_commit'))
 =(media_slot IS NOT NULL)
);
-- One approved target has one effect of each kind; retries create attempts, never
-- duplicate steps. Reservation-derived byte chunks alone may repeat by range.
CREATE UNIQUE INDEX action_execution_step_single_effect ON action_execution_step(execution_id,kind)
 WHERE kind<>'asc_app_clip_header_upload_chunk';
CREATE UNIQUE INDEX action_execution_step_chunk_identity ON action_execution_step(execution_id,media_slot,upload_offset)
 WHERE kind='asc_app_clip_header_upload_chunk';
CREATE UNIQUE INDEX action_execution_step_native_key ON action_execution_step(native_idempotency_key)
 WHERE native_idempotency_key IS NOT NULL;

-- execution_id is intentional enforcement denormalization: it enables a single
-- active I/O attempt index across every step of one execution. Composite FK
-- prevents this copied value from diverging from step.execution_id.
ALTER TABLE action_execution_attempt ADD COLUMN execution_id text NOT NULL;
ALTER TABLE action_execution_attempt ADD COLUMN claim_token uuid NOT NULL;
ALTER TABLE action_execution_attempt ADD COLUMN input_attempt_id text;
ALTER TABLE action_execution_attempt ADD COLUMN output_kind action_output_kind;
ALTER TABLE action_execution_attempt ADD COLUMN output_revision_id text;
ALTER TABLE action_execution_attempt ADD COLUMN output_review_analysis_id text REFERENCES public.review_analysis(id);
ALTER TABLE action_execution_attempt ADD COLUMN output_agent_run_id text REFERENCES public.agent_run(id);
ALTER TABLE action_execution_attempt ADD COLUMN no_work_reason action_no_work_reason;
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_output_revision
 FOREIGN KEY(organization_id,output_revision_id) REFERENCES action_revision(organization_id,id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_output_shape CHECK(
 (result IS DISTINCT FROM 'generated' OR output_kind IS NOT NULL)
 AND (output_kind IS NULL OR (result IS NOT NULL AND result IN ('generated','discarded')))
 AND (
  (output_kind IS NULL AND num_nonnulls(output_revision_id,output_review_analysis_id,output_agent_run_id,no_work_reason)=0)
  OR (output_kind='revision' AND output_revision_id IS NOT NULL AND num_nonnulls(output_revision_id,output_review_analysis_id,output_agent_run_id,no_work_reason)=1)
  OR (output_kind='review_analysis' AND output_review_analysis_id IS NOT NULL AND num_nonnulls(output_revision_id,output_review_analysis_id,output_agent_run_id,no_work_reason)=1)
  OR (output_kind='agent_run' AND output_agent_run_id IS NOT NULL AND num_nonnulls(output_revision_id,output_review_analysis_id,output_agent_run_id,no_work_reason)=1)
  OR (output_kind='no_work' AND no_work_reason IS NOT NULL AND agent_run_id IS NOT NULL AND num_nonnulls(output_revision_id,output_review_analysis_id,output_agent_run_id,no_work_reason)=1)
 )
);
ALTER TABLE action_execution_attempt ADD COLUMN finalized_claim_generation bigint CHECK(finalized_claim_generation>0);
ALTER TABLE action_execution_attempt ADD COLUMN finalized_claim_token uuid;
ALTER TABLE action_execution_attempt ADD COLUMN evidence_command_id text;
ALTER TABLE action_execution_attempt ADD COLUMN observation_surface action_surface;
ALTER TABLE action_execution_attempt ADD COLUMN observation_completeness action_observation_completeness;
ALTER TABLE action_execution_attempt ADD COLUMN observed_at timestamptz;
ALTER TABLE action_execution_attempt ADD COLUMN non_application_basis action_non_application_basis;
ALTER TABLE action_execution_attempt ADD COLUMN provider_edit_expires_at timestamptz;
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_non_application_shape
 CHECK((result IS NOT DISTINCT FROM 'known_not_applied')=(non_application_basis IS NOT NULL));
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_execution_identity
 UNIQUE(organization_id,execution_id,id);
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_step_identity
 UNIQUE(organization_id,step_id,id);
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_step_execution
 FOREIGN KEY(organization_id,execution_id,step_id)
 REFERENCES action_execution_step(organization_id,execution_id,id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_subject_same_step
 FOREIGN KEY(organization_id,step_id,subject_attempt_id)
 REFERENCES action_execution_attempt(organization_id,step_id,id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_input_same_execution
 FOREIGN KEY(organization_id,execution_id,input_attempt_id)
 REFERENCES action_execution_attempt(organization_id,execution_id,id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_evidence_command
 FOREIGN KEY(organization_id,evidence_command_id)
 REFERENCES action_command(organization_id,id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_active_kind
 CHECK(kind IN ('write','readback','generation','late_evidence'));
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_active_identity
 CHECK(step_id IS NOT NULL AND number IS NOT NULL AND claim_generation IS NOT NULL
       AND started_at IS NOT NULL AND transport IS NOT NULL);
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_finalization_fence CHECK (
 kind='late_evidence'
 OR ((finished_at IS NOT NULL)=(finalized_claim_generation IS NOT NULL)
     AND (finalized_claim_generation IS NULL)=(finalized_claim_token IS NULL))
);
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_evidence_shape CHECK (
 (kind='late_evidence')=(evidence_command_id IS NOT NULL)
 AND (kind<>'late_evidence' OR (finished_at IS NOT NULL AND finalized_claim_generation IS NULL AND finalized_claim_token IS NULL))
);
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_result_by_kind CHECK (
 result IS NULL OR
 (kind='write' AND result IN ('acknowledged','known_not_applied','uncertain')) OR
 (kind='readback' AND result IN ('matched','mismatch','unreadable','known_not_applied')) OR
 (kind='generation' AND result IN ('generated','discarded','known_not_applied','uncertain')) OR
 kind='late_evidence'
);
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_verified_observation CHECK (
 (result NOT IN ('matched','mismatch') AND NOT (kind='readback' AND result='known_not_applied')) OR
 (observation_revision_id IS NOT NULL AND observation_surface IS NOT NULL
  AND observation_completeness IS NOT DISTINCT FROM 'complete' AND observed_at IS NOT NULL AND comparison_version IS NOT NULL)
);
ALTER TABLE action_execution_attempt ADD CONSTRAINT action_attempt_no_self_input CHECK(id IS DISTINCT FROM input_attempt_id);
CREATE UNIQUE INDEX action_one_active_attempt_per_execution ON action_execution_attempt(execution_id)
 WHERE finished_at IS NULL AND kind<>'late_evidence';
CREATE UNIQUE INDEX action_late_evidence_replay ON action_execution_attempt(subject_attempt_id,evidence_command_id)
 WHERE kind='late_evidence';

-- A delayed write response and a delayed readback response retain different
-- provenance. Both can resolve uncertainty without rewriting their subject.
CREATE FUNCTION action_write_has_resolution(write_id text) RETURNS boolean LANGUAGE sql STABLE AS $$
 SELECT EXISTS (
  SELECT 1 FROM action_execution_attempt evidence
  JOIN action_execution_attempt subject ON subject.id=evidence.subject_attempt_id
  WHERE evidence.finished_at IS NOT NULL AND (
    evidence.subject_attempt_id=write_id
    OR (evidence.kind='late_evidence' AND subject.kind='readback' AND subject.subject_attempt_id=write_id)
  ) AND (
    (evidence.result IN ('matched','known_not_applied') AND evidence.observation_completeness='complete')
    OR (evidence.kind='late_evidence' AND subject.kind='write' AND evidence.result IN ('acknowledged','known_not_applied'))
  )
 );
$$;

-- A claim is business exclusion, not proof that provider I/O can be revoked.
-- Cancelled/settled execution state is immutable; later evidence goes to attempts.
CREATE FUNCTION action_guard_execution_transition() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE a action_approval%ROWTYPE; c action_command%ROWTYPE;
BEGIN
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'executions are retained'; END IF;
 IF TG_OP='INSERT' AND (NEW.phase<>'ready' OR NEW.claim_generation<>0 OR NEW.schedule_generation<>1 OR NEW.writes_closed_at IS NOT NULL)
 THEN RAISE EXCEPTION 'new execution begins ready with an unclaimed open plan'; END IF;
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
 IF NEW.writes_closed_at IS NOT NULL AND NOT EXISTS(SELECT 1 FROM action_execution_step WHERE execution_id=NEW.id)
 THEN RAISE EXCEPTION 'empty plan cannot close its mutation phase'; END IF;
 IF NEW.writes_closed_at IS NOT NULL AND (
  EXISTS(SELECT 1 FROM action_execution_attempt x WHERE x.execution_id=NEW.id AND x.finished_at IS NULL AND x.kind='write')
  OR EXISTS(SELECT 1 FROM action_execution_step s WHERE s.execution_id=NEW.id
    AND s.kind NOT IN ('internal_generate_content','internal_revise_content','internal_commit_children','internal_recheck_prerequisite')
    AND NOT EXISTS(SELECT 1 FROM action_execution_attempt x WHERE x.step_id=s.id AND x.finished_at IS NOT NULL
      AND (x.result='acknowledged' OR (x.result='matched' AND x.observation_completeness='complete'))))
 ) THEN RAISE EXCEPTION 'close mutation phase only after every planned effect has evidence'; END IF;
 IF NEW.writes_closed_at IS NOT NULL AND EXISTS(
  SELECT 1 FROM action_execution_attempt w WHERE w.execution_id=NEW.id AND w.kind='write' AND w.result='uncertain'
    AND NOT action_write_has_resolution(w.id)
 ) THEN RAISE EXCEPTION 'unresolved write prevents closing mutation phase'; END IF;
 IF NEW.phase IN ('settled','cancelled') AND EXISTS (
  SELECT 1 FROM action_execution_attempt x WHERE x.execution_id=NEW.id AND x.finished_at IS NULL
 ) THEN RAISE EXCEPTION 'cannot settle while an I/O attempt remains open'; END IF;
 IF NEW.phase IN ('settled','cancelled') AND EXISTS (
  SELECT 1 FROM action_execution_attempt w WHERE w.execution_id=NEW.id AND w.kind='write' AND w.result='uncertain'
    AND NOT action_write_has_resolution(w.id)
 ) THEN RAISE EXCEPTION 'uncertain provider effect cannot be hidden by terminal state'; END IF;
 IF NEW.phase='cancelled' AND EXISTS (
  SELECT 1 FROM action_execution_attempt x WHERE x.execution_id=NEW.id AND x.kind IN ('write','generation')
 ) THEN RAISE EXCEPTION 'Undo cannot cancel an execution after work started'; END IF;
 IF NEW.phase='cancelled' THEN
  SELECT * INTO c FROM action_command WHERE organization_id=NEW.organization_id AND id=NEW.cancelled_command_id;
  IF c.id IS NULL OR c.kind<>'undo' OR c.outcome<>'accepted' OR a.undo_deadline<clock_timestamp()
   OR NOT EXISTS(SELECT 1 FROM action_command_target t WHERE t.organization_id=NEW.organization_id AND t.command_id=c.id AND t.action_id=a.action_id)
  THEN RAISE EXCEPTION 'Undo needs accepted targeted command before server deadline'; END IF;
 END IF;
 IF NEW.phase='settled' AND NEW.result<>'failed' THEN
  IF NOT EXISTS(SELECT 1 FROM action_execution_step s WHERE s.execution_id=NEW.id)
   OR EXISTS(SELECT 1 FROM action_execution_step s WHERE s.execution_id=NEW.id AND NOT EXISTS(
    SELECT 1 FROM action_execution_attempt x WHERE x.step_id=s.id AND x.finished_at IS NOT NULL AND (
      (x.result='matched' AND x.observation_completeness='complete' AND x.observation_surface=s.required_surface)
      OR (x.result='acknowledged' AND s.required_surface='provider_response')
      OR (x.result='generated' AND s.required_surface='internal_artifact'))))
  THEN RAISE EXCEPTION 'successful execution requires evidence for every planned step'; END IF;
  IF a.required_surface NOT IN ('provider_response','internal_artifact') AND NOT EXISTS(
    SELECT 1 FROM action_execution_attempt x WHERE x.execution_id=NEW.id AND x.finished_at IS NOT NULL
      AND x.result='matched' AND x.observation_completeness='complete' AND x.observation_surface=a.required_surface
  ) THEN RAISE EXCEPTION 'terminal success must satisfy approval surface, not only intermediate step acknowledgements'; END IF;
  IF (NEW.result='acknowledged_only' AND a.required_surface<>'provider_response')
   OR (NEW.result='verified_editable' AND a.required_surface<>'editable_listing')
   OR (NEW.result='verified_live' AND a.required_surface NOT IN ('live_listing','review_response','advertising_resource'))
   OR (NEW.result='generated' AND (a.scope NOT IN ('generate','revise') OR a.required_surface<>'internal_artifact'))
  THEN RAISE EXCEPTION 'execution result does not meet approval evidence contract'; END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER action_execution_transition BEFORE INSERT OR UPDATE OR DELETE ON action_execution
 FOR EACH ROW EXECUTE FUNCTION action_guard_execution_transition();

CREATE FUNCTION action_guard_approval_execution_authority() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE r action_revision%ROWTYPE; a action%ROWTYPE; c action_command%ROWTYPE;
BEGIN
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
CREATE TRIGGER action_approval_authority BEFORE INSERT OR UPDATE OR DELETE ON action_approval
 FOR EACH ROW EXECUTE FUNCTION action_guard_approval_execution_authority();

CREATE FUNCTION action_guard_execution_step() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE e action_execution%ROWTYPE; ap action_approval%ROWTYPE; r action_revision%ROWTYPE;
 pred action_execution_step%ROWTYPE; g action_resource_guard%ROWTYPE;
 rc action_review_content%ROWTYPE; lc action_listing_content%ROWTYPE;
 ad action_ad_content%ROWTYPE;
 actual_provider text; actual_account text; actual_app text;
BEGIN
 IF TG_OP<>'INSERT' THEN RAISE EXCEPTION 'execution steps are immutable'; END IF;
 SELECT * INTO e FROM action_execution WHERE organization_id=NEW.organization_id AND id=NEW.execution_id FOR UPDATE;
 SELECT * INTO ap FROM action_approval WHERE organization_id=e.organization_id AND id=e.approval_id;
 SELECT * INTO r FROM action_revision WHERE organization_id=ap.organization_id AND id=ap.revision_id;
 IF e.id IS NULL OR e.phase IN ('settled','cancelled') OR e.writes_closed_at IS NOT NULL THEN RAISE EXCEPTION 'step requires active open plan'; END IF;
 IF NEW.content_revision_id IS DISTINCT FROM ap.revision_id THEN RAISE EXCEPTION 'step must bind exact approved revision'; END IF;
 IF NEW.input_step_id IS NOT NULL THEN
  SELECT * INTO pred FROM action_execution_step WHERE organization_id=NEW.organization_id AND id=NEW.input_step_id;
  IF pred.execution_id IS DISTINCT FROM NEW.execution_id OR pred.ordinal>=NEW.ordinal
  THEN RAISE EXCEPTION 'step dependency must precede it within same execution'; END IF;
 END IF;
 IF (NEW.kind='play_listing_put' AND pred.kind IS DISTINCT FROM 'play_edit_create')
  OR (NEW.kind='play_edit_commit' AND pred.kind IS DISTINCT FROM 'play_listing_put')
  OR (NEW.kind IN ('asc_app_clip_header_upload_chunk','asc_app_clip_header_commit') AND pred.kind IS DISTINCT FROM 'asc_app_clip_header_reserve')
 THEN RAISE EXCEPTION 'provider step lacks its exact typed predecessor'; END IF;
 IF NEW.kind='asc_app_clip_header_upload_chunk' THEN
  IF NOT EXISTS(SELECT 1 FROM action_media_content m WHERE m.organization_id=NEW.organization_id
   AND m.revision_id=NEW.content_revision_id AND m.slot=NEW.media_slot
   AND m.availability='stored' AND NEW.upload_offset+NEW.upload_length<=m.byte_length)
   OR EXISTS(SELECT 1 FROM action_execution_step other WHERE other.execution_id=e.id
    AND other.kind='asc_app_clip_header_upload_chunk' AND other.media_slot=NEW.media_slot
    AND NEW.upload_offset<other.upload_offset+other.upload_length
    AND other.upload_offset<NEW.upload_offset+NEW.upload_length)
  THEN RAISE EXCEPTION 'upload chunk must fit exact pinned bytes without overlap'; END IF;
 END IF;
 IF EXISTS(SELECT 1 FROM action_execution_attempt WHERE execution_id=e.id) AND EXISTS(
  SELECT 1 FROM action_execution_step WHERE execution_id=e.id AND ordinal>=NEW.ordinal
 ) THEN RAISE EXCEPTION 'running plan only permits appended steps'; END IF;
 IF NEW.kind IN ('internal_generate_content','internal_revise_content','internal_commit_children','internal_recheck_prerequisite') THEN
  IF NEW.recovery_mode<>'internal_atomic' OR NEW.media_slot IS NOT NULL
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
 SELECT * INTO lc FROM action_listing_content WHERE organization_id=NEW.organization_id AND revision_id=NEW.content_revision_id;
 SELECT * INTO ad FROM action_ad_content WHERE organization_id=NEW.organization_id AND revision_id=NEW.content_revision_id;
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
  IF NEW.kind IN ('play_edit_create','play_listing_put','play_edit_commit') THEN
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
    OR NOT EXISTS(SELECT 1 FROM action_listing_content baseline WHERE baseline.organization_id=r.organization_id
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
   IF NEW.media_slot IS NOT NULL AND NEW.media_slot IS DISTINCT FROM lc.app_clip_header_media_slot
   THEN RAISE EXCEPTION 'App Clip image must use exact approved media slot'; END IF;
  END IF;
  actual_provider:=CASE WHEN lc.store='ios' THEN 'app_store_connect' ELSE 'google_play' END;
  actual_account:=lc.provider_account_id; actual_app:=CASE WHEN lc.store='ios' THEN lc.provider_app_id ELSE lc.package_name END;
 END IF;
 SELECT * INTO g FROM action_resource_guard WHERE id=e.resource_guard_id;
 IF actual_account IS NULL OR g.id IS NULL OR g.provider IS DISTINCT FROM actual_provider
  OR g.provider_account_id IS DISTINCT FROM actual_account OR g.remote_application_id IS DISTINCT FROM actual_app
 THEN RAISE EXCEPTION 'execution guard must identify approved canonical provider resource'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER action_execution_step_guard BEFORE INSERT OR UPDATE OR DELETE ON action_execution_step
 FOR EACH ROW EXECUTE FUNCTION action_guard_execution_step();

CREATE FUNCTION action_guard_attempt() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE e action_execution%ROWTYPE; s action_execution_step%ROWTYPE;
 subject action_execution_attempt%ROWTYPE; input_row action_execution_attempt%ROWTYPE;
 c action_command%ROWTYPE; g action_resource_guard%ROWTYPE; r action_revision%ROWTYPE;
 approved_revision action_revision%ROWTYPE; ap action_approval%ROWTYPE; a action%ROWTYPE; policy action_policy_revision%ROWTYPE;
BEGIN
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'attempt evidence is retained'; END IF;
 SELECT * INTO s FROM action_execution_step WHERE organization_id=NEW.organization_id AND id=NEW.step_id;
 SELECT * INTO e FROM action_execution WHERE organization_id=NEW.organization_id AND id=s.execution_id FOR UPDATE;
 SELECT * INTO ap FROM action_approval WHERE organization_id=e.organization_id AND id=e.approval_id;
 SELECT * INTO approved_revision FROM action_revision WHERE organization_id=ap.organization_id AND id=ap.revision_id;
 SELECT * INTO a FROM action WHERE organization_id=ap.organization_id AND id=ap.action_id FOR UPDATE;
 IF s.id IS NULL OR e.id IS NULL OR NEW.execution_id IS DISTINCT FROM e.id THEN RAISE EXCEPTION 'attempt requires exact execution step'; END IF;
 IF TG_OP='UPDATE' THEN
  IF OLD.finished_at IS NOT NULL THEN RAISE EXCEPTION 'finalized attempt is immutable; append evidence'; END IF;
  IF ROW(NEW.id,NEW.organization_id,NEW.execution_id,NEW.step_id,NEW.number,NEW.kind,NEW.claim_generation,NEW.claim_token,NEW.subject_attempt_id,NEW.input_attempt_id,NEW.started_at,NEW.transport,NEW.connector_id,NEW.agent_run_id,NEW.recorded_at)
   IS DISTINCT FROM ROW(OLD.id,OLD.organization_id,OLD.execution_id,OLD.step_id,OLD.number,OLD.kind,OLD.claim_generation,OLD.claim_token,OLD.subject_attempt_id,OLD.input_attempt_id,OLD.started_at,OLD.transport,OLD.connector_id,OLD.agent_run_id,OLD.recorded_at)
  THEN RAISE EXCEPTION 'attempt start identity is immutable'; END IF;
  IF NEW.finished_at IS NULL OR e.phase<>'claimed' OR e.claim_token IS DISTINCT FROM NEW.finalized_claim_token
   OR e.claim_generation IS DISTINCT FROM NEW.finalized_claim_generation OR e.claim_expires_at<=clock_timestamp()
  THEN RAISE EXCEPTION 'attempt settlement requires live current execution claim'; END IF;
 ELSE
  IF NEW.number<>(SELECT coalesce(max(number),0)+1 FROM action_execution_attempt WHERE step_id=s.id)
  THEN RAISE EXCEPTION 'attempt number must append within locked execution'; END IF;
  IF NEW.kind='late_evidence' THEN
   SELECT * INTO c FROM action_command WHERE organization_id=NEW.organization_id AND id=NEW.evidence_command_id;
   SELECT * INTO subject FROM action_execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.subject_attempt_id;
   IF c.id IS NULL OR c.outcome<>'accepted' OR c.kind NOT IN ('record_observation','record_attempt')
    OR NOT EXISTS(SELECT 1 FROM action_command_target t WHERE t.organization_id=NEW.organization_id AND t.command_id=c.id AND t.action_id=ap.action_id)
    OR subject.step_id IS DISTINCT FROM NEW.step_id OR subject.kind='late_evidence'
    OR NEW.claim_generation IS DISTINCT FROM subject.claim_generation OR NEW.claim_token IS DISTINCT FROM subject.claim_token
    OR NEW.transport IS DISTINCT FROM subject.transport OR NEW.started_at IS DISTINCT FROM subject.started_at
   THEN RAISE EXCEPTION 'late evidence must name original attempt and attributable evidence command'; END IF;
   IF NOT ((subject.kind='write' AND NEW.result IN ('acknowledged','known_not_applied','uncertain'))
    OR (subject.kind='readback' AND NEW.result IN ('matched','mismatch','unreadable','known_not_applied'))
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
    SELECT 1 FROM action_execution_step prior WHERE prior.execution_id=e.id AND prior.ordinal<s.ordinal
      AND NOT EXISTS(SELECT 1 FROM action_execution_attempt done WHERE done.step_id=prior.id AND done.finished_at IS NOT NULL
        AND ((done.result='matched' AND done.observation_completeness='complete' AND done.observation_surface=prior.required_surface)
          OR (done.result='acknowledged' AND prior.required_surface='provider_response')
          OR (done.result='generated' AND prior.required_surface='internal_artifact')))
   ) THEN RAISE EXCEPTION 'earlier planned steps must satisfy their required evidence before next mutation'; END IF;
   IF NEW.kind='write' THEN
    IF e.writes_closed_at IS NOT NULL THEN RAISE EXCEPTION 'mutation phase closed; only readback remains'; END IF;
    IF EXISTS(SELECT 1 FROM action_execution_attempt done WHERE done.step_id=s.id AND done.finished_at IS NOT NULL
      AND done.result IN ('acknowledged','matched'))
    THEN RAISE EXCEPTION 'effect already applied; further requests may only verify'; END IF;
    IF s.kind IN ('internal_generate_content','internal_revise_content','internal_commit_children','internal_recheck_prerequisite')
    THEN RAISE EXCEPTION 'internal step cannot issue provider write'; END IF;
    IF s.kind='asc_app_clip_header_commit' AND NOT EXISTS(
      SELECT 1 FROM action_media_content m WHERE m.organization_id=s.organization_id
       AND m.revision_id=s.content_revision_id AND m.slot=s.media_slot AND m.byte_length>0
       AND m.byte_length=(SELECT sum(ch.upload_length) FROM action_execution_step ch
        WHERE ch.execution_id=e.id AND ch.kind='asc_app_clip_header_upload_chunk' AND ch.media_slot=s.media_slot AND ch.ordinal<s.ordinal)
    ) THEN RAISE EXCEPTION 'header commit requires every pinned byte represented by preceding nonoverlapping chunks'; END IF;
    SELECT * INTO g FROM action_resource_guard WHERE id=e.resource_guard_id;
    IF g.holder_execution_id IS DISTINCT FROM e.id OR g.holder_organization_id IS DISTINCT FROM e.organization_id
    THEN RAISE EXCEPTION 'provider write requires held canonical resource guard'; END IF;
    IF EXISTS(SELECT 1 FROM action_execution_attempt w WHERE w.execution_id=e.id AND w.kind='write' AND w.result='uncertain'
      AND NOT action_write_has_resolution(w.id))
    THEN RAISE EXCEPTION 'unresolved earlier write permits readback only'; END IF;
   END IF;
   IF NEW.kind='generation' AND (NEW.transport<>'internal' OR s.kind NOT IN ('internal_generate_content','internal_revise_content','internal_commit_children','internal_recheck_prerequisite'))
   THEN RAISE EXCEPTION 'generation requires internal typed step'; END IF;
  END IF;
 END IF;
 IF NEW.subject_attempt_id IS NOT NULL THEN
  SELECT * INTO subject FROM action_execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.subject_attempt_id;
  IF subject.step_id IS DISTINCT FROM NEW.step_id OR subject.number>=NEW.number OR subject.kind='late_evidence'
  THEN RAISE EXCEPTION 'observation subject must be earlier actual attempt on same step'; END IF;
 END IF;
 IF NEW.input_attempt_id IS NOT NULL THEN
  SELECT * INTO input_row FROM action_execution_attempt WHERE organization_id=NEW.organization_id AND id=NEW.input_attempt_id;
  IF input_row.execution_id IS DISTINCT FROM e.id OR input_row.step_id IS DISTINCT FROM s.input_step_id
   OR input_row.finished_at IS NULL OR input_row.result NOT IN ('acknowledged','matched','generated')
  THEN RAISE EXCEPTION 'input must reference recorded successful result of declared predecessor'; END IF;
 ELSIF s.input_step_id IS NOT NULL AND NEW.kind IN ('write','generation') THEN
  RAISE EXCEPTION 'dependent request requires exact input attempt result';
 END IF;
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
    OR (NEW.non_application_basis='provider_terminal_non_application' AND (NEW.provider_request_id IS NULL OR subject.provider_request_id IS NULL OR NEW.provider_request_id IS DISTINCT FROM subject.provider_request_id))
    OR (NEW.non_application_basis='expired_uncommitted_edit' AND (
      s.kind<>'play_listing_put' OR NEW.provider_edit_id IS NULL
      OR NOT EXISTS(SELECT 1 FROM action_execution_attempt created JOIN action_execution_step create_step ON create_step.id=created.step_id
        WHERE create_step.execution_id=e.id AND create_step.kind='play_edit_create' AND created.result IN ('acknowledged','matched') AND created.provider_edit_id=NEW.provider_edit_id)
      OR NEW.provider_edit_expires_at IS NULL OR NEW.provider_edit_expires_at>NEW.observed_at
      OR EXISTS(SELECT 1 FROM action_execution_step commit_step JOIN action_execution_attempt commit_attempt ON commit_attempt.step_id=commit_step.id
        WHERE commit_step.execution_id=e.id AND commit_step.kind='play_edit_commit' AND commit_attempt.kind='write')
    ))
   THEN RAISE EXCEPTION 'negative read is not proof of final non-application'; END IF;
  ELSIF NEW.non_application_basis NOT IN ('pre_dispatch_failure','provider_rejection') THEN
   RAISE EXCEPTION 'direct failure requires pre-dispatch or definitive provider rejection evidence';
  END IF;
 END IF;
 IF NEW.result IN ('acknowledged','matched') THEN
  IF (s.kind='play_edit_create' AND NEW.provider_edit_id IS NULL)
   OR (s.kind IN ('asc_app_info_localization_upsert','asc_version_localization_upsert','asc_app_clip_localization_create') AND NEW.provider_localization_id IS NULL)
   OR (s.kind='asc_app_clip_header_reserve' AND NEW.provider_media_id IS NULL)
   OR (s.kind IN ('asa_keyword_create','asa_negative_keyword_create') AND NEW.provider_resource_id IS NULL)
  THEN RAISE EXCEPTION 'successful provider creation requires its typed durable result identifier'; END IF;
 END IF;
 IF ((s.kind IN ('internal_generate_content','internal_revise_content','internal_commit_children','internal_recheck_prerequisite')) AND NEW.transport<>'internal')
  OR ((s.kind IN ('play_edit_create','play_listing_put','play_edit_commit','play_review_response_set')) AND NEW.transport NOT IN ('play_api','play_session','play_browser'))
  OR ((s.kind IN ('asa_campaign_status_set','asa_campaign_budget_set','asa_keyword_bid_set','asa_keyword_create','asa_negative_keyword_create','asa_negative_keyword_delete')) AND NEW.transport<>'asa_api')
  OR ((s.kind IN ('asc_app_info_localization_upsert','asc_version_localization_upsert','asc_live_promotional_text_set','asc_editable_promotional_text_set','asc_review_response_upsert','asc_app_clip_localization_create','asc_app_clip_header_reserve','asc_app_clip_header_upload_chunk','asc_app_clip_header_commit','asc_app_clip_incomplete_header_delete')) AND NEW.transport NOT IN ('asc_api','asc_browser'))
 THEN RAISE EXCEPTION 'attempt transport does not implement its typed provider step'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER action_execution_attempt_guard BEFORE INSERT OR UPDATE OR DELETE ON action_execution_attempt
 FOR EACH ROW EXECUTE FUNCTION action_guard_attempt();

CREATE FUNCTION action_guard_resource_holder() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE old_execution action_execution%ROWTYPE; new_execution action_execution%ROWTYPE;
BEGIN
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'canonical resource guard rows are retained'; END IF;
 IF TG_OP='UPDATE' THEN
  IF ROW(NEW.id,NEW.provider,NEW.provider_account_id,NEW.remote_application_id,NEW.scope)
    IS DISTINCT FROM ROW(OLD.id,OLD.provider,OLD.provider_account_id,OLD.remote_application_id,OLD.scope)
  THEN RAISE EXCEPTION 'canonical resource identity is immutable'; END IF;
  IF OLD.holder_execution_id IS NOT NULL AND NEW.holder_execution_id IS DISTINCT FROM OLD.holder_execution_id THEN
   SELECT * INTO old_execution FROM action_execution WHERE id=OLD.holder_execution_id FOR UPDATE;
   IF old_execution.phase NOT IN ('settled','cancelled') AND old_execution.writes_closed_at IS NULL
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
CREATE TRIGGER action_resource_holder_guard BEFORE INSERT OR UPDATE OR DELETE ON action_resource_guard
 FOR EACH ROW EXECUTE FUNCTION action_guard_resource_holder();

-- SQL privileges in the actual migration must allow mutations only through the
-- transaction-owning Actions adapters. These triggers are integrity defenses,
-- not a substitute for canonical organization-member/policy authorization.
-- No native mode is enabled by this candidate. Late evidence never mutates a
-- finalized attempt or a settled execution; a new explicit reconciliation
-- decision consumes it. A transaction-level resource lock remains held only
-- for claim changes, never during provider I/O.


-- Exact existing domain identities. The isolated design harness supplies only identity stubs;
-- the real Drizzle migration chain must validate these bindings against the full repository schema.
SET search_path=actions_design,public;
ALTER TABLE action ADD FOREIGN KEY(organization_id) REFERENCES public.organization(id);
ALTER TABLE action ADD FOREIGN KEY(asset_id) REFERENCES public.asset(id);
ALTER TABLE action ADD FOREIGN KEY(owner_user_id) REFERENCES public."user"(id);
ALTER TABLE action_command ADD FOREIGN KEY(organization_id) REFERENCES public.organization(id);
ALTER TABLE action_command ADD FOREIGN KEY(acting_for_user_id) REFERENCES public."user"(id);
ALTER TABLE action_command ADD FOREIGN KEY(actor_slack_integration_id) REFERENCES public.slack_integration(id);
ALTER TABLE action_command ADD FOREIGN KEY(actor_discord_integration_id) REFERENCES public.discord_integration(id);
ALTER TABLE action_command ADD FOREIGN KEY(actor_user_id) REFERENCES public."user"(id);
ALTER TABLE action_command ADD FOREIGN KEY(actor_api_key_id) REFERENCES public.api_key(id);
ALTER TABLE action_command ADD FOREIGN KEY(actor_agent_run_id) REFERENCES public.agent_run(id);
ALTER TABLE action_execution_attempt ADD FOREIGN KEY(agent_run_id) REFERENCES public.agent_run(id);
ALTER TABLE action_execution_attempt ADD FOREIGN KEY(connector_id) REFERENCES public.data_connector(id);
ALTER TABLE action_read ADD FOREIGN KEY(user_id) REFERENCES public."user"(id);
ALTER TABLE action_policy_revision ADD FOREIGN KEY(asset_id) REFERENCES public.asset(id);

CREATE TYPE action_source_kind AS ENUM ('agent_run','recommendation','recommendation_variant','report_version','backlog_item','experiment','action');
CREATE TABLE action_revision_source (
 id text PRIMARY KEY,
 organization_id text NOT NULL,
 revision_id text NOT NULL,
 kind action_source_kind NOT NULL,
 source_agent_run_id text REFERENCES public.agent_run(id),
 source_recommendation_id text REFERENCES public.aso_recommendation(id),
 source_variant_id text REFERENCES public.aso_recommendation_variant(id),
 source_report_version_id text REFERENCES public.report_version(id),
 source_backlog_id text REFERENCES public.opportunity_backlog(id),
 source_experiment_id text REFERENCES public.aso_experiment(id),
 source_action_id text,
 source_plan_coordinate text,
 source_finding_coordinate text,
 source_candidate_coordinate text,
 FOREIGN KEY(organization_id,revision_id) REFERENCES action_revision(organization_id,id),
 FOREIGN KEY(organization_id,source_action_id) REFERENCES action(organization_id,id),
 CHECK(num_nonnulls(source_agent_run_id,source_recommendation_id,source_variant_id,source_report_version_id,source_backlog_id,source_experiment_id,source_action_id)=1),
 CHECK((kind='agent_run')=(source_agent_run_id IS NOT NULL)),
 CHECK((kind='recommendation')=(source_recommendation_id IS NOT NULL)),
 CHECK((kind='recommendation_variant')=(source_variant_id IS NOT NULL)),
 CHECK((kind='report_version')=(source_report_version_id IS NOT NULL)),
 CHECK((kind='backlog_item')=(source_backlog_id IS NOT NULL)),
 CHECK((kind='experiment')=(source_experiment_id IS NOT NULL)),
 CHECK((kind='action')=(source_action_id IS NOT NULL)),
 CHECK(kind IN ('agent_run','report_version') OR (source_plan_coordinate IS NULL AND source_finding_coordinate IS NULL AND source_candidate_coordinate IS NULL))
);
CREATE INDEX action_revision_source_owner ON action_revision_source(organization_id,revision_id);
CREATE TRIGGER provenance_seal_guard BEFORE INSERT OR UPDATE OR DELETE ON action_revision_source FOR EACH ROW EXECUTE FUNCTION guard_revision_content_edit();
ALTER TABLE action_revision_source ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_scope ON action_revision_source USING(organization_id=current_setting('fload.organization_id',true)) WITH CHECK(organization_id=current_setting('fload.organization_id',true));

CREATE FUNCTION validate_domain_tenant() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE owner_id text;
BEGIN
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
CREATE TRIGGER action_domain_scope BEFORE INSERT OR UPDATE ON action FOR EACH ROW EXECUTE FUNCTION validate_domain_tenant();
CREATE TRIGGER provenance_domain_scope BEFORE INSERT OR UPDATE ON action_revision_source FOR EACH ROW EXECUTE FUNCTION validate_domain_tenant();

CREATE TRIGGER policy_domain_scope BEFORE INSERT OR UPDATE ON action_policy_revision FOR EACH ROW EXECUTE FUNCTION validate_domain_tenant();
CREATE FUNCTION validate_command_integration_tenant() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.actor_slack_integration_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.slack_integration WHERE id=NEW.actor_slack_integration_id AND organization_id=NEW.organization_id) THEN RAISE EXCEPTION 'Slack integration tenant mismatch' USING ERRCODE='23514'; END IF;
 IF NEW.actor_discord_integration_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.discord_integration WHERE id=NEW.actor_discord_integration_id AND organization_id=NEW.organization_id) THEN RAISE EXCEPTION 'Discord integration tenant mismatch' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER command_integration_scope BEFORE INSERT ON action_command FOR EACH ROW EXECUTE FUNCTION validate_command_integration_tenant();
