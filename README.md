# Fload inbox reliability — architecture review packet

**Latest: destination follow-up and merged-work coordination · 19 September 2026.** [Visual walkthrough](ownership-overview.html#coordination-heading) · [C1–C6 disposition](Fload-Inbox-R3-Destination-Followup-Resolution.md) · [Exact admission/replacement contract](Fload-Inbox-R3-Parallel-Work-Coordination.md) · [Historical capture matrix](Fload-Inbox-R3-Historical-Ticket-Matrix.md).

Product decision: five items needing client attention; approved passive waiting remains visible outside that count. Both parallel PRs are merged. Their current cap still permits concurrent overshoot, and blocker re-checks can select unrelated rows. The plan now specifies short atomic admission, exact replacement scope, hourly refills and separate channel announcements. Existing failures still surface above the attention cap; new suggestions pause. Historical declined capture requires independently recovered comparable evidence; captures do not create unread churn. Source columns are unchanged, but the writer/contract census must be refreshed. Documentation only; platform fixes and runtime validation remain ahead.

---

**Latest: destination v2 review follow-up · 19 September 2026.** [Visual overview](ownership-overview.html#destination-heading) · [Review disposition](Fload-Inbox-R3-Destination-v2-Review-Resolution.md) · [Current contracts](Fload-Inbox-R3-Destination-Contracts-v2.md) · [Historical-ticket matrix](Fload-Inbox-R3-Historical-Ticket-Matrix.md) · [Parallel cap/UI/cleanup coordination](Fload-Inbox-R3-Parallel-Work-Coordination.md).

Canonical baseline capture is allowed without reopening history; restore intent is explicit; adoption uses existing revision links. Source claims about archives and handoff writers are corrected. Standing-cap/month grouping changes and fresh-census requirements are recorded. These remain proposed contracts: no application change, final table count, migration or runtime proof is claimed.

---


**Latest: destination contracts v2 · 19 September 2026.** [Visual summary](ownership-overview.html#destination-heading) · [Corrected concrete contracts](Fload-Inbox-R3-Destination-Contracts-v2.md) · [Historical-ticket matrix](Fload-Inbox-R3-Historical-Ticket-Matrix.md) · [Review corrections](Fload-Inbox-R3-Destination-Review-Resolution.md).

Provider aliases stay outside Core; repeated rejections, exact content and actor provenance are preserved; replay and schedule ordering are corrected. All 13 keyword-context fields and the successful release-verification shape are mapped. The new companion proposes safe same-ID historical→fresh-work transitions using existing commands. B9–B13, consolidated DDL, data rehearsal and runtime proof remain open. Implementation is paused; no final table count is approved.

---


**Latest: R3 ledger v2 review follow-up · 19 September 2026.** [Review disposition](Fload-Inbox-R3-v2-Review-Resolution.md) · [Current ledger](Fload-Inbox-R3-Conservation-Ledger-v2.md) · [Visual walkthrough](ownership-overview.html#conservation-heading) · [Source types and identity evidence](Fload-Inbox-R3-Source-Type-Inventory.md).

The independent review confirms the eight main corrections. Explicit review-sync fencing, missing-card holds, pin mismatch handling, partial policy blocking and per-store identity rules are now included. Correlation-based transaction proof and historical manual-authorship reopening were not adopted. Next: concrete destination contracts for B9–B13; no final schema/table count or runtime proof is claimed. Implementation remains paused.

---


**Latest: R3 conservation ledger corrected · 19 September 2026.** [Visual walkthrough](ownership-overview.html#conservation-heading) · [Corrected 212-column ledger](Fload-Inbox-R3-Conservation-Ledger-v2.md) · [Actual source types](Fload-Inbox-R3-Source-Type-Inventory.md) · [What changed and what remains](Fload-Inbox-R3-Ledger-Review-Resolution.md).

All 212 source column names are covered; exact destination schemas and migration proof remain open. Evidence, actors, retry, aliases, personal notes, localization facts, suppression and domain-retirement rules have been corrected. No final table count is approved. Ownership v6 remains accepted; platform implementation is paused.

---

## Previous checkpoints


**Latest: R2/R3 v2 review confirmed · six clarifications applied.** [Review disposition and next deliverable](Fload-Inbox-R2-R3-v2-Review-Resolution.md) · [Current v2](Fload-Inbox-R2-R3-Schema-Design-v2.md) · [Visual overview](ownership-overview.html). Next: the field/relationship conservation ledger. Ownership v6 stays accepted; full codecs, destination schemas, DDL and migration proof remain open. Implementation is paused.

**Latest: R2/R3 corrected draft · 18 September 2026.** [Visual summary](ownership-overview.html) · [Corrected evidence and migration rules](Fload-Inbox-R2-R3-Schema-Design-v2.md) · [All 212 source fields](Fload-Inbox-R3-Source-Fields.md) · [Review findings and corrections](Fload-Inbox-R2-R3-Review-Resolution.md). Ownership v6 remains accepted. Exact destination mappings, codecs, consolidated DDL and runtime/migration proof remain open; implementation is paused.


**Latest: ownership review resolved · v6 · 18 September 2026.** [Open the new visual comparison](https://hassanbazzi.github.io/fload-inbox-reliability-brief/ownership-overview.html): original inbox or v15 → new ownership design, clickable module map, selected concrete fields and three lifecycle walkthroughs. [Detailed v6 proposal](Fload-Inbox-Ownership-Design-v6.md) · [Review closure and remaining work](Fload-Inbox-Ownership-v6-Review-Closure.md).

The independent v6 review closes N1–N4 and C1–C4 with no actionable findings. V6 remains the ownership design; no new numbered draft is needed for this status update.

Actions owns workflow; domains own content; providers own native contracts; Usage owns settlement. V6 preserves the accepted v5 routing and early-offer rules, makes the NULL-route scan branch explicit, and fixes later expansion to the original plan’s operation versions. A newer worker cannot silently upgrade an approved plan; ordinary supported recovery stays independent of whole-plan support. No tables, columns or enum values are added. **Implementation is paused. R2/R3, complete consolidated DDL and runtime/migration proof remain open.** The older explorer is preserved for comparison; it is not the new schema.

---

**Earlier v15 checkpoint.** [Open the simple visual summary](https://hassanbazzi.github.io/fload-inbox-reliability-brief/summary.html) for a team walkthrough, or [read the corrected v15 design](Fload-Inbox-Revised-Design-v15.md) for exact field contracts and transaction rules. [Reviewer handover](Fload-Reviewer-Relay.md) · [What the v14 review changed](Fload-Inbox-v14-Review-Resolution.md).

V15 gives the final protected cleanup read one fixed grace rule on either side of the ordinary deadline. Up to five ordinary starts plus one protected start preserve the same six-start budget; unused ordinary slots never become extra protected retries. The accepted Scheduled presentation and history rules remain. No stored fields, enum values or tables are added. Its revised scope is **28 Actions relations + two new Usage relations + one modified existing Usage relation = 31 touched relations**, not 31 newly added tables. The field explorer preserves the earlier prototype; application implementation remains paused.

---

The following supporting packet and historical schema describe the earlier review checkpoint. V15 takes precedence where it changes a contract.

[Open the visual artifact](https://hassanbazzi.github.io/fload-inbox-reliability-brief/)

Updated 16 September 2026 · FLO-1355 · Repository baseline `f0b1af5fc5925d818be7d9b02b42b1fc54556ecc`.

**Documentation is the current deliverable. Implementation is paused and preserved locally.** This packet contains the actual draft schema, the complete delivery plan, review findings, qualified test evidence and explicit remaining gates. No platform implementation PR or production deployment has been made.

## Independent review update

**Revise the architecture before implementation resumes.** [Review resolution R01–R12](Fload-Review-Resolution.md) records confirmed blockers, corrections, proposed remedies and acceptance proof. [Reviewer relay brief](Fload-Reviewer-Relay.md) is ready to forward to another AI. The actual DDL and catalog remain unchanged; they show the paused draft, not a completed correction.

## Start here

1. [End-to-end specification and team walkthrough](Fload-Inbox-End-to-End-Specification.md)
2. [Actual fields, keys and closed values](Fload-Inbox-Current-Fields.md)
3. [Exact draft SQL and guards](Fload-Inbox-Current-Schema.sql)
4. [Fload / provider ownership](Fload-Provider-Boundary-Review.md)
5. [All entrypoints, actors and permissions](Fload-Entrypoint-and-Ownership-Plan.md)
6. [Execution, queues, provider readback and cutover](Fload-Execution-and-Cutover-Plan.md)
7. [Migration, preservation and cleanup](Fload-Migration-and-Data-Plan.md)
8. [Implementation checkpoint and validation limits](Fload-Implementation-Checkpoint.md)

## Actual proposed schema

**Current paused draft: 31 physical tables · 497 columns · three relational views · four PostgreSQL schemas.** This is not a final table-count target. Advisory/request subtype constraints, referent retention, tenant invariants and constraint-preserving consolidation require another design pass. No JSON/JSONB, arrays or arbitrary property/value columns in the proposed model.

The [catalog](current-schema-catalog.json) is exported from the exact repository migrations applied to an isolated synthetic PostgreSQL database. [Validation metadata](repository-validation-result.json) records their SHA-256 hashes. The catalog file uses JSON to distribute schema metadata in the browser; it is not JSON database storage and contains no customer rows.

The SQL bundle contains [0146](0146_durable_actions.sql) and [0147](0147_action_progress.sql) verbatim. It requires the existing Fload schema and preceding repository migrations. It is not a standalone database bootstrap or a production-ready cutover script. To reproduce the migration validation, use the repository's isolated test-database workflow and full migration chain; the older stub-based design harness is not current proof.

The six additional tables compared with the earlier 25-table design separate two provider listing contracts, one ASC upload-step contract and three native receipt contracts. Their tradeoffs are explicit. Historical evidence without provable approval still needs a final typed retention representation before old authorities can be removed.

## What changed in this review response

- Added a public disposition of the independent review, R01–R12 acceptance gates and a relay brief for the next AI.
- Updated all current plans for bounded recovery, same-ticket reopening, lost confirmation, queue promotion, strict subtype constraints, retention/erasure, tenant roles and coordinated cutover.
- Corrected overstated provider, clock, cursor, attention and CI claims without dismissing the confirmed blockers.
- Replaced unsupported green-test summaries with qualified retained evidence and reproducibility requirements.
- Kept the actual 31-table catalog and exact migrations unchanged for honest comparison. No application code, new migration, production action or main refresh was performed for this response.

Earlier source audits remain available as dated evidence. The current documents above supersede their schema proposals. Private customer records and operational census outputs are excluded from this repository.
