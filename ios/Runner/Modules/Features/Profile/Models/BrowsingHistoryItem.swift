import Foundation

struct BrowsingHistoryItem: Codable {
    let ai: AIUserModel
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case ai
        case timestamp
    }
} 