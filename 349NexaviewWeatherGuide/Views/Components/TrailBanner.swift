import SwiftUI

enum TrailBannerKind {
    case instruments
    case layers
    case lake

    var asset: String {
        switch self {
        case .instruments: return "BannerInstruments"
        case .layers: return "BannerLayers"
        case .lake: return "BannerLake"
        }
    }
}

struct TrailBanner: View {
    let kind: TrailBannerKind
    let eyebrow: String
    let title: String

    var body: some View {
        Image(kind.asset)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: ThemeMetrics.bannerHeight)
            .clipped()
            .overlay(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [Palette.purple.opacity(0.05), Palette.purple.opacity(0.78)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(eyebrow)
                        .font(ThemeMetrics.plate(11, weight: .bold))
                        .foregroundColor(Palette.gold)
                        .tracking(1.6)
                    Text(title)
                        .font(ThemeMetrics.instrument(22, weight: .bold))
                        .foregroundColor(Palette.ivory)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Palette.gold.opacity(0.55), lineWidth: ThemeMetrics.hairline)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
