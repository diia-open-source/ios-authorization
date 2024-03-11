import Foundation
import DiiaAuthorizationPinCode

final class PinCodeStorageMock: PinCodeStorageProtocol {
    
    private(set) var getIsBiometryEnabledCalled = false
    private(set) var getIncorrectPincodeAttemptsCountCalled = false
    private(set) var saveIncorrectPincodeAttemptsCountCalled = false
    
    private(set) var incorrectPincodeAttemptsCounter: Int = 0
    private(set) var incorrectPincodeAttemptsValue: Int = 0
    var isBiometryEnabledExpectedResult = false

    func getIsBiometryEnabled() -> Bool? {
        getIsBiometryEnabledCalled = true
        return isBiometryEnabledExpectedResult
    }
    
    func getIncorrectPincodeAttemptsCount(flow: EnterPinCodeFlow) -> Int? {
        getIncorrectPincodeAttemptsCountCalled = true
        return incorrectPincodeAttemptsValue
    }
    
    func saveIncorrectPincodeAttemptsCount(_ value: Int, flow: EnterPinCodeFlow) {
        saveIncorrectPincodeAttemptsCountCalled = true
        incorrectPincodeAttemptsValue = value
        incorrectPincodeAttemptsCounter += 1
    }
    
}
