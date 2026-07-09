# unhooked-quit-widget

Native iOS quit-anything streak app — ships as **Ballast** (org `com.beyondkaira`;
the repo and internal target names keep the working title "Unhooked").
All product decisions live in `docs/` — start with `docs/resume-prompt.md`.
The live operator checklist is `docs/operator-expected.md`.

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
unit / snapshot / UI-smoke lanes on a macOS runner (10x-billed — keep runs
lean; docs-only commits carry `[skip ci]`). The TestFlight upload lane is LIVE
on green merges to `main` — see `fastlane/Fastfile`.
