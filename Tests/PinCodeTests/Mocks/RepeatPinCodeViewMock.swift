import UIKit
import DiiaCommonTypes
@testable import DiiaAuthorizationPinCode

final class RepeatPinCodeViewMock: UIViewController, RepeatPinCodeView {
    
    private(set) var enteredNumbersCountValue: Int = 0
    private(set) var userDidEnterIncorrectPinCalled = false
    private(set) var configureWithViewModelCalled = false

    func configure(with viewModel: PinCodeViewModel) {
        configureWithViewModelCalled = true
    }
    
    func userDidEnterIncorrectPin() {
        userDidEnterIncorrectPinCalled = true
    }
    
    func setEnteredNumbersCount(count: Int) {
        enteredNumbersCountValue = count
    }
}
