# FLO-1355 — v11 review disposition and v12 corrections

17 September 2026 · Documentation only · Implementation paused

The v11 review confirms H2/M3/L4/L5 are resolved and finds M4, a cleanup recovery dead end, plus L6, a same-release readiness limit. The [v12 design](Fload-Inbox-Revised-Design-v12.md) addresses both. The [visual summary](summary.html) remains the compact team walkthrough.

| Finding | Disposition |
|---|---|
| M4 · Lost inspection-edit DELETE response holds the app guard forever | Confirmed and corrected. Exact native evidence that this temporary edit is permanently unusable can close the remaining-effect hazard. Keep the lost response and uncertain original write in history; do not invent non-application or external handling. |
| L6 · Same version becomes editable again after its grant closed | Explicit stricter policy, as allowed by the review. Retain one automatic grant per exact identity/context. Offer bounded Re-check now through Reconcile; do not reset an immutable grant or bypass its unique key. |
| I1 · DELETE decoder accepts only 204 | Specified exact policy-2 variants: 200 with an empty JSON object, and 204 with an empty body. Arbitrary 2xx, including 202, is not terminal proof. Native/transport fixtures remain required. |

## The important correction to the suggested fix

An absent edit does not tell us whether the lost DELETE succeeded. Therefore v12 does **not** add inspection_edit_absent to non_application_basis or rewrite the result as known_not_applied/matched_external. That would falsify history.

Instead, the original write stays uncertain. A later native cleanup readback is matched with terminal_outcome=TRUE only under the closed temporary_edit_quiescent rule. The exact step, policy, original-write subject, creation receipt, account/package/edit identity, freshly admitted recovery-read observation, required receipt and irreversible unusability must all agree. The rule proves no remaining effect from that exact temporary-resource deletion; it grants no resend and says nothing about listing publication. Other operations retain their existing request-finality rules.

| Existing fact | Required representation |
|---|---|
| Original DELETE attempt | Immutable uncertain result and its original missing/invalid confirmation |
| Recovery attempt | Native readback linked to that original DELETE and exact cleanup step |
| Native result | matched; terminal_outcome=TRUE under the exact quiescence predicate |
| Observation | Sealed exact edit, availability=absent, provider_response surface, pinned fingerprint/version |
| Receipt | Required exact Play edit identity, HTTP status and validated native decoder facts |
| Non-application/retry fields | NULL on this matched readback |
| Read-only explanation | temporary_edit_quiescent; cleanup response was not confirmed |

The five closed derived finality classes are unresolved, definitive_non_application, terminal_acknowledgement, correlated_terminal and temporary_edit_quiescent. They are derived from existing validated facts, not a second persisted authority. SQL predicates, Core and strict wire projections must agree. Both marks matrices and the receipt matrix specify the exception; all unrelated TRUE claims are rejected.

A late acknowledgement or rejection can refine attribution without replaying settlement, rewriting the readback, restarting the ticket or touching a newer execution's guard. A late recovery-read response goes through the original readback's late-evidence path; only the current owner recomputes closure. Another unresolved write still blocks release.

Google describes the exact-edit DELETE route and empty-object success body, while its edit lifecycle describes discarded/invalidated edits. V12's quiescence rule is an explicit operation-specific inference, with controlled decoder/identity fixtures required before policy enablement. The sources do not establish a generic absence-to-finality rule. [DELETE reference](https://developers.google.com/android-publisher/api-ref/rest/v3/edits/delete), [Edits lifecycle](https://developers.google.com/android-publisher/edits), [Edit resource](https://developers.google.com/android-publisher/api-ref/rest/v3/edits).

## Why L6 does not silently reset a grant

A later sync of the same native version has the same uniqueness and idempotency tuple. The proposed one-sentence reacceptance would contradict those constraints or renew an immutable budget. V12 keeps the stricter option explicitly: after this grant closes, a new native version or actual schedule change follows the existing event rules, while the same-version readiness cycle offers Re-check now. No-op scheduling and repeated syncs do not mint capacity. Fully automatic recovery on every cycle would need persisted, ordered readiness-episode identity; that extra mechanism is outside current scope.

## What must be proved in implementation

- Lost or malformed cleanup response → exact quiescence → no resend, truthful history, safe settlement/reopen and app guard release.
- Wrong edit/account/package, cached pre-admission evidence, generic 404, permission errors, throttling, ambiguous identity or another operation cannot assert quiescence.
- Crash before/after persistence, duplicate delivery, late recovery response, late DELETE acknowledgement/rejection, and a second ticket acquiring the same app guard.
- Independent unresolved sibling write still blocks settlement; cleanup evidence does not replace content-verification evidence.
- 200 {} and 204 empty decode as acknowledgement; 202 and malformed/nonempty bodies do not.
- Same release becomes ready again after no_editable_release closed its grant: no duplicate event grant; one explicit Reconcile key gives one bounded grant.

These are required failing→passing fixtures, not executed application tests. Existing migration, provider decoder, shared exhaustion, due-scan, pricing/Usage and complete cutover gates remain. Native response reasons must be pinned from controlled evidence; v12 does not invent undocumented error codes.

**No additional stored fields, enum values or tables.** V11's scheduling reference remains. Scope stays 28 Actions relations + two new Usage relations + one modified Usage log = 31 touched relations. The [prototype catalog](Fload-Inbox-Current-Fields.md) remains unchanged historical evidence. Platform HEAD and all 215 recorded prototype entries are preserved. No implementation, migrations, application tests, provider writes or production deployment occurred in this pass.
