import XCTest
import DiiaMVPModule
@testable import DiiaAuthorizationPinCode

final class ChangePincodePresenterTests: XCTestCase {
    private var view: ChangePincodeViewMock!
    private var viewModel: ChangePincodeViewModel!

    private var vmCheckActionCalled = false
    private var vmSuccessActionCalled = false
    private var vmFailureActionCalled = false
    private let pinCodeLength: Int = 4

    func test_configureView() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()

        // Assert
        XCTAssertTrue(view.configureWithPinCodeLengthCalled)
        XCTAssertTrue(view.setTitleCalled)
        XCTAssertTrue(view.setDescriptionCalled)
    }
    
    func test_pinCodeSetter_incrementsViewNumberCount() {
        // Arrange
        let sut = makeSUT()
        XCTAssertFalse(view.setEnteredNumbersCountCalled)
        
        // Act
        sut.selectNumber(number: 2)
        
        // Assert
        XCTAssertTrue(view.setEnteredNumbersCountCalled)
    }
    
    func test_pinCodeSetter_notEnoughDigitsToCheckPincode() {

        // Arrange
        let sut = makeSUT()
        
        // Act
        for _ in 1...(pinCodeLength - 1) {
            sut.selectNumber(number: 2)
        }
        
        // Assert
        XCTAssertFalse(vmCheckActionCalled)
    }
    
    func test_pinCodeSetter_tooManyDigitsToCheckPincode() {

        // Arrange
        let sut = makeSUT()
        for _ in 1...pinCodeLength {
            sut.selectNumber(number: 2)
        }
        XCTAssertTrue(vmCheckActionCalled)
        vmCheckActionCalled = false // reset. the flag was set to true once pinCode.count == Constants.pinCodeLength
        
        // Act
        // exceed pinCodeLength
        sut.selectNumber(number: 2)

        // Assert
        XCTAssertFalse(vmCheckActionCalled)
    }
    
    func test_pinCodeSetter_enoughDigitsToCheckPincodeWrongPin() {

        // Arrange
        let checkResult = false
        let sut = makeSUT(isValidCode: checkResult)
        
        // Act
        for _ in 1...pinCodeLength {
            sut.selectNumber(number: 2)
        }
        
        // Assert
        XCTAssertTrue(vmCheckActionCalled)
        XCTAssertFalse(vmSuccessActionCalled)
        XCTAssertTrue(view.userDidEnterIncorrectPinCalled)
    }
    
    func test_pinCodeSetter_enoughDigitsToCheckPincodeCorrectPin() {

        // Arrange
        let checkResult = true
        let sut = makeSUT(isValidCode: checkResult)
        
        // Act
        for _ in 1...pinCodeLength {
            sut.selectNumber(number: 2)
        }
        
        // Assert
        XCTAssertTrue(vmCheckActionCalled)
        XCTAssertTrue(vmSuccessActionCalled)
        XCTAssertFalse(view.userDidEnterIncorrectPinCalled)
    }
    
    func test_clear() {

        // Arrange
        let sut = makeSUT()
        XCTAssertEqual(view.enteredNumbersCounter, 0)
        sut.selectNumber(number: 2)
        XCTAssertEqual(view.enteredNumbersCounter, 1)
        
        // Act
        sut.clear()
        
        // Assert
        XCTAssertEqual(view.enteredNumbersCounter, 0)
    }
    
    func test_removeLast() {
        // Arrange
        let sut = makeSUT()
        sut.selectNumber(number: 2)
        sut.selectNumber(number: 3)
        
        // Act
        sut.removeLast()
        
        // Assert
        XCTAssertEqual(view.enteredNumbersCounter, 1)
    }
    
    func test_removeLast_returnIfEmpty() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.removeLast()
        
        // Assert
        XCTAssertEqual(view.enteredNumbersCounter, 0)
    }
}

private extension ChangePincodePresenterTests {
    func makeSUT(isValidCode: Bool = false) -> ChangePincodePresenter {
        view = ChangePincodeViewMock()
        weak var weakSelf = self
        viewModel = ChangePincodeViewModel(title: "title",
                                           description: "description",
                                           pinCodeLength: 5,
                                           checkAction: { pincodeArray in
            weakSelf?.vmCheckActionCalled = true
            return isValidCode
        },
                                           successAction: { pincodeArray, _ in
            weakSelf?.vmSuccessActionCalled = true
        },
                                           failureAction: { _ in
            weakSelf?.vmFailureActionCalled = true
        })
        
        return ChangePincodePresenter(view: view, viewModel: viewModel)
    }
}
