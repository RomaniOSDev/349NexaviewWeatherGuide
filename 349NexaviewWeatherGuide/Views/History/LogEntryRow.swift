import SwiftUI

struct LogEntryRow: View {
    let entry: WindChillEntry
    let units: PreferredUnits
    let onEdit: () -> Void
    let onReuse: () -> Void
    let onDelete: () -> Void

    var body: some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(WindChillMath.formatted(entry.chill(in: units)))
                        .font(ThemeMetrics.instrument(28, weight: .bold))
                        .foregroundColor(Palette.gold)
                    Text(units.temperatureSymbol)
                        .font(ThemeMetrics.plate(13, weight: .semibold))
                        .foregroundColor(Palette.ivory.opacity(0.75))
                    Spacer()
                    Text(DateStamp.medium(entry.date))
                        .font(ThemeMetrics.plate(11, weight: .medium))
                        .foregroundColor(Palette.ivory.opacity(0.65))
                }
                Text(entry.locationNote.isEmpty ? "No field note" : entry.locationNote)
                    .font(ThemeMetrics.plate(14, weight: .medium))
                    .foregroundColor(Palette.ivory)
                HStack(spacing: 14) {
                    metric(title: "AIR", value: "\(WindChillMath.formatted(entry.temperature(in: units))) \(units.temperatureSymbol)")
                    metric(title: "WIND", value: "\(WindChillMath.formatted(entry.windSpeed(in: units))) \(units.windSymbol)")
                }
                if entry.isExtreme {
                    Text("Extreme chill on this reading.")
                        .font(ThemeMetrics.plate(12, weight: .semibold))
                        .foregroundColor(Palette.danger)
                }
                HStack(spacing: 10) {
                    Button("Edit", action: onEdit)
                        .font(ThemeMetrics.plate(13, weight: .bold))
                        .foregroundColor(Palette.gold)
                    Button("Again", action: onReuse)
                        .font(ThemeMetrics.plate(13, weight: .bold))
                        .foregroundColor(Palette.gold)
                    Button("Delete", action: onDelete)
                        .font(ThemeMetrics.plate(13, weight: .bold))
                        .foregroundColor(Palette.danger)
                    Spacer()
                }
            }
        }
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(ThemeMetrics.plate(10, weight: .bold))
                .foregroundColor(Palette.gold)
                .tracking(1.1)
            Text(value)
                .font(ThemeMetrics.plate(13, weight: .medium))
                .foregroundColor(Palette.ivory)
        }
    }
}
