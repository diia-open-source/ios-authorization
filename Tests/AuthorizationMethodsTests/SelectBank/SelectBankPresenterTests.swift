import XCTest
import DiiaCommonTypes
import DiiaCommonServices
import DiiaAuthorization
@testable import DiiaAuthorizationMethods

final class SelectBankPresenterTests: XCTestCase {
    private var view: SelectBankMockView!
    private var authorizationService: AutorizationManagerMock!
    private var authErrorRouter: AuthErrorRouterMock!
    private var analyticsHandler: AnalyticsAuthMethodsHandlerMock!

    func test_configureView_successfully() {
        // Arrange
        let sut = makeSUT()
        let expectedBanksValue = 2
        
        // Act
        sut.configureView()
        
        // Assert
        XCTAssertFalse(view.isShowStubMessageCalled)
        XCTAssertEqual(view.banksItems?.count, expectedBanksValue)
        XCTAssertEqual(view.setLoadingStateCallCount, 2)
    }
    
    func test_configureView_unsuccessfully() {
        // Arrange
        let sut = makeSUT(apiClient: SelectBankApiClientErrorStub())
        let expectedBanksValue = 0
        let expectation = self.expectation(description: "configureView unsuccessfully")
        var isGeneralErrorShowing = false
        view.onGeneralErrorShow = { isGeneralErrorVisible in
            isGeneralErrorShowing = isGeneralErrorVisible
            expectation.fulfill()
        }
        
        // Act
        sut.configureView()
        
        // Assert
        XCTAssertEqual(view.banksItems?.count ?? 0, expectedBanksValue)
        XCTAssertEqual(view.setLoadingStateCallCount, 2)
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(isGeneralErrorShowing)
    }
    
    func test_selectItem_successfully_authUrl() {
        // Arrange
        let sut = makeSUT()
        authorizationService.setProcessId(processId: "processId")
        
        // Act
        sut.configureView()
        view.banksItems?.first?.onClick?()
        
        // Assert
        XCTAssertTrue(view.isBankIdAuthModuleCalled)
        XCTAssertEqual(view.setLoadingStateCallCount, 2)
        XCTAssertTrue(analyticsHandler.isTrackInitLoginByBankId)
    }
    
    func test_selectItem_successfully_alertTemplate() {
        // Arrange
        let apiClient = SelectBankApiClientStub(isAuthUrlExist: false)
        let authRoutingHandler = AuthRoutingHandlerMock()
        let expectation = self.expectation(description: "selectItem successfully_alertTemplate")
        
        var receivedAction: AlertTemplateAction?
        let sut = makeSUT(apiClient: apiClient, onClose: { action in
            receivedAction = action
            expectation.fulfill()
        })
        authorizationService.setProcessId(processId: "processId")
        TemplateHandler.setup(context: .init(router: authRoutingHandler,
                                             deepLink: DeepLinkManagerStub(),
                                             communicationHelper: URLOpenerStub()))
        
        // Act
        sut.configureView()
        view.banksItems?.first?.onClick?()
        authRoutingHandler.action?(view)
        
        // Assert
        XCTAssertTrue(view.isShowProgressCalled)
        XCTAssertTrue(view.isHideProgressCalled)
        XCTAssertTrue(analyticsHandler.isTrackInitLoginByBankId)
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedAction)
    }
    
    func test_selectItem_unsuccessfully() {
        // Arrange
        let sut = makeSUT(apiClient: SelectBankApiClientErrorStub(isGetAuthUrlUnderTest: true))
        authorizationService.setProcessId(processId: "processId")
        
        // Act
        sut.configureView()
        view.banksItems?.first?.onClick?()
        
        // Assert
        XCTAssertEqual(view.setLoadingStateCallCount, 2)
        XCTAssertTrue(authErrorRouter.isRouteCalled)
        XCTAssertTrue(analyticsHandler.isTrackInitLoginByBankId)
    }
}

private extension SelectBankPresenterTests {
    func makeSUT(apiClient: SelectBankApiClientProtocol = SelectBankApiClientStub(),
                 onClose: @escaping (AlertTemplateAction) -> Void = { _ in }) -> SelectBankPresenter {
        view = SelectBankMockView()
        authorizationService = AutorizationManagerMock()
        authErrorRouter = AuthErrorRouterMock()
        analyticsHandler = AnalyticsAuthMethodsHandlerMock()
        
        return .init(view: view,
                     selectBankAPIClient: apiClient,
                     authErrorRouter: authErrorRouter,
                     authService: authorizationService,
                     analyticsHandler: analyticsHandler,
                     onClose: onClose)
    }
}

