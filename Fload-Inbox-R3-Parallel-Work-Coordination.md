# Related cleanup, cadence and work-list changes

19 September 2026 · Coordination note for FLO-1355 · Documentation only

The other work changes the product rules and the source population that the migration must preserve. It does not replace the durable-ticket design. This note records the boundary so the two efforts do not undo each other.

| Related work | Verified status at this inspection | Consequence for the reliability design |
|---|---|---|
| FLO-1437 / PR 1445 | Open at 34cd3526d8d1a9731d3d82374519ea9e5cd52eb5; standing-cap and weekly-top-up changes in progress | Five open tasks per app is a standing capacity rule, not a monthly allowance. Weekly planning, due-work safety checks and manual top-ups must use the same admission policy |
| FLO-1438 / PR 1446 | Open at 35e3c1fcd0a1f089af9d65ea40338d9139ac9089; Mission Control UI changes | Due now, current month, next/future months, with Earlier collapsed. Keep old work discoverable and list/count predicates consistent |
| FLO-1436 cleanup / PR 1444 | PR closed unmerged; operational expiry was reported in the supplied conversation, not independently verified against production | Preserve exact expired status/reason/history and old links. Never resurrect expired proposals from stale source copies or interpret expiry as provider success |

These are inspected branch/issue states, not a claim of deployment. No production rows were read here. Customer identities, counts and private operational details from the supplied conversation are intentionally omitted from this public artifact.

## Standing cap belongs to admission, not delivery truth

The current cap proposal counts visible, app-scoped pending_action rows in pending_approval/approved/blocked, excludes deleted rows, and excludes organization-wide connector prompts from every app's count. That is the **existing-source predicate**, not the final Actions predicate: durable requests, review children, packages, advisories and derived localizations must have explicit corresponding inclusion rules.

The final domain policy must define one capacity unit per admitted customer task, deduplicate all same-work aliases, and state package/child counting explicitly. Collapsing a UI group, marking read or archiving presentation cannot create capacity for unresolved work. Do not count a parent and the same surfaced child twice, and do not hide unlimited independent child work behind one package to evade the policy. These are required admission fixtures, not a claim that the open PR already implements the durable model.

Count and admission serialize per organization/app across weekly planning, manual staging, agents, chat and retries. A read of open count followed by independent inserts is not by itself a concurrency proof. Reusing or unblocking the **same** ticket consumes no new slot. If migration temporarily replaces a blocker with a real ticket, bind the old and new identities and apply the exact net slot delta atomically; do not treat the entire app as empty. The inspected PR has an explicit exempt replacement branch, so verify its narrow one-for-one semantics when integrating.

Already approved delivery, uncertain-effect readback, required recovery and provider verification are never held hostage by a full suggestion cap. Approval waiting for an editable release remains open work; approving does not free its slot. Historical/deleted/expired non-actionable facts do not become fresh open tasks. The final count query must share canonical identity/lifecycle eligibility with the list; personal read state, capped fetches and monthly buckets are not its authority.

## UI intent and scheduling

The new month grouping is placement only: moving an item into Earlier does not finish it, change its deadline or excuse a hidden actionable count. Any horizon/pagination limit must remain navigable and agree with counts; the old 365-day inbox horizon is not a migration or conservation rule. The inspected UI uses UTC month keys; the final list/cursor contract must explicitly align its calendar/asOf basis with schedule semantics rather than silently mixing browser, UTC and organization calendars.

Approval pins exact content and may be followed by waiting for a release. Re-check inspects a named prerequisite; it is not a substitute approval. The UI branch correctly renames the legacy blocker button as a check because its current endpoint only re-tests/re-stages. The durable design must retain separate typed approve and re-check commands and their actors; native prerequisite wording belongs to domain/provider presentation, not a Core Apple enum or free-text parsing rule.

No new history tab is requested. Placement of non-actionable imported history remains the bounded choice documented in the historical-ticket matrix; it must fit the single-list/month/Earlier behavior, remain labelled as historical source claims, and never count as verified provider success.

## Cleanup and report regeneration are migration inputs

The separate conversation reports expiry of old ad/product proposals and plans report regeneration for already-audited apps. This task does not repeat those operations or broaden their scope. An expired legacy row preserves a source claim; missing approval/effect evidence still requires the ordinary whole-component recovery gate. Age or an operational status change cannot prove that no provider request was issued.

Before migration rehearsal, re-pin the merged writer revision and take a fresh authoritative census **after** the cleanup/report runs, or explicitly stop/drain those writers under the cutover fence. Regeneration may revise backlog, archive absent report items, reuse cards and create children. A stale snapshot must fail source revalidation; it must not restore retired work or erase the new plan. Preserve original reasons and actors when known; never manufacture an actor from NULL fields or from this conversation.

Required integration cases: two simultaneous top-ups; same-ticket unblock at cap; one-for-one replacement at cap; approval waiting for release still counted; uncertain work recovery while full; review/package child visibility and deduplication; previous-month actionable work discoverability; expiry followed by importer retry; report regeneration changing component closure; already-audited report scope retained. These are requirements, not executed tests.

[Current destination contracts](Fload-Inbox-R3-Destination-Contracts-v2.md) · [Historical-ticket matrix](Fload-Inbox-R3-Historical-Ticket-Matrix.md) · [Visual summary](ownership-overview.html#destination-heading)
