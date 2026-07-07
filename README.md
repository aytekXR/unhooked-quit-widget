# unhooked-quit-widget

Native iOS quit-anything streak app (working title "Unhooked" — rename pending, Gate G0).
All product decisions live in `docs/` — start with `docs/resume-prompt.md`.

## Building

The `.xcodeproj` is generated, not committed:

```sh
brew install xcodegen
xcodegen generate
open Unhooked.xcodeproj
```

Portfolio stub packages live in `Packages/` and test standalone:

```sh
swift test --package-path Packages/StreakEngine
```

CI (`.github/workflows/ci.yml`) runs package units on Linux and the app's
unit / snapshot / UI-smoke lanes on a macOS runner. The TestFlight lane is
dormant until the rename gate clears — see `fastlane/Fastfile`.
