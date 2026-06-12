import SwiftUI
import UIKit

// MARK: - TTDesign
//
// Spatial / structural design tokens for TripTalk v3.
// Color tokens live in Views/Components/ThemeColors.swift — do not duplicate here.

enum TTDesign {

    // MARK: Spacing

    /// 4 pt — tightest gap (icon-to-label, tag inner padding)
    static let spacingXS: CGFloat = 4
    /// 8 pt — small gap (between related items within a card)
    static let spacingSM: CGFloat = 8
    /// 12 pt — medium gap (card section spacing)
    static let spacingMD: CGFloat = 12
    /// 16 pt — large gap (section-to-section, default HStack/VStack spacing)
    static let spacingLG: CGFloat = 16
    /// 24 pt — extra-large gap (between major page sections)
    static let spacingXL: CGFloat = 24
    /// 32 pt — double-extra-large gap (page-level breathing room)
    static let spacingXXL: CGFloat = 32

    // MARK: Corner Radius

    /// 8 pt — small radius (tags, chips, small buttons)
    static let radiusSM: CGFloat = 8
    /// 12 pt — medium radius (compact cards)
    static let radiusMD: CGFloat = 12
    /// 16 pt — large radius (standard glass cards — matches DarkGlassCard)
    static let radiusLG: CGFloat = 16
    /// 20 pt — extra-large radius (elevated/hero cards — matches DarkGlassCardElevated)
    static let radiusXL: CGFloat = 20
    /// 100 pt — pill / fully-rounded shape
    static let radiusPill: CGFloat = 100

    // MARK: Icon Sizes (emoji / SF Symbol rendering)

    /// 72 pt — hero emoji on splash/launch screens
    static let iconHero: CGFloat = 72
    /// 60 pt — large feature emoji (write-review, onboarding)
    static let iconXL: CGFloat = 60
    /// 50 pt — large-ish emoji (substance/service detail hero)
    static let iconLg50: CGFloat = 50
    /// 48 pt — medium-large emoji (age-gate, auth screens, crisis)
    static let iconLG: CGFloat = 48
    /// 32 pt — medium emoji (explore empty state, inline icons)
    static let iconMD: CGFloat = 32

    // MARK: Stroke / Border

    /// 1 px physical pixel — hairline stroke / divider weight
    static var hairlineWidth: CGFloat { 1 / UIScreen.main.scale }
}

// MARK: - Hairline Divider

/// A 1-physical-pixel horizontal divider using `Color.ttSecondary` at low opacity.
/// Drop anywhere in a VStack to visually separate sections without Divider's default padding.
struct TTHairline: View {
    var opacity: Double = 0.2

    var body: some View {
        Rectangle()
            .fill(Color.ttSecondary.opacity(opacity))
            .frame(height: TTDesign.hairlineWidth)
            .padding(.horizontal, TTDesign.spacingLG)
    }
}
