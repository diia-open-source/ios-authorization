import UIKit
import DiiaMVPModule
import DiiaCommonTypes

protocol AuthMethodsActionSheetAction: BasePresenter {
    func identify(with authMethod: AuthMethod)
    func onCloseTapped()
}

final class AuthMethodsActionSheetPresenter: AuthMethodsActionSheetAction {
    
    // MARK: - Properties
    unowned var view: AuthMethodsActionSheetView
    private let data: AuthActivityViewData
    private let authFlow: AuthFlow
    private weak var authorizationService: (AuthorizationServiceProtocol&UserAuthFlowHandlerProtocol)?
    private let identifyCallback: (AuthMethod) -> Void
    private let onClose: (AlertTemplateAction) -> Void
        
    init(
        view: AuthMethodsActionSheetView,
        data: AuthActivityViewData,
        authFlow: AuthFlow,
        authorizationService: AuthorizationServiceProtocol&UserAuthFlowHandlerProtocol,
        identifyCallback: @escaping (AuthMethod) -> Void,
        onClose: @escaping (AlertTemplateAction) -> Void
    ) {
        self.view = view
        self.data = data
        self.authFlow = authFlow
        self.authorizationService = authorizationService
        self.identifyCallback = identifyCallback
        self.onClose = onClose
    }
    
    func configureView() {
        view.setTitle(data.title)
        view.setSeparatorColor(authFlow: authFlow)
        view.configure(with: self.data.authMethods)
    }
    
    func identify(with authMethod: AuthMethod) {
        view.close()
        identifyCallback(authMethod)
    }
    
    func onCloseTapped() {
        authorizationService?.setUserAuthorizationFlow(.login(completionHandler: { _, _ in }))
        authorizationService?.setProcessId(processId: nil)
        authorizationService?.setRequestId(requestId: nil)
        authorizationService?.setTarget(target: nil)
        view.close()
        onClose(.cancel)
    }
}
