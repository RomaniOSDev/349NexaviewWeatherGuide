import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: ChillStore
    @State private var selected: TrailActivity = .hiking

    var body: some View {
        RidgeBackdrop {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    TrailBanner(kind: .exposure, eyebrow: "COLD EXPOSURE PLAN", title: "How are you outside today?")
                    Text("Pick a scenario. Kit tips, exposure timers, and the first screen adapt to how you move in the cold.")
                        .font(ThemeMetrics.plate(15))
                        .foregroundColor(Palette.ivory.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(TrailActivity.allCases) { activity in
                        Button {
                            selected = activity
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: icon(for: activity))
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(selected == activity ? Palette.ink : Palette.gold)
                                    .frame(width: 36, height: 36)
                                    .background(selected == activity ? Palette.gold : Palette.purple.opacity(0.45))
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(activity.onboardingTitle)
                                        .font(ThemeMetrics.plate(17, weight: .semibold))
                                        .foregroundColor(Palette.ivory)
                                    Text(activity.onboardingDetail)
                                        .font(ThemeMetrics.plate(13))
                                        .foregroundColor(Palette.ivory.opacity(0.75))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(14)
                            .background(Palette.card.opacity(0.92))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        selected == activity ? Palette.gold : Palette.gold.opacity(0.35),
                                        lineWidth: selected == activity ? 2 : ThemeMetrics.hairline
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    BrassAction(title: "Start planning", enabled: true) {
                        store.completeOnboarding(with: selected)
                    }
                    .padding(.top, 6)
                }
                .padding(ThemeMetrics.pagePadding)
                .padding(.bottom, 28)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .preferredColorScheme(.dark)
    }

    private func icon(for activity: TrailActivity) -> String {
        switch activity {
        case .hiking: return "figure.hiking"
        case .skiing: return "snowflake"
        case .working: return "wrench.and.screwdriver.fill"
        }
    }
}
