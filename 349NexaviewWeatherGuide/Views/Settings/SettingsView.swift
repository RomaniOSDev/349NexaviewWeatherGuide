import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: ChillStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false

    var body: some View {
        RidgeBackdrop {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    TrailBanner(kind: .trends, eyebrow: "PREFERENCES", title: "Plan and alerts")
                    unitsPlate
                    alertsPlate
                    actionPlate(title: "Change scenario", detail: "Re-open hiking / working / skiing onboarding.") {
                        store.hasCompletedOnboarding = false
                        UserDefaults.standard.set(false, forKey: DefaultsKeys.onboardingDone)
                        dismiss()
                    }
                    actionPlate(title: "Rate Us", detail: "Leave a short App Store review.") {
                        RatePrompt.present()
                    }
                    actionPlate(title: "Privacy", detail: "Read how readings and location stay under your control.") {
                        open(AppLinks.privacy)
                    }
                    actionPlate(title: "Terms", detail: "Review the conditions of use.") {
                        open(AppLinks.terms)
                    }
                    actionPlate(title: "Reset All Data", detail: "Clears logs, recents, sites, alerts, activity, and units.", danger: true) {
                        confirmReset = true
                    }
                    Button("Close") { dismiss() }
                        .font(ThemeMetrics.plate(14, weight: .semibold))
                        .foregroundColor(Palette.ivory)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
                .padding(ThemeMetrics.pagePadding)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .alert("Reset All Data", isPresented: $confirmReset) {
            Button("Reset", role: .destructive) {
                store.resetAllData()
                dismiss()
            }
            Button("Keep Data", role: .cancel) { }
        } message: {
            Text("This removes every saved reading, recent dial, last inputs, site presets, activity, alerts, and unit preference.")
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
            dismiss()
        }
    }

    private var unitsPlate: some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 10) {
                Text("UNITS")
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.5)
                ForEach(PreferredUnits.allCases) { units in
                    Button {
                        store.setUnits(units)
                    } label: {
                        HStack {
                            Text(units.toggleTitle)
                                .font(ThemeMetrics.plate(15, weight: .medium))
                                .foregroundColor(Palette.ivory)
                            Spacer()
                            Circle()
                                .stroke(Palette.gold, lineWidth: 1.6)
                                .frame(width: 18, height: 18)
                                .overlay {
                                    if store.preferredUnits == units {
                                        Circle()
                                            .fill(Palette.gold)
                                            .frame(width: 10, height: 10)
                                    }
                                }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var alertsPlate: some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 12) {
                Text("CHILL ALERT")
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.5)
                Toggle(isOn: Binding(
                    get: { store.chillAlertEnabled },
                    set: { store.setChillAlertEnabled($0) }
                )) {
                    Text("Notify when chill hits threshold")
                        .font(ThemeMetrics.plate(14))
                        .foregroundColor(Palette.ivory)
                }
                .tint(Palette.gold)
                if store.chillAlertEnabled {
                    HStack {
                        Text("Threshold")
                            .font(ThemeMetrics.plate(14))
                            .foregroundColor(Palette.ivory)
                        Spacer()
                        Text("\(WindChillMath.formatted(store.chillAlertThreshold)) \(store.preferredUnits.temperatureSymbol)")
                            .font(ThemeMetrics.plate(14, weight: .semibold))
                            .foregroundColor(Palette.gold)
                    }
                    Slider(
                        value: Binding(
                            get: { store.chillAlertThreshold },
                            set: { store.setChillAlertThreshold($0) }
                        ),
                        in: store.preferredUnits == .metric ? -40...5 : -40...40,
                        step: 1
                    )
                    .tint(Palette.gold)
                    BrassAction(title: "Allow notifications", enabled: true) {
                        Task { _ = await ChillNotificationCenter.requestAuthorizationIfNeeded() }
                    }
                }
            }
        }
    }

    private func actionPlate(title: String, detail: String, danger: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(ThemeMetrics.plate(16, weight: .semibold))
                        .foregroundColor(danger ? Palette.danger : Palette.ivory)
                    Text(detail)
                        .font(ThemeMetrics.plate(13))
                        .foregroundColor(Palette.ivory.opacity(0.7))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Palette.gold)
            }
            .padding(14)
            .background(Palette.card.opacity(0.92))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Palette.gold.opacity(0.45), lineWidth: ThemeMetrics.hairline)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func open(_ url: URL?) {
        guard let url else { return }
        UIApplication.shared.open(url)
    }
}
