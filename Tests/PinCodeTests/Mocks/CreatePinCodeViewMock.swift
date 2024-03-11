import UIKit
import DiiaMVPModule
@testable import DiiaAuthorizationPinCode

final class CreatePinCodeViewMock: UIViewController, CreatePinCodeView {
    
    private(set) var configureWithViewModelCalled = false
    private(set) var setEnteredNumbersCountCalled = false
    private(set) var openModuleCalled = false

    private(set) var enteredNumbersCountValue: Int = 0

    func configure(with viewModel: PinCodeViewModel) {
        configureWithViewModelCalled = true
    }
    
    func setEnteredNumbersCount(count: Int) {
        setEnteredNumbersCountCalled = true
        enteredNumbersCountValue = count
    }
    
    func open(module: BaseModule) {
        openModuleCalled = true
    }
}
