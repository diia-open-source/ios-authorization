import UIKit
import DiiaMVPModule
import DiiaUIComponents
import DiiaAuthorization

protocol SelectBankView: BaseView {
    func setLoadingState(_ state: LoadingState)
    func setupBanks(_ items: [DSListItemViewModel])
    func showStubMessage(with viewModel: StubMessageViewModel)
}

final class SelectBankViewController: UIViewController, Storyboarded {
    
    // MARK: - Outlets
    @IBOutlet private weak var topView: TopNavigationBigView!
    @IBOutlet private weak var contentLoadingView: ContentLoadingView!
    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet private weak var infoStackView: UIView!
    @IBOutlet private weak var stubMessage: StubMessageViewV2!
    
    @IBOutlet private weak var allBanksInfoLabel: UILabel!
    @IBOutlet private weak var searchTextField: DSSearchInputView!
    @IBOutlet private weak var banksListView: DSWhiteColoredListView!
    
    @IBOutlet private weak var contentBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var presenter: SelectBankAction!
    private var keyboardHandler: KeyboardHandler?
    
	// MARK: - Lifecycle
	override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        presenter.configureView()
    }
    
    private func initialSetup() {
        setupTopView()
        setupFonts()

        setupLabels()
        setupTextField()
        setupKeyboardHandler()
        setupAccessibility()

        stubMessage.isHidden = true
    }
    
    private func setupTopView() {
        topView.configure(
            viewModel: TopNavigationBigViewModel(
                title: R.Strings.authorization_all_banks_title.localized(),
                backAction: { [weak self] in
                    self?.closeModule(animated: true)
                })
        )
    }
    
    private func setupFonts() {
        allBanksInfoLabel.font = FontBook.usualFont
    }
    
    private func setupLabels() {
        allBanksInfoLabel.setTextWithCurrentAttributes(
            text: R.Strings.authorization_all_banks_info.localized(),
            lineHeightMultiple: Constants.infoLineHeightMultiple
        )
    }
    
    private func setupTextField() {
        searchTextField.setup(
            placeholder: R.Strings.authorization_search.localized(),
            delegate: searchTextField,
            isActive: false,
            textChangeCallback: { [weak self] in
                self?.textChanged()
            }
        )
    }
    
    private func setupKeyboardHandler() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        contentView.addGestureRecognizer(tapRecognizer)
        contentView.isUserInteractionEnabled = true
        
        keyboardHandler = KeyboardHandler(type: .constraint(constraint: contentBottomConstraint, withoutInset: Constants.buttonBottomOffset, keyboardInset: Constants.keyboardInset, superview: self.view))
    }
    
    private func setupAccessibility() {
        allBanksInfoLabel.accessibilityIdentifier = Constants.titleComponentId
        infoStackView.accessibilityIdentifier = Constants.bodyComponentId
        searchTextField.accessibilityIdentifier = Constants.searchComponentId
        banksListView.accessibilityIdentifier = Constants.bankListComponentId
        stubMessage.accessibilityIdentifier = Constants.stubMessageComponentId

        searchTextField.isAccessibilityElement = true
        searchTextField.accessibilityTraits = .searchField
        searchTextField.accessibilityLabel = R.Strings.auth_accessibility_banks_search.localized()
    }
    
    // MARK: - Actions
    private func textChanged() {
        presenter.search(text: searchTextField.searchText)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - View logic
extension SelectBankViewController: SelectBankView {
    
    func setupBanks(_ items: [DSListItemViewModel]) {
        infoStackView.isHidden = false
        stubMessage.isHidden = true
        banksListView.alpha = items.isEmpty ? 0 : 1
        banksListView.configure(viewModel: DSListViewModel(items: items))
    }

    func showStubMessage(with viewModel: StubMessageViewModel) {
        infoStackView.isHidden = true
        stubMessage.isHidden = false
        stubMessage.configure(with: viewModel)
    }

    func setLoadingState(_ state: LoadingState) {
        contentLoadingView.setLoadingState(state)
        contentView.isHidden = state == .loading
    }
}

// MARK: - UITextFieldDelegate
extension SelectBankViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(false)
        return true
    }
}

// MARK: - Constants
extension SelectBankViewController {
    private enum Constants {
        static let keyboardInset: CGFloat = 0
        static let infoLineHeightMultiple: CGFloat = 1.25
        
        static var buttonBottomOffset: CGFloat = {
            switch UIDevice.size() {
            case .screen4Inch, .screen4_7Inch, .screen5_5Inch: return 32
            default: return 0
            }
        }()

        static let titleComponentId = "title_bankid"
        static let bodyComponentId = "body_bankid"
        static let searchComponentId = "search_bankid"
        static let bankListComponentId = "bank_list_bankid"
        static let stubMessageComponentId = "stub_message_bankid"
    }
}
