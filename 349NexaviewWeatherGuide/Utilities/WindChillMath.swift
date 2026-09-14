import Foundation

enum WindChillMath {
    static func chill(temperature: Double, windSpeed: Double, units: PreferredUnits) -> Double {
        let temperatureF = UnitBridge.temperature(temperature, from: units, to: .imperial)
        let windMPH = UnitBridge.wind(windSpeed, from: units, to: .imperial)
        let chillF = nwsFahrenheit(temperatureF: temperatureF, windMPH: windMPH)
        return UnitBridge.temperature(chillF, from: .imperial, to: units)
    }

    static func nwsFahrenheit(temperatureF: Double, windMPH: Double) -> Double {
        if usesFormula(temperatureF: temperatureF, windMPH: windMPH) {
            let velocityFactor = pow(windMPH, 0.16)
            return 35.74 + 0.6215 * temperatureF - 35.75 * velocityFactor + 0.4275 * temperatureF * velocityFactor
        }
        return temperatureF
    }

    static func usesFormula(temperature: Double, windSpeed: Double, units: PreferredUnits) -> Bool {
        let temperatureF = UnitBridge.temperature(temperature, from: units, to: .imperial)
        let windMPH = UnitBridge.wind(windSpeed, from: units, to: .imperial)
        return usesFormula(temperatureF: temperatureF, windMPH: windMPH)
    }

    static func usesFormula(temperatureF: Double, windMPH: Double) -> Bool {
        temperatureF <= 50.0 && windMPH >= 3.0
    }

    static func formulaHint(units: PreferredUnits) -> String {
        switch units {
        case .metric:
            return "NWS wind chill applies at 10°C or colder and winds of 5 km/h or more. This gauge is showing air temperature."
        case .imperial:
            return "NWS wind chill applies at 50°F or colder and winds of 3 mph or more. This gauge is showing air temperature."
        }
    }

    static func isExtreme(chill: Double, units: PreferredUnits) -> Bool {
        switch units {
        case .metric:
            return chill < -27.0
        case .imperial:
            return chill < -15.0
        }
    }

    static func formatted(_ value: Double, decimals: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        formatter.numberStyle = .decimal
        if let text = formatter.string(from: NSNumber(value: value)) {
            return text
        }
        return String(format: "%.\(decimals)f", value)
    }
}
