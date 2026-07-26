# Ballast — App Icon Concepts

Standalone SVG extractions of the four app-icon concepts from the QA-passed design board, plus their dark/tinted variants and the zero-brand-color discreet alternates. All concepts render on the Horizon Gradient — Harbor Teal `#0C6F65` into Dusk Indigo `#5262BC` — the field reserved for the icon and marketing only. No red, no letterforms on brand icons, no habit imagery, no people.

> **These are SVG drafts, not store assets.** The final App Store render goes through the luminous-waterline raster pass (1024×1024 masters per concept, four appearances) and is assembled in **Apple Icon Composer** for the iOS 26 layered/dark/tinted/clear appearance set, per [creative-assets.md](../creative-assets.md). The winner replaces `AppIcon.appiconset` and the sizes in `brandkit/branding-assets/icons/`.

Open [icon-preview.html](./icon-preview.html) for the full board: light/dark/tinted rows, the composition grid, 29px legibility proofs, and the shoulder-distance dark comparison.

---

## 1. Surfaced Breath — Refined · **RECOMMENDED — build this**

<img src="./surfaced-breath.svg" width="120" alt="Surfaced Breath icon"> <img src="./surfaced-breath-dark.svg" width="120" alt="Surfaced Breath dark"> <img src="./surfaced-breath-tinted.svg" width="120" alt="Surfaced Breath tinted">

The existing crest geometry re-rendered with contemporary depth: crest enlarged ~8%, the hard 1px horizon replaced by a luminous waterline glow, the submerged reflection deepened at 18% opacity. The concept is proven and precious — polysemous (sun rising / head above water / breath surfacing), habit-neutral, comfortable on a family-visible home screen, and rename-proof with no letterforms. It is recommended because only the execution was dated, and the refinement preserves recognition for existing TestFlight users while fixing the hairline that vanished at 29pt.

## 2. Waterline Keel · prototype at 29pt first

<img src="./waterline-keel.svg" width="120" alt="Waterline Keel icon"> <img src="./waterline-keel-dark.svg" width="120" alt="Waterline Keel dark"> <img src="./waterline-keel-tinted.svg" width="120" alt="Waterline Keel tinted">

Calm Harbor Teal negative space above a thin Foam waterline; below it, a single rounded keel-weight in deep indigo hanging steady — the ballast itself. The only concept that literalizes the name without nautical cliché (anchors are banned territory — tattoo/navy connotations, and "stuck" contradicts forgiveness), and semantically the truest mark: steadiness comes from what's below the surface. Risk: bottom-weighted forms can read as sinking rather than held at glance distance, so it must be prototyped at 29pt before further investment.

## 3. Breath Ring · argue against, keep on file

<img src="./breath-ring.svg" width="120" alt="Breath Ring icon"> <img src="./breath-ring-dark.svg" width="120" alt="Breath Ring dark"> <img src="./breath-ring-tinted.svg" width="120" alt="Breath Ring tinted">

A single soft teal ring open at 12 o'clock, crest-dot resting in the gap, on a Dusk Indigo-to-near-black field — the momentum ring and breath bloom, the two glyphs users see daily, collapsed into one mark. Risk: ring marks are crowded territory (Activity rings, meditation apps), and differentiation depends entirely on the crest-dot surviving 29pt.

## 4. First Light · benchmark — do not ship

<img src="./first-light.svg" width="120" alt="First Light icon"> <img src="./first-light-dark.svg" width="120" alt="First Light dark"> <img src="./first-light-tinted.svg" width="120" alt="First Light tinted">

No shapes: the two-zone horizon field alone with a soft light bloom breathing at the waterline — the moment before dawn. Maximally discreet — indistinguishable from a wallpaper app at shoulder distance, which is a genuine feature for this audience — but near-invisible recall in App Library and search results. It stays on file as the ceiling of restraint the chosen icon is measured against.

## Discreet alternates · zero brand color, by definition

<img src="./calendar-discreet.svg" width="120" alt="Calendar-style discreet icon"> <img src="./calendar-discreet-dark.svg" width="120" alt="Calendar-style discreet dark"> <img src="./timer-discreet.svg" width="120" alt="Timer-style discreet icon"> <img src="./timer-discreet-dark.svg" width="120" alt="Timer-style discreet dark">

The Calendar-style and Timer-style alternates are **habit-context-free and carry zero brand color** — the disguise is the absence of identity, so nothing on the home screen hints at what the app is for. They are a privacy feature, not a brand surface: grays only, no red anywhere (even the disguise obeys the palette law), redrawn on the crest's geometric grid so they read as quality apps rather than clip art. The erase flow resets to the primary icon — an "erased" phone doesn't keep the disguise.

---

## Files

| File | Concept | Variant |
|---|---|---|
| [surfaced-breath.svg](./surfaced-breath.svg) | Surfaced Breath — Refined (recommended) | Light |
| [surfaced-breath-dark.svg](./surfaced-breath-dark.svg) | Surfaced Breath — Refined | Dark (field deepened `#121417` @52%) |
| [surfaced-breath-tinted.svg](./surfaced-breath-tinted.svg) | Surfaced Breath — Refined | Tinted template on `#1C1F24` |
| [surfaced-breath-clear.svg](./surfaced-breath-clear.svg) | Surfaced Breath — Refined | Clear (crest on glass; translucent by design, preview over a wallpaper) |
| [waterline-keel.svg](./waterline-keel.svg) | Waterline Keel | Light |
| [waterline-keel-dark.svg](./waterline-keel-dark.svg) | Waterline Keel | Dark (field deepened @50%) |
| [waterline-keel-tinted.svg](./waterline-keel-tinted.svg) | Waterline Keel | Tinted template |
| [breath-ring.svg](./breath-ring.svg) | Breath Ring | Light |
| [breath-ring-dark.svg](./breath-ring-dark.svg) | Breath Ring | Dark (field deepened @35%) |
| [breath-ring-tinted.svg](./breath-ring-tinted.svg) | Breath Ring | Tinted template |
| [first-light.svg](./first-light.svg) | First Light | Light |
| [first-light-dark.svg](./first-light-dark.svg) | First Light | Dark ("11pm" register, @55%) |
| [first-light-tinted.svg](./first-light-tinted.svg) | First Light | Tinted (reduces to the waterline alone) |
| [calendar-discreet.svg](./calendar-discreet.svg) | Discreet alternate — Calendar style | Light |
| [calendar-discreet-dark.svg](./calendar-discreet-dark.svg) | Discreet alternate — Calendar style | Dark |
| [timer-discreet.svg](./timer-discreet.svg) | Discreet alternate — Timer style | Light |
| [timer-discreet-dark.svg](./timer-discreet-dark.svg) | Discreet alternate — Timer style | Dark |
| [icon-preview.html](./icon-preview.html) | Full board | All concepts, 29px proofs, dark comparison |

## Related docs

- [creative-assets.md](../creative-assets.md) — App icon concepts section: full composition specs, palette law, production deliverables.
- [ui-ux-redesign.md](../ui-ux-redesign.md) — the UI redesign these assets serve.
