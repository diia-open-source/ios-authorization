import XCTest
@testable import DiiaAuthorizationPinCode

final class BiometryHelperTests: XCTestCase {
    
    private var authorizationError: Error?
    private var isCompletionCalled = false

    func test_biometricTypeIsNoneForSimulator() {
        // Arrange
        let sut = BiometryHelper.self
        
    #if targetEnvironment(simulator)
        // Act
        let type: BiometryHelper.BiometricType = sut.biometricType()

        // Assert
        XCTAssertEqual(type, .none)
    #else
        XCTSkipIf("This test is written for simulator only")
    #endif
    }
    
    func test_authorizeWithBiometryFailsForSimulator() {
        // Arrange
        let sut = BiometryHelper.self
        
    #if targetEnvironment(simulator)
        // Act
        sut.authorizeWithBiometry { error in
            self.authorizationError = error
            self.isCompletionCalled = true
        }

        // Assert
        XCTAssertNotNil(authorizationError)
        XCTAssertTrue(isCompletionCalled)
        
    #else
        XCTSkipIf("This test is written for simulator only")
    #endif
    }
}
