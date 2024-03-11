import UIKit
import DiiaMVPModule
import DiiaUIComponents

public final class ChangePincodeModule: BaseModule {
    private let view: ChangePincodeViewController
    private let presenter: ChangePincodePresenter
    
    public init(pinCodeLength: Int, context: ChangePincodeModuleContext) {
        
        view = ChangePincodeViewController.storyboardInstantiate(bundle: Bundle.module)
        let viewModel = ChangePincodeViewModel(
            title: R.Strings.authorization_repeat_pincode.formattedLocalized(arguments: String(pinCodeLength)),
            description: R.Strings.menu_change_pin_olddescr.localized(),
            pinCodeLength: pinCodeLength,
            checkAction: { (pincode) -> Bool in
                return context.pinCodeManager.checkPincode(pincode: pincode)
            },
            successAction: { (_, currentView) in
                let module = ChangePincodeNewModule(pinCodeLength: pinCodeLength, context: context)
                let navigationController = (currentView as? UIViewController)?.navigationController
                navigationController?.replaceTopViewController(with: module.viewController(), animated: true)
                context.storage.saveIncorrectPincodeAttemptsCount(0, flow: .auth)

            },
            failureAction: context.onOldPincodeWrongValue)
        
        presenter = ChangePincodePresenter(view: view, viewModel: viewModel)
        view.presenter = presenter
    }

    public func viewController() -> UIViewController {
        return view
    }
}

final class ChangePincodeNewModule: BaseModule {
    private let view: ChangePincodeViewController
    private let presenter: ChangePincodePresenter
    
    init(pinCodeLength: Int, context: ChangePincodeModuleContext) {
        view = ChangePincodeViewController.storyboardInstantiate(bundle: Bundle.module)
        let viewModel = ChangePincodeViewModel(
            title: R.Strings.menu_change_pin_new.formattedLocalized(arguments: String(pinCodeLength)),
            description: R.Strings.authorization_new_pin_details.localized(),
            pinCodeLength: pinCodeLength,
            checkAction: { _ in return true },
            successAction: { (pincode, currentView) in
                currentView?.open(module: ChangePincodeRepeatModule(
                    pincode: pincode,
                    pinCodeLength: pinCodeLength,
                    context: context)
                )
            },
            failureAction: { _ in }
        )
        
        presenter = ChangePincodePresenter(view: view, viewModel: viewModel)
        view.presenter = presenter
    }

    func viewController() -> UIViewController {
        return view
    }
}

final class ChangePincodeRepeatModule: BaseModule {
    private let view: ChangePincodeViewController
    private let presenter: ChangePincodePresenter
    
    init(pincode: [Int], pinCodeLength: Int, context: ChangePincodeModuleContext) {
        view = ChangePincodeViewController.storyboardInstantiate(bundle: Bundle.module)
        
        let viewModel = ChangePincodeViewModel(
            title: R.Strings.menu_change_pin_repeat.formattedLocalized(arguments: String(pinCodeLength)),
            description: R.Strings.authorization_repeat_pin_details.localized(),
            pinCodeLength: pinCodeLength,
            checkAction: { $0 == pincode },
            successAction: context.onPincodeChangedWithSuccess,
            failureAction: { view in view?.closeModule(animated: true) }
        )
        
        presenter = ChangePincodePresenter(view: view, viewModel: viewModel)
        view.presenter = presenter
    }

    func viewController() -> UIViewController {
        return view
    }
}
