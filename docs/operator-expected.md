# Operator Expected — the live "what only aytek can do" checklist

| Field | Value |
|---|---|
| Status | LIVE — updated at every session close (operator request, Session 10) |
| Last updated | 2026-07-11 (Session 15 CLOSE: E8.1 COMPLETE — the analytics boundary is live and double-gated shut; §0 panic-fix push STILL OPEN; NEW §8 TelemetryDeck app ID) |
| Rule for agents | Update this file at session end alongside `resume-prompt.md`. It is TRACKED (in `docs/`) so the operator can read it anywhere on the go. The untracked root `OPERATOR-TODO.md` is now just a pointer here. |

Nothing below blocks the next session (E5.1 age gate — though its agent must
resolve the `age_gate_blocked` schema tension first, see the resume prompt) — but
**§0 is urgent in a way the rest isn't**: an uncommitted, device-verified fix
lives only in your Mac's working tree. Items below §0 are ordered by how much
they age; check a box by replacing `[ ]` with `[x]` and the next session's agent
will prune completed items.

> **Session 15 outcome (2026-07-11):** E8.1 is DONE — the closed `AnalyticsEvent`
> enum (19 MVP §5 events, forbidden properties unrepresentable BY TYPE) +
> `AnalyticsService` with the consent gate (default OFF) + TelemetryDeck 2.14.1
> exact-pinned behind a DORMANT transport; `urge_averted`/`slip_undone` fire live
> (in-process only — nothing can leave any build until BOTH the E8.2 consent step
> ships AND you provide the app ID in §8). **Billed runs used: 3** (one burned on
> a missing test-file import — red `29130610823` burned → red evidence
> `29130875659` → green `29131380401` + TestFlight). The zero-burn streak ended
> at three sessions; the gate that closes this failure class is recorded in the
> resume prompt.

> **Session 14 outcome (2026-07-10):** E4.2 is DONE — every slip/relapse string now
> comes from the ONE audited table (`slipCopy.json`, new `dashboard` section is a
> byte-move of already-shipped literals), and
> `SlipLexiconTests.test_slipStrings_containNoForbiddenLexicon()` is a PERMANENT
> unit-lane gate (37 banned tokens, list can only grow, reflection-driven corpus).
> **Billed runs used: 2** (red evidence `29122473990` → green `29123195424`, zero
> burned — third zero-burn session in a row). Nothing rendered changed: no golden
> was touched. Your half of the E4.2 acceptance is the §3 checklist signature below.

## 0. ⚠️ Control Center panic fix is UNCOMMITTED on your Mac — push it (Session 15, 2026-07-11)

Your device report ("Panic control did nothing") was root-caused and fixed in a
Mac-side debug session: `OpenPanicControlIntent`/`OpenPanicIntent` were compiled
only into the widget extension (iOS silently no-ops a control whose
`openAppWhenRun` intent isn't in the app target), plus a latent warm-launch bug
(the flag was consumed only in `UnhookedApp.init`). The fix — intents moved to
`Shared/Sources`, new `App/Sources/WarmPanicEntry.swift` warm gate, new
`Tests/Unit/PanicWarmLaunchTests.swift` (151/151 unit + 17/17 snapshot on the
Mac) — exists ONLY in the Mac's working tree. This build machine and
`origin/main` are at `9f69f2b` WITHOUT it.

- [ ] **Commit & push the fix from the Mac** (2 moved, 3 edited, 2 new files).
      Until then the verified fix is one careless `git checkout` from being lost,
      and the build installed on your iPhone corresponds to no commit. If
      Session 15 has already pushed E8.1 commits by the time you do this, pull
      and rebase first — the touched file sets were kept disjoint on purpose
      (see the deferral note below). Push protection tripping ⇒ secret-ify,
      never unblock-URL.
- [ ] **Device-verify both paths** (the debug session's ask): COLD — app not
      running, tap Control Center "Panic" → app launches straight into the
      panic flow. WARM — app open on the dashboard, pull down Control Center,
      tap Panic → panic flow appears as a sheet over the dashboard. Doing §1's
      latency capture in the same sitting kills two birds.
- [ ] **Decide the warm-mount presentation:** it ships as a swipe-dismissible
      SHEET, not a full-screen cover, because the celebration screen has no
      dismiss button and a cover would trap you there. Veto (= you want a hard
      cover + a designed dismiss affordance) or accept; if accepted, silence —
      the record stands.
- [ ] FYI from that Mac session: `gstack` 1.39 → 1.60 is available —
      `/gstack-upgrade` on the Mac when convenient.

> **Session 15 consequence (already handled, nothing for you to do):** E8.1
> deliberately does NOT wire the `panic_opened` analytics call site this
> session — its consumption points (`UnhookedApp` init / `WarmPanicEntry` /
> `RootPlaceholderView`) are exactly the files hot in your uncommitted Mac
> tree. The seam stays deferred one more session to keep your push
> conflict-free; everything else in E8.1 proceeds.

## 1. E0.3 panic-latency device measurement — carried since Session 02, load-bearing

- [ ] Run the harness in `docs/spike-panic-latency.md` on an **iPhone 15-class
      physical device** with full Xcode; record the numbers in that doc (~30 min).
      It is the ONLY remaining blocker on wiring E3's permanent latency CI gate —
      and since Session 10 it measures the REAL panic flow's first frame.
- [ ] With the numbers, settle the wording drift: MVP §7 "<2 s, 10/10" vs
      test-suite §1.5 "p90 < 2.0 s" (one-line edit to the losing doc).
- [ ] While on the device (optional, ~5 min): feel-pass the 4-7-8 haptic rhythm in
      the real panic flow — input for E5's haptics-only settings work.

## 2. Try E4.1 on your device (your ask, Session 12) — ~10 min

- [ ] **From Xcode (Mac26 + iOS26 device):** open the project, edit the Unhooked
      scheme's Run environment variables, add `FORCE_PANIC_ROUTE=1` and
      `UITEST_SEED_PANIC_SNAPSHOT=1`, run on the device. You should see: the
      seeded two-quit picker → the real ~90s panic flow (4-7-8 breath bloom with
      haptics, urge timer, your seeded motivations verbatim, redirect menu) →
      exits → **"I slipped" → the NEW two-tap slip flow**: "Log a slip?" →
      "Log it" → the forgiveness screen ("Logged." + best/momentum framing, the
      calm NEUTRAL undo banner) → tap Undo within 10 minutes → "Undone. Your
      streak is right where it was."
- [ ] A plain TestFlight launch still shows the walking-skeleton root: no
      quiz/onboarding exists yet to create quits, so the new dashboard slip entry
      has nothing to list. That arrives with E5.

## 3. Content tone review — now fully TestFlight-visible — **+ NEW: E4.2 checklist signature (~15 min)**

- [ ] **NEW (E4.2 acceptance, your half): sign the MVP §7 copy-audit checklist**
      — "Copy audit: no medical claims, no fear content, no fabricated statistics;
      milestones say 'commonly reported'" — for the SLIP surface. The mechanical
      half is now CI-enforced (`Tests/Unit/SlipLexiconTests.swift` scans every
      slip string against 37 banned tokens on every run, and the list can only
      grow); your half is the judgment call a wordlist can't make: read
      `slipCopy.json` top to bottom (including the new `dashboard` section — its
      3 strings are byte-moves of copy you've already seen on device) against the
      brandkit voice (Steady / Forgiving / Honest), and record the sign-off by
      checking this box. If any string fails your read, note the replacement —
      the next session re-records the affected goldens deliberately (a string
      change is a third billed run; batch it with other copy edits if possible).
- [ ] `panicScript.json` ships since Session 10; **`slipCopy.json` ships since
      Session 12** — every string in the slip flow renders from it. Review both
      files' tone against the brand kit voice.
- [ ] **The ONE new agent-drafted line (Session 12):** `slipCopy.json`
      `confirm.retryNote` — *"That didn't save just yet — nothing's lost. Tap Log
      it to try again whenever you're ready."* Shown only when the durable write
      fails; must stay calm, zero-shame, retryable (`REVIEW.md` item 3).
- [ ] Pre-ship (unchanged): clinician/legal pass on `safetyCopy.json`; verify the
      flagged helplines; TR L10n review (`App/Resources/Content/REVIEW.md`).

## 4. GitHub Actions billing headroom — ~2 min per session

- [ ] Session 15 used **3** billed macOS runs (**1 burned**: a new test file was
      missing an import — TEST BUILD FAILED with no red evidence; the gate that
      closes this class is now standing rule #2 in the resume prompt). Session 16
      (E5.1 age gate) plans **2**. The TelemetryDeck SPM dependency resolved
      cleanly on CI (no extra runs from the new-dependency risk class). Check
      Settings → Billing → spending limit before the session.
- [ ] Optional, would eliminate the burned-run class entirely: a cheap self-hosted
      macOS runner or a pre-push `xcodebuild -quiet build` step.

## 5. TestFlight housekeeping — carried from Sessions 07–09

- [ ] Add internal testers (nobody receives builds until a tester group exists —
      the panic **and slip** flows are now genuinely worth testing).
- [ ] Expire the stray bundle-version-"1" build; answer export compliance only if
      App Store Connect prompts.

## 6. Slack webhook rotation — optional hygiene, ~5 min

- [ ] CI reads `secrets.SLACK_WEBHOOK_URL`; the old URL briefly sat in local git
      history. Rotate when convenient.

## 7. E3.3 manual device matrix — YOUR half of the E3.3 acceptance (~15 min)

The build half shipped Session 13; the acceptance's device matrix is operator-owned
device work. Any post-E3.3 build works; for seeded quits run from Xcode with scheme
env `UITEST_SEED_PANIC_SNAPSHOT=1` (two-quit pre-cache: "Vaping" + one discreet).

- [ ] **Place the surfaces** from the system galleries: the "Streak" lock-screen
      widget (its wind button); the **"Panic"** control in a lock-screen control
      slot AND in Control Center; Settings → Action Button → Controls → "Panic".
- [ ] **Discreet check:** in the controls gallery, confirm the **"Reset"** control
      shows the neutral counterclockwise-arrow glyph and its description ("Opens a
      quick reset.") carries zero habit words; place it once and fire it.
- [ ] **Run the matrix** — each row × Focus ON and OFF; at least one pass in
      airplane mode (Epic 3 DoD: zero network dependency):

      | # | Launch from | Expect | Recorded source |
      |---|---|---|---|
      | 1 | Lock-screen widget button | picker (2 quits) → flow | lockscreenWidget |
      | 2 | Lock-screen control slot | same | controlCenter (see note) |
      | 3 | Control Center "Panic" | same | controlCenter |
      | 4 | Action button | same | controlCenter (see note) |
      | 5 | "Reset" control (any surface) | same | controlCenter (see note) |
      | 6 | In-app "Panic" button on the root | picker sheet | inApp |

- [ ] The attribution VALUES are unit-pinned, so if row-by-row source inspection is
      friction, it is enough to confirm each surface OPENS the flow (Focus on/off,
      airplane ok) — that closes the matrix. To spot-check a recorded source, finish
      one flow arm ("The urge passed") and inspect the persisted UrgeEvent from an
      Xcode run.

> **Platform note (recorded adjustment, not a bug):** iOS provides NO API to tell
> Control Center vs lock-screen slot vs Action button apart — one control
> registration serves all three and YOU assign placement. Rows 2/4/5 recording
> `controlCenter` is correct behavior. `.actionButton` stays reserved in the schema.

## 8. TelemetryDeck app ID — the E8.1 transport ships DORMANT until you provide it (~10 min, whenever)

- [ ] Create the app in the **TelemetryDeck console** (SaaS credentials are
      operator-held by design — agent-workflows §1.3) and paste the app ID into
      `AnalyticsConfiguration.telemetryDeckAppID`
      (`App/Sources/TelemetryDeckSink.swift`). Until then the transport is a Noop
      sink and the SDK is never even initialized — zero bytes leave any build.
      **No urgency**: consent is independently hardwired OFF until E8.2's consent
      screen ships, so this is the second half of a double gate.
- [ ] While creating the app, decide the **salt** (optional `Config(appID:salt:)`
      hardening — 64 random chars; TelemetryDeck says set it once and never change
      it, or distinct-user continuity breaks). Record the decision; wiring it is a
      one-line agent edit.

---

## Decisions on record you can veto (FYI, no action needed)

- **Discreet quits keep VERBATIM motivations in the pre-cache** (labels stay
  stripped) — Session 10 ruling. Veto before E5.2 if you want discreet
  motivations minimized instead.
- **A completed store-route undo DELETES the Slip row** (Session 11, shipped
  Session 12) — an undone slip never counts against Reduce allowance or insights;
  its CloudKit tombstoning is a named §4.3-flip design item.
- **The cold slip flow writes ONLY the outcome buffer** (single-writer pre-cache
  pin, Session 11) — repeat-cold-slip display honesty comes from the in-memory
  draft fold, never a second writer to `panic-snapshot.json`.
- **Redirect menu ships the JSON's 4 options** (ratified override, not drift).
- **E3.3 attribution ceiling (Session 13, recorded adjustment):** control-family
  launches (Control Center / lock-screen slot / Action button) all record
  `.controlCenter` — iOS has no launch-surface API for controls (docs-checked,
  WWDC24 10157). `.actionButton` stays reserved in the schema. Veto path: a new
  dedicated `PanicSource` case for the "Reset" control would need a schema
  decision, not a platform fight.
- **Shortcuts exposure (Session 13):** the lock-screen widget intent ("Panic")
  remains Shortcuts-discoverable (pre-E3.3 behavior); a Shortcuts-run launch
  attributes `.lockscreenWidget` exactly as the old hardcode did. The control
  intent is NOT discoverable (the discreet "Reset" control rides it — a Shortcuts
  row titled "Panic" would leak what it hides).
