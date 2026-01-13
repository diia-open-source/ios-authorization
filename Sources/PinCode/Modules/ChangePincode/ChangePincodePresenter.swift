
import UIKit
import DiiaMVPModule

protocol ChangePincodeAction: BasePresenter {
    func selectNumber(number: Int)
    func clear()
    func removeLast()
}

final class ChangePincodePresenter: ChangePincodeAction {
    
    // MARK: - Properties
    unowned var view: ChangePincodeView
    private let viewModel: ChangePincodeViewModel

    private var pinCode: [Int] = [] {
        didSet {
            view.setEnteredNumbersCount(count: pinCode.count)
            if pinCode.count == Constants.pinCodeLength {
                checkPincode()
            }
        }
    }
    
    // MARK: - Init
    init(view: ChangePincodeView,
         viewModel: ChangePincodeViewModel
    ) {
        self.view = view
        self.viewModel = viewModel
    }
    
    // MARK: - Public Methodds
    func configureView() {
        view.configure(with: viewModel.pinCodeLength)
        view.setTitle(title: viewModel.title)
        view.setDescription(description: viewModel.description)
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
    
    // MARK: - Logic
    private func checkPincode() {
        if viewModel.checkAction(pinCode) {
            viewModel.successAction(pinCode, view)
        } else {
            view.userDidEnterIncorrectPin()
            pinCode = []
            viewModel.failureAction(view)
        }
    }
}

// MARK: - Constants
extension ChangePincodePresenter {
    private enum Constants {
        static let pinCodeLength: Int = 4
    }
}
