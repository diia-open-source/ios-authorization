import Foundation
import DiiaNetwork

public enum AuthorizationAPI: CommonService {
    static var host: String = ""
    static var headers: [String: String]?

    case getAuthUrl(target: AuthTarget, token: String)
    case getAuthUrlv3(target: AuthTarget, processId: String?, trueDepthAvailable: Bool, token: String)
    case getToken(processId: String)
    case refreshToken(token: String)
    case getTemporaryToken
    case prolong(processId: String, token: String)
    case logout(token: String, mobileID: String)
    case authMethods(token: String)
    case verify(target: AuthTarget, requestId: String, processId: String, bankCode: String?, token: String)
    case verificationAuthMethods(flow: VerificationFlowProtocol, processId: String?, token: String)

    public var method: HTTPMethod {
        switch self {
        case .refreshToken, .logout:
            return .post
        case .getToken, .getAuthUrl, .getAuthUrlv3, .authMethods, .getTemporaryToken, .verificationAuthMethods, .verify, .prolong:
            return .get
        }
    }

    public var path: String {
        switch self {
        case .getAuthUrl(let target, _):
            return "v2/auth/\(target.rawValue)/auth-url"
        case .getAuthUrlv3(let target, _, _, _):
            return "v3/auth/\(target.rawValue)/auth-url"
        case .getToken:
            return "v3/auth/token"
        case .refreshToken:
            return "v2/auth/token/refresh"
        case .getTemporaryToken:
            return "v1/auth/temporary/token"
        case .prolong:
            return "v1/auth/prolong/"
        case .logout:
            return "v2/auth/token/logout"
        case .authMethods:
            return "v1/auth/methods"
        case .verify(let target, let requestId, _, _, _):
            return "v1/auth/\(target.rawValue)/\(requestId)/verify"
        case .verificationAuthMethods(let activityType, _, _):
            return "v3/auth/\(activityType.flowCode)/methods"
        }
    }

    public var parameters: [String: Any]? {
        switch self {
        case .getToken(let processId):
            return ["processId": processId]
        case  .verificationAuthMethods(_, let processId, _):
            return ["processId": processId ?? ""]
        case .getAuthUrlv3(_, let processId, let trueDepthAvailable, _):
            return ["processId": processId ?? "",
                    "builtInTrueDepthCamera": trueDepthAvailable]
        case .prolong(let processId, _):
            return ["processId": processId]
        case .verify(_, _, let processId, let bankCode, _):
            if let bankCode = bankCode {
                return [
                    "bankId": bankCode,
                    "processId": processId
                ]
            } else {
                return ["processId": processId]
            }
        default:
            return nil
        }
    }
    
    public var host: String {
        return AuthorizationAPI.host
    }
    
    public var timeoutInterval: TimeInterval {
        return 30
    }
    
    public var headers: [String: String]? {
        var headersCandidate = AuthorizationAPI.headers
        switch self {
        case .refreshToken(let token),
                .authMethods(let token),
                .prolong(_, let token),
                .getAuthUrl(_, let token),
                .getAuthUrlv3(_, _, _, let token),
                .verify(_, _, _, _, let token):
            headersCandidate?["authorization"] = "bearer \(token)"
            return headersCandidate
        case .logout(let token, let mobileUID):
            headersCandidate?["authorization"] = "bearer \(token)"
            headersCandidate?["mobile_uid"] = mobileUID
            return headersCandidate
        case .verificationAuthMethods(let activityType, _, let token):
            if activityType.isAuthorization { break }
            headersCandidate?["authorization"] = "bearer \(token)"
            return headersCandidate
        default:
            break
        }
        return headersCandidate
    }
    
    public var analyticsName: String {
        switch self {
        case .getAuthUrl(let target, _), .getAuthUrlv3(let target, _, _, _):
            switch target {
            case .bankId:
                return NetworkActionKey.getBankIdAuthUrl.rawValue
            case .monobank:
                return NetworkActionKey.monobankAuthUrl.rawValue
            case .privatbank:
                return NetworkActionKey.privatbankAuthUrl.rawValue
            case .photoId:
                return NetworkActionKey.photoIdAuthUrl.rawValue
            case .nfc:
                return NetworkActionKey.nfcAuthUrl.rawValue
            }
        case .getToken:
            return NetworkActionKey.getToken.rawValue
        case .refreshToken:
            return NetworkActionKey.refreshToken.rawValue
        case .getTemporaryToken:
            return NetworkActionKey.getTemporaryToken.rawValue
        case .prolong:
            return NetworkActionKey.prolongToken.rawValue
        case .logout:
            return NetworkActionKey.logout.rawValue
        case .authMethods:
            return NetworkActionKey.authMethods.rawValue
        case .verify:
            return NetworkActionKey.verify.rawValue
        case .verificationAuthMethods:
            return NetworkActionKey.verificationAuthMethods.rawValue
        }
    }
    
    public var analyticsAdditionalParameters: String? { return nil }
}

private enum NetworkActionKey: String {
    case getBankIdAuthUrl
    case monobankAuthUrl
    case privatbankAuthUrl
    case photoIdAuthUrl
    case nfcAuthUrl
    case getToken
    case refreshToken
    case getTemporaryToken
    case prolongToken
    case logout
    case authMethods
    case verify
    case verificationAuthMethods
}
