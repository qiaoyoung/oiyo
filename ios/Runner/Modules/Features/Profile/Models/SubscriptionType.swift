import Foundation

enum SubscriptionType {
    case weekly
    case monthly
    
    var title: String {
        switch self {
        case .weekly:
            return "Weekly VIP"
        case .monthly:
            return "Monthly VIP"
        }
    }
    
    var price: String {
        switch self {
        case .weekly:
            return "12 OhlaVIPs/Week"
        case .monthly:
            return "49 OhlaVIPs/Month"
        }
    }
    
    var productId: String {
        switch self {
        case .weekly:
            return "com.oiyo.subscription.weekly"
        case .monthly:
            return "com.oiyo.subscription.monthly"
        }
    }
} 