import Combine
import Foundation

@MainActor
final class ChillStore: ObservableObject {
    @Published var recentCalculations: [WindChillEntry] = []
    @Published var windChillEntries: [WindChillEntry] = []
    @Published var preferredUnits: PreferredUnits = .metric
    @Published var lastInputTemp: Double = 0
    @Published var lastInputWindSpeed: Double = 0
    @Published var activity: TrailActivity = .hiking
    @Published var selectedSite: SitePreset?
    @Published var draftNote: String = ""
    @Published var dialRevision: Int = 0
    @Published var requestedSection: MainSection?

    private let defaults: UserDefaults
    private var bag = Set<AnyCancellable>()
    private var siteDials: [String: SiteDial] = [:]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadAll()
        NotificationCenter.default.publisher(for: Notification.Name("dataReset"))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.loadAll()
                }
            }
            .store(in: &bag)
    }

    func persistInputs(temperature: Double, windSpeed: Double) {
        lastInputTemp = temperature
        lastInputWindSpeed = windSpeed
        defaults.set(temperature, forKey: DefaultsKeys.lastInputTemp)
        defaults.set(windSpeed, forKey: DefaultsKeys.lastInputWindSpeed)
    }

    func setUnits(_ units: PreferredUnits) {
        guard units != preferredUnits else { return }
        lastInputTemp = UnitBridge.temperature(lastInputTemp, from: preferredUnits, to: units)
        lastInputWindSpeed = UnitBridge.wind(lastInputWindSpeed, from: preferredUnits, to: units)
        preferredUnits = units
        persistAll()
    }

    func setActivity(_ activity: TrailActivity) {
        self.activity = activity
        defaults.set(activity.rawValue, forKey: DefaultsKeys.trailActivity)
    }

    func applySite(_ site: SitePreset) {
        selectedSite = site
        draftNote = site.title
        if let dial = siteDials[site.rawValue] {
            lastInputTemp = UnitBridge.temperature(dial.temperature, from: dial.units, to: preferredUnits)
            lastInputWindSpeed = UnitBridge.wind(dial.windSpeed, from: dial.units, to: preferredUnits)
            persistInputs(temperature: lastInputTemp, windSpeed: lastInputWindSpeed)
        }
        defaults.set(site.rawValue, forKey: DefaultsKeys.selectedSite)
        dialRevision += 1
    }

    func syncSelectedSite(with note: String) {
        selectedSite = SitePreset.matching(note: note)
        if let selectedSite {
            defaults.set(selectedSite.rawValue, forKey: DefaultsKeys.selectedSite)
        } else {
            defaults.removeObject(forKey: DefaultsKeys.selectedSite)
        }
    }

    func consumeDraftNote() -> String {
        let note = draftNote
        draftNote = ""
        return note
    }

    func rememberSite(temperature: Double, windSpeed: Double, note: String) {
        let site = selectedSite ?? SitePreset.matching(note: note)
        guard let site else { return }
        siteDials[site.rawValue] = SiteDial(
            temperature: temperature,
            windSpeed: windSpeed,
            units: preferredUnits
        )
        selectedSite = site
        persistSites()
        defaults.set(site.rawValue, forKey: DefaultsKeys.selectedSite)
    }

    func reuseOnDial(_ entry: WindChillEntry) {
        lastInputTemp = entry.temperature(in: preferredUnits)
        lastInputWindSpeed = entry.windSpeed(in: preferredUnits)
        persistInputs(temperature: lastInputTemp, windSpeed: lastInputWindSpeed)
        draftNote = entry.locationNote
        syncSelectedSite(with: entry.locationNote)
        dialRevision += 1
        requestedSection = .measure
    }

    func record(temperature: Double, windSpeed: Double, locationNote: String) -> WindChillEntry {
        let chill = WindChillMath.chill(temperature: temperature, windSpeed: windSpeed, units: preferredUnits)
        let entry = WindChillEntry(
            temperature: temperature,
            windSpeed: windSpeed,
            chill: chill,
            locationNote: locationNote,
            units: preferredUnits
        )
        windChillEntries.insert(entry, at: 0)
        recentCalculations.insert(entry, at: 0)
        if recentCalculations.count > 12 {
            recentCalculations = Array(recentCalculations.prefix(12))
        }
        persistInputs(temperature: temperature, windSpeed: windSpeed)
        rememberSite(temperature: temperature, windSpeed: windSpeed, note: locationNote)
        persistAll()
        return entry
    }

    func update(_ entry: WindChillEntry) {
        let chill = WindChillMath.chill(temperature: entry.temperature, windSpeed: entry.windSpeed, units: entry.units)
        var revised = entry
        revised.chill = chill
        replace(revised, in: &windChillEntries)
        replace(revised, in: &recentCalculations)
        persistAll()
    }

    func delete(_ entry: WindChillEntry) {
        windChillEntries.removeAll { $0.id == entry.id }
        recentCalculations.removeAll { $0.id == entry.id }
        persistAll()
    }

    func resetAllData() {
        recentCalculations = []
        windChillEntries = []
        preferredUnits = .metric
        lastInputTemp = 0
        lastInputWindSpeed = 0
        activity = .hiking
        selectedSite = nil
        draftNote = ""
        siteDials = [:]
        dialRevision += 1
        defaults.removeObject(forKey: DefaultsKeys.recentCalculations)
        defaults.removeObject(forKey: DefaultsKeys.windChillEntries)
        defaults.removeObject(forKey: DefaultsKeys.preferredUnits)
        defaults.removeObject(forKey: DefaultsKeys.lastInputTemp)
        defaults.removeObject(forKey: DefaultsKeys.lastInputWindSpeed)
        defaults.removeObject(forKey: DefaultsKeys.trailActivity)
        defaults.removeObject(forKey: DefaultsKeys.selectedSite)
        defaults.removeObject(forKey: DefaultsKeys.siteDials)
        NotificationCenter.default.post(name: Notification.Name("dataReset"), object: nil)
    }

    func loadAll() {
        recentCalculations = decodeEntries(key: DefaultsKeys.recentCalculations)
        windChillEntries = decodeEntries(key: DefaultsKeys.windChillEntries)
        if let raw = defaults.string(forKey: DefaultsKeys.preferredUnits),
           let units = PreferredUnits(rawValue: raw) {
            preferredUnits = units
        } else {
            preferredUnits = .metric
        }
        if defaults.object(forKey: DefaultsKeys.lastInputTemp) != nil {
            lastInputTemp = defaults.double(forKey: DefaultsKeys.lastInputTemp)
        } else {
            lastInputTemp = 0
        }
        if defaults.object(forKey: DefaultsKeys.lastInputWindSpeed) != nil {
            lastInputWindSpeed = defaults.double(forKey: DefaultsKeys.lastInputWindSpeed)
        } else {
            lastInputWindSpeed = 0
        }
        if let raw = defaults.string(forKey: DefaultsKeys.trailActivity),
           let stored = TrailActivity(rawValue: raw) {
            activity = stored
        } else {
            activity = .hiking
        }
        if let raw = defaults.string(forKey: DefaultsKeys.selectedSite),
           let site = SitePreset(rawValue: raw) {
            selectedSite = site
        } else {
            selectedSite = nil
        }
        if let data = defaults.data(forKey: DefaultsKeys.siteDials),
           let decoded = try? JSONDecoder().decode([String: SiteDial].self, from: data) {
            siteDials = decoded
        } else {
            siteDials = [:]
        }
    }

    private func persistAll() {
        encodeEntries(recentCalculations, key: DefaultsKeys.recentCalculations)
        encodeEntries(windChillEntries, key: DefaultsKeys.windChillEntries)
        defaults.set(preferredUnits.rawValue, forKey: DefaultsKeys.preferredUnits)
        defaults.set(lastInputTemp, forKey: DefaultsKeys.lastInputTemp)
        defaults.set(lastInputWindSpeed, forKey: DefaultsKeys.lastInputWindSpeed)
        defaults.set(activity.rawValue, forKey: DefaultsKeys.trailActivity)
        persistSites()
        if let selectedSite {
            defaults.set(selectedSite.rawValue, forKey: DefaultsKeys.selectedSite)
        } else {
            defaults.removeObject(forKey: DefaultsKeys.selectedSite)
        }
    }

    private func persistSites() {
        if let data = try? JSONEncoder().encode(siteDials) {
            defaults.set(data, forKey: DefaultsKeys.siteDials)
        }
    }

    private func decodeEntries(key: String) -> [WindChillEntry] {
        guard let data = defaults.data(forKey: key) else { return [] }
        if let decoded = try? JSONDecoder().decode([WindChillEntry].self, from: data) {
            return decoded
        }
        return []
    }

    private func encodeEntries(_ entries: [WindChillEntry], key: String) {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: key)
        }
    }

    private func replace(_ entry: WindChillEntry, in collection: inout [WindChillEntry]) {
        if let index = collection.firstIndex(where: { $0.id == entry.id }) {
            collection[index] = entry
        }
    }
}
