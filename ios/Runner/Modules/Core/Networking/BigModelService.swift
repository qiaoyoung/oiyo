import Foundation
import Moya

enum BigModelAPI {
    case chatCompletion(messages: [[String: String]])
}

extension BigModelAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://open.bigmodel.cn/api/paas/v4/chat/completions")!
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .chatCompletion(let messages):
            let parameters: [String: Any] = [
                "model": "glm-4-flash",
                "messages": messages
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer 2cd90c31371fb56ae334ede392b8a742.lZTzBm0p4tmUCnCV"
        ]
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
    var sampleData: Data {
        return Data()
    }
} 