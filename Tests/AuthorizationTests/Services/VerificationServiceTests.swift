
import XCTest
import DiiaUIComponents
@testable import DiiaAuthorization

final class VerificationServiceTests: XCTestCase {

    private var authorizationService: AutorizationManagerMock!
    private var authorizationApiClient: AuthorizationApiClientStub!
    private var identificationInput: UserIdentificationInput?

    override func tearDown() {
        authorizationService = nil
        identificationInput = nil
        authorizationApiClient = nil
        
        super.tearDown()
    }

    func test_verifyUser_withSkipAuthMethods() {
        // Arrange
        let sut = makeSUT(authMethods: [])
        let view = BaseMockView()
        var expectProcessId: String?
        let completionHandler: (DiiaIdResult<String, Error>) -> Void = { result in
            if case .success(let processId) = result {
                expectProcessId = processId
            } else {
                XCTFail("Unexpected state")
            }
        }
        let flow = VerificationFlowMock(flowCode: "skipAuthMethods")

        // Act
        sut.verifyUser(for: flow, in: view, completionHandler: completionHandler)

        // Assert
        XCTAssertTrue(view.isShowProgressCalled)
        XCTAssertNotNil(authorizationService.processId)
        XCTAssertNotNil(expectProcessId)
        XCTAssertTrue(view.isHideProgressCalled)
    }

    func test_verifyUser_withAuthMethods_successful() {
        // Arrange
        let sut = makeSUT(authMethods: [.bankId])
        let view = BaseMockView()
        let expectation = self.expectation(description: "verifyUser withAuthMethods_successful")
        var expectProcessId: String?
        let completionHandler: (DiiaIdResult<String, Error>) -> Void = { result in
            if case .success(let processId) = result {
                expectProcessId = processId
                expectation.fulfill()
            }
        }
        let flow = VerificationFlowMock(flowCode: "bankId")
        var authMethodsHandler: AuthMethodsHandler?

        // Act
        sut.verifyUser(for: flow, in: view, completionHandler: completionHandler)
        let mirror = Mirror(reflecting: sut)
        if let propertyChild = mirror.children.first(where: { $0.label == "authMethodsHandler" }) {
            if let propertyValue = propertyChild.value as? AuthMethodsHandler {
                authMethodsHandler = propertyValue
            }
        }
        // Perform identify after template alert is displayed
        onMainQueue {
            authMethodsHandler?.identify(with: .bankId)
            if case .login(let completionHanler) = self.authorizationService.flow {
                completionHanler(view, .getToken)
            }
        }
        
        // Assert
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(view.isShowProgressCalled)
        XCTAssertNotNil(authorizationService.processId)
        XCTAssertTrue(view.isHideProgressCalled)
        XCTAssertTrue(view.isCloseToViewViewAnimatedCalled)
        XCTAssertNotNil(expectProcessId)
    }

    func test_verifyUser_unsuccessful() {
        // Arrange
        let sut = makeSUT(authMethods: [])
        let view = BaseMockView()
        let completionHandler: (DiiaIdResult<String, Error>) -> Void = { _ in }
        let flow = VerificationFlowMock()
        
        let expectation = self.expectation(description: "verifyUser unsuccessful")
        var isGeneralErrorShowing = false
        view.onGeneralErrorShow = { isGeneralErrorVisible in
            isGeneralErrorShowing = isGeneralErrorVisible
            expectation.fulfill()
        }

        // Act
        sut.verifyUser(for: flow, in: view, completionHandler: completionHandler)

        // Assert
        XCTAssertTrue(view.isShowProgressCalled)
        XCTAssertNil(authorizationService.processId)
        XCTAssertTrue(view.isHideProgressCalled)
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(isGeneralErrorShowing)
    }
    
    func test_verifyUser_withAuthMethods_logout() {
        // Arrange
        let sut = makeSUT(authMethods: [.bankId])
        let view = BaseMockView()
        let expectation = self.expectation(description: "verifyUser withAuthMethods_logout")
        var isVerificationCancelled: Bool = false
        let completionHandler: (DiiaIdResult<String, Error>) -> Void = { result in
            if case .canceled = result {
                isVerificationCancelled.toggle()
                expectation.fulfill()
            }
        }
        let flow = VerificationFlowMock(flowCode: "bankId_logout")
        var authMethodsHandler: AuthMethodsHandler?

        // Act
        sut.verifyUser(for: flow, in: view, completionHandler: completionHandler)
        let mirror = Mirror(reflecting: sut)
        if let propertyChild = mirror.children.first(where: { $0.label == "authMethodsHandler" }) {
            if let propertyValue = propertyChild.value as? AuthMethodsHandler {
                authMethodsHandler = propertyValue
            }
        }
        authMethodsHandler?.identify(with: .bankId)
        if case .login(let completionHanler) = authorizationService.flow {
            completionHanler(view, .logout)
        }

        // Assert
        XCTAssertTrue(view.isShowProgressCalled)
        XCTAssertNotNil(authorizationService.processId)
        XCTAssertTrue(view.isHideProgressCalled)
        XCTAssertTrue(view.isCloseToViewViewAnimatedCalled)
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(isVerificationCancelled)
    }
}

private extension VerificationServiceTests {
    func makeSUT(authMethods: [AuthMethod] = [.bankId, .privatbank]) -> VerificationService {
        authorizationService = AutorizationManagerMock()
        let identifyHandler: UserIdentifyHandler = { input in self.identificationInput = input }
        let performer: IdentifyTaskPerformer = IdentifyTaskPerformerMock(completion: identifyHandler)
        let identifyPerformers: [AuthMethod: IdentifyTaskPerformer] = authMethods.reduce(into: [:]) { result, authMethod in
            result[authMethod] = performer
        }
        authorizationApiClient = AuthorizationApiClientStub()
        let service = VerificationService(authorizationService: authorizationService,
                                          apiClient: authorizationApiClient,
                                          userIdentifyHandlers: identifyPerformers)
        return service
    }
}
