import UIKit
import DiiaMVPModule
import DiiaUIComponents
       
public final class CreatePinCodeModule: BaseModule {
    private let view: CreatePinCodeViewController
    private let presenter: CreatePinCodePresenter
    
    public init(viewModel: PinCodeViewModel) {
        view = CreatePinCodeViewController.storyboardInstantiate(bundle: Bundle.module)
        presenter = CreatePinCodePresenter(view: view, viewModel: viewModel)
        view.presenter = presenter
    }

    public func viewController() -> UIViewController {
        return view
    }
}
