
import Foundation
import LocalAuthentication

protocol BiometrySupportProtocol {
    func biometricType() -> BiometryHelper.BiometricType
    func authorizeWithBiometry(completion: @escaping (Error?) -> Void)
}

struct BiometrySupportImpl: BiometrySupportProtocol {
    
    func biometricType() -> BiometryHelper.BiometricType {
        return BiometryHelper.biometricType()
    }
    
    func authorizeWithBiometry(completion: @escaping (Error?) -> Void) {
        BiometryHelper.authorizeWithBiometry(completion: completion)
    }
}

public final class BiometryHelper {

    public enum BiometricType {
        case none
        case touch
        case face
    }
    
    public static func biometricType() -> BiometricType {
        let authContext = LAContext()
        
        if !authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            return .none
        }
        switch(authContext.biometryType) {
        case .none: return .none
        case .touchID: return .touch
        case .faceID: return .face
        default: return .none
        }
    }
    
    public static func authorizeWithBiometry(completion: @escaping (Error?) -> Void) {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Please use your Passcode"

        var authorizationError: NSError?
        let reason = "Authentication required to access the secure data"

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authorizationError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
                
                if success {
                    completion(nil)
                } else {
                    guard let error = evaluateError else { return }
                    completion(error)
                }
            }
        } else {
            guard let error = authorizationError else { return }
            completion(error)
        }
    }
    
}
