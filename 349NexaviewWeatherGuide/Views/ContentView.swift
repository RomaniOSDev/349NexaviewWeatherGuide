import SwiftUI

struct ContentView: View {
    @StateObject private var store = ChillStore()
    @State private var section: MainSection = .measure
    @State private var showSettings = false

    var body: some View {
        RidgeBackdrop {
            VStack(spacing: 14) {
                HStack(alignment: .center, spacing: 10) {
                    SegmentRail(section: $section)
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Palette.ink)
                            .frame(width: ThemeMetrics.railHeight, height: ThemeMetrics.railHeight)
                            .background(Palette.gold)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Palette.purple.opacity(0.4), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Settings")
                }
                .padding(.horizontal, ThemeMetrics.pagePadding)
                .padding(.top, 10)

                Group {
                    switch section {
                    case .measure:
                        MeasureView()
                    case .log:
                        LogView()
                    case .contrast:
                        ContrastView()
                    case .stats:
                        StatsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .environmentObject(store)
        .tint(Palette.gold)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(store)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
            showSettings = false
        }
        .onChange(of: store.requestedSection) { target in
            guard let target else { return }
            withAnimation(.easeInOut(duration: 0.22)) {
                section = target
            }
            Task { @MainActor in
                store.requestedSection = nil
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
