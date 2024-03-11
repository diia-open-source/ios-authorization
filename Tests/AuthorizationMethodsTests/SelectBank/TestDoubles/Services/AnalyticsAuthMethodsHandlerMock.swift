import Foundation
@testable import DiiaAuthorizationMethods

final class AnalyticsAuthMethodsHandlerMock: AnalyticsAuthMethodsHandler {
    private(set) var isTrackInitLoginByBankId: Bool = false
    
    func trackInitLoginByBankId(bankId: String) {
        isTrackInitLoginByBankId.toggle()
    }
}
