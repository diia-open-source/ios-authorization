import XCTest
@testable import DiiaAuthorization

final class AuthorizationServiceTests: XCTestCase {
    private var userAuthManager: UserAuthorizationManagerMock!
    private var serviceAuthManager: ServiceAuthorizationManagerMock!
    
    private var authorizationStorage: AuthorizationStorageMock!
    
    private var authStateHandler: AuthorizationServiceStateHandlerMock!

    override func tearDown() {
        userAuthManager = nil
        serviceAuthManager = nil
        authorizationStorage = nil
        
        super.tearDown()
    }
    
    func test_tokenExist() {
        // Arrange
        let expectToken = "token"
        authorizationStorage = AuthorizationStorageMock()
        authorizationStorage.saveAuthToken(expectToken)
        let sut = makeSUT(storage: authorizationStorage)
        
        // Act
        let token = sut.token
        
        // Assert
        XCTAssertEqual(token, expectToken)
    }
    
    func test_tokenDoesntExist() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        let token = sut.token
        
        // Assert
        XCTAssertNil(token)
    }

    func test_authorize() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.authorize(in: BaseMockView())
        
        // Assert
        XCTAssertTrue(userAuthManager.isAuthorizeCalled)
    }
    
    func test_userLogin() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.userLogin(in: BaseMockView(), processId: "processId", completion: nil)
        
        // Assert
        XCTAssertTrue(userAuthManager.isGetTokenCalled)
    }
    
    func test_serviceLogin() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.serviceLogin(in: BaseMockView(), offerId: "offerId")
        
        // Assert
        XCTAssertTrue(serviceAuthManager.isServiceLoginCalled)
    }
    
    func test_loginWithToken() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.loginWithToken(token: "token", completion: nil)
        
        // Assert
        XCTAssertTrue(userAuthManager.isLoginWithTokenCalled)
    }
    
    func test_userTokenRefresh() {
        // Arrange
        let sut = makeSUT()
        sut.authState = .userAuth
        
        // Act
        sut.refresh()
        
        // Assert
        XCTAssertTrue(userAuthManager.isRefreshCalled)
    }
    
    func test_serviceTokenRefresh() {
        // Arrange
        let sut = makeSUT()
        sut.authState = .serviceAuth
        
        // Act
        sut.refresh()
        
        // Assert
        XCTAssertTrue(serviceAuthManager.isRefreshCalled)
    }
    
    func test_tokenRefresh_notAuthorized() {
        // Arrange
        let sut = makeSUT()
        var refreshError: Error?
        let completion: ((Error?) -> Void)? = { error in
            refreshError = error
        }
        
        // Act
        sut.refresh(completion: completion)
        
        // Assert
        XCTAssertNil(refreshError)
    }
    
    func test_prolongToken() {
        // Arrange
        let sut = makeSUT()
        sut.authState = .userAuth
        
        // Act
        sut.prolong(in: BaseMockView(), processId: "processId", completion: nil)
        
        // Assert
        XCTAssertTrue(userAuthManager.isProlongTokenCalled)
    }
    
    func test_userLogout() {
        // Arrange
        let sut = makeSUT()
        sut.authState = .userAuth
        
        // Act
        sut.logout()
        
        // Assert
        XCTAssertNil(authorizationStorage.getHashedPincode())
        XCTAssertEqual(sut.authState, .notAuthorized)
        XCTAssertTrue(authStateHandler.isLogoutDidFinishCalled)
        XCTAssertTrue(userAuthManager.isLogoutCalled)
    }
    
    func test_serviceLogout() {
        // Arrange
        let sut = makeSUT()
        sut.authState = .serviceAuth
        
        // Act
        sut.logout()
        
        // Assert
        XCTAssertNil(authorizationStorage.getHashedPincode())
        XCTAssertEqual(sut.authState, .notAuthorized)
        XCTAssertTrue(authStateHandler.isLogoutDidFinishCalled)
        XCTAssertTrue(serviceAuthManager.isLogoutCalled)
    }
    
    func test_isUserAuthorizeTrue() {
        // Arrange
        authorizationStorage = AuthorizationStorageMock()
        authorizationStorage.saveAuthToken("token")
        let sut = makeSUT(storage: authorizationStorage)
        
        // Act
        let isAuthorize = sut.isAuthorized()
        
        // Assert
        XCTAssertTrue(isAuthorize)
        XCTAssertEqual(sut.authState, .userAuth)
    }
    
    func test_isServiceAuthorizeTrue() {
        // Arrange
        authorizationStorage = AuthorizationStorageMock()
        authorizationStorage.saveServiceToken("token")
        let sut = makeSUT(storage: authorizationStorage)
        
        // Act
        let isAuthorize = sut.isAuthorized()
        
        // Assert
        XCTAssertTrue(isAuthorize)
        XCTAssertEqual(sut.authState, .serviceAuth)
    }
    
    func test_isAuthorizeFalse() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        let isAuthorize = sut.isAuthorized()
        
        // Assert
        XCTAssertFalse(isAuthorize)
    }
    
    func test_setTarget() {
        // Arrange
        let expectTarget = AuthTarget.bankId
        let sut = makeSUT()
        
        // Act
        sut.setTarget(target: expectTarget)
        
        // Assert
        XCTAssertEqual(userAuthManager.target, expectTarget)
    }
    
    func test_setProcessId() {
        // Arrange
        let expectProcessId = "processId"
        let sut = makeSUT()
        
        // Act
        sut.setProcessId(processId: expectProcessId)
        
        // Assert
        XCTAssertEqual(userAuthManager.processId, expectProcessId)
    }
    
    func test_setRequestId() {
        // Arrange
        let expectRequestId = "RequestId"
        let sut = makeSUT()
        
        // Act
        sut.setRequestId(requestId: expectRequestId)
        
        // Assert
        XCTAssertEqual(userAuthManager.requestId, expectRequestId)
    }
    
    func test_setUserAuthFlow() {
        // Arrange
        var isCompletionFlowCalled = false
        let expectUserFlow: UserAuthorizationFlow = .login(completionHandler: { _, _  in
            isCompletionFlowCalled = true
        })
        let sut = makeSUT()
        
        // Act
        sut.setUserAuthorizationFlow(expectUserFlow)
        userAuthManager.flow.onCompletion()
        
        // Assert
        XCTAssertTrue(isCompletionFlowCalled)
    }
    
    func test_getRequestId() {
        // Arrange
        let expectRequestId = "RequestId"
        let sut = makeSUT()
        userAuthManager.requestId = expectRequestId
        
        // Act
        let requestId = sut.getRequestId()
        
        // Assert
        XCTAssertEqual(requestId, expectRequestId)
    }
    
    func test_getProcessId() {
        // Arrange
        let expectProcessId = "processId"
        let sut = makeSUT()
        userAuthManager.processId = expectProcessId
        
        // Act
        let processId = sut.getProcessId()
        
        // Assert
        XCTAssertEqual(processId, expectProcessId)
    }
    
    func test_setPincode() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.setPincode(pincode: [1, 2, 3, 4])
        
        // Assert
        XCTAssertTrue(sut.havePincode())
        XCTAssertNotNil(authorizationStorage.getHashedPincode())
    }
    
    func test_checkPincode_successfully() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.setPincode(pincode: [1, 2, 3, 4])
        let isCorrectPincode = sut.checkPincode(pincode: [1, 2, 3, 4])
        
        // Assert
        XCTAssertTrue(isCorrectPincode)
    }
    
    func test_checkPincode_unsuccessfully() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.setPincode(pincode: [4, 3, 2, 1])
        let isCorrectPincode = sut.checkPincode(pincode: [1, 2, 3, 4])
        
        // Assert
        XCTAssertFalse(isCorrectPincode)
    }
    
    func test_setLastPincodeDate_updateDate() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.setPincode(pincode: [1, 2, 3, 4])
        sut.setLastPincodeDate(date: Date())
        
        // Assert
        XCTAssertNotNil(authorizationStorage.getHashedPincode())
        XCTAssertNotNil(authorizationStorage.getLastPincodeDate())
    }
    
    func test_setLastPincodeDate_removeDate() {
        // Arrange
        authorizationStorage = AuthorizationStorageMock()
        authorizationStorage.saveLastPincodeDate(Date())
        let sut = makeSUT(storage: authorizationStorage)
        
        // Act & Assert
        XCTAssertNil(authorizationStorage.getHashedPincode())
        XCTAssertNotNil(authorizationStorage.getLastPincodeDate())
        sut.setLastPincodeDate(date: Date())
        
        // Final Assert
        XCTAssertNil(authorizationStorage.getHashedPincode())
        XCTAssertNil(authorizationStorage.getLastPincodeDate())
    }
    
    func test_doesNeedPincode_whenNotAuthorized() {
        // Arrange
        let sut = makeSUT()
        
        // Act & Assert
        XCTAssertFalse(sut.doesNeedPincode())
    }
    
    func test_doesNeedPincode_whenAuthorized_expiredPincodeTime() {
        // Arrange
        let sut = makeSUT()
        sut.authState = .userAuth
        
        // Act
        sut.setPincode(pincode: [1, 2, 3, 4])
        sut.setLastPincodeDate(date: Date(timeIntervalSinceNow: -500))
        let result = sut.doesNeedPincode()
        
        // Assert
        XCTAssertTrue(result)
    }
    
    func test_doesNeedPincode_whenAuthorized_withinPincodeTime() {
        // Arrange
        let sut = makeSUT()
        sut.authState = .userAuth
        
        // Act
        sut.setPincode(pincode: [1, 2, 3, 4])
        sut.setLastPincodeDate(date: Date(timeIntervalSinceNow: -30))
        let result = sut.doesNeedPincode()
        
        // Assert
        XCTAssertFalse(result)
    }
    
    func test_doesNeedPincode_whenNoPincodeDateIsSet() {
        // Arrange
        let sut = makeSUT()
        sut.authState = .userAuth
        
        // Act
        sut.setPincode(pincode: [1, 2, 3, 4])
        let result = sut.doesNeedPincode()
        
        // Assert
        XCTAssertTrue(result)
    }
}

private extension AuthorizationServiceTests {
    func makeSUT(storage: AuthorizationStorageMock = AuthorizationStorageMock()) -> AuthorizationService {
        authorizationStorage = storage
        userAuthManager = UserAuthorizationManagerMock(storage: authorizationStorage)
        serviceAuthManager = ServiceAuthorizationManagerMock(storage: authorizationStorage)
        authStateHandler = AuthorizationServiceStateHandlerMock()
        
        let service = AuthorizationService(context: .init(network: .init(session: .default, host: "", headers: [:]),
                                                          storage: authorizationStorage,
                                                          serviceAuthSuccessModule: nil,
                                                          refreshTemplateActionProvider: RefreshTemplateActionProviderMock(),
                                                          authStateHandler: authStateHandler,
                                                          userAuthorizationErrorRouter: UserAuthorizationErrorRouterMock(),
                                                          analyticsHandler: AnalyticsAuthHandlerMock()),
                                           userAuthManager: userAuthManager,
                                           serviceAuthManager: serviceAuthManager)
        return service
    }
}
