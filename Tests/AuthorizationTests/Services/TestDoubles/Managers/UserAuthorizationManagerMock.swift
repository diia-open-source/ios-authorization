import Foundation
import DiiaMVPModule
import DiiaNetwork
import DiiaCommonTypes
@testable import DiiaAuthorization

class UserAuthorizationManagerMock: UserAuthorizationManager {
    private(set) var isLogoutCalled: Bool = false
    private(set) var isRefreshCalled: Bool = false
    private(set) var isGetTokenCalled: Bool = false
    private(set) var isAuthorizeCalled: Bool = false
    private(set) var isProlongTokenCalled: Bool = false
    private(set) var isLoginWithTokenCalled: Bool = false
    
    init(storage: AuthorizationStorageProtocol) {
        super.init(authorizationService: AutorizationManagerMock(),
                   apiClient: AuthorizationApiClientStub(),
                   storage: storage,
                   authStateHandler: AuthorizationServiceStateHandlerMock(),
                   refreshTemplateActionProvider: RefreshTemplateActionProviderMock(),
                   userAuthorizationErrorRouter: UserAuthorizationErrorRouterMock(),
                   analyticsHandler: AnalyticsAuthHandlerMock())
        
    }
    
    override func logout() {
        isLogoutCalled.toggle()
    }
    
    override func refresh(completion: ((Error?) -> Void)? = nil) {
        isRefreshCalled.toggle()
    }
    
    override func getToken(in view: BaseView? = nil, processId: String, completion: ((NetworkError?) -> Void)? = nil) {
        isGetTokenCalled.toggle()
    }
    
    override func authorize(in view: BaseView? = nil, parameters: [String : String]? = nil, failureAction: Callback? = nil) {
        isAuthorizeCalled.toggle()
    }
    
    override func prolongToken(in view: BaseView? = nil, processId: String, completion: ((NetworkError?) -> Void)? = nil) {
        isProlongTokenCalled.toggle()
    }
    
    override func loginWithToken(token: String, completion: Callback?) {
        isLoginWithTokenCalled.toggle()
    }
    
}
