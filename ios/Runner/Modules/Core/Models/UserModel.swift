import Foundation

struct UserModel: Codable {
    var id: String
    var nickname: String
    var avatarData: Data?
    var coins: Int
    var vipExpiryDate: Date?
    
    init(id: String, nickname: String, avatarData: Data? = nil, coins: Int = Int.random(in: 1000...9999), vipExpiryDate: Date? = nil) {
        self.id = id
        self.nickname = nickname
        self.avatarData = avatarData
        self.coins = coins
        self.vipExpiryDate = vipExpiryDate
    }
    
    var isVipActive: Bool {
        guard let expiryDate = vipExpiryDate else { return false }
        return expiryDate > Date()
    }
} 
