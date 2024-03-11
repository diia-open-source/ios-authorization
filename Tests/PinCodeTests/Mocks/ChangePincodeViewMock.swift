import UIKit
import DiiaCommonTypes
@testable import DiiaAuthorizationPinCode

final class ChangePincodeViewMock: UIViewController, ChangePincodeView {
    
    private(set) var enteredNumbersCounter: Int = 0

    private(set) var configureWithPinCodeLengthCalled = false
    private(set) var setTitleCalled = false
    private(set) var setDescriptionCalled = false
    private(set) var userDidEnterIncorrectPinCalled = false
    private(set) var setEnteredNumbersCountCalled = false
    
    func configure(with pinCodeLength: Int) {
        configureWithPinCodeLengthCalled = true
    }
    
    func setTitle(title: String) {
        setTitleCalled = true
    }
    
    func setDescription(description: String) {
        setDescriptionCalled = true
    }
    
    func userDidEnterIncorrectPin() {
        userDidEnterIncorrectPinCalled = true
    }
    
    func setEnteredNumbersCount(count: Int) {
        setEnteredNumbersCountCalled = true
        enteredNumbersCounter = count
    }
}
