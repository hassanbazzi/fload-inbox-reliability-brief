# R3 ledger v2 — review follow-up

19 September 2026 · Documentation only · Implementation paused

The independent review confirms the eight main corrections in ledger v2. This follow-up adds explicit rules for the remaining source cases and qualifies proposed shortcuts that would infer facts the records do not prove. The document remains **v2**; ownership v6 is unchanged.

[Current ledger](Fload-Inbox-R3-Conservation-Ledger-v2.md) · [Visual walkthrough](ownership-overview.html#conservation-heading) · [Source types and identity evidence](Fload-Inbox-R3-Source-Type-Inventory.md)

## What changed

| Review item | Resolution |
|---|---|
| F1 · Review sync can destroy migration evidence | Explicitly fence scheduler, queued/manual executors, draft regeneration/deletion and review deletion. Ordinary provider disappearance must not cascade into imported tickets, declines or history. Record known gaps without inventing lost data. |
| F2 · Staged backlog without its original card | Preserve staging facts and the missing link; hold for recovery. Do not recreate executable work from a leftover backlog row. |
| F3 · Approval-pin mismatch | Preserve it as unproved content, not a demonstrated content edit or decline. Matching hashes still need decision provenance, scope and exact transformation proof. The cited blocked-ticket gloss-refresh scenario is unproven because those writers require pending_approval. |
| F4 · Dismissed overlay associated with rejection | **Do not use matching user/asset/note/time as transaction identity.** The overlay is mutable and upserted; repeated operations can match. Preserve proven declines independently; resolve the overlay only with actual provenance or an explicit present resolution. |
| F5 · Rejection plus a later draft | One declined identity, both pieces of history preserved. Automatic replacement still requires every accepted replace_declined guard. Historical manual authorship or a manual generation trigger does not authorize reopening or publishing. |
| F6 · Partial approval policy | Explicit blocker. Do not fill missing source keys from current defaults; preserve exact source shape until its typed disposition exists. |
| F7 · Nullable finalization blocker | Preserve explicit NULL in the closed destination. Missing and NULL remain distinct; unknown non-NULL strings block. |
| F8 · Historical deleted ticket | Preserve deletion facts and its link. Final tombstone presentation remains B12; do not invent a cancelled ticket decision from execution-cancellation rules. |
| F9 · Per-store application identity | Pin Apple Adam ID for iOS and propose exact package name for Play. Play source appId can be numeric or a package, so numeric rows need a proved retained identity bridge. Ambiguous/missing bridges block; no first-candidate guess. |

Timestamp pairing is useful only when independent evidence proves two fresh default writes in the same transaction. The proposed rejection/overlay pair may instead contain an old overlay creation time. Equality does not prove transaction identity, a named timezone or unsampled periods. Agent attribution likewise needs row-linked writer/run evidence; completed/failed events also have human writers.

## How this protects the migration

| Situation | Visible result |
|---|---|
| Review disappears from the store | Its history and declined decision remain; source availability is recorded separately. |
| A staged card was deleted | The migration holds the leftover source instead of resurrecting the card. |
| Draft exists after rejection | The rejection remains until a valid explicit transition; content is not lost. |
| Old identifiers disagree | Preserve them and show an identity blocker instead of creating duplicate work. |

## What remains

All 212 source column names remain covered. Exact destination DDL, source-value round trips and runtime proof remain open. The next bounded deliverable is the consolidated **R3 destination contract**: close B9–B13 with actual fields, keys, variant constraints, command attribution, historical/tombstone presentation and stable old-link resolution. Retained domain normalization and writer/reader/erasure conversion remain required.

No new table count, lifecycle state, manual-reopen shortcut or provider-dependent Core field is approved by this follow-up. No platform code, migrations, runtime tests, production data or provider operations were used.
