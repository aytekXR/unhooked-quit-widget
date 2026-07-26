# Golden batch — the ONE final snapshot re-record for the operator's §3 copy sitting

| Field | Value |
|---|---|
| Status | **SCOPED AND READY — but PAUSED on one operator decision (`operator-expected.md` §0).** The §3 gate cleared in 46B, so this batch is technically unblocked. Session 48 then scoped it end-to-end and stopped, because the operator's own `redesign/design-roadmap.md` schedules changes to **all four** surfaces this batch covers (QW-6 age gate, ME-8 quiz, **ME-4 "Summary payoff redesign"**, **ME-9 "Paywall goldens"**) and puts the re-record at its Phase 4. Minting now risks 12–20 goldens thrown away within weeks, plus production snapshot seams added to views scheduled for rewrite. **One short answer in §0 resumes it with zero re-scoping.** |
| The banked plan (Session 48) | **22 goldens, 2 billed runs, split to isolate risk.** Suites: AgeGate entry (4 axes) + blocked (2); Quiz habit (4) + consent (2); Summary fullData (4) + savingsAbsent (2) + withAlcoholNotice (2); Paywall hard_annual (2) + teaser_annual (2). **Run 1** = age gate + quiz + paywall (18 goldens; no or trivial seam). **Run 2** = summary alone (4; the one complex seam), so a seam error cannot destroy the other 18. **Two production seams required, each in the same commit as its tests:** `AgeGateBlockedView.init(model:blocked:)` (2 lines, bypasses its `Locale.current` read — the `ResourcesSnapshotTests` precedent), and `QuizSummaryView` explicit + test-internal inits taking `_snapshotRevealed: Bool` assigning `_revealed = State(initialValue:)`. **THE TRAP that seam exists for:** `QuizSummaryView` renders `.opacity(revealed ? 1 : 0)` and sets `revealed` in `.onAppear { withAnimation { … } }` — without the seam **every summary golden is a BLANK PNG**, certain, not speculative. Fixtures must use `SummaryPresentation.make(inputs:copy: SummaryCopy.loadShipping() ?? .degraded, locale: Locale(identifier: "en_US"))` — hand-built literal strings would leave the golden GREEN when copy changes, defeating the point. Paywall needs NO seam (pure renderer, settled at construction, constructible with zero RevenueCat symbols). **Watch on run 1:** the age-gate UIPickerView has 122 rows and may not populate synchronously — eyeball that golden before adopting; and CI pins no locale/timezone for the snapshot lane (worth pinning while writing these). Full write-ups + quoted initializers are in the Session 48 ledger entry in `docs/past-prompts.md`. |
| Trigger fired | 2026-07-26. Copy is FINAL across every table. Two riders from 46B/47 to carry in: (a) 46B's AX5 goldens disproved a documented "the panic title truncates" claim and revealed something worse the docs never recorded — at max Dynamic Type the long title pushed the **breath bloom entirely off-screen**; check the quiz/summary AX5 axes for that same class rather than trusting a default-size render. (b) `HabitCategory.displayNoun` now drives **5** surfaces (the documented scope of 2 was wrong), so any golden rendering a category noun is affected. Also re-check the 2 `ResourcesSnapshotTests` goldens before assuming they are byte-stable — the §3 safety-copy edits touched that surface. |
| Purpose | Enumerate exactly which snapshot goldens get **minted / re-recorded** when the operator finalizes copy (§3) — so that batch is ONE clean re-record, not a scramble |
| Rule it serves | **R33.2 — DON'T mint goldens for draft copy.** Onboarding + paywall ship DRAFT copy (§3-blocked), so their goldens do not exist yet; they are minted the moment the copy is final. |

## Where the 107 current goldens stand

Every golden below is **GREEN and STABLE on the finished design system** (tokens-v2 palette,
UIR-regenerated layouts). None of these move on the §3 copy pass **unless** the operator changes the
copy/palette that surface renders.

| Suite | Goldens | Copy source | In the §3 batch? |
|---|---:|---|---|
| `DashboardSnapshotTests` | 8 | audited labels + pure data (ADR-11) | **No** — copy is final/data (R34.2) |
| `PanicFlowSnapshotTests` | 40 | script + verbatim user words | **No** — copy byte-identical |
| `SlipFlowSnapshotTests` | 24 | script | **No** — copy byte-identical |
| `StreakWidgetSnapshotTests` | 29 | luminance-only (no Theme); labels from `StreakWidgetStyle` | **No** — no palette; DRAFT widget strings could re-shoot if reworded |
| `ResourcesSnapshotTests` | 2 | safety copy (operator-verified helplines) | **Maybe** — if the §3 safety-copy items (alcohol notice / GLOBAL fallback wording) change |
| `SettingsSnapshotTests` | 2 | audited settings strings | **Maybe** — re-records if the DEFERRED settings-content audit fix lands (see below) |
| `PrivacyOverlaySnapshotTests` | 2 | none (hardcoded hexes) | **No** — until the overlay is deliberately re-recorded |
| `SnapshotSmokeTests` | 0 | — | — |
| **Total** | **107** | | |

## The FINAL BATCH — what gets MINTED at the §3 sitting

These surfaces ship **draft copy** and therefore have **NO snapshot suite yet** (R33.2). When the
founder finalizes their copy, CREATE the suites and MINT the goldens. This is the "post-UIR, ONE
re-record" the roadmap and operator-expected refer to.

1. **Onboarding — age gate, quiz, summary.** Draft copy across the age-gate prompt, the 11–13-step quiz
   (11 always-shown + 2 conditional slots — custom-habit name, reduce-goal weekly limit),
   the consent step, and the savings summary. Suites to create (mirror `DashboardSnapshotTests`
   config: `.image(precision:0.99, perceptualPrecision:0.98, layout:.device(config:.iPhone13),
   traits:{ style, contentSize })`; axes light/dark + AX5 where a surface has a size pivot).
2. **Paywall** (`Monetization/PaywallView`). 20 draft paywall strings + the teaser/win-back draft copy
   (S24–S26). Mint the hard + teaser variants, light/dark. Prices are NEVER copy-table literals — the
   fixture supplies them, so a price change does not re-shoot goldens.

Rough size of the batch: onboarding (~4 surfaces × light/dark [× AX5]) + paywall (~2 variants ×
light/dark) ≈ **12–20 new goldens**, all MINTED (record:.missing) in one red→adopt→green pass.

## Re-record triggers (what would move an EXISTING golden)

- **Final copy (§3):** mints the onboarding + paywall goldens (above). May also re-record the 2
  resources goldens (if the safety-copy items change) and any widget golden whose DRAFT string is
  reworded.
- **Palette change:** `docs/design/tokens-v2.md` is the FINAL palette; a hex edit would cascade a
  re-record across every Theme-based golden (Dashboard/Panic/Slip/Resources/Settings). Not expected —
  the palette is machine-verified against WCAG and locked.
- **The DEFERRED settings-content audit (S39 iceberg):** if the settings-content fix lands (title →
  free-standing `.largeTitle` above the List; long List section footers → scalable in-content rows —
  see the breadcrumb in `DiscreetSettingsView`), it re-records the **2** `SettingsSnapshotTests`
  goldens. Independent of the §3 copy pass.

## Device-eyeball items (NOT goldens — a golden cannot verify them)

- **`StreakRing` motion (UIR-5c):** the momentum-ring `motion/calm` (0.6s ease-out) appear animation
  renders only at runtime (the goldens capture a settled ring). Confirm on device in the E6.2 / founder
  dashboard eyeball.
- **Widget numeral weight (R34.7):** shipped `.semibold` (within the §3 Semibold–Bold range); `.bold`
  is the "heaviest that fits" alternative — a lock-screen render comparison decides.
- **Medium widget labels fixed-12pt (R34.7):** do not scale at AX5 (a §3 micro-label choice); confirm
  legibility on the home screen at large text if desired.

## Mint / re-record mechanics (the standing discipline)

`record: .missing` on macOS CI **writes-then-fails** the missing golden (R32.4) — it is NOT born-green.
Per surface: create the suite → CI run 1 records + goes RED on the snapshot lane → `gh run download
<id> -n test-outputs` → **VISUALLY VERIFY every recorded PNG** → adopt (commit only the changed/new
PNGs; never re-record byte-stable ones) → CI run 2 GREEN. Budget it as a 2-run batch.
