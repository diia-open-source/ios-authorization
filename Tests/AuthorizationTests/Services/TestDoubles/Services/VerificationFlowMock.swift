
import Foundation
import DiiaAuthorization

final class VerificationFlowMock: VerificationFlowProtocol {
    let flowCode: String
    let authFlow: AuthFlow
    let isAuthorization: Bool
    
    init(flowCode: String = "",
         authFlow: AuthFlow = .login,
         isAuthorization: Bool = true) {
        self.flowCode = flowCode
        self.authFlow = authFlow
        self.isAuthorization = isAuthorization
    }
}
