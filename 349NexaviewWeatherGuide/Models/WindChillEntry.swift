import Foundation

struct WindChillEntry: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var date: Date
    var temperature: Double
    var windSpeed: Double
    var chill: Double
    var locationNote: String
    var units: PreferredUnits

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        temperature: Double,
        windSpeed: Double,
        chill: Double,
        locationNote: String,
        units: PreferredUnits
    ) {
        self.id = id
        self.date = date
        self.temperature = temperature
        self.windSpeed = windSpeed
        self.chill = chill
        self.locationNote = locationNote
        self.units = units
    }

    func temperature(in target: PreferredUnits) -> Double {
        UnitBridge.temperature(temperature, from: units, to: target)
    }

    func windSpeed(in target: PreferredUnits) -> Double {
        UnitBridge.wind(windSpeed, from: units, to: target)
    }

    func chill(in target: PreferredUnits) -> Double {
        UnitBridge.temperature(chill, from: units, to: target)
    }

    var isExtreme: Bool {
        WindChillMath.isExtreme(chill: chill, units: units)
    }
}
