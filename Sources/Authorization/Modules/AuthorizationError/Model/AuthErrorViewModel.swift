import UIKit
import DiiaCommonTypes

enum AuthorizationErrorType {
    case userAuth
    case serviceAuth
}

public struct AuthErrorViewModel {
    let message: String
    let details: ActionText
    let errorType: AuthorizationErrorType
}

public extension AuthErrorViewModel {
    static func userAuth(with callback: Callback?) -> AuthErrorViewModel {
        return AuthErrorViewModel(
            message: R.Strings.authorization_error_title.localized(),
            details: ActionText(
                text: R.Strings.authorization_error_description.localized(),
                attributes: [
                    ActionTextAttribute(
                        range: Constants.localizedRange,
                        attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue],
                        action: callback
                    )
                ]
            ),
            errorType: .userAuth
        )
    }
    
    static var onServiceAuth: AuthErrorViewModel {
        return AuthErrorViewModel(
            message: R.Strings.authorization_error_already_auth.localized(),
            details: ActionText(
                text: R.Strings.authorization_error_logout_first.localized(),
                attributes: []
            ),
            errorType: .serviceAuth
        )
    }
}

extension AuthErrorViewModel {
    private enum Constants {
        static let localizedRange = NSRange(location: 70, length: 16)
    }
}
