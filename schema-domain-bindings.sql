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
