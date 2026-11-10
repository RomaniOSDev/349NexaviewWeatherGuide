import SwiftUI

struct InstrumentPlate<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Palette.gold)
                .frame(width: 4)
                .padding(.vertical, 10)
                .padding(.leading, 8)
            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            LinearGradient(
                colors: [Palette.card, Palette.purple.opacity(0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: ThemeMetrics.plateCorner, style: .continuous)
                .stroke(Palette.gold.opacity(0.4), lineWidth: ThemeMetrics.hairline)
        )
        .clipShape(RoundedRectangle(cornerRadius: ThemeMetrics.plateCorner, style: .continuous))
        .shadow(color: Color.black.opacity(0.22), radius: 10, x: 0, y: 6)
    }
}
