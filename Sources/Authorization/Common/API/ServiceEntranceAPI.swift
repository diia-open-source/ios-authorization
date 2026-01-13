
import Foundation
import DiiaNetwork

enum ServiceEntranceAPI: CommonService {
    static var host: String = ""
    static var headers: [String: String]?
    
    case login(offerId: String)
    case logout(token: String, mobileUid: String)
    case refreshToken(token: String)

    var method: HTTPMethod {
        switch self {
        case .login:
            return .get
        case .logout, .refreshToken:
            return .post
        }
    }
    
    public var host: String {
        return ServiceEntranceAPI.host
    }

    var path: String {
        switch self {
        case .login(let offerId):
            return "v1/auth/acquirer/branch/offer/\(offerId)/token"
        case .logout:
            return "v1/auth/acquirer/branch/offer/token/logout"
        case .refreshToken:
            return "v1/auth/acquirer/branch/offer/token/refresh"
        }
    }
    
    var parameters: [String: Any]? {
        return nil
    }
    
    var headers: [String: String]? {
        switch self {
        case .login:
            return ServiceEntranceAPI.headers
        case .logout(let token, let mobileUid):
            var headers = ServiceEntranceAPI.headers
            headers?["mobile_uid"] = mobileUid
            headers?["authorization"] = "bearer \(token)"
            return headers
        case .refreshToken(let token):
            var headers = ServiceEntranceAPI.headers
            headers?["authorization"] = "bearer \(token)"
            return headers
        }
    }
    
    public var timeoutInterval: TimeInterval {
        return 30
    }

    var analyticsName: String {
        switch self {
        case .refreshToken:
            return NetworkActionKey.serviceRefreshToken.rawValue
        case .login:
            return NetworkActionKey.serviceLogin.rawValue
        case .logout:
            return NetworkActionKey.serviceLogout.rawValue
        }
    }

    var analyticsAdditionalParameters: String? { nil }
}

private enum NetworkActionKey: String {
    case serviceRefreshToken
    case serviceLogin
    case serviceLogout
}
