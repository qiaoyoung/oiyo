import Foundation

struct HelpItem {
    let title: String
    let detail: String?
    let action: () -> Void
} 