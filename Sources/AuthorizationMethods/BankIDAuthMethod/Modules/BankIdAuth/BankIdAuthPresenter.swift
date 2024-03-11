import UIKit
import DiiaMVPModule
import DiiaAuthorization

protocol BankIdAuthAction: BasePresenter {
    var appShortVersion: String { get }

    func handle(url: URL) -> Bool
    func handleUnsecureContent()
}

final class BankIdAuthPresenter: BankIdAuthAction {
    
    // MARK: - Properties
    unowned var view: BankIdAuthView
    private var bankId: String
    private let authUrl: String
    private let parentView: BaseView
    private let authService: AuthorizationServiceProtocol
    let appShortVersion = AppConstants.appShortVersion

    // MARK: - Init
    init(
        view: BankIdAuthView,
        bankId: String,
        authUrl: String,
        parentView: BaseView,
        authService: AuthorizationServiceProtocol
    ) {
        self.view = view
        self.bankId = bankId
        self.authUrl = authUrl
        self.parentView = parentView
        self.authService = authService
    }
    
    // MARK: - Public Methods
    func configureView() {
        if let url = makeBankIdUrl() {
            view.load(url: url)
        }
    }
    
    func handle(url: URL) -> Bool {
        if Constants.schemes.contains(url.scheme ?? "") && Constants.marketUrl != url.host {
            if AppConstants.handledRedirectionHosts.contains(url.host ?? "") {
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                    for item in components.queryItems ?? [] {
                        if item.name == "code", let code = item.value {
                            proceed(code: code)
                            return true
                        }
                    }
                }
            }
        } else if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        }
        
        return false
    }
    
    func handleUnsecureContent() {
        view.showInsecureContentInfo()
    }
    
    private func proceed(code: String) {
        authService.setRequestId(requestId: code)
        authService.setTarget(target: .bankId)
        authService.authorize(
            in: view,
            parameters: [Constants.bankIdKey: bankId],
            failureAction: { [weak self] in
                guard let self = self else { return }
                self.view.closeToView(view: self.parentView, animated: true)
            }
        )
    }
    
    private func makeBankIdUrl() -> URL? {
        return URL(string: authUrl)
    }
}

private extension BankIdAuthPresenter {
    enum Constants {
        static let bankIdKey: String = "bankId"
        static let schemes = ["https", "http"]
        static let marketUrl = "apps.apple.com"
    }
}
