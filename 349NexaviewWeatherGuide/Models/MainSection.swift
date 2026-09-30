import Foundation

enum MainSection: String, CaseIterable, Identifiable {
    case chill
    case journal
    case match
    case trends

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chill: return "Chill"
        case .journal: return "Journal"
        case .match: return "Match"
        case .trends: return "Trends"
        }
    }
}
