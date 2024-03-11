import Foundation
import ReactiveKit
import DiiaNetwork
import DiiaCommonTypes
@testable import DiiaAuthorization

class AuthorizationApiClientStub: AuthorizationApiClientProtocol {
    func getAuthUrl(target: AuthTarget) -> Signal<AuthUrlResponse, NetworkError> {
        return .failed(.noData)
    }
    
    func verificationAuthMethods(flow: VerificationFlowProtocol, processId: String?) -> Signal<VerificationAuthMethodsResponse, NetworkError> {
        switch flow.flowCode {
        case "skipAuthMethods":
            return .init(just: .init(title: "",
                                     processId: "id",
                                     authMethods: nil,
                                     button: nil,
                                     skipAuthMethods: true,
                                     template: nil))
        case "bankId":
            return .init(just: .init(title: "BankId Auth",
                                     processId: "id",
                                     authMethods: [.bankid],
                                     button: nil,
                                     skipAuthMethods: false,
                                     template: .init(type: .middleCenterAlignAlert,
                                                     isClosable: true,
                                                     data: .init(icon: nil,
                                                                 title: "action",
                                                                 description: nil,
                                                                 mainButton: .init(title: nil,
                                                                                   icon: nil,
                                                                                   action: .authMethods),
                                                                 alternativeButton: nil))))
        case "bankId_logout":
            return .init(just: .init(title: "BankId Logout",
                                     processId: "id",
                                     authMethods: [.bankid],
                                     button: nil,
                                     skipAuthMethods: false,
                                     template: nil))
        default:
            return .failed(.noData)
        }
    }
    
    func getAuthUrlv3(target: AuthTarget, processId: String?, trueDepthCameraAvailable: Bool) -> Signal<TemplatedResponse<AuthUrlResponse>, NetworkError> {
        return .failed(.noData)
    }
    
    func verify(target: AuthTarget, requestId: String, processId: String, bankCode: String?) -> Signal<AlertTemplateResponse, NetworkError> {
        return .init(just: .init(template: .init(type: .middleCenterAlignAlert,
                                                 isClosable: true,
                                                 data: .init(icon: nil,
                                                             title: "Success",
                                                             description: nil,
                                                             mainButton: .init(title: "Ok",
                                                                               icon: nil,
                                                                               action: .ok), alternativeButton: nil)),
                                 processCode: 200))
    }
    
    func getToken(processId: String) -> Signal<GetTokenResponse, NetworkError> {
        return .init(just: .init(token: "token"))
    }
    
    func refresh() -> Signal<RefreshTokenResponse, NetworkError> {
        return .init(just: .init(token: "token",
                                 template: .init(type: .middleCenterAlignAlert,
                                                 isClosable: true,
                                                 data: .init(icon: nil,
                                                             title: "Refresh",
                                                             description: nil,
                                                             mainButton: .init(title: "Ok",
                                                                               icon: nil,
                                                                               action: .ok), alternativeButton: nil))))
    }
    
    func getTemporaryToken() -> Signal<GetTokenResponse, NetworkError> {
        return .failed(.noData)
    }
    
    func prolong(processId: String) -> Signal<RefreshTokenResponse, NetworkError> {
        return .init(just: .init(token: "token",
                                 template: .init(type: .middleCenterAlignAlert,
                                                 isClosable: true,
                                                 data: .init(icon: nil,
                                                             title: "Prolong",
                                                             description: nil,
                                                             mainButton: .init(title: "Ok",
                                                                               icon: nil,
                                                                               action: .ok), alternativeButton: nil))))
    }
    
    func getAuthMethods() -> Signal<AuthMethodsResponse, NetworkError> {
        return .failed(.noData)
    }
    
    func logout(token: String, mobileID: String) -> Signal<SuccessResponse, NetworkError> {
        return .init(just: .init(success: true))
    }
}
