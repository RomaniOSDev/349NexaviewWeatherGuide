import Foundation

enum ClothingAdvice {
    static func line(chill: Double, units: PreferredUnits, activity: TrailActivity = .hiking) -> String {
        let chillC = UnitBridge.temperature(chill, from: units, to: .metric)
        return "\(base(chillC: chillC)) \(coda(chillC: chillC, activity: activity))"
    }

    private static func base(chillC: Double) -> String {
        if chillC < -27.0 {
            return "Frostbite range. Cover every patch of skin and keep outdoor time short."
        }
        if chillC < -18.0 {
            return "Parka, insulated boots, face mask, and mitts. Windproof the whole stack."
        }
        if chillC < -10.0 {
            return "Insulated coat, warm hat, gloves, and a sealed shell over the core."
        }
        if chillC < 0.0 {
            return "Fleece layers, a wind jacket, and light gloves for the exposed trail."
        }
        if chillC < 10.0 {
            return "Long sleeves and a light insulated jacket are enough for this chill."
        }
        return "Breathable layers match this reading. Keep a shell handy if gusts rise."
    }

    private static func coda(chillC: Double, activity: TrailActivity) -> String {
        switch activity {
        case .hiking:
            if chillC < -10.0 {
                return "On the move, vent the core on climbs so sweat does not freeze."
            }
            return "Keep a pace that warms you without soaking the inner layer."
        case .skiing:
            if chillC < -10.0 {
                return "Ski shell, goggles, and a covered face; the descent wind is harsher than the dial."
            }
            return "Windproof the front of the body for the descent, even if the climb feels mild."
        case .standing:
            if chillC < 0.0 {
                return "You are not generating trail heat. Add a static layer and rotate indoors sooner."
            }
            return "Standing cools you faster than walking. Keep an extra layer within reach."
        }
    }
}
