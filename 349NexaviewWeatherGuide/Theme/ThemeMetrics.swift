import SwiftUI

enum ThemeMetrics {
    static let gaugeSize: CGFloat = 268
    static let bannerHeight: CGFloat = 92
    static let plateCorner: CGFloat = 18
    static let hairline: CGFloat = 1.2
    static let railHeight: CGFloat = 44
    static let fieldHeight: CGFloat = 52
    static let pagePadding: CGFloat = 18

    static func instrument(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static func plate(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}
