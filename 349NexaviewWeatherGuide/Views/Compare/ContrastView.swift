import SwiftUI

struct ContrastView: View {
    @EnvironmentObject private var store: ChillStore
    @State private var first: WindChillEntry?
    @State private var second: WindChillEntry?
    @State private var pickingSlot: Slot?

    private enum Slot: Identifiable {
        case first
        case second
        var id: String {
            switch self {
            case .first: return "first"
            case .second: return "second"
            }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                TrailBanner(kind: .match, eyebrow: "CONDITION MATCH", title: "Compare two days")
                slotPlate(title: "READING A", entry: first, action: { pickingSlot = .first })
                slotPlate(title: "READING B", entry: second, action: { pickingSlot = .second })
                if let comparison {
                    if comparison.first.isExtreme || comparison.second.isExtreme {
                        ExtremeWarningCard(chillText: "one of the selected logs")
                    }
                    ContrastResultPanel(comparison: comparison)
                } else if store.windChillEntries.count < 2 {
                    InstrumentPlate {
                        Text("Save at least two journal readings before matching them.")
                            .font(ThemeMetrics.plate(15))
                            .foregroundColor(Palette.ivory)
                    }
                }
            }
            .padding(.horizontal, ThemeMetrics.pagePadding)
            .padding(.bottom, 28)
        }
        .sheet(item: $pickingSlot) { slot in
            EntryPickerSheet(
                title: slot == .first ? "Reading A" : "Reading B",
                entries: store.windChillEntries,
                units: store.preferredUnits,
                excluding: slot == .first ? second?.id : first?.id,
                onPick: { picked in
                    switch slot {
                    case .first: first = picked
                    case .second: second = picked
                    }
                }
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
            first = nil
            second = nil
            pickingSlot = nil
        }
    }

    private var comparison: ChillComparison? {
        guard let first, let second else { return nil }
        return ChillComparison(first: first, second: second, displayUnits: store.preferredUnits, activity: store.activity)
    }

    private func slotPlate(title: String, entry: WindChillEntry?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(ThemeMetrics.plate(11, weight: .bold))
                        .foregroundColor(Palette.gold)
                        .tracking(1.3)
                    if let entry {
                        Text("\(WindChillMath.formatted(entry.chill(in: store.preferredUnits))) \(store.preferredUnits.temperatureSymbol)")
                            .font(ThemeMetrics.instrument(24, weight: .bold))
                            .foregroundColor(Palette.ivory)
                        Text(entry.locationNote.isEmpty ? DateStamp.medium(entry.date) : entry.locationNote)
                            .font(ThemeMetrics.plate(13))
                            .foregroundColor(Palette.ivory.opacity(0.75))
                    } else {
                        Text("Tap to pick a saved reading")
                            .font(ThemeMetrics.plate(15))
                            .foregroundColor(Palette.ivory)
                    }
                }
                Spacer()
                Image(systemName: "plus.circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Palette.gold)
            }
            .padding(14)
            .background(Palette.card)
            .overlay(
                RoundedRectangle(cornerRadius: ThemeMetrics.plateCorner, style: .continuous)
                    .stroke(Palette.gold.opacity(0.5), lineWidth: ThemeMetrics.hairline)
            )
            .clipShape(RoundedRectangle(cornerRadius: ThemeMetrics.plateCorner, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(store.windChillEntries.isEmpty)
    }
}
