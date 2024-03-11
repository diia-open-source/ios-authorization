import Foundation

internal extension R {
    enum Strings: String, CaseIterable {
        
        // MARK: - General
        case general_number_copied
        
        case diia_id_identify_please
        
        // MARK: - Authorization
        case authorization_error_title
        case authorization_error_description
        case authorization_error_button_title
        case authorization_stay_in_app
        case authorization_error_already_auth
        case authorization_error_logout_first
        case authorization_nfc
        case auth_methods_bankId
        case auth_methods_monobank
        case auth_methods_privatBank
        
        // MARK: - Accessibility
        case general_accessibility_close
        
        case auth_accessibility_methods_title_hint
        case auth_accessibility_methods_close_hint
        case auth_accessibility_methods_bank
        
        // MARK: - Menu
        case menu_copy_uid
        case menu_logout
        case menu_logout_title
        case menu_logout_message
        case menu_logout_cancel
        
        // MARK: - Errors
        
        func localized() -> String {
            let localized = NSLocalizedString(rawValue, bundle: Bundle.module, comment: "")
            return localized
        }
        
        func formattedLocalized(arguments: CVarArg...) -> String {
            let localized = NSLocalizedString(rawValue, bundle: Bundle.module, comment: "")
            return String(format: localized, arguments)
        }
    }
}
