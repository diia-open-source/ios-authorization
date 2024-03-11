import Foundation
import DiiaNetwork
@testable import DiiaAuthorization

final class AnalyticsAuthHandlerMock: AnalyticsAuthorizationHandler {
    private(set) var isTrackSuccessForTarget: Bool = false
    private(set) var isTrackFailForTarget: Bool = false
    
    func trackSuccessForTarget(target: AuthTarget) {
        isTrackSuccessForTarget.toggle()
    }
    
    func trackFailForTarget(target: AuthTarget, error: NetworkError) {
        isTrackFailForTarget.toggle()
    }
}
