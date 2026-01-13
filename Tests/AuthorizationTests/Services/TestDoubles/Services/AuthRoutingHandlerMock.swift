
import UIKit
import DiiaMVPModule
import DiiaCommonTypes
import DiiaCommonServices

final class AuthRoutingHandlerMock: RoutingHandlerProtocol {
    
    var action: ((BaseView?) -> Void)?
    
    func configure(window: UIWindow, navigationController: UINavigationController) {}
    
    func open(module: BaseModule, needPincode: Bool, asRoot: Bool) {}
    
    func popToPublicServices() {}
    
    func performPresenting(action: @escaping (BaseView?) -> Void) {
        self.action = action
    }
}

// MARK: - Stubs
final class DeepLinkManagerStub: DeepLinkManagerProtocol {
    var appRouter: RoutingHandlerProtocol? = AuthRoutingHandlerMock()
    
    func parse(url: URL) -> Bool {
        return false
    }
}

final class URLOpenerStub: URLOpenerProtocol {
    func url(urlString: String?, linkType: String?) -> Bool {
        return false
    }
    
    func tryURL(urls: [String]) -> Bool {
        return false
    }
}
