import SwiftUI

struct DialField: View {
    let label: String
    let unit: String
    @Binding var text: String
    let error: String?
    var step: Double? = nil
    var range: ClosedRange<Double>? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(ThemeMetrics.plate(12, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.2)
                Spacer()
                Text(unit)
                    .font(ThemeMetrics.plate(11, weight: .semibold))
                    .foregroundColor(Palette.ivory.opacity(0.7))
            }
            TextField("", text: $text)
                .keyboardType(.decimalPad)
                .font(ThemeMetrics.instrument(22, weight: .medium))
                .foregroundColor(Palette.ivory)
                .frame(height: ThemeMetrics.fieldHeight)
                .padding(.horizontal, 14)
                .background(Palette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(error == nil ? Palette.stroke : Palette.danger, lineWidth: ThemeMetrics.hairline)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            if step != nil, range != nil {
                HStack(spacing: 8) {
                    stepButton("−") { nudge(-1) }
                    stepButton("+") { nudge(1) }
                }
            }
            if let error {
                Text(error)
                    .font(ThemeMetrics.plate(12, weight: .medium))
                    .foregroundColor(Palette.danger)
            }
        }
    }

    private func nudge(_ direction: Double) {
        guard let step, let range else { return }
        let current = SafeParse.decimal(text) ?? 0
        let next = min(max(current + direction * step, range.lowerBound), range.upperBound)
        text = WindChillMath.formatted(next)
    }

    private func stepButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(ThemeMetrics.plate(18, weight: .bold))
                .foregroundColor(Palette.gold)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Palette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Palette.gold.opacity(0.7), lineWidth: ThemeMetrics.hairline)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title == "+" ? "Increase \(label)" : "Decrease \(label)")
    }
}
