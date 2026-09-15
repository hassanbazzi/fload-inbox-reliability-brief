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
