-- Isolated PostgreSQL DESIGN contract cases; synthetic IDs/content only.
-- No migration/runtime/provider/concurrent-session claim is made by this file.
SET search_path=actions_design,public;
INSERT INTO public.organization(id) VALUES('proof-org'),('proof-other-org');
INSERT INTO public."user"(id) VALUES('proof-user'),('proof-other-user');
INSERT INTO public.asset(id,"organizationId") VALUES('proof-asset','proof-org'),('proof-other-asset','proof-other-org');

CREATE FUNCTION proof_assert(ok boolean,label text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %',label; END IF; RAISE NOTICE 'PASS: %',label; END $$;
CREATE FUNCTION proof_reject(statement text,expected_message text,label text) RETURNS void LANGUAGE plpgsql AS $$
DECLARE caught text;
BEGIN
 BEGIN EXECUTE statement; EXCEPTION WHEN OTHERS THEN GET STACKED DIAGNOSTICS caught=MESSAGE_TEXT; END;
 IF caught IS NULL THEN RAISE EXCEPTION 'FAIL (accepted invalid data): %',label; END IF;
 IF position(expected_message IN caught)=0 THEN RAISE EXCEPTION 'FAIL (wrong rejection) %: %',label,caught; END IF;
 RAISE NOTICE 'PASS: %',label;
END $$;
CREATE FUNCTION proof_command(command_id text,command_kind action_command_kind,policy_id text DEFAULT NULL) RETURNS void LANGUAGE sql AS $$
 INSERT INTO action_command(id,organization_id,idempotency_key,principal_kind,actor_user_id,actor_subject_snapshot,channel,kind,request_digest,digest_version,outcome,accepted_at,target_policy_revision_id)
 VALUES(command_id,'proof-org',gen_random_uuid(),'user','proof-user','proof-user','web',command_kind,repeat('a',64),1,'accepted',clock_timestamp()-interval '1 minute',policy_id)
$$;
CREATE FUNCTION proof_start(ticket text,domain_name text,parent_ticket text DEFAULT NULL) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
 PERFORM proof_command('create-'||ticket,'create');
 INSERT INTO action(id,organization_id,asset_id,domain,parent_action_id,created_at,updated_at,last_command_id)
 SELECT ticket,'proof-org','proof-asset',domain_name,parent_ticket,accepted_at,accepted_at,id FROM action_command WHERE id='create-'||ticket;
END $$;
CREATE FUNCTION proof_revision(ticket text,revision text,family text,op text,number bigint DEFAULT 1,author text DEFAULT NULL) RETURNS void LANGUAGE sql AS $$
 INSERT INTO action_revision(id,organization_id,action_id,purpose,kind,operation,revision_number,authored_command_id,title,summary,content_digest,canonicalization_version,created_at)
 SELECT revision,'proof-org',ticket,'proposal',family,op,number,coalesce(author,'create-'||ticket),'Synthetic proof item','Synthetic proof content',repeat('b',64),1,accepted_at
 FROM action_command WHERE id=coalesce(author,'create-'||ticket)
$$;
CREATE FUNCTION proof_finish_create(ticket text,revision text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
 UPDATE action_revision SET sealed=true WHERE id=revision;
 INSERT INTO action_command_target(organization_id,command_id,action_id,result_version,result_decision,result_revision_id)
 VALUES('proof-org','create-'||ticket,ticket,1,'open',revision);
 UPDATE action SET current_revision_id=revision WHERE id=ticket;
END $$;
CREATE FUNCTION proof_review(ticket text,parent_ticket text DEFAULT NULL) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
 PERFORM proof_start(ticket,'reviews',parent_ticket);
 PERFORM proof_revision(ticket,ticket||'-r1','review_reply','post_reply');
 INSERT INTO action_review_content(organization_id,revision_id,provider_account_id,store,provider_app_id,provider_review_id,intent,reply_text,response_availability,review_rating)
 VALUES('proof-org',ticket||'-r1','proof-provider-account','ios','proof-provider-app',ticket||'-provider-review','send','Synthetic reply','absent',5);
 PERFORM proof_finish_create(ticket,ticket||'-r1');
END $$;
CREATE FUNCTION proof_target(cmd text,ticket text,new_decision action_decision,new_approval text DEFAULT NULL,parent_revision text DEFAULT NULL,new_revision text DEFAULT NULL) RETURNS void LANGUAGE sql AS $$
 INSERT INTO action_command_target(organization_id,command_id,action_id,expected_version,expected_revision_id,expected_parent_revision_id,previous_version,result_version,previous_decision,result_decision,previous_revision_id,result_revision_id,previous_approval_id,result_approval_id,previous_owner_user_id,result_owner_user_id,previous_snoozed_until,result_snoozed_until,previous_archived_at,result_archived_at)
 SELECT organization_id,cmd,id,version,current_revision_id,parent_revision,version,version+1,decision,new_decision,current_revision_id,coalesce(new_revision,current_revision_id),current_approval_id,new_approval,owner_user_id,owner_user_id,snoozed_until,snoozed_until,archived_at,archived_at FROM action WHERE id=ticket
$$;
CREATE FUNCTION proof_apply(cmd text,ticket text) RETURNS void LANGUAGE sql AS $$
 UPDATE action a SET decision=t.result_decision,version=t.result_version,current_revision_id=t.result_revision_id,current_approval_id=t.result_approval_id,owner_user_id=t.result_owner_user_id,snoozed_until=t.result_snoozed_until,archived_at=t.result_archived_at,last_command_id=cmd,updated_at=c.accepted_at
 FROM action_command_target t JOIN action_command c ON c.id=t.command_id WHERE a.id=ticket AND t.action_id=a.id AND t.command_id=cmd
$$;
CREATE FUNCTION proof_approval(cmd text,ticket text,approval_id text,scope_name action_authorization_scope,parent_revision text DEFAULT NULL,deadline_offset interval DEFAULT interval '5 seconds') RETURNS void LANGUAGE plpgsql AS $$
BEGIN
 INSERT INTO action_approval(id,organization_id,action_id,revision_id,command_id,scope,parent_revision_id,undo_deadline,required_surface,authorization_version,created_at)
 SELECT approval_id,'proof-org',ticket,a.current_revision_id,cmd,scope_name,parent_revision,c.accepted_at+deadline_offset,
 CASE WHEN scope_name<>'perform' THEN 'internal_artifact'::action_surface WHEN r.kind='listing' THEN 'editable_listing'::action_surface ELSE 'review_response'::action_surface END,1,c.accepted_at FROM action a JOIN action_revision r ON r.id=a.current_revision_id JOIN action_command c ON c.id=cmd WHERE a.id=ticket;
 INSERT INTO action_execution(id,organization_id,approval_id,phase,next_run_at,created_at,plan_version)
 SELECT 'exec-'||approval_id,'proof-org',approval_id,'ready',undo_deadline,created_at,1 FROM action_approval WHERE id=approval_id;
END $$;

BEGIN;
SELECT proof_review('review-one');
SELECT proof_review('review-two');
SELECT proof_start('review-package','collection');
SELECT proof_review('batch-one','review-package');
SELECT proof_review('batch-two','review-package');
SELECT proof_revision('review-package','review-package-r1','collection','post_batch');
INSERT INTO action_membership(organization_id,parent_revision_id,child_action_id,child_revision_id,ordinal) VALUES
 ('proof-org','review-package-r1','batch-one','batch-one-r1',0),('proof-org','review-package-r1','batch-two','batch-two-r1',1);
SELECT proof_finish_create('review-package','review-package-r1');
SELECT proof_start('locale-child','listing');
SELECT proof_revision('locale-child','locale-child-r1','request','generate_locale');
INSERT INTO action_request_content(organization_id,revision_id,intent,store,locale,origin) VALUES('proof-org','locale-child-r1','locale_expansion','ios','fr-FR','human');
SELECT proof_finish_create('locale-child','locale-child-r1');
COMMIT;
SELECT proof_assert((SELECT count(*)=6 FROM action),'create permanently identified tickets with complete sealed content');

BEGIN;
SELECT proof_command('approve-one','approve');
SELECT proof_target('approve-one','review-one','approved','approval-one');
SELECT proof_approval('approve-one','review-one','approval-one','perform');
SELECT proof_apply('approve-one','review-one');
COMMIT;
SELECT proof_assert((SELECT a.current_revision_id=ap.revision_id AND a.current_approval_id=ap.id AND ap.command_id=c.id AND c.actor_user_id='proof-user' AND e.phase='ready' FROM action a JOIN action_approval ap ON ap.id=a.current_approval_id JOIN action_command c ON c.id=ap.command_id JOIN action_execution e ON e.approval_id=ap.id WHERE a.id='review-one'),'approval pins exact bytes, actor and durable execution before acceptance completes');
SELECT proof_assert((SELECT t.result_version=2 AND t.result_approval_id='approval-one' AND t.result_revision_id='review-one-r1' FROM action_command_target t WHERE command_id='approve-one'),'immutable command target reconstructs original replay result');
SELECT proof_reject($q$INSERT INTO action_command SELECT * FROM action_command WHERE id='approve-one'$q$,'duplicate key','duplicate accepted command cannot create a second effect');
SELECT proof_reject($q$UPDATE action_command SET actor_user_id='proof-other-user' WHERE id='approve-one'$q$,'immutable','history attribution cannot be rewritten');
SELECT proof_reject($q$UPDATE action_approval SET revision_id='review-two-r1' WHERE id='approval-one'$q$,'immutable','approval cannot retarget different content');
SELECT proof_reject($q$UPDATE action_review_content SET reply_text='Unseen replacement' WHERE revision_id='review-one-r1'$q$,'sealed','approved content is immutable');
SELECT proof_reject($q$UPDATE action_revision SET kind='advisory' WHERE id='review-one-r1'$q$,'immutable','revision family is immutable');
SELECT proof_reject($q$UPDATE action SET decision='invented_status' WHERE id='review-two'$q$,'invalid input value for enum','unknown lifecycle value fails closed');
SELECT proof_reject($q$UPDATE action SET current_approval_id=NULL WHERE id='review-one'$q$,'mutation must match','approval pointer cannot be dropped outside command protocol');

BEGIN;
SELECT proof_command('batch-approve-selected','approve');
SELECT proof_target('batch-approve-selected','review-package','approved');
SELECT proof_target('batch-approve-selected','batch-one','approved','batch-approval-one','review-package-r1');
SELECT proof_approval('batch-approve-selected','batch-one','batch-approval-one','perform','review-package-r1');
SELECT proof_apply('batch-approve-selected','batch-one');
SELECT proof_apply('batch-approve-selected','review-package');
COMMIT;
SELECT proof_assert((SELECT count(*)=2 FROM action_membership WHERE parent_revision_id='review-package-r1') AND (SELECT decision='open' FROM action WHERE id='batch-two') AND (SELECT parent_action_id='review-package' FROM action WHERE id='batch-one'),'partial batch approval retains parent, exact membership and independent unselected child');
SELECT proof_reject($q$DELETE FROM action_membership WHERE parent_revision_id='review-package-r1' AND child_action_id='batch-two'$q$,'unsealed collection','accepted package membership cannot disappear');
SELECT proof_reject($q$UPDATE action SET parent_action_id=NULL WHERE id='batch-two'$q$,'new mutation requires','structural child cannot silently detach');

-- A stale browser snapshot loses even though its revision bytes still exist.
SELECT proof_reject($q$
 SELECT proof_command('stale-browser','approve');
 INSERT INTO action_command_target(organization_id,command_id,action_id,expected_version,expected_revision_id,previous_version,result_version,previous_decision,result_decision,previous_revision_id,result_revision_id,previous_approval_id,result_approval_id)
 VALUES('proof-org','stale-browser','review-one',1,'review-one-r1',2,3,'approved','approved','review-one-r1','review-one-r1','approval-one','approval-one');
 SELECT proof_apply('stale-browser','review-one');
$q$,'stale or absent','stale expected version rejected after competing approval');
SELECT proof_reject($q$
 SELECT proof_command('batch-unseen','approve');
 SELECT proof_target('batch-unseen','review-two','approved','unseen-approval','review-package-r1');
 SELECT proof_approval('batch-unseen','review-two','unseen-approval','perform','review-package-r1');
$q$,'exact sealed membership','a review outside approved package cannot join the selection');
SELECT proof_reject($q$
 SELECT proof_command('batch-missing-parent','approve');
 SELECT proof_target('batch-missing-parent','batch-two','approved','missing-parent-approval','review-package-r1');
 SELECT proof_approval('batch-missing-parent','batch-two','missing-parent-approval','perform','review-package-r1');
 SELECT proof_apply('batch-missing-parent','batch-two');
 SET CONSTRAINTS ALL IMMEDIATE;
$q$,'exact parent snapshot','child approval must serialize with the viewed parent revision');
SELECT proof_reject($q$
 SELECT proof_command('missing-delivery','approve');
 SELECT proof_target('missing-delivery','review-two','approved','missing-delivery-approval');
 INSERT INTO action_approval(id,organization_id,action_id,revision_id,command_id,scope,undo_deadline,required_surface,authorization_version,created_at)
 SELECT 'missing-delivery-approval','proof-org','review-two','review-two-r1',id,'perform',accepted_at+interval '5 seconds','review_response',1,accepted_at FROM action_command WHERE id='missing-delivery';
 SELECT proof_apply('missing-delivery','review-two');
 SET CONSTRAINTS ALL IMMEDIATE;
$q$,'durable execution obligation','accepted approval cannot omit persistent dispatch obligation');

-- Personal read state never issues a shared lifecycle command.
BEGIN;
SELECT proof_command('snooze-two','snooze');
INSERT INTO action_command_target(organization_id,command_id,action_id,expected_version,expected_revision_id,previous_version,result_version,previous_decision,result_decision,previous_revision_id,result_revision_id,result_snoozed_until)
SELECT organization_id,'snooze-two',id,version,current_revision_id,version,version+1,decision,decision,current_revision_id,current_revision_id,clock_timestamp()+interval '1 day' FROM action WHERE id='review-two';
SELECT proof_apply('snooze-two','review-two');
COMMIT;
CREATE TEMP TABLE proof_shared_before AS SELECT * FROM action WHERE id IN ('review-one','review-two');
INSERT INTO action_read(organization_id,user_id,action_id,seen_attention_version,force_unread,updated_at) VALUES
 ('proof-org','proof-user','review-one',1,false,clock_timestamp()),('proof-org','proof-user','review-two',1,false,clock_timestamp()),
 ('proof-org','proof-other-user','review-two',0,true,clock_timestamp());
UPDATE action_read SET force_unread=true,updated_at=clock_timestamp() WHERE action_id='review-one';
SELECT proof_assert(NOT EXISTS((SELECT * FROM action WHERE id IN ('review-one','review-two') EXCEPT SELECT * FROM proof_shared_before) UNION ALL (SELECT * FROM proof_shared_before EXCEPT SELECT * FROM action WHERE id IN ('review-one','review-two'))),'mark read/unread leaves approval, snooze and every shared lifecycle field unchanged');
SELECT proof_reject($q$UPDATE action_read SET seen_attention_version=2 WHERE action_id='review-two' AND user_id='proof-user'$q$,'beyond visible history','read cannot claim unseen attention events');
SELECT proof_reject($q$
 SELECT proof_command('cross-org','create');
 INSERT INTO action(id,organization_id,asset_id,domain,created_at,updated_at,last_command_id)
 SELECT 'cross-org-ticket','proof-org','proof-other-asset','reviews',accepted_at,accepted_at,id FROM action_command WHERE id='cross-org';
$q$,'asset tenant mismatch','ticket cannot bind another organization asset');
SELECT proof_reject($q$
 INSERT INTO action_read(organization_id,user_id,action_id,seen_attention_version,updated_at) VALUES('proof-other-org','proof-other-user','review-one',0,clock_timestamp());
$q$,'beyond visible history','personal read cannot cross organization ticket identity');
SELECT proof_reject($q$
 INSERT INTO action_command(id,organization_id,idempotency_key,principal_kind,actor_user_id,actor_agent_run_id,actor_subject_snapshot,channel,kind,request_digest,digest_version,outcome,error,accepted_at)
 VALUES('mixed-actor','proof-org',gen_random_uuid(),'user','proof-user','invented-agent','proof-user','web','approve',repeat('c',64),1,'refused','invalid_transition',clock_timestamp());
$q$,'command_principal_exclusive','actor principal variants are exclusive');

BEGIN;
SELECT proof_command('grant-generation','grant_policy','generation-policy-r1');
INSERT INTO action_policy_revision(id,organization_id,asset_id,granted_by_command_id,policy_kind,revision_number,allow_initial_reply,allow_generation,rule_version,created_at)
SELECT 'generation-policy-r1','proof-org','proof-asset',id,'agent_generation',1,false,true,1,accepted_at FROM action_command WHERE id='grant-generation';
COMMIT;
SELECT proof_reject($q$UPDATE action_policy_revision SET allow_initial_reply=true WHERE id='generation-policy-r1'$q$,'only one-way','policy grant content is immutable');
BEGIN;
SELECT proof_command('revoke-generation','revoke_policy','generation-policy-r1');
UPDATE action_policy_revision p SET revoked_by_command_id=c.id,revoked_at=c.accepted_at FROM action_command c WHERE p.id='generation-policy-r1' AND c.id='revoke-generation';
COMMIT;
SELECT proof_reject($q$UPDATE action_policy_revision SET revoked_by_command_id=NULL,revoked_at=NULL WHERE id='generation-policy-r1'$q$,'only one-way','policy revocation cannot be undone in place');
SELECT proof_assert((SELECT p.granted_by_command_id='grant-generation' AND p.revoked_by_command_id='revoke-generation' FROM action_policy_revision p WHERE id='generation-policy-r1'),'policy grant and revoke preserve explicit accountable history');

SELECT proof_assert((SELECT count(*)=6 FROM action) AND (SELECT count(*)=2 FROM action_approval) AND (SELECT count(*)=2 FROM action_execution),'failed adversarial transactions leave permanent work and approvals intact');
SELECT 'PASS: isolated design contract fixture suite; application migration, provider integration and broader concurrency cases remain implementation gates.' AS result;

-- Stable localization identity: generation authority is consumed by a typed
-- internal attempt; its output opens a new unapproved listing revision.
BEGIN;
SELECT proof_command('generate-locale','approve');
SELECT proof_target('generate-locale','locale-child','approved','locale-generation-approval');
SELECT proof_approval('generate-locale','locale-child','locale-generation-approval','generate');
SELECT proof_apply('generate-locale','locale-child');
INSERT INTO action_execution_step(id,organization_id,execution_id,ordinal,kind,adapter_version,content_revision_id,recovery_mode,recovery_policy_version,required_surface)
 VALUES('locale-generate-step','proof-org','exec-locale-generation-approval',0,'internal_generate_content',1,'locale-child-r1','internal_atomic',1,'internal_artifact');
COMMIT;
SELECT proof_reject($q$
 SELECT proof_command('racing-iteration','revise');
 SELECT proof_revision('locale-child','racing-locale-r2','request','generate_locale',2,'racing-iteration');
 INSERT INTO action_request_content(organization_id,revision_id,intent,store,locale,origin) VALUES('proof-org','racing-locale-r2','locale_expansion','ios','fr-FR','human');
 UPDATE action_revision SET sealed=true WHERE id='racing-locale-r2';
 SELECT proof_target('racing-iteration','locale-child','open',NULL,NULL,'racing-locale-r2');
 SELECT proof_apply('racing-iteration','locale-child');
$q$,'unsettled effect','iteration cannot replace a revision with an accepted execution still pending');
UPDATE action_execution SET phase='claimed',claim_generation=1,claim_token='11111111-1111-1111-1111-111111111111',claim_expires_at=clock_timestamp()+interval '5 minutes',next_step_id='locale-generate-step'
 WHERE id='exec-locale-generation-approval';
INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,transport,started_at,recorded_at)
 VALUES('locale-attempt','proof-org','locale-generate-step','exec-locale-generation-approval',1,'generation',1,'11111111-1111-1111-1111-111111111111','internal',clock_timestamp(),clock_timestamp());
SELECT proof_reject($q$
 INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,transport,started_at,recorded_at)
 VALUES('overlapping-attempt','proof-org','locale-generate-step','exec-locale-generation-approval',2,'generation',1,'11111111-1111-1111-1111-111111111111','internal',clock_timestamp(),clock_timestamp());
$q$,'action_one_active_attempt_per_execution','an execution cannot open overlapping I/O attempts');
SELECT proof_reject($q$
 UPDATE action_execution_attempt SET finished_at=clock_timestamp(),result='generated',finalized_claim_generation=2,finalized_claim_token='22222222-2222-2222-2222-222222222222' WHERE id='locale-attempt';
$q$,'live current execution claim','a stale worker cannot finalize an attempt');
BEGIN;
SELECT proof_command('commit-generated-locale','revise');
INSERT INTO action_revision(id,organization_id,action_id,purpose,kind,operation,revision_number,authored_command_id,generated_from_revision_id,title,summary,content_digest,canonicalization_version,created_at)
 SELECT 'locale-child-r2','proof-org','locale-child','proposal','listing','create_locale',2,id,'locale-child-r1','Synthetic French locale','Synthetic generated output',repeat('d',64),1,accepted_at FROM action_command WHERE id='commit-generated-locale';
INSERT INTO action_listing_content(organization_id,revision_id,provider_account_id,store,locale,intent,provider_app_id,app_info_id,title_state,title)
 VALUES('proof-org','locale-child-r2','proof-provider-account','ios','fr-FR','create','proof-provider-app','proof-app-info','present','Synthetic French title');
UPDATE action_revision SET sealed=true WHERE id='locale-child-r2';
UPDATE action_execution_attempt SET finished_at=clock_timestamp(),result='generated',output_kind='revision',output_revision_id='locale-child-r2',finalized_claim_generation=1,finalized_claim_token='11111111-1111-1111-1111-111111111111' WHERE id='locale-attempt';
UPDATE action_execution SET phase='settled',claim_token=NULL,claim_expires_at=NULL,next_run_at=NULL,result='generated',settled_at=clock_timestamp() WHERE id='exec-locale-generation-approval';
SELECT proof_target('commit-generated-locale','locale-child','open',NULL,NULL,'locale-child-r2');
SELECT proof_apply('commit-generated-locale','locale-child');
COMMIT;
SELECT proof_reject($q$UPDATE action_execution_attempt SET result='discarded' WHERE id='locale-attempt'$q$,'finalized attempt is immutable','completed attempt evidence cannot be rewritten');
SELECT proof_assert((SELECT a.current_revision_id='locale-child-r2' AND a.current_approval_id IS NULL AND a.decision='open' AND r.generated_from_revision_id=old.revision_id AND old.scope='generate' FROM action a JOIN action_revision r ON r.id=a.current_revision_id JOIN action_approval old ON old.id='locale-generation-approval' WHERE a.id='locale-child'),'one permanent locale ticket changes request to listing; output has no inherited approval');
SELECT proof_reject($q$
 SELECT proof_command('stale-generation-approve','approve');
 SELECT proof_target('stale-generation-approve','locale-child','approved','stale-generation-ap');
 INSERT INTO action_approval(id,organization_id,action_id,revision_id,command_id,scope,undo_deadline,required_surface,authorization_version,created_at)
 SELECT 'stale-generation-ap','proof-org','locale-child','locale-child-r1',id,'generate',accepted_at+interval '5 seconds','internal_artifact',1,accepted_at FROM action_command WHERE id='stale-generation-approve';
$q$,'cannot approve stale revision','generation request approval cannot silently authorize generated listing');
BEGIN;
SELECT proof_command('publish-generated-locale','approve');
SELECT proof_target('publish-generated-locale','locale-child','approved','locale-publication-approval');
SELECT proof_approval('publish-generated-locale','locale-child','locale-publication-approval','perform');
SELECT proof_apply('publish-generated-locale','locale-child');
COMMIT;
SELECT proof_assert((SELECT count(*)=2 FROM action_approval WHERE action_id='locale-child') AND (SELECT a.current_approval_id='locale-publication-approval' AND ap.revision_id='locale-child-r2' AND ap.scope='perform' FROM action a JOIN action_approval ap ON ap.id=a.current_approval_id WHERE a.id='locale-child'),'publication requires fresh exact approval; prior generation attribution remains attached');
SELECT 'PASS: localization handoff, claim fencing and immutable attempt evidence.' AS result;

-- Undo is an immediately persisted server command, independent of browser life.
SELECT proof_reject($q$
 SELECT proof_command('expired-undo','undo');
 SELECT proof_target('expired-undo','review-one','open');
 SELECT proof_apply('expired-undo','review-one');
$q$,'Undo expired','expired server deadline rejects Undo');
BEGIN;
SELECT proof_command('approve-for-undo','approve');
SELECT proof_target('approve-for-undo','review-two','approved','undo-approval');
SELECT proof_approval('approve-for-undo','review-two','undo-approval','perform',NULL,interval '1 hour');
SELECT proof_apply('approve-for-undo','review-two');
COMMIT;
SELECT proof_reject($q$
 SELECT proof_command('incomplete-undo','undo');
 SELECT proof_target('incomplete-undo','review-two','open');
 SELECT proof_apply('incomplete-undo','review-two');
 SET CONSTRAINTS ALL IMMEDIATE;
$q$,'Undo command requires a cancelled execution','Undo cannot reopen work and leave its durable dispatch live');
BEGIN;
SELECT proof_command('accepted-undo','undo');
SELECT proof_target('accepted-undo','review-two','open');
UPDATE action_execution SET phase='cancelled',next_run_at=NULL,result='cancelled',settled_at=clock_timestamp(),cancelled_command_id='accepted-undo' WHERE id='exec-undo-approval';
SELECT proof_apply('accepted-undo','review-two');
COMMIT;
SELECT proof_assert((SELECT decision='open' AND current_approval_id IS NULL AND snoozed_until IS NOT NULL FROM action WHERE id='review-two') AND (SELECT phase='cancelled' AND cancelled_command_id='accepted-undo' FROM action_execution WHERE id='exec-undo-approval'),'valid server Undo atomically cancels dispatch and preserves unrelated shared snooze');
SELECT proof_reject($q$UPDATE action_execution SET phase='ready',next_run_at=clock_timestamp(),result=NULL,settled_at=NULL,cancelled_command_id=NULL WHERE id='exec-undo-approval'$q$,'settled execution cannot be rewritten','cancelled execution cannot restart after a duplicate wakeup');
SELECT 'PASS: server Undo acceptance, deadline and cancellation atomicity.' AS result;

-- Creation identity and tenant boundaries added after final domain binding.
SELECT proof_reject($q$
 SELECT proof_command('duplicate-creation','create');
 INSERT INTO action(id,organization_id,asset_id,domain,created_at,updated_at,last_command_id,creation_key)
 SELECT 'duplicate-creation-ticket','proof-org','proof-asset','reviews',c.accepted_at,c.accepted_at,c.id,a.creation_key FROM action a CROSS JOIN action_command c WHERE a.id='review-one' AND c.id='duplicate-creation';
$q$,'action_organization_id_creation_key_key','the same producer creation key cannot manufacture a second ticket');
SELECT proof_reject($q$
 SELECT proof_command('rewrite-creation-key','assign');
 SELECT proof_target('rewrite-creation-key','review-two','open');
 UPDATE action a SET creation_key=gen_random_uuid(),version=t.result_version,last_command_id=c.id,updated_at=c.accepted_at FROM action_command_target t JOIN action_command c ON c.id=t.command_id WHERE t.command_id='rewrite-creation-key' AND a.id=t.action_id;
$q$,'ticket identity and structural parent are permanent','producer creation key is permanent');
SELECT proof_reject($q$
 SELECT proof_command('cross-tenant-policy','grant_policy','cross-tenant-policy-r1');
 INSERT INTO action_policy_revision(id,organization_id,asset_id,granted_by_command_id,policy_kind,revision_number,allow_initial_reply,allow_generation,rule_version,created_at)
 SELECT 'cross-tenant-policy-r1','proof-org','proof-other-asset',id,'agent_generation',1,false,true,1,accepted_at FROM action_command WHERE id='cross-tenant-policy';
$q$,'asset tenant mismatch','policy cannot grant authority over another organization asset');
SELECT 'PASS: permanent producer creation keys and policy tenant boundaries.' AS result;

SELECT proof_reject($q$
 INSERT INTO action_command(id,organization_id,idempotency_key,principal_kind,actor_user_id,actor_subject_snapshot,channel,kind,request_digest,digest_version,outcome,accepted_at)
 SELECT 'duplicate-idempotency-new-command-id',organization_id,idempotency_key,principal_kind,actor_user_id,actor_subject_snapshot,channel,kind,request_digest,digest_version,outcome,accepted_at FROM action_command WHERE id='approve-one';
$q$,'duplicate key','a retried idempotency key cannot allocate a new accepted command identity');
SELECT proof_reject($q$
 INSERT INTO action_command(id,organization_id,idempotency_key,principal_kind,actor_user_id,actor_subject_snapshot,channel,kind,request_digest,digest_version,outcome,accepted_at)
 SELECT 'mismatched-idempotency-new-command-id',organization_id,idempotency_key,principal_kind,actor_user_id,actor_subject_snapshot,channel,kind,repeat('f',64),digest_version,outcome,accepted_at FROM action_command WHERE id='approve-one';
$q$,'duplicate key','changed payload cannot replace the command already occupying an idempotency key');

-- Policy is checked again before a new internal effect starts, after approval.
BEGIN;
SELECT proof_start('policy-locale','listing');
SELECT proof_revision('policy-locale','policy-locale-r1','request','generate_locale');
INSERT INTO action_request_content(organization_id,revision_id,intent,store,locale,origin) VALUES('proof-org','policy-locale-r1','locale_expansion','ios','fr-FR','scheduled_agent');
SELECT proof_finish_create('policy-locale','policy-locale-r1');
SELECT proof_command('grant-generation-next','grant_policy','generation-policy-r2');
INSERT INTO action_policy_revision(id,organization_id,asset_id,granted_by_command_id,policy_kind,revision_number,allow_initial_reply,allow_generation,rule_version,created_at)
SELECT 'generation-policy-r2','proof-org','proof-asset',id,'agent_generation',2,false,true,1,accepted_at FROM action_command WHERE id='grant-generation-next';
INSERT INTO action_command(id,organization_id,idempotency_key,principal_kind,actor_policy_revision_id,actor_subject_snapshot,channel,kind,request_digest,digest_version,outcome,accepted_at)
VALUES('policy-approve-generation','proof-org',gen_random_uuid(),'policy','generation-policy-r2','generation-policy-r2','agent','approve',repeat('1',64),1,'accepted',clock_timestamp()-interval '1 minute');
SELECT proof_target('policy-approve-generation','policy-locale','approved','policy-generation-approval');
INSERT INTO action_approval(id,organization_id,action_id,revision_id,command_id,scope,policy_revision_id,undo_deadline,required_surface,authorization_version,created_at)
SELECT 'policy-generation-approval','proof-org','policy-locale','policy-locale-r1',id,'generate','generation-policy-r2',accepted_at+interval '5 seconds','internal_artifact',1,accepted_at FROM action_command WHERE id='policy-approve-generation';
INSERT INTO action_execution(id,organization_id,approval_id,phase,next_run_at,created_at,plan_version)
SELECT 'exec-policy-generation','proof-org',id,'ready',undo_deadline,created_at,1 FROM action_approval WHERE id='policy-generation-approval';
INSERT INTO action_execution_step(id,organization_id,execution_id,ordinal,kind,adapter_version,content_revision_id,recovery_mode,recovery_policy_version,required_surface)
VALUES('policy-generation-step','proof-org','exec-policy-generation',0,'internal_generate_content',1,'policy-locale-r1','internal_atomic',1,'internal_artifact');
SELECT proof_apply('policy-approve-generation','policy-locale');
COMMIT;
BEGIN;
SELECT proof_command('revoke-generation-next','revoke_policy','generation-policy-r2');
UPDATE action_policy_revision p SET revoked_by_command_id=c.id,revoked_at=c.accepted_at FROM action_command c WHERE p.id='generation-policy-r2' AND c.id='revoke-generation-next';
COMMIT;
UPDATE action_execution SET phase='claimed',claim_generation=1,claim_token='88888888-8888-8888-8888-888888888888',claim_expires_at=clock_timestamp()+interval '5 minutes',next_step_id='policy-generation-step' WHERE id='exec-policy-generation';
SELECT proof_reject($q$
 INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,transport,started_at,recorded_at)
 VALUES('revoked-policy-attempt','proof-org','policy-generation-step','exec-policy-generation',1,'generation',1,'88888888-8888-8888-8888-888888888888','internal',clock_timestamp(),clock_timestamp());
$q$,'revoked or missing policy','approval from a subsequently revoked policy cannot start a new generation effect');

-- Typed content cannot silently move a permanent ticket to another target.
SELECT proof_reject($q$
 SELECT proof_command('wrong-generated-locale','revise');
 INSERT INTO action_revision(id,organization_id,action_id,purpose,kind,operation,revision_number,authored_command_id,generated_from_revision_id,title,summary,content_digest,canonicalization_version,created_at)
 SELECT 'wrong-generated-locale-r3','proof-org','locale-child','proposal','listing','create_locale',3,id,'locale-child-r1','Wrong target candidate','Synthetic adversarial candidate',repeat('2',64),1,accepted_at FROM action_command WHERE id='wrong-generated-locale';
 INSERT INTO action_listing_content(organization_id,revision_id,provider_account_id,store,locale,intent,package_name,title_state,title,play_commit_policy)
 VALUES('proof-org','wrong-generated-locale-r3','proof-provider-account','android','de-DE','create','synthetic.wrong.package','present','Wrong target title','ERROR_IF_IN_REVIEW');
 UPDATE action_revision SET sealed=true WHERE id='wrong-generated-locale-r3';
 SELECT assert_revision_target_continuity('proof-org','locale-child-r1','wrong-generated-locale-r3');
$q$,'ticket target cannot change','locale generation cannot change the approved request store or locale');
SELECT proof_reject($q$
 SELECT proof_command('wrong-review-account','revise');
 SELECT proof_revision('review-two','wrong-review-account-r2','review_reply','post_reply',2,'wrong-review-account');
 INSERT INTO action_review_content(organization_id,revision_id,provider_account_id,store,provider_app_id,provider_review_id,intent,reply_text,response_availability)
 VALUES('proof-org','wrong-review-account-r2','another-provider-account','ios','proof-provider-app','review-two-provider-review','send','Synthetic changed reply','absent');
 UPDATE action_revision SET sealed=true WHERE id='wrong-review-account-r2';
 SELECT proof_target('wrong-review-account','review-two','open',NULL,NULL,'wrong-review-account-r2');
 SELECT proof_apply('wrong-review-account','review-two');
$q$,'ticket target cannot change','manual iteration cannot retarget the permanent review ticket to another provider account');

-- Review catch-up is generation work, then an explicit permanent review package.
BEGIN;
SELECT proof_start('catchup-package','collection');
SELECT proof_revision('catchup-package','catchup-package-r1','request','review_catch_up_30d');
INSERT INTO action_request_content(organization_id,revision_id,intent,window_days,review_mode,origin)
VALUES('proof-org','catchup-package-r1','review_catch_up',30,'full_agentic','human');
SELECT proof_finish_create('catchup-package','catchup-package-r1');
COMMIT;
BEGIN;
SELECT proof_command('approve-catchup-generation','approve');
SELECT proof_target('approve-catchup-generation','catchup-package','approved','catchup-generation-approval');
SELECT proof_approval('approve-catchup-generation','catchup-package','catchup-generation-approval','generate');
SELECT proof_apply('approve-catchup-generation','catchup-package');
INSERT INTO action_execution_step(id,organization_id,execution_id,ordinal,kind,adapter_version,content_revision_id,recovery_mode,recovery_policy_version,required_surface)
VALUES('catchup-generation-step','proof-org','exec-catchup-generation-approval',0,'internal_commit_children',1,'catchup-package-r1','internal_atomic',1,'internal_artifact');
COMMIT;
UPDATE action_execution SET phase='claimed',claim_generation=1,claim_token='99999999-9999-9999-9999-999999999999',claim_expires_at=clock_timestamp()+interval '5 minutes',next_step_id='catchup-generation-step' WHERE id='exec-catchup-generation-approval';
INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,transport,started_at,recorded_at)
VALUES('catchup-generation-attempt','proof-org','catchup-generation-step','exec-catchup-generation-approval',1,'generation',1,'99999999-9999-9999-9999-999999999999','internal',clock_timestamp(),clock_timestamp());
BEGIN;
SELECT proof_command('commit-catchup-children','revise');
SELECT proof_review('catchup-review-one','catchup-package');
INSERT INTO action_revision(id,organization_id,action_id,purpose,kind,operation,revision_number,authored_command_id,generated_from_revision_id,title,summary,content_digest,canonicalization_version,created_at)
SELECT 'catchup-package-r2','proof-org','catchup-package','proposal','collection','post_batch',2,id,'catchup-package-r1','Synthetic catch-up package','One exact generated reply',repeat('3',64),1,accepted_at FROM action_command WHERE id='commit-catchup-children';
INSERT INTO action_membership(organization_id,parent_revision_id,child_action_id,child_revision_id,ordinal)
VALUES('proof-org','catchup-package-r2','catchup-review-one','catchup-review-one-r1',0);
UPDATE action_revision SET sealed=true WHERE id='catchup-package-r2';
UPDATE action_execution_attempt SET finished_at=clock_timestamp(),result='generated',output_kind='revision',output_revision_id='catchup-package-r2',finalized_claim_generation=1,finalized_claim_token='99999999-9999-9999-9999-999999999999' WHERE id='catchup-generation-attempt';
UPDATE action_execution SET phase='settled',claim_token=NULL,claim_expires_at=NULL,next_run_at=NULL,result='generated',settled_at=clock_timestamp() WHERE id='exec-catchup-generation-approval';
SELECT proof_target('commit-catchup-children','catchup-package','open',NULL,NULL,'catchup-package-r2');
SELECT proof_apply('commit-catchup-children','catchup-package');
COMMIT;
SELECT proof_assert((SELECT domain='collection' AND current_revision_id='catchup-package-r2' AND current_approval_id IS NULL AND decision='open' FROM action WHERE id='catchup-package') AND (SELECT decision='open' AND parent_action_id='catchup-package' AND current_approval_id IS NULL FROM action WHERE id='catchup-review-one') AND NOT EXISTS(SELECT 1 FROM action_approval WHERE action_id='catchup-review-one'),'catch-up retains permanent request/package identity and creates unapproved durable review children');
BEGIN;
SELECT proof_command('approve-catchup-reply','approve');
SELECT proof_target('approve-catchup-reply','catchup-package','approved');
SELECT proof_target('approve-catchup-reply','catchup-review-one','approved','catchup-reply-approval','catchup-package-r2');
SELECT proof_approval('approve-catchup-reply','catchup-review-one','catchup-reply-approval','perform','catchup-package-r2');
SELECT proof_apply('approve-catchup-reply','catchup-review-one');
SELECT proof_apply('approve-catchup-reply','catchup-package');
COMMIT;
SELECT proof_assert((SELECT scope='generate' AND revision_id='catchup-package-r1' FROM action_approval WHERE id='catchup-generation-approval') AND (SELECT scope='perform' AND revision_id='catchup-review-one-r1' AND parent_revision_id='catchup-package-r2' FROM action_approval WHERE id='catchup-reply-approval'),'review batch handoff requires new exact child publication approval after generation');

-- Zero eligible reviews is a retained, evidenced outcome; never an empty batch.
INSERT INTO public.agent(id,"organizationId","assetId") VALUES('no-work-agent','proof-org','proof-asset');
INSERT INTO public.agent_run(id,"organizationId","agentId",status) VALUES('no-work-run','proof-org','no-work-agent','running');
BEGIN;
SELECT proof_start('catchup-no-work','collection');
SELECT proof_revision('catchup-no-work','catchup-no-work-r1','request','review_catch_up_30d');
INSERT INTO action_request_content(organization_id,revision_id,intent,window_days,review_mode,origin)
VALUES('proof-org','catchup-no-work-r1','review_catch_up',30,'full_agentic','human');
SELECT proof_finish_create('catchup-no-work','catchup-no-work-r1');
COMMIT;
BEGIN;
SELECT proof_command('approve-catchup-no-work','approve');
SELECT proof_target('approve-catchup-no-work','catchup-no-work','approved','catchup-no-work-approval');
SELECT proof_approval('approve-catchup-no-work','catchup-no-work','catchup-no-work-approval','generate');
SELECT proof_apply('approve-catchup-no-work','catchup-no-work');
INSERT INTO action_execution_step(id,organization_id,execution_id,ordinal,kind,adapter_version,content_revision_id,recovery_mode,recovery_policy_version,required_surface)
VALUES('catchup-no-work-step','proof-org','exec-catchup-no-work-approval',0,'internal_commit_children',1,'catchup-no-work-r1','internal_atomic',1,'internal_artifact');
COMMIT;
UPDATE action_execution SET phase='claimed',claim_generation=1,claim_token='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',claim_expires_at=clock_timestamp()+interval '5 minutes',next_step_id='catchup-no-work-step' WHERE id='exec-catchup-no-work-approval';
INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,agent_run_id,transport,started_at,recorded_at)
VALUES('catchup-no-work-attempt','proof-org','catchup-no-work-step','exec-catchup-no-work-approval',1,'generation',1,'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','no-work-run','internal',clock_timestamp(),clock_timestamp());
SELECT proof_reject($q$
 UPDATE action_execution_attempt SET finished_at=clock_timestamp(),result='generated',output_kind='no_work',no_work_reason='no_eligible_reviews',finalized_claim_generation=1,finalized_claim_token='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' WHERE id='catchup-no-work-attempt';
$q$,'completed scoped generation run','no-work cannot manufacture completion before the scoped run completes');
UPDATE public.agent_run SET status='completed',"completedAt"=clock_timestamp() WHERE id='no-work-run';
UPDATE action_execution_attempt SET finished_at=clock_timestamp(),result='generated',output_kind='no_work',no_work_reason='no_eligible_reviews',finalized_claim_generation=1,finalized_claim_token='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' WHERE id='catchup-no-work-attempt';
UPDATE action_execution SET phase='settled',claim_token=NULL,claim_expires_at=NULL,next_run_at=NULL,result='generated',settled_at=clock_timestamp() WHERE id='exec-catchup-no-work-approval';
SELECT proof_assert((SELECT a.current_revision_id='catchup-no-work-r1' AND e.phase='settled' AND x.output_kind='no_work' AND x.no_work_reason='no_eligible_reviews' AND x.agent_run_id='no-work-run' FROM action a JOIN action_execution e ON e.approval_id=a.current_approval_id JOIN action_execution_attempt x ON x.execution_id=e.id WHERE a.id='catchup-no-work') AND NOT EXISTS(SELECT 1 FROM action WHERE parent_action_id='catchup-no-work'),'no eligible reviews retains the ticket, reason and completed run without invented children or membership');
SELECT 'PASS: catch-up output package and explicit no-work result are both durable and typed.' AS result;

SELECT proof_reject($q$
 SELECT proof_start('wrong-family-package','collection');
 SELECT proof_start('wrong-family-child','listing','wrong-family-package');
 SELECT proof_revision('wrong-family-child','wrong-family-child-r1','request','generate_locale');
 INSERT INTO action_request_content(organization_id,revision_id,intent,store,locale,origin)
 VALUES('proof-org','wrong-family-child-r1','locale_expansion','ios','fr-FR','human');
 SELECT proof_finish_create('wrong-family-child','wrong-family-child-r1');
 SELECT proof_revision('wrong-family-package','wrong-family-package-r1','collection','post_batch');
 INSERT INTO action_membership(organization_id,parent_revision_id,child_action_id,child_revision_id,ordinal)
 VALUES('proof-org','wrong-family-package-r1','wrong-family-child','wrong-family-child-r1',0);
 SELECT proof_finish_create('wrong-family-package','wrong-family-package-r1');
 SET CONSTRAINTS ALL IMMEDIATE;
$q$,'collection','review batch cannot contain unrelated localization work');

-- A wake-agent request approves an exact existing agent, not any agent on an app.
INSERT INTO public.agent(id,"organizationId","assetId") VALUES
 ('requested-agent','proof-org','proof-asset'),('other-agent-same-app','proof-org','proof-asset');
INSERT INTO public.agent_run(id,"organizationId","agentId",status,"completedAt") VALUES
 ('requested-agent-run','proof-org','requested-agent','completed',clock_timestamp()),
 ('other-agent-run','proof-org','other-agent-same-app','completed',clock_timestamp());
BEGIN;
SELECT proof_start('wake-agent-ticket','agent');
SELECT proof_revision('wake-agent-ticket','wake-agent-ticket-r1','request','run_agent');
INSERT INTO action_request_content(organization_id,revision_id,intent,origin,requested_agent_id)
VALUES('proof-org','wake-agent-ticket-r1','wake_agent','human','requested-agent');
SELECT proof_finish_create('wake-agent-ticket','wake-agent-ticket-r1');
COMMIT;
BEGIN;
SELECT proof_command('approve-wake-agent','approve');
SELECT proof_target('approve-wake-agent','wake-agent-ticket','approved','wake-agent-approval');
SELECT proof_approval('approve-wake-agent','wake-agent-ticket','wake-agent-approval','generate');
SELECT proof_apply('approve-wake-agent','wake-agent-ticket');
INSERT INTO action_execution_step(id,organization_id,execution_id,ordinal,kind,adapter_version,content_revision_id,recovery_mode,recovery_policy_version,required_surface)
VALUES('wake-agent-step','proof-org','exec-wake-agent-approval',0,'internal_generate_content',1,'wake-agent-ticket-r1','internal_atomic',1,'internal_artifact');
COMMIT;
UPDATE action_execution SET phase='claimed',claim_generation=1,claim_token='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',claim_expires_at=clock_timestamp()+interval '5 minutes',next_step_id='wake-agent-step' WHERE id='exec-wake-agent-approval';
SELECT proof_reject($q$
 INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,agent_run_id,transport,started_at,recorded_at)
 VALUES('wrong-wake-attempt','proof-org','wake-agent-step','exec-wake-agent-approval',1,'generation',1,'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','other-agent-run','internal',clock_timestamp(),clock_timestamp());
$q$,'requested agent','a run from another agent on the same app is rejected before generation work starts');
INSERT INTO action_execution_attempt(id,organization_id,step_id,execution_id,number,kind,claim_generation,claim_token,agent_run_id,transport,started_at,recorded_at)
VALUES('correct-wake-attempt','proof-org','wake-agent-step','exec-wake-agent-approval',1,'generation',1,'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','requested-agent-run','internal',clock_timestamp(),clock_timestamp());
UPDATE action_execution_attempt SET finished_at=clock_timestamp(),result='generated',output_kind='agent_run',output_agent_run_id='requested-agent-run',finalized_claim_generation=1,finalized_claim_token='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb' WHERE id='correct-wake-attempt';
UPDATE action_execution SET phase='settled',claim_token=NULL,claim_expires_at=NULL,next_run_at=NULL,result='generated',settled_at=clock_timestamp() WHERE id='exec-wake-agent-approval';
SELECT proof_assert((SELECT req.requested_agent_id=run."agentId" AND x.output_agent_run_id='requested-agent-run' AND e.phase='settled' FROM action_request_content req JOIN action_approval ap ON ap.revision_id=req.revision_id JOIN action_execution e ON e.approval_id=ap.id JOIN action_execution_attempt x ON x.execution_id=e.id AND x.result='generated' JOIN public.agent_run run ON run.id=x.output_agent_run_id WHERE req.revision_id='wake-agent-ticket-r1'),'agent request retains exact approved target and completed typed run output');
