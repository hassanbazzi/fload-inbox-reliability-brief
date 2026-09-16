ALTER TYPE "actions"."action_command_kind" ADD VALUE 'record_progress' BEFORE 'resolve_dependency';--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD COLUMN "progress_execution_id" text;--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD COLUMN "progress_phase" "actions"."action_execution_phase";--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD COLUMN "progress_result" "actions"."action_execution_result";--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD COLUMN "progress_hold_reason" "actions"."action_hold_reason";--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD CONSTRAINT "action_command_progress_execution_fk" FOREIGN KEY ("organization_id","progress_execution_id") REFERENCES "actions"."action_execution"("organization_id","id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "actions"."action_command" ADD CONSTRAINT "action_command_progress_shape" CHECK ((kind::text = 'record_progress' AND progress_execution_id IS NOT NULL AND progress_phase IS NOT NULL AND progress_phase IN ('verification_due','uncertain','blocked','settled') AND principal_kind = 'system' AND channel = 'worker' AND outcome = 'accepted' AND (progress_phase = 'settled') = (progress_result IS NOT NULL) AND (progress_phase NOT IN ('blocked','uncertain') OR progress_hold_reason IS NOT NULL)) OR (kind::text <> 'record_progress' AND progress_execution_id IS NULL AND progress_phase IS NULL AND progress_result IS NULL AND progress_hold_reason IS NULL));
--> statement-breakpoint
-- Workflow progress is a typed, immutable fact captured with the execution transaction.
CREATE FUNCTION actions.guard_progress_command() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,public AS $$
DECLARE e action_execution;
BEGIN
 IF NEW.kind::text <> 'record_progress' THEN RETURN NEW; END IF;
 SELECT * INTO e FROM action_execution WHERE organization_id=NEW.organization_id AND id=NEW.progress_execution_id;
 IF e.id IS NULL OR ROW(e.phase,e.result,e.hold_reason) IS DISTINCT FROM ROW(NEW.progress_phase,NEW.progress_result,NEW.progress_hold_reason)
 THEN RAISE EXCEPTION 'progress must capture the exact persisted execution' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE TRIGGER action_progress_command BEFORE INSERT ON actions.action_command FOR EACH ROW EXECUTE FUNCTION actions.guard_progress_command();
--> statement-breakpoint
CREATE FUNCTION actions.guard_progress_attention() RETURNS trigger LANGUAGE plpgsql SET search_path=actions,public AS $$
DECLARE c action_command; ap action_approval;
BEGIN
 SELECT * INTO c FROM action_command WHERE organization_id=NEW.organization_id AND id=NEW.last_command_id;
 IF c.kind::text <> 'record_progress' THEN RETURN NEW; END IF;
 IF ROW(NEW.decision,NEW.current_revision_id,NEW.current_approval_id,NEW.owner_user_id,NEW.snoozed_until,NEW.archived_at,NEW.successor_action_id,NEW.priority)
  IS DISTINCT FROM ROW(OLD.decision,OLD.current_revision_id,OLD.current_approval_id,OLD.owner_user_id,OLD.snoozed_until,OLD.archived_at,OLD.successor_action_id,OLD.priority)
  OR NEW.attention_version<>OLD.attention_version+1 OR NEW.version<>OLD.version+1
 THEN RAISE EXCEPTION 'progress can only advance attention and its history version' USING ERRCODE='23514'; END IF;
 SELECT p.* INTO ap FROM action_execution e JOIN action_approval p ON p.organization_id=e.organization_id AND p.id=e.approval_id
  WHERE e.organization_id=NEW.organization_id AND e.id=c.progress_execution_id;
 IF NOT ((ap.action_id=OLD.id AND ap.id=OLD.current_approval_id AND ap.revision_id=OLD.current_revision_id)
  OR EXISTS(SELECT 1 FROM action_membership m JOIN action child ON child.organization_id=m.organization_id AND child.id=m.child_action_id
   WHERE m.organization_id=OLD.organization_id AND m.parent_revision_id=OLD.current_revision_id AND m.child_action_id=ap.action_id
    AND m.child_revision_id=ap.revision_id AND child.parent_action_id=OLD.id AND child.current_approval_id=ap.id))
 THEN RAISE EXCEPTION 'progress cannot resurface unrelated or changed work' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
--> statement-breakpoint
CREATE TRIGGER action_progress_attention BEFORE UPDATE ON actions.action FOR EACH ROW EXECUTE FUNCTION actions.guard_progress_attention();
