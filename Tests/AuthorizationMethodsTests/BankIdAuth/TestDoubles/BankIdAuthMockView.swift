
import UIKit
import DiiaMVPModule
@testable import DiiaAuthorizationMethods

final class BankIdAuthMockView: UIViewController, BankIdAuthView {
    private(set) var isLoadCalled: Bool = false
    private(set) var isShowInsecureContentInfoCalled: Bool = false
    private(set) var isCloseToParentViewCalled: Bool = false
    
    func load(url: URL) {
        isLoadCalled.toggle()
    }
    
    func showInsecureContentInfo() {
        isShowInsecureContentInfoCalled.toggle()
    }
    
    func closeToView(view: BaseView?, animated: Bool) {
        if view is BaseViewStub {
            isCloseToParentViewCalled.toggle()
        }
    }
}
