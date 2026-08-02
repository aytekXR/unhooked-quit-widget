#!/usr/bin/env python3
"""Fill the TestFlight Test Information that external distribution requires, and check it.

WHY THIS EXISTS
---------------
`testflight_distribute.py` gets BUILDS to a group. `testflight_testers.py` gets PEOPLE
into one. Neither fills the **Test Information**, and until it is filled an external
group cannot ship a build at all: Apple sends every externally-distributed build for
Beta App Review, and Beta App Review reads fields that CI has never touched.

`docs/testflight-beta-kit.md` §1.4 says those fields are hand-typed in App Store
Connect. That was true and it was the last hand-work left in the beta path, so this
script closes it: the same paste-ready text, written through the API, verifiable in
one command, and re-runnable without duplicating anything.

WHAT EXTERNAL DISTRIBUTION ACTUALLY NEEDS — measured, not assumed
-----------------------------------------------------------------
  * a BetaAppLocalization for the app's primary locale carrying a **Beta App
    Description** and a **feedback email**. The app had ZERO rows before this script
    (`GET /apps/{id}/betaAppLocalizations` returned an empty collection).
  * a BetaAppReviewDetail carrying the **review contact**. The row exists from birth
    (its id IS the app id) but every attribute was null.
  * an EXTERNAL beta group — see `testflight_testers.py`, and the constraint recorded
    there: an internal group can never be converted.
  * a VALID build whose `externalBuildState` is READY_FOR_BETA_SUBMISSION.

Every request shape below was verified against Apple's own published schema JSON
(developer.apple.com/tutorials/data/documentation/appstoreconnectapi/...) rather than
recalled:
  * `BetaAppLocalizationCreateRequest.Data.Attributes` -> locale (REQUIRED),
    description, feedbackEmail, marketingUrl, privacyPolicyUrl, tvOsPrivacyPolicy
  * `BetaAppLocalizationUpdateRequest.Data.Attributes` -> the same, minus locale
  * `BetaAppReviewDetailUpdateRequest.Data.Attributes` -> contactFirstName,
    contactLastName, contactPhone, contactEmail, demoAccountName,
    demoAccountPassword, demoAccountRequired, notes.

    **APPLE'S PUBLISHED SCHEMA IS WRONG ABOUT contactPhone, and the live API is the
    authority.** The docs JSON marks all eight attributes `optional`. Sending the
    PATCH without a phone is rejected:

        HTTP 409  ENTITY_ERROR.ATTRIBUTE.REQUIRED
        "You must provide a value for the attribute 'contactPhone' with this request"
        source.pointer: /data/attributes/contactPhone

    Measured 2026-07-31 against the live account, not inferred. So the phone is a hard
    input this script cannot supply or invent — it is the operator's own number — and
    `--contact-phone` is pre-flighted below rather than left to surface as a raw 409
    half-way through a run that has already written other fields.
  * `BetaBuildLocalizationCreateRequest.Data.Attributes` -> locale (REQUIRED), whatsNew
  * `BetaAppReviewSubmissionCreateRequest.Data.Relationships` -> build (REQUIRED); the
    object carries NO attributes, so submitting is a pure "this build, please".

SAFETY
------
DRY-RUN BY DEFAULT, like its two sibling scripts. Nothing is written until --apply.
`--submit-for-beta-review` is separate from --apply on purpose: filling fields is
private and reversible, and handing a build to Apple's reviewers is neither.

Usage:
    # What is there now, and is it enough for an external ring? Read-only.
    testflight_test_info.py --list --secrets-file secret.yml

    # Fill everything. Prints the plan; --apply executes.
    testflight_test_info.py --secrets-file secret.yml --contact-phone '+90...' --apply

    # Hand the newest build to Beta App Review (needs --apply too).
    testflight_test_info.py --secrets-file secret.yml --submit-for-beta-review --apply

Credentials: ASC_KEY_ID, ASC_ISSUER_ID, ASC_API_KEY_P8_BASE64 from the environment,
or --secrets-file secret.yml to read them from the operator's local mirror.
"""

from __future__ import annotations

import argparse
import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0])

from testflight_testers import Client, fail, load_secrets_file, log, resolve_app  # noqa: E402

# --------------------------------------------------------------------------- copy
#
# VERBATIM from docs/testflight-beta-kit.md. The doc is the source the operator reads
# and signs; this file is what actually reaches Apple. They must move together — if
# you edit one, edit the other in the same commit.

# §1.2 — Beta App Description. Shown to external testers in TestFlight.
BETA_APP_DESCRIPTION = """\
Ballast helps you cut down or stop a habit — vaping, adult content, alcohol, \
cannabis, doomscrolling, or something you name yourself. It keeps your streak, holds \
on to the reasons you gave for starting, and puts a panic button one tap away on your \
lock screen for when an urge shows up.

Everything stays on your device. There is no account to create and nothing to sign in \
to."""

# §1.3 — Beta App Review notes. Bound by review-notes.md §4: no latency number, no
# "anonymous", no medical vocabulary, no explicit terms, nothing dormant called live.
BETA_REVIEW_NOTES = """\
Ballast is an on-device habit-tracking utility. It stores all data on-device, requires \
no account, and puts a lock-screen "panic" control one tap from a short breathing \
exercise.

A fresh install opens on a birth-year age check (17+). An under-17 entry routes to a \
resources screen; no habit content is reachable before the gate. A passing entry leads \
to an onboarding quiz of 11-13 steps (two appear only for a custom habit or a "cut \
down" goal), then a personalized summary, then the subscription screen.

To exercise the panic control: add the "Panic" control from the Control Center gallery \
(or a lock-screen control slot, or the Action button), or add the "Streak" lock-screen \
widget, which carries the same button. It launches the app directly into a full-screen \
urge intervention. It needs no account and no network, and works with notifications \
off and Focus on. A second, visually neutral "Reset" control opens the same flow for \
users who want it discreet.

One trackable category is adult-content use. It is described in clinical terms ("Adult \
content") throughout, and no explicit terminology or imagery appears anywhere in the \
app. The app is a self-tracking utility and makes no medical or clinical claim.

Analytics are opt-in and currently dormant in this build - no analytics data leaves \
the device. Billing is StoreKit via RevenueCat."""

# §1.1 — "What to Test", per build.
WHATS_NEW = """\
Ballast is a habit-tracking app: you pick something you want to cut down or stop, and \
it keeps a streak, saves your own reasons in your own words, and puts a panic button \
on your lock screen for the moment an urge hits.

Please walk the whole first-run: the age check, the questions, the summary, and then \
add the "Streak" widget when it offers. After that, try the panic button from your \
lock screen at least once, and log a slip at least once.

The subscription screen after the summary has no close button, and that is expected. \
In TestFlight the purchase is free and not a real charge - please go through it so the \
rest of the app opens up. If you would rather not, quit the app and reopen it and you \
will land on the main screen.

Two known oddities, both Apple's and neither a bug: your test subscription will renew \
once a day for six days and then switch itself off, and the phone helpline list only \
has real numbers for the US and Turkey right now - everywhere else shows written \
guidance instead.

Tell me anything that felt confusing, slow, or wrong - especially wording. Screenshots \
from inside TestFlight are the easiest way."""

# The app links to these from the paywall (Shared/Sources/AppIdentifiers.swift). The
# same URL belongs in Test Information so a reviewer meets the same page a tester does.
PRIVACY_POLICY_URL = "https://ballast.beyondkaira.com/privacy"
MARKETING_URL = "https://ballast.beyondkaira.com/"

DEFAULT_FEEDBACK_EMAIL = "aytek@beyondkaira.com"


# ----------------------------------------------------------------------- reading


def primary_locale(api: Client, app_id: str) -> str:
    app = api.request("GET", f"/apps/{app_id}")
    return app["data"]["attributes"].get("primaryLocale") or "en-US"


def beta_localizations(api: Client, app_id: str) -> list[dict]:
    return api.paged(f"/apps/{app_id}/betaAppLocalizations")


def review_detail(api: Client, app_id: str) -> dict | None:
    got = api.request("GET", f"/apps/{app_id}/betaAppReviewDetail", tolerate=(404,))
    return None if got.get("__status__") else got.get("data")


def newest_build(api: Client, app_id: str) -> dict | None:
    got = api.request(
        "GET",
        "/builds",
        params={
            "filter[app]": app_id,
            "sort": "-version",
            "limit": 1,
            "include": "buildBetaDetail,betaAppReviewSubmission",
        },
    )
    if not got.get("data"):
        return None
    build = got["data"][0]
    included = {(i["type"], i["id"]): i for i in got.get("included", [])}
    for key, rel in (("buildBetaDetail", "buildBetaDetails"), ("betaAppReviewSubmission", "betaAppReviewSubmissions")):
        ref = build["relationships"].get(key, {}).get("data")
        build[key] = included.get((rel, ref["id"]), {}).get("attributes", {}) if ref else {}
    return build


def build_by_version(api: Client, app_id: str, version: str) -> dict | None:
    got = api.request(
        "GET",
        "/builds",
        params={
            "filter[app]": app_id,
            "filter[version]": version,
            "limit": 1,
            "include": "buildBetaDetail,betaAppReviewSubmission",
        },
    )
    if not got.get("data"):
        return None
    build = got["data"][0]
    included = {(i["type"], i["id"]): i for i in got.get("included", [])}
    for key, rel in (("buildBetaDetail", "buildBetaDetails"), ("betaAppReviewSubmission", "betaAppReviewSubmissions")):
        ref = build["relationships"].get(key, {}).get("data")
        build[key] = included.get((rel, ref["id"]), {}).get("attributes", {}) if ref else {}
    return build


def external_groups(api: Client, app_id: str) -> list[dict]:
    groups = api.paged("/betaGroups", {"filter[app]": app_id})
    return [g for g in groups if not g["attributes"].get("isInternalGroup")]


# ---------------------------------------------------------------------- checking


def cmd_list(api: Client, app_id: str) -> int:
    """Print the live Test Information and score external readiness. Read-only.

    Returns the number of BLOCKING gaps, so this doubles as a gate in a shell.
    """
    locale = primary_locale(api, app_id)
    locs = beta_localizations(api, app_id)
    detail = review_detail(api, app_id)
    groups = external_groups(api, app_id)
    build = newest_build(api, app_id)

    log()
    log(f"TEST INFORMATION  (primary locale: {locale})")
    log()
    log(f"  betaAppLocalizations: {len(locs)} row(s)")
    for row in locs:
        attrs = row["attributes"]
        log(f"    [{attrs.get('locale')}] feedbackEmail={attrs.get('feedbackEmail')!r}")
        log(f"           privacyPolicyUrl={attrs.get('privacyPolicyUrl')!r}")
        log(f"           marketingUrl={attrs.get('marketingUrl')!r}")
        desc = attrs.get("description") or ""
        log(f"           description={len(desc)} chars {'(EMPTY)' if not desc else ''}")

    log()
    log("  betaAppReviewDetail:")
    if not detail:
        log("    (absent)")
    else:
        attrs = detail["attributes"]
        name = " ".join(p for p in (attrs.get("contactFirstName"), attrs.get("contactLastName")) if p)
        log(f"    contact       : {name or '(unset)'}  <{attrs.get('contactEmail') or 'unset'}>")
        log(f"    phone         : {attrs.get('contactPhone') or '(unset)'}")
        log(f"    demoRequired  : {attrs.get('demoAccountRequired')}")
        log(f"    notes         : {len(attrs.get('notes') or '')} chars")

    log()
    log(f"  external beta groups: {len(groups)}")
    for group in groups:
        attrs = group["attributes"]
        log(
            f"    {attrs.get('name')!r}  id={group['id']}  allBuilds={attrs.get('hasAccessToAllBuilds')}  "
            f"publicLink={'ON' if attrs.get('publicLinkEnabled') else 'off'}"
        )

    log()
    # Defined before the branch: the warning is consumed unconditionally further down,
    # and an account with no builds must not turn a readiness report into a NameError.
    whats_new_warning: str | None = None
    if build:
        attrs = build["attributes"]
        log(f"  newest build: {attrs.get('version')}  processing={attrs.get('processingState')}")
        log(f"    internal={build['buildBetaDetail'].get('internalBuildState')}")
        log(f"    external={build['buildBetaDetail'].get('externalBuildState')}")
        log(f"    betaAppReviewSubmission={build['betaAppReviewSubmission'].get('betaReviewState') or '(none)'}")
        whats_new = api.paged(f"/builds/{build['id']}/betaBuildLocalizations")
        for row in whats_new:
            text = row["attributes"].get("whatsNew") or ""
            log(f"    whatsNew[{row['attributes'].get('locale')}]: {len(text)} chars {'(EMPTY)' if not text else ''}")
        if not whats_new:
            log("    whatsNew: 0 rows (EMPTY)")
        # S61 — whatsNew is PRINTED above and was never SCORED below, which is the
        # exact shape of defect this script exists to prevent. Consequence, verified
        # live: build 163's whatsNew is empty while S59's note went to build 145 —
        # `whatsNew` is PER-BUILD and is never inherited, so every green push starts
        # blank. Once the operator fills contact + phone, this readiness report would
        # have printed "READY — every field external distribution requires is filled"
        # over a build whose testers open TestFlight to no briefing at all: no warning
        # about the close-free hard paywall they meet after onboarding, no instruction
        # to add the widget, nothing. `testflight-beta-kit.md` promises that briefing.
        #
        # WARN and not BLOCKING, deliberately: an empty note does not stop Apple, so
        # calling it blocking would make `--list` exit non-zero as a shell gate over
        # something Apple accepts. It degrades the beta rather than preventing it.
        newest_has_notes = any(
            (row["attributes"].get("whatsNew") or "").strip() for row in whats_new
        )
        if not newest_has_notes:
            whats_new_warning = (
                f"build {build['attributes'].get('version')} has an EMPTY 'What to Test' "
                "(whatsNew is PER-BUILD and never inherited — every new build starts blank). "
                "Testers would see no briefing; re-run with --apply to write it."
            )
        else:
            whats_new_warning = None
    else:
        log("  newest build: NONE")

    # --- the verdict -------------------------------------------------------
    blocking: list[str] = []
    warnings: list[str] = []

    primary = next((r for r in locs if r["attributes"].get("locale") == locale), None)
    if not primary:
        blocking.append(f"no betaAppLocalization for the primary locale ({locale})")
    else:
        if not (primary["attributes"].get("description") or "").strip():
            blocking.append("Beta App Description is empty")
        if not (primary["attributes"].get("feedbackEmail") or "").strip():
            blocking.append("feedback email is empty")
        if not (primary["attributes"].get("privacyPolicyUrl") or "").strip():
            warnings.append("no privacy-policy URL in Test Information")

    if not detail:
        blocking.append("no betaAppReviewDetail")
    else:
        attrs = detail["attributes"]
        if not (attrs.get("contactFirstName") and attrs.get("contactLastName") and attrs.get("contactEmail")):
            blocking.append("Beta App Review contact name/email incomplete")
        if not attrs.get("contactPhone"):
            # Measured, not assumed: the live API 409s a PATCH with no phone even
            # though Apple's published schema calls the attribute optional.
            blocking.append("no review-contact phone (the API 409s without one — operator's own number)")
        if not (attrs.get("notes") or "").strip():
            warnings.append("no Beta App Review notes")

    if whats_new_warning:
        warnings.append(whats_new_warning)

    if not groups:
        blocking.append("no EXTERNAL beta group (testflight_testers.py --create-external-group)")

    if not build:
        blocking.append("no build")
    elif build["attributes"].get("processingState") != "VALID":
        blocking.append(f"newest build is {build['attributes'].get('processingState')}, not VALID")

    log()
    for item in blocking:
        log(f"  BLOCKING  {item}")
    for item in warnings:
        log(f"  WARN      {item}")
    if not blocking:
        log("  READY — every field external distribution requires is filled.")
        if warnings:
            log("           (the WARNs above are judgment calls, not gates)")
    log()
    return len(blocking)


# ----------------------------------------------------------------------- writing


def put_localization(api: Client, app_id: str, locale: str, feedback_email: str, apply: bool) -> None:
    existing = beta_localizations(api, app_id)
    row = next((r for r in existing if r["attributes"].get("locale") == locale), None)
    attributes = {
        "description": BETA_APP_DESCRIPTION,
        "feedbackEmail": feedback_email,
        "privacyPolicyUrl": PRIVACY_POLICY_URL,
        "marketingUrl": MARKETING_URL,
    }
    log()
    if row:
        log(f"PLAN: UPDATE betaAppLocalization [{locale}] (id={row['id']})")
    else:
        log(f"PLAN: CREATE betaAppLocalization [{locale}]")
    log(f"    description   : {len(BETA_APP_DESCRIPTION)} chars (beta-kit §1.2)")
    log(f"    feedbackEmail : {feedback_email}")
    log(f"    privacyPolicyUrl: {PRIVACY_POLICY_URL}")
    log(f"    marketingUrl  : {MARKETING_URL}")
    if not apply:
        return
    if row:
        api.request(
            "PATCH",
            f"/betaAppLocalizations/{row['id']}",
            body={"data": {"type": "betaAppLocalizations", "id": row["id"], "attributes": attributes}},
        )
        log("  UPDATED")
    else:
        api.request(
            "POST",
            "/betaAppLocalizations",
            body={
                "data": {
                    "type": "betaAppLocalizations",
                    "attributes": {**attributes, "locale": locale},
                    "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
                }
            },
        )
        log("  CREATED")


def put_review_detail(
    api: Client, app_id: str, first: str, last: str, email: str, phone: str | None, apply: bool
) -> bool:
    """Write the Beta App Review contact. Returns False if it was skipped for want of a phone.

    Skipping rather than failing is deliberate. Every field this script writes is
    independent, so one missing operator-only input should not strand the two that
    need nothing from anybody — a half-filled Test Information is still strictly
    closer to ready than an empty one, and --list says exactly what is left.
    """
    detail = review_detail(api, app_id)
    if not detail:
        fail("the app has no betaAppReviewDetail row to update, which should be impossible.")
    if not phone and not (detail["attributes"].get("contactPhone") or "").strip():
        # Pre-flight rather than let the PATCH 409 after other fields have landed:
        # Apple requires this attribute despite publishing it as optional (see the
        # module docstring for the measured error), and no agent can invent a number.
        log()
        log("SKIP: betaAppReviewDetail — no contact phone.")
        log("    Apple's published schema calls contactPhone optional; the live API does not —")
        log("    it answers 409 ENTITY_ERROR.ATTRIBUTE.REQUIRED without one.")
        log("    Re-run with your own number:  --contact-phone '+90 5xx xxx xx xx'")
        return False
    attributes = {
        "contactFirstName": first,
        "contactLastName": last,
        "contactEmail": email,
        # The app has no sign-in anywhere, so this is a statement of fact, not a choice.
        "demoAccountRequired": False,
        "notes": BETA_REVIEW_NOTES,
    }
    if phone:
        attributes["contactPhone"] = phone
    log()
    log(f"PLAN: UPDATE betaAppReviewDetail (id={detail['id']})")
    log(f"    contact           : {first} {last} <{email}>")
    log(f"    phone             : {phone or '(LEFT UNSET — operator must supply)'}")
    log("    demoAccountRequired: False  (no sign-in exists in the app)")
    log(f"    notes             : {len(BETA_REVIEW_NOTES)} chars (beta-kit §1.3)")
    if not apply:
        return True
    api.request(
        "PATCH",
        f"/betaAppReviewDetails/{detail['id']}",
        body={"data": {"type": "betaAppReviewDetails", "id": detail["id"], "attributes": attributes}},
    )
    log("  UPDATED")
    return True


def put_whats_new(api: Client, build: dict, locale: str, apply: bool) -> None:
    rows = api.paged(f"/builds/{build['id']}/betaBuildLocalizations")
    row = next((r for r in rows if r["attributes"].get("locale") == locale), None)
    version = build["attributes"].get("version")
    log()
    if row:
        log(f"PLAN: UPDATE 'What to Test' on build {version} [{locale}] (id={row['id']})")
    else:
        log(f"PLAN: CREATE 'What to Test' on build {version} [{locale}]")
    log(f"    whatsNew: {len(WHATS_NEW)} chars (beta-kit §1.1)")
    if not apply:
        return
    if row:
        api.request(
            "PATCH",
            f"/betaBuildLocalizations/{row['id']}",
            body={"data": {"type": "betaBuildLocalizations", "id": row["id"], "attributes": {"whatsNew": WHATS_NEW}}},
        )
        log("  UPDATED")
    else:
        api.request(
            "POST",
            "/betaBuildLocalizations",
            body={
                "data": {
                    "type": "betaBuildLocalizations",
                    "attributes": {"whatsNew": WHATS_NEW, "locale": locale},
                    "relationships": {"build": {"data": {"type": "builds", "id": build["id"]}}},
                }
            },
        )
        log("  CREATED")


def submit_for_review(api: Client, build: dict, apply: bool) -> None:
    version = build["attributes"].get("version")
    state = build["betaAppReviewSubmission"].get("betaReviewState")
    log()
    if state:
        log(f"Build {version} already has a Beta App Review submission: {state}. Nothing to do.")
        return
    log(f"PLAN: SUBMIT build {version} for BETA APP REVIEW.")
    log("  This is the one action here that leaves the account:")
    log("    * Apple's reviewers receive the build and the notes above.")
    log("    * Review runs ONCE PER VERSION; later builds of the same version usually clear.")
    log("    * A rejection is recorded against the version and costs a cycle to redo.")
    if not apply:
        log("  DRY RUN — not submitted.")
        return
    got = api.request(
        "POST",
        "/betaAppReviewSubmissions",
        body={
            "data": {
                "type": "betaAppReviewSubmissions",
                "relationships": {"build": {"data": {"type": "builds", "id": build["id"]}}},
            }
        },
        tolerate=(409, 422),
    )
    if got.get("__status__"):
        fail(f"submission refused (HTTP {got['__status__']}):\n{got['__detail__']}")
    log(f"  SUBMITTED — state={got['data']['attributes'].get('betaReviewState')}")


# --------------------------------------------------------------------------- cli


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Fill and verify the TestFlight Test Information external distribution requires.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("--bundle-id", default="com.beyondkaira.ballast")
    ap.add_argument("--list", action="store_true", help="Show the live state and score readiness. Read-only.")
    ap.add_argument("--apply", action="store_true", help="Actually write. Without it, this is a dry run.")
    ap.add_argument("--feedback-email", default=DEFAULT_FEEDBACK_EMAIL)
    ap.add_argument("--contact-first", default="Aytek")
    ap.add_argument("--contact-last", default="Erdogan")
    ap.add_argument("--contact-email", help="Defaults to --feedback-email.")
    ap.add_argument("--contact-phone", help="Beta App Review contact phone. Operator-supplied.")
    ap.add_argument("--build", default="latest", help="Build number for 'What to Test', or 'latest'.")
    ap.add_argument(
        "--submit-for-beta-review",
        action="store_true",
        help="Hand the build to Apple's Beta App Review. Needs --apply as well.",
    )
    ap.add_argument("--secrets-file", help="Read ASC_* from a secret.yml-shaped file.")
    args = ap.parse_args()

    if args.secrets_file:
        load_secrets_file(args.secrets_file)

    api = Client()
    log("TestFlight Test Information" + ("" if (args.apply or args.list) else "   [DRY RUN — no changes]"))
    app_id = resolve_app(api, args.bundle_id)

    if args.list:
        sys.exit(1 if cmd_list(api, app_id) else 0)

    locale = primary_locale(api, app_id)
    build = newest_build(api, app_id) if args.build == "latest" else build_by_version(api, app_id, args.build)
    if not build:
        fail(f"no build {args.build!r} on this app.")

    put_localization(api, app_id, locale, args.feedback_email, args.apply)
    complete = put_review_detail(
        api,
        app_id,
        args.contact_first,
        args.contact_last,
        args.contact_email or args.feedback_email,
        args.contact_phone,
        args.apply,
    )
    put_whats_new(api, build, locale, args.apply)
    if args.submit_for_beta_review:
        submit_for_review(api, build, args.apply)

    if not args.apply:
        log()
        log("DRY RUN — nothing was written. Re-run with --apply to execute this plan.")
    else:
        log()
        log("Done. Re-check with --list.")
    # Non-zero when a field is still missing, so a shell or a CI step can tell the
    # difference between "filled it all" and "filled what it could".
    sys.exit(0 if complete else 2)


if __name__ == "__main__":
    main()
