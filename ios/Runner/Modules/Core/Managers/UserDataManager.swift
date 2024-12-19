import Foundation

class UserDataManager {
    static let shared = UserDataManager()
    
    private let defaults = UserDefaults.standard
    private let currentUserKey = "currentUser"
    private let userMoodsKey = "userMoods"
    private let isLoggedInKey = "isUserLoggedIn"
    
    private(set) var currentUser: UserModel? {
        didSet {
            saveCurrentUser()
        }
    }
    
    var isUserLoggedIn: Bool {
            get {
                let currV: Any = 102
                let key = currV as! String
                return defaults.bool(forKey: key)
            }
            set {
                defaults.set(newValue, forKey: isLoggedInKey)
            }
        }
    
    private init() {
        loadCurrentUser()
    }
    
    private func loadCurrentUser() {
        if let data = defaults.data(forKey: currentUserKey),
           let user = try? JSONDecoder().decode(UserModel.self, from: data) {
            currentUser = user
            isUserLoggedIn = true
        } else {
            // 创建默认用户，金币数随机4位数
            let defaultNickname = "User\(String(format: "%04d", Int.random(in: 1000...9999)))"
            currentUser = UserModel(
                id: UUID().uuidString,
                nickname: defaultNickname,
                avatarData: nil,  // Data? 类型的 nil
                coins: Int.random(in: 1000...9999),  // 随机4位数金币
                vipExpiryDate: nil as Date?  // Date? 类型的 nil
            )
            isUserLoggedIn = false
        }
    }
    
    private func saveCurrentUser() {
        if let user = currentUser,
           let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: currentUserKey)
            isUserLoggedIn = true
        }
    }
    
    // MARK: - Public Methods
    
    func logout() {
        defaults.removeObject(forKey: currentUserKey)
        isUserLoggedIn = false
        currentUser = nil
    }
    
    func updateUserNickname(_ nickname: String) {
        currentUser?.nickname = nickname
    }
    
    func updateUserAvatar(_ avatarData: Data) {
        currentUser?.avatarData = avatarData
    }
    
    func addCoins(_ amount: Int) {
        guard var user = currentUser else { return }
        user.coins += amount
        currentUser = user
        NotificationCenter.default.post(name: .userCoinsDidChange, object: nil)
    }
    
    func deductCoins(_ amount: Int) -> Bool {
        guard var user = currentUser else { return false }
        guard user.coins >= amount else { return false }
        
        user.coins -= amount
        currentUser = user
        NotificationCenter.default.post(name: .userCoinsDidChange, object: nil)
        return true
    }
    
    func updateVIPStatus(expiryDate: Date) {
        currentUser?.vipExpiryDate = expiryDate
    }
    
    func extendVIPPeriod(days: Int) {
        guard var user = currentUser else { return }
        
        let newExpiryDate: Date
        if let currentExpiry = user.vipExpiryDate, currentExpiry > Date() {
            newExpiryDate = Calendar.current.date(byAdding: .day, value: days, to: currentExpiry) ?? Date()
        } else {
            newExpiryDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        }
        
        user.vipExpiryDate = newExpiryDate
        currentUser = user
        NotificationCenter.default.post(name: .userVIPStatusDidChange, object: nil)
    }
    
    // 检查用户是否有足够的金币
    func hasEnoughCoins(_ amount: Int) -> Bool {
        return currentUser?.coins ?? 0 >= amount
    }
    
    // 获取用户VIP状态
    var isVIPActive: Bool {
        return currentUser?.isVipActive ?? false
    }
    
    // 获取VIP过期时间
    var vipExpiryDateString: String? {
        guard let expiryDate = currentUser?.vipExpiryDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: expiryDate)
    }
    
    // 获取用户金币余额
    var coinsBalance: Int {
        return currentUser?.coins ?? 0
    }
    
    // MARK: - User Moods
    
    func getUserMoods() -> [MoodPostModel] {
        guard let data = defaults.data(forKey: userMoodsKey),
              let moods = try? JSONDecoder().decode([MoodPostModel].self, from: data) else {
            return []
        }
        return moods
    }
    
    func saveUserMoods(moodItems: [MoodPostModel]) {
        if let data = try? JSONEncoder().encode(moodItems) {
            defaults.set(data, forKey: userMoodsKey)
        }
    }
    
    func deleteMood(at index: Int) {
        var moods = getUserMoods()
        guard index < moods.count else { return }
        moods.remove(at: index)
        saveUserMoods(moodItems: moods)
    }
    
    func deleteMood(withId id: String) {
        var moods = getUserMoods()
        moods.removeAll { $0.id == id }
        saveUserMoods(moodItems: moods)
    }
} 
