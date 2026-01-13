
import Foundation
import DiiaMVPModule
import DiiaCommonTypes

final class AuthErrorRouterMock: RouterProtocol {
    private(set) var isRouteCalled: Bool = false
    
    func route(in view: BaseView) {
        isRouteCalled.toggle()
    }
}
