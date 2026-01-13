
import UIKit
import DiiaMVPModule
import DiiaUIComponents

protocol RepeatPinCodeView: BaseView {
    func configure(with viewModel: PinCodeViewModel)
    func userDidEnterIncorrectPin()
	func setEnteredNumbersCount(count: Int)
}

final class RepeatPinCodeViewController: UIViewController, Storyboarded {

	// MARK: - Outlets
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var pincodeView: PincodeView!
    @IBOutlet private weak var backButton: UIButton?
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    @IBOutlet weak private var pincodeHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var presenter: RepeatPinCodeAction!

	// MARK: - Lifecycle
	override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        presenter.configureView()
    }
    
    // MARK: - Overriding
    override func canGoBack() -> Bool {
        return false
    }
    
    // MARK: - Private Methods
    private func initialSetup() {
        headerLabel.text = R.Strings.authorization_repeat_pincode.formattedLocalized(arguments: Constants.pincodeLength)
        headerLabel.font = FontBook.largeFont
        infoLabel.font = FontBook.usualFont
        titleLabel.font = FontBook.mainFont.regular.size(16)
        pincodeHeightConstraint.constant = Constants.pincodeHeight
        pincodeView.delegate = self
        
        cancelButton?.titleLabel?.font = FontBook.bigText
        cancelButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var newContainer = container
            newContainer.font = FontBook.bigText
            return newContainer
        }
        
        setupAccessibility()
    }

    private func setupAccessibility() {
        headerLabel.accessibilityIdentifier = Constants.titleComponentId
        pincodeView.accessibilityIdentifier = Constants.numButtonTitleComponentId
        pincodeView.setComponentIds(
            indicatorsId: Constants.ellipsStepperComponentId,
            buttonsTile: Constants.btnNumComponentId)

        cancelButton?.accessibilityLabel = R.Strings.general_cancel.localized()
        cancelButton?.accessibilityHint = R.Strings.general_cancel_hint.localized()
        backButton?.accessibilityLabel = R.Strings.general_accessibility_back_button_label.localized()
        backButton?.accessibilityHint = R.Strings.general_accessibility_back_button_step.localized()
        headerLabel.accessibilityHint = R.Strings.auth_accessibility_pincode_header_hint.localized()
    }
    
    // MARK: - Actions
    @IBAction private func backButtonTapped() {
        closeModule(animated: true)
    }

    @IBAction private func cancelButtonTapped() {
        presenter.cancel()
    }
}

// MARK: - View logic
extension RepeatPinCodeViewController: RepeatPinCodeView {
    func configure(with viewModel: PinCodeViewModel) {
        pincodeView.indicatorsAmount = viewModel.pinCodeLength
        headerLabel.text = R.Strings.authorization_repeat_pincode.formattedLocalized(arguments: String(viewModel.pinCodeLength))
        infoLabel.text = viewModel.repeatDetails
        
        switch viewModel.authFlow {
        case .login, .prolong, .serviceLogin:
            backButton?.removeFromSuperview()
            cancelButton.isHidden = true
        case .diiaId:
            titleLabel.isHidden = false
            backgroundImageView.image = UIImage.from(color: Constants.backgroundColor)
        default:
            return
        }
    }
    
    func userDidEnterIncorrectPin() {
        pincodeView.notifyIncorrectPincode()
    }
    
    func setEnteredNumbersCount(count: Int) {
        pincodeView.setNumbersCount(count: count)
    }
}

// MARK: - PinCodeViewDelegate
extension RepeatPinCodeViewController: PinCodeViewDelegate {
    func numberSelected(number: Int) {
        presenter.selectNumber(number: number)
    }
    
    func clearPressed() {
        presenter.removeLast()
    }
}

// MARK: - Constants
extension RepeatPinCodeViewController {
    private enum Constants {
        static let backgroundColor = UIColor("#E2ECF4")
        static var pincodeHeight: CGFloat {
            switch UIDevice.size() {
            case .screen4Inch, .screen_zoomed: return 372
            case .screen5_5Inch, .screen6_1Inch: return 480
            case .screen6_5Inch, .screen6_7Inch: return 640
            default: return 436
            }
        }
        
        static let pincodeLength = "4"

        static let titleComponentId = "title_pinconfirm"
        static let numButtonTitleComponentId = "num_button_title_pinconfirm"
        static let ellipsStepperComponentId = "ellips_stepper_pinconfirm"
        static let btnNumComponentId = "btn_num_pinconfirm"
    }
}
