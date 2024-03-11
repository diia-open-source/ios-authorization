import Foundation
@testable import DiiaAuthorization

class AuthorizationStorageMock: AuthorizationStorageProtocol {
    private(set) var isRemoveAllDataCalled: Bool = false
    private(set) var isRemoveLogoutTokenCalled: Bool = false
    private(set) var isRemoveServiceLogoutTokenCalled: Bool = false
    
    private var authToken: String?
    private var serviceToken: String?
    private var logoutToken: String?
    private var serviceLogoutToken: String?
    private var hashedPincode: String?
    private var lastPincodeDate: Date?
    
    func getMobileUID() -> String {
        return UUID().uuidString
    }
    
    func getHashedPincode() -> String? {
        return hashedPincode
    }
    
    func saveHashedPincode(_ value: String?) {
        hashedPincode = value
    }
    
    func getAuthToken() -> String? {
        return authToken
    }
    
    func saveAuthToken(_ value: String?) {
        authToken = value
    }
    
    func getLogoutToken() -> String? {
        return logoutToken
    }
    
    func saveLogoutToken(_ value: String) {
        logoutToken = value
    }
    
    func removeLogoutToken() {
        isRemoveLogoutTokenCalled = true
    }
    
    func getServiceToken() -> String? {
        return serviceToken
    }
    
    func saveServiceToken(_ value: String?) {
        serviceToken = value
    }
    
    func getServiceLogoutToken() -> String? {
        return serviceLogoutToken
    }
    
    func saveServiceLogoutToken(_ value: String) {
        serviceLogoutToken = value
    }
    
    func removeServiceLogoutToken() {
        isRemoveServiceLogoutTokenCalled = true
    }
    
    func getLastPincodeDate() -> Date? {
        return lastPincodeDate
    }
    
    func saveLastPincodeDate(_ value: Date) {
        lastPincodeDate = value
    }
    
    func removeLastPincodeDate() {
        lastPincodeDate = nil
    }
    
    func removeAllData() {
        isRemoveAllDataCalled = true
    }
}
