# Proposed narrow history-ticket matrix for R3

19 September 2026. Companion proposal to destination contracts v2; not an accepted schema amendment or implementation claim. No code, tests, migrations or provider calls. It closes the **ticket/head/command** branch for source facts that already have an accepted closed historical content shape; unresolved content, target, membership and effect proofs remain explicitly gated below.

## Why use revise, not reopen

The preserved Core `revise` edit branch installs a new sealed proposal on the same action, retains identity and keeps approval absent on the proposed historical branch (`packages/core/src/actions/ticket-service.ts:290–306`; wire `contracts/actions.ts:102–119` calls this mode `edit`). `restore` currently permits declined→open without changing its revision (`ticket-service.ts:363–367`). In contrast, accepted v15 `reopen` settles a real failed active execution using exact approval/execution/effect evidence (v15:440–453). Imported history has no such execution. Never fabricate one or borrow that command.

The changes below extend the existing **create, reject, supersede, archive, restore, assign and revise** variants with finite historical branches. They do not add a command kind, execution, approval or workflow engine.

## 1. Discriminator and committed-head matrix

Replace the proposed `historical_completed` label with neutral `historical`. Use:

`action.record_kind ENUM('work','historical','historical_deleted') NOT NULL DEFAULT 'work'`.

“Historical” means non-authorizing imported facts, **not completed provider work**. Source completion/deletion claims remain independently attributed history. `record_kind` is immutable except the two exact command transitions below; it is not immutable forever.

| Committed record kind | Permitted decision | Required current_revision_id | Current approval / executions | Meaning |
|---|---|---|---|---|
| work | existing runtime decision matrix | Same-action, same-tenant sealed proposal | Existing rules | Normal work, including work with prior imported facts |
| historical | open, declined, superseded | Same-action, same-tenant sealed historical revision | NULL approval; **no action_approval or action_execution rows for this action** | An inspectable historical display head; open does not mean actionable |
| historical_deleted | open, declined, superseded | Same historical-head rule | Same prohibition | Preserved deleted identity reachable through its old link |

For superseded, retain the existing iff successor ID rule, same-tenant scope and cycle rules. Do not infer a supersession or fabricate its missing successor. Declined requires an actual conserved rejection/disposition claim. Open here means there is no imported present decision; it must never become a default approval or completion.

All three kinds have the same permanent action/creation key and parent identity. Historical content may remain on a work ticket after fresh work is adopted. A historical revision can be selected as a **display head only** for the two historical kinds; it is never an executable head, approval target, baseline, generated result or dependency-completion proof. Baselines/observations can be attached through their normal preparation path but never selected as any current head.

The prototype's unconditional proposal checks (`0146_durable_actions.sql:2115,2224`; Core `ticket-service.ts:127–130`) must become this exact finite matrix. Keep the ordinary work branch unchanged. Do not merely remove those checks or permit NULL heads at commit. The proposal’s earlier blanket “historical excluded from head adoption” becomes “excluded from **work** head adoption; historical kinds have a non-authorizing historical display head.”

## 2. Exact command matrix after import

All commands retain canonical authorization, exact version/revision pins, tenant checks, idempotency and standard owner permission checks. Personal read commands remain separate from workflow. Any command not listed is refused invalid_transition for a historical record; there is no generic migration/runtime bypass.

| Current state | Allowed workflow commands and result |
|---|---|
| historical/open | archive and assign, retaining kind/decision/head; restore clears placement only; **revise/edit** may adopt new work under §3 |
| historical/declined | archive and assign, retaining kind/decision/head; **explicit current human restore** changes only decision to open and clears placement, retaining historical kind/head; **automatic revise/replace_declined** is the exact v15 meaningful-source-change branch in §3 |
| historical/superseded | archive only; preserve successor and follow its permanent link; no restore or revise |
| historical_deleted/open or declined or superseded | **explicit current human restore** changes kind to historical, clears placement and preserves decision/head/successor exactly; all other workflow commands refused |
| work/any | Existing runtime rules, unaffected by this historical branch |

“Current human” means an established user or user-bound API-key/delegated principal with the existing appropriate command permission. A system importer, background discovery, agent, policy, source author or old approval is not that authority. The UI names the two distinct restores: “Restore historical record” for historical_deleted; “Reconsider declined work” for historical/declined. Restoring a deleted declined record does **not** also reconsider its rejection.

`restore` never creates a proposal, approval, execution or provider I/O. Its historical/open result stays non-actionable until §3 succeeds. The command receipt records that actual present actor. Preserve v15 restore attention semantics; adopting the new proposal increments attention through revise, not through an invented success notification.

`revise/iterate`, approve, undo, retry, reconcile, reopen, schedule/unschedule, snooze/unsnooze, acknowledge and resolve_external are refused for historical kinds. Historical effect recovery is completed through the cutover recovery gate before these kinds are admitted; these records are not replacement recovery executions.

## 3. Same-ID adoption of a fresh proposal

### A. Explicit edit from historical/open

Use existing `revise`, `mode='edit'`, with a complete new revision draft and the exact current historical target pins. It is an explicit present reconsideration, not an automatic producer upsert. A background producer finding that permanent key returns the historical ticket and the need for an authorized edit; it may not mint a duplicate or silently activate the record.

1. Outside the adoption transaction, obtain any required fresh canonical baseline and complete content. Preparation is read-only with respect to provider writes and bound to the exact historical action/head; a post-restoration baseline is required when restoration is the reconsideration step. Historical snapshots and matching legacy hashes do not satisfy freshness. Apply all normal content/target/source/completeness rules.
2. Under canonical idempotency then ordered action/scope locks, re-read authority, exact kind/decision/version/head, source identities and dependencies. Require historical/open, NULL approval, no approval/execution rows, and the durable cutover disposition showing no unresolved prior effect. Revalidate the prepared baseline under the same required freshness/target rules as new work. A concurrent source/head/permission change refuses atomically.
3. Append and seal the new baseline/proposal through the existing closed domain paths. Change **record_kind historical→work**, preserve decision=open, set the proposal as current head, leave current_approval_id NULL, and increment version and attention once as a revision change. Keep action ID, creation key, structural parent, all aliases, historical revisions, rejection claims and actors.
4. Persist the exact before/after command target in that transaction. Commit all or nothing. A missing baseline returns baseline_required; incomplete content returns incomplete_revision; no partial conversion or empty executable skeleton may commit.

The next provider/generation action still needs a **new approval pinned to this new proposal**. No old source claim, restore command or edit authorizes delivery. `work→historical*` is forbidden; normal subsequent completion uses the existing workflow.

### B. Automatic declined replacement

Use the already accepted v15 `revise/replace_declined` mode, not the edit branch. It may transition historical/declined→work/open only with exact current pins, a proved meaningful review-source change in rating/body/title/provider-edited flag, a fresh source baseline, and no unresolved effects (v15:183–185). Preserve the original suppression/rejection history; use the carried source-change idempotency key. Unknown legacy preimages and manual authorship are not substitutes for the meaningful-change proof. This branch also creates no approval.

Suppression follows the currently effective decline in the exact command/version chain. A successful explicit reconsideration retires its blocking effect without deleting the claim; historical/open still cannot be automatically activated. After fresh-work adoption, a later runtime rejection pins its own source snapshot, so an old incomparable import claim is not a permanent veto on that later valid source-change proof. Import, alias discovery and matching dates never select or clear this authority.

For an explicit human override without meaningful source change, the two commands are deliberate: restore historical/declined→historical/open, then §3A with a fresh complete proposal. Both are separately attributable, can commit independently without enabling I/O, and cannot be synthesized by migration. For historical_deleted/declined, first unhide without altering declined; reconsideration remains a second explicit decision.

## 4. Initial import transaction and structural constraints

Historical ticket creation still has one accepted system/migration `create` command with exact source/mapping provenance. Insert the action as the bounded uncommitted NULL-head skeleton at version=attention_version=1; its intended record_kind is set at insertion. Insert an unsealed historical revision envelope, persist only allowed closed historical content, seal it, insert the matching create target, then initialize that historical display head without changing version. At commit the matrix in §1 must hold.

For a proved declined or superseded historical disposition, follow create with the existing migration-channel reject or supersede command in the same component transaction. These **import-only initialization branches** accept the exact sealed historical display head and conserved source decision; they cannot run on an existing runtime ticket or manufacture a human actor. Expected pins/version come from the immediately preceding command. A historical_deleted ticket can retain a declined/superseded decision through these bounded import branches; that is distinct from its restricted post-import command matrix. Source dates remain claims; no schedule is written to a historical kind.

New executable imported work uses the unchanged work/proposal initialization and all required fresh baseline gates. For those tickets, initialize a proved inherited schedule while open, then terminal dispositions as appropriate. Do not make declined history executable simply to make the command chain pass.

Add `previous_record_kind` nullable and `result_record_kind` NOT NULL to the **existing action_command_target**, using the same closed enum; include record_kind in workflow/result snapshots. On create previous is NULL; on every non-create action target previous is the exact locked preimage and result is its recorded outcome. Unchanged-head evidence commands preserve both values. Historical revision/approval admission and record-kind changes use canonical Core policy plus the accepted structural, immutable and concurrency guards. No new history table or command kind is introduced by this matrix.

Permit only these record-kind changes: create sets initial kind; explicit historical_deleted restore→historical; eligible revise from historical→work. All other commands preserve it, all work→historical changes fail, and no transaction may leave a historical kind with an approval/execution row. Command targets and the final head must match; ordinary revision immutability remains intact.

## 5. Display and scope limits

Historical records belong to a clearly labelled **Imported history** group within the single work-list projection (no new tab), excluded from actionable/in-progress and provider-verified success totals. Display “legacy source reported complete” where supported, not “Fload verified live.” Count each permanent ticket once using the same eligibility and deterministic historical-claim/date selector in list/count/cursor paths. Unknown date is explicit; import time is not fabricated occurrence time. Historical_deleted is excluded from customer lists/counts and resolves through an authorized old URL. After adoption, the same ID moves to work and its old claims remain in detail, without a duplicate history item.

This matrix does **not** resolve these rows by assertion:

- Any component with unresolved issued effects, unclear quiescence or unresolved duplicate identity: remains a cutover blocker; do not hide it as historical_deleted or historical complete.
- Missing or open historical content shapes/targets: preserve sources until the relevant owner supplies a strict non-authorizing shape. A new historical purpose is not permission for arbitrary payloads.
- Unproved historical collection membership: retain the separately typed historical set, not an approvable reconstructed package. Fresh collection adoption additionally needs an exact fully populated current member proposal set and atomic child/parent rules. Until that specific matrix is complete, collection adoption returns unsupported_operation; member ticket identity and readable historical group links remain preserved. Do not relax ordinary proposal membership requirements.
- Supersession whose successor cannot be resolved: retain the claim/link ambiguity and block a superseded runtime decision; do not invent a successor or reopen it.

Required acceptance cases: historical-only create→reject commits without an executable proposal; archive/assign of a historical display head; deleted-declined restore preserves declined; reconsideration remains historical until a fresh baseline/proposal commits; concurrent restore/edit/source change; two edits reuse the same key/pins; automatic meaningful-change replacement vs unknown old preimage; no second action at the same review key; every approval/iteration/execution/dependency-completion attempt against a historical head refuses; same-ID adoption emits one attention change and no approval; stale import/replay cannot change an already adopted work ticket. These are design requirements, not executed tests.
