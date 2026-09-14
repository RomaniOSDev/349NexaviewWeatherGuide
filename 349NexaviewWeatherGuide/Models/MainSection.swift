import Foundation

enum MainSection: String, CaseIterable, Identifiable {
    case measure
    case log
    case contrast
    case stats

    var id: String { rawValue }

    var title: String {
        switch self {
        case .measure: return "Measure"
        case .log: return "Log"
        case .contrast: return "Contrast"
        case .stats: return "Stats"
        }
    }
}
