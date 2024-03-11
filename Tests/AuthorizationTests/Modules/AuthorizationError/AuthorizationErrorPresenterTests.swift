import XCTest
@testable import DiiaAuthorization

final class AuthorizationErrorPresenterTests: XCTestCase {
    
    private var view: AuthorizationErrorMockView!
    
    override func tearDown() {
        view = nil
        
        super.tearDown()
    }
    
    
    func test_configureView_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()
        
        // Assert
        XCTAssertTrue(view.isSetMessageCalled)
        XCTAssertTrue(view.isSetMainActionTitleCalled)
        XCTAssertTrue(view.isSetAlternativeActionTitleCalled)
    }
    
    func test_userAuth_onMainAction() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.onMainAction()
        
        // Assert
        XCTAssertTrue(view.isCloseModuleCalled)
    }
    
    func test_userAuth_onAlternativeAction() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.onAlternativeAction()
        
        // Assert
        XCTAssertTrue(view.isShowSuccessMessageCalled)
    }
    
    func test_serviceAuth_onMainAction() {
        // Arrange
        let sut = makeSUT(errorInfo: .onServiceAuth)
        
        // Act
        sut.onMainAction()
        
        // Assert
        XCTAssertTrue(view.isShowLogoutAlertCalled)
    }
    
    func test_serviceAuth_onAlternativeAction() {
        // Arrange
        let sut = makeSUT(errorInfo: .onServiceAuth)
        
        // Act
        sut.onAlternativeAction()
        
        // Assert
        XCTAssertTrue(view.isCloseModuleCalled)
    }
    
    func test_onClickCopy() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.onClickCopy()
        
        // Assert
        XCTAssertTrue(view.isShowSuccessMessageCalled)
    }
    
    func test_logout() {
        // Arrange
        var isLogoutCallbackCalled: Bool = false
        let sut = makeSUT {
            isLogoutCallbackCalled.toggle()
        }
        
        // Act
        sut.logout()
        
        // Assert
        XCTAssertTrue(isLogoutCallbackCalled)
    }
    
}

private extension AuthorizationErrorPresenterTests {
    func makeSUT(errorInfo: AuthErrorViewModel = .userAuth(with: nil), logout: @escaping () -> Void = {}) -> AuthorizationErrorPresenter {
        view = AuthorizationErrorMockView()
        return .init(view: view,
                     errorInfo: errorInfo,
                     mobileUID: { return UUID().uuidString },
                     logout: logout)
    }
}
