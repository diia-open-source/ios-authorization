
import Foundation
import DiiaCommonTypes
@testable import DiiaAuthorization

typealias UserIdentifyHandler = (_ input: UserIdentificationInput) -> Void

final class IdentifyTaskPerformerMock: IdentifyTaskPerformer {

    private let completion: UserIdentifyHandler
    
    init(completion: @escaping UserIdentifyHandler) {
        self.completion = completion
    }
    
    func identify(with input: UserIdentificationInput) {
        completion(input)
    }
}
