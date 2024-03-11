import Foundation
import ReactiveKit
import DiiaNetwork
import DiiaCommonTypes

protocol ServiceEntranceApiClientProtocol {
    func login(offerId: String) -> Signal<GetTokenResponse, NetworkError>
    func logout(token: String, mobileUid: String) -> Signal<SuccessResponse, NetworkError>
    func refresh(token: String) -> Signal<GetTokenResponse, NetworkError>
}

class ServiceEntranceApiClient: ApiClient<ServiceEntranceAPI>, ServiceEntranceApiClientProtocol {

    init(context: AuthorizationNetworkContext) {
        super.init()
        sessionManager = NetworkConfiguration.default.sessionWithoutInterceptor
        ServiceEntranceAPI.host = context.host
        ServiceEntranceAPI.headers = context.headers
    }

    func login(offerId: String) -> Signal<GetTokenResponse, NetworkError> {
        return request(.login(offerId: offerId))
    }
    
    func logout(token: String, mobileUid: String) -> Signal<SuccessResponse, NetworkError> {
        return request(.logout(token: token, mobileUid: mobileUid))
    }
    
    func refresh(token: String) -> Signal<GetTokenResponse, NetworkError> {
        return request(.refreshToken(token: token))
    }
}
