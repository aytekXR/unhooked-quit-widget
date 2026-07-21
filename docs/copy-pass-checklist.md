# Copy Pass Checklist — the §3 founder review, file by file

| Field | Value |
|---|---|
| Document | Copy-pass checklist (created Session 41, 2026-07-19) |
| Status | LIVE — a flat, file-by-file extraction of `operator-expected.md` §3 so you can do the copy pass without re-reading 290 chronological lines. Check a box when that file is signed off. |
| Owner | **Founder** (roadmap: "agents scaffold screens, copy is founder-owned"). Two files additionally need **clinician + counsel** sign-off before public release — flagged below. |
| Why it matters | This pass gates the **ONE final golden batch** (onboarding + paywall screenshots — `golden-batch.md`). **Onboarding + paywall copy edits are still CHEAP** — no goldens exist for those screens yet, so rewrite freely now. Editing widget/settings copy re-records a handful of *existing* goldens (still cheap; batch it). |
| How to use | Read each file top to bottom against the brandkit voice (Steady / Forgiving / Honest; no shame, no medical claims, no fabricated stats, milestones "commonly reported"). Rewrite freely where marked DRAFT. The CI lexicon gates catch banned tokens on every merge, so you cannot accidentally ship a shame/medical word — your job is the nuance a wordlist can't judge. |

Legend: **✍️ founder rewrite** (DRAFT, your words) · **🩺 clinician+counsel ship gate** · **🔎 verify** (external source) · **🔒 confirm literal** (brandkit-fixed, don't rewrite) · **⚖️ decision** (a call rides along, see `critical-path-post-uir.md` "Open decisions").

---

## A. Onboarding & summary (edits are cheapest here — no goldens yet)

- [ ] **`App/Resources/Content/quizConfig.json`** — ✍️ the whole quiz — **13 slots** (11 always-shown + 2 conditional DRAFT steps that are easy to miss: **slot 2** "What should we call it?" shown only for a *custom* habit, and **slot 12** "What weekly limit feels right?" shown only on the *reduce* goal path — review their copy too) — DRAFT; agents scaffolded, you own the words. ~20 min.
  - Includes the **slot-3 consent strings** (title "Share app usage data?", the helper, "Share usage data" / "No thanks") — ✍️ + ⚖️ two calls: (a) helper opener conditional "You'd share…" vs imperative "Turn this on to share…"; (b) do NOT add any "change this in Settings" promise (no settings-analytics surface exists — promise nothing unbuilt).
  - Includes the **effects step (slot 10)** — ⚖️ your medical-claims read: chips are non-diagnostic self-report nouns ("Restless sleep", never "insomnia"); the title makes no causal claim — keep it that way.
  - ⚖️ optional: should the motivations step gain a free-text "why does {motivation} matter to you?" elaboration (enriches the panic reasons screen; local-only)? Copy/UX call, not built yet.
- [ ] **`App/Resources/Content/summaryCopy.json`** — ✍️ 11 DRAFT strings (eyebrow, savings caption, the six "first hard window" phrases, motivation intro, CTA). Brand signed with zero required replacements. ~10 min.
  - ⚖️ the flagged nit: the hero renders "~$1,350/year" and the caption says "saved in a year, if you stay on track." (a double-"year" read; optional alt: "saved in a year at this rate.").
  - ⚖️ keep the risk-window phrases as REFLECTION hedges ("…is likely evenings.") — keep "likely", never let "predict"-family words in.

## B. Paywall (edits still cheap — no goldens yet; the biggest decisions live here)

- [ ] **`App/Resources/Content/paywallCopy.json`** — ✍️ 20 DRAFT strings + the 3 teaser strings + the 4 win-back strings, ALL founder-owned. (The 5th win-back string, `winbackRowLabel`, lives in `DiscreetSettingsCopy.swift` — see §E, not this file.) Prices are NEVER in this file (`%@` slots bind the catalog), so rewrite freely. ~15 min. Three decisions ride along:
  - ⚖️ **(a) THE register decision:** mvp §6 fixes the positioning canon verbatim as "No account. No server. Nothing to leak. Apple handles billing — cancel or refund in one tap." The panel shipped an audit-safe variant instead ("No account. No sign-up. Apple handles billing — cancel in one tap." + "Your notes and journal never leave your device.") because the paywall is the one screen brokered by RevenueCat's servers. **Restore the verbatim canon by saying so, or accept the shipped variant** — your call alone.
  - ⚖️ **(b) legal riders** (also step 9 of the critical path): the Terms/Privacy links render as LABELS today — they MUST become functional URLs before submission (Apple Schedule 2); re-check the auto-renewal wording ("Apple Account" terminology) in ASC at product-setup time.
  - ⚖️ **(c)** the screen has NO "Not now" close (your hard-ish wall; the sanctioned escape is the teaser variant). Confirm or change.
  - **Teaser strings** (`teaserEscapeLabel`, `teaserEscapeNote`, `teaserExpiryEyebrow`): factual duration only — never a countdown, no urgency, no loss framing, name-free.
  - **Win-back strings** (in this file: `winbackOfferLine`, `winbackMechanicsLineFmt`, `winbackReassurance`, `winbackDismissLabel`; the Settings-row `winbackRowLabel` is in §E): "half price" is honest (a real discount) but NO countdown, NO "one-time", NO we-miss-you framing, and NEVER "Reactivate"/"Come back" (a trial-lapse user may never have paid).

## C. Panic & slip (SAFETY surfaces — the stricter loop; parts are clinician-gated)

- [ ] **`App/Resources/Content/panicScript.json`** — ✍️ ships since Session 10; review the whole flow's tone. Plus:
  - 🩺 the eyes-free panic-path strings: the taps-anchored breath instruction **"Breathe with the taps. In for 4, hold for 7, out for 8. Three rounds."** (renders instead of "Follow the circle…" in haptics-only mode; what VoiceOver speaks) — panic-path copy, clinician+counsel ship gate.
  - ⚖️ two niceties: the panic entry title "Let's take this one wave at a time." TRUNCATES at max Dynamic Type ("Let's take t…") — a shorter title fixes it (currently pinned by goldens); and the degraded slip path echoes "Logged." twice (title + body).
- [ ] **`App/Resources/Content/slipCopy.json`** — ✍️ ships since Session 12; review the whole slip flow (incl. the `dashboard` section) against the voice. ~E4.2 signature. Watch `confirm.retryNote` ("That didn't save just yet — nothing's lost…") stays calm/zero-shame/retryable.
- [ ] **Settings toggle copy** (in `DiscreetSettingsCopy.swift`, see section E): the "Breathe with taps" label + footer — ⚖️ binding condition: never frame the eyes-free mode as an accessibility accommodation (it is first-class for anyone).

## D. Safety content & helplines (clinician + counsel + external verification)

- [ ] **`App/Resources/Content/safetyCopy.json`** — 🩺 the SHIP gate for public release (the file's own `_meta` still says "DRAFT — needs clinician + counsel sign-off"):
  - the **alcohol withdrawal notice** (title/body/"See resources"/"Got it") — panel signed the wording as-is (calm, hedged, points to a professional, never says HOW to withdraw), but your clinician+counsel pass is the gate.
  - the **resourcesScreen** strings (title/intro/footer) — re-read in the post-gate render context.
  - ⚖️ one reword to eyeball: `notMedicalCareDisclaimer` now reads "…not medical or mental-health **care**" (was "treatment") — meaning preserved; veto with different wording if counsel prefers.
  - the **"Support & resources"** label (Settings row + slip-flow link, byte-identical) — ✍️.
  - 🔎 the **GLOBAL fallback note** ("…visit findahelpline.com.") — verify-or-veto the findahelpline.com pointer (ThroughLine's vetted global directory; the GLOBAL bucket stays number-free by ruling — never add a phone row without an official source).
- [ ] **`App/Resources/Content/helplines.json`** — 🔎 verify the flagged rows. Specifically **ALO 182 (Turkish crisis line)**: `tr_crisis` is `verified: false` pending your official-source check (Sağlık Bakanlığı). Verify it and flip `verified: true` and it joins the blocked-minors surface automatically (a unit test pins that unverified rows never render).
- [ ] **`App/Resources/Content/ageGateCopy.json`** — ✍️ 8 strings, both gate screens (panel-signed, CI shame-scanned). Review.
- [ ] **`App/Resources/Content/milestones.json`** — ✍️ + 🩺-adjacent (E9.2 signature): **43** milestone bodies (vape 8, alcohol/porn/weed/doomscroll/custom 7 each), "commonly reported" framing per its `_meta` — all 43 are framing-pinned by `MilestoneCopyTests`. Read with the medical-claims eye — experiential, never clinical promises. (These render on the dashboard.)

## E. Widget & settings strings (a rewrite re-records a few EXISTING goldens — batch it)

- [ ] **`Shared/Sources/StreakWidgetStyle.swift`** — ✍️ 9 strings: gallery name "Streak" + description, the "today"/"saved"/"next milestone" micro-labels, the empty-state "Ready when you are.", the "Day 7" gallery sample, `panicAccessibilityLabel` ("Panic — opens a full-screen reset"), and `panicAccessibilityLabelDiscreet` ("Reset"). (The struct has 12 `String` props; the other 3 are non-copy: `widgetKind` + the two SF-Symbol glyph names `panicGlyph`="wind"/`panicGlyphDiscreet`="arrow.counterclockwise" — confirm-only.) Baked into the **29 recorded widget goldens** (`Tests/Snapshot/__Snapshots__/StreakWidgetSnapshotTests/`) — a rewrite re-records the affected ones (cheap; batch). (An in-file `StreakWidgetStyle.swift` comment still says "15" — stale since S22 added the discreet variants; the real count is 29.) ⚖️ one fork: `panicAccessibilityLabelDiscreet` is a bare "Reset" (brandkit literal); a descriptive "Reset — opens a quick reset" would give VoiceOver action-hint parity and still leak nothing — your call.
- [ ] **`App/Sources/DiscreetSettingsCopy.swift`** — ✍️ **12 strings total**. The 8 settings-chrome strings: "Discreet Mode", "Widgets" / "Widgets for this streak show numbers only.", "App Icon", 🔒 "Default"/"Calendar style"/"Timer style" (brandkit §4.3 literals — confirm, don't rewrite), "Settings" (VoiceOver label). Plus 4 strings that live in this same file but are reviewed under their functional sections above: `winbackRowLabel` ("See your plan options", §B), `resourcesRowLabel` ("Support & resources", §D), and `hapticPacerRowLabel` + `hapticPacerFooter` (the "Breathe with taps" toggle, §C) — so a rewrite of any of those also touches this file. (The discreet panic-button VoiceOver "Reset" fork lives in §E's `StreakWidgetStyle.swift` bullet — that's where the string is, NOT this file.)

## F. Rides-along items (not copy tables, but part of the same sign-off)

- [ ] **`docs/review-notes.md`** — 🩺 read top to bottom (clinician + counsel pass is its SHIP gate); it holds itself to the register bans in its §4. Its §3 surfaces the review-build/keys/17+ decisions (also in the Open-decisions table).
- [ ] **`App/Resources/Content/REVIEW.md`** — 🔎 the TR localization review item.
- [ ] **App icons `AppIconCalendar` / `AppIconTimer`** — ⚖️ veto-class: look at them on a device home screen (§7). The generator is deterministic (`brandkit/branding-assets/generate-alt-icons.py`); no golden pins the pixels. Plus the **R22.10 store-screenshot decision**: never market the discreet alternates (one public exposure makes an "innocuous" icon reverse-image-linkable to Ballast forever) — confirm/veto before any screenshot work.
- [ ] **OQ-1 — the displayLabel words "Porn"/"Weed"** (from `QuitRepository.displayLabel`, not a copy file) — ⚖️ keep the short nouns (silence = they stand) or switch to "Adult content"/"Cannabis" (one agent re-pin run; a brand-signed test currently pins the current words). See Open decisions.
- [ ] **Sign the MVP §7 copy-audit checklist** (E4.2 for slip, E9.2 for milestones) — the mechanical half is CI-enforced; your half is the nuance read. Record by checking the box.

---

### When this pass is done

1. Any changed onboarding/paywall strings → an agent mints the **final golden batch** (`golden-batch.md`, ~12–20 new goldens, 2 CI runs). This is the last snapshot re-record.
2. Any changed widget/settings strings → an agent re-records the affected existing goldens (batch with #1).
3. The clinician+counsel sign-offs (safetyCopy, review-notes, panic-path strings) clear the safety-content ship gate.
4. Proceed to the rest of `critical-path-post-uir.md` (device sittings, keys, G0, screenshots, beta, submission).
