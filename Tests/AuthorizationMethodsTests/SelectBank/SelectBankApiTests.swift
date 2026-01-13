
import XCTest
@testable import DiiaAuthorizationMethods

final class SelectBankApiTests: XCTestCase {
    
    override func tearDown() {
        SelectBankAPI.host = ""
        SelectBankAPI.headers = nil
        
        super.tearDown()
    }
    
    func test_getBanksApi() {
        // Arrange
        SelectBankAPI.host = "api.ua"
        SelectBankAPI.headers = ["header": "header"]
        
        // Act
        let api = SelectBankAPI.getBanks
        
        // Assert
        XCTAssert(api.method == .get, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v1/auth/banks", "Incorrect path for \(api)")
        XCTAssert(api.host == SelectBankAPI.host, "Incorrect host for \(api)")
        XCTAssert(api.timeoutInterval == Constants.timeoutInterval, "Incorrect timeoutInterval for \(api)")
        XCTAssertNil(api.parameters, "Incorrect parameters for \(api)")
        XCTAssert(api.headers == SelectBankAPI.headers, "Incorrect headers for \(api)")
        XCTAssert(api.analyticsName == "getBanksList", "Incorrect analyticsName for \(api)")
        XCTAssertNil(api.analyticsAdditionalParameters, "Incorrect analyticsAdditionalParameters for \(api)")
    }
    
    func test_getAuthUrlApi() {
        // Arrange
        SelectBankAPI.host = "api.ua"
        let singleHeaderKey = "headerKey"
        let headers = [singleHeaderKey: "headerValue"]
        SelectBankAPI.headers = headers
        let target = "monobank"
        let processId = "processId"
        let defaultParameters: [String: String] = ["processId": processId,
                                                   "bankId": target]
        
        // Act
        let api = SelectBankAPI.getAuthUrl(target: target, processId: processId, token: "token")
        
        // Assert
        XCTAssert(api.method == .get, "Incorrect HTTP method for \(api)")
        XCTAssert(api.path == "v3/auth/bankid/auth-url", "Incorrect path for \(api)")
        XCTAssert(api.host == SelectBankAPI.host, "Incorrect host for \(api)")
        XCTAssert(api.timeoutInterval == Constants.timeoutInterval, "Incorrect timeoutInterval for \(api)")
        XCTAssert(api.parameters as? [String: String] == defaultParameters, "Incorrect parameters for \(api)")
        XCTAssertEqual(api.headers?.count, headers.count + 1)
        XCTAssertNotNil(api.headers?[singleHeaderKey])
        XCTAssert(api.analyticsName == "getBankIdAuthUrl", "Incorrect analyticsName for \(api)")
        XCTAssert(api.analyticsAdditionalParameters == "BANK_ID: \(target)", "Incorrect analyticsAdditionalParameters for \(api)")
    }
}

private extension SelectBankApiTests {
    struct Constants {
        static let timeoutInterval: TimeInterval = 30
    }
}
