import Foundation

enum InputLimits {
    static let metricTemperature = -50.0...50.0
    static let metricWind = 0.0...150.0

    static func temperatureRange(for units: PreferredUnits) -> ClosedRange<Double> {
        switch units {
        case .metric:
            return metricTemperature
        case .imperial:
            let lower = UnitBridge.temperature(metricTemperature.lowerBound, from: .metric, to: .imperial)
            let upper = UnitBridge.temperature(metricTemperature.upperBound, from: .metric, to: .imperial)
            return lower...upper
        }
    }

    static func windRange(for units: PreferredUnits) -> ClosedRange<Double> {
        switch units {
        case .metric:
            return metricWind
        case .imperial:
            let lower = UnitBridge.wind(metricWind.lowerBound, from: .metric, to: .imperial)
            let upper = UnitBridge.wind(metricWind.upperBound, from: .metric, to: .imperial)
            return lower...upper
        }
    }

    static func temperatureError(_ value: Double?, units: PreferredUnits) -> String? {
        guard let value else {
            return "Enter air temperature."
        }
        let range = temperatureRange(for: units)
        if range.contains(value) {
            return nil
        }
        return "Temperature must be \(WindChillMath.formatted(range.lowerBound, decimals: 0)) to \(WindChillMath.formatted(range.upperBound, decimals: 0)) \(units.temperatureSymbol)."
    }

    static func windError(_ value: Double?, units: PreferredUnits) -> String? {
        guard let value else {
            return "Enter wind speed."
        }
        let range = windRange(for: units)
        if range.contains(value) {
            return nil
        }
        return "Wind must be \(WindChillMath.formatted(range.lowerBound, decimals: 0)) to \(WindChillMath.formatted(range.upperBound, decimals: 0)) \(units.windSymbol)."
    }
}
