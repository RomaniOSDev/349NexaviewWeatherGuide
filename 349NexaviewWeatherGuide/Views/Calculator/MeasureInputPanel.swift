import SwiftUI

struct MeasureInputPanel: View {
    @Binding var temperatureText: String
    @Binding var windText: String
    @Binding var noteText: String
    let units: PreferredUnits
    let temperatureError: String?
    let windError: String?
    let canRecord: Bool
    let selectedSite: SitePreset?
    let onSelectSite: (SitePreset) -> Void
    let onRecord: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                DialField(
                    label: "AIR",
                    unit: units.temperatureSymbol,
                    text: $temperatureText,
                    error: temperatureError,
                    step: 0.5,
                    range: InputLimits.temperatureRange(for: units)
                )
                DialField(
                    label: "WIND",
                    unit: units.windSymbol,
                    text: $windText,
                    error: windError,
                    step: 1,
                    range: InputLimits.windRange(for: units)
                )
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("PLACE SHORTCUTS")
                    .font(ThemeMetrics.plate(12, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.2)
                HStack(spacing: 8) {
                    ForEach(SitePreset.allCases) { site in
                        Button {
                            onSelectSite(site)
                        } label: {
                            Text(site.title)
                                .font(ThemeMetrics.plate(13, weight: .semibold))
                                .foregroundColor(selectedSite == site ? Palette.ink : Palette.ivory)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(selectedSite == site ? Palette.gold : Palette.card)
                                .overlay(
                                    Capsule()
                                        .stroke(Palette.gold.opacity(0.7), lineWidth: ThemeMetrics.hairline)
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("SESSION NOTE")
                    .font(ThemeMetrics.plate(12, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.2)
                TextField("Outlook, shore, shelter…", text: $noteText)
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
            BrassAction(title: "Save chill check", enabled: canRecord, action: onRecord)
        }
    }
}
