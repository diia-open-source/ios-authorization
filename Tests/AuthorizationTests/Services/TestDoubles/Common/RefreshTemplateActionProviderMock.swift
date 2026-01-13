
import Foundation
import DiiaCommonTypes
import DiiaAuthorization

final class RefreshTemplateActionProviderMock: RefreshTemplateActionProvider {
    var callback: Callback?
    
    func refreshTemplateAction(with callback: @escaping Callback) -> (AlertTemplateAction) -> Void {
        self.callback = callback
        return { _ in }
    }
}
