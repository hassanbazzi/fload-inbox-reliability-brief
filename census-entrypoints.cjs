const fs = require('fs');
const path = require('path');
const ROOT = path.resolve(process.argv[2] || process.cwd());
const OUT = __dirname;
const ts = require(path.join(ROOT, 'node_modules/typescript'));
const commit = '63275b2f51ac5b5a151a9a6683c813423e682785';
const tables = new Set(['pendingAction','agentRequest','agentRequestEvent','reviewDraftReply','reviewDraftRejection','inboxItemState','capabilityExecution']);
const boundaries = new Set(['approvePendingAction','approvePendingActionBatch','rejectPendingAction','rejectPendingActionBatch','rejectPendingActionAtomically','cancelPendingActionApproval','retryPendingAction','resurfacePendingAction','upsertInboxState','startInboxIteration','upsertAgentRequest','approveAgentRequest','approveAgentRequestWithDispatch','stageRegisteredWork','stageAgentPendingActions','queueApprovedReply','executeWork','executeRegisteredWork','submitCapability','submitCatalogCapability','dispatchNextStage','sendReplyViaApi','sendReplyViaBrowser']);
for(const name of ['createCatalogTask','startBacklogGenerationRequest','approveAndDispatchAgentRequest','stageBacklogItem','stageBacklogItemsBatch','stageLocaleExpansionForReview','stageLocaleHypothesis','stageListingChangeHypothesis','stageAsaWorkFromChat','runAsaWritePipeline','updateLocaleDraft','patchLocaleDraftFields','setLocaleDraftFieldDismissed','deleteDeclinedPendingAction','resumeGateBlockedActions','recordBeforeAfterState','resolveStagingRefusal','commitManagedWork','prepareBacklogItem','insertPreparedBacklogItem']) boundaries.add(name);
const routeFiles = new Set(['inbox.ts','pending-actions.ts','recommendations.ts','capabilities.ts','backlog.ts','journal.ts','assets/reviews.ts','assets/aso.ts','assets/aso-experiments.ts','assets/aso-screenshots.ts','assets/aso-screenshot-localize.ts','agents/index.ts']);
for(const name of ['apple-search-ads/write-operations.ts','webhooks/slack.ts','webhooks/discord.ts','reports.ts'])routeFiles.add(name);
const scan = { commit, directWrites: [], boundaryCalls: [], routes: [], toolNames: [], manifest: [], filesScanned: 0 };
function walk(dir) { return fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(dir,e.name)): /\.(ts|tsx)$/.test(e.name)?[path.join(dir,e.name)]:[]); }
const roots = ['apps/api/src','apps/web/src','packages/client/src','packages/fload-mcp/src','packages/core/src'];
for (const absolute of roots.flatMap(r=>walk(path.join(ROOT,r)))) {
  const file=path.relative(ROOT,absolute);
  if(file.includes('/__tests__/')||file.includes('/test/')||/\.(test|spec)\./.test(file)) continue;
  const source=fs.readFileSync(absolute,'utf8');
  const sf=ts.createSourceFile(file,source,ts.ScriptTarget.Latest,true,file.endsWith('tsx')?ts.ScriptKind.TSX:ts.ScriptKind.TS);
  scan.filesScanned++;
  const aliases = new Map();
  for(const statement of sf.statements) if(ts.isImportDeclaration(statement)) {
    const bindings=statement.importClause?.namedBindings;
    if(bindings&&ts.isNamedImports(bindings)) for(const element of bindings.elements) aliases.set(element.name.text,element.propertyName?.text||element.name.text);
  }
  const line=n=>sf.getLineAndCharacterOfPosition(n.getStart(sf)).line+1;
  const ref=(n,extra)=>({file,line:line(n),...extra});
  const literal=n=>n&&(ts.isStringLiteral(n)||ts.isNoSubstitutionTemplateLiteral(n))?n.text:null;
  function visit(n) {
    if(ts.isCallExpression(n)) {
      const exp=n.expression;
      const rawName=ts.isIdentifier(exp)?exp.text:ts.isPropertyAccessExpression(exp)?exp.name.text:null;
      const name=aliases.get(rawName)||rawName;
      if(boundaries.has(name))scan.boundaryCalls.push(ref(n,{name}));
      if(['insert','update','delete'].includes(rawName)&&n.arguments.length) {
        const arg=n.arguments[0];
        const rawTable=ts.isIdentifier(arg)?arg.text:ts.isPropertyAccessExpression(arg)?arg.name.text:null;
        const table=aliases.get(rawTable)||rawTable;
        if(tables.has(table))scan.directWrites.push(ref(n,{operation:rawName,table,category:file.includes('/scripts/')?'operator_script':file.includes('/e2e/')||/dev-agent-replay|atlas-destructive|dummy-app/.test(file)?'fixture_or_demo':/maintenance|reset-inbox-aso/.test(file)?'maintenance':'runtime'}));
      }
      const routeSuffix=file.replace('apps/api/src/routes/','');
      if(routeFiles.has(routeSuffix)&&['get','post','put','patch','delete'].includes(rawName)&&ts.isPropertyAccessExpression(exp)&&['app','fastify'].includes(exp.expression.getText(sf))) {
        const route=literal(n.arguments[0]);
        if(route) {
          const auth=n.arguments.map(a=>a.getText(sf)).join(' ').match(/authorizationPolicy\.[A-Za-z]+\([^)]*\)/)?.[0]||'see route wrapper';
          scan.routes.push(ref(n,{method:rawName.toUpperCase(),path:route,authorization:auth}));
        }
      }
    }
    if(ts.isPropertyAssignment(n)&&ts.isCallExpression(n.initializer)&&n.initializer.expression.getText(sf)==='tool')scan.toolNames.push(ref(n,{name:n.name.getText(sf)}));
    if(file.includes('capability-manifest/entries-')&&ts.isObjectLiteralExpression(n)){
      const props=Object.fromEntries(n.properties.filter(ts.isPropertyAssignment).map(p=>[p.name.getText(sf),literal(p.initializer)]));
      if(props.key&&props.executionPath)scan.manifest.push(ref(n,{key:props.key,executionPath:props.executionPath,status:props.status}));
    }
    ts.forEachChild(n,visit);
  }
  visit(sf);
}
for (const list of [scan.directWrites,scan.boundaryCalls,scan.routes,scan.toolNames,scan.manifest])list.sort((a,b)=>a.file.localeCompare(b.file)||a.line-b.line);
fs.writeFileSync(path.join(OUT,'entrypoint-census.json'),JSON.stringify(scan,null,2)+'\n');
console.log(JSON.stringify({filesScanned:scan.filesScanned,directWrites:scan.directWrites.length,boundaryCalls:scan.boundaryCalls.length,routes:scan.routes.length,tools:scan.toolNames.length,manifest:scan.manifest.length,manifestByPath:Object.fromEntries([...new Set(scan.manifest.map(r=>r.executionPath))].map(k=>[k,scan.manifest.filter(r=>r.executionPath===k).length]))},null,2));
