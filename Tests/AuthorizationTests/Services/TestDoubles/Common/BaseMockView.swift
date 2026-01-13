
import UIKit
import DiiaMVPModule
import DiiaUIComponents
import DiiaCommonServices
@testable import DiiaAuthorization

final class BaseMockView: UIViewController, BaseView {
    private(set) var isAuthMethodsActionSheetModuleCalled = false
    private(set) var isCloseToViewViewAnimatedCalled = false
    private(set) var isBaseModuleStubCalled = false
    private(set) var isShowProgressCalled = false
    private(set) var isHideProgressCalled = false
    
    var onGeneralErrorShow: ((Bool) -> Void)?
    
    func showChild(module: BaseModule) {
        if module is GeneralErrorModule {
            onGeneralErrorShow?(true)
        } else if module is AuthMethodsActionSheetModule {
            isAuthMethodsActionSheetModuleCalled.toggle()
        } else if let childContainerController = module.viewController() as? ChildContainerViewController,
                  let controller = childContainerController.childSubview as? SmallAlertViewController {
            onMainQueue { controller.presenter.onMainButton() }
        }
    }
    
    func open(module: BaseModule) {
        if module is BaseModuleStub {
            isBaseModuleStubCalled.toggle()
        }
    }
    
    func closeToView(view: BaseView?, animated: Bool) {
        isCloseToViewViewAnimatedCalled.toggle()
    }
    
    func showProgress() {
        isShowProgressCalled = true
    }
    
    func hideProgress() {
        isHideProgressCalled = true
    }
}
