import SwiftUI
import UIKit

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha)
    }
}

extension Color {
    /// Creates a color from a 24-bit hex value, e.g. `Color(hex: 0xFFBC42)`.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    // MARK: Brand palette (fixed)

    /// #FFBC42: sun motifs, the jar lid, warm highlights
    static let sunflowerGold = Color(hex: 0xFFBC42)
    /// #D81159: primary action buttons and energetic accents
    static let raspberryRed = Color(hex: 0xD81159)
    /// #8F2D56: deep contrast text and headers by day
    static let vintageBerry = Color(hex: 0x8F2D56)
    /// #218380: secondary buttons and interactive elements
    static let sunTeal = Color(hex: 0x218380)
    /// #73D2DE: soft glow, cool accents, secondary color at night
    static let frostedBlue = Color(hex: 0x73D2DE)

    /// Lighter tints used for gradients (not part of the five brand colors).
    static let sunflowerGoldLight = Color(hex: 0xFFD27A)
    static let raspberryRedLight = Color(hex: 0xE8366F)
    static let raspberryRedDeep = Color(hex: 0xA80C45)
    /// Warm cream used for ink on dark or saturated surfaces.
    static let sunCream = Color(hex: 0xFFF1D6)

    /// Colors used for the paper slips inside the jar (same in day and night).
    static let slipPalette: [Color] = [
        .sunflowerGold,
        .raspberryRed,
        .frostedBlue,
        .sunTeal,
        .vintageBerry
    ]

    // MARK: Adaptive tokens (day / night)

    fileprivate static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traits in traits.userInterfaceStyle == .dark ? dark : light })
    }

    /// Primary text and icon ink: Vintage Berry by day, warm cream by night.
    static let sunInk = adaptive(light: UIColor(hex: 0x8F2D56), dark: UIColor(hex: 0xFFF1D6))
    /// Accent for text and small controls that must stay readable on both backgrounds.
    static let sunAccentText = adaptive(light: UIColor(hex: 0xD81159), dark: UIColor(hex: 0xFF6B9A))
    /// Secondary buttons and interactive elements: Teal by day, Frosted Blue by night.
    static let sunSecondary = adaptive(light: UIColor(hex: 0x218380), dark: UIColor(hex: 0x73D2DE))
    /// Text and icons placed on `sunSecondary`.
    static let sunOnSecondary = adaptive(light: UIColor.white, dark: UIColor(hex: 0x05303A))
    /// Cards and fields.
    static let sunSurface = adaptive(light: UIColor(hex: 0xFFF9EC), dark: UIColor(hex: 0x0F4A4B))
    /// Screen gradient top / bottom.
    static let sunBackgroundTop = adaptive(light: UIColor(hex: 0xFFF4DA), dark: UIColor(hex: 0x052A2E))
    static let sunBackgroundBottom = adaptive(light: UIColor(hex: 0xD3F0F3), dark: UIColor(hex: 0x176663))
    /// Warm variant used on the welcome page (gold on top by day).
    static let sunWarmTop = adaptive(light: UIColor(hex: 0xFFE2A8), dark: UIColor(hex: 0x052A2E))
    static let sunWarmBottom = adaptive(light: UIColor(hex: 0xFFF4DA), dark: UIColor(hex: 0x176663))
    /// Soft light pool in the middle of the screen.
    static let sunGlow = adaptive(
        light: UIColor.white.withAlphaComponent(0.6), dark: UIColor(hex: 0xFFBC42, alpha: 0.14))
}
