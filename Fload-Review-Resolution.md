# FLO-1355 — independent review response and next design gates

> **17 September update:** [Corrected design v7](Fload-Inbox-Revised-Design-v7.md) now defines the reviewed execution, command-history and Usage contracts. Start with the [simple visual summary](summary.html). This supporting document preserves the wider inventory and earlier review evidence; v7 takes precedence where its contracts change these proposals. Implementation and migration validation remain open.

16 September 2026 · Review of baseline `f0b1af5fc` plus the paused local prototype.

**Disposition: retain the lifecycle foundation; revise the architecture before implementation resumes.** This update changes documentation, not application code. Source inspection confirms several release blockers. It does not reproduce every review finding at runtime, establish a green branch, or demonstrate a production incident.

[Visual review](https://hassanbazzi.github.io/fload-inbox-reliability-brief/#review) · [Specification](Fload-Inbox-End-to-End-Specification.md) · [Evidence checkpoint](Fload-Implementation-Checkpoint.md) · [Reviewer relay brief](Fload-Reviewer-Relay.md)

## What remains sound

Permanent organization-owned tickets, immutable revisions, exact approval pins, revisioned collection membership, personal attention separate from workflow, attributable commands, and durable execution independent of queue transport remain the foundation. Provider acknowledgement, verified editable content, verified live content and measurement remain different facts.

The actual schema explorer still shows **31 tables / 497 columns / three views / four namespaces** from the unchanged draft migrations. Those numbers describe the prototype, not an approved final table count. Applying DDL successfully does not prove its invariants, safe migration sequencing, or application readiness.

## Required changes and proof

| ID | Verified issue / architectural gap | Required design decision | Acceptance evidence before release |
|---|---|---|---|
| R01 | Readback and incomplete-plan branches can reschedule indefinitely; late evidence cannot always reconstruct the next plan | Durable observation budgets, backoff, explicit waiting/hold reasons, and a deterministic continuation path; certainty remains separate from scheduling | Unsupported readback, repeated mismatch, late acknowledgement and incomplete App Clip plan stop automatic looping without inventing failure or completion |
| R02 | Definitive permanent publication rejection cannot return to editable work through the current execution lifecycle | Resolve all issued effects, settle the old execution, then explicitly reopen the same ticket without restoring old approval | Permanent rejection → attributed restore → new revision → new approval; partial successes retained; unresolved writes prevent unsafe reopening/replay |
| R03 | Receipt persistence can fail after provider success; App Clip reservation recovery relies on a missing prior receipt | Retry persistence of the captured native outcome, deduplicate ambiguous commits, accept sufficient typed readback evidence to reconstruct a reservation safely | Provider success then DB failure/process loss; exact reservation recovered once; stale completion cannot overwrite current state; provider mutation never retried just to save a receipt |
| R04 | Re-adding the same delayed BullMQ job ID does not promote that job | Reconcile SQL due obligations with actual delayed/active/completed queue states; promote overdue jobs safely and keep SQL as authority | Delayed duplicate, lost enqueue, active-job race and worker restart; no lost obligation and no duplicate provider effect |
| R05 | Schema constraints allow invalid advisory/request field combinations; some table splits have unproven value | Required/optional/forbidden matrix per closed subtype; justify every relation by key, grain, lifetime and integrity constraints | Wire and DB tests reject impossible variants; concrete comparison of receipt and listing-contract consolidations; no JSON, serialized property bags or arbitrary field names |
| R06 | Existing resource deletion conflicts with new immutable history FKs | Per-reference retention and erasure matrix, with identity snapshots/tombstones and precisely allowed referent-deletion updates | Connector disconnect, integration uninstall, run retention, user/organization erasure and asset history paths; approval/receipt conservation without silent cascades |
| R07 | Migration sets session search_path; some tenant references lack ownership checks; actual deployed role behavior is unverified | Fully qualified migration DDL; explicit tenant-scoped app and limited cross-organization worker roles; close missing reference constraints | Full real migration chain plus sentinel migration on the same connection; cross-tenant API-key/run/connector references rejected; role tests exercise recovery, resource locks and erasure |
| R08 | Actions readers coexist with old producers/direct writers; catch-up and ordinary review work use different identity paths | One durable identity rule, explicit changed-source/rejection policy, one coordinated writer/reader cutover and complete producer inventory | Same review across producer races/batches resolves once; declined work obeys policy; all entrypoints create/command Actions; old dispatch is fenced before cleanup |
| R09 | Worker generation lacks billing context; generation HTTP path can charge while returning existing human-owned text; impersonated web chat violates DB actor shape | Idempotent accounting for actual computation/output adoption; explicit generation refusal or real revision adoption; aligned actor/delegation/channel contracts | Failed generation and crash accounting; existing-ticket generation; human-edit race; real admin and delegated member retained for web chat |
| R10 | Parent and child rows are counted without a selected product unit; in-progress work enters needs_attention | Explicit list scope and counting unit; separate human decisions from processing; define meaningful attention events and concurrency versions | Parent/standalone/child views with identical list/count scope; no hidden actionable child; no repeated poll noise; stale approval remains rejected |
| R11 | Error classification and read-model cost need evidence rather than generic fixes | Closed application conflict codes, provider-specific retry reasons, documented text equivalence and measured query plans | Cursor/read conflicts produce typed responses; unexpected DB bugs remain diagnostic; EXPLAIN/latency on realistic data; no unmeasured status cache |
| R12 | Checkpoint claims exceed the retained reproducible evidence | Command + timestamp + base/source fingerprint + result + retained output for every validation claim | Required reproductions fail for the intended reason, then pass; complete repository checks and Semaphore blocks; migration/provider/queue handoff rehearsal |

## Important corrections to the independent review

These corrections narrow specific claims; they do not remove the release blockers above.

| Claim | Verified correction |
|---|---|
| Play `changesInReviewBehavior` is invalid/undocumented | Google explicitly documents it, including `ERROR_IF_IN_REVIEW`. Cookie-based authentication compatibility remains a separate unresolved contract gate. [Official reference](https://developers.google.com/android-publisher/api-ref/rest/v3/edits/commit) |
| A producer clock 30 seconds behind necessarily adds 30 seconds of delay | The current BullMQ default timestamp and computed delay use the same host clock, normally cancelling that offset. Worker-clock skew remains relevant; changing delay alone to database-relative arithmetic can introduce skew. |
| A normal acknowledgement can save a receipt but silently skip its upload manifest at the cited compiler check | Normal acknowledgement persists receipt, manifest and outcome atomically; the cited MIME mismatch throws. Late acknowledgement and lost-receipt continuation remain real gaps. |
| Every worker phase/poll advances attention | Progress records are limited to meaningful outcome phases and deduplicate unchanged phase/result/hold. Command/attention semantics still need refinement. |
| Microsecond pagination is untested because JavaScript Date is millisecond precision | The fixture inserts fractional timestamp strings through raw timestamptz SQL; the cursor preserves database microseconds. This is a valid focused test, not scale proof. |
| List and count use different current filters | The new read model shares its projection/predicate. The remaining issue is choosing the right counting unit and attention semantics. |
| No existing CI discovers these tests | Semaphore already discovers relevant API/package suites. This uncommitted prototype has no CI result; the standalone storage proof still needs explicit pipeline coverage. |
| Dependency has no consumer | Detail reads dependencies; no producer was found. Deferral requires removing the exposed behavior deliberately. |
| Production RLS is certainly bypassed | Local owner-role bypass is evidenced. Production runtime role/grants must be inspected before making that claim. |
| MCP impersonation necessarily has the same invalid actor shape as chat | Confirmed for impersonated web chat. Current MCP authority does not supply the delegated-admin field used by that scenario. |
| Ordinary review UI Regenerate always discards new text | The current existing-draft UI uses canonical iteration. The generation HTTP endpoint still exposes charged-old-text behavior for existing tickets/direct or stale-client calls. |
| Declined review work is irreversibly suppressed | Automatic discovery has no changed-source reopening path; explicit human restore exists. Catch-up seeding suppresses rejection, but later generation selection is inconsistent. |

## Remedies that would weaken the design

- Ending a polling budget does not establish non-application. An operator assertion or absent readback cannot cancel an in-flight provider request.
- Pending publication must not satisfy an approval requiring verified live content. Track the publication obligation separately from whether the mutation is still unresolved.
- Releasing a resource guard requires all issued effects to be resolved. Resource scopes should follow actual provider conflicts, not arbitrary operation-family labels.
- `SET LOCAL` alone does not fix leakage between migration files sharing one transaction. A fresh-connection test misses the issue.
- `ON DELETE SET NULL` alone may violate immutability and actor-shape guards. Blanket receipt cascades discard evidence.
- Neither blindly forcing RLS nor removing policies defines a safe application/worker authorization model.
- Blanket retry of HTTP 401/403/409, or mapping every SQL constraint error to 409, loses meaningful distinctions.
- A cached current-status column and a ban on sequential scans are not substitutes for measured query behavior.

## Schema simplification: evaluate, do not preselect a number

| Candidate | Possible benefit | Must preserve |
|---|---|---|
| Combine native receipt tables under a closed transport discriminator | Fewer one-to-one joins and finalization branches | Exactly one compatible receipt, typed native identity, immutable completion and parent attempt transport consistency |
| Fold small Play listing contract into a strictly discriminated listing relation | Fewer joins for a small native contract | Store-specific required/forbidden fields, reviewed policy versus observed edit state, exact approval digest |
| Combine selected ordered content relations | Shared ordering/ownership machinery | Finite roles, country/competitor request ownership, term meaning, scalar validation and cardinality; no extensible property/value table |
| Defer dependency capability | Remove an unused production path if not needed for present work | Explicit scope decision, detail contract cleanup and a real alternative for prerequisites |
| One versus several PostgreSQL namespaces | Simpler qualification versus enforceable ownership/grants | Provider boundaries in types/adapters; explicit grants; fully qualified DDL in either layout |

No target of 23, 25, 27 or 31 tables is approved by this response. A one-to-one split is not inherently better normalization; similar column shapes are not proof that facts have the same owner or grain. Finite text CHECKs can be closed types. The highest-priority schema work is excluding invalid combinations and preserving referential integrity.

## Evidence boundary and next reviewer task

Source inspection and retained-log review were performed without new application test runs, migrations, provider writes or deployment. Several named logs are red, including the file named progress-green. Specific retained passes are useful historical evidence, not certification of the working copy. The [checkpoint](Fload-Implementation-Checkpoint.md) separates those categories.

The next reviewer should respond to R01–R12 with agreement/disagreement, precise source evidence, a concrete design change where needed and the regression that would prove it. Resolve architecture decisions before changing DDL or application code. Revised DDL must then produce its own catalog and validation evidence; do not relabel this unchanged 31-table draft as the revised design.
