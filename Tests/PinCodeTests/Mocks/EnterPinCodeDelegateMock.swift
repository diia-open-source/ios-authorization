
import Foundation
import DiiaAuthorizationPinCode
import DiiaMVPModule
 
final class EnterPinCodeDelegateMock: EnterPinCodeDelegate {
    
    private(set) var onForgotPincodeCalled = false
    private(set) var didAllAttemptsExhaustedCalled = false
    private(set) var checkPincodeCalled = false
    private(set) var didCorrectPincodeEnteredCalled = false
    
    // MARK: - expected results
    var checkPincodeExpectedResult = false

    // MARK: - EnterPinCodeDelegate
    func onForgotPincode(in view: BaseView) {
        onForgotPincodeCalled = true
    }
    
    func didAllAttemptsExhausted(in view: BaseView) {
        didAllAttemptsExhaustedCalled = true
    }
    
    func checkPincode(_ pincode: [Int]) -> Bool {
        checkPincodeCalled = true
        return checkPincodeExpectedResult
    }
    
    func didCorrectPincodeEntered(pincode: String) {
        didCorrectPincodeEnteredCalled = true
    }
}
