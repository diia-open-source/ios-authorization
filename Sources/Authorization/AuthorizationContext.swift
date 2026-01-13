
import Foundation
import Alamofire
import DiiaMVPModule
import DiiaCommonTypes

public struct AuthorizationNetworkContext {
    public let session: Alamofire.Session
    public let host: String
    public let headers: [String: String]?

    public init(session: Alamofire.Session, host: String, headers: [String: String]?) {
        self.session = session
        self.host = host
        self.headers = headers
    }
}

public struct AuthorizationContext {
    let network: AuthorizationNetworkContext
    let storage: AuthorizationStorageProtocol
    let serviceAuthSuccessModule: BaseModule?
    let refreshTemplateActionProvider: RefreshTemplateActionProvider
    let authStateHandler: AuthorizationServiceStateHandler
    let userAuthorizationErrorRouter: RouterExtendedProtocol
    let analyticsHandler: AnalyticsAuthorizationHandler

    public init(network: AuthorizationNetworkContext,
                storage: AuthorizationStorageProtocol,
                serviceAuthSuccessModule: BaseModule?,
                refreshTemplateActionProvider: RefreshTemplateActionProvider,
                authStateHandler: AuthorizationServiceStateHandler,
                userAuthorizationErrorRouter: RouterExtendedProtocol,
                analyticsHandler: AnalyticsAuthorizationHandler) {
        self.network = network
        self.storage = storage
        self.serviceAuthSuccessModule = serviceAuthSuccessModule
        self.refreshTemplateActionProvider = refreshTemplateActionProvider
        self.authStateHandler = authStateHandler
        self.userAuthorizationErrorRouter = userAuthorizationErrorRouter
        self.analyticsHandler = analyticsHandler
    }
}
