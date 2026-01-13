
import UIKit
import DiiaMVPModule

protocol BiometryRequestAction: BasePresenter {
    func approve()
    func makeItLater()
}

final class BiometryRequestPresenter: BiometryRequestAction {
    
    // MARK: - Properties
    unowned var view: BiometryRequestView
    private let viewModel: BiometryRequestViewModel

    init(
        view: BiometryRequestView,
        viewModel: BiometryRequestViewModel
    ) {
        self.view = view
        self.viewModel = viewModel
    }
    
    func configureView() {
        view.configure(with: viewModel)
    }
    
    func approve() {
        viewModel.completionHandler(true, view)
    }
    
    func makeItLater() {
        viewModel.completionHandler(false, view)
    }
}
