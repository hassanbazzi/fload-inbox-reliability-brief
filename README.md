# Fload inbox reliability

[Open the public visual walkthrough](https://hassanbazzi.github.io/fload-inbox-reliability-brief/)

This is a current-capability architecture investigation and executable database design proof for FLO-1355. It is **not an implemented platform change, production migration or deployment**.

Start with [the end-to-end specification](Fload-Inbox-End-to-End-Specification.md). Inspect [the actual SQL](Fload-Inbox-Current-Schema.sql), [every field and constraint](Fload-Inbox-Current-Fields.md), and the [database-generated catalog](current-schema-catalog.json).

Supporting audits:

- [Current work and all entrypoints](audit-entrypoints.md)
- [Content and migration mappings](audit-content-migration.md)
- [Queues, provider steps and recovery](audit-dispatch-recovery.md)
- [Atomic command invariants](schema-command-guards.md)

Run the design proof with `python3 validate-design-schema.py` on a machine with Docker and `timescale/timescaledb:latest-pg17` already installed. It creates and removes its own network-isolated PostgreSQL 17 container, loads minimal external identity stubs, compiles the proposed schema, exercises invariant cases and a two-session contention test, then regenerates the catalog. It never loads Fload env files or connects to existing application databases or queues. This does not replace the complete Drizzle migration or application integration suites.

The source census can be reproduced with `node census-entrypoints.cjs /path/to/fload-platform` using a checkout at the source commit and its installed TypeScript dependency. The scan is read-only; output is written beside the script. Actual runtime data and queue census results remain private and are not in this repository.

Earlier schema proposals are preserved in Git history. This packet supersedes them. The current runtime contract includes no retired executors, JSON/JSONB payloads, arbitrary key/value rows or SQL queue engine.
