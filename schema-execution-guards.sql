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
