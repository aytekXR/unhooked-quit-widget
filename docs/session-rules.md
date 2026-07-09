# Session Rules — Resume-Driven Development (permanent)

| Field | Value |
|---|---|
| Document | Session Rules v1.0 |
| Created | 2026-07-07 (Session 02) |
| Status | Permanent project rules — future sessions MUST follow them |

These rules govern every implementation session in this repository. They complement
(never override) `agent-workflows.md`, `test-suite.md` §7, and the canonical docs.

## Source of truth

Everything under `./docs/` is the project documentation and source of truth. Read it
before writing code. Documentation always overrides assumptions.

## One session, one objective

1. Each execution is exactly ONE session.
2. `./docs/resume-prompt.md` defines the ONLY objective of the current session.
3. No work outside its scope: no feature creep, no "while I'm here", no unrelated
   refactors. Code-quality improvements are allowed only when required by the current
   resume prompt, a failing test, or CI.

## Development process

- Follow the documented workflows (`agent-workflows.md`) in order; respect all gates;
  never skip validation steps.
- TDD whenever applicable, per the binding working agreement in `test-suite.md` §7
  (red first; paste the red run under a `## Red` heading; minimal green; refactor on
  green; never weaken a QA assertion; safety-critical paths acceptance-test-first
  with zero disabled tests).

## CodeGraph (permanent, added 2026-07-09 Session 06)

The repository is indexed by CodeGraph (`.codegraph/` at the repo root — gitignored,
machine-local). Rules for every session and every spawned agent:

1. **Query it first.** For any "how does X work / where is X / what depends on X"
   question, use the `codegraph_explore` MCP tool (shell fallback:
   `codegraph explore "<symbols or question>"`) BEFORE grep/find or manual file
   reading — one call returns the verbatim line-numbered source plus call paths and
   blast radius. Pass this instruction into subagent/workflow prompts explicitly.
2. **Check blast radius before editing.** When changing a public symbol, consult the
   explore output's dependents/callers list (or `codegraph callers <symbol>`) before
   the edit, not after CI fails.
3. **Update it before session end.** Run `codegraph sync` (or `codegraph init` if the
   index is missing) as a mandatory session-end step, BEFORE the final commit/push, so
   the next session starts on a fresh index. Verify with `codegraph status`.
4. The index is a cache, not a source of truth — on any suspicion of staleness (mass
   renames, generated files), re-run `codegraph sync` and re-query.

## Documentation updates at session end

1. **`docs/past-prompts.md`** — append (never rewrite) a dated entry: completed
   objective, major decisions, important notes, known limitations.
2. **`docs/resume-prompt.md`** — overwrite with the NEXT session's objective, derived
   from `docs/roadmap.md` and the current repo state. The next prompt must be small,
   independently executable, one-session-sized, with a clear definition of done. The
   resume prompt must carry the CodeGraph rules forward (use `codegraph_explore` first;
   `codegraph sync` before session end).
3. **CodeGraph index** — run `codegraph sync` and confirm `codegraph status` is clean
   (see the CodeGraph section below).

## Git & CI verification

1. Review changes, commit everything with a meaningful message, `git push`.
2. Inspect GitHub Actions (`gh` CLI), wait for workflows, verify results.
3. Failures: small issue → fix, commit, push, re-verify until green. Large issue →
   do NOT attempt a risky refactor; document the failure + root cause + what remains,
   update the relevant docs, and put the fix at the top of the next resume prompt.

## Quality rules

Never leave documentation, roadmap, or resume-prompt inconsistent; never leave
completed work undocumented. The repository must always be resumable by another
agent from `./docs/resume-prompt.md` alone.

## Environment note (recorded 2026-07-07, applies until the dev machine changes)

The build machine is Linux (no Xcode, no simulators). Consequences:
- App-target tests run only in CI on macOS runners; package tests (`swift test`)
  also run locally via a Linux Swift toolchain.
- "Paste the red run" is satisfied with local `swift test` output for packages and
  with the CI run for app lanes; red→green is driven through CI commits.
- The repo is private: macOS CI minutes bill at 10x — keep macOS jobs lean, prefer
  Linux lanes where honest, and cancel superseded runs (already configured in ci.yml).
- Physical-device work (panic-latency spike, widget device matrix, TestFlight) is
  operator-owned and can only be scaffolded, never executed, from this machine.
- **Parse gate (added 2026-07-09, Session 08):** before EVERY push that touches Swift
  sources, run `swiftc -parse` on each touched file (syntax-only — works on the Linux
  toolchain without Xcode or module resolution). A backslash-line-continuation typo
  inside a string literal reached CI in Session 08 and cost a billed macOS run that
  produced no red evidence; the parse gate makes that class of failure impossible.
