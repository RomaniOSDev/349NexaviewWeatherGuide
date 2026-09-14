import SwiftUI

struct SegmentRail: View {
    @Binding var section: MainSection

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainSection.allCases) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        section = item
                    }
                } label: {
                    Text(item.title)
                        .font(ThemeMetrics.plate(12, weight: .semibold))
                        .foregroundColor(section == item ? Palette.ink : Palette.ivory)
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .frame(height: ThemeMetrics.railHeight)
                        .background(
                            Capsule()
                                .fill(section == item ? Palette.gold : Palette.purple.opacity(0.01))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Palette.purple.opacity(0.72))
        )
        .overlay(
            Capsule()
                .stroke(Palette.gold.opacity(0.7), lineWidth: ThemeMetrics.hairline)
        )
    }
}
