
import Foundation
@testable import DiiaAuthorizationPinCode

final class BiometrySupportMock: BiometrySupportProtocol {

    private(set) var authorizeWithBiometryCalled = false
    
    var authorizeWithBiometryCompletionSubscriber: ((Error?) -> Void)?

    // MARK: - expected results
    private let type: BiometryHelper.BiometricType
    var needAsyncAction = false
    
    init(type: BiometryHelper.BiometricType?) {
        self.type = type ?? .none
    }
    
    func biometricType() -> BiometryHelper.BiometricType {
        return type
    }
    
    func authorizeWithBiometry(completion: @escaping (Error?) -> Void) {
        authorizeWithBiometryCalled = true
        
        guard needAsyncAction else {
            return
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + TimeInterval(Constants.delay), execute: {
            completion(nil)
            self.authorizeWithBiometryCompletionSubscriber?(nil)
        })
    }
}

private extension BiometrySupportMock {
    enum Constants {
        static let delay = 0.01
    }
}

