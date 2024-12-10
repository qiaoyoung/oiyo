import Foundation

struct MoodPostModel: Codable {
    let id: String
    let userId: String
    let userAvatar: String
    let userName: String
    let content: String
    let mood: MoodType
    let timestamp: Date
    let isMine: Bool

    
    enum MoodType: String, Codable {
        case happy = "happy"
        case sad = "sad"
        case angry = "angry"
        case excited = "excited"
        case peaceful = "peaceful"
        case anxious = "anxious"
    }
    
    // 格式化时间
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: timestamp)
    }
}


