
import UIKit
import ReactiveKit
import DiiaMVPModule
import DiiaCommonTypes
import DiiaCommonServices

class ServiceAuthorizationManager {
    
    // MARK: - Properties
    private weak var authorizationService: AuthorizationServiceProtocol?
    private let storage: AuthorizationStorageProtocol
    private let serviceEntranceClient: ServiceEntranceApiClientProtocol?
    private let mobileUID: () -> String
    private let authSuccessModule: BaseModule?
    private let userAuthorizationErrorRouter: RouterProtocol

    private let disposeBag = DisposeBag()

    private(set) var serviceToken: String? {
        didSet {
            storage.saveServiceToken(serviceToken)
        }
    }
    
    // MARK: - Init
    init(authorizationService: AuthorizationServiceProtocol,
         storage: AuthorizationStorageProtocol,
         serviceEntranceClient: ServiceEntranceApiClientProtocol,
         mobileUID: @escaping () -> String,
         authSuccessModule: BaseModule?,
         userAuthorizationErrorRouter: RouterProtocol) {
        self.authorizationService = authorizationService
        self.storage = storage
        self.mobileUID = mobileUID
        self.serviceEntranceClient = serviceEntranceClient
        self.authSuccessModule = authSuccessModule
        self.userAuthorizationErrorRouter = userAuthorizationErrorRouter

        serviceToken = storage.getServiceToken()
    }

    convenience init(authorizationService: AuthorizationServiceProtocol,
                     storage: AuthorizationStorageProtocol,
                     networkContext: AuthorizationNetworkContext,
                     mobileUID: @escaping () -> String,
                     authSuccessModule: BaseModule?,
                     userAuthorizationErrorRouter: RouterProtocol) {
        let apiClient = ServiceEntranceApiClient(context: networkContext)

        self.init(authorizationService: authorizationService,
                  storage: storage,
                  serviceEntranceClient: apiClient,
                  mobileUID: mobileUID,
                  authSuccessModule: authSuccessModule,
                  userAuthorizationErrorRouter: userAuthorizationErrorRouter)
    }

    // MARK: - Public Methods
    func serviceLogin(in view: BaseView?, offerId: String) {
        serviceEntranceClient?
            .login(offerId: offerId)
            .observe { [weak self, weak view] signal in
                guard let self = self, let moduleToDisplay = self.authSuccessModule else { return }

                switch signal {
                case .next(let response):
                    self.serviceToken = response.token
                    self.authorizationService?.authState = .serviceAuth
                    view?.open(module: moduleToDisplay)
                case .failed:
                    guard let view = view else { return }
                    userAuthorizationErrorRouter.route(in: view)
                default:
                    break
                }
            }
            .dispose(in: disposeBag)
    }
    
    func logout() {
        guard let logoutToken = serviceToken else { return }
        storage.saveServiceLogoutToken(logoutToken)
        
        serviceToken = nil
        
        if ReachabilityHelper.shared.isReachable() {
            logout(for: logoutToken)
        } else {
            ReachabilityHelper.shared.statusSignal
                .filter { $0 }
                .first()
                .observeNext { _ in self.logout(for: logoutToken) }
                .dispose(in: disposeBag)
        }
    }
    
    func refresh(completion: ((Error?) -> Void)? = nil) {
        serviceEntranceClient?
            .refresh(token: authorizationService?.token ?? "")
            .observe { signal in
                switch signal {
                case .completed:
                    break
                case .next(let response):
                    self.serviceToken = response.token
                    completion?(nil)
                case .failed(let error):
                    switch error {
                    case .nsUrlErrorDomain(_, let statusCode), .wrongStatusCode(_, let statusCode, _):
                        if statusCode == 401 {
                            self.authorizationService?.logout()
                        }
                    default:
                        break
                    }
                    
                    completion?(error)
                }
            }
            .dispose(in: disposeBag)
    }
    
    // MARK: - Private Methods
    private func logout(for logoutToken: String) {
        let uid = mobileUID()
        serviceEntranceClient?
            .logout(token: logoutToken, mobileUid: uid)
            .observe { _ in self.storage.removeServiceLogoutToken() }
            .dispose(in: disposeBag)
    }
}
