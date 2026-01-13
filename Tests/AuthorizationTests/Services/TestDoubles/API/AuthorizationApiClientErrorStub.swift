
import Foundation
import ReactiveKit
import DiiaNetwork
import DiiaCommonTypes
@testable import DiiaAuthorization

final class AuthorizationApiClientErrorStub: AuthorizationApiClientProtocol {
    func getAuthUrl(target: AuthTarget) -> Signal<AuthUrlResponse, NetworkError> {
        return .failed(.noData)
    }
    
    func verificationAuthMethods(flow: VerificationFlowProtocol, processId: String?) -> Signal<VerificationAuthMethodsResponse, NetworkError> {
        return .failed(.noData)
    }
    
    func getAuthUrlv3(target: AuthTarget, processId: String?, trueDepthCameraAvailable: Bool) -> Signal<TemplatedResponse<AuthUrlResponse>, NetworkError> {
        return .failed(.noData)
    }
    
    func verify(target: AuthTarget, requestId: String, processId: String, bankCode: String?) -> Signal<AlertTemplateResponse, NetworkError> {
        return .failed(.noData)
    }
    
    func getToken(processId: String) -> Signal<GetTokenResponse, NetworkError> {
        return .failed(.noData)
    }
    
    func refresh() -> Signal<RefreshTokenResponse, NetworkError> {
        return .failed(.wrongStatusCode("", AppConstants.HttpCode.unauthorized, .noData))
    }
    
    func getTemporaryToken() -> Signal<GetTokenResponse, NetworkError> {
        return .failed(.noData)
    }
    
    func prolong(processId: String) -> Signal<RefreshTokenResponse, NetworkError> {
        return .failed(.noData)
    }
    
    func getAuthMethods() -> Signal<AuthMethodsResponse, NetworkError> {
        return .failed(.noData)
    }
    
    func logout(token: String, mobileID: String) -> Signal<SuccessResponse, NetworkError> {
        return .failed(.noData)
    }
}
