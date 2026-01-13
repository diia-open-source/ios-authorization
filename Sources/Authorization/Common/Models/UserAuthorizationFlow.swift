
import Foundation
import DiiaMVPModule
import DiiaCommonTypes

public typealias UserAuthorizationFlowCompletion = (BaseView?, AlertTemplateAction?) -> Void

// MARK: - UserAuthorizationFlow
/// Used for navigation
public enum UserAuthorizationFlow {
    case login(completionHandler: UserAuthorizationFlowCompletion)
    case prolong(completionHandler: UserAuthorizationFlowCompletion)
    case diiaId(action: DiiaIdAction, completionHandler: UserAuthorizationFlowCompletion)
    case independentVerification(completionHandler: UserAuthorizationFlowCompletion)
    
    func onCompletion(in view: BaseView? = nil, action: AlertTemplateAction? = nil) {
        switch self {
        case .prolong(let callback): callback(view, action)
        case .diiaId(_, let callback): callback(view, action)
        case .login(let callback): callback(view, action)
        case .independentVerification(let callback): callback(view, action)
        }
    }
}
