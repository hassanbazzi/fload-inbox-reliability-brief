-- FLO-1355 current provider content contract additions, not a migration.
-- Apply after schema-content.sql; all references target actions_design.
-- No new relations: App Clip fields share the locale revision and pin a media
-- member of that same revision. Independent locale operations remain children.

-- One baseline authority, already owned by root action_revision.
ALTER TABLE actions_design.action_review_content DROP COLUMN baseline_revision_id;
ALTER TABLE actions_design.action_listing_content DROP COLUMN baseline_revision_id;
ALTER TABLE actions_design.action_ad_content DROP COLUMN baseline_revision_id;
-- Dropping the review column also drops its dependent local CHECK; the central
-- revision validator must require a sealed baseline for reply intent=update.

-- Current source commits omit this query policy. This is a deliberate fix:
-- https://developers.google.com/android-publisher/api-ref/rest/v3/edits/commit
-- Omission defaults to CANCEL_IN_REVIEW_AND_SUBMIT. Broader cancellation is
-- outside current scope; the closed policy has exactly one permitted value.
CREATE TYPE actions_design.play_commit_policy AS ENUM ('ERROR_IF_IN_REVIEW');
CREATE TYPE actions_design.app_clip_operation AS ENUM ('none','create_localization','repair_header','observed');
ALTER TABLE actions_design.action_listing_content
 ADD COLUMN play_commit_policy actions_design.play_commit_policy,
 ADD COLUMN app_clip_operation actions_design.app_clip_operation NOT NULL DEFAULT 'none',
 ADD COLUMN app_clip_id text,
 ADD COLUMN app_clip_experience_id text,
 ADD COLUMN app_clip_release_version_id text,
 ADD COLUMN app_clip_localization_id text,
 ADD COLUMN app_clip_source_localization_id text,
 ADD COLUMN app_clip_subtitle text,
 ADD COLUMN app_clip_header_media_slot integer,
 ADD CONSTRAINT listing_play_policy_store CHECK(store='android' OR play_commit_policy IS NULL),
 ADD CONSTRAINT listing_clip_target CHECK(
  (app_clip_operation='none' AND app_clip_id IS NULL AND app_clip_experience_id IS NULL
   AND app_clip_release_version_id IS NULL AND app_clip_localization_id IS NULL
   AND app_clip_source_localization_id IS NULL AND app_clip_subtitle IS NULL
   AND app_clip_header_media_slot IS NULL)
  OR
  (app_clip_operation<>'none' AND store='ios' AND app_clip_id IS NOT NULL
   AND app_clip_experience_id IS NOT NULL AND app_clip_release_version_id IS NOT NULL
   AND (app_clip_operation='observed' OR app_clip_header_media_slot IS NOT NULL))
 ),
 ADD CONSTRAINT listing_clip_subtitle CHECK(app_clip_operation<>'create_localization'
  OR (app_clip_subtitle IS NOT NULL AND length(app_clip_subtitle)>0)),
 ADD CONSTRAINT listing_clip_repair_target CHECK(app_clip_operation<>'repair_header'
  OR app_clip_localization_id IS NOT NULL),
 ADD CONSTRAINT listing_clip_media_fk FOREIGN KEY(organization_id,revision_id,app_clip_header_media_slot)
  REFERENCES actions_design.action_media_content(organization_id,revision_id,slot)
  DEFERRABLE INITIALLY DEFERRED;

-- Current promo code writes the same proposed copy to independently pinned
-- live and editable destinations. Snapshot values can differ, so retain a
-- separate live value only as observation evidence; desired copy stays singular.
CREATE TYPE actions_design.app_clip_header_state AS ENUM ('absent','incomplete','complete','unreadable');
CREATE TYPE actions_design.review_publication_state AS ENUM ('published','pending_publication','hidden','deleted','unreadable');
CREATE TYPE actions_design.listing_version_state AS ENUM ('editable','in_review','processing','live','rejected','removed','unreadable');
ALTER TABLE actions_design.action_review_content DROP COLUMN provider_response_state_text;
ALTER TABLE actions_design.action_review_content ADD COLUMN provider_response_state actions_design.review_publication_state;
ALTER TABLE actions_design.action_listing_content DROP COLUMN provider_state_text;
ALTER TABLE actions_design.action_listing_content
 ADD COLUMN provider_version_state actions_design.listing_version_state,
 ADD COLUMN live_promotional_version_id text,
 ADD COLUMN live_promotional_localization_id text,
 ADD COLUMN live_promotional_text_state actions_design.content_value_state NOT NULL DEFAULT 'unspecified',
 ADD COLUMN live_promotional_text text,
 ADD COLUMN app_clip_incomplete_header_id text,
 ADD COLUMN app_clip_header_state actions_design.app_clip_header_state,
 ADD CONSTRAINT listing_live_promo_target CHECK(
  (live_promotional_version_id IS NULL AND live_promotional_localization_id IS NULL)
  OR (store='ios' AND live_promotional_version_id IS NOT NULL AND length(live_promotional_version_id)>0
   AND live_promotional_localization_id IS NOT NULL AND length(live_promotional_localization_id)>0)),
 ADD CONSTRAINT listing_live_promo_observed_value CHECK(
  (live_promotional_text_state='present' AND live_promotional_text IS NOT NULL AND length(live_promotional_text)>0)
  OR (live_promotional_text_state='empty' AND live_promotional_text IS NOT NULL AND live_promotional_text='')
  OR (live_promotional_text_state IN ('unspecified','unreadable') AND live_promotional_text IS NULL)),
 ADD CONSTRAINT listing_live_promo_value_target CHECK(live_promotional_text_state='unspecified' OR live_promotional_version_id IS NOT NULL),
 ADD CONSTRAINT listing_clip_observed_header CHECK(
  (app_clip_operation='none' AND app_clip_incomplete_header_id IS NULL AND app_clip_header_state IS NULL)
  OR (app_clip_operation IN ('create_localization','repair_header','observed')
   AND (app_clip_incomplete_header_id IS NULL OR length(app_clip_incomplete_header_id)>0)
   AND (app_clip_header_state IS NULL OR app_clip_operation='observed')
   AND (app_clip_header_state IS DISTINCT FROM 'incomplete'::actions_design.app_clip_header_state
    OR app_clip_incomplete_header_id IS NOT NULL)));

-- Apple's current official ScreenshotDisplayType enum, verified 2026-09-15:
-- https://developer.apple.com/documentation/appstoreconnectapi/screenshotdisplaytype
-- These are accepted observation/display identities, not a claim that Fload
-- has an upload executor for every device. Publication remains capability-gated.
CREATE TYPE actions_design.media_display_type AS ENUM (
 'APP_APPLE_TV','APP_APPLE_VISION_PRO','APP_DESKTOP','APP_IPAD_105','APP_IPAD_97',
 'APP_IPAD_PRO_129','APP_IPAD_PRO_3GEN_11','APP_IPAD_PRO_3GEN_129',
 'APP_IPHONE_35','APP_IPHONE_40','APP_IPHONE_47','APP_IPHONE_55','APP_IPHONE_58',
 'APP_IPHONE_61','APP_IPHONE_65','APP_IPHONE_67','APP_WATCH_SERIES_10',
 'APP_WATCH_SERIES_3','APP_WATCH_SERIES_4','APP_WATCH_SERIES_7','APP_WATCH_ULTRA',
 -- Current Play read source supports precisely these screenshot sets.
 'phoneScreenshots','sevenInchScreenshots'
);
ALTER TYPE actions_design.media_kind ADD VALUE 'app_clip_header';
-- Avoid using the new enum literal until the DDL transaction commits. Guards
-- below compare kind::text. The completed contract is tested after commit.
CREATE TYPE actions_design.media_storage_immutability AS ENUM ('versioned_object','content_addressed_immutable');
ALTER TABLE actions_design.action_media_content
 ALTER COLUMN display_type TYPE actions_design.media_display_type USING display_type::actions_design.media_display_type,
 ADD COLUMN source_storage_immutability actions_design.media_storage_immutability,
 ADD COLUMN output_storage_immutability actions_design.media_storage_immutability,
 ADD COLUMN provider_md5 text,
 ADD CONSTRAINT media_source_digest_format CHECK(source_digest IS NULL OR source_digest ~ '^sha256:[0-9a-f]{64}$'),
 ADD CONSTRAINT media_output_digest_format CHECK(output_digest IS NULL OR output_digest ~ '^sha256:[0-9a-f]{64}$'),
 ADD CONSTRAINT media_md5_format CHECK(provider_md5 IS NULL OR provider_md5 ~ '^[0-9a-f]{32}$'),
 ADD CONSTRAINT media_display_store CHECK(display_type IS NULL
   OR (store='android' AND display_type IN ('phoneScreenshots','sevenInchScreenshots'))
   OR (store='ios' AND display_type NOT IN ('phoneScreenshots','sevenInchScreenshots'))),
 ADD CONSTRAINT media_screenshot_display CHECK(kind::text<>'screenshot' OR display_type IS NOT NULL),
 ADD CONSTRAINT media_clip_shape CHECK(kind::text<>'app_clip_header'
   OR (store='ios' AND display_type IS NULL AND mime_type IS NOT NULL AND mime_type IN ('image/png','image/jpeg')));

-- The old design CHECK forced a provider object-version on every stored file.
-- R2 can instead use a content-addressed key, conditional creation, and a
-- storage service that rejects replacement/deletion while any revision pins it.
-- This is the known auto-generated name from the supplied contract, not an
-- application migration that guesses an arbitrary deployed constraint name.
ALTER TABLE actions_design.action_media_content DROP CONSTRAINT action_media_content_check;
ALTER TABLE actions_design.action_media_content ADD CONSTRAINT media_stored_bytes_immutable CHECK(
 availability<>'stored' OR
 (output_object_key IS NOT NULL AND length(output_object_key)>0
  AND output_digest IS NOT NULL AND byte_length IS NOT NULL
  AND output_storage_immutability IS NOT NULL
  AND (
   (output_storage_immutability='versioned_object' AND output_object_version IS NOT NULL AND length(output_object_version)>0)
   OR
   (output_storage_immutability='content_addressed_immutable'
    AND output_object_version IS NULL
    AND position(substring(output_digest FROM 8) IN output_object_key)>0)
  ))
);

-- Call this validator when linking a baseline or attaching a provider readback
-- to a subject revision. Organization and action equality also required by
-- root FKs; new server-assigned IDs may fill a subject's previously null slot.
-- The root invokes this before accepting an observation or sealing a proposal.
CREATE FUNCTION actions_design.assert_same_provider_content_target(
 p_org text, p_subject text, p_observation text
) RETURNS void LANGUAGE plpgsql AS $$
DECLARE sr actions_design.action_revision%ROWTYPE;
 orr actions_design.action_revision%ROWTYPE;
 sreview actions_design.action_review_content%ROWTYPE;
 oreview actions_design.action_review_content%ROWTYPE;
 slisting actions_design.action_listing_content%ROWTYPE;
 olisting actions_design.action_listing_content%ROWTYPE;
 sad actions_design.action_ad_content%ROWTYPE;
 oad actions_design.action_ad_content%ROWTYPE;
BEGIN
 SELECT * INTO STRICT sr FROM actions_design.action_revision WHERE organization_id=p_org AND id=p_subject;
 SELECT * INTO STRICT orr FROM actions_design.action_revision WHERE organization_id=p_org AND id=p_observation;
 IF sr.action_id IS DISTINCT FROM orr.action_id OR sr.kind IS DISTINCT FROM orr.kind
   OR NOT orr.sealed OR orr.purpose NOT IN ('baseline','observation')
 THEN RAISE EXCEPTION 'Observation must belong to the same ticket and content family'; END IF;
 IF sr.kind='review_reply' THEN
  SELECT * INTO STRICT sreview FROM actions_design.action_review_content WHERE organization_id=p_org AND revision_id=p_subject;
  SELECT * INTO STRICT oreview FROM actions_design.action_review_content WHERE organization_id=p_org AND revision_id=p_observation;
  IF ROW(sreview.provider_account_id,sreview.store,sreview.provider_app_id,sreview.provider_review_id)
    IS DISTINCT FROM ROW(oreview.provider_account_id,oreview.store,oreview.provider_app_id,oreview.provider_review_id)
    OR (sreview.apple_review_resource_id IS NOT NULL AND sreview.apple_review_resource_id IS DISTINCT FROM oreview.apple_review_resource_id)
  THEN RAISE EXCEPTION 'Review observation changed the approved target'; END IF;
 ELSIF sr.kind='listing' THEN
  SELECT * INTO STRICT slisting FROM actions_design.action_listing_content WHERE organization_id=p_org AND revision_id=p_subject;
  SELECT * INTO STRICT olisting FROM actions_design.action_listing_content WHERE organization_id=p_org AND revision_id=p_observation;
  IF ROW(slisting.provider_account_id,slisting.store,slisting.locale,slisting.provider_app_id,slisting.package_name)
    IS DISTINCT FROM ROW(olisting.provider_account_id,olisting.store,olisting.locale,olisting.provider_app_id,olisting.package_name)
    OR (slisting.live_promotional_version_id IS NOT NULL AND slisting.live_promotional_version_id IS DISTINCT FROM olisting.live_promotional_version_id)
    OR (slisting.live_promotional_localization_id IS NOT NULL AND slisting.live_promotional_localization_id IS DISTINCT FROM olisting.live_promotional_localization_id)
    OR (slisting.app_clip_id IS NOT NULL AND slisting.app_clip_id IS DISTINCT FROM olisting.app_clip_id)
    OR (slisting.app_clip_localization_id IS NOT NULL AND slisting.app_clip_localization_id IS DISTINCT FROM olisting.app_clip_localization_id)
    OR (slisting.app_info_localization_id IS NOT NULL AND slisting.app_info_localization_id IS DISTINCT FROM olisting.app_info_localization_id)
    OR (slisting.app_version_localization_id IS NOT NULL AND slisting.app_version_localization_id IS DISTINCT FROM olisting.app_version_localization_id)
    OR (slisting.app_info_id IS NOT NULL AND slisting.app_info_id IS DISTINCT FROM olisting.app_info_id)
    OR (slisting.app_version_id IS NOT NULL AND slisting.app_version_id IS DISTINCT FROM olisting.app_version_id)
    OR (slisting.app_clip_experience_id IS NOT NULL AND slisting.app_clip_experience_id IS DISTINCT FROM olisting.app_clip_experience_id)
    OR (slisting.app_clip_release_version_id IS NOT NULL AND slisting.app_clip_release_version_id IS DISTINCT FROM olisting.app_clip_release_version_id)
  THEN RAISE EXCEPTION 'Listing observation changed the approved target'; END IF;
 ELSIF sr.kind='ads' THEN
  SELECT * INTO STRICT sad FROM actions_design.action_ad_content WHERE organization_id=p_org AND revision_id=p_subject;
  SELECT * INTO STRICT oad FROM actions_design.action_ad_content WHERE organization_id=p_org AND revision_id=p_observation;
  IF ROW(sad.provider_account_id,sad.provider_campaign_id,sad.provider_ad_group_id)
    IS DISTINCT FROM ROW(oad.provider_account_id,oad.provider_campaign_id,oad.provider_ad_group_id)
    OR (sad.provider_keyword_id IS NOT NULL AND sad.provider_keyword_id IS DISTINCT FROM oad.provider_keyword_id)
    OR (sad.provider_negative_keyword_id IS NOT NULL AND sad.provider_negative_keyword_id IS DISTINCT FROM oad.provider_negative_keyword_id)
  THEN RAISE EXCEPTION 'Ads observation changed the approved target'; END IF;
 ELSE RAISE EXCEPTION 'Provider observation unsupported for this content family';
 END IF;
END $$;

-- Finite canonical locale domain generated from packages/utils/src/storefront-data.ts
-- on main 63275b2f5. Input normalization resolves aliases before persistence;
-- ambiguity is an error. Adding a supported locale is a schema+contract change.
CREATE FUNCTION actions_design.is_supported_store_locale(p_store actions_design.store_kind,p_locale text)
RETURNS boolean LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$ SELECT CASE p_store
 WHEN 'ios' THEN p_locale IN ('ar-SA','bn-BD','ca','zh-Hans','zh-Hant','hr','cs','da','nl-NL','en-AU','en-CA','en-GB','en-US','fi','fr-FR','fr-CA','de-DE','el','gu-IN','he','hi','hu','id','it','ja','kn-IN','ko','ms','ml-IN','mr-IN','no','or-IN','pl','pt-BR','pt-PT','pa-IN','ro','ru','sk','sl-SI','es-MX','es-ES','sv','ta-IN','te-IN','th','tr','uk','ur-PK','vi')
 WHEN 'android' THEN p_locale IN ('af','am','ar','az-AZ','be','bg','bn-BD','ca','cs-CZ','da-DK','de-DE','el-GR','en-AU','en-CA','en-GB','en-IN','en-SG','en-US','en-ZA','es-419','es-ES','es-US','et','eu-ES','fa','fi-FI','fil','fr-CA','fr-FR','gl-ES','gu','hi-IN','hr','hu-HU','hy-AM','id','is-IS','it-IT','iw-IL','ja-JP','ka-GE','kk','km-KH','kn-IN','ko-KR','ky-KG','lo-LA','lt','lv','mk-MK','ml-IN','mn-MN','mr-IN','ms','ms-MY','my-MM','nb-NO','ne-NP','nl-NL','no-NO','pa','pl-PL','pt-BR','pt-PT','ro','ru-RU','si-LK','sk','sl','sq','sr','sv-SE','sw','ta-IN','te-IN','th','tr-TR','uk','ur','vi','zh-CN','zh-HK','zh-TW','zu')
 END $$;
ALTER TABLE actions_design.action_listing_content ADD CONSTRAINT listing_supported_locale
 CHECK(actions_design.is_supported_store_locale(store,locale));
ALTER TABLE actions_design.action_media_content ADD CONSTRAINT media_supported_locale
 CHECK(actions_design.is_supported_store_locale(store,locale));
ALTER TABLE actions_design.action_media_content ADD CONSTRAINT media_supported_source_locale
 CHECK(source_locale IS NULL OR actions_design.is_supported_store_locale(store,source_locale));
ALTER TABLE actions_design.action_request_content ADD CONSTRAINT request_supported_locale
 CHECK(locale IS NULL OR (store IS NOT NULL AND actions_design.is_supported_store_locale(store,locale)));

-- PostgreSQL length counts Unicode code points; Apple and JS use UTF-16 units.
CREATE FUNCTION actions_design.utf16_length(p_value text)
RETURNS bigint LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
 SELECT coalesce(sum(CASE WHEN ascii(substring(p_value FROM i FOR 1))>65535 THEN 2 ELSE 1 END),0)::bigint
 FROM generate_series(1,length(p_value)) AS n(i)
$$;
CREATE FUNCTION actions_design.is_content_write(p_state actions_design.content_value_state)
RETURNS boolean LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
 SELECT p_state IN ('present','empty')
$$;
ALTER TABLE actions_design.action_listing_content ADD CONSTRAINT listing_clip_utf16_limit
 CHECK(app_clip_subtitle IS NULL OR actions_design.utf16_length(app_clip_subtitle)<=56);
ALTER TABLE actions_design.action_media_content ADD CONSTRAINT media_source_bytes_immutable CHECK(
 (source_object_key IS NULL AND source_object_version IS NULL AND source_digest IS NULL AND source_storage_immutability IS NULL)
 OR (source_object_key IS NOT NULL AND length(source_object_key)>0 AND source_digest IS NOT NULL
  AND source_storage_immutability IS NOT NULL AND
  ((source_storage_immutability='versioned_object' AND source_object_version IS NOT NULL AND length(source_object_version)>0)
   OR (source_storage_immutability='content_addressed_immutable' AND source_object_version IS NULL
    AND position(substring(source_digest FROM 8) IN source_object_key)>0)))
);

-- Every seal is validated from committed content, including INSERT + later
-- content + seal in one transaction. Root owns subtype/membership/digest guards.
-- This trigger supplements those guards rather than replacing their function.
CREATE FUNCTION actions_design.assert_provider_content_complete(p_revision text)
RETURNS void LANGUAGE plpgsql SET search_path=actions_design,public AS $$
DECLARE r action_revision; review action_review_content; listing action_listing_content;
 ad action_ad_content; req action_request_content; media action_media_content;
 original action_revision; expected text; writable integer;
BEGIN
 SELECT * INTO r FROM action_revision WHERE id=p_revision;
 IF NOT FOUND THEN RETURN; END IF;
 IF NOT r.sealed THEN RAISE EXCEPTION 'provider content revision must be sealed' USING ERRCODE='23514'; END IF;
 IF r.kind='review_reply' THEN
  SELECT * INTO STRICT review FROM action_review_content WHERE organization_id=r.organization_id AND revision_id=r.id;
  IF length(review.provider_account_id)=0 OR length(review.provider_app_id)=0 OR length(review.provider_review_id)=0
   OR (review.store='android' AND review.apple_review_resource_id IS NOT NULL)
   OR ((r.purpose='proposal') IS DISTINCT FROM (review.intent IN ('send','update')))
  THEN RAISE EXCEPTION 'invalid review target or intent' USING ERRCODE='23514'; END IF;
  IF review.intent='update' AND r.baseline_revision_id IS NULL THEN RAISE EXCEPTION 'reply update requires exact prior response baseline' USING ERRCODE='23514'; END IF;
  IF r.purpose<>'proposal' AND (review.reply_text IS NOT NULL OR review.observation_captured_at IS NULL
    OR (review.response_availability='present' AND review.provider_response_state IS NULL))
  THEN RAISE EXCEPTION 'review observation requires captured response facts, not proposed copy' USING ERRCODE='23514'; END IF;
  IF review.original_ai_revision_id IS NOT NULL THEN
   SELECT * INTO original FROM action_revision WHERE id=review.original_ai_revision_id AND organization_id=r.organization_id;
   IF original.id IS NULL OR NOT original.sealed OR original.action_id<>r.action_id OR original.kind<>'review_reply'
    OR original.purpose<>'proposal' OR original.revision_number>=r.revision_number
   THEN RAISE EXCEPTION 'original AI reply must be an earlier sealed proposal on this ticket' USING ERRCODE='23514'; END IF;
   IF NOT EXISTS(SELECT 1 FROM action_review_content old WHERE old.revision_id=original.id
    AND (old.provider_account_id,old.store,old.provider_app_id,old.provider_review_id)=
     (review.provider_account_id,review.store,review.provider_app_id,review.provider_review_id))
   THEN RAISE EXCEPTION 'original AI reply target mismatch' USING ERRCODE='23514'; END IF;
  END IF;
 ELSIF r.kind='listing' THEN
  SELECT * INTO STRICT listing FROM action_listing_content WHERE organization_id=r.organization_id AND revision_id=r.id;
  IF length(listing.provider_account_id)=0
   OR (listing.store='ios' AND (listing.provider_app_id IS NULL OR length(listing.provider_app_id)=0 OR listing.package_name IS NOT NULL))
   OR (listing.store='android' AND (listing.package_name IS NULL OR length(listing.package_name)=0 OR listing.provider_app_id IS NOT NULL
    OR listing.app_info_id IS NOT NULL OR listing.app_info_localization_id IS NOT NULL
    OR listing.app_version_id IS NOT NULL OR listing.app_version_localization_id IS NOT NULL))
   OR (listing.store='ios' AND (listing.short_description_state<>'unspecified' OR listing.google_edit_id IS NOT NULL))
   OR (listing.store='android' AND (listing.subtitle_state<>'unspecified' OR listing.keywords_state<>'unspecified'
    OR listing.promotional_text_state<>'unspecified' OR listing.whats_new_state<>'unspecified' OR listing.support_url_state<>'unspecified'))
   OR ((r.purpose='proposal') IS DISTINCT FROM (listing.intent<>'observed'))
  THEN RAISE EXCEPTION 'invalid listing target, field/store pair, or intent' USING ERRCODE='23514'; END IF;
  IF r.purpose<>'proposal' THEN
   IF listing.observation_captured_at IS NULL OR listing.observation_availability IS NULL
    OR listing.play_commit_policy IS NOT NULL OR listing.app_clip_operation NOT IN ('none','observed')
    OR (listing.app_clip_operation='observed' AND listing.app_clip_header_state IS NULL)
   THEN RAISE EXCEPTION 'listing snapshot requires observation facts' USING ERRCODE='23514'; END IF;
  ELSE
   IF listing.title_state='unreadable' OR listing.subtitle_state='unreadable' OR listing.description_state='unreadable'
    OR listing.keywords_state='unreadable' OR listing.promotional_text_state='unreadable'
    OR listing.short_description_state='unreadable' OR listing.whats_new_state='unreadable' OR listing.support_url_state='unreadable'
    OR listing.app_clip_operation='observed' OR listing.google_edit_id IS NOT NULL
    OR listing.live_promotional_text_state<>'unspecified' OR listing.app_clip_header_state IS NOT NULL
    OR (listing.live_promotional_version_id IS NOT NULL AND NOT is_content_write(listing.promotional_text_state))
   THEN RAISE EXCEPTION 'unreadable fields cannot be proposed or approved' USING ERRCODE='23514'; END IF;
   IF listing.store='android' AND listing.play_commit_policy IS DISTINCT FROM 'ERROR_IF_IN_REVIEW'::play_commit_policy
   THEN RAISE EXCEPTION 'Play writes require explicit safe commit policy' USING ERRCODE='23514'; END IF;
   writable=is_content_write(listing.title_state)::int+is_content_write(listing.subtitle_state)::int+
    is_content_write(listing.description_state)::int+is_content_write(listing.keywords_state)::int+
    is_content_write(listing.promotional_text_state)::int+is_content_write(listing.short_description_state)::int+
    is_content_write(listing.whats_new_state)::int+is_content_write(listing.support_url_state)::int;
   IF writable=0 AND listing.app_clip_operation='none' THEN RAISE EXCEPTION 'listing proposal has no authorized effect' USING ERRCODE='23514'; END IF;
   IF (r.operation='create_locale' AND listing.intent NOT IN ('create','update','repair'))
    OR (r.operation IN ('apply_listing_changes','update_promo_text','update_description','update_short_description') AND listing.intent<>'update')
    OR (r.operation IN ('revert_experiment','aso_revert_listing') AND (listing.intent<>'restore' OR r.baseline_revision_id IS NULL))
    OR (r.operation='apply_listing_changes' AND listing.store<>'ios')
    OR (r.operation='update_promo_text' AND (listing.store<>'ios' OR writable<>1 OR NOT is_content_write(listing.promotional_text_state)))
    OR (r.operation='update_description' AND (listing.store<>'android' OR writable<>1 OR NOT is_content_write(listing.description_state)))
    OR (r.operation='update_short_description' AND (listing.store<>'android' OR writable<>1 OR NOT is_content_write(listing.short_description_state)))
    OR (listing.app_clip_operation<>'none' AND r.operation<>'create_locale')
   THEN RAISE EXCEPTION 'listing revision operation disagrees with exact content effect' USING ERRCODE='23514'; END IF;
   -- Never resolve editable app info/version IDs from current provider state
   -- after approval. New locale resource IDs may remain null until reserved.
   IF listing.store='ios' AND ((is_content_write(listing.title_state) OR is_content_write(listing.subtitle_state)) AND listing.app_info_id IS NULL
    OR (is_content_write(listing.description_state) OR is_content_write(listing.keywords_state)
     OR (is_content_write(listing.promotional_text_state) AND listing.live_promotional_version_id IS NULL) OR is_content_write(listing.whats_new_state)
     OR is_content_write(listing.support_url_state)) AND listing.app_version_id IS NULL)
   THEN RAISE EXCEPTION 'Apple write target app info/version must be pinned' USING ERRCODE='23514'; END IF;
   IF (listing.store='ios' AND ((is_content_write(listing.title_state) AND utf16_length(listing.title)>30)
     OR (is_content_write(listing.subtitle_state) AND utf16_length(listing.subtitle)>30)
     OR (is_content_write(listing.keywords_state) AND utf16_length(listing.keywords)>100)
     OR (is_content_write(listing.promotional_text_state) AND utf16_length(listing.promotional_text)>170)))
    OR (listing.store='android' AND ((is_content_write(listing.title_state) AND length(listing.title)>30)
     OR (is_content_write(listing.short_description_state) AND length(listing.short_description)>80)))
    OR (is_content_write(listing.description_state) AND length(listing.description)>4000)
   THEN RAISE EXCEPTION 'listing proposal exceeds provider field limits' USING ERRCODE='23514'; END IF;
   IF listing.app_clip_incomplete_header_id IS NOT NULL AND (listing.app_clip_operation<>'repair_header'
    OR r.baseline_revision_id IS NULL OR NOT EXISTS(SELECT 1 FROM action_listing_content b
     WHERE b.organization_id=r.organization_id AND b.revision_id=r.baseline_revision_id
      AND b.app_clip_header_state='incomplete' AND b.app_clip_incomplete_header_id=listing.app_clip_incomplete_header_id))
   THEN RAISE EXCEPTION 'App Clip deletion target requires exact incomplete baseline' USING ERRCODE='23514'; END IF;
   IF listing.app_clip_operation<>'none' THEN
    SELECT * INTO STRICT media FROM action_media_content WHERE organization_id=r.organization_id AND revision_id=r.id AND slot=listing.app_clip_header_media_slot;
    IF media.kind::text<>'app_clip_header' OR media.store<>listing.store OR media.locale<>listing.locale OR media.availability<>'stored'
     OR media.provider_md5 IS NULL OR listing.app_clip_release_version_id IS DISTINCT FROM listing.app_version_id
    THEN RAISE EXCEPTION 'App Clip approval must pin same-locale immutable header and exact release target' USING ERRCODE='23514'; END IF;
   END IF;
  END IF;
  IF EXISTS(SELECT 1 FROM action_media_content m WHERE m.revision_id=r.id AND
   (m.store<>listing.store OR m.locale<>listing.locale OR
    (r.purpose='proposal' AND (m.availability<>'stored' OR m.kind::text<>'app_clip_header'))))
  THEN RAISE EXCEPTION 'listing media must match locale; current write capability supports frozen App Clip headers only' USING ERRCODE='23514'; END IF;
 ELSIF r.kind='ads' THEN
  SELECT * INTO STRICT ad FROM action_ad_content WHERE organization_id=r.organization_id AND revision_id=r.id;
  IF length(ad.provider_account_id)=0 OR ((r.purpose='proposal') IS DISTINCT FROM (ad.intent<>'observed'))
  THEN RAISE EXCEPTION 'invalid ads account or intent' USING ERRCODE='23514'; END IF;
  IF r.purpose='proposal' THEN
   expected=CASE r.operation WHEN 'asa_pause_campaign' THEN 'pause_campaign' WHEN 'asa_enable_campaign' THEN 'enable_campaign'
    WHEN 'asa_update_campaign_budget' THEN 'set_campaign_budget' WHEN 'asa_update_keyword_bid' THEN 'set_keyword_bid'
    WHEN 'asa_create_keyword' THEN 'create_keyword' WHEN 'asa_add_negative_keyword' THEN 'add_negative_keyword'
    WHEN 'asa_delete_negative_keyword' THEN 'delete_negative_keyword' END;
   IF expected IS NULL OR ad.intent::text<>expected OR (ad.intent='add_negative_keyword' AND ad.provider_ad_group_id IS NOT NULL)
   THEN RAISE EXCEPTION 'ads operation mismatch or unsupported ad-group negative keyword scope' USING ERRCODE='23514'; END IF;
  END IF;
 ELSIF r.kind='request' THEN
  SELECT * INTO STRICT req FROM action_request_content WHERE organization_id=r.organization_id AND revision_id=r.id;
  IF r.purpose<>'proposal'
   OR (r.operation='generate_locale' AND req.intent<>'locale_expansion')
   OR (r.operation='generate_listing' AND req.intent<>'listing_change')
   OR (r.operation='review_catch_up_30d' AND req.intent<>'review_catch_up')
   OR (r.operation='generate_review_analysis' AND req.intent<>'review_analysis')
   OR (r.operation='run_agent' AND req.intent NOT IN ('wake_agent','propose_experiment','revert_experiment','restore_listing'))
  THEN RAISE EXCEPTION 'request purpose or operation mismatch' USING ERRCODE='23514'; END IF;
 END IF;
 IF r.generated_from_revision_id IS NOT NULL AND r.purpose='proposal' THEN
  PERFORM assert_revision_target_continuity(r.organization_id,r.generated_from_revision_id,r.id);
 END IF;
 IF r.kind IN ('review_reply','listing','ads') AND r.baseline_revision_id IS NOT NULL THEN
  PERFORM assert_same_provider_content_target(r.organization_id,r.id,r.baseline_revision_id);
 END IF;
 IF r.kind='media' AND r.purpose='proposal' AND EXISTS(SELECT 1 FROM action_media_content m WHERE m.revision_id=r.id
   AND m.source_provider_resource_id IS NOT NULL AND m.source_digest IS NULL)
 THEN RAISE EXCEPTION 'generation source requires immutable pinned bytes, not only a provider URL/resource' USING ERRCODE='23514'; END IF;
END $$;
CREATE FUNCTION actions_design.provider_content_complete_at_commit()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN PERFORM actions_design.assert_provider_content_complete(NEW.id); RETURN NEW; END $$;
CREATE CONSTRAINT TRIGGER provider_content_complete AFTER INSERT OR UPDATE ON actions_design.action_revision
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions_design.provider_content_complete_at_commit();

-- Transport/compiler contract: write changesInReviewBehavior=ERROR_IF_IN_REVIEW
-- on EVERY Play commit; compile App Clip source/subtitle before review and use
-- only frozen output bytes after approval. Never choose fallback copy later.
-- For App Clip reservation repair, pin the exact observed incomplete resource
-- ID on the execution step before deletion. Existing matching card is evidence;
-- a conflicting card is an explicit blocker, never a replay overwrite.
-- R2 immutability constraints prove pin shape, not storage behavior/existence:
-- creation must be conditional, pinned objects protected from replacement and
-- deletion, and bytes rehashed before any provider upload.


-- Permanent ticket target continuity. Version/localization write targets may
-- change in a freshly reviewed revision; account/app/store/locale identity may
-- not. A genuinely different target requires a new linked child ticket.
CREATE FUNCTION actions_design.assert_revision_target_continuity(p_org text,p_previous text,p_next text)
RETURNS void LANGUAGE plpgsql SET search_path=actions_design,public AS $$
DECLARE previous action_revision; next action_revision; pr action_review_content; nr action_review_content;
 pl action_listing_content; nl action_listing_content; pa action_ad_content; na action_ad_content;
 pq action_request_content; nq action_request_content;
BEGIN
 SELECT * INTO STRICT previous FROM action_revision WHERE organization_id=p_org AND id=p_previous;
 SELECT * INTO STRICT next FROM action_revision WHERE organization_id=p_org AND id=p_next;
 IF previous.action_id<>next.action_id OR previous.purpose<>'proposal' OR next.purpose<>'proposal'
  OR NOT previous.sealed OR NOT next.sealed OR previous.revision_number>=next.revision_number
 THEN RAISE EXCEPTION 'ticket target cannot change: invalid revision predecessor' USING ERRCODE='23514'; END IF;
 IF previous.kind='request' AND next.kind='listing' THEN
  SELECT * INTO STRICT pq FROM action_request_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT nl FROM action_listing_content WHERE organization_id=p_org AND revision_id=p_next;
  IF previous.operation NOT IN ('generate_locale','generate_listing') OR pq.store IS NULL OR pq.locale IS NULL
   OR ROW(pq.store,pq.locale) IS DISTINCT FROM ROW(nl.store,nl.locale)
  THEN RAISE EXCEPTION 'ticket target cannot change: generated listing differs from requested store/locale' USING ERRCODE='23514'; END IF;
 ELSIF previous.kind='request' AND next.kind='collection' THEN
  SELECT * INTO STRICT pq FROM action_request_content WHERE organization_id=p_org AND revision_id=p_previous;
  IF previous.operation<>'review_catch_up_30d' OR pq.intent<>'review_catch_up' OR next.operation<>'post_batch'
   OR NOT EXISTS(SELECT 1 FROM action parent WHERE parent.organization_id=p_org AND parent.id=next.action_id AND parent.domain='collection' AND parent.asset_id IS NOT NULL)
   OR EXISTS(SELECT 1 FROM action_membership m
    JOIN action_revision child_revision ON child_revision.organization_id=m.organization_id AND child_revision.id=m.child_revision_id
    JOIN action child ON child.organization_id=m.organization_id AND child.id=m.child_action_id
    JOIN action parent ON parent.organization_id=p_org AND parent.id=next.action_id
    LEFT JOIN action_review_content child_content ON child_content.organization_id=m.organization_id AND child_content.revision_id=m.child_revision_id
    WHERE m.organization_id=p_org AND m.parent_revision_id=p_next
     AND (child_revision.kind<>'review_reply' OR child.asset_id IS DISTINCT FROM parent.asset_id
      OR child_content.revision_id IS NULL OR (pq.store IS NOT NULL AND child_content.store<>pq.store)))
  THEN RAISE EXCEPTION 'ticket target cannot change: catch-up batch differs from requested asset/store' USING ERRCODE='23514'; END IF;
 ELSIF previous.kind<>next.kind THEN
  RAISE EXCEPTION 'ticket target cannot change: unsupported content family transition' USING ERRCODE='23514';
 ELSIF next.kind='review_reply' THEN
  SELECT * INTO STRICT pr FROM action_review_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT nr FROM action_review_content WHERE organization_id=p_org AND revision_id=p_next;
  IF ROW(pr.provider_account_id,pr.store,pr.provider_app_id,pr.provider_review_id)
   IS DISTINCT FROM ROW(nr.provider_account_id,nr.store,nr.provider_app_id,nr.provider_review_id)
   OR (pr.apple_review_resource_id IS NOT NULL AND pr.apple_review_resource_id IS DISTINCT FROM nr.apple_review_resource_id)
  THEN RAISE EXCEPTION 'ticket target cannot change: review identity drift' USING ERRCODE='23514'; END IF;
 ELSIF next.kind='listing' THEN
  SELECT * INTO STRICT pl FROM action_listing_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT nl FROM action_listing_content WHERE organization_id=p_org AND revision_id=p_next;
  IF ROW(pl.provider_account_id,pl.store,pl.provider_app_id,pl.package_name,pl.locale)
   IS DISTINCT FROM ROW(nl.provider_account_id,nl.store,nl.provider_app_id,nl.package_name,nl.locale)
  THEN RAISE EXCEPTION 'ticket target cannot change: listing identity drift' USING ERRCODE='23514'; END IF;
 ELSIF next.kind='ads' THEN
  SELECT * INTO STRICT pa FROM action_ad_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT na FROM action_ad_content WHERE organization_id=p_org AND revision_id=p_next;
  IF ROW(pa.provider_account_id,pa.provider_campaign_id,pa.provider_ad_group_id,pa.provider_keyword_id,pa.provider_negative_keyword_id)
   IS DISTINCT FROM ROW(na.provider_account_id,na.provider_campaign_id,na.provider_ad_group_id,na.provider_keyword_id,na.provider_negative_keyword_id)
  THEN RAISE EXCEPTION 'ticket target cannot change: ads identity drift' USING ERRCODE='23514'; END IF;
 ELSIF next.kind='request' THEN
  SELECT * INTO STRICT pq FROM action_request_content WHERE organization_id=p_org AND revision_id=p_previous;
  SELECT * INTO STRICT nq FROM action_request_content WHERE organization_id=p_org AND revision_id=p_next;
  IF ROW(pq.intent,pq.store,pq.locale,pq.requested_agent_id) IS DISTINCT FROM ROW(nq.intent,nq.store,nq.locale,nq.requested_agent_id)
  THEN RAISE EXCEPTION 'ticket target cannot change: request identity drift' USING ERRCODE='23514'; END IF;
 ELSIF next.kind='media' THEN
  -- Per-slot generation images may change; their store/locale target cannot.
  IF EXISTS(SELECT 1 FROM action_media_content old WHERE old.organization_id=p_org AND old.revision_id=p_previous
   AND NOT EXISTS(SELECT 1 FROM action_media_content fresh WHERE fresh.organization_id=p_org AND fresh.revision_id=p_next
    AND (fresh.store,fresh.locale)=(old.store,old.locale)))
   OR EXISTS(SELECT 1 FROM action_media_content fresh WHERE fresh.organization_id=p_org AND fresh.revision_id=p_next
    AND NOT EXISTS(SELECT 1 FROM action_media_content old WHERE old.organization_id=p_org AND old.revision_id=p_previous
     AND (fresh.store,fresh.locale)=(old.store,old.locale)))
  THEN RAISE EXCEPTION 'ticket target cannot change: media store/locale drift' USING ERRCODE='23514'; END IF;
 END IF;
END $$;
CREATE FUNCTION actions_design.guard_action_target_continuity()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF OLD.current_revision_id IS NOT NULL AND NEW.current_revision_id IS DISTINCT FROM OLD.current_revision_id THEN
  PERFORM actions_design.assert_revision_target_continuity(NEW.organization_id,OLD.current_revision_id,NEW.current_revision_id);
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER action_target_continuity BEFORE UPDATE ON actions_design.action
 FOR EACH ROW EXECUTE FUNCTION actions_design.guard_action_target_continuity();


-- Current wake_agent intent resolves the exact existing agent before approval.
-- A different agent on the same asset cannot satisfy this approved request.
ALTER TABLE actions_design.action_request_content
 ADD COLUMN requested_agent_id text REFERENCES public.agent(id),
 ADD CONSTRAINT request_agent_target_shape CHECK((intent='wake_agent')=(requested_agent_id IS NOT NULL));
CREATE FUNCTION actions_design.request_agent_target_at_commit() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF NEW.intent='wake_agent' AND NOT EXISTS(
  SELECT 1 FROM public.agent target
  JOIN actions_design.action_revision r ON r.organization_id=NEW.organization_id AND r.id=NEW.revision_id
  JOIN actions_design.action a ON a.organization_id=r.organization_id AND a.id=r.action_id
  WHERE target.id=NEW.requested_agent_id AND target."organizationId"=a.organization_id
   AND target."assetId" IS NOT DISTINCT FROM a.asset_id
 ) THEN RAISE EXCEPTION 'requested agent must belong to exact organization and asset' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE CONSTRAINT TRIGGER request_agent_target_complete AFTER INSERT OR UPDATE ON actions_design.action_request_content
 DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION actions_design.request_agent_target_at_commit();
