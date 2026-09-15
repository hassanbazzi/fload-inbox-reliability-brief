"""Validate design SQL in a NEW, disposable, network-isolated PostgreSQL 17 container.
Never loads Fload env files, secrets, existing databases, queues, or application code.
"""
from pathlib import Path
import csv, io, json, subprocess, time, uuid, sys, re, hashlib
from concurrent.futures import ThreadPoolExecutor

root=Path(__file__).parent
name='flo1355-schema-proof-'+uuid.uuid4().hex[:8]
image='timescale/timescaledb:latest-pg17'
def run(args, **kw):
    return subprocess.run(args,check=True,text=True,capture_output=True,**kw)
def sql(statement):
    result=subprocess.run(['docker','exec','-i',name,'psql','-X','-v','ON_ERROR_STOP=1','-U','postgres','-d','fload_inbox_design_test','--csv'],input=statement,text=True,capture_output=True)
    if result.returncode:
        raise RuntimeError(result.stderr[-12000:])
    return result.stdout
def rows(statement):
    return list(csv.DictReader(io.StringIO(sql(statement))))
def concurrency_proof():
    """Two real PG sessions; tests row-lock serialization + stale CAS rejection.
    It does not simulate worker death, a provider, migration, RLS, or API auth.
    """
    before=rows("SELECT version,owner_user_id FROM actions_design.action WHERE id='review-two';")[0]
    expected=int(before['version'])
    def mutation(command, snapshot_version):
        return f"""SELECT proof_command('{command}','assign');
INSERT INTO action_command_target(organization_id,command_id,action_id,expected_version,expected_revision_id,previous_version,result_version,previous_decision,result_decision,previous_revision_id,result_revision_id,previous_approval_id,result_approval_id,previous_owner_user_id,result_owner_user_id,previous_snoozed_until,result_snoozed_until,previous_archived_at,result_archived_at)
SELECT organization_id,'{command}',id,{snapshot_version},current_revision_id,version,version+1,decision,decision,current_revision_id,current_revision_id,current_approval_id,current_approval_id,owner_user_id,'proof-other-user',snoozed_until,snoozed_until,archived_at,archived_at FROM action WHERE id='review-two';
SELECT proof_apply('{command}','review-two');
COMMIT;"""
    winner="""SET search_path=actions_design,public; SET application_name='flo1355-proof-winner';
BEGIN; SELECT id FROM action WHERE id='review-two' FOR UPDATE; SELECT pg_sleep(3);
"""+mutation('concurrent-winner',expected)
    stale="""SET search_path=actions_design,public; SET application_name='flo1355-proof-stale';
BEGIN; SELECT id FROM action WHERE id='review-two' FOR UPDATE;
"""+mutation('concurrent-stale',expected)
    with ThreadPoolExecutor(max_workers=2) as pool:
        first=pool.submit(sql,winner)
        deadline=time.monotonic()+5
        while time.monotonic()<deadline:
            if rows("SELECT count(*) AS n FROM pg_stat_activity WHERE application_name='flo1355-proof-winner' AND wait_event='PgSleep';")[0]['n']=='1':break
            if first.done():raise RuntimeError('Concurrency setup failed: winner did not hold row lock')
            time.sleep(.05)
        else:raise RuntimeError('Concurrency setup timed out before winner held row lock')
        second=pool.submit(sql,stale)
        blocked=False
        deadline=time.monotonic()+2
        while time.monotonic()<deadline:
            blocked=rows("SELECT count(*) AS n FROM pg_stat_activity WHERE application_name='flo1355-proof-stale' AND wait_event_type='Lock';")[0]['n']=='1'
            if blocked:break
            if second.done():break
            time.sleep(.05)
        first.result(timeout=10)
        try:second.result(timeout=10)
        except RuntimeError as exc:
            if 'stale or absent expected version/revision' not in str(exc):raise
        else:raise RuntimeError('Concurrency failure: stale command unexpectedly accepted')
        assert blocked,'Second real PostgreSQL session was not observed waiting for the row lock'
    after=rows("SELECT version,owner_user_id,last_command_id FROM actions_design.action WHERE id='review-two';")[0]
    assert int(after['version'])==expected+1 and after['owner_user_id']=='proof-other-user' and after['last_command_id']=='concurrent-winner'
    assert rows("SELECT count(*) AS n FROM actions_design.action_command WHERE id='concurrent-stale';")[0]['n']=='0'
    print('PASS: two PostgreSQL sessions serialize the same ticket; stale snapshot rejects after winner commits; exactly one version advances.',flush=True)
    return {'sessions':2,'rowLockWaitObserved':True,'winnerVersionAdvance':1,'staleCommandAccepted':False}
started=False
try:
    run(['docker','image','inspect',image])
    run(['docker','run','-d','--rm','--network','none','--name',name,'--label','fload.schema-proof=flo-1355','-e','POSTGRES_PASSWORD=flo1355-disposable-test','-e','POSTGRES_DB=fload_inbox_design_test',image])
    started=True
    for _ in range(40):
        logs=subprocess.run(['docker','logs',name],capture_output=True,text=True)
        r=subprocess.run(['docker','exec',name,'pg_isready','-U','postgres','-d','fload_inbox_design_test'],capture_output=True)
        if r.returncode==0 and 'init process complete' in logs.stdout+logs.stderr:break
        time.sleep(0.5)
    else:raise RuntimeError('Disposable test PostgreSQL did not become ready')
    assert rows('SELECT current_database() AS database, current_setting(\'server_version_num\') AS version;')[0]['database']=='fload_inbox_design_test'
    sql('''CREATE TABLE public.organization(id text PRIMARY KEY);
CREATE TABLE public."user"(id text PRIMARY KEY);
CREATE TABLE public.asset(id text PRIMARY KEY,"organizationId" text NOT NULL);
CREATE TABLE public.api_key(id text PRIMARY KEY);
CREATE TABLE public.slack_integration(id text PRIMARY KEY,organization_id text NOT NULL);
CREATE TABLE public.discord_integration(id text PRIMARY KEY,organization_id text NOT NULL);
CREATE TABLE public.agent(id text PRIMARY KEY,"organizationId" text NOT NULL,"assetId" text);
CREATE TABLE public.agent_run(id text PRIMARY KEY,"organizationId" text NOT NULL,"agentId" text,status text,"completedAt" timestamptz);
CREATE TABLE public.review_analysis(id text PRIMARY KEY,organization_id text NOT NULL,asset_id text NOT NULL,total_reviews_analyzed integer NOT NULL);
CREATE TABLE public.data_connector(id text PRIMARY KEY,"organizationId" text NOT NULL);
CREATE TABLE public.aso_recommendation(id text PRIMARY KEY,"assetId" text NOT NULL);
CREATE TABLE public.aso_recommendation_variant(id text PRIMARY KEY,"recommendationId" text NOT NULL);
CREATE TABLE public.report_version(id text PRIMARY KEY,organization_id text NOT NULL);
CREATE TABLE public.opportunity_backlog(id text PRIMARY KEY,organization_id text NOT NULL);
CREATE TABLE public.aso_experiment(id text PRIMARY KEY,"assetId" text NOT NULL);''')
    parts=['schema-core.sql','schema-content.sql','schema-content-additions.sql','schema-revision-guards.sql','schema-command-guards.sql','schema-execution-guards.sql','schema-domain-bindings.sql']
    statements=[]
    for part in parts:
        p=root/part
        if not p.exists():raise RuntimeError('Missing schema component '+part)
        statements.append(p.read_text())
    complete='\n\n'.join(statements)
    sql(complete)
    print('PASS: complete current-capability schema compiled on isolated PostgreSQL 17.',flush=True)
    if '--compile-only' in sys.argv:
        raise SystemExit(0)
    proof=root/'schema-proof.sql'
    if proof.exists():
        output=sql(proof.read_text())
        print(output[-12000:],flush=True)
    else:raise RuntimeError('Missing invariant proof cases')
    execution_proof=root/'schema-execution-proof.sql'
    if not execution_proof.exists():raise RuntimeError('Missing provider execution proof cases')
    print(sql(execution_proof.read_text())[-12000:],flush=True)
    concurrency_result=concurrency_proof()
    proof_text=proof.read_text()+'\n'+execution_proof.read_text()
    proof_counts={'positive':len(re.findall(r'^SELECT proof_assert\(',proof_text,re.M)), 'negative':len(re.findall(r'^SELECT proof_reject\(',proof_text,re.M))}
    model={
      'scope':'current-capability design with external domain identity stubs; not a migration or implemented application',
      'validatedAt':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),
      'columns':rows("SELECT c.relname AS table_name,a.attnum AS position,a.attname AS name,format_type(a.atttypid,a.atttypmod) AS type,NOT a.attnotnull AS nullable,pg_get_expr(d.adbin,d.adrelid) AS default_expression FROM pg_attribute a JOIN pg_class c ON c.oid=a.attrelid JOIN pg_namespace n ON n.oid=c.relnamespace LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE n.nspname='actions_design' AND c.relkind='r' AND a.attnum>0 AND NOT a.attisdropped ORDER BY c.relname,a.attnum;"),
      'constraints':rows("SELECT cl.relname AS table_name,c.conname AS name,c.contype AS kind,pg_get_constraintdef(c.oid,true) AS definition FROM pg_constraint c JOIN pg_class cl ON cl.oid=c.conrelid JOIN pg_namespace n ON n.oid=cl.relnamespace WHERE n.nspname='actions_design' ORDER BY cl.relname,c.conname;"),
      'enums':rows("SELECT t.typname AS name,e.enumlabel AS value FROM pg_type t JOIN pg_enum e ON e.enumtypid=t.oid JOIN pg_namespace n ON n.oid=t.typnamespace WHERE n.nspname='actions_design' ORDER BY t.typname,e.enumsortorder;"),
      'indexes':rows("SELECT tablename AS table_name,indexname AS name,indexdef AS definition FROM pg_indexes WHERE schemaname='actions_design' ORDER BY tablename,indexname;"),
      'triggers':rows("SELECT event_object_table AS table_name,trigger_name AS name,event_manipulation AS event,action_timing AS timing FROM information_schema.triggers WHERE trigger_schema='actions_design' ORDER BY event_object_table,trigger_name,event_manipulation;")}
    assert not any(c['type'] in ('json','jsonb') or c['type'].endswith('[]') for c in model['columns'])
    (root/'Fload-Inbox-Current-Schema.sql').write_text(complete)
    (root/'current-schema-catalog.json').write_text(json.dumps(model,indent=2))
    (root/'design-validation-result.json').write_text(json.dumps({'schemaCompiled':True,'proofPassed':True,'database':'isolated PostgreSQL 17','tableCount':len(set(c['table_name'] for c in model['columns'])),'columnCount':len(model['columns']),'validatedAt':model['validatedAt'],'applicationImplemented':False,'migrationTested':False,'sqlAssertions':proof_counts,'concurrency':concurrency_result,'schemaSha256':hashlib.sha256(complete.encode()).hexdigest(),'schemaParts':{part:hashlib.sha256(statement.encode()).hexdigest() for part,statement in zip(parts,statements)}},indent=2))
    print('PASS: field catalog generated from PostgreSQL; no JSON/JSONB or array columns.',flush=True)
finally:
    if started:
        subprocess.run(['docker','stop','-t','1',name],check=False,capture_output=True)
