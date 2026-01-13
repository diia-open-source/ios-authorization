
import Foundation
import DiiaMVPModule
import DiiaCommonTypes

final class UserAuthorizationErrorRouterMock: RouterExtendedProtocol {
    private(set) var isRouteCalled: Bool = false
    private(set) var isRouteReplaceCalled: Bool = false
    
    func route(in view: BaseView) {
        isRouteCalled.toggle()
    }
    
    func route(in view: BaseView, replace: Bool, animated: Bool) {
        isRouteReplaceCalled.toggle()
    }
}
