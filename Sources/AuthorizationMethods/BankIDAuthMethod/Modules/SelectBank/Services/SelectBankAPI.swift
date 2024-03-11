import Foundation
import DiiaNetwork

enum SelectBankAPI: CommonService {

    static var host: String = ""
    static var headers: [String: String]?
    
    case getBanks
    case getAuthUrl(target: String, processId: String, token: String)
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getBanks:
            return "v1/auth/banks"
        case .getAuthUrl:
            return "v3/auth/bankid/auth-url"
        }
    }
    
    var host: String {
        return SelectBankAPI.host
    }

    var timeoutInterval: TimeInterval {
        return 30
    }
    
    var headers: [String: String]? {
        
        var headersCandidate = SelectBankAPI.headers
        switch self {
        case .getAuthUrl( _, _, let token):
            headersCandidate?["authorization"] = "bearer \(token)"
        default:
            break
        }
        
        return headersCandidate
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getAuthUrl(let target, let processId, _):
            return [
                "bankId": target,
                "processId": processId
            ]
        default:
            return nil
        }
    }
    
    var analyticsName: String {
        switch self {
        case .getBanks:
            return NetworkActionKey.getBanksList.rawValue
        case .getAuthUrl:
            return NetworkActionKey.getBankIdAuthUrl.rawValue
        }
    }
    
    var analyticsAdditionalParameters: String? {
        switch self {
        case .getAuthUrl(let target, _, _):
            return "BANK_ID: \(target)"
        default:
            return nil
        }
    }
    
}

private enum NetworkActionKey: String {
    // SelectBankAPI
    case getBanksList
    case getBankIdAuthUrl
}
