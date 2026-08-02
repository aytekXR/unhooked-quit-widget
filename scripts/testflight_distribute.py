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


def create_group(token: str, app_id: str, name: str) -> dict:
    """Create an INTERNAL group with automatic access to every build.

    `hasAccessToAllBuilds` is the important half. On an internal group it means the
    group receives EVERY build — past, present and future — as a property of the group
    itself, rather than because something remembered to attach each one. That is a
    structural guarantee where a CI step is only a procedural one, and it is why this
    is preferred over attaching build-by-build.

    Both attribute names are verified against Apple's own
    `BetaGroupCreateRequest.Data.Attributes` schema, not assumed.
    """
    log(f"  group   : '{name}' does not exist — creating it (internal, all-builds access)")
    payload = request(
        token,
        "POST",
        "/betaGroups",
        body={
            "data": {
                "type": "betaGroups",
                "attributes": {
                    "name": name,
                    # Internal: testers are Users on the ASC account, and builds reach
                    # them with NO Beta App Review wait. That is what makes this usable
                    # for a friends-and-family ring.
                    "isInternalGroup": True,
                    "hasAccessToAllBuilds": True,
                },
                "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
            }
        },
    )
    group = payload.get("data", {})
    if not group.get("id"):
        fail(f"Create succeeded but returned no group id — response: {json.dumps(payload)[:400]}")
    log(f"  created : '{name}' id={group['id']}")
    log(
        "::notice title=TestFlight group created::"
        f"'{name}' is an INTERNAL group with access to all builds. Add testers in "
        "App Store Connect > TestFlight > " + name + " (they must be Users on the account)."
    )
    return group


def resolve_or_create_group(token: str, app_id: str, name: str, allow_create: bool) -> tuple[str, bool]:
    """Return (groupId, hasAccessToAllBuilds)."""
    payload = request(token, "GET", "/betaGroups", {"filter[app]": app_id, "limit": 200})
    groups = payload.get("data", [])
    for group in groups:
        attrs = group["attributes"]
        if attrs.get("name", "").strip().lower() == name.strip().lower():
            internal = bool(attrs.get("isInternalGroup"))
            all_builds = bool(attrs.get("hasAccessToAllBuilds"))
            log(
                f"  group   : '{attrs.get('name')}' id={group['id']} "
                f"({'internal' if internal else 'EXTERNAL'}, "
                f"allBuilds={'yes' if all_builds else 'no'})"
            )
            if not internal:
                # External groups need Beta App Review before testers actually receive
                # a build. Attaching still succeeds, so warn rather than imply delivery.
                log(
                    "::warning title=External beta group::"
                    f"'{name}' is an EXTERNAL group — builds attached here reach testers only "
                    "after Beta App Review approves them."
                )
            return group["id"], all_builds

    available = ", ".join(sorted(g["attributes"].get("name", "?") for g in groups)) or "(none)"
    if not allow_create:
        fail(
            f"No TestFlight beta group named '{name}' on this app. "
            f"Groups that do exist: {available}. "
            "Create it in App Store Connect > TestFlight, pass --group with the real name, "
            "or re-run with --create-if-missing."
        )
    log(f"  (existing groups: {available})")
    created = create_group(token, app_id, name)
    return created["id"], bool(created.get("attributes", {}).get("hasAccessToAllBuilds"))


def group_tester_count(token: str, group_id: str) -> int:
    """How many testers are actually IN a group. Read-only (GET)."""
    payload = request(token, "GET", f"/betaGroups/{group_id}/betaTesters", {"limit": 200})
    return len(payload.get("data", []))


def audit_delivery(token: str, app_id: str, target_name: str, target_id: str) -> None:
    """S61 — the check that turns a silent no-op into a visible one.

    THE DEFECT THIS EXISTS FOR, because it was live and green for weeks. This job
    reported SUCCESS on every build while delivering to nobody. `ci.yml` targets
    `${TESTFLIGHT_GROUP:-Friends}`, the repo Variable is UNSET, so the target is the
    INTERNAL group 'Friends' — which has `hasAccessToAllBuilds`, so the caller takes
    the early-return branch above ("distribution is structural, not per-build") and
    exits happily. Nobody had ever asked whether that group contains a human. It
    contains zero. Meanwhile the real ring, 'Friends (external)', sits empty and
    unreferenced.

    So the trap is armed and invisible: the day the operator adds friends to the
    EXTERNAL ring — which is what `operator-expected.md` §5 tells them to do, and the
    only group that can legally hold non-team members — CI keeps cheerfully
    "distributing" to an empty internal group and those friends receive nothing. The
    job is green, Slack is green, and the beta silently does not happen.

    WHY THIS WARNS RATHER THAN CHANGING THE TARGET. Pointing CI at the external group
    would be the obvious fix and it is NOT safe to do unasked: Apple auto-submits a
    build for Beta App Review the moment it is attached to an external group, which is
    an irreversible send to Apple — and today it would be a send that CANNOT succeed,
    because `betaAppReviewDetail` has no contact and no phone. The target is the
    operator's call; this function only makes the consequence impossible to miss.

    WHY IT FAILS ONLY IN THE ONE CASE. An unconditional failure would redden every
    run today for a beta that has not started yet, and a gate that cries wolf is a
    gate people stop reading (the S54 ruling, in this repo's own words). It fails on
    exactly one condition — the target is empty AND an external group has real
    testers in it — because that combination cannot mean anything except
    misdirection, and it becomes true at the precise moment it starts costing
    something.
    """
    payload = request(token, "GET", "/betaGroups", {"filter[app]": app_id, "limit": 200})
    groups = payload.get("data", [])

    target_count = group_tester_count(token, target_id)
    log("")
    log("  delivery audit (read-only):")
    misdirected = []
    for group in groups:
        attrs = group["attributes"]
        name = attrs.get("name", "?")
        external = not bool(attrs.get("isInternalGroup"))
        count = target_count if group["id"] == target_id else group_tester_count(token, group["id"])
        mark = " <- CI TARGET" if group["id"] == target_id else ""
        log(f"    '{name}': {count} tester(s), {'EXTERNAL' if external else 'internal'}{mark}")
        if external and count > 0 and group["id"] != target_id:
            misdirected.append((name, count))

    if target_count == 0 and misdirected:
        names = ", ".join(f"'{n}' ({c} tester(s))" for n, c in misdirected)
        fail(
            f"MISDIRECTED DISTRIBUTION. This job attached builds to '{target_name}', which has "
            f"ZERO testers, while the EXTERNAL group(s) {names} hold real people who are "
            "therefore receiving NOTHING. Set the repo Variable TESTFLIGHT_GROUP to the group "
            "the testers are actually in (Settings > Secrets and variables > Actions > "
            "Variables). Note that targeting an external group makes Apple auto-submit each "
            "build for Beta App Review, so finish the review contact + phone first "
            "(scripts/testflight_test_info.py --list scores it)."
        )

    if target_count == 0:
        log(
            "::warning title=Distributing to an empty group::"
            f"'{target_name}' has ZERO testers, so this build reached nobody. That is expected "
            "while the beta has not started; it becomes a real problem the moment testers are "
            "added to a DIFFERENT group. Set TESTFLIGHT_GROUP when the ring is populated."
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
    ap.add_argument(
        "--create-if-missing",
        action="store_true",
        help="Create the group (internal, access to all builds) when it does not exist.",
    )
    args = ap.parse_args()

    log(f"TestFlight distribution -> group '{args.group}' (sweep={args.sweep})")
    token = make_token()
    app_id = resolve_app(token, args.bundle_id)
    group_id, all_builds = resolve_or_create_group(token, app_id, args.group, args.create_if_missing)

    if all_builds:
        # The group is configured to receive every build as a property of the group.
        # Attaching individually would be redundant at best and rejected at worst, and
        # — more to the point — the guarantee the operator asked for ("current AND
        # future builds automatically available") is already satisfied structurally.
        # Nothing here needs to run again, ever.
        log(
            f"  '{args.group}' has access to ALL builds — every current and future build is "
            "available to it automatically. No per-build attach needed."
        )
        # S61 — the early return above is exactly where the silent no-op lived:
        # "structural" was true and "reached a human" was never asked.
        audit_delivery(token, app_id, args.group, group_id)
        log("Done — distribution is structural, not per-build.")
        return

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

    # S61 — the per-build path needs the same audit as the structural one: "attached"
    # and "reached a human" are different claims, and only the second is the point.
    audit_delivery(token, app_id, args.group, group_id)
    log(f"Done — {attached} build(s) now available to '{args.group}'.")
    if timed_out:
        log(f"::warning::Still processing, not attached: {', '.join(timed_out)}. Re-run to pick them up.")


if __name__ == "__main__":
    main()
