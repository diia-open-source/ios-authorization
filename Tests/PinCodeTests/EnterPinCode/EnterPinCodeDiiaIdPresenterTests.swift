
import XCTest
@testable import DiiaAuthorizationPinCode

final class EnterPinCodeDiiaIdPresenterTests: XCTestCase {
    private var view: EnterPinCodeViewMock!
    private var enterPinCodeDelegate: EnterPinCodeDelegateMock!
    private var storage: PinCodeStorageMock!
    
    private let pinCodeLength: Int = 5

    func test_configureView() {
        // Arrange
        let sut = makeSUT(with: nil)
        
        // Act
        sut.configureView()

        // Assert
        XCTAssertTrue(view.configureWithViewModelCalled)
    }
    
    func test_checkPincodeCalled_notEnoughDigitsToCheck() {

        // Arrange
        let sut = makeSUT(with: nil)
        
        // Act
        for _ in 1...(pinCodeLength - 1) {
            sut.selectNumber(number: 2)
        }
        
        // Assert
        XCTAssertFalse(enterPinCodeDelegate.checkPincodeCalled)
    }
    
    func test_checkPincodeCalled_enoughDigitsToCheckButIncorrect() {

        // Arrange
        let sut = makeSUT(with: nil)
        let expectedValueOfIncorrectPincodeAttemptsInStorage: Int = 1
        
        // Act
        for _ in 1...pinCodeLength {
            sut.selectNumber(number: 2)
        }
        
        // Assert
        XCTAssertTrue(enterPinCodeDelegate.checkPincodeCalled)
        XCTAssertTrue(storage.saveIncorrectPincodeAttemptsCountCalled)
        XCTAssertEqual(storage.incorrectPincodeAttemptsCounter, 1)
        XCTAssertEqual(storage.incorrectPincodeAttemptsValue, expectedValueOfIncorrectPincodeAttemptsInStorage)
        XCTAssertFalse(enterPinCodeDelegate.didAllAttemptsExhaustedCalled)
    }
    
    func test_checkPincodeCalled_enoughDigitsToCheckButIncorrectAndLimitIsExceeded() {

        // Arrange
        let sut = makeSUT(with: nil)
        let expectedValueOfIncorrectPincodeAttemptsInStorage: Int = 2 // third attempt won't be saved, because failure must reported instead
        
        // Act
        for _ in 1...pinCodeLength {
            sut.selectNumber(number: 2)
        }
        // after first failure pincode will be reset, so need to type all digits agian
        for _ in 1...pinCodeLength {
            sut.selectNumber(number: 2)
        }
        
        for _ in 1...pinCodeLength {
            sut.selectNumber(number: 2)
        }
        
        // Assert
        XCTAssertTrue(enterPinCodeDelegate.checkPincodeCalled)
        XCTAssertTrue(storage.saveIncorrectPincodeAttemptsCountCalled)
        XCTAssertEqual(storage.incorrectPincodeAttemptsCounter, 2)
        XCTAssertEqual(storage.incorrectPincodeAttemptsValue, expectedValueOfIncorrectPincodeAttemptsInStorage)
        XCTAssertTrue(enterPinCodeDelegate.didAllAttemptsExhaustedCalled)
    }
    
    func test_checkPincodeCalled_correctPincode() {

        // Arrange
        let sut = makeSUT(with: nil)
        enterPinCodeDelegate.checkPincodeExpectedResult = true
        // value after successful check must be zeroed
        let expectedValueOfIncorrectPincodeAttemptsInStorage: Int = 0
        
        // Act
        for _ in 1...pinCodeLength {
            sut.selectNumber(number: 2)
        }
        
        // Assert
        XCTAssertTrue(enterPinCodeDelegate.checkPincodeCalled)
        XCTAssertTrue(enterPinCodeDelegate.didCorrectPincodeEnteredCalled)
        XCTAssertTrue(storage.saveIncorrectPincodeAttemptsCountCalled)
        XCTAssertEqual(storage.incorrectPincodeAttemptsCounter, 1)
        XCTAssertEqual(storage.incorrectPincodeAttemptsValue, expectedValueOfIncorrectPincodeAttemptsInStorage)
    }
    
    func test_pinCodeSetter() {

        // Arrange
        let sut = makeSUT(with: nil)
        let expectedEnteredNumbersCounter: Int = 1
        XCTAssertEqual(view.enteredNumbersCounter, 0)
        
        // Act
        sut.selectNumber(number: 2)
        
        // Assert
        XCTAssertEqual(view.enteredNumbersCounter, expectedEnteredNumbersCounter)
    }
    
    func test_clear() {

        // Arrange
        let sut = makeSUT(with: nil)
        XCTAssertEqual(view.enteredNumbersCounter, 0)
        sut.selectNumber(number: 2)
        XCTAssertEqual(view.enteredNumbersCounter, 1)
        
        // Act
        sut.removeLast()
        
        // Assert
        XCTAssertEqual(view.enteredNumbersCounter, 0)
    }

    func test_forgotPincodePressed() {

        // Arrange
        let sut = makeSUT(with: nil)
        XCTAssertFalse(enterPinCodeDelegate.onForgotPincodeCalled)
        
        // Act
        sut.forgotPincodePressed()
        
        // Assert
        XCTAssertTrue(enterPinCodeDelegate.onForgotPincodeCalled)
    }
}


private extension EnterPinCodeDiiaIdPresenterTests {
    func makeSUT(with context: EnterPinCodeModuleContext?) -> EnterPinCodeDiiaIdPresenter {
        view = EnterPinCodeViewMock()
        enterPinCodeDelegate = EnterPinCodeDelegateMock()
        storage = PinCodeStorageMock()
        let vm = EnterPinCodeViewModel(pinCodeLength: pinCodeLength, title: "title", forgotTitle: "forgotTitle")

        let contexToGo: EnterPinCodeModuleContext = context ?? EnterPinCodeModuleContext(storage: storage, enterPinCodeDelegate: enterPinCodeDelegate)

        return .init(context: contexToGo, view: view, viewModel: vm)
    }
}
