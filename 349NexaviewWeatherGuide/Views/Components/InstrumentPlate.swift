import SwiftUI

struct InstrumentPlate<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.card)
            .overlay(
                RoundedRectangle(cornerRadius: ThemeMetrics.plateCorner, style: .continuous)
                    .stroke(Palette.gold.opacity(0.45), lineWidth: ThemeMetrics.hairline)
            )
            .clipShape(RoundedRectangle(cornerRadius: ThemeMetrics.plateCorner, style: .continuous))
    }
}
