#!/usr/bin/env python3
"""Lint the public site's VISIBLE copy against the brand's own tone rules.

WHY A LINT AND NOT A PROMISE
----------------------------
`redesign/product-copy.md` §"Non-negotiables" and `redesign/marketing-strategy.md`
§3 "Tone rules" are binding on every asset, and marketing copy has no golden, no
snapshot and no unit test behind it. This is the gate. It costs nothing, runs on
Linux, and it fires on the mutation it claims to catch (`--self-test`).

TWO DESIGN DECISIONS THAT MATTER, BOTH LEARNED FROM THIS REPO'S OWN MISTAKES
---------------------------------------------------------------------------
1. **It scans VISIBLE TEXT, not the file.** A naive substring walk over HTML fires
   on `!important` in the stylesheet, on `noindex` in a comment, and on every
   attribute value. So `<style>`, `<script>`, HTML comments and all tags are
   stripped first, and only what a reader sees is scanned. The S50 ledger records
   a lint that reddened CI because a plain `Section(` matched a method name; this
   is the same class of bug, avoided the same way.

2. **Some banned words are legitimate when NEGATED.** The approved copy says
   "There's no red in this app, no countdowns, and no lecture" — a lint that bans
   "countdown" and "red" outright would reject the very sentence the brand
   direction drafts. Those two are negation-aware: a match is a violation only
   when it is NOT preceded by a negator.

Usage:
    site_copy_lint.py                 # lint site/*.html — exit 1 on any violation
    site_copy_lint.py --self-test     # prove every rule fires on a mutation
"""

from __future__ import annotations

import argparse
import glob
import html
import os
import re
import sys

SITE_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "site")

# A corpus floor, so a rename or a bad glob can never make this lint vacuously
# green. The S42 precedent: the account-absence lint gained exactly this.
MIN_PAGES = 2

# ---------------------------------------------------------------------- rules

# Never acceptable in visible marketing copy. Sources, in order:
#   product-copy.md §"Non-negotiables"  — no exclamation marks, no urgency,
#                                         "a slip" never "relapse"/"failure"
#   marketing-strategy.md §3 tone rule 3 — no fight/battle/war language
#   marketing-strategy.md §3 tone rule 5 — hedge every claim
#   copy-pass-checklist.md               — "clean day(s)" is an identity statement
HARD_BANS: list[tuple[str, str]] = [
    (r"!", "exclamation mark (tone rule 6: zero exclamation marks)"),
    (r"\brelapses?\b", "'relapse' — always 'a slip'"),
    (r"\bfailures?\b", "'failure' — always 'a slip'"),
    (r"\bfailed\b", "'failed' — always 'a slip'"),
    (r"clean slate", "'clean slate' is banned by the CI lexicon"),
    (r"\bclean days?\b", "'clean day(s)' is an AA/NA identity statement"),
    (r"\bhurry\b", "urgency"),
    (r"limited time", "urgency / fake scarcity"),
    (r"\bact (?:now|fast)\b", "urgency"),
    (r"don'?t miss", "urgency / FOMO"),
    (r"while you (?:still )?can", "urgency"),
    (r"\bguarantee[sd]?\b", "unhedged claim (tone rule 5)"),
    (r"\bcure[sd]?\b", "medical claim"),
    (r"\bproven\b", "unhedged claim (tone rule 5)"),
    (r"\bwar\b", "fight/battle/war language (tone rule 3)"),
    (r"\bbattles?\b", "fight/battle/war language (tone rule 3)"),
    (r"\bfight(?:ing|s)?\b", "fight/battle/war language (tone rule 3)"),
    (r"\bcombat\b", "fight/battle/war language (tone rule 3)"),
]

# Legitimate ONLY when negated — the brand copy names these to disown them.
NEGATION_AWARE: list[tuple[str, str]] = [
    (r"\bcountdowns?\b", "countdown language — allowed only when negated"),
    (r"\bred\b", "'red' — nothing red; allowed only when negated"),
]
NEGATORS = re.compile(r"(?:\bno\b|\bnot\b|\bnever\b|\bzero\b|\bwithout\b)[^.;:]{0,40}$", re.I)

# Every page must carry these. Each one is a thing that is expensive to notice late.
REQUIRED_IN_EVERY_PAGE: list[tuple[str, str]] = [
    (r"noindex", "the noindex robots meta tag (name clearance / gate G0 is open)"),
    (r"isn'?t medical care", "the 'it isn't medical care' disclaimer"),
]

# Self-containment: the origin's CSP forbids all of these, so a violation is a
# page that silently renders wrong in production but fine in a local browser.
STRUCTURE_BANS: list[tuple[str, str]] = [
    (r"<script\b", "a <script> tag — the CSP has no script-src, so it will not run"),
    (r"<form\b", "a <form> — the CSP forbids form-action"),
    (r"@import", "@import — external CSS is blocked"),
    (r"""(?:href|src)\s*=\s*["']\s*(?:https?:)?//""", "an external href/src — blocked by the CSP"),
    (r"url\(\s*['\"]?\s*(?:https?:)?//", "an external url() in CSS — blocked by the CSP"),
]


# ------------------------------------------------------------------- extraction


def visible_text(markup: str) -> str:
    """Reduce HTML to what a reader actually sees.

    Order matters: comments and <style>/<script> bodies must go BEFORE tags are
    stripped, or their contents survive as text.
    """
    text = re.sub(r"<!--.*?-->", " ", markup, flags=re.S)
    text = re.sub(r"<style\b.*?</style\s*>", " ", text, flags=re.S | re.I)
    text = re.sub(r"<script\b.*?</script\s*>", " ", text, flags=re.S | re.I)
    # <head> carries <title> and meta content — real user-visible words live in
    # the title, so keep the title's text and drop the rest of head's tags.
    text = re.sub(r"<[^>]+>", " ", text)
    text = html.unescape(text)
    return re.sub(r"\s+", " ", text)


def line_of(markup: str, needle_start: int) -> int:
    return markup.count("\n", 0, needle_start) + 1


# ------------------------------------------------------------------------ lint


def lint_text(label: str, text: str) -> list[str]:
    problems: list[str] = []

    for pattern, why in HARD_BANS:
        for match in re.finditer(pattern, text, re.I):
            snippet = text[max(0, match.start() - 45) : match.end() + 45].strip()
            problems.append(f"{label}: {why} -> …{snippet}…")

    for pattern, why in NEGATION_AWARE:
        for match in re.finditer(pattern, text, re.I):
            before = text[max(0, match.start() - 60) : match.start()]
            if NEGATORS.search(before):
                continue
            snippet = text[max(0, match.start() - 45) : match.end() + 45].strip()
            problems.append(f"{label}: {why} -> …{snippet}…")

    return problems


def lint_page(path: str) -> list[str]:
    with open(path, encoding="utf-8") as fh:
        markup = fh.read()
    label = os.path.basename(path)
    problems = lint_text(f"{label} (visible copy)", visible_text(markup))

    for pattern, why in REQUIRED_IN_EVERY_PAGE:
        if not re.search(pattern, markup, re.I):
            problems.append(f"{label}: MISSING {why}")

    for pattern, why in STRUCTURE_BANS:
        match = re.search(pattern, markup, re.I)
        if match:
            problems.append(f"{label}:{line_of(markup, match.start())}: {why}")

    return problems


# ------------------------------------------------------------------- self-test


def self_test() -> int:
    """Prove each rule fires. A lint nobody has seen fail is not evidence."""
    failures: list[str] = []
    checked = 0

    mutations = [
        ("Quit anything today!", "exclamation"),
        ("After a relapse you start over.", "relapse"),
        ("A failure is not the end.", "failure"),
        ("Start with a clean slate.", "clean slate"),
        ("Forty clean days and counting.", "clean days"),
        ("Hurry, the offer ends soon.", "hurry"),
        ("Limited time offer.", "limited time"),
        ("Act now to save.", "act now"),
        ("Don't miss out.", "don't miss"),
        ("Join while you still can.", "while you can"),
        ("Guaranteed to work.", "guarantee"),
        ("A cure for vaping.", "cure"),
        ("Clinically proven results.", "proven"),
        ("Win the war on nicotine.", "war"),
        ("Your battle with alcohol.", "battle"),
        ("Fight the urge.", "fight"),
        ("Combat cravings.", "combat"),
        ("A countdown to your goal.", "countdown (unnegated)"),
        ("The button turns red when you slip.", "red (unnegated)"),
    ]
    for text, name in mutations:
        checked += 1
        if not lint_text("mutation", text):
            failures.append(f"rule did NOT fire on {name!r}: {text!r}")

    # The negation carve-out must actually carve out — otherwise the lint rejects
    # the brand's own approved sentence.
    approved = [
        "There's no red in this app, no countdowns, and no lecture — just the next hour.",
        "No countdown timers. No fake discounts. Cancel in one tap.",
        "Milestones say 'commonly reported,' because we won't promise what we can't know.",
        "No red anywhere in the app — errors are amber, because shame doesn't help.",
    ]
    for text in approved:
        checked += 1
        found = lint_text("approved", text)
        if found:
            failures.append(f"lint REJECTED approved copy {text!r} -> {found}")

    # Visible-text extraction must hide what it claims to hide, or every page
    # with `!important` in its stylesheet reds out.
    checked += 1
    hidden = "<style>a{animation:none !important}</style><!-- don't miss --><p>Calm copy.</p>"
    if lint_text("extract", visible_text(hidden)):
        failures.append("visible_text() leaked <style>/comment content into the scan")

    checked += 1
    if "Calm copy." not in visible_text(hidden):
        failures.append("visible_text() dropped real body text")

    # And it must NOT hide the title, which is user-visible in a browser tab.
    checked += 1
    if "Steady beats perfect" not in visible_text("<head><title>Steady beats perfect.</title></head>"):
        failures.append("visible_text() dropped the <title>, which readers do see")

    print(f"self-test: {checked} checks")
    for problem in failures:
        print(f"  FAIL  {problem}")
    if failures:
        print(f"self-test FAILED — {len(failures)} problem(s)")
        return 1
    print("self-test PASSED — every rule fires, and no approved sentence is rejected")
    return 0


# ------------------------------------------------------------------------ main


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--self-test", action="store_true", help="Prove the rules fire, then exit.")
    ap.add_argument("--dir", default=SITE_DIR, help="Directory of pages to lint.")
    args = ap.parse_args()

    if args.self_test:
        return self_test()

    pages = sorted(glob.glob(os.path.join(args.dir, "*.html")))
    if len(pages) < MIN_PAGES:
        print(
            f"::error::site copy lint scanned {len(pages)} page(s) in {args.dir}, "
            f"expected at least {MIN_PAGES}. A green result here would be vacuous."
        )
        return 1

    all_problems: list[str] = []
    for path in pages:
        all_problems.extend(lint_page(path))

    print(f"site copy lint: {len(pages)} page(s) scanned in {args.dir}")
    for path in pages:
        print(f"  - {os.path.basename(path)}")
    if all_problems:
        print()
        for problem in all_problems:
            print(f"::error::{problem}")
        print(f"\n{len(all_problems)} violation(s).")
        return 1
    print("clean — no tone, structure or self-containment violations.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
