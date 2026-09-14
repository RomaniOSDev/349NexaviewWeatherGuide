import SwiftUI

struct BrassAction: View {
    let title: String
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(ThemeMetrics.plate(16, weight: .bold))
                .foregroundColor(enabled ? Palette.ink : Palette.dim)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(enabled ? Palette.gold : Palette.card)
                .overlay(
                    Capsule()
                        .stroke(Palette.gold.opacity(0.8), lineWidth: ThemeMetrics.hairline)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}
