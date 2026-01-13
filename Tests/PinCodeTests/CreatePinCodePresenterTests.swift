
import XCTest
import DiiaMVPModule
@testable import DiiaAuthorizationPinCode

final class CreatePinCodePresenterTests: XCTestCase {
    
    private var view: CreatePinCodeViewMock!
    private var viewModel: PinCodeViewModel!
    private let pinCodeLength: Int = 4

    func test_configureView() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()

        // Assert
        XCTAssertTrue(view.configureWithViewModelCalled)
    }
    
    func test_selectNumberCallsSetter() {
        // Arrange
        let sut = makeSUT()
        XCTAssertEqual(view.enteredNumbersCountValue, 0)
        
        // Act
        sut.selectNumber(number: 2)

        // Assert
        XCTAssertEqual(view.enteredNumbersCountValue, 1)
    }
    
    func test_clear() {

        // Arrange
        let sut = makeSUT()
        XCTAssertEqual(view.enteredNumbersCountValue, 0)
        sut.selectNumber(number: 2)
        XCTAssertEqual(view.enteredNumbersCountValue, 1) // verify that counter works before act - clean
        
        // Act
        sut.clear()
        
        // Assert
        XCTAssertEqual(view.enteredNumbersCountValue, 0)
    }
    
    func test_removeLast() {

        // Arrange
        let sut = makeSUT()
        XCTAssertEqual(view.enteredNumbersCountValue, 0)
        sut.selectNumber(number: 2)
        sut.selectNumber(number: 2)
        XCTAssertEqual(view.enteredNumbersCountValue, 2) // verify that counter works before act - clean
        
        // Act
        sut.removeLast()
        
        // Assert
        XCTAssertEqual(view.enteredNumbersCountValue, 1)
    }
    
    func test_pinCodeSetter_notEnoughDigitsToCheckPincode() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.selectNumber(number: 2)

        // Assert
        // checkpincode is not called, because pinCode.count != viewModel.pinCodeLength
        XCTAssertFalse(view.openModuleCalled)
    }
    
    func test_pinCodeSetter_enoughDigitsToCheckPincode() {
        // Arrange
        let sut = makeSUT()
        XCTAssertFalse(view.openModuleCalled)
        
        // Act
        // set number enough times to call checkpincode
        for _ in 1...pinCodeLength {
            sut.selectNumber(number: 2)
        }
        
        // Assert
        XCTAssertTrue(view.openModuleCalled)
    }
}

private extension CreatePinCodePresenterTests {
    func makeSUT() -> CreatePinCodePresenter {
        view = CreatePinCodeViewMock()
        viewModel = PinCodeViewModel(pinCodeLength: pinCodeLength, createDetails: "", repeatDetails: "", authFlow: .login, completionHandler: { _, _ in })

        return CreatePinCodePresenter(view: view, viewModel: viewModel)
    }
}
