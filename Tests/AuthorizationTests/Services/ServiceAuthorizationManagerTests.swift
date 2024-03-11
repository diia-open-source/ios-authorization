import XCTest
import ReactiveKit
@testable import DiiaAuthorization

final class ServiceAuthorizationManagerTests: XCTestCase {
    
    private var autorizationManager: AutorizationManagerMock!
    private var authorizationStorage: AuthorizationStorageMock!
    private var userAuthorizationErrorRouter: UserAuthorizationErrorRouterMock!
    
    override func tearDown() {
        autorizationManager = nil
        authorizationStorage = nil
        userAuthorizationErrorRouter = nil
        
        super.tearDown()
    }
    
    func test_serviceLogin_successfully() {
        // Arrange
        let sut = makeSUT()
        let view = BaseMockView()
        
        // Act
        sut.serviceLogin(in: view, offerId: "offerId")
        
        // Assert
        XCTAssertNotNil(sut.serviceToken)
        XCTAssertEqual(autorizationManager.authState, .serviceAuth)
        XCTAssertTrue(view.isBaseModuleStubCalled)
    }
    
    func test_serviceLogin_authError_unsuccessfully() {
        // Arrange
        let sut = makeSUT(apiClient: ServiceEntranceApiClientErrorStub())
        let view = BaseMockView()
        
        // Act
        sut.serviceLogin(in: view, offerId: "offerId")
        
        // Assert
        XCTAssertTrue(userAuthorizationErrorRouter.isRouteCalled)
    }
    
    func test_logout_worksCorrect() {
        // Arrange
        let tokenValue = "serviceToken"
        authorizationStorage = AuthorizationStorageMock()
        authorizationStorage.saveServiceToken(tokenValue)
        let sut = makeSUT(storage: authorizationStorage)
        
        // Act
        sut.logout()
        
        // Assert
        XCTAssertNil(authorizationStorage.getServiceToken())
        XCTAssertEqual(authorizationStorage.getServiceLogoutToken(), tokenValue)
        XCTAssertTrue(authorizationStorage.isRemoveServiceLogoutTokenCalled)
    }
    
    func test_refresh_successfully() {
        // Arrange
        let sut = makeSUT()
        var networkError: Error?
        
        // Act
        sut.refresh { error in
            networkError = error
        }
        
        // Assert
        XCTAssertNil(networkError)
        XCTAssertNotNil(sut.serviceToken)
    }
    
    func test_refresh_unsuccessfully() {
        // Arrange
        let sut = makeSUT(apiClient: ServiceEntranceApiClientErrorStub())
        var networkError: Error?
        
        // Act
        sut.refresh { error in
            networkError = error
        }
        
        // Assert
        XCTAssertNotNil(networkError)
        XCTAssertNil(sut.serviceToken)
        XCTAssertTrue(autorizationManager.isLogoutCalled)
    }
    
}

private extension ServiceAuthorizationManagerTests {
    func makeSUT(storage: AuthorizationStorageMock = AuthorizationStorageMock(),
                 apiClient: ServiceEntranceApiClientProtocol = ServiceEntranceApiClientStub()) -> ServiceAuthorizationManager {
        authorizationStorage = storage
        autorizationManager = AutorizationManagerMock()
        userAuthorizationErrorRouter = UserAuthorizationErrorRouterMock()
        
        return .init(authorizationService: autorizationManager,
                     storage: authorizationStorage,
                     serviceEntranceClient: apiClient,
                     mobileUID: { return UUID().uuidString },
                     authSuccessModule: BaseModuleStub(),
                     userAuthorizationErrorRouter: userAuthorizationErrorRouter)
    }
}
