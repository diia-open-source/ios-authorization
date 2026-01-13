
import UIKit
import DiiaMVPModule
import DiiaCommonServices
import DiiaCommonTypes

protocol CreatePinCodeAction: BasePresenter {
    func selectNumber(number: Int)
    func clear()
    func removeLast()
    func cancel()
}

final class CreatePinCodePresenter: CreatePinCodeAction {
    
    // MARK: - Properties
    unowned var view: CreatePinCodeView
    private let viewModel: PinCodeViewModel

    private var pinCode: [Int] = [] {
        didSet {
            view.setEnteredNumbersCount(count: pinCode.count)
            if pinCode.count == viewModel.pinCodeLength {
                view.open(module: RepeatPinCodeModule(pinCode: pinCode, viewModel: viewModel))
            }
        }
    }
    
    // MARK: - Init
    init(
        view: CreatePinCodeView,
        viewModel: PinCodeViewModel
    ) {
        self.view = view
        self.viewModel = viewModel
    }
    
    // MARK: - Public Methods
    func configureView() {
        view.configure(with: viewModel)
    }
    
    func selectNumber(number: Int) {
        pinCode.append(number)
    }
    
    func clear() {
        pinCode = []
    }
    
    func removeLast() {
        guard !pinCode.isEmpty else { return }
        pinCode.removeLast()
    }

    func cancel() {
        handleTemplate(Constants.cancelTemplate)
    }

    // MARK: - Private
    private func handleTemplate(_ alert: AlertTemplate) {
        TemplateHandler.handleGlobal(alert) { [weak self] action in
            switch action {
            case .cancel:
                self?.view.closeModule(animated: true)
            default:
                break
            }
        }
    }
}

extension CreatePinCodePresenter {
    private enum Constants {
        static let templateIcon = "attentionBlackRound"
        static let cancelTemplate = AlertTemplate(
            type: .middleCenterIconBlackButtonAlert,
            isClosable: false,
            data: AlertTemplateData(
                icon: Constants.templateIcon,
                title: R.Strings.authorization_template_cancel_title.localized(),
                description: R.Strings.authorization_template_cancel_description.localized(),
                mainButton: AlertButtonModel(
                    title: R.Strings.authorization_template_cancel_button_primary.localized(),
                    icon: nil,
                    action: .cancel
                ),
                alternativeButton: AlertButtonModel(
                    title: R.Strings.authorization_template_cancel_button_secondary.localized(),
                    icon: nil,
                    action: .skip
                )
            )
        )
    }
}
