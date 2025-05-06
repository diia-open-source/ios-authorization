import UIKit
import DiiaMVPModule
import DiiaAuthorization
import DiiaCommonTypes

public class BiometryRequestViewModel {
    
    // MARK: - Properties
    let title: String
    let description: String
    let icon: UIImage?
    let authFlow: AuthFlow
    let completionHandler: (Bool, BaseView) -> Void
    
    // MARK: - Init
    public init(
        title: String,
        description: String,
        icon: UIImage?,
        authFlow: AuthFlow,
        completionHandler: @escaping (Bool, BaseView) -> Void
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.authFlow = authFlow
        self.completionHandler = completionHandler
    }
}
