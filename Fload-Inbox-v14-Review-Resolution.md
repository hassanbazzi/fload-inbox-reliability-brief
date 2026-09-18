# FLO-1355 — v14 review disposition and v15 correction

18 September 2026 · Documentation only · Implementation paused

The v14 review accepts M7 and L8. Its remaining finding, **L9**, is a small recovery-timing improvement. The [v15 design](Fload-Inbox-Revised-Design-v15.md) applies it; the [visual summary](summary.html) shows the unchanged architecture and the simplified recovery rule.

## One final-read deadline instead of two branches

Near the old ordinary deadline, v14 could leave only seconds for the protected read to start; exactly at the boundary it provided 24 hours. V15 uses one fixed end:

```text
R = exact provider edit expiry + initial backoff
D = original uncertain DELETE finish + ordinary window
H = max(D, R + fixed grace)
```

| Allowance | Lower bound | Exclusive deadline |
|---|---|---|
| Up to five ordinary starts | Current time and existing backoff | D |
| At most one protected start | Current time, existing backoff and R | H |

This remains six starts at most. Ordinary starts have priority while they fit before D, even after expiry. After D, unused ordinary slots are forfeited, but the one protected start remains available until H. It does not require five earlier starts to have happened. No seventh attempt, new grant or deadline reset is introduced.

The protected allowance is consumed when the original initial-read count reaches six, or any original initial read was admitted at/after D. This uses existing immutable attempts. Finalizing a consumed protected read ends initial capacity immediately, even if only three reads ran and H remains in the future. Independent Reconcile grants retain their own counts and due times.

## The boundary example

Times below are hours after the original uncertain DELETE finished; the pinned ordinary window is 168h and grace is 24h.

| Case | R | D | Protected end H | Result |
|---|---|---|---|---|
| Edit expires at 166h | 167h | 168h | 191h | A worker arriving at 168h05m can still start the protected check if backoff and authority permit |
| R just before D | 168h−1µs | 168h | 192h−1µs | No collapse to a microsecond admission interval |
| R equals D | 168h | 168h | 192h | Same fixed-grace rule |
| R just after D | 168h+1µs | 168h | 192h+1µs | Endpoint changes continuously |

Admission at H is refused. A long claim, backoff or outage can still outlast the fixed interval; this is a bounded recovery opportunity, not guaranteed provider success. Expiry or exhaustion never proves cleanup or permits resending the uncertain DELETE. Exact provider evidence remains required. [AppEdit resource](https://developers.google.com/android-publisher/api-ref/rest/v3/edits), [GET edit](https://developers.google.com/android-publisher/api-ref/rest/v3/edits/get).

## Checks and unchanged decisions

A documentation arithmetic check reproduced the old short-window failure and passed seven groups: delayed final start; old-expiry retries; microsecond boundaries and endpoint exclusion; fewer ordinary starts; no seventh attempt; far expiry/backoff; and protected-start consumption after failure. These checks do not exercise Fload code, SQL, queues or providers.

The independent design pass found the selector, consumption rule, normalizer, general grant contract and acceptance case consistent. The corrected contract records the same captured database instant for admission checks and started_at, so a stale ordinary delivery cannot bypass D.

M7's preserved retry allowance and L8's Scheduled presentation remain accepted. The future date wake, exact attention history, parent/list/count rules, conservative personal watermark, native finality and safe guard release are unchanged. A gate can make work unread before a later legitimate event restores automatic checks; that real history is retained.

No stored fields, enum values or relations are added. The preserved prototype remains unchanged. Implementation proof I1–I6 still includes transaction admission guards, SQL/Core parity, native decoding, durable gate handling, migrations, crash/concurrency fixtures and producer cutover. No platform implementation, application tests, migrations, provider writes or production deployment occurred.
