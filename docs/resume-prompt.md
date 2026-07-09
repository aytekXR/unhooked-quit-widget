# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v1.8 |
| Last updated | 2026-07-09 (Session 06 close: E2.2 DONE + ADR-7 cap closed + engine v1.1.0; TestFlight signing proven, upload waits on the ASC app record) |
| Phase | Phase 1 core build — Epics 0–1 CLOSED; E2.1 + E2.2 DONE and CI-verified |
| Next session objective | **E2.3 — CloudKit dedupe merge pass + `recomputeDerivedState()` (incl. the carried ADR-7 re-anchor healing)** |

> **What changed in Session 06:** E2.2 QuitRepository is DONE and CI-verified
> (red 28986772423 → green 28987307905 → review-red 28988559874 → review-green on
> b9080ab, all test lanes + the new sole-SwiftData-importer lint green). The ADR-7
> reboot sanity cap carried since Session 03 is CLOSED — StreakEngine is **1.1.0**
> (tagged `streakengine-v1.1.0`): `lastKnownGood` reboot guard, 14d gap cap, same-boot
> bridge, all coverage floors held at 100%. The TestFlight **signing** chain is proven
> end-to-end (gym exports a signed IPA); the upload now fails ONLY on the missing
> App Store Connect app record (operator, see blockers). CodeGraph is now a permanent
> session rule (see below and `session-rules.md`).

---

## Standing tooling rule — CodeGraph (permanent, applies to every agent)

The repo is CodeGraph-indexed (`.codegraph/`, machine-local). **Query it first**: use
the `codegraph_explore` MCP tool (shell: `codegraph explore "<symbols or question>"`)
BEFORE grep/find or manual file reading — one call returns verbatim line-numbered
source + call paths + blast radius. Pass this instruction into every subagent/workflow
prompt. Check dependents before editing public symbols. **Before the session-end
commit, run `codegraph sync` and confirm `codegraph status` is clean.**

## Where we are

- **StreakEngine 1.1.0** (tagged, 77/77, llvm-cov 100/100/100, merge-blocking gate
  live): full guard incl. the reboot cap — semantics ratified in Sessions 03–06 "Key
  decisions" in `past-prompts.md`; READ THEM before touching the engine.
- **E2.2 QuitRepository** (`App/Sources/Persistence/QuitRepository.swift`, @MainActor,
  the sole SwiftData importer — CI grep enforces): createQuit (max-3), synchronous
  logSlip (save-before-return; banks BANKED-only totalCleanSeconds; guarded slip
  instant), logUrgeEvent, activeQuits (justifies the landed
  `#Index<Quit>([\.isArchived,\.sortIndex])`), streakValue (LKG-fed reboot cap
  end-to-end), debounced widget reload (500 ms trailing, injected sleep).
  `LastKnownGoodStore` = App Group defaults, device-local BY DESIGN (never the
  mirrored store); advancement gated on `.normal` verdict AND continuity with the
  previous reading (Session 06 review MAJOR — do not weaken either gate).
- **TestFlight:** match → manual signing → gym all green. `MATCH_BOOTSTRAP=true`
  stays set until the first green upload, THEN delete it.

## Next session objective (one session, definition of done below)

**E2.3 — CloudKit dedupe merge pass** (`implementation-plan.md` E2.3, deps E2.1 ✓),
strictly test-first (session-rules mechanics: package/app red evidence as usual):

1. The plan's named red tests: `test_mergeDuplicateQuits_keepsMaxTotalTrackedSeconds`,
   `test_merge_takesFieldwiseMax_bestStreak_totalClean`,
   `test_merge_unionsSlipsWithoutDuplicates`, `test_merge_noDuplicates_isNoOp`, plus
   the property test `test_property_mergeIsCommutativeAndIdempotent`.
2. **The carried ADR-7 healing half:** a `recomputeDerivedState()` pass (architecture
   §8) that runs the launch-time merge AND re-anchors a frozen/flagged quit
   deterministically (freeze-then-resume for the innocent long-power-off user; the
   Session 06 design panel deferred exactly this here as the only sync-safe place for
   a corrective write). Red-first; engine changes, if any, red-first with the 100%
   coverage bar held.
3. Merge is repository/service-layer work — the sole-importer lint must stay green;
   simulated duplicate records only (real CloudKit is contract-tier/nightly, and the
   §4.3 CloudKit-option flip to `iCloud.com.beyondkaira.ballast` remains a separate
   red-test-first decision a session may take on deliberately, not incidentally).

Scope guards: no UI, no paywall, no widget rendering; never weaken a QA assertion;
`logSlip` stays synchronous-local; monotonic fields never decrease (undo is the one
sanctioned exemption); no `Date()`/`ProcessInfo` outside the sanctioned seam.

---

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**, org
> `com.beyondkaira`). Epics 0–1 CLOSED; E2.1 + E2.2 DONE and CI-verified; StreakEngine
> is 1.1.0 (tagged) with the ADR-7 reboot cap live and all coverage floors at 100%.
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`. **CodeGraph is a standing
> rule:** `codegraph_explore` first for any code question (pass the rule to every
> subagent), blast-radius before edits, and `codegraph sync` + `codegraph status`
> before the session-end commit. Read `docs/session-rules.md`,
> `docs/implementation-plan.md` (E2.3–E2.4), `docs/architecture.md` §4/§8/ADR-3/ADR-7,
> `docs/test-suite.md` §1.2/§4.3/§7, and the Session 03–06 entries in
> `docs/past-prompts.md` before writing anything.
>
> **This session: E2.3 — the CloudKit dedupe merge pass + `recomputeDerivedState()`**:
> the five named red tests (fieldwise-max merge, slip union, no-op, commutative+
> idempotent property) plus the carried ADR-7 re-anchor healing (freeze-then-resume)
> which the Session 06 panel deferred to exactly this pass. Test-first; repository
> stays the sole SwiftData importer (CI-linted); package changes red-first with the
> coverage gate held.
>
> **At session end:** append the Session 07 entry to `docs/past-prompts.md`, overwrite
> `docs/resume-prompt.md` with the next objective (E2.4 one-tap erase per
> `roadmap.md`), run `codegraph sync`, commit, push, and verify GitHub Actions is
> green (`gh run watch`). Fix small CI issues immediately; document large ones at the
> top of the next resume prompt.

## Operator-owned blockers (not agent work; carry until closed)

1. **App Store Connect app record missing** — `pilot` fails with "Couldn't find app
   'com.beyondkaira.ballast'"; verified via ASC API (bundle IDs + distribution cert
   visible, zero apps). Create the app record (My Apps → ＋ New App: iOS, name
   **Ballast**, bundle `com.beyondkaira.ballast`, SKU e.g. `ballast-ios`), rerun the
   TestFlight lane, and **after the first green upload DELETE the `MATCH_BOOTSTRAP`
   repo variable**. Signing/gym proven green (run 28984577954 onward). Does NOT block
   E2.3.
2. Slack webhook hygiene (optional): rotate the incoming-webhook URL that briefly sat
   in local git history; CI reads `secrets.SLACK_WEBHOOK_URL` now.
3. E0.3 device measurement (`docs/spike-panic-latency.md`, iPhone 15-class, full
   Xcode needed) — unchanged.
4. Content sign-off before ship: clinician/legal pass on `safetyCopy.json`, 3 helpline
   verify-flags, TR L10n (see `App/Resources/Content/REVIEW.md`) — unchanged.
5. Drift decision: MVP §7 "<2s 10/10" vs test-suite §1.5 "p90 < 2s" — unchanged.

## Standing rules reminders (do not relearn these)

- No shame copy; no medical claims; no red anywhere in UI; discreet variants mandatory.
- Analytics via the closed `AnalyticsEvent` enum only; zero events before opt-in;
  `logSlip` stays synchronous-local.
- Monotonic fields (`bestStreakSeconds`, `totalCleanSeconds`) never decrease — undo is
  the ONE sanctioned exemption; streaks freeze, never inflate (ADR-7).
  `Quit.totalCleanSeconds` is BANKED-only (== engine `priorCleanSeconds`; the live
  streak is added at read time — anything else double-counts momentum).
- LKG discipline (Session 06): the last-known-good reading is device-local (App Group
  defaults, NEVER the mirrored store); it advances ONLY on a `.normal` verdict against
  a pre-existing anchor AND continuity with the previous reading; createQuit never
  refreshes it. The bridge inherits the within-boot verdict — never hardcode `.normal`.
- Undo lifecycle (flag=true, finalize sweep, undoSlip, isPendingUndo index) is E4.1's,
  as ONE unit. `#Index<Slip>([\.at])` → first time-ordered query; UrgeEvent.at → E12.4.
- Panic path stays thin (ADR-6). Single CloudKit-mirrored SwiftData store; no accounts,
  no backend (ADR-2). Never re-introduce `dev.placeholder.quitwidget`. Never weaken a
  QA assertion; TDD red first, always (test-suite §7); red evidence = local swift test
  for packages, the CI run on the red commit for app lanes.
- StreakEngine ratified semantics: Sessions 03–06 "Key decisions" in `past-prompts.md`
  — the engine's input type is `StreakSnapshot`; package `///` docs stay
  consumer-self-contained; no `@Attribute(.unique)` ever; `cloudKitDatabase` is
  `.none` until the §4.3 red-test-first flip is deliberately taken.
