import Foundation

public protocol AnalyticsAuthMethodsHandler {
    func trackInitLoginByBankId(bankId: String)
}
