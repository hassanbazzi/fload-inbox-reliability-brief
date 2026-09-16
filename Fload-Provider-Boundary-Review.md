# Fload-owned workflow and provider-owned semantics

16 September 2026 · FLO-1355 · Source baseline `63275b2f51ac5b5a151a9a6683c813423e682785`

This is an architecture amendment to the inbox design. It recommends how to split responsibilities before implementation. The earlier SQL remains the tested baseline for its existing invariants; its 25 tables / 464 fields are **not a validated implementation of the split proposed here**. No application or database schema has been changed by this review.

## Recommendation

Keep one PostgreSQL database and one Actions lifecycle. Put provider-specific content, targets and evidence behind explicit integration modules; use PostgreSQL schemas to make their storage ownership visible. Organize by independently changing API/product contracts: `apple_ads`, `app_store_connect`, `google_play`, and, when a real write capability is implemented, `meta_ads`. A single `apple` namespace would put two different products back together.

The same organization belongs in code first. Fload already documents provider-neutral bounded contexts and adapter composition in [Core architecture](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/docs/core-architecture.md). Its [Apple architecture tests](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/apple/src/architecture.test.ts) already keep product clients independent and exclude Fload infrastructure from those clients. Extend that boundary instead of inventing another execution framework.

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

## 2. What should move out of the common Actions tables

The current proposed Ads relation is effectively **Apple Search Ads content**, despite the generic name. Its keyword/ad-group IDs and match types must not become the definition of every provider's Ads model.

| Current proposed location | Keep with Fload's common workflow | Move to its actual owner |
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

Moving the existing Apple Ads content relation into its own namespace adds zero tables. Splitting the currently mixed listing targets, App Clip step details and three providers’ attempt receipts could add up to six relations in the audited four-table area. That is a real tradeoff, not a free consequence of namespacing. The next physical-schema pass should extract cohesive contract records where it prevents mixed semantics and future provider-column growth, while retaining genuinely common fields and avoiding a separate table per verb. Do not clone Actions for each provider or adopt a blanket table-count target.

The supporting [field audit](provider-boundary-field-audit.md) classifies every one of the 144 columns in the four mixed relations and presents both the minimal module-boundary change and stronger physical separation. This document recommends the provider-owned contract boundary; exact DDL and the final relation count remain a follow-up design/validation task.

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

The earlier 60 SQL assertions remain evidence for the earlier concrete design, not proof that this new boundary has been migrated or implemented. Complete the responsibility split and rerun the generated-schema proof before treating a revised physical schema as ready for implementation.

Supporting source and field audits: [field ownership](provider-boundary-field-audit.md), [execution and provider effects](provider-boundary-execution-audit.md).
