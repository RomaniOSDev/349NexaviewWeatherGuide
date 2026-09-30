import SwiftUI

struct ExposureTimerCard: View {
    @EnvironmentObject private var store: ChillStore
    @State private var tick = Date()

    var body: some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 10) {
                Text("EXPOSURE WINDOW")
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.5)
                Text(store.isExposureRunning ? remainingLabel : "\(store.exposureLimitMinutes) min planned")
                    .font(ThemeMetrics.instrument(26, weight: .bold))
                    .foregroundColor(Palette.ivory)
                Text(store.isExposureRunning
                     ? "Local alert fires when this window ends."
                     : "Start a timed outdoor session for \(store.activity.title.lowercased()).")
                    .font(ThemeMetrics.plate(13))
                    .foregroundColor(Palette.ivory.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    stepButton(title: "−15", enabled: !store.isExposureRunning) {
                        store.setExposureLimitMinutes(store.exposureLimitMinutes - 15)
                    }
                    stepButton(title: "+15", enabled: !store.isExposureRunning) {
                        store.setExposureLimitMinutes(store.exposureLimitMinutes + 15)
                    }
                    Spacer()
                    Button {
                        if store.isExposureRunning {
                            store.stopExposureSession()
                        } else {
                            store.startExposureSession()
                        }
                    } label: {
                        Text(store.isExposureRunning ? "Stop" : "Start timer")
                            .font(ThemeMetrics.plate(14, weight: .bold))
                            .foregroundColor(Palette.ink)
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .background(Palette.gold)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in
            tick = date
            if store.isExposureRunning, remainingSeconds <= 0 {
                store.stopExposureSession()
            }
        }
    }

    private var remainingSeconds: Int {
        guard let started = store.exposureStartedAt else { return store.exposureLimitMinutes * 60 }
        let elapsed = Int(tick.timeIntervalSince(started))
        return max(0, store.exposureLimitMinutes * 60 - elapsed)
    }

    private var remainingLabel: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d left", minutes, seconds)
    }

    private func stepButton(title: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(ThemeMetrics.plate(13, weight: .semibold))
                .foregroundColor(enabled ? Palette.ivory : Palette.ivory.opacity(0.35))
                .frame(width: 52, height: 36)
                .background(Palette.purple.opacity(0.45))
                .overlay(
                    Capsule().stroke(Palette.gold.opacity(0.6), lineWidth: ThemeMetrics.hairline)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}
