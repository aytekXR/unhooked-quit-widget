# Design Tokens v2 — Ballast (Brand Kit Addendum)

| Field | Value |
|---|---|
| Document | Design Tokens v2 — the machine-consumable registry |
| Status | **Brand Kit ADDENDUM** — supplements `docs/frontend-brandkit.md`; §1 (essence), copy, and everything non-visual are untouched canon |
| Date | 2026-07-14 (Session 32 / UIR-0, roadmap §2.5) |
| Reason to exist | Close the R28.13-deferred WCAG `.contrast` findings **by construction** — the palette is machine-verified before anything renders it |
| Code home | `App/Sources/DesignSystem/` (`Theme.swift` is the single source of truth; this doc re-derives with it — the key-set pin in `ThemeContrastTests` names both) |
| Harness | `ContrastMath.swift` (WCAG 2.1 relative luminance + alpha compositing) runs over `Theme.contrastPairs` in the unit lane, every ratio below is script-computed, never eyeballed |
| Generator record | uipro (UI/UX Pro Max) v2.11.0 — see §8 |

## 1. What UIR-0 shipped (and deliberately did not)

- **Shipped:** the color-token registry + contrast harness; an in-place
  **colors-only** substitution across all 12 App/Sources view files (layout,
  structure, fonts, spacing, and every copy byte identical); the themed
  primitives (built + isolated — §6); `.contrast` restored to the a11y audit.
- **Not shipped (deliberate):** screen structural redesigns (UIR-1…4), type/
  spacing adoption by existing screens (the tokens exist as API; primitives
  consume them; screens migrate with their surfaces), motion polish (UIR-5),
  any widget change (widgets are luminance-only — brandkit §2.4 — and their 29
  goldens stay byte-stable), `AppSwitcherPrivacyOverlay` (its two hardcoded
  surface hexes ARE `surface/base`; left untouched so its goldens stay
  byte-stable — ruling R32.2).

## 2. Color tokens — LIGHT

**Bold hex** = minimal hue-preserving correction from brandkit §2 (the claimed
ratios were never machine-verified; four claims drift below their own
thresholds — §7). Ratios are the shipping registry's, vs the surfaces each
token actually renders on.

| Token | Light hex | vs base #F7F6F3 | vs raised #FFFFFF | vs sunken #EEECE7 | Tier |
|---|---|---|---|---|---|
| brand/primary | **#0C6F65** (was #0E7A6F) | 5.59 | 6.04 | 5.12 | 4.5 |
| brand/onPrimary | #FFFFFF | on primary **6.04** · on pressed **7.53** | | | 4.5 |
| brand/primaryPressed | #0A5F57 | — | — | — | (via onPrimary) |
| brand/secondary | **#5262BC** (was #5B6ABF) | 5.07 | 5.48 | 4.64 (fill: 3.0 tier ✓) | 4.5 |
| brand/accentFlame | #E8833A | decorative glyph only — exempt | | | — |
| semantic/positive | **#2C774B** (was #2E7D4F) | 5.05 | 5.46 | 4.62 | 4.5 |
| semantic/caution | **#8C6100** (was #9A6B00) | 5.08 | 5.49 | 4.65 | 4.5 |
| semantic/info | #3D6C9E | — | 5.47 | — | 4.5 |
| semantic/paused | #6E7681 | — | 4.59 | — | 3.0 (large) |
| content/primary | #1A1D21 | 15.65 | 16.91 | 14.33 | 4.5 |
| content/secondary | #565D66 | 6.16 | 6.66 | 5.64 | 4.5 |
| content/tertiary | **#80868E** (was #8A9097) | 3.40 | 3.67 | 3.11 | 3.0 (large ONLY) |
| border/hairline | #E2E0DB (canon) | 1.2-class | | | decorative-EXEMPT |
| border/strong | #80868E | 3.40 | — | — | 3.0 (UI) |

## 3. Color tokens — DARK (zero corrections; brandkit dark canon passes with margin)

| Token | Dark hex | vs base #121417 | vs raised #1C1F24 | vs sunken #0B0D0F |
|---|---|---|---|---|
| brand/primary | #4CC8B9 | 9.02 | 8.08 | 9.52 |
| brand/onPrimary | #08302B | on primary **7.00** · on pressed **8.52** | | |
| brand/primaryPressed | #6ADACB | — | — | — |
| brand/secondary | #93A0E8 | 7.41 | 6.64 | 7.82 |
| semantic/positive | #6FCE97 | 9.62 | 8.62 | 10.15 |
| semantic/caution | #E5B84B | 9.92 | 8.88 | 10.47 |
| semantic/info | #8FB6E0 | — | 7.82 | — |
| semantic/paused | #9AA3AD | — | 6.47 | — |
| content/primary | #F2F1EE | 16.34 | 14.63 | 17.24 |
| content/secondary | #A8AFB8 | 8.34 | 7.47 | 8.80 |
| content/tertiary | #6E757E | 3.96 | 3.55 | 4.18 |
| border/hairline | #2B3036 (canon) | decorative-EXEMPT | | |
| border/strong | #6E757E | 3.96 | — | — |

Surfaces (canon, unchanged): base #F7F6F3/#121417 · raised #FFFFFF/#1C1F24 ·
sunken #EEECE7/#0B0D0F · overlay #FFFFFF/#22262C.

## 4. Interaction & state tokens

| Token | Value | Grounds |
|---|---|---|
| state/pressed | `brand/primaryPressed` fill + scale 0.98 | onPrimary-on-pressed ≥7.5 both modes |
| **state/disabled (GHOST — R32.3)** | `content/secondary` label on `surface/sunken` fill | **Deliberately replaces brandkit §6.1's "40% opacity"**: a label at full alpha over a 35%-alpha primary fill computes 1.38–3.07:1 at every alpha/scheme, and the audited first quiz frame SHOWS a disabled Continue. The ghost form computes 5.64 L / 8.80 D — safe even if Apple's `.contrast` audit inspects disabled controls (its behavior there is undocumented). WCAG itself exempts inactive controls; this is margin, not compliance theater. |
| selection/tint | primary @ 12% over surface (`Theme.alpha.selectionTint`) | content/primary on it: 13.2:1. `brand/primary`-as-text on it: **4.72 L — TIGHT, registry-pinned**; never below `type/body` size |
| caution/tint | caution @ 10% over surface (`Theme.alpha.cautionTint`) | the alcohol-notice card fill; content 13.7 / 5.4 / 4.9 on it, all pinned |
| overlay/scrim | black @ **55%** (`Theme.alpha.scrim`) | uipro 40–60% rule; 55% is the LIGHT white-on-scrim 4.5 floor (50% computes 4.22) — floor-pinned in the unit lane |
| focus/selectionRing | `brand/primary` 2pt stroke | primary-vs-base ≥5.59 (3.0 UI tier) |
| pacer bloom alphas | ring .25 / fill .28 / ticks .35 | decorative, a11y-hidden — exempt |

**Exempt (documented, not gating):** border/hairline (<3:1 — WCAG 1.4.11
decorative separators); the tint fills vs their surfaces (~1.2 — backgrounds,
not boundaries); accentFlame (decorative glyph budget, never text/buttons).

## 5. Type · spacing · radii · motion · touch (brandkit §3/§5/§7 as machine registry)

Landed as `Theme.space/radius/motion/touch` (`ThemeMetrics.swift`). Values are
canon, restated: spacing 4/8/12/16/20/24/32/40/48; radii 10/16/24/full(pill);
motion instant 100ms · quick 200ms · standard 300ms spring(0.35, 0.85) · calm
600ms · breath 4-7-8 sinusoidal; touch 44 global / 56 panic+slip; type roles
per brandkit §3 (SF system only, Dynamic-Type-bound; Rounded for the streak
hero alone; no weight <400). Screens keep their current metrics until their
UIR session — the swap was colors-only (R32.2).

## 6. Themed primitives (BUILT, NOT ADOPTED — adoption is UIR-1…4's work)

| Primitive | File | States (registry-backed) |
|---|---|---|
| PrimaryButton + PrimaryButtonStyle | `Primitives/PrimaryButton.swift` | default (onPrimary/primary), pressed (pressed fill + 0.98), disabled (GHOST — §4), loading (width-locked inline spinner) |
| QuietButtonStyle | `Primitives/QuietButtonStyle.swift` | the escape hatch — content/secondary, `type/body`, never shrunk/hidden, ≥44pt |
| AnswerChipStyle | `Primitives/AnswerChipStyle.swift` | pill (`radius/full` — the shipped screens' 14pt rounding is a known drift UIR-1 closes); selected = primary/onPrimary, unselected = sunken/content-primary; checkmark glyph stays the caller's (never color-alone) |
| ThemedProgressBar | `Primitives/ThemedProgressBar.swift` | secondary-on-sunken (4.64/7.82, 1.4.11-clean); a11y semantics stay with the consumer (the quiz R28.13 hit-region shape) |
| themedCard / themedCautionCard / themedSelectionTint | `Primitives/ThemedContainers.swift` | raised+hairline card; the amber notice fill; the tinted-row fill |
| themedScreenSurface | `ColorToken+Color.swift` | surface/base behind a screen (adopted by the swapped screens NOW — it IS the swap's surface half) |

### StreakRing — SPEC (implementation rides UIR-2 with the dashboard)

The momentum ring (brandkit §4.1 custom-glyph budget #3): a circular arc,
`brand/secondary` stroke on a `surface/sunken` track ring (4.64/7.82 —
1.4.11-clean), stroke width 6pt at the dashboard-card size, round caps,
fill fraction = momentum %, animated with `motion/calm` on appear only
(never ticking); NEVER teal (momentum is indigo so streak and momentum are
never confused — brandkit §2.1); the ring is `.accessibilityHidden` with the
card's single a11y element speaking "momentum N percent" (brandkit §8); AX5:
the ring yields its slot per brandkit §11-Q3 (open question, decided in
UIR-2). Discreet mode renders the ring in `semantic/paused` neutrals.

## 7. Brandkit §2 claim corrections (machine-verified drift — R32.7)

| Brandkit claim | Machine (canon hex) | Correction |
|---|---|---|
| primary light "5.0:1 on white" | 5.21 (understated, passes) | adopted #0C6F65 → 6.04 for margin + sunken headroom |
| caution light "4.6:1" | 4.34 on base — **FAIL** | #8C6100 → ≥4.65 all surfaces |
| positive light "4.9:1" | 4.27 on sunken — **FAIL** | #2C774B → ≥4.62 all surfaces |
| secondary (as sunken text) | 4.18 — **FAIL** | #5262BC → ≥4.64 |
| content/tertiary "3.2:1-class" | 2.73–2.98 — **FAIL 3:1** | #80868E → ≥3.11 |
| onPrimary dark "7.4:1" | 7.00 (minor drift, passes) | no change |

Dark palette: all canon hexes verified PASS, zero changes.

## 8. Generator record — uipro (operator-expected §9, RESOLVED)

uipro v2.11.0 **is installed on the build box** — as an npm CLI on PATH
(`~/.nvm/versions/node/v20.20.2/bin/uipro`), which is why the S31 probes
(skills/plugins/MCP surfaces) missed it. `uipro init -a claude` installed the
"UI/UX Pro Max" skill into `.claude/skills/` (gitignored — machine-local
tooling, the `.codegraph` precedent). It was driven as the UIR-0 generator:

- **Overridden (palette):** its color DB has no on-canon deep-teal wellness
  row, and every candidate row ships a **red destructive token (#DC2626)** —
  banned product-wide. Its style picks for "wellness" (Neumorphism) self-report
  "Accessibility: low contrast". Its font pairings are Google web fonts (we are
  SF-system-only). All rejected; brandkit §2 stayed the palette source.
- **Adopted (as acceptance rules):** WCAG 4.5/3.0 floors (tightened to a ≥4.6
  working target for antialiasing margin), token-driven single-source theming,
  dark+light designed together, disabled 0.38–0.5 emphasis (met via the ghost
  form), visible focus affordance, tabular numerals for live counts, 40–60%
  scrim (floor-calibrated at 55%).

## 9. Acceptance — the shipping registry (32 pairs × 2 modes, all PASS)

Gate: normal text ≥4.5, large text & non-text UI ≥3.0. Enforced permanently by
`Tests/Unit/ThemeContrastTests.swift` (fires-on-violation calibrated with the
S28 white-on-system-teal defect fixture, which computes 2.57 — the gate
gates itself). Tightest pairs, watch-listed: `content/tertiary` on sunken
3.11 L (large-only tier) and `brand/primary`-as-text on selection tint 4.72 L.
Full per-pair output: run the unit suite, or `Theme.contrastPairs` ×
`ContrastMath.ratio(for:dark:)`.
