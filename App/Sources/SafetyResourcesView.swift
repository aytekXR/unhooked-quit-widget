import SwiftUI

/// E9.1 (R27.2/R27.3) — what the post-gate resources screen renders, composed once
/// at mount. Copy passthrough from the audited `safetyCopy.json` table (degrading to
/// the plainest calm labels, never invented copy); rows via the pure sibling
/// selection over the shipping directory. `source` is the INJECTED analytics origin:
/// `.settings` from the settings row, `.slipFlow` from the slip-flow link, and `nil`
/// from the alcohol notice's "See resources" hand-off — the nil path fires nothing
/// BY RULING (R27.4: the closed {settings, slip_flow} domain is preserved; an
/// out-of-domain open is honest-by-omission, the S16 shape).
struct SafetyResourcesViewData: Equatable, Sendable {
    var title: String
    var intro: String
    var footerDisclaimer: String?
    var emergencyNote: String
    var rows: [HelplineRow]
    var source: ResourcesSource?
}

/// Pure inputs+copy → view data (the SummaryPresentation idiom: display assembly is
/// computed, never stored; views stay thin renderers).
enum SafetyResourcesPresentation {
    /// The §9 honest-degrade floor: plainest functional strings when the shipping
    /// copy table is missing/undecodable — never silence on a safety surface.
    static let degradedTitle = "Support"
    static let degradedIntro = "Free, confidential help lines."

    static func make(
        source: ResourcesSource?,
        locale: Locale,
        directory: HelplineDirectory?,
        copy: SafetyCopy?
    ) -> SafetyResourcesViewData {
        let screen = copy?.resourcesScreen
        guard let directory else {
            // Missing/undecodable directory: the calm copy still renders — degraded,
            // never a crash, never an invented number (the AgeGateBlockedView posture).
            return SafetyResourcesViewData(
                title: screen?.title ?? Self.degradedTitle,
                intro: screen?.intro ?? Self.degradedIntro,
                footerDisclaimer: screen?.footerDisclaimer,
                emergencyNote: "",
                rows: [],
                source: source
            )
        }
        let region = SafetyResourcesSelection.region(for: locale, in: directory)
        return SafetyResourcesViewData(
            title: screen?.title ?? Self.degradedTitle,
            intro: screen?.intro ?? Self.degradedIntro,
            footerDisclaimer: screen?.footerDisclaimer,
            emergencyNote: directory.regions[region]?.emergencyNote ?? "",
            rows: SafetyResourcesSelection.rows(region: region, in: directory),
            source: source
        )
    }
}

/// The screen's one side effect: `resources_viewed(source)` through the consent-gated
/// service. Once per PRESENTATION via the durable guard (the `didFireQuizCompleted`
/// precedent — held by the mounting view's @State, so SwiftUI re-renders cannot
/// double-fire, while a genuine re-open is a genuine second view and fires again;
/// deliberately NOT the winback once-per-process guard, R27.3). A nil source is the
/// out-of-domain notice path and fires nothing (R27.4).
@MainActor
final class SafetyResourcesModel {
    private let analytics: AnalyticsService
    private var didFireResourcesViewed = false

    init(analytics: AnalyticsService = .disabled) {
        self.analytics = analytics
    }

    func viewed(_ source: ResourcesSource?) {
        guard let source, !didFireResourcesViewed else { return }
        didFireResourcesViewed = true
        analytics.fire(.resourcesViewed(source: source))
    }
}

/// E9.1 — the post-gate resources screen (mvp feature 11: region-aware helplines,
/// one tap from Settings and every slip flow). STORE-FREE BY CONSTRUCTION: bundled
/// JSON + the injected analytics seam only — no repository, no SwiftData — which is
/// what lets the COLD slip route (store-free by contract) mount it unchanged
/// (R27.11). Brand bindings (S16, re-signed R27.1): zero red, calm text emergency
/// note, teal links, SF Symbols only (`lifepreserver` header, `phone.fill` rows —
/// no new symbol this session, R27.9). Numbers render VERBATIM from the directory
/// (rule #12); only verified rows ever reach `rows`.
struct SafetyResourcesView: View {
    private let data: SafetyResourcesViewData
    @State private var model: SafetyResourcesModel
    /// Decorative screen glyph, Dynamic-Type-bound like the age gate / blocked screen
    /// (R33.12: a point size on a DECORATIVE Image is fine — the audit does not scan it).
    @ScaledMetric(relativeTo: .largeTitle) private var glyphSize: CGFloat = Theme.type.screenGlyphBase

    @MainActor
    init(source: ResourcesSource?, analytics: AnalyticsService = .disabled) {
        self.data = SafetyResourcesPresentation.make(
            source: source,
            locale: Locale.current,
            directory: HelplineDirectory.loadShipping(),
            copy: SafetyCopy.loadShipping()
        )
        _model = State(initialValue: SafetyResourcesModel(analytics: analytics))
    }

    /// Test-internal seam (the snapshot lane): renders over a pre-composed, locale-fixed
    /// `SafetyResourcesViewData` so a CI simulator locale change can never move the golden.
    /// Production never calls this (the `source:` init composes from the live directory).
    @MainActor
    init(data: SafetyResourcesViewData, analytics: AnalyticsService = .disabled) {
        self.data = data
        _model = State(initialValue: SafetyResourcesModel(analytics: analytics))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.space.s5) {
                Image(systemName: "lifepreserver")
                    .font(.system(size: min(glyphSize, Theme.type.screenGlyphCap), weight: .light))
                    .foregroundStyle(Theme.color.brandPrimary.color)
                    .accessibilityHidden(true)

                Text(data.title)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(data.intro)
                    .font(.body)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if !data.emergencyNote.isEmpty {
                    // Calm text by binding brand rule — never red, never a button.
                    Text(data.emergencyNote)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.color.contentPrimary.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: Theme.space.s3) {
                    ForEach(data.rows, id: \.dialString) { row in
                        helplineRow(row)
                    }
                }

                if let footerDisclaimer = data.footerDisclaimer {
                    Text(footerDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(Theme.space.s5)
        }
        .themedScreenSurface() // UIR-0: surface/base behind the resources screen
        .onAppear { model.viewed(data.source) }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("resources.screen")
    }

    /// One verbatim helpline row: name + description + a tappable tel: link
    /// (the AgeGateBlockedView row, unchanged — same brand sign-off).
    private func helplineRow(_ row: HelplineRow) -> some View {
        VStack(spacing: Theme.space.s1) {
            Text(row.name)
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.color.contentPrimary.color)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text(row.descr)
                .font(.footnote)
                .foregroundStyle(Theme.color.contentSecondary.color)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if let url = URL(string: "tel:\(row.dialString)") {
                // R33.10: the DIAL link is the one thing this safety surface exists to get
                // tapped — a 44pt-floor target (via a frame floor, R33.5) and a DESCRIPTIVE
                // VoiceOver label ("Call <name>"), not the bare number (the S33 blocked-screen
                // precedent).
                Link(destination: url) {
                    HStack(spacing: Theme.space.s2) {
                        Image(systemName: "phone.fill")
                            .accessibilityHidden(true)
                        Text(verbatim: row.phoneDisplay)
                            .font(.body.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundStyle(Theme.color.brandPrimary.color)
                    .frame(maxWidth: .infinity, minHeight: Theme.touch.minTarget)
                    .contentShape(Rectangle())
                    .padding(.top, Theme.space.s1)
                }
                .accessibilityLabel("Call \(row.name)")
            } else {
                Text(verbatim: row.phoneDisplay)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Theme.space.s1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.space.s4)
        .themedCard() // was .quaternary (unregistered system material) — now surface/raised + hairline
    }
}
