import StoreKit
import UIKit

enum RatePrompt {
    static func present() {
        let scenes = UIApplication.shared.connectedScenes
        let active = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        if let active {
            SKStoreReviewController.requestReview(in: active)
            return
        }
        if let fallback = scenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: fallback)
        }
    }
}
