import SwiftUI

struct EntryPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let entries: [WindChillEntry]
    let units: PreferredUnits
    let excluding: UUID?
    let onPick: (WindChillEntry) -> Void

    var body: some View {
        RidgeBackdrop {
            VStack(alignment: .leading, spacing: 14) {
                TrailBanner(kind: .match, eyebrow: "CHOOSE READING", title: title)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(entries.filter { $0.id != excluding }) { entry in
                            Button {
                                onPick(entry)
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(WindChillMath.formatted(entry.chill(in: units))) \(units.temperatureSymbol)")
                                            .font(ThemeMetrics.instrument(20, weight: .bold))
                                            .foregroundColor(Palette.gold)
                                        Text(entry.locationNote.isEmpty ? DateStamp.medium(entry.date) : entry.locationNote)
                                            .font(ThemeMetrics.plate(13))
                                            .foregroundColor(Palette.ivory)
                                    }
                                    Spacer()
                                    Circle()
                                        .stroke(Palette.gold, lineWidth: 1.4)
                                        .frame(width: 18, height: 18)
                                }
                                .padding(12)
                                .background(Palette.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Palette.gold.opacity(0.4), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Button("Close") { dismiss() }
                    .font(ThemeMetrics.plate(14, weight: .semibold))
                    .foregroundColor(Palette.ivory)
                    .frame(maxWidth: .infinity)
            }
            .padding(ThemeMetrics.pagePadding)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
            dismiss()
        }
    }
}
