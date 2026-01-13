
import Foundation
import DiiaMVPModule
import DiiaCommonTypes
import ReactiveKit
@testable import DiiaAuthorization

final class AutorizationManagerMock: AuthorizationServiceProtocol, UserAuthFlowHandlerProtocol {
    var isAuthorizingByDeeplink: Bool = false
    private(set) var flow: UserAuthorizationFlow?
    private(set) var processId: String?
    private(set) var requestId: String?
    private(set) var authTarget: AuthTarget?
    private(set) var isUserAuthSignalReceived: Bool = false
    private(set) var isLogoutCalled: Bool = false
    private(set) var isAuthorizeCalled: Bool = false
    
    // MARK: - Properties
    private let bag = DisposeBag()
    var authState: AuthorizationState
    var token: String?
    var userAuthSignal: PassthroughSubject<Void, Never>
    var failureAuthorizeCallback: Callback?
    
    // MARK: - Init
    init(authState: AuthorizationState = .notAuthorized,
         token: String? = nil,
         userAuthSignal: PassthroughSubject<Void, Never> = .init()) {
        self.authState = authState
        self.token = token
        self.userAuthSignal = userAuthSignal
        userAuthSignal.observe { _ in
            self.isUserAuthSignalReceived.toggle()
        }.dispose(in: bag)
    }
    
    // MARK: - Methods
    func getProcessId() -> String? {
        return processId
    }
    
    func setProcessId(processId: String?) {
        self.processId = processId
    }
    
    func setRequestId(requestId: String?) {
        self.requestId = requestId
    }
    
    func getRequestId() -> String? {
        return requestId
    }
    
    func setTarget(target: AuthTarget?) {
        self.authTarget = target
    }
    
    func authorize(in view: BaseView?, parameters: [String : String]?, failureAction: Callback?) {
        isAuthorizeCalled.toggle()
        failureAuthorizeCallback = failureAction
    }
    
    func setUserAuthorizationFlow(_ flow: UserAuthorizationFlow) {
        self.flow = flow
    }
    
    func logout() {
        isLogoutCalled.toggle()
    }
}
