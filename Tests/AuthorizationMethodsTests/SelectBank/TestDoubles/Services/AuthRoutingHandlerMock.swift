import UIKit
import DiiaMVPModule
import DiiaCommonTypes
import DiiaCommonServices

class AuthRoutingHandlerMock: RoutingHandlerProtocol {
    
    var action: ((BaseView?) -> Void)?

    func performPresenting(action: @escaping (BaseView?) -> Void) {
        self.action = action
    }
    
    func popToPublicServices() {
        
    }
}

// MARK: - Stubs
class DeepLinkManagerStub: DeepLinkManagerProtocol {
    var appRouter: RoutingHandlerProtocol? = AuthRoutingHandlerMock()
    
    func parse(url: URL) -> Bool {
        return false
    }
}

class URLOpenerStub: URLOpenerProtocol {
    func url(urlString: String?, linkType: String?) -> Bool {
        return false
    }
    
    func tryURL(urls: [String]) -> Bool {
        return false
    }
}
