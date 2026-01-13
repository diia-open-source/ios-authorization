
import UIKit
import DiiaMVPModule
import DiiaUIComponents
import DiiaCommonServices
import DiiaAuthorization
@testable import DiiaAuthorizationMethods

final class SelectBankMockView: UIViewController, SelectBankView {
    private(set) var isBankIdAuthModuleCalled: Bool = false
    private(set) var isShowProgressCalled = false
    private(set) var isHideProgressCalled = false
    private(set) var isShowStubMessageCalled = false
    private(set) var setLoadingStateCallCount: Int = .zero
    private(set) var banksItems: [DSListItemViewModel]?
    
    var onGeneralErrorShow: ((Bool) -> Void)?
    
    func setLoadingState(_ state: DiiaUIComponents.LoadingState) {
        setLoadingStateCallCount += 1
    }
    
    func setupBanks(_ items: [DiiaUIComponents.DSListItemViewModel]) {
        banksItems = items
    }
    
    func showStubMessage(with viewModel: DiiaUIComponents.StubMessageViewModel) {
        isShowStubMessageCalled = true
    }
    
    func showChild(module: BaseModule) {
        if module is GeneralErrorModule {
            onGeneralErrorShow?(true)
        } else if let childContainerController = module.viewController() as? ChildContainerViewController,
                  let controller = childContainerController.childSubview as? SmallAlertViewController {
            onMainQueue { controller.presenter.onMainButton() }
        }
    }
    
    func open(module: BaseModule) {
        if module is BankIdAuthModule {
            isBankIdAuthModuleCalled.toggle()
        }
    }
    
    func showProgress() {
        isShowProgressCalled = true
    }
    
    func hideProgress() {
        isHideProgressCalled = true
    }
}
