# Ballast — Brand Guidelines (v1)

**Ballast** — the weight that keeps you steady. iOS-first quit-anything streak widget.
Tagline: *Quit habits. Keep momentum.*

This is the working summary. The full source brand kit is in `brand-guidelines-full.md`.

## 1. Essence
Steady · Discreet · Forgiving · Honest · Quietly proud.
Never: clinical, preachy, macho, shame-based, cutesy, recovery-culture coded.
Voice: coach, never judge. The user's words outrank ours. "A slip," never "a relapse."

## 2. Name
"Ballast" sits in the steady/momentum naming territory: no vice in the name, comfortable
on a shared lock screen, pronounceable in Turkish, abstract enough that the ASO subtitle
carries the keywords ("Quit Vaping, Porn & Alcohol").

## 3. Color
Calm, low-arousal. Primary = deep teal (cool water). One hot color (ember flame) reserved
for the streak glyph only. **No red anywhere** — cautions and errors are amber.
Full token values in `tokens.json`. Dark mode is the primary design target.

## 4. Typography
SF Pro (system) everywhere; SF Pro Rounded for streak numerals only. No custom fonts,
no light weights, monospaced digits wherever numbers tick. Key roles:
- streakHero 64pt Bold Rounded · panicReason 40pt Semibold (the user's own words)
- titleXL 34 · title 22 · body 17 · secondary 15 · caption 13
- widget numerals Semibold–Bold, labels 12pt Medium +0.3 tracking

## 5. App icon — "the surfaced breath"
A soft off-white circle cresting a thin horizon line on a teal→indigo vertical gradient.
Reads as sun rising / head above water / breath surfacing. No letterforms, no flame,
no chain, no lock. Files in `icons/`:
- `AppIcon-light-{1024,180,167,152,120,87,80,76,60,58,40,29}.png`
- `AppIcon-dark-{1024,180,120}.png` · `AppIcon-tinted-{1024,180,120}.png`
All square — iOS applies the mask. Discreet alternates ("Calendar style", "Timer style")
carry zero brand color by design.

## 6. Widgets & lock screen
Lock-screen accessory families are pure luminance (system tints them); meaning lives in
glyph + text, never hue. Home widgets use surface tokens + flame at glyph size only.
Every family ships a discreet variant ("Day 34", Panic → "Reset").

## 7. Social & marketing rules
- Angles we own: lock-screen panic button, forgiveness ("a slip isn't day zero"), privacy
  ("No account. No cloud we control. One-tap erase."), multi-habit one price.
- Never: before/after imagery, fear statistics, fake urgency/discounts, explicit terms,
  medical claims. Adult-content references stay clinical.
- Milestone share cards are anonymous-safe: no habit named, no category vernacular.
- Ready-made graphics in `social/` (post 1080², story 1080×1920, milestone card 1080²,
  X header 1500×500).

## 8. Motion
Breath, not bounce. Panic flow opens with zero decorative animation. Widgets never animate.
Celebrations are 600ms fades + one soft haptic — never confetti.
