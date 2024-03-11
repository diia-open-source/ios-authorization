import Foundation
import ReactiveKit
import DiiaNetwork
import DiiaCommonTypes

protocol SelectBankApiClientProtocol {
    func getBanks() -> Signal<BankListResponse, NetworkError>
    func getAuthUrl(bankId: String, processId: String) -> Signal<TemplatedResponse<BankIDAuthUrlModel>, NetworkError>
}

class SelectBankAPIClient: ApiClient<SelectBankAPI>, SelectBankApiClientProtocol {
    
    private let token: () -> String
    
    init(context: BankIDAuthorizationNetworkContext) {
        self.token = context.token

        super.init()
        sessionManager = context.session
        SelectBankAPI.host = context.host
        SelectBankAPI.headers = context.headers
    }
    
    func getBanks() -> Signal<BankListResponse, NetworkError> {
        return request(.getBanks)
    }
    
    func getAuthUrl(bankId: String, processId: String) -> Signal<TemplatedResponse<BankIDAuthUrlModel>, NetworkError> {
        return request(.getAuthUrl(target: bankId, processId: processId, token: token()))
    }
}
