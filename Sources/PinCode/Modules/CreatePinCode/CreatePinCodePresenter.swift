import UIKit
import DiiaMVPModule

protocol CreatePinCodeAction: BasePresenter {
    func selectNumber(number: Int)
    func clear()
    func removeLast()
}

final class CreatePinCodePresenter: CreatePinCodeAction {
    
    // MARK: - Properties
    unowned var view: CreatePinCodeView
    private let viewModel: PinCodeViewModel

    private var pinCode: [Int] = [] {
        didSet {
            view.setEnteredNumbersCount(count: pinCode.count)
            if pinCode.count == viewModel.pinCodeLength {
                view.open(module: RepeatPinCodeModule(pinCode: pinCode, viewModel: viewModel))
            }
        }
    }
    
    // MARK: - Init
    init(
        view: CreatePinCodeView,
        viewModel: PinCodeViewModel
    ) {
        self.view = view
        self.viewModel = viewModel
    }
    
    // MARK: - Public Methods
    func configureView() {
        view.configure(with: viewModel)
    }
    
    func selectNumber(number: Int) {
        pinCode.append(number)
    }
    
    func clear() {
        pinCode = []
    }
    
    func removeLast() {
        guard !pinCode.isEmpty else { return }
        pinCode.removeLast()
    }
}
