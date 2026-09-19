# Destination follow-up — confirmed gaps and tightened proof rules

19 September 2026 · Documentation only · Platform implementation paused

The user has also confirmed a product refinement: five items needing client attention, with approved passive waiting outside that admission count but still visible and unfinished. Client-owned blockers count; returning problems must surface even above five, pausing new suggestions. This supersedes the earlier plan to count every approved waiting ticket.

The independent review confirms the earlier destination-contract corrections. The remaining changes are narrow: make capacity admission atomic, bind re-checks to exact targets, and state when historical review evidence can qualify. No architecture version, command kind or extra table is added.

| Finding | Disposition |
|---|---|
| C1 · Concurrent admission can exceed five | Confirmed in the merged FLO-1437 code. The source explicitly accepts overshoot. Require a short shared per-app transaction that re-counts and commits admission; prepare provider/AI content outside it. Existing field locks do not protect capacity |
| C2 · Replacement can admit unrelated tasks | Confirmed. Exempt zeroes the count; named re-check IDs do not reach the asset-wide selector. Restrict exact IDs through every delivery phase and compute credit from counted rows actually closed in the same transaction. A quantity cap alone is not a membership filter |
| C3 · Repository state moved | Both PRs are now merged, beyond the review's checkpoint. Local origin/main is `324b05de256e00e74e2074bd047199f00523f3d2`. Schema inventory is unchanged, but admission writers and the backlog wire contract changed; re-pin and re-audit before integration |
| C4 · Declined capture is conditional | Clarified: imported review claims hold legacy digests. Automatic source-change capture needs an independently recovered, fully comparable preimage. v1 hash equality cannot establish unhashed provider-edited state. Missing proof keeps suppression and the explicit reconsideration path |
| C5 · Attention for evidence capture | Explicitly follows ownership v6: canonical writer derives the delta. These historical evidence-only captures add one workflow `version` and zero `attention_version`; no personal read marks change. They do not inherit v15's broad observation-attention wording |
| C6 · Count exclusions | Named the asset_id equality exclusion of org-level prompts and hidden agent/action filters. Hidden executable obligations remain real work. The future customer capacity unit and any operational counts need explicit separate scopes |

The review's suggested fixes needed two qualifications: do not hold a database lock around a network/AI staging loop, and do not grant replacement credit by subtracting requested IDs. The current source already separates candidate preparation from its staging transaction and atomically supersedes a specific blocker; preserve those foundations.

The coordination contract also carries forward hourly top-ups, removal of the ten-day dedupe and separate in-app/channel announcements, and records open copy PR 1447. Newly raised blockers and pre-transaction review catch-up seeding are included in the admission audit; a cap on successful stages alone is not a bound on all newly surfaced work.

Read [the current coordination contract](Fload-Inbox-R3-Parallel-Work-Coordination.md), [historical capture rules](Fload-Inbox-R3-Historical-Ticket-Matrix.md#22-canonical-historical-baseline-capture-m1-qualified), [destination fields](Fload-Inbox-R3-Destination-Contracts-v2.md), or the [visual walkthrough](ownership-overview.html#coordination-heading).

The [final review disposition](Fload-Inbox-R3-Final-Review-Resolution.md) separates occupied attention slots from `attention_version`, decides new-work blocker admission and manual adoption, and names the existing wait-mode projection.

Still open: strict E4 child/variant codec; provider identity proof; per-leaf historical matrices; collection adoption; retained review identity/access/erasure; complete R2 codecs; consolidated DDL; updated writer census and migration/runtime proof. The accepted ownership boundary remains unchanged. No platform code, database migration, provider operation, cleanup, runtime test or production deployment was performed in this documentation pass.
