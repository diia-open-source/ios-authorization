import Foundation
import Alamofire
import DiiaCommonTypes
import DiiaAuthorization

public struct BankIDAuthorizationNetworkContext {
    public let session: Alamofire.Session
    public let host: String
    public let headers: [String: String]?
    public let token: (() -> String)

    public init(session: Alamofire.Session, host: String, headers: [String: String]?, token: @escaping (() -> String)) {
        self.session = session
        self.host = host
        self.headers = headers
        self.token = token
    }
}

public struct BankIDAuthorizationContext {
    public let network: BankIDAuthorizationNetworkContext
    public let authService: AuthorizationServiceProtocol
    public let authErrorRouter: RouterProtocol
    public let analyticsHandler: AnalyticsAuthMethodsHandler?

    public init(network: BankIDAuthorizationNetworkContext,
                authService: AuthorizationServiceProtocol,
                authErrorRouter: RouterProtocol,
                analyticsHandler: AnalyticsAuthMethodsHandler? = nil) {
        self.network = network
        self.authService = authService
        self.authErrorRouter = authErrorRouter
        self.analyticsHandler = analyticsHandler
    }
}
