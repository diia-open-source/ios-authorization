
import UIKit
import DiiaMVPModule
import DiiaCommonTypes
import DiiaUIComponents

protocol AuthMethodsActionSheetView: BaseView {
    func setTitle(_ title: String)
    func configure(with authMethods: [AuthMethod])
    func setLoadingState(_ state: LoadingState)
    func setEnabledButtonsStack(isEnabled: Bool)
    func setSeparatorColor(authFlow: AuthFlow)
    func close()
}

final class AuthMethodsActionSheetViewController: UIViewController, ChildSubcontroller, Storyboarded {
    
    // MARK: - Outlets
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet private weak var loadingIndicator: UIProgressView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var buttonsList: DSWhiteColoredListView!
    @IBOutlet weak private var separatorView: UIView!
    @IBOutlet weak private var closeButton: ActionButton!
    @IBOutlet weak private var containerButtomConstraint: NSLayoutConstraint!

	// MARK: - Properties
	var presenter: AuthMethodsActionSheetAction!
    weak var container: ContainerProtocol?

	// MARK: - Lifecycle
	override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        presenter.configureView()
    }
    
    private func initialSetup() {
        containerView.layer.cornerRadius = Constants.containerCornerRadius
        containerView.layer.masksToBounds = true
        
        titleLabel.font = FontBook.bigText
        titleLabel.text = R.Strings.diia_id_identify_please.localized()
        
        closeButton.action = Action(
            title: R.Strings.general_accessibility_close.localized(),
            iconName: nil,
            callback: { [weak self] in self?.presenter.onCloseTapped() }
        )
        closeButton.titleLabel?.textAlignment = .center
        closeButton.setupUI(font: FontBook.smallHeadingFont, cornerRadius: Constants.cornerRadiusButton)
        closeButton.setTitle(R.Strings.general_accessibility_close.localized(), for: .normal)
        
        containerButtomConstraint.constant = Constants.containerButtonInset
        
        setupAccessibility()
    }
    
    // MARK: - Private Methods
    
    private func identifyWithMethod(authMethod: AuthMethod) {
        presenter.identify(with: authMethod)
    }
    
    private func setupAccessibility() {
        titleLabel.accessibilityHint = R.Strings.auth_accessibility_methods_title_hint.localized()
        closeButton.accessibilityLabel = R.Strings.general_accessibility_close.localized()
        closeButton.accessibilityHint = R.Strings.auth_accessibility_methods_close_hint.localized()
        
        UIAccessibility.post(notification: .layoutChanged, argument: titleLabel)
    }
}

// MARK: - View logic
extension AuthMethodsActionSheetViewController: AuthMethodsActionSheetView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func configure(with authMethods: [AuthMethod]) {
        let list: DSListViewModel = .init(
            title: nil,
            items: authMethods.compactMap { item in
                return DSListItemViewModel(
                    leftBigIcon: item.icon,
                    title: item.label ?? "",
                    onClick: { [weak self] in
                        self?.identifyWithMethod(authMethod: item)
                    })
            })
        buttonsList.configure(viewModel: list)
    }
    
    func setLoadingState(_ state: LoadingState) {
        loadingIndicator.layer.sublayers?.forEach { $0.removeAllAnimations() }
        loadingIndicator.setProgress(0.0, animated: false)
        loadingIndicator.isHidden = state == .ready
        buttonsList.isUserInteractionEnabled = state == .ready
        
        guard state == .loading else { return }
        
        loadingIndicator.layoutIfNeeded()
        loadingIndicator.setProgress(1.0, animated: false)
        UIView.animate(withDuration: Constants.progressAnimationDuration, delay: 0, options: [.repeat], animations: { [unowned self] in
            self.loadingIndicator.layoutIfNeeded()
        })
    }
    
    func setEnabledButtonsStack(isEnabled: Bool) {
        buttonsList.isUserInteractionEnabled = isEnabled
    }
    
    func setSeparatorColor(authFlow: AuthFlow) {
        var separatorColor: UIColor
        switch authFlow {
        case .login:
            separatorColor = Constants.separatorColor
        default:
            separatorColor = UIColor(AppConstants.Colors.separatorColor)
        }
        separatorView.backgroundColor = separatorColor
        closeButton.imageView?.tintColor = separatorView.backgroundColor
    }
    
    func close() {
        container?.close()
    }
}

// MARK: - Constants
extension AuthMethodsActionSheetViewController {
    private enum Constants {
        static let progressAnimationDuration: TimeInterval = 1.5
        static let containerCornerRadius: CGFloat = 24
        static var buttonSize: CGFloat = 32
        static var containerButtonInset: CGFloat {
            switch UIDevice.size() {
            case .screen4Inch, .screen4_7Inch, .screen5_5Inch:
                return 16
            default:
                return 0
            }
        }
        static let cornerRadiusButton: CGFloat = 28
        static let separatorColor = UIColor.black.withAlphaComponent(0.07)
    }
}
