import Foundation
import DiiaAuthorization

final class AuthorizationServiceStateHandlerMock : AuthorizationServiceStateHandler {
    
    private(set) var isLoginDidFinishCalled = false
    private(set) var isLogoutDidFinishCalled = false
    
    func onLoginDidFinish() {
        isLoginDidFinishCalled = true
    }
    
    func onLogoutDidFinish() {
        isLogoutDidFinishCalled = true
    }
}
