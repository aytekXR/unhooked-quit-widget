/// The subscription period discriminator, mirroring the documented RevenueCat
/// `PeriodType` value set exactly (purchases-ios 5.80.3 source: normal, intro,
/// trial, prepaid — docs-verified Session 23; "promotional" is a Store value,
/// not a period type). The trial gate is `.trial` and only `.trial`: whether a
/// $0 paid-intro ever reports `.intro` is docs-UNCONFIRMED, so `.intro` is
/// deliberately NOT treated as a trial (ledger Session 23).
public enum PeriodType: String, CaseIterable, Sendable {
    case normal
    case intro
    case trial
    case prepaid
}
