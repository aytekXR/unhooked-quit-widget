# Operator Expected — the live "what only aytek can do" checklist

| Field | Value |
|---|---|
| Status | LIVE — **only OPEN items are listed here** (Session 45, 2026-07-24). The build side is agent-complete and the project is OPERATOR-GATED; everything below is yours. Completed/closed items and the full FYI vetoable-rulings record live in `docs/past-prompts.md` (the append-only ledger). |
| Read first | **`docs/critical-path-post-uir.md`** — the single-page, dependency-ordered launch playbook (11 steps + the consolidated open-decisions table). It sequences every open item below into an order of operations. **The one thing worth doing this week: the §3 copy pass** — it gates the final golden batch → screenshots → submission (`docs/golden-batch.md` + the file-by-file `docs/copy-pass-checklist.md`). |
| Rule for agents | Update this file at session end alongside `resume-prompt.md`. **Keep it OPEN-items-only** — when an item closes, DELETE it here and record the closure in the `past-prompts.md` ledger; never re-accrete session history, closed-section stubs, or FYI narrative. Section numbers are kept stable (gaps are fine) because other docs cross-reference §3/§7/§8. TRACKED in `docs/` so the operator can read it anywhere. |

---

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
      resources surface (988 on a US device; "Go back" recovers). **All quiz + summary copy is DRAFT
      pending your §3 pass.**

## 3. Content tone review (the §3 copy pass) — the longest-lead operator item

> This is the biggest open item and it gates the final golden batch. `docs/copy-pass-checklist.md`
> lays it out file-by-file; work down that list. The distinct open pieces and the judgment calls that
> live nowhere else:

**The copy tables to read + finalize (all DRAFT, founder-owned, CI-lexicon-scanned):**

- [ ] **App Review notes** — `docs/review-notes.md` (~15 min read). The paste-ready notes; every
      claim is anchored to a shipped test. Read it top-to-bottom with copy-table eyes. Its §3 surfaces
      three submission decisions that are yours alone: (a) 3.1.2 review-build posture — point the review
      build at the **teaser** arm (has the escape) or defend the **hard wall** (no close); (b)
      keys-at-submission — a keyless review build never shows a purchase screen, so submit keyed or
      explain the gating; (c) the 17+ rating in ASC. **Your clinician + counsel pass is its ship gate.**
- [ ] **Quiz** — `App/Resources/Content/quizConfig.json` (~20 min). The quiz's one audited copy table;
      rewrite freely (no snapshot goldens exist yet, so edits are cheap). Two sub-decisions: (a) the
      effects step (slot 10) needs your medical-claims read — chips are non-diagnostic self-report nouns
      ("Restless sleep", never "insomnia"), keep it non-causal; (b) whether the motivations step gains an
      optional free-text "why does {motivation} matter?" elaboration (not built yet — a copy/UX call).
- [ ] **Consent strings** — `quizConfig.json` slot-3 (~5 min): title "Share app usage data?", the helper,
      and the two choice labels. Two founder calls: (a) helper opener "You'd share…" (conditional) vs "Turn
      this on to share…" (imperative); (b) do NOT let any "change this anytime in Settings" promise creep in
      — no settings analytics surface exists. Note: "anonymous" was deliberately removed everywhere as an
      unverifiable overclaim; the audit-backed "never tied to you" carries the reassurance.
- [ ] **Summary** — `App/Resources/Content/summaryCopy.json` (~10 min, 11 strings). Two founder calls: (a)
      the hero renders "~$1,350/year" + "saved in a year, if you stay on track." (a double-"year" read;
      optional alt: "saved in a year at this rate."); (b) the risk-window phrases are REFLECTION hedges
      ("…is likely evenings.") — keep "likely", never "predict"-family words.
- [ ] **Paywall** — `App/Resources/Content/paywallCopy.json` (~15 min, 20 strings; prices are never in this
      file — `%@` slots bind `ProductCatalog`). Three decisions: (a) **the register decision** — mvp.md §6
      fixes the positioning canon as "No account. No server. Nothing to leak. Apple handles billing — cancel
      or refund in one tap." The panel shipped the audit-safe variant instead ("No account. No sign-up. Apple
      handles billing — cancel in one tap." + "Your notes and journal never leave your device."), because the
      paywall is the one RC-brokered screen ("No server" is self-contradictory there) and Apple refunds are
      requested, not one-tap. Restore the verbatim canon by saying so — mvp.md was not touched, this is your
      call. (b) **Legal riders (legal-owned):** the Terms of Use + Privacy Policy links render as LABELS today
      — they MUST become **functional URLs** before submission (Apple Schedule 2); re-check the auto-renewal
      boilerplate against Apple's current "Apple Account" wording in ASC. (c) the screen has NO "Not now" close
      (the sanctioned escape is E7.2's teaser).
- [ ] **Win-back strings (5)** — `paywallCopy.json` gains `winbackOfferLine` / `winbackMechanicsLineFmt`
      (`%@`-bound $14.99 then $29.99 — never a price literal) / `winbackReassurance` / `winbackDismissLabel`,
      and the settings `winbackRowLabel`. Register: "half price" is honest (a real discount) but NO countdown,
      NO "one-time", NO we-miss-you framing, NEVER "Reactivate"/"Come back" (a trial-lapse user may never have
      paid).
- [ ] **Teaser strings (3)** — `paywallCopy.json` gains `teaserEscapeLabel` / `teaserEscapeNote` /
      `teaserExpiryEyebrow`. Register: factual duration (never a countdown), no urgency, no loss framing.
- [ ] **Settings chrome (8 strings)** — `App/Sources/DiscreetSettingsCopy.swift`. All DRAFT except the two
      picker literals "Calendar style" / "Timer style" (brandkit §4.3 — confirm rather than rewrite). One
      flagged fork: the discreet widget button's VoiceOver label is bare "Reset" (brandkit literal); a
      descriptive "Reset — opens a quick reset" gives VoiceOver action-hint parity and still leaks nothing.
      (The other 4 settings strings — `winbackRowLabel`, `resourcesRowLabel`, `hapticPacerRowLabel`,
      `hapticPacerFooter` — are reviewed under their functional items here.)
- [ ] **Widget gallery strings (9)** — `Shared/Sources/StreakWidgetStyle.swift` (gallery name/description,
      the micro-labels, the empty-state "Ready when you are.", the panic button a11y label). A rewrite
      re-records the 29 widget goldens (cheap; batch it).
- [ ] **Milestones (43 strings)** — `App/Resources/Content/milestones.json` (~10 min). "Commonly reported"
      framing; review with the medical-claims eye — experiential, never clinical promises.
- [ ] **Slip flow** — `slipCopy.json` (incl. `dashboard` section) + the one agent-drafted line
      `confirm.retryNote` ("That didn't save just yet — nothing's lost. Tap Log it to try again whenever
      you're ready."). Read against the brandkit voice (Steady / Forgiving / Honest) and sign the MVP §7
      copy-audit checklist for the slip surface.
- [ ] **Panic + haptic-pacer strings** — the settings toggle "Breathe with taps" + its footer (never frame
      it as an accessibility accommodation — it is first-class eyes-free-for-anyone, brandkit §8), and the
      taps-anchored breath instruction "Breathe with the taps. In for 4, hold for 7, out for 8. Three rounds."
      (renders instead of "Follow the circle…" in haptics-only mode; PANIC-PATH copy → clinician+counsel is its
      ship gate). Two copy niceties to keep-or-fix: the panic entry title "Let's take this one wave at a time."
      truncates at max Dynamic Type (a shorter title fixes it), and the degraded slip path shows "Logged."
      twice.
- [ ] **Age-gate copy** — review the 8 `ageGateCopy.json` strings (both gate screens; panel-signed,
      CI-scanned against the shame lexicon).

**The safety block + clinician/counsel gate:**

- [ ] **`safetyCopy.json` sign-off** — every string now renders in TestFlight. The panel signed the wording
      as-is, but the file's `_meta` still says "DRAFT — needs clinician + counsel sign-off" and that stays
      YOURS before public release. Includes: the alcohol withdrawal notice (title "One thing worth knowing" +
      body + "See resources"/"Got it"), the resourcesScreen strings, one reword to eyeball
      (`notMedicalCareDisclaimer` → "…not medical or mental-health **care**"), the "Support & resources" label,
      and the GLOBAL fallback note ("…call your local emergency number. To find a helpline in your country,
      visit findahelpline.com.") — **verify-or-veto the findahelpline.com pointer** (removing it is a one-line
      edit; the GLOBAL bucket stays number-free by ruling — never add a phone row without an official source).
- [ ] **ALO-182 — the Turkish crisis line** (~5 min): `tr_crisis` (ALO 182) is `verified: false` in
      `helplines.json`, so TR currently shows only 112. Verify it against an official source (Sağlık Bakanlığı),
      flip `verified: true`, and it renders automatically (a unit test pins that unverified rows can never render).
- [ ] **E9.2 milestones audit signature** (~10 min): the mechanical half (medical-claim lexicon, "commonly
      reported" framing on all 43 bodies) is permanent CI; your half is reading `milestones.json` for nuance and
      recording the sign-off.

**The two MVP ratifications (your file was not touched — ratify or veto):**

- [ ] **Win-back in-app-only (mvp §6):** v1 ships the win-back offer in-app only (no local notification) — a
      notification would add a permission prompt this privacy-first app never asks for and break a landed test.
      Honest cost: a lapsed user who never re-opens never sees the offer (you can measure shown→converted but not
      eligible→shown). Ratify in-app-only for v1, or veto to schedule a notification session.
- [ ] **Teaser vocabulary (mvp §5):** ratify the two flagged deviations — `paywall_viewed.source` gains
      `teaser_expiry`, and `variant` transmits the semantic labels `teaser`/`hard`.
- [ ] **3.1.1 winback row:** add the winback line (discounted price + standard renewal price in one line, plus
      the standing auto-renew/restore/Terms/Privacy set) to your guideline-3.1.1 sign-off, alongside the S25
      remote-B-arm rider.

**The two generated assets + the ASO decision (VETO-CLASS):**

- [ ] **The two generated app icons** — `AppIconCalendar` + `AppIconTimer` (built to brandkit §4.3). Look at them
      on a device home screen (§7 row). Veto/replace freely; the generator
      (`brandkit/branding-assets/generate-alt-icons.py`) is deterministic and no golden pins icon pixels.
- [ ] **Store-screenshot decision (R22.10):** brandkit §9.1 says never market the discreet alternates; §9.2 frame 3
      shows the Calendar icon. They're mutually exclusive (one public exposure makes the "innocuous" icon
      reverse-image-linkable to Ballast forever). The panel resolved toward §9.1 (frame 3 should show the discreet
      WIDGET only, primary icon). You own ASO — confirm or veto, and note it in the brandkit.

## 5. TestFlight housekeeping — carried from Sessions 07–09; NOW TIMELY

> Step-by-step walkthrough: `docs/testflight-tester-guide.md` (internal group setup, external groups/public link).

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

> Paste keys in this order (the vertical wakes as a unit): **RevenueCat → Superwall → ASC products + win-back
> offer + IAP Key → TelemetryDeck app ID.** Until each key lands its SDK is never initialized (zero network).
> The sandbox purchase matrix + the payload audit are the SECOND physical sitting, sequenced after the keys.

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
      Purchase History once RC is live), all Not-linked / Not-tracking, NO Identifiers row. **OQ-2 (counsel,
      VETO-CLASS): the habit-category taxonomy** — recommendation is **Health & Fitness › Health** (the
      reviewer-safe mapping for a 17+ addiction app); alternatives are Sensitive Info, or folding it into Product
      Interaction with the sensitive-class disclosure carried in the privacy policy. Declare exactly ONE — ratify
      before ASC entry (it flows lockstep to the privacy manifest + label doc).

## Open decision not tied to a section above

- [ ] **OQ-1 — displayLabel (VETO-CLASS, ~2 min):** the panic multi-quit picker and the widget setup screen render
      the category words **"Porn"** and **"Weed"** (from `QuitRepository.displayLabel`). Brand flags this against the
      brandkit §1.2 clinical-noun rule (the quiz chips already say "Adult content"/"Cannabis"), but `PanicPathTests`
      deliberately PINS the current words as "brand-reviewed, clinical" — a genuine documented deadlock. Keep the
      short nouns (silence = they stand) or say the word and a session repins both strings + the sanctioning test to
      "Adult content"/"Cannabis" (one billed run; not an App-Review blocker either way).
