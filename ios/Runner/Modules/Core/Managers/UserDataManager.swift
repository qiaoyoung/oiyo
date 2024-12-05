import Foundation

// 导入 UserModel



class UserDataManager {
    static let shared = UserDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let currentUserKey = "CurrentUser"
    private let isLoggedInKey = "IsUserLoggedIn"
    private let userDefaultsKey = "UserMoods"

    var isUserLoggedIn: Bool {
        get {
            return userDefaults.bool(forKey: isLoggedInKey)
        }
        set {
            userDefaults.set(newValue, forKey: isLoggedInKey)
        }
    }
    
    var currentUser: UserModel? {
        get {
            guard let data = userDefaults.data(forKey: currentUserKey),
                  let user = try? JSONDecoder().decode(UserModel.self, from: data) else {
                // Create default user if none exists
                let defaultNickname = "User\(String(format: "%04d", Int.random(in: 1000...9999)))"
                let defaultUser = UserModel(
                    id: UUID().uuidString,
                    nickname: defaultNickname,
                    avatarData: nil
                )
                saveUser(defaultUser)
                return defaultUser
            }
            return user
        }
        set {
            if let user = newValue,
               let data = try? JSONEncoder().encode(user) {
                userDefaults.set(data, forKey: currentUserKey)
                isUserLoggedIn = true
            } else {
                userDefaults.removeObject(forKey: currentUserKey)
                isUserLoggedIn = false
            }
        }
    }
    
    private init() {}
    
    
    func saveUser(_ user: UserModel) {
        if let data = try? JSONEncoder().encode(user) {
            userDefaults.set(data, forKey: currentUserKey)
            isUserLoggedIn = true
        }
    }
    
    func updateUserNickname(_ nickname: String) {
        if var user = currentUser {
            user.nickname = nickname
            saveUser(user)
        }
    }
    
    func updateUserAvatar(_ avatarData: Data) {
        if var user = currentUser {
            user.avatarData = avatarData
            saveUser(user)
        }
    }
    
    func logout() {
        userDefaults.removeObject(forKey: currentUserKey)
        isUserLoggedIn = false
    }
    
    // 获取用户的所有心情
    func getUserMoods() -> [MoodPostModel] {

        guard let data = userDefaults.data(forKey: userDefaultsKey),
              let moods = try? JSONDecoder().decode([MoodPostModel].self, from: data) else {
            return []
        }
        return moods.sorted { $0.timestamp > $1.timestamp }
    }
    
    func saveUserMoods(moodItems :[MoodPostModel]) {

        if let data = try? JSONEncoder().encode(moodItems) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    
    // 删除心情
    func deleteMood(_ mood: MoodPostModel) {
        var moods = getUserMoods()
        moods.removeAll { $0.id == mood.id }
        
        if let data = try? JSONEncoder().encode(moods) {
            userDefaults.set(data, forKey: userDefaultsKey)
        }
    }
    
    // 清除所有心情
    func clearAllMoods() {
        userDefaults.removeObject(forKey: userDefaultsKey)
    }
} 
