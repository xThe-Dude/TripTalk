import SwiftUI
import UIKit

// MARK: - Fraunces Availability

/// True once the Fraunces variable font has been registered via UIAppFonts.
/// Falls back gracefully to system serif when the font is unavailable (e.g. Simulator
/// before the app has been built with the font resource included).
private let frauncesAvailable: Bool = UIFont(name: "Fraunces", size: 17) != nil

// MARK: - Type Token Enum

/// Named type-scale tokens that mirror the triptalk.guide editorial type system.
/// Fraunces (variable serif) for display/heading roles; system font for body roles.
enum TTTypeStyle: String, CaseIterable, Hashable {
    /// Large hero / launch-screen display text — Fraunces Bold ~52 pt
    case display
    /// Page-level headings (e.g. section landing titles) — Fraunces Bold ~34 pt
    case pageHead
    /// Section headings within a scrolling page — Fraunces Bold ~26 pt
    case section
    /// Card titles, inline sub-headings — Fraunces Bold ~20 pt
    case cardTitle
    /// Body copy — system `.body`
    case body
    /// Secondary metadata / subheadline — system `.subheadline`
    case metadata
    /// Eyebrow / overline label — system `.caption`, semibold
    case eyebrow
    /// Fine-print / timestamp captions — system `.caption2`
    case caption
}

// MARK: - Font Tokens

extension Font {

    // MARK: Serif display/heading tokens (Fraunces)

    /// Hero/launch display: Fraunces Bold 52 pt (Dynamic Type: relativeTo `.largeTitle`)
    static var ttDisplay: Font  { fraunces(size: 52, relativeTo: .largeTitle, weight: .bold) }

    /// Page heading: Fraunces Bold 34 pt (Dynamic Type: relativeTo `.largeTitle`)
    static var ttPageHead: Font { fraunces(size: 34, relativeTo: .largeTitle, weight: .bold) }

    /// Section heading: Fraunces Bold 26 pt (Dynamic Type: relativeTo `.title`)
    static var ttSection: Font  { fraunces(size: 26, relativeTo: .title, weight: .bold) }

    /// Card / inline title: Fraunces Bold 20 pt (Dynamic Type: relativeTo `.title2`)
    static var ttCardTitle: Font { fraunces(size: 20, relativeTo: .title2, weight: .bold) }

    // MARK: System body tokens

    /// Body copy — system `.body`
    static var ttBody: Font     { .body }

    /// Secondary metadata / subheadline — system `.subheadline`
    static var ttMetadata: Font { .subheadline }

    /// Eyebrow label — system `.caption`, semibold
    static var ttEyebrow: Font  { .system(.caption, design: .default, weight: .semibold) }

    /// Fine-print caption — system `.caption2`
    static var ttCaption: Font  { .system(.caption2) }

    // MARK: Icon / emoji size tokens (system font — not Fraunces)

    /// 72 pt system — hero emoji / splash-screen icons
    static var ttIconHero: Font { .system(size: 72) }
    /// 60 pt system — large feature emoji
    static var ttIconXL: Font   { .system(size: 60) }
    /// 50 pt system — large-ish emoji
    static var ttIconLg50: Font { .system(size: 50) }
    /// 48 pt system — medium-large emoji / auth-screen icons
    static var ttIconLg: Font   { .system(size: 48) }
    /// 32 pt system — medium emoji / inline icon
    static var ttIconMd: Font   { .system(size: 32) }

    // MARK: Token accessor

    /// Return the `Font` value for a given `TTTypeStyle` token.
    static func tt(_ style: TTTypeStyle) -> Font {
        switch style {
        case .display:   return ttDisplay
        case .pageHead:  return ttPageHead
        case .section:   return ttSection
        case .cardTitle: return ttCardTitle
        case .body:      return ttBody
        case .metadata:  return ttMetadata
        case .eyebrow:   return ttEyebrow
        case .caption:   return ttCaption
        }
    }

    // MARK: Private helpers

    /// Build a Fraunces font at the requested size / text style, with a system-serif
    /// fallback when the font file has not yet been registered in the app target.
    private static func fraunces(
        size: CGFloat,
        relativeTo textStyle: Font.TextStyle = .body,
        weight: Font.Weight = .bold
    ) -> Font {
        if frauncesAvailable {
            return Font.custom("Fraunces", size: size, relativeTo: textStyle).weight(weight)
        }
        // Graceful fallback: system serif honours Dynamic Type and approximate weight
        return Font.system(textStyle, design: .serif).weight(weight)
    }
}

// MARK: - View / Text Modifier

extension View {
    /// Apply a `TTTypeStyle` token as this view's font.
    func ttType(_ style: TTTypeStyle) -> some View {
        self.font(.tt(style))
    }
}

extension Text {
    /// Apply a `TTTypeStyle` token as this Text's font.
    func ttType(_ style: TTTypeStyle) -> Text {
        self.font(.tt(style))
    }
}
