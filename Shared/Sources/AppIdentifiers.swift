import Foundation

/// Single source of truth for identifier strings shared between the app target and
/// the widget-extension target.
///
/// ── Gate G0 (rename) — CLEARED 2026-07-08 ──
/// Values below are the real, registered identifiers for "Ballast" (org prefix
/// `com.beyondkaira`, derived from the owned domain beyondkaira.com). Registered in
/// the Apple Developer portal on 2026-07-08 (App ID, widget App ID, App Group, and
/// iCloud container `iCloud.com.beyondkaira.ballast`; Team ID UH7MXG7Z94). The former
/// placeholder `dev.placeholder.quitwidget` was never registered (feasibility §7
/// condition 1). If these ever change, sweep exactly: project.yml + this file.
enum AppIdentifiers {
    /// The App Group both targets read/write. Architecture §4: the SwiftData store,
    /// panic-snapshot.json, and the panic launch flag all live in this container.
    static let appGroupID = "group.com.beyondkaira.ballast.shared"

    /// os_log / signpost subsystem for both targets.
    static let loggingSubsystem = "com.beyondkaira.ballast"

    /// URL of the shared App Group container, identically derivable from either target.
    static var appGroupContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    // MARK: - Legal destinations (Apple Schedule 2 / guideline 3.1.2(c))

    /// The product's public host. Split out as a constant so the legal
    /// destinations below cannot drift apart, and so a future page (support,
    /// marketing) inherits the same origin.
    ///
    /// **Moved from the apex `beyondkaira.com` to the product subdomain in S56**,
    /// at the operator's instruction: Ballast is one product under the
    /// `com.beyondkaira` org, and its public pages belong on its own host rather
    /// than the org apex.
    ///
    /// ⚠️ **This host is NOT serving yet, and that is a submission blocker, not a
    /// nicety.** Verified at the time of the change: `ballast.beyondkaira.com`
    /// RESOLVES (a wildcard A record points it at the same origin as the apex) but
    /// presents no matching TLS certificate, so an HTTPS request fails the
    /// hostname check outright. See `docs/public-site-deploy.md` for the nginx +
    /// certbot runbook that closes it.
    ///
    /// Worth knowing about what it replaced, because it is worse than it looks:
    /// the old apex URLs returned **HTTP 200 with a 16-byte body reading
    /// "beyondkaira.com"** — for `/terms`, `/privacy`, and every other path alike.
    /// They were never real pages; the origin answers 200 to everything. A
    /// link-checker would have called them healthy while a reviewer tapping
    /// "Terms of Use" met a blank placeholder — an Apple Schedule 2 / 3.1.2(c)
    /// rejection that no automated 404 sweep could ever have caught.
    static let publicSiteHost = "ballast.beyondkaira.com"

    /// Terms of Use (EULA). Every subscription purchase screen MUST link to a
    /// FUNCTIONAL URL — a plain label is a rejection. Operator-owned destination;
    /// the page itself is published separately (see the runbook above).
    static let termsOfUseURL = URL(string: "https://\(publicSiteHost)/terms")!

    /// Privacy Policy. Same Schedule 2 requirement as the Terms link above, and
    /// the destination the App Privacy label's sensitive-class disclosure points at.
    static let privacyPolicyURL = URL(string: "https://\(publicSiteHost)/privacy")!
}
