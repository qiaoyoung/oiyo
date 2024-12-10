import Foundation

extension Notification.Name {
    static let chatUpdated = Notification.Name("chatUpdated")
}

struct ChatItem: Codable {
    let ai: AIUserModel
    let lastMessage: String
    let timestamp: Date
    let isSender: Bool
    var isPinned: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case ai
        case lastMessage
        case timestamp
        case isSender
        case isPinned
    }
} 