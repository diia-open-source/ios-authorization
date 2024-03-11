import UIKit
import DiiaMVPModule

protocol RepeatPinCodeAction: BasePresenter {
    func selectNumber(number: Int)
    func removeLast()
}

final class RepeatPinCodePresenter: RepeatPinCodeAction {
    
    // MARK: - Properties
    unowned var view: RepeatPinCodeView
    private var oldPinCode: [Int]
    private let viewModel: PinCodeViewModel
    
    private var pinCode: [Int] = [] {
        didSet {
            view.setEnteredNumbersCount(count: pinCode.count)
            if pinCode.count == viewModel.pinCodeLength {
                checkPincode()
            }
        }
    }
    
    private var numberOfIncorrectAttempts = 0
    
    // MARK: - Init
    init(
        view: RepeatPinCodeView,
        oldPinCode: [Int],
        viewModel: PinCodeViewModel
    ) {
        self.view = view
        self.oldPinCode = oldPinCode
        self.viewModel = viewModel
    }
    
    // MARK: - Public Methods
    func configureView() {
        view.configure(with: viewModel)
    }
    
    func selectNumber(number: Int) {
        pinCode.append(number)
    }
    
    func removeLast() {
        guard !pinCode.isEmpty else { return }
        pinCode.removeLast()
    }
    
    // MARK: - Private Methods
    private func checkPincode() {
        if oldPinCode == pinCode {
            viewModel.completionHandler(pinCode, view)
            return
        }
        
        numberOfIncorrectAttempts += 1
        pinCode = []
        if numberOfIncorrectAttempts < 3 {
            view.userDidEnterIncorrectPin()
        } else {
            view.closeModule(animated: true)
        }
    }
}
