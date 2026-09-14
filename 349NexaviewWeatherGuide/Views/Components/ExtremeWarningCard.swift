import SwiftUI

struct ExtremeWarningCard: View {
    let chillText: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Palette.danger)
                .frame(width: 10, height: 10)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 4) {
                Text("EXTREME CHILL")
                    .font(ThemeMetrics.plate(12, weight: .bold))
                    .foregroundColor(Palette.danger)
                    .tracking(1.4)
                Text("Reading \(chillText) is below the frostbite threshold. Limit exposed skin and shorten time on the ridge.")
                    .font(ThemeMetrics.plate(14))
                    .foregroundColor(Palette.ivory)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Palette.card)
        .overlay(
            RoundedRectangle(cornerRadius: ThemeMetrics.plateCorner, style: .continuous)
                .stroke(Palette.danger.opacity(0.85), lineWidth: 1.4)
        )
        .clipShape(RoundedRectangle(cornerRadius: ThemeMetrics.plateCorner, style: .continuous))
    }
}
