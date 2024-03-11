import XCTest
@testable import DiiaAuthorization

class AuthorizationApiTests: XCTestCase {
    
    override func tearDown() {
        AuthorizationAPI.headers = nil
        
        super.tearDown()
    }
    
    func test_getAuthUrlAuthApi() {
        // Arrange
        AuthorizationAPI.headers = [:]
        let defaultHeaders = ["authorization": "bearer \(Constants.token)"]
        
        // Act
        let api = AuthorizationAPI.getAuthUrl(target: .monobank, token: Constants.token)
        
        // Assert
        XCTAssert(api.method == .get, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v2/auth/monobank/auth-url", "Incorrect path for \(api)")
        XCTAssertNil(api.parameters, "Incorrect parameters for \(api)")
        XCTAssert(api.headers == defaultHeaders, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "monobankAuthUrl", "Incorrect analyticsName for \(api)")
    }
    
    func test_getAuthUrlv3AuthApi() {
        // Arrange
        AuthorizationAPI.headers = [:]
        let defaultHeaders = ["authorization": "bearer \(Constants.token)"]
        let defaultParameters: [String: Any] = ["processId": Constants.processId,
                                                "builtInTrueDepthCamera": true]
        
        // Act
        let api = AuthorizationAPI.getAuthUrlv3(target: .photoId,
                                                processId: Constants.processId,
                                                trueDepthAvailable: true,
                                                token: Constants.token)
        
        // Assert
        XCTAssert(api.method == .get, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v3/auth/photoid/auth-url", "Incorrect path for \(api)")
        XCTAssert(api.parameters?.keys == defaultParameters.keys, "Incorrect parameters for \(api)")
        XCTAssert(api.headers == defaultHeaders, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "photoIdAuthUrl", "Incorrect analyticsName for \(api)")
    }
    
    func test_getTokenAuthApi() {
        // Arrange
        let processId = Constants.processId
        
        // Act
        let api = AuthorizationAPI.getToken(processId: processId)
        
        // Assert
        XCTAssert(api.method == .get, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v3/auth/token", "Incorrect path for \(api)")
        XCTAssert(api.parameters?["processId"] as? String == processId, "Incorrect parameters for \(api)")
        XCTAssertNil(api.headers, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "getToken", "Incorrect analyticsName for \(api)")
    }
    
    func test_refreshTokenAuthApi() {
        // Arrange
        AuthorizationAPI.headers = [:]
        let defaultHeaders = ["authorization": "bearer \(Constants.token)"]
        
        // Act
        let api = AuthorizationAPI.refreshToken(token: Constants.token)
        
        // Assert
        XCTAssert(api.method == .post, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v2/auth/token/refresh", "Incorrect path for \(api)")
        XCTAssertNil(api.parameters, "Incorrect parameters for \(api)")
        XCTAssert(api.headers == defaultHeaders, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "refreshToken", "Incorrect analyticsName for \(api)")
    }
    
    func test_getTemporaryTokenAuthApi() {
        // Arrange & Act
        let api = AuthorizationAPI.getTemporaryToken
        
        // Assert
        XCTAssert(api.method == .get, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v1/auth/temporary/token", "Incorrect path for \(api)")
        XCTAssertNil(api.parameters, "Incorrect parameters for \(api)")
        XCTAssertNil(api.headers, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "getTemporaryToken", "Incorrect analyticsName for \(api)")
    }
    
    func test_prolongTokenAuthApi() {
        // Arrange
        AuthorizationAPI.headers = [:]
        let defaultHeaders = ["authorization": "bearer \(Constants.token)"]
        
        // Act
        let api = AuthorizationAPI.prolong(processId: Constants.processId, token: Constants.token)
        
        // Assert
        XCTAssert(api.method == .get, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v1/auth/prolong/", "Incorrect path for \(api)")
        XCTAssert(api.parameters?["processId"] as? String == Constants.processId, "Incorrect parameters for \(api)")
        XCTAssert(api.headers == defaultHeaders, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "prolongToken", "Incorrect analyticsName for \(api)")
    }
    
    func test_logoutAuthApi() {
        // Arrange
        AuthorizationAPI.headers = [:]
        let mobileID = UUID().uuidString
        let defaultHeaders = ["authorization": "bearer \(Constants.token)", "mobile_uid": mobileID]
        
        // Act
        let api = AuthorizationAPI.logout(token: Constants.token, mobileID: mobileID)
        
        // Assert
        XCTAssert(api.method == .post, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v2/auth/token/logout", "Incorrect path for \(api)")
        XCTAssertNil(api.parameters, "Incorrect parameters for \(api)")
        XCTAssert(api.headers == defaultHeaders, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "logout", "Incorrect analyticsName for \(api)")
    }
    
    func test_authMethodsAuthApi() {
        // Arrange
        AuthorizationAPI.headers = [:]
        let defaultHeaders = ["authorization": "bearer \(Constants.token)"]
        
        // Act
        let api = AuthorizationAPI.authMethods(token: Constants.token)
        
        // Assert
        XCTAssert(api.method == .get, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v1/auth/methods", "Incorrect path for \(api)")
        XCTAssertNil(api.parameters, "Incorrect parameters for \(api)")
        XCTAssert(api.headers == defaultHeaders, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "authMethods", "Incorrect analyticsName for \(api)")
    }
    
    func test_verifyAuthApi() {
        // Arrange
        AuthorizationAPI.headers = [:]
        let bankCode = "monoBankCode"
        let requestId = "requestId"
        let defaultHeaders = ["authorization": "bearer \(Constants.token)"]
        let defaultParameters: [String: String] = ["processId": Constants.processId,
                                                   "bankId": bankCode]
        
        // Act
        let api = AuthorizationAPI.verify(target: .bankId,
                                          requestId: requestId,
                                          processId: Constants.processId,
                                          bankCode: bankCode,
                                          token: Constants.token)
        
        // Assert
        XCTAssert(api.method == .get, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v1/auth/bankid/\(requestId)/verify", "Incorrect path for \(api)")
        XCTAssert(api.parameters as? [String: String] == defaultParameters, "Incorrect parameters for \(api)")
        XCTAssert(api.headers == defaultHeaders, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "verify", "Incorrect analyticsName for \(api)")
    }
    
    func test_verificationAuthMethodsAuthApi() {
        // Arrange
        AuthorizationAPI.headers = [:]
        let flowCode = "loginCode"
        let defaultHeaders = ["authorization": "bearer \(Constants.token)"]
        
        // Act
        let api = AuthorizationAPI.verificationAuthMethods(flow: VerificationFlowMock(flowCode: flowCode, isAuthorization: false),
                                                           processId: Constants.processId,
                                                           token: Constants.token)
        
        // Assert
        XCTAssert(api.method == .get, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v3/auth/\(flowCode)/methods", "Incorrect path for \(api)")
        XCTAssert(api.parameters?["processId"] as? String == Constants.processId, "Incorrect parameters for \(api)")
        XCTAssert(api.headers == defaultHeaders, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "verificationAuthMethods", "Incorrect analyticsName for \(api)")
    }
    
}

private extension AuthorizationApiTests {
    struct Constants {
        static let token = "authToken"
        static let processId = "processId"
    }
}
