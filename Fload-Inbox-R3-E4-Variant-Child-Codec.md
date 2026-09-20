# FLO-1355 — E4 strict variant/child identity codec (revision 4.2 — reconciled)

20 September 2026 · Revised documentation proposal · Runtime implementation remains separate


**Revision 4.2 reconciliation.** See [the drift assessment and current decisions](Fload-Inbox-R3-E4-Reconciliation.md). Keep revision 4.1's conservative reference mapping and source-supported R1/R2 decisions. The supplied revision-4 review is unchanged. This revision corrects cross-document integration drift: collection-parent prose is not yet a permitted sealed shape; unequal repaired outcomes have no accepted lossless destination; derived diagnostics are read projections, not new authoritative columns. Pending obligations require positive disposition, not fencing alone. Consequently this is a selected mapping direction with explicit gates, not blanket implementation or cutover readiness. The current reconciliation and assessment supersede earlier readiness/handover wording.

**Revision 4.1 follow-up (historical review verdict, qualified above).** Independent review of revision 4 confirms F1–F6 resolved and the E4 mapping ready to implement. R2's latest-approval manifest clarification is incorporated in §4/§6 without timestamp ordering. R1 remains a counted preflight blocker: current single-store asset state alone does not prove historical request scope, and a no-children historical fallback needs an explicit conservation mapping before it can replace the existing atomic-component rule. See the archived local review record. Runtime/DDL/cutover work remains separate.

**Revision 4 decision (retaining revision 3’s reference-only mapping).** Preserve every recorded request→card reference and resolve its exact listing snapshot, including package children. The legacy writers do not retain enough evidence to distinguish original generation from cache reuse or later replacement. Accordingly this codec records references and human-edit markers; it does **not** infer generated/restaged authorship, an approval-time manifest, or a historical request-child successor. This is the implementable conservative branch of contracts v2 §1.4 (output IDs prove references, not content/revision/approval). It supersedes revision 2's six-state classification and T2 automatic successor proposal, rather than leaving those branches underspecified.

**Revision 4 review response.** Addresses F1–F6 in the independent revision-3 review: admit cleared FK columns even after deterministic-ID recreation; retain recreation/decision-reset/manifest evidence; inventory repair, unblock, collapse, experiment-link and delete paths; distinguish V3 terminal singletons; correct missing-plan ownership; make row-local invariants SQL CHECKs. The response and regression results are in the archived local review record. Suggested rules are qualified where the source retains multiple overlapping facts (auto-policy plus approval event, or both approval and rejection resets), rather than forcing a lossy exclusive label.

**Revision 3 background.** Package references resolve through their sealed membership; current columns and event arrays are separate evidence; missing historical V2 output IDs remain explicitly unavailable; timestamps no longer imply authorship. Source inspection also established that the draft rebuilds its plan, so the completed plan need not equal the hypothesized plan. Duplicate array occurrences, all retained completion events, missing targets and back-pointers are conserved without inventing membership or a completion event for an unreferenced card. The core counterexamples have executable design vectors in the companion self-review artifacts. The required integration fixtures in §8 are listed separately and have not been run against production code.

**Evidence and limits.** Additional source checks in this revision use exact commit `e7c094c81b54e13e52d329f39157a39fb99a3c98`, not the dirty working tree. §1.1–§1.3 retain the original source census references from `e2cc156994855e401a83399fbb4c3d7be5194875`; the prior review reported those writer files unchanged through `e7c094c8` except a policy string. Additional source checks and writer effects are documented in §1.4–§1.5. Prior frozen-prototype hash checks are historical review results, not checks repeated by this revision. Governing documents: ownership v6; destination contracts v2 §1.4/§2.6; conservation ledger §4.1/§4.2/§9; historical-ticket matrix §1–§5. This is a mapping specification with the explicit G1/G2/G3 integration gates, not DDL, a final table count, deployment proof or a new production census.

**What E4 is.** `agent_request.pendingActionId` references `pending_action.id` with `ON DELETE SET NULL`; `recommendationIds` stores pending-action IDs, not recommendation-plan IDs. V1/V1d are locale hypotheses, V2 listing-change hypotheses, V3 blocked requests. The request remains distinct from each referenced listing ticket.

---

## 1. Every writer at the pin

### 1.1 Request writers

| Variant | Writer | Idempotency key `(organizationId, idempotencyKey)` unique | Kind · phase · status at write | `evidence` / `proposedOutcome` | Links at write |
|---|---|---|---|---|---|
| **V1** `locale_expansion` hypothesis, scheduled | `locale-hypothesis.ts:95–195` `stageLocaleHypothesis`; sole caller `aso-agent.ts:4531` | `aso:<assetId>:<store>:locale_wave:<waveIndex>` (`:58–64`) | hypothesis · hypothesis · `open` | `{kind:'locale_expansion', store, waveIndex, hypothesisSource:'scheduled_agent', demandLookbackDays?, locales[{locale, language, reasoning, score, demand?, demandCountries?, competitorMarket?, marketResearchNote?}]}` / `{kind, store, waveIndex, locales[]}` | none |
| **V1d** `locale_expansion`, directed | same function, `directed` branch (`:106–195`) | `aso:<assetId>:<store>:locale_direct_command:<sorted,deduped locales>:<attemptId>` (`:66–83`) | hypothesis · hypothesis · **`approved` at creation**, `approvalPolicy {hypothesize:auto, draft:auto, execute:await}` | header adds `hypothesisSource:'user_directed_chat_or_mcp'`, `supportingEvidence[]` | none |
| **V2** `listing_change` hypothesis | `listing-change-hypothesis.ts:90–158`; sole caller `aso-agent.ts:886` | `aso:<assetId>:<store>:listing_change:<recommendationType>` (`:48–56`) | hypothesis · hypothesis · `open` | `{kind:'listing_change', store, recommendationType, planId, findingIds[], locales[{locale, language, findingTitle?, rationale?, severity?}]}` / `{kind, store, recommendationType, planId, findingIds, locales[]}` | none |
| **V3** blocked request | `aso-agent-request-blockers.ts:90–128` `surfaceAsoBlockedRequest` | app-level `aso:<assetId>:blocked:<code>` for `NO_OPEN_RELEASE`/`NO_WRITABLE_CONNECTOR`; else `aso:<assetId>:blocked:<code>:<platform|any>:<locale|all>:<field|all>` (`:131–146`) | blocked · draft · `blocked` | empty; `blockerCode`, `blockerContext {platform, locale, field, …caller context}`, `unblockGuide` | none |

**Reachability.** `git grep` at the pin finds no caller that passes `directed`; V1d rows can exist only from earlier code. Only `NO_OPEN_RELEASE` is reachable for V3 (ledger §4.2). This is the ASO E4 writer inventory; other domains or unsupported historical variants are not admitted by this decoder.

**Upsert semantics that E4 must survive** (`agent-request.service.ts:225–325`): insert `areq_<nanoid12>` with `ON CONFLICT (organizationId, idempotencyKey) DO NOTHING`; when the row exists, `UPDATE … SET values` overwrites **every** value column, including `status` (back to the input's, `open` for V1/V2), `evidence`, `proposedOutcome`, `title`, `summary`, `pendingActionId` (input ?? NULL) and `recommendationIds` (input ?? `[]`). The listing-change caller checks `created` only after the upsert (`aso-agent.ts:886–899`), so an audit that re-proposes an already-completed type for the same (asset, store) resets that request to `open` and erases its links. The locale wave caller derives `waveIndex` from wave state that drops failed requests (`aso-agent.ts:4495–4531`, `:603–607`), so a failed wave's key can be reused the same way. The re-upsert event is recorded as `created` again with `data {kind, phase, status, blockerCode}` only (core `agent-request.ts:393–398`). Consequence: current link columns are not the only surviving references. §3 conserves event arrays and back-pointers separately. None proves the old manifest or draft bytes; §6 records reset evidence without reconstructing either.

### 1.2 Completion writers (output-column setters; clearing and other writers are in §1.5)

| Writer | Command | Links | Data on the event |
|---|---|---|---|
| **W1** listing change drafted, `aso-agent.ts:1179–1188` | `complete({phase:'draft', links:{pendingActionId: applyCardId, recommendationIds:[applyCardId]}})` where `applyCardId = 'pending_aso_' + plan.id` (`:1124`) | both columns, same single id | none (message only) |
| W1f listing change failed, `:1140–1150` | `fail({phase:'draft'})` after the apply card was marked `failed` | none | none |
| W1n listing change no-op, `resolveNoChange` `:1008–1024`, used at `:1041`, `:1057`, `:1172` | `complete({phase:'draft'})` | none | none |
| **W2** locale drafted, `locale-hypothesis.ts:199–224` `completeLocaleHypothesisDraft`, called from `aso-agent.ts:564` | `complete({phase:'draft', data:{pendingActionIds}, links:{recommendationIds: pendingActionIds}})` when ≥1 id | `recommendationIds` only; `pendingActionId` untouched (NULL) | `data.pendingActionIds` |
| W2f locale zero output | `fail({… same data and links …})` when 0 ids | `recommendationIds: []` | `data.pendingActionIds: []` |

The core service applies links only on `complete` (`agent-request-service.ts:255–274`) and records one `agent_request_event` per accepted transition with `sourceAgentRunId`, `message` and `data` (`:173–182`). `fail` ignores `links` (`:275–289`), so W2f's links are dropped and only the event `data` survives.

### 1.3 Card writers the links point at

| Card | Writer | Id | Params that matter for E4 | Upsert behaviour |
|---|---|---|---|---|
| `create_locale` | `locale-expansion.ts:2012–2071` inside `stageLocaleExpansionForReview` (`:1757`) | `pending_aso_locale_<assetId>_<locale>` — **no store component** | `assetId, store, locale, localeClass ∈ {new, update, repair}, metadata (operator field scope applied), englishGloss?, variantId, recommendationId = plan.id, hypothesisRequestId?, operatorInstructions?, keywordResearch?` | `ON CONFLICT (id) DO UPDATE` sets `params` **wholesale**, `reason, status='pending_approval', orchestratorRunId, sourceAgentRunId` for prior statuses `{pending_approval, superseded, rejected, expired, failed}` (`:2222–2254`); rows carrying the human-edit marker are excluded first (`:2093–2135`) |
| its variant | same, `:1990–2004`, `:2140–2160` | `md5('aso_recommendation_variant:locale_expansion:<assetId>:<locale>')` (`:102–116`) — **no store component**; `recommendationId = md5('aso_recommendation:locale_expansion:<assetId>:<store>')` (`:117–137`); `UNIQUE (recommendationId, locale)` | `proposal {metadata, rationale, keywordAnalysis, englishGloss?, research?, sourceFingerprint?, humanEditedAt?}` | `ON CONFLICT (id) DO UPDATE proposal, status='draft'` for `{draft, rejected, expired, failed}`; `recommendationId` is not in the SET list |
| `apply_listing_changes` | `aso-agent.ts:5657–5785` inside `draftAndEmitListingChanges` | `pending_aso_<plan.id>`; `plan.id` is `deterministicId(…)`, a SHA-256 over a sorted JSON object (`recommendation-loop.ts:606–640, 877`); exact members and mutation limits are in §1.4 | `assetId, store, scope:'all_locales', locales: Record<locale, {before: Record<field,string>, after: Record<field,string>}>` (`:6325–6339`, read back by the executor at `:1718–1722`), `recommendationIds:[plan.id]` (**aso_recommendation ids, not pending_action ids**), `recommendationType, riskLevel, parentId?, cycleNumber?`; **no `variantId` and no back-pointer** on agent-emitted cards (`:5657–5677`) | inside a transaction under the per-field advisory locks: an existing `pending_approval`/`failed` row is updated (`locales` merged only when `mergeExistingApplyLocales`, retries), any other status is skipped as terminal; chat-owned locales are dropped before write. The plan and one variant per locale are persisted **before** emission in the same run (`persistRecommendations`, called at `:704`, body `:6189–6238`), variant key `(recommendationId = plan.id, locale)` |
| immediate field update | `generated-listing-updates.ts:99–104, 243–276` | `pending_aso_<suffix>_<assetId>_<locale>` per definition key | definition params; no variant, no `hypothesisRequestId` | not an E4 target; identity is the pending-card anchor (E1 family) |

**Which ids reach W2.** `stageLocaleExpansionForReview` pushes an id for **every** generated locale before the human-edit filter (`:2066–2071`), and the agent passes `toStage = [...batch.generated, ...partition.reused]` (`aso-agent.ts:440`; reused = fingerprint-current cached variants, `locale-expansion.ts:1262–1300`). So `recommendationIds` after W2 contains newly created cards, refreshed pre-existing cards, cards restaged from cache without a model call, and cards left untouched because a person edited them. The array proves that the run *referenced* those locales, nothing more. The worker door (`process-aso-locale-expansion.ts:763–789`) stages additively without a request and never calls W2; its cards carry no `hypothesisRequestId`.

**Back-pointers.** `create_locale.params.hypothesisRequestId` exists only when the agent passes it (`aso-agent.ts:473`, from `executeApprovedLocaleDraft:556`), and because the restage upsert replaces `params` wholesale, the pointer names only the **latest** restaging request, or disappears when the latest restage came through a path that passes none. `apply_listing_changes` carries no back-pointer. Current output columns prove its request reference; its own card ID and params prove the emitted plan association. The request evidence plan may be older (§1.4). Run equality is not a substitute for an erased reference.

**Human-edit marker.** `params.humanEditedAt` (ISO string; constant `DRAFT_HUMAN_EDIT_PARAMS_KEY`, `inbox-work-actions.ts:894`) is written by `update-locale-draft.ts:79–86` only for source `human` and only on `pending_approval` `create_locale` rows; mirrored onto the variant proposal. No writer marks an `apply_listing_changes` card; a human revision of one produces a successor card through inbox iteration (E7). Readers: locale staging skips both rows of a marked locale (`locale-expansion.ts:1606–1660, 2093–2135`); revise-by-prompt never auto-closes a marked ticket (`supersede-revised-card.ts:133–143, 290–303`); the catalog treats a marked draft as not generation-produced (`localize-submission.ts:161–172`).

---

### 1.4 Additional source findings that change the decoder

Source references below are at `e7c094c8`. Code blocks abbreviate formatting and local variable names for readability; the cited source ranges are authoritative.

**The approved listing request rebuilds its plan.** `aso-agent.ts:1027–1040`:

```ts
const audit = buildASOAuditPayload(args.localeInputs, new Date(), args.store);
const basePlans = buildRecommendationPlansFromAudit(args.assetId, audit, args.store);
let plan = basePlans.find(p => p.type === recommendationType);
```

Then `:1124` builds the card ID as the literal prefix `pending_aso_` plus `plan.id` from that rebuilt plan, and `:1179–1188` completes with both output columns. The request's original `evidence.planId` is not rewritten here. Therefore equality to that original ID is **not** an admission rule. Resolve the emitted plan from the referenced card; retain the hypothesized plan independently as evidence.

**Creation time is not generation evidence.** The update branch at `aso-agent.ts:5735–5765` sets `params`, `sourceAgentRunId: runId` and `updatedAt: new Date()` but leaves `createdAt` unchanged. A card inserted at 10:01 after a 10:00 approval can be updated at 10:02 and still satisfy revision 2's alleged insert predicate. Locale staging likewise overwrites run/params (`locale-expansion.ts:2222–2254`), and cached variants enter the same writer (§1.3). No comparison of `createdAt`, `approvedAt` and the latest run distinguishes generation from restaging. Creation time can nevertheless prove physical-row recreation against a preceding completion (§3.3); that is a different fact and must be retained. Equal card/variant text proves only present correspondence; both are mutable. A human marker proves an edit was marked, not that every character was human-written or who wrote it.

**Plan/variant ID inventory is resolved.** `recommendation-loop.ts:609–637, 877–905` constructs:

```ts
recommendationId = deterministicId('aso_recommendation', {
  assetId, recommendationType, findingIds: sortedFindings.map(f => f.id)
});
variantId = deterministicId('aso_recommendation_variant', {
  recommendationId, locale, proposal: variantProposal
});
// deterministicId: prefix + '_' + sha256(JSON.stringify(sortDeep(payload))).slice(0, 24)
```

`sortDeep` orders object keys with JavaScript `localeCompare`, preserves array order, and recurses. The plan payload has no explicit store; the variant payload contains the pre-enrichment proposal. `recommendation-analysis.ts:2794–2809` replaces `proposal` while spreading `...variant` (retaining the ID). `aso-agent.ts:6213–6238` upserts variants by `(recommendationId, locale)` and updates their proposal without replacing their ID. Do not recompute a historical variant ID from today's draft or use either hash as store/content proof. Use stored IDs, actual plan asset/store/type, exact variant association and collision checks. These legacy codecs are not the E4 netstring codec.

**Apply-field inventory is resolved.** `apply-field-diff.ts:23–34` maps `appName→name`, `name→name`, and identity mappings for `title`, `subtitle`, `shortDescription`, `description`, `promotionalText`, `keywords`, `whatsNew`. Lines 46–55 map recommendation types: promotional_text→promotionalText; title→title; subtitle→subtitle; title_subtitle→title+subtitle; keywords→keywords; description→description; short_description→shortDescription; name→name. Other types have no expected-field assertion. The writer loops proposal entries, skips invalid/no-op values and writes `after[applyField]` (`:124–197`); it does not translate `title` into `name` here. Conflicting `appName` and `name` values cannot be resolved by inventing an ordering lost in JSONB. E4 imports the card's actual `before`/`after` through the listing decoder and retains variant evidence separately; it does not regenerate a diff or infer authorship from present equality. Unknown listing-content shapes remain the listing decoder's explicit refusal, not stripped fields.

**Event limitations are concrete.** W1 events have no output IDs; W2 events have the exact `pendingActionIds` array. Upserts clear columns and replace manifests without recording their old values. A same-run V2 card, even with the original plan ID, does not distinguish W1 success from W1f failure or a no-op, nor bind the old output snapshot. Preserve the event and the independently imported card; do not manufacture an output edge from proximity, run equality or current `evidence.planId`.

---

### 1.5 Repair, lifecycle, dependency and deletion writers

Additional exact-pin inventory from the independent review and a search for every production `update(agentRequest)` at `e7c094c8`:

| Writer / source range | Conserved effect |
|---|---|
| `legacy-inbox-repair.service.ts:51–96, 148–239` | `inferLegacyProposedOutcome` can infer kind from evidence/key, prefer old outcome locales over evidence, preserve an existing outcome store or use `evidence.store ?? 'ios'`. It does not write evidence. It can normalize outcome; reopen approved/failed to open and clear approvedBy/approvedAt; or mark unsupported shapes superseded with `legacy_lifecycle_unsupported`. Events are retried with repair=`FLO-822`, normalized/reopened flags, or superseded with repair=`FLO-822`; not created. |
| `aso/collapse-no-open-release-duplicates.ts:146–166` | V3 survivor idempotency key is rewritten; duplicates become superseded. No successor column is written. Preserve exact keys and superseded event messages; a prose-mentioned survivor is not a proved successor FK. |
| `agent-request-unblock.service.ts:299–325, 352–398, 560–575, 716–745, 803–816` | V3 verification can retain blocked status or set completed, clear blockerCode, and maintain `blockerContext.unblockFinalization` pending/finalized state, target IDs and retry facts. Completion can precede its finalization event. Keep those facts; they are not E4 output-column edges or provider-execution proof. |
| `aso/experiment-ticket-link.ts:94–105`; `aso/reconcile-experiment-tickets.service.ts:213–234` | Set experimentId by pending-card association; conserve as the actual E12 experiment dependency. No output-array or manifest rewrite. |
| `agent-request-dispatch.service.ts:34–64`; core `agent-request-service.ts:190–300` | Auto dispatch invokes the real approve command/event, with nullable actor, and may compensate by reopening. Reopen clears approval columns, not rejection columns; fail/retry do not clear output arrays. Approval policy and occurrence of an approval event are overlapping facts. |
| `inbox-housekeeping.service.ts:115–166` | Supersedes stale non-blocked-kind open requests through the core command, with housekeeping event data. Does not prove generation, fulfillment, child disposition or a successor. |
| `scripts/flo-486-fix-no-open-release-cta.ts:48–78` | Rewrites only blocker guide CTA and updatedAt. Preserve display facts; updatedAt is not a manifest-change timestamp. |

Hard deletion can remove cards while request rows and events survive:

| Path | Effect |
|---|---|
| `maintenance/reset-agent-state.ts:143–166` | Deletes org cards and runs, plus recommendation/variant rows, without deleting requests. |
| `routes/admin.ts:4080–4100` | Deletes selected agents’ pending actions and runs; requests survive. |
| `maintenance/purge-removed-agent-history.ts:470–508` | Deletes agents (cascading through runs/cards) and stranded cards by agent type. |
| `capability-catalog.service.ts:3843–3845` | Deletes a failed submission’s run shell; the card FK cascade applies if dependent cards exist. |

`schema.ts:4685–4687` cascades pending_action from orchestratorRunId; `:4913–4917` sets request.pendingActionId NULL when the card is deleted, without clearing recommendationIds. Because card IDs are deterministic, later insertion can recreate the same ID. Hence `(NULL,[r])` is admissible whether r is currently missing or present. Record `column_cleared`; never infer the old physical row survives from ID equality.

Retain **all** source events: created, approved, rejected, blocked, retried, superseded, completed, failed. Repair and collapse do not invent new event types. Retain repair data and current decision columns separately from event counts; a repair is not an upsert. V3 key normalization does not re-key a destination ticket: the anchor is always the permanent source request identity, never its mutable idempotency key.

---

## 2. Identity anchors

| Thing | Domain / kind | Creation key | Alias |
|---|---|---|---|
| **Request parent** (V1, V1d, V2) | `collection` ticket; its revision holds title, summary and exact membership. Request-level promise/supporting prose remains subject to the parent-note sealing gate below | ledger `migrationCreationKey(org, 'agent_request', id)` | `action_alias(namespace='agent_request', old_id=areq_…)` |
| **Per-locale request child** (one per `proposedOutcome.locales[i]`) | `agent` ticket; revision kind `request`, `agent_work.request(intent ∈ {locale_expansion, listing_change}, store, locale, …)` per contracts §2.2 and ledger §4.2 | **E4 child key** (§2.1) | none from source; discoverable through the parent's membership |
| **Locale card** (`create_locale`) | `listing` ticket by the pending-card anchor (E1 rule) | ledger pending-action key | `pending_action` alias; additional plan/variant aliases only where E1 independently proves the same-work class |
| **Listing-change card** (`apply_listing_changes`) | `collection` package with per-locale `listing` children (contracts §2.6) | E1 package/child keys; never the E4 request-child key | pending-action alias resolves to package root; one plan alias must not be copied onto multiple children |
| **Blocked request** (V3) | one ticket per ledger `blocked` mapping; no E4 children | ledger request key | `agent_request` alias |

Why the drafted card is not the same ticket as the request child: `action.domain` is fixed per ticket (`schema-core.sql:26–33`) and v6 binds revision content family to domain (v6:153–156), so a hypothesis (agent domain, request content) cannot later carry listing content. Contracts §1.4 precedence selects a key for the *request child*, while the card keeps its own; the two are linked by the proofs in §3, not merged.

**Parent-note sealing gate (G1).** Ownership v6 §5.1 currently forbids content leaves on an ordinary collection proposal. Destination contracts §2.3's note mapping does not by itself authorize attachment to this parent. Preserve exact ordered `whatWillHappen` and directed `supportingEvidence` values, including empty arrays, in the source/conservation input; the latter already has a typed history mapping in ledger §4.2. Do not regenerate, drop, or copy the parent prose onto every child. Until one canonical typed owner and an explicit proposal/historical sealing-and-read contract are integrated, any component requiring that unsupported attachment remains blocked as `unmapped_content`; it must not receive a successful import marker. A future closed request-package shape could reuse the existing notes relation, but this revision does not silently introduce it or loosen generic collection sealing. Avoid a second independent copy of the same ordered source text.

### 2.1 The E4 child key codec

Tuple, in order: `['e4-child:1', organization_id, request_action_id, store, locale, role]`.

- `request_action_id` is the parent's permanent Actions id (from the `agent_request` alias), not the source `areq_` id and not the idempotency key, which names a slot that upserts overwrite.
- `store` ∈ {`ios`, `android`} from `evidence.store`. `locale` is the exact string in `proposedOutcome.locales[i]`, no case folding or normalization; a differing spelling is a different anchor. Require exact evidence/outcome store and locale-list agreement; never infer locale equivalence. Reject duplicate manifest locales with `manifest_mismatch`, rather than silently changing ordered membership.
- `role` = `hypothesis_locale` for both intents; intent is revision content.
- Encoding: each field as UTF-8 bytes, prefixed by its byte length in ASCII decimal and `:`, terminated by `,` (netstring form); concatenate; SHA-256; format as a UUID exactly as the prototype's review key does (`review-work.ts:52–69`): hex 0–7, 8–11, `5`+13–15, `a`+17–19, 20–31. `action.creation_key` is `uuid NOT NULL` (`schema-core.sql:29`); `materializedActionId(org, creationKey)` (`materialize.ts:87–93`) derives the action id.
- Compare the full decoded tuple as well as the hash on replay; equal keys with unequal tuples block as `identity_collision`. Reuse a proved existing permanent child target before minting a new ID. UTF-8 byte lengths, including non-ASCII and delimiter-bearing values, are fixture requirements.
- Never in the key: `waveIndex`, `planId`, `recommendationType`, `localeClass`, `language`, any pending-action id, any variant id, timestamps.

### 2.2 Source identities are weaker than the destination anchor

The locale card id and the variant id omit `store`; the plan id includes it. An asset on both stores (FLO-571 merges same-bundle assets) staging the same locale on the second store upserts onto the first store's card and collides on the variant primary key while `recommendationId` stays the first store's plan. The importer takes `store` from `params.store` **and** recomputes `md5('aso_recommendation:locale_expansion:<assetId>:<store>')` for both stores to find which plan the variant belongs to; if the surviving card, variant plan and referencing request disagree on store, block with `store_ambiguity`. Also validate the actual plan asset/store, not just the hash. If a referenced variant or plan is missing, retain its exact source ID and unavailable-target fact on the card history through the E1 listing decoder; do not dereference NULL or assert its store. Existing contradictory evidence blocks; missing dependency evidence is labelled unavailable. An overwritten prior store is unrecoverable and is not inferred.

---

## 3. Reference collection and resolution — deterministic order

This section replaces revision 2's inferred handoff predicates. All references below describe the frozen source, not the current runtime head of a ticket.

### 3.1 Validate the request manifest and collect every actual edge

First dispatch by request kind/variant, then status (§4); do not apply a hypothesis manifest decoder to V3. For unrepaired V1/V1d/V2, require `evidence.kind/store`, `proposedOutcome.kind/store`, and `evidence.locales[].locale` versus `proposedOutcome.locales` to agree, with nonempty unique locale strings. V2 duplicated recommendationType/planId must agree with each other, not with the rebuilt emitted plan.

**FLO-822 normalization branch.** A retained retried event with `repair='FLO-822'` and `normalized=true` conserves that repair as evidence; it is not proof of the overwritten preimage or that every current difference was caused by repair. Decode authoritative request scope from explicit, valid evidence. A repaired outcome may omit duplicated planId/findingIds because the repair does not synthesize them; retain absence and use the actual evidence values for the request content. A missing evidence store must never become proved iOS merely because the repair defaulted outcome.store. Missing authoritative store blocks `store_ambiguity`; contradictory explicit stores/locales still block `manifest_mismatch`, with the repair marker reported separately. Strict repaired-shape decoding may establish request scope, but it does not complete conservation. Ledger §4.2 currently retires `proposedOutcome` only on exact equality to its declared evidence projection; it provides no independent destination for a differing repaired outcome. Keep unequal outcomes blocked as `unmapped_content` until an exhaustive closed codec names lossless typed destinations or an exactly reversible reconstruction for every key presence, value, array ordinal and unknown-key refusal. Retain the complete source; do not silently rewrite one object to match the other or claim a current typed destination exists. The exactly equal branch remains eligible subject to every other gate. Repair spreads prior outcome fields, so a shortcut for only missing planId/findingIds is not a complete codec.

Unsupported/malformed shapes block explicitly, with source data preserved for preflight. V3 creates no E4 child and any output-column/event-array/back-pointer edge on it refuses `unexpected_links`. Its unblockFinalization target IDs are separate blocker facts, not these output edges.

Collect these edge occurrences without inventing any:

| Origin / `link_kind` | Owning source record | Ordinal / conservation |
|---|---|---|
| `output_array` | current request | Original zero-based `recommendationIds` index; retain **every** occurrence, including duplicate IDs |
| `pending_action_column` | current request | 0, when `pendingActionId` is non-NULL |
| `event_output_array` | exact completed/failed event | Original zero-based `data.pendingActionIds` index, for every retained event with this supported array shape; empty arrays remain recorded in event facts |
| `back_pointer` | current request named by the card | Bytewise UTF-8 ascending card-ID rank among all cards naming this request, even when a forward edge also exists |

No "latest event" selection. The event record is part of identity, so multiple completion attempts cannot overwrite one another. Missing optional event output data is distinct from a recorded empty array. At this pin, output arrays on events are admitted only for completed/failed V1/V1d events. Their appearance on V2/V3 or another event type is an unsupported writer shape and blocks `shape_mismatch`. Wrongly typed arrays or non-string/empty entries block; do not use a stripping parser. Non-output event data is conserved by its existing typed event decoder, not discarded by this E4 projection. A card pointing to another existing request joins that request's closure; it neither invalidates nor proves the first request's edge. If the named request is absent, preserve the exact dangling request ID on the card history with `back_pointer_state=target_missing`; do not invent a request or an output-link row owned by it.

### 3.2 Validate current column pairs, independently of event edges

- V1/V1d: current `pendingActionId` must be NULL (`unexpected_pending_action_id` otherwise). Any number of array entries, including zero, is retained.
- V2: valid current pairs are `(NULL, [])`, `(r, [r])`, or `(NULL, [r])` regardless of whether r currently exists (the source FK can clear the column, then a writer can recreate r). The latter sets `column_cleared=true` and keeps the array edge, resolving it with the recreation qualification below if r exists; it does not invent the now-absent column edge. Any other current pair blocks as `link_disagreement`. A missing card with `(r,[r])` also resolves as missing if present in a legitimately captured source snapshot; do not fabricate a card.
- Empty current columns never invalidate a supported earlier event array. Those edges belong to their own event records. Conversely an event cannot repair contradictory nonempty current columns.
- A V2 event with no IDs remains a completion/failure claim with output evidence unavailable. There is no inferred V2 recovery edge. Cards remain independently importable by E1. This is a defined loss of evidence, not a request to manually manufacture an assessment or reconnect records by guesswork.

### 3.3 Resolve each collected edge

1. Find the exact card ID in the authorized census. If absent, `resolution=target_missing`, retaining the source ID. Stop target-dependent checks for that edge; do not fabricate a locale or variant.
2. Validate same organization and asset for every request/event/card/plan relationship. Cross-tenant or cross-asset edges block the component, including incoming back-pointers. Tenant authorization precedes exposing any foreign record.
3. Validate card action (`create_locale` for V1/V1d; `apply_listing_changes` for V2), exact store, and the appropriate listing-content decoder. Scope contradictions block. The request's current locale list does not erase an older event edge or an extra card locale; those references remain visible at the parent/history level.
4. V1: validate `params.assetId`, exact locale, deterministic pending-card ID, variant reference and store-qualified locale plan association where those dependency rows survive (§2.2). Missing dependencies are preserved as unavailable; contradictory surviving associations block `plan_mismatch`/`store_ambiguity`. A missing variant never fabricates generation provenance or makes the actual card disappear.
5. V2: obtain the **emitted** plan ID from the card's single `params.recommendationIds` entry and require `card.id == 'pending_aso_' + emittedPlanId`. Validate `params.assetId`, store and recommendation type against the current request, and against the actual plan if it survives. The hypothesized plan can differ. Missing emitted plan/variant rows retain opaque source IDs and unavailable-target facts on the card history through the E1 listing decoder; they do not erase the real output reference. Multiple or contradictory plan IDs block `plan_mismatch`; do not pick the first. E7 human successors import independently; a reference to an agent-emitted root stays on that root.
6. Resolve through E1's permanent alias to the card root and its **sealed imported content revision**. For a locale card this is one listing snapshot. For a listing-change card it is a collection package snapshot; its exact imported membership resolves each stored locale to one sealed listing child snapshot. No lookup against a mutable future head. Missing/duplicate/mis-scoped package membership blocks `package_membership_mismatch`.

**Recreation qualification.** Resolve the ID for navigation, then compute `target_recreated boolean NULL` separately from resolution. On a resolved event-array edge, compare the card’s database-default createdAt with that exact owning completion event’s database-default createdAt. For a resolved current-column/array edge, use the latest retained completed-event time for that request; preserve the event identity (or all tied latest event IDs), never choose a tied event as uniquely authoritative. A strictly later card time proves `true`; a comparable earlier/equal time gives `false` meaning **“recreation not proved”**, not “original row proved.” Absent events, incomparable timestamps or missing target give NULL (unavailable). Back-pointer-only edges have no completion claim to compare, so NULL. Do not use approvedAt or sourceAgentRunId as substitutes. Comparisons use database precision and the same validated source clock/session interpretation, not rounded dates or guessed time zones. These source writers default both creation timestamps in the database and stage before completing; an unverified older writer/clock cannot support the comparison.

For a V2 resolved array edge with `column_cleared=true`, `target_recreated=true` independently of event availability: the FK-cleared column shows the originally associated row was deleted, and a row now exists at that same ID. Label its basis `cleared_fk`; a time proof has basis `after_completion`; when both apply, retain both facts. The exact reference survives, but the recreated snapshot is shown as a replacement currently at that ID, never as the original completed output. Its new locales cannot prove which locales the deleted output contained. `column_cleared` with a still-missing target retains target_recreated NULL and the missing reference.

A successfully resolved edge has `resolution=resolved`. It asserts only that the recorded ID resolves to that imported card snapshot, qualified by the recreation fact; it never asserts the physical row or bytes survived from completion. Run IDs, created/approved times and human markers remain separately labelled source facts. Equality of card/variant bytes does not establish which request authored them.

### 3.4 Authorship and successor rule

For the writer inventory at this pin, E4 creates **no** `revision_source(kind='action')`, `revision_source(kind='agent_run')`, generation charge, approval, execution, or `successor_action_id` from these edges. Generated/restaged are deliberately absent from the admitted classification. Even a newly inserted card can contain cached copy, and both card and variant may have been replaced since completion.

Human-edit markers are conserved on the listing snapshot per contracts §2.1. They do not attribute the whole text to a human, supply an editor identity, or rewrite the request's historical decision. Provenance independently proved by another source remains that source's responsibility.

T2 from revision 2 is therefore **not enabled by this E4 codec**. Navigation uses the typed reference and exact package-child mapping, so no reference is lost by refusing an unproved workflow transition. A future writer retaining immutable request manifest + produced revision + actual generation/reuse receipt would need its own versioned codec before generation or successor semantics can be enabled. This future option is not a prerequisite for implementing the conservative legacy mapping.

---

## 4. Where the parent and children land

Per ledger v2 §8/§9.1, preserve policy, actual decision events, request variant, references and in-flight state separately. **Positive obligation gate (G3):** before any historical disposition in this table is applied, each accepted unfinished draft/verification/send/follow-up obligation needs either a reviewed durable successor or an explicit authorized non-executing disposition under the cutover protocol. Fencing prevents future old writes; it does not settle work already owed. Drain must establish the outcome and trigger a fresh stable census. Without that evidence, keep the component in recovery/preflight-blocked state and preserve source/queue facts; create no terminal historical-only replacement or success marker. Import cannot fabricate a new approval/execution/Usage charge to bridge the gap. The following is an explicit variant/status mapping, not an “all other statuses → historical” fallback. Unknown variants/statuses refuse `shape_mismatch` without manufacturing a collection.

| Variant · status | Parent | Per-locale request children | Preserved meaning |
|---|---|---|---|
| V1/V1d/V2 · open | work collection, decision open | work agent request proposals for the current proved manifest | Earlier decisions/outputs remain facts; no old reference settles current work |
| V1/V1d/V2 · blocked | work collection, decision open, explicit blocker facts | work request children for the proved manifest | Blocked drafting is not the V3 singleton; preserve exact blocker and any dispatched/in-flight work for fencing |
| V1/V1d/V2 · approved | historical collection plus exact approval facts | historical agent tickets, decision open | Distinguish policy-driven approve event, other approve event and created-approved shape; drain/fence dispatched drafting |
| V1/V1d/V2 · completed | historical collection plus completion claim | historical agent tickets, decision open | Preserve manifest at this disposition and qualified output references; no inferred produced revision or successor |
| V1/V1d/V2 · failed | historical collection plus failure claim | historical agent tickets, decision open | Failure can occur from open, so it does not imply a preceding approval |
| V1/V1d/V2 · superseded | historical collection plus supersession/repair/housekeeping facts | historical agent tickets, decision open | Source supersession is not child fulfillment or an inferred successor |
| V1/V1d/V2 · rejected | historical collection with rejection preserved under the matrix | historical agent tickets, decision open | Preserve the manifest at current rejection; a request-level rejection is not a separately recorded decision on each synthetic child |
| V3 · blocked | one work ticket under ledger blocked mapping | none | Exact blocker/guide facts; no hypothesis manifest required |
| V3 · completed | one historical ticket under ledger blocked mapping | none | UnblockFinalization pending/finalized/target/retry facts, plus completion event when retained; a pending finalization is still a cutover drain/recovery concern |
| V3 · superseded | one historical ticket under ledger blocked mapping | none | Collapse/repair source facts and retained key; no inferred successor from event prose |
| V3 · rejected | one historical ticket under ledger blocked mapping | none | Core reject admits blocked→rejected; preserve actual rejection claim |

All admitted V3 statuses forbid E4 output edges. V3 open/approved/failed are not emitted by the inventoried blocked-request paths; refuse those combinations pending a separately evidenced decoder rather than applying the hypothesis rows.

**T1 retained:** historical request children use the same identity codec as work children. They are history, excluded from current actionable work by record kind. An open historical child does not mean an active task requiring action. Approved V1d at creation has no human actor proof; retain the system creation claim instead of inventing an approval event.

A reset keeps today's work open even when an earlier event names a still-existing draft. Earlier manifests replaced by upsert remain unavailable. Exact source events retain their own ordered references, actor/run claims and timestamps. For V1/V1d/V2 at a non-open status, the current explicit `evidence.locales` is the manifest in force at the most recent transition to that status: the only evidence rewrite is the hypothesis upsert, which returns it to open (V1d inserts approved with that same evidence). Preserve this positive fact as `manifest_at_current_disposition=true` once the evidence decoder passes. FLO-822 may separately normalize outcome but does not rewrite evidence; retain that qualifier.

This proves the current disposition manifest, not every earlier approval manifest. Core fail and supersede can start from open; complete can start from blocked; policy dispatch records its own approve event. An old approved event/approvedAt can also survive a later upsert. **Latest approval exception:** for an inventoried V1/V1d/V2 row with status=`approved`, non-NULL approvedAt and valid explicit evidence, the current evidence manifest is the manifest at that latest recorded approval, without event-time ordering. A subsequent ordinary hypothesis upsert would make status open; a subsequent approve would rewrite approvedAt; repair/reopen would clear approval and return to open. Equal/missing event timestamps do not defeat this writer-state proof. This identifies the latest approvedAt claim only, not every older approved event, and does not import executable approval. Created-approved V1d with NULL approvedAt keeps its separately recorded creation basis; do not fabricate a missing approval timestamp or event.

For other statuses, including completed, correlate a historical approval with this manifest only when retained event ordering/writer evidence proves no intervening upsert or normalization; otherwise keep approval-membership proof unavailable. Earlier-cycle manifests remain unavailable. Evidence that identifies a stable current manifest does not prove exact generated content or a child successor.

---

## 5. Request leaf: historical-purpose matrix

- `agent_work.request` can exist under historical revisions of historical/historical_deleted tickets, with the same typed content checks as the governing matrix permits. Work proposals remain complete; no incomplete executable fallback.
- Current ordered manifest, request countries, competitors and notes are conserved with their source provenance. Lost old manifests are not filled from card locales.
- Historical request content receives no fabricated baseline, generated-from revision, approval or execution. Parent prose and unequal-outcome gates still apply. Output navigation is through §6, not an inverted generation link.
- A present authorized `revise/edit` can adopt an eligible historical request with a fresh complete proposal, applying the matrix's cap and lifecycle rules. Import itself does not perform that adoption.

---

## 6. Typed output reference, snapshot mapping and erasure (T3)

Logical relation `history.request_output_link` (physical consolidation remains the ledger's DDL responsibility). Every tenant key below explicitly includes `organization_id`. **Storage versus projection (G4):** occurrence identity, exact source target ID and imported action/revision binding are retained facts. The diagnostic fields `column_cleared`, `target_recreated`, `recreation_by_cleared_fk`, `recreation_by_event_time`, and the derived witness set below are computed from immutable request/event/card facts using the pinned import codec and validated clock provenance. They are not independently written history columns or a new authoritative witness table. The following table states their closed returned types alongside the retained fields; the distinction is normative. Computation never consults mutable runtime heads. If source evidence is unavailable/redacted, the projection returns the specified unavailable state, not a stale materialized verdict.

| Column | Type / rule |
|---|---|
| `organization_id` | text NN; tenant-qualified composite PK/FKs throughout |
| `request_record_id` | text NN FK source_record; source kind agent_request |
| `owner_record_id` | text NN FK source_record; request itself for column/back-pointer edges, exact event for event-array edges |
| `link_kind` | closed enum NN `output_array`, `pending_action_column`, `event_output_array`, `back_pointer` |
| `ordinal` | integer NN CHECK >= 0; §3.1 |
| `source_pending_action_id` | text NN; exact source ID, never discarded when target missing |
| `resolution` | closed enum NN `resolved`, `target_missing` |
| `resolved_action_id` | nullable tenant FK action; card root (package root for V2), `ON DELETE RESTRICT` |
| `resolved_revision_id` | nullable tenant/action FK action_revision; sealed imported card snapshot, `ON DELETE RESTRICT` |
| `column_cleared` | boolean NN; true only on a V2 current output_array occurrence where pendingActionId is NULL and recommendationIds=[r] |
| `target_recreated` | boolean NULL; §3.3; NULL unavailable, false not proved, true recreated |
| `recreation_by_cleared_fk` | boolean NN; resolved current V2 array edge with column_cleared |
| `recreation_by_event_time` | boolean NN; strict same-clock creation-after-completion proof |

PK `(organization_id, request_record_id, owner_record_id, link_kind, ordinal)`. `target_missing` iff **both** target columns NULL; `resolved` iff **both** non-NULL. The revision FK includes `resolved_action_id`, so a revision of another action cannot satisfy it. Event owner must be source kind agent_request_event with `parent_record_id=request_record_id` in the same tenant/asset; non-event owners must equal request_record_id. Column edges require ordinal 0. Persist neither mixed-NULL target pairs nor cross-request event owners. All retained history rows are immutable after import except governed erasure; runtime producer updates cannot repoint a historical link. Stored-row SQL CHECKs:

```sql
CHECK ((resolution = 'target_missing' AND resolved_action_id IS NULL AND resolved_revision_id IS NULL)
    OR (resolution = 'resolved' AND resolved_action_id IS NOT NULL AND resolved_revision_id IS NOT NULL));
CHECK (link_kind <> 'pending_action_column' OR ordinal = 0);
```

The following are logical projection invariants, not deployable SQL or stored columns:

```text
INVARIANT (resolution <> 'target_missing' OR target_recreated IS NULL);
INVARIANT (NOT column_cleared OR link_kind = 'output_array');
INVARIANT (NOT recreation_by_cleared_fk OR (column_cleared AND resolution = 'resolved'));
INVARIANT (NOT (recreation_by_cleared_fk OR recreation_by_event_time) OR target_recreated IS TRUE);
INVARIANT (target_recreated IS DISTINCT FROM TRUE OR recreation_by_cleared_fk OR recreation_by_event_time);
```

Closed enums and NN retained fields prevent three-valued CHECK bypasses in the two SQL checks. Composite FKs enforce tenant/action/revision identity; seal/relation validation additionally enforces event parentage, request variant, shared asset and snapshot shape. Expose the exact event witnesses for a time comparison as the closed derived relation `request_output_recreation_event` over retained source events: each returned witness is keyed by the full output-link identity plus `event_record_id`, joined through the existing same-tenant source-record relation; event must belong to this request and be completed, or be the exact supported owning event for an event-array edge. Keep all tied latest witnesses for current edges. The derived witness set is nonempty iff recreation_by_event_time=true; validate the strict timestamp inequality and source-clock basis. Keep all underlying events and their exact identities, so this set is reproducible for the pinned interpretation. This is a typed read result, not an additional physical relation or deletion dependency. No optional guessed completion event, JSONB, EAV or unspecified evidence blob.

**Snapshot expansion `targets(link)`.** Missing link → empty set, with missing state retained. Resolved locale root → its sealed listing snapshot `(store, locale, action_id, revision_id)`. Resolved package root → the exact sealed child revisions recorded by that package revision's membership. The existing prototype actually stores both `child_action_id` and `child_revision_id` on membership (`packages/database/src/schema-actions.ts:2633–2690`, frozen prototype read-only); no new mutable-head inference is needed. Each pair `(store,locale)` appears once; validate tenant, asset, domain and store and preserve the full source-card locale set. Duplicate references may share targets; they remain distinct evidence rows. This expansion never consults request-child successors or current heads, and creates no additional request children for package locales outside the manifest.

**Derived per-child view.** For current request child `k=(store,locale)`, return three separate groups:

- `current_outputs`: distinct target snapshots matching `k` from **current** column/array links whose target_recreated is not true; include all originating link keys. One target yields `referenced`; more than one yields `multiple_references` and shows all, without choosing a successor. This is a count of referenced targets, not proof of generation or completion.
- `historical_references`: matching non-recreated snapshots from each event-array/back-pointer link, separately labelled with that exact origin. These do not become current outputs or approval-time membership. Extra locales remain visible at the request/history level without fabricated children.

- `replacement_references`: every resolved edge with target_recreated=true, labelled “Recreated after the referenced output” and with its proof basis. Show its current snapshot for navigation, but exclude it from current_outputs and historical-original output matches. Keep these also at request level because replacement locales do not recover the original locale set.

If no current target matches, return `evidence_unavailable` when any current link has a missing target (its locale is unknown), or when only event/back-pointer references survive, or when a recreated target or overwritten/decision-reset cycle is proved (§6 facts). Otherwise return `not_drafted`, whose UI meaning is **“No recorded output for this locale”**, never “no draft has ever existed.” Missing targets always remain explicit in the request-level reference list, even if another resolved target matches a child. Missing event targets stay in history and do not invalidate a valid current target. The ordered manifest supplies the child population; absence is never derived by subtracting package-root IDs from child IDs.

**Facts and event conservation.** Preserve the original typed request/event/card fields, ordered occurrences and absent-versus-empty markers once. All named request diagnostic flags/enums below, event output_count, and card back_pointer_state are closed read-model projections over those facts; do not add independently writable columns for them. The event output_evidence marker preserves recorded-empty versus absent data, and hypothesis_request_source_id preserves the exact source pointer; these are retained facts. `history.event_detail_target` and `history.request_output_link` overlap for event output occurrences: consolidated DDL must choose one canonical stored occurrence with the other exposed as a projection, not dual authoritative writes. Use the same tenant/erasure scope and pinned interpretation version:

- Request `repeated_upsert_seen boolean NN`: more than one retained created event. Keep this literal meaning; a repair is not an upsert. Separately, `repair_normalized_seen boolean NN` and `repair_reopened_seen boolean NN` come from retried events with repair=FLO-822 and the corresponding true flag. `manifest_rewrite_seen boolean NN` is repeated_upsert_seen OR repair_normalized_seen; it captures both writer families without conflating them. Preserve the exact repair events and their fields, not just flags.
- Request `reset_after_decision enum NN {not_proved,after_approval,after_rejection,after_both}`: for status=open, approvedAt NN proves after_approval and rejectedAt NN proves after_rejection; retain both when both columns survive. For non-open or neither column, not_proved. These columns persist through ordinary upsert, so this proof does not require timestamp ordering. Reopen clears approval but not rejection, so the fact describes a reset, not exclusively an upsert. False/absent evidence does not prove no reset occurred.
- Request `approval_policy_auto boolean NN`, `approved_event_seen boolean NN`, `created_approved_seen boolean NN`: respectively current draft policy auto, any retained approved event, and retained created event with status approved plus V1d creation shape. Actor evidence belongs to each event. Derived `approval_origin enum NN {none_recorded,policy_auto,approve_event,created_approved,multiple}` counts these bases; multiple retains their combination. Auto dispatch actually emits approved, so policy_auto and approve_event are not mutually exclusive and neither alone proves human approval. The current policy is not backdated onto all old events.
- Request `manifest_at_current_disposition boolean NN`: true only for valid explicit evidence of a non-open V1/V1d/V2 as described in §4; repair_normalized_seen is a separate qualifier. For status approved with non-NULL approvedAt, §4 additionally proves the current evidence manifest at that latest approval, even without ordered event times. Preserve that claim’s membership proof against the exact imported parent membership; actor evidence and content-generation proof remain separate. This does not upgrade older approvals or manufacture a current executable approval.
- Request `reset_after_completion boolean NN`: current links are empty and a retained `created` event has a strictly later source time than a retained completed/failed event. Equal or missing times do not prove order. Preserve the event identities/times independently; this flag is a conservative observed reset fact, not complete reset detection.
- Completed/failed event `output_evidence enum NN {recorded_array, unavailable}` and `output_count integer NULL`; recorded_array iff count NN >= 0. Event link ordinals must be exactly `0..count-1`. Empty is not unavailable. W1 events without IDs have output_evidence unavailable.
- Card `hypothesis_request_source_id text NULL` plus `back_pointer_state enum NN {absent,resolved,target_missing}`; absent iff source ID NULL. This conserves an exact dangling pointer even when there is no request row to own a link. Resolved pointer requires same-tenant/asset request and the reverse link occurrence.

No single `completion_event_record_id`: a request may retain multiple completions. These derived facts never replace the underlying source evidence.

**Erasure.** Link rows share the request's asset scope. Asset erasure deletes the links **before** deleting their referenced revisions/actions and source records, within one transaction; this explicit order satisfies RESTRICT (a transaction alone does not). All referenced targets must share the asset, including package children. Personal erasure must redact actor facts without removing the non-personal event/output identity. Organization erasure uses the same dependent-first order for all its scopes. No individual physical ticket/revision purge is admitted while a link references it; `historical_deleted` keeps the row and sealed snapshot. An out-of-scope surviving dependency follows the governing mixed-component policy rather than blanket cascading. Link state never changes by nulling a resolved target.

---

## 7. Create, update, repair and human-edited reuse

`localeClass=new/update/repair` maps to listing intent create/update/repair. It is content, not an E4 key field. Missing overwritten earlier classes stay unavailable. Worker-door cards with no request remain standalone E1 listing work.

Preserve `humanEditedAt` wherever retained, without inventing the editor or asserting that the whole draft was human-authored. Enforce the destination's human-edit protection on future automatic updates; E4 references do not relax it. Preserve dismissed fields, operator field scope, gloss and pins through the listing decoder. The card's actual metadata/after map is the listing snapshot; a variant mismatch is not permission to replace it or mint a new request-derived listing identity.

---

## 8. Closure, failure ordering and verification

Compute the transitive closure to a fixed point: request and all events; current/event-array cards; reverse back-pointer cards; all other requests referencing any included card through **any** of those origins; the requests named by included back-pointers; E1 equivalence and E7/E14 lineage neighbors; package roots/children and their exact snapshots. Consume referenced plan/variant versions or their proved absence through the E1 listing decoder. E11 is capability execution and E12 is the experiment link; neither is a plan/variant destination. Missing plan/variant IDs must not enter FK-backed action_revision_source as if a target row existed. Shared-card grouping requires an incoming-edge index, not just walking a card's one latest back-pointer. Missing targets are consumed absence checks: a newly appearing card or incoming edge changes the component fingerprint and must invalidate apply/replay.

Authorize and validate tenant scope before diagnostics. Then validate source/manifest shapes, current column pairs, existing target scope/shape and plan associations, E1 identity and sealed package membership. A missing target stops only that edge's target-dependent checks; it does not suppress another edge's contradiction. Resolve all aliases/snapshots before writing link rows. Deterministic ordered locks, source fingerprints, mapping digest, replay precedence and atomicity follow ledger §9.2 and contracts §3. No provider/network/model calls during import. Transactional output conservation must compare every collected occurrence with its stored link key and exact source ID; a complete component has neither missing nor extra rows, and each resolved snapshot decodes back to the frozen card content.

E4 refusals: `unmapped_content` (the existing source-conservation gate, not a new public command kind), `shape_mismatch`, `manifest_mismatch`, `unexpected_pending_action_id`, `link_disagreement`, `unexpected_links`, `cross_tenant`, `asset_mismatch`, `store_ambiguity`, `plan_mismatch`, `package_membership_mismatch`, `identity_collision`. Exact missing targets/dependencies are preserved as unavailable; they are not guessed identities. No `foreign_back_pointer` refusal.

### Required implementation fixtures

1. V2 package with two locales: both column references resolve to one package snapshot; each child finds its own listing snapshot and reports referenced, never not_drafted because its ID differs from the package ID. No successor or generation provenance.
2. Card created after approval, then updated by a later run: reference survives; neither run gains inferred authorship. Same result for newly inserted cards populated from cache and for missing approval times.
3. V2 emitted plan differs from request hypothesis plan: accept the actual coherent emitted plan; reject mismatched card-ID/params/actual-plan scope, not the legitimate rebuild.
4. Empty current links plus earlier W2 event IDs: retain event-owned edges, no link_disagreement and no automatic current-work completion. Two earlier events with different IDs both survive.
5. Empty V2 current links plus same-run card: event output evidence remains unavailable; no inferred output link. A failed/no-op same-run case yields the same absence of inferred linkage.
6. V2 `(NULL,[missing])`: column_cleared and target_missing. `(NULL,[existing])`: column_cleared and a qualified recreated replacement reference. Two differing non-NULL column IDs or multiple V2 array entries: link_disagreement. Current malformed columns still refuse even when an earlier event is valid.
7. V1 human-protected and cache-reused cards: retain references/markers and exact card text, no generated/restaged labels or fabricated human actor.
8. Shared card with latest back-pointer to another request: both requests join the same closure; all actual references survive; no authorship chosen by pointer or timestamp.
9. Back-pointer-only card: no fabricated completion event. Missing pointed request retains exact ID on card facts, with no phantom request/link owner.
10. Duplicate IDs in V1/V1d current/event arrays: preserve every source ordinal; child view deduplicates identical target snapshots only. Same target from current column, current array and event has three independently identified origins.
11. Zero-output recorded event versus missing event data versus missing card: preserve three different evidence states; unknown-locale missing target never becomes a confidently undrafted child.
12. Changed manifest after upsert: only current locales become children; old event-card locales remain historical references; no inference of old approval membership.
13. Missing variant/plan: unavailable dependency with existing card retained. Contradictory surviving store/asset/plan or foreign tenant: component refuses. An independently malformed listing snapshot still refuses under E1.
14. Package evolves after import: link expansion uses the sealed imported membership and child snapshots, not today's head. Duplicate locale membership or wrong child store refuses.
15. Multiple current targets for one locale: multiple_references, all shown, no arbitrary winner. Extra package locale: parent reference retained, no extra request child.
16. Asset erasure deletes stored link dependents before targets/source records in one transaction; derived witness/projection results disappear with their input facts; tombstoning keeps links/snapshots. Personal actor erasure preserves non-personal output identity. Real-role DB fixture must demonstrate FK behavior.
17. E4 netstring vectors: delimiter-bearing and non-ASCII inputs, both stores, different roles/parents and injected hash collision; exact tuple check refuses unequal tuples sharing a key. Duplicate manifest locales refuse.
18. New incoming edge, changed referenced bytes, appearing formerly missing target or incompatible replay mapping invalidates apply atomically. No partial component marker or fabricated execution/approval/usage survives a refusal.
19. Non-open hypothesis: preserve its evidence manifest at the current disposition, including FLO-822 normalization qualifier, without assigning a child workflow decision or backdating it to an older approval. Open with retained approvedAt/rejectedAt: record each decision-reset fact, including both and equal-timestamp cases.
20. V1d system-created approved row: retain claim with no invented user; historical adoption later requires the present authorized command and cap checks.

21. Delete a completed request’s card, clear its FK and recreate the deterministic ID: admit the column pair, qualify replacement, retain the new card without claiming it is the old output. Same-clock createdAt strictly after the owning completion proves recreation for V1 event references; equality/missing time does not prove original-row identity.
22. FLO-822 normalized outcome missing duplicated planId can establish scope from explicit evidence but remains blocked unmapped_content when unequal to the retirement projection until the separate closed conservation codec lands; then prove both source shapes round-trip. Missing evidence.store plus defaulted outcome ios never becomes proved iOS; conflicting explicit scope still refuses with repair facts retained.
23. Auto policy plus actual system approve event preserves both bases. Created-approved V1d, no recorded approval, and old approval followed by open→failed each preserve their distinct facts without invented human approval or approval-time manifest.
24. V3 completed (including pending finalization), collapse-superseded, repair-superseded and rejected each remain a singleton with zero children. Source unknown combinations refuse explicitly; no hypothesis collection fallback.
25. Approved status with valid evidence and approvedAt: latest-approval manifest proof survives equal or absent event times. Re-upsert returning open, open→failed, blocked→completed and created-approved V1d with NULL approvedAt must not acquire this specific approvedAt proof.
26. Exercise stored-row CHECKs for mixed-NULL targets and nonzero column ordinal; exercise recreation flags and witnesses as derived projection properties, including parentage and strict event-time inequality. DB checks, composite FKs and relation/seal validators have separately stated responsibilities. No duplicate diagnostic writes.
27. Collection notes fail sealing until G1's explicit owner/shape is integrated; unequal repaired outcomes cannot gain a success marker before G2. Fencing an approved unfinished run alone cannot pass G3; an explicit reviewed disposition or durable successor is required. Test the real adapters, not just a model.

---

## 9. Implementation boundary and remaining external work

The E4 source/reference direction is selected; blanket mapping readiness is withdrawn. Plan-ID/apply-field inventory and conservative handling of unavailable generation evidence are useful completed design work. G1 collection-parent prose and G2 unequal repaired-outcome conservation still need exact integrated schema contracts. G3 is the already-governing positive obligation-disposition condition, now explicit here. These are not permission to guess historical facts or discard accepted work. Derived projection clarification G4 removes duplicate authorities without reducing retained evidence.

Still required for **runtime implementation/cutover**, not claimed complete by this document: integrate the typed relations and historical-purpose leaves with the consolidated DDL; implement seal/tenant/owner checks and immutable snapshot expansion; run the fixture suite against real database roles, E1 adapters and canonical commands; refresh the source/data census under the cutover fence and report counts for missing references/dependencies, repeated/reset/repair-normalized requests, column-cleared/recreated targets, approval bases, terminal V3 statuses, store conflicts and repaired requests missing evidence.store (including their connected card/request counts). Actor attribution without retained evidence stays unavailable. Source changes after the pin require a decoder review.

Provider-native identity/ASC association/Play bridge, global collection adoption, R2 codecs and unrelated domain matrices remain governed by their own deliverables. This revision neither enables provider calls nor changes production ASO behavior.

**Revision 4.1 response:** the archived local review record.

**Revision 4 review response:** the archived local review record. The revision-3 self-review is historical and does not supersede the independent findings. Executable design vectors validate the pure rules and counterexamples; they are not a claim that the migration or its database constraints have shipped.


## 10. Reconciliation authority and test scope

Revision 4.2 supersedes revision 4.1 only on G1–G4 and readiness/coordination wording. It preserves the source inventory, reference-only migration, identity codec, exact target snapshots and R1/R2 evidence standards. It does not weaken future runtime lineage, exact approvals or durable obligations. For V1d the inventoried constructor creates a fresh internal attempt ID on every call; historical rows still require proof that this constructor applies. The 4,096-sequence model covers ordinary open-status upserts and is not proof of every historical directed writer.

The 43 supplied revision-4.1 Python design tests were independently re-run and passed. They are archived baseline model checks, not coverage of these newly identified sealing/conservation integration gaps, SQL constraints, concurrency, crashes, roles, migrations or production data. Real implementation fixtures now total 27 groups and remain requirements.
