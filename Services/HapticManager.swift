import UIKit

@MainActor
class HapticManager {
    static let shared = HapticManager()
    
    // Impact styles: .light, .medium, .heavy, .soft, .rigid
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let successNotification = UINotificationFeedbackGenerator()
    
    func triggerLightImpact() {
        lightImpact.impactOccurred()
    }
    
    func triggerSuccessHaptic() {
        successNotification.notificationOccurred(.success)
    }
}
