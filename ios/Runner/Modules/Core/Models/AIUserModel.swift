import Foundation

struct AIUserModel: Codable {
    let id: String
    let nickname: String
    let avatar: String
    let gender: String
    let aiType: String
    let desStr: String
    let rating: Double
    let personality: String
    let specialties: [String]
    let languages: [String]
    let signature: String
    let totalChats: Int
    let features: [String]
    let sampleDialogs: [SampleDialog]
    let moodPhrase: String
    
    struct SampleDialog: Codable {
        let question: String
        let answer: String
    }
}

struct AIUserResponse: Codable {
    let users: [AIUserModel]
}

struct AIUserCategory {
    let title: String
    var users: [AIUserModel]
}
