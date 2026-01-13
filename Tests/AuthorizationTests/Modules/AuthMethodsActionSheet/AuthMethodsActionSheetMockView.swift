
import UIKit
import DiiaUIComponents
@testable import DiiaAuthorization

final class AuthMethodsActionSheetMockView: UIViewController, AuthMethodsActionSheetView {
    private(set) var isSetTitleCalled: Bool = false
    private(set) var isConfigureCalled: Bool = false
    private(set) var isSetSeparatorColorCalled: Bool = false
    private(set) var isCloseCalled: Bool = false
    
    func setTitle(_ title: String) {
        isSetTitleCalled.toggle()
    }
    
    func configure(with authMethods: [AuthMethod]) {
        isConfigureCalled.toggle()
    }
    
    func setLoadingState(_ state: LoadingState) {}
    
    func setEnabledButtonsStack(isEnabled: Bool) {}
    
    func setSeparatorColor(authFlow: AuthFlow) {
        isSetSeparatorColorCalled.toggle()
    }
    
    func close() {
        isCloseCalled.toggle()
    }
}
