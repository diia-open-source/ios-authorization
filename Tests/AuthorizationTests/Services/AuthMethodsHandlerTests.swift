import XCTest
import DiiaMVPModule
import DiiaCommonTypes
@testable import DiiaAuthorization

class AuthMethodsHandlerTests: XCTestCase {
    
    private var authorizationService: AutorizationManagerMock!
    private var identificationInput: UserIdentificationInput?
    
    override func tearDown() {
        authorizationService = nil
        identificationInput = nil
        
        super.tearDown()
    }
    
    func test_processAuthMethods_withNoMethods() {
        // Arrange
        let sut = makeSUT(authMethods: [])
        let view = BaseMockView()
        let expectation = self.expectation(description: "processAuthMethode withNoMethods")
        var isGeneralErrorShowing = false
        view.onGeneralErrorShow = { isGeneralErrorVisible in
            isGeneralErrorShowing = isGeneralErrorVisible
            expectation.fulfill()
        }
        
        // Act
        sut.processAuthMethods(in: view)
        
        // Assert
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(isGeneralErrorShowing)
    }
    
    func test_processAuthMethods_withSingleMethod() {
        // Arrange
        let sut = makeSUT(authFlow: .login, authMethods: [.bankId])
        let view = BaseMockView()
        
        // Act
        sut.processAuthMethods(in: view)
        
        // Assert
        XCTAssertNotNil(identificationInput)
        if case .login = identificationInput?.authFlow, case .login = authorizationService.flow {
            XCTAssertTrue(true)
        } else {
            XCTFail("Unexpected state")
        }
    }
    
    func test_processAuthMethods_WithMultipleMethods() {
        // Arrange
        let sut = makeSUT(authMethods: [.bankId, .privatbank])
        let view = BaseMockView()
        
        // Act
        sut.processAuthMethods(in: view)
        
        // Assert
        XCTAssertTrue(view.isAuthMethodsActionSheetModuleCalled)
    }
    
    func test_onVerificationFinish_withNilArguments() {
        // Arrange
        var expectView: BaseView?
        let sut = makeSUT { view in
            expectView = view
        }
        
        // Act
        sut.identify(with: .bankId)
        
        // Assert
        if case .login(let completionHanler) = authorizationService.flow {
            completionHanler(nil, nil)
            XCTAssertNil(expectView)
        } else {
            XCTFail("Unexpected state")
        }
    }
    
    func test_onVerificationFinish_withArguments_getTokenAction() {
        // Arrange
        var expectView: BaseView?
        let sut = makeSUT { view in
            expectView = view
        }
        let view = BaseMockView()
        
        // Act
        sut.identify(with: .bankId)
        
        // Assert
        if case .login(let completionHanler) = authorizationService.flow {
            completionHanler(view, .getToken)
            XCTAssertTrue(view === expectView)
        } else {
            XCTFail("Unexpected state")
        }
    }
    
    func test_onVerificationFinish_withArguments_logoutAction() {
        // Arrange
        let expectAction: AlertTemplateAction = .close
        var receivedAction: AlertTemplateAction?
        let sut = makeSUT(onClose: { action in
            receivedAction = action
        })
        let view = BaseMockView()
        
        // Act
        sut.identify(with: .bankId)
        
        // Assert
        if case .login(let completionHanler) = authorizationService.flow {
            completionHanler(view, expectAction)
            XCTAssertEqual(expectAction, receivedAction)
            XCTAssertTrue(view.isCloseToViewViewAnimatedCalled)
            
        } else {
            XCTFail("Unexpected state")
        }
    }
    
    func test_onVerificationFinish_withArguments_prolong() {
        // Arrange
        var expectView: BaseView?
        let sut = makeSUT(authFlow: .prolong) { view in
            expectView = view
        }
        let view = BaseMockView()
        
        // Act
        sut.identify(with: .bankId)
        
        // Assert
        if case .prolong(let completionHanler) = authorizationService.flow {
            completionHanler(view, .prolong)
            XCTAssertTrue(view === expectView)
        } else {
            XCTFail("Unexpected state")
        }
    }
    
    func test_onVerificationFinish_withFlow_diiaId() {
        // Arrange
        var expectView: BaseView?
        let sut = makeSUT(authFlow: .diiaId(action: .creation)) { view in
            expectView = view
        }
        let view = BaseMockView()
        
        // Act
        sut.identify(with: .bankId)
        
        // Assert
        if case .diiaId(_, let completionHanler) = authorizationService.flow {
            completionHanler(view, .pinCreation)
            XCTAssertTrue(view === expectView)
        } else {
            XCTFail("Unexpected state")
        }
    }
    
    func test_onVerificationFinish_withFlow_independentVerification() {
        // Arrange
        var expectView: BaseView?
        let sut = makeSUT(authFlow: .residencePermitNfcAdding) { view in
            expectView = view
        }
        let view = BaseMockView()
        
        // Act
        sut.identify(with: .bankId)
        
        // Assert
        if case .independentVerification(let completionHanler) = authorizationService.flow {
            completionHanler(view, .ok)
            XCTAssertTrue(view === expectView)
        } else {
            XCTFail("Unexpected state")
        }
    }
    
    func test_flow_serviceLogin() {
        // Arrange
        let sut = makeSUT(authFlow: .serviceLogin)
        
        // Act
        sut.identify(with: .bankId)
        
        // Assert
        XCTAssertNil(authorizationService.flow)
    }
}

private extension AuthMethodsHandlerTests {
    func makeSUT(authFlow: AuthFlow = .login,
                 authMethods: [AuthMethod] = [.bankId, .privatbank],
                 onSuccess: @escaping (BaseView) -> Void = { _ in },
                 onClose: @escaping (AlertTemplateAction) -> Void = { _ in }) -> AuthMethodsHandler {
        let data = AuthActivityViewData(title: "testAuthData", authMethods: authMethods)
        authorizationService = AutorizationManagerMock()
        let identifyHandler: UserIdentifyHandler = { input in self.identificationInput = input }
        let performer: IdentifyTaskPerformer = IdentifyTaskPerformerMock(completion: identifyHandler)

        let identifyPerformers: [AuthMethod: IdentifyTaskPerformer] = authMethods.reduce(into: [:]) { result, authMethod in
            result[authMethod] = performer
        }
        
        return .init(data: data,
                     authFlow: authFlow,
                     authorizationService: authorizationService,
                     identifyHandlers: identifyPerformers,
                     onSuccess: onSuccess,
                     onClose: onClose
        )
    }
}

