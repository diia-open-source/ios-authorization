import UIKit
import DiiaMVPModule
import DiiaAuthorization
       
final class BankIdAuthModule: BaseModule {
    private let view: BankIdAuthViewController
    private let presenter: BankIdAuthPresenter
    
    init(bankId: String,
         authURL: String,
         parentView: BaseView,
         authService: AuthorizationServiceProtocol) {
            view = BankIdAuthViewController.storyboardInstantiate(bundle: Bundle.module)
            presenter = BankIdAuthPresenter(view: view,
                                            bankId: bankId,
                                            authUrl: authURL,
                                            parentView: parentView,
                                            authService: authService)
            view.presenter = presenter
    }

    func viewController() -> UIViewController {
        return view
    }
}
