import UIKit

enum KeyboardDismiss {
    static func hide() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

final class KeyboardDismissTapController: NSObject, UIGestureRecognizerDelegate {
    static let shared = KeyboardDismissTapController()

    private weak var installedWindow: UIWindow?

    func install(on window: UIWindow) {
        if installedWindow === window { return }
        installedWindow = window
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        window.addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        KeyboardDismiss.hide()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var view = touch.view
        while let current = view {
            if current is UITextField || current is UITextView {
                return false
            }
            view = current.superview
        }
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
