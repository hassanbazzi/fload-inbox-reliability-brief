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
