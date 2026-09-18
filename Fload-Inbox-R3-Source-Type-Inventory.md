# R3 source type inventory

Source pin: `e2cc156994855e401a83399fbb4c3d7be5194875`. Read-only source audit; no runtime or historical-data census. This records source facts, not approved destination DDL. Optional TypeScript properties mean absence is permitted by the declaration; they do not establish a database NULL rule. A TypeScript interface does not validate persisted JSON or prove historical keys are exhausted.

## 1. Locale evidence

Source: [localization.ts:4–20](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/packages/shared-types/src/aso/localization.ts#L4).

| Type | Field | Source type | Optional |
|---|---|---|---|
| LocaleDemandSignal | downloads | number | yes |
| LocaleDemandSignal | revenueUsd | number | yes |
| LocaleDemandSignal | impressions | number | yes |
| LocaleDemandSignal | pageViews | number | yes |
| LocaleDemandSignal | reviewCount | number | yes |
| CompetitorMarketSignal | strength | number | no |
| CompetitorMarketSignal | localizedCompetitorCount | number | yes |
| CompetitorMarketSignal | topChartCount | number | yes |
| CompetitorMarketSignal | estMarketDownloads | number | yes |
| CompetitorMarketSignal | topCompetitors | string[] | yes |

The declarations do not specify integer, nonnegative, finite-number, decimal-scale, or upper-bound constraints. A destination conversion must specify and validate any narrower SQL representation. `impressions` means summed daily exposure, not period-unique users; `pageViews` is separate exposure and must not be merged into impressions.

Actual writer behavior:

- [locale-discovery.ts:180–195](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/locale-discovery.ts#L180) accumulates all **five** demand quantities by default storefront locale, filling missing constituent values with zero. It separately records contributing country codes.
- [locale-discovery.ts:206–231](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/locale-discovery.ts#L206) accepts positive competitor strength, retains the strongest country's quantitative evidence, and merges distinct competitor names, taking at most five in this writer. That five-name limit is not a constraint on the interface or proof of historical storage.
- [locale-hypothesis.ts:137–151](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/locale-hypothesis.ts#L137) carries locale, language, reasoning, score, and optional demand, demandCountries, competitorMarket, and marketResearchNote into request evidence.

## 2. Gloss content and correspondence pins

Source: [localization.ts:46–72](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/packages/shared-types/src/aso/localization.ts#L46).

| ListingGloss field | Source type | Optional |
|---|---|---|
| title | string | yes |
| subtitle | string | yes |
| promotionalText | string | yes |
| keywords | Array<{ word: string; meaning: string }> | yes |

Each keyword entry requires both `word` and `meaning`. The declaration does not impose unique words, nonempty strings, or an array bound. Conserving the existing array means preserving order and repeated entries unless an independently proven transformation allows otherwise.

`GeneratedLocaleMetadata` separately allows the optional metadata strings `title`, `subtitle`, `description`, `keywords`, `promotionalText`, `shortDescription`, `whatsNew`, and `supportUrl`. Its `rationale` and `keywordAnalysis` are required strings; `englishGloss?: ListingGloss`; `qualityGateSkips?: { naturalness?: true; fidelity?: true }`. A keyword string in listing metadata is not the same fact as the ordered keyword translation pairs.

Actual storage fields in `pending_action.params` and `aso_recommendation_variant.proposal`:

| Field | Writer value/type | Presence rule in inspected writer |
|---|---|---|
| metadata | Record<string, string> | Written during draft revision |
| metadataRevision | string | Written during draft revision; generated using randomUUID() |
| englishGloss | ListingGloss | Present on successful refresh; removed when invalidated or unavailable |
| englishGlossRevision | string | Present on successful refresh, equal to that refresh's metadata revision |
| englishGlossStatus | 'updating' / 'ready' / 'unavailable' | updating while needed; ready or unavailable after refresh; may be absent when no gloss is needed or in older rows |

Evidence: [update-locale-draft.ts:106–113](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/update-locale-draft.ts#L106), [333–399](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/update-locale-draft.ts#L333), revision creation at [724](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/update-locale-draft.ts#L724) and [840](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/update-locale-draft.ts#L840).

These are known writer values in open JSON storage, not an existing persisted SQL enum. The refresh updates only rows whose `metadataRevision` still equals its input revision. The inbox reader accepts `ready` only with matching metadata/gloss revisions, while separately retaining compatibility for old rows with none of the three pins: [inbox.service.ts:4410–4438](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/inbox.service.ts#L4410). Do not discard these pins and infer that a surviving gloss describes the latest draft.

## 3. Unblock verification and finalization

Source: [agent-request-unblock.service.ts:34–75](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/agent-request-unblock.service.ts#L34).

Exact unions:

- `VerificationOutcome = 'editable' | 'not_editable' | 'uncertain'`
- `VerificationReason = 'missing_asset' | 'missing_connector' | 'cached_fallback' | 'empty_response' | 'timeout' | 'live_error'`
- Verification source, when present: `'live_asc_release_state'`
- Verification transport, when present: `'api' | 'scraper'`

| AgentRequestUnblockVerification field | Source type | Optional |
|---|---|---|
| resolved | boolean | no |
| message | string | no |
| verificationSource | 'live_asc_release_state' | yes |
| verificationOutcome | VerificationOutcome | yes |
| verificationReason | VerificationReason | yes |
| transport | 'api' \| 'scraper' | yes |
| fetchedAt | string | yes |
| syncAttempted | boolean | yes |
| syncError | string | yes |
| data | Record<string, unknown> | yes |

The outer source type is **not fully closed** because `data` aliases an open record. Listing the enums does not finish that nested decoder. Time strings are declared as strings here; their complete historical formatting is not established by this type.

The specialized [verifyAsoEditableRelease return contract:1043–1057](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/agent-request-unblock.service.ts#L1043) makes `verificationSource`, `verificationOutcome`, and `syncAttempted` required in addition to `resolved` and `message`; other listed values remain optional. This tighter writer path must not be imposed on every older enclosing verification object.

`UnblockFinalizationState` exact declared fields:

| Field | Source type | Optional |
|---|---|---|
| blockerCode | string \| null | no |
| status | 'pending' \| 'finalized' | no |
| targetActionIds | string[] | no |
| completedAt | string | yes |
| verification | AgentRequestUnblockVerification | yes |
| attempts | number | yes |
| lastAttemptAt | string | yes |
| nextAttemptAt | string | yes |
| lastError | string | yes |

No source enum closes `blockerCode` in this declaration. A destination cannot infer new authorization from `resolved` or `finalized`.

## 4. Review batch handoff acknowledgement

Source: [inbox-work-actions.ts:298–337](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/packages/shared-types/src/contracts/inbox-work-actions.ts#L298).

`ReviewBatchUnclaimableReason` is exactly:

`'already_sending' | 'already_sent' | 'delivery_budget_spent' | 'no_longer_open'`

`no_longer_open` includes missing rows, a row belonging to another app, or changed state. It does not distinguish those cases and cannot safely be converted into a more specific historical reason.

`ReviewBatchQueueAcknowledgement` requires every field:

| Field | Source type |
|---|---|
| assetId | string |
| queuedDraftIds | string[] |
| unclaimable | Array<{ draftId: string; reason: ReviewBatchUnclaimableReason }> |
| contentDigest | string |

[The builder:19–43](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/reviews/batch-queue-acknowledgement.ts#L19) sorts each list by draft ID and computes `sha256:` plus hex over the asset ID and both lists. It does not itself deduplicate inputs. Preserve each outcome and the recorded digest. This is evidence of queue handoff/accounting, not proof that replies were published.

## 5. Exact ASC mutation field catalog

Three distinct contracts must not be conflated:

1. General ASO apply field enum: `name | title | subtitle | shortDescription | description | promotionalText | keywords | whatsNew`. [experiments.ts:23–47](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/packages/shared-types/src/aso/experiments.ts#L23).
2. Canonical ASC acknowledgement **builder** fields: `description | keywords | name | promotionalText | subtitle | supportUrl | whatsNew`. Each content value is an optional string. [listing-mutation-acknowledgement.ts:5–29](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/listing-mutation-acknowledgement.ts#L5).
3. Exported `ASOListingMutationAcknowledgement.fields` is only `string[]`, not either enum. [experiments.ts:87–96](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/packages/shared-types/src/aso/experiments.ts#L87).

The canonical writer never outputs `title` or `shortDescription` as ASC acknowledgement fields. It includes `supportUrl`, which is absent from the general apply enum. The expected-acknowledgement helper maps `after.name ?? after.title` to canonical `name`: [listing-mutation-acknowledgement.ts:60–86](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/listing-mutation-acknowledgement.ts#L60).

| ASOListingMutationAcknowledgement field | Source type | Optional |
|---|---|---|
| action | 'apply_listing_changes' \| 'update_promo_text' \| 'create_locale' | no |
| locale | string | no |
| versionId | string | no |
| transport | 'asc_api' \| 'asc_web' \| 'asc_api_and_web' | no |
| fields | string[]; builder emits the seven canonical names above | no |
| contentDigest | string; builder emits sha256: followed by hexadecimal digest | no |

The builder normalizes only string values, retaining empty strings and emitting canonical field order. Its digest binds `locale`, `versionId`, and actual normalized field content; the digest input does **not** include action, transport, app ID, account ID, or organization ID: [builder:32–57](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/listing-mutation-acknowledgement.ts#L32). Those missing identity facts need independent retained evidence; never infer them from the hash alone.

Actual mutation input differences:

- General ASC apply accepts optional `name, subtitle, description, promotionalText, keywords, whatsNew`; [asc-promo-text-writer.ts:76–90](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/asc-promo-text-writer.ts#L76). The apply service forwards these six fields and resolves title/name to name: [apply-service.ts:223–243](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/apply-service.ts#L223).
- Create-locale metadata accepts those six plus optional `supportUrl`: [asc-promo-text-writer.ts:559–577](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/asc-promo-text-writer.ts#L559). This writer can backfill required metadata before I/O and acknowledgement, so receipt content must not be assumed equal to an earlier draft without exact comparison: [614–680](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/asc-promo-text-writer.ts#L614), [721–737](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/asc-promo-text-writer.ts#L721).
- Promo updates require `promotionalText: string`; their acknowledgement contains that field: [55–67](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/asc-promo-text-writer.ts#L55), [145–155](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/asc-promo-text-writer.ts#L145).

Unknown historical acknowledgement field strings remain a decoder blocker unless another evidenced writer explains them. Widening a destination enum to speculative names is not conservation.

## 6. Two identity corrections

**Requested agent.** The pinned orchestrator stores the chosen exact target as `agent_run.agentId`, then retains that run as `pending_action.resultRunId`: [orchestrator-agent.ts:1539–1542](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/agents/implementations/orchestrator-agent.ts#L1539), [1574–1587](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/agents/implementations/orchestrator-agent.ts#L1574). Where the retained same-tenant run proves it, prefer that target. A currently unique agent with the same asset/type might be a replacement, so current lookup cannot establish historical identity. Missing proof remains unavailable; it must not select a new execution target.

**Review identity.** The preserved, uncommitted prototype helper `reviewWorkCreationKey` uses `(organizationId, assetId, store, reviewId)` with a versioned digest; it is not present at this main-source pin. Accepted behavior v15 instead identifies reviews by `(organizationId, store, providerAppId, providerReviewId)` (the review identity section). Keep these baselines explicit. An importer should follow the accepted canonical identity and map proven prototype/source aliases to it; silently reinstating the prototype asset-based key would undo that decision. No destination-key implementation or collision proof is supplied by this inventory.


---

## 7. Review follow-up: policies, nullability and per-store identity

Read-only verification at `e2cc156994855e401a83399fbb4c3d7be5194875`. Accepted identity authority: revised design v15, line 183. No provider calls, live data, tests, or platform edits. Source behavior establishes possible shapes; it does not establish which historical rows exist.

### F6 — Partial approval policies: confirmed; defaulting needs a conservation rule

The source interface makes all three keys optional. The normalizer keeps each valid key independently and discards invalid values; it does not fill defaults. More decisively, the persistence service stores `input.approvalPolicy ?? {}` directly. A caller-supplied `{ execute: 'await' }` can therefore be persisted without the other keys.

Evidence:

- [Core ApprovalPolicy:110–118](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/packages/core/src/agents/agent-request.ts#L110); [normalizer:428–445](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/packages/core/src/agents/agent-request.ts#L428).
- [Direct persistence:agent-request.service.ts:234–249](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/agent-request.service.ts#L234).
- [Caller passes optional policy:listing-change-hypothesis.ts:143–147](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/listing-change-hypothesis.ts#L143).

Defaults are actual behavior, not only comments: [requiresApprovalToEnter:380–389](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/packages/core/src/agents/agent-request.ts#L380) treats missing hypothesize as automatic, and missing draft/execute as requiring approval.

**Smallest correction:** explicitly block partial objects from the new all-present/all-absent active tuple until their typed historical representation is approved. Preserve their exact known source keys and values as non-authorizing evidence through the component conservation gate. Do not silently run the forgiving normalizer on source JSON: discarded invalid keys/values are unhandled source facts.

If default expansion is selected instead, retain original key presence per stage separately from the derived complete policy. A single `policy_defaults_applied` boolean cannot reconstruct whether an explicit `await` was supplied for draft, execute, both, or neither. In either approach, old policy settings are not a historical grant or permission to execute new work.

### F7 — Nullable finalization blocker: confirmed

The proposed `blocker_code enum NN` contradicts both the type and runtime reader:

- [UnblockFinalizationState:66–75](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/agent-request-unblock.service.ts#L66) requires the property but allows `string | null`.
- [Reader:493–500](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/agent-request-unblock.service.ts#L493) explicitly accepts null and returns it unchanged. A missing property is rejected by this reader; missing and explicit null are not interchangeable.
- [Resolution input:267](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/agent-request-unblock.service.ts#L267) falls back to the request's nullable blocker. [Marker construction:345–350](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/agent-request-unblock.service.ts#L345) preserves that value.

**Smallest correction:** declare the historical field nullable, preserve explicit null, and keep nonnull unknown strings at the existing closed-decoder gate until their vocabulary is evidenced. Do not invent an “unknown” enum member or replace null with the current request blocker. This confirms a representational requirement; no claim is made that null markers exist in production.

### F9 — Per-store review identity: confirmed; Android appId is demonstrably mixed

Accepted v15:183 uses `(organization_id, store, provider_app_id, provider_review_id)`, independent of asset aliases. It does not by itself define which Play app identifier occupies `provider_app_id`. Pin the following store-specific rule before B9 is closed:

| Store | Proposed canonical provider_app_id | Source provider_review_id | Identity aliases that must remain distinct |
|---|---|---|---|
| ios | Apple Adam app ID as text | Exact source `review.id`, populated by String(fetchedReview.id) | Asset ID, connector/account ID, and official ASC customerReviews resource ID are separate facts |
| android | Android package name as text, preserving its source spelling | Exact fetched Play review ID stored in `review.id` | Console numeric app ID and asset ID require explicit bridges; neither is the package itself |

The **Play package choice is a precise proposed completion of B9**, consistent with existing reply targeting; it must not be described as already stated explicitly by v15. Do not alternate between numeric ID and package name in the permanent key.

#### Actual write paths

**iOS:** [ios-reviews.ts:182–205](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/worker/scraping/executors/reviews/ios-reviews.ts#L182) stores the fetched review ID and resolved `reviewAppId`; [293–296](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/worker/scraping/executors/reviews/ios-reviews.ts#L293) inserts that object. [resolveIOSReviewAppId:731–764](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/worker/scraping/executors/reviews/ios-reviews.ts#L731) supplies asset/linked/provided/metadata candidates to [the selector:53–67](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/reviews/ios-app-id-resolver.ts#L53), which accepts a trimmed 5–15-digit Adam-ID candidate. This is executable selection logic, not merely a schema comment. Conflicting retained candidates still need migration adjudication; the runtime's first-match precedence is not historical proof.

**Android worker:** [android-reviews.ts:103–120](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/worker/scraping/executors/reviews/android-reviews.ts#L103) takes `appId` from the job and branches on whether it is numeric. [460–473](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/worker/scraping/executors/reviews/android-reviews.ts#L460) stores that **same input unchanged** alongside `fetchedReview.id`. No assignment normalizes the stored app ID to a package in that path.

**Scheduler:** [review-sync-scheduler.service.ts:275–315](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/review-sync-scheduler.service.ts#L275) selects `asset_data_source.appId` and copies it into the Android review job. It does not enforce a numeric-only source constraint.

**Alternative sync:** [review-sync.service.ts:1737–1749](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/review-sync.service.ts#L1737) chooses the linked Google Play data source's `appId`; [852–855](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/review-sync.service.ts#L852) stores it. Its “numeric” comment does not add validation.

#### Evidence for the numeric-ID/package bridge

[google-play-acceptance.ts:390–434](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/worker/scraping/google-play-acceptance.ts#L390) searches a provider apps response by exact package name, then replaces a data source's missing/package-like appId with the matched `numericAppId`. Search package comes from data-source packageName/bundleId metadata, the previous appId, or the associated asset bundleId. This proves why both source shapes can exist and where a paired identity can originate; it does not prove that a particular historical pair survives.

The send path selects `target.packageName` for Android: [send-replies-enqueue.ts:76–102](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/reviews/send-replies-enqueue.ts#L76). [gplay-sync-targets.ts:42–72](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/gplay-sync-targets.ts#L42) reads linked app ID, package metadata and asset googleAppId, scoped to the organization; [127–134](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/gplay-sync-targets.ts#L127) retains both `packageName` and `consoleAppId`. [gplay-package-name.ts:25–46](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/aso/gplay-package-name.ts#L25) returns the first package-shaped candidate, preserving case; it cannot algorithmically derive a package from a numeric ID.

**Smallest migration rule:** freeze the exact retained asset/data-source/provider identity evidence with the source component. A direct package-shaped review appId may supply its package candidate; a numeric review appId requires a matching same-tenant Google Play identity bridge that resolves to one consistent package. Assert the review's source asset/organization and store independently. Conflicting, missing, or merely guessed bridges remain B9-blocked, with source IDs and links preserved. Never resolve by current title, first connector, asset ID alone, or by casting the numeric ID into the package slot. Connector readiness or credentials are not required to conserve proven historical identity and do not confer execution authority.

A current readback predicate is insufficient as the bridge: [reply-readback-targets.ts:55–62](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/reviews/reply-readback-targets.ts#L55) compares `review.appId` only with asset appleAppId/googleAppId, which can miss the numeric Play rows above. Do not turn that failed join into “review absent” or create a second ticket.

Finally, preserve Apple's optional `appleReviewResourceId` separately. [reply-helpers.ts:482–519](https://github.com/fload-ai/fload-platform/blob/e2cc156994855e401a83399fbb4c3d7be5194875/apps/api/src/services/worker/scraping/helpers/reply-helpers.ts#L482) resolves/caches an official API resource ID against the existing review. Do not switch the permanent review key to that value whenever it becomes known; new API-only producers require an explicit equivalent-identity rule before materialization.

