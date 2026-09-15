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
