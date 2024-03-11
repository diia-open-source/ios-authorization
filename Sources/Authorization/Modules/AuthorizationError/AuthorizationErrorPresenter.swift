import UIKit
import DiiaMVPModule
import DiiaCommonTypes

protocol AuthorizationErrorAction: BasePresenter {
	func onMainAction()
    func onAlternativeAction()
    func logout()
}

final class AuthorizationErrorPresenter: AuthorizationErrorAction {
    
    // MARK: - Properties
    unowned var view: AuthorizationErrorView
    private let mainAction: Action
    private let alternativeAction: Action
    private let errorInfo: AuthErrorViewModel
    private let mobileUID: () -> String
    private let logoutAction: () -> Void

    // MARK: - Init
    init(view: AuthorizationErrorView,
         errorInfo: AuthErrorViewModel,
         mobileUID: @escaping () -> String,
         logout: @escaping () -> Void) {
        self.view = view
        self.errorInfo = errorInfo
        self.mobileUID = mobileUID
        self.logoutAction = logout

        switch errorInfo.errorType {
        case .userAuth:
            mainAction = Action(
                title: R.Strings.authorization_error_button_title.localized(),
                iconName: nil,
                callback: { [weak view] in view?.closeModule(animated: true) }
            )
            alternativeAction = Action(
                title: R.Strings.menu_copy_uid.localized(),
                iconName: nil,
                callback: { [weak view] in
                    UIPasteboard.general.string = mobileUID()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    view?.showSuccessMessage(message: R.Strings.general_number_copied.localized())
                }
            )
        case .serviceAuth:
            mainAction = Action(
                title: R.Strings.menu_logout.localized(),
                iconName: nil,
                callback: { [weak view] in view?.showLogoutAlert() }
            )
            alternativeAction = Action(
                title: R.Strings.authorization_stay_in_app.localized(),
                iconName: nil,
                callback: { [weak view] in view?.closeModule(animated: true) }
            )
        }
    }
    
    func configureView() {
        view.setMessage(message: errorInfo.message, description: errorInfo.details.text)
        view.setMainActionTitle(title: mainAction.title)
        view.setAlternativeActionTitle(title: alternativeAction.title)
    }
    
    func onMainAction() {
        mainAction.callback()
    }
    
    func onAlternativeAction() {
        alternativeAction.callback()
    }
    
    func onClickCopy() {
        UIPasteboard.general.string = mobileUID()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        view.showSuccessMessage(message: R.Strings.general_number_copied.localized())
    }
    
    func logout() {
        logoutAction()
    }
}
