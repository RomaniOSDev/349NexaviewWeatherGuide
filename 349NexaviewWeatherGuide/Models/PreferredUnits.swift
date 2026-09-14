import Foundation

enum PreferredUnits: String, Codable, CaseIterable, Identifiable {
    case metric
    case imperial

    var id: String { rawValue }

    var temperatureSymbol: String {
        switch self {
        case .metric: return "°C"
        case .imperial: return "°F"
        }
    }

    var windSymbol: String {
        switch self {
        case .metric: return "km/h"
        case .imperial: return "mph"
        }
    }

    var toggleTitle: String {
        switch self {
        case .metric: return "Celsius / km/h"
        case .imperial: return "Fahrenheit / mph"
        }
    }
}
