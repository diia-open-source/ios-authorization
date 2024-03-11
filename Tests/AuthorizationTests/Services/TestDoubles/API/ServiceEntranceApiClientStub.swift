import Foundation
import ReactiveKit
import DiiaNetwork
import DiiaCommonTypes
@testable import DiiaAuthorization

class ServiceEntranceApiClientStub: ServiceEntranceApiClientProtocol {
    func login(offerId: String) -> Signal<GetTokenResponse, NetworkError> {
        return .init(just: .init(token: "serviceToken"))
    }
    
    func logout(token: String, mobileUid: String) -> Signal<SuccessResponse, NetworkError> {
        return .init(just: .init(success: true))
    }
    
    func refresh(token: String) -> Signal<GetTokenResponse, NetworkError> {
        return .init(just: .init(token: "serviceToken"))
    }
}
