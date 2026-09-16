# Implementation checkpoint — paused for documentation

16 September 2026 · FLO-1355 · Source baseline `f0b1af5fc`

The requested deliverable is the complete architecture and documentation packet. Implementation started before that intent was clarified. It is now **paused**, with the uncommitted changes preserved on branch `flo-1355-inbox-reliability`. No implementation PR, merge, production migration, deployment or live provider write has been performed.

The schema explorer now represents the actual proposed repository migrations, including the provider split. It no longer displays the older 25-table standalone design as though that were the current schema. The current draft has **31 physical tables, 497 fields and three relational projections** across `actions`, `apple_ads`, `app_store_connect` and `google_play`.

This is a design and implementation checkpoint. The branch is not ready to merge. A passing focused suite does not establish that all old entrypoints are removed, all production data can migrate, or every product behavior is preserved.

## What exists in the prototype

| Area | Implemented in draft code | Important limit |
|---|---|---|
| Storage | Closed relational schema; immutable revisions, membership, approvals, commands, attempts; tenant-safe foreign keys and database guards | Complete production data conversion and removal of old tables are unfinished |
| Commands | Version/revision checks, idempotency receipts, atomic batch decisions, server Undo deadline, ownership and shared lifecycle | Remaining callers must all converge; unsupported command/surface errors need a final audit |
| Dispatch | Durable execution obligations; existing BullMQ workers; database recovery scan; claim fencing; uncertainty and provider readback | Full catalog/report/agent handoffs and all recovery policy edges need closure |
| Content | Typed review, listing, request, advisory and Apple Search Ads content; provider-specific contracts | Localization request parity for field selection, overwrite consent and credits is incomplete |
| Review workflows | Durable reply producers, explicit automation policy, exact revision route/tool approvals, external-completion evidence | Final statistics/tool edits and retired-suite replacements were not all validated |
| ASO | Durable listing packages, generation-only localization approval, frozen baselines and App Clip preparation | Catalog/backlog/report localization generation and experiment measurement handoff remain incomplete |
| Ads | Seven current Apple Search Ads operations; typed decimal/ID capture; accepted ticket references | Full producer convergence, historic execution migration and obsolete tests remain to close |
| Inbox | Actions SDK/hooks, durable inbox page, history, owner controls, personal read state and paginated counts | Visual/product parity checks, old code removal and App Clip media preview are unfinished |
| External channels | Unmapped Slack/Discord senders receive a member-login ticket link; installer identity is not an approver | Direct external approval requires a separately designed verified member mapping |

## Focused evidence already obtained

These results describe named test runs, not a combined full-suite pass. Suites overlap and should not be added into a single coverage number.

| Proof | Latest observed result | What it establishes |
|---|---|---|
| Core ticket commands | 22 passing tests | Atomic command behavior including stale approvals, external resolution and failed-generation reopening |
| Execution + listing integration | 9 passing tests | Concurrent execution, intent before I/O, native readback after confirmation crash, source-review change refusal, stable listing packages and generation-only approvals |
| Generation integration | 3 passing tests | Permanent identity, committed output recovery and atomic provider-baseline/proposal persistence |
| Personal read/list/count integration | 5 passing tests | Read isolation, organization-wide work under app filtering, uncapped pagination and sub-millisecond cursor ordering |
| Advisory + ads integration | 8 passing tests | Stable advisory recurrence and durable Apple Ads producer behavior |
| Review integration | 21 passing tests in the last completed review run | Reply producers, route decisions, catch-up handoff and external evidence in the tested cases |
| Migration coordinator integration | 7 passing tests | Paged source processing, a 251-source case beyond former caps and receipt/link retention for supported inputs |
| Public MCP tools | 12 passing tests | Exact pins, unchanged idempotency key on retry, honest conflict responses and server pagination |
| Web command hook | 4 passing tests | Immediate submission, transport uncertainty, safe identical retry and accepted-response refresh failure |
| Provider/schema focused tests | Multiple named unit suites passed; storage proof previously passed 87 cases plus contention checks | See the specialized plans for precise scope; later fixture changes do not inherit earlier pass claims |
| Exact DDL catalog | Repository migration hashes matched the isolated test database | Every field, constraint, index and view in the explorer came from the loaded migration schema |

## Known failures and unvalidated work

Two new HTTP regressions were reproduced and left failing when implementation was paused:

1. The route commits approval but waits for a best-effort queue enqueue before returning the receipt. A stalled Redis operation can therefore stall HTTP acceptance. The final handler must return the durable receipt independently of queue availability.
2. An invalid cursor currently produces HTTP 500. Read-target and future-watermark error mapping also needs completion and verification.

The last full API typecheck reported errors in a generation fixture, optional ASO route authorization contexts and a retired ASO test import. Some subsequent fixes were made, but no clean final full API check was obtained. A previous web typecheck passed; later changes require another pass. Full repository lint, tests, builds, route-authorization inventory and Semaphore validation have not been completed.

Additional required work includes canonical catalog/backlog/report and orchestrator producers; stable migration-to-producer identity convergence; existing rejection suppression import; trustworthy historical approval/receipt treatment; provider baseline/generation permissions and billing parity; App Clip approval preview; final notification/count consumers; and deletion of obsolete authorities after reconciliation.

## Where the code is preserved

The implementation branch is `flo-1355-inbox-reliability`, in the repository’s registered worktree with the same name, on the local Mac mini. It uses its isolated development database and ports. The public artifact contains architecture, schemas and synthetic validation facts, not private machine paths or customer census rows.

No further implementation should be inferred from this documentation publication. The next implementation phase must begin from this checkpoint and the acceptance gates in the three detailed plans.
