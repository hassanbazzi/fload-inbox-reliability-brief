# Related cleanup, cadence and work-list changes

19 September 2026 · Follow-up C1–C6 · Documentation only; implementation paused

**Product decision confirmed in this session:** limit new suggestions to five items needing client attention per app. Approved passive waiting remains visible and durable outside that attention cap. This changes the earlier proposed unfinished-work count; it does not change approval, lifecycle or delivery authority. Implementation is still paused.

The related changes are now merged. The source confirms two remaining capacity gaps; this plan does not treat the existing cap as an atomic ceiling. The durable-ticket design must preserve the new cadence and presentation while correcting admission.

| Related work | Verified repository status at this inspection | Consequence |
|---|---|---|
| FLO-1437 / [PR 1445](https://github.com/fload-ai/fload-platform/pull/1445) | Merged 2026-09-19 01:20:37 UTC; final branch head `79c4385a18d26df1df8bc857d0dcf383e41a4730`; squash `324b05de256e00e74e2074bd047199f00523f3d2` | Five open tasks per app replaces the monthly allowance. Weekly planning and other top-ups use available capacity, but current admission permits concurrent overshoot and the replacement pass is too broad |
| FLO-1438 / [PR 1446](https://github.com/fload-ai/fload-platform/pull/1446) | Merged 2026-09-19 01:02:13 UTC; squash `560aaeabe6cd08dcf8b931112c91155f67873adc` | Due now, current month, next/future months, with Earlier collapsed; preserve prerequisite-specific check labels |
| FLO-1437 copy follow-up / [PR 1447](https://github.com/fload-ai/fload-platform/pull/1447) | Open at `029fe413d893ffdfeba020539388b032e3898c47` when inspected | Removes stale ten-day-skip wording; must follow the newly selected attention-cap terminology before integration |
| FLO-1436 cleanup / [PR 1444](https://github.com/fload-ai/fload-platform/pull/1444) | Closed unmerged; operational expiry was reported separately and not verified against production | Preserve exact expired status/reason/history and old links. Do not repeat cleanup, resurrect stale proposals or infer provider success |

Local origin/main was `324b05de256e00e74e2074bd047199f00523f3d2` at inspection. This supersedes both the earlier note's open-PR status and the follow-up review's intermediate `9e1f027b`/`560aaeab` checkpoint. A merged commit is not deployment evidence. No production rows were read here; customer names, counts and private operational details remain excluded.

## Cadence and notifications carried forward

The hourly worker sweep now tops up available capacity; weekly planning is not the only refill opportunity. It retains its existing refusal backoff, settings, hourly sweep lease and operational bounds. That sweep lease does not serialize every other admission door. The ten-day monthly-release dedupe was removed, so a recent manual/monthly top-up does not by itself suppress the next refill.

Successful staging calls the in-app announcement path. A channel post is separately requested only by an announcing entry point: the scheduled **or manual** monthly-release/top-up service passes announceToClientChannel=true; report completion derives it from whether the report reaches the customer. Routine sweep/silent regeneration uses the non-announcing default. A pass that stages nothing does not emit the successful-stage announcement. Preserve this split and delivery deduplication in the existing notification owner; do not move notification transport or a new queue authority into Actions.

Source: auto-stage-scheduler.ts:49–62 and its delivery call; monthly-release.ts:176–185; stage-on-completion.ts:509–520 and stageReportWorkOnCompletion. PR 1447 is a copy change, not a capacity fix or deployment proof. Its inspected `atOpenCap > 0` zero-result branch establishes **some** apps are full, not “every app”; mixed full/empty/refused/failed results require truthful wording. The confirmed attention-cap choice also supersedes copy promising five open tasks.

## What the current count actually measures (C6)

At merged `324b05de`, `apps/api/src/services/backlog/open-task-cap.ts` counts pending_action rows with organization_id and **asset_id equality**, status in pending_approval/approved/blocked, deletedAt NULL, and pendingActionInboxVisibilityCondition(). Org-level connector prompts have NULL assetId; the equality filter excludes them from every app, rather than a separate connector-specific rule.

The visibility predicate excludes agent types orchestrator/fio/product and action wake_agent; when the revert surface flag is off it also excludes revert_experiment and aso_revert_listing. Those hidden rows can still be open obligations: aso_revert_listing can be approved by its dedicated route. Visibility is a current product-count rule, not proof that hidden work is complete or safe to discard.

The final Actions admission policy must explicitly name its capacity unit and every included/excluded ticket class: requests, review children, packages, advisory work and derived localizations. A customer task cap may intentionally exclude internal obligations, but their execution, recovery, history and operational counts remain authoritative and discoverable. Do not inherit a legacy hidden-action list as the new lifecycle predicate. The user-facing list and its corresponding counts must share the same eligibility relation; capacity totals with a different scope must be named and documented as such.

## Confirmed target policy: five items needing client attention

This is an organization-shared admission rule, not personal unread state and not an execution concurrency limit. Derive it from canonical workflow plus the typed domain/prerequisite facts; do not store a second mutable needs_attention lifecycle boolean or infer it from free text.

| Current ticket situation | Attention slot | Required behavior |
|---|---|---|
| Actionable proposal awaiting a client decision | Yes | Exact current revision and actor authority; marking read does not free the slot |
| Approved; executing or passively waiting for provider/release progress with no client action available now | No | Keep visible as in progress/waiting, preserve approval, attempts and recovery |
| Client must now fix a prerequisite, decide a retry, edit or resolve a failure | Yes | Name the actual client action and owner, irrespective of whether the prior decision was approved |
| Fload/operator owns the next recovery step | No client slot | Surface to its responsible operator, retain honest status for the customer |
| Historical or completed work with no current decision | No | Preserve history and links; do not fabricate execution success |

“Editable release missing” alone cannot select a row of this table. If the client must create/upload a release, that is client-owned action. If a valid submitted release is processing and there is no client action now, it is passive waiting. Domain/provider adapters supply closed, typed prerequisite facts; Actions owns workflow and consumes the provider-neutral next-action contract. Core gets no Apple-specific status or heuristic parser. The exact existing hold/owner variants must be reconciled in the remaining matrix; no unreviewed flag, table or new command is introduced here.

Example: two proposals need a decision and three approved tasks wait passively. A top-up may admit three proposals: **five attention items, eight unfinished tickets**. List/count endpoints expose the same canonical relation and name these scopes explicitly; eight total and five needing attention are different truthful measures, not an accidental mismatch. Future placement and snooze do not silently manufacture spare capacity; their effect must follow the same explicit actionability/date contract. Personal read/unread has no effect.

The five-item bound applies to **admitting new discretionary work**. It cannot prevent an existing approved task from developing an urgent blocker, an Undo from restoring a decision, or a known failure from appearing. Record and surface those changes even if attention temporarily exceeds five; pause additional suggestions until it drops below the limit. Never suppress a blocker or block evidence capture to maintain a cosmetic count. This exception distinguishes truthful existing-work transitions from avoidable concurrent overshoot by new admissions.

No second numeric in-flight cap is selected. Approved waiting is still monitored and retains its owner, due/recovery obligations and stale-work visibility. Dependency groups/parent-child counting remain an explicit unit-design gate; sharing a prerequisite does not by itself prove multiple tickets are the same work.

## Confirmed capacity gaps in the merged source (C1/C2)

| Gap | Source evidence at `324b05de` | Consequence |
|---|---|---|
| Count, then stage in separate operations | open-task-cap.ts:39–51 explicitly accepts overshoot; stage-on-completion.ts:238–247 supplies a count snapshot; stage-ready-work.ts:284–294 computes headroom from it | With four tasks, two independent passes can each admit one and leave six. The snapshot is a planning hint, not an atomic ceiling |
| Re-check treats the app as empty and loses its target restriction | stage-blocker-resume.ts:292–330 clears backoff for named IDs but calls the asset-wide delivery pass without those IDs; stage-on-completion.ts:240–247 sets openTasks=0 for exempt | The pass has headroom five and may select unrelated due rows. A one-card replacement can grow the list; it is not guaranteed one-for-one |

These gaps were also present at reviewed heads `34cd3526` and `9e1f027b`; the final comment acknowledges C1 rather than fixing it. Source establishes the possible interleavings, not their frequency in production. In the C2 example, five existing cards plus five selected rows can reach ten if none replaces a counted card; replacing the one counted blocker yields nine. The exact total depends on the selected rows and actual closures. Nor is five successful stages an upper bound on all new cards: stage-ready-work.ts:327–374 stops after successful stages, while refusals can subsequently raise new blocked cards (stage-on-completion.ts:450–458). Failed residue can return to blocked. The durable policy must account for these transitions and preserve known problems; it cannot claim a fixed overshoot bound from the successful-stage cap alone.

The review's blanket “no locks or transactions” claim is too broad. backlog.service.ts already uses per-(asset,locale,field) transaction locks and a staging transaction. They protect overlapping field claims, not shared app capacity. It also prepares provider/AI content before that transaction (`prepareStructuredStageCandidate`, lines 1782–1796). A strict cap does not require holding a database transaction across that preparation.

## Required short admission transaction

1. Prepare provider observations and any draft outside the admission transaction. Preparation alone grants no slot or delivery authority; revalidate exact source/content pins at commit. An early count may avoid unnecessary work but is not authoritative.
2. Enter the canonical idempotent command transaction with one common per-(organization, app) database guard. An existing asset-row FOR UPDATE lock is a candidate without a new capacity table; an advisory transaction lock is an alternative only with a namespaced, unambiguous key convention. Integrate the chosen guard into the existing global lock order for **all** relevant writers. No independently acquired Redis/queue lock or transaction on another connection substitutes for it. Re-count and writes must use the same transaction handle; the current global-db count helper is not automatically transaction-aware.
3. After acquiring the guard, re-read the authoritative count in a fresh READ COMMITTED statement (or use an explicitly tested equivalent isolation/retry protocol). Lock/revalidate the exact target and replacement rows, then compute the **actual net change** to counted work. All discretionary admissions increasing that count must participate; serializing only one staging entry point is insufficient. Existing-work blocker/Undo/progress transitions participate in the same short guard/lock order so subsequent admissions see them, but cannot be refused for capacity; they persist truthfully under the defined exception.
4. In that same short transaction persist the accepted command/receipt, admitted ticket or same-ID transition, and any exact replacement closure. Require available capacity only for new discretionary positive-delta admissions. Replay and proved zero/negative-delta replacements need no new slot. Compute attention delta from the canonical before/after classification, never identity alone: the same ticket can move from passive waiting to client action. Existing-work blocker/Undo/progress changes follow the explicit exception even with a positive delta above five. Rollback accepts neither the work nor the slot. Never trust a caller-supplied old count.
5. Commit before queue notification, provider I/O or further AI work. A refused prepared proposal remains unattached/non-authorizing under its domain's retention rules. Generation usage remains honestly recorded even when concurrent admission is later refused. If the product also promises no speculative generation charges, a separate reviewed reservation/lifecycle contract is needed; this note does not add one by implication.

For example: both passes may prepare while the app has four tasks. The first transaction locks, re-counts four and commits the fifth. The second acquires the same guard, sees five and refuses new admission. Preparation may be concurrent; accepted new work is serialized at commit.

The existing typed command matrix and lock-order integration still need implementation design and concurrency tests. This requirement adds no new table, generic job authority or open payload field.

## Replacement must mean the exact work being replaced

Restrict every affected delivery phase to the authorized backlogItemIds, including create-locale conversion/generation, refusal/blocker creation and final staging. A cap equal to the number of IDs limits quantity, **not membership**; it can still select unrelated work. A missing or stale item must not cause selection of the next unrelated row.

At commit, derive replacement credit only from unique, currently counted rows in the same organization/app that the transaction actually closes for those exact targets. Do not subtract requested ID count, missing/deleted/hidden/already-closed cards or a closure already counted in the fresh total. Preserve the existing atomic replacement link: backlog.service.ts:1134–1138 supersedes the specific blocker alongside creating its replacement. Carry that integrity into the capacity check. The long-term model unblocks the same permanent ticket whenever it is the same work. Review catch-up needs its own admission seam: backlog.service.ts:1632 seeds its real card before the later blocker-close transaction at 1645–1674, and the batch path does likewise at 2008–2031. Do not describe that whole operation as already atomic. Move the counted mutation into the protected commit boundary while retaining external preparation outside it. Blocker creation/refresh and failed-to-blocked transitions also need the explicit new-work versus existing-work policy; they cannot silently evade admission or be discarded.

Remove the semantic blanket exemption from the durable contract: it cannot zero the app count. A legitimate replacement and unrelated new admission are separately identified operations, even when planned in one pass.

## Admission is separate from delivery truth

The final policy counts one admitted customer task once, deduplicates same-work aliases and explicitly decides package/child units. Do not count a parent and the same surfaced child twice or hide unlimited independent work behind one package. Collapsing a group, marking read or archiving presentation cannot create capacity for unresolved counted work.

Already approved delivery, uncertain-effect readback, required recovery and provider verification never wait for a suggestion slot. Under the newly confirmed policy, approval followed by passive waiting releases its attention slot, while a client-owned next action still consumes one. Both remain unfinished work; neither becomes completed merely to change the count. Historical/deleted/expired non-actionable facts are not new suggestions, but expiry alone cannot prove there is no outstanding provider effect.

## UI and scheduling

Month grouping changes placement only. Earlier remains accessible; moving work there does not finish it or excuse a hidden actionable count. Pagination/horizons must remain navigable and agree with counts. The old 365-day horizon is not a migration conservation rule. The merged UI uses UTC month keys; the final list/cursor contract must align calendar/asOf semantics explicitly.

Approval pins exact content and may be followed by waiting for a release. Re-check inspects a named prerequisite. The current blocker endpoint only re-tests/re-stages; its check label must not imply approval. The durable design retains separate typed commands and actors. Native wording belongs to domain/provider presentation, not a Core Apple enum or free-text parsing authority.

No new history tab is requested. The matrix's undecided placement of non-actionable imported history must fit the single list/month/Earlier behavior and never imply verified provider success.

## Updated migration checkpoint (C3)

The 212-column census stays pinned to `e2cc156994855e401a83399fbb4c3d7be5194875`. A read-only diff through merged `324b05de` shows no packages/database changes, so the declared source-column inventory still applies. **The writer/contract pin does not remain current:** PR 1445 changes backlog admission, ASO/report delivery, schedules, the Mission Control route and `packages/shared-types/src/contracts/backlog.ts`. The earlier “writers unchanged” conclusion applied only through the web-only FLO-1438 merge.

Before integration, re-pin the exact merged commit again and review every changed producer and wire contract. Before migration rehearsal, take a fresh authoritative source census after reported cleanup/report runs, or stop/drain those writers under the cutover fence. Report regeneration can revise/retire backlog rows, reuse cards and create children. Stale importer retries must fail source revalidation rather than restore retired work. Preserve reasons and proved actors; the supplied conversation is not actor or transaction proof.

No cleanup or report regeneration is repeated here. Already-audited report scope remains with the separate operation. Missing approval/effect evidence still requires whole-component recovery even for expired rows.

Required cases: concurrent top-ups at four; every producer using the same guard; replay/rollback; same-ticket unblock at/above five; one proved replacement with unrelated due rows; missing/hidden/already-closed replacement with no capacity credit; exact re-check scope through conversion; passive approved waiting excluded from attention but counted as unfinished; client-owned release action included; waiting→client action and Undo surfaced above five; uncertain recovery while full; package/child deduplication; Earlier discoverability; expiry followed by import retry; report regeneration changing component closure. These are acceptance requirements, not executed runtime tests.

[Current contracts](Fload-Inbox-R3-Destination-Contracts-v2.md) · [Historical matrix](Fload-Inbox-R3-Historical-Ticket-Matrix.md) · [Follow-up disposition](Fload-Inbox-R3-Destination-Followup-Resolution.md) · [Visual summary](ownership-overview.html#coordination-heading)
