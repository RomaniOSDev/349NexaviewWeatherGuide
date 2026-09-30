import SwiftUI
import UIKit

struct TripShareCard: View {
    let chill: Double
    let units: PreferredUnits
    let activity: TrailActivity
    let kitItems: [String]
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NEXAVIEW COLD PLAN")
                        .font(ThemeMetrics.plate(11, weight: .bold))
                        .foregroundColor(Palette.gold)
                        .tracking(1.4)
                    Text(activity.onboardingTitle)
                        .font(ThemeMetrics.instrument(24, weight: .bold))
                        .foregroundColor(Palette.ivory)
                }
                Spacer()
                Image(systemName: "snowflake")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Palette.gold)
            }
            Text("\(WindChillMath.formatted(chill)) \(units.temperatureSymbol)")
                .font(ThemeMetrics.instrument(48, weight: .bold))
                .foregroundColor(Palette.gold)
            Text("Wind chill · kit for this session")
                .font(ThemeMetrics.plate(13))
                .foregroundColor(Palette.ivory.opacity(0.8))
            if !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(note)
                    .font(ThemeMetrics.plate(14, weight: .semibold))
                    .foregroundColor(Palette.ivory)
            }
            VStack(alignment: .leading, spacing: 6) {
                ForEach(kitItems, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Palette.gold)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        Text(item)
                            .font(ThemeMetrics.plate(14))
                            .foregroundColor(Palette.ivory)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(22)
        .frame(width: 320, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Palette.purple, Palette.card],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Palette.gold.opacity(0.7), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

enum TripCardExporter {
    @MainActor
    static func renderImage(
        chill: Double,
        units: PreferredUnits,
        activity: TrailActivity,
        note: String
    ) -> UIImage {
        let kit = ClothingAdvice.kitItems(chill: chill, units: units, activity: activity)
        let card = TripShareCard(
            chill: chill,
            units: units,
            activity: activity,
            kitItems: kit,
            note: note
        )
        let renderer = ImageRenderer(content: card)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage ?? UIImage()
    }
}

struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var onComplete: (() -> Void)? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in
            onComplete?()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
