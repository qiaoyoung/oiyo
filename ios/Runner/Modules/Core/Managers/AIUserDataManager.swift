import Foundation

class AIUserDataManager {
    static let shared = AIUserDataManager()
    
    private(set) var aiUsers: [AIUserModel] = []
    private(set) var groupedAIUsers: [AIUserCategory] = [] // AI users grouped by type
    
    private init() {
        loadAIUsers()
    }
    
    private func loadAIUsers() {
        guard let url = Bundle.main.url(forResource: "ai_users", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let response = try? JSONDecoder().decode(AIUserResponse.self, from: data) else {
            print("Failed to load AI users")
            return
        }
        
        self.aiUsers = response.users
        
        // Group users by type
        let groupedUsers = Dictionary(grouping: aiUsers) { $0.aiType }
        
        self.groupedAIUsers = groupedUsers.map { type, users in
            let title = getDisplayTitle(for: type)
            return AIUserCategory(title: title, users: users)
        }.sorted { $0.title < $1.title }
    }
    
    private func getDisplayTitle(for type: String) -> String {
        switch type {
        case "creative": return "Creative"
        case "technical": return "Technical"
        case "life": return "Life"
        case "education": return "Education"
        case "business": return "Business"
        case "health": return "Health"
        default: return type.capitalized
        }
    }
}
