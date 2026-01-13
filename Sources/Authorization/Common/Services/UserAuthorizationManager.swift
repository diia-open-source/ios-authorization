
import UIKit
import ReactiveKit
import DiiaCommonTypes
import DiiaCommonServices
import DiiaNetwork
import DiiaMVPModule

public protocol RefreshTemplateActionProvider {
    func refreshTemplateAction(with callback: @escaping Callback) -> (AlertTemplateAction) -> Void
}

public protocol AnalyticsAuthorizationHandler {
    func trackSuccessForTarget(target: AuthTarget)
    func trackFailForTarget(target: AuthTarget, error: NetworkError)
}

public class UserAuthorizationManager: DisposeBagProvider, BindingExecutionContextProvider {
    // MARK: - Properties
    private weak var authorizationService: AuthorizationServiceProtocol?
    private let storage: AuthorizationStorageProtocol
    private let apiClient: AuthorizationApiClientProtocol
    private let authStateHandler: AuthorizationServiceStateHandler
    private let refreshTemplateActionProvider: RefreshTemplateActionProvider
    private let userAuthorizationErrorRouter: RouterExtendedProtocol
    private let analyticsHandler: AnalyticsAuthorizationHandler

    private(set) var token: String? {
        didSet {
            storage.saveAuthToken(token)
        }
    }
    var target: AuthTarget?
    var requestId: String?
    var processId: String?
    var flow: UserAuthorizationFlow = .login(completionHandler: { _, _ in })

    public var bindingExecutionContext: ExecutionContext { .immediateOnMain }
    public let bag: DisposeBag = DisposeBag()
    
    // MARK: - Init
    init(authorizationService: AuthorizationServiceProtocol,
         apiClient: AuthorizationApiClientProtocol,
         storage: AuthorizationStorageProtocol,
         authStateHandler: AuthorizationServiceStateHandler,
         refreshTemplateActionProvider: RefreshTemplateActionProvider,
         userAuthorizationErrorRouter: RouterExtendedProtocol,
         analyticsHandler: AnalyticsAuthorizationHandler) {

        self.authorizationService = authorizationService
        self.storage = storage
        self.apiClient = apiClient
        self.refreshTemplateActionProvider = refreshTemplateActionProvider
        self.authStateHandler = authStateHandler
        self.userAuthorizationErrorRouter = userAuthorizationErrorRouter
        self.analyticsHandler = analyticsHandler

        self.token = storage.getAuthToken()

        guard let logoutToken: String = storage.getLogoutToken() else { return }
        
        if ReachabilityHelper.shared.isReachable() {
            logout(for: logoutToken)
        } else {
            ReachabilityHelper.shared.statusSignal
                .filter { $0 }
                .first()
                .observeNext { [weak self] _ in self?.logout(for: logoutToken) }
                .dispose(in: bag)
        }
    }

    convenience init(authorizationService: AuthorizationServiceProtocol,
                     network: AuthorizationNetworkContext,
                     storage: AuthorizationStorageProtocol,
                     authStateHandler: AuthorizationServiceStateHandler,
                     refreshTemplateActionProvider: RefreshTemplateActionProvider,
                     userAuthorizationErrorRouter: RouterExtendedProtocol,
                     analyticsHandler: AnalyticsAuthorizationHandler) {
        let apiClient = AuthorizationApiClient(context: network, token: { [weak authorizationService] in
            authorizationService?.token ?? ""
        })

        self.init(authorizationService: authorizationService,
                  apiClient: apiClient,
                  storage: storage,
                  authStateHandler: authStateHandler,
                  refreshTemplateActionProvider: refreshTemplateActionProvider,
                  userAuthorizationErrorRouter: userAuthorizationErrorRouter,
                  analyticsHandler: analyticsHandler)
    }

    // MARK: - Public Methods
    func authorize(in view: BaseView? = nil, parameters: [String: String]? = nil, failureAction: Callback? = nil) {
        verify(in: view, parameters: parameters, failureAction: failureAction)
    }
    
    func loginWithToken(token: String, completion: Callback?) {
        processId = nil
        finishLogin(with: token, completion: completion)
    }

    func logout() {
        guard let logoutToken = token else { return }
        storage.saveLogoutToken(logoutToken)
        
        token = nil
        
        if ReachabilityHelper.shared.isReachable() {
            logout(for: logoutToken)
        } else {
            ReachabilityHelper.shared.statusSignal
                .filter { $0 }
                .first()
                .observeNext { [weak self] _ in self?.logout(for: logoutToken) }
                .dispose(in: bag)
        }
    }
    
    func refresh(completion: ((Error?) -> Void)? = nil) {
        apiClient
            .refresh()
            .observe { [weak self] signal in
                guard let self = self else { return }
                switch signal {
                case .completed:
                    break
                case .next(let response):
                    if let token = response.token {
                        self.token = token
                    }
                    if let template = response.template {
                        
                        let refreshCallback = self.refreshTemplateActionProvider.refreshTemplateAction(with: {
                            completion?(nil)
                        })
                        TemplateHandler.handleGlobal(template, callback: refreshCallback)
                        return
                    }
                    completion?(nil)
                case .failed(let error):
                    switch error {
                    case .nsUrlErrorDomain(_, let statusCode), .wrongStatusCode(_, let statusCode, _):
                        if statusCode == AppConstants.HttpCode.unauthorized {
                            self.authorizationService?.logout()
                        }
                    default:
                        break
                    }
                    
                    completion?(error)
                }
            }
            .dispose(in: bag)
    }
    
    // MARK: - Private Methods
    private func verify(in view: BaseView? = nil, parameters: [String: String]? = nil, failureAction: Callback? = nil) {
        guard
            let target = target,
            let requestId = requestId,
            let processId = processId
        else {
            authorizationService?.isAuthorizingByDeeplink = false
            failureAction?()
            return
        }
        view?.showProgress()
        
        apiClient
            .verify(target: target, requestId: requestId, processId: processId, parameters: parameters)
            .observe { [weak self, weak view] signal in
                guard let view = view else { return }
                view.hideProgress()
                
                switch signal {
                case .next(let alertTemplateResponse):
                    self?.analyticsHandler.trackSuccessForTarget(target: target)
                    TemplateHandler.handleGlobal(alertTemplateResponse.template,
                                           callback: { [weak self] action in
                        self?.flow.onCompletion(in: view, action: action)
                        self?.authorizationService?.isAuthorizingByDeeplink = false
                    })
                case .failed(let error):
                    self?.analyticsHandler.trackFailForTarget(target: target, error: error)
                    self?.authorizationService?.isAuthorizingByDeeplink = false
                    failureAction?()
                    switch self?.flow {
                    case .login:
                        self?.userAuthorizationErrorRouter.route(in: view, replace: target == .bankId, animated: target == .bankId)
                    default:
                        break
                    }
                default:
                    return
                }
                view.hideProgress()
            }
            .dispose(in: bag)
    }
    
    func getToken(in view: BaseView? = nil, processId: String, completion: ((NetworkError?) -> Void)? = nil) {
        // TODO: Remove target from here
        guard
            let target = target
        else {
            completion?(.badUrl)
            return
        }
        view?.showProgress()
        apiClient
            .getToken(processId: processId)
            .observe { [weak view, weak self] signal in
                view?.hideProgress()
                
                switch signal {
                case .next(let tokenResponse):
                    self?.finishLogin(with: tokenResponse.token) {
                        completion?(nil)
                    }
                case .failed(let error):
                    completion?(error)
                    guard let view = view else { return }
                    self?.userAuthorizationErrorRouter.route(in: view, replace: target == .bankId, animated: target == .bankId)
                default:
                    break
                }
            }
            .dispose(in: bag)
    }
    
    func prolongToken(in view: BaseView? = nil, processId: String, completion: ((NetworkError?) -> Void)? = nil) {
        view?.showProgress()
        
        apiClient
            .prolong(processId: processId)
            .observe { [ weak self, weak view] signal in
                view?.hideProgress()
                
                switch signal {
                case .next(let tokenResponse):
                    if let token = tokenResponse.token {
                        self?.token = token
                    }
                    
                    if let template = tokenResponse.template {
                        TemplateHandler.handleGlobal(template, callback: { [weak self] _ in
                            completion?(nil)
                            self?.flow = .login(completionHandler: { _, _ in })
                        })
                        return
                    }
                    completion?(nil)
                    self?.flow = .login(completionHandler: { _, _ in })
                case .failed(let error):
                    completion?(error)
                default:
                    break
                }
            }
            .dispose(in: bag)
    }
    
    private func finishLogin(with token: String, completion: Callback?) {
        target = nil
        requestId = nil
        self.token = token
        self.authorizationService?.authState = .userAuth
        self.authorizationService?.userAuthSignal.receive()
        self.authStateHandler.onLoginDidFinish()
        completion?()
    }

    private func logout(for logoutToken: String) {
        apiClient
            .logout(
                token: logoutToken,
                mobileID: storage.getMobileUID()
            )
            .observe { _ in self.storage.removeLogoutToken() }
            .dispose(in: bag)
    }
}
