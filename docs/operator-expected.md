# Operator Expected — the live "what only aytek can do" checklist

| Field | Value |
|---|---|
| Status | LIVE — **only OPEN items are listed here.** Pruned to open-items-only in Session 52 (2026-07-27): 11 blocks of session narrative removed, all 45 open actions kept. Closed items and the full decision record live in `docs/past-prompts.md` (the append-only ledger). |
| Read first | **`docs/critical-path-post-uir.md`** — the single-page, dependency-ordered launch playbook; it sequences this file. For the beta: **`docs/testflight-beta-kit.md`**. |
| Rule for agents | Update this file at session end alongside `resume-prompt.md`. **Keep it OPEN-items-only** — when an item closes, DELETE it here and record the closure in the `past-prompts.md` ledger; never re-accrete session history, closed-section stubs, or FYI narrative. Section numbers are kept stable (gaps are fine) because other docs cross-reference §3/§7/§8. TRACKED in `docs/` so the operator can read it anywhere. |

---

## 0. Redesign acceptance — your half

> The §0 decision is answered: **(B), the redesign runs before launch**, given as a standing
> instruction. It gates nothing now. What is left below is your acceptance of what shipped.

- [ ] **Founder copy pass** over the wave-1/2 DRAFT tables (all shipped operator-instructed, every
      `_meta` kept DRAFT): `widgetMomentCopy.json`, `StreakDetailCopy`, `panicSupport` in
      `safetyCopy.json`, the summary `footer`/`cta`, the erase dialog strings, the dashboard
      panic-entry labels, the wave timer's `elapsedLabel`.
- [ ] **ME-7 adds FIVE strings to that same pass** (`DiscreetSettingsCopy`).
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
- [ ] **ME-8 adds NO new strings** — the Waterline field, the keyboard-step echo and the slider
      detents are all visual. Nothing joins your copy pass from this wave.
      **But two ME-8 judgments are yours, because no CI gate can make them:**
      **(a) Does the field READ?** The quiz now has a horizon behind it that advances as you answer
      (teal-over-indigo bands, a luminous waterline, one soft bloom that surfaces as you go). It ships
      at **6% opacity**, not the 12% the creative doc specifies — and that is not timidity, it is
      arithmetic: compositing the field over `surface/base` and re-measuring every text token puts
      dark-mode `content/tertiary` at **2.63:1 against its 3.0 WCAG floor** at 12%. The hard ceiling
      is now 8%, with 6% the default. **If it reads as invisible on your device, say so** — the honest
      fix is a bolder MOTIF (a taller water band, a stronger waterline), never a bolder opacity,
      because the opacity is what keeps the text legible. Worth checking in **both appearances and
      outdoors**, where a 6% tint can vanish entirely.
      **(b) The slider detents.** "How ready do you feel?" now snaps to four stops with a haptic tick
      on each, one per word. Judge the feel: too sticky, too loose, or right.
      One known-cosmetic item while you are there: the field's advance between steps may read as a
      soft drift or as a clean cut, depending on how SwiftUI treats the layer. Either is acceptable
      and the settled picture is identical; if the cut looks abrupt to you, that is worth reporting.
- [ ] **ME-4 adds NO new strings either** — the summary redesign touches no founder-owned byte, so
      there is nothing here for your copy pass. **But one decision is genuinely yours, because it
      needs copy AND a product call, and an agent may make neither.**

      **Your UX blueprint §6.5 asks the risk window to become "a 24-hour horizontal band with the
      user's likely hard window (e.g. evenings) rendered as a deeper indigo segment". It shipped as
      a designed sunken well with an indigo marker instead — emphasis, not a scale.** Two reasons,
      either sufficient on its own:

      1. **Four of your six trigger tokens have no clock meaning.** The shipped phrases for
         `social` / `alone` / `boredom` / `stress` are "around social plans", "in quiet moments
         alone", "when things get idle" and "when stress spikes". Shading an hour of a 24-hour axis
         for those users asserts a time-of-day finding the derivation never made — which `mvp.md`
         §7 forbids outright ("no fabricated statistics") and which `SummaryDerivation`'s own
         contract already refuses ("insufficient data shows nothing, not guesses"). And there is no
         range to source even for "evenings": `quizConfig.json` carries
         `{"id":"evenings","label":"Evenings"}` — a label, no hours. An 18:00–23:00 bracket would be
         invented precision on a screen whose copy you deliberately hedged to "likely".
      2. **There is no copy for it.** Your copy deck §4 lists the six window lines as "Keep. Same
         six" and drafts no axis labels. A clock needs them, and copy is yours.

      **If you want the arc, it needs exactly two things from you** — the axis labels as DRAFT
      strings for `summaryCopy.json`, and a decision on what the four non-temporal tokens should
      render (no band at all, or something else). It is a small self-contained follow-up, tracked as
      **ME-4b** on the design roadmap. If you would rather not, say so and ME-4b closes: the
      sunken-well treatment is then the final answer.

      **While you are on that screen, two things only your eye can settle** — and the first comes
      with a caveat an agent should state rather than let you discover:

      **(a) The field is mostly HIDDEN on this screen, by design, and that is worth a look.** §6.5
      puts a full-bleed Waterline field behind a full-width card — so the card occludes most of it
      and what actually reaches you is a tint in the side margins plus the area below the card. In
      the recorded goldens the crest reads as a faint arc at the card's left and right edges; it is
      clearer in dark mode than in light. That is the honest picture at the measured-safe 6%. **If
      it reads as nothing at all on your device, the fix is a bolder MOTIF — a taller water band, a
      stronger waterline — never a bolder opacity**, because the opacity is what keeps the text
      legible (and on THIS screen the ceiling is tighter than the quiz's: 0.0695 vs 0.0934).

      **(b) Does the number read as the hero?** The savings figure is now Moss green with the
      luminous horizon rule beneath it and 32pt of clearspace bracketing the stage. That is the
      whole of §6.5's "drama recovered through composition, colour and the motif, never point
      sizes", so it either works or the composition needs another pass.

      One cosmetic item disclosed rather than quietly shipped: in the **zero-spend** variant (no
      money block) the horizon rule has no caption beneath it, so there is a visibly airier gap
      before the risk-window well than in the money variant. It reads as generous whitespace rather
      than a broken layout and the card still ends at a comparable height, so it was not worth a
      billed run to tighten — but if it looks wrong to you, say so and it rides the next pass.
- [ ] **Safety-content panel sign-off** on the panic in-flow support PLACEMENT (the strings are
      lexicon-clean and the affordance only adds a path to help, but §_meta says the panel signs
      placement before ship).
- [ ] **Eyeball the current TestFlight build on your device** — the operator half of accepting the
      redesign (agents verified simulator goldens + CI; your thumb on the real widget flow is the
      missing evidence). Always take the newest build: CI uploads one per green `main`, so the
      build number moves constantly and no specific number is worth chasing.
- [ ] **Glance at the rebuilt Settings screen (~2 min).** It looks different on
      purpose: the system `List` is gone, replaced by a scrolling column of themed cards, and the
      title moved out of the navigation bar into the content. That change is what retires
      the parked AX5 accessibility defect, so the visual delta is the fix, not
      a side effect. Four goldens were eyeballed before adoption, including both at the largest
      accessibility size — but goldens cannot tell you whether it FEELS like a settings screen.
      While you are there, tap **Panic access → "Add the lock-screen widget"** and confirm it
      re-opens the widget-adoption moment.

## 1. E0.3 panic-latency — one 15-minute pass is what is left

The app-owned panic cost is **~104 ms**, measured on device (2483 ms panic arm vs 2379 ms control;
the raw figure is XCTest's own attach/quiescence handshake, not the product). **What is still
unmeasured, and only you can measure it: total lock-to-intervention** — finger down on the
lock-screen widget to a breathing screen. That span also contains the OS's intent→process-spawn
phase (architecture §11 budgets ~500–800 ms), which no in-app instrument sees. Everything points to
comfortably under 2 s, but that is an inference, not the 10/10 evidence MVP §7 asks for.

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

## 2. Try E4.1/the funnel on your device — ~10 min

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
      resources surface (988 on a US device; "Go back" recovers). **The quiz + summary copy is FINAL** —
      this is a confirm-what-you-signed pass, not a draft review.

## 3. Content sign-offs — the work that leaves this repo

- [ ] **Clinician + counsel sign-off — the safety-content SHIP GATE.** The words are
      FINAL pending their pass; nothing else blocks them. Send these three together:
      (a) `App/Resources/Content/safetyCopy.json` — its `_meta` still reads "DRAFT — needs
      clinician + counsel sign-off" and that line is what clears on their approval. Note
      one change to draw their eye to: the alcohol notice body now says "the safest way
      **forward**" (was "the safest way to **cut down**"). The old phrasing implied gradual
      self-tapering is the safe route, which is directional medical advice and is not true
      for every heavy drinker — both stopping and tapering can require supervision. The same
      fix landed in the degraded fallback (`SafetyResourcesCopy.swift`).
      (b) the PANIC-PATH breath instruction in `panicScript.json` — "Breathe with the taps.
      In for 4, hold for 7, out for 8. Three rounds." (what VoiceOver speaks in haptics-only
      mode). It names no technique and makes no claim; if the clinician wants the counts
      de-emphasized, that is a one-line edit with no golden impact.
      (c) `docs/review-notes.md` — read top to bottom; its factual claims are source-verified.
- [ ] **Publish the two legal pages — A HARD DEPENDENCY (~30 min + your counsel's text).**
      The paywall's Terms of Use / Privacy Policy are real tappable links pointing at
      **`https://beyondkaira.com/terms`** and **`https://beyondkaira.com/privacy`**
      (constants in `Shared/Sources/AppIdentifiers.swift` — change them there if you host
      elsewhere). Apple Schedule 2 requires the links to WORK; a reviewer tapping through to a
      404 is a rejection, so the pages must be live before submission. The privacy policy is
      also where the sensitive-class habit-category disclosure lives (see
      `docs/app-privacy-label.md`).
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

**Two small copy calls, both one-line agent edits once you say:**

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
      any user. Either activate rotation — one line,
      `copy.encouragement[slipCount % copy.encouragement.count]` — so a repeat user gets fresh
      framing, or delete the two dead strings.

## 5. TestFlight — the initial testing sitting

> **Read `docs/testflight-beta-kit.md` §0 before you invite anyone (~5 min).** It is the pre-flight for the
> initial sitting: what a tester actually meets, what to put in the invite, and the paste-ready ASC fields.
> Step-by-step ASC mechanics stay in `docs/testflight-tester-guide.md` (internal group setup, external
> groups/public link).

- [ ] **⚠️ Brief testers about the close-free paywall, or the sitting stalls there (the one that matters).**
      RevenueCat going live flipped the summary CTA: every non-entitled user now routes into the paywall
      (`PostGateRootView.swift:412`), and with Superwall still dormant the variant is always the **hard** arm
      (`PaywallVariant.swift:47`) — **no close button.** Nobody is permanently stuck: force-quit and relaunch and
      the existing-quit branch mounts the dashboard (`PostGateRootView.swift:440`), and the paywall does not
      re-present because a user with no teaser grant re-enters at `.dashboard` (`PaywallRouting.swift:55`).
      In TestFlight the purchase is **free** (sandbox), so the intended
      path works and doubles as your §8 sandbox evidence. But a tester who is not told will refuse the purchase sheet
      and report "the app won't let me in". Beta-kit §2 and §4.1 are written to prevent exactly that. **Two notes:**
      a non-purchaser silently skips the ME-1 widget-adoption moment (the north-star metric's only surface) — the
      script routes them back via Settings → Panic access instead; and if testers do stall, that is the argument for
      pasting the Superwall key and assigning the teaser arm (§8), which is already the decided posture for the
      *review* build.
- [ ] **Know what TestFlight does to subscriptions before a tester reports it as a bug.** Verified against
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
- [ ] **Decide beta-tester GEOGRAPHY before you recruit (~2 min).** Verified helpline rows exist for
      **US and TR only**. Every other region resolves to the GLOBAL bucket, which by your own number-free ruling
      shows text guidance ("…call your local emergency number… visit findahelpline.com") and **no tappable
      number**; a blocked under-17 tester outside US/TR falls back to the US 988 line they cannot dial. Every
      fallback path was probed and they all behave correctly — this is design working as intended, not a bug, and an
      agent may never author a helpline row (official-source verification is yours; the ALO 182 finding is
      exactly why). But if you recruit your ≥15 external testers outside US/TR, that is what they will see. Either
      weight recruiting to US/TR, or add officially-sourced rows for the regions you recruit from — the render
      path is already proven, so adding a row is data-only.
- [ ] **Add internal testers** (nobody receives builds until a tester group exists). The
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
> the tooling is installed) + the eyeball checks below. **The SECOND sitting** is the sandbox purchase matrix,
> which is live work now that the RevenueCat key is in. The payload audit still waits on the TelemetryDeck app
> ID (§8 — Superwall and TelemetryDeck are both still empty; only RevenueCat is keyed).
> For seeded quits, run from Xcode with scheme env `UITEST_SEED_PANIC_SNAPSHOT=1`.

**The eyeball checks (each a screenshot can't verify):**

- [ ] **Eyes-free / VoiceOver (~2 min):** Settings → toggle **"Breathe with taps"** ON → lock → hit the
      lock-screen panic button → the breath step shows the hand-tap glyph and the on-screen line
      **"Feel the taps — in, hold, out."** instead of the circle (with VoiceOver on you instead HEAR
      "Breathe with the taps. In for 4, hold for 7, out for 8. Three rounds." — two different strings,
      `hapticOnlyLabel` and `instructionNonVisual`), and the 4-7-8 rhythm arrives as TAPS you can follow
      with eyes shut (the haptic feel is yours to judge). Toggle OFF → the visual bloom returns. With
      VoiceOver on, swipe one quiz step + the panic steps + a slip log — every control announces a
      sensible name (the slider says its WORDS; the icon picker says which is selected).
- [ ] **Safety layer (~2 min):** Settings → "Support & resources" → your region's verified lines (US: 988 first,
      then SAMHSA/quitline/NAMI; TR: 112 + 171 + 115 — **182 is gone for good, and that is correct**: established
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
      money); VoiceOver says **"Reset — opens a quick exercise"**. (b) **Alternate icons** — pick "Calendar style",
      confirm the home-screen icon
      swaps (iOS shows its own alert) and the app NAME still reads "Ballast"; this also verifies the actool wiring
      (a misspelled build setting fails silently — only a device proves it). (c) **The shield** — with a discreet
      quit, background the app → the switcher card is BLANK (also try with the panic sheet open); with no discreet
      quit, the card shows content. (d) **Erase** — with an alternate icon set, one-tap erase reverts to the
      primary icon.

## 8. §8 keys + config

> **RevenueCat is LIVE — do not redo it.** Key in the app, RC project + entitlement + all three
> products + offering + In-App Purchase Key configured, all three products READY_TO_SUBMIT across
> 175 territories. **Superwall and TelemetryDeck are still EMPTY** (`SuperwallConfiguration.swift:18`,
> `TelemetryDeckSink.swift:12`) — those two are the open keys below.

- [ ] **FREE, DO IT NOW (~2 min) — confirm no ITMS-91053 email ever arrived.** Both
      `PrivacyInfo.xcprivacy` manifests were checked against the app's actual Required-Reason-API usage and **no
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
- [ ] **THE SANDBOX PURCHASE MATRIX — unblocked, and it is Epic 7's operator half.** ASC →
      Users and Access → **Sandbox** → create a test account; on the device Settings → Developer
      → **Sandbox Apple Account** → sign in. Then run: trial start · trial→paid · monthly ·
      restore · reinstall · cancellation · **the on-update regression** (the Quittr-scandal row:
      an existing subscriber must not lose entitlement across an app update). This is also **the
      only test that proves the R46.2 fix** — after a sandbox purchase the win-back settings
      row must disappear immediately, without a relaunch.
      **The first attempt failed; read this before you retry.** The sandbox account signs in fine and
      Apple's purchase sheet OPENS and shows the correct USD price, so StoreKit resolves the products and
      the account is right. The purchase then failed with the app's generic banner. A 4-agent diagnosis
      ruled out, against source: an active StoreKit config in the scheme, bundle-id or SKU mismatch, the
      win-back path being taken by mistake, observer mode, and entitlement/signing causes. The leading
      hypothesis was Apple-side product propagation, which is no longer plausible — the products were
      created several sessions ago. **One-click check first:** in the RevenueCat dashboard confirm the
      `default` offering carries the **Current** badge.
      **The error is now readable.** Retry, then read it with Console.app: connect the phone,
      select it in the sidebar, filter the subsystem to `com.beyondkaira.ballast` and look for category
      `Purchase`. You will get either the missing SKU plus which offering was current, or the RevenueCat
      error code (e.g. 23 `configurationError` = none of the products could be fetched from ASC).
      No `sudo`, no log-collect, no rebuild.
- [ ] **Open `App/Resources/Ballast.storekit` in Xcode 26 once (~5 min, any Mac sitting):** it was hand-authored
      on Linux against Apple's documented structure; a one-time open-and-save validates/normalizes it (and the
      `adHocOffers` win-back entry). Same sitting: run with launch env `UITEST_PAYWALL=1` to eyeball the paywall.
- [ ] **Superwall key:** create the app in the Superwall dashboard and paste the public API key
      into `App/Sources/Monetization/SuperwallConfiguration.swift` (`superwallAPIKey`). Until then every build shows
      the bundled hard-wall control paywall — which is also what every beta tester meets (§5, first item).
- [ ] **Superwall dashboard config (with the key):** two placements — **`quiz_completed`** and **`winback`**; the
      teaser-vs-hard experiment (teaser = escape allowed; hard = no close); the $29.99-vs-$39.99 price experiment
      binding `….annual` (control) vs `….annual.hi` (B arm); then hand an agent the variant ids to fill
      `SuperwallPlacement.variantMapping` (opaque dashboard ids → `teaser`/`hard`; unmapped ids safely render the
      hard control). **Also assign the review build to the TEASER arm** — that is what makes the ratified
      3.1.2 posture true; it is a dashboard setting, not code. For the App Privacy label: SuperwallKit's manifest
      declares Purchase History + a FileTimestamp reason and pulls a checksummed Rust binary
      (`libcel.xcframework`) — recorded so review surprises no one.
- [ ] **TelemetryDeck app ID (~10 min)** — create the app in the TelemetryDeck console and paste the app ID into
      `App/Sources/TelemetryDeckSink.swift` (`telemetryDeckAppID`). Until then the transport is a Noop sink (zero
      bytes leave any build), which also means **the beta produces no funnel data at all**. This is the ONLY
      analytics gate (the consent step already shipped); the moment a
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
      **OQ-2 — RATIFIED:** the habit CATEGORY is declared as **Health & Fitness › Health**. Rationale and
      the two rejected alternatives are in `docs/app-privacy-label.md`. Counsel may still veto; if they do, the
      manifest + its key-set pin move in the same session (LOCKSTEP).
