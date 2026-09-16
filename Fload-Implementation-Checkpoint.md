# Implementation checkpoint — paused for documentation

16 September 2026 · FLO-1355 · Source baseline `f0b1af5fc`

The requested deliverable is the complete architecture and documentation packet. Implementation started before that intent was clarified. It is now **paused**, with the uncommitted changes preserved on branch `flo-1355-inbox-reliability`. No implementation PR, merge, production migration, deployment or live provider write has been performed.

The schema explorer now represents the actual proposed repository migrations, including the provider split. It no longer displays the older 25-table standalone design as though that were the current schema. The current draft has **31 physical tables, 497 fields and three relational projections** across `actions`, `apple_ads`, `app_store_connect` and `google_play`.

This is a design and implementation checkpoint. The branch is not ready to merge. A passing focused suite does not establish that all old entrypoints are removed, all production data can migrate, or every product behavior is preserved. The [review resolution](Fload-Review-Resolution.md) supersedes any interpretation of this packet as an approved final implementation. The [entrypoint and ownership plan](Fload-Entrypoint-and-Ownership-Plan.md) maps the unfinished boundaries.

**Evidence boundary:** review findings below were checked by source inspection and by reading retained outputs, without new tests, migrations or provider calls. Retained failing runs document particular historical reproductions; static findings are not newly reproduced failures. The current working-copy fingerprint is `22c54c4352f996d8620b7aa90a8b66b5ca872061c093ba9715703390921f2cbf` (HEAD plus 215 changed/deleted/untracked source entries). Historical test logs are **not bound to this fingerprint**.

## What exists in the prototype

| Area | Implemented in draft code | Important limit |
|---|---|---|
| Storage | Typed relational schema; immutable revisions, membership, approvals, commands, attempts; tenant foreign keys and database guards | Some subtype combinations, tenant references and retention/deletion contracts remain incomplete; no blanket tenant-safety certification. Complete data conversion and old-table removal are unfinished |
| Commands | Version/revision checks, idempotency receipts, atomic batch decisions, server Undo deadline, ownership and shared lifecycle | Remaining callers must all converge; unsupported command/surface errors need a final audit |
| Dispatch | Durable execution obligations; existing BullMQ workers; database recovery scan; claim fencing; uncertainty and provider readback | Full catalog/report/agent handoffs and all recovery policy edges need closure |
| Content | Typed review, listing, request, advisory and Apple Search Ads content; provider-specific contracts | Localization request parity for field selection, overwrite consent and credits is incomplete |
| Review workflows | Durable reply producers, explicit automation policy, exact revision route/tool approvals, external-completion evidence | Catch-up identity diverges from ordinary review creation. Direct generation can charge then return existing text. Rejection/source-change reopening and remaining consumers need closure |
| ASO | Durable listing packages, generation-only localization approval, frozen baselines and App Clip preparation | Old opt-in weekly promo and auto-mode publishing still use separate guarded effect paths. Catalog/backlog/report generation and measurement handoff remain incomplete |
| Ads | Seven current Apple Search Ads operations; typed decimal/ID capture; accepted ticket references | Full producer convergence, historic execution migration and obsolete tests remain to close |
| Inbox | Actions SDK/hooks, durable inbox page, history, owner controls, personal read state and paginated counts | Reader switched while old writers remain. Counts agree mechanically but include parents, children and in-progress work together. Attention policy, visual parity and App Clip preview remain unfinished |
| Attribution | Canonical member/API-key/agent/policy actors and separate acting-for identity | Impersonated web chat uses `chat`, but delegation CHECK allows only `web`/`operator`. The same failure is not established for OAuth MCP, which does not populate impersonation context |
| External channels | Unmapped Slack/Discord senders receive a member-login ticket link; installer identity is not an approver | Direct external approval requires a separately designed verified member mapping |

## Retained test-evidence ledger

The outputs below were inspected during documentation review. They are separate historical runs, not a current full-suite pass. Suites overlap; do not total them into a coverage score. Pass summaries establish that those runs passed, not that their source matches the current working copy or that all scenarios named elsewhere were covered.

| Evidence | Retained result | Meaning and limit |
|---|---|---|
| E1 · Execution + listing integration | 9 passed, 2 files | Bounded historical integration pass; does not establish complete provider recovery or producer convergence |
| E2 · Generation integration | 3 passed, 1 file | Bounded generation/baseline fixtures; no proof of complete metering or every source handoff |
| E3 · Personal read/list/count integration | 5 passed, 1 file | Bounded read/filter/pagination cases; does not decide the parent/child counting product contract |
| E4 · Public MCP tools | 12 passed, 3 files | Bounded client-tool tests; no certification of all authentication/impersonation paths |
| E5 · Web command hook | 4 passed, 1 file | Hook-level tests; not browser end-to-end coverage |
| E6 · Review workstream | 92 unit passes across 4 files; 21 integration passes across 3 files | Aggregate summaries retained. Per-case names are absent from those summaries; coverage description relies on the contemporaneous handover. The catch-up/direct identity mismatch remains despite these passes |
| E7 · Ticket command integration | 1 failed, 7 passed, 1 file | Retained eight-case run is red. It is a different suite from the claimed 22 Core tests |
| E8 · Execution/progress run | 1 failed, 7 passed across 2 files | The retained output is red despite its filename containing “green” |
| E9 · Advisory producer integration | 1 failed, 3 passed, 1 file | Does not substantiate the previous combined advisory + ads eight-pass claim |
| E10 · HTTP regressions | 2 failed, 1 file | Historical reproduction of acceptance waiting for queue enqueue and invalid cursor returning 500 |
| E11 · Full API typecheck | Errors retained | Later partial fixes do not establish a clean final rerun |

**Claims withdrawn as current evidence:** the reported 22-case Core pass and combined eight-case advisory/ads pass cannot be reconstructed from the inspected outputs. The reported seven-case migration coordinator pass and earlier provider/storage totals have not been independently re-established in this review. Retain their historical notes for investigation, but do not present them as a current certification. A red integration log cannot by itself disprove a distinct Core unit run; the missing evidence must be supplied, not inferred either way.

The DDL catalog documents the loaded draft schema and its recorded hashes. Introspection is structural evidence; it does not prove application correctness, complete historical migration or release readiness. The schema explorer remains labeled as the paused draft until revised constraints and their validation exist.

For the next authorized implementation phase, retain suite name, exact command, timestamp, base commit, full uncommitted-source fingerprint, result and output together. Re-run the repository-required checks after fixes. Existing CI discovery covers ordinary API/package tests, but the uncommitted prototype has no current CI result; any standalone storage proof requires its own explicit CI integration.

## Source-confirmed findings and qualifications

| Area | Confirmed present state | Acceptance gate and qualification |
|---|---|---|
| Reader/writer cutover | New inbox reads Actions; old recommendation/orchestrator/catalog paths still write pending work; old routes and synchronous ASA dispatch remain. Weekly promo and low-risk ASO publication retain separate conditional effect paths | Converge or retire all writers before releasing the reader switch. These are prospective release blockers, not evidence of a deployed incident or wholly unguarded old code |
| Review lifecycle | Catch-up keys children by parent/source version, ordinary creation by review identity; lookup refuses duplicate identities. Declined reviews can be selected again. Historical rejection filtering exists in the seeder but is absent from actual generation selection | One cross-producer identity and explicit source-change/rejection policy. Automatic discovery has no declined-ticket reopen path, although human `restore` exists |
| Regeneration and accounting | HTTP generation can perform billed LLM work, then return an existing human-owned ticket's old text. Worker generation separately lacks the billing context needed to meter LLM calls | Existing-draft UI regeneration already uses canonical iteration; the HTTP defect applies to direct or stale/missing-draft-state calls. Make usage/customer charging and accepted output adoption explicit and idempotent |
| Impersonated web chat | Real admin + acting-for member is persisted with `chat`, conflicting with the DB/wire delegation constraint | Align authorized transport and attribution or explicitly refuse before submission. Do not repeat the review's unsupported extension to ordinary OAuth MCP |
| Attention | Accepted lifecycle commands advance both counters. Worker progress also advances ticket/parent counters for verification_due/uncertain/blocked/settled, deduplicating identical phase/result/hold | Define attention triggers and command-conflict semantics. The report overstates this as every worker phase/poll; removing state-version updates blindly could weaken concurrency |
| Counting | Shared list/count predicates include parent and children, plus queued/working/verifying. Partial Undo opens parent decision while displayed collection progress is child-derived | Define root/child/all scope and decision-needed versus in-progress views consistently. Mechanical list/count agreement already exists; product counting semantics and parent decision meaning remain open |

Precise prototype file/line references and the full boundary matrix are in the [entrypoint and ownership plan](Fload-Entrypoint-and-Ownership-Plan.md). Broader storage, recovery, retention and provider findings are tracked in the [review resolution](Fload-Review-Resolution.md).

## Known failures and unvalidated work

Two HTTP regressions have retained failing historical test output; they were not rerun for this review:

1. The route commits approval but waits for a best-effort queue enqueue before returning the receipt. A stalled Redis operation can therefore stall HTTP acceptance. The final handler must return the durable receipt independently of queue availability.
2. An invalid cursor currently produces HTTP 500. Read-target and future-watermark error mapping also needs completion and verification.

The retained full API typecheck reported errors in a generation fixture, optional ASO route authorization contexts and a retired ASO test import. Some subsequent fixes were made, but no clean final full API check was obtained. A previous web typecheck was reported as passing; later changes require another pass. No current complete repository lint, tests, builds, route-authorization inventory or Semaphore validation is established.

Additional required work includes canonical catalog/backlog/report and orchestrator producers; stable migration-to-producer identity convergence; existing rejection suppression import; trustworthy historical approval/receipt treatment; provider baseline/generation permissions and billing parity; App Clip approval preview; final notification/count consumers; and deletion of obsolete authorities after reconciliation.

## Where the code is preserved

The implementation branch is `flo-1355-inbox-reliability`, in the repository’s registered worktree with the same name, on the local Mac mini. It uses its isolated development database and ports. The public artifact contains architecture, schemas and synthetic validation facts, not private machine paths or customer census rows.

No further implementation should be inferred from this documentation publication. The next implementation phase requires authorization and must begin from this checkpoint, the review resolution and the detailed acceptance gates. Source-inspected defects, historical passing runs and proposed remedies must remain separate claims.
