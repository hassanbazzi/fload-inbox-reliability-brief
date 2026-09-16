> Historical source investigation. Retained as dated evidence; use the [current specification](Fload-Inbox-End-to-End-Specification.md), [actual field catalog](Fload-Inbox-Current-Fields.md) and [checkpoint](Fload-Implementation-Checkpoint.md) for the current proposal and its limits.

# Content, provenance, and migration audit

**Source inspected:** `63275b2f51ac5b5a151a9a6683c813423e682785` (latest main pulled 15 September 2026). This is a source investigation, not a production row census. No credentials, provider APIs, application changes, or migrations were accessed or executed in this subtask. A later private aggregate census supplied by the lead agent is addressed at the end. Exact source columns are reproduced below and in `audit-content-source-columns.json`.

> **Current scope:** The live design in `schema-content.sql` includes current supported workflows only. Retired Ads/Product payloads discovered in the census below are migration preservation evidence, not runtime variants. The live schema has no historical-only subtype/column families. Existing experiment-owned regression analysis is referenced, not copied into another evidence table.

## Decisions the final schema needs to encode

1. The thing approved is an immutable **revision of one ticket**. A request to produce drafts is a different approval scope from permission to publish those drafts. A collection can be a ticket; its revision contains an immutable selection of child ticket revisions. Each child is independently visible and independently executable.
2. A listing child targets exactly one store and canonical locale; a review child exactly one provider review; a bid child exactly one Apple campaign/ad-group/keyword. Reusing `pending_aso_locale_<asset>_<locale>` or `review_draft_batch:<asset>` as the identity of every future occurrence must stop. These become historical address aliases, not generators for new identity.
3. Content uses concrete relations and columns. There is no `params`, arbitrary `kind/value`, serialized JSON text, generic property bag, open discriminant, or fallback executor in the replacement. A text field for prose is fine; text encoding a structure is not.
4. Do not add a generic `action_event` table if an immutable command/command-target ledger, immutable revisions, approvals, attempts and observations already carry every fact. A history view can UNION those authoritative records, using stable `(fact_kind, fact_id)` identifiers and deterministic ordering. Historical events with no command need explicit historical observation records; do not label imported evidence a newly accepted command.
5. Historical uncertainty must be represented, not erased. Existing approval stamps often prove only **who/when**, not exact content. Current draft text must not be silently assigned to an old approval. A digest without the bytes can prove a match if a trustworthy byte candidate exists; it cannot recover absent bytes. Store `historical_unpinned` approval scope and require a fresh approval before any further write.
6. No platform deployment can safely contract the old tables until every source row/field is either mapped losslessly or explicitly adjudicated. Unknown source keys are a failed migration precondition. Do not ship a permanent JSON archive, generic key/value table, guessed values, or silent dropping as the escape hatch.

## Current executable content: exact declared fields

All rows below also inherit action organization, asset, actor, rationale, priority, origin, and revision identity from the shared ticket model. Brackets mean an ordered relation in the target, never a JSON array column.

| Current action | Exact declared executor content | Proposed concrete target |
| --- | --- | --- |
| `post_reply` | `reviewId`, `replyText`, optional `mode: send/update` (absence currently means send) | `review_reply_revision`: review identity/observation reference, exact reply text, explicit mode, expected previous developer-response observation for update |
| `post_batch` | `assetId`, nonempty unique `draftIds[]`, optional `draftDigests[{draftId,textDigest}]` | Ordinary parent ticket revision + child membership pins; child replies each use the above. Digests today may cover only a subset; missing pins remain historical uncertainty. |
| `apply_listing_changes` | optional `assetId`, `variantId`, nullable `parentId`, `cycleNumber`; `store`; `locales[locale]{before,after,termsAdded?,termsRemoved?}`; optional `recommendationIds[]` | One listing child per locale; parent pins selection; concrete listing content and baseline snapshot; typed provenance/experiment relationship and term ledger |
| `update_promo_text` | `locale`, `promotionalText`, optional `beforePromotionalText` | iOS listing revision; only promotional-text operation selected, baseline only if actually captured |
| `update_description` | `locale`, `description`, optional `beforeDescription`, optional executor-resolved `packageName` | Android listing revision; package belongs to resolved effect target, not a producer-supplied ambiguous asset identifier |
| `update_short_description` | `locale`, `shortDescription`, optional `beforeShortDescription`, optional executor-resolved `packageName` | Android listing revision with explicit short-description operation |
| `create_locale` | `store`, `locale`, optional `packageName`; `metadata{title,subtitle,description,keywords,promotionalText,shortDescription,whatsNew,supportUrl}` all optional; `dismissedFields[]`; `recommendationId?`, `recommendationIds[]?` | Listing revision with create/update/repair distinction; explicit per-field intent; recommendation links; generated cache never remains parallel workflow authority |
| `revert_experiment` | `experimentId`, optional `assetId` | A new restore ticket, pointing to experiment and concrete frozen restore content per locale. Keep old execute behavior (full experiment, not the informational locales list) explicit during migration. |
| `aso_revert_listing` | `assetId`, exact `capturedAt` ISO instant, nonempty `locales[]` | Resolve the immutable Timescale snapshot collection before approval and copy required concrete content into the durable restore revision. `(asset,capture instant,locale)` is the existing locator, not a nonexistent snapshot collection ID. |
| `review_catch_up_30d` | optional `assetId`, `days` normalized 7–180 default30, `agentMode: manual/full_agentic` defaultmanual | Typed review generation request revision: window days, policy/mode. Resulting replies are linked children, with distinct publication authorization. Keep historical wire-name alias despite configurable window. |
| `generate_review_analysis` | optional `assetId`, `days` normalized 7–180 default90 | Typed analysis request revision with analysis output FK and approved window. Internal durable result differs from public provider publication. |
| `asa_pause_campaign` | positive platform `campaignId` string | Typed campaign revision: operation pause, campaign target |
| `asa_enable_campaign` | positive platform `campaignId` string | Same family: operation enable |
| `asa_update_campaign_budget` | platform `campaignId`, positive finite `dailyBudgetAmount`, required `currencyCode` | Campaign revision: exact decimal monetary amount + ISO currency, frozen before approval; never binary float for storage |
| `asa_update_keyword_bid` | `updates[{campaignId,adGroupId,keywordId,bidAmount,currencyCode}]`, no repeated scoped keyword | One child per target keyword; parent pins children. An executor may transport a safe bulk request, but outcomes remain per child. |
| `asa_create_keyword` | `campaignId`, `adGroupId`, `text`, `matchType: EXACT/BROAD`, `bidAmount`, `currencyCode` | Typed keyword revision; create result records provider-assigned keyword ID as evidence, not preapproval content |
| `asa_add_negative_keyword` | `campaignId`, optional `adGroupId`, `text`, `matchType` | Typed negative-keyword revision with explicit campaign/ad-group scope; current route only writes campaign-level, so unsupported ad-group scope must refuse until supported |
| `asa_delete_negative_keyword` | `campaignId`, `negativeKeywordId` | Same negative-keyword family; negative and targeting keyword IDs must never share ambiguous column semantics |

Source contracts: [inbox work actions](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/shared-types/src/contracts/inbox-work-actions.ts), [ASA work actions](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/shared-types/src/contracts/asa-work-actions.ts), [listing apply content](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/shared-types/src/aso/experiments.ts).

**Important shape discrepancy:** listing apply before/after declares `name` and `title` plus subtitle, shortDescription, description, promotionalText, keywords, whatsNew. Canonical target uses one title/name concept with explicit adapter mapping. If a historical row has both unequal values, migration must refuse to choose silently. New ASC `apply_listing_changes` only supports iOS; its compatibility executor schema still parses Android and strips Android shortDescription from the after-map. Those rows cannot be declared valid iOS work by default.

## Minimum justified concrete content families

These are data requirements for the main agent's canonical DDL, not an additional independently approved schema. Reuse relations where the keys and constraints genuinely match.

| Family/key | Actual columns/facts required | Why separate / where reuse is safe |
| --- | --- | --- |
| Review reply, `revision_id` | `review_identity_id`, `review_observation_id`, `reply_text`, `mode`, `expected_response_observation_id`, `original_ai_revision_id`, `detected_language_name` | One-to-one subtype with exactly one review. Null detected language means unobserved, not English. |
| Listing content, `revision_id` | `store`, `locale`, `operation`, `title`, `subtitle`, `description`, `keywords`, `promotional_text`, `short_description`, `whats_new`, `support_url`; per-field operation enum; baseline observation reference | Eight explicit text columns. Field enum operations distinguish keep/set/clear/dismissed; use DB CHECKs, including allowed store fields and nonempty content. Existing APIs reject some clearing; only expose clear where adapter supports it. |
| Listing explanation/research, `revision_id` | `rationale`, `keyword_analysis`, `operator_instructions`, `source_fingerprint`, `naturalness_check_skipped`, `fidelity_check_skipped`, `english_title`, `english_subtitle`, `english_promotional_text`; country,coverage,model-source/version/formula,app-tier/resolved; candidates,judged,scored,p0,p1,p2,with-volume; conformance terms/from-table | Fixed facts dependent on the revision may remain on its listing content subtype; no need a table per scalar subobject. Model can instead be an immutable model-version FK where it fully determines the recorded triple. |
| Listing keyword terms, `(revision_id,role,ordinal)` | role in added/removed/gloss, term, optional meaning; uniqueness appropriate to exact role | A genuinely multi-valued fact. Concrete term relation with a finite role enum is not a generic content EAV table. A glossary requires meaning only for gloss. Order must be retained where source order mattered. |
| Media, `(revision_id,slot)` | media-kind screenshot/icon/app-preview; store/device/display-type; slot; source-locale; source-provider-resource-id; source object-version/digest; output immutable object-version/digest; MIME type; width/height; prompt; generated-at; generation-attempt FK; caption/intent where present | Multiple independently ordered files cannot be stored in a text listing row. R2 URL/key alone is not an immutable content reference. Media storage metadata should belong to an existing immutable media asset relation if available. |
| Campaign, `revision_id` | operation pause/enable/budget, platform campaign ID; budget amount and currency only for budget | One family with strict operation-based checks; no separate table for pause and enable. |
| Keyword, `revision_id` | operation create/change-bid, campaign ID, ad-group ID, targeting keyword ID only for update; text/match-type only for create; bid amount/currency | Distinct target key from campaign; target fields constrained. |
| Negative keyword, `revision_id` | operation create/delete, campaign ID, optional ad-group ID with explicit scope; negative keyword ID only for delete; text/match-type only for create | Distinct provider ID namespace and side effects; avoid shared ambiguous targetId content. |
| Generation/analysis request, `revision_id` | request kind, store, window-days/mode as applicable, recommendation-type, wave-index, plan reference, operator instructions; explicit per-stage policy columns `hypothesize`,`draft`,`execute` | Content is a request to generate, not provider write. Locale requests should be child tickets so locale target rows can be represented by membership. Approval scope says generate/execute explicitly. |
| Request evidence, `request_locale_revision_id` | language,reasoning,score,market-research-note; downloads,revenue-usd,impressions,review-count; competitor strength/localized-count/chart-count/market-downloads; finding-title/rationale/severity | Snapshot rationale seen at approval; values null when missing. Demand-country, competitor-country, competitor samples and finding IDs require related rows. Metrics source window and units must be explicit. |
| Advisory, `revision_id` | finite reason kind, title,summary,explanation,suggested-outcome, primary-link destination/label, confidence/impact/effort if present, connector/agent references if relevant | Pure prose does not require a new table for every advisory label. DB and wire enum decides acknowledgment/dismissal behavior; never fall through to successful execution. |
| Presentation lists, `(revision_id,section,ordinal)` | finite section in next-steps/supporting-evidence/description-outline/prioritization/notes; text | Optional dedicated display-content relation only if preserving those exact current lists. No field-key plus arbitrary value; section restricted to known prose list semantics. Storyboard is its own concrete slot/intent/caption relation or media slot subtype. |
| Concrete provenance | action/revision foreign references to source agent run, request, recommendation, variant, report version, backlog candidate, experiment, observation; source recommendation index only as historical coordinate | Use dedicated junction where relationship can be many-valued; no `source_type+source_id` polymorphic FK as new authority. A legacy address alias table is solely a router with checked target ticket FK. |

**Normalization choice:** many optional attributes do not by themselves violate 3NF. Split when a different key, cardinality, identity, retention, or integrity rule requires it. A fixed concrete listing row is preferable to one row per arbitrary field; ordinary parent membership is preferable to arrays of selected children; actor snapshots are historical facts rather than a mutable profile duplicate.

## Full derivation and request content requirements

`GeneratedLocaleMetadata` contains store,locale, the eight metadata fields, rationale,keywordAnalysis, optional englishGloss (`title`,`subtitle`,`promotionalText`,`keywords[{word,meaning}]`), optional qualityGateSkips (`naturalness`,`fidelity`), and optional research: country, coverage ready/cold, model source/version/formula, appTier1/2/3, appTierResolved, counts candidates/judged/scored/p0/p1/p2/withVolume, optional keywordConformance terms/fromTable. The narrower wire `KeywordResearchProvenanceSchema` currently omits keywordConformance; do not lose it by only migrating that parser's output.

Staging additionally writes `assetId`, `localeClass: new/update/repair`, `variantId`, `recommendationId`, `hypothesisRequestId`, `operatorInstructions`, `keywordResearch`, `humanEditedAt`, and `dismissedFields`. Recommendation variants also carry sourceFingerprint, editedAt and prior proposal data. An operator edit must create an attributed revision; generation may only publish its resulting revision if its captured base revision is still current. Generation cache and UI projection must refer to that revision, not mutate two copies in `pending_action.params` and `aso_recommendation_variant.proposal`.

A locale hypothesis currently carries `store`, `waveIndex`, `locales[]`; evidence duplicates these plus `hypothesisSource: scheduled_agent/user_directed_chat_or_mcp`, `supportingEvidence[]`, `demandLookbackDays`, and each locale's language,reasoning,score,demand,demandCountries,competitorMarket,marketResearchNote. Listing-change hypotheses carry store,recommendationType,planId,findingIds,locales; per-locale evidence language,findingTitle,rationale,severity. These need typed, immutable request content and related facts. `directed` approval must attribute the actual authenticated user/API principal; an absent historical approvedBy is not license to infer one from the run creator.

Sources: [localization contracts](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/shared-types/src/aso/localization.ts), [locale staging](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/services/aso/locale-expansion.ts#L1980), [locale hypotheses](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/services/aso/locale-hypothesis.ts), [listing hypotheses](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/services/aso/listing-change-hypothesis.ts).

### Media handoff is a distinct durability gap

The screenshot localization route overwrites `org-<org>/aso/<asset>/screenshots-localized/<locale>/<screenshotId>.png`, reads and rewrites a manifest, and stores only one last `screenshotId/sourceLocale/r2Path/prompt` quartet per recommendation locale variant. It catches upload and manifest errors, then can still return the generated image and record usage. This is generated output, not a durable immutable artifact. The latest merge preserves text metadata via JSON merge, which is useful behavior but not versioning.

New flow: durable generation attempt → immutable source pin → image generate → content-addressed/unique-version upload → verify stored digest/size → DB transaction attaches media revision and settles generation → UI sees draft. A crash after upload leaves an orphan object eligible for age-based cleanup only after confirming no revision references it. A storage failure keeps generation incomplete/failed; never mark a missing file durable. Source and output slots must survive regeneration. Existing overwritten past bytes cannot be reconstructed from current R2 keys; mark unavailable historic media explicitly.

Source: [screenshot localize storage/manifest/proposal](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/routes/assets/aso-screenshot-localize.ts#L430).

## Advisory, legacy and prerequisite items

| Current kind | Required migration/disposition |
| --- | --- |
| `optimize_keywords`, `improve_retention`, `adjust_monetization`, `update_store_listing`, `review_finding` | Current capability manifest calls these acknowledgment-only. Convert to typed advisory tickets; never equate their historical executed stamp with a provider write. |
| `aso_review_needed` | Dismiss-only notice. Known writers carry listing/field/protected-name/readiness failures; map known shape to typed cause/target and preserved prose. Census must enumerate all observed payload shapes. |
| `agent_attention_needed` | Preserve agentId,agentType,lastError,consecutiveFailures; link durable underlying agent failure evidence. Future resolved episode creates a new occurrence if it recurs. |
| `onboarding_audit_recommendation` | Preserve quick-win id,title,type,impact,effort,confidence,proposal; audit platform,storeAppId,country,locale,generatedAt; source run FK. It is a public-audit quick win, not necessarily an asoRecommendation row. |
| `connect_source` | Preserve connectorType,sourceLabel,benefit,href,platform. One missing-source fact can produce separate future episodes. Existing synthetic parent run must not be mistaken for causal agent execution. |
| `store_app_access_lost` | connectorId/name/type,platform,appName,bundleId,scrapingAccountEmail,consecutiveFailures,lastSuccessAt,lastError. Live profile/connector values differ from historical displayed snapshots. Retention/redaction for account identity must match approved product policy. |
| `flag_issue`, `escalate` | Durable advisory/attention ticket, with provenance to orchestrator activity. No generic provider executor. |
| `wake_agent`, `propose_experiment` | Typed generation/investigation request; wake result is an agent run, proposal result is new draft work. Neither is verified store publication. |
| `update_keywords`, `update_screenshots` | Manifest legacy acknowledgment types. Preserve historical fields recommendationType/findingCount/locales/severity or score-area; do not turn an acknowledgment into authorization to write. New work must use concrete generation/write family. |
| `pause_campaign`, `resume_campaign`, `adjust_budget` | Manifest retired Ads Agent types. Preserve campaignId and historical newBudget where present; do not map to ASA assuming platform, currency or ID namespace. Unknown platform/amount semantics remain historical-unproven. |
| `localize_listing` | Still appears in old ASO recommendation production; not a registered executable work definition. Inventory data before any conversion; produce fresh reviewable localization request only with sufficient explicit scope. |
| `backlog_opportunity` | Distinguish historic generic prose from latest live `stageBlocker` marker. Marker resumes typed staging and must become a typed prerequisite ticket linked to source backlog candidate; it cannot execute placeholder content. |
| Unknown key/status | Fail closed, preserve a typed migration exception requiring concrete adjudication before contract. Never default status to approved or unknown action to acknowledgment. |

Source: [capability work manifest](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/core/src/actions/capability-manifest/entries-work.ts), [informational classification](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/services/agents/pending-action-summary.ts), [stage blocker resume](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/services/backlog/stage-blocker-resume.ts).

## Source-to-target migration mapping

| Source table/fields | Destination and rule |
| --- | --- |
| pending_action id,organizationId,assetId | Preserve pending ID as canonical ticket where unambiguous; enforce same-organization FKs. Never delete ticket when agent run/review/connector disappears. |
| pending_action agentType,action,mode,priority | Closed action kind, actor domain and execution/approval policy; explicitly normalize known values. Agent display persona derives from existing canonical identity map. |
| pending_action params,reason | Concrete immutable revision content and rationale; collect all non-executor provenance keys before parser stripping. Multiple concrete revisions can be extracted only when source history proves them. |
| pending_action status,updatedAt | Explicit shared decision/work lifecycle facts with documented conversion. Unknown statuses are exceptions. updatedAt is not an optimistic concurrency revision; initialize a new monotonic version with migration event. |
| pending_action approvedBy/At,rejectedBy/At,rejectedReason,deletedBy/At | Attributed immutable historical decision/command observations; exact-content scope known/unpinned; retain original timestamps and unknown actor facts. Tombstone remains visible in history and old link resolution. |
| pending_action orchestratorRunId,sourceAgentRunId,sourceRecommendationIndex | Typed provenance to agent run/recommendation slot. Borrowed synthetic orchestrator parent is historical association, not causal generation. New org-level advisories must not manufacture agent runs to satisfy NOT NULL. |
| pending_action supersededByPendingActionId | Explicit successor relationship; use revisions for same-work edits going forward, distinct ticket successor only for materially new work. Preserve both old IDs/URLs. |
| pending_action executedAt,resultRunId,failureReason,completedAt | Historical attempt/result facts, not proof of provider publication. Keep run FK and old timestamp evidence. |
| pending_action beforeState,afterState,experimentId,checkBackAt,checkBackRunId,checkBackResult | Extract concrete execution receipts/observations/experiment references/measurement facts. Canonical experiment FK preferred; reconcile disagreements against older afterState.experimentId without silently choosing. Measurement stays experiment domain. |
| inbox_item_state id,organization_id,user_id,source_type,source_id | Convert through durable source-address mapping; user read relation unique(org,user,ticket). A state referencing an already-missing source needs an explicit historical alias/exception, not guessed live ticket. |
| inbox_item_state status,snoozed_until,note,created_at,updated_at | Read/unread to personal read marker. Per-user snooze/dismiss/archive/iterate is evidence of personal overlay, not prior org consensus. Deterministic migration policy: authoritative source decisions win; unanimous compatible overlay can map only under approved rule; conflicts become visible migration decision, not last-writer-wins. Note becomes historical iteration outcome evidence. No persisted personal lifecycle after cutover. |
| agent_request scalar identity/source/title/summary/kind/phase/status | Preserve request identity as ticket, retain Agents-owned request/run computation. Remove duplicate approval/work lifecycle after cutover; content and phase-specific policy references are typed. |
| agent_request evidence,proposedOutcome,whatWillHappen,approvalPolicy | Map exact locale/listing/request facts above; three concrete policy enum columns; explicit ordered prose next-step rows. Unsupported shapes stop migration. |
| agent_request blockerCode,blockerContext,unblockGuide | Typed blocker cause, target/prerequisite links, finite presentation fields title/whatHappened/whyItMatters/next/CTA+orderedsteps; scheduler state nested in unblockFinalization moves to durable dispatch obligation. |
| agent_request pendingActionId,recommendationIds,scenarioId,experimentId,supersededByAgentRequestId | Concrete foreign/junction relationships. Check scenario source exists; no bare polymorphic IDs. |
| agent_request idempotencyKey,approval/rejection stamps,timestamps | Preserve old idempotency namespace for import mapping; new command idempotency durable even after ticket terminal. Imported stamps follow pinned/unpinned rule. |
| agent_request_event all | Preserve each event ID,time,actor/run,type,message. Normalize its data into concrete command result/evidence. History view imports historical facts without claiming command replay or exact preconditions existed. |
| review_draft_reply id,review_id,asset_id,reply,original_ai_reply | Canonical child ticket with old draft alias; revision text and explicit original AI revision when recorded. A review can have multiple sequential reply/update tickets, so retire unique(review_id) as ticket identity rule. |
| review_draft_reply model,language,prompt_tokens,completion_tokens,total_tokens | Preserve generation provenance and nullable detected language. Token usage belongs to generation attempt/run, not duplicated billing debit. Older originalAiReply has unknown authored timestamp; do not fabricate one. |
| review_draft_reply pending_send_at,sent_at,send_attempts,last_send_error,readback_scheduled_at | Replace scheduler/lease/retry fields with durable execution/attempt records. Historical pending_send_at cannot disambiguate queued time vs lease deadline. Missing readback job does not prove write absent. |
| review_draft_rejection all | Preserve rejection receipt ID/sourceDraftId, exact snapshot fields, fingerprint version/hash, actor/reason/time; recover deleted draft as historical ticket. Existing receipt may survive deleted user with null actor. Never discard it because no current draft exists. |
| review_history all | Preserve provider observation snapshot and contained reply text/source/createdAt as available. A draft snapshot may corroborate earlier text but does not alone prove the human approved it. |
| review developer_response and history developer_response | Concrete developer-response observation fields; old history has only responseId,response,lastModified, so hidden/pending-state are unknown in those rows. Keep existing review synchronization facts in Reviews domain with typed accessor. |
| review_activity_log id,asset_id,review_id,activity_type,draft_text,message,created_at | Migrate attributable historical activity where link is provable; draft_completed text can recover historical content, not approval scope. Operational sync events remain Reviews telemetry and never become work automatically. |
| aso_recommendation and variant id,asset,store,locale,type,risk,evidence,proposal | Preserve recommendation+variant IDs as provenance/source aliases; migrate actionable content to ticket revisions; generation cache refers to revisions. Do not maintain independently writable duplicate proposal JSON. |
| aso_recommendation/variant status,createdBy/approvedBy/appliedBy/approvedAt/appliedAt,lastError,supersededByVariantId,timestamps | Import known decisions/results with actor/time/source. Remove second workflow authority; historical lastError retained; replace variant supersession with explicit immutable revision/successor relation. |
| aso_audit_log actor/action/data/time | Retain evidence and link to canonical history where typed/provable; do not erase compliance history. All scoped action-bearing data fields require census. |
| opportunity_backlog work_definition_key,work_execution_mode,work_params,work_preview,work_preflight_receipt | Replace work content copies with typed proposed ticket/revision or intent reference. Display preview computed from authoritative content; historical preflight records typed with observation time/version. A backlog candidate can be a fact until committed, but cannot remain an untyped executable backdoor. |
| opportunity_backlog staged_pending_action_id,staged_at,staged_by,staged_intent_identity,rejected_intent_identity/rejected_at | Permanent typed action linkage and provenance; staged/rejected intent pin retained for duplicate/rejection suppression. New terminal identity must not recycle when proposal reappears. |
| opportunity_backlog source/report/version/candidate/evidence refs/supersession/availability/rejection/archive fields | Retain Report/Backlog domain planning facts; normalize action-bearing references and evidence. Existing rejection/reconciliation behavior must not be lost. Not every proposal fact must immediately become inbox work. |
| work_intake_commit all | Retain durable idempotency for bulk intake; map selected task keys and resulting IDs to relational command targets/intake outcomes; response replay reconstructed from immutable result facts, never regenerated from latest ticket state. |
| capability_execution all | Preserve receipt IDs. Normalize true historical initiator,actor,capability,outcome/counts/credits. `work_id` may be queue-job:/agent-run: synthetic correlation; pending_action_id is not enforced FK. Do not guess exact execution linkage. Convert old mutable verification stamp/detail to historical observation; new checks append observations. |
| inbox_recovery_run all | Preserve applied migration manifest identity/hash/time. Existing manifest JSON must be fully typed into recovery-operation records before removing it; cannot pretend already-converted audit proof has vanished. |
| agent_run/agent_activity | Keep agent runtime/run usage; remove action execution commands/receipts from triggerContext/result blobs as workflow authority. Activity is evidence only. Retain report/agent analysis results outside inbox ownership; do not migrate unrelated analytical schema in this work. |
| aso_experiment,aso_listing_locale_state,store_listing_snapshot,store_listing_version_history | Keep experiment/observed-store facts in owning domains; reference/copy concrete frozen baseline when used for approval. Snapshot/measurement progress is not another action lifecycle. `store_listing_version_history` can omit long value text, preserving only digest, so it cannot always supply revert bytes. |

## Immutable provider evidence content

Execution status and observation are separate. Store concrete observed fields needed to show a mismatch, not merely expected/observed hashes. Pin the comparison implementation version and surface (ASC editable version, live public listing, Google Play committed listing, review response); explicit observation availability distinguishes present,absent,unreadable,pending,unknown. Provider-specific raw error/status strings may be fixed diagnostic text fields, never control-flow enums without strict mapping.

- Review observation: platform/app identity, legacy review ID, ASC API resource ID when known, review modified timestamp/rating/title/body/nickname/storefront/app-version, developer-response resource ID/text/modified time/hidden flag/provider pending-state, capturedAt. Map review.provider response timestamp numeric units deliberately; preserve unknowns. Do not alias provider response and review IDs.
- ASC listing observation: app info ID/localization ID and version/localization ID as applicable, canonical locale, capturedAt, appStoreState as raw diagnostic plus closed availability, title/name/subtitle/keywords/description/promotionalText/whatsNew/supportUrl, and concrete media slot observations. Public/live status requires correct surface evidence; editable draft match is not live.
- Google listing observation: packageName, canonical locale, committed edit ID when known, title/description/shortDescription, capture time. The edit's successful commit can precede durable confirmation; recovery reads the provider before repeating.
- ASA observation: Apple account/org, campaign/ad-group/scoped keyword IDs, status/budget/bid/currency/text/matchType with exact monetary representation, capture time/provider request ID. Creation lacks a general exactly-once guarantee: an uncertain create requires safe readback matching under documented conditions or manual reconciliation, not ordinary replay.
- Analysis/catch-up: preserve analysisId+approved days+reviewsAnalyzed, or connector+asset+days+mode queue handoff. Those receipts prove internal result/handoff only. Each eventual reply publication has its own approved content and provider evidence.
- Restore: evidence links both new restore revision and original experiment/snapshot source; a queue ACK alone is not reverted-live. Partial locale restoration remains per child.

## Migration safety and exact readiness gates

1. **Read-only live census must still run.** Source code cannot enumerate unknown values in unrestricted text/JSON columns. Collect counts by organization/source/action/status; JSON key/type frequency recursively; alias orphans and duplicate identities; current draft-vs-approved digest matches; receipt linkage certainty; R2 reference existence/versionability; pending/active/failed/delayed/grouped jobs. Return aggregated counts and sanitized exception IDs, never credentials or private customer content in this public artifact.
2. Snapshot every known source schema version and fixture shape before contracting it. Tests need unknown keys, null/missing/empty distinctions, impossible enum values, mixed-store locale spelling collisions, stale/unpinned approvals, multiple distinct historical stamps, source rows already deleted, and receipt ID collisions.
3. Build migration into a temporary strictly typed target schema on a safe `_test` database; compare every original column and every nested recognized leaf against normalized output. Record source row/leaf counters, constraints, child links, exact content digests and old URL resolution. A retry of each phase must produce identical IDs/counts.
4. Backfill only under controlled producer cutover and final catch-up. Running old writers cannot mutate snapshots after approval migration. Drain or fence old executable jobs before enabling new worker handlers; migrate unresolved side effects as uncertain. Contract phase removes old writers, readers and fields, not a permanent compatibility stack.
5. Proof cases: approval during iteration; child edit during parent approval; review arriving during batch approval; retry after provider ACK before DB commit; queue accepted before publisher ACK; crash after object upload; missing snapshot bytes; unknown current source status; conflicting personal overlays; deleted actor; missing review; original receipt IDs/links preserved. Failure to map any data prevents contract, not ingestion into a generic bag.
6. Repository requirements: generated Drizzle migrations → migrate, never db:push. RLS on all target relations. Integration tests import DB from `./setup/test-db`, not database package singleton; test DB guard must confirm `_test`. Bug reproduction fails for the right reason before fix, then passes, with surrounding test file. No live mutation tests for this audit.

Existing focused regression starting points: `review-draft-rejection-schema.test.ts`, `review-published-reply-edit.test.ts`, `review-queued-drafts-drain.test.ts`, `review-draft-external-reply.test.ts`, `aso-screenshot-localize-proposal.test.ts`, `aso-locale-draft-handoff.service.test.ts`, `aso/locale-draft-field-ops.test.ts`, `backlog-stage-from-intent.test.ts`, `backlog-prose-stage.test.ts`, `work-execution/review-applied-readback.test.ts`, `work-execution/guarded-asc-listing-execution.test.ts`, `inbox-batch-iteration.service.test.ts` and `inbox-cancel-approval.test.ts`. These were inspected by location; none run in this subtask.

## Exact current database source column census

This appendix inventories declarations, not the values actually present. Column casing below is physical SQL casing. The accompanying structured file also carries Drizzle property names and declaration source lines.

### `pending_action`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L4637) — 33 columns.

`id`, `organizationId`, `orchestratorRunId`, `assetId`, `agentType`, `action`, `params`, `reason`, `priority`, `mode`, `status`, `approvedBy`, `approvedAt`, `rejectedBy`, `rejectedAt`, `rejectedReason`, `deletedAt`, `deletedBy`, `failureReason`, `supersededByPendingActionId`, `sourceAgentRunId`, `sourceRecommendationIndex`, `executedAt`, `resultRunId`, `completedAt`, `beforeState`, `afterState`, `experimentId`, `checkBackAt`, `checkBackRunId`, `checkBackResult`, `createdAt`, `updatedAt`.

### `inbox_item_state`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L5002) — 10 columns.

`id`, `organization_id`, `user_id`, `source_type`, `source_id`, `status`, `snoozed_until`, `note`, `created_at`, `updated_at`.

### `agent_request`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L4800) — 30 columns.

`id`, `organizationId`, `assetId`, `agentType`, `sourceAgentRunId`, `kind`, `phase`, `status`, `title`, `summary`, `evidence`, `proposedOutcome`, `whatWillHappen`, `approvalPolicy`, `blockerCode`, `blockerContext`, `unblockGuide`, `pendingActionId`, `recommendationIds`, `scenarioId`, `experimentId`, `idempotencyKey`, `supersededByAgentRequestId`, `approvedBy`, `approvedAt`, `rejectedBy`, `rejectedAt`, `rejectionReason`, `createdAt`, `updatedAt`.

### `agent_request_event`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L4915) — 8 columns.

`id`, `agentRequestId`, `eventType`, `actorUserId`, `sourceAgentRunId`, `message`, `data`, `createdAt`.

### `review`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L1121) — 18 columns.

`id`, `app_id`, `platform`, `rating`, `title`, `body`, `nickname`, `store_front`, `app_version_string`, `last_modified`, `helpful_views`, `total_views`, `edited`, `developer_response`, `is_editable`, `apple_review_resource_id`, `created_at`, `updated_at`.

### `review_draft_reply`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L1205) — 17 columns.

`id`, `review_id`, `asset_id`, `reply`, `original_ai_reply`, `model`, `language`, `prompt_tokens`, `completion_tokens`, `total_tokens`, `pending_send_at`, `sent_at`, `send_attempts`, `last_send_error`, `readback_scheduled_at`, `created_at`, `updated_at`.

### `review_draft_rejection`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L1307) — 11 columns.

`id`, `organization_id`, `asset_id`, `review_id`, `rejected_by`, `source_draft_id`, `fingerprint_version`, `review_fingerprint`, `draft_snapshot`, `reason`, `created_at`.

### `review_history`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L1353) — 13 columns.

`id`, `review_id`, `rating`, `title`, `body`, `nickname`, `store_front`, `app_version_string`, `last_modified`, `edited`, `developer_response`, `draft_reply`, `captured_at`.

### `review_activity_log`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L1475) — 7 columns.

`id`, `asset_id`, `review_id`, `activity_type`, `draft_text`, `message`, `created_at`.

### `aso_recommendation`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L3916) — 14 columns.

`id`, `assetId`, `store`, `locale`, `type`, `riskLevel`, `evidence`, `proposal`, `status`, `createdBy`, `approvedBy`, `appliedAt`, `createdAt`, `updatedAt`.

### `aso_recommendation_variant`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L3976) — 13 columns.

`id`, `recommendationId`, `locale`, `proposal`, `status`, `supersededByVariantId`, `approvedBy`, `approvedAt`, `appliedBy`, `appliedAt`, `lastError`, `createdAt`, `updatedAt`.

### `aso_audit_log`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L4021) — 11 columns.

`id`, `organizationId`, `assetId`, `actorUserId`, `actorType`, `action`, `resourceType`, `resourceId`, `requestId`, `metadata`, `createdAt`.

### `aso_experiment`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L4284) — 22 columns.

`id`, `organizationId`, `assetId`, `store`, `status`, `experimentType`, `hypothesis`, `changes`, `metricsBefore`, `metricsAfter`, `impactAnalysis`, `recommendationIds`, `parentId`, `cycleNumber`, `createdAt`, `appliedAt`, `measurementStartAt`, `measurementEndAt`, `measuredAt`, `archivedAt`, `archivedBy`, `updatedAt`.

### `agent_run`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L4439) — 22 columns.

`id`, `agentId`, `organizationId`, `status`, `trigger`, `triggerContext`, `result`, `resultSummary`, `recommendations`, `errorMessage`, `errorCode`, `inputTokens`, `outputTokens`, `totalTokens`, `estimatedCostCents`, `model`, `startedAt`, `completedAt`, `durationMs`, `parentRunId`, `createdAt`, `updatedAt`.

### `agent_activity`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L4511) — 12 columns.

`id`, `agentId`, `agentRunId`, `organizationId`, `level`, `category`, `title`, `detail`, `data`, `entityType`, `entityId`, `createdAt`.

### `opportunity_backlog`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L6201) — 40 columns.

`id`, `organization_id`, `asset_id`, `title`, `description`, `market`, `gate`, `priority`, `capability_tier`, `work_definition_key`, `work_execution_mode`, `work_params`, `work_preview`, `workPreflightReceipt`, `staged_intent_identity`, `status`, `source`, `source_report_version_id`, `source_report_id`, `candidate_key`, `candidate_source_kind`, `content_hash`, `evidence_refs`, `latest_seen_report_version_id`, `retirement_reason`, `supersedes_backlog_item_id`, `staged_pending_action_id`, `staged_at`, `staged_by`, `available_at`, `schedule_month`, `stage_attempted_at`, `stage_refusal_reason`, `rejected_at`, `rejected_intent_identity`, `archived_at`, `archived_by`, `created_by`, `created_at`, `updated_at`.

### `work_intake_commit`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L6412) — 14 columns.

`id`, `organization_id`, `asset_id`, `created_by`, `idempotency_key`, `request_hash`, `preview_hash`, `mode`, `status`, `selected_task_keys`, `backlog_item_ids`, `response`, `created_at`, `updated_at`.

### `capability_execution`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L7979) — 15 columns.

`id`, `organization_id`, `capability_key`, `work_id`, `pending_action_id`, `initiator`, `actor_user_id`, `outcome`, `unit_count`, `failed_unit_count`, `credits_charged`, `verification_outcome`, `verified_at`, `verification_detail`, `created_at`.

### `inbox_recovery_run`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L4772) — 6 columns.

`id`, `manifest_hash`, `organization_id`, `manifest`, `applied_at`, `created_at`.

### `aso_listing_locale_state`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L4236) — 9 columns.

`id`, `assetId`, `store`, `sourceAppId`, `locales`, `capturedAt`, `runKey`, `createdAt`, `updatedAt`.

### `store_listing_version_history`

[Source](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/database/src/schema.ts#L8071) — 11 columns.

`id`, `asset_id`, `store`, `version_string`, `released_at`, `released_at_precision`, `locale`, `field`, `value_text`, `value_digest`, `captured_at`.


## Private aggregate census follow-up

The lead agent subsequently supplied a read-only aggregate census of the actual database. This subtask inspected only path/type metadata and action/status categories from that report. No customer text, customer IDs, private row counts or raw payload values are included here. The source-only migration plan above is therefore supplemented by actual observed shape coverage. The private census has a finite recursion limit; observed paths were shallower than that limit, so it did not truncate the action parameter shapes inspected. Other source JSON columns still need the same recursive census before a lossless contract migration.

`audit-observed-content-paths.csv` maps every observed scalar parameter shape after locale-key normalization to its concrete target family. It is a review checklist, not an implemented converter. The planned converter must assert zero unknown paths, preserve every meaningful missing/null/empty distinction, and demonstrate every leaf mapping with fixtures.

### Historical content absent from today's executable manifest

| Existing historical kind | All observed parameter fields / nested structures | Required concrete retention |
| --- | --- | --- |
| add_keyword | adGroupId number/string; bid number; campaignId string; confidence number; keyword string; matchType string | Historical keyword content: retain exact source handle and encoding, bid, text, match type, confidence. Never invent currency or current provider namespace. |
| add_negative_keyword | campaignId,confidence,keyword,matchType; insight title/description, change metric/currentValue/recommendedValue, projection summary, evidence[{label,value,trend,isPositive}] | Historical negative content plus ordered insight evidence. Insight values are already display text; retain exactly as evidence, do not infer numerical semantics. |
| adjust_adgroup_default_bid | adGroupId,adGroupName,campaignId,confidence,currentBid,newBid | Concrete historical ad-group content, no new executor. |
| adjust_keyword_bid | adGroupId number/string,campaignId,confidence,currentBid,keyword,keywordId number/string,newBid | Historical targeting-keyword content; numeric ID provenance and possible precision loss remain explicit. |
| pause_keyword | adGroupId number/string,campaignId,confidence,keyword,keywordId number/string | Historical targeting-keyword content with paused intent only as historical label. |
| adjust_budget | campaignId,confidence,currentDailyBudget,newDailyBudget | Historical campaign content; exact source lacks currency, so cannot become current spending authorization. |
| resume_campaign | campaignId and sometimes adGroupId,keywordId,keyword | Preserve contradictory extra target handles; do not silently discard or infer campaign-vs-keyword intent. |
| asa_create_campaign | adamId number,adGroupName,budgetAmount,budgetType,campaignName,countriesOrRegions[],currency,defaultBid,keywords[{text,matchType,bidAmount}],supplySources[] | Historical campaign content; explicit placement members and historical child keyword tickets. No registered current executor is inferred. |
| run_product_agent_scenario | draftOnly boolean,personaHint nullable text,proposalKind,scenarioId,signalRefs[{id,kind}] | Historical product content and ordered signal refs. Retired source handles are evidence rather than fabricated FKs to deleted tables. |
| propose_experiment | experimentId,fields[],hypothesis | Existing experiment relation plus immutable original proposed field selection/hypothesis. |
| revert_experiment | assetId,experimentId,locales[],origin,regressionSummary,severity,regressions[{after,before,locale?,metric,reason,relativeChange,scope,severity}] | Exact regression evidence rows; locale null means wider scope, not an invented locale. Restore remains separately approved concrete content. |
| create_locale extras | metadataRevision,englishGlossRevision,englishGlossStatus | Preserve historic revision correlation tokens and status; new glossary carries its actual content revision, never updates approved copy silently. |
| apply_listing_changes extras | cause,failedLocales[],recommendationType,riskLevel,scope,workReceipt{ok,blockers[]} | Fixed cause/risk/scope provenance, child failure evidence, typed preflight observation. These must not be discarded by narrow executor parsing. |

### Final data caveats

The observed data confirms the source-only manifest was insufficient: retired Ads/Product work survives, including nonterminal records, and historical batch content pins are missing on some approvals. A clean migration must preserve those records as typed historical evidence and require an explicit fresh replacement proposal for any further work. The receipt table also has records with no extant pending-action FK target; matching an arbitrary recent action is not acceptable. Known legacy source enum-like strings need a safe finite value census before strict enum constraints are finalized.

The design SQL in `schema-content.sql` covers current supported content shapes only; the historical shape appendix is a migration checklist. It reuses snapshot content for baseline and observation revisions, and folds same-key market and ad-insight scalar objects into their primary subtypes. This is a proposed data contract; no claim is made that migration fixtures, import completeness, RLS behavior or application integration have already passed.


## Provider-bound content validation follow-up (current capabilities only)

`schema-content-additions.sql` adds no relations. It removes the duplicate content-level baseline pointers: `action_revision.baseline_revision_id` is the single baseline authority. It adds executable deferred seal guards, rather than leaving provider target and operation checks as prose.

| Area | Verified current behavior | Exact design change |
|---|---|---|
| App Clip card | `app-clip-localization-writer.ts:550–666` reads a live source card, downloads header bytes and calculates MD5 during execution. `:390–463` selects approved translated subtitle or falls back to the source subtitle. `authorized-writes.ts:310–330` explicitly permits this extra subtitle plus support URL/what’s-new content. | Before approval, freeze `app_clip_id`, `app_clip_experience_id`, `app_clip_release_version_id`, source localization ID, exact subtitle and header media slot. The locale revision carries the fixed scope; the same-revision media row carries immutable bytes, SHA-256, MD5, dimensions and MIME. Create/repair/observed are closed operations; an absent-card baseline still records the target experience/version. No post-approval live fallback. |
| App Clip subtitle | `packages/utils/src/aso-field-usage.ts:113` limits the value to 56 UTF-16 units. PostgreSQL ordinary length counts code points instead. | SQL `utf16_length` counts supplementary Unicode characters as two units, matching the existing JavaScript contract. All approved App Clip subtitles pass the database constraint. |
| Google Play commit | `packages/google/src/play-console-web/client.ts:8474` and the other three edit-commit call sites omit `changesInReviewBehavior`. Official Google documentation says omission defaults to `CANCEL_IN_REVIEW_AND_SUBMIT`. | Every Android publication proposal pins the sole permitted `play_commit_policy='ERROR_IF_IN_REVIEW'`. Every commit adapter must supply it; precondition failure becomes a durable blocker. This is a deliberate behavior fix, not an existing guarantee. The transient edit ID belongs to the execution step; it cannot be supplied in an approved proposal. |
| Provider target drift | Content contains account/app/review or account/store/locale/app/version/campaign identifiers, but current flows can resolve some of them later. | Seal-time `assert_same_provider_content_target` rejects a baseline on another target. Attempt linkage invokes the same function for provider observations. Known resource IDs must match; a previously absent created resource may acquire its provider-assigned ID. Apple app-info/version targets must be frozen before proposing a write. |
| Locales | `packages/utils/src/storefront-data.ts` defines 50 ASC and 84 Play canonical locales, with alias and ambiguity resolution helpers. | A finite SQL function enforces this catalog on listing, media and request content. Resolve accepted aliases before persistence; never persist case/underscore variants or guess an ambiguous language. A provider addition requires an explicit schema/contract update. |
| Screenshot display sets | Apple documents 21 current screenshot display types. Fload’s Play listing reader currently reads `phoneScreenshots` and `sevenInchScreenshots`. | A closed display enum admits these observation identities with store constraints. It does not claim an upload executor exists for every set. Current approved listing-media effects are limited to frozen App Clip headers; other generated media remains a distinct generation revision until a supported publication capability is explicitly added. |
| R2 identity | Current generation/storage paths do not by themselves prove the object key can never be overwritten. | Stored/source media must identify either a provider object version or a SHA-256-addressed object protected from replacement and deletion. SQL checks the shape and digest. The storage adapter must enforce conditional creation/protection and rehash bytes before upload; a digest-looking key alone is not proof of immutability. |

The proposal-intent validator rejects unsupported store/field combinations, operation/content disagreements, unreadable proposed values, Android approval without safe commit policy, mismatched original-AI review revisions, incorrect review-request windows, and ad-group negative-keyword creation (which the current adapter does not support). Review catch-up and analysis retain the current **integer 7–180 day window**; the key `review_catch_up_30d` names its default, not a three-value enum.

Known limits of this contract: sealed content is not a deployment, storage existence proof, provider transaction, migration rehearsal, or grant revocation protocol. The parent plan’s approval, execution, resource fencing, observation-surface and migration tests remain required. Readback records the requested target even when the provider reports it absent; “no matching resource returned” does not erase the target identity.

Sources: [Google Play edits.commit](https://developers.google.com/android-publisher/api-ref/rest/v3/edits/commit), [Apple ScreenshotDisplayType](https://developer.apple.com/documentation/appstoreconnectapi/screenshotdisplaytype). Source claims above refer to the investigated `63275b2f5` checkout; none were inferred from the older agent narrative.


## Final current-schema normalization review

The design has one authoritative revision title, summary and rationale. The final review removed `action_advisory_content.title`, `action_advisory_content.summary` and `action_listing_content.rationale`; copying these into a second 1:1 subtype would create two answers for the same fact. Migration maps the source values to `action_revision` directly. The subtype retains only distinct domain content.

Normalization does not require one physical table for every variant or every 1:1 extension. Seven current Ads operations intentionally share one constrained concrete relation because their key, ownership and revision lifetime match. Baselines and provider observations reuse the same typed content relations as proposals, distinguished by closed revision purpose. App Clip fields and both promotional-text destination pairs share the locale revision; they do not introduce more relations. Historical-only families are absent from the live runtime model.

The remaining repeated facts have different keys: batch membership is per parent revision/child; attempts are per physical interaction; steps are per separately recoverable effect; terms, ordered prose notes, country evidence, competitor names and provenance links each repeat independently. Collapsing those into a single row would require forbidden arrays/JSON, impose a fixed arbitrary maximum, or duplicate unrelated facts. Keeping them relational is the actual normalization benefit.

A possible one-table reduction is merging `action_approval` into `action_command_target`, since a successful approval is unique per command and action. We retain the explicit approval relation: it is the immutable authorization referenced by an execution, with its exact revision, scope and Undo deadline. Merging would burden all nonapproval commands with optional authorization columns and complicate foreign keys that must reference a real grant. This is an intentional domain boundary, not a claim that normal forms force the split.

There is no new generic job, outbox or event relation. `action_execution` owns durable scheduling/recovery facts; existing BullMQ queues are transport. History is a projection of immutable command/revision/approval/attempt facts. Tenant keys repeated for composite foreign keys and RLS are intentional enforcement data; they are not competing workflow authorities.

The final correctness pass also added: the exact incomplete App Clip header reservation ID and observed state before deletion; separate live/editable promotional target IDs and live snapshot text; closed provider publication/version states; and target-continuity guards on head adoption and generated outputs. A locale request cannot silently produce another store/locale, nor can an iteration change a review/account/app identity. The sole added request-to-collection transition is current review catch-up to a pinned review batch on the same asset and requested store. Empty catch-up is an explicit no-work generation outcome, not an empty disappearing collection.
