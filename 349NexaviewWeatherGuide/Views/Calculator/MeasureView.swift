import SwiftUI

struct MeasureView: View {
    @EnvironmentObject private var store: ChillStore
    @State private var temperatureText = ""
    @State private var windText = ""
    @State private var noteText = ""
    @State private var didHydrate = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                TrailBanner(kind: .instruments, eyebrow: "MANUAL DIAL", title: "Ridge wind chill")
                ChillGaugeView(chill: displayedChill, units: store.preferredUnits, isValid: canRecord)
                if showsExtreme {
                    ExtremeWarningCard(chillText: "\(WindChillMath.formatted(displayedChill)) \(store.preferredUnits.temperatureSymbol)")
                }
                if showsFormulaHint {
                    hintPlate(
                        title: "NWS RANGE",
                        text: WindChillMath.formulaHint(units: store.preferredUnits)
                    )
                }
                if canRecord {
                    frostbitePlate
                    activityPlate
                    clothingPlate
                }
                MeasureInputPanel(
                    temperatureText: $temperatureText,
                    windText: $windText,
                    noteText: $noteText,
                    units: store.preferredUnits,
                    temperatureError: temperatureError,
                    windError: windError,
                    canRecord: canRecord,
                    selectedSite: store.selectedSite,
                    onSelectSite: { store.applySite($0) },
                    onRecord: record
                )
                RecentTickStrip(entries: store.recentCalculations, units: store.preferredUnits)
            }
            .padding(.horizontal, ThemeMetrics.pagePadding)
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear(perform: hydrateIfNeeded)
        .onChange(of: store.preferredUnits) { _ in
            temperatureText = WindChillMath.formatted(store.lastInputTemp)
            windText = WindChillMath.formatted(store.lastInputWindSpeed)
        }
        .onChange(of: store.dialRevision) { _ in
            applyStoreDial()
        }
        .onChange(of: temperatureText) { _ in persistDraft() }
        .onChange(of: windText) { _ in persistDraft() }
        .onChange(of: noteText) { note in
            store.syncSelectedSite(with: note)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
            temperatureText = WindChillMath.formatted(0)
            windText = WindChillMath.formatted(0)
            noteText = ""
        }
    }

    private var parsedTemperature: Double? { SafeParse.decimal(temperatureText) }
    private var parsedWind: Double? { SafeParse.decimal(windText) }
    private var temperatureError: String? { InputLimits.temperatureError(parsedTemperature, units: store.preferredUnits) }
    private var windError: String? { InputLimits.windError(parsedWind, units: store.preferredUnits) }
    private var canRecord: Bool { temperatureError == nil && windError == nil }

    private var displayedChill: Double {
        guard let temperature = parsedTemperature, let wind = parsedWind, canRecord else {
            return store.preferredUnits == .metric ? 0 : 32
        }
        return WindChillMath.chill(temperature: temperature, windSpeed: wind, units: store.preferredUnits)
    }

    private var showsExtreme: Bool {
        canRecord && WindChillMath.isExtreme(chill: displayedChill, units: store.preferredUnits)
    }

    private var showsFormulaHint: Bool {
        guard let temperature = parsedTemperature, let wind = parsedWind, canRecord else {
            return false
        }
        return !WindChillMath.usesFormula(temperature: temperature, windSpeed: wind, units: store.preferredUnits)
    }

    private var frostbite: FrostbiteRisk {
        FrostbiteRisk.from(chill: displayedChill, units: store.preferredUnits)
    }

    private var frostbitePlate: some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 8) {
                Text("FROSTBITE CLOCK")
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.5)
                Text(frostbite.headline)
                    .font(ThemeMetrics.instrument(28, weight: .bold))
                    .foregroundColor(frostbite == .unlikely ? Palette.ivory : Palette.danger)
                Text(frostbite.detail)
                    .font(ThemeMetrics.plate(14))
                    .foregroundColor(Palette.ivory)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var activityPlate: some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 8) {
                Text("ACTIVITY")
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.5)
                HStack(spacing: 8) {
                    ForEach(TrailActivity.allCases) { item in
                        Button {
                            store.setActivity(item)
                        } label: {
                            Text(item.title)
                                .font(ThemeMetrics.plate(13, weight: .semibold))
                                .foregroundColor(store.activity == item ? Palette.ink : Palette.ivory)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(store.activity == item ? Palette.gold : Palette.purple.opacity(0.45))
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
        }
    }

    private var clothingPlate: some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 8) {
                Text("LAYERS · \(store.activity.title.uppercased())")
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.5)
                Text(ClothingAdvice.line(chill: displayedChill, units: store.preferredUnits, activity: store.activity))
                    .font(ThemeMetrics.plate(15))
                    .foregroundColor(Palette.ivory)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func hintPlate(title: String, text: String) -> some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.5)
                Text(text)
                    .font(ThemeMetrics.plate(14))
                    .foregroundColor(Palette.ivory)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func hydrateIfNeeded() {
        if didHydrate { return }
        applyStoreDial()
        didHydrate = true
    }

    private func applyStoreDial() {
        temperatureText = WindChillMath.formatted(store.lastInputTemp)
        windText = WindChillMath.formatted(store.lastInputWindSpeed)
        let note = store.consumeDraftNote()
        if !note.isEmpty {
            noteText = note
        } else if noteText.isEmpty, let site = store.selectedSite {
            noteText = site.title
        }
    }

    private func persistDraft() {
        if let temperature = parsedTemperature, let wind = parsedWind,
           temperatureError == nil, windError == nil {
            store.persistInputs(temperature: temperature, windSpeed: wind)
        }
    }

    private func record() {
        guard let temperature = parsedTemperature, let wind = parsedWind, canRecord else { return }
        _ = store.record(temperature: temperature, windSpeed: wind, locationNote: noteText)
        if let site = store.selectedSite {
            noteText = site.title
        } else {
            noteText = ""
        }
    }
}
