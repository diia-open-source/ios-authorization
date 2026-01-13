
import XCTest
import DiiaCommonTypes
@testable import DiiaAuthorization

final class AuthMethodsActionSheetPresenterTests: XCTestCase {
    
    private var view: AuthMethodsActionSheetMockView!
    private var authorizationService: AutorizationManagerMock!
    
    override func tearDown() {
        view = nil
        authorizationService = nil
        
        super.tearDown()
    }
    
    func test_configureView_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()
        
        // Assert
        XCTAssertTrue(view.isSetTitleCalled)
        XCTAssertTrue(view.isConfigureCalled)
        XCTAssertTrue(view.isSetSeparatorColorCalled)
    }
    
    func test_identify_worksCorrect() {
        // Arrange
        var receivedAuthMethod: AuthMethod?
        let sut = makeSUT(identifyCallback: { method in
            receivedAuthMethod = method
        })
        
        // Act
        sut.identify(with: .bankId)
        
        // Assert
        XCTAssertTrue(view.isCloseCalled)
        XCTAssertEqual(receivedAuthMethod, .bankId)
    }
    
    func test_onCloseTapped_worksCorrect() {
        // Arrange
        var receivedAction: AlertTemplateAction?
        let sut = makeSUT(onClose: { action in
            receivedAction = action
        })
        authorizationService.setProcessId(processId: "processId")
        authorizationService.setRequestId(requestId: "requestId")
        authorizationService.setTarget(target: .bankId)
        
        // Act
        sut.onCloseTapped()
        
        // Assert
        XCTAssertTrue(view.isCloseCalled)
        XCTAssertEqual(receivedAction, .cancel)
        XCTAssertNil(authorizationService.getProcessId())
        XCTAssertNil(authorizationService.getRequestId())
        XCTAssertNil(authorizationService.authTarget)
        XCTAssertNil(authorizationService.processId)
        if case .login = authorizationService.flow {
            XCTAssert(true)
        } else {
            XCTFail("Unexpected state")
        }
    }
}

private extension AuthMethodsActionSheetPresenterTests {
    func makeSUT(authFlow: AuthFlow = .login,
                 authMethods: [AuthMethod] = [.bankId, .privatbank],
                 identifyCallback: @escaping (AuthMethod) -> Void = { _ in },
                 onClose: @escaping (AlertTemplateAction) -> Void = { _ in }) -> AuthMethodsActionSheetPresenter {
        view = AuthMethodsActionSheetMockView()
        authorizationService = AutorizationManagerMock()
        let data = AuthActivityViewData(title: "testAuthData", authMethods: authMethods)
        
        return .init(view: view,
                     data: data,
                     authFlow: authFlow,
                     authorizationService: authorizationService,
                     identifyCallback: identifyCallback,
                     onClose: onClose)
    }
}
