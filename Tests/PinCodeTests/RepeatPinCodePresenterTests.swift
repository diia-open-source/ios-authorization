
import XCTest
import DiiaMVPModule
@testable import DiiaAuthorizationPinCode

final class RepeatPinCodePresenterTests: XCTestCase {
    
    private var view: RepeatPinCodeViewMock!
    private var viewModel: PinCodeViewModel!
    private let pinCodeLength: Int = 3
    private let oldPinCode: [Int] = [1,2,1,3]
    private var vmCompletionHandlerCalled = false


    func test_selectNumberCallsSetter() {
        // Arrange
        let sut = makeSUT()
        XCTAssertEqual(view.enteredNumbersCountValue, 0)
        
        // Act
        sut.selectNumber(number: 2)

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
        XCTAssertFalse(vmCompletionHandlerCalled)
        XCTAssertFalse(view.userDidEnterIncorrectPinCalled)
    }

    func test_pinCodeSetter_enoughDigitsToCheckPincodeWrongPin() {
        // Arrange
        let sut = makeSUT()
        XCTAssertFalse(vmCompletionHandlerCalled)
        XCTAssertFalse(view.userDidEnterIncorrectPinCalled)
        
        // Act
        // set number enough times to call checkpincode
        for _ in oldPinCode {
            sut.selectNumber(number: 2)
        }

        // Assert
        XCTAssertFalse(vmCompletionHandlerCalled)
        XCTAssertTrue(view.userDidEnterIncorrectPinCalled)
    }
    
    func test_pinCodeSetter_enoughDigitsToCheckPincodeCorrectPin() {
        // Arrange
        let sut = makeSUT()
        XCTAssertFalse(vmCompletionHandlerCalled)
        XCTAssertFalse(view.userDidEnterIncorrectPinCalled)
        
        // Act
        // set number enough times to call checkpincode
        for digit in oldPinCode {
            sut.selectNumber(number: digit)
        }

        // Assert
        XCTAssertTrue(vmCompletionHandlerCalled)
        XCTAssertFalse(view.userDidEnterIncorrectPinCalled)
    }
    
    func test_clear() {

        // Arrange
        let sut = makeSUT()
        XCTAssertEqual(view.enteredNumbersCountValue, 0)
        sut.selectNumber(number: 2)
        XCTAssertEqual(view.enteredNumbersCountValue, 1) // verify that counter works before act - clean
        
        // Act
        sut.removeLast()
        
        // Assert
        XCTAssertEqual(view.enteredNumbersCountValue, 0)
        XCTAssertFalse(vmCompletionHandlerCalled)
        XCTAssertFalse(view.userDidEnterIncorrectPinCalled)
    }

}

private extension RepeatPinCodePresenterTests {
    func makeSUT() -> RepeatPinCodePresenter {
        view = RepeatPinCodeViewMock()
        weak var weakSelf = self

        viewModel = PinCodeViewModel(pinCodeLength: oldPinCode.count, createDetails: "", repeatDetails: "", authFlow: .login, completionHandler: { pin, _ in
            weakSelf?.vmCompletionHandlerCalled = true
        })

        return RepeatPinCodePresenter(view: view, oldPinCode: oldPinCode, viewModel: viewModel)
    }
}
