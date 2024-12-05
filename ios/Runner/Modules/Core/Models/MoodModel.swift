import Foundation

struct MoodModel: Codable {
    let id: String
    let content: String
    let timestamp: Date
    let userId: String
    
    init(id: String = UUID().uuidString, content: String, timestamp: Date = Date(), userId: String) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.userId = userId
    }
    
    // 格式化时间
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: timestamp)
    }
    
    // 判断是否是今天发布的
    var isToday: Bool {
        return Calendar.current.isDateInToday(timestamp)
    }
    
    // 判断是否是本周发布的
    var isThisWeek: Bool {
        return Calendar.current.isDate(timestamp, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

// MARK: - 扩展用于分组展示
extension MoodModel {
    enum TimeGroup: String {
        case today = "今天"
        case thisWeek = "本周"
        case earlier = "更早"
    }
    
    var timeGroup: TimeGroup {
        if isToday {
            return .today
        } else if isThisWeek {
            return .thisWeek
        } else {
            return .earlier
        }
    }
}

// MARK: - 扩展用于排序和比较
extension MoodModel: Comparable {
    static func < (lhs: MoodModel, rhs: MoodModel) -> Bool {
        return lhs.timestamp > rhs.timestamp // 按时间倒序排列
    }
} 