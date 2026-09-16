# Fload-owned workflow and provider-owned semantics

16 September 2026 · FLO-1355 · Source baseline `f0b1af5fc5925d818be7d9b02b42b1fc54556ecc`

This review now accompanies the actual paused prototype schema: **31 physical tables, 497 fields and three views across four PostgreSQL schemas**. The exact repository migration chain was applied to an isolated synthetic test database and exported into the [field explorer](Fload-Inbox-Current-Fields.md). Application implementation and migration cutover remain incomplete; no production deployment occurred. Earlier 25-table source audits remain dated supporting evidence, not the current schema authority.

## Recommendation

Keep one PostgreSQL database and one Actions lifecycle. Put provider-specific content, targets and evidence behind explicit integration modules; use PostgreSQL schemas to make their storage ownership visible. Organize by independently changing API/product contracts: `apple_ads`, `app_store_connect`, `google_play`, and, when a real write capability is implemented, `meta_ads`. A single `apple` namespace would put two different products back together.

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

A provider-specific prepared request is **not** an untyped payload. It has named columns, closed variants, checks and tenant-safe foreign keys. Provider responses enter strict decoders and are mapped into explicit typed evidence. Unknown provider values remain unsupported/uncertain; they cannot silently become approved or successful.

Authored content does not automatically belong in Actions either. Reviews owns reply content and reply policy; Listings owns listing content and experiments; Ads owns advertising policy. Actions coordinates approval and execution of their immutable revisions. Domain code must not copy a second approval or lifecycle into its own rows.

## 3. Proposed namespace layout

This is a responsibility layout, not a request to create every namespace or a new table for every endpoint today:

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

### Make the physical split deliberate

Moving Apple Ads content into `apple_ads.action_content` adds zero tables. The draft extracts **six** provider-owned extensions: `app_store_connect.listing_contract`, `google_play.listing_contract`, `app_store_connect.step_contract`, and one `attempt_receipt` relation in each of the three current provider schemas. This accounts for the exact 25 → 31 change.

The split prevents unrelated provider columns from accumulating in common workflow rows and gives each extension native constraints. It costs joins, subtype sealing rules and a larger migration surface. Normalization does not require every one-to-one subtype to be physically separate; a strictly constrained smaller design remains possible. The recommendation is to retain these cohesive provider contract boundaries, then require their cross-schema invariants and migration proof before cutover.

The [actual field catalog](Fload-Inbox-Current-Fields.md) and [SQL](Fload-Inbox-Current-Schema.sql) now show this split concretely. The earlier [144-column ownership audit](provider-boundary-field-audit.md) explains the classification of the mixed design; it is historical evidence and must not be used as the current column count.

## 4. The typed seam

The application composes Actions with the owning domain and integration adapter. Core depends on stable ports; provider clients continue to expose their native contracts. The adapter translates between them. This follows the established [anti-corruption layer pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer), but it is a module boundary here, not a requirement for another service.

The public registry remains a closed set of supported capabilities. For example, current Apple Ads keyword-bid changes have a distinct contract. A future Meta budget change gets its own concrete contract after its semantics are investigated; it does not acquire Apple keyword columns or accept arbitrary JSON.

1. **Prepare:** resolve the concrete account, resource, baseline, units, preserved fields and material provider effects. Persist the immutable provider-specific plan with the domain proposal.
2. **Review:** render that exact proposal/plan. An abstract instruction such as “lower spend” cannot authorize an unseen later selection of campaigns, budget scope or bid strategy.
3. **Approve:** pin the sealed revision, its provider-specific content and semantics version in the same database transaction as the execution obligation.
4. **Execute:** use the frozen plan, current authorization and the appropriate adapter. Queue payloads carry durable references, never new content or authority.
5. **Observe:** decode and preserve provider-specific evidence; translate it into a closed common classification for Actions. No catch block may turn an ambiguous write into known failure.

Provider-specific rows reference the common revision/step/attempt with explicit composite tenant-safe FKs. Sealing enforces the right subtype and exactly the required content. Do not replace real FKs with a `(table_name, record_id)` pointer. Shared recognition of capability identifiers is an intentional extension point; provider branches and vendor fields do not belong in the lifecycle implementation.

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
- Full migration/seed/cleanup/RLS/restore tests include every introduced schema.

The exact draft migrations now compile and have been applied in isolated repository test databases; the exported catalog is tied to their hashes. Focused provider, command and storage tests provide partial proof. They do not establish a completed cutover, full repository validation, or production readiness. See the [implementation checkpoint](Fload-Implementation-Checkpoint.md) and [migration plan](Fload-Migration-and-Data-Plan.md) for the remaining gates.

Supporting source and field audits: [field ownership](provider-boundary-field-audit.md), [execution and provider effects](provider-boundary-execution-audit.md).
