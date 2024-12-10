import Foundation

struct VIPBenefitModel {
    let icon: String // SF Symbol name
    let title: String
    let description: String
    let availableIn: [APPSunManager.ProductID] // Supported subscription tiers
}

extension VIPBenefitModel {
    static func benefits(for productId: APPSunManager.ProductID) -> [VIPBenefitModel] {
        return allBenefits.filter { $0.availableIn.contains(productId) }
    }
    
    private static let allBenefits: [VIPBenefitModel] = [
        VIPBenefitModel(
            icon: "message.badge.filled.fill",
            title: "Unlimited AI Chat",
            description: "Chat with AI assistant anytime, anywhere",
            availableIn: [.vipWeekly, .vipMonthly]
        ),
        VIPBenefitModel(
            icon: "bolt.badge.clock.fill",
            title: "Priority Response",
            description: "Enjoy faster AI response times",
            availableIn: [.vipWeekly, .vipMonthly]
        ),
        VIPBenefitModel(
            icon: "star.fill",
            title: "Advanced Features",
            description: "Unlock all advanced AI features",
            availableIn: [.vipMonthly]
        ),
        VIPBenefitModel(
            icon: "gift.fill",
            title: "Exclusive Content",
            description: "Access VIP-only content and services",
            availableIn: [.vipMonthly]
        )
    ]
} 