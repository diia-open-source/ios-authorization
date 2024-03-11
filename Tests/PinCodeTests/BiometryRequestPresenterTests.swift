import XCTest
@testable import DiiaAuthorizationPinCode

final class BiometryRequestPresenterTests: XCTestCase {

    private var view: BiometryRequestViewMock!
    private var viewModel: BiometryRequestViewModel!

    private var vmCompletionHandlerCalled = false
    
    func test_configureView() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()

        // Assert
        XCTAssertTrue(view.configureWithViewModelCalled)
    }
    
    func test_approve() {
        // Arrange
        let sut = makeSUT()
        XCTAssertFalse(vmCompletionHandlerCalled)
        
        // Act
        sut.approve()

        // Assert
        XCTAssertTrue(vmCompletionHandlerCalled)
    }
    
    func test_makeItLater() {
        // Arrange
        let sut = makeSUT()
        // set state to opposite
        sut.approve()
        XCTAssertTrue(vmCompletionHandlerCalled)

        // Act
        sut.makeItLater()

        // Assert
        XCTAssertFalse(view.configureWithViewModelCalled)
    }
}

private extension BiometryRequestPresenterTests {
    func makeSUT() -> BiometryRequestPresenter {
        view = BiometryRequestViewMock()
        weak var weakSelf = self
        viewModel = BiometryRequestViewModel(title: "title", description: "title", icon: nil, authFlow: .login) { isAllowed, _ in
            weakSelf?.vmCompletionHandlerCalled = true
        }

        return BiometryRequestPresenter(view: view, viewModel: viewModel)
    }
}
