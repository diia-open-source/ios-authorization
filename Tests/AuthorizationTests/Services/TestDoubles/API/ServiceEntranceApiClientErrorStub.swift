import Foundation
import ReactiveKit
import DiiaNetwork
import DiiaCommonTypes
@testable import DiiaAuthorization

class ServiceEntranceApiClientErrorStub: ServiceEntranceApiClientProtocol {
    func login(offerId: String) -> Signal<GetTokenResponse, NetworkError> {
        return .failed(.noData)
    }
    
    func logout(token: String, mobileUid: String) -> Signal<SuccessResponse, NetworkError> {
        return .failed(.noData)
    }
    
    func refresh(token: String) -> Signal<GetTokenResponse, NetworkError> {
        return .failed(.wrongStatusCode("", AppConstants.HttpCode.unauthorized, .noData))
    }
}
