import Foundation
import UserNotifications

enum ChillNotificationCenter {
    static let chillThresholdId = "chill.threshold.alert"
    static let exposureLimitId = "chill.exposure.limit"

    static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        @unknown default:
            return false
        }
    }

    static func cancelChillThreshold() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [chillThresholdId])
    }

    static func cancelExposureLimit() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [exposureLimitId])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [exposureLimitId])
    }

    static func scheduleChillThreshold(chill: Double, threshold: Double, units: PreferredUnits) async {
        cancelChillThreshold()
        guard chill <= threshold else { return }
        guard await requestAuthorizationIfNeeded() else { return }
        let content = UNMutableNotificationContent()
        content.title = "Chill threshold reached"
        content.body = "Wind chill is \(WindChillMath.formatted(chill)) \(units.temperatureSymbol), at or below your alert of \(WindChillMath.formatted(threshold)) \(units.temperatureSymbol)."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: chillThresholdId, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    static func scheduleExposureLimit(minutes: Int, activity: TrailActivity) async {
        cancelExposureLimit()
        guard minutes > 0 else { return }
        guard await requestAuthorizationIfNeeded() else { return }
        let content = UNMutableNotificationContent()
        content.title = "Exposure limit reached"
        content.body = "Your \(minutes)-minute outdoor window for \(activity.title.lowercased()) is up. Move to shelter or reset the timer."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * 60), repeats: false)
        let request = UNNotificationRequest(identifier: exposureLimitId, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }
}
