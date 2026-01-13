
import XCTest
import ReactiveKit
import DiiaCommonTypes
import DiiaCommonServices
@testable import DiiaAuthorization

final class UserAuthorizationManagerTests: XCTestCase {
    
    private var autorizationManager: AutorizationManagerMock!
    private var authorizationStorage: AuthorizationStorageMock!
    private var authRoutingHandler: AuthRoutingHandlerMock!
    private var userAuthorizationErrorRouter: UserAuthorizationErrorRouterMock!
    private var refreshTemplateActionProvider: RefreshTemplateActionProviderMock!
    private var analyticsHandler: AnalyticsAuthHandlerMock!

    override func tearDown() {
        autorizationManager = nil
        authorizationStorage = nil
        authRoutingHandler = nil
        userAuthorizationErrorRouter = nil
        refreshTemplateActionProvider = nil
        analyticsHandler = nil
        
        super.tearDown()
    }
    
    func test_autorize_successfully() {
        // Arrange
        let sut = makeSUT()
        let view = BaseMockView()
        let expectation = self.expectation(description: "autorize_successfully")
        TemplateHandler.setup(context: .init(router: authRoutingHandler,
                                             deepLink: DeepLinkManagerStub(),
                                             communicationHelper: URLOpenerStub()))
        sut.target = AuthTarget.bankId
        sut.requestId = "requestId"
        sut.processId = "processId"
        var isFailureCalled = false
        var receivedTemplateAction: AlertTemplateAction?
        sut.flow = .login(completionHandler: { _, alertAction in
            receivedTemplateAction = alertAction
            expectation.fulfill()
        })
        
        // Act
        sut.authorize(in: view, parameters: ["bankId": "privatbank"]) {
            isFailureCalled = true
        }
        authRoutingHandler.action?(view)
        
        // Assert
        XCTAssertFalse(isFailureCalled)
        XCTAssertTrue(view.isShowProgressCalled)
        XCTAssertTrue(view.isHideProgressCalled)
        XCTAssertTrue(analyticsHandler.isTrackSuccessForTarget)
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedTemplateAction, .ok)
    }
    
    func test_autorize_incompleteInput_unsuccessfully() {
        // Arrange
        let sut = makeSUT()
        let view = BaseMockView()
        sut.flow = .login(completionHandler: { _, _ in })
        var isFailureCalled = false
        
        // Assert
        sut.authorize(in: view) {
            isFailureCalled = true
        }
        
        // then
        XCTAssertTrue(isFailureCalled)
    }
    
    func test_autorize_authError_unsuccessfully() {
        // Arrange
        let sut = makeSUT(apiClient: AuthorizationApiClientErrorStub())
        let view = BaseMockView()
        sut.target = AuthTarget.bankId
        sut.requestId = "requestId"
        sut.processId = "processId"
        sut.flow = .login(completionHandler: { _, _ in })
        var isFailureCalled = false
        
        // Act
        sut.authorize(in: view) {
            isFailureCalled = true
        }
        
        // Assert
        XCTAssertTrue(isFailureCalled)
        XCTAssertTrue(analyticsHandler.isTrackFailForTarget)
        XCTAssertTrue(userAuthorizationErrorRouter.isRouteReplaceCalled)
        XCTAssertTrue(view.isShowProgressCalled)
        XCTAssertTrue(view.isHideProgressCalled)
    }
    
    func test_loginWithToken_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        sut.target = AuthTarget.bankId
        sut.requestId = "requestId"
        sut.processId = "processId"
        var isFinishCallbackCalled = false
        
        // Assert
        sut.loginWithToken(token: "token") {
            isFinishCallbackCalled.toggle()
        }
        
        // Assert
        XCTAssertNil(sut.processId)
        XCTAssertNil(sut.target)
        XCTAssertNil(sut.requestId)
        XCTAssertNotNil(sut.token)
        XCTAssertEqual(autorizationManager.authState, .userAuth)
        XCTAssertTrue(autorizationManager.isUserAuthSignalReceived)
        XCTAssertTrue(isFinishCallbackCalled)
    }
    
    func test_logout_worksCorrect() {
        // Arrange
        let tokenValue = "token"
        authorizationStorage = AuthorizationStorageMock()
        authorizationStorage.saveAuthToken(tokenValue)
        let sut = makeSUT(storage: authorizationStorage)
        
        // Act
        sut.logout()
        
        // Assert
        XCTAssertNil(authorizationStorage.getAuthToken())
        XCTAssertEqual(authorizationStorage.getLogoutToken(), tokenValue)
        XCTAssertTrue(authorizationStorage.isRemoveLogoutTokenCalled)
    }
    
    func test_refresh_successfully() {
        // Arrange
        let sut = makeSUT()
        let view = BaseMockView()
        TemplateHandler.setup(context: .init(router: authRoutingHandler,
                                             deepLink: DeepLinkManagerStub(),
                                             communicationHelper: URLOpenerStub()))
        var networkError: Error?
        
        // Act
        sut.refresh { error in
            networkError = error
        }
        authRoutingHandler.action?(view)
        refreshTemplateActionProvider.callback?()
        
        // Assert
        XCTAssertNil(networkError)
        XCTAssertNotNil(sut.token)
    }
    
    func test_refresh_unsuccessfully() {
        // Arrange
        let sut = makeSUT(apiClient: AuthorizationApiClientErrorStub())
        var networkError: Error?
        
        // Act
        sut.refresh { error in
            networkError = error
        }
        
        // Assert
        XCTAssertNotNil(networkError)
        XCTAssertNil(sut.token)
        XCTAssertTrue(autorizationManager.isLogoutCalled)
    }
    
    func test_getToken_successfully() {
        // Arrange
        let sut = makeSUT()
        let view = BaseMockView()
        sut.target = AuthTarget.bankId
        var networkError: Error?
        
        // Act
        sut.getToken(in: view, processId: "processId") { error in
            networkError = error
        }
        
        // Assert
        XCTAssertNil(networkError)
        XCTAssertTrue(view.isShowProgressCalled)
        XCTAssertTrue(view.isHideProgressCalled)
        XCTAssertNil(sut.target)
        XCTAssertNil(sut.requestId)
        XCTAssertNotNil(sut.token)
        XCTAssertEqual(autorizationManager.authState, .userAuth)
        XCTAssertTrue(autorizationManager.isUserAuthSignalReceived)
    }
    
    func test_getToken_incompleteInput_unsuccessfully() {
        // Arrange
        let sut = makeSUT()
        var networkError: Error?
        
        // Assert
        sut.getToken(processId: "processId") { error in
            networkError = error
        }
        
        // then
        XCTAssertNotNil(networkError)
    }
    
    func test_getToken_authError_unsuccessfully() {
        // Arrange
        let sut = makeSUT(apiClient: AuthorizationApiClientErrorStub())
        let view = BaseMockView()
        sut.target = AuthTarget.bankId
        var networkError: Error?
        
        // Act
        sut.getToken(in: view, processId: "processId") { error in
            networkError = error
        }
        
        // Assert
        XCTAssertNotNil(networkError)
        XCTAssertTrue(view.isShowProgressCalled)
        XCTAssertTrue(view.isHideProgressCalled)
        XCTAssertNil(sut.token)
        XCTAssertTrue(userAuthorizationErrorRouter.isRouteReplaceCalled)
    }
    
    func test_prolongToken_successfully() {
        // Arrange
        let sut = makeSUT()
        let view = BaseMockView()
        TemplateHandler.setup(context: .init(router: authRoutingHandler,
                                             deepLink: DeepLinkManagerStub(),
                                             communicationHelper: URLOpenerStub()))
        var networkError: Error?
        
        // Act
        sut.prolongToken(in: view, processId: "processId") { error in
            networkError = error
        }
        authRoutingHandler.action?(view)
        
        // Assert
        XCTAssertNil(networkError)
        XCTAssertTrue(view.isShowProgressCalled)
        XCTAssertTrue(view.isHideProgressCalled)
        XCTAssertNotNil(sut.token)
        if case .login = sut.flow {
            XCTAssert(true)
        } else {
            XCTFail("Unexpected state")
        }
    }
    
    func test_prolongToken_authError_unsuccessfully() {
        // Arrange
        let sut = makeSUT(apiClient: AuthorizationApiClientErrorStub())
        let view = BaseMockView()
        var networkError: Error?
        
        // Act
        sut.prolongToken(in: view, processId: "processId") { error in
            networkError = error
        }
        
        // Assert
        XCTAssertNotNil(networkError)
        XCTAssertTrue(view.isShowProgressCalled)
        XCTAssertTrue(view.isHideProgressCalled)
        XCTAssertNil(sut.token)
    }
}

private extension UserAuthorizationManagerTests {
    func makeSUT(storage: AuthorizationStorageMock = AuthorizationStorageMock(),
                 apiClient: AuthorizationApiClientProtocol = AuthorizationApiClientStub()) -> UserAuthorizationManager {
        authorizationStorage = storage
        autorizationManager = AutorizationManagerMock()
        authRoutingHandler = AuthRoutingHandlerMock()
        refreshTemplateActionProvider = RefreshTemplateActionProviderMock()
        userAuthorizationErrorRouter = UserAuthorizationErrorRouterMock()
        analyticsHandler = AnalyticsAuthHandlerMock()
        
        return .init(authorizationService: autorizationManager,
                     apiClient: apiClient,
                     storage: authorizationStorage,
                     authStateHandler: AuthorizationServiceStateHandlerMock(),
                     refreshTemplateActionProvider: refreshTemplateActionProvider,
                     userAuthorizationErrorRouter: userAuthorizationErrorRouter,
                     analyticsHandler: analyticsHandler)
    }
}

