# Golden batch — the ONE final snapshot re-record for the operator's §3 copy sitting

| Field | Value |
|---|---|
| Status | LIVE plan — prepared in Session 40 (UIR-5c), the consolidated golden-batch prep |
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
