-- FLO-1355 DESIGN CONTRACT ONLY. Not a deployable migration.
-- Requires actions_design.action_revision UNIQUE (organization_id,id).
-- All content is immutable once its owning revision is sealed.
-- Cross-table validation requirements are listed at the end.

CREATE TYPE actions_design.store_kind AS ENUM ('ios','android');
CREATE TYPE actions_design.content_value_state AS ENUM ('unspecified','present','empty','dismissed','unreadable');
CREATE TYPE actions_design.reply_intent AS ENUM ('send','update','observed');
CREATE TYPE actions_design.listing_intent AS ENUM ('create','update','repair','restore','observed');
CREATE TYPE actions_design.term_role AS ENUM ('added','removed','gloss','trending');
CREATE TYPE actions_design.media_kind AS ENUM ('screenshot','icon','app_preview');
CREATE TYPE actions_design.media_availability AS ENUM ('stored','missing','unreadable');
CREATE TYPE actions_design.request_intent AS ENUM ('locale_expansion','listing_change','review_catch_up','review_analysis','wake_agent','propose_experiment','revert_experiment','restore_listing');
CREATE TYPE actions_design.approval_setting AS ENUM ('auto','await');
CREATE TYPE actions_design.request_origin AS ENUM ('scheduled_agent','user_directed_chat_or_mcp','human','system');
CREATE TYPE actions_design.recommendation_kind AS ENUM ('keywords','promotional_text','description','screenshots','icon','app_previews','title_subtitle','cpp','short_description','title','subtitle','locale_expansion');
CREATE TYPE actions_design.advisory_connector_kind AS ENUM ('app_store_connect','apple_search_ads');
CREATE TYPE actions_design.closed_severity AS ENUM ('low','medium','high');
CREATE TYPE actions_design.research_coverage AS ENUM ('ready','cold');
CREATE TYPE actions_design.gloss_status AS ENUM ('updating','ready','unavailable');
CREATE TYPE actions_design.country_role AS ENUM ('demand','competitor');
CREATE TYPE actions_design.prose_section AS ENUM ('what_will_happen','supporting_evidence','description_outline','prioritization','notes','unblock_steps');
CREATE TYPE actions_design.ad_match_type AS ENUM ('EXACT','BROAD');
CREATE TYPE actions_design.advisory_kind AS ENUM ('optimize_keywords','improve_retention','adjust_monetization','update_store_listing','review_finding','aso_review_needed','agent_attention_needed','onboarding_audit_recommendation','connect_source','store_app_access_lost','flag_issue','escalate','stage_blocker');
CREATE TYPE actions_design.observation_availability AS ENUM ('present','absent','unreadable','pending','unknown');

CREATE TABLE actions_design.action_review_content (
  organization_id text NOT NULL,
  revision_id text NOT NULL,
  provider_account_id text NOT NULL,
  store actions_design.store_kind NOT NULL,
  provider_app_id text NOT NULL,
  provider_review_id text NOT NULL,
  apple_review_resource_id text,
  intent actions_design.reply_intent NOT NULL,
  reply_text text,
  original_ai_revision_id text,
  baseline_revision_id text,
  detected_language_name text,
  review_rating integer CHECK (review_rating BETWEEN 1 AND 5),
  review_title text,
  review_body text,
  review_nickname text,
  review_storefront text,
  review_app_version text,
  review_modified_at timestamptz,
  review_edited boolean,
  response_availability actions_design.observation_availability NOT NULL,
  provider_response_id text,
  provider_response_text text,
  provider_response_modified_at timestamptz,
  provider_response_hidden boolean,
  provider_response_state_text text,
  observation_captured_at timestamptz,
  PRIMARY KEY (organization_id,revision_id),
  FOREIGN KEY (organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  FOREIGN KEY (organization_id,original_ai_revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  FOREIGN KEY (organization_id,baseline_revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK (intent NOT IN ('send','update') OR (reply_text IS NOT NULL AND length(reply_text) > 0)),
  CHECK (intent <> 'update' OR baseline_revision_id IS NOT NULL),
  CHECK (response_availability <> 'present' OR provider_response_text IS NOT NULL),
  CHECK (response_availability <> 'absent' OR (provider_response_id IS NULL AND provider_response_text IS NULL))
);

CREATE TABLE actions_design.action_listing_content (
  organization_id text NOT NULL,
  revision_id text NOT NULL,
  provider_account_id text NOT NULL,
  store actions_design.store_kind NOT NULL,
  locale text NOT NULL CHECK (length(locale)>0),
  intent actions_design.listing_intent NOT NULL,
  provider_app_id text,
  package_name text,
  app_info_id text,
  app_info_localization_id text,
  app_version_id text,
  app_version_localization_id text,
  google_edit_id text,
  baseline_revision_id text,
  title_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', title text,
  subtitle_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', subtitle text,
  description_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', description text,
  keywords_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', keywords text,
  promotional_text_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', promotional_text text,
  short_description_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', short_description text,
  whats_new_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', whats_new text,
  support_url_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified', support_url text,
  keyword_analysis text,
  operator_instructions text,
  source_fingerprint text,
  naturalness_check_skipped boolean,
  fidelity_check_skipped boolean,
  english_title text,
  english_subtitle text,
  english_promotional_text text,
  gloss_status actions_design.gloss_status,
  research_country text,
  research_coverage actions_design.research_coverage,
  research_model_source text,
  research_model_version text,
  research_model_formula text,
  app_tier integer CHECK (app_tier BETWEEN 1 AND 3),
  app_tier_resolved boolean,
  candidate_count bigint CHECK (candidate_count>=0),
  judged_count bigint CHECK (judged_count>=0),
  scored_count bigint CHECK (scored_count>=0),
  p0_count bigint CHECK (p0_count>=0),
  p1_count bigint CHECK (p1_count>=0),
  p2_count bigint CHECK (p2_count>=0),
  with_volume_count bigint CHECK (with_volume_count>=0),
  conformance_term_count bigint CHECK (conformance_term_count>=0),
  conformance_from_table_count bigint CHECK (conformance_from_table_count>=0),
  observation_availability actions_design.observation_availability,
  provider_state_text text,
  observation_captured_at timestamptz,
  source_capture_at timestamptz,
  PRIMARY KEY (organization_id,revision_id),
  FOREIGN KEY (organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  FOREIGN KEY (organization_id,baseline_revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK ((title_state='present' AND title IS NOT NULL AND length(title)>0) OR (title_state='dismissed' AND title IS NOT NULL) OR (title_state='empty' AND title IS NOT NULL AND title='') OR (title_state IN ('unspecified','unreadable') AND title IS NULL)),
  CHECK ((subtitle_state='present' AND subtitle IS NOT NULL AND length(subtitle)>0) OR (subtitle_state='dismissed' AND subtitle IS NOT NULL) OR (subtitle_state='empty' AND subtitle IS NOT NULL AND subtitle='') OR (subtitle_state IN ('unspecified','unreadable') AND subtitle IS NULL)),
  CHECK ((description_state='present' AND description IS NOT NULL AND length(description)>0) OR (description_state='dismissed' AND description IS NOT NULL) OR (description_state='empty' AND description IS NOT NULL AND description='') OR (description_state IN ('unspecified','unreadable') AND description IS NULL)),
  CHECK ((keywords_state='present' AND keywords IS NOT NULL AND length(keywords)>0) OR (keywords_state='dismissed' AND keywords IS NOT NULL) OR (keywords_state='empty' AND keywords IS NOT NULL AND keywords='') OR (keywords_state IN ('unspecified','unreadable') AND keywords IS NULL)),
  CHECK ((promotional_text_state='present' AND promotional_text IS NOT NULL AND length(promotional_text)>0) OR (promotional_text_state='dismissed' AND promotional_text IS NOT NULL) OR (promotional_text_state='empty' AND promotional_text IS NOT NULL AND promotional_text='') OR (promotional_text_state IN ('unspecified','unreadable') AND promotional_text IS NULL)),
  CHECK ((short_description_state='present' AND short_description IS NOT NULL AND length(short_description)>0) OR (short_description_state='dismissed' AND short_description IS NOT NULL) OR (short_description_state='empty' AND short_description IS NOT NULL AND short_description='') OR (short_description_state IN ('unspecified','unreadable') AND short_description IS NULL)),
  CHECK ((whats_new_state='present' AND whats_new IS NOT NULL AND length(whats_new)>0) OR (whats_new_state='dismissed' AND whats_new IS NOT NULL) OR (whats_new_state='empty' AND whats_new IS NOT NULL AND whats_new='') OR (whats_new_state IN ('unspecified','unreadable') AND whats_new IS NULL)),
  CHECK ((support_url_state='present' AND support_url IS NOT NULL AND length(support_url)>0) OR (support_url_state='dismissed' AND support_url IS NOT NULL) OR (support_url_state='empty' AND support_url IS NOT NULL AND support_url='') OR (support_url_state IN ('unspecified','unreadable') AND support_url IS NULL)),
  CHECK (conformance_from_table_count IS NULL OR conformance_term_count IS NULL OR conformance_from_table_count<=conformance_term_count)
);

CREATE TABLE actions_design.action_content_term (
  organization_id text NOT NULL, revision_id text NOT NULL,
  role actions_design.term_role NOT NULL, ordinal integer NOT NULL CHECK(ordinal>=0),
  term text NOT NULL, meaning text,
  PRIMARY KEY(organization_id,revision_id,role,ordinal),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK ((role='gloss' AND meaning IS NOT NULL) OR (role<>'gloss' AND meaning IS NULL))
);

CREATE TABLE actions_design.action_media_content (
  organization_id text NOT NULL, revision_id text NOT NULL,
  slot integer NOT NULL CHECK(slot>=0), kind actions_design.media_kind NOT NULL,
  store actions_design.store_kind NOT NULL, locale text NOT NULL, source_locale text,
  display_type text, source_provider_resource_id text,
  source_object_key text, source_object_version text, source_digest text,
  output_object_key text, output_object_version text, output_digest text,
  availability actions_design.media_availability NOT NULL,
  mime_type text CHECK(mime_type IN ('image/png','image/jpeg','image/webp','video/mp4','video/quicktime')),
  width integer CHECK(width>0), height integer CHECK(height>0), byte_length bigint CHECK(byte_length>=0),
  generation_prompt text, generated_at timestamptz,
  storyboard_intent text, caption text, first_slot_hook_guidance text,
  PRIMARY KEY(organization_id,revision_id,slot),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK(availability<>'stored' OR (output_object_key IS NOT NULL AND output_object_version IS NOT NULL AND output_digest IS NOT NULL AND byte_length IS NOT NULL))
);

CREATE TABLE actions_design.action_request_content (
  organization_id text NOT NULL, revision_id text NOT NULL,
  intent actions_design.request_intent NOT NULL,
  store actions_design.store_kind, locale text,
  wave_index integer CHECK(wave_index>=0),
  recommendation_type actions_design.recommendation_kind,
  plan_source_id text, experiment_source_id text, source_capture_at timestamptz,
  window_days integer CHECK(window_days BETWEEN 7 AND 180),
  review_mode text CHECK(review_mode IN ('manual','full_agentic')),
  operator_instructions text, focus text, context_text text, hypothesis text,
  hypothesize_policy actions_design.approval_setting,
  draft_policy actions_design.approval_setting,
  execute_policy actions_design.approval_setting,
  origin actions_design.request_origin NOT NULL,
  language text, reasoning text, score numeric,
  demand_lookback_days integer CHECK(demand_lookback_days>0),
  downloads numeric, revenue_usd numeric, impressions numeric, review_count bigint,
  competitor_strength numeric, localized_competitor_count bigint,
  top_chart_count bigint, estimated_market_downloads numeric,
  market_research_note text, finding_title text, finding_rationale text,
  finding_severity actions_design.closed_severity,
  PRIMARY KEY(organization_id,revision_id),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK(intent NOT IN ('review_catch_up','review_analysis') OR window_days IS NOT NULL),
  CHECK(intent<>'review_catch_up' OR review_mode IS NOT NULL),
  CHECK(intent<>'locale_expansion' OR (store IS NOT NULL AND locale IS NOT NULL))
);

CREATE TABLE actions_design.action_market_country (
  organization_id text NOT NULL, revision_id text NOT NULL,
  role actions_design.country_role NOT NULL, ordinal integer NOT NULL CHECK(ordinal>=0),
  country text NOT NULL,
  PRIMARY KEY(organization_id,revision_id,role,ordinal),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_request_content(organization_id,revision_id)
);
CREATE TABLE actions_design.action_market_competitor (
  organization_id text NOT NULL, revision_id text NOT NULL,
  ordinal integer NOT NULL CHECK(ordinal>=0), competitor_name text NOT NULL,
  PRIMARY KEY(organization_id,revision_id,ordinal),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_request_content(organization_id,revision_id)
);
CREATE TABLE actions_design.action_content_note (
  organization_id text NOT NULL, revision_id text NOT NULL,
  section actions_design.prose_section NOT NULL, ordinal integer NOT NULL CHECK(ordinal>=0), text_content text NOT NULL,
  PRIMARY KEY(organization_id,revision_id,section,ordinal),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id)
);




CREATE TABLE actions_design.action_advisory_content (
  organization_id text NOT NULL, revision_id text NOT NULL,
  kind actions_design.advisory_kind NOT NULL,
  detail text, suggestion text,
  primary_link_label text, primary_link_path text,
  connector_source_id text, connector_type actions_design.advisory_connector_kind, connector_name_snapshot text,
  source_label text, benefit text, app_name_snapshot text, bundle_id_snapshot text,
  scraping_account_email_snapshot text,
  agent_source_id text,
  consecutive_failures bigint CHECK(consecutive_failures>=0), last_success_at timestamptz, last_error text,
  impact actions_design.closed_severity, effort actions_design.closed_severity,
  confidence_label actions_design.closed_severity, confidence_score numeric,
  quick_win_source_id text, recommendation_type actions_design.recommendation_kind,
  market_label text, gate_text text, capability_tier integer CHECK(capability_tier BETWEEN 1 AND 3),
  proposed_next_step text,
  audit_store actions_design.store_kind, audit_store_app_id text, audit_country text, audit_locale text, audit_generated_at timestamptz,
  blocker_reason_text text, blocker_reasoning text,
  unblock_title text, unblock_what_happened text, unblock_why_it_matters text,
  unblock_next text, unblock_cta_label text, unblock_cta_path text,
  PRIMARY KEY(organization_id,revision_id),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK(primary_link_path IS NULL OR primary_link_path ~ '^/[^/]'),
  CHECK(unblock_cta_path IS NULL OR unblock_cta_path ~ '^/[^/]')
);

CREATE TYPE actions_design.ad_intent AS ENUM ('pause_campaign','enable_campaign','set_campaign_budget','set_keyword_bid','create_keyword','add_negative_keyword','delete_negative_keyword','observed');
CREATE TYPE actions_design.ad_observed_status AS ENUM ('ENABLED','ACTIVE','PAUSED','DELETED');
CREATE TABLE actions_design.action_ad_content (
  organization_id text NOT NULL, revision_id text NOT NULL,
  intent actions_design.ad_intent NOT NULL,
  provider_account_id text NOT NULL,
  provider_campaign_id text NOT NULL CHECK(provider_campaign_id ~ '^[1-9][0-9]*$'),
  provider_ad_group_id text CHECK(provider_ad_group_id ~ '^[1-9][0-9]*$'),
  provider_keyword_id text CHECK(provider_keyword_id ~ '^[1-9][0-9]*$'),
  provider_negative_keyword_id text CHECK(provider_negative_keyword_id ~ '^[1-9][0-9]*$'),
  keyword_text text, match_type actions_design.ad_match_type,
  daily_budget_amount numeric CHECK(daily_budget_amount>0),
  bid_amount numeric CHECK(bid_amount>0),
  currency_code text CHECK(currency_code ~ '^[A-Z]{3}$'),
  observed_status actions_design.ad_observed_status,
  observation_availability actions_design.observation_availability,
  observation_captured_at timestamptz,
  baseline_revision_id text,
  PRIMARY KEY(organization_id,revision_id),
  FOREIGN KEY(organization_id,revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  FOREIGN KEY(organization_id,baseline_revision_id) REFERENCES actions_design.action_revision(organization_id,id),
  CHECK(intent<>'set_campaign_budget' OR (daily_budget_amount IS NOT NULL AND currency_code IS NOT NULL)),
  CHECK(intent<>'set_keyword_bid' OR (provider_ad_group_id IS NOT NULL AND provider_keyword_id IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL)),
  CHECK(intent<>'create_keyword' OR (provider_ad_group_id IS NOT NULL AND keyword_text IS NOT NULL AND match_type IS NOT NULL AND bid_amount IS NOT NULL AND currency_code IS NOT NULL)),
  CHECK(intent<>'add_negative_keyword' OR (keyword_text IS NOT NULL AND match_type IS NOT NULL)),
  CHECK(intent<>'delete_negative_keyword' OR provider_negative_keyword_id IS NOT NULL),
  CHECK(intent<>'observed' OR (observation_availability IS NOT NULL AND observation_captured_at IS NOT NULL)),
  CHECK(intent='observed' OR observed_status IS NULL),
  CHECK(intent IN ('set_campaign_budget','observed') OR daily_budget_amount IS NULL),
  CHECK(intent IN ('set_keyword_bid','create_keyword','observed') OR bid_amount IS NULL),
  CHECK(intent IN ('set_keyword_bid','set_campaign_budget','create_keyword','observed') OR currency_code IS NULL),
  CHECK(intent IN ('create_keyword','add_negative_keyword','observed') OR (keyword_text IS NULL AND match_type IS NULL)),
  CHECK(intent IN ('set_keyword_bid','observed') OR provider_keyword_id IS NULL),
  CHECK(intent IN ('delete_negative_keyword','observed') OR provider_negative_keyword_id IS NULL),
  CHECK(intent IN ('set_keyword_bid','create_keyword','add_negative_keyword','observed') OR provider_ad_group_id IS NULL)
);

-- REQUIRED CENTRAL GUARDS (root schema seals transactions):
-- 1. Every proposal/baseline/observation revision has exactly the permitted
--    primary subtype for action_revision.kind. Kind interface: review_reply, listing,
--    media, request, ads, advisory, collection. Auxiliary relations cannot
--    float on incompatible revisions. Collection carries immutable membership.
-- 2. Any insert/update/delete here locks the parent revision, rejects sealed,
--    and sealing validates the whole content graph atomically.
-- 3. Baseline and original-AI references must be same organization, correct
--    purpose, sealed and same concrete target. Reject self/cyclic references.
-- 4. Listing locale uses the closed supported-store catalog. Android supports
--    title/description/shortDescription; iOS excludes shortDescription. New
--    unsupported fields reject at command validation before persistence.
-- 5. Proposal present/empty means intended set/clear; unspecified means keep;
--    dismissed preserves reviewed copy but omits that field from execution.
--    Only observations permit unreadable. Clear supported only where adapter
--    explicitly implements it. Approval preview and compiler use same schema.
-- 6. Generation provenance refers to immutable run/attempts in core; do not
--    duplicate billing usage totals in content rows. Generation output from
--    stale base revision may be retained but never becomes current silently.
-- 7. Media approved for publication requires stored immutable version/digest;
--    provider display_type parsed through the supported typed device catalog.
--    Unknown provider display types fail typed parsing and cannot enter the closed catalog. Media source/output rows
--    reference actual storage inventory by FK where canonical assets exist.
-- 8. Request child has exactly one locale; parent membership freezes its set.
--    Generation approval and publication approval are distinct scopes.
-- 9. Root concrete provenance relations carry source run, recommendation,
--    variant, report, backlog, experiment, source snapshot, receipt identity;
--    connect source placeholders here to those checked FK relations.
-- 10. Revert rationale references the existing experiment-owned outcome;
--     executable restore bytes are frozen concrete listing child revisions.
-- 11. RLS/indexes/grants/sealed-content triggers apply to every relation here.
-- 12. Old retired capability data is outside live schema. Preserve existing
--     links/receipts through bounded migration handling; no retired executor,
--     historical param bag or archive-specific variant in this runtime.
-- 13. Current ad content uses one relation because all seven shapes have the
--     same revision key/lifetime; operation CHECKs enforce exact variants.
--     No ad-group mutation/campaign-create handler is implied.
-- 14. Active ASA negative-keyword create rejects ad-group scope until adapter
--     supports it. Provider account+campaign target must be bound at staging.
