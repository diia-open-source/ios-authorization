
import UIKit
import DiiaMVPModule
import DiiaUIComponents

protocol EnterPinCodeAction: BasePresenter {
    func forgotPincodePressed()
    func selectNumber(number: Int)
    func viewDidAppear()
    func removeLast()
}

final class EnterPinCodeAuthPresenter: EnterPinCodeAction {
    
    // MARK: - Properties
    unowned var view: EnterPinCodeView
    private let viewModel: EnterPinCodeViewModel
    private let enterPinCodeDelegate: EnterPinCodeDelegate // strong reference, must live as long as EnterPinCodeAuthPresenter itself
    private let biometryHelper: BiometrySupportProtocol
    
    private let storage: PinCodeStorageProtocol
    private var pinCode: [Int] = [] {
        didSet {
            view.setEnteredNumbersCount(count: pinCode.count)
        }
    }
    private var cancelledBiometryAuth = false

    // MARK: - Init
    init(
        context: EnterPinCodeModuleContext,
        view: EnterPinCodeView,
        viewModel: EnterPinCodeViewModel,
        biometryHelper: BiometrySupportProtocol
    ) {
        self.storage = context.storage
        self.view = view
        self.viewModel = viewModel
        
        self.enterPinCodeDelegate = context.enterPinCodeDelegate
        self.biometryHelper = biometryHelper
    }
    
    func configureView() {
        view.configure(with: viewModel)
        
        let biometryType = biometryHelper.biometricType()
        if biometryType != .none, storage.getIsBiometryEnabled() == true {
            view.configureForBiometry(biometryType: biometryType) { [weak self] in
                self?.authorizeWithBiometry()
            }
        }
    }
    
    private func authorizeWithBiometry() {
        guard view.canStartBiometry() else { return }
        biometryHelper.authorizeWithBiometry { [weak self] (error) in
            onMainQueue {
                guard let self else { return }
                self.cancelledBiometryAuth = error != nil
                
                guard error == nil, self.view.canStartBiometry() else { return }
                self.enterPinCodeDelegate.didCorrectPincodeEntered(pincode: "")
            }
        }
    }
    
    func viewDidAppear() {
        guard biometryHelper.biometricType() != .none,
              storage.getIsBiometryEnabled() == true,
              !cancelledBiometryAuth
        else { return }
        
        onMainQueueAfter(time: Constants.biometryAuthDelay) { [weak self] in
            self?.authorizeWithBiometry()
        }
    }
    
    func selectNumber(number: Int) {
        pinCode.append(number)
        if pinCode.count >= viewModel.pinCodeLength {
            let incorrectCount: Int = (storage.getIncorrectPincodeAttemptsCount(flow: .auth) ?? 0) + 1
            if enterPinCodeDelegate.checkPincode(pinCode) {
                storage.saveIncorrectPincodeAttemptsCount(0, flow: .auth)
                enterPinCodeDelegate.didCorrectPincodeEntered(pincode: pinCode.map(String.init).joined())
            } else if incorrectCount < Constants.allowedAttempts {
                view.userDidEnterIncorrectPin()
                pinCode = []
                storage.saveIncorrectPincodeAttemptsCount(incorrectCount, flow: .auth)
            } else {
                enterPinCodeDelegate.didAllAttemptsExhausted(in: view)
            }
        }
    }
    
    func removeLast() {
        guard !pinCode.isEmpty else { return }
        pinCode.removeLast()
    }
    
    func forgotPincodePressed() {
        enterPinCodeDelegate.onForgotPincode(in: view)
    }
}

// MARK: - Constants
extension EnterPinCodeAuthPresenter {
    private enum Constants {
        static let allowedAttempts = 3
        static let biometryAuthDelay: TimeInterval = 0.2
    }
}
