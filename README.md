# Fload inbox reliability — architecture review packet

[Open the visual artifact](https://hassanbazzi.github.io/fload-inbox-reliability-brief/)

Updated 16 September 2026 · FLO-1355 · Repository baseline `f0b1af5fc5925d818be7d9b02b42b1fc54556ecc`.

**Documentation is the current deliverable. Implementation is paused and preserved locally.** This packet contains the actual draft schema, the complete delivery plan, focused test evidence and explicit remaining gates. No platform implementation PR or production deployment has been made.

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

**31 physical tables · 497 columns · three relational views · four PostgreSQL schemas.** No JSON/JSONB, arrays or arbitrary property/value columns in the proposed model.

The [catalog](current-schema-catalog.json) is exported from the exact repository migrations applied to an isolated synthetic PostgreSQL database. [Validation metadata](repository-validation-result.json) records their SHA-256 hashes. The catalog file uses JSON to distribute schema metadata in the browser; it is not JSON database storage and contains no customer rows.

The SQL bundle contains [0146](0146_durable_actions.sql) and [0147](0147_action_progress.sql) verbatim. It requires the existing Fload schema and preceding repository migrations. It is not a standalone database bootstrap or a production-ready cutover script. To reproduce the migration validation, use the repository's isolated test-database workflow and full migration chain; the older stub-based design harness is not current proof.

The six additional tables compared with the earlier 25-table design separate two provider listing contracts, one ASC upload-step contract and three native receipt contracts. Their tradeoffs are explicit. Historical evidence without provable approval still needs a final typed retention representation before old authorities can be removed.

## What changed

- Replaced the older schema explorer with the actual four-schema migration catalog, including every field, foreign key, enum, check, index, trigger and view.
- Added visual field cards and complete review, localization, ASO/App Clip, Apple Ads, request/advisory and recovery flows.
- Completed ownership, queue, entrypoint, migration and cleanup documentation around the paused prototype.
- Recorded focused test results, known failing HTTP regressions and remaining architecture/implementation gates.
- Preserved the implementation locally while returning to the requested documentation phase.

Earlier source audits remain available as dated evidence. The current documents above supersede their schema proposals. Private customer records and operational census outputs are excluded from this repository.
