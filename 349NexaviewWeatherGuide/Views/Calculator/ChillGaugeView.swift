import SwiftUI

struct ChillGaugeView: View {
    let chill: Double
    let units: PreferredUnits
    let isValid: Bool

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("FELT TEMPERATURE")
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.6)
                Spacer()
                Text(units.temperatureSymbol)
                    .font(ThemeMetrics.plate(13, weight: .semibold))
                    .foregroundColor(Palette.gold)
            }
            Text(isValid ? WindChillMath.formatted(chill) : "—")
                .font(ThemeMetrics.instrument(56, weight: .bold))
                .foregroundColor(Palette.ivory)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Palette.purple.opacity(0.55))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Palette.gold.opacity(0.35), Palette.gold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(12, geo.size.width * progress))
                    Circle()
                        .fill(Palette.ivory)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(Palette.gold, lineWidth: 2))
                        .offset(x: max(0, geo.size.width * progress - 9))
                }
            }
            .frame(height: 18)
            .opacity(isValid ? 1 : 0.35)

            HStack {
                Text(boundsLabel(bounds.lowerBound))
                Spacer()
                Text("Wind chill band")
                    .font(ThemeMetrics.plate(12, weight: .medium))
                    .foregroundColor(Palette.ivory.opacity(0.7))
                Spacer()
                Text(boundsLabel(bounds.upperBound))
            }
            .font(ThemeMetrics.plate(12, weight: .semibold))
            .foregroundColor(Palette.gold.opacity(0.85))
        }
        .padding(18)
        .background(Palette.card.opacity(0.95))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Palette.gold.opacity(0.55), lineWidth: ThemeMetrics.hairline)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Palette.gold.opacity(0.16), radius: 14, x: 0, y: 8)
    }

    private var bounds: ClosedRange<Double> {
        switch units {
        case .metric: return -40...20
        case .imperial: return -40...50
        }
    }

    private var progress: CGFloat {
        guard isValid else { return 0.15 }
        let clamped = min(max(chill, bounds.lowerBound), bounds.upperBound)
        return CGFloat((clamped - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound))
    }

    private func boundsLabel(_ value: Double) -> String {
        "\(Int(value))\(units.temperatureSymbol)"
    }
}
