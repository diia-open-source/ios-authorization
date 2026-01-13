
import UIKit
import DiiaMVPModule
import DiiaUIComponents

protocol BiometryRequestView: BaseView {
    func configure(with viewModel: BiometryRequestViewModel)
}

final class BiometryRequestViewController: UIViewController, Storyboarded {

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var approveButton: UIButton!
    @IBOutlet private weak var laterButton: UIButton!
    
	// MARK: - Properties
	var presenter: BiometryRequestAction!
    
    // MARK: - Lifecycle
	override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        presenter.configureView()
    }
    
    private func initialSetup() {
        titleLabel.font = FontBook.numbersHeadingFont
        descriptionLabel.font = FontBook.usualFont
        
        approveButton.titleLabel?.font = FontBook.bigText
        approveButton.setTitle(R.Strings.authorization_allow.localized(), for: .normal)
        
        laterButton.titleLabel?.font = FontBook.usualFont
        laterButton.setTitle(R.Strings.authorization_allow_later.localized(), for: .normal)

        setupAccessibility()
    }
    
    private func setupAccessibility() {
        approveButton.accessibilityHint = R.Strings.auth_accessibility_biometry_request_approve.localized()
        laterButton.accessibilityHint = R.Strings.auth_accessibility_biometry_request_later.localized()
    }
    
    // MARK: - Overriding
    override func canGoBack() -> Bool {
        return false
    }
    
    // MARK: - Actions
    @IBAction func approveBtnPressed(_ sender: Any) {
        presenter.approve()
    }
    
    @IBAction func laterBtnPressed(_ sender: Any) {
        presenter.makeItLater()
    }
}

// MARK: - View logic
extension BiometryRequestViewController: BiometryRequestView {
    func configure(with viewModel: BiometryRequestViewModel) {
        titleLabel.text = viewModel.title
        descriptionLabel.setTextWithCurrentAttributes(
            text: viewModel.description,
            lineHeightMultiple: Constants.descriptionLineHeightMultiple
        )
        
        imageView.image = viewModel.icon
    }
}

// MARK: - Constants
extension BiometryRequestViewController {
    private enum Constants {
        static let descriptionLineHeightMultiple: CGFloat = 1.25
    }
}
