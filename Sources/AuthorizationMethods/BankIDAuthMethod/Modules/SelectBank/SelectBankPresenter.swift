import UIKit
import ReactiveKit
import DiiaMVPModule
import DiiaNetwork
import DiiaCommonTypes
import DiiaAuthorization
import DiiaCommonServices
import DiiaUIComponents

protocol SelectBankAction: BasePresenter {
    func search(text: String?)
}

final class SelectBankPresenter: SelectBankAction {
    
    // MARK: - Properties
    unowned var view: SelectBankView
    
    private let selectBankAPIClient: SelectBankApiClientProtocol
    private let authService: AuthorizationServiceProtocol
    private let authErrorRouter: RouterProtocol
    private let analyticsHandler: AnalyticsAuthMethodsHandler?
    private let onClose: ((AlertTemplateAction) -> Void)?

    private var didRetry = false
    private let bag = DisposeBag()

    private var banks: [DSListItemViewModel] = []
    private var searchedBanks: [DSListItemViewModel] = [] {
        didSet {
            view.setupBanks(searchedBanks)
        }
    }
    
    // MARK: - Init
    init(view: SelectBankView,
         selectBankAPIClient: SelectBankApiClientProtocol,
         authErrorRouter: RouterProtocol,
         authService: AuthorizationServiceProtocol,
         analyticsHandler: AnalyticsAuthMethodsHandler?,
         onClose: ((AlertTemplateAction) -> Void)?) {
        self.view = view
        self.selectBankAPIClient = selectBankAPIClient
        self.authErrorRouter = authErrorRouter
        self.authService = authService
        self.analyticsHandler = analyticsHandler
        self.onClose = onClose
    }
    
    // MARK: - Public Methods
    func configureView() {
        loadBanks()
    }
    
    // MARK: - SelectBankAction
    func search(text: String?) {
        guard let search = text?.lowercased() else { return }
        if search.isEmpty {
            searchedBanks = banks
        } else {
            searchedBanks = banks.filter({ $0.title.lowercased().contains(search) })
        }
    }
    
    // MARK: - API Methods
    private func loadBanks() {
        view.setLoadingState(.loading)
        selectBankAPIClient
            .getBanks()
            .observe { [weak self] signal in
                guard let self = self else { return }

                switch signal {
                case .next(let response):
                    self.didRetry = false
                    self.handleResponse(response)
                case .failed(let error):
                    self.handleError(
                        error: error,
                        retryAction: { [weak self] in self?.loadBanks() })
                default:
                    return
                }

                self.view.setLoadingState(.ready)
            }
            .dispose(in: bag)
    }
    
    private func selectBank(_ bank: DSListItemViewModel) {
        guard let processId = authService.getProcessId(), let bankId = bank.id else { return }

        view.showProgress()
        analyticsHandler?.trackInitLoginByBankId(bankId: bankId)

        selectBankAPIClient
            .getAuthUrl(bankId: bankId, processId: processId)
            .observe { [weak self] signal in
                guard let self = self else { return }

                switch signal {
                case .next(let response):
                    self.handleSelectionResponse(response, bankId: bankId)
                case .failed:
                    self.authErrorRouter.route(in: self.view)
                default:
                    return
                }
                self.view.hideProgress()
            }
            .dispose(in: bag)
    }
    
    // MARK: - Private Methods
    private func handleResponse(_ response: BankListResponse) {
        if response.banks.isEmpty {
            view.showStubMessage(with: StubMessageViewModel(
                icon: Constants.defaultStubIcon,
                title: R.Strings.authorization_bank_id_list_error_title.localized(),
                descriptionText: R.Strings.authorization_bank_id_list_error_details.localized(),
                repeatAction: nil)
            )
            return
        }
        self.banks = response.banks.map {
            let bank = DSListItemViewModel(id: $0.id, title: $0.name, rightIcon: R.Image.out_link.image)
            bank.onClick = { [weak self] in
                self?.selectBank(bank)
            }
            
            bank.accessibilityLabel = R.Strings.auth_accessibility_methods_bank.formattedLocalized(arguments: $0.name)
            return bank
        }
        searchedBanks = banks
    }
    
    private func handleSelectionResponse(_ response: TemplatedResponse<BankIDAuthUrlModel>, bankId: String) {
        switch response {
        case .data(let data):
            view.open(module: BankIdAuthModule(bankId: bankId, authURL: data.authUrl, parentView: self.view, authService: authService))
        case .template(let alert):
            handleTemplate(alert)
        }
    }
    
    private func handleTemplate(_ alert: AlertTemplate) {
        TemplateHandler.handleGlobal(alert) { [weak self] action in
            self?.onClose?(action)
        }
    }
    
    private func handleError(error: NetworkError, retryAction: @escaping Callback) {
        GeneralErrorsHandler.process( error: .init(networkError: error),
                                      with: { [weak self] in
                                        self?.didRetry = true
                                        retryAction()
                                      },
                                      didRetry: didRetry,
                                      in: view
        )
    }
}

// MARK: - Constants
extension SelectBankPresenter {
    private enum Constants {
        static let minimalSearchNameCount = 2
        static let defaultStubIcon = "😔"
    }
}
