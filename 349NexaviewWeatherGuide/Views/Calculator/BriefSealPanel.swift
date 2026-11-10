import SwiftUI

struct BriefSealPanel: View {
    @EnvironmentObject private var store: ChillStore
    let chill: Double
    let isValid: Bool
    @State private var showSealSheet = false
    @State private var minutesText = "45"
    @State private var severity: OutingSeverity = .harsh
    @State private var carryNote = ""

    private var decision: GoDecision {
        GoNoGo.decide(chill: chill, units: store.preferredUnits, activity: store.activity)
    }

    var body: some View {
        VStack(spacing: 14) {
            if let carry = store.latestCarryNote {
                InstrumentPlate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CARRY FROM LAST OUTING")
                            .font(ThemeMetrics.plate(11, weight: .bold))
                            .foregroundColor(Palette.gold)
                            .tracking(1.5)
                        Text(carry)
                            .font(ThemeMetrics.plate(15))
                            .foregroundColor(Palette.ivory)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            InstrumentPlate {
                VStack(alignment: .leading, spacing: 10) {
                    Text("PRE-OUTING BRIEF")
                        .font(ThemeMetrics.plate(11, weight: .bold))
                        .foregroundColor(Palette.gold)
                        .tracking(1.5)
                    Text(decision.title)
                        .font(ThemeMetrics.instrument(28, weight: .bold))
                        .foregroundColor(decisionColor)
                    Text(decision.detail)
                        .font(ThemeMetrics.plate(14))
                        .foregroundColor(Palette.ivory)
                        .fixedSize(horizontal: false, vertical: true)

                    if let brief = store.todaysBrief, store.isTodaysBriefSealed {
                        Text("Sealed for today · \(WindChillMath.formatted(brief.chill)) \(brief.units.temperatureSymbol) · \(brief.activity.title)")
                            .font(ThemeMetrics.plate(13, weight: .semibold))
                            .foregroundColor(Palette.gold)
                        ForEach(brief.kitItems.prefix(5), id: \.self) { item in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Palette.gold)
                                    .font(.system(size: 13))
                                Text(item)
                                    .font(ThemeMetrics.plate(13))
                                    .foregroundColor(Palette.ivory)
                            }
                        }
                        BrassAction(title: "Reseal brief", enabled: isValid) {
                            store.sealTodaysBrief(chill: chill)
                        }
                    } else {
                        BrassAction(title: "Seal today's brief", enabled: isValid) {
                            store.sealTodaysBrief(chill: chill)
                        }
                    }
                }
            }

            InstrumentPlate {
                VStack(alignment: .leading, spacing: 10) {
                    Text("OUTING SEAL")
                        .font(ThemeMetrics.plate(11, weight: .bold))
                        .foregroundColor(Palette.gold)
                        .tracking(1.5)
                    Text("Close the session: log minutes, how harsh it felt, and one note to carry into the next brief.")
                        .font(ThemeMetrics.plate(14))
                        .foregroundColor(Palette.ivory)
                        .fixedSize(horizontal: false, vertical: true)
                    BrassAction(title: "Seal outing", enabled: true) {
                        minutesText = "\(store.exposureLimitMinutes)"
                        severity = decision == .go ? .mild : (decision == .noGo ? .extreme : .harsh)
                        carryNote = ""
                        showSealSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showSealSheet) {
            sealSheet
        }
    }

    private var decisionColor: Color {
        switch decision {
        case .go: return Palette.ivory
        case .caution, .highCaution: return Palette.gold
        case .noGo: return Palette.danger
        }
    }

    private var sealSheet: some View {
        RidgeBackdrop {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    TrailBanner(kind: .journal, eyebrow: "CLOSE THE LOOP", title: "Seal this outing")
                    InstrumentPlate {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MINUTES OUTSIDE")
                                .font(ThemeMetrics.plate(11, weight: .bold))
                                .foregroundColor(Palette.gold)
                                .tracking(1.5)
                            TextField("45", text: $minutesText)
                                .keyboardType(.numberPad)
                                .font(ThemeMetrics.plate(16))
                                .foregroundColor(Palette.ivory)
                                .padding(.horizontal, 12)
                                .frame(height: 44)
                                .background(Palette.purple.opacity(0.45))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                    InstrumentPlate {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("HOW HARSH")
                                .font(ThemeMetrics.plate(11, weight: .bold))
                                .foregroundColor(Palette.gold)
                                .tracking(1.5)
                            HStack(spacing: 8) {
                                ForEach(OutingSeverity.allCases) { item in
                                    Button {
                                        severity = item
                                    } label: {
                                        Text(item.title)
                                            .font(ThemeMetrics.plate(13, weight: .semibold))
                                            .foregroundColor(severity == item ? Palette.ink : Palette.ivory)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 36)
                                            .background(severity == item ? Palette.gold : Palette.purple.opacity(0.45))
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    InstrumentPlate {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CARRY NOTE FOR NEXT BRIEF")
                                .font(ThemeMetrics.plate(11, weight: .bold))
                                .foregroundColor(Palette.gold)
                                .tracking(1.5)
                            TextField("Bring thicker mitts next time…", text: $carryNote, axis: .vertical)
                                .lineLimit(3...5)
                                .font(ThemeMetrics.plate(15))
                                .foregroundColor(Palette.ivory)
                        }
                    }
                    BrassAction(title: "Save outing seal", enabled: true) {
                        let minutes = Int(minutesText) ?? store.exposureLimitMinutes
                        store.sealOuting(
                            minutesOutside: minutes,
                            severity: severity,
                            carryNote: carryNote,
                            chill: chill
                        )
                        showSealSheet = false
                    }
                    Button("Cancel") { showSealSheet = false }
                        .font(ThemeMetrics.plate(14, weight: .semibold))
                        .foregroundColor(Palette.ivory)
                        .frame(maxWidth: .infinity)
                }
                .padding(ThemeMetrics.pagePadding)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .preferredColorScheme(.dark)
    }
}
