# FLO-1355 — Command, approval, membership and history design review

Reviewed `schema-core.sql` as supplied on 15 September 2026, including the subsequent decisions to keep kind/operation on revisions, add persistent parent links and use one-way policy revocation. Findings are design gaps to close, not claims about applied database objects. The runtime target covers the 18 supported executors plus actual current generation, iteration, package, prerequisite and information flows. Retired ads/product payload variants must not enter the active schema or dispatcher; their receipt/link accounting stays at cutover.

## Executable design validation, 15 September 2026

The concrete implementation of this design review is now [schema-command-guards.sql](schema-command-guards.sql), composed with the core, content, revision, execution and domain-binding modules by [validate-design-schema.py](validate-design-schema.py). The table below records the original gaps and their resolutions; it is not a claim that every gap remains open.

The integrated PostgreSQL 17 proof passed 60 explicit SQL assertions (16 positive and 44 negative), plus a two-session contention test: the second connection was observed waiting on the same ticket row, the winner committed one version, and the stale command was rejected and rolled back. The immutable output pin was tested through one locale ticket's generation request → generated listing → fresh publication approval, and a catch-up request → permanent review package → fresh exact child approval. Zero eligible reviews remains a typed no-work outcome linked to a completed scoped run. Revoked policy authority is rejected before a fresh internal effect; current-target continuity rejects store, locale and provider-account changes. A wake-agent request pins the exact requested agent; a run from another agent on the same app is rejected before its generation attempt can start, and output finalization retains the same exact run/agent requirement. Collection content is constrained to the declared operation family and asset. Provider proof covered uncertain outcomes, complete readback, late evidence, resource release and repeated-write rejection. The generated catalog contained 25 domain tables and 464 columns, with no JSON/JSONB or array columns. The result is recorded in [design-validation-result.json](design-validation-result.json); subsequent schema edits require rerunning the harness.

These are executable design proofs against synthetic data and exact-shaped external identity stubs. They do not prove the repository migration, production role grants/RLS, current membership and credential checks, typed canonical digest implementation, queue dispatch/recovery, provider behavior, or user interface acceptance. Those remain explicit implementation and integration test gates. The two-session case establishes the tested lock/CAS interaction; it does not claim exhaustive approval/Undo/revocation/provider race coverage.

## Required before the schema is considered complete

| Priority | Invariant | Gap in reviewed core | Concrete resolution |
|---|---|---|---|
| P0 | One current authorization for one exact proposal | `action.decision='approved'` has no current approval identity; multiple historical approvals can each have executable obligations | Add `action.current_approval_id` as a maintained head reference, with same-organization/action/revision identity constraints. Worker claim checks that exact approval remains current. Undo/reject/revise clears or replaces it atomically; earlier approvals remain immutable history. Package containers without their own effect need an explicit exception, not fake parent execution. |
| P0 | Stale approvals cannot be accepted | `action_command_target.expected_version` and `expected_revision_id` are nullable; nothing relates them to locked previous state | For content decisions require both. Lock target rows, compare actual current version/head against supplied values, insert refusal/conflict otherwise. Accepted target records capture the exact locked preimage and resulting version. Database triggers enforce legal transitions/preimage consistency, not only a service convention. |
| P0 | Approval actually represents an accepted approval command | Approval references any existing command target; command kind/outcome and target result need not be approval | Deferred approval guard requires accepted `approve`, result decision approved, matching result/expected revision, proposal purpose, sealed revision, eligible kind/scope, correct actor/policy and accepted timestamp. No `snooze` or refused command can create an execution authority. |
| P0 | Selected batch membership is exact | `approval.parent_revision_id` references any same-org revision, not a membership entry; `expected_parent_revision_id` has the same weakness | Add composite uniqueness on membership `(organization_id,parent_revision_id,child_action_id,child_revision_id)` and a matching composite approval FK. Require current parent version/head in the command, parent command-target row, same parent reference on each selected child, and exact selected membership. Nonselected members get no approval. |
| P0 | Generation never edits approved membership/content | Membership belongs to a sealed revision, but generated child IDs often become known only after generation | Keep approved r1 request revision unchanged; the same stable child gains r2 concrete listing/reply revision after its authorized generation finishes. Clear current approval and require fresh perform approval for r2. Parent gets an explicit new membership revision pinning output revisions; old membership remains immutable. Persistent parent_action_id carries lineage across these revisions. Never let generation authorization follow the changing child head. |
| P0 | Undo revokes before an irreversible claim | Approval carries a deadline but no revocation selector/claim comparison | Undo checks database time and current approval under the same lock used by execution claim. All selected members must be unclaimed for atomic batch Undo. Record undo command/targets, clear current authorization and cancel ready obligations together. A late undo returns a typed `execution_started`/`undo_expired` result; it does not change provider state. |
| P0 | Auto approval is currently authorized and bounded | Policy revisions have no active/revoked head; existence of any old revision is enough structurally | Use one-way revoked_at + revoked_by_command_id on the otherwise immutable policy revision, with unique active (organization,asset,policy_kind) where revoked_at IS NULL. Grant/revoke commands explicitly target policy revision IDs. Approval binds exact revision; unstarted dispatch requires not revoked. Replace policy by atomically revoking old then inserting new; do not infer active by max revision. |
| P0 | Actor identity is complete, typed and real | Actor checks allow extra conflicting actor columns; external actor is an unscoped string; no OAuth/admin delegation shape | Enforce mutually exclusive principal shapes; preserve credential ID+owner; separate authenticated actor from acting-for user; for Slack/Discord require mapped member plus typed integration identity and external user ID. Only canonical auth establishes these fields. Current commands never accept unknown actor. |
| P0 | Approved data is immutable at every child table | `sealed` is a boolean without triggers in the reviewed core | Reject updates/deletes to a sealed revision, its concrete content and its membership/terms/media. Content mutation locks the owning revision; sealing takes the same lock so insert-versus-seal cannot race. Require sealed current/proposal/approval references at commit. Make commands/approvals/history append-only. |
| P0 | No unrelated content can execute under an approval | Execution step `content_revision_id` only enforces same org | Guard the step's revision and concrete target against its execution's approval. Baseline/readback revisions have the same authorized target but cannot replace write content. Every step in a public write must be derivable from the pinned approval; upload slots must refer to pinned media versions. |
| P1 | History is a faithful sequence, not arbitrary snapshots | Target previous/result versions/decisions are unconstrained and several are optional | Create is previous-null/result-1. Accepted changes increment exactly once; refusals/conflicts do not modify action. Guard preimage and result fields against actual action. Unique changed `(action_id,result_version)` history sequence; preserve nonchanging observations separately or explicitly tie order to command/event sequence. |
| P1 | Idempotent replay returns the same decision/result | Request digest exists but versioned serialization/result reconstruction are unspecified | Canonicalize typed input including selected members in defined order, expected versions, approval scope and all supplied content. On equal replay return the original target snapshots/approval/execution IDs/deadline, never re-run side effects or return newer content as the old result. On mismatch preserve the original command and return conflict. |
| P1 | Personal read state cannot hide future updates | No upper bound on `seen_attention_version`; stale writes can reduce a later read watermark | Server validates it against authorized observed action version; mark-read uses monotonic max and a documented force-unread concurrency rule. MarkRead touches only `action_read`, never shared version/deadline/history. |
| P1 | Parent/child and dependency graphs remain meaningful | Membership permits self-parenting, cycles, nonpackage parents; dependency FK has no cycle check | Persistent parent_action_id must reject self/cyclic structural relationships and unapproved reparenting. Membership rows must match that structural parent; define allowed parent revision kinds and whether nested package selection is supported. Approval must flatten an explicitly shown leaf selection, never recursively approve unseen descendants. Parent progress uses persisted edges and actual child state. |
| P1 | “Superseded” means a proven replacement | Action requires a successor for every superseded decision, but referenced action can cycle and have incompatible scope | Enforce same org, no cycle, allowed target lineage; use distinct explicit cancellation/no-op/external outcome when there is no successor. Do not invent replacement IDs to satisfy a check. |
| P1 | Current actor and tenant relations are enforced | Most external IDs (`organization_id`,`asset_id`,`actor_user_id`, key/run/connector IDs) have no domain FK in this design fragment | Harness supplies real-shaped domain references; final DDL adds same-org target constraints and principled retained identity semantics. API-key owner, integration membership, asset, run and policy relationship must be checked, not just ID existence. |

## Acceptance transaction: the required contract

1. Parse a closed discriminated command at the API boundary. It contains target ID(s), expected versions/revisions, exact selected child pins and an idempotency UUID. Actor is server-established; ignore/reject actor fields in client input. Reject unknown fields rather than strip potentially meaningful additions silently.
2. Establish canonical tenant/principal and operation-specific authorization. An internal adapter does not broaden a caller's scope: `write:reviews`, `write:aso` and ASA write permission remain meaningful through a generic Actions command.
3. Resolve a tenant+stable-principal+idempotency key. Use an atomic insert or lock to serialize concurrent duplicates. Never key this by editable actor display name or raw untrusted subject text. An equal existing command returns its original response; changed digest is a conflict.
4. Resolve target scope and lock parent/selected children in deterministic action-ID order. Freeze a single database timestamp after obtaining locks. Avoid external calls while holding this transaction; any expensive preflight observation is checked again for the facts whose change would invalidate acceptance.
5. Validate expected versions, exact revisions, current membership, sealed proposal content, operation/family/scope, current authorization and no unresolved conflicting provider effect. Validate the whole batch before accepting any member.
6. Insert the accepted command; insert targets with exact before/after facts; insert each selected leaf approval and its initial durable execution/step plan; update action head/version/attention and current-approval pointer. Parent target records membership decision, but no duplicate batch provider effect is created. All rows commit together.
7. Return the canonical receipt only after commit. It includes command ID, historical result snapshots, approval/execution IDs, `accepted_at`, `undo_deadline`, and any distinct current snapshot. A client retry does not get a newly extended deadline.
8. Signal BullMQ after commit. Lost signal is repaired by durable due-work scanning. A queued message carries only closed execution/step identity and schedule generation; the database remains acceptance authority.

`accepted_at` on refused/conflict commands is misleading. Use a neutral `recorded_at`/`received_at` for all commands and an explicit acceptance timestamp for accepted outcomes, or document precisely that the existing field means command result commit time. Undo starts from the single server acceptance time, not browser scheduling and not transaction start before a long lock wait.

## Database guards versus service checks

Database constraints should guarantee tenant/FK identity, exact membership, unique current authorization heads, sealed immutability, legal state/version shapes and append-only history. They cannot independently decide whether a signed Slack user has product permission, whether a provider permission has just been revoked or whether a preflight observation remains valid. Those require canonical auth and typed provider facts under the command/dispatch protocol. The reviewable design must label these responsibilities instead of claiming CHECK constraints prove authorization.

A deferred guard inspecting only final table state is insufficient to prove that `expected_version` matched the state before the command. Use the locked command service/SQL procedure, a BEFORE UPDATE guard against OLD, and immutable target records linked to the update. A client cannot forge a higher version plus a matching invented “previous” snapshot. Service integration tests must exercise the true writer, not a mock that bypasses the lock.

## Concrete composite relation additions

These are design fragments for the owner to integrate after final table names/guards are reconciled; they intentionally do not create another generic job/history table.

```sql
-- Make batch authorization prove an actual member and exact child revision.
ALTER TABLE action_membership
  ADD UNIQUE (organization_id, parent_revision_id,
              child_action_id, child_revision_id);
ALTER TABLE action_approval
  ADD FOREIGN KEY (organization_id, parent_revision_id,
                   action_id, revision_id)
  REFERENCES action_membership
    (organization_id, parent_revision_id,
     child_action_id, child_revision_id)
  DEFERRABLE INITIALLY DEFERRED;

-- The public-write ticket head selects current approval, never “latest row”.
ALTER TABLE action_approval
  ADD UNIQUE (organization_id, action_id, revision_id, id);
ALTER TABLE action ADD COLUMN current_approval_id text;
ALTER TABLE action
  ADD FOREIGN KEY (organization_id, id, current_revision_id,
                   current_approval_id)
  REFERENCES action_approval
    (organization_id, action_id, revision_id, id)
  DEFERRABLE INITIALLY DEFERRED;
```

The composite current-head FK permits stable child progression: after generation r1 settles, commit r2 with kind/operation appropriate to concrete listing/reply work and clear current_approval_id in the same transaction. r1 and its approval/execution remain immutable. No active or uncertain public write may be displaced by that revision advance. Package containers with no independently approved effect have no current approval/execution; their progress is computed from children. New later opportunities create new package/child identities rather than reopening a permanent app+locale key forever.

Nullable composite FKs skip validation when an optional component is null. Accompany the fragments with explicit shape checks: approval parent revision is optional for a standalone decision, required for a batch child; current approval is required only for effect-bearing approved tickets and must be null for open/rejected/cancelled/superseded tickets. Do not use null components to silently bypass scope guards.

## Policy matrix

| Policy/actor | What can be approved | Required authority at acceptance and dispatch |
|---|---|---|
| Member/session | Exact shown proposal/selection | Active membership, operation permission, asset/connector scope; actor immutable in decision history. |
| API key | Exact shown/read revision under declared API scope | Key active and owned by current org member, operation scope; retain key ID and owner, no secret/token storage. |
| OAuth delegate | Exact revision under delegated scopes | Canonical delegated principal and current membership; retain app/client identity when auth establishes it, do not invent it from channel. |
| Slack/Discord mapped human | Exact button revision/selection | Valid signed interaction, owning integration and mapped current member with permission. Unmapped new actors get authentication/current-content link, not store-write approval. |
| Admin impersonation | Exact permitted proposal in selected organization | Preserve real admin actor and acting-for identity; record explicit delegated scope. |
| Review automation policy | Bounded initial/replacement reply intents explicitly granted | Active exact policy revision; org+asset/store, rating/window/content/rule restrictions and replacement permission all checked. A newer policy never broadens an already approved revision. |
| Generation policy | Bounded generation targets only | Active generation policy and budget/entitlement; cannot authorize publication of generated text. |
| Agent run | Create/revise/generate within granted scope | Agent provenance is authorship/execution actor. Public-write authorization must point to a human or current policy grant, not merely `principal_kind=agent`. |
| Recovery worker | Dispatch/readback/reconcile existing authorization | No new public-write scope or content; revoked/mismatched authority blocks. Uncertain prior effects are read back even if no new write is allowed. |

`action_policy_revision` needs strict policy shape checks: bounds pair rules and ordering; generation policy has no reply permissions; reply policy declares allowed intent and required concrete target; policy scope/content is immutable. Only a paired NULL→revoked_at/revoked_by_command_id transition is permitted, never reversal/rewrite. Revocation actor/time lives in an accepted revoke command explicitly targeting this revision; grant likewise requires an authorized human/admin command. A partial unique index permits at most one active revision per org/asset/kind. Replace/revoke serializes on this scope, revokes old first, inserts new, and never infers active by max revision. Readback for uncertain earlier writes remains permitted after revocation; new public-write claims do not.

## Response reconstruction and history

The existing command-target before/after snapshot design can avoid a separate open event payload table. It works only if:

- targets exactly describe the state transition actually committed;
- command, target, approval and content rows are immutable;
- typed response fields that cannot be reconstructed from these rows receive explicit columns/relations;
- original result and current ticket snapshot are distinct in the API;
- child approval selections link through the actual membership rows;
- returned Undo deadline and accepted IDs remain the same on every retry;
- assignment, read state, author, approver, delegated initiator and worker identity never collapse into one owner field;
- event ordering is durable and paginated, with actor snapshots deliberate historical facts rather than mutable profile lookups;
- failed/refused commands contain typed errors without recording an accepted approval or advancing workflow version.

Do not store a response JSON blob “for idempotency.” Enumerate the response union and test that it can be reconstructed from exact immutable rows. A digest proves request equality only with a versioned canonical encoder; it does not preserve missing approved content.

## Proof tests for the schema harness and service suite

1. Insert approval against baseline/observation/unsealed/unrelated revision: reject.
2. Insert approval referencing accepted snooze, refused approve, wrong target result, wrong tenant or wrong scope: reject.
3. Parent has A@r2 and B@r4; approve A@r1 or C@r1 or an unrelated parent revision: reject. Approve A@r2 only: no B approval created.
4. Change membership after the client read; old expected parent version fails even if selected children happen to be unchanged.
5. Two concurrent approvals of one revision: one current authorization; losing command returns stable conflict, not a second execution.
6. Same idempotency key concurrently: same command/approval/execution/deadline. Changed body or selected child revision: conflict without modifying first result.
7. Approve versus iteration/human edit: one atomic winner; discarded generation result cannot replace approved content.
8. Seal versus child content/member insertion: one serial ordering; no content can appear after approval without being in its digest.
9. Undo exactly before/at/after deadline versus execution claim: documented boundary; never both successful undo and first effect claim.
10. Batch Undo where one member already started: entire Undo refused; optional remaining-member cancellation requires a separate explicit command.
11. Revoke key/membership/policy before dispatch: public write blocked; already-uncertain execution still gets safe readback.
12. Old policy revision still exists but current policy disabled/replaced: cannot acquire new approval or reauthorize broader effect.
13. Forged external user ID or owning integration without member mapping: no approval. API-key approval retains credential identity; admin action retains impersonation pair.
14. Failed/refused command cannot advance action or create execution. Accepted state mutation cannot omit history or forge preimage/version.
15. MarkRead with a future watermark rejected; stale read does not regress watermark; neither operation changes shared action version/deadline/decision.
16. Generation completes: approved r1 request remains immutable; same child gets r2 typed output and cleared current approval; new parent membership pins r2; child write remains unapproved; retry yields the same child/revision identities. Unsettled or uncertain old effect prevents head replacement.
17. Cyclic/self membership/dependency/successor edges rejected under concurrent inserts, not only sequential prechecks.
18. History response remains reconstructable after actor profile rename, later ticket revisions and repeated retries; durable detail URLs remain valid.

The DDL harness can prove structural rejection and concurrent transaction guards. Full canonical authorization, queue delivery, browser acceptance and provider boundaries need repository integration tests on the final command implementation. Passing schema creation alone is not implementation readiness.

## Stable identity across generation and application

`action` owns permanent organization/domain/asset/parent identity. `action_revision` owns the immutable kind and operation that explain what is being proposed at that stage. This is normalized: kind/operation can change when a locale child moves from a request to concrete listing copy, while permanent identity does not.

Required transition matrix examples:

| Stable domain | Before revision | After revision | Gate |
|---|---|---|---|
| Listing | Request: generate one target locale/listing | Listing: create locale/apply exact fields | Prior generation claim accepted and settled; same org/app/store/locale target; current revision still generation input; new perform approval required. |
| Review reply | Request: generate draft for one review | Review: send exact text | Same review target; prior generation result authoritative; no public effect implied; new perform approval/policy decision. |
| Listing/review | Concrete unapproved draft | Same concrete operation with edited content | Explicit Revise/iteration claim against current revision; no dispatched or uncertain effect; old approval invalidated before change. |
| Collection | Input membership revision | Generated/edited output membership revision | Same structural child IDs for this collection; explicit version advance after result; never mutate old approved membership. |
| Any current domain | Settled completed work | New later opportunity | New ticket/collection occurrence with linked prior work, rather than deterministic ID resurrection. |

Every revision purpose still has exactly its matching concrete content. Same tenant is not enough: a request to generate an iOS locale cannot turn into an Android listing or ads budget revision. Family guards compare stable target/domain and allowed stage transitions. The generation worker may author the next draft only using its current authorized generation claim; it cannot grant itself perform authority.
