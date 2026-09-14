import SwiftUI

struct RecentTickStrip: View {
    let entries: [WindChillEntry]
    let units: PreferredUnits

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECENT DIALS")
                .font(ThemeMetrics.plate(11, weight: .bold))
                .foregroundColor(Palette.gold)
                .tracking(1.4)
            if entries.isEmpty {
                Text("Record a reading to etch it on the dial strip.")
                    .font(ThemeMetrics.plate(13))
                    .foregroundColor(Palette.ivory.opacity(0.7))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entries.prefix(8)) { entry in
                            VStack(spacing: 3) {
                                Text(WindChillMath.formatted(entry.chill(in: units)))
                                    .font(ThemeMetrics.instrument(16, weight: .bold))
                                    .foregroundColor(Palette.gold)
                                Text(units.temperatureSymbol)
                                    .font(ThemeMetrics.plate(10, weight: .semibold))
                                    .foregroundColor(Palette.ivory.opacity(0.7))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Palette.purple.opacity(0.55))
                            .overlay(
                                Capsule()
                                    .stroke(Palette.gold.opacity(0.45), lineWidth: 1)
                            )
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }
}
