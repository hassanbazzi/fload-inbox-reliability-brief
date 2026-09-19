# Proposed narrow history-ticket matrix for R3

19 September 2026. M1–M3 / L1–L6 follow-up applied; subsequent C4/C5 proof and attention qualifications applied. Companion proposal to destination contracts v2; not an accepted schema amendment or implementation claim. No code, tests, migrations or provider calls. It specifies the proposed **ticket/head/command** branch for source facts that already have an accepted closed historical content shape; unresolved content, target, membership and effect proofs remain explicitly gated below.

## Why use revise, not reopen

The preserved Core `revise` edit branch installs a new sealed proposal on the same action, retains identity and keeps approval absent on the proposed historical branch (`packages/core/src/actions/ticket-service.ts:290–306`; wire `contracts/actions.ts:102–119` calls this mode `edit`). `restore` currently permits declined→open without changing its revision (`ticket-service.ts:363–367`). In contrast, accepted v15 `reopen` settles a real failed active execution using exact approval/execution/effect evidence (v15:440–453). Imported history has no such execution. Never fabricate one or borrow that command.

The changes below extend the existing **create, reject, supersede, archive, restore, assign, record_observation and revise** variants with finite historical branches. They do not add a command kind, execution, approval or workflow engine.

## 1. Discriminator and committed-head matrix

Replace the proposed `historical_completed` label with neutral `historical`. Use:

`action.record_kind ENUM('work','historical','historical_deleted') NOT NULL DEFAULT 'work'`.

“Historical” means non-authorizing imported facts, **not completed provider work**. Source completion/deletion claims remain independently attributed history. `record_kind` is set at create and changed only by the two exact transition families below.

| Committed record kind | Permitted decision | Required current_revision_id | Current approval / executions | Meaning |
|---|---|---|---|---|
| work | existing runtime decision matrix | Same-action, same-tenant sealed proposal | Existing rules | Normal work, including work with prior imported facts |
| historical | open, declined, superseded | Same-action, same-tenant sealed historical revision | NULL approval; **no action_approval or action_execution rows for this action** | An inspectable historical display head; open does not mean actionable |
| historical_deleted | open, declined, superseded | Same historical-head rule | Same prohibition | Preserved deleted identity reachable through its old link |

For superseded, retain the existing iff successor ID rule, same-tenant scope and cycle rules. Do not infer a supersession or fabricate its missing successor. Declined requires an actual conserved rejection/disposition claim. Open here means there is no imported present decision; it must never become a default approval or completion.

All three kinds have the same permanent action/creation key and parent identity. Historical content may remain on a work ticket after fresh work is adopted. A historical revision can be selected as a **display head only** for the two historical kinds; it is never an executable head, approval target, baseline, generated result or dependency-completion proof. Baselines/observations use only the explicit canonical capture branches in §2.2; they are never selected as the current historical head.

The prototype's unconditional proposal checks (`0146_durable_actions.sql:2115,2224`; Core `ticket-service.ts:127–130`) must become this exact finite matrix. Keep the ordinary work branch unchanged. Do not merely remove those checks or permit NULL heads at commit. The proposal’s earlier blanket “historical excluded from head adoption” becomes “excluded from **work** head adoption; historical kinds have a non-authorizing historical display head.”


L1 structural shape (schematic joined-row predicate, required to evaluate IS TRUE rather than allowing SQL NULL): `current_revision_id IS NOT NULL AND sealed AND CASE record_kind WHEN 'work' THEN purpose='proposal' WHEN 'historical' THEN purpose='historical' WHEN 'historical_deleted' THEN purpose='historical' ELSE false END`. The same-tenant/same-action head FK remains mandatory. Historical kinds require current_approval_id NULL and no approval/execution rows. Deferred structural constraints check committed shape; they do not duplicate Core's full transition policy. Wire unions, canonical writer policy and real-role fixtures must agree before admitting any historical ticket.

The read model joins the current revision on tenant/action/id and the exact purpose selected by record_kind. It excludes both historical kinds from needs_decision/in_progress **before** ordinary status logic; INNER JOIN and count selectors cannot silently drop them or classify historical/open as actionable. No widened `purpose IN (...)` substitutes for this matrix.

## 2. Exact command matrix after import

All commands retain canonical authorization, exact version/revision pins, tenant checks, idempotency and standard owner permission checks. Personal read commands remain separate from workflow. Any command not listed is refused invalid_transition for a historical record; there is no generic migration/runtime bypass.

| Current state | Allowed workflow commands and result |
|---|---|
| historical/open | archive and assign; restore(mode=placement) preserves kind/decision/head; canonical record_observation for baseline preparation (§2.2); **revise/edit** may adopt under §3 |
| historical/declined | archive and assign, retaining kind/decision/head; **explicit current human restore(mode=reconsider)** changes decision to open and clears placement, retaining historical kind/head; qualified source-change record_observation (§2.2), then **revise/replace_declined** only under §3B |
| historical/superseded | archive only; preserve successor and follow its permanent link; no restore or revise |
| historical_deleted/open or declined or superseded | **explicit current human restore(mode=unhide)** changes kind to historical, clears placement and preserves decision/head/successor exactly; all other workflow commands refused |
| work/any | Existing runtime rules, unaffected by this historical branch |

“Current human” means an established user or user-bound API-key/delegated principal with the existing appropriate command permission. A system importer, background discovery, agent, policy, source author or old approval is not that authority. The UI names the two distinct restores: “Restore historical record” for historical_deleted; “Reconsider declined work” for historical/declined. Restoring a deleted declined record does **not** also reconsider its rejection.

`restore` never creates a proposal, approval, execution or provider I/O. Its historical/open result stays non-actionable until §3 succeeds. The command receipt records that actual present actor. Preserve v15 restore attention semantics; adopting the new proposal increments attention through revise, not through an invented success notification.

`revise/iterate`, approve, undo, retry, reconcile, reopen, schedule/unschedule, snooze/unsnooze, acknowledge and resolve_external are refused for historical kinds. Historical effect recovery is completed through the cutover recovery gate before these kinds are admitted; these records are not replacement recovery executions.

### 2.1 Restore binds explicit intent (M2)

Add required `restore_mode enum {placement,reconsider,unhide}` to the strict restore wire payload, command digest and a nullable column on action_command. Require it exactly when kind=restore; forbid it for every other command. Preserve the submitted mode on a refused request receipt where such a receipt is admitted; an idempotency mismatch never rewrites an existing command. Historical branches have no inferred default mode.

| Mode | Historical preimage | Exact result |
|---|---|---|
| placement | historical/open | Clear shared archive/snooze placement only; preserve decision, kind, head and successor |
| reconsider | historical/declined; present user or user-bound authorized principal | historical/open, same head, no approval; clear placement; preserve rejection history |
| unhide | historical_deleted/open, declined or superseded; present user or user-bound authorized principal | historical with the exact previous decision/head/successor; no reconsideration |

Mode/preimage mismatch refuses invalid_transition. unhide is the only new exception to the prototype's closed refusal for a superseded ticket: it changes visibility only. It never permits superseded revision/adoption. Historical acknowledged is not added by copying the review's work-state example. Exact pins still reject stale intent even with a valid mode.

Work restore keeps the existing unsettled/unresolved/closed guards and canonical principal permissions. The finite mode mapping is:

| Work mode | Existing eligible preimage | Result |
|---|---|---|
| placement | open, or approved where the existing restore branch preserves decision/approval | Clear placement only; preserve revision/decision/approval |
| reconsider | declined or acknowledged, under the existing work command authority | Open, same revision; no new approval |
| reconsider | approved, current approval scope generate/revise (never perform), its execution settled and failed, no unresolved or unsettled work, and the existing branch's principal permission | Open and clear current approval, preserving the old execution/approval as history |
| unhide | none | Refused; work cannot become historical |

Source prototype ticket-service.ts:363–374 includes that failed non-perform branch. Do not silently remove it through the review's shorter declined/acknowledged predicate. Failed perform work still requires its separate accepted reopen/effect protocol. No caller may select placement on a preimage whose old restore changes decision. Missing mode refuses under the new strict contract; clients and source/digest versions must migrate together rather than backfilling guessed intent on old immutable commands. Historical prior-source restore labels remain claims. Restore remains attention-neutral and creates no provider I/O, proposal or approval.

### 2.2 Canonical historical baseline capture (M1, qualified)

Allow accepted record_observation on historical/open for adoption baseline preparation. Also allow a **conditionally reachable source-change capture** on historical/declined for the accepted automatic replace_declined path only when the rejected source can be independently recovered and compared. Declined capture requires the exact currently effective reject command/head and a proved comparable original source; unknown legacy preimages remain suppressed. Neither capture changes record kind, decision, display head, approval or suppression. They increment workflow version once and are attention-neutral because they only prepare non-actionable evidence. Historical/superseded and historical_deleted/* refuse both captures. No write, generation or execution is created.

**Recovered-preimage gate (C4):** historical/declined review tickets come from import; their conserved rejection claim contains the legacy digest, not a sealed rejected review snapshot. This capture branch is unavailable by default. A separately proved historical review preimage is required: for example, a retained review_history snapshot with the exact original review/app/store identity and all legacy hash inputs whose v1 digest reproduces the claim under the proved original process-zone/codec semantics (RD1). Matching a date, today's review or the rejected reply text is insufficient. The v1 hash omits the provider-edited flag; a hash match therefore does not by itself prove every field required by the new meaningful-change comparison. Establish the complete comparable source and any unhashed required fields independently, using the strict version bridge. Missing provenance, multiple conflicting candidates or an unfinished recovery codec keep the branch unavailable and suppression intact. Recovery does not rewrite the immutable claim as a newly sealed historical approval or observation. The recovered-source representation and comparison fixtures remain a design gate; this paragraph does not claim recovered production rows exist.

**Attention rule (C5):** the canonical writer derives attention from prior state, new state and cause under ownership v6. These two evidence-only historical captures increment workflow version once and attention by zero, and never advance personal read marks. Do not copy v15:747's broad “ordinary observation version/attention” wording into these additional branches. A subsequent adopted revision or meaningful visible transition receives its own normal attention treatment; evidence capture cannot silently perform that transition. The existing failed-perform refresh branch is not redefined here.

Reuse the existing command-target `refresh_after_command_id`, `refresh_read_started_at` and evidence_revision_id with **explicit additional historical guard branches**. The existing v15 failed-perform-reopen branch is unchanged; it is not a generic guard that already admits create/restore/reject boundaries.

- historical/open boundary: latest accepted command in the exact target result_version chain that entered this historical/open state — create, restore(reconsider), or restore(unhide) preserving open. Placement-only restore, archive, assign and evidence append do not renew the boundary.
- historical/declined boundary: the exact active accepted migration reject plus its conserved source claim. Capture is limited to the review source fields needed by v15 meaningful-change comparison and the complete replacement baseline; it grants no new decision.
- At a short authorized preflight, verify the boundary has already committed and exact head/version/target still match; acquire a DB-clock read-start marker after its accepted_at, then release locks. Perform a fresh supported read-only provider read, without cached results or provider mutation. A timestamp comparison alone cannot prove this ordering.
- Final transaction locks idempotency then the ticket/scope, revalidates authority, boundary, pins, source identity and effect disposition, seals the exact observation and persists the accepted record_observation target with that provenance. Stale results refuse without adopting the network result. Refused targets forbid populated refresh metadata. Read-start >= boundary acceptance; captured_at >= read-start, using the existing server-clock convention.
- A later edit uses the post-capture current workflow version. When its domain requires a baseline, it pins the already recorded qualifying observation as baseline_revision_id; it does not insert a second copy or invent an observation for a domain without that contract. Complete target/field/freshness requirements remain unchanged. Unsupported readback leaves baseline_required; import itself still makes no provider calls.

Historical source snapshots are never manufactured as observations. The before/after kind/decision/head snapshots on capture are identical; no current-read watermark is silently advanced. This new branch needs integrated strict request/capture guards and fixtures, not merely an allowance in prose.

## 3. Same-ID adoption of a fresh proposal

### A. Explicit edit from historical/open

Use existing `revise`, `mode='edit'`, with a complete new revision draft and the exact current historical target pins. It is an explicit present reconsideration, not an automatic producer upsert. A background producer finding that permanent key returns the historical ticket and the need for an authorized edit; it may not mint a duplicate or silently activate the record.

1. Before adoption, obtain and persist the required fresh canonical baseline through §2.2 and prepare complete content. Preparation is read-only with respect to provider writes and bound to the exact historical action/head; a post-restoration baseline is required when restoration is the reconsideration step. Historical snapshots and matching legacy hashes do not satisfy freshness. Apply all normal content/target/source/completeness rules.
2. Under canonical idempotency then ordered action/scope locks, re-read authority, exact kind/decision/version/head, source identities and dependencies. Require historical/open, NULL approval, no approval/execution rows, and the durable cutover disposition showing no unresolved prior effect. Revalidate the prepared baseline under the same required freshness/target rules as new work. A concurrent source/head/permission change refuses atomically.
3. Append and seal the new proposal through the existing closed domain path. Where its domain/operation requires a baseline, pin the already persisted qualifying observation as baseline_revision_id. For request/advisory operations without a baseline contract, do not invent an observation or perform provider I/O. The accepted revise target records previous_revision_id=the exact historical head and result_revision_id=the new proposal under contracts §2.4; no new adoption column or generation provenance is needed. Change **record_kind historical→work**, preserve decision=open, set the proposal as current head, leave current_approval_id NULL, and increment version and attention once as a revision change. Keep action ID, creation key, structural parent, all aliases, historical revisions, rejection claims and actors.
4. Persist the exact before/after command target in that transaction. Commit all or nothing. A missing baseline returns baseline_required; incomplete content returns incomplete_revision; no partial conversion or empty executable skeleton may commit.

The next provider/generation action still needs a **new approval pinned to this new proposal**. No old source claim, restore command or edit authorizes delivery. `work→historical*` is forbidden; normal subsequent completion uses the existing workflow.

### B. Automatic declined replacement

Use the already accepted v15 `revise/replace_declined` mode, not the edit branch. It may transition historical/declined→work/open only with exact current pins, a proved meaningful review-source change in rating/body/title/provider-edited flag, a fresh source baseline, and no unresolved effects (v15:183–185). Preserve the original suppression/rejection history; use the carried source-change idempotency key. Unknown legacy preimages and manual authorship are not substitutes for the meaningful-change proof. This branch also creates no approval.

Suppression follows the currently effective decline in the exact command/version chain. A successful explicit reconsideration retires its blocking effect without deleting the claim; historical/open still cannot be automatically activated. After fresh-work adoption, a later runtime rejection pins its own source snapshot, so an old incomparable import claim is not a permanent veto on that later valid source-change proof. Import, alias discovery and matching dates never select or clear this authority.

For an explicit human override without meaningful source change, the two commands are deliberate: restore historical/declined→historical/open, then §3A with a fresh complete proposal. Both are separately attributable, can commit independently without enabling I/O, and cannot be synthesized by migration. For historical_deleted/declined, first unhide without altering declined; reconsideration remains a second explicit decision.

## 4. Initial import transaction and structural constraints

Historical ticket creation still has one accepted system/migration `create` command with exact source/mapping provenance. Insert the action as the bounded uncommitted NULL-head skeleton at version=attention_version=1; its intended record_kind is set at insertion. Insert an unsealed historical revision envelope, persist only allowed closed historical content, seal it, insert the matching create target, then initialize that historical display head without changing version. At commit the matrix in §1 must hold.

For a proved declined or superseded historical disposition, follow create with the existing migration-channel reject or supersede command in the same component transaction. These **import-only initialization branches** accept the exact sealed historical display head and conserved source decision; they cannot run on an existing runtime ticket or manufacture a human actor. Expected pins/version come from the immediately preceding command. A historical_deleted ticket can retain a declined/superseded decision through these bounded import branches; that is distinct from its restricted post-import command matrix. Source dates remain claims; no schedule is written to a historical kind.

A proved shared backlog archive may use the bounded import archive branch only after whole-class reconciliation and effect disposition (contracts §3.3); its historical actor/time stay in claims. No pending-action archive field is invented, and deletion/personal overlays do not authorize archive.

New executable imported work uses the unchanged work/proposal initialization and all required fresh baseline gates. For those tickets, initialize a proved inherited schedule while open, then terminal dispositions as appropriate. Do not make declined history executable simply to make the command chain pass.

Add `previous_record_kind` nullable and `result_record_kind` NOT NULL to the **existing action_command_target**, using the same closed enum; include record_kind in workflow/result snapshots. On create previous is NULL; on every non-create action target previous is the exact locked preimage and result is its recorded outcome. Unchanged-head evidence commands preserve both values. This applies to each target that actually exists; not-found/permission refusals and idempotency mismatches may have no targets and do not fabricate snapshots. Historical revision/approval admission and record-kind changes use canonical Core policy plus the accepted structural, immutable and concurrency guards. No new history table or command kind is introduced by this matrix.

Permit only these record-kind changes: create sets initial kind; explicit historical_deleted restore→historical; eligible revise from historical→work. All other commands preserve it, all work→historical changes fail, and no transaction may leave a historical kind with an approval/execution row. Command targets and the final head must match; ordinary revision immutability remains intact.

## 5. Display and scope limits

Historical placement remains a product decision: (a) existing collapsed Done groups with an explicit legacy-source label and deterministic claim-date placement, or (b) a new labelled group within the single list. Neither candidate is accepted here and no new tab is introduced. Both exclude historical records from actionable/in-progress and provider-verified success totals. Display “legacy source reported complete” where supported, not “Fload verified live.” Count each permanent ticket once using the same eligibility and deterministic historical-claim/date selector in list/count/cursor paths. Unknown date is explicit; import time is not fabricated occurrence time. Historical_deleted is excluded from customer lists/counts and resolves through an authorized old URL. After adoption, the same ID moves to work and its old claims remain in detail, without a duplicate history item.

This matrix does **not** resolve these rows by assertion:

- Any component with unresolved issued effects, unclear quiescence or unresolved duplicate identity: remains a cutover blocker; do not hide it as historical_deleted or historical complete.
- Missing or open historical content shapes/targets: preserve sources until the relevant owner supplies a strict non-authorizing shape. A new historical purpose is not permission for arbitrary payloads.
- Unproved historical collection membership: retain the separately typed historical set, not an approvable reconstructed package. Fresh collection adoption additionally needs an exact fully populated current member proposal set and atomic child/parent rules. Until that specific matrix is complete, collection adoption returns unsupported_operation; member ticket identity and readable historical group links remain preserved. Do not relax ordinary proposal membership requirements.
- Supersession whose successor cannot be resolved: retain the claim/link ambiguity and block a superseded runtime decision; do not invent a successor or reopen it.

Required acceptance cases: historical-only create→reject commits without an executable proposal; archive/assign of a historical display head; deleted-declined restore preserves declined; reconsideration remains historical until a fresh baseline/proposal commits; concurrent restore/edit/source change; two edits reuse the same key/pins; automatic meaningful-change replacement vs unknown old preimage; no second action at the same review key; every approval/iteration/execution/dependency-completion attempt against a historical head refuses; same-ID adoption emits one attention change and no approval; stale import/replay cannot change an already adopted work ticket. These are design requirements, not executed tests.
