# Ownership v6 — clarification after the v5 review

18 September 2026 · Documentation only · Platform implementation paused

[Visual comparison](ownership-overview.html) · [Ownership v6](Fload-Inbox-Ownership-Design-v6.md) · [Previous v5](Fload-Inbox-Ownership-Design-v5.md)

The independent v5 review confirms C1 and C2, finds no failing interleaving in the reviewed sequences, and confirms the public page. Two low clarifications are now explicit. No tables, columns or enum values are added.

| Clarification | Applied in v6 |
|---|---|
| C3: decide the no-step scan branch from stored facts | A NULL effective route is eligible only when the execution is blocked and has a due time, subject to existing due/claim/hold rules. It runs only state normalization. An active execution with no effective route is excluded and reported as an operational integrity problem. |
| C4: keep later expansion on its original operation versions | The existing immutable plan version selects a typed template pinned when approval creates the execution. Binding and reservation expansion use that template's exact operation contracts and policies, never whatever is newest on the worker. |

“Effective route” preserves the accepted unfinished-attempt precedence: a valid unfinished original attempt still supplies its step even if the stored next-step pointer is NULL. Active executions with real routes also retain their normal deadline checks. This is not a rule that every state-only check must be blocked, nor permission to silently change malformed rows into blocked work.

For expansion, knowing the pinned template and having every later provider handler are different capabilities. A worker that knows the exact template can append its prescribed steps, then leave unsupported steps due for a compatible worker. A worker that does not know the template cannot claim that expansion. The existing worker capability manifest therefore includes operation/template pairs for expansion; ordinary readback and cleanup remain gated by their current operation alone. No whole-plan support condition is imposed on safe recovery.

## Verification and limits

The source already stores an immutable `plan_version`, but its compiler currently uses a single constant and hardcoded expansion versions. The proposed versioned templates and complete routing rules still require implementation. The public page shows the existing plan-version field and explains why release binding cannot upgrade operation versions.

Required fixtures include blocked NULL-route normalization; malformed active NULL-route rows excluded and alerted; unfinished-attempt precedence; a newer worker expanding an older plan; a known template with absent later handlers; an unknown template under a shared binding contract; and lease identity changing when advertised expansion support changes.

R2 conflicting-completion retention, R3 historical-evidence source matrices, consolidated DDL/types, migration conservation, database-role checks, native decoders, concurrency/crash/retry/load proof remain open. No platform code, migrations, provider calls or production deployment are included.
