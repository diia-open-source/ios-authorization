
import UIKit
import ReactiveKit
import DiiaMVPModule
import DiiaCommonTypes
import DiiaNetwork

public protocol AuthorizationServiceProtocol: AnyObject, Logoutable {
    var authState: AuthorizationState { get set }
    var token: String? { get }

    var userAuthSignal: PassthroughSubject<Void, Never> { get }
    var isAuthorizingByDeeplink: Bool { get set }

    func getProcessId() -> String?
    func setProcessId(processId: String?)

    func setRequestId(requestId: String?)
    func getRequestId() -> String?

    func setTarget(target: AuthTarget?)

    func authorize(in view: BaseView?, parameters: [String: String]?, failureAction: Callback?)
}

public protocol PinCodeManagerProtocol: AnyObject {
    func havePincode() -> Bool
    func setPincode(pincode: [Int])
    func checkPincode(pincode: [Int]) -> Bool
    func setLastPincodeDate(date: Date)
    func doesNeedPincode() -> Bool
}

public protocol Logoutable: AnyObject {
    func logout()
}
                                        
public protocol UserAuthFlowHandlerProtocol: AnyObject {
    func setUserAuthorizationFlow(_ flow: UserAuthorizationFlow)
}

public protocol AuthorizationServiceStateHandler {
    func onLoginDidFinish()
    func onLogoutDidFinish()
}

// MARK: - AuthorizationService
public final class AuthorizationService: AuthorizationServiceProtocol {

    // MARK: - Properties
    private let context: AuthorizationContext

    private lazy var serviceAuthManager: ServiceAuthorizationManager = .init(authorizationService: self,
                                                                             storage: context.storage,
                                                                             networkContext: context.network,
                                                                             mobileUID: { [weak self] in self?.context.storage.getMobileUID() ?? "" },
                                                                             authSuccessModule: context.serviceAuthSuccessModule,
                                                                             userAuthorizationErrorRouter: context.userAuthorizationErrorRouter)

    private lazy var userAuthManager: UserAuthorizationManager = .init(authorizationService: self,
                                                                       network: context.network,
                                                                       storage: context.storage,
                                                                       authStateHandler: context.authStateHandler,
                                                                       refreshTemplateActionProvider: context.refreshTemplateActionProvider,
                                                                       userAuthorizationErrorRouter: context.userAuthorizationErrorRouter,
                                                                       analyticsHandler: context.analyticsHandler)

    private var hashedPincode: String? {
        didSet {
            context.storage.saveHashedPincode(hashedPincode)
        }
    }
    
    public lazy var authState: AuthorizationState = {
        if userAuthManager.token != nil {
            return .userAuth
        } else if serviceAuthManager.serviceToken != nil {
            return .serviceAuth
        } else {
            return .notAuthorized
        }
    }()
    public var token: String? {
        switch authState {
        case .userAuth: return userAuthManager.token
        case .serviceAuth: return serviceAuthManager.serviceToken
        case .notAuthorized: return nil
        }
    }
    public let userAuthSignal = PassthroughSubject<Void, Never>()
    public var isAuthorizingByDeeplink = false

    // MARK: - Public Init
    public init(context: AuthorizationContext) {
        self.context = context

        hashedPincode = context.storage.getHashedPincode()
    }
    
    // MARK: - Internal Init
    convenience init(context: AuthorizationContext,
                     userAuthManager: UserAuthorizationManager,
                     serviceAuthManager: ServiceAuthorizationManager) {
        self.init(context: context)
        self.userAuthManager = userAuthManager
        self.serviceAuthManager = serviceAuthManager
    }
}

extension AuthorizationService {

    public func getProcessId() -> String? {
        return userAuthManager.processId
    }

    public func setProcessId(processId: String?) {
        userAuthManager.processId = processId
    }

    public func setTarget(target: AuthTarget?) {
        userAuthManager.target = target
    }

    public func setRequestId(requestId: String?) {
        userAuthManager.requestId = requestId
    }

    public func getRequestId() -> String? {
        return userAuthManager.requestId
    }

    public func authorize(in view: BaseView?, parameters: [String: String]? = nil, failureAction: Callback? = nil) {
        userAuthManager.authorize(in: view, parameters: parameters, failureAction: failureAction)
    }
}

extension AuthorizationService: Logoutable {
    public func logout() {
        hashedPincode = nil
        let storedState = self.authState
        authState = .notAuthorized

        context.authStateHandler.onLogoutDidFinish()
        
        switch storedState {
        case .userAuth:
            userAuthManager.logout()
        case .serviceAuth:
            serviceAuthManager.logout()
        case .notAuthorized:
            break
        }
    }
}

extension AuthorizationService {
    public func loginWithToken(token: String, completion: Callback?) {
        userAuthManager.loginWithToken(token: token, completion: completion)
    }

    public func userLogin(in view: BaseView?, processId: String, completion: ((Error?) -> Void)?) {
        guard isAuthorized() == false else { return }

        userAuthManager.getToken(in: view, processId: processId, completion: completion)
    }

    public func serviceLogin(in view: BaseView?, offerId: String) {
        guard isAuthorized() == false else { return }

        serviceAuthManager.serviceLogin(in: view, offerId: offerId)
    }

    public func refresh(completion: ((Error?) -> Void)? = nil) {
        switch authState {
        case .userAuth:
            userAuthManager.refresh(completion: completion)
        case .serviceAuth:
            serviceAuthManager.refresh(completion: completion)
        case .notAuthorized:
            completion?(nil)
        }
    }

    public func isAuthorized() -> Bool {
        authState != .notAuthorized
    }
}

extension AuthorizationService: PinCodeManagerProtocol {
    public func havePincode() -> Bool {
        return hashedPincode != nil
    }
    
    public func setPincode(pincode: [Int]) {
        self.hashedPincode = pincode.map { String($0) }.joined().toSHA256()
    }
    
    public func checkPincode(pincode: [Int]) -> Bool {
        return self.hashedPincode == pincode.map { String($0) }.joined().toSHA256()
    }
    
    public func setLastPincodeDate(date: Date) {
        if hashedPincode != nil {
            context.storage.saveLastPincodeDate(date)
        } else {
            context.storage.removeLastPincodeDate()
        }
    }
    
    public func doesNeedPincode() -> Bool {
        if !isAuthorized() || !havePincode() { return false }
        
        if let date: Date = context.storage.getLastPincodeDate() {
            return Date() - date >= Constants.timeForNeedPincode
        }
        return true
    }
}

extension AuthorizationService {
    public func prolong(in view: BaseView?, processId: String, completion: ((NetworkError?) -> Void)?) {
        guard isAuthorized() == true else { return }
        
        userAuthManager.prolongToken(in: view, processId: processId, completion: completion)
    }
}

extension AuthorizationService: UserAuthFlowHandlerProtocol {
    public func setUserAuthorizationFlow(_ flow: UserAuthorizationFlow) {
        userAuthManager.flow = flow
    }
}

// MARK: - Constants
extension AuthorizationService {
    private enum Constants {
        static let timeForNeedPincode: Double = 300
    }
}
