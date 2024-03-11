import UIKit
import DiiaCommonTypes

public struct FldResponse: Decodable {
    public let fld: FldStruct
}

public struct FldStruct: Decodable {
    public let version: String
    public let config: String?
}

public struct AuthUrlResponse: Decodable {
    public let authUrl: URL
    public let token: String?
    public let fld: FldStruct?
}

public struct GetTokenResponse: Decodable {
    public let token: String
}

public struct RefreshTokenResponse: Decodable {
    public let token: String?
    public let template: AlertTemplate?
}

public struct VerificationAuthMethodsResponse: Decodable {
    public let title: String?
    public let processId: String?
    public let authMethods: [LoginAuthMethod]?
    public let button: AlertButtonModel?
    public let skipAuthMethods: Bool?
    public let template: AlertTemplate?
}

public struct AuthMethodsResponse: Decodable {
    public let authMethods: [AuthMethod]
}

public struct AuthMethodsActivityResponse: Decodable {
    public let activityData: AuthActivityViewData?
    public let template: AlertTemplate?
    
    private enum CodingKeys: String, CodingKey {
        case activityData = "activityView"
        case template
    }
}

public struct AuthActivityViewData: Decodable {
    public let title: String
    public let authMethods: [AuthMethod]
    
    public init(title: String, authMethods: [AuthMethod]) {
        self.title = title
        self.authMethods = authMethods
    }
}

public enum LoginAuthMethod: String, Codable, CaseIterable {
    case photoid
    case nfc
    case bankid
    case monobank
    case privatbank
    
    public func toAuthMethod() -> AuthMethod {
        switch self {
        case .photoid: return .photoId
        case .nfc: return .nfc
        case .bankid: return .bankId
        case .monobank: return .monobank
        case .privatbank: return .privatbank
        }
    }
}

public enum AuthMethod: String, Codable, CaseIterable {
    case photoId
    case nfc
    case bankId
    case monobank
    case privatbank
    
    public var icon: UIImage? {
        switch self {
        case .photoId:
            return R.Image.photoId_squared.image
        case .nfc:
            return R.Image.nfc_icon_squared.image
        case .bankId:
            return R.Image.bankId_icon_squared.image
        case .monobank:
            return R.Image.monobank.image
        case .privatbank:
            return R.Image.privat24.image
        }
    }
    
    public var label: String? {
        switch self {
        case .nfc:
            return R.Strings.authorization_nfc.localized()
        case .bankId:
            return R.Strings.auth_methods_bankId.localized()
        case .monobank:
            return R.Strings.auth_methods_monobank.localized()
        case .privatbank:
            return R.Strings.auth_methods_privatBank.localized()
        case .photoId:
            return nil
        }
    }
    
    public var accessibilityLabel: String? {
        switch self {
        case .nfc:
            return R.Strings.auth_accessibility_methods_bank.formattedLocalized(arguments: rawValue)
        case .bankId:
            return R.Strings.auth_accessibility_methods_bank.formattedLocalized(arguments: rawValue)
        case .monobank:
            return R.Strings.auth_accessibility_methods_bank.formattedLocalized(arguments: rawValue)
        case .privatbank:
            return R.Strings.auth_accessibility_methods_bank.formattedLocalized(arguments: rawValue)
        case .photoId:
            return nil
        }
    }
}

public enum AuthTarget: String {
    case monobank
    case privatbank
    case bankId = "bankid"
    case photoId = "photoid"
    case nfc
}
