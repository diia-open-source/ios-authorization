import Foundation
import ReactiveKit
import DiiaNetwork
import DiiaCommonTypes

public protocol AuthorizationApiClientProtocol {
    func getAuthUrl(target: AuthTarget) -> Signal<AuthUrlResponse, NetworkError>

    func verificationAuthMethods(flow: VerificationFlowProtocol, processId: String?) -> Signal<VerificationAuthMethodsResponse, NetworkError>
    func getAuthUrlv3(target: AuthTarget, processId: String?, trueDepthCameraAvailable: Bool) -> Signal<TemplatedResponse<AuthUrlResponse>, NetworkError>
    func verify(target: AuthTarget, requestId: String, processId: String, bankCode: String?) -> Signal<AlertTemplateResponse, NetworkError>
    func getToken(processId: String) -> Signal<GetTokenResponse, NetworkError>

    func refresh() -> Signal<RefreshTokenResponse, NetworkError>
    func getTemporaryToken() -> Signal<GetTokenResponse, NetworkError>
    func prolong(processId: String) -> Signal<RefreshTokenResponse, NetworkError>
    func logout(token: String, mobileID: String) -> Signal<SuccessResponse, NetworkError>

    func getAuthMethods() -> Signal<AuthMethodsResponse, NetworkError>
}

public class AuthorizationApiClient: ApiClient<AuthorizationAPI>, AuthorizationApiClientProtocol {

    private let token: () -> String

    public init(context: AuthorizationNetworkContext, token: @escaping () -> String) {
        self.token = token

        super.init()

        sessionManager = context.session
        AuthorizationAPI.host = context.host
        AuthorizationAPI.headers = context.headers
    }
    
    public func getAuthUrl(target: AuthTarget) -> Signal<AuthUrlResponse, NetworkError> {
        return request(.getAuthUrl(target: target, token: token()))
    }
    
    public func getAuthUrlv3(target: AuthTarget, processId: String?, trueDepthCameraAvailable: Bool) -> Signal<TemplatedResponse<AuthUrlResponse>, NetworkError> {
        return request(.getAuthUrlv3(target: target, processId: processId, trueDepthAvailable: trueDepthCameraAvailable, token: token()))
    }
    
    public func getToken(processId: String) -> Signal<GetTokenResponse, NetworkError> {
        return request(.getToken(processId: processId))
    }
    
    public func refresh() -> Signal<RefreshTokenResponse, NetworkError> {
        return request(.refreshToken(token: token()))
    }
    
    public func getTemporaryToken() -> Signal<GetTokenResponse, NetworkError> {
        return request(.getTemporaryToken)
    }
    
    public func prolong(processId: String) -> Signal<RefreshTokenResponse, NetworkError> {
        return request(.prolong(processId: processId, token: token()))
    }
    
    public func logout(token: String, mobileID: String) -> Signal<SuccessResponse, NetworkError> {
        return request(.logout(token: token, mobileID: mobileID))
    }
    
    public func getAuthMethods() -> Signal<AuthMethodsResponse, NetworkError> {
        return request(.authMethods(token: token()))
    }
    
    public func verificationAuthMethods(flow: VerificationFlowProtocol, processId: String?) -> Signal<VerificationAuthMethodsResponse, NetworkError> {
        return request(.verificationAuthMethods(flow: flow, processId: processId, token: token()))
    }
    
    public func verify(target: AuthTarget, requestId: String, processId: String, bankCode: String?) -> Signal<AlertTemplateResponse, NetworkError> {
        return request(.verify(target: target, requestId: requestId, processId: processId, bankCode: bankCode, token: token()))
    }
}
