# FLO-1355 — R3 destination contracts v2

19 September 2026 · v2 review follow-up applied · Documentation only · Implementation paused

**Review follow-up:** [Disposition of M1–M3 and L1–L6](Fload-Inbox-R3-Destination-v2-Review-Resolution.md). Baseline capture, explicit restore intent, adoption provenance, native identity proof, archive scope and actual handoff writers are clarified below. The reviewed inputs are preserved unchanged; no new architecture version or final DDL is claimed.

**Status:** this is a concrete destination-contract increment, not final DDL or closure of B9–B13. Ownership v6 and the clarified R2/R3 v2 remain the governing design. The corrected conservation ledger remains the source-preservation contract. New historical-purpose, head and presentation rules need the integrated matrices identified below before acceptance. No final new-table count is approved.

**What changed:** provider aliases stay outside Core; repeated rejection facts survive; source claims no longer become execution proof; replay checks bind the complete plan; schedules precede terminal decisions; keyword context and successful release verification now have exact typed destinations. Historical admission and future work must use the same permanent ticket without inheriting old approval.

**Evidence:** source census pin `e2cc156994855e401a83399fbb4c3d7be5194875`. The preserved prototype is based on `f0b1af5fc5925d818be7d9b02b42b1fc54556ecc` **plus recorded uncommitted files**; its schema-actions.ts is not in that commit's tree. The earlier checkpoint observed origin/main `94685451be84b5199e344f11a614ec1206930657`; it is superseded by the [coordination checkpoint](Fload-Inbox-R3-Parallel-Work-Coordination.md#updated-migration-checkpoint-c3) at `324b05de256e00e74e2074bd047199f00523f3d2`. Backlog/ASO/report writers and the backlog wire contract changed; the database source-column inventory did not. This is a read-only local-ref comparison, not a fresh remote-main or production-data census. The original destination proposal is preserved privately unchanged.

[Review disposition](Fload-Inbox-R3-Destination-Review-Resolution.md) · [Conservation ledger](Fload-Inbox-R3-Conservation-Ledger-v2.md) · [Source types](Fload-Inbox-R3-Source-Type-Inventory.md) · [Visual walkthrough](ownership-overview.html#destination-heading)

---

## 0. Conventions

- IDs are text; existing creation/idempotency keys are UUID; SHA-256 digests are lowercase char(64); instants are timestamptz. Numeric source values require finite, lossless round-trip conversion; integrality/range checks come from the actual source contract, never from intuition about the field name.
- Every candidate relation below carries organization_id NOT NULL and tenant-qualified keys/FKs unless explicitly identified as shared domain evidence. No new global migration-run exception is introduced.
- New canonical tuples use LP(s): unsigned 32-bit big-endian UTF-8 byte length followed by bytes, with a versioned domain prefix. Required scalar types and tuple order are fixed. Optional fields use a separate one-byte presence tag (0 absent, 1 explicit null, 2 value followed by LP); arrays include a 32-bit count and ordered typed elements. No delimiter joining or unspecified `LP(number)`; integer ordinals use canonical base-10 ASCII without leading zeroes. No open object encoder is implied. A complete per-command payload codec remains part of consolidated DDL/type work.
- uuid_fold denotes the preserved helper's exact nibble replacement, not standard UUIDv5 derivation: for SHA-256 hex h, `h[0:8]-h[8:12]-5+h[13:16]-a+h[17:20]-h[20:32]`. Retain/compare the complete typed identity tuple on a key conflict. Equal folded keys alone do not prove equal work.
- Closed alternatives have one contract source generating/validating SQL enums and strict wire/domain unions. Native catalogs belong to their provider package; Core consumes neutral workflow contracts. No JSONB, serialized structured payloads in text, or field/value EAV storage.
- Historical content is immutable except explicit authorized erasure transitions. Existing prototype guards do not automatically implement ownership v6 or the candidate historical shapes. Required/forbidden matrices and integration fixtures must be updated together.

---

## 1. B9 — Identity, keys and edges

### 1.1 Canonical review identity (v15:183 completed per store)

`review_identity_key_v1(organization_id, store, provider_app_id, provider_review_id) → uuid`

| Step | Rule |
|---|---|
| Inputs | `store` ∈ closed `store_kind` {`ios`,`android`}; `provider_app_id`, `provider_review_id` text. |
| Normalisation | Provider adapter applies the declared, versioned source normalization only; raw spellings remain source facts. Review ID validation: `provider_review_id` non-empty and preserved as the source opaque ID; any further native-format restriction needs its provider decoder, not delimiter requirements. iOS `provider_app_id` matches the source resolver's `^\d{5,15}$` after its explicit trim (Adam ID, `ios-app-id-resolver.ts:53–67`); preserve the raw source spelling separately and do not silently introduce the proposed nonzero-first-digit restriction. Android `provider_app_id` matches `^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$`, case preserved (`gplay-package-name.ts:25–46` preserves case). A numeric Android value is **refused** at this function; it must be bridged first (§1.2). |
| Canonical bytes | `LP('fload:review-identity:1') ‖ LP(organization_id) ‖ LP(store) ‖ LP(provider_app_id) ‖ LP(provider_review_id)` |
| Key | SHA-256 of the canonical bytes, folded into a uuid exactly as `migrationCreationKey` folds (`backfill-pending.ts:58–65`), stored in `action.creation_key`; `UNIQUE (organization_id, creation_key)` (prototype). |
| Version | The prefix carries the version. A future codec needs an explicit identity-resolution migration; it cannot create a new ticket for already known work or silently change an existing permanent ID. |
| Where the components live | `review_work.reply_content.store / provider_app_id / provider_review_id` on every revision purpose (v6 §3.3, "review identity columns required for every purpose"). Actions never interprets them; the Reviews adapter computes the key. |

Collision rule: compare the full canonical identity tuple as well as its key. Equal keys with unequal tuples block as identity_collision. Proved equal tuples resolve to one same-work class (§1.4); key equality is never the evidence of equivalence. Two keys for what evidence says is one review (e.g. numeric and package forms) are a B9 census failure, not two tickets.

### 1.2 Google Play identity bridge (provider-owned candidate)

Source review.appId may be a package or console numeric ID. The acceptance writer replaces asset_data_source.appId with a console ID, while the reply path needs a package. The asset package unique index does not prove a permanent provider-level bijection. Missing historical bridge proof blocks import; there is no provider I/O during import and no first-candidate/title/asset-only inference.

Candidate `google_play.app_identity_bridge` fields:

| Field | Type / meaning |
|---|---|
| organization_id, id | text, tenant-qualified PK |
| package_name, console_app_id | text NOT NULL; exact case/package spelling and numeric ID preserved |
| asset_id | nullable tenant-qualified asset FK; context, not identity authority |
| bridge_version | integer NOT NULL, 1 |
| captured_at | timestamptz NOT NULL; census capture time, not historical pairing time |
| evidence_asset_id, evidence_data_source_id | text NOT NULL snapshots of both source identities, not one polymorphic evidence_source_id |
| evidence_asset_fingerprint, evidence_data_source_fingerprint | char(64) NOT NULL; exact consumed typed source versions/values |

Only `frozen_asset_data_source_pair` is considered for admission in this candidate. Its decoder must prove the same tenant/asset/Android connector association and both exact source values under the stable census. Current co-location proves what the snapshot contains; it is not automatically proof that the same mapping held when an old review was fetched. Historical use additionally requires row-linked origin/provenance or a validated provider identity invariant. `acceptance_pairing` and `provider_apps_response` are **not enabled origins**: the cited acceptance update does not durably retain the whole returned pair. Add a concrete typed evidence contract before enabling them.

Conservative admitted uniqueness `(organization_id, console_app_id)` and `(organization_id, package_name)` may refuse ambiguous mappings; these are proposed safety constraints, not proven native lifetime/cardinality facts. Developer/account scope and reassignment rules must be established before final DDL. Multiple same-pair witnesses must remain distinct evidence references; do not lose them through a uniqueness upsert.

Package-form review IDs retain the exact package and require consistency with all proved associated mappings. Numeric-form review IDs require one proved same-tenant mapping. Missing, conflicting or historically unproved mapping stays blocked. Do not copy today's first-match resolver into migration.

Provider-owned identity/target references must identify every surviving dependent ticket before bridge erasure is implemented. Organization erasure removes tenant facts; asset erasure may clear only the erased asset pointer while retaining a still-required proved pair. Evidence availability must become explicitly unavailable when its source is erased. Admission and erasure serialize on the same identity; opaque source IDs are never deletion authority. Exact reference/erasure DDL is still B9 work.

### 1.3 Native aliases that appear later (no Core provider namespaces)

ASC customerReviews resource IDs and Play console-review associations belong in their provider schemas. Reuse the ownership-v6 typed provider target lookup where it proves one target; any additional association must have concrete native columns and provenance. **Do not add asc_review_resource or play_console_review to action_alias.** Core receives only the already-resolved action ID/neutral creation key. No generic provider-identifier bag replaces the removed namespaces.

Later resource discovery leaves the canonical key unchanged. Concurrent discovery of the same proved target replays; incompatible associations block, never reassign a prior ID. An API producer with only an unbridged native resource cannot create a second ticket.

`action_alias` remains the closed resolver for old Fload identities. The v15 additions `backlog_item` and `stage_blocker_card` remain appropriate. Alias uniqueness is tenant-qualified; no delimiter-encoded provider tuples are stored in Core.


#### Candidate ASC native association (L3)

Name the provider-owned landing relation `app_store_connect.review_resource_link`; it is a proposed identity association, not a second ticket or execution authority.

| Field | Type / constraint |
|---|---|
| organization_id, provider_app_id, review_resource_id | text NOT NULL; composite PK, scoped to the exact native app; conservatively avoid claiming resource-ID uniqueness across all apps/accounts |
| action_id | text NOT NULL; same-tenant Actions FK; exact iOS review identity must match the evidence |
| proof_revision_id | text NOT NULL; same-tenant/same-action sealed observation reference with both review_work.reply_content and app_store_connect.review_target leaves |
| provenance | closed enum `canonical_identity_observation`; no cached-ID or fuzzy-match branch |
| proved_at | timestamptz NOT NULL; server time this association was admitted, not source/provider occurrence time |

The proof revision must bind the original review ID, provider app, account scope and official resource ID through the provider identity codec. Reject ambiguous same-rating/nickname/body matches; those facts are not a durable cross-ID proof. Source review-response-reader.ts trusts cached IDs and chooses the first matching candidate, so neither its cached result nor a provenance label is accepted automatically. Exact identity/correlation admission is still part of R2/B9; until that codec exists, this branch is disabled. Import never fabricates an observation to turn a cache into proof.

No `UNIQUE(organization_id,action_id)` is added without a demonstrated native one-to-one lifetime rule. The same proven alias cannot point to two tickets; multiple observation/target revisions may legitimately repeat it. A unique index on per-revision leaves is therefore not equivalent. Additional aliases for an action require their own exact proof and cannot mutate previous associations. Conflict/refusal preserves both evidence and the existing target. API-only producers without app/identity proof remain blocked instead of creating another action.

Immutable once admitted; tenant/action erasure removes the scoped association. Ordinary provider disappearance does not erase it. The proof FK must not depend on the mutable legacy review row; proof-erasure availability and native account-scope/ownership rules remain integrated DDL gates. Play numeric/package lookup continues through its separate typed bridge in §1.2, never this ASC relation.

### 1.4 Edge classification, canonical keys and closure

Compute typed relationships and same-work equivalence classes **before** assigning keys. A referenced card is not automatically the same work as its request. A linked blocked request is not automatically a dependency. E4 is classified using the exact request variant, immutable output/intent, domain scope, locale/store and retained handoff evidence.

| Edge | Class / representation | Admission rule |
|---|---|---|
| E1, E2 backlog → staged/catch-up card | Same work; one ticket, every proved old-source alias retained | Exact staged pointer and source association; missing staged target is recovery, never fresh backlog work |
| E3 refusal card ↔ backlog | Same work only for the proved same intent; preserve blocker wording as historical domain content | A later executable listing head cannot inherit the advisory's nonexistent delivery approval |
| E4a proved generation handoff | Request parent plus genuine locale children, or one listing-change identity, according to the actual output topology | `kind=hypothesis` alone is insufficient. Output ID arrays prove references, not child content/revision/approval. A multi-locale card cannot become both a child and its parent |
| E4b proved blocked-request relationship | Distinct identities; admitted neutral dependency only with exact relation and domain readiness contract | `surfaceAsoBlockedRequest` does not itself persist pendingActionId. NO_OPEN_RELEASE plus same asset is not link proof. Acknowledging a blocker cannot satisfy release availability |
| E5 post_batch → drafts | Persisted package membership from recorded manifest; exact approval membership separately proved | No today's-pending reconstruction |
| E6 draft ↔ individual reply card | Same review tuple, one ticket | Complete native identity equality, not asset-only match |
| E7, E8, E14 | Distinct lineage identities; successor/history links | No accidental equivalence union |
| E9 | Child source event/history | Retain source parent link |
| E10 | Personal state | action_read / unresolved overlay fact |
| E11, E12 | Evidence/domain reference | Stable tenant-authorized dependency snapshot |
| E13 | Rejection snapshot whose draft may be gone | Preserve rejection and exact unavailable draft reference |

Canonical identity precedence within a **proved equivalence class**: review tuple; otherwise proved request/child lineage anchor; otherwise the exact retained pending-card anchor; otherwise backlog/request singleton. A proven existing permanent target always wins. Do not compute a card-derived key for E1 and an incompatible request-derived key for E4 and then reject a normal handoff. All class members receive the one selected key and aliases. Conflicting semantic identities still block; precedence cannot merge different intents or provider targets.

Child anchors require the full domain discriminator (store, locale and intent/role as applicable), not locale alone. The exhaustive E4 source-variant matrix and byte codec remain B9 design work; ambiguous variants stay blocked. No newly inferred child becomes approval-time membership.


#### E4 source variants checked in this follow-up

| Variant | Actual writer and output | Safe mapping |
|---|---|---|
| listing_change hypothesis | listing-change-hypothesis.ts:110–155; aso-agent.ts:1185–1187 writes **both** pendingActionId=applyCardId and recommendationIds=[applyCardId] | Request/package and card may share a proved class; derive per-locale child intent only from exact retained content. The review's claim that this pendingActionId writer is unidentified is incorrect |
| locale_expansion hypothesis | locale-hypothesis.ts:199–224 stores returned card references; aso-agent.ts:464–477 passes hypothesisRequestId to locale staging | Returned IDs are references, not proof of N newly created drafts or approval-time membership |
| Locale output variants | locale-expansion.ts:2012–2038 uses action=create_locale with localeClass=create/update/repair and a reused asset/locale card ID; :2087–2135 can retain a protected human-edited row while discarding newly generated copy | Do not force intent=create, attribute unchanged copy to this generation, or mint a request-derived identity for an already proved target. Preserve exact locale class and historical request/card references |
| blocked request | aso-agent-request-blockers.ts:102–124 creates no pendingActionId link itself | Distinct work; admit a neutral dependency only with retained same-tenant relationship and readiness proof |

The illustrative new-child anchor uses organization + stable lineage anchor + store + locale + domain role, encoded as an explicit LP tuple. Mutable create/update/repair intent is revision content, not a reason to re-key permanent work. A proved existing target takes precedence. Reused IDs and missing original content cannot manufacture a generation handoff revision. The remaining E4 work is strict variant/relationship decoding and conflict/partial-output fixtures, not rediscovering the already identified completion writer.

Atomic closure includes E1–E9, E13 **and E14**, including incoming and outgoing relationships within the organization. E10–E12 remain independently versioned consumed dependencies unless their actual ownership edge requires inclusion. Apply rediscovery binds all members, edges, source versions and shared-domain facts per ledger §9.2. Missing target is an exact unavailable reference; cross-tenant target blocks. An absent dependency ticket is not fabricated from a blocker code.

---

## 2. B10 — Owned facts: exact destinations

Each row: destination, SQL type/nullability, closed values, determinant/cardinality, CHECK, mutation/erasure, decoder assertion. Relations already in the prototype/v6 are reused; additions are marked **add**.

### 2.1 Localization gloss and pins

| Source fact | Destination | Type · null | Rule |
|---|---|---|---|
| `englishGloss.title/subtitle/promotionalText` | `listing_work.listing_content.english_title / english_subtitle / english_promotional_text` (prototype `action_listing_content`) | text NULL | proposal and `historical` purposes only; NULL = key absent. |
| `englishGloss.keywords[{word,meaning}]` | `listing_work.content_term(role='gloss', ordinal, term=word, meaning)` (prototype `action_content_term`) | `ordinal` int NN; `term` text NN; `meaning` text NN for role `gloss` | order and duplicates preserved; CHECK (`role='gloss'` ⇒ `meaning` NN). |
| `englishGlossStatus` | `listing_content.gloss_status` | enum NULL {`updating`,`ready`,`unavailable`} (prototype) | NULL = key absent. |
| `metadataRevision`, `englishGlossRevision` | **add** `listing_content.metadata_revision text NULL`, `english_gloss_revision text NULL` | | CHECK (`CASE WHEN gloss_status='ready' THEN metadata_revision IS NOT NULL AND english_gloss_revision IS NOT NULL AND english_gloss_revision = metadata_revision ELSE true END`) (`inbox.service.ts:4410–4438` acceptance rule); rows with none of the three pins are the documented legacy shape and pass. |
| `humanEditedAt` | **add** `listing_content.human_edited_at timestamptz NULL` | | `iso()`; not a decision claim (no actor). |
| `dismissedFields[]` | field `*_state='dismissed'` with its retained text | | unknown field name blocks; dismissing never drops restoreable copy. |
| Decoder | keys ⊆ {`metadata`,`metadataRevision`,`englishGloss`,`englishGlossRevision`,`englishGlossStatus`,`dismissedFields`,`humanEditedAt`} ∪ the action's declared params; `englishGloss` keys ⊆ {`title`,`subtitle`,`promotionalText`,`keywords`}; each keyword entry exactly `{word: string, meaning: string}` | | any other key blocks `unmapped_content`. |

### 2.2 Locale demand and competitor facts

| Source fact | Destination | Type · null | Rule |
|---|---|---|---|
| `demand.downloads / revenueUsd / impressions / reviewCount` | `agent_work.request.downloads / revenue_usd / impressions / review_count` (prototype) | numeric NULL ×3; bigint NULL | `review_count` requires an integral finite value else block. |
| `demand.pageViews` | **add** `agent_work.request.page_views numeric NULL CHECK (page_views >= 0)` | | separate from impressions (inventory §1). |
| `competitorMarket.strength / localizedCompetitorCount / topChartCount / estMarketDownloads` | `request.competitor_strength numeric; localized_competitor_count bigint; top_chart_count bigint; estimated_market_downloads numeric` | NULL | integrality asserted for the two counts. |
| `competitorMarket.topCompetitors[]` | `agent_work.request_competitor(ordinal, competitor_name)` (prototype `action_market_competitor`) | | order preserved; no dedupe. |
| `demandCountries[]` | `agent_work.request_country(role='demand', ordinal, country)` | | v15 permits only for locale_expansion. |
| `language`, `reasoning`, `score`, `marketResearchNote`, `demandLookbackDays` | `request.language text; reasoning text; score numeric; market_research_note text; demand_lookback_days int` | NULL | `language` is a typed snapshot of the caller value (not retired). |
| Decoder | `LocaleDemandSignal` keys ⊆ {downloads,revenueUsd,impressions,pageViews,reviewCount}; `CompetitorMarketSignal` keys ⊆ {strength,localizedCompetitorCount,topChartCount,estMarketDownloads,topCompetitors}; all numbers finite | | |

### 2.3 Promise wording and blocked guide steps

| Source fact | Destination | Rule |
|---|---|---|
| `agent_request.whatWillHappen[]` | `agent_work.content_note(section='what_will_happen', ordinal, text_content)` (prototype `action_content_note`, `prose_section` enum) | exact ordered text; not regenerated. |
| `unblockGuide.steps[]` | `content_note(section='unblock_steps', ordinal, text_content)` | |
| `supportingEvidence[]` (directed) | `content_note(section='supporting_evidence', …)` | |
| `pending_action.params.fieldLabel` | **add** `history.pending_action_facts.field_label text NULL` | typed snapshot; retirement only with byte-equal reconstruction proof. |

### 2.4 Original/current text, historical purpose and execution claims

`historical` is a **candidate new purpose**, not an already supported enum. It stores typed, non-authorizing content without inventing a missing account, target, baseline, generation or approval. Each affected domain/provider leaf needs its own required/optional/forbidden matrix and composite purpose FK. Proposal requirements stay strict; adding one enum is insufficient. Historical-only heads and commands are covered in §4.

| Case | Conservation rule |
|---|---|
| original_ai_reply differs from reply | Two immutable typed snapshots, preserving both exact strings. Original-AI linkage is same-ticket provenance, not proof of generation time or actor. The existing pointer guard admits only proposal ancestors; its historical branch must be explicitly designed |
| Fresh executable adoption | A **new** complete proposal revision after current baseline/source/effect checks, explicitly linked to its source snapshot. Never change a sealed revision's purpose or treat one row as both historical and proposal |
| workExecutionParams differs from params | Separate historical content reference plus source claim that it was used. This alone cannot set proved_revision_id or content_proof. Exact effect/content correlation is independently required |
| rejection plus later draft | Preserve the decline and both texts. Later content cannot be the current approvable head until an accepted explicit replacement transition; no implicit reopen |

Snapshot created_at is the import instant. Original source timestamps stay separately labelled and undergo provenance checks. Historical content never creates an execution, provider attempt, LLM usage record or current approval.


**Named adoption reference (L2):** use the existing immutable accepted revise command target: `(organization_id, action_id, previous_revision_id, result_revision_id)`. For historical→work adoption, previous_revision_id is the exact sealed historical display head and result_revision_id is the new sealed proposal on the same ticket; previous/result record_kind make the transition explicit. Same-tenant/action FKs, revision order and exact expected-head checks apply. This edge is the typed provenance link, so no adopted_from_revision_id column is needed. It proves deliberate adoption, not byte equality or LLM generation. Do not overload generated_from_revision_id or the observation evidence_revision_id. A different non-head source snapshot requires its own reviewed provenance contract; it cannot be silently substituted here.

### 2.5 Rejection preservation and suppression (Reviews-owned)

Candidate import-only `review_work.rejection_claim`:

| Column | Type / rule |
|---|---|
| organization_id, id | text, tenant PK |
| action_id | text NOT NULL, tenant-qualified permanent review FK |
| source_rejection_id, source_draft_id | text NOT NULL, exact retained source IDs |
| review_fingerprint | char(64) NOT NULL, exact legacy bytes |
| fingerprint_version | integer NOT NULL CHECK = 1 |
| fingerprint_algorithm | enum `legacy_review_content_v1`; labels the original `fload.review-content` namespace plus separate version 1, **not** the new LP codec |
| rejected_by, actor_state | nullable user FK and enum known/unavailable; erasure nulls user and marks unavailable atomically |
| rejected_at, reason | timestamptz NOT NULL with proved conversion; nullable text |
| draft_present_at_import | boolean NOT NULL; refers to the draft, not the surviving rejection receipt |
| import_component_id | text NOT NULL, tenant-qualified FK |

UNIQUE `(organization_id, source_rejection_id)`. Fingerprint lookup is a **nonunique** index: separate rejections of separate drafts may share the same review hash and retain different actors, times, reasons and content. The exact rejection draft snapshot is conserved through the ledger's typed content/generation/delivery references; its source-to-snapshot FK must be integrated before DDL acceptance.

Remove the unsupported preimage_state=sealed_snapshot branch from this import-only relation. A legacy digest without its actual historical preimage remains incomparable and suppresses automatic regeneration. A current review row is not that preimage. The companion matrix §2.2 makes the historical/declined capture branch conditional on independently recovered, fully comparable source evidence. Reproducing v1 bytes alone cannot prove unhashed provider-edited state; the strict recovery/version bridge remains a gate.

Future declines use the immutable reject command and exact rejected revision/source snapshot. Do not invent source_rejection_id/import_component_id for runtime commands. Candidate `review_work.reply_content.source_fingerprint char(64)` and `source_fingerprint_version integer CHECK=2` are populated for complete new proposals **before** rejection, with an exact sealed source-snapshot FK; a flag alone is not proof. Rating/title/body/provider-edited values and normalization must match the accepted meaningful-change policy, with executable vectors for missing/null/empty and the original v1 codec kept distinct. Do not approve a new hash formula before that complete snapshot contract exists.

Automatic replace_declined requires every v15 guard: current ticket/head/version pins, comparable exact rejected source, meaningful source change, fresh observation, no unresolved effects and correct suppression. Missing old preimage stays suppressed. Present authorized reconsideration must use an explicit reviewed transition; there is no invented command or authorship bypass here. Suppression is scoped to the currently effective decline identified by the exact command/version chain, not every retained historical claim forever. Explicit reconsideration ends that decline’s blocking effect while preserving its immutable facts; historical/open still requires the authorized fresh-work adoption path. A later runtime rejection uses its own exact rejected revision/source. Never select the effective decision by approximate source timestamps or silently clear suppression during import.

### 2.6 Listing package facts (collection subtype)

**Add `listing_work.listing_package`** — determinant: the collection parent revision (1:1).

| Column | Type · null | Values |
|---|---|---|
| `revision_id` | text PK FK `action_revision(organization_id,id,purpose)` | purpose ∈ {`proposal`,`historical`} |
| `store` | enum NN | `store_kind` |
| `scope` | enum NN {`all_locales`} | writer literal (`aso-agent.ts:5654–5677`) |
| `recommendation_type` | enum NN | prototype `recommendation_kind` |
| `risk_level` | enum NN {`low`,`medium`,`high`} | `plan.riskLevel` |

Immutable; erased with the revision.

### 2.7 Run provenance is not actor proof

Keep `history.decision_claim.source_agent_run_id text NULL` separately from actor_agent_run_id. A source run ID is retained regardless of actor certainty.

An explicit actorUserId with valid source provenance supports the human actor claim. Otherwise sourceAgentRunId + same organization + completed/failed event + empty/draft_output data is **insufficient** to assign agent authorship: human approval flows can produce those shapes too. Require row-linked writer/run provenance establishing who performed that event; absent it, actor_state=unavailable. Do not use current run ownership to fill an unknown historical actor.

### 2.8 Deleted-draft referent

Carried by `review_work.rejection_claim.source_draft_id` + `draft_present_at_import`; the rejection's `history.source_record.source_present_at_import` stays true (E13). No separate relation.

### 2.9 Provider history leaves

| Candidate relation | Exact fields / restrictions |
|---|---|
| app_store_connect.historical_release_resolution | organization_id; record_id text PK/FK source_record; release_key text NN; release_version_id text NN; release_version_string text NULL; resolved_at timestamptz NN. Historical claim only |
| app_store_connect.historical_before_listing | organization_id, record_id, locale, snapshot_origin enum `locale_before / action_before`, all NN and composite PK. Concrete text columns before_name, before_title, before_subtitle, before_description, before_keywords, before_promotional_text, before_whats_new, before_short_description; each paired with its own state enum `absent / null / value`. State=value iff value IS NOT NULL; empty string is a value. Closed source-shape matrix admits only fields actually present in the relevant traced writer |
| google_play.historical_before_listing | same identity/origin pattern; concrete before_title, before_description, before_short_description plus individual presence states; other fields block until mapped |
| app_store_connect.historical_unblock_finalization | Carry the ledger-v2 status, blocker_code (required nullable), verification and provenance fields. Add resolved boolean NULL, message text NULL, verification_data_shape enum `absent / empty / editable_version` NN; version_id text NULL; version_string text NULL; app_store_state closed native enum NULL |

No field_name/value relation is introduced. Concrete named before-fields preserve each declared source spelling and cannot be substituted for a baseline. Container absent/null/object shapes and duplicate representations also need exact round-trip rules in the strict writer decoder; unsupported shapes stay blocked rather than flattened.

The successful verification writer is **known**: verification.data is `{versionId: string, versionString: string|null, appStoreState: string|null}`. Shape=editable_version requires all three keys, version_id NOT NULL and source NULLs preserved. Empty/absent forbids those field values. Inspect keys before any forgiving source parser. The provider-owned historical appStoreState catalog must be pinned and closed; unknown values block, never arbitrary string fallback. This is a historical verification claim, not a fresh release baseline or resumption authority.

All leaves have tenant-qualified FKs, immutable fact rows and source-record erasure scope. The exact per-action/shape admission and native-state enum still need consolidated DDL/codecs.

### 2.10 After-state scalars

**Add** to `history.pending_action_state`: `after_auto_applied boolean NULL` (NULL = key absent; the writer only ever writes `true`), `after_experiment_id text NULL` (opaque, separate from the column value). Remove the `release_*` columns (moved to §2.9).

### 2.11 Partial approval policies — lossless representation

`agent_work.request.hypothesize_policy / draft_policy / execute_policy` (prototype `approval_setting` {auto, await}) mirror the three optional keys one-to-one; NULL = key absent. The all-present-or-all-absent CHECK applies **only when `action_revision.purpose='proposal'`**; a `historical` revision may carry any subset. Decoder: keys ⊆ {hypothesize, draft, execute}; each value ∈ {auto, await}; anything else blocks. The proposed historical request shape preserves partial policy fields; until that shape and its sealing/head matrix are implemented and validated, the actual import disposition remains blocked. Later work needs a separate fresh complete proposal; no historical row is mutated into one. No defaults are applied and key presence is preserved exactly.

### 2.12 Keyword term context — full typed shape now traced

Source: `packages/shared-types/src/contracts/keyword-term-context.ts:45–172`. This list also occurs on ordinary keyword/prose actions; it is not confined to stage blockers. The generic content_term relation cannot represent keep, coverage, ranking or the independent verdicts.

Candidate ASO-owned `listing_work.keyword_term_context` uses tenant/revision FK, PK `(organization_id, revision_id, ordinal)`, ordinal integer >=0, at most 120 ordered rows per source list. Duplicate terms remain distinct. Its parent has `term_context_presence enum absent/null/array`, preserving empty arrays; the exact supported listing/stage-blocker historical parent matrix remains required.

| Source field → column | SQL type / closed values | Presence |
|---|---|---|
| term → term | text, min length 1; exact original case | required |
| direction → direction | enum add/remove/keep | required |
| kind → kind | enum own_brand/competitor_brand/misspelling/category/feature/use_case/audience/seasonal/generic/unknown | required |
| correctedTo → corrected_to | text | nullable/optional |
| demand → demand | numeric, finite; no invented 0–100 bound | nullable/optional |
| difficulty → difficulty | numeric, finite; no invented 0–100 bound | nullable/optional |
| ownRank → own_rank | numeric, finite; source does not require integral | nullable/optional |
| rankObservedOn → rank_observed_on | text; source does not require ISO date | nullable/optional |
| coverage → coverage | enum title/subtitle/keywords/mixed/none/unknown | nullable/optional |
| relevance → relevance | smallint CHECK 1..5 | nullable/optional |
| offCategory → off_category | boolean | nullable/optional |
| worthIt → worth_it | boolean | nullable/optional |
| rationale → rationale | text <=90 graphemes; empty allowed | required |

Each of the nine nullable/optional fields has its own `<column>_present boolean NOT NULL`; absent requires value NULL, while present may carry NULL or a value. These are nine named fields, never a map. Preserve source order and all independent verdicts; no recomputation or clamping. Grapheme validation uses a pinned domain codec and fixtures, not SQL character length pretending to count graphemes. The old Zod item parser strips unknown keys, so migration checks raw key sets first. Unknown fields preserve source and block.

Immutable after sealing; same revision/asset/organization erasure as owned content. Domain decoder and combined historical-purpose constraints must be tested before migration use.

---

## 3. B11 — Import attribution, exact replay and command order

### 3.1 Audit anchors

| Candidate relation | Concrete fields / constraints |
|---|---|
| history.import_run | organization_id + id text PK; importer_version integer NN; decoder_version integer NN; source_pin char(40) NN; census_id text NN; operator_principal_snapshot text NN with established actor erasure policy; started_at timestamptz NN; finished_at timestamptz NULL; outcome enum completed/aborted NULL. One tenant-bounded invocation; unfinished is a crash/recovery fact, not success. No global operational row containing mixed-tenant history |
| history.import_component | Retain ledger fields, replace import_command_id with import_run_id tenant FK; component_key char(64) NN; component_fingerprint char(64) NN; mapping_digest char(64) NN; fingerprint_version integer CHECK=1; member_count integer >0; imported_at timestamptz NN. UNIQUE(org,component_key); successful complete transactions only |
| history.component_command | organization_id, component_id, ordinal integer >=0, command_id; all NN. PK(org,component_id,ordinal); UNIQUE(org,command_id); tenant FKs. Command kind comes from the immutable command row; do not duplicate its authoritative value |

History-only/personal-only components may have zero command links. Their full mapping digest, source snapshots and run attribution are mandatory. No targetless create command. Invocation audit may survive a failed component transaction without implying that any component was imported. Erasure follows tenant ownership and the accepted mixed-component scope rules; identify/redact operator snapshots under the same established principal policy before DDL acceptance.

### 3.2 Replay is a joint validation, never an early return

Command keys bind component identity + deterministic ordinal + command kind through the explicit LP tuple codec. Request digests bind complete typed mapping, source fingerprint, admitted captures, target versions and each command payload, including importer/decoder version. mapping_digest binds the same complete plan for zero-command imports. Individual command payload codecs remain an enumerated contract, not `canonical payload` as an undefined primitive.

Under deterministic ordered locks: (1) validate every reused command key/digest before any semantic replay; mismatch is idempotency_mismatch. (2) Independently re-discover exact source closure and consumed dependency versions, then validate every source's successful ownership. A new command key cannot bypass source_changed; mixed/overlapping owners are component_conflict. (3) Replay only when the whole source set, mapping, capture set and complete command plan agree with the recorded successful receipt. Never return after the first matching member. (4) Otherwise insert a new complete component atomically.

If a reused command key has a different digest, keep idempotency_mismatch as the stable primary refusal and never overwrite its original receipt. A separately authorized read-only preflight report may also record a **verified** source_changed finding. Do not inspect source content before authorization, append an untyped diagnostic bag, or let a supplementary diagnosis change replay precedence. A combined closed diagnostic schema is future contract work; no receipt mutation is implied by this review (L4).

Carry ledger §9.2's old-writer freeze, in-flight-effect accounting, stable dependency snapshot and sorted source locks. Revalidate incoming as well as outgoing edges at apply. Uniqueness conflict rolls back and re-enters the checks; it never means automatic success. No provider I/O inside import. Changed mapping is an explicit separately designed reconciliation, not a changed key trick.

### 3.3 One component transaction, exact version chain

1. Create all admitted tickets at version=1/attention_version=1 with migration principal, channel=migration. Initialize valid sealed heads, content, aliases and proved relationships before commit. A NULL-head skeleton may exist only transiently inside the transaction; executable work still needs every current baseline/shape gate. Historical-only materialization is subject to §4's pending matrix.
2. Apply source-proven schedules to targets **while they remain open**, before decline/supersession. Preserve inadmissible or uncertain dates as claims; never guess timezone.
3. Apply supported reject/supersede transitions in deterministic target order. Each reads the exact preceding revision/version; do not hardcode expected_version=1 after scheduling. A historical rejection needs the explicit non-authorizing command/head branch in §4; do not fake a complete proposal to pass old guards.
4. Apply import archive placement only for proved shared source placement after same-work reconciliation and the effect gate. `opportunity_backlog.archived_at/archived_by` are actual fields; `pending_action` has deletedAt/deletedBy and **no archived_at**. Do not translate deletion or a personal archived overlay into shared archive. An archived catch-up/replaced predecessor alone cannot hide an active staged card in the same work class. Where archive is admitted, issue an `attention_version`-preserving migration archive command after terminal dispositions, with exact version/head, previous/result archived_at and importer actor. Retain the original occurrence/actor separately as the history claim; command accepted_at and result_archived_at describe migration-time placement, not the old event. Never backdate command acceptance to make those meanings coincide. Historical_deleted remains a tombstone and does not receive a fabricated archive command.
5. Write personal reads, immutable historical facts, component_command links and successful component marker in the same transaction. Historical actors belong to claims; commands keep importer attribution. No historical approval, execution, attempt or Usage charge is created.

Atomic commit or no component facts. Blocked preflight has no successful marker or accepted mutation command. Scheduling preserves `attention_version`; meaningful decision changes follow existing `attention_version` rules. Example owed: **the same ticket** has an inherited schedule and rejection, not merely separate scheduled and rejected tickets.

---

## 4. B12 — Historical tickets: admission and future work

The submitted `record_kind={work,historical_completed,historical_deleted}` and enum-only historical purpose are **not accepted as complete**. A legacy completed claim does not establish provider finality; immutable historical kind also strands later work at the permanent review identity. Existing head checks require a sealed proposal, Core loads it before ordinary commands, and the list INNER JOINs it. Merely excluding historical purpose from head adoption makes the advertised create/reject/archive path invalid.

A [concrete companion matrix](Fload-Inbox-R3-Historical-Ticket-Matrix.md) now specifies the narrow proposed fix using existing create/reject/supersede/archive/restore/assign/revise commands, with no new command kind. This is reviewable contract work, not implemented or accepted DDL.

| Proposed record kind / decision | Head and authority | Allowed path |
|---|---|---|
| work / existing decisions | Sealed proposal, existing complete baseline and exact approval rules | Existing lifecycle branches retained; discretionary restart uses the companion admission gate |
| historical / open | Sealed historical display head; NULL approval; no approval/execution rows | Archive/assign/restore(placement); canonical baseline record_observation under §4.1; authorized revise/edit can adopt fresh work |
| historical / declined | Same non-authorizing historical head and no approval/execution | Archive/assign; explicit restore(reconsider) to historical/open; qualified source-change record_observation and replace_declined only with every v15 meaningful-change guard |
| historical / superseded | Same head; exact valid successor required | Archive and follow successor; no reopening |
| historical_deleted / open, declined or superseded | Historical display head, no approval/execution; hidden from lists after full effect disposition | Explicit restore(unhide) to historical, preserving decision/head/successor; it does not also reconsider a decline |

Add previous_record_kind (nullable only on create) and result_record_kind NOT NULL to the existing action_command_target, with exact locked before/after values. Create sets the initial kind; only explicit deleted-record restore changes historical_deleted→historical, and eligible revise changes historical→work. Work never transitions back to historical. The source snapshots and deletion/rejection claims remain immutable.

**Same-ID fresh work:** historical/open + present authorized revise/edit + complete fresh proposal + any baseline required by its domain/operation + exact head/version/source/identity/effect checks → work/open on the same ID and creation key, current_approval_id still NULL. The new proposal is a separate sealed revision; preserve the old display revision. Increment `version` and `attention_version` once through revise. Apply the companion’s admission guard and slot classification before accepting the adoption; a positive slot delta requires capacity for manual as well as automatic new work. `attention_version` is an unread change counter and never measures occupied admission slots. Background discovery cannot perform that edit or create a duplicate ticket. Declined human reconsideration is a separate explicit restore first; deleted declined records need an unhide first without removing suppression. Automatic replacement requires comparable source-change proof; unknown legacy preimages remain suppressed.

The committed-head constraint becomes this finite matrix, never a blanket removal of proposal checks. Initial create may use the existing bounded uncommitted NULL-head skeleton but must insert/seal the admitted historical display leaf and matching command target before commit. Migration reject/supersede are restricted to newly created historical identities with conserved exact claims and importer attribution. Historical kinds receive no schedule; source dates remain claims. Ordinary approval, iteration, execution, dependency completion and recovery commands refuse historical heads. Personal reads are separate.

**Remaining boundary:** the matrix applies only where a strict historical leaf already exists. Full collection adoption with unknown membership remains unsupported until exact parent/child atomic proposal rules exist; source and historical-group identity survive. Missing successors cannot create a superseded state. The companion lists every permitted branch, pins, actors, crash/replay and `attention_version` expectations.

Both historical completion and deletion require a positive, recorded disposition of all possible issued effects in the component. Absence of best-effort logs/hints is not proof of no effects. Any unresolved effect remains visible in the cutover recovery/blocker process and prevents source retirement; not a hidden terminal historical ticket.

**Read model rule:** one ticket counts once. If historical source-reported completion is shown in a Done group, it must remain explicitly unverified and cannot satisfy success/dependency metrics. Placement is undecided: existing Done groups with an explicit legacy-source label, or a new labelled group within the same list. Neither option is accepted here; both exclude these rows from actionable/in-progress and verified-success totals. No new tab is introduced. Placement selects the latest proved relevant occurrence timestamp for that ticket; ties use stable source-kind/source-ID/claim-ID ordering. Unknown occurrence stays “Date unknown”, never import time. The exact same eligible relation, selector, NULL order and ticket-ID tiebreaker drives lists, counts and cursors. Claims must not multiply counts.

**Visible suppression policy (L6):** an imported currently effective decline with an unknown original fingerprint preimage stays suppressed even if the review now looks edited. The current source filter can admit a changed fingerprint when no matching rejection receipt remains; that is weaker evidence. The conservative new rule requires explicit present reconsideration for this legacy case. Explain that reason and offer the authorized reconsider action; do not silently present it as ordinary automatic drafting or fabricate a new original snapshot. Later valid declines use their own exact source, so this is not a permanent veto from old history.

Unresolved personal overlays stay non-ticket facts (`resolution=pending_review`) visible to authorized operators and the target detail, not shared workflow or counts. A present authorized shared command may resolve one with the current actor/time. User erasure deletes personal annotations. No correlation-based historic decision inference.

**Gate:** the full proposed matrix and same-ID transition are now written in the companion; until reviewed and validated, B11/B12 materialization is blocked for these rows. Conserving a source does not require pretending the proposed storage already works.

---


### 4.1 Follow-up command fields and provenance

The companion now explicitly permits canonical record_observation for historical/open preparation and qualified historical/declined source-change capture, using the carried refresh boundary/read-start/evidence fields. It records evidence only, never a head or approval. The failed-perform-reopen guard remains unchanged. Restore now has required restore_mode=placement/reconsider/unhide in its strict payload, action_command column and digest, checked against exact before/after kind/decision. The existing revise target links the previous historical head to the new proposal; no new adoption column or generation/effect evidence is invented. Full matrices and source-bound read ordering are in the companion.

## 5. B13 — Old links and evidence-scoped historical groups

`resolveLegacyLink(org, closed_namespace, old_id)` returns a strict discriminated union; authorization precedes existence disclosure.

| Outcome | Typed payload / admission |
|---|---|
| ticket | action_id, historical_membership_known; tenant action_alias, only ordinary ticket namespaces |
| domain_row | domain_kind enum agent_activity/review_history/recommendation/recommendation_variant/capability_execution, row_id; domain-owned scope resolver, never ID existence alone |
| historical_group | group_id, membership_known=false, ordered evidence associations with member identity, source evidence reference and proof class |
| unavailable | reason enum erased/never_imported/blocked/unknown; specific reason only with retained authorized evidence, otherwise unknown |

Reused pending_action_batch and review_draft_batch URLs take the historical_group path **before** ordinary ticket aliases; their union of associations is never one approval-time manifest. Unknown cross-tenant IDs return unavailable(unknown).

Candidate `history.legacy_group`: organization_id + id text PK; namespace enum pending_action_batch/review_draft_batch NN; group_key text NN; asset_id nullable tenant FK with proven parsed/source scope; UNIQUE(org,namespace,group_key). No stored first/last evidence timestamps: derive them from retained evidence with known source-time provenance; import capture time is separate. A key referenced by any source resolves even with zero members.

Candidate `history.legacy_group_member`: organization_id, group_id text FK, evidence_record_id text FK source_record, evidence_ordinal integer >=0, member_namespace enum pending_action/review_draft, member_old_id text, proof_class enum association/recorded_manifest/decision_pinned_manifest; all NN. PK(org,group_id,evidence_record_id,evidence_ordinal). Checked source/member/proof matrix; preserve duplicates and source order. Every member/evidence link is tenant- and scope-qualified. One rejection uses ordinal 0 as a local association index, never an invented historical batch ordinal.

Rejection rows prove separate draft rejections, not a shared batch decision: there is no recorded transaction/manifest ID to reconstruct that group. Equal user/time/reason does not help. Recorded post_batch content proves recorded membership; decision_pinned_manifest additionally needs independent exact decision-to-manifest proof. Its concrete proof reference must be defined before that enum branch is enabled. Until then only association and recorded_manifest are admitted. Group-level membership remains unknown even when an individual evidence record contains a proved manifest.

Facts append immutably; reusing a group key never rewrites earlier evidence. Asset erasure requires proved scope and the accepted mixed-component rules, not unconditional nullable-FK cascades. Member evidence erasure removes its associations; derived first/last dates update from surviving evidence. No undefined erasure log is used to assert erased versus unknown.

Retained review history needs a durable native identity/scope authorization path independent of the live review row. The current route proves access through live review+asset and returns not found after disappearance. Removing its cascade alone is insufficient; typed snapshot identity and the exact tenant-access join remain retained-domain design work. Do not duplicate global history per tenant merely to make an existence check appear safe.

---

## 6. Schema delta and consolidation status

This pass does not approve ten additional tables. The submitted arithmetic counted ten **candidates relative to the ledger's candidates**, not ten tables relative to shipped main. Keyword context adds another concrete fact family; provider aliases may reuse existing native targets. Final physical consolidation follows owner, determinant, cardinality, lifecycle and erasure, not document section count.

| Owner | Concrete delta under review | Decision |
|---|---|---|
| Actions | Historical head/capture matrix, explicit restore_mode, existing revise-target adoption edge and record-kind command snapshots | Concrete companion proposal; B11/B12 acceptance/validation open |
| Actions aliases | backlog_item/stage_blocker_card only | Native ASC/Play namespace additions removed |
| Reviews | Import rejection claims; exact snapshot links; runtime source fingerprint evidence | Preserve repeated facts; no fingerprint uniqueness or bare preimage flag |
| Listing / agent domains | Full gloss pins, page_views, original content, collection facts, partial-policy history, 13-field term context | Concrete fields mapped; combined historical leaf matrices still required |
| Providers | Play pairing proof, ASC release/verification claims, concrete before-listing snapshots | Native facts remain provider-owned; scope, state catalog and decoder gates explicit |
| Migration history | Tenant import run, component plan digest, ordered command links, legacy group/evidence associations | No targetless commands, duplicate command-kind authority, generic field bag or group-as-approval shortcut |
| Retained domains | Typed review/ASO/calibration facts and authorized readers | Not waived by retaining domain ownership |

No impact/risk mirror is added to Core. No new JSONB, EAV, serialized object text or generic provider payload. Historical tables are not an alternative workflow engine. Closed source claims cannot authorize execution.

---

## 7. Retained-domain closure (not waived by D)

| Owner | Must land before contract removal | Anchor |
|---|---|---|
| Reviews | strict schema for `review_history` snapshots (`developer_response`, `draft_reply` typed); remove the `review → rejection/history/draft` cascade for conserved history; fence `draft-helpers.ts:49–56`, `agent-processing.ts:652–654, 1044–1046`; stop the 30-minute scheduler (`review-sync-scheduler.service.ts:27`) and manual/in-flight executors during cutover | RD1, F1 |
| ASO | typed `proposal`/`evidence` schemas; replace the `'auto_detected'` user-FK sentinel with a typed observation fact; remove secondary approval/application authority from recommendation statuses; convert `reset-inbox-aso.ts:182–190` hard deletes | RD3, RD6 |
| Work execution | `capability_execution` documented as best-effort with mutable verdicts; readers converted: `weekly-report/data.ts:410–429`, `end-of-month/data.ts:1214–1241` to tenant-qualified alias/history reads; calibration feed derived from durable Actions facts | RD4, RD5 |
| Inbox | `inbox-iteration.service.ts` deletes and admin `reset-inbox-aso`, `reset-agent-state`, `purge-removed-agent-history` fenced at cutover | F1/F2 |

---

## 8. Data-dependent gates (B8), kept separate

1. Row populations per source/status; legacy `review_draft` overlays; `agent_activity` overlays; `expired` actions; numeric-form Play review rows and bridge coverage; conflicting iOS Adam-ID candidates; `'auto_detected'` rows and the actual FK state.
2. Timestamp provenance per naive column and period: Drizzle `Date` writers are UTC (established); server-default columns need writer/transaction provenance; unknown cohorts remain `time_provenance_unknown` and block their conversion. Paired defaults corroborate a row, never a period.
3. Fingerprint mismatch counts by `action_key` (D7) and legacy rejection preimage availability.
4. Component closure stability under the freeze; late legacy provider responses.
5. Production `TimeZone` and any historical session overrides.

---

## 9. Required proof and remaining work

| Gate | What is now concrete | Still needed before closure |
|---|---|---|
| B9 identity/edges | Core/provider alias boundary; tuple collision rule; E14 closure; no automatic request-kind union | Finish E4 strict variant/child codec from the now traced writers; prove ASC association and Play scope/history/evidence/erasure references |
| B10 destinations | 13-field termContext; successful verification data; null-safe gloss check; rejection cardinality; no guessed actor or executed-content proof | Historical-purpose per-leaf matrices, exact snapshot/proof FKs, closed native-state catalog, all strict nested decoders |
| B11 import | Tenant audit anchor, full-plan replay, create→schedule→terminal order | Exhaustive command payload codecs, locks/constraints and historical-head command integration |
| B12 historical work | No false Done, invisible uncertainty or permanently stranded identity | Review/validate the companion matrix; historical leaf and collection-adoption integration; final product bucket |
| B13 URLs | Historical group precedence, evidence-scoped keys, truthful missing outcomes | Decision-proof reference branch; retained review identity/authorization/erasure schema and route closure |
| B8 data | Separate from these design gaps | Authorized representative census, time/provenance cohorts, actual conflicts, rehearsal |

Mandatory fixtures include:

- Same-work backlog plus generation handoff yields one canonical target; E14-only lineage change invalidates apply; numeric/package identity and hash collision cannot merge unrelated work.
- Two rejections with the same review fingerprint preserve both actors, times, reasons and draft snapshots. Unknown original preimage stays suppressed. No actor is inferred from event shape.
- All 13 keyword-context fields round-trip, including keep, duplicate terms, fractional ownRank, explicit null versus absent and empty array; unknown keys block before forgiving parse.
- Ready gloss with either pin missing fails; successful verification keeps all three nullable/key-presence facts; typed before-fields preserve empty strings without field/value storage.
- Same source with changed command/capture/mapping digest fails replay. New key cannot bypass changed source. Overlapping components serialize. Crashes leave either one whole component or none.
- Schedule and reject on the same ticket use the correct ordered version chain. Historical-only decline/head and same-ID adoption require open and qualified declined capture tests, stale boundary/read refusals, mode mismatches and explicit adoption-reference constraints before acceptance.
- Deleted/completed claim with an unresolved sibling effect blocks historical materialization and source retirement. Historical source claims do not satisfy verified success or dependencies. Counts use one ticket and the same predicate as pagination.
- Reused/empty group URLs remain resolvable; equal-time rejections never form a decision manifest; lost evidence does not invent erased status. Authorized history survives ordinary review disappearance without leaking across organizations.
- User/asset/organization/shared-domain erasure follows explicit scope and immutable-fact exceptions; all old writers/report joins are converted before removal.

These are **test requirements, not test results**. Only document integrity, preserved input/worktree fingerprints and public artifact validation are run in this pass. Final consolidated DDL/types, R2 provider codecs, real-role tests, concurrency/crash tests and migration rehearsal remain required.

Implementation remains paused. Public documentation publication is authorized; no application change, migration, provider action, source retirement or production deployment is part of this pass.

**Related work now tracked:** [Standing cap, month grouping and cleanup coordination](Fload-Inbox-R3-Parallel-Work-Coordination.md). These live changes affect the final admission/count predicate and the migration census; they do not authorize this task to repeat cleanup or regenerate reports.
