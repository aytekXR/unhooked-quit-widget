# Operator Expected — the live "what only aytek can do" checklist

| Field | Value |
|---|---|
| Status | LIVE — **only OPEN items are listed here** (Session 47, 2026-07-26). The build side is agent-complete and the project is OPERATOR-GATED; everything below is yours. Completed/closed items and the full FYI vetoable-rulings record live in `docs/past-prompts.md` (the append-only ledger). |
| What changed since you last read this (Session 47) | **One new thing for you, and it is free: §8's first checkbox — search your ASC email for "ITMS-9105" (2 min).** It permanently closes a privacy-manifest question S47 investigated but deliberately did not guess at. Otherwise S47 needed nothing from you. It continued 46A's thread: the age-gate calendar bug was one member of a CLASS — a *device Settings* value silently changing behaviour, invisible to CI because every simulator is `en_US` — so S47 swept the rest of that class and **found and fixed two more real money defects**. A user in any comma-decimal region (most of Europe, Turkey, Brazil, Indonesia) who typed **"12,50" for their weekly spend had it stored as 12**; **"0,50" became 0**, which hides the money feature entirely on the summary, dashboard AND widget — permanently, since spend has no edit path. An Arabic-numeral entry became 0 outright. Also fixed: a projection under ten units rendered a fabricated "~$0/year". **Two dimensions came back clean** (crash safety; and helpline region resolution, which now has probe evidence behind the "region-aware" claim in your App Review notes). One thing worth knowing for **§5 beta recruiting**: verified helplines exist for **US and TR only** — see the new first checkbox there. **Your §3 copy pass is what unblocked the final golden batch — but see the new §0 at the top: your `redesign/` blueprint schedules changes to all four surfaces that batch would cover, so an agent stopped rather than mint goldens that get thrown away. One short answer in §0 unblocks it.** |
| Read first | **`docs/critical-path-post-uir.md`** — the single-page, dependency-ordered launch playbook. **The §3 copy pass is CLOSED** (Session 46B: every copy table read with you end-to-end, ~20 decisions made, 18 string edits + 5 code changes landed, 12 goldens re-recorded, 404 unit / 35 snapshot / 121 free-lane green). The critical path's step 1 is DONE and **the final golden batch is unblocked.** Three findings from it are worth your eye even though they are already fixed: **ALO 182 is a hospital-appointment line, not a crisis line** — §3 had been telling you to mark it verified, which would have shipped a life-safety defect; the **alcohol withdrawal notice was unreachable** for any alcohol user who hit the hard paywall and did not convert; and the paywall's **Terms/Privacy were dead labels** (now real links — but the two pages still need publishing, and that is on you). **The next longest-lead items are the clinician + counsel sign-off and the §8 keys — plus the §0 decision at the top, which is the only thing blocking agent work.** |
| Rule for agents | Update this file at session end alongside `resume-prompt.md`. **Keep it OPEN-items-only** — when an item closes, DELETE it here and record the closure in the `past-prompts.md` ledger; never re-accrete session history, closed-section stubs, or FYI narrative. Section numbers are kept stable (gaps are fine) because other docs cross-reference §3/§7/§8. TRACKED in `docs/` so the operator can read it anywhere. |

---

## 0. ⛔ DECISION NEEDED — does the `redesign/` program run BEFORE launch? (blocks the golden batch)

> **This is the only thing blocking agent work right now.** Everything else below is yours-and-external.
> One answer unblocks it; it costs you two minutes and it is not a technical question.

**What happened.** Your §3 copy pass (Session 46B) unblocked the **final golden batch** — the last agent
task on the launch path. Session 48 scoped it fully and was about to mint it. Then it read the
`redesign/` blueprint you committed in the same session, and stopped, because the two documents disagree:

| Document | What it says about the golden batch |
|---|---|
| `docs/critical-path-post-uir.md` (you updated it in 46B) | Step 1 is DONE, the batch is unblocked, "an agent can mint it whenever you want it" |
| `redesign/design-roadmap.md` (you added it in 46B) | **Phase 4 — Conversion: ME-4 + ME-9 … "Summary + paywall carry their weight; goldens re-record once (`docs/golden-batch.md`); screenshots (LB-5) can shoot against final UI."** And Phases 1–4 are framed as **"to launch-ready … ~7 weeks"** |

**Why an agent cannot decide this for you.** The batch is ~12–20 goldens across the age gate, quiz,
summary and paywall. The redesign schedules changes to **all four** of those surfaces before launch —
QW-6 puts the crest on the age gate (Phase 2), ME-8's waterline field sits behind the quiz and warms the
spend/custom-name steps (Phase 3), **ME-4 is "Summary payoff redesign"** and **ME-9 is literally named
"Paywall goldens + reachable polish"** (Phase 4). If the redesign runs first, every golden minted now is
re-recorded within weeks — two billed CI runs spent, plus a permanent maintenance cost and friction
against the redesign work. If the redesign is post-v1 or partial, the batch should be minted now, because
it gates your screenshots, which gate submission.

**Answer whichever is true — that is all an agent needs:**

- [ ] **(A) "Ship the current UI. Mint the goldens now."** → the redesign becomes a post-v1 program. An
      agent mints the batch immediately; the plan is already written and banked (see below), so it is
      ~2 billed runs and no further design decisions from you.
- [ ] **(B) "The redesign runs before launch."** → the golden batch is DEFERRED to redesign Phase 4 by
      the redesign's own sequencing, and the agent work becomes the redesign roadmap itself, starting
      with its Phase 1 ("Truth & instrumentation — do this before any pixel moves"). Note QW-7 (paywall
      Terms/Privacy links) already landed in 46B, so Phase 1 is partly done. **If you pick this, also say
      whether an agent should start executing that roadmap** — it is a ~7-week program and a much larger
      scope commitment than anything an agent has taken on autonomously so far.
- [ ] **(C) Something in between** — e.g. "do the redesign's quick wins, but ship the current summary and
      paywall." Name which surfaces are frozen and an agent mints goldens for exactly those.

**Nothing is lost while you decide.** Session 48 already scoped the batch in full — the exact view
initializers, the fixture shapes, the determinism hazards and the per-surface golden list are banked in
the session log, so whenever you answer (A) or (C) the mint starts immediately with no re-scoping.

## 1. E0.3 panic-latency device measurement — carried since Session 02, load-bearing

- [ ] Run the harness in `docs/spike-panic-latency.md` on an **iPhone 15-class physical
      device** with full Xcode; record the numbers in that doc (~30 min). It is the ONLY
      remaining blocker on wiring E3's permanent latency CI gate, and it measures the REAL
      panic flow's first frame. (The signpost fires under subsystem `com.beyondkaira.ballast`
      — the runbook names it.)
- [ ] With the numbers, settle the wording drift: MVP §7 "<2 s, 10/10" vs test-suite §1.5
      "p90 < 2.0 s" (one-line edit to the losing doc). This also decides whether "<2s" can be
      marketing copy (10/10 cold taps < 2000 ms) or degrades to "fast".
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

> Step-by-step walkthrough: `docs/testflight-tester-guide.md` (internal group setup, external groups/public link).

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
> E3.3 matrix + the widget/discreet rows + §2's funnel try + the E0.3 latency measurement + the eyeball checks
> below. The SECOND physical sitting (the §8 sandbox purchase matrix + the payload audit) waits for your §8
> keys — sequenced, not now. For seeded quits, run from Xcode with scheme env `UITEST_SEED_PANIC_SNAPSHOT=1`.

**The eyeball checks (each a screenshot can't verify):**

- [ ] **Eyes-free / VoiceOver (~2 min):** Settings → toggle **"Breathe with taps"** ON → lock → hit the
      lock-screen panic button → the breath step shows the hand-tap glyph + "Breathe with the taps…" instead of
      the circle, and the 4-7-8 rhythm arrives as TAPS you can follow with eyes shut (the haptic feel is yours to
      judge). Toggle OFF → the visual bloom returns. With VoiceOver on, swipe one quiz step + the panic steps + a
      slip log — every control announces a sensible name (the slider says its WORDS; the icon picker says which is
      selected).
- [ ] **Safety layer (~2 min):** Settings → "Support & resources" → your region's verified lines (US: 988 first,
      then SAMHSA/quitline/NAMI; TR: 112 + 171 + 115 — 182 hidden until your ALO-182 check flips its flag); tap a
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

## 8. §8 keys + config — the last gates on live monetization + funnel data

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

> Paste keys in this order (the vertical wakes as a unit): **RevenueCat → Superwall → ASC products + win-back
> offer + IAP Key → TelemetryDeck app ID.** Until each key lands its SDK is never initialized (zero network).
> The sandbox purchase matrix + the payload audit are the SECOND physical sitting, sequenced after the keys.

- [ ] **⚠️ AGENT RIDER — R46.2, do this WITH the RevenueCat key, before the sandbox matrix (~1 agent run):** the
      S46 defect hunt proved (source-verified, not speculative) that **`EntitlementModel` is never refreshed after a
      purchase/restore or on foreground**, though its own contract promises all three — there is exactly ONE
      `refresh()` call site in the app (`RepositoryProvider.swift:130`, at launch), and
      `PaywallPresenter.makeOnPurchaseCompleted` receives the fresh `EntitlementState`, fires analytics with it,
      then discards it. **Nothing is wrong on today's dormant build** (no key ⇒ no entitlement model at all), but
      the moment your key lands two things break: (a) the win-back settings row stays visible to someone who JUST
      bought, re-offering the half-price deal (**not a double-charge risk — StoreKit refuses a second purchase of
      an active subscription; the harm is a paying subscriber repeatedly walked into a purchase sheet, a support
      burden and a guideline-3.1.2 smell**); (b) `checkPaywallReentry()` re-runs on every foreground against a
      launch-time snapshot, so a trial that expires mid-session keeps access until a cold launch. It was NOT fixed
      blind because the live monetization path cannot be verified without your key. **Say the word when the key is
      in and an agent lands it in one run — your sandbox matrix below is exactly the test that proves it.**
- [ ] **RevenueCat key (~10 min)** — create the app in the RevenueCat dashboard and paste the PUBLIC SDK key into
      `App/Sources/Monetization/RevenueCatConfiguration.swift` (`revenueCatAPIKey`). The moment a build carries it,
      non-subscribers hit the paywall after the quiz summary and RC starts caching entitlements (Purchase History
      only, not linked/tracking; device-identifier collection is switched OFF).
- [ ] **ASC + RC products (sandbox-verification time — where your accounts become blocking):** in RC create the
      entitlement **"premium"** + three products matching `ProductCatalog` EXACTLY —
      `com.beyondkaira.ballast.monthly` ($6.99), `com.beyondkaira.ballast.annual` ($29.99, 3-day trial — control),
      `com.beyondkaira.ballast.annual.hi` ($39.99, 3-day trial — Superwall B arm); attach all three to "premium",
      build an offering with monthly + the control annual, and create the same products in App Store Connect. The
      **sandbox matrix** (trial start, trial→paid, monthly, restore, reinstall, cancellation) is your half of the
      Epic 7 acceptance.
- [ ] **Win-back offer config (~15 min, with the sandbox matrix):** in ASC on `com.beyondkaira.ballast.annual`
      create a **Promotional Offer** — type **Pay Up Front**, duration **1 year**, price **$14.99**, identifier
      **`winback_annual`** (this exact string — it's the pinned analytics `offer` value and what the app requests).
      Then ASC → Users and Access → Integrations → In-App Purchase → generate/reuse the **In-App Purchase Key** and
      upload it to RevenueCat (Project settings → Apple → In-App Purchase Key) — RC signs the offer server-side;
      without the key the discounted purchase can't be authorized. The app-side signed path is already built; this
      upload is the ONLY thing between the app and the live 50%-off (zero further app-side code).
- [ ] **Open `App/Resources/Ballast.storekit` in Xcode 26 once (~5 min, any Mac sitting):** it was hand-authored
      on Linux against Apple's documented structure; a one-time open-and-save validates/normalizes it (and the new
      `adHocOffers` win-back entry). Same sitting: run with launch env `UITEST_PAYWALL=1` to eyeball the paywall
      (unreachable any other way until your key lands).
- [ ] **Superwall key (after the RC key):** create the app in the Superwall dashboard and paste the public API key
      into `App/Sources/Monetization/SuperwallConfiguration.swift` (`superwallAPIKey`). Until then every build shows
      the bundled hard-wall control paywall.
- [ ] **Superwall dashboard config (with the key):** two placements — **`quiz_completed`** and **`winback`**; the
      teaser-vs-hard experiment (teaser = escape allowed; hard = no close); the $29.99-vs-$39.99 price experiment
      binding `….annual` (control) vs `….annual.hi` (B arm); then fill the variant-id mapping in
      `SuperwallPlacement.variantMapping` (opaque dashboard ids → `teaser`/`hard`; unmapped ids safely render the
      hard control). For the App Privacy label: SuperwallKit's manifest declares Purchase History + a FileTimestamp
      reason and pulls a checksummed Rust binary (`libcel.xcframework`) — recorded so review surprises no one.
- [ ] **TelemetryDeck app ID (~10 min)** — create the app in the TelemetryDeck console and paste the app ID into
      `App/Sources/TelemetryDeckSink.swift` (`telemetryDeckAppID`). Until then the transport is a Noop sink (zero
      bytes leave any build). This is now the ONLY analytics gate (the consent step already shipped); the moment a
      build carries it, opted-in users' funnel events flow and decliners still transmit nothing. While creating the
      app, decide the optional **salt** (`Config(appID:salt:)` — 64 chars, set once and never change it, or
      distinct-user continuity breaks); record the decision (wiring it is a one-line agent edit).
- [ ] **Payload / MITM audit (~30 min, after the app ID ships in a TestFlight build):** run `docs/payload-audit.md`
      — your operator-only release gate (mitmproxy + the §4 procedure; expect the real wire values, e.g. the
      cold-start bucket sends `under_1s`/`1s_to_2s`/`over_2s`). Archive per its §6
      (`docs/audits/payload-audit-<build>.md`) — that archive IS the Epic 8 DoD's operator half and the evidence
      base for the App Privacy label. The zero-before-consent half is verifiable on today's dormant build too.
- [ ] **App Privacy label entry (~15 min at submission time)** — `docs/app-privacy-label.md` is the ready-to-enter
      row set: THREE collected rows (Usage Data › Product Interaction; the habit CATEGORY — see OQ-2; Purchases ›
      Purchase History once RC is live), all Not-linked / Not-tracking, NO Identifiers row. **OQ-2 — RATIFIED Session 46:**
      the habit CATEGORY is declared as **Health & Fitness › Health** (the reviewer-safe mapping for a 17+
      addiction app). Rationale and the two rejected alternatives are recorded in `docs/app-privacy-label.md`.
      Counsel may still veto; if they do, the manifest + its key-set pin move in the same session (LOCKSTEP).
