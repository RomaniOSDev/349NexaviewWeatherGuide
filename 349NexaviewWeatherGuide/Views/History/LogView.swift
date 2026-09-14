import SwiftUI

struct LogView: View {
    @EnvironmentObject private var store: ChillStore
    @State private var editing: WindChillEntry?
    @State private var revealed: Set<UUID> = []
    @State private var searchText = ""
    @State private var extremeOnly = false
    @State private var sort: LogSort = .newest

    private enum LogSort: String, CaseIterable, Identifiable {
        case newest
        case coldest

        var id: String { rawValue }

        var title: String {
            switch self {
            case .newest: return "Newest"
            case .coldest: return "Coldest"
            }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                TrailBanner(kind: .layers, eyebrow: "SAVED READINGS", title: "Field log")
                if store.windChillEntries.isEmpty {
                    InstrumentPlate {
                        Text("No readings yet. Record a dial on Measure and it will land here.")
                            .font(ThemeMetrics.plate(15))
                            .foregroundColor(Palette.ivory)
                    }
                } else {
                    filterPlate
                    if visibleEntries.isEmpty {
                        InstrumentPlate {
                            Text("No logs match this search or filter.")
                                .font(ThemeMetrics.plate(15))
                                .foregroundColor(Palette.ivory)
                        }
                    } else {
                        ForEach(visibleEntries) { entry in
                            LogEntryRow(
                                entry: entry,
                                units: store.preferredUnits,
                                onEdit: { editing = entry },
                                onReuse: { store.reuseOnDial(entry) },
                                onDelete: { store.delete(entry) }
                            )
                            .opacity(revealed.contains(entry.id) ? 1 : 0)
                            .offset(y: revealed.contains(entry.id) ? 0 : 8)
                            .onAppear {
                                if revealed.contains(entry.id) { return }
                                withAnimation(.easeIn(duration: 0.45)) {
                                    revealed.insert(entry.id)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, ThemeMetrics.pagePadding)
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(.interactively)
        .sheet(item: $editing) { entry in
            LogEditSheet(entry: entry)
                .environmentObject(store)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
            editing = nil
            revealed = []
            searchText = ""
            extremeOnly = false
            sort = .newest
        }
    }

    private var visibleEntries: [WindChillEntry] {
        var items = store.windChillEntries
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            items = items.filter { $0.locationNote.localizedCaseInsensitiveContains(query) }
        }
        if extremeOnly {
            items = items.filter(\.isExtreme)
        }
        switch sort {
        case .newest:
            items.sort { $0.date > $1.date }
        case .coldest:
            items.sort { $0.chill(in: .metric) < $1.chill(in: .metric) }
        }
        return items
    }

    private var filterPlate: some View {
        InstrumentPlate {
            VStack(alignment: .leading, spacing: 10) {
                Text("FIND")
                    .font(ThemeMetrics.plate(11, weight: .bold))
                    .foregroundColor(Palette.gold)
                    .tracking(1.5)
                TextField("Search field notes", text: $searchText)
                    .font(ThemeMetrics.plate(15))
                    .foregroundColor(Palette.ivory)
                    .padding(.horizontal, 14)
                    .frame(height: 42)
                    .background(Palette.purple.opacity(0.45))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Palette.stroke, lineWidth: ThemeMetrics.hairline)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                HStack(spacing: 8) {
                    filterChip("Extreme", selected: extremeOnly) {
                        extremeOnly.toggle()
                    }
                    ForEach(LogSort.allCases) { option in
                        filterChip(option.title, selected: sort == option) {
                            sort = option
                        }
                    }
                }
            }
        }
    }

    private func filterChip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(ThemeMetrics.plate(13, weight: .semibold))
                .foregroundColor(selected ? Palette.ink : Palette.ivory)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(selected ? Palette.gold : Palette.purple.opacity(0.45))
                .overlay(
                    Capsule()
                        .stroke(Palette.gold.opacity(0.7), lineWidth: ThemeMetrics.hairline)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
