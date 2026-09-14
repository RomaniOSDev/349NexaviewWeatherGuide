import Foundation

enum TrailActivity: String, CaseIterable, Identifiable, Codable {
    case hiking
    case skiing
    case standing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hiking: return "Hiking"
        case .skiing: return "Skiing"
        case .standing: return "Standing"
        }
    }
}

enum SitePreset: String, CaseIterable, Identifiable, Codable {
    case ridge
    case lake
    case camp

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ridge: return "Ridge"
        case .lake: return "Lake trail"
        case .camp: return "Camp"
        }
    }

    static func matching(note: String) -> SitePreset? {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        return allCases.first { $0.title.compare(trimmed, options: .caseInsensitive) == .orderedSame }
    }
}

struct SiteDial: Codable, Equatable {
    var temperature: Double
    var windSpeed: Double
    var units: PreferredUnits
}
