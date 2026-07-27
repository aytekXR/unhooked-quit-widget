#!/usr/bin/env python3
"""Attach TestFlight builds to a beta tester group via the App Store Connect API.

WHY THIS EXISTS RATHER THAN A `groups:` ARGUMENT ON `pilot`
-----------------------------------------------------------
`fastlane/Fastfile` uploads with `skip_waiting_for_build_processing: true`. That is
not incidental — fastlane's own documentation for the option says:

    "If set to true, the distribute_external option won't work and NO BUILD WILL BE
     DISTRIBUTED TO TESTERS. (You might want to use this option if you are using this
     action on CI and have to pay for 'minutes used' on your CI plan.)"

So `pilot(groups: [...])` cannot work while that flag is set, and the flag is set for
a real reason: this is a private repo, so macOS runner minutes bill at 10x, and Apple's
build processing can take 10+ minutes of pure idling. S52 already made exactly this
judgment call for the build changelog and rejected holding the runner for it.

The resolution is to keep the fast upload and do distribution from a FREE ubuntu runner
afterwards: this script polls the ASC API until the build is processed and then attaches
it to the group. macOS minutes spent: zero.

IDEMPOTENT by design — re-attaching a build that is already in the group is a no-op, so
this is safe to re-run, safe to run manually, and safe to run on every merge.

Usage:
    testflight_distribute.py --bundle-id com.beyondkaira.ballast --group Friends [--sweep 1]

Env (the same secrets the fastlane lane already uses):
    ASC_KEY_ID, ASC_ISSUER_ID, ASC_API_KEY_P8_BASE64
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

API = "https://api.appstoreconnect.apple.com/v1"
# Only a VALID build can be handed to testers. PROCESSING is the wait state;
# FAILED / INVALID are terminal and must fail loudly rather than spin.
TERMINAL_BAD = {"FAILED", "INVALID"}


def log(msg: str) -> None:
    print(msg, flush=True)


def fail(msg: str) -> "NoReturn":  # type: ignore[valid-type]
    # ::error:: renders in the GitHub Actions UI, so a failure here is visible
    # without opening the log.
    print(f"::error title=TestFlight distribution::{msg}", flush=True)
    sys.exit(1)


def make_token() -> str:
    try:
        import jwt  # PyJWT
    except ImportError:
        fail("PyJWT is not installed — the workflow step must `pip install pyjwt cryptography`.")

    for var in ("ASC_KEY_ID", "ASC_ISSUER_ID", "ASC_API_KEY_P8_BASE64"):
        if not os.environ.get(var):
            fail(f"{var} is empty. This job must only run when the TestFlight gate is enabled.")

    key_id = os.environ["ASC_KEY_ID"]
    issuer = os.environ["ASC_ISSUER_ID"]
    try:
        private_key = base64.b64decode(os.environ["ASC_API_KEY_P8_BASE64"]).decode("utf-8")
    except Exception as exc:  # noqa: BLE001
        fail(f"ASC_API_KEY_P8_BASE64 is not valid base64: {exc}")

    now = int(time.time())
    return jwt.encode(
        # ASC rejects tokens with a lifetime over 20 minutes.
        {"iss": issuer, "iat": now, "exp": now + 20 * 60, "aud": "appstoreconnect-v1"},
        private_key,
        algorithm="ES256",
        headers={"kid": key_id, "typ": "JWT"},
    )


def request(token: str, method: str, path: str, params=None, body=None):
    url = f"{API}{path}"
    if params:
        # ASC uses bracketed filter keys; quote_via=quote_plus would mangle them.
        url += "?" + urllib.parse.urlencode(params, safe="[]")
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {token}")
    if data:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            raw = resp.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", "replace")[:600]
        fail(f"{method} {path} -> HTTP {exc.code}\n{detail}")
    except urllib.error.URLError as exc:
        fail(f"{method} {path} -> network error: {exc}")


def resolve_app(token: str, bundle_id: str) -> str:
    payload = request(token, "GET", "/apps", {"filter[bundleId]": bundle_id, "limit": 200})
    apps = payload.get("data", [])
    if not apps:
        fail(
            f"No App Store Connect app with bundleId '{bundle_id}'. "
            "Check the ASC API key's team and that the app record exists."
        )
    app = apps[0]
    log(f"  app     : {app['attributes'].get('name')} ({bundle_id}) id={app['id']}")
    return app["id"]


def resolve_group(token: str, app_id: str, name: str) -> str:
    payload = request(token, "GET", "/betaGroups", {"filter[app]": app_id, "limit": 200})
    groups = payload.get("data", [])
    for group in groups:
        if group["attributes"].get("name", "").strip().lower() == name.strip().lower():
            attrs = group["attributes"]
            kind = "internal" if attrs.get("isInternalGroup") else "EXTERNAL"
            log(f"  group   : '{attrs.get('name')}' id={group['id']} ({kind})")
            if not attrs.get("isInternalGroup"):
                # External groups need Beta App Review before testers actually receive
                # a build. Attaching still succeeds, so warn rather than fail.
                log(
                    "::warning title=External beta group::"
                    f"'{name}' is an EXTERNAL group — builds attached here reach testers only "
                    "after Beta App Review approves them."
                )
            return group["id"]
    available = ", ".join(sorted(g["attributes"].get("name", "?") for g in groups)) or "(none)"
    fail(
        f"No TestFlight beta group named '{name}' on this app. "
        f"Groups that do exist: {available}. "
        "Create the group in App Store Connect > TestFlight, or pass --group with the real name."
    )


def newest_builds(token: str, app_id: str, limit: int):
    payload = request(
        token,
        "GET",
        "/builds",
        {
            "filter[app]": app_id,
            "sort": "-version",
            "limit": max(1, min(limit, 200)),
            "fields[builds]": "version,processingState,uploadedDate,expired",
        },
    )
    return payload.get("data", [])


def wait_until_processed(token: str, app_id: str, build_id: str, timeout_s: int) -> bool:
    """Poll one build until it is VALID. Returns False on timeout (soft-fail)."""
    deadline = time.time() + timeout_s
    delay = 20
    while time.time() < deadline:
        payload = request(token, "GET", f"/builds/{build_id}", {"fields[builds]": "version,processingState"})
        state = payload.get("data", {}).get("attributes", {}).get("processingState")
        version = payload.get("data", {}).get("attributes", {}).get("version")
        if state == "VALID":
            log(f"  build {version}: VALID")
            return True
        if state in TERMINAL_BAD:
            fail(f"Build {version} finished processing as {state} — nothing to distribute.")
        log(f"  build {version}: {state}, waiting {delay}s …")
        time.sleep(delay)
        delay = min(delay + 10, 60)  # back off, but stay responsive
    return False


def attach(token: str, group_id: str, build_id: str, version: str) -> None:
    # POST to the relationship is additive and idempotent: a build already in the
    # group is accepted without duplication, which is what makes re-runs safe.
    request(
        token,
        "POST",
        f"/betaGroups/{group_id}/relationships/builds",
        body={"data": [{"type": "builds", "id": build_id}]},
    )
    log(f"  attached build {version} -> group")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--bundle-id", default="com.beyondkaira.ballast")
    ap.add_argument("--group", default="Friends")
    ap.add_argument(
        "--sweep",
        type=int,
        default=1,
        help="How many of the newest builds to attach. 1 = just this run's build. "
        "Use a larger number once to back-fill builds uploaded before this job existed.",
    )
    ap.add_argument("--timeout", type=int, default=1500, help="Seconds to wait for processing.")
    args = ap.parse_args()

    log(f"TestFlight distribution -> group '{args.group}' (sweep={args.sweep})")
    token = make_token()
    app_id = resolve_app(token, args.bundle_id)
    group_id = resolve_group(token, app_id, args.group)

    builds = newest_builds(token, app_id, args.sweep)
    if not builds:
        fail("The app has no builds at all — nothing to distribute.")

    attached = 0
    timed_out = []
    for build in builds:
        attrs = build["attributes"]
        version, state = attrs.get("version"), attrs.get("processingState")
        if attrs.get("expired"):
            log(f"  build {version}: expired, skipping")
            continue
        if state != "VALID":
            if not wait_until_processed(token, app_id, build["id"], args.timeout):
                timed_out.append(version)
                continue
        attach(token, group_id, build["id"], version)
        attached += 1

    if attached == 0:
        # Distinguish "Apple is slow" from "this is broken" — only the second is a defect.
        if timed_out:
            fail(
                f"Timed out waiting for build(s) {', '.join(timed_out)} to finish processing. "
                "The upload succeeded; re-run this job (workflow_dispatch) to attach them."
            )
        fail("No build could be attached. See the log above.")

    log(f"Done — {attached} build(s) now available to '{args.group}'.")
    if timed_out:
        log(f"::warning::Still processing, not attached: {', '.join(timed_out)}. Re-run to pick them up.")


if __name__ == "__main__":
    main()
