import Foundation

struct ChillComparison {
    let first: WindChillEntry
    let second: WindChillEntry
    let displayUnits: PreferredUnits
    var activity: TrailActivity = .hiking

    var temperatureDelta: Double {
        first.temperature(in: displayUnits) - second.temperature(in: displayUnits)
    }

    var windDelta: Double {
        first.windSpeed(in: displayUnits) - second.windSpeed(in: displayUnits)
    }

    var chillDelta: Double {
        first.chill(in: displayUnits) - second.chill(in: displayUnits)
    }

    var colder: WindChillEntry {
        if first.chill(in: .metric) <= second.chill(in: .metric) {
            return first
        }
        return second
    }

    var firstAdvice: String {
        ClothingAdvice.line(chill: first.chill, units: first.units, activity: activity)
    }

    var secondAdvice: String {
        ClothingAdvice.line(chill: second.chill, units: second.units, activity: activity)
    }

    var colderAdvice: String {
        ClothingAdvice.line(chill: colder.chill, units: colder.units, activity: activity)
    }
}
