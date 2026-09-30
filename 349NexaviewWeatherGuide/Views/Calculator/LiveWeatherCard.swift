import SwiftUI

struct LiveWeatherCard: View {
    @ObservedObject var weather: LiveWeatherService
    let units: PreferredUnits
    let manualTemp: Double?
    let manualWind: Double?
    let onUseLive: (LiveWeatherSnapshot) -> Void

    var body: some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("LIVE NEAR YOU")
                        .font(ThemeMetrics.plate(11, weight: .bold))
                        .foregroundColor(Palette.gold)
                        .tracking(1.5)
                    Spacer()
                    Button {
                        Task { await weather.refresh() }
                    } label: {
                        if weather.isLoading {
                            ProgressView()
                                .tint(Palette.gold)
                        } else {
                            Image(systemName: "location.north.line.fill")
                                .foregroundColor(Palette.gold)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(weather.isLoading)
                    .accessibilityLabel("Refresh live weather")
                }

                if let snapshot = weather.snapshot {
                    let liveTemp = snapshot.temperature(in: units)
                    let liveWind = snapshot.wind(in: units)
                    let liveChill = snapshot.chill(in: units)
                    Text("\(WindChillMath.formatted(liveTemp)) \(units.temperatureSymbol) · \(WindChillMath.formatted(liveWind)) \(units.windSymbol)")
                        .font(ThemeMetrics.instrument(22, weight: .bold))
                        .foregroundColor(Palette.ivory)
                    Text("Live chill \(WindChillMath.formatted(liveChill)) \(units.temperatureSymbol)")
                        .font(ThemeMetrics.plate(14, weight: .semibold))
                        .foregroundColor(Palette.gold)
                    if let compareText = compareText(liveTemp: liveTemp, liveWind: liveWind) {
                        Text(compareText)
                            .font(ThemeMetrics.plate(13))
                            .foregroundColor(Palette.ivory.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    BrassAction(title: "Use live values", enabled: true) {
                        onUseLive(snapshot)
                    }
                } else if let error = weather.lastError {
                    Text(error)
                        .font(ThemeMetrics.plate(14))
                        .foregroundColor(Palette.ivory)
                        .fixedSize(horizontal: false, vertical: true)
                    BrassAction(title: "Try live weather", enabled: true) {
                        Task { await weather.refresh() }
                    }
                } else {
                    Text("Pull Open-Meteo air temperature and wind for your location, then compare with your manual dial.")
                        .font(ThemeMetrics.plate(14))
                        .foregroundColor(Palette.ivory)
                        .fixedSize(horizontal: false, vertical: true)
                    BrassAction(title: "Fetch live weather", enabled: true) {
                        Task { await weather.refresh() }
                    }
                }
            }
        }
    }

    private func compareText(liveTemp: Double, liveWind: Double) -> String? {
        guard let manualTemp, let manualWind else { return nil }
        let tempDelta = manualTemp - liveTemp
        let windDelta = manualWind - liveWind
        let tempPart: String
        if abs(tempDelta) < 0.4 {
            tempPart = "Manual air matches live"
        } else if tempDelta > 0 {
            tempPart = "Manual air is \(WindChillMath.formatted(tempDelta)) warmer than live"
        } else {
            tempPart = "Manual air is \(WindChillMath.formatted(abs(tempDelta))) colder than live"
        }
        let windPart: String
        if abs(windDelta) < 0.6 {
            windPart = "wind matches"
        } else if windDelta > 0 {
            windPart = "manual wind is \(WindChillMath.formatted(windDelta)) \(units.windSymbol) stronger"
        } else {
            windPart = "manual wind is \(WindChillMath.formatted(abs(windDelta))) \(units.windSymbol) lighter"
        }
        return "\(tempPart); \(windPart)."
    }
}
