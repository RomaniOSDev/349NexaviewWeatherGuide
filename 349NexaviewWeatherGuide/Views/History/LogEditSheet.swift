import SwiftUI

struct LogEditSheet: View {
    @EnvironmentObject private var store: ChillStore
    @Environment(\.dismiss) private var dismiss
    let entry: WindChillEntry
    @State private var temperatureText = ""
    @State private var windText = ""
    @State private var noteText = ""
    @State private var didHydrate = false

    var body: some View {
        RidgeBackdrop {
            VStack(spacing: 16) {
                TrailBanner(kind: .journal, eyebrow: "ADJUST LOG", title: "Revise a reading")
                DialField(
                    label: "AIR",
                    unit: entry.units.temperatureSymbol,
                    text: $temperatureText,
                    error: temperatureError,
                    step: 0.5,
                    range: InputLimits.temperatureRange(for: entry.units)
                )
                DialField(
                    label: "WIND",
                    unit: entry.units.windSymbol,
                    text: $windText,
                    error: windError,
                    step: 1,
                    range: InputLimits.windRange(for: entry.units)
                )
                VStack(alignment: .leading, spacing: 6) {
                    Text("FIELD NOTE")
                        .font(ThemeMetrics.plate(12, weight: .bold))
                        .foregroundColor(Palette.gold)
                        .tracking(1.2)
                    TextField("Ridge, lake trail, camp…", text: $noteText)
                        .font(ThemeMetrics.plate(15))
                        .foregroundColor(Palette.ivory)
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(Palette.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Palette.stroke, lineWidth: ThemeMetrics.hairline)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                BrassAction(title: "Save Changes", enabled: canSave, action: save)
                Button("Close") { dismiss() }
                    .font(ThemeMetrics.plate(14, weight: .semibold))
                    .foregroundColor(Palette.ivory)
                Spacer()
            }
            .padding(ThemeMetrics.pagePadding)
        }
        .onAppear {
            if didHydrate { return }
            temperatureText = WindChillMath.formatted(entry.temperature)
            windText = WindChillMath.formatted(entry.windSpeed)
            noteText = entry.locationNote
            didHydrate = true
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
            dismiss()
        }
    }

    private var parsedTemperature: Double? { SafeParse.decimal(temperatureText) }
    private var parsedWind: Double? { SafeParse.decimal(windText) }
    private var temperatureError: String? { InputLimits.temperatureError(parsedTemperature, units: entry.units) }
    private var windError: String? { InputLimits.windError(parsedWind, units: entry.units) }
    private var canSave: Bool { temperatureError == nil && windError == nil }

    private func save() {
        guard let temperature = parsedTemperature, let wind = parsedWind, canSave else { return }
        var revised = entry
        revised.temperature = temperature
        revised.windSpeed = wind
        revised.locationNote = noteText
        store.update(revised)
        dismiss()
    }
}
