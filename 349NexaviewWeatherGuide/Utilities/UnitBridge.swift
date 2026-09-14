import Foundation

enum UnitBridge {
    static func temperature(_ value: Double, from: PreferredUnits, to: PreferredUnits) -> Double {
        if from == to {
            return value
        }
        switch (from, to) {
        case (.metric, .imperial):
            return value * 9.0 / 5.0 + 32.0
        case (.imperial, .metric):
            return (value - 32.0) * 5.0 / 9.0
        default:
            return value
        }
    }

    static func wind(_ value: Double, from: PreferredUnits, to: PreferredUnits) -> Double {
        if from == to {
            return value
        }
        switch (from, to) {
        case (.metric, .imperial):
            return value / 1.609344
        case (.imperial, .metric):
            return value * 1.609344
        default:
            return value
        }
    }
}
