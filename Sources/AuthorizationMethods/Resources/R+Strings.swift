
import Foundation

internal enum R {
    enum Strings: String, CaseIterable {
        
        // MARK: - General
        case general_step
        case general_ok

        // MARK: - Accessibility
        case general_accessibility_back_button_label
        case general_accessibility_back_button_step
        case auth_accessibility_bank_selection_bank_hint
        case auth_accessibility_banks_search
        case auth_accessibility_methods_bank
        
        // MARK: - Authorization
        case authorization_bank_id_list_error_title
        case authorization_bank_id_list_error_details
        case authorization_all_banks_info
        case authorization_all_banks_title
        case authorization_bank_id_insecure_title
        case authorization_bank_id_insecure_description
        case authorization_search
        
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
