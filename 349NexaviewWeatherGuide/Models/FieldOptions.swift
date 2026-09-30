import Foundation

enum TrailActivity: String, CaseIterable, Identifiable, Codable {
    case hiking
    case skiing
    case working

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hiking: return "Hiking"
        case .skiing: return "Skiing"
        case .working: return "Working"
        }
    }

    var onboardingTitle: String {
        switch self {
        case .hiking: return "Hiking today"
        case .skiing: return "Skiing"
        case .working: return "Working outside"
        }
    }

    var onboardingDetail: String {
        switch self {
        case .hiking:
            return "Pace, climbs, and wind on open trail — we tune kit tips for moving heat."
        case .skiing:
            return "Descent wind hits harder than the climb. We bias for shell, face, and goggles."
        case .working:
            return "Low movement outdoor shifts cool you faster — longer layers and earlier alerts."
        }
    }

    var defaultExposureMinutes: Int {
        switch self {
        case .hiking: return 90
        case .skiing: return 60
        case .working: return 45
        }
    }

    static func migrating(rawValue: String) -> TrailActivity? {
        if rawValue == "standing" { return .working }
        return TrailActivity(rawValue: rawValue)
    }
}

enum SitePreset: String, CaseIterable, Identifiable, Codable {
    case outlook
    case shore
    case shelter

    var id: String { rawValue }

    var title: String {
        switch self {
        case .outlook: return "Outlook"
        case .shore: return "Shore"
        case .shelter: return "Shelter"
        }
    }

    static func matching(note: String) -> SitePreset? {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if let match = allCases.first(where: { $0.title.compare(trimmed, options: .caseInsensitive) == .orderedSame }) {
            return match
        }
        // Legacy ridge/lake/camp notes from earlier builds
        switch trimmed.lowercased() {
        case "ridge": return .outlook
        case "lake trail": return .shore
        case "camp": return .shelter
        default: return nil
        }
    }

    static func migrating(rawValue: String) -> SitePreset? {
        switch rawValue {
        case "ridge": return .outlook
        case "lake": return .shore
        case "camp": return .shelter
        default: return SitePreset(rawValue: rawValue)
        }
    }
}

struct SiteDial: Codable, Equatable {
    var temperature: Double
    var windSpeed: Double
    var units: PreferredUnits
}
