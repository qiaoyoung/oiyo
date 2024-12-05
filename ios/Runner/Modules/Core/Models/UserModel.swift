import Foundation

struct UserModel: Codable {
    let id: String
    var nickname: String
    var avatarData: Data?
    
    init(id: String, nickname: String, avatarData: Data? = nil) {
        self.id = id
        self.nickname = nickname
        self.avatarData = avatarData
    }
} 
