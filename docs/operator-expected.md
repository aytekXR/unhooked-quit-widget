# Operator Expected — the live "what only aytek can do" checklist

| Field | Value |
|---|---|
| Status | LIVE — **only OPEN items are listed here** (Session 47, 2026-07-26). The build side is agent-complete and the project is OPERATOR-GATED; everything below is yours. Completed/closed items and the full FYI vetoable-rulings record live in `docs/past-prompts.md` (the append-only ledger). |
| What changed since you last read this (Session 48B) | **Monetization went LIVE and it needed nothing further from you.** The RevenueCat key you pasted is wired; the RC project now carries the App Store app, entitlement `premium`, all three products, an offering, and the **In-App Purchase Key** (the piece that authorizes the signed 50%-off win-back). In App Store Connect the subscription group, all three products, both 3-day trials, the `winback_annual` offer, localizations, review screenshots and prices across **175 territories** are in — **all three products now report READY_TO_SUBMIT**. Two things were fixed on the way: **R46.2** (`EntitlementModel` was never refreshed after purchase/restore or on foreground, so a user who had JUST subscribed kept being offered the half-price win-back), and the **E0.3 harness, which could never have run on a device at all** (a missing test-target bundle id failed the build before any test executed — see §1, which now carries real numbers). **What this unblocks for you: the sandbox purchase matrix**, §8's first checkbox and Epic 7's operator half — it is also the only test that proves the R46.2 fix. Nothing in §0 changed; that decision still gates all agent work. |
| Read first | **`docs/critical-path-post-uir.md`** — the single-page, dependency-ordered launch playbook. **The §3 copy pass is CLOSED** (Session 46B: every copy table read with you end-to-end, ~20 decisions made, 18 string edits + 5 code changes landed, 12 goldens re-recorded, 404 unit / 35 snapshot / 121 free-lane green). The critical path's step 1 is DONE and **the final golden batch is unblocked.** Three findings from it are worth your eye even though they are already fixed: **ALO 182 is a hospital-appointment line, not a crisis line** — §3 had been telling you to mark it verified, which would have shipped a life-safety defect; the **alcohol withdrawal notice was unreachable** for any alcohol user who hit the hard paywall and did not convert; and the paywall's **Terms/Privacy were dead labels** (now real links — but the two pages still need publishing, and that is on you). **The §8 keys are DONE as of Session 48B — monetization is live end-to-end.** The next longest-lead items are now the clinician + counsel sign-off, the two legal pages, and G0 trademark clearance — all three run on someone else's clock, so start them first. The §0 decision at the top remains the only thing blocking agent work. |
| Rule for agents | Update this file at session end alongside `resume-prompt.md`. **Keep it OPEN-items-only** — when an item closes, DELETE it here and record the closure in the `past-prompts.md` ledger; never re-accrete session history, closed-section stubs, or FYI narrative. Section numbers are kept stable (gaps are fine) because other docs cross-reference §3/§7/§8. TRACKED in `docs/` so the operator can read it anywhere. |

---

## 0. ✅ ANSWERED (operator-instructed, external redesign session, 2026-07-26) — the redesign runs BEFORE launch, and waves 1–2 have ALREADY LANDED

**Your answer was (B), given as a direct operator instruction in the external Claude session
("take all the designs live, don't wait for my approval") — and the same session executed it.**
What is now ON `main`, green through every CI lane, and in TestFlight:

- **Wave 1 (build 125, uploaded 02:52):** the Surfaced Breath app icon (light/dark/tinted) + redrawn
  discreet Calendar/Timer alternates; the Erase UI (QW-2 — the App Review promise made real);
  panic in-flow "More support" (QW-10); dashboard panic-entry priority + support line (QW-4);
  summary "Start your streak" CTA + the "Steady beats perfect." footer signature; brandkit
  tokens.json regenerated from Theme.swift (QW-1).
- **Wave 2 (pushed a6376fe, CI running at close):** the widget-adoption moment after the summary with
  `widget_added` FINALLY wired (ME-1 — the north-star metric has a surface and instrumentation);
  Streak Detail rendering the 43-body milestone catalog (first Ember spend); the live wave count-up
  timer on the panic urge step (ME-5); the Home "Today" shell with tappable cards into Streak Detail.

**What this means for the golden batch you were asked about:** the question is superseded, not
pending. Waves 1–2 minted/re-recorded goldens for every surface they changed (24 touched in wave 2
alone, all eyeballed); the remaining batch surfaces (age gate, quiz field, summary payoff ME-4,
paywall ME-9) stay deferred to the redesign's own Phase 3–4 sequencing, exactly as the roadmap wrote
it. Re-scope the final batch AFTER ME-4/ME-8/ME-9 land — the S48 banked scoping still applies, minus
the surfaces waves 1–2 already covered.

**What the redesign program still owes (next agent session):** ME-7 Settings rebuild (canonical
section order + panic-access re-entry rows + the widget-moment "Maybe later" nudge), ME-3 milestone
unlock moments, ME-8 quiz continuous field + interstitials, ME-4 summary payoff, ME-9 paywall polish,
then the final golden batch + LB-5 screenshots.

**NEW operator items this created (add to your §3 reading list):**
- [ ] **Founder copy pass** over the wave-1/2 DRAFT tables (all shipped operator-instructed, every
      `_meta` kept DRAFT): `widgetMomentCopy.json`, `StreakDetailCopy`, `panicSupport` in
      `safetyCopy.json`, the summary `footer`/`cta`, the erase dialog strings, the dashboard
      panic-entry labels, the wave timer's `elapsedLabel`.
- [ ] **Wave 3 / ME-7 adds FIVE strings to that same pass** (Session 50, `DiscreetSettingsCopy`).
      Deliberately small: the S46 copy pass CLOSED this table, so every byte it signed is
      verbatim — including `hapticPacerRowLabel` "Breathe with taps", which §7 below tells you to
      toggle by name. Only what the new IA genuinely required changed:

      | Field | Was | Now | Why it had to move |
      |---|---|---|---|
      | `screenTitle` | "Discreet Mode" | **"Settings"** | the screen IS Settings now; Discreet Mode is one section inside it. This also aligns §7, which already says "Settings → …". |
      | `discreetModeSectionHeader` (was `widgetsHeader`) | "Widgets" | **"Discreet Mode"** | the section carries the feature's own name |
      | `panicAccessSectionHeader` | — | **"Panic access"** | new first section |
      | `widgetAdoptionRowLabel` | — | **"Add the lock-screen widget"** | its one row (re-opens the widget-adoption moment). ⚠️ **ONE WORD DEVIATES FROM YOUR COPY DOC — read the note below** |
      | `privacyDataSectionHeader` | — | **"Privacy & Data"** | new section (hosts erase; consent + "what leaves this device" join it later) |
      | `breathingSectionHeader` | — | **"Breathing"** | new section |

      Three things an agent deliberately did NOT do, so you can overrule any of them:
      **(a)** the per-quit toggle label stays the QUIT's own name (or "Tracked goal" when
      discreet) rather than a shared "Show numbers only" — with up to three quits, one shared
      label renders three indistinguishable switches, and the neutral-identity rule is a privacy
      panel amendment; **(b)** the `eye.slash` glyph was dropped from those toggle rows (the
      section header now carries the meaning); **(c)** no "Your plan" section header was invented
      — that byte is not drafted, so the win-back row sits in an unlabelled card.

      **⚠️ One byte deviates from `redesign/product-copy.md` §11, and Apple forced it.** The doc
      drafts the panic-access row as **"Add the lock-screen button"**. That fails Apple's
      accessibility audit — *"Label duplicates traits"* — because the row IS a button, so a label
      containing the word "button" restates its own trait. It is a real CI failure, not a warning
      (it reddened run `30220337353`). The word was clearly meant to name the WIDGET's panic
      button, a different object, but the check is a machine one and it gates every merge. The
      shipped byte changes exactly one word: **"Add the lock-screen widget"** — which is arguably
      the truer noun anyway, since what you add is the widget and the widget is what carries the
      button. **The rejected shortcut is worth knowing:** the bytes could have been kept by
      overriding the VoiceOver label instead, and that was refused — it would break WCAG 2.5.3
      (Label in Name), so a Voice Control user saying "tap Add the lock-screen button" would no
      longer match the control. Trading a real accessibility property for a green check is not a
      trade this project makes. **If you want different bytes, any wording without a control-type
      noun works** ("button", "image", "icon", "switch", "toggle"); a unit test now states this in
      one line if a future edit reintroduces one, so nobody rediscovers it from a red UI lane.
- [ ] **Safety-content panel sign-off** on the panic in-flow support PLACEMENT (the strings are
      lexicon-clean and the affordance only adds a path to help, but §_meta says the panel signs
      placement before ship).
- [ ] **Eyeball builds 125 + the wave-2 build on your device** — the operator half of accepting the
      redesign (the session verified simulator goldens + CI; your thumb on the real widget flow is
      the missing evidence).
- [ ] **Glance at the rebuilt Settings screen (~2 min, wave 3 / ME-7).** It looks different on
      purpose: the system `List` is gone, replaced by a scrolling column of themed cards, and the
      title moved out of the navigation bar into the content. That change is what finally retires
      the parked AX5 accessibility defect (see the note below), so the visual delta is the fix, not
      a side effect. Four goldens were eyeballed before adoption, including both at the largest
      accessibility size — but goldens cannot tell you whether it FEELS like a settings screen.
      While you are there, tap **Panic access → "Add the lock-screen button"** and confirm it
      re-opens the widget-adoption moment.

## 1. E0.3 panic-latency — PARTLY MEASURED (S48). What is left is one 15-minute pass.

> **The harness could never have run.** `UnhookedUITests` carried no
> `PRODUCT_BUNDLE_IDENTIFIER`; simulator lanes (all of CI) do not need one, so a device run
> failed the BUILD before a single test executed. Fixed in S48 — so this item was carried as
> "the operator hasn't measured it" when it was closer to "it could not be measured."

**What S48 measured (real numbers, iPhone 17 Pro Max / iOS 27, Debug):**

| | p90 |
|---|---|
| panic arm | 2483 ms |
| control arm (same harness, panic route OFF) | 2379 ms |
| **⇒ panic route's app-owned cost** | **≈ 104 ms** |

The raw 2483 looked like a failure and is not one: ~2.36 s of it is XCTest's own
automation-attach/quiescence handshake, present identically on a launch that does no panic
work. **The app-owned panic cost is ~0.1 s.**

**What is still unmeasured, and only you can do it:** total lock-to-intervention — finger
down on the lock-screen widget to a breathing screen. That span also contains the OS's
intent→process-spawn phase (architecture §11 budgets ~500–800 ms), which no in-app
instrument sees. Everything points to comfortably under 2 s, but that is an inference, not
the 10/10 evidence MVP §7 asks for.

- [ ] **The 15-minute pass (tooling is ready).** `ffmpeg` is installed and
      `measure_panic.py` (in the S48 session scratch, re-creatable in a minute) parses a
      screen recording frame-by-frame and prints every attempt's span plus p90 against both
      bars. Procedure: start iOS screen recording → lock → wait ~10 s → tap the lock-screen
      panic button → let the breath screen settle → **swipe the app away in the app switcher**
      (otherwise attempts 2-10 are warm, not cold) → repeat ×10 → AirDrop the video to the Mac.
- [ ] With the numbers, settle the wording drift: MVP §7 "<2 s, 10/10" vs test-suite §1.5
      "p90 < 2.0 s" (one-line edit to the losing doc). This also decides whether "<2s" can be
      marketing copy or degrades to "fast". **Until then the copy stays "fast".**
- [ ] **⚠️ BINDING for E3.1 (recorded in `spike-panic-latency.md`):** the plan graduates this
      test into a permanent CI gate **on its raw p90**. It must not — that pins XCTest's
      overhead, not the product, and fails at 2000 ms today for reasons unrelated to the app.
      Gate on the delta (the control now ships beside it) or on the `PanicColdLaunch` signpost.
- [ ] Optional, while on the device (~5 min): feel-pass the 4-7-8 haptic rhythm in the real
      panic flow.

## 2. Try E4.1/the funnel on your device (your ask, Session 12) — ~10 min

- [ ] **From Xcode (Mac26 + iOS26 device):** open the project, add scheme Run env vars
      `FORCE_PANIC_ROUTE=1` + `UITEST_SEED_PANIC_SNAPSHOT=1`, run on device. Expect: the seeded
      two-quit picker → the real ~90s panic flow (4-7-8 breath bloom + haptics, urge timer, your
      seeded motivations verbatim, redirect menu) → exit → **"I slipped" → the two-tap slip flow**
      → the forgiveness screen (best/momentum framing + the calm neutral undo banner) → Undo within
      10 min → "Undone. Your streak is right where it was."
- [ ] A plain TestFlight launch shows the **age gate first**; a passing year lands on **the quiz**
      (11–13 screens: 11 always-shown + 2 conditional — the custom-habit name step and the
      reduce-goal weekly-limit step). Answering creates a real quit with your motivations verbatim,
      then the **personalized summary** (projected yearly savings / calm non-monetary reframe; likely
      hard window; your motivation words) → Continue → dashboard. Enter e.g. 2012 to see the blocked
      resources surface (988 on a US device; "Go back" recovers). **The quiz + summary copy is FINAL as of
      Session 46** — this is now a confirm-what-you-signed pass, not a draft review.

## 3. Content sign-offs — what is LEFT after the Session 46 copy pass

> **The copy pass itself is CLOSED.** Every DRAFT copy table was read end-to-end with you
> in Session 46, every open copy decision was made, and the edits are landed and green.
> The full decision record is in `docs/past-prompts.md`. What remains below is only the
> work that leaves this repo — external sign-off, published legal pages, and two
> verifications against outside sources.

- [ ] **Clinician + counsel sign-off — the safety-content SHIP GATE.** The words are now
      FINAL pending their pass; nothing else blocks them. Send these three together:
      (a) `App/Resources/Content/safetyCopy.json` — its `_meta` still reads "DRAFT — needs
      clinician + counsel sign-off" and that line is what clears on their approval. Note
      one S46 change to draw their eye to: the alcohol notice body now says "the safest way
      **forward**" (was "the safest way to **cut down**"). The old phrasing implied gradual
      self-tapering is the safe route, which is directional medical advice and is not true
      for every heavy drinker — both stopping and tapering can require supervision. The same
      fix landed in the degraded fallback (`SafetyResourcesCopy.swift`).
      (b) the PANIC-PATH breath instruction in `panicScript.json` — "Breathe with the taps.
      In for 4, hold for 7, out for 8. Three rounds." (what VoiceOver speaks in haptics-only
      mode). It names no technique and makes no claim; if the clinician wants the counts
      de-emphasized, that is a one-line edit with no golden impact.
      (c) `docs/review-notes.md` — read top to bottom; its factual claims were re-verified
      against source in S46 and three inaccurate ones were corrected.
- [ ] **Publish the two legal pages — NOW A HARD DEPENDENCY (~30 min + your counsel's text).**
      S46 wired the paywall's Terms of Use / Privacy Policy from dead labels into real
      tappable links pointing at **`https://beyondkaira.com/terms`** and
      **`https://beyondkaira.com/privacy`** (constants in `Shared/Sources/AppIdentifiers.swift`
      — change them there if you host elsewhere). Apple Schedule 2 requires the links to
      WORK; a reviewer tapping through to a 404 is a rejection, so the pages must be live
      before submission. The privacy policy is also where the sensitive-class habit-category
      disclosure lives (see `docs/app-privacy-label.md`).
- [ ] **YEDAM 115 operating hours (~5 min, `helplines.json`).** The row ships with
      `hoursVerified: false` and the honest placeholder "Bilinmiyor — yayına almadan
      doğrulayın". Confirm the real hours on yedam.org.tr and replace the string.
- [ ] **US SAMHSA row — re-verify before submission (~5 min).** The 1-800-662-4357 number is
      currently answering, but SAMHSA is mid-restructuring (proposed FY2026 cuts, absorption
      into a new agency). Re-check it close to submission; a dead number on a resources
      screen is the worst class of defect this app can ship.
- [ ] **The two generated app icons** — `AppIconCalendar` + `AppIconTimer` (built to brandkit
      §4.3). Look at them on a device home screen (§7 row). Veto/replace freely; the generator
      (`brandkit/branding-assets/generate-alt-icons.py`) is deterministic and no golden pins
      icon pixels.

**Two small copy calls S46 surfaced but did NOT decide (both one-line agent edits once you say):**

- [ ] **Control Center / Shortcuts intent wording.** You approved changing the widget's
      VoiceOver label from "Panic — opens a full-screen reset" to "Panic — opens a
      90-second urge exercise" (geometry → function). The SAME "full-screen reset" wording
      still ships in three iOS system-UI strings: `OpenPanicIntent.swift:15`,
      `OpenPanicControlIntent.swift:15`, and `PanicControlStyle.swift:35`. These render in
      the controls gallery and Shortcuts. Left alone deliberately because your §7 device
      matrix checks those exact strings and changing system-surface text mid-matrix is your
      call. Align them or keep them.
- [ ] **Slip encouragement rotation.** `slipCopy.json` carries three encouragement lines but
      `SlipFlowView.swift:215` renders only `.first`, so lines 2 and 3 have never been seen by
      any user (line 2 is the one you reworded away from "clean days" in S46). Either activate
      rotation — one line, `copy.encouragement[slipCount % copy.encouragement.count]` — so a
      repeat user gets fresh framing, or delete the two dead strings.

## 5. TestFlight housekeeping — carried from Sessions 07–09; NOW TIMELY

> **Read `docs/testflight-beta-kit.md` §0 before you invite anyone (~5 min).** It is the pre-flight for the
> initial sitting: what a tester actually meets, what to put in the invite, and the paste-ready ASC fields.
> Step-by-step ASC mechanics stay in `docs/testflight-tester-guide.md` (internal group setup, external
> groups/public link).

- [ ] **⚠️ Brief testers about the close-free paywall, or the sitting stalls there (S52/O52.1, the one that matters).**
      RevenueCat going live in 48B flipped the summary CTA: every non-entitled user now routes into the paywall
      (`PostGateRootView.swift:412`), and with Superwall still dormant the variant is always the **hard** arm
      (`PaywallVariant.swift:47`) — **no close button.** Nobody is permanently stuck (force-quit → relaunch lands on
      the dashboard, `PaywallRouting.swift:55`), and in TestFlight the purchase is **free** (sandbox), so the intended
      path works and doubles as your §8 sandbox evidence. But a tester who is not told will refuse the purchase sheet
      and report "the app won't let me in". Beta-kit §2 and §4.1 are written to prevent exactly that. **Two notes:**
      a non-purchaser silently skips the ME-1 widget-adoption moment (the north-star metric's only surface) — the
      script routes them back via Settings → Panic access instead; and if testers do stall, that is the argument for
      pasting the Superwall key and assigning the teaser arm (§8), which is already the decided posture for the
      *review* build.
- [ ] **Know what TestFlight does to subscriptions before a tester reports it as a bug (S52).** Verified against
      Apple's own page: in TestFlight **every** subscription duration renews once per **24 hours** — a 1-year plan
      renews daily just like a 1-week plan — up to **6 renewals**, after which auto-renewal is disabled. (This is
      NOT the minute-scale compression the Sandbox environment uses; do not brief the sandbox numbers.) So a tester
      who subscribes on day 1 lapses around day 7 — which is the **only free way to watch a real lapse**, i.e. the
      one test that proves the R46.2 foreground-refresh fix. Ask a week-one tester to reopen the app around day 7:
      correct is the dashboard or a *dismissible* win-back offer, never a wall.
- [ ] **Check the OS floor before spending an invite (~1 min).** Minimum is **iOS 26.0** (`project.yml`). Older
      devices are not offered the build at all, which reads as a broken invite. Relevant to recruiting the ≥15
      external testers the beta gate wants.
- [ ] **Do NOT enable the TestFlight public link yet.** The build wears "Ballast" and G0 trademark/name clearance is
      still open (critical path step 7); a public link is an indexable public exposure of an uncleared name.
      Email-invited external testers are fine.
- [ ] **Decide beta-tester GEOGRAPHY before you recruit (S47/O47.1, ~2 min).** Verified helpline rows exist for
      **US and TR only**. Every other region resolves to the GLOBAL bucket, which by your own number-free ruling
      shows text guidance ("…call your local emergency number… visit findahelpline.com") and **no tappable
      number**; a blocked under-17 tester outside US/TR falls back to the US 988 line they cannot dial. S47 probed
      every fallback path and they all behave correctly — this is design working as intended, not a bug, and an
      agent may never author a helpline row (official-source verification is yours; S46's ALO 182 finding is
      exactly why). But if you recruit your ≥15 external testers outside US/TR, that is what they will see. Either
      weight recruiting to US/TR, or add officially-sourced rows for the regions you recruit from — the render
      path is already proven, so adding a row is data-only.
- [ ] **Add internal testers** (nobody receives builds until a tester group exists). Now maximally timely — the
      newest build completes the M1 loop end-to-end (install → gate → quiz incl. the consent step → the summary
      payoff → a real quit whose panic flow speaks the tester's own motivations). Follow Part 1 of the guide.
- [ ] **Expire the stray bundle-version-"1" build;** answer export compliance only if ASC prompts (guide Part 3 has
      the exact answers — note `ITSAppUsesNonExemptEncryption=false` is already set, so this should not be asked).
- [ ] **Re-add the widget once.** SkeletonWidget was retired for the real "Streak" widget (new kind — a placed
      placeholder disappears). Long-press → add "Streak"; the rectangular size carries the panic button. Any tester
      who had the old placeholder placed must re-add too (one-time).

## 6. Slack webhook rotation — optional hygiene, ~5 min

- [ ] CI reads `secrets.SLACK_WEBHOOK_URL`; the old URL briefly sat in local git history. Rotate when convenient.

## 7. Physical device matrix (E3.3 + the carried device rows) — YOUR half of acceptance

> **Recommended: do everything here as ONE consolidated sitting (~1 hour) on today's build** — it clears the
> E3.3 matrix + the widget/discreet rows + §2's funnel try + the E0.3 measurement (§1 has the procedure and
> the tooling is installed) + the eyeball checks below. **The SECOND sitting no longer waits on anything:**
> the §8 keys are all in, so the sandbox purchase matrix is live work (see §8 for where the first attempt
> got to). The payload audit still waits on the TelemetryDeck app ID. For seeded quits, run from Xcode with scheme env `UITEST_SEED_PANIC_SNAPSHOT=1`.

**The eyeball checks (each a screenshot can't verify):**

- [ ] **Eyes-free / VoiceOver (~2 min):** Settings → toggle **"Breathe with taps"** ON → lock → hit the
      lock-screen panic button → the breath step shows the hand-tap glyph + "Breathe with the taps…" instead of
      the circle, and the 4-7-8 rhythm arrives as TAPS you can follow with eyes shut (the haptic feel is yours to
      judge). Toggle OFF → the visual bloom returns. With VoiceOver on, swipe one quiz step + the panic steps + a
      slip log — every control announces a sensible name (the slider says its WORDS; the icon picker says which is
      selected).
- [ ] **Safety layer (~2 min):** Settings → "Support & resources" → your region's verified lines (US: 988 first,
      then SAMHSA/quitline/NAMI; TR: 112 + 171 + 115 — **182 is gone for good, and that is correct**: S46 established
      against the Ministry of Health's own page that ALO 182 is the MHRS hospital-APPOINTMENT line, not a
      crisis line, so its row stays permanently `verified: false` and can never render); tap a
      number row and confirm the dial sheet shows the number verbatim. Log a slip → the forgiveness screen carries
      the same link. With an alcohol quit (or a reduce goal for one), the amber "One thing worth knowing" card
      appears ONCE — "Got it" dismisses forever, "See resources" opens the same screen.
- [ ] **Streak-ring motion glance (~1 min):** open the dashboard, confirm the **momentum ring** smoothly fills in
      (~0.6s ease-out) on first render. CI goldens capture only the settled ring, so this is device-only QA. With
      Reduce Motion on, the ring should simply appear already-filled (also correct).
- [ ] **Your day-counter report — re-verify (~2 min):** the "lock-screen day counter not working" report was
      triaged as **not a code bug** — the 2026-07-10 binary predated the real widget (it only had the hardcoded
      "Day 0" placeholder). Steps: (1) update to the newest build; (2) remove the dead widget and re-add "Streak";
      (3) open the app once (the launch refresh writes the widget feed). **If it STILL fails**, record: the build
      number, what the widget shows, whether the in-app dashboard shows the right Day N, and whether logging any
      event updates the widget within ~60s — that makes it a real device bug the next session can hunt.

**The E3.3 matrix (any post-E3.3 build works):**

- [ ] **Place the surfaces** from the system galleries: the "Streak" lock-screen widget (its wind button); the
      **"Panic"** control in a lock-screen control slot AND in Control Center; Settings → Action Button → Controls
      → "Panic".
- [ ] **Discreet check:** in the controls gallery, confirm the **"Reset"** control shows the neutral
      counterclockwise-arrow glyph and its description ("Opens a quick reset.") carries zero habit words; place it
      once and fire it.
- [ ] **Run the matrix** — each row × Focus ON and OFF; at least one pass in airplane mode (Epic 3 DoD: zero
      network dependency):

      | # | Launch from | Expect |
      |---|---|---|
      | 1 | Lock-screen widget button | picker (2 quits) → flow |
      | 2 | Lock-screen control slot | same |
      | 3 | Control Center "Panic" | same |
      | 4 | Action button | same |
      | 5 | "Reset" control (any surface) | same |
      | 6 | In-app "Panic" button on the root | picker sheet |

      Attribution values are unit-pinned, so it's enough to confirm each surface OPENS the flow. (Platform note: iOS
      provides no API to tell Control Center vs lock-screen slot vs Action button apart — one registration serves
      all three and you assign placement; rows 2/4/5 recording `controlCenter` is correct.)
- [ ] **Widget rows (~15 min):** (a) **Tinted mode** — set a tinted home screen, add systemSmall/Medium "Streak",
      confirm legibility (device-only; tinted homes can't be host-snapshotted). (b) **Day-ring mid-fill** — the
      circular family's ring fills across your local day. (c) **Freshness** — log an urge/slip, confirm the widget
      updates within ~60s. (d) **Selector binding** — with 2+ quits, long-press → Edit Widget → pick a quit;
      archive/erase it and confirm the widget shows "Ready when you are." (never another habit's streak).
- [ ] **Discreet + icons + shield rows (~10 min):** (a) **Discreet toggle** — Settings sheet → toggle a quit
      discreet → the lock-screen rectangular widget shows "Day N" + the counterclockwise-arrow button ONLY (no
      money); VoiceOver says "Reset". (b) **Alternate icons** — pick "Calendar style", confirm the home-screen icon
      swaps (iOS shows its own alert) and the app NAME still reads "Ballast"; this also verifies the actool wiring
      (a misspelled build setting fails silently — only a device proves it). (c) **The shield** — with a discreet
      quit, background the app → the switcher card is BLANK (also try with the panic sheet open); with no discreet
      quit, the card shows content. (d) **Erase** — with an alternate icon set, one-tap erase reverts to the
      primary icon.

## 8. §8 keys + config — RevenueCat is LIVE (S48). What is left.

> **DONE in S48, do not redo:** the RevenueCat public SDK key is in the app; the RC project
> carries the App Store app, entitlement `premium`, all three products attached to it, and an
> offering (monthly + control annual — `annual.hi` deliberately excluded, it reaches users only
> through the Superwall B arm); the **In-App Purchase Key is uploaded** (`subscription_key_configured: true`),
> which is what authorizes the signed 50%-off win-back purchase. In ASC: the subscription group,
> all three products at $6.99/$29.99/$39.99, 3-day trials on both annual arms, the
> `winback_annual` promotional offer, localizations, review screenshots, and prices across all
> **175 territories** — all three products report **READY_TO_SUBMIT**. The R46.2 entitlement-refresh
> defect was fixed in the same run. Full record in `past-prompts.md` (Session 48B).

- [ ] **FREE, DO IT NOW (~2 min) — confirm no ITMS-91053 email ever arrived (S47/O47.3).** S47 checked both
      `PrivacyInfo.xcprivacy` manifests against the app's actual Required-Reason-API usage and concluded **no
      change is needed** — but that rests on Apple's published System-Boot-Time list naming `systemUptime` and
      **`mach_absolute_time()`**, while `LiveClock.swift:36` deliberately uses **`mach_continuous_time()`** (chosen
      because it keeps counting across device sleep) plus a `kern.bootsessionuuid` sysctl. Neither is named in
      Apple's list, so nothing was declared — and declaring a category you do NOT need is itself a rejection
      (ITMS-91055 "Invalid API reason declaration"), so an agent must not add one speculatively. **You already hold
      the definitive evidence:** App Store Connect emails an **ITMS-91053 "Missing API declaration"** warning after
      it processes a build, and this exact manifest + clock code has been through processing on every green-main
      TestFlight upload. Search your ASC/developer email for **"ITMS-9105"**. Nothing there ⇒ closed permanently,
      delete this line. If a warning IS there, paste it and an agent lands the named category + reason code in one
      run (a two-line XML edit plus its `PrivacyManifestTests` pin).
> **✅ S48B closed two things you asked for, both landed and green.**
> **(1) The paywall now shows the STOREFRONT's price.** It used to bind the hardcoded `"$6.99"`/`"$29.99"`
> with no live path at all — you caught it on the device, seeing $29.99 on the paywall while Apple's sheet
> showed the real local price; with all 175 territories priced that was 174 of them shown a price they
> would not be charged (a trust problem, and a 3.1.2 exposure since the post-trial disclosure line carried
> it too). The live path now binds Apple's own `localizedPriceString`, and fails SOFT per field — a slow or
> unreachable store degrades to the old constants rather than blocking the wall, which is also why dormant
> and offline builds are unchanged. Two new tests pin it.
> **(2) Purchase failures now say WHY.** All five failure arms in `RevenueCatEntitlementSource` used to
> `return .failed` with no trace, which is exactly why the sandbox attempt cost an hour. They now log the
> distinguishing fact to `os_log` (subsystem `com.beyondkaira.ballast`, category `Purchase`): the missing
> SKU and which offering was current, or the RevenueCat error code — e.g. 23 `configurationError` means
> "none of the products could be fetched from App Store Connect", which is what an unpropagated catalog
> produces. Release-safe and habit-word-free, so a shipped purchase failure is diagnosable too.

- [ ] **THE SANDBOX PURCHASE MATRIX — now unblocked, and it is Epic 7's operator half.** ASC →
      Users and Access → **Sandbox** → create a test account; on the device Settings → Developer
      → **Sandbox Apple Account** → sign in. Then run: trial start · trial→paid · monthly ·
      restore · reinstall · cancellation · **the on-update regression** (the Quittr-scandal row:
      an existing subscriber must not lose entitlement across an app update). This is also **the
      only test that proves the S48 R46.2 fix** — after a sandbox purchase the win-back settings
      row must disappear immediately, without a relaunch.
      **WHERE THE FIRST ATTEMPT GOT TO (S48B — read this before you retry, it will save you an hour):**
      the sandbox account signs in fine and Apple's purchase sheet OPENS and shows the correct USD price,
      so StoreKit resolves the products and the account is right. The purchase then fails with the app's
      generic banner. A 4-agent diagnosis ruled out, against source: an active StoreKit config in the
      scheme, bundle-id or SKU mismatch, the win-back path being taken by mistake, observer mode, and
      entitlement/signing causes. The most likely remaining cause is **Apple-side propagation** — the
      products were created ~1 h before the test, and RevenueCat's API still reports
      `duration: null` on all three (RC populates that field from Apple's product metadata, and RC's own
      template products in the same project carry `duration: "P1M"`), which is the fingerprint of Apple
      not yet serving them. Retry ~24 h after creation. **Second, unrelated cause worth eliminating
      first because it is a one-click check:** in the RevenueCat dashboard confirm the `default` offering
      carries the **Current** badge (the API reported `is_current: true` in S48B, so this is very likely
      already fine).
      **✅ The error is now readable (S48B).** Retry, then read it with Console.app: connect the phone,
      select it in the sidebar, filter the subsystem to `com.beyondkaira.ballast` and look for category
      `Purchase`. You will get either the missing SKU plus which offering was current, or the RevenueCat
      error code. No `sudo`, no log-collect, no rebuild.
- [ ] **Open `App/Resources/Ballast.storekit` in Xcode 26 once (~5 min, any Mac sitting):** it was hand-authored
      on Linux against Apple's documented structure; a one-time open-and-save validates/normalizes it (and the
      `adHocOffers` win-back entry). Same sitting: run with launch env `UITEST_PAYWALL=1` to eyeball the paywall.
- [ ] **Superwall key:** create the app in the Superwall dashboard and paste the public API key
      into `App/Sources/Monetization/SuperwallConfiguration.swift` (`superwallAPIKey`). Until then every build shows
      the bundled hard-wall control paywall.
- [ ] **Superwall dashboard config (with the key):** two placements — **`quiz_completed`** and **`winback`**; the
      teaser-vs-hard experiment (teaser = escape allowed; hard = no close); the $29.99-vs-$39.99 price experiment
      binding `….annual` (control) vs `….annual.hi` (B arm); then hand an agent the variant ids to fill
      `SuperwallPlacement.variantMapping` (opaque dashboard ids → `teaser`/`hard`; unmapped ids safely render the
      hard control). **Also assign the review build to the TEASER arm** — that is what makes the S46-ratified
      3.1.2 posture true; it is a dashboard setting, not code. For the App Privacy label: SuperwallKit's manifest
      declares Purchase History + a FileTimestamp reason and pulls a checksummed Rust binary
      (`libcel.xcframework`) — recorded so review surprises no one.
- [ ] **TelemetryDeck app ID (~10 min)** — create the app in the TelemetryDeck console and paste the app ID into
      `App/Sources/TelemetryDeckSink.swift` (`telemetryDeckAppID`). Until then the transport is a Noop sink (zero
      bytes leave any build). This is now the ONLY analytics gate (the consent step already shipped); the moment a
      build carries it, opted-in users' funnel events flow and decliners still transmit nothing. While creating the
      app, decide the optional **salt** (`Config(appID:salt:)` — 64 chars, set once and never change it, or
      distinct-user continuity breaks); record the decision (wiring it is a one-line agent edit).
- [ ] **RevenueCat privacy toggle (~1 min, do it while you are in there):** Project settings →
      privacy → switch **device-identifier collection OFF**. The App Privacy label declares NO
      Identifiers row, so leaving it on would make that declaration false.
- [ ] **Payload / MITM audit (~30 min, after the app ID ships in a TestFlight build):** run `docs/payload-audit.md`
      — your operator-only release gate (mitmproxy + the §4 procedure; expect the real wire values, e.g. the
      cold-start bucket sends `under_1s`/`1s_to_2s`/`over_2s`). Archive per its §6
      (`docs/audits/payload-audit-<build>.md`) — that archive IS the Epic 8 DoD's operator half and the evidence
      base for the App Privacy label. The zero-before-consent half is verifiable on today's build too.
- [ ] **App Privacy label entry (~15 min at submission time)** — `docs/app-privacy-label.md` is the ready-to-enter
      row set: THREE collected rows (Usage Data › Product Interaction; the habit CATEGORY; Purchases ›
      Purchase History — RC is live now, so this row APPLIES), all Not-linked / Not-tracking, NO Identifiers row.
      **OQ-2 — RATIFIED Session 46:** the habit CATEGORY is declared as **Health & Fitness › Health**. Rationale and
      the two rejected alternatives are in `docs/app-privacy-label.md`. Counsel may still veto; if they do, the
      manifest + its key-set pin move in the same session (LOCKSTEP).
