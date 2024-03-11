import Foundation

final class EnterPinCodeDiiaIdPresenter: EnterPinCodeAction {
    
    // MARK: - Properties
    unowned var view: EnterPinCodeView
    private let viewModel: EnterPinCodeViewModel
    private let storeHelper: PinCodeStorageProtocol

    private let enterPinCodeDelegate: EnterPinCodeDelegate // strong reference, must live as long as EnterPinCodeAuthPresenter itself

    private var pinCode: [Int] = [] {
        didSet {
            view.setEnteredNumbersCount(count: pinCode.count)
        }
    }
    
    // MARK: - Init
    init(
        context: EnterPinCodeModuleContext,
        view: EnterPinCodeView,
        viewModel: EnterPinCodeViewModel
    ) {
        self.storeHelper = context.storage
        self.view = view
        self.viewModel = viewModel
        
        self.enterPinCodeDelegate = context.enterPinCodeDelegate
    }
    
    // MARK: - Public Methods
    func configureView() {
        view.configure(with: viewModel)
    }
    
    func viewDidAppear() { }
    
    func forgotPincodePressed() {
        enterPinCodeDelegate.onForgotPincode(in: view)
    }
    
    func selectNumber(number: Int) {
        pinCode.append(number)
        if pinCode.count >= viewModel.pinCodeLength {
            let incorrectCount: Int = (storeHelper.getIncorrectPincodeAttemptsCount(flow: .diiaId) ?? 0) + 1
            if enterPinCodeDelegate.checkPincode(pinCode) {
                storeHelper.saveIncorrectPincodeAttemptsCount(0, flow: .diiaId)
                enterPinCodeDelegate.didCorrectPincodeEntered(pincode: pinCode.map(String.init).joined())
            } else if incorrectCount < Constants.allowedAttempts {
                view.userDidEnterIncorrectPin()
                pinCode = []
                storeHelper.saveIncorrectPincodeAttemptsCount(incorrectCount, flow: .diiaId)
            } else {
                enterPinCodeDelegate.didAllAttemptsExhausted(in: view)
            }
        }
    }
    
    func removeLast() {
        guard !pinCode.isEmpty else { return }
        pinCode.removeLast()
    }
}

// MARK: - Constants
extension EnterPinCodeDiiaIdPresenter {
    private enum Constants {
        static let allowedAttempts = 3
    }
}
