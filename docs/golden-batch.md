# Golden batch — the ONE final snapshot re-record for the operator's §3 copy sitting

| Field | Value |
|---|---|
| Status (Session 49) | **§0 ANSWERED (A) "ship the current UI, mint now" — and the plan below is now RE-VERIFIED against the S48B redesign wave (`852bd76`), with the one ambiguity that would have cost a billed run RESOLVED. See "Session 49 re-verification" immediately below. NOT YET MINTED, for a NEW reason that is not §0: the S48B session pushed 9 commits in ~2 hours touching ALL FOUR surfaces this batch covers — the paywall as recently as `852bd76` and the summary twice (`8ef20b9` added the footer, `5d83646` fixed its ink). A mint is a record→adopt→green cycle across 2 billed macOS runs that only yields valid PNGs if the bytes hold still. The operator has been asked for a "wave is done" signal; on that signal this fires immediately with zero further scoping.** |
| _superseded_ | **SCOPED AND READY — but PAUSED on one operator decision (`operator-expected.md` §0).** The §3 gate cleared in 46B, so this batch is technically unblocked. Session 48 then scoped it end-to-end and stopped, because the operator's own `redesign/design-roadmap.md` schedules changes to **all four** surfaces this batch covers (QW-6 age gate, ME-8 quiz, **ME-4 "Summary payoff redesign"**, **ME-9 "Paywall goldens"**) and puts the re-record at its Phase 4. Minting now risks 12–20 goldens thrown away within weeks, plus production snapshot seams added to views scheduled for rewrite. **One short answer in §0 resumes it with zero re-scoping.** |
| The banked plan (Session 48) | **22 goldens, 2 billed runs, split to isolate risk.** Suites: AgeGate entry (4 axes) + blocked (2); Quiz habit (4) + consent (2); Summary fullData (4) + savingsAbsent (2) + withAlcoholNotice (2); Paywall hard_annual (2) + teaser_annual (2). **Run 1** = age gate + quiz + paywall (18 goldens; no or trivial seam). **Run 2** = summary alone (4; the one complex seam), so a seam error cannot destroy the other 18. **Two production seams required, each in the same commit as its tests:** `AgeGateBlockedView.init(model:blocked:)` (2 lines, bypasses its `Locale.current` read — the `ResourcesSnapshotTests` precedent), and `QuizSummaryView` explicit + test-internal inits taking `_snapshotRevealed: Bool` assigning `_revealed = State(initialValue:)`. **THE TRAP that seam exists for:** `QuizSummaryView` renders `.opacity(revealed ? 1 : 0)` and sets `revealed` in `.onAppear { withAnimation { … } }` — without the seam **every summary golden is a BLANK PNG**, certain, not speculative. Fixtures must use `SummaryPresentation.make(inputs:copy: SummaryCopy.loadShipping() ?? .degraded, locale: Locale(identifier: "en_US"))` — hand-built literal strings would leave the golden GREEN when copy changes, defeating the point. Paywall needs NO seam (pure renderer, settled at construction, constructible with zero RevenueCat symbols). **Watch on run 1:** the age-gate UIPickerView has 122 rows and may not populate synchronously — eyeball that golden before adopting; and CI pins no locale/timezone for the snapshot lane (worth pinning while writing these). Full write-ups + quoted initializers are in the Session 48 ledger entry in `docs/past-prompts.md`. |
| Trigger fired | 2026-07-26. Copy is FINAL across every table. Two riders from 46B/47 to carry in: (a) 46B's AX5 goldens disproved a documented "the panic title truncates" claim and revealed something worse the docs never recorded — at max Dynamic Type the long title pushed the **breath bloom entirely off-screen**; check the quiz/summary AX5 axes for that same class rather than trusting a default-size render. (b) `HabitCategory.displayNoun` now drives **5** surfaces (the documented scope of 2 was wrong), so any golden rendering a category noun is affected. Also re-check the 2 `ResourcesSnapshotTests` goldens before assuming they are byte-stable — the §3 safety-copy edits touched that surface. |
| Purpose | Enumerate exactly which snapshot goldens get **minted / re-recorded** when the operator finalizes copy (§3) — so that batch is ONE clean re-record, not a scramble |
| Rule it serves | **R33.2 — DON'T mint goldens for draft copy.** Onboarding + paywall ship DRAFT copy (§3-blocked), so their goldens do not exist yet; they are minted the moment the copy is final. |

## Session 49 re-verification — read this before minting

Two independent re-scopers plus hand-verification against the shipping bytes at `852bd76`. Every
claim below was checked by reading the file, not inferred.

### Still valid, unchanged

- **The `QuizSummaryView` seam is still MANDATORY.** `@State private var revealed = false` (line 48),
  `.opacity(revealed ? 1 : 0)` (line 68), `revealed = true` only inside
  `.onAppear { model.onSummaryAppear(); withAnimation { … } }` — all unchanged. **And the new
  `summary.footer` block added in `8ef20b9` sits INSIDE that opacity scope**, as does the CTA (it is
  in the scaffold's `actions:`). So without the seam every summary golden is still a blank PNG.
- **The `AgeGateBlockedView` seam is still MANDATORY and still 2 lines.** `init(model:)` still reads
  `AgeGateResources.region(for: Locale.current, in: directory)`. `copy` and `footerDisclaimer` have
  inline stored initializers and must NOT be added as init parameters; only `model` and `blocked`
  need assigning. One call site (`AgeGateContainerView.swift:66`), so the seam is purely additive.
- **The fixture call still compiles and is still required in that exact form.**
  `SummaryPresentation.make(inputs:copy:locale:)` declares `locale: Locale = .current`, so the
  explicit `locale: Locale(identifier: "en_US")` is load-bearing, not decoration. It now populates
  the new `footer` field automatically from `copy.footer` — **no fixture change needed**, and a
  hand-built literal would still defeat the point.
- **The two-run split is still the right risk strategy** (run 1 = age gate + quiz + paywall = 18;
  run 2 = summary alone = 4).
- **22 goldens, matrix unchanged.**

### RESOLVED — the ambiguity that would have burned a run

The two re-scopers proposed the seam init with `_snapshotRevealed` in **different positions**
(leading vs trailing) — precisely the mismatch class S48 flagged, recurring on parameter *order*
instead of label. Swift requires arguments in declaration order, so this is not cosmetic: the wrong
order fails to compile and records nothing. **Ruling — `_snapshotRevealed` goes LAST**, and
`onContinue` must be `@escaping` (it is a stored `let` closure; the synthesized memberwise init
exempts this, a custom init does not):

```swift
// BOTH inits go in the struct body BEFORE `var body`. Adding any explicit init
// suppresses the synthesized memberwise init, so the production one is required.
init(
    model: QuizFlowModel,
    data: SummaryViewData,
    onContinue: @escaping () -> Void,
    alcoholNotice: AlcoholNoticeSlot? = nil
) {
    self.model = model
    self.data = data
    self.onContinue = onContinue
    self.alcoholNotice = alcoholNotice
}

/// Snapshot seam — `_snapshotRevealed` is LAST (S49 ruling). `alcoholNotice`
/// keeps its default, so a test may pass `_snapshotRevealed:` alone or supply
/// `alcoholNotice:` first — both are legal in declaration order.
init(
    model: QuizFlowModel,
    data: SummaryViewData,
    onContinue: @escaping () -> Void,
    alcoholNotice: AlcoholNoticeSlot? = nil,
    _snapshotRevealed: Bool
) {
    self.model = model
    self.data = data
    self.onContinue = onContinue
    self.alcoholNotice = alcoholNotice
    self._revealed = State(initialValue: _snapshotRevealed)
}
```

Verified compatible with both existing call sites (`PostGateRootView.swift:288` and `:378`) — each
passes `model:`, `data:`, `onContinue:` only, so the production init above is signature-identical to
the memberwise one it replaces.

```swift
// AgeGateBlockedView — add immediately after the existing init's closing brace.
/// Snapshot seam — bypasses the `Locale.current` / `HelplineDirectory` reads
/// (the `ResourcesSnapshotTests` precedent). Never called by production code.
init(model: AgeGateModel, blocked: AgeGateBlocked) {
    self.model = model
    self.blocked = blocked
}
```

### Hazard CLEARED — the live RevenueCat key does not affect the paywall goldens

Worth stating because it was the obvious new worry once `644c04d` went live: **`PaywallView` is a
pure renderer.** It declares `let data: PaywallViewData` / `let model: PaywallModel` and contains
**no `import RevenueCat`, no `import Purchases`, and no `Purchases.` reference at all**. So the
fixtures still construct it with zero SDK symbols and no network, and it needs no seam. The
`hard_annual` / `teaser_annual` goldens remain deterministic under a live key.

### REJECTED — do not add erase-flow goldens to this batch

One re-scoper proposed extending the batch to `EraseEverythingView` (+ making its `Stage` enum
internal for a `.done`-stage golden). **Do not.** Three reasons: it would require editing a file the
S48B session created hours ago and may still be editing; the operator's instruction is not to change
the redesigned UI, and flipping `private enum Stage` to internal is a production change; and most
importantly **that surface carries a live HIGH accessibility finding** (`docs/session-49-audit.md`
§1) — minting goldens there would lock in a state that is about to change. Revisit after that
finding is settled on a device.

### Carried hazards, unchanged

- The age-gate **UIPickerView has 122 rows** and may not populate synchronously. Eyeball that golden
  specifically; do **not** adopt a blank or centre-row-only wheel.
- **CI pins no locale or timezone** for the snapshot lane — worth pinning while writing these.
- `UITraitCollection(traitsFrom:)` is **DEPRECATED** and fails under `-warnings-as-errors` (it burned
  a billed run once). Closure-init form only: `UITraitCollection { traits in … }`.
- Mirror `DashboardSnapshotTests` config exactly: `precision: 0.99`, `perceptualPrecision: 0.98`,
  `layout: .device(config: .iPhone13)`, `@Suite(.snapshots(record: .missing))`.
- **A note on golden sensitivity (S49):** QW-10 added a visible footer button to `RedirectStepView`
  and the four `snapshot_redirectStep` goldens were *not* re-recorded — yet
  `✔ snapshot_redirectStep() passed`. Either the button renders below the scroll fold or the delta
  fell inside the 1% tolerance. Both readings matter here: this suite's precision may be less
  sensitive to an added control than assumed, so **visually verify, never trust green alone.**

## Where the 141 current goldens stand

> **✅ This table is CORRECT as of S52 — re-counted from disk, and it matches.** Trust it, and
> re-count before you rely on it. (History, so nobody re-derives the fix: it had been wrong since
> wave 1 — 107 goldens across 7 suites, missing FIVE suites entirely and two counts wrong. It is
> the first thing ME-8 is told to read, which is why it was worth fixing.) **Count, never quote:**
> `find Tests/Snapshot/__Snapshots__ -name '*.png' | sed 's|.*/__Snapshots__/\([^/]*\)/.*|\1|' | sort | uniq -c`

Every golden below is **GREEN and STABLE on the finished design system** (tokens-v2 palette,
UIR-regenerated layouts). None of these move on a copy pass **unless** the operator changes the
copy/palette that surface renders.

| Suite | Goldens | Copy source | In the deferred final batch? |
|---|---:|---|---|
| `PanicFlowSnapshotTests` | 40 | script + verbatim user words | **No** — copy byte-identical |
| `StreakWidgetSnapshotTests` | 29 | luminance-only (no Theme); labels from `StreakWidgetStyle` | **No** — no palette; DRAFT widget strings could re-shoot if reworded |
| `SlipFlowSnapshotTests` | 24 | script | **No** — copy byte-identical |
| `DashboardSnapshotTests` | 10 | audited labels + pure data (ADR-11) | **No** — copy is final/data (R34.2) |
| `WidgetAdoptionSnapshotTests` | 8 | `widgetMomentCopy.json` (**DRAFT**) | **Maybe** — rides the founder pass on §0's DRAFT list |
| `StreakDetailSnapshotTests` | 6 | `StreakDetailCopy` (**DRAFT**) + the 43-body milestone catalog | **Maybe** — same DRAFT list |
| `MilestoneUnlockSnapshotTests` | 6 | milestone catalog + ME-3 frame (**DRAFT**) | **Maybe** — same DRAFT list |
| `EraseEverythingSnapshotTests` | 6 | `DiscreetSettingsCopy` erase strings (**DRAFT**) | **Maybe** — same DRAFT list |
| `SettingsSnapshotTests` | 4 | `DiscreetSettingsCopy` (5 S50 strings are DRAFT) | **Maybe** — same DRAFT list |
| `QuizSummarySnapshotTests` | 4 | `SummaryCopy` | **YES** — ME-4 rewrites this surface |
| `ResourcesSnapshotTests` | 2 | safety copy (operator-verified helplines) | **Maybe** — if the safety-copy items change |
| `PrivacyOverlaySnapshotTests` | 2 | none (hardcoded hexes) | **No** — until the overlay is deliberately re-recorded |
| **Total** | **141** | across **12** suites | |

**The age gate and the paywall still have ZERO goldens** — they are the two surfaces the deferred
final batch exists for, and QW-6 (age-gate crest) and ME-9 (paywall polish) both still owe work.

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
