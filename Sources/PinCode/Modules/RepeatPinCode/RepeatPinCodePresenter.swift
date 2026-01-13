
import UIKit
import DiiaMVPModule
import DiiaCommonServices
import DiiaCommonTypes

protocol RepeatPinCodeAction: BasePresenter {
    func selectNumber(number: Int)
    func removeLast()
    func cancel()
}

final class RepeatPinCodePresenter: RepeatPinCodeAction {
    
    // MARK: - Properties
    unowned var view: RepeatPinCodeView
    private var oldPinCode: [Int]
    private let viewModel: PinCodeViewModel
    
    private var pinCode: [Int] = [] {
        didSet {
            view.setEnteredNumbersCount(count: pinCode.count)
            if pinCode.count == viewModel.pinCodeLength {
                checkPincode()
            }
        }
    }
    
    private var numberOfIncorrectAttempts = 0
    
    // MARK: - Init
    init(
        view: RepeatPinCodeView,
        oldPinCode: [Int],
        viewModel: PinCodeViewModel
    ) {
        self.view = view
        self.oldPinCode = oldPinCode
        self.viewModel = viewModel
    }
    
    // MARK: - Public Methods
    func configureView() {
        view.configure(with: viewModel)
    }
    
    func selectNumber(number: Int) {
        pinCode.append(number)
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
                if let viewController = self?.view as? UIViewController,
                   let navigationController = viewController.navigationController,
                   navigationController.viewControllers.count >= 3 {
                    let targetViewController = navigationController.viewControllers[navigationController.viewControllers.count - 3]
                    navigationController.popToViewController(targetViewController, animated: true)
                } else {
                    self?.view.closeModule(animated: true)
                }
            default:
                break
            }
        }
    }

    private func checkPincode() {
        if oldPinCode == pinCode {
            viewModel.completionHandler(pinCode, view)
            return
        }
        
        numberOfIncorrectAttempts += 1
        pinCode = []
        if numberOfIncorrectAttempts < 3 {
            view.userDidEnterIncorrectPin()
        } else {
            view.closeModule(animated: true)
        }
    }
}

extension RepeatPinCodePresenter {
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

