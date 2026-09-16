> Historical source investigation. Retained as dated evidence; use the [current specification](Fload-Inbox-End-to-End-Specification.md), [actual field catalog](Fload-Inbox-Current-Fields.md) and [checkpoint](Fload-Implementation-Checkpoint.md) for the current proposal and its limits.

# Provider boundary field audit

**Scope:** read-only follow-up against source commit `63275b2f51ac5b5a151a9a6683c813423e682785` and the published design catalog validated `2026-09-15T19:40:07Z`. The 25-table SQL is the existing design baseline, not implemented application code. This document recommends ownership boundaries; it does not change that SQL, add tables, or publish anything.

**Conclusion:** Fload owns the ticket, approval, immutable intended content and delivery history. Providers own remote resource identity and their current state. Fload must persist the exact approved target plus the evidence it observed; calling these “provider data” is not a reason to discard them. The provider module should own their meaning, parsing and comparison. The current proposal mixes those responsibilities in several physical relations.

## Field ownership, exhaustively classified

F = Fload workflow/protocol; D = Fload domain-authored content or research; P = provider-specific target/contract; E = external observation; I = infrastructure. A `D / E` field deliberately changes evidentiary role with immutable revision purpose: proposed text and observed text are different records, not competing current-state authorities.

### `action_ad_content` — 16 fields

| Ownership | Exact fields | Meaning |
|---|---|---|
| F | `organization_id`, `revision_id` | Fload tenant and immutable revision ownership. |
| P | `intent`, `provider_account_id`, `provider_campaign_id`, `provider_ad_group_id`, `provider_keyword_id`, `provider_negative_keyword_id`, `match_type` | Apple Ads operation, remote target hierarchy and supported match contract. These are not Meta identifiers. |
| D / E | `keyword_text`, `daily_budget_amount`, `bid_amount`, `currency_code` | Authored desired values on a proposal; captured external values on baseline/observation revisions. Currency validation is adapter-owned. |
| E | `observed_status`, `observation_availability`, `observation_captured_at` | What the adapter actually observed, when, and whether it could read it. |

### `action_listing_content` — 73 fields

| Ownership | Exact fields | Meaning |
|---|---|---|
| F | `organization_id`, `revision_id` | Fload tenant and immutable revision ownership. |
| D | `store`, `locale`, `intent`, `operator_instructions` | Fload choice of work destination and intended change. Store/locale validity and legal operations are constrained by the destination adapter. |
| D / E | `title_state`, `title`, `subtitle_state`, `subtitle`, `description_state`, `description`, `keywords_state`, `keywords`, `promotional_text_state`, `promotional_text`, `short_description_state`, `short_description`, `whats_new_state`, `whats_new`, `support_url_state`, `support_url` | Exact proposed copy plus explicit set/clear/keep/dismiss states; on snapshot revisions these columns hold readback values. Not a mutable mirror of the provider catalog. |
| D | `keyword_analysis`, `naturalness_check_skipped`, `fidelity_check_skipped`, `english_title`, `english_subtitle`, `english_promotional_text`, `gloss_status`, `research_country`, `research_coverage`, `research_model_source`, `research_model_version`, `research_model_formula`, `app_tier`, `app_tier_resolved`, `candidate_count`, `judged_count`, `scored_count`, `p0_count`, `p1_count`, `p2_count`, `with_volume_count`, `conformance_term_count`, `conformance_from_table_count` | Fload ASO generation/research/explanation facts; provider adapters do not own generation quality or ranking logic. |
| D / E | `source_fingerprint`, `source_capture_at` | Fload provenance fingerprint and capture time for the input observation; neither is provider authorization. |
| P | `provider_account_id`, `provider_app_id`, `package_name` | Pinned remote account/application identity. provider_app_id is ASC; package_name is Play. Remote account identity is distinct from a Fload connector row ID. |
| P | `app_info_id`, `app_info_localization_id`, `app_version_id`, `app_version_localization_id`, `live_promotional_version_id`, `live_promotional_localization_id` | ASC exact app-info, editable-version and live-version destination contracts. |
| P | `play_commit_policy` | Play commit behavior approved in advance, currently the single safe ERROR_IF_IN_REVIEW choice. |
| P | `app_clip_operation`, `app_clip_id`, `app_clip_experience_id`, `app_clip_release_version_id`, `app_clip_localization_id`, `app_clip_source_localization_id`, `app_clip_header_media_slot`, `app_clip_incomplete_header_id` | ASC App Clip operation and exact source/destination/reservation pins. The media slot is a Fload reference used by that provider-specific contract. |
| D / E | `app_clip_subtitle` | Fload-authored/frozen subtitle on proposal; captured card subtitle in a snapshot. Its field existence and UTF-16 limit are ASC-specific. |
| E | `observation_availability`, `observation_captured_at`, `provider_version_state`, `live_promotional_text_state`, `live_promotional_text`, `app_clip_header_state` | Typed external observations. Live/editable promotional values can differ, so these are distinct facts. |
| E / P | `google_edit_id` | Observed Play edit identity only; proposals reject it. New edit identity and expiry belong to a physical attempt, not to authored listing copy. |

### `action_execution_step` — 15 fields

| Ownership | Exact fields | Meaning |
|---|---|---|
| F | `id`, `organization_id`, `execution_id`, `ordinal`, `input_step_id`, `content_revision_id` | Fload durable ordered plan and its exact authorized content/input dependency. |
| F / P | `kind`, `required_surface` | Closed effect identity and required success surface. The coordinator owns orchestration; provider modules own asc_*, play_* and asa_* semantics. |
| I / P | `adapter_version`, `recovery_mode`, `recovery_policy_version`, `native_idempotency_key` | Versioned execution/recovery policy and transport support. A native provider idempotency key is not a Fload command idempotency key. |
| P / I | `media_slot`, `upload_offset`, `upload_length` | Current use is specifically ASC App Clip reservation/upload byte ranges. These are provider transport details inside an otherwise generic plan. |

### `action_execution_attempt` — 40 fields

| Ownership | Exact fields | Meaning |
|---|---|---|
| F | `id`, `organization_id`, `step_id`, `execution_id`, `number`, `kind`, `subject_attempt_id`, `input_attempt_id`, `evidence_command_id` | Fload immutable interaction identity, sequence, lineage and attributable late evidence. |
| I | `claim_generation`, `claim_token`, `finalized_claim_generation`, `finalized_claim_token`, `agent_run_id`, `connector_id`, `transport`, `started_at`, `finished_at`, `recorded_at` | Worker fencing, internal execution identity, selected credential connection, transport and timing. Connector ID must not substitute for remote account identity. |
| F | `result`, `failure_class`, `comparison_version`, `non_application_basis` | Fload canonical interpretation of an interaction and versioned evidence classifier, not a raw provider status. |
| F / D | `output_kind`, `output_revision_id`, `output_review_analysis_id`, `output_agent_run_id`, `no_work_reason` | Typed internal generation outputs. These should never be read as provider delivery receipts. |
| E | `observation_revision_id`, `observation_surface`, `observation_completeness`, `observed_at` | Link and coverage of external readback; matched only has meaning for the named surface. |
| E / P | `provider_request_id`, `provider_resource_id`, `provider_version`, `provider_edit_id`, `provider_localization_id`, `provider_media_id`, `provider_error_code`, `provider_edit_expires_at` | Provider-issued receipts or errors. Play owns edit/expiry semantics; ASC owns localization/media semantics; ASA owns created keyword/resource semantics. Generic resource/version names need explicit per-step meaning. |

## What current code establishes

- **Apple Ads is a separate product boundary from App Store Connect.** The seven registered `asa_*` actions are mechanical spend/keyword operations, with provider-specific target validation and readback. `AsaWriteClient` is narrowed to seven mutation methods; `AsaReadClient` deliberately has no writes. [Registered actions](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/services/inbox-work/work-definition-registry.ts#L1145), [guarded ASA gateway](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/services/work-execution/guarded-asa-gateway.ts#L12).
- **The present `action_ad_content` is Apple Ads content, not a universal advertising model.** Its account → campaign → ad group → keyword targets and EXACT/BROAD match type fit the Apple Ads client. Meta has campaign/ad-set/creative concepts and different status/budget contracts. Name and place this content accordingly; do not add `provider='meta'` and reuse the ASA interpretation. [Apple Ads models](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/apple/src/apple-ads-api/models.ts#L168), [Meta types](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/connectors/meta-ads/types.ts#L26).
- **Meta exists as integration code but has no registered inbox mutation in this baseline.** Its client exposes status and daily-budget writes, with the latter accepting minor units. Repository search found no direct call sites beyond these method definitions. Keep that adapter separately owned and audit latent writes; do not create speculative Meta Action tables or describe Meta as an implemented inbox capability. [Meta client](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/connectors/meta-ads/client.ts#L740).
- **ASC and Play already have distinct guarded modules.** The shared machinery verifies authority; the wrappers know provider operations and permitted argument projection. ASC has app-info/version writes and dual promotional targets; Play has its edit/commit behavior. These are not interchangeable transport names. [ASC wrapper](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/services/work-execution/guarded-asc-listing.ts#L16), [Play wrapper](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/services/work-execution/guarded-gplay-listing.ts#L15), [Play edit commit](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/packages/google/src/play-console-web/client.ts#L8474).
- **The existing shared kernel is the right foundation, but its current logging is not the proposed durable attempt protocol.** Existing code consumes authorization before calling a provider, then records a capability log through a function that catches persistence failures. The proposed start/settle/readback facts belong to Fload's coordinator, even when the adapter interprets the receipt. [Shared guard](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/services/work-execution/guarded-write.ts#L37), [current execution log](https://github.com/fload-ai/fload-platform/blob/63275b2f51ac5b5a151a9a6683c813423e682785/apps/api/src/services/work-execution/execution-log.ts#L8).

## Smallest useful boundary

Use three code layers, with one coordinator and existing queues:

```text
Actions: commands → revisions → approvals → execution/attempt protocol
    ↓ typed approved effect + frozen target
Domain content: listing/review copy, ASO research, media references
    ↓ exact provider-specific contract
Adapters: app_store_connect | google_play | apple_ads | meta_ads (existing integration only)
    ↓ typed receipt / observation / uncertainty
Actions: persist result, schedule verification/recovery, derive inbox state
```

The generic coordinator owns acceptance, authorization, cancellation windows, fencing and retry eligibility. Adapters own supported remote targets, value limits, provider I/O, receipt decoding and the rules needed to prove a remote outcome. An adapter returns facts; it cannot approve, advance or silently complete the ticket. Provider-specific SQL validators should be maintained with that adapter's contract and invoked by central invariants; moving them into a central file does not make them provider-neutral.

**Recommended minimum now:** enforce those module/import boundaries and assign provider ownership to existing closed contracts. Rename/move the cohesive ASA-specific content relation to `apple_ads.action_content` when the architecture change is implemented. Keep common immutable content and protocol tables under `actions`. ASC/Play contract types and validation functions can have `app_store_connect` / `google_play` namespaces without creating new tables merely to populate a namespace. The existing Meta module stays separate; it needs no Action table until a supported workflow is implemented. This makes meaningful ownership clearer without increasing the current relation count.

PostgreSQL schemas are namespaces for tables, types and functions; they are not separate databases or automatic isolation boundaries. Cross-schema access depends on privileges. Use qualified object references, explicit grants and the same tenant/invariant checks; a cosmetic `SET SCHEMA` is insufficient. [PostgreSQL schemas documentation](https://www.postgresql.org/docs/current/ddl-schemas.html).

## Where a stricter physical split would move fields

If the team requires provider contracts to be physically absent from generic relations, these are the precise cohesive splits—not a recommendation to create one table per field:

| Existing relation | Keep with Actions/domain content | Provider-owned move |
|---|---|---|
| `action_ad_content` | Its revision remains owned by Actions through the same composite FK | Move the whole current relation to `apple_ads.action_content`; do not introduce a generic ads union for hypothetical providers. |
| `action_listing_content` | Authored copy, intent states, locale choice, provenance and ASO research | ASC target/App Clip/live-version contract into one revision-keyed `app_store_connect.listing_contract`; Play account/package/commit contract into one `google_play.listing_contract`. Exactly one target contract per store/revision. Snapshot observations reuse the same typed family. |
| `action_execution_step` | Plan identity/order, authorization reference, recovery policy and required result | Current App Clip media-slot/range details into an ASC step extension, only if physical purity is required. They may remain a strict closed subtype in shared storage when table simplicity is the priority. |
| `action_execution_attempt` | Attempt identity, fencing, timing, internal outputs and canonical result | Provider receipt fields into a provider-owned attempt extension: ASC localization/media facts, Play edit/expiry facts, ASA created-resource facts. No duplicated attempt lifecycle. |

This full physical separation would add **up to six relations** in this four-table audit: two listing target extensions, one ASC step extension and one attempt receipt extension per three active providers. The ASA table move adds none. That is a real complexity cost, not something schema names can hide. I would not pay it solely to make the diagram look purer; require a concrete ownership, privileges or lifecycle benefit. The no-extra-table module boundary above is the smallest meaningful improvement. No field move changes approval hashing: frozen provider targets remain part of the approved revision digest and must commit/seal atomically with authored content.

## Actionable issues in the proposed baseline

1. **Misleading generic Ads name.** `action_ad_content` is a closed ASA contract. Rename it and its contract owner before adding another advertising provider; Apple Ads, App Store Connect and Meta must not share an “Apple/provider client” abstraction.
2. **Generic delivery storage contains provider-specific leaves.** App Clip byte ranges and Play edit expiry are legitimate durable facts, but the adapter must own their allowed shape. Current typed SQL guards provide safety; module ownership should match them. Do not let the generic coordinator interpret those values through ad-hoc conditionals.
3. **`provider_version` and `provider_resource_id` need exact documented meaning per step.** “Version” could otherwise mean API version, ETag, release version or localization identity. Keep only currently consumed receipts and use provider-specific names/types or an exhaustive step-to-field matrix. This is a semantic typing issue even though the SQL column is legally `text`.
4. **Observed value versus desired value must remain explicit.** Provider-owned current state cannot overwrite the immutable proposed value. The existing revision-purpose separation is useful and should survive module/schema moves. The live promotional snapshot is distinct from the one desired copy sent to both approved targets.
5. **No provider clone of workflow.** Avoid `apple_ads.action_status`, `meta_ads.approval`, independent retry jobs or provider-owned read/unread flags. The Actions lifecycle remains one authority. Conversely, an Actions decision is never evidence that the remote state changed.

No schema changes, app changes, provider calls or publication were performed for this audit. All four field groups above were mechanically checked against the published catalog: every column classified once, with conditional roles stated explicitly.
