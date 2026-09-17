# Fload-owned workflow and provider-owned semantics

> **18 September update:** [Corrected design v13](Fload-Inbox-Revised-Design-v13.md) now defines the reviewed execution, command-history and Usage contracts. Start with the [simple visual summary](summary.html). This supporting document preserves the wider inventory and earlier review evidence; v13 takes precedence where its contracts change these proposals. Implementation and migration validation remain open.

16 September 2026 · FLO-1355 · Source baseline `f0b1af5fc5925d818be7d9b02b42b1fc54556ecc`

This review accompanies the **unchanged, paused draft: 31 physical tables, 497 columns and three views across four PostgreSQL schemas**. The [field explorer](Fload-Inbox-Current-Fields.md) records what the prototype contains, not an approved destination schema. Its migration chain has been applied to isolated synthetic databases, but independent review found correctness gaps that require redesign and fresh validation. Implementation remains paused; no production deployment occurred. Earlier 25-table audits are dated supporting evidence. The [review resolution](Fload-Review-Resolution.md) records the full finding-by-finding disposition.

## Recommendation

Keep one PostgreSQL database and one Actions lifecycle. Put provider-specific content, targets and evidence behind explicit integration modules, organized by independently changing API/product contracts: Apple Ads, App Store Connect and Google Play. A future Meta write capability would get its own investigated contract. Code ownership is required; separate PostgreSQL namespaces and one-to-one provider tables are optional physical choices to evaluate. The next design pass must justify each split by its constraints, lifecycle, permissions or maintenance benefit, rather than adopt a target table count.

The same organization belongs in code first. Fload already documents provider-neutral bounded contexts and adapter composition in [Core architecture](https://github.com/fload-ai/fload-platform/blob/f0b1af5fc5925d818be7d9b02b42b1fc54556ecc/docs/core-architecture.md). Its [Apple architecture tests](https://github.com/fload-ai/fload-platform/blob/f0b1af5fc5925d818be7d9b02b42b1fc54556ecc/packages/apple/src/architecture.test.ts) already keep product clients independent and exclude Fload infrastructure from those clients. Extend that boundary instead of inventing another execution framework.

## 1. Draw two lines: authority and contract ownership

A field's location in our database does not determine who is authoritative about its meaning or current value. A provider-specific row is still stored, secured and migrated by Fload. Apple and Meta do not gain access to those schemas.

| Record | Who defines its meaning? | What Fload can guarantee |
| --- | --- | --- |
| Ticket, owner, approval, read marker | Fload | Our accepted decisions, exact approved content, atomic local transitions and retained history |
| A proposed reply, listing or campaign change | Owning Fload domain, constrained by the provider capability | The exact proposal the user saw, including provider target and material effect |
| Prepared provider-specific change | Integration contract | Exact frozen target, values, units, preconditions and semantics version we authorize; transport authentication may refresh without changing these |
| Provider campaign ID, edit ID, moderation state | Provider | What identifier or value we observed, when and through which account/API; not exclusive control of the remote resource |
| Verification result | Fload classification of provider evidence | Our comparison against exact approved content at an explicit observation time, with evidence completeness and uncertainty |
| Queue job, lease, browser session | Infrastructure mechanism | Our scheduling and exclusion rules; not the provider's completion or future behavior |

For example, `desired_campaign_state = paused`, an HTTP acknowledgement, `observed_campaign_state = paused at T`, and measured spend are four different facts. A teammate can subsequently change the campaign outside Fload. The approval remains immutable; the newest provider observation changes.

A Fload resource guard coordinates Fload's writers, even when several organizations reach the same provider account. It cannot lock the provider's console or another API client. Use native provider preconditions when available; otherwise document and test the remaining external race and reconcile it honestly.

## 2. What the draft moves out of the common Actions tables

The earlier generic Ads relation was effectively **Apple Search Ads content**. The draft now names it `apple_ads.action_content`. Its keyword/ad-group IDs and match types must not become the definition of every provider's Ads model.

| Earlier proposed location | Keep with Fload's common workflow | Move to its actual owner |
| --- | --- | --- |
| `action_ad_content` | Revision identity and exact approval reference | Current content becomes Apple Ads-specific change content; reuse genuinely common Ads policies/types separately |
| `action_listing_content` | Revision envelope and authored provenance | Listings owns proposal text/research; ASC owns App Info/version/App Clip targets; Play owns package/edit/commit semantics |
| `action_execution_step` | Step identity, ordering, input dependency, claim/recovery coordination | Typed provider effect variant, App Clip chunk offsets/lengths and reservation semantics |
| `action_execution_attempt` | Attempt identity, timing, claim fence, common outcome classification | Play edit receipts/expiry, ASC localization/media identifiers, provider-specific observations and finality evidence |
| Provider resources and credentials | Fload connector authorization, account access and scoped references | Integration-specific remote account/resource bindings; credentials remain with Connectors/secure transport |

The required provider-specific prepared request has named columns, closed variants, complete subtype checks and tenant-safe foreign keys. The prototype does not yet satisfy that standard everywhere: advisory/request variants permit irrelevant field combinations, and some attribution and connector references lack tenant validation. Absence of JSONB is not sufficient evidence of strictness. Provider responses must enter strict decoders and explicit typed evidence; unknown values cannot silently become approved or successful.

Authored content does not automatically belong in Actions either. Reviews owns reply content and reply policy; Listings owns listing content and experiments; Ads owns advertising policy. Actions coordinates approval and execution of their immutable revisions. Domain code must not copy a second approval or lifecycle into its own rows.

## 3. Ownership layout and physical alternatives

This is a responsibility map. The current prototype implements four namespaces; the final physical layout remains undecided. It is not a request to create every namespace or a new table for every endpoint:

```text
One PostgreSQL database
│
├─ actions
│  └─ ticket · revision envelope · command · approval
│     execution/step/attempt coordination · membership · personal read
│
├─ reviews / listings / ads
│  └─ Existing Fload-owned domain content and business policy
│     Only shared concepts with proven common semantics
│
├─ apple_ads
│  └─ Apple Ads change content · target bindings · typed provider evidence
│
├─ app_store_connect
│  └─ ASC listing/reply targets · App Clip effects · typed provider evidence
│
├─ google_play
│  └─ Play listing/reply targets · edit protocol · typed provider evidence
│
└─ meta_ads  [add action storage with a real supported write capability]
   └─ Meta-specific change content · target bindings · typed provider evidence
```

Fload-owned domains can begin as existing code modules and tables; a new PostgreSQL schema is useful when it groups real owned storage. Do not create empty contexts, tables or speculative Meta operation unions merely to fill out the drawing.

PostgreSQL schemas provide namespaces and privileges within the same database. They are not separate services or automatically isolated execution boundaries. Keeping them in one database preserves normal foreign keys and one transaction for sealed content, approvals and execution obligations. [PostgreSQL schema documentation](https://www.postgresql.org/docs/17/ddl-schemas.html)

Drizzle supports named PostgreSQL schemas through `pgSchema`. The actual migration must also cover migration discovery, RLS/grants, schema-qualified queries, introspection, backup/restore, seed tooling and test cleanup. Changing a prefix alone does not enforce architectural ownership. [Drizzle schema documentation](https://orm.drizzle.team/docs/schemas)

### Evaluate the physical split, without a table-count target

Moving Apple Ads content into `apple_ads.action_content` adds zero tables. The current draft extracted **six** provider extensions: two listing contracts, one ASC upload-step contract and three provider receipt relations. This explains the historical 25 → 31 delta; it does not establish that every extraction should survive redesign.

| Candidate | Reasonable alternative | Invariants the alternative must preserve |
| --- | --- | --- |
| Three provider receipt tables | One finite, discriminated receipt relation | Exactly one receipt per applicable attempt; transport compatibility; finalized interaction; tenant ownership; immutable evidence. An ordinary CHECK cannot inspect the parent attempt's transport, so a cross-row constraint remains necessary. |
| Small Play listing contract | Store-specific columns in listing content | Android target/account requirements, non-Android forbidden fields, approved commit policy and observation-only edit facts. |
| Notes, terms, countries and competitors | A closed ordered-item relation, only if its full matrix is simpler | Existing subtype ownership, role, value validation, ordering and gloss meaning. Country/competitor rows currently reference request content; notes/terms reference revisions. Similar-looking columns do not make their foreign keys interchangeable. No extensible property/value model. |
| Dependency relation | Defer the capability if it is outside the agreed release | The prototype already exposes a dependency reader, although no producer was found. Removing the table requires removing or deferring that behavior explicitly. |
| Research fields inside listing/request content | Keep proposal rationale with its revision; place independently owned run telemetry with its source | Decide from actual meaning and lifetime. Moving every research field into a one-to-one table is not inherently more normalized. |

A one-to-one provider subtype can share a table when a closed discriminator enforces all required, forbidden and optional fields. Multiple values, different identities or different lifetimes usually require separate relations. These are design choices to evaluate with concrete DDL and constraint tests, not automatic reductions to 23, 25 or 27 tables.

Multiple PostgreSQL schemas can make ownership and privileges explicit. A single `actions` schema with enforced module boundaries is also valid. Neither arrangement provides tenant isolation by itself. Cross-table invariants and transaction cycles exist even when both tables use the same namespace; changing names does not eliminate them. Choose after evaluating grants, introspection, backup/restore, migration and cleanup tooling.

The [actual field catalog](Fload-Inbox-Current-Fields.md) and [SQL](Fload-Inbox-Current-Schema.sql) remain the unchanged draft. The earlier [field ownership audit](provider-boundary-field-audit.md) describes the mixed predecessor, not the current field count or a validated replacement.

### Strict variants and real database boundaries

For every closed content variant, specify a field matrix: **required, optional or forbidden**. Enforce that matrix in wire validation and database constraints. In particular, an agent-attention advisory must not carry market-audit fields, and a request must not accumulate fields from unrelated intents. An enum or text constrained to a finite CHECK can both be closed storage; neither replaces the field matrix.

Complete tenant validation for API-key attribution, actor-agent-run references and attempt connectors. Existing source-provenance checks already cover many domain references; preserve those rather than treating all source references as unchecked. Frozen provider account identity remains distinct from the current connector used to authenticate.

The prototype's tenant policies do not prove runtime isolation. Local owner-role access bypasses RLS; the deployed role's ownership and bypass privileges have not been established by this review. Define a non-owner application role and explicit tenant transaction scope, plus narrowly authorized cross-organization recovery/resource operations. Validate list, claim, due scans, migrations and erasure under those actual roles. Blindly adding FORCE RLS can break recovery and locking; deleting policies removes protection. See the [migration plan](Fload-Migration-and-Data-Plan.md) for these release gates.

### Migration and deletion are part of ownership

Migration 0146 contains a standalone session `SET search_path`, while the migrator runs pending files on one connection in one transaction. Later unqualified DDL can land in the wrong namespace. Qualify the migration's DDL and remove the leaked session setting; preserve the caller's original path if migration code changes it. SET LOCAL alone is insufficient across files sharing that transaction. A same-run sentinel migration must prove later unqualified public DDL lands correctly. A lint check must distinguish session statements from legitimate function-local search-path attributes.

Provider and source references must also survive authorized deletion. The draft's deferred NO ACTION references can block connector uninstall, integration removal and source/agent cleanup while the organization still exists. Existing organization/user erasure handling does not solve those cases. Decide per reference whether a stable snapshot, narrowly allowed nullification, or a tombstone retains the necessary evidence. Updating an FK to SET NULL is insufficient when immutable guards reject that update; cascading deletion of approval or receipt evidence is not an acceptable shortcut.

## 4. The typed seam

The application composes Actions with the owning domain and integration adapter. Core depends on stable ports; provider clients continue to expose their native contracts. The adapter translates between them. This follows the established [anti-corruption layer pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer), but it is a module boundary here, not a requirement for another service.

The public registry remains a closed set of supported capabilities. For example, current Apple Ads keyword-bid changes have a distinct contract. A future Meta budget change gets its own concrete contract after its semantics are investigated; it does not acquire Apple keyword columns or accept arbitrary JSON.

1. **Prepare:** resolve the concrete account, resource, baseline, units, preserved fields and material provider effects. Persist the immutable provider-specific plan with the domain proposal.
2. **Review:** render that exact proposal/plan. An abstract instruction such as “lower spend” cannot authorize an unseen later selection of campaigns, budget scope or bid strategy.
3. **Approve:** pin the sealed revision, its provider-specific content and semantics version in the same database transaction as the execution obligation.
4. **Execute:** use the frozen plan, current authorization and the appropriate adapter. Queue payloads carry durable references, never new content or authority.
5. **Observe:** decode and preserve provider-specific evidence; translate it into a closed common classification for Actions. No catch block may turn an ambiguous write into known failure.

The target contract requires provider-specific rows to reference the common revision/step/attempt with explicit composite tenant-safe FKs. Sealing must enforce the right subtype and exactly the required content; the revised constraint matrix must demonstrate that guarantee. Do not replace real FKs with a `(table_name, record_id)` pointer. Shared recognition of capability identifiers is an intentional extension point; provider branches and vendor fields do not belong in the lifecycle implementation.

Keep common policy where it has the same meaning. Money can have a shared exact-decimal representation, while budget scope, period, pacing, object type and provider encoding remain explicit. “Campaign,” “status” and “budget” being shared words is not proof of interchangeable behavior. Use common projections for reporting where useful without forcing one universal write model.

## 5. What adding a provider changes

| Expected addition | Should remain stable |
| --- | --- |
| Its typed content/target/evidence storage, only for supported capabilities | Ticket IDs, ownership, history and personal read state |
| Strict wire decoders and application adapter | Revision immutability and approval transaction protocol |
| Capability registration, typed UI/SDK variants and permissions | Batch membership rules and server Undo rules |
| Provider-specific planning, observations and reconciliation | Common execution identity, durable scheduling and claim fencing |
| Contract fixtures, effect tests and provider storage migrations | Inbox pagination, count semantics and organization authorization |

Adding real capabilities adds real typed data. The promise is **bounded change**, not zero new fields or tables. New columns belong with the new capability's owner, instead of accumulating nullable Meta/Google/TikTok columns in common Actions tables. A new capability identifier may extend a shared closed registry/constraint; that is different from rewriting workflow semantics.

Do not create one table per API call by default. Keep variants together when they have the same owner, grain and lifecycle, with strict discriminator checks. Split repeated facts and genuinely different lifetimes. Splitting provider-specific content can increase the total relation count while making the common workflow smaller and more stable; the final count must come from the refactored DDL, not a target number.

Current repository distinction: Meta has integration/client code and campaign mutation methods, but the audited Actions registry does not expose a Meta write capability and no callers of those mutation methods were found. Do not advertise Meta writes or build speculative Meta action storage from that alone. See the supporting execution audit.

## 6. A repeatable classification method

For each field and operation, record:

- **Semantic owner:** Actions, Reviews, Listings, Ads, Connectors, an integration contract, or infrastructure.
- **Authority:** Fload decision, Fload-authored proposal, provider-defined contract, external observation, or derived classification.
- **Identity and grain:** one ticket, revision, remote resource, effect, attempt or observation.
- **Who can change it:** our command, provider, other external actor, or infrastructure expiry.
- **Lifetime:** immutable approved snapshot, append-only observation, or mutable current coordination state.
- **Atomicity and evidence:** local transaction guarantee, provider condition/idempotency, or uncertain cross-boundary outcome.
- **Change driver:** which provider API change should require altering this field and its consumers.

The best boundary test is concrete: **if Meta changes its API tomorrow, which Fload files, tables and tests should change?** The Meta adapter/contract/storage should absorb that change. Approval locking, read state and ticket history should not need to know the new provider field.

Review side effects, not function names. A provider helper called “read” can open or delete a remote session/edit. Current Play metadata readers do this. A TypeScript `ReadClient` interface alone cannot certify a readback is side-effect-free; those session effects and any retries must be declared and coordinated by the adapter.

## 7. Required proof for the refactor

- Core architecture tests prohibit provider SDK/DTO and persistence imports.
- Provider clients remain independent of Fload business policy; application adapters own translation.
- Sealed provider subtypes cannot be changed, omitted, substituted or linked across organizations.
- The same approval/Undo/concurrency tests pass through two distinct adapters, with explicit unsupported capabilities.
- Provider-target and contract-version changes require an appropriate new revision/approval; newer adapters cannot reinterpret old approvals.
- Cross-schema atomic rollback leaves neither partial content nor orphan approval/execution records.
- Provider observation cannot rewrite authorization or erase an uncertain attempt.
- Provider console edits and hidden read-session effects are covered by contract tests.
- Full migration/seed/cleanup/restore tests include every introduced schema and a subsequent same-run migration.
- Every variant rejects forbidden fields, missing required fields and cross-tenant references at both wire and database boundaries.
- Connector, integration, agent/source, user and organization deletion each follow tested retention rules without bypassing immutable history.
- Non-owner application access and bounded worker access prove RLS behavior, including global resource exclusion and due scans.
- Recognized database business conflicts map to closed application errors; unexpected integrity failures remain diagnostic failures.

The exported catalog records the paused draft; successful isolated migration runs do not establish safe later migrations, complete subtype enforcement, deletion compatibility or production readiness. Historical focused tests provide partial evidence only. Some checkpoint totals lack reconstructible retained proof, and some retained runs failed. When implementation resumes, record the exact command, timestamp, source fingerprint, outcome and output for each required suite. Do not present the current catalog or an unimplemented smaller design as validated. See the [review resolution](Fload-Review-Resolution.md), [implementation checkpoint](Fload-Implementation-Checkpoint.md) and [migration plan](Fload-Migration-and-Data-Plan.md).

Supporting source and field audits: [field ownership](provider-boundary-field-audit.md), [execution and provider effects](provider-boundary-execution-audit.md).
