import UIKit
import DiiaCommonTypes
@testable import DiiaAuthorization

class AuthorizationErrorMockView: UIViewController, AuthorizationErrorView {
    private(set) var isSetMessageCalled: Bool = false
    private(set) var isSetMainActionTitleCalled: Bool = false
    private(set) var isSetAlternativeActionTitleCalled: Bool = false
    private(set) var isShowLogoutAlertCalled: Bool = false
    private(set) var isCloseModuleCalled: Bool = false
    private(set) var isShowSuccessMessageCalled: Bool = false
    
    func setMessage(message: String, description: String?) {
        isSetMessageCalled.toggle()
    }
    
    func setMainActionTitle(title: String?) {
        isSetMainActionTitleCalled.toggle()
    }
    
    func setAlternativeActionTitle(title: String?) {
        isSetAlternativeActionTitleCalled.toggle()
    }
    
    func showLogoutAlert() {
        isShowLogoutAlertCalled.toggle()
    }
    
    func closeModule(animated: Bool) {
        isCloseModuleCalled.toggle()
    }
    
    func showSuccessMessage(message: String) {
        isShowSuccessMessageCalled.toggle()
    }
}
