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
    @IBOutlet weak private var buttonsStackView: UIStackView!
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
        
        titleLabel.font = FontBook.smallHeadingFont
        titleLabel.text = R.Strings.diia_id_identify_please.localized()
        
        closeButton.action = Action(
            title: nil,
            iconName: R.Image.clear.name,
            callback: { [weak self] in self?.presenter.onCloseTapped() }
        )
        closeButton.contentHorizontalAlignment = .center
        closeButton.contentVerticalAlignment = .center
        closeButton.iconRenderingMode = .alwaysTemplate
        
        containerButtomConstraint.constant = Constants.containerButtonInset
        
        setupAccessibility()
    }
    
    // MARK: - Private Methods
    @objc private func photoIdTapped() {
        presenter.identify(with: .photoId)
    }
    
    @objc private func nfcIdTapped() {
        presenter.identify(with: .nfc)
    }
    
    @objc private func bankIdTapped() {
        presenter.identify(with: .bankId)
    }
    
    @objc private func monobankTapped() {
        presenter.identify(with: .monobank)
    }
    
    @objc private func privatbankTapped() {
        presenter.identify(with: .privatbank)
    }
    
    private func prepareButton(for authMethod: AuthMethod) -> UIButton {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        
        let image: UIImage?
        let action: Selector
        
        switch authMethod {
        case .photoId:
            image = R.Image.photoId_squared.image
            action = #selector(photoIdTapped)
        case .nfc:
            image = R.Image.nfc_icon_squared.image
            action = #selector(nfcIdTapped)
        case .bankId:
            image = R.Image.bankId_icon_squared.image
            action = #selector(bankIdTapped)
        case .monobank:
            image = R.Image.monobank.image
            action = #selector(monobankTapped)
        case .privatbank:
            image = R.Image.privat24.image
            action = #selector(privatbankTapped)
        }
        
        button.titleLabel?.font = FontBook.smallHeadingFont
        button.setImage(image, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        return button
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
        func createStack(with authMethods: [AuthMethod]) -> UIStackView {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = Constants.horizontalStackSpacing
            stack.heightAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
            
            let leftPaddingView = UIView()
            leftPaddingView.backgroundColor = .clear
            
            stack.addArrangedSubview(leftPaddingView)
            authMethods
                .map(prepareButton)
                .forEach { stack.addArrangedSubview($0) }
            
            let rightPaddingView = UIView()
            rightPaddingView.backgroundColor = .clear
            stack.addArrangedSubview(rightPaddingView)
            rightPaddingView.widthAnchor.constraint(equalTo: leftPaddingView.widthAnchor).isActive = true
            
            return stack
        }
        
        var authMethods = authMethods
        
        if authMethods.count > Constants.maxMethodsInLine {
            let lastThreeMethods: [AuthMethod] = authMethods.suffix(Constants.maxMethodsInLine)
            authMethods.removeLast(Constants.maxMethodsInLine)
            
            buttonsStackView.addArrangedSubview(createStack(with: lastThreeMethods))
        }
        
        buttonsStackView.insertArrangedSubview(createStack(with: authMethods), at: 0)
    }
    
    func setLoadingState(_ state: LoadingState) {
        loadingIndicator.layer.sublayers?.forEach { $0.removeAllAnimations() }
        loadingIndicator.setProgress(0.0, animated: false)
        loadingIndicator.isHidden = state == .ready
        buttonsStackView.isUserInteractionEnabled = state == .ready
        
        guard state == .loading else { return }
        
        loadingIndicator.layoutIfNeeded()
        loadingIndicator.setProgress(1.0, animated: false)
        UIView.animate(withDuration: Constants.progressAnimationDuration, delay: 0, options: [.repeat], animations: { [unowned self] in
            self.loadingIndicator.layoutIfNeeded()
        })
    }
    
    func setEnabledButtonsStack(isEnabled: Bool) {
        buttonsStackView.isUserInteractionEnabled = isEnabled
    }
    
    func setSeparatorColor(authFlow: AuthFlow) {
        var separatorColorStr: String
        switch authFlow {
        case .login:
            separatorColorStr = Constants.separatorColorGreen
        default:
            separatorColorStr = AppConstants.Colors.separatorColor
        }
        separatorView.backgroundColor = UIColor(separatorColorStr)
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
        static let containerCornerRadius: CGFloat = 8
        static let horizontalStackSpacing: CGFloat = 24
        static var buttonSize: CGFloat {
            switch UIScreen.main.bounds.width {
            case 320:
                return 56
            default:
                return 64
            }
        }
        static let maxMethodsInLine = 3
        static var containerButtonInset: CGFloat {
            switch UIDevice.size() {
            case .screen4Inch, .screen4_7Inch, .screen5_5Inch:
                return 16
            default:
                return 0
            }
        }
        
        static let separatorColorGreen = "#BAD6B8"
    }
}
