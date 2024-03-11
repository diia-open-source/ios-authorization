import Foundation

public protocol VerificationFlowProtocol {
    var flowCode: String { get }
    var authFlow: AuthFlow { get }
    var isAuthorization: Bool { get }
}
