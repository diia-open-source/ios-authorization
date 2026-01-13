
import UIKit
import DiiaMVPModule
import DiiaUIComponents
import DiiaCommonTypes

protocol AuthorizationErrorView: BaseView {
    func setMessage(message: String, description: String?)
    func setMainActionTitle(title: String?)
    func setAlternativeActionTitle(title: String?)
    func showLogoutAlert()
}

final class AuthorizationErrorViewController: UIViewController, Storyboarded {
    // MARK: - Outlets
    @IBOutlet private weak var stubMessageView: StubMessageViewV2!
    @IBOutlet private weak var mainButton: VerticalRoundButton!
    @IBOutlet private weak var alternativeButton: UIButton!

    // MARK: - Properties
    var presenter: AuthorizationErrorAction!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        presenter.configureView()
    }
    
    private func initialSetup() {
        setupFonts()
        setupAccessibility()
    }
    
    private func setupFonts() {
        mainButton.titleLabel?.font = FontBook.bigText
        alternativeButton.titleLabel?.font = FontBook.usualFont
    }
    
    override func canGoBack() -> Bool {
        return false
    }
    
    private func setupAccessibility() {
        stubMessageView.accessibilityIdentifier = Constants.stubMessageComponentId
        mainButton.accessibilityIdentifier = Constants.mainButtonComponentId
        alternativeButton.accessibilityIdentifier = Constants.altButtonComponentId
    }

    // MARK: - Actions
    @IBAction func mainButtonTapped() {
        presenter.onMainAction()
    }
    
    @IBAction func alternativeButtonTapped() {
        presenter.onAlternativeAction()
    }
}

// MARK: - View logic
extension AuthorizationErrorViewController: AuthorizationErrorView {
    
    func setMessage(message: String, description: String?) {
        stubMessageView.configure(with: StubMessageViewModel(
            icon: Constants.defaultIcon,
            title: message,
            descriptionText: description,
            repeatAction: nil)
        )
    }
    
    func setMainActionTitle(title: String?) {
        mainButton.setTitle(title, for: .normal)
    }
    
    func setAlternativeActionTitle(title: String?) {
        alternativeButton.setTitle(title, for: .normal)
    }
    
    func showLogoutAlert() {
        let actions = [
            AlertAction(
                title: R.Strings.menu_logout.localized(),
                type: .destructive,
                callback: { [weak self] in
                    self?.presenter.logout()
                }
            ),
            AlertAction(
                title: R.Strings.menu_logout_cancel.localized(),
                type: .normal,
                callback: {}
            )
        ]
        let alertModule = CustomAlertModule(title: R.Strings.menu_logout_title.localized(),
                                            message: R.Strings.menu_logout_message.localized(),
                                            actions: actions)
        
        self.showChild(module: alertModule)
    }
}

// MARK: - Constants
extension AuthorizationErrorViewController {
    private enum Constants {
        static let defaultIcon = "😔"

        static let stubMessageComponentId = "stub_message_failauth"
        static let mainButtonComponentId = "btn_tryagain_failauth"
        static let altButtonComponentId = "btn_copydeviceid_failauth"
    }
}
