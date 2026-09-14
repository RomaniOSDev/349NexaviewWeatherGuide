import Foundation

enum FrostbiteRisk: Equatable {
    case unlikely
    case minutes(Int)

    static func from(chill: Double, units: PreferredUnits) -> FrostbiteRisk {
        let chillF = UnitBridge.temperature(chill, from: units, to: .imperial)
        if chillF <= -48 {
            return .minutes(2)
        }
        if chillF <= -35 {
            return .minutes(5)
        }
        if chillF <= -18 {
            return .minutes(10)
        }
        if chillF <= 0 {
            return .minutes(30)
        }
        return .unlikely
    }

    var headline: String {
        switch self {
        case .unlikely:
            return "Unlikely"
        case .minutes(let minutes):
            return "~\(minutes) min"
        }
    }

    var detail: String {
        switch self {
        case .unlikely:
            return "Exposed skin is outside the usual NWS frostbite bands at this chill."
        case .minutes(let minutes):
            return "NWS band: exposed skin can freeze in about \(minutes) minutes. Cover face, ears, and fingers."
        }
    }
}
