import Foundation

enum ClothingAdvice {
    static func line(chill: Double, units: PreferredUnits, activity: TrailActivity = .hiking) -> String {
        let chillC = UnitBridge.temperature(chill, from: units, to: .metric)
        return "\(base(chillC: chillC)) \(coda(chillC: chillC, activity: activity))"
    }

    static func kitItems(chill: Double, units: PreferredUnits, activity: TrailActivity) -> [String] {
        let chillC = UnitBridge.temperature(chill, from: units, to: .metric)
        var items: [String] = []
        if chillC < -27 {
            items = ["Full face cover", "Insulated parka", "Mitts + liner", "Windproof boots", "Short outdoor windows"]
        } else if chillC < -18 {
            items = ["Parka", "Insulated boots", "Face mask", "Mitts", "Windproof shell"]
        } else if chillC < -10 {
            items = ["Insulated coat", "Warm hat", "Gloves", "Core shell", "Neck gaiter"]
        } else if chillC < 0 {
            items = ["Fleece mid-layer", "Wind jacket", "Light gloves", "Beanie", "Dry base layer"]
        } else if chillC < 10 {
            items = ["Long sleeves", "Light insulated jacket", "Optional gloves", "Packable shell"]
        } else {
            items = ["Breathable layers", "Packable shell", "Sun / wind cap"]
        }
        switch activity {
        case .hiking:
            items.append(chillC < -10 ? "Vent zipper on climbs" : "Pace without soaking")
        case .skiing:
            items.append(chillC < -10 ? "Goggles + covered face" : "Windproof front for descent")
        case .working:
            items.append(chillC < 0 ? "Static warm layer nearby" : "Rotate indoors on schedule")
        }
        return items
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
            return "Fleece layers, a wind jacket, and light gloves for open ground."
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
        case .working:
            if chillC < 0.0 {
                return "Low movement cools you faster. Add a static layer and rotate indoors sooner."
            }
            return "Outdoor work cools faster than hiking. Keep an extra layer within reach."
        }
    }
}
