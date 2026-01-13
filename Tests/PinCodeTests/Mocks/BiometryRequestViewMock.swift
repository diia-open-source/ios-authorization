
import UIKit
@testable import DiiaAuthorizationPinCode

final class BiometryRequestViewMock: UIViewController, BiometryRequestView {
    
    private(set) var configureWithViewModelCalled = false

    func configure(with viewModel: BiometryRequestViewModel) {
        configureWithViewModelCalled = true
    }
}
