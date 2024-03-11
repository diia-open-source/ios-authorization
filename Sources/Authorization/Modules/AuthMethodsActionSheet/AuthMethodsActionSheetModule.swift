import UIKit
import DiiaMVPModule
import DiiaCommonTypes
import DiiaUIComponents
       
final class AuthMethodsActionSheetModule: BaseModule {
    private let view: AuthMethodsActionSheetViewController
    private let presenter: AuthMethodsActionSheetPresenter
    
    init(
        data: AuthActivityViewData,
        authFlow: AuthFlow,
        authorizationService: AuthorizationServiceProtocol&UserAuthFlowHandlerProtocol,
        identifyCallback: @escaping (AuthMethod) -> Void,
        onClose: @escaping (AlertTemplateAction) -> Void
    ) {
        view = AuthMethodsActionSheetViewController.storyboardInstantiate(bundle: Bundle.module)
        presenter = AuthMethodsActionSheetPresenter(
            view: view,
            data: data,
            authFlow: authFlow,
            authorizationService: authorizationService,
            identifyCallback: identifyCallback,
            onClose: onClose
        )
        view.presenter = presenter
    }

    func viewController() -> UIViewController {
        let vc = ChildContainerViewController()
        vc.childSubview = view
        vc.presentationStyle = .actionSheet
        return vc
    }
}
