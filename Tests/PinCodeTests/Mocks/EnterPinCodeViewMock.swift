import UIKit
import Foundation
import DiiaCommonTypes
import DiiaUIComponents
@testable import DiiaAuthorizationPinCode

final class EnterPinCodeViewMock: UIViewController, EnterPinCodeView {
    
    // MARK: - state monitores
    private(set) var enteredNumbersCounter: Int = 0
    private(set) var configureForBiometryCalled = false
    private(set) var canStartBiometryCalled = false
    private(set) var configureWithViewModelCalled = false
    
    // MARK: -
    var configureForBiometryActionSubscriber: Callback?

    // MARK: - expected result
    var canStartBiometryExpectedResult = false
    var needAsyncAction = false
    
    func canStartBiometry() -> Bool {
        canStartBiometryCalled = true
        return canStartBiometryExpectedResult
    }
    
    func configure(with viewModel: EnterPinCodeViewModel) {
        configureWithViewModelCalled = true
    }
    
    func setEnteredNumbersCount(count: Int) {
        enteredNumbersCounter = count
    }
    
    func userDidEnterIncorrectPin() {
        
    }
    
    func configureForBiometry(biometryType: BiometryHelper.BiometricType, action: @escaping Callback) {
        configureForBiometryCalled = true
        
        guard needAsyncAction else {
            return
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + TimeInterval(Constants.delay), execute: {
            action()
            self.configureForBiometryActionSubscriber?()
        })
    }
}

private extension EnterPinCodeViewMock {
    enum Constants {
        static let delay = 0.01
    }
}

