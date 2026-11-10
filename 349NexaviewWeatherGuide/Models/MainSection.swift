import Foundation

enum MainSection: String, CaseIterable, Identifiable {
    case brief
    case outings
    case match
    case pattern

    var id: String { rawValue }

    var title: String {
        switch self {
        case .brief: return "Brief"
        case .outings: return "Outings"
        case .match: return "Match"
        case .pattern: return "Pattern"
        }
    }
}
