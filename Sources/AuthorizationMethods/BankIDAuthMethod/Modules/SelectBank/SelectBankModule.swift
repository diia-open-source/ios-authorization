
import UIKit
import DiiaMVPModule
import DiiaCommonTypes

public final class SelectBankModule: BaseModule {
    private let view: SelectBankViewController
    private let presenter: SelectBankPresenter

    public init(context: BankIDAuthorizationContext,
                onClose: ((AlertTemplateAction) -> Void)?,
                handledRedirectionHosts: [String],
                appShortVersion: String) {

        AppConstants.handledRedirectionHosts = handledRedirectionHosts
        AppConstants.appShortVersion = appShortVersion

        view = SelectBankViewController.storyboardInstantiate(bundle: Bundle.module)
        let apiClient = SelectBankAPIClient(context: context.network)

        presenter = SelectBankPresenter(
            view: view,
            selectBankAPIClient: apiClient,
            authErrorRouter: context.authErrorRouter,
            authService: context.authService,
            analyticsHandler: context.analyticsHandler,
            onClose: onClose
        )
        view.presenter = presenter
    }

    public func viewController() -> UIViewController {
        return view
    }
}
