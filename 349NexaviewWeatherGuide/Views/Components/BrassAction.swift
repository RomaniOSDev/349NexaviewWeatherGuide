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
                .background(
                    LinearGradient(
                        colors: enabled
                            ? [Palette.gold, Palette.gold.opacity(0.82)]
                            : [Palette.card, Palette.card],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Palette.gold.opacity(enabled ? 0.9 : 0.35), lineWidth: ThemeMetrics.hairline)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: enabled ? Palette.gold.opacity(0.25) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}
