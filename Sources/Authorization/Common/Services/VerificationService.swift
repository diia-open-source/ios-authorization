
import Foundation
import ReactiveKit
import DiiaMVPModule
import DiiaUIComponents
import DiiaCommonTypes
import DiiaCommonServices

public struct UserIdentificationInput {
    public let initialView: BaseView?
    public let authFlow: AuthFlow
    public let onCloseCallback: ((AlertTemplateAction) -> Void)

    public init(inView: BaseView?, authFlow: AuthFlow, onClose: @escaping (AlertTemplateAction) -> Void) {
        self.initialView = inView
        self.authFlow = authFlow
        self.onCloseCallback = onClose
    }
}

public final class VerificationService {
    // MARK: - Properties
    private let authorizationService: (AuthorizationServiceProtocol&UserAuthFlowHandlerProtocol)
    private var authApiClient: AuthorizationApiClientProtocol
    private let identifyHandlers: [AuthMethod: IdentifyTaskPerformer]
    private var authMethodsHandler: AuthMethodsHandler?

    private let disposeBag = DisposeBag()

    // MARK: - Public Init
    public init(authorizationService: AuthorizationServiceProtocol&UserAuthFlowHandlerProtocol,
                network: AuthorizationNetworkContext,
                userIdentifyHandlers: [AuthMethod: IdentifyTaskPerformer]) {
        self.authorizationService = authorizationService
        self.authApiClient = AuthorizationApiClient(context: network, token: {
            authorizationService.token ?? ""
        })
        self.identifyHandlers = userIdentifyHandlers
    }
    
    // MARK: - Internal Init
    init(authorizationService: AuthorizationServiceProtocol&UserAuthFlowHandlerProtocol,
         apiClient: AuthorizationApiClientProtocol,
         userIdentifyHandlers: [AuthMethod: IdentifyTaskPerformer]) {
        self.authorizationService = authorizationService
        self.authApiClient = apiClient
        self.identifyHandlers = userIdentifyHandlers
    }
    
    // MARK: - Public Methods
    /// Starts verification flow with using of AuthMethodsHandler
    /// - Parameters:
    ///   - flow: Flow
    ///   - view: View for showing auth methods and errors
    ///   - completionHandler: Completion handler of flow when success result is processId 
    public func verifyUser(for flow: VerificationFlowProtocol, in view: BaseView, completionHandler: @escaping (DiiaIdResult<String, Error>) -> Void) {
        authorizationService.setProcessId(processId: nil)
        fetchAndShowAuthMethods(for: flow, in: view, completionHandler: completionHandler)
    }
}

// MARK: - Private Methods
extension VerificationService {
    private func fetchAndShowAuthMethods(for flow: VerificationFlowProtocol,
                                         in view: BaseView,
                                         completionHandler: @escaping (DiiaIdResult<String, Error>) -> Void) {
        view.showProgress()
        authApiClient
            .verificationAuthMethods(flow: flow, processId: self.authorizationService.getProcessId(), selectedMethod: nil)
            .observe { [weak self, weak view] signal in
                guard let self, let view else { return }
                switch signal {
                case .next(let response):
                    self.authorizationService.setProcessId(processId: response.processId)
                    if response.skipAuthMethods == true, let processId = response.processId {
                        completionHandler(.success(processId))
                        view.hideProgress()
                        return
                    }
                    self.processAuthMethodsResponse(response: response, flow: flow, view: view, completionHandler: completionHandler)
                    view.hideProgress()
                case .failed(let error):
                    GeneralErrorsHandler.process(
                        error: .init(networkError: error),
                        with: { [weak self, weak view] in
                            guard let self, let view else { return }
                            self.fetchAndShowAuthMethods(for: flow, in: view, completionHandler: completionHandler)
                        },
                        in: view,
                        closeCallback: { onMainQueue { completionHandler(.canceled) } }
                    )
                    view.hideProgress()
                default:
                    break
                }
            }
            .dispose(in: disposeBag)
    }
    
    private func processAuthMethodsResponse(
        response: VerificationAuthMethodsResponse,
        flow: VerificationFlowProtocol,
        view: BaseView,
        completionHandler: @escaping (DiiaIdResult<String, Error>) -> Void
    ) {
        let activityData = AuthActivityViewData(
            title: response.title ?? "",
            authMethods: response.authMethods ?? []
        )
        guard let template = response.template else {
            showAvaliableAuthMethods(with: activityData, flow: flow, view: view, completionHandler: completionHandler)
            return
        }
        
        TemplateHandler.handle(
            template,
            in: view,
            callback: { [weak self, weak view] templateAction in
                guard let self = self, let view = view else { return }
                
                switch templateAction {
                case .authMethods, .signatureCreationMethods, .getSignatureCreationMethods, .showMethods:
                    self.showAvaliableAuthMethods(with: activityData, flow: flow, view: view, completionHandler: completionHandler)
                case .skip, .cancel:
                    onMainQueue { completionHandler(.canceled) }
                default:
                    break
                }
            },
            onClose: {
                onMainQueue { completionHandler(.canceled) }
            }
        )
    }
    
    private func showAvaliableAuthMethods(
        with activityData: AuthActivityViewData?,
        flow: VerificationFlowProtocol,
        view: BaseView,
        completionHandler: @escaping (DiiaIdResult<String, Error>) -> Void
    ) {
        guard let activityData = activityData else {
            let customError = GeneralError.custom(error: "No auth methods received")
            onMainQueue { completionHandler(.failure(customError)) }
            return
        }
        
        authMethodsHandler = AuthMethodsHandler(
            data: activityData,
            authFlow: flow.authFlow,
            authorizationService: authorizationService,
            identifyHandlers: identifyHandlers,
            onSuccess: { [weak self, weak view] _ in
                guard
                    let self = self, let view = view,
                    let processId = self.authorizationService.getProcessId()
                else {
                    completionHandler(.canceled)
                    return
                }
                view.closeToView(view: view, animated: true)
                completionHandler(.success(processId))
            },
            onClose: { [weak self, weak view] authMethodsAction in
                guard let self = self, let view = view else { return }
                switch authMethodsAction {
                case .diiaIdAuthMethods, .getSignatureCreationMethods, .signatureCreationMethods, .getMethods:
                    self.fetchAndShowAuthMethods(for: flow, in: view, completionHandler: completionHandler)
                case .cancel:
                    onMainQueue { completionHandler(.canceled) }
                case .logout:
                    self.authorizationService.logout()
                    onMainQueue { completionHandler(.canceled) }
                default:
                    onMainQueue { completionHandler(.close) }
                }
            }
        )
        authMethodsHandler?.processAuthMethods(in: view)
    }
}
