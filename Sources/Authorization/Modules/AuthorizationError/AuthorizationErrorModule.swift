
import UIKit
import DiiaMVPModule
import DiiaUIComponents
       
public final class AuthorizationErrorModule: BaseModule {
    private let view: AuthorizationErrorViewController
    private let presenter: AuthorizationErrorPresenter
    
    public init(errorInfo: AuthErrorViewModel, mobileUID: @escaping () -> String, logout: @escaping () -> Void) {
        view = AuthorizationErrorViewController.storyboardInstantiate(bundle: Bundle.module)
        presenter = AuthorizationErrorPresenter(
            view: view,
            errorInfo: errorInfo,
            mobileUID: mobileUID,
            logout: logout
        )
        view.presenter = presenter
    }
    
    public func viewController() -> UIViewController {
        return view
    }
}
