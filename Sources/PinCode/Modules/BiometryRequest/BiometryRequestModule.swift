import UIKit
import DiiaMVPModule
import DiiaUIComponents
       
public final class BiometryRequestModule: BaseModule {
    private let view: BiometryRequestViewController
    private let presenter: BiometryRequestPresenter
    
    public init(viewModel: BiometryRequestViewModel) {
        view = BiometryRequestViewController.storyboardInstantiate(bundle: Bundle.module)
        presenter = BiometryRequestPresenter(view: view, viewModel: viewModel)
        view.presenter = presenter
    }

    public func viewController() -> UIViewController {
        return view
    }
}
