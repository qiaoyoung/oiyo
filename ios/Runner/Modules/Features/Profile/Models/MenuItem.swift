import Foundation

enum MenuItemType {
    case normal
    case arrow
    case toggle
}

struct MenuItem {
    let icon: String
    let title: String
    let subtitle: String?
    let type: MenuItemType
    let showArrow: Bool
    let action: () -> Void
} 