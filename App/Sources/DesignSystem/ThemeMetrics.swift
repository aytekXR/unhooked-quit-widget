import Foundation

/// UIR-0 — the non-color token tables (tokens-v2 §type/§spacing/§radii/§motion/
/// §touch; brandkit §3/§5/§7 formalized as a machine registry). Pure data —
/// screens keep their current metrics through UIR-0 (the in-place swap is
/// COLORS-ONLY by ruling R32.2); the themed PRIMITIVES consume these now and the
/// screens adopt them as each surface migrates in UIR-1…4.
extension Theme {
    /// Spacing scale, 4pt base (brandkit §5).
    enum space {
        static let s1: CGFloat = 4
        static let s2: CGFloat = 8
        static let s3: CGFloat = 12
        static let s4: CGFloat = 16
        static let s5: CGFloat = 20
        static let s6: CGFloat = 24
        static let s8: CGFloat = 32
        static let s10: CGFloat = 40
        static let s12: CGFloat = 48
    }

    /// Corner radii (brandkit §5). `full` renders as a Capsule in practice.
    enum radius {
        static let s: CGFloat = 10
        static let m: CGFloat = 16
        static let l: CGFloat = 24
    }

    /// Motion durations in seconds (brandkit §7 — breath, not bounce). The 4-7-8
    /// pacer curve stays the model's own pattern math; these are the UI tokens.
    enum motion {
        static let instant: TimeInterval = 0.1
        static let quick: TimeInterval = 0.2
        static let standard: TimeInterval = 0.3
        static let calm: TimeInterval = 0.6
        /// motion/standard's spring parameters (response 0.35, damping 0.85).
        static let standardSpringResponse: Double = 0.35
        static let standardSpringDamping: Double = 0.85
    }

    /// Touch-target floors (brandkit §5): 44pt global, 56pt on the panic and slip
    /// flows (agitated users; fat-finger tolerance is a safety feature).
    enum touch {
        static let minTarget: CGFloat = 44
        static let panicTarget: CGFloat = 56
    }

    /// Interaction affordances shared by the primitives.
    enum interaction {
        /// Pressed-state scale (brandkit §6.1).
        static let pressedScale: CGFloat = 0.98
    }

    /// Layout constants (brandkit §5 grid). UIR-1 adopts these: the single-column
    /// measure keeps body copy near the ~34ch line-length rule ("the quiz reads
    /// like a conversation, not a form") and makes every screen iPad-safe without
    /// a second layout.
    enum layout {
        /// Content column ceiling (brandkit §5: "content max-width 560pt").
        static let contentMaxWidth: CGFloat = 560
    }

    /// Type scale (brandkit §3 as machine values). Only DECORATIVE glyphs need a
    /// point size. Every role that renders TEXT is a Dynamic-Type text style used
    /// directly (`.largeTitle`, `.title2`, `.body`, `.subheadline`, `.footnote`) —
    /// including the summary's hero numeral.
    ///
    /// R33.12 (run 29303961082, artifact-measured): Apple's `.dynamicType` audit
    /// reports *"User will not be able to change the font size"* for text sized by a
    /// point value — a `.font(.system(size:))` carries no type metrics, and a
    /// `@ScaledMetric` driving the number does NOT rescue it. So there is deliberately
    /// NO `heroBase`/`heroCap` here: a token that hands a point size to a `Text` would
    /// be a token for writing the bug. The glyph sizes below are safe BECAUSE they are
    /// `Image`s (SF Symbols), which the audit does not scan for type scaling — proven
    /// on the same run, where both screen glyphs passed the full set.
    enum type {
        /// Decorative SF-Symbol screen glyphs (age gate, blocked screen) — never text.
        static let screenGlyphBase: CGFloat = 44
        static let screenGlyphCap: CGFloat = 72
    }
}
