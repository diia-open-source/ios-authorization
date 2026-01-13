
import XCTest
@testable import DiiaAuthorization

final class ServiceEntranceApiTests: XCTestCase {
    
    override func tearDown() {
        ServiceEntranceAPI.headers = nil
        
        super.tearDown()
    }
    
    func test_loginServiceEntranceApi() {
        // Arrange
        ServiceEntranceAPI.headers = ["header": "header"]
        let offerId = "offerId"
        
        // Act
        let api = ServiceEntranceAPI.login(offerId: offerId)
        
        // Assert
        XCTAssert(api.method == .get, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v1/auth/acquirer/branch/offer/\(offerId)/token", "Incorrect path for \(api)")
        XCTAssertNil(api.parameters, "Incorrect parameters for \(api)")
        XCTAssert(api.headers == ServiceEntranceAPI.headers, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "serviceLogin", "Incorrect analyticsName for \(api)")
    }
    
    func test_refreshTokenServiceEntranceApi() {
        // Arrange
        ServiceEntranceAPI.headers = [:]
        let defaultHeaders = ["authorization": "bearer \(Constants.token)"]
        
        // Act
        let api = ServiceEntranceAPI.refreshToken(token: Constants.token)
        
        // Assert
        XCTAssert(api.method == .post, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v1/auth/acquirer/branch/offer/token/refresh", "Incorrect path for \(api)")
        XCTAssertNil(api.parameters, "Incorrect parameters for \(api)")
        XCTAssert(api.headers == defaultHeaders, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "serviceRefreshToken", "Incorrect analyticsName for \(api)")
    }
    
    func test_logoutServiceEntranceApi() {
        // Arrange
        ServiceEntranceAPI.headers = [:]
        let mobileID = UUID().uuidString
        let defaultHeaders = ["authorization": "bearer \(Constants.token)", "mobile_uid": mobileID]
        
        // Act
        let api = ServiceEntranceAPI.logout(token: Constants.token, mobileUid: mobileID)
        
        // Assert
        XCTAssert(api.method == .post, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v1/auth/acquirer/branch/offer/token/logout", "Incorrect path for \(api)")
        XCTAssertNil(api.parameters, "Incorrect parameters for \(api)")
        XCTAssert(api.headers == defaultHeaders, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "serviceLogout", "Incorrect analyticsName for \(api)")
    }
}

private extension ServiceEntranceApiTests {
    struct Constants {
        static let token = "serviceToken"
    }
}
