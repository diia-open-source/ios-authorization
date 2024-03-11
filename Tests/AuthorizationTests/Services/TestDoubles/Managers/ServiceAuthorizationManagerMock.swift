import Foundation
import DiiaMVPModule
@testable import DiiaAuthorization

class ServiceAuthorizationManagerMock: ServiceAuthorizationManager {
    private(set) var isLogoutCalled: Bool = false
    private(set) var isServiceLoginCalled: Bool = false
    private(set) var isRefreshCalled: Bool = false
    
    init(storage: AuthorizationStorageProtocol) {
        super.init(authorizationService: AutorizationManagerMock(),
                   storage: storage,
                   serviceEntranceClient: ServiceEntranceApiClientStub(),
                   mobileUID: { return "" },
                   authSuccessModule: nil,
                   userAuthorizationErrorRouter: UserAuthorizationErrorRouterMock())
    }
    
    override func logout() {
        isLogoutCalled.toggle()
    }
    
    override func serviceLogin(in view: BaseView?, offerId: String) {
        isServiceLoginCalled.toggle()
    }
    
    override func refresh(completion: ((Error?) -> Void)? = nil) {
        isRefreshCalled.toggle()
    }
}
