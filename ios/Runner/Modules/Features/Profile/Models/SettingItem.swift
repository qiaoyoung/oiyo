import Foundation

struct SettingItem {
    let icon: String
    let title: String
    let detail: String?
    let type: ItemType
    let action: () -> Void
    
    enum ItemType {
        case normal
        case toggle
        case arrow
    }
} 