
import Foundation

public struct BankModel: Decodable {
    let id: String
    let name: String
    let logoUrl: URL
    let workable: Bool
}

public struct BankListResponse: Decodable {
    let banks: [BankModel]
}
