import SwiftUI

struct ContrastResultPanel: View {
    let comparison: ChillComparison

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DELTA")
                .font(ThemeMetrics.plate(11, weight: .bold))
                .foregroundColor(Palette.gold)
                .tracking(1.6)
            deltaRow(title: "Air", value: comparison.temperatureDelta, suffix: comparison.displayUnits.temperatureSymbol)
            deltaRow(title: "Wind", value: comparison.windDelta, suffix: comparison.displayUnits.windSymbol)
            deltaRow(title: "Chill", value: comparison.chillDelta, suffix: comparison.displayUnits.temperatureSymbol)
            Divider()
                .background(Palette.stroke)
            Text("CLOTHING FROM CHILL")
                .font(ThemeMetrics.plate(11, weight: .bold))
                .foregroundColor(Palette.gold)
                .tracking(1.6)
            labeledAdvice(title: slotTitle(comparison.first), text: comparison.firstAdvice)
            labeledAdvice(title: slotTitle(comparison.second), text: comparison.secondAdvice)
            labeledAdvice(title: "Colder reading", text: comparison.colderAdvice)
        }
        .padding(14)
        .background(Palette.card)
        .overlay(
            RoundedRectangle(cornerRadius: ThemeMetrics.plateCorner, style: .continuous)
                .stroke(Palette.gold.opacity(0.5), lineWidth: ThemeMetrics.hairline)
        )
        .clipShape(RoundedRectangle(cornerRadius: ThemeMetrics.plateCorner, style: .continuous))
    }

    private func slotTitle(_ entry: WindChillEntry) -> String {
        if entry.locationNote.isEmpty {
            return DateStamp.medium(entry.date)
        }
        return entry.locationNote
    }

    private func deltaRow(title: String, value: Double, suffix: String) -> some View {
        HStack {
            Text(title)
                .font(ThemeMetrics.plate(14, weight: .medium))
                .foregroundColor(Palette.ivory)
            Spacer()
            Text("\(signed(value)) \(suffix)")
                .font(ThemeMetrics.instrument(18, weight: .semibold))
                .foregroundColor(Palette.gold)
        }
    }

    private func labeledAdvice(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(ThemeMetrics.plate(12, weight: .bold))
                .foregroundColor(Palette.gold)
            Text(text)
                .font(ThemeMetrics.plate(14))
                .foregroundColor(Palette.ivory)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func signed(_ value: Double) -> String {
        let body = WindChillMath.formatted(abs(value))
        if value > 0.05 {
            return "+\(body)"
        }
        if value < -0.05 {
            return "−\(body)"
        }
        return body
    }
}
