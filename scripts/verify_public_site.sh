#!/usr/bin/env bash
# Verify the public site is genuinely serving — by reading BODIES, not status codes.
#
# WHY THIS IS NOT A STATUS-CODE SWEEP
# -----------------------------------
# Before this site existed, `beyondkaira.com/terms`, `/privacy` and every other
# path returned **HTTP 200 with a 16-byte body reading "beyondkaira.com"** — a
# catch-all, not a site. So a link-checker, an uptime probe, or any 404-based sweep
# reported the app's legal links as healthy while a reviewer tapping "Terms of Use"
# met a blank placeholder. That failure was invisible to automation and visible only
# to a human, which is exactly the kind Apple rejects for.
#
# Hence two non-obvious assertions here:
#   * every page must contain REAL WORDS, not just return 200; and
#   * a nonsense path must return 404 — if it returns 200, the catch-all is back and
#     every legal link is silently broken again.
#
# Usage: scripts/verify_public_site.sh [host]     (default ballast.beyondkaira.com)

set -uo pipefail

HOST="${1:-ballast.beyondkaira.com}"
BASE="https://${HOST}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0

ok()   { printf '  \033[32mPASS\033[0m  %s\n' "$1"; PASS=$((PASS+1)); }
bad()  { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; FAIL=$((FAIL+1)); }
head2() { printf '\n\033[1m%s\033[0m\n' "$1"; }

printf '\033[1mVerifying %s\033[0m\n' "$BASE"

# ---------------------------------------------------------------- 1. DNS + TLS
head2 "1. DNS and TLS"

if getent hosts "$HOST" >/dev/null 2>&1; then
  ok "DNS resolves ($(getent hosts "$HOST" | awk '{print $1}' | head -1))"
else
  bad "DNS does not resolve for $HOST"
fi

# A hostname-mismatch here is the specific failure the subdomain started with: the
# apex certificate did not list it, so every HTTPS request failed before nginx was
# ever consulted. Report that distinctly from "site is down".
tls_err="$(curl -sS -o /dev/null --max-time 15 "$BASE/" 2>&1)"
if [ -z "$tls_err" ]; then
  ok "TLS handshake and certificate cover $HOST"
else
  case "$tls_err" in
    *"certificate subject name"*|*"SSL"*|*"certificate"*)
      bad "TLS does not cover $HOST — certbot has not issued for it yet: $tls_err" ;;
    *) bad "cannot reach $BASE — $tls_err" ;;
  esac
fi

# ------------------------------------------------------------------- 2. pages
head2 "2. Pages serve real content"

# path | words that must appear in the body (case-insensitive, any one of them)
check_page() {
  local path="$1" want="$2" body="$TMP/body" code size
  # Pre-create the file: when curl cannot connect it never writes one, and an
  # unguarded `wc -c` then buries the real failure under a shell error.
  : > "$body"
  # curl already prints 000 on a connection failure, so this must not append its
  # own — hence `|| true` rather than `|| echo 000`.
  code="$(curl -sS -o "$body" -w '%{http_code}' --max-time 20 "$BASE$path" 2>/dev/null || true)"
  code="${code:-000}"
  size="$(wc -c < "$body" 2>/dev/null || echo 0)"

  if [ "$code" != "200" ]; then
    bad "$path -> HTTP $code (want 200)"
    return
  fi

  # The signature of the old catch-all: a 200 whose body is just the domain name.
  if [ "$size" -lt 200 ]; then
    bad "$path -> HTTP 200 but only ${size} bytes — this is the catch-all placeholder, not a page"
    return
  fi

  if grep -qiE "$want" "$body"; then
    ok "$path -> HTTP 200, ${size} bytes, contains real content"
  else
    bad "$path -> HTTP 200, ${size} bytes, but no expected words (/${want}/) — wrong page served?"
  fi
}

check_page "/"        "steady beats perfect|ballast"
check_page "/beta"    "testflight|beta"
check_page "/terms"   "terms|agreement|subscription"
check_page "/privacy" "privacy|data|policy"

# ------------------------------------------------------- 3. the catch-all guard
head2 "3. A missing path must fail LOUDLY"

nonsense="/definitely-not-a-page-$$"
code="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 20 "$BASE$nonsense" 2>/dev/null || true)"
code="${code:-000}"
if [ "$code" = "404" ]; then
  ok "$nonsense -> HTTP 404 (correct — no catch-all)"
else
  bad "$nonsense -> HTTP $code (want 404). A catch-all is back; every legal link is silently broken"
fi

# --------------------------------------------------------- 4. the name-clearance gate
head2 "4. Crawler gate (must stay closed until name clearance)"

body="$TMP/robots"
: > "$body"
code="$(curl -sS -o "$body" -w '%{http_code}' --max-time 20 "$BASE/robots.txt" 2>/dev/null || true)"
code="${code:-000}"
if [ "$code" = "200" ] && grep -qi "disallow: */" "$body"; then
  ok "/robots.txt disallows crawling"
else
  bad "/robots.txt -> HTTP $code and/or no Disallow — gate G0 (name clearance) is still open"
fi

for path in / /beta; do
  if curl -sS --max-time 20 "$BASE$path" 2>/dev/null | grep -qi 'name="robots"[^>]*noindex'; then
    ok "$path carries the noindex meta tag"
  else
    bad "$path is MISSING the noindex meta tag"
  fi
done

# ------------------------------------------------------------------ 5. headers
head2 "5. Security headers"

hdrs="$TMP/hdrs"
: > "$hdrs"
curl -sSI --max-time 20 "$BASE/" -o "$hdrs" 2>/dev/null || true
for h in "strict-transport-security" "x-content-type-options" "content-security-policy" "referrer-policy"; do
  if grep -qi "^$h:" "$hdrs"; then
    ok "$h present"
  else
    bad "$h missing (see docs/public-site-deploy.md §2)"
  fi
done

# -------------------------------------------------------------------- verdict
head2 "Result"
printf '  %d passed, %d failed\n\n' "$PASS" "$FAIL"
if [ "$FAIL" -gt 0 ]; then
  echo "NOT READY. Fix the failures above, then re-run."
  echo "Runbook: docs/public-site-deploy.md"
  exit 1
fi
echo "READY — pages serve real content, missing paths 404, and the crawler gate is closed."
echo "Tick the operator-expected.md §3 item and the critical-path submission dependency."
