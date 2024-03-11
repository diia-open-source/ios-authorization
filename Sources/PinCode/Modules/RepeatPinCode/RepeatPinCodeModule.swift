import UIKit
import DiiaMVPModule
import DiiaUIComponents
       
final class RepeatPinCodeModule: BaseModule {
    private let view: RepeatPinCodeViewController
    private let presenter: RepeatPinCodePresenter
    
    init(pinCode: [Int], viewModel: PinCodeViewModel) {
        view = RepeatPinCodeViewController.storyboardInstantiate(bundle: Bundle.module)
        presenter = RepeatPinCodePresenter(view: view, oldPinCode: pinCode, viewModel: viewModel)
        view.presenter = presenter
    }

    func viewController() -> UIViewController {
        return view
    }
}
