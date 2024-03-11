import XCTest
@testable import DiiaAuthorizationMethods

final class BankIdAuthPresenterTests: XCTestCase {
    private var view: BankIdAuthMockView!
    private var authorizationService: AutorizationManagerMock!
    
    override func tearDown() {
        view = nil
        authorizationService = nil
        AppConstants.handledRedirectionHosts = []
        
        super.tearDown()
    }
    
    func test_configureView() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()
        
        // Assert
        XCTAssertTrue(view.isLoadCalled)
    }
    
    func test_handleUnsecureContent_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.handleUnsecureContent()
        
        // Assert
        XCTAssertTrue(view.isShowInsecureContentInfoCalled)
    }
    
    func test_handle_successfully() {
        // Arrange
        let sut = makeSUT()
        let code = "authCode"
        let authUrl = URL(string: "https://api.ua/callback?code=\(code)")!
        AppConstants.handledRedirectionHosts = ["api.ua"]
        
        // Act
        let result = sut.handle(url: authUrl)
        
        // Assert
        XCTAssertTrue(result)
        XCTAssertEqual(authorizationService.getRequestId(), code)
        XCTAssertEqual(authorizationService.authTarget, .bankId)
        XCTAssertTrue(authorizationService.isAuthorizeCalled)
    }
    
    func test_handle_successfully_withAuthFailure() {
        // Arrange
        let sut = makeSUT()
        let code = "authCode"
        let authUrl = URL(string: "https://api.ua/callback?code=\(code)")!
        AppConstants.handledRedirectionHosts = ["api.ua"]
        
        // Act
        let result = sut.handle(url: authUrl)
        authorizationService.failureAuthorizeCallback?()
        
        // Assert
        XCTAssertTrue(result)
        XCTAssertEqual(authorizationService.getRequestId(), code)
        XCTAssertEqual(authorizationService.authTarget, .bankId)
        XCTAssertTrue(authorizationService.isAuthorizeCalled)
        XCTAssertTrue(view.isCloseToParentViewCalled)
    }
    
    func test_handle_unsuccessfully() {
        // Arrange
        let sut = makeSUT()
        let authUrl = URL(string: "https://test.com")!
        AppConstants.handledRedirectionHosts = ["test.com"]
        
        // Act
        let result = sut.handle(url: authUrl)
        
        // Assert
        XCTAssertFalse(result)
    } 
}

private extension BankIdAuthPresenterTests {
    func makeSUT() -> BankIdAuthPresenter {
        view = BankIdAuthMockView()
        authorizationService = AutorizationManagerMock()
        
        return BankIdAuthPresenter(view: view,
                                   bankId: "id1",
                                   authUrl: "authUrl",
                                   parentView: BaseViewStub(),
                                   authService: authorizationService)
    }
}
