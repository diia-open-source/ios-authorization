import UIKit
import DiiaMVPModule
import DiiaUIComponents

public enum EnterPinCodeFlow {
    case auth
    case diiaId
}
       
public protocol EnterPinCodeDelegate {
    func onForgotPincode(in view: BaseView)
    func didAllAttemptsExhausted(in view: BaseView)
    func checkPincode(_ pincode: [Int]) -> Bool
    func didCorrectPincodeEntered(pincode: String)
}

public final class EnterPinCodeModule: BaseModule {
    private let view: EnterPinCodeViewController
    private let presenter: EnterPinCodeAction
    
    public init(context: EnterPinCodeModuleContext, flow: EnterPinCodeFlow, viewModel: EnterPinCodeViewModel) {
        
        view = EnterPinCodeViewController.storyboardInstantiate(bundle: Bundle.module)
        
        switch flow {
        case .auth:
            presenter = EnterPinCodeAuthPresenter(
                context: context,
                view: view,
                viewModel: viewModel,
                biometryHelper: BiometrySupportImpl()
            )
        case .diiaId:
            presenter = EnterPinCodeDiiaIdPresenter(
                context: context,
                view: view,
                viewModel: viewModel
            )
        }
        
        view.presenter = presenter
    }

    public func viewController() -> UIViewController {
        return view
    }
}

// MARK: - EnterPinCodeInContainerModule
public final class EnterPinCodeInContainerModule: BaseModule {
    private let view: EnterPinCodeViewController
    private let presenter: EnterPinCodeAction
    private let container: ChildContainerViewController
    
    public init(
        context: EnterPinCodeModuleContext,
        flow: EnterPinCodeFlow,
        viewModel: EnterPinCodeViewModel
    ) {
        view = EnterPinCodeViewController.storyboardInstantiate(bundle: Bundle.module)
        
        switch flow {
        case .auth:
            presenter = EnterPinCodeAuthPresenter(
                context: context,
                view: view,
                viewModel: viewModel,
                biometryHelper: BiometrySupportImpl()
            )
        case .diiaId:
            presenter = EnterPinCodeDiiaIdPresenter(
                context: context,
                view: view,
                viewModel: viewModel
            )
        }
        
        view.presenter = presenter
        
        let childContainer = ChildContainerViewController()
        childContainer.childSubview = view
        childContainer.presentationStyle = .fullscreen
        container = childContainer
    }

    public func viewController() -> UIViewController {
        return container
    }
}
