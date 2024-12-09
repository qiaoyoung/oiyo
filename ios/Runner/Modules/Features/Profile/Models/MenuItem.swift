import Foundation

struct MenuItem {
    enum ItemType {
        case arrow
        case subscription
        case coins
    }
    
    let icon: String
    let title: String
    let subtitle: String?
    let type: ItemType
    let showArrow: Bool
    let action: () -> Void
    
    init(icon: String, 
         title: String, 
         subtitle: String? = nil, 
         type: ItemType = .arrow,
         showArrow: Bool = true, 
         action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.showArrow = showArrow
        self.action = action
    }
} 