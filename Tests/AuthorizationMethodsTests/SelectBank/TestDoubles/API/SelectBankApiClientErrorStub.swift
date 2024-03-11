import Foundation
import ReactiveKit
import DiiaNetwork
import DiiaCommonTypes
@testable import DiiaAuthorizationMethods

final class SelectBankApiClientErrorStub: SelectBankApiClientProtocol {

    
    private let isGetAuthUrlUnderTest: Bool
    
    init(isGetAuthUrlUnderTest: Bool = false) {
        self.isGetAuthUrlUnderTest = isGetAuthUrlUnderTest
    }
    
    func getBanks() -> Signal<BankListResponse, NetworkError> {
        return isGetAuthUrlUnderTest ? .init(just: .init(banks: [.init(id: "id1",
                                                                       name: "monobank",
                                                                       logoUrl: .init(string: "monobank")!,
                                                                       workable: true)])) : .failed(.noData)
    }
    
    func getAuthUrl(bankId: String, processId: String) -> Signal<TemplatedResponse<BankIDAuthUrlModel>, NetworkError> {
        return .failed(.noData)
    }
    
}
