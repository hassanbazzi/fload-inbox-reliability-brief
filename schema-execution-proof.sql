-- Append-only companion to schema-proof.sql. Synthetic IDs; database integrity
-- tests only. No live provider, migration or true concurrent-session claim.
SET search_path=actions_design,public;
CREATE FUNCTION proof_provider_approval(ticket text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
 PERFORM proof_review(ticket);
 PERFORM proof_command('approve-'||ticket,'approve');
 PERFORM proof_target('approve-'||ticket,ticket,'approved','approval-'||ticket);
 INSERT INTO action_approval(id,organization_id,action_id,revision_id,command_id,scope,undo_deadline,required_surface,authorization_version,created_at)
 SELECT 'approval-'||ticket,'proof-org',ticket,ticket||'-r1',id,'perform',accepted_at+interval '5 seconds','review_response',1,accepted_at FROM action_command WHERE id='approve-'||ticket;
 INSERT INTO action_execution(id,organization_id,approval_id,phase,next_run_at,created_at,plan_version,resource_guard_id)
 SELECT 'execution-'||ticket,'proof-org','approval-'||ticket,'ready',undo_deadline,created_at,1,'33333333-3333-3333-3333-333333333333' FROM action_approval WHERE id='approval-'||ticket;
 PERFORM proof_apply('approve-'||ticket,ticket);
 INSERT INTO action_execution_step(id,organization_id,execution_id,ordinal,kind,adapter_version,content_revision_id,recovery_mode,recovery_policy_version,required_surface)
 VALUES('step-'||ticket,'proof-org','execution-'||ticket,0,'asc_review_response_upsert',1,ticket||'-r1','readback_before_retry',1,'review_response');
END $$;
BEGIN;
INSERT INTO action_resource_guard(id,provider,provider_account_id,remote_application_id,scope)
 VALUES('33333333-3333-3333-3333-333333333333','app_store_connect','proof-provider-account','proof-provider-app','store_application');
SELECT proof_provider_approval('provider-ack');
SELECT proof_provider_approval('provider-uncertain');
COMMIT;
UPDATE action_resource_guard SET holder_organization_id='proof-org',holder_execution_id='execution-provider-ack',acquired_at=clock_timestamp()
 WHERE id='33333333-3333-3333-3333-333333333333';
UPDATE action_execution SET phase='claimed',claim_generation=1,claim_token='44444444-4444-4444-4444-444444444444',claim_expires_at=clock_timestamp()+interval '5 minutes',next_step_id='step-provider-ack' WHERE id='execution-provider-ack';
INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,transport,started_at,recorded_at)
 VALUES('provider-ack-write','proof-org','step-provider-ack','execution-provider-ack',1,'write',1,'44444444-4444-4444-4444-444444444444','asc_api',clock_timestamp(),clock_timestamp());
UPDATE action_execution_attempt SET finished_at=clock_timestamp(),result='acknowledged',provider_resource_id='synthetic-response-a',finalized_claim_generation=1,finalized_claim_token='44444444-4444-4444-4444-444444444444' WHERE id='provider-ack-write';
SELECT proof_reject($q$
 INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,transport,started_at,recorded_at)
 VALUES('provider-ack-duplicate','proof-org','step-provider-ack','execution-provider-ack',2,'write',1,'44444444-4444-4444-4444-444444444444','asc_api',clock_timestamp(),clock_timestamp());
$q$,'effect already applied','acknowledged effect cannot be physically repeated while awaiting publication');
SELECT proof_reject($q$
 UPDATE action_resource_guard SET holder_organization_id=NULL,holder_execution_id=NULL,acquired_at=NULL WHERE id='33333333-3333-3333-3333-333333333333';
$q$,'resource remains excluded','resource cannot be released by a lease or queue-state shortcut');
UPDATE action_execution SET writes_closed_at=clock_timestamp(),phase='verification_due',claim_token=NULL,claim_expires_at=NULL,next_run_at=clock_timestamp()+interval '1 hour' WHERE id='execution-provider-ack';
UPDATE action_resource_guard SET holder_organization_id='proof-org',holder_execution_id='execution-provider-uncertain',acquired_at=clock_timestamp() WHERE id='33333333-3333-3333-3333-333333333333';
SELECT proof_assert((SELECT phase='verification_due' AND writes_closed_at IS NOT NULL FROM action_execution WHERE id='execution-provider-ack'),'known writes release app exclusion while immutable revision verification remains pending');
UPDATE action_execution SET phase='claimed',claim_generation=1,claim_token='55555555-5555-5555-5555-555555555555',claim_expires_at=clock_timestamp()+interval '5 minutes',next_step_id='step-provider-uncertain' WHERE id='execution-provider-uncertain';
INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,transport,started_at,recorded_at)
 VALUES('provider-uncertain-write','proof-org','step-provider-uncertain','execution-provider-uncertain',1,'write',1,'55555555-5555-5555-5555-555555555555','asc_api',clock_timestamp(),clock_timestamp());
UPDATE action_execution_attempt SET finished_at=clock_timestamp(),result='uncertain',failure_class='transport',finalized_claim_generation=1,finalized_claim_token='55555555-5555-5555-5555-555555555555' WHERE id='provider-uncertain-write';
SELECT proof_reject($q$
 INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,transport,started_at,recorded_at)
 VALUES('provider-uncertain-duplicate','proof-org','step-provider-uncertain','execution-provider-uncertain',2,'write',1,'55555555-5555-5555-5555-555555555555','asc_api',clock_timestamp(),clock_timestamp());
$q$,'unresolved earlier write','timeout never permits blind retry or browser fallback');
SELECT proof_reject($q$
 UPDATE action_execution SET phase='settled',claim_token=NULL,claim_expires_at=NULL,next_run_at=NULL,result='failed',settled_at=clock_timestamp() WHERE id='execution-provider-uncertain';
$q$,'uncertain provider effect','terminal failure cannot conceal an ambiguous provider write');
INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,subject_attempt_id,transport,started_at,recorded_at)
 VALUES('provider-uncertain-read','proof-org','step-provider-uncertain','execution-provider-uncertain',2,'readback',1,'55555555-5555-5555-5555-555555555555','provider-uncertain-write','asc_api',clock_timestamp(),clock_timestamp());
BEGIN;
SELECT proof_command('observe-provider-uncertain','record_observation');
SELECT proof_target('observe-provider-uncertain','provider-uncertain','approved','approval-provider-uncertain');
SELECT proof_apply('observe-provider-uncertain','provider-uncertain');
INSERT INTO action_revision(id,organization_id,action_id,purpose,kind,operation,revision_number,authored_command_id,title,summary,content_digest,canonicalization_version,created_at)
 SELECT 'provider-uncertain-observation','proof-org','provider-uncertain','observation','review_reply','post_reply',2,id,'Synthetic response observation','Synthetic exact response match',repeat('e',64),1,accepted_at FROM action_command WHERE id='observe-provider-uncertain';
INSERT INTO action_review_content(organization_id,revision_id,provider_account_id,store,provider_app_id,provider_review_id,intent,response_availability,provider_response_id,provider_response_text,provider_response_state,observation_captured_at)
 VALUES('proof-org','provider-uncertain-observation','proof-provider-account','ios','proof-provider-app','provider-uncertain-provider-review','observed','present','synthetic-response-b','Synthetic reply','published',clock_timestamp());
UPDATE action_revision SET sealed=true WHERE id='provider-uncertain-observation';
COMMIT;
SELECT proof_reject($q$
 UPDATE action_execution_attempt SET finished_at=clock_timestamp(),result='matched',observation_revision_id='provider-uncertain-observation',observation_surface='review_response',observed_at=clock_timestamp(),comparison_version=1,finalized_claim_generation=1,finalized_claim_token='55555555-5555-5555-5555-555555555555' WHERE id='provider-uncertain-read';
$q$,'action_attempt_verified_observation','NULL completeness cannot count as verified matching evidence');
SELECT proof_reject($q$
 UPDATE action_execution_attempt SET finished_at=clock_timestamp(),result='known_not_applied',non_application_basis='pre_dispatch_failure',observation_revision_id='provider-uncertain-observation',observation_surface='review_response',observation_completeness='complete',observed_at=clock_timestamp(),comparison_version=1,finalized_claim_generation=1,finalized_claim_token='55555555-5555-5555-5555-555555555555' WHERE id='provider-uncertain-read';
$q$,'negative read is not proof','a negative read cannot invent final non-application authority');
UPDATE action_execution_attempt SET finished_at=clock_timestamp(),result='matched',observation_revision_id='provider-uncertain-observation',observation_surface='review_response',observation_completeness='complete',observed_at=clock_timestamp(),comparison_version=1,finalized_claim_generation=1,finalized_claim_token='55555555-5555-5555-5555-555555555555' WHERE id='provider-uncertain-read';
UPDATE action_execution SET phase='settled',claim_token=NULL,claim_expires_at=NULL,next_run_at=NULL,result='verified_live',settled_at=clock_timestamp(),writes_closed_at=clock_timestamp() WHERE id='execution-provider-uncertain';
BEGIN;
SELECT proof_command('late-provider-uncertain','record_attempt');
SELECT proof_target('late-provider-uncertain','provider-uncertain','approved','approval-provider-uncertain');
SELECT proof_apply('late-provider-uncertain','provider-uncertain');
INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,subject_attempt_id,transport,started_at,finished_at,result,provider_resource_id,evidence_command_id,recorded_at)
 SELECT 'provider-late-ack','proof-org',step_id,execution_id,3,'late_evidence',claim_generation,claim_token,id,transport,started_at,clock_timestamp(),'acknowledged','synthetic-response-b','late-provider-uncertain',clock_timestamp() FROM action_execution_attempt WHERE id='provider-uncertain-write';
COMMIT;
SELECT proof_assert((SELECT count(*)=3 FROM action_execution_attempt WHERE execution_id='execution-provider-uncertain') AND (SELECT result='uncertain' FROM action_execution_attempt WHERE id='provider-uncertain-write') AND (SELECT result='verified_live' FROM action_execution WHERE id='execution-provider-uncertain'),'late original response is retained after settlement without rewriting original uncertainty or current outcome');
SELECT 'PASS: provider acknowledgement, uncertain readback, late evidence and resource-release design contracts.' AS result;
