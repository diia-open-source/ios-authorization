import Foundation

public protocol AuthorizationStorageProtocol {
    func getMobileUID() -> String

    func getHashedPincode() -> String?
    func saveHashedPincode(_ value: String?)
    
    func getAuthToken() -> String?
    func saveAuthToken(_ value: String?)
    
    func getLogoutToken() -> String?
    func saveLogoutToken(_ value: String)
    func removeLogoutToken()
    
    func getServiceToken() -> String?
    func saveServiceToken(_ value: String?)
  
    func getServiceLogoutToken() -> String?
    func saveServiceLogoutToken(_ value: String)
    func removeServiceLogoutToken()
    
    func getLastPincodeDate() -> Date?
    func saveLastPincodeDate(_ value: Date)
    func removeLastPincodeDate()
}
