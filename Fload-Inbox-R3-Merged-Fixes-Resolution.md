# Four product PRs merged — current behavior and remaining fixes

19 September 2026 · F1–F4 reconciled · Documentation only; platform implementation paused

Both local origin/main and remote main were verified at `e7c094c81b54e13e52d329f39157a39fb99a3c98`. The related product PRs are all merged:

| Merged change | What is already in main |
|---|---|
| [1445](https://github.com/fload-ai/fload-platform/pull/1445) · `324b05de` | Standing top-ups, hourly/weekly refill paths, no ten-day dedupe, separate in-app and channel announcements |
| [1446](https://github.com/fload-ai/fload-platform/pull/1446) · `560aaeab` | Due/current/future month grouping, Earlier collapsed, prerequisite-specific check labels |
| [1448](https://github.com/fload-ai/fload-platform/pull/1448) · `eec9f029` | Count pending approval plus blocked rows with stored ownerCode=you; exclude approved work and Fload-owned/unowned blocked rows |
| [1447](https://github.com/fload-ai/fload-platform/pull/1447) · `e7c094c8` | Remove ten-day-skip copy; distinguish all-full from some-full in the toast |

PR1449 is an additional CI-only merge. Merge status is not proof of production deployment. The 212-column schema inventory is unchanged; producer behavior changed and must be re-audited before migration.

| Review finding | Applied disposition |
|---|---|
| F1 · Count and source pins moved | Current predicate now documented exactly. Approved passive waiting is already excluded; approved work with a client-required next action is also excluded by status, so the target's typed required-action projection still needs integration. Atomic admission and exact re-check scope remain unfixed at this checkpoint |
| F2 · Stable key could be permanently refused | Corrected: deterministic producers evaluate capacity inside the final locked transaction before command insertion. Capacity alone returns a closed internal deferral with no receipt/key consumption. Keep the original source-change key; replay/mismatch checks come first. SQL-backed producer rescanning must rediscover deferred work after lost wakes or long waits. Caller-minted commands retain immutable refusal/new-key retry |
| F3 · Visible is not the same as client-clearable | A new client-clearable blocker consumes a slot. A supported Fload-owned real-work card with no independent client obligation may be visibly admitted at zero slots under the same guard, preserving “Blocked on us.” Unknown owner is not proof for that branch; existing-work problems always remain visible |
| F4 · Merged copy still needs correction | The all-versus-some toast logic is fixed. The dialog still says five open tasks/every week and understates delivered-report channel announcements. Track as post-merge copy work, not an open PR review |

No new table, command kind, admission epoch, arbitrary payload or mutable counter is introduced. The new producer result is a closed internal contract; it does not claim work was accepted. An execution due scanner cannot discover a declined candidate with no execution, so the producer SQL relation and fair full rescan are explicit implementation gates. Current recent-review scans alone do not prove durable re-offer.

[Current coordination and producer protocol](Fload-Inbox-R3-Parallel-Work-Coordination.md) · [Historical command matrix](Fload-Inbox-R3-Historical-Ticket-Matrix.md) · [Destination contracts](Fload-Inbox-R3-Destination-Contracts-v2.md) · [Visual summary](ownership-overview.html#coordination-heading)

The accepted ownership architecture and five-client-attention policy remain unchanged. E4 and the remaining strict schemas, final DDL, refreshed census and runtime/migration proof remain open. No platform edits, provider/database operations, cleanup, runtime tests or deployment in this documentation pass.
