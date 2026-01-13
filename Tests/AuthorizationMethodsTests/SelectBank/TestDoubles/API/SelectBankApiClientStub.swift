
import Foundation
import ReactiveKit
import DiiaNetwork
import DiiaCommonTypes
@testable import DiiaAuthorizationMethods

final class SelectBankApiClientStub: SelectBankApiClientProtocol {

    
    private let isAuthUrlExist: Bool
    
    init(isAuthUrlExist: Bool = true) {
        self.isAuthUrlExist = isAuthUrlExist
    }
    
    func getBanks() -> Signal<BankListResponse, NetworkError> {
        return .init(just: .init(banks: [.init(id: "id1",
                                               name: "monobank",
                                               logoUrl: .init(string: "monobank")!,
                                               workable: true),
                                         .init(id: "id2",
                                               name: "privatebank",
                                               logoUrl: .init(string: "privatbank")!,
                                               workable: true)]))
    }
    
    func getAuthUrl(bankId: String, processId: String) -> Signal<TemplatedResponse<BankIDAuthUrlModel>, NetworkError> {
        
        let template = AlertTemplate(type: .middleCenterAlignAlert,
                                     isClosable: true,
                                     data: .init(icon: nil,
                                                 title: "AuthUrl",
                                                 description: nil,
                                                 mainButton: AlertButtonModel(title: nil, icon: nil, action: .ok),
                                                 alternativeButton: nil))
        
        if isAuthUrlExist {
            return .init(just: .data(.init(authUrl: "authUrl")) )
        } else {
            return .init(just: .template(template))
        }
    }
}
