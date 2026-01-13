
import Foundation

public protocol PinCodeStorageProtocol {
    func getIsBiometryEnabled() -> Bool?
    func getIncorrectPincodeAttemptsCount(flow: EnterPinCodeFlow) -> Int?
    func saveIncorrectPincodeAttemptsCount(_ value: Int, flow: EnterPinCodeFlow)
}
