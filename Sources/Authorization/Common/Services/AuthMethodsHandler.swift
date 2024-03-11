import UIKit
import DiiaCommonTypes
import DiiaCommonServices
import DiiaMVPModule

public protocol IdentifyTaskPerformer {
    func identify(with input: UserIdentificationInput)
}

class AuthMethodsHandler {
    private let data: AuthActivityViewData
    private let authFlow: AuthFlow
    private let authorizationService: (AuthorizationServiceProtocol&UserAuthFlowHandlerProtocol)
    private let identifyHandlers: [AuthMethod: IdentifyTaskPerformer]
    private let onSuccess: (BaseView) -> Void
    private let onClose: (AlertTemplateAction) -> Void
    private weak var initialView: BaseView?

    init(
        data: AuthActivityViewData,
        authFlow: AuthFlow,
        authorizationService: (AuthorizationServiceProtocol&UserAuthFlowHandlerProtocol),
        identifyHandlers: [AuthMethod: IdentifyTaskPerformer],
        onSuccess: @escaping (BaseView) -> Void,
        onClose: @escaping (AlertTemplateAction) -> Void
    ) {
        self.data = data
        self.authFlow = authFlow
        self.authorizationService = authorizationService
        self.identifyHandlers = identifyHandlers
        self.onSuccess = onSuccess
        self.onClose = onClose
    }
    
    func processAuthMethods(in view: BaseView) {
        self.initialView = view
        var authMethods = self.data.authMethods
        
        // no need to show methods that can't be processed
        authMethods.removeAll(where: { identifyHandlers[$0] == nil })

        guard authMethods.count > 0 else {
            GeneralErrorsHandler.process(error: .serverError, in: view, forceClose: false)
            return
        }
        
        configureAuthState()
        // MARK: -
        guard authMethods.count > 1 else {
            identify(with: authMethods[0])
            return
        }

        let module = AuthMethodsActionSheetModule(
            data: data,
            authFlow: authFlow,
            authorizationService: authorizationService,
            identifyCallback: { [weak self] method in
                self?.identify(with: method)
            },
            onClose: onClose)
        view.showChild(module: module)
    }
    
    private func configureAuthState() {
        let userAuthorizationFlow: UserAuthorizationFlow?
        
        switch authFlow {
        case .login:
            userAuthorizationFlow = .login(completionHandler: { [weak self] view, action in
                self?.onVerificationFinish(in: view, action: action)
            })
        case .prolong:
            userAuthorizationFlow = .prolong(completionHandler: { [weak self] view, action in
                self?.onVerificationFinish(in: view, action: action)
            })
        case .diiaId(let action):
            userAuthorizationFlow = .diiaId(
                action: action,
                completionHandler: { [weak self] view, action in
                    self?.onVerificationFinish(in: view, action: action)
                }
            )
        case .residencePermitNfcAdding:
            userAuthorizationFlow = .independentVerification(completionHandler: { [weak self] view, action in
                self?.onVerificationFinish(in: view, action: action)
            })
        case .serviceLogin:
            userAuthorizationFlow = nil
        }
        
        guard let flow = userAuthorizationFlow else { return }
        
        authorizationService.setUserAuthorizationFlow(flow)
    }
    
    private func onVerificationFinish(in view: BaseView?, action: AlertTemplateAction?) {
        guard
            let view = view,
            let action = action
        else {
            return
        }
        
        switch action {
        case .ok, .pinCreation, .inputPin, .getToken, .prolong:
            onSuccess(view)
        default:
            view.closeToView(view: initialView, animated: true)
            onClose(action)
        }
    }
    
    func identify(with authMethod: AuthMethod) {
        onClose(.close)
        configureAuthState()

        guard let identify = identifyHandlers[authMethod] else { return }
        identify.identify(with: UserIdentificationInput(inView: initialView, authFlow: authFlow, onClose: onClose))
    }
}
