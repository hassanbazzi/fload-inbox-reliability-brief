# FLO-1355 — R2/R3 schema review and corrections

18 September 2026 · Documentation correction · Implementation paused

**The first R2/R3 draft is not implementation-ready.** Its direction is useful, but some rules contradict accepted evidence contracts and several promised historical facts have no destination. The [corrected draft v2](Fload-Inbox-R2-R3-Schema-Design-v2.md) replaces those rules and makes the remaining schema work explicit. The accepted ownership-v6 review stays closed.

[Visual overview](ownership-overview.html) · [Actual source fields](Fload-Inbox-R3-Source-Fields.md)

## What we fixed in the documentation

| Finding | Consequence if implemented as written | Correction in v2 |
|---|---|---|
| Receipt/result matrix weakened mandatory nonterminal proof and allowed inspection `matched_external` | Incomplete provider evidence could be admitted as a valid result | Original operation contract governs every capture; preserve provider evidence, partial observations and manual attribution. |
| Conflict rows dropped original prewrite/guard/run identity | History could describe the wrong interaction or lose generated no-work provenance | Copy original identity; remove only new admission authority. |
| Every nonterminal conflict immediately forced `blocked` | A newer in-flight request could lose its claim or recovery path | Preserve its fence and expiry, persist its result, prohibit new effects/adoption, then enter the diagnostic hold safely. |
| Manifest storage omitted readback and late/unexpanded cases | A captured upload plan could be lost after a successful native reservation | Store exact typed manifests without authorizing expansion. |
| Capture digest omitted semantic fields; replay checked after inserting leaves | Different captures could merge, or an ambiguous-commit retry could fail before replay | Full versioned semantic tuple, equality check and replay before inserts. |
| `test_plan` attributed to the wrong ASO tables | Destination schema and decoder inventory would describe nonexistent fields | It belongs to `aso_experiment`. The named source set has 212 columns, including 23 JSONB columns, not 25. |
| Proposed history fields lost snapshot details and original relationships | Source retirement could irreversibly lose rejected draft history, actors and links | Field conservation checklist; explicit missing facts and nested variants remain cutover blockers. |
| Overlay variants came from a stale comment | Request/batch read state and original targets could be lost; unread could become shared workflow | Current wire kinds, original target tuple, personal read **and unread**, and exact old aliases. |
| Separate source import identities treated as work identities | Backlog + its staged action could become two executable tickets | Consolidate explicit same-work relationships before atomic import; apply lifecycle gates to recommendations too. |
| Historical observations gained ordinary workflow authority | Old partial facts might satisfy present verification or freshness requirements | Historical facts remain non-authorizing; fresh native capture is a separate validated operation. |
| Erasure depended on ticket links and assumed all recovery records were tenant-owned | Unlinked asset data or global manifests could receive the wrong retention scope | Source-owned asset/tenant/global scope and a complete actor/reference erasure inventory. |
| “All additive migrations” and unregistered schema modules | Old authorities might remain indefinitely, or new schema files might never generate DDL | Explicit expand/reconcile/switch/contract sequence and Drizzle entrypoint coverage. |

## Architecture judgment

The evidence ledger and provider boundaries are worth keeping. The first draft's dozen source-shaped history tables are not yet justified by normalization: some duplicate domain content, while other facts are missing. Complete the field/relationship ledger first, then choose relations by ownership and cardinality. Neither “three tables” nor “twelve tables” is an approved final count.

The largest remaining risk is accidental authority: a historical claim or contradictory provider response must never become permission to deliver, release a resource guard, adopt output or claim success. The second is irreversible migration loss disguised by matching row counts. Field, value and relationship reconciliation is required.

## Evidence and limits

- Read the supplied R2/R3 draft, accepted ownership v6, carried v15 contracts and migration plan.
- Independent evidence/dispatch and source/schema reviews found the issues above. The revised R2 section received a bounded second check; its nullable digest-column wording and explicit adoption prohibition were corrected.
- Source-column census is AST-based against `e2cc156994855e401a83399fbb4c3d7be5194875`: twelve named tables, 212 declared fields, 23 JSONB columns. This is source metadata, not production data. Payload writers can change even when column declarations do not.
- Preserved prototype HEAD and all 212 recorded file hashes plus three recorded deletions remain intact; 145 working-tree status entries are unchanged.
- No platform changes, database migrations, application tests, provider operations or production deployment were performed. Static documentation and publication checks are separate from runtime correctness.

## What remains

R2 still needs the exact per-provider codec tuples, manifest constraints, complete reference census and executable structural matrices. R3 still needs the full destination mapping of all source fields and nested variants, partial native history, actor/asset/global scopes and alias FKs. Consolidated DDL/types and representative migration/concurrency/crash tests follow. These are open deliverables, not details hidden behind a “ready” label.
