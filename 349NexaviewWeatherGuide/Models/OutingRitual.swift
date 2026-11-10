import Foundation

enum GoDecision: String, Codable, CaseIterable, Identifiable {
    case go
    case caution
    case highCaution
    case noGo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .go: return "GO"
        case .caution: return "CAUTION"
        case .highCaution: return "HIGH CAUTION"
        case .noGo: return "NO-GO"
        }
    }

    var detail: String {
        switch self {
        case .go:
            return "Conditions look workable for this scenario. Pack the kit and keep an eye on wind shifts."
        case .caution:
            return "Cold enough to bite. Shorten the window, cover extremities, and start the exposure timer."
        case .highCaution:
            return "Severe chill. Limit outdoor time, seal every exposed area, and prefer sheltered routes."
        case .noGo:
            return "Frostbite-range chill. Prefer postponing or staying near shelter unless you are fully prepared."
        }
    }
}

enum OutingSeverity: String, Codable, CaseIterable, Identifiable {
    case mild
    case harsh
    case extreme

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mild: return "Mild"
        case .harsh: return "Harsh"
        case .extreme: return "Extreme"
        }
    }
}

struct OutingBrief: Codable, Equatable {
    var dayKey: String
    var activity: TrailActivity
    var chill: Double
    var units: PreferredUnits
    var decision: GoDecision
    var kitItems: [String]
    var sealedAt: Date

    static func dayKey(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct OutingSeal: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var activity: TrailActivity
    var minutesOutside: Int
    var severity: OutingSeverity
    var carryNote: String
    var chill: Double
    var units: PreferredUnits

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        activity: TrailActivity,
        minutesOutside: Int,
        severity: OutingSeverity,
        carryNote: String,
        chill: Double,
        units: PreferredUnits
    ) {
        self.id = id
        self.date = date
        self.activity = activity
        self.minutesOutside = minutesOutside
        self.severity = severity
        self.carryNote = carryNote
        self.chill = chill
        self.units = units
    }
}

enum GoNoGo {
    static func decide(chill: Double, units: PreferredUnits, activity: TrailActivity) -> GoDecision {
        let chillC = UnitBridge.temperature(chill, from: units, to: .metric)
        let adjusted: Double
        switch activity {
        case .hiking: adjusted = chillC
        case .skiing: adjusted = chillC - 2
        case .working: adjusted = chillC - 3
        }
        if adjusted < -27 { return .noGo }
        if adjusted < -18 { return .highCaution }
        if adjusted < -5 { return .caution }
        return .go
    }
}
